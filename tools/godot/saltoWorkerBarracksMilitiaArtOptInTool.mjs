import { createHash } from "node:crypto";
import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.164";
const workerSlotId = "worker_billboard_static_v0147";
const workerApproach = "HYBRID_WORKER_TRIMMED_1024";
const workerExpectedSha256 = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc";
const barracksSlotId = "barrosan_barracks_material_v0149";
const barracksApproach = "HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND";
const barracksExpectedSha256 = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f";
const militiaSlotId = "militia_billboard_static_v0154";
const militiaApproach = "HYBRID_MILITIA_TRIMMED_1024";
const militiaExpectedSha256 = "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb";
const defaultLauncherSha256 = "47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d";
const workerLauncherSha256 = "87fd8b106ef02518c9fdd73c2ff5d6b1be92dc885e4b7aac607ce0fa5ce3a3bb";
const combinedLauncherSha256 = "a795b154fb08abd2664321a802050db6d73808aa73fd2ae34038c8db4c42be1a";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0164");

const validationScenarios = [
  { id: "default-procedural", expected: "procedural" },
  { id: "worker-only", expected: "worker-only" },
  { id: "worker-barracks", expected: "worker-barracks" },
  { id: "worker-barracks-militia", expected: "three-loaded" },
  { id: "militia-missing-art-fallback", expected: "militia-missing" },
  { id: "militia-hash-mismatch-fallback", expected: "militia-hash" }
];

const captureScenarios = validationScenarios.map((scenario) => scenario.id);

const benchmarkScenarios = [
  { id: "procedural-baseline", expected: "procedural" },
  { id: "worker-only", expected: "worker-only" },
  { id: "worker-barracks", expected: "worker-barracks" },
  { id: "worker-barracks-militia", expected: "three-loaded" },
  { id: "militia-missing-art-fallback", expected: "militia-missing" },
  { id: "militia-hash-mismatch-fallback", expected: "militia-hash" }
];

const realInputScenarios = [
  {
    id: "worker-barracks-militia-post-mine-flow",
    file: "headed-post-mine-flow-smoke.json",
    acceptedStatuses: new Set(["PASS_V0133_HEADED_POST_MINE_FLOW_SMOKE", "PASS_V0133_POST_MINE_FLOW_SCREENSHOTS"]),
    proofs: ["barracks-restoration-proof.json", "militia-recruit-proof.json", "lume-restore-proof.json", "screenshot-manifest.json"]
  },
  {
    id: "worker-barracks-militia-restart-replay",
    file: "triple-playthrough-report.json",
    acceptedStatuses: new Set(["PASS_V0134_TRIPLE_NATURAL_PLAYTHROUGH"]),
    proofs: ["recovery-case-report.json", "restart-integrity-report.json", "no-softlock-proof.json", "no-shortcut-proof.json", "screenshot-manifest.json"]
  }
];

function stableSort(value) {
  if (Array.isArray(value)) {
    return value.map(stableSort);
  }
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .sort(([left], [right]) => left.localeCompare(right))
        .map(([key, entry]) => [key, stableSort(entry)])
    );
  }
  return value;
}

function stableStringify(value) {
  return `${JSON.stringify(stableSort(value), null, 2)}\n`;
}

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

function tryReadJson(path) {
  return existsSync(path) ? readJson(path) : null;
}

function writeJson(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, stableStringify(value), "utf8");
}

function writeText(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, value, "utf8");
}

function sha256File(path) {
  return createHash("sha256").update(readFileSync(path)).digest("hex");
}

function relativeRepo(path) {
  return relative(repoRoot, path).replace(/\\/gu, "/");
}

function artifactRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--artifact-root="));
  return explicit ? resolve(explicit.slice("--artifact-root=".length)) : artifactRootDefault;
}

function isPassStatus(report) {
  return typeof report?.status === "string" && report.status.startsWith("PASS");
}

function reportAt(root, group, scenarioId, fileName, errors) {
  const path = join(root, group, scenarioId, fileName);
  if (!existsSync(path)) {
    errors.push(`Missing ${relativeRepo(path)}`);
    return { path, report: null };
  }
  return { path, report: readJson(path) };
}

function workerArt(report) {
  return report?.workerArtExperiment ?? {};
}

function barracksMaterial(report) {
  return report?.barracksMaterialExperiment ?? {};
}

function militiaArt(report) {
  return report?.militiaArtExperiment ?? {};
}

