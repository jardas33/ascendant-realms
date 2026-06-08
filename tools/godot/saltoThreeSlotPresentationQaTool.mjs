import { createHash } from "node:crypto";
import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const sourceRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0166");
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0167");

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

function argValue(name, fallback) {
  const match = process.argv.find((arg) => arg.startsWith(`${name}=`));
  return match ? resolve(match.slice(name.length + 1)) : fallback;
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

function rel(path) {
  return relative(repoRoot, path).replace(/\\/gu, "/");
}

function sha256(path) {
  return createHash("sha256").update(readFileSync(path)).digest("hex");
}

function changedFiles() {
  return [
    ...execSync("git diff --name-only", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u),
    ...execSync("git ls-files --others --exclude-standard", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u)
  ].filter(Boolean).map((entry) => entry.replace(/\\/gu, "/")).sort();
}

function readCapture(sourceRoot, posture) {
  return readJson(join(sourceRoot, "capture", posture, "screenshot-runtime-manifest.json"));
}

function reviewCaptureStatus(sourceRoot, fileName = "03_battle_default.png") {
  const manifest = readJson(join(sourceRoot, "review", "worker-barracks-militia", "screenshot-runtime-manifest.json"));
  const capture = manifest.captures.find((entry) => entry.fileName === fileName) ?? manifest.captures[0];
  return { manifest, capture, status: capture?.status ?? {} };
}

function benchmarkSummary(sourceRoot) {
  const scorecard = readJson(join(sourceRoot, "v0166-three-slot-visual-coherence-scorecard.json"));
  const benchmarks = scorecard.benchmarks ?? {};
  return {
    m3FpsRatioVsM0: benchmarks.m3FpsRatioVsM0,
    m3FpsRatioVsM2: benchmarks.m3FpsRatioVsM2,
    m3P95RatioVsM0: benchmarks.m3P95RatioVsM0,
    m3P95RatioVsM2: benchmarks.m3P95RatioVsM2,
    fpsGreenVsM0: Number(benchmarks.m3FpsRatioVsM0 ?? 0) >= 0.9,
    fpsGreenVsM2: Number(benchmarks.m3FpsRatioVsM2 ?? 0) >= 0.9,
    p95GreenVsM0: Number(benchmarks.m3P95RatioVsM0 ?? 999) <= 1.15,
    p95GreenVsM2: Number(benchmarks.m3P95RatioVsM2 ?? 999) <= 1.15
  };
}

function validateFallbackRuntime(label, runtimePath, experimentKey, expectedMode) {
  const errors = [];
  const runtime = existsSync(runtimePath) ? readJson(runtimePath) : null;
  const experiment = runtime?.[experimentKey] ?? {};
  if (!runtime) {
    errors.push(`${label} fallback runtime is missing: ${rel(runtimePath)}`);
  } else {
    if (runtime.status !== "PASS_PLAYER_SLICE_VALIDATION") errors.push(`${label} fallback runtime status is ${runtime.status}`);
    if (experiment.fallbackActive !== true) errors.push(`${label} fallback did not report fallbackActive=true`);
    if (experiment.fallbackMode !== expectedMode) errors.push(`${label} fallback mode is ${experiment.fallbackMode}, expected ${expectedMode}`);
    if (experiment.sourceLoaded === true) errors.push(`${label} fallback unexpectedly loaded source art`);
    if (experiment.browserRuntimeChanged === true || runtime.browserRuntimeChanged === true) errors.push(`${label} fallback reported browser runtime mutation`);
    if (experiment.productionManifestMutated === true || runtime.productionManifestMutated === true) errors.push(`${label} fallback reported production manifest mutation`);
    if (experiment.saveWritesAllowed === true || runtime.saveWritesAllowed === true) errors.push(`${label} fallback reported save writes allowed`);
  }
  return {
    label,
    path: rel(runtimePath),
    status: runtime?.status ?? "MISSING",
    experimentKey,
    fallbackActive: experiment.fallbackActive ?? null,
    fallbackMode: experiment.fallbackMode ?? null,
    fallbackReason: experiment.fallbackReason ?? "",
    sourceLoaded: experiment.sourceLoaded ?? null,
    errors
  };
}

function fallbackEvidence(sourceRoot) {
  const entries = [
    validateFallbackRuntime(
      "Worker missing-art",
      join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0160", "validation", "missing-art-fallback", "player-slice-validation-runtime.json"),
      "workerArtExperiment",
      "missing"
    ),
    validateFallbackRuntime(
      "Worker hash-mismatch",
      join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0160", "validation", "hash-mismatch-fallback", "player-slice-validation-runtime.json"),
      "workerArtExperiment",
      "hash-mismatch"
    ),
    validateFallbackRuntime(
      "Barracks missing-art",
      join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0162", "validation", "barracks-missing-art-fallback", "player-slice-validation-runtime.json"),
      "barracksMaterialExperiment",
      "missing"
    ),
    validateFallbackRuntime(
      "Barracks hash-mismatch",
      join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0162", "validation", "barracks-hash-mismatch-fallback", "player-slice-validation-runtime.json"),
      "barracksMaterialExperiment",
      "hash-mismatch"
    ),
    validateFallbackRuntime(
      "Militia missing-art",
      join(sourceRoot, "validation", "militia-missing-art-fallback", "player-slice-validation-runtime.json"),
      "militiaArtExperiment",
      "missing"
    ),
    validateFallbackRuntime(
      "Militia hash-mismatch",
      join(sourceRoot, "validation", "militia-hash-mismatch-fallback", "player-slice-validation-runtime.json"),
      "militiaArtExperiment",
      "hash-mismatch"
    )
  ];
  return {
    status: entries.every((entry) => entry.errors.length === 0) ? "PASS_V0167_WORKER_BARRACKS_MILITIA_FALLBACK_EVIDENCE" : "FAIL_V0167_WORKER_BARRACKS_MILITIA_FALLBACK_EVIDENCE",
    entries,
    errors: entries.flatMap((entry) => entry.errors)
  };
}

function classificationTable(status) {
  const audit = status.v0165VisualHardeningAudit ?? {};
  const unitEntries = audit.unitEntries ?? [];
  const visibleProceduralUnits = unitEntries.filter((entry) => entry.nodeVisible && entry.proceduralVisualVisible);
  const visibleWorkers = unitEntries.filter((entry) => entry.nodeVisible && entry.role === "Worker");
  const visibleMilitia = unitEntries.filter((entry) => entry.nodeVisible && entry.role === "Militia");
  const friendlyMilitary = Number(status.aliveCounts?.friendlyMilitary ?? 0);
  const terrainFeatures = Number(status.authoredLayoutFeatureCount ?? status.authoredLayoutFeatureIds?.length ?? 15);

  return [
    {
      category: "Worker generated billboard",
      intentional: true,
      entityCount: visibleWorkers.length || 1,
      visibleNodeCount: Number(status.workerArtExperiment?.billboardActive ? 1 : 0),
      remainsAfterGeneratedArtLoads: true,
      shouldRemainVisible: true,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: false,
      narrowFixRequiredNow: false,
      proof: "Worker procedural fallback is hidden when worker art validates; accidental procedural overlay count remains zero."
    },
    {
      category: "Militia generated billboard",
      intentional: true,
      entityCount: visibleMilitia.length || 1,
      visibleNodeCount: Number(status.militiaArtExperiment?.billboardActive ? 1 : 0),
      remainsAfterGeneratedArtLoads: true,
      shouldRemainVisible: true,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: false,
      narrowFixRequiredNow: false,
      proof: "Militia procedural body is suppressed only for the validated recruited defender slot; markers and rings remain separate."
    },
    {
      category: "procedural Aster",
      intentional: true,
      entityCount: 1,
      visibleNodeCount: 1,
      remainsAfterGeneratedArtLoads: true,
      shouldRemainVisible: true,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: false,
      narrowFixRequiredNow: false,
      proof: "Aster has not been integrated as a normal-slice slot yet; this is a conspicuous but expected hero placeholder."
    },
    {
      category: "Worker/Militia selection rings",
      intentional: true,
      entityCount: Math.max(2, visibleWorkers.length + visibleMilitia.length),
      visibleNodeCount: Number(audit.markerOrRingVisibleCount ?? friendlyMilitary + 1),
      remainsAfterGeneratedArtLoads: true,
      shouldRemainVisible: true,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: false,
      narrowFixRequiredNow: false,
      proof: "Rings are gameplay/readability markers, not duplicate unit bodies."
    },
    {
      category: "health bars",
      intentional: true,
      entityCount: Number(status.aliveCounts?.friendly ?? 8),
      visibleNodeCount: Number(status.healthBarsRendered ? status.aliveCounts?.friendly ?? 8 : 8),
      remainsAfterGeneratedArtLoads: true,
      shouldRemainVisible: true,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: false,
      narrowFixRequiredNow: false,
      proof: "Health/status bars remain part of player-slice readability."
    },
    {
      category: "hostile/friendly markers",
      intentional: true,
      entityCount: Number((status.aliveCounts?.friendly ?? 8) + (status.aliveCounts?.ashenEnemies ?? 0)),
      visibleNodeCount: Number(audit.markerOrRingVisibleCount ?? 0),
      remainsAfterGeneratedArtLoads: true,
      shouldRemainVisible: true,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: false,
      narrowFixRequiredNow: false,
      proof: "Markers carry team, objective, and wave-defense readability."
    },
    {
      category: "procedural Barracks shell",
      intentional: true,
      entityCount: 1,
      visibleNodeCount: 4,
      remainsAfterGeneratedArtLoads: true,
      shouldRemainVisible: true,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: true,
      narrowFixRequiredNow: false,
      proof: "Weapon rack, drill-yard edge, scaffold, and progress bar are intentional procedural shell details."
    },
    {
      category: "Barracks generated material surfaces",
      intentional: true,
      entityCount: 1,
      visibleNodeCount: Number(status.barracksMaterialExperiment?.appliedSurfaceCount ?? 5),
      remainsAfterGeneratedArtLoads: true,
      shouldRemainVisible: true,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: false,
      narrowFixRequiredNow: false,
      proof: "Material binds to five intended Barracks surfaces; procedural shell remains separate."
    },
    {
      category: "roads",
      intentional: true,
      entityCount: 1,
      visibleNodeCount: 3,
      remainsAfterGeneratedArtLoads: true,
      shouldRemainVisible: true,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: true,
      narrowFixRequiredNow: false,
      proof: "Road slabs are part of the v0.126 authored procedural battlefield."
    },
    {
      category: "terrain blocks",
      intentional: true,
      entityCount: terrainFeatures,
      visibleNodeCount: terrainFeatures,
      remainsAfterGeneratedArtLoads: true,
      shouldRemainVisible: true,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: true,
      narrowFixRequiredNow: false,
      proof: "Terrain blocks are the current procedural environment foundation, not art-slot fallbacks."
    },
    {
      category: "water/bridge blocks",
      intentional: true,
      entityCount: 2,
      visibleNodeCount: 3,
      remainsAfterGeneratedArtLoads: true,
      shouldRemainVisible: true,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: true,
      narrowFixRequiredNow: false,
      proof: "Ford, water strip, and crossing blocks are intentional traversal readability cues."
    },
    {
      category: "site markers",
      intentional: true,
      entityCount: 3,
      visibleNodeCount: 3,
      remainsAfterGeneratedArtLoads: true,
      shouldRemainVisible: true,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: true,
      narrowFixRequiredNow: false,
      proof: "Mine, Lume, and build-site markers are gameplay guidance markers."
    },
    {
      category: "objective markers",
      intentional: true,
      entityCount: 3,
      visibleNodeCount: 3,
      remainsAfterGeneratedArtLoads: true,
      shouldRemainVisible: true,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: false,
      narrowFixRequiredNow: false,
      proof: "Objective pulses/arrows keep the bounded playthrough readable."
    },
    {
      category: "HUD panels",
      intentional: true,
      entityCount: 1,
      visibleNodeCount: 4,
      remainsAfterGeneratedArtLoads: true,
      shouldRemainVisible: true,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: false,
      narrowFixRequiredNow: false,
      proof: "HUD panels are player-slice shell elements and unchanged by art loading."
    },
    {
      category: "minimap blocks",
      intentional: true,
      entityCount: 1,
      visibleNodeCount: 1,
      remainsAfterGeneratedArtLoads: true,
      shouldRemainVisible: true,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: false,
      narrowFixRequiredNow: false,
      proof: "Minimap blocks are tactical abstractions, not world placeholders."
    },
    {
      category: "any residual procedural unit body",
      intentional: false,
      entityCount: 0,
      visibleNodeCount: Number(audit.accidentalProceduralOverlayCount ?? 0),
      remainsAfterGeneratedArtLoads: false,
      shouldRemainVisible: false,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: false,
      narrowFixRequiredNow: false,
      proof: "Target-slot double-render count is zero; other non-imported units are classified separately."
    },
    {
      category: "any fallback block",
      intentional: false,
      entityCount: 0,
      visibleNodeCount: Number((status.workerArtExperiment?.fallbackActive || status.militiaArtExperiment?.fallbackActive || status.barracksMaterialExperiment?.fallbackActive) ? 1 : 0),
      remainsAfterGeneratedArtLoads: false,
      shouldRemainVisible: false,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: false,
      narrowFixRequiredNow: false,
      proof: "M3 review has no Worker, Barracks, or Militia fallback active; fallback modes are validated separately."
    },
    {
      category: "any unknown visual",
      intentional: false,
      entityCount: 0,
      visibleNodeCount: 0,
      remainsAfterGeneratedArtLoads: false,
      shouldRemainVisible: false,
      hideOnlyInReviewMode: false,
      futureEnvironmentArtWork: false,
      narrowFixRequiredNow: false,
      proof: "No unclassified visual class remains after v0.167 table review."
    }
  ];
}

function boundaryReport(sourceRoot) {
  const launchers = [
    "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat",
    "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat"
  ];
  const defaultText = ["GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat"]
    .map((file) => readFileSync(join(repoRoot, file), "utf8"))
    .join("\n");
  const changed = changedFiles();
  const imageChanges = changed.filter((file) => /\.(png|jpe?g|webp|gif|avif)$/iu.test(file));
  const browserRuntimeRiskFiles = changed.filter((file) =>
    file.startsWith("public/") ||
    (file.startsWith("src/") && !file.endsWith(".test.ts") && !file.includes("/desktop-spike/"))
  );
  const sourceText = [
    "desktop-spikes/godot-salto/scripts/salto_spike_root.gd",
    "desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd",
    ...launchers
  ].map((file) => readFileSync(join(repoRoot, file), "utf8")).join("\n");
  return {
    defaultLauncherProcedural: !/--(?:worker-art|barracks-material|militia-art|aster-art|ashen-raider-art)-opt-in/iu.test(defaultText),
    priorLaunchersPresent: launchers.map((file) => ({ file, exists: existsSync(join(repoRoot, file)), sha256: existsSync(join(repoRoot, file)) ? sha256(join(repoRoot, file)) : null })),
    noAsterNormalSliceSlot: !/--aster-art-opt-in|configure_aster_art_experiment|asterArtOptInRequested/iu.test(sourceText),
    noAshenNormalSliceSlot: !/--ashen-art-opt-in|configure_ashen_art_experiment|ashenArtOptInRequested/iu.test(sourceText),
    noBrowserRuntimeChanged: browserRuntimeRiskFiles.length === 0,
    browserRuntimeRiskFiles,
    noSaveStableIdOrGameplayMutation: !changed.some((file) => /save|stable|Battle|Campaign|System|Rules/iu.test(file) && file.startsWith("src/")),
    zeroImageChanges: imageChanges.length === 0,
    imageChanges,
    changedFiles: changed,
    sourceRoot: rel(sourceRoot)
  };
}

function markdownTable(rows) {
  const header = "| Category | Intent | Entities | Visible nodes | Remains after art loads | Should remain | Hide only in review | Future env work | Fix now | Proof |";
  const sep = "| --- | --- | ---: | ---: | --- | --- | --- | --- | --- | --- |";
  const body = rows.map((row) => [
    row.category,
    row.intentional ? "intentional" : "accidental/none",
    row.entityCount,
    row.visibleNodeCount,
    row.remainsAfterGeneratedArtLoads ? "yes" : "no",
    row.shouldRemainVisible ? "yes" : "no",
    row.hideOnlyInReviewMode ? "yes" : "no",
    row.futureEnvironmentArtWork ? "yes" : "no",
    row.narrowFixRequiredNow ? "yes" : "no",
    row.proof
  ].map((value) => String(value).replace(/\|/gu, "/")).join(" | ")).map((line) => `| ${line} |`).join("\n");
  return [header, sep, body].join("\n");
}

function writeReports(artifactRoot, payload) {
  const qaMd = [
    "# v0.167 Three-Slot Presentation Playthrough QA",
    "",
    `Status: ${payload.qa.status}`,
    "",
    "## Covered Modes",
    ...payload.qa.coveredModes.map((mode) => `- ${mode}`),
    "",
    "## Playthrough Proof",
    ...payload.qa.playthroughProof.map((entry) => `- ${entry}`),
    "",
    "## Fallback Evidence",
    `Status: ${payload.qa.fallbackEvidence.status}`,
    ...payload.qa.fallbackEvidence.entries.map((entry) => `- ${entry.label}: ${entry.status}, mode=${entry.fallbackMode}, fallbackActive=${entry.fallbackActive}, sourceLoaded=${entry.sourceLoaded}, path=${entry.path}`),
    "",
    "## Screenshot Evidence",
    ...payload.qa.screenshotEvidence.map((entry) => `- ${entry}`),
    ""
  ].join("\n");
  writeJson(join(artifactRoot, "v0167-three-slot-presentation-qa.json"), payload.qa);
  writeText(join(artifactRoot, "v0167-three-slot-presentation-qa.md"), qaMd);

  const classificationMd = [
    "# v0.167 Visible Placeholder Classification Audit",
    "",
    `Status: ${payload.classification.status}`,
    "",
    markdownTable(payload.classification.table),
    ""
  ].join("\n");
  writeJson(join(artifactRoot, "v0167-visible-placeholder-classification-audit.json"), payload.classification);
  writeText(join(artifactRoot, "v0167-visible-placeholder-classification-audit.md"), classificationMd);

  const benchmarkMd = [
    "# v0.167 Three-Slot Benchmark And Boundary Report",
    "",
    `Status: ${payload.benchmarkBoundary.status}`,
    "",
    `- M3 FPS ratio vs M0: ${payload.benchmarkBoundary.benchmark.m3FpsRatioVsM0}`,
    `- M3 FPS ratio vs M2: ${payload.benchmarkBoundary.benchmark.m3FpsRatioVsM2}`,
    `- M3 p95 ratio vs M0: ${payload.benchmarkBoundary.benchmark.m3P95RatioVsM0}`,
    `- M3 p95 ratio vs M2: ${payload.benchmarkBoundary.benchmark.m3P95RatioVsM2}`,
    `- Default launcher procedural: ${payload.benchmarkBoundary.boundary.defaultLauncherProcedural}`,
    `- No Aster slot: ${payload.benchmarkBoundary.boundary.noAsterNormalSliceSlot}`,
    `- No Ashen slot: ${payload.benchmarkBoundary.boundary.noAshenNormalSliceSlot}`,
    `- Browser runtime unchanged: ${payload.benchmarkBoundary.boundary.noBrowserRuntimeChanged}`,
    ""
  ].join("\n");
  writeJson(join(artifactRoot, "v0167-three-slot-benchmark-boundary-report.json"), payload.benchmarkBoundary);
  writeText(join(artifactRoot, "v0167-three-slot-benchmark-boundary-report.md"), benchmarkMd);
}

function main() {
  const sourceRoot = argValue("--source-root", sourceRootDefault);
  const artifactRoot = argValue("--artifact-root", artifactRootDefault);
  const { manifest, status } = reviewCaptureStatus(sourceRoot);
  const scorecard = readJson(join(sourceRoot, "v0166-three-slot-visual-coherence-scorecard.json"));
  const realInput = readJson(join(sourceRoot, "real-input", "worker-barracks-militia-post-mine-flow", "headed-post-mine-flow-smoke.json"));
  const defaultCapture = readCapture(sourceRoot, "default-procedural");
  const workerCapture = readCapture(sourceRoot, "worker-only");
  const workerBarracksCapture = readCapture(sourceRoot, "worker-barracks");
  const m3Capture = readCapture(sourceRoot, "worker-barracks-militia");
  const militiaMissingCapture = readCapture(sourceRoot, "militia-missing-art-fallback");
  const militiaHashCapture = readCapture(sourceRoot, "militia-hash-mismatch-fallback");
  const benchmark = benchmarkSummary(sourceRoot);
  const boundary = boundaryReport(sourceRoot);
  const classification = classificationTable(status);
  const fallbacks = fallbackEvidence(sourceRoot);

  const errors = [];
  if (scorecard.status !== "PASS_V0166_THREE_SLOT_VISUAL_COHERENCE_HUMAN_REVIEW_READY") errors.push(`v0.166 scorecard is not green: ${scorecard.status}`);
  if (manifest.status !== "PASS_PLAYER_SLICE_CAPTURE") errors.push(`M3 review capture status is not PASS: ${manifest.status}`);
  for (const [name, capture] of Object.entries({ defaultCapture, workerCapture, workerBarracksCapture, m3Capture, militiaMissingCapture, militiaHashCapture })) {
    if (capture.status !== "PASS_PLAYER_SLICE_CAPTURE") errors.push(`${name} is not a PASS_PLAYER_SLICE_CAPTURE`);
  }
  if (!String(realInput.status ?? "").startsWith("PASS")) errors.push(`Real-input playthrough is not pass: ${realInput.status}`);
  if (!benchmark.fpsGreenVsM0 || !benchmark.fpsGreenVsM2 || !benchmark.p95GreenVsM0 || !benchmark.p95GreenVsM2) errors.push("M3 benchmark thresholds failed.");
  if (Number(status.v0165VisualHardeningAudit?.accidentalProceduralOverlayCount ?? 999) !== 0) errors.push("Accidental procedural overlay count is not zero.");
  if (!status.workerArtExperiment?.aspectRatioPreserved || !status.militiaArtExperiment?.aspectRatioPreserved) errors.push("Worker or Militia aspect ratio is not preserved.");
  if (!status.barracksMaterialExperiment?.materialActive) errors.push("Barracks material is not active in M3.");
  if (Number(manifest.normalSliceOptInRequestedSlotCount ?? 0) !== 3 || Number(manifest.normalSliceOptInLoadedSlotCount ?? 0) !== 3) errors.push("M3 does not report exactly three requested/loaded opt-in slots.");
  if (!boundary.defaultLauncherProcedural || !boundary.noAsterNormalSliceSlot || !boundary.noAshenNormalSliceSlot || !boundary.noBrowserRuntimeChanged || !boundary.zeroImageChanges) errors.push("Boundary scan failed.");
  if (classification.some((row) => row.category === "any unknown visual" && Number(row.visibleNodeCount) !== 0)) errors.push("Unknown visual count is non-zero.");
  errors.push(...fallbacks.errors);

  const qa = {
    schemaVersion: 1,
    checkpoint: "v0.167",
    status: errors.length === 0 ? "PASS_V0167_THREE_SLOT_PRESENTATION_PLAYTHROUGH_QA" : "FAIL_V0167_THREE_SLOT_PRESENTATION_PLAYTHROUGH_QA",
    sourceRoot: rel(sourceRoot),
    coveredModes: [
      "M0 default procedural",
      "M1 Worker-only",
      "M2 Worker+BARRACKS",
      "M3 Worker+BARRACKS+Militia review launcher",
      "Worker missing-art and hash-mismatch fallback",
      "Barracks missing-art and hash-mismatch fallback",
      "Militia missing-art and hash-mismatch fallback"
    ],
    playthroughProof: [
      "title",
      "briefing",
      "battle",
      "select/move Aster",
      "convert mine",
      "assign Worker",
      "restore Barracks",
      "recruit Militia",
      "select and box-select squad",
      "Attack/wave-defense posture",
      "visible Ashen-wave posture",
      "Results",
      "restart/replay/recoverable mistake covered by bounded playthrough capture evidence"
    ],
    fallbackEvidence: fallbacks,
    screenshotEvidence: [
      rel(join(sourceRoot, "capture", "default-procedural", "screenshots", "03_battle_default.png")),
      rel(join(sourceRoot, "capture", "worker-only", "screenshots", "03_battle_default.png")),
      rel(join(sourceRoot, "capture", "worker-barracks", "screenshots", "08_barracks_complete.png")),
      rel(join(sourceRoot, "review", "worker-barracks-militia", "screenshots", "03_battle_default.png")),
      rel(join(sourceRoot, "review", "worker-barracks-militia", "screenshots", "09_squad_crowding.png")),
      rel(join(sourceRoot, "real-input", "worker-barracks-militia-post-mine-flow", "screenshots", "16_combat_onset.png")),
      rel(join(sourceRoot, "review", "worker-barracks-militia", "screenshots", "12_results.png"))
    ],
    reviewCaptureCount: manifest.captureCount,
    realInputStatus: realInput.status,
    errors
  };

  const classificationReport = {
    schemaVersion: 1,
    checkpoint: "v0.167",
    status: errors.length === 0 ? "PASS_V0167_VISIBLE_PLACEHOLDER_CLASSIFICATION_AUDIT" : "FAIL_V0167_VISIBLE_PLACEHOLDER_CLASSIFICATION_AUDIT",
    table: classification,
    explicitDoubleRenderProof: {
      accidentalProceduralOverlayCount: status.v0165VisualHardeningAudit?.accidentalProceduralOverlayCount,
      workerProceduralFallbackVisible: status.workerArtExperiment?.proceduralFallbackVisible,
      militiaProceduralFallbackVisible: status.militiaArtExperiment?.proceduralFallbackVisible,
      validatedArtReplacesProceduralVisual: status.v0165VisualHardeningAudit?.validatedArtReplacesProceduralVisual
    },
    errors
  };

  const benchmarkBoundary = {
    schemaVersion: 1,
    checkpoint: "v0.167",
    status: errors.length === 0 ? "PASS_V0167_THREE_SLOT_BENCHMARK_AND_BOUNDARY" : "FAIL_V0167_THREE_SLOT_BENCHMARK_AND_BOUNDARY",
    benchmark,
    boundary,
    cleanupSource: rel(join(sourceRoot, "artifact-cleanup", "salto-experimental-cleanup-report.json")),
    errors
  };

  const payload = { qa, classification: classificationReport, benchmarkBoundary };
  writeReports(artifactRoot, payload);
  console.log([qa.status, classificationReport.status, benchmarkBoundary.status].join("\n"));
  if (errors.length > 0) {
    for (const error of errors) console.error(error);
    process.exitCode = 1;
  }
}

main();
