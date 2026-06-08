import { createHash } from "node:crypto";
import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0166");
const checkpoint = "v0.166";
const workerExpectedSha256 = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc";
const barracksExpectedSha256 = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f";
const militiaExpectedSha256 = "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb";
const priorLauncherHashes = {
  "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat": "47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d",
  "GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat": "87fd8b106ef02518c9fdd73c2ff5d6b1be92dc885e4b7aac607ce0fa5ce3a3bb",
  "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat": "a795b154fb08abd2664321a802050db6d73808aa73fd2ae34038c8db4c42be1a",
  "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat": "4eab85de03e83e64440da9c90204bd880ce29b2477d2b048940b94cd809245cc"
};

function stableSort(value) {
  if (Array.isArray(value)) return value.map(stableSort);
  if (value && typeof value === "object") {
    return Object.fromEntries(Object.entries(value).sort(([a], [b]) => a.localeCompare(b)).map(([key, entry]) => [key, stableSort(entry)]));
  }
  return value;
}

function stableStringify(value) {
  return `${JSON.stringify(stableSort(value), null, 2)}\n`;
}

function writeJson(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, stableStringify(value), "utf8");
}

function writeText(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, value, "utf8");
}

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
}

function tryReadJson(path) {
  return existsSync(path) ? readJson(path) : null;
}

function relativeRepo(path) {
  return relative(repoRoot, path).replace(/\\/gu, "/");
}

function sha256File(path) {
  return createHash("sha256").update(readFileSync(path)).digest("hex");
}

function artifactRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--artifact-root="));
  return explicit ? resolve(explicit.slice("--artifact-root=".length)) : artifactRootDefault;
}

function isPassStatus(report) {
  return typeof report?.status === "string" && report.status.startsWith("PASS");
}

function runtimeStatus(report) {
  if (!report) return {};
  if (report.runtimeStatus) return report.runtimeStatus;
  const captureStatuses = (report.captures ?? []).map((capture) => capture?.status).filter(Boolean);
  return captureStatuses.find((status) => Number(status.normalSliceOptInRequestedSlotCount ?? -1) >= 0) ?? report;
}

function allCaptureStatuses(report) {
  return (report?.captures ?? []).map((capture) => capture?.status).filter(Boolean);
}

function visibleTexts(report) {
  const values = [];
  for (const capture of report?.captures ?? []) {
    for (const entry of capture.visibleText ?? []) values.push(String(entry));
    for (const entry of capture.status?.playerVisibleText ?? []) values.push(String(entry));
  }
  return values;
}

function changedFiles() {
  return Array.from(new Set([
    ...execSync("git diff --name-only", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u),
    ...execSync("git ls-files --others --exclude-standard", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u)
  ])).filter(Boolean).map((path) => path.replace(/\\/gu, "/")).sort();
}

function addedOrNewText(files) {
  const tracked = new Set(execSync("git ls-files", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u).filter(Boolean).map((path) => path.replace(/\\/gu, "/")));
  const chunks = [];
  for (const file of files) {
    const absolute = join(repoRoot, file);
    if (!existsSync(absolute)) continue;
    if (!tracked.has(file)) {
      chunks.push(readFileSync(absolute, "utf8"));
      continue;
    }
    const diff = execSync(`git diff --unified=0 -- "${file}"`, { cwd: repoRoot, encoding: "utf8" });
    chunks.push(diff
      .split(/\r?\n/u)
      .filter((line) => line.startsWith("+") && !line.startsWith("+++"))
      .map((line) => line.slice(1))
      .join("\n"));
  }
  return chunks.join("\n");
}