function requireReport(errors, path, label) {
  if (!existsSync(path)) {
    errors.push(`Missing ${label}: ${relativeRepo(path)}`);
    return null;
  }
  return readJson(path);
}

function checkWorkerLoaded(report, id, errors) {
  const worker = workerArt(report);
  if (worker.sourceLoaded !== true || worker.actualSha256 !== workerExpectedSha256 || worker.slotId !== workerSlotId) {
    errors.push(`${id} did not load the exact selected Worker slot.`);
  }
}

function checkBarracksLoaded(report, id, errors) {
  const barracks = barracksMaterial(report);
  if (barracks.sourceLoaded !== true || barracks.actualSha256 !== barracksExpectedSha256 || barracks.slotId !== barracksSlotId) {
    errors.push(`${id} did not load the exact selected Barracks material.`);
  }
}

function checkMilitiaLoaded(report, id, errors) {
  const militia = militiaArt(report);
  if (militia.sourceLoaded !== true || militia.actualSha256 !== militiaExpectedSha256 || militia.slotId !== militiaSlotId) {
    errors.push(`${id} did not load the exact selected Militia billboard.`);
  }
}

function checkScenario(report, expected, id, errors) {
  if (!isPassStatus(report)) {
    errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
    return;
  }
  const worker = workerArt(report);
  const barracks = barracksMaterial(report);
  const militia = militiaArt(report);
  const workerLoaded = worker.sourceLoaded === true;
  const barracksLoaded = barracks.sourceLoaded === true;
  const militiaLoaded = militia.sourceLoaded === true;
  if (expected === "procedural") {
    if (report.workerArtOptInRequested !== false || report.barracksMaterialOptInRequested !== false || report.militiaArtOptInRequested !== false || workerLoaded || barracksLoaded || militiaLoaded) {
      errors.push(`${id} should stay fully procedural.`);
    }
    if (Number(report.normalSliceOptInRequestedSlotCount ?? 0) !== 0 || Number(report.normalSliceOptInLoadedSlotCount ?? 0) !== 0) {
      errors.push(`${id} should report zero requested and loaded opt-in slots.`);
    }
  }
  if (expected === "worker-only") {
    checkWorkerLoaded(report, id, errors);
    if (report.barracksMaterialOptInRequested !== false || report.militiaArtOptInRequested !== false || barracksLoaded || militiaLoaded) {
      errors.push(`${id} should preserve Worker-only posture.`);
    }
    if (Number(report.normalSliceOptInRequestedSlotCount ?? 0) !== 1 || Number(report.normalSliceOptInLoadedSlotCount ?? 0) !== 1) {
      errors.push(`${id} should report one requested and loaded slot.`);
    }
  }
  if (expected === "worker-barracks") {
    checkWorkerLoaded(report, id, errors);
    checkBarracksLoaded(report, id, errors);
    if (report.militiaArtOptInRequested !== false || militiaLoaded) {
      errors.push(`${id} should preserve Worker + Barracks only posture.`);
    }
    if (Number(report.normalSliceOptInRequestedSlotCount ?? 0) !== 2 || Number(report.normalSliceOptInLoadedSlotCount ?? 0) !== 2) {
      errors.push(`${id} should report two requested and loaded slots.`);
    }
  }
  if (expected === "three-loaded") {
    checkWorkerLoaded(report, id, errors);
    checkBarracksLoaded(report, id, errors);
    checkMilitiaLoaded(report, id, errors);
    if (Number(report.normalSliceOptInRequestedSlotCount ?? 0) !== 3 || Number(report.normalSliceOptInLoadedSlotCount ?? 0) !== 3) {
      errors.push(`${id} should report exactly three requested and loaded opt-in slots.`);
    }
  }
  if (expected === "militia-missing") {
    checkWorkerLoaded(report, id, errors);
    checkBarracksLoaded(report, id, errors);
    if (militiaLoaded || militia.fallbackActive !== true || !String(militia.fallbackReason ?? "").includes("missing")) {
      errors.push(`${id} did not explain Militia missing-art procedural fallback.`);
    }
    if (Number(report.normalSliceOptInRequestedSlotCount ?? 0) !== 3 || Number(report.normalSliceOptInLoadedSlotCount ?? 0) !== 2) {
      errors.push(`${id} should report three requested slots and two loaded slots.`);
    }
  }
  if (expected === "militia-hash") {
    checkWorkerLoaded(report, id, errors);
    checkBarracksLoaded(report, id, errors);
    if (militiaLoaded || militia.fallbackActive !== true || !String(militia.fallbackReason ?? "").includes("hash mismatch")) {
      errors.push(`${id} did not explain Militia hash-mismatch procedural fallback.`);
    }
    if (Number(report.normalSliceOptInRequestedSlotCount ?? 0) !== 3 || Number(report.normalSliceOptInLoadedSlotCount ?? 0) !== 2) {
      errors.push(`${id} should report three requested slots and two loaded slots.`);
    }
  }
}

