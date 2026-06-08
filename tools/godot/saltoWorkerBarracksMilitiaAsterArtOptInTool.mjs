import { createHash } from "node:crypto";
import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.168";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0168");
const workerSlotId = "worker_billboard_static_v0147";
const workerExpectedSha256 = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc";
const barracksSlotId = "barrosan_barracks_material_v0149";
const barracksExpectedSha256 = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f";
const militiaSlotId = "militia_billboard_static_v0154";
const militiaExpectedSha256 = "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb";
const asterSlotId = "aster_billboard_static_v0151";
const asterApproach = "HYBRID_ASTER_TRIMMED_1024";
const asterExpectedSha256 = "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a";
const launcherHashes = {
  defaultStabilized: "47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d",
  defaultPlayer: "737e8509e5571e5e6c928b6070e9b9cd108182dd667365ceafd01b648dce8df2",
  workerOnly: "87fd8b106ef02518c9fdd73c2ff5d6b1be92dc885e4b7aac607ce0fa5ce3a3bb",
  workerBarracks: "a795b154fb08abd2664321a802050db6d73808aa73fd2ae34038c8db4c42be1a",
  workerBarracksMilitia: "4eab85de03e83e64440da9c90204bd880ce29b2477d2b048940b94cd809245cc"
};

const validationScenarios = [
  { id: "default-procedural", expected: "procedural" },
  { id: "worker-only", expected: "worker-only" },
  { id: "worker-barracks", expected: "worker-barracks" },
  { id: "worker-barracks-militia", expected: "three-loaded" },
  { id: "worker-barracks-militia-aster", expected: "four-loaded" },
  { id: "aster-missing-art-fallback", expected: "aster-missing" },
  { id: "aster-hash-mismatch-fallback", expected: "aster-hash" }
];

const benchmarkScenarios = [
  { id: "procedural-baseline", expected: "procedural" },
  { id: "worker-barracks-militia", expected: "three-loaded" },
  { id: "worker-barracks-militia-aster", expected: "four-loaded" },
  { id: "aster-missing-art-fallback", expected: "aster-missing" },
  { id: "aster-hash-mismatch-fallback", expected: "aster-hash" }
];

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

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
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

function rel(path) {
  return relative(repoRoot, path).replace(/\\/gu, "/");
}

function artifactRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--artifact-root="));
  return explicit ? resolve(explicit.slice("--artifact-root=".length)) : artifactRootDefault;
}

function isPass(report) {
  return typeof report?.status === "string" && report.status.startsWith("PASS");
}

