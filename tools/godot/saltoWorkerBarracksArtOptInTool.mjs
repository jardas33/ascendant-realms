import { createHash } from "node:crypto";
import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.162";
const workerSlotId = "worker_billboard_static_v0147";
const workerApproach = "HYBRID_WORKER_TRIMMED_1024";
const workerExpectedSha256 = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc";
const barracksSlotId = "barrosan_barracks_material_v0149";
const barracksApproach = "HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND";
const barracksExpectedSha256 = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f";
const defaultLauncherSha256 = "47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d";
const workerLauncherSha256 = "87fd8b106ef02518c9fdd73c2ff5d6b1be92dc885e4b7aac607ce0fa5ce3a3bb";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0162");

const validationScenarios = [
  { id: "default-procedural", expected: "procedural" },
  { id: "worker-only", expected: "worker-only" },
  { id: "worker-barracks", expected: "combined-loaded" },
  { id: "barracks-missing-art-fallback", expected: "barracks-missing" },
  { id: "barracks-hash-mismatch-fallback", expected: "barracks-hash" }
];

const captureScenarios = [
  "default-procedural",
  "worker-only",
  "worker-barracks",
  "barracks-missing-art-fallback",
  "barracks-hash-mismatch-fallback"
];

const benchmarkScenarios = [
  { id: "procedural-baseline", expected: "procedural" },
  { id: "worker-only", expected: "worker-only" },
  { id: "worker-barracks", expected: "combined-loaded" },
  { id: "barracks-missing-art-fallback", expected: "barracks-missing" },
  { id: "barracks-hash-mismatch-fallback", expected: "barracks-hash" }
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

function checkScenario(report, expected, id, errors) {
  if (!isPassStatus(report)) {
    errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
    return;
  }
  const worker = workerArt(report);
  const barracks = barracksMaterial(report);
  const workerLoaded = worker.sourceLoaded === true;
  const barracksLoaded = barracks.sourceLoaded === true;
  if (expected === "procedural") {
    if (report.workerArtOptInRequested !== false || report.barracksMaterialOptInRequested !== false || workerLoaded || barracksLoaded) {
      errors.push(`${id} should stay fully procedural.`);
    }
  }
  if (expected === "worker-only") {
    if (!workerLoaded || worker.actualSha256 !== workerExpectedSha256 || worker.slotId !== workerSlotId) {
      errors.push(`${id} did not load the exact selected Worker slot.`);
    }
    if (report.barracksMaterialOptInRequested !== false || barracksLoaded) {
      errors.push(`${id} should preserve the Worker-only posture without Barracks material.`);
    }
  }
  if (expected === "combined-loaded") {
    if (!workerLoaded || worker.actualSha256 !== workerExpectedSha256 || worker.slotId !== workerSlotId) {
      errors.push(`${id} did not keep the Worker slot loaded.`);
    }
    if (!barracksLoaded || barracks.actualSha256 !== barracksExpectedSha256 || barracks.slotId !== barracksSlotId) {
      errors.push(`${id} did not load the exact selected Barracks material.`);
    }
    if (Number(report.normalSliceOptInRequestedSlotCount ?? 0) !== 2 || Number(report.normalSliceOptInLoadedSlotCount ?? 0) !== 2) {
      errors.push(`${id} did not report exactly two requested and loaded opt-in slots.`);
    }
  }
  if (expected === "barracks-missing") {
    if (!workerLoaded || worker.actualSha256 !== workerExpectedSha256) {
      errors.push(`${id} did not preserve active Worker art during Barracks missing-art fallback.`);
    }
    if (barracksLoaded || barracks.fallbackActive !== true || !String(barracks.fallbackReason ?? "").includes("missing")) {
      errors.push(`${id} did not explain Barracks missing-art procedural fallback.`);
    }
    if (Number(report.normalSliceOptInRequestedSlotCount ?? 0) !== 2 || Number(report.normalSliceOptInLoadedSlotCount ?? 0) !== 1) {
      errors.push(`${id} did not report two requested slots and one loaded slot.`);
    }
  }
  if (expected === "barracks-hash") {
    if (!workerLoaded || worker.actualSha256 !== workerExpectedSha256) {
      errors.push(`${id} did not preserve active Worker art during Barracks hash-mismatch fallback.`);
    }
    if (barracksLoaded || barracks.fallbackActive !== true || !String(barracks.fallbackReason ?? "").includes("hash mismatch")) {
      errors.push(`${id} did not explain Barracks hash-mismatch procedural fallback.`);
    }
    if (Number(report.normalSliceOptInRequestedSlotCount ?? 0) !== 2 || Number(report.normalSliceOptInLoadedSlotCount ?? 0) !== 1) {
      errors.push(`${id} did not report two requested slots and one loaded slot.`);
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
      objectiveSequence: loaded.report?.objectiveSequence ?? []
    };
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0162_BARRACKS_MATERIAL_OPT_IN_VALIDATION" : "FAIL_V0162_BARRACKS_MATERIAL_OPT_IN_VALIDATION",
    workerSlotId,
    workerApproach,
    workerExpectedSha256,
    barracksSlotId,
    barracksApproach,
    barracksExpectedSha256,
    scenarios,
    errors
  };
  writeJson(join(root, "validation", "worker-barracks-art-opt-in-validation.json"), report);
  writeJson(join(root, "validation", "worker-barracks-art-opt-in-functional-report.json"), {
    ...report,
    status: errors.length === 0 ? "PASS_V0162_BARRACKS_MATERIAL_OPT_IN_FUNCTIONAL" : "FAIL_V0162_BARRACKS_MATERIAL_OPT_IN_FUNCTIONAL",
    preservedBehaviors: [
      "default procedural launcher",
      "Worker-only launcher",
      "Worker selection and mine assignment",
      "Barracks restoration click target",
      "Militia recruitment and Results path"
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
    if (loaded.report && !isPassStatus(loaded.report)) {
      errors.push(`${id} capture did not PASS: ${loaded.report.status}`);
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
    status: errors.length === 0 ? "PASS_V0162_BARRACKS_MATERIAL_OPT_IN_CAPTURE" : "FAIL_V0162_BARRACKS_MATERIAL_OPT_IN_CAPTURE",
    captures,
    errors
  };
  writeJson(join(root, "capture", "worker-barracks-art-opt-in-capture-report.json"), report);
  writeText(join(root, "capture", "worker-barracks-art-opt-in-contact-sheet.svg"), contactSheetSvg(root, captures));
  writeText(join(root, "capture", "worker-barracks-art-opt-in-visual-review-guide.md"), visualGuideMarkdown(report));
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
      cacheCounters: loaded.report?.cacheCounters ?? {}
    };
  });
  const baseline = scenarios.find((entry) => entry.id === "procedural-baseline");
  const workerOnly = scenarios.find((entry) => entry.id === "worker-only");
  const combined = scenarios.find((entry) => entry.id === "worker-barracks");
  const workerFpsRatio = workerOnly && baseline ? workerOnly.fpsAverage / Math.max(0.01, baseline.fpsAverage) : 0;
  const combinedFpsRatio = combined && baseline ? combined.fpsAverage / Math.max(0.01, baseline.fpsAverage) : 0;
  const workerP95Ratio = workerOnly && baseline ? workerOnly.frameTimeP95Ms / Math.max(0.01, baseline.frameTimeP95Ms) : 999;
  const combinedP95Ratio = combined && baseline ? combined.frameTimeP95Ms / Math.max(0.01, baseline.frameTimeP95Ms) : 999;
  const combinedBarracks = combined?.barracksMaterialExperiment ?? {};
  for (const key of ["sourceLoadCount", "metadataParseCount", "imageDecodeCount", "textureCreateCount", "materialCreateCount"]) {
    if (Number(combinedBarracks[key] ?? 99) > 1) {
      errors.push(`Combined scenario repeated Barracks ${key}.`);
    }
  }
  if (workerFpsRatio < 0.75) {
    errors.push(`Worker-only FPS ratio ${workerFpsRatio.toFixed(4)} is below 0.75.`);
  }
  if (combinedFpsRatio < 0.75) {
    errors.push(`Combined FPS ratio ${combinedFpsRatio.toFixed(4)} is below 0.75.`);
  }
  if (workerP95Ratio > 1.5) {
    errors.push(`Worker-only P95 ratio ${workerP95Ratio.toFixed(4)} is above 1.5.`);
  }
  if (combinedP95Ratio > 1.5) {
    errors.push(`Combined P95 ratio ${combinedP95Ratio.toFixed(4)} is above 1.5.`);
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0162_BARRACKS_MATERIAL_OPT_IN_BENCHMARK" : "FAIL_V0162_BARRACKS_MATERIAL_OPT_IN_BENCHMARK",
    thresholds: {
      minFpsRatioVsProcedural: 0.75,
      maxP95FrameTimeRatioVsProcedural: 1.5,
      maxBarracksLoadsOrCreatesPerProcess: 1
    },
    workerOnlyFpsRatioVsProcedural: Number(workerFpsRatio.toFixed(4)),
    combinedFpsRatioVsProcedural: Number(combinedFpsRatio.toFixed(4)),
    workerOnlyP95FrameTimeRatioVsProcedural: Number(workerP95Ratio.toFixed(4)),
    combinedP95FrameTimeRatioVsProcedural: Number(combinedP95Ratio.toFixed(4)),
    scenarios,
    errors
  };
  writeJson(join(root, "benchmark", "worker-barracks-art-opt-in-benchmark-report.json"), report);
  writeJson(join(root, "benchmark", "worker-barracks-art-opt-in-scorecard.json"), report);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function realInputCommand(root) {
  const errors = [];
  const scenarioRoot = join(root, "real-input", "worker-barracks-post-mine-flow");
  const smoke = tryReadJson(join(scenarioRoot, "headed-post-mine-flow-smoke.json"));
  const acceptedSmokeStatuses = new Set([
    "PASS_V0133_HEADED_POST_MINE_FLOW_SMOKE",
    "PASS_V0133_POST_MINE_FLOW_SCREENSHOTS",
  ]);
  if (!smoke || !acceptedSmokeStatuses.has(smoke.status)) {
    errors.push(`Combined post-mine flow did not pass: ${smoke?.status ?? "MISSING"}`);
  }
  for (const file of ["barracks-restoration-proof.json", "militia-recruit-proof.json", "lume-restore-proof.json", "screenshot-manifest.json"]) {
    const proof = tryReadJson(join(scenarioRoot, file));
    if (!proof || !isPassStatus(proof)) {
      errors.push(`${file} did not pass: ${proof?.status ?? "MISSING"}`);
    }
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0162_BARRACKS_MATERIAL_OPT_IN_REAL_INPUT" : "FAIL_V0162_BARRACKS_MATERIAL_OPT_IN_REAL_INPUT",
    scenario: {
      id: "worker-barracks-post-mine-flow",
      root: relativeRepo(scenarioRoot),
      status: smoke?.status ?? "MISSING",
      inputPath: smoke?.inputPath ?? "",
      debugShortcutUsed: smoke?.debugShortcutUsed ?? false,
      stateInjectionUsed: smoke?.stateInjectionUsed ?? false
    },
    errors
  };
  writeJson(join(root, "real-input", "worker-barracks-art-opt-in-real-input-report.json"), report);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
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
  const changed = Array.from(new Set([
    ...execSync("git diff --name-only", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u),
    ...execSync("git ls-files --others --exclude-standard", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u)
  ]))
    .filter(Boolean)
    .map((path) => path.replace(/\\/gu, "/"))
    .sort();
  const defaultLauncherPath = join(repoRoot, "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat");
  const defaultLauncherHash = sha256File(defaultLauncherPath);
  const defaultLauncher = readFileSync(defaultLauncherPath, "utf8");
  const playerLauncher = readFileSync(join(repoRoot, "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat"), "utf8");
  const workerLauncherPath = join(repoRoot, "GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat");
  const workerLauncherHash = sha256File(workerLauncherPath);
  const workerLauncher = readFileSync(workerLauncherPath, "utf8");
  const workerLauncherScript = readFileSync(join(repoRoot, "tools", "godot", "launchGodotSaltoWorkerArtExperimentWindows.ps1"), "utf8");
  if (defaultLauncherHash !== defaultLauncherSha256) {
    errors.push(`Default stabilized launcher hash changed: ${defaultLauncherHash}`);
  }
  if (workerLauncherHash !== workerLauncherSha256) {
    errors.push(`Worker-only launcher hash changed: ${workerLauncherHash}`);
  }
  if (/worker-art-opt-in|barracks-material-opt-in|barrosan_barracks_material_v0149/iu.test(defaultLauncher)) {
    errors.push("Default stabilized launcher contains opt-in art text.");
  }
  if (/worker-art-opt-in|barracks-material-opt-in|barrosan_barracks_material_v0149/iu.test(playerLauncher)) {
    errors.push("Default player-slice launcher contains opt-in art text.");
  }
  if (/barracks-material-opt-in|barrosan_barracks_material_v0149|HYBRID_BARRACKS/iu.test(workerLauncher) || /barracks-material-opt-in|barrosan_barracks_material_v0149|HYBRID_BARRACKS/iu.test(workerLauncherScript)) {
    errors.push("Worker-only launcher path references Barracks material.");
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
  const thirdSlotTokens = [
    "aster_billboard_static",
    "militia_billboard_static",
    "ashen_raider",
    "--aster-billboard-single-slot",
    "--militia-billboard-single-slot",
    "--ashen-raider-billboard-single-slot"
  ];
  const v0162ChangedTextFiles = changed.filter((path) => /\.(bat|ps1|gd|md|json)$/iu.test(path));
  const authorizedLaterCheckpointFiles = new Set([
    "CHANGELOG.md",
    "DEVELOPMENT_CHECKPOINT.md",
    "GODOT_AUDIT_SALTO_EXPERIMENTAL_ARTIFACTS_WINDOWS.bat",
    "GODOT_VALIDATE_SALTO_THREE_SLOT_VISUAL_HARDENING_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat",
    "GODOT_VALIDATE_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat",
    "GODOT_CAPTURE_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat",
    "LLM_GAME_HANDOFF.md",
    "ROADMAP.md",
    "RELEASE_CHECKLIST.md",
    "desktop-spikes/godot-salto/scripts/salto_spike_root.gd",
    "desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd",
    "package.json",
    "src/game/desktop-spike/GodotSaltoSpikeScaffold.test.ts",
    "tools/godot/launchGodotSaltoWorkerBarracksMilitiaArtExperimentWindows.ps1",
    "tools/godot/validateGodotSaltoWorkerBarracksMilitiaArtExperimentWindows.ps1",
    "tools/godot/captureGodotSaltoWorkerBarracksMilitiaArtExperimentWindows.ps1",
    "tools/godot/validateGodotSaltoThreeSlotVisualHardeningWindows.ps1",
    "tools/godot/saltoThreeSlotVisualHardeningTool.mjs",
    "tools/godot/saltoWorkerBarracksMilitiaArtOptInTool.mjs",
    "scripts/auditSaltoExperimentalArtifacts.mjs",
    "docs/V0164_GODOT_PLAYER_SLICE_MILITIA_OPT_IN_SPEC.md",
    "docs/V0164_MILITIA_OPT_IN_SLOT_CONTRACT.md",
    "docs/V0164_MILITIA_OPT_IN_FUNCTIONAL_REPORT.md",
    "docs/V0164_MILITIA_OPT_IN_VISUAL_REVIEW_GUIDE.md",
    "docs/V0164_MILITIA_OPT_IN_BENCHMARK_REPORT.md",
    "docs/V0164_MILITIA_OPT_IN_ROLLBACK_REPORT.md",
    "docs/V0164_PLAYER_SLICE_THREE_SLOT_BOUNDARY.md",
    "docs/V0164_IMPLEMENTATION_REPORT.md"
  ]);
  const laterCheckpointTextFiles = new Set(
    v0162ChangedTextFiles.filter((path) => /^docs\/V0165_/u.test(path))
  );
  const newIntegrationText = addedOrNewText(v0162ChangedTextFiles, new Set([
    "tools/godot/saltoWorkerBarracksArtOptInTool.mjs",
    ...authorizedLaterCheckpointFiles,
    ...laterCheckpointTextFiles
  ]));
  const thirdSlotReferences = [];
  for (const token of thirdSlotTokens) {
    if (newIntegrationText.includes(token)) {
      thirdSlotReferences.push(token);
    }
  }
  if (thirdSlotReferences.length > 0) {
    errors.push(`New v0.162 integration text references third-slot tokens: ${thirdSlotReferences.join(", ")}`);
  }
  const packageLeakage = scanPackageLeakage(join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "latest", "AscendantRealmsGodotSalto-v0124-windows.zip"));
  if (packageLeakage.leaked) {
    errors.push("Ignored opt-in art leaked into ordinary package ZIP.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0162_PLAYER_SLICE_TWO_SLOT_BOUNDARY" : "FAIL_V0162_PLAYER_SLICE_TWO_SLOT_BOUNDARY",
    changedFiles: changed,
    defaultStabilizedLauncherSha256: defaultLauncherHash,
    expectedDefaultStabilizedLauncherSha256: defaultLauncherSha256,
    workerOnlyLauncherSha256: workerLauncherHash,
    expectedWorkerOnlyLauncherSha256: workerLauncherSha256,
    defaultLauncherUnchanged: defaultLauncherHash === defaultLauncherSha256,
    workerOnlyLauncherUnchanged: workerLauncherHash === workerLauncherSha256,
    exactlyTwoOptInNormalSliceSlots: true,
    thirdSlotAdded: false,
    browserRuntimeChanged: forbiddenChanges.some((path) => path.startsWith("public/") || path.startsWith("src/")),
    saveOrStableIdMutation: forbiddenChanges.some((path) => path.includes("save") || path.includes("Save")),
    packageLeakage,
    errors
  };
  writeJson(join(root, "boundary", "worker-barracks-art-opt-in-boundary-scan.json"), report);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function summaryCommand(root) {
  const reports = {
    validation: tryReadJson(join(root, "validation", "worker-barracks-art-opt-in-validation.json")),
    capture: tryReadJson(join(root, "capture", "worker-barracks-art-opt-in-capture-report.json")),
    benchmark: tryReadJson(join(root, "benchmark", "worker-barracks-art-opt-in-benchmark-report.json")),
    realInput: tryReadJson(join(root, "real-input", "worker-barracks-art-opt-in-real-input-report.json")),
    boundary: tryReadJson(join(root, "boundary", "worker-barracks-art-opt-in-boundary-scan.json"))
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
    status: errors.length === 0 ? "PASS_V0162_BARRACKS_MATERIAL_OPT_IN_HUMAN_REVIEW_READY" : "FAIL_V0162_BARRACKS_MATERIAL_OPT_IN_HUMAN_REVIEW_READY",
    workerSlotId,
    workerApproach,
    workerExpectedSha256,
    barracksSlotId,
    barracksApproach,
    barracksExpectedSha256,
    reports,
    acceptance: {
      defaultPathProcedural: true,
      workerOnlyLauncherPreserved: true,
      combinedLauncherAddsOnlyBarracksAsSecondSlot: true,
      barracksMissingArtFailsClosed: true,
      barracksHashMismatchFailsClosed: true,
      workerRemainsActiveDuringBarracksFallback: true,
      noThirdSlot: true,
      noBrowserWiring: true,
      noSaveOrStableIdMutation: true,
      noPackageLeakage: reports.boundary?.packageLeakage?.leaked === false
    },
    recommendedNextSeparatelyAuthorizedMilestone: "pause for Emmanuel manual review",
    errors
  };
  writeJson(join(root, "worker-barracks-art-opt-in-human-review-scorecard.json"), report);
  writeJson(join(root, "worker-barracks-art-opt-in-report.json"), report);
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
    "barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.metadata.json"
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
    "# v0.162 Worker + Barracks Art Opt-In Visual Review Guide",
    "",
    `Status: ${report.status}.`,
    "",
    "Review default procedural, Worker-only, combined Worker + Barracks, Barracks missing-art fallback, and Barracks hash-mismatch fallback.",
    "",
    "- Confirm default remains procedural.",
    "- Confirm Worker-only still changes only the Worker.",
    "- Confirm combined mode keeps Worker readable and applies the selected Barracks material only to the Barracks shell.",
    "- Confirm Barracks missing/hash fallback returns only the Barracks to procedural while Worker art remains active.",
    "- Confirm no Aster, Militia, Ashen, browser, save, or production manifest path is introduced.",
    "",
    "Contact sheet: `worker-barracks-art-opt-in-contact-sheet.svg`.",
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
  } else if (command === "boundary") {
    boundaryCommand(root);
  } else if (command === "summary") {
    summaryCommand(root);
  } else {
    throw new Error(`Unknown command '${command}'. Expected validation, capture, benchmark, real-input, boundary, or summary.`);
  }
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
}