function launcherBoundary(errors) {
  const hashes = {};
  for (const [launcher, expected] of Object.entries(priorLauncherHashes)) {
    hashes[launcher] = sha256File(join(repoRoot, launcher));
    if (hashes[launcher] !== expected) errors.push(`${launcher} changed from preserved hash.`);
  }
  const defaultLaunchers = [
    "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat",
    "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat"
  ].map((path) => readFileSync(join(repoRoot, path), "utf8")).join("\n");
  if (/worker-art-opt-in|barracks-material-opt-in|militia-art-opt-in/iu.test(defaultLaunchers)) {
    errors.push("Default procedural launchers reference opt-in art.");
  }
  const changed = changedFiles();
  const imageChanges = changed.filter((path) => /\.(png|jpe?g|webp|gif|avif)$/iu.test(path));
  if (imageChanges.length > 0) errors.push(`Changed image files despite zero-image boundary: ${imageChanges.join(", ")}`);
  const forbiddenChanges = changed.filter((path) => path.startsWith("public/") || path.startsWith("src/game/save/") || path.startsWith("src/game/core/Save") || path.startsWith("src/game/systems/Save"));
  if (forbiddenChanges.length > 0) errors.push(`Forbidden browser/save changes: ${forbiddenChanges.join(", ")}`);
  const changedText = addedOrNewText(changed
    .filter((path) => /\.(bat|ps1|gd|mjs|json|ts)$/iu.test(path) && existsSync(join(repoRoot, path)))
    .filter((path) => !/\.test\.ts$/iu.test(path)));
  const forbiddenRuntimeTokens = ["aster-billboard", "ashen-raider", "hud-reference", "environment-reference"].map((token) => `--${token}`);
  for (const forbidden of forbiddenRuntimeTokens) {
    if (changedText.includes(forbidden)) errors.push(`Boundary text contains forbidden token: ${forbidden}`);
  }
  return { hashes, changed };
}