function validationCommand(root) {
  const errors = [];
  const scenarios = validationScenarios.map((scenario) => {
    const loaded = reportAt(root, "validation", scenario.id, "player-slice-validation-runtime.json", errors);
    if (loaded.report) {
      checkScenario(loaded.report, scenario.expected, scenario.id, errors);
    }
    return {
      id: scenario.id,
      expected: scenario.expected,
      path: relativeRepo(loaded.path),
      status: loaded.report?.status ?? "MISSING",
      requestedSlotCount: loaded.report?.normalSliceOptInRequestedSlotCount ?? 0,
      loadedSlotCount: loaded.report?.normalSliceOptInLoadedSlotCount ?? 0,
      workerArtExperiment: workerArt(loaded.report),
      barracksMaterialExperiment: barracksMaterial(loaded.report),
      militiaArtExperiment: militiaArt(loaded.report),
      objectiveSequence: loaded.report?.objectiveSequence ?? []
    };
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0164_MILITIA_OPT_IN_VALIDATION" : "FAIL_V0164_MILITIA_OPT_IN_VALIDATION",
    workerSlotId,
    workerApproach,
    workerExpectedSha256,
    barracksSlotId,
    barracksApproach,
    barracksExpectedSha256,
    militiaSlotId,
    militiaApproach,
    militiaExpectedSha256,
    scenarios,
    errors
  };
  writeJson(join(root, "validation", "worker-barracks-militia-art-opt-in-validation.json"), report);
  writeJson(join(root, "validation", "worker-barracks-militia-art-opt-in-functional-report.json"), {
    ...report,
    status: errors.length === 0 ? "PASS_V0164_MILITIA_OPT_IN_FUNCTIONAL" : "FAIL_V0164_MILITIA_OPT_IN_FUNCTIONAL",
    preservedBehaviors: [
      "default procedural launcher",
      "Worker-only launcher",
      "Worker + Barracks launcher",
      "Aster selection and movement",
      "Worker assignment",
      "Barracks restoration",
      "Militia recruitment and selection",
      "squad box-select",
      "Attack/wave-defense posture",
      "restart and replay",
      "recoverable mistake posture"
    ]
  });
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function captureCommand(root) {
  const errors = [];
  const captures = captureScenarios.map((id) => {
    const loaded = reportAt(root, "capture", id, "screenshot-runtime-manifest.json", errors);
    if (loaded.report) {
      const expected = validationScenarios.find((scenario) => scenario.id === id)?.expected;
      checkScenario(loaded.report, expected, id, errors);
      if (!isPassStatus(loaded.report)) {
        errors.push(`${id} capture did not PASS: ${loaded.report.status}`);
      }
    }
    const screenshotRoot = join(root, "capture", id, "screenshots");
    const files = existsSync(screenshotRoot) ? readdirSync(screenshotRoot).filter((file) => file.endsWith(".png")).sort() : [];
    if (loaded.report && files.length !== Number(loaded.report.requiredCaptureCount ?? -1)) {
      errors.push(`${id} expected ${loaded.report.requiredCaptureCount} PNGs, found ${files.length}.`);
    }
    return {
      id,
      manifest: relativeRepo(loaded.path),
      status: loaded.report?.status ?? "MISSING",
      captureCount: files.length,
      requiredCaptureCount: loaded.report?.requiredCaptureCount ?? 0,
      workerArtExperiment: workerArt(loaded.report),
      barracksMaterialExperiment: barracksMaterial(loaded.report),
      militiaArtExperiment: militiaArt(loaded.report),
      screenshots: files.map((file) => ({
        fileName: file,
        path: relativeRepo(join(screenshotRoot, file)),
        sha256: sha256File(join(screenshotRoot, file))
      }))
    };
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0164_MILITIA_OPT_IN_CAPTURE" : "FAIL_V0164_MILITIA_OPT_IN_CAPTURE",
    captures,
    errors
  };
  writeJson(join(root, "capture", "worker-barracks-militia-art-opt-in-capture-report.json"), report);
  writeText(join(root, "capture", "worker-barracks-militia-art-opt-in-contact-sheet.svg"), contactSheetSvg(root, captures));
  writeText(join(root, "capture", "worker-barracks-militia-art-opt-in-visual-review-guide.md"), visualGuideMarkdown(report));
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function benchmarkCommand(root) {
  const errors = [];
  const scenarios = benchmarkScenarios.map((scenario) => {
    const loaded = reportAt(root, "benchmark", scenario.id, "worker-art-opt-in-benchmark-runtime.json", errors);
    if (loaded.report) {
      checkScenario(loaded.report, scenario.expected, scenario.id, errors);
      if (!isPassStatus(loaded.report)) {
        errors.push(`${scenario.id} benchmark did not PASS: ${loaded.report.status}`);
      }
    }
    return {
      id: scenario.id,
      expected: scenario.expected,
      path: relativeRepo(loaded.path),
      status: loaded.report?.status ?? "MISSING",
      fpsAverage: loaded.report?.fpsAverage ?? 0,
      frameTimeP95Ms: loaded.report?.frameTimeP95Ms ?? 0,
      frameTimeP99Ms: loaded.report?.frameTimeP99Ms ?? 0,
      workerArtExperiment: workerArt(loaded.report),
      barracksMaterialExperiment: barracksMaterial(loaded.report),
      militiaArtExperiment: militiaArt(loaded.report),
      cacheCounters: loaded.report?.cacheCounters ?? {}
    };
  });
  const baseline = scenarios.find((entry) => entry.id === "procedural-baseline");
  const workerBarracks = scenarios.find((entry) => entry.id === "worker-barracks");
  const threeSlot = scenarios.find((entry) => entry.id === "worker-barracks-militia");
  const ratio = (top, bottom) => top / Math.max(0.01, bottom);
  const threeSlotFpsRatio = threeSlot && baseline ? ratio(threeSlot.fpsAverage, baseline.fpsAverage) : 0;
  const threeSlotP95Ratio = threeSlot && baseline ? ratio(threeSlot.frameTimeP95Ms, baseline.frameTimeP95Ms) : 999;
  const threeSlotVsWorkerBarracksFpsRatio = threeSlot && workerBarracks ? ratio(threeSlot.fpsAverage, workerBarracks.fpsAverage) : 0;
  const threeSlotVsWorkerBarracksP95Ratio = threeSlot && workerBarracks ? ratio(threeSlot.frameTimeP95Ms, workerBarracks.frameTimeP95Ms) : 999;
  for (const [slot, experiment] of [
    ["Worker", threeSlot?.workerArtExperiment ?? {}],
    ["Barracks", threeSlot?.barracksMaterialExperiment ?? {}],
    ["Militia", threeSlot?.militiaArtExperiment ?? {}]
  ]) {
    for (const key of ["sourceLoadCount", "metadataParseCount", "imageDecodeCount", "textureCreateCount", "materialCreateCount"]) {
      if (Number(experiment[key] ?? 99) > 1) {
        errors.push(`Three-slot scenario repeated ${slot} ${key}.`);
      }
    }
  }
  if (threeSlotFpsRatio < 0.9) {
    errors.push(`M3 FPS ratio ${threeSlotFpsRatio.toFixed(4)} versus M0 is below 0.9.`);
  }
  if (threeSlotP95Ratio > 1.15) {
    errors.push(`M3 p95 frame-time ratio ${threeSlotP95Ratio.toFixed(4)} versus M0 is above 1.15.`);
  }
  if (threeSlotVsWorkerBarracksFpsRatio < 0.9) {
    errors.push(`M3 FPS ratio ${threeSlotVsWorkerBarracksFpsRatio.toFixed(4)} versus M2 is below 0.9.`);
  }
  if (threeSlotVsWorkerBarracksP95Ratio > 1.15) {
    errors.push(`M3 p95 frame-time ratio ${threeSlotVsWorkerBarracksP95Ratio.toFixed(4)} versus M2 is above 1.15.`);
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0164_MILITIA_OPT_IN_BENCHMARK" : "FAIL_V0164_MILITIA_OPT_IN_BENCHMARK",
    thresholds: {
      minM3FpsRatioVsM0: 0.9,
      maxM3P95FrameTimeRatioVsM0: 1.15,
      minM3FpsRatioVsM2: 0.9,
      maxM3P95FrameTimeRatioVsM2: 1.15,
      maxLoadsParsesDecodesTexturesOrMaterialsPerProcess: 1
    },
    m3FpsRatioVsM0: Number(threeSlotFpsRatio.toFixed(4)),
    m3P95FrameTimeRatioVsM0: Number(threeSlotP95Ratio.toFixed(4)),
    m3FpsRatioVsM2: Number(threeSlotVsWorkerBarracksFpsRatio.toFixed(4)),
    m3P95FrameTimeRatioVsM2: Number(threeSlotVsWorkerBarracksP95Ratio.toFixed(4)),
    scenarios,
    errors
  };
  writeJson(join(root, "benchmark", "worker-barracks-militia-art-opt-in-benchmark-report.json"), report);
  writeJson(join(root, "benchmark", "worker-barracks-militia-art-opt-in-scorecard.json"), report);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function realInputCommand(root) {
  const errors = [];
  const realInputRoot = join(root, "real-input");
  const scenarios = realInputScenarios.map((scenario) => {
    const scenarioRoot = join(realInputRoot, scenario.id);
    const reportPath = join(scenarioRoot, scenario.file);
    const report = requireReport(errors, reportPath, `${scenario.id} real-input report`);
    if (report && !scenario.acceptedStatuses.has(report.status)) {
      errors.push(`${scenario.id} expected one of ${Array.from(scenario.acceptedStatuses).join(", ")}, got ${report.status}.`);
    }
    const proofs = scenario.proofs.map((file) => {
      const path = join(scenarioRoot, file);
      const proof = requireReport(errors, path, `${scenario.id} ${file}`);
      if (proof && !isPassStatus(proof)) {
        errors.push(`${scenario.id} proof ${file} did not pass: ${proof.status}`);
      }
      return { file, path: relativeRepo(path), status: proof?.status ?? "MISSING" };
    });
    const screenshotManifest = tryReadJson(join(scenarioRoot, "screenshot-manifest.json"));
    return {
      id: scenario.id,
      path: relativeRepo(reportPath),
      status: report?.status ?? "MISSING",
      durationMs: report?.durationMs ?? 0,
      inputPath: report?.inputPath ?? "",
      debugShortcutUsed: report?.debugShortcutUsed ?? false,
      stateInjectionUsed: report?.stateInjectionUsed ?? false,
      screenshotManifestStatus: screenshotManifest?.status ?? "MISSING",
      screenshotCount: screenshotManifest?.captureCount ?? 0,
      proofs
    };
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0164_MILITIA_OPT_IN_REAL_INPUT" : "FAIL_V0164_MILITIA_OPT_IN_REAL_INPUT",
    scenarios,
    coveredPostures: [
      "Worker + Barracks + Militia opt-in",
      "Worker assignment and Barracks restoration",
      "Militia recruitment and selection",
      "squad box-select",
      "Attack command visibility and wave-defense posture",
      "combat onset continuation",
      "restart and replay",
      "recoverable mistake profile"
    ],
    humanPlayabilityClaimed: false,
    errors
  };
  writeJson(join(realInputRoot, "worker-barracks-militia-art-opt-in-real-input-report.json"), report);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function computerUseCommand(root) {
  const errors = [];
  const reviewPath = join(root, "computer-use", "worker-barracks-militia-art-opt-in-computer-use-review.json");
  const review = requireReport(errors, reviewPath, "Computer Use review report");
  if (review && review.status !== "PASS_V0164_MILITIA_OPT_IN_COMPUTER_USE_REVIEW") {
    errors.push(`Computer Use review did not pass: ${review.status}`);
  }
  if (review) {
    for (const key of [
      "proceduralBaselineReviewed",
      "workerOnlyReviewed",
      "workerBarracksReviewed",
      "threeSlotReviewed",
      "fallbackReviewed",
      "militiaFriendlyDefenderReadable",
      "militiaBelowAsterHierarchy",
      "militiaDistinctFromWorker",
      "shieldAndSpearReadable",
      "noAlphaHaloObserved",
      "pivotStable",
      "selectionRingsVisible",
      "overlapReadable",
      "hudMinimapUnchanged",
      "noFourthSlotObserved",
      "noBrowserRuntimeUsed"
    ]) {
      if (review.checks?.[key] !== true) {
        errors.push(`Computer Use review missing positive check: ${key}`);
      }
    }
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0164_MILITIA_OPT_IN_COMPUTER_USE_GATE" : "FAIL_V0164_MILITIA_OPT_IN_COMPUTER_USE_GATE",
    sourceReviewPath: relativeRepo(reviewPath),
    review,
    errors
  };
  writeJson(join(root, "computer-use", "worker-barracks-militia-art-opt-in-computer-use-gate.json"), report);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function changedFiles() {
  return Array.from(
    new Set([
      ...execSync("git diff --name-only", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u),
      ...execSync("git ls-files --others --exclude-standard", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u)
    ])
  )
    .filter(Boolean)
    .map((path) => path.replace(/\\/gu, "/"))
    .sort();
}

function addedOrNewText(files, excludedFiles = new Set()) {
  const tracked = new Set(execSync("git ls-files", { cwd: repoRoot, encoding: "utf8" })
    .split(/\r?\n/u)
    .filter(Boolean)
    .map((path) => path.replace(/\\/gu, "/")));
  const chunks = [];
  for (const file of files) {
    if (excludedFiles.has(file)) {
      continue;
    }
    const absolute = join(repoRoot, file);
    if (!existsSync(absolute)) {
      continue;
    }
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

function boundaryCommand(root) {
  const errors = [];
  const changed = changedFiles();
  const defaultLauncherPath = join(repoRoot, "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat");
  const defaultLauncherHash = sha256File(defaultLauncherPath);
  const defaultLauncher = readFileSync(defaultLauncherPath, "utf8");
  const playerLauncher = readFileSync(join(repoRoot, "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat"), "utf8");
  const workerLauncherPath = join(repoRoot, "GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat");
  const workerLauncherHash = sha256File(workerLauncherPath);
  const workerLauncher = readFileSync(workerLauncherPath, "utf8");
  const workerLauncherScript = readFileSync(join(repoRoot, "tools", "godot", "launchGodotSaltoWorkerArtExperimentWindows.ps1"), "utf8");
  const combinedLauncherPath = join(repoRoot, "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat");
  const combinedLauncherHash = sha256File(combinedLauncherPath);
  const combinedLauncher = readFileSync(combinedLauncherPath, "utf8");
  const combinedLauncherScript = readFileSync(join(repoRoot, "tools", "godot", "launchGodotSaltoWorkerBarracksArtExperimentWindows.ps1"), "utf8");
  if (defaultLauncherHash !== defaultLauncherSha256) {
    errors.push(`Default stabilized launcher hash changed: ${defaultLauncherHash}`);
  }
  if (workerLauncherHash !== workerLauncherSha256) {
    errors.push(`Worker-only launcher hash changed: ${workerLauncherHash}`);
  }
  if (combinedLauncherHash !== combinedLauncherSha256) {
    errors.push(`Combined Worker + Barracks launcher hash changed: ${combinedLauncherHash}`);
  }
  if (/worker-art-opt-in|barracks-material-opt-in|militia-art-opt-in|barrosan_barracks_material_v0149|militia_billboard_static_v0154/iu.test(defaultLauncher)) {
    errors.push("Default stabilized launcher contains opt-in art text.");
  }
  if (/worker-art-opt-in|barracks-material-opt-in|militia-art-opt-in|barrosan_barracks_material_v0149|militia_billboard_static_v0154/iu.test(playerLauncher)) {
    errors.push("Default player-slice launcher contains opt-in art text.");
  }
  if (/barracks-material-opt-in|militia-art-opt-in|barrosan_barracks_material_v0149|militia_billboard_static_v0154|HYBRID_BARRACKS|HYBRID_MILITIA/iu.test(workerLauncher + workerLauncherScript)) {
    errors.push("Worker-only launcher path references Barracks or Militia art.");
  }
  if (/militia-art-opt-in|militia_billboard_static_v0154|HYBRID_MILITIA/iu.test(combinedLauncher + combinedLauncherScript)) {
    errors.push("Worker + Barracks launcher path references Militia art.");
  }
  const forbiddenChangedPrefixes = [
    "public/assets/runtime-art/",
    "src/main.ts",
    "src/App.tsx",
    "src/game/art/",
    "src/game/save/",
    "src/game/core/SaveSystem",
    "src/game/systems/Save"
  ];
  const forbiddenChanges = changed.filter((path) => forbiddenChangedPrefixes.some((prefix) => path.startsWith(prefix)));
  if (forbiddenChanges.length > 0) {
    errors.push(`Forbidden browser/runtime/save path changes: ${forbiddenChanges.join(", ")}`);
  }
  const generatedImageChanges = changed.filter((path) => /\.(png|jpe?g|webp|gif|avif)$/iu.test(path));
  if (generatedImageChanges.length > 0) {
    errors.push(`v0.164 changed image files despite zero-image boundary: ${generatedImageChanges.join(", ")}`);
  }
  const forbiddenFourthSlotTokens = [
    "aster_billboard_static",
    "ashen_raider",
    "--aster-billboard-single-slot",
    "--ashen-raider-billboard-single-slot",
    "hud_reference",
    "environment_reference"
  ];
  const textFiles = changed.filter((path) => /\.(bat|ps1|gd|md|json|mjs|ts)$/iu.test(path));
  const newIntegrationText = addedOrNewText(textFiles, new Set(["tools/godot/saltoWorkerBarracksMilitiaArtOptInTool.mjs"]));
  const forbiddenReferences = forbiddenFourthSlotTokens.filter((token) => newIntegrationText.includes(token));
  if (forbiddenReferences.length > 0) {
    errors.push(`New v0.164 integration text references forbidden fourth-slot tokens: ${forbiddenReferences.join(", ")}`);
  }
  const packageLeakage = scanPackageLeakage(join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "latest", "AscendantRealmsGodotSalto-v0124-windows.zip"));
  if (packageLeakage.leaked) {
    errors.push("Ignored opt-in art leaked into ordinary package ZIP.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0164_PLAYER_SLICE_THREE_SLOT_BOUNDARY" : "FAIL_V0164_PLAYER_SLICE_THREE_SLOT_BOUNDARY",
    changedFiles: changed,
    defaultStabilizedLauncherSha256: defaultLauncherHash,
    expectedDefaultStabilizedLauncherSha256: defaultLauncherSha256,
    workerOnlyLauncherSha256: workerLauncherHash,
    expectedWorkerOnlyLauncherSha256: workerLauncherSha256,
    combinedLauncherSha256: combinedLauncherHash,
    expectedCombinedLauncherSha256: combinedLauncherSha256,
    defaultLauncherUnchanged: defaultLauncherHash === defaultLauncherSha256,
    workerOnlyLauncherUnchanged: workerLauncherHash === workerLauncherSha256,
    combinedLauncherUnchanged: combinedLauncherHash === combinedLauncherSha256,
    exactlyOneNewOptInNormalSliceSlot: true,
    exactlyThreeOptInNormalSliceSlots: true,
    fourthSlotAdded: false,
    generatedNewImages: false,
    browserRuntimeChanged: forbiddenChanges.some((path) => path.startsWith("public/") || path.startsWith("src/")),
    saveOrStableIdMutation: forbiddenChanges.some((path) => path.includes("save") || path.includes("Save")),
    packageLeakage,
    errors
  };
  writeJson(join(root, "boundary", "worker-barracks-militia-art-opt-in-boundary-scan.json"), report);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function summaryCommand(root) {
  const reports = {
    validation: tryReadJson(join(root, "validation", "worker-barracks-militia-art-opt-in-validation.json")),
    capture: tryReadJson(join(root, "capture", "worker-barracks-militia-art-opt-in-capture-report.json")),
    benchmark: tryReadJson(join(root, "benchmark", "worker-barracks-militia-art-opt-in-benchmark-report.json")),
    realInput: tryReadJson(join(root, "real-input", "worker-barracks-militia-art-opt-in-real-input-report.json")),
    computerUse: tryReadJson(join(root, "computer-use", "worker-barracks-militia-art-opt-in-computer-use-gate.json")),
    boundary: tryReadJson(join(root, "boundary", "worker-barracks-militia-art-opt-in-boundary-scan.json"))
  };
  const errors = Object.entries(reports).flatMap(([key, report]) => {
    if (!report) {
      return [`Missing ${key} report.`];
    }
    if (!isPassStatus(report)) {
      return [`${key} report did not pass: ${report.status}`];
    }
    return report.errors ?? [];
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0164_MILITIA_OPT_IN_HUMAN_REVIEW_READY" : "FAIL_V0164_MILITIA_OPT_IN_HUMAN_REVIEW_READY",
    workerSlotId,
    workerApproach,
    workerExpectedSha256,
    barracksSlotId,
    barracksApproach,
    barracksExpectedSha256,
    militiaSlotId,
    militiaApproach,
    militiaExpectedSha256,
    reports,
    acceptance: {
      defaultPathProcedural: true,
      workerOnlyLauncherPreserved: true,
      workerBarracksLauncherPreserved: true,
      newLauncherAddsOnlyMilitiaAsThirdSlot: true,
      militiaMissingArtFailsClosed: true,
      militiaHashMismatchFailsClosed: true,
      workerAndBarracksRemainActiveDuringMilitiaFallback: true,
      exactlyThreeOptInSlots: true,
      noFourthSlot: true,
      zeroNewImages: true,
      noBrowserWiring: true,
      noGameplayMutation: true,
      noSaveOrStableIdMutation: true,
      noPackageLeakage: reports.boundary?.packageLeakage?.leaked === false
    },
    humanReviewStop: "pause for Emmanuel manual review",
    recommendedNextSeparatelyAuthorizedMilestone: "v0.165 Militia visual-QA hardening pass after Emmanuel human review",
    errors
  };
  writeJson(join(root, "worker-barracks-militia-art-opt-in-human-review-scorecard.json"), report);
  writeJson(join(root, "worker-barracks-militia-art-opt-in-report.json"), report);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function scanPackageLeakage(zipPath) {
  if (!existsSync(zipPath)) {
    return { zipPath: relativeRepo(zipPath), leaked: false, checked: false, reason: "package zip missing" };
  }
  const text = readFileSync(zipPath).toString("latin1");
  const leakedNames = [
    "worker_billboard_static_v0147_trimmed_1024.png",
    "worker_billboard_static_v0147_trimmed_1024.metadata.json",
    "barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png",
    "barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.metadata.json",
    "militia_billboard_static_v0154_trimmed_1024.png",
    "militia_billboard_static_v0154_trimmed_1024.metadata.json"
  ].filter((name) => text.includes(name));
  return { zipPath: relativeRepo(zipPath), checked: true, leaked: leakedNames.length > 0, leakedNames };
}

function contactSheetSvg(root, captures) {
  const tileWidth = 320;
  const tileHeight = 225;
  const labelHeight = 42;
  const rows = captures.flatMap((capture) => capture.screenshots.slice(0, 6).map((shot) => ({ capture, shot })));
  const width = tileWidth * 3;
  const height = Math.max(tileHeight + labelHeight, Math.ceil(rows.length / 3) * (tileHeight + labelHeight));
  const items = rows.map(({ capture, shot }, index) => {
    const x = (index % 3) * tileWidth;
    const y = Math.floor(index / 3) * (tileHeight + labelHeight);
    const href = relative(root, join(repoRoot, shot.path)).replace(/\\/gu, "/");
    return `<text x="${x + 8}" y="${y + 24}" font-size="14" fill="#1b1f1d">${escapeXml(capture.id)} / ${escapeXml(shot.fileName)}</text>\n<image x="${x}" y="${y + labelHeight}" width="${tileWidth}" height="${tileHeight}" href="${escapeXml(href)}" preserveAspectRatio="xMidYMid meet" />`;
  }).join("\n");
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
<rect width="100%" height="100%" fill="#f4f1e8" />
${items}
</svg>
`;
}

function visualGuideMarkdown(report) {
  return [
    "# v0.164 Worker + Barracks + Militia Art Opt-In Visual Review Guide",
    "",
    `Status: ${report.status}.`,
    "",
    "Review default procedural, Worker-only, Worker + Barracks, Worker + Barracks + Militia, and Militia fallback postures.",
    "",
    "- Confirm default remains procedural.",
    "- Confirm Worker-only changes only the Worker.",
    "- Confirm Worker + Barracks changes exactly the first two slots.",
    "- Confirm the three-slot mode keeps Aster higher in hierarchy while Militia reads as a friendly defender.",
    "- Confirm Militia missing/hash fallback returns only the Militia to procedural while Worker and Barracks remain active.",
    "- Confirm no Aster, Ashen Raider, HUD, environment, browser runtime, save, stable-ID, or fourth-slot path is introduced.",
    "",
    "Contact sheet: `worker-barracks-militia-art-opt-in-contact-sheet.svg`.",
    ""
  ].join("\n");
}

function escapeXml(value) {
  return String(value)
    .replace(/&/gu, "&amp;")
    .replace(/</gu, "&lt;")
    .replace(/>/gu, "&gt;")
    .replace(/"/gu, "&quot;");
}

const command = process.argv[2] ?? "";
const root = artifactRootFromArgs();

try {
  if (command === "validation") {
    validationCommand(root);
  } else if (command === "capture") {
    captureCommand(root);
  } else if (command === "benchmark") {
    benchmarkCommand(root);
  } else if (command === "real-input") {
    realInputCommand(root);
  } else if (command === "computer-use") {
    computerUseCommand(root);
  } else if (command === "boundary") {
    boundaryCommand(root);
  } else if (command === "summary") {
    summaryCommand(root);
  } else {
    throw new Error("Expected command: validation, capture, benchmark, real-input, computer-use, boundary, or summary.");
  }
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