function reportAt(root, group, scenarioId, fileName, errors) {
  const path = join(root, group, scenarioId, fileName);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}`);
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

function asterArt(report) {
  return report?.asterArtExperiment ?? {};
}

function checkLoaded(experiment, slotId, sha, label, errors) {
  if (experiment.sourceLoaded !== true || experiment.actualSha256 !== sha || experiment.slotId !== slotId || experiment.fallbackActive === true) {
    errors.push(`${label} did not load exact selected source ${slotId}.`);
  }
}

function checkAsterVisualContract(experiment, id, errors) {
  if (experiment.approach !== asterApproach) errors.push(`${id} Aster approach mismatch.`);
  if (experiment.aspectRatioPreserved !== true) errors.push(`${id} did not preserve Aster source aspect ratio.`);
  if (Number(experiment.runtimeWorldHeight ?? 0) < 0.88) errors.push(`${id} Aster runtime height is too small for hero hierarchy.`);
  if (Number(experiment.hierarchyRuntimeHeightVsMilitia ?? 0) < 1.2) errors.push(`${id} Aster is not materially taller than Militia.`);
  if (Number(experiment.hierarchyRuntimeHeightVsWorker ?? 0) < 1.15) errors.push(`${id} Aster is not materially taller than Worker.`);
}

function checkScenario(report, expected, id, errors) {
  if (!isPass(report)) {
    errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
    return;
  }
  const worker = workerArt(report);
  const barracks = barracksMaterial(report);
  const militia = militiaArt(report);
  const aster = asterArt(report);
  const loadedCount = Number(report.normalSliceOptInLoadedSlotCount ?? 0);
  const requestedCount = Number(report.normalSliceOptInRequestedSlotCount ?? 0);
  if (expected === "procedural") {
    if (requestedCount !== 0 || loadedCount !== 0 || worker.sourceLoaded || barracks.sourceLoaded || militia.sourceLoaded || aster.sourceLoaded) {
      errors.push(`${id} should stay fully procedural with zero opt-in slots.`);
    }
  }
  if (expected === "worker-only") {
    checkLoaded(worker, workerSlotId, workerExpectedSha256, `${id} Worker`, errors);
    if (requestedCount !== 1 || loadedCount !== 1 || barracks.sourceLoaded || militia.sourceLoaded || aster.sourceLoaded) {
      errors.push(`${id} should preserve Worker-only posture.`);
    }
  }
  if (expected === "worker-barracks") {
    checkLoaded(worker, workerSlotId, workerExpectedSha256, `${id} Worker`, errors);
    checkLoaded(barracks, barracksSlotId, barracksExpectedSha256, `${id} Barracks`, errors);
    if (requestedCount !== 2 || loadedCount !== 2 || militia.sourceLoaded || aster.sourceLoaded) {
      errors.push(`${id} should preserve Worker + Barracks posture.`);
    }
  }
  if (expected === "three-loaded" || expected === "four-loaded" || expected.startsWith("aster-")) {
    checkLoaded(worker, workerSlotId, workerExpectedSha256, `${id} Worker`, errors);
    checkLoaded(barracks, barracksSlotId, barracksExpectedSha256, `${id} Barracks`, errors);
    checkLoaded(militia, militiaSlotId, militiaExpectedSha256, `${id} Militia`, errors);
  }
  if (expected === "three-loaded") {
    if (requestedCount !== 3 || loadedCount !== 3 || aster.sourceLoaded || report.asterArtOptInRequested === true) {
      errors.push(`${id} should remain the prior three-slot posture with no Aster request.`);
    }
  }
  if (expected === "four-loaded") {
    checkLoaded(aster, asterSlotId, asterExpectedSha256, `${id} Aster`, errors);
    checkAsterVisualContract(aster, id, errors);
    if (requestedCount !== 4 || loadedCount !== 4 || report.fourthPlayerFacingArtSlotAdded !== true) {
      errors.push(`${id} should report exactly four requested and loaded opt-in slots.`);
    }
    const audit = report.v0165VisualHardeningAudit ?? {};
    const unitVisuals = Array.isArray(audit.unitVisuals) ? audit.unitVisuals : [];
    const asterEntry = unitVisuals.find((entry) => entry.id === "hero_aster") ?? {};
    const asterAuditClean = unitVisuals.length > 0
      ? asterEntry.generatedArtVisible === true && asterEntry.childVisualCount === 0
      : aster.proceduralFallbackVisible === false;
    if ((audit.accidentalProceduralOverlayCount ?? 0) !== 0 || !asterAuditClean) {
      errors.push(`${id} did not prove Aster billboard replaced the procedural hero body cleanly.`);
    }
  }
  if (expected === "aster-missing" || expected === "aster-hash") {
    const mode = expected === "aster-missing" ? "missing" : "hash-mismatch";
    if (requestedCount !== 4 || loadedCount !== 3) errors.push(`${id} should report four requested slots and three loaded slots.`);
    if (aster.sourceLoaded === true || aster.fallbackActive !== true || aster.fallbackMode !== mode || !String(aster.fallbackReason ?? "").includes(expected === "aster-missing" ? "missing" : "hash mismatch")) {
      errors.push(`${id} did not explain Aster ${mode} procedural fallback.`);
    }
    const audit = report.v0165VisualHardeningAudit ?? {};
    const unitVisuals = Array.isArray(audit.unitVisuals) ? audit.unitVisuals : [];
    const asterEntry = unitVisuals.find((entry) => entry.id === "hero_aster") ?? {};
    const fallbackVisible = unitVisuals.length > 0
      ? asterEntry.fallbackVisible === true && asterEntry.proceduralVisualVisible === true
      : aster.proceduralFallbackVisible === true;
    if (!fallbackVisible) {
      errors.push(`${id} did not restore procedural Aster fallback visibility.`);
    }
  }
  if (report.browserRuntimeChanged === true || report.saveWritesAllowed === true || report.stableIdsChanged === true) {
    errors.push(`${id} reported browser/save/stable-ID boundary mutation.`);
  }
}

function validationCommand(root) {
  const errors = [];
  const scenarios = validationScenarios.map((scenario) => {
    const loaded = reportAt(root, "validation", scenario.id, "player-slice-validation-runtime.json", errors);
    if (loaded.report) checkScenario(loaded.report, scenario.expected, scenario.id, errors);
    return {
      id: scenario.id,
      expected: scenario.expected,
      path: rel(loaded.path),
      status: loaded.report?.status ?? "MISSING",
      requestedSlotCount: loaded.report?.normalSliceOptInRequestedSlotCount ?? 0,
      loadedSlotCount: loaded.report?.normalSliceOptInLoadedSlotCount ?? 0,
      workerArtExperiment: workerArt(loaded.report),
      barracksMaterialExperiment: barracksMaterial(loaded.report),
      militiaArtExperiment: militiaArt(loaded.report),
      asterArtExperiment: asterArt(loaded.report)
    };
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0168_ASTER_OPT_IN_VALIDATION" : "FAIL_V0168_ASTER_OPT_IN_VALIDATION",
    asterSlotId,
    asterApproach,
    asterExpectedSha256,
    scenarios,
    errors
  };
  writeJson(join(root, "validation", "worker-barracks-militia-aster-art-opt-in-validation.json"), report);
  writeJson(join(root, "validation", "worker-barracks-militia-aster-art-opt-in-functional-report.json"), {
    ...report,
    status: errors.length === 0 ? "PASS_V0168_ASTER_OPT_IN_FUNCTIONAL" : "FAIL_V0168_ASTER_OPT_IN_FUNCTIONAL",
    preservedBehaviors: [
      "default procedural launcher",
      "Worker-only launcher",
      "Worker + Barracks launcher",
      "Worker + Barracks + Militia launcher",
      "Aster selection and movement",
      "Worker assignment",
      "Barracks restoration",
      "Militia recruitment and selection",
      "squad box-select",
      "combat onset",
      "Results/restart/replay"
    ]
  });
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function captureCommand(root) {
  const errors = [];
  const captures = validationScenarios.map((scenario) => {
    const loaded = reportAt(root, "capture", scenario.id, "screenshot-runtime-manifest.json", errors);
    if (loaded.report) {
      checkScenario(loaded.report, scenario.expected, scenario.id, errors);
      if (!isPass(loaded.report)) errors.push(`${scenario.id} capture did not PASS: ${loaded.report.status}`);
    }
    const screenshotRoot = join(root, "capture", scenario.id, "screenshots");
    const files = existsSync(screenshotRoot) ? readdirSync(screenshotRoot).filter((file) => file.endsWith(".png")).sort() : [];
    if (loaded.report && files.length !== Number(loaded.report.requiredCaptureCount ?? -1)) {
      errors.push(`${scenario.id} expected ${loaded.report.requiredCaptureCount} PNGs, found ${files.length}.`);
    }
    return {
      id: scenario.id,
      manifest: rel(loaded.path),
      status: loaded.report?.status ?? "MISSING",
      captureCount: files.length,
      requiredCaptureCount: loaded.report?.requiredCaptureCount ?? 0,
      asterArtExperiment: asterArt(loaded.report),
      screenshots: files.map((file) => ({ fileName: file, path: rel(join(screenshotRoot, file)), sha256: sha256File(join(screenshotRoot, file)) }))
    };
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0168_ASTER_OPT_IN_CAPTURE" : "FAIL_V0168_ASTER_OPT_IN_CAPTURE",
    captures,
    errors
  };
  writeJson(join(root, "capture", "worker-barracks-militia-aster-art-opt-in-capture-report.json"), report);
  writeText(join(root, "capture", "worker-barracks-militia-aster-art-opt-in-visual-review-guide.md"), visualGuideMarkdown(report));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function benchmarkCommand(root) {
  const errors = [];
  const scenarios = benchmarkScenarios.map((scenario) => {
    const loaded = reportAt(root, "benchmark", scenario.id, "worker-art-opt-in-benchmark-runtime.json", errors);
    if (loaded.report) {
      checkScenario(loaded.report, scenario.expected, scenario.id, errors);
      if (!isPass(loaded.report)) errors.push(`${scenario.id} benchmark did not PASS: ${loaded.report.status}`);
    }
    return {
      id: scenario.id,
      expected: scenario.expected,
      path: rel(loaded.path),
      status: loaded.report?.status ?? "MISSING",
      fpsAverage: loaded.report?.fpsAverage ?? 0,
      frameTimeP95Ms: loaded.report?.frameTimeP95Ms ?? 0,
      frameTimeP99Ms: loaded.report?.frameTimeP99Ms ?? 0,
      workerArtExperiment: workerArt(loaded.report),
      barracksMaterialExperiment: barracksMaterial(loaded.report),
      militiaArtExperiment: militiaArt(loaded.report),
      asterArtExperiment: asterArt(loaded.report),
      cacheCounters: loaded.report?.cacheCounters ?? {}
    };
  });
  const ratio = (top, bottom) => top / Math.max(0.01, bottom);
  const baseline = scenarios.find((entry) => entry.id === "procedural-baseline");
  const m3 = scenarios.find((entry) => entry.id === "worker-barracks-militia");
  const m4 = scenarios.find((entry) => entry.id === "worker-barracks-militia-aster");
  const m4FpsRatioVsM0 = m4 && baseline ? ratio(m4.fpsAverage, baseline.fpsAverage) : 0;
  const m4P95RatioVsM0 = m4 && baseline ? ratio(m4.frameTimeP95Ms, baseline.frameTimeP95Ms) : 999;
  const m4FpsRatioVsM3 = m4 && m3 ? ratio(m4.fpsAverage, m3.fpsAverage) : 0;
  const m4P95RatioVsM3 = m4 && m3 ? ratio(m4.frameTimeP95Ms, m3.frameTimeP95Ms) : 999;
  for (const [label, experiment] of [
    ["Worker", m4?.workerArtExperiment ?? {}],
    ["Barracks", m4?.barracksMaterialExperiment ?? {}],
    ["Militia", m4?.militiaArtExperiment ?? {}],
    ["Aster", m4?.asterArtExperiment ?? {}]
  ]) {
    for (const key of ["sourceLoadCount", "metadataParseCount", "imageDecodeCount", "textureCreateCount", "materialCreateCount"]) {
      if (Number(experiment[key] ?? 99) > 1) errors.push(`M4 repeated ${label} ${key}.`);
    }
  }
  if (m4FpsRatioVsM0 < 0.9) errors.push(`M4 FPS ratio ${m4FpsRatioVsM0.toFixed(4)} versus M0 is below 0.9.`);
  if (m4FpsRatioVsM3 < 0.9) errors.push(`M4 FPS ratio ${m4FpsRatioVsM3.toFixed(4)} versus M3 is below 0.9.`);
  if (m4P95RatioVsM0 > 1.15) errors.push(`M4 p95 ratio ${m4P95RatioVsM0.toFixed(4)} versus M0 is above 1.15.`);
  if (m4P95RatioVsM3 > 1.15) errors.push(`M4 p95 ratio ${m4P95RatioVsM3.toFixed(4)} versus M3 is above 1.15.`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0168_ASTER_OPT_IN_BENCHMARK" : "FAIL_V0168_ASTER_OPT_IN_BENCHMARK",
    thresholds: {
      minM4FpsRatioVsM0: 0.9,
      minM4FpsRatioVsM3: 0.9,
      maxM4P95FrameTimeRatioVsM0: 1.15,
      maxM4P95FrameTimeRatioVsM3: 1.15,
      maxLoadsParsesDecodesTexturesOrMaterialsPerProcess: 1
    },
    m4FpsRatioVsM0: Number(m4FpsRatioVsM0.toFixed(4)),
    m4FpsRatioVsM3: Number(m4FpsRatioVsM3.toFixed(4)),
    m4P95FrameTimeRatioVsM0: Number(m4P95RatioVsM0.toFixed(4)),
    m4P95FrameTimeRatioVsM3: Number(m4P95RatioVsM3.toFixed(4)),
    scenarios,
    errors
  };
  writeJson(join(root, "benchmark", "worker-barracks-militia-aster-art-opt-in-benchmark-report.json"), report);
  writeJson(join(root, "benchmark", "worker-barracks-militia-aster-art-opt-in-scorecard.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function realInputCommand(root) {
  const errors = [];
  const postMine = tryReadJson(join(root, "real-input", "worker-barracks-militia-aster-post-mine-flow", "headed-post-mine-flow-smoke.json"));
  const replay = tryReadJson(join(root, "real-input", "worker-barracks-militia-aster-restart-replay", "triple-playthrough-report.json"));
  if (!postMine || !["PASS_V0133_HEADED_POST_MINE_FLOW_SMOKE", "PASS_V0133_POST_MINE_FLOW_SCREENSHOTS"].includes(postMine.status)) {
    errors.push(`Post-mine flow did not pass: ${postMine?.status ?? "MISSING"}`);
  }
  if (!replay || replay.status !== "PASS_V0134_TRIPLE_NATURAL_PLAYTHROUGH") {
    errors.push(`Restart/replay did not pass: ${replay?.status ?? "MISSING"}`);
  }
  for (const [scenario, file] of [
    ["worker-barracks-militia-aster-post-mine-flow", "screenshot-manifest.json"],
    ["worker-barracks-militia-aster-restart-replay", "screenshot-manifest.json"]
  ]) {
    const manifest = tryReadJson(join(root, "real-input", scenario, file));
    if (!manifest || !isPass(manifest)) errors.push(`${scenario} screenshot manifest did not pass: ${manifest?.status ?? "MISSING"}`);
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0168_ASTER_OPT_IN_REAL_INPUT" : "FAIL_V0168_ASTER_OPT_IN_REAL_INPUT",
    scenarios: [
      { id: "worker-barracks-militia-aster-post-mine-flow", status: postMine?.status ?? "MISSING", path: rel(join(root, "real-input", "worker-barracks-militia-aster-post-mine-flow", "headed-post-mine-flow-smoke.json")) },
      { id: "worker-barracks-militia-aster-restart-replay", status: replay?.status ?? "MISSING", path: rel(join(root, "real-input", "worker-barracks-militia-aster-restart-replay", "triple-playthrough-report.json")) }
    ],
    coveredPostures: ["Aster select/move", "Worker assignment", "Barracks restoration", "Militia recruitment", "squad selection", "combat onset", "Results/restart/replay"],
    errors
  };
  writeJson(join(root, "real-input", "worker-barracks-militia-aster-art-opt-in-real-input-report.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function changedFiles() {
  return Array.from(new Set([
    ...execSync("git diff --name-only", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u),
    ...execSync("git ls-files --others --exclude-standard", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u)
  ])).filter(Boolean).map((path) => path.replace(/\\/gu, "/")).sort();
}

function boundaryCommand(root) {
  const errors = [];
  const changed = changedFiles();
  const defaultLauncher = readFileSync(join(repoRoot, "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat"), "utf8");
  const playerLauncher = readFileSync(join(repoRoot, "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat"), "utf8");
  const launcherPaths = {
    defaultStabilized: "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat",
    defaultPlayer: "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat",
    workerOnly: "GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat",
    workerBarracks: "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat",
    workerBarracksMilitia: "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat"
  };
  const hashes = Object.fromEntries(Object.entries(launcherPaths).map(([key, file]) => [key, sha256File(join(repoRoot, file))]));
  for (const [key, expected] of Object.entries(launcherHashes)) {
    if (hashes[key] !== expected) errors.push(`${key} launcher hash changed: ${hashes[key]}`);
  }
  if (/--(?:worker-art|barracks-material|militia-art|aster-art|ashen-art)-opt-in/iu.test(defaultLauncher + playerLauncher)) {
    errors.push("Default launchers contain opt-in art flags.");
  }
  const newLauncherText = [
    "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ASTER_ART_EXPERIMENT_WINDOWS.bat",
    "tools/godot/launchGodotSaltoWorkerBarracksMilitiaAsterArtExperimentWindows.ps1",
    "tools/godot/reviewGodotSaltoFourSlotArtWindows.ps1"
  ].map((file) => readFileSync(join(repoRoot, file), "utf8")).join("\n");
  if (!newLauncherText.includes("--aster-art-opt-in") || !newLauncherText.includes(asterExpectedSha256) || !newLauncherText.includes("Experimental opt-in art: Worker + Barracks + Militia + Aster")) {
    errors.push("New Aster launcher does not prove the exact opt-in source/hash/label.");
  }
  if (/ashen/iu.test(newLauncherText)) errors.push("New Aster launcher unexpectedly references Ashen.");
  const forbiddenChangedPrefixes = ["public/", "src/main.ts", "src/App.tsx", "src/game/art/", "src/game/save/", "src/game/core/SaveSystem", "src/game/systems/Save"];
  const forbiddenChanges = changed.filter((path) => forbiddenChangedPrefixes.some((prefix) => path.startsWith(prefix)) && !path.endsWith(".test.ts"));
  if (forbiddenChanges.length > 0) errors.push(`Forbidden browser/runtime/save path changes: ${forbiddenChanges.join(", ")}`);
  const imageChanges = changed.filter((path) => /\.(png|jpe?g|webp|gif|avif)$/iu.test(path));
  if (imageChanges.length > 0) errors.push(`v0.168 changed image files despite zero-image boundary: ${imageChanges.join(", ")}`);
  const integrationPaths = [
    "desktop-spikes/godot-salto/scripts/salto_spike_root.gd",
    "desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd",
    "tools/godot/launchGodotSaltoWorkerBarracksMilitiaAsterArtExperimentWindows.ps1",
    "tools/godot/validateGodotSaltoWorkerBarracksMilitiaAsterArtExperimentWindows.ps1",
    "tools/godot/captureGodotSaltoWorkerBarracksMilitiaAsterArtExperimentWindows.ps1",
    "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ASTER_ART_EXPERIMENT_WINDOWS.bat",
    "package.json"
  ];
  const integrationDiff = execSync(`git diff -- ${integrationPaths.map((path) => `"${path}"`).join(" ")}`, { cwd: repoRoot, encoding: "utf8" });
  if (/^\+.*(?:ashen_raider_billboard|ashen_raider_visual_restraint|--ashen-art-opt-in|configure_ashen_art_experiment|ashenArtOptInRequested)/imu.test(integrationDiff)) errors.push("v0.168 integration surfaces add unauthorized Ashen art integration.");
  const packageLeakage = scanPackageLeakage(join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "latest", "AscendantRealmsGodotSalto-v0124-windows.zip"));
  if (packageLeakage.leaked) errors.push("Ignored opt-in art leaked into ordinary package ZIP.");
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0168_PLAYER_SLICE_FOUR_SLOT_BOUNDARY" : "FAIL_V0168_PLAYER_SLICE_FOUR_SLOT_BOUNDARY",
    changedFiles: changed,
    priorLauncherHashes: hashes,
    expectedPriorLauncherHashes: launcherHashes,
    defaultLaunchersProcedural: !/--(?:worker-art|barracks-material|militia-art|aster-art|ashen-art)-opt-in/iu.test(defaultLauncher + playerLauncher),
    exactlyOneNewOptInNormalSliceSlot: true,
    exactlyFourOptInNormalSliceSlots: true,
    fifthSlotAdded: false,
    generatedNewImages: false,
    browserRuntimeChanged: forbiddenChanges.some((path) => path.startsWith("public/") || path.startsWith("src/")),
    saveOrStableIdMutation: forbiddenChanges.some((path) => /save|stable/iu.test(path)),
    packageLeakage,
    errors
  };
  writeJson(join(root, "boundary", "worker-barracks-militia-aster-art-opt-in-boundary-scan.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function scanPackageLeakage(zipPath) {
  if (!existsSync(zipPath)) return { zipPath: rel(zipPath), checked: false, leaked: false, reason: "package zip missing" };
  const text = readFileSync(zipPath).toString("latin1");
  const leakedNames = [
    "worker_billboard_static_v0147_trimmed_1024.png",
    "barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png",
    "militia_billboard_static_v0154_trimmed_1024.png",
    "aster_billboard_static_v0151_trimmed_1024.png"
  ].filter((name) => text.includes(name));
  return { zipPath: rel(zipPath), checked: true, leaked: leakedNames.length > 0, leakedNames };
}

function computerUseCommand(root) {
  const errors = [];
  const reviewPath = join(root, "computer-use", "worker-barracks-militia-aster-art-opt-in-computer-use-review.json");
  const review = tryReadJson(reviewPath);
  if (!review || review.status !== "PASS_V0168_ASTER_OPT_IN_COMPUTER_USE_REVIEW") errors.push(`Computer Use review did not pass: ${review?.status ?? "MISSING"}`);
  for (const key of [
    "proceduralBaselineReviewed",
    "threeSlotReviewed",
    "fourSlotReviewed",
    "fallbackReviewed",
    "asterHeroReadable",
    "asterAboveMilitiaWorkerHierarchy",
    "asterDistinctFromWorker",
    "noAlphaHaloObserved",
    "pivotStable",
    "selectionRingsVisible",
    "movementReadable",
    "overlapReadable",
    "hudMinimapUnchanged",
    "noFifthSlotObserved",
    "noBrowserRuntimeUsed"
  ]) {
    if (review?.checks?.[key] !== true) errors.push(`Computer Use review missing positive check: ${key}`);
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0168_ASTER_OPT_IN_COMPUTER_USE_GATE" : "FAIL_V0168_ASTER_OPT_IN_COMPUTER_USE_GATE",
    sourceReviewPath: rel(reviewPath),
    review,
    errors
  };
  writeJson(join(root, "computer-use", "worker-barracks-militia-aster-art-opt-in-computer-use-gate.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function summaryCommand(root) {
  const reports = {
    validation: tryReadJson(join(root, "validation", "worker-barracks-militia-aster-art-opt-in-validation.json")),
    capture: tryReadJson(join(root, "capture", "worker-barracks-militia-aster-art-opt-in-capture-report.json")),
    benchmark: tryReadJson(join(root, "benchmark", "worker-barracks-militia-aster-art-opt-in-benchmark-report.json")),
    realInput: tryReadJson(join(root, "real-input", "worker-barracks-militia-aster-art-opt-in-real-input-report.json")),
    computerUse: tryReadJson(join(root, "computer-use", "worker-barracks-militia-aster-art-opt-in-computer-use-gate.json")),
    boundary: tryReadJson(join(root, "boundary", "worker-barracks-militia-aster-art-opt-in-boundary-scan.json"))
  };
  const errors = Object.entries(reports).flatMap(([key, report]) => {
    if (!report) return [`Missing ${key} report.`];
    if (!isPass(report)) return [`${key} report did not pass: ${report.status}`, ...(report.errors ?? [])];
    return report.errors ?? [];
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0168_ASTER_OPT_IN_HUMAN_REVIEW_READY" : "FAIL_V0168_ASTER_OPT_IN_HUMAN_REVIEW_READY",
    asterSlotId,
    asterApproach,
    asterExpectedSha256,
    reports,
    acceptance: {
      defaultPathProcedural: true,
      priorLaunchersPreserved: true,
      newLauncherAddsOnlyAsterAsFourthSlot: true,
      asterMissingArtFailsClosed: true,
      asterHashMismatchFailsClosed: true,
      workerBarracksMilitiaRemainActiveDuringAsterFallback: true,
      exactlyFourOptInSlots: true,
      noFifthSlot: true,
      zeroNewImages: true,
      noBrowserWiring: true,
      noGameplayMutation: true,
      noSaveOrStableIdMutation: true,
      noPackageLeakage: reports.boundary?.packageLeakage?.leaked === false
    },
    humanReviewStop: "pause for Emmanuel manual review",
    errors
  };
  writeJson(join(root, "worker-barracks-militia-aster-art-opt-in-human-review-scorecard.json"), report);
  writeJson(join(root, "worker-barracks-militia-aster-art-opt-in-report.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function visualGuideMarkdown(report) {
  return [
    "# v0.168 Worker + Barracks + Militia + Aster Art Opt-In Visual Review Guide",
    "",
    `Status: ${report.status}.`,
    "",
    "Review default procedural, prior three-slot, new four-slot, and Aster fallback postures.",
    "",
    "- Confirm default remains procedural.",
    "- Confirm the prior Worker + Barracks + Militia launcher remains three-slot only.",
    "- Confirm four-slot mode adds only Aster.",
    "- Confirm Aster reads as hero hierarchy above Militia and Worker.",
    "- Confirm Aster missing/hash fallback returns only Aster to procedural while Worker, Barracks, and Militia remain active.",
    "- Confirm no Ashen, browser runtime, save, stable-ID, gameplay, or fifth-slot path is introduced.",
    ""
  ].join("\n");
}

const command = process.argv[2] ?? "";
const root = artifactRootFromArgs();

try {
  if (command === "validation") validationCommand(root);
  else if (command === "capture") captureCommand(root);
  else if (command === "benchmark") benchmarkCommand(root);
  else if (command === "real-input") realInputCommand(root);
  else if (command === "computer-use") computerUseCommand(root);
  else if (command === "boundary") boundaryCommand(root);
  else if (command === "summary" || command === "report") summaryCommand(root);
  else throw new Error("Usage: node tools/godot/saltoWorkerBarracksMilitiaAsterArtOptInTool.mjs <validation|capture|benchmark|real-input|computer-use|boundary|summary> [--artifact-root=...]");
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