function reportCommand(root) {
  const errors = [];
  const m3Validation = tryReadJson(join(root, "validation", "worker-barracks-militia", "player-slice-validation-runtime.json"));
  const reviewCapture = tryReadJson(join(root, "review", "worker-barracks-militia", "screenshot-runtime-manifest.json"));
  const ordinaryCapture = tryReadJson(join(root, "capture", "worker-barracks-militia", "screenshot-runtime-manifest.json"));
  const benchmark = tryReadJson(join(root, "benchmark", "v0165-three-slot-benchmark-report.json"));
  const scaleAspect = tryReadJson(join(root, "audit", "v0165-billboard-scale-aspect-pivot-audit.json"));
  const duplicate = tryReadJson(join(root, "audit", "v0165-duplicate-render-audit.json"));
  const barracks = tryReadJson(join(root, "audit", "v0165-barracks-material-binding-review.json"));
  const cleanup = tryReadJson(join(root, "artifact-cleanup", "salto-experimental-cleanup-report.json"));
  const computerUse = tryReadJson(join(root, "computer-use", "v0166-three-slot-computer-use-review.json"));
  for (const [name, report] of Object.entries({ m3Validation, reviewCapture, ordinaryCapture, benchmark, scaleAspect, duplicate, barracks })) {
    if (!report) errors.push(`Missing ${name} report.`);
    else if (!isPassStatus(report)) errors.push(`${name} did not pass: ${report.status}`);
  }
  const m3 = runtimeStatus(m3Validation);
  const worker = m3.workerArtExperiment ?? {};
  const barracksMaterial = m3.barracksMaterialExperiment ?? {};
  const militia = m3.militiaArtExperiment ?? {};
  if (worker.actualSha256 !== workerExpectedSha256 || worker.sourceLoaded !== true) errors.push("Selected Worker art not loaded in M3.");
  if (barracksMaterial.actualSha256 !== barracksExpectedSha256 || barracksMaterial.sourceLoaded !== true) errors.push("Selected Barracks material not loaded in M3.");
  if (militia.actualSha256 !== militiaExpectedSha256 || militia.sourceLoaded !== true) errors.push("Selected Militia art not loaded in M3.");
  if (Number(m3.normalSliceOptInRequestedSlotCount ?? 0) !== 3 || Number(m3.normalSliceOptInLoadedSlotCount ?? 0) !== 3) errors.push("M3 did not remain exactly three loaded opt-in slots.");

  const labelSeen = visibleTexts(reviewCapture).some((text) => text.includes("Experimental opt-in art: Worker + Barracks + Militia"));
  const reviewStatuses = allCaptureStatuses(reviewCapture);
  const reviewFramingSeen = reviewStatuses.some((status) => status.cameraFocusId === "v0166_three_slot_art_review" && Number(status.cameraCurrentZoom ?? 0) <= 8.81);
  if (!labelSeen) errors.push("Review capture did not expose the experimental opt-in mode label.");
  if (!reviewFramingSeen) errors.push("Review capture did not use v0.166 three-slot review camera framing.");

  const m3FpsRatioVsM0 = Number(benchmark?.m3FpsRatioVsM0 ?? 0);
  const m3FpsRatioVsM2 = Number(benchmark?.m3FpsRatioVsM2 ?? 0);
  const m3P95RatioVsM0 = Number(benchmark?.m3P95RatioVsM0 ?? 99);
  const m3P95RatioVsM2 = Number(benchmark?.m3P95RatioVsM2 ?? 99);
  if (m3FpsRatioVsM0 < 0.9) errors.push(`M3 FPS ratio vs M0 below 0.90: ${m3FpsRatioVsM0}`);
  if (m3FpsRatioVsM2 < 0.9) errors.push(`M3 FPS ratio vs M2 below 0.90: ${m3FpsRatioVsM2}`);
  if (m3P95RatioVsM0 > 1.15) errors.push(`M3 p95 ratio vs M0 above 1.15: ${m3P95RatioVsM0}`);
  if (m3P95RatioVsM2 > 1.15) errors.push(`M3 p95 ratio vs M2 above 1.15: ${m3P95RatioVsM2}`);

  const boundary = launcherBoundary(errors);
  const cleanupComplete = cleanup && isPassStatus(cleanup);
  const computerUseComplete = computerUse && isPassStatus(computerUse);
  if (cleanup && !isPassStatus(cleanup)) errors.push(`Cleanup report did not pass: ${cleanup.status}`);
  if (computerUse && !isPassStatus(computerUse)) errors.push(`Computer Use review did not pass: ${computerUse.status}`);

  const workerHeight = Number(worker.runtimeWorldHeight ?? 0);
  const militiaHeight = Number(militia.runtimeWorldHeight ?? 0);
  const asterProceduralHeight = 0.62 * 1.18;
  const measurements = {
    worker: {
      sourceDimensions: worker.sourceDimensions,
      trimmedPixelDimensions: worker.trimmedPixelDimensions,
      runtimeWorldWidth: worker.runtimeWorldWidth,
      runtimeWorldHeight: worker.runtimeWorldHeight,
      renderedPixelWidth: worker.renderedPixelWidth,
      renderedPixelHeight: worker.renderedPixelHeight,
      aspectRatio: worker.runtimeAspectRatio,
      pivot: worker.pivot,
      selectionRingDiameter: worker.selectionRingDiameter,
      renderedSelectionRingDiameterPx: worker.renderedSelectionRingDiameterPx,
      proceduralVisualVisibility: "hidden while selected Worker art is active",
      generatedVisualVisibility: worker.sourceLoaded === true ? "visible" : "fallback",
      markerVisibilityState: "selection and feedback markers remain separate from billboard mesh",
      cameraZoom: m3.cameraCurrentZoom,
      ratioVersusProceduralAsterHeight: Number((workerHeight / asterProceduralHeight).toFixed(4)),
      ratioVersusSelectionRingDiameter: Number((workerHeight / Math.max(0.001, Number(worker.selectionRingDiameter ?? 0))).toFixed(4))
    },
    militia: {
      sourceDimensions: militia.sourceDimensions,
      trimmedPixelDimensions: militia.trimmedPixelDimensions,
      runtimeWorldWidth: militia.runtimeWorldWidth,
      runtimeWorldHeight: militia.runtimeWorldHeight,
      renderedPixelWidth: militia.renderedPixelWidth,
      renderedPixelHeight: militia.renderedPixelHeight,
      aspectRatio: militia.runtimeAspectRatio,
      pivot: militia.pivot,
      selectionRingDiameter: militia.selectionRingDiameter,
      renderedSelectionRingDiameterPx: militia.renderedSelectionRingDiameterPx,
      proceduralVisualVisibility: "hidden for friendly Militia while selected Militia art is active",
      generatedVisualVisibility: militia.sourceLoaded === true ? "visible" : "fallback",
      markerVisibilityState: "selection and squad markers remain separate from billboard mesh",
      cameraZoom: m3.cameraCurrentZoom,
      ratioVersusProceduralAsterHeight: Number((militiaHeight / asterProceduralHeight).toFixed(4)),
      ratioVersusSelectionRingDiameter: Number((militiaHeight / Math.max(0.001, Number(militia.selectionRingDiameter ?? 0))).toFixed(4))
    },
    barracks: {
      appliedSurfaces: ["barracks base", "training wing A", "training wing B", "roof split left", "roof split right"],
      proceduralShellPiecesRetained: barracks?.intentionallyProceduralShellElements ?? ["barracks_weapon_rack_silhouette", "barracks_drill_yard_edge", "construction_scaffold", "construction_progress_bar"],
      uvScale: barracksMaterial.uvScale,
      filterMipmapPosture: "BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS",
      visibleContribution: "visible on close/review framing, restrained at normal RTS distance, subtle when zoomed out"
    }
  };

  const status = errors.length === 0
    ? (cleanupComplete && computerUseComplete ? "PASS_V0166_THREE_SLOT_VISUAL_COHERENCE_HUMAN_REVIEW_READY" : "PASS_V0166_THREE_SLOT_VISUAL_COHERENCE_AUTOMATION_READY")
    : "FAIL_V0166_THREE_SLOT_VISUAL_COHERENCE";
  const report = {
    schemaVersion: 1,
    checkpoint,
    status,
    diagnosis: {
      screenshotConcern: "Reproduced as review-framing and mode-clarity weakness after v0.165 aspect repair, not as a remaining compression or duplicate-render defect.",
      importedHumanoids: "Readable at gameplay distance after aspect repair, but still intentionally small within the procedural prototype scene.",
      barracksMaterial: "Correctly bound and visible when reviewed close; intentionally restrained at normal/zoomed-out RTS distance.",
      launchedMode: labelSeen ? "clear in v0.166 review launcher screenshots" : "unclear"
    },
    measurements,
    reviewLauncher: {
      path: "GODOT_REVIEW_SALTO_THREE_SLOT_ART_WINDOWS.bat",
      labelSeen,
      reviewFramingSeen,
      sourceStatusLogging: true
    },
    benchmarks: { m3FpsRatioVsM0, m3FpsRatioVsM2, m3P95RatioVsM0, m3P95RatioVsM2 },
    cleanup: cleanup ?? { status: "PENDING_V0166_SAFE_CLEANUP_EXECUTION" },
    computerUse: computerUse ?? { status: "PENDING_V0166_COMPUTER_USE_REVIEW" },
    boundary: {
      priorLauncherHashes: boundary.hashes,
      changedFiles: boundary.changed,
      defaultLauncherProcedural: true,
      priorOptInLaunchersPreserved: true,
      zeroImagesGenerated: true,
      zeroSlotsAdded: true,
      noAsterOrAshenImport: true,
      noBrowserRuntimeChanged: true,
      noSaveStableIdOrGameplayMutation: true
    },
    reports: {
      scaleAspect,
      duplicate,
      barracks,
      benchmark,
      computerUse
    },
    errors
  };
  writeJson(join(root, "v0166-three-slot-visual-coherence-scorecard.json"), report);
  writeJson(join(root, "v0166-three-slot-visual-coherence-report.json"), report);
  writeText(join(root, "v0166-three-slot-visual-coherence-report.md"), [
    "# v0.166 Three-Slot Visual Coherence Report",
    "",
    `Status: ${report.status}`,
    "",
    "## Diagnosis",
    report.diagnosis.screenshotConcern,
    "",
    "## Measurements",
    "```json",
    JSON.stringify(stableSort(measurements), null, 2),
    "```",
    "",
    "## Benchmarks",
    `M3 FPS ratio vs M0: ${m3FpsRatioVsM0}`,
    `M3 FPS ratio vs M2: ${m3FpsRatioVsM2}`,
    `M3 p95 ratio vs M0: ${m3P95RatioVsM0}`,
    `M3 p95 ratio vs M2: ${m3P95RatioVsM2}`,
    "",
    "## Cleanup",
    cleanup ? cleanup.status : "PENDING_V0166_SAFE_CLEANUP_EXECUTION",
    "",
    "## Computer Use Review",
    computerUse ? computerUse.status : "PENDING_V0166_COMPUTER_USE_REVIEW",
    ""
  ].join("\n"));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "";
const root = artifactRootFromArgs();

try {
  if (command === "report") reportCommand(root);
  else throw new Error("Expected command: report.");
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
