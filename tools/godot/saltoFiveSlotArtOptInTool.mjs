import { createHash } from "node:crypto";
import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.170";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0170");
const workerSlotId = "worker_billboard_static_v0147";
const workerExpectedSha256 = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc";
const barracksSlotId = "barrosan_barracks_material_v0149";
const barracksExpectedSha256 = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f";
const militiaSlotId = "militia_billboard_static_v0154";
const militiaExpectedSha256 = "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb";
const asterSlotId = "aster_billboard_static_v0151";
const asterExpectedSha256 = "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a";
const ashenSlotId = "ashen_raider_billboard_static_v0156";
const ashenApproach = "HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024";
const ashenExpectedSha256 = "8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8";
const priorLauncherHashes = {
  defaultStabilized: ["GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d"],
  defaultPlayer: ["GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "737e8509e5571e5e6c928b6070e9b9cd108182dd667365ceafd01b648dce8df2"],
  workerOnly: ["GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat", "87fd8b106ef02518c9fdd73c2ff5d6b1be92dc885e4b7aac607ce0fa5ce3a3bb"],
  workerBarracks: ["GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat", "a795b154fb08abd2664321a802050db6d73808aa73fd2ae34038c8db4c42be1a"],
  workerBarracksMilitia: ["GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat", "4eab85de03e83e64440da9c90204bd880ce29b2477d2b048940b94cd809245cc"],
  workerBarracksMilitiaAster: ["GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ASTER_ART_EXPERIMENT_WINDOWS.bat", "597e4796c1a4d4a683a2f72d48000e7e188aa271d07df554457a716f6e86a348"]
};

const validationScenarios = [
  { id: "default-procedural", expected: "procedural" },
  { id: "worker-barracks-militia-aster", expected: "four-loaded" },
  { id: "worker-barracks-militia-aster-ashen", expected: "five-loaded" },
  { id: "ashen-missing-art-fallback", expected: "ashen-missing" },
  { id: "ashen-hash-mismatch-fallback", expected: "ashen-hash" }
];

const benchmarkScenarios = [
  { id: "procedural-baseline", expected: "procedural" },
  { id: "worker-barracks-militia-aster", expected: "four-loaded" },
  { id: "worker-barracks-militia-aster-ashen", expected: "five-loaded" },
  { id: "ashen-missing-art-fallback", expected: "ashen-missing" },
  { id: "ashen-hash-mismatch-fallback", expected: "ashen-hash" }
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

function ashenArt(report) {
  return report?.ashenArtExperiment ?? {};
}

function checkLoaded(experiment, slotId, sha, label, errors) {
  if (experiment.sourceLoaded !== true || experiment.actualSha256 !== sha || experiment.slotId !== slotId || experiment.fallbackActive === true) {
    errors.push(`${label} did not load exact selected source ${slotId}.`);
  }
}

function checkPriorFourLoaded(report, id, errors) {
  checkLoaded(workerArt(report), workerSlotId, workerExpectedSha256, `${id} Worker`, errors);
  checkLoaded(barracksMaterial(report), barracksSlotId, barracksExpectedSha256, `${id} Barracks`, errors);
  checkLoaded(militiaArt(report), militiaSlotId, militiaExpectedSha256, `${id} Militia`, errors);
  checkLoaded(asterArt(report), asterSlotId, asterExpectedSha256, `${id} Aster`, errors);
}

function checkAshenVisualContract(experiment, id, errors) {
  if (experiment.approach !== ashenApproach) errors.push(`${id} Ashen approach mismatch.`);
  if (experiment.aspectRatioPreserved !== true) errors.push(`${id} did not preserve Ashen source aspect ratio.`);
  if (Number(experiment.runtimeWorldHeight ?? 0) < 0.68) errors.push(`${id} Ashen runtime height is too small for hostile readability.`);
  if (Number(experiment.runtimeWorldHeight ?? 0) > 0.84) errors.push(`${id} Ashen runtime height risks reading as a hero/elite.`);
  if (Number(experiment.hierarchyRuntimeHeightVsAster ?? 1) >= 0.90) errors.push(`${id} Ashen is not materially below Aster hierarchy.`);
  if (Number(experiment.hierarchyRuntimeHeightVsMilitia ?? 0) < 0.95) errors.push(`${id} Ashen is not readable beside Militia.`);
  if (experiment.visualRestraintIntent?.ordinaryWaveAttacker !== true || experiment.visualRestraintIntent?.noBossOrElitePresentation !== true) {
    errors.push(`${id} Ashen metadata did not preserve restrained ordinary-wave intent.`);
  }
}

function checkAshenAudit(report, expected, id, errors) {
  const audit = report.v0165VisualHardeningAudit ?? {};
  const unitVisuals = Array.isArray(audit.unitVisuals) ? audit.unitVisuals : [];
  const ashenEntries = unitVisuals.filter((entry) => typeof entry.id === "string" && entry.id.startsWith("ashen_"));
  if ((audit.accidentalProceduralOverlayCount ?? 0) !== 0) {
    errors.push(`${id} reported accidental procedural overlays.`);
  }
  if (expected === "five-loaded") {
    if (ashenEntries.length < 4) errors.push(`${id} did not expose the four-attacker Ashen wave in the audit.`);
    const dirty = ashenEntries.filter((entry) => entry.meshClass !== "QuadMesh" || entry.childVisualCount !== 0 || entry.proceduralVisualVisible === true);
    if (dirty.length > 0) errors.push(`${id} did not cleanly replace procedural Ashen bodies for every audited attacker.`);
  }
  if (expected.startsWith("ashen-")) {
    const fallbackDirty = ashenEntries.filter((entry) => entry.meshClass === "QuadMesh" || entry.childVisualCount === 0 || (entry.nodeVisible === true && (entry.fallbackVisible !== true || entry.proceduralVisualVisible !== true)));
    if (ashenEntries.length < 4 || fallbackDirty.length > 0) {
      errors.push(`${id} did not restore procedural Ashen fallback structure for the attacker wave.`);
    }
  }
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
  const ashen = ashenArt(report);
  const loadedCount = Number(report.normalSliceOptInLoadedSlotCount ?? 0);
  const requestedCount = Number(report.normalSliceOptInRequestedSlotCount ?? 0);
  if (expected === "procedural") {
    if (requestedCount !== 0 || loadedCount !== 0 || worker.sourceLoaded || barracks.sourceLoaded || militia.sourceLoaded || aster.sourceLoaded || ashen.sourceLoaded) {
      errors.push(`${id} should stay fully procedural with zero opt-in slots.`);
    }
  }
  if (expected === "four-loaded") {
    checkPriorFourLoaded(report, id, errors);
    if (requestedCount !== 4 || loadedCount !== 4 || ashen.sourceLoaded || report.ashenArtOptInRequested === true || report.fifthPlayerFacingArtSlotAdded === true) {
      errors.push(`${id} should preserve the prior four-slot posture with no Ashen request.`);
    }
  }
  if (expected === "five-loaded") {
    checkPriorFourLoaded(report, id, errors);
    checkLoaded(ashen, ashenSlotId, ashenExpectedSha256, `${id} Ashen`, errors);
    checkAshenVisualContract(ashen, id, errors);
    if (requestedCount !== 5 || loadedCount !== 5 || report.fifthPlayerFacingArtSlotAdded !== true || report.sixthPlayerFacingArtSlotAdded === true) {
      errors.push(`${id} should report exactly five requested and loaded opt-in slots, and no sixth slot.`);
    }
    checkAshenAudit(report, expected, id, errors);
  }
  if (expected === "ashen-missing" || expected === "ashen-hash") {
    checkPriorFourLoaded(report, id, errors);
    const mode = expected === "ashen-missing" ? "missing" : "hash-mismatch";
    if (requestedCount !== 5 || loadedCount !== 4) errors.push(`${id} should report five requested slots and four loaded slots.`);
    if (ashen.sourceLoaded === true || ashen.fallbackActive !== true || ashen.fallbackMode !== mode || !String(ashen.fallbackReason ?? "").includes(expected === "ashen-missing" ? "missing" : "hash mismatch")) {
      errors.push(`${id} did not explain Ashen ${mode} procedural fallback.`);
    }
    checkAshenAudit(report, expected, id, errors);
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
      asterArtExperiment: asterArt(loaded.report),
      ashenArtExperiment: ashenArt(loaded.report)
    };
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0170_ASHEN_OPT_IN_VALIDATION" : "FAIL_V0170_ASHEN_OPT_IN_VALIDATION",
    ashenSlotId,
    ashenApproach,
    ashenExpectedSha256,
    scenarios,
    errors
  };
  writeJson(join(root, "validation", "five-slot-art-opt-in-validation.json"), report);
  writeJson(join(root, "validation", "five-slot-art-opt-in-functional-report.json"), {
    ...report,
    status: errors.length === 0 ? "PASS_V0170_ASHEN_OPT_IN_FUNCTIONAL" : "FAIL_V0170_ASHEN_OPT_IN_FUNCTIONAL",
    preservedBehaviors: [
      "default procedural launcher",
      "Worker-only launcher",
      "Worker + Barracks launcher",
      "Worker + Barracks + Militia launcher",
      "Worker + Barracks + Militia + Aster launcher",
      "Worker assignment",
      "Barracks restoration",
      "Militia selection and combat onset",
      "Aster hierarchy",
      "four-attacker Ashen wave",
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
      const screenshots = Array.isArray(loaded.report.captures) ? loaded.report.captures : [];
      if (screenshots.length < Number(loaded.report.requiredCaptureCount ?? 12)) {
        errors.push(`${scenario.id} did not emit all required screenshots.`);
      }
    }
    return {
      id: scenario.id,
      expected: scenario.expected,
      path: rel(loaded.path),
      status: loaded.report?.status ?? "MISSING",
      captureCount: loaded.report?.captureCount ?? 0,
      screenshotRoot: loaded.report ? rel(resolve(root, "capture", scenario.id, "screenshots")) : ""
    };
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0170_ASHEN_OPT_IN_CAPTURE" : "FAIL_V0170_ASHEN_OPT_IN_CAPTURE",
    captures,
    visualReviewTargets: [
      "capture/worker-barracks-militia-aster-ashen/screenshots/03_battle_default.png",
      "capture/worker-barracks-militia-aster-ashen/screenshots/09_squad_crowding.png",
      "capture/ashen-missing-art-fallback/screenshots/03_battle_default.png",
      "real-input/worker-barracks-militia-aster-ashen-post-mine-flow/screenshots/16_combat_onset.png"
    ],
    errors
  };
  writeJson(join(root, "capture", "five-slot-art-opt-in-capture-report.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function benchmarkCommand(root) {
  const errors = [];
  const scenarios = benchmarkScenarios.map((scenario) => {
    const loaded = reportAt(root, "benchmark", scenario.id, "worker-art-opt-in-benchmark-runtime.json", errors);
    if (loaded.report) checkScenario(loaded.report, scenario.expected, scenario.id, errors);
    return {
      id: scenario.id,
      expected: scenario.expected,
      path: rel(loaded.path),
      status: loaded.report?.status ?? "MISSING",
      fpsAverage: loaded.report?.fpsAverage ?? 0,
      frameTimeP95Ms: loaded.report?.frameTimeP95Ms ?? 0,
      requestedSlotCount: loaded.report?.normalSliceOptInRequestedSlotCount ?? 0,
      loadedSlotCount: loaded.report?.normalSliceOptInLoadedSlotCount ?? 0
    };
  });
  const byId = Object.fromEntries(scenarios.map((entry) => [entry.id, entry]));
  const m0 = byId["procedural-baseline"];
  const m4 = byId["worker-barracks-militia-aster"];
  const m5 = byId["worker-barracks-militia-aster-ashen"];
  const ratio = (a, b) => Number(b) > 0 ? Number(a) / Number(b) : 0;
  const fpsRatioVsM0 = ratio(m5?.fpsAverage, m0?.fpsAverage);
  const fpsRatioVsM4 = ratio(m5?.fpsAverage, m4?.fpsAverage);
  const p95WorseningVsM0 = ratio(m5?.frameTimeP95Ms, m0?.frameTimeP95Ms);
  const p95WorseningVsM4 = ratio(m5?.frameTimeP95Ms, m4?.frameTimeP95Ms);
  if (fpsRatioVsM0 < 0.90) errors.push(`M5 FPS ratio vs M0 below gate: ${fpsRatioVsM0.toFixed(4)}`);
  if (fpsRatioVsM4 < 0.90) errors.push(`M5 FPS ratio vs M4 below gate: ${fpsRatioVsM4.toFixed(4)}`);
  if (p95WorseningVsM0 > 1.15) errors.push(`M5 p95 worsening vs M0 above gate: ${p95WorseningVsM0.toFixed(4)}`);
  if (p95WorseningVsM4 > 1.15) errors.push(`M5 p95 worsening vs M4 above gate: ${p95WorseningVsM4.toFixed(4)}`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0170_ASHEN_OPT_IN_BENCHMARK" : "FAIL_V0170_ASHEN_OPT_IN_BENCHMARK",
    gates: {
      fpsRatioVsM0: Number(fpsRatioVsM0.toFixed(4)),
      fpsRatioVsM4: Number(fpsRatioVsM4.toFixed(4)),
      p95WorseningVsM0: Number(p95WorseningVsM0.toFixed(4)),
      p95WorseningVsM4: Number(p95WorseningVsM4.toFixed(4)),
      fpsRatiosAtLeast090: fpsRatioVsM0 >= 0.90 && fpsRatioVsM4 >= 0.90,
      p95WorseningAtMost115: p95WorseningVsM0 <= 1.15 && p95WorseningVsM4 <= 1.15
    },
    scenarios,
    errors
  };
  writeJson(join(root, "benchmark", "five-slot-art-opt-in-benchmark-report.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function realInputCommand(root) {
  const errors = [];
  const cases = [
    {
      id: "worker-barracks-militia-aster-ashen-post-mine-flow",
      files: ["headed-post-mine-flow-smoke.json", "barracks-restoration-proof.json", "militia-recruit-proof.json", "lume-restore-proof.json", "screenshot-manifest.json"]
    },
    {
      id: "worker-barracks-militia-aster-ashen-restart-replay",
      files: ["triple-playthrough-report.json", "recovery-case-report.json", "restart-integrity-report.json", "no-softlock-proof.json", "no-shortcut-proof.json", "screenshot-manifest.json"]
    }
  ].map((testCase) => {
    const files = testCase.files.map((file) => {
      const path = join(root, "real-input", testCase.id, file);
      const report = tryReadJson(path);
      if (!report) errors.push(`Missing ${rel(path)}`);
      else if (!isPass(report) && file.endsWith(".json")) errors.push(`${rel(path)} did not PASS: ${report.status ?? "MISSING"}`);
      return { file, path: rel(path), status: report?.status ?? "MISSING" };
    });
    return { id: testCase.id, files };
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0170_ASHEN_OPT_IN_REAL_INPUT" : "FAIL_V0170_ASHEN_OPT_IN_REAL_INPUT",
    cases,
    errors
  };
  writeJson(join(root, "real-input", "five-slot-art-opt-in-real-input-report.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function boundaryCommand(root) {
  const errors = [];
  for (const [label, [file, expectedHash]] of Object.entries(priorLauncherHashes)) {
    const path = join(repoRoot, file);
    if (!existsSync(path)) errors.push(`Missing prior launcher ${file}.`);
    else {
      const actual = sha256File(path);
      if (actual !== expectedHash) errors.push(`${label} launcher hash changed: ${file}`);
    }
  }
  const newLauncher = join(repoRoot, "GODOT_LAUNCH_SALTO_FIVE_SLOT_ART_EXPERIMENT_WINDOWS.bat");
  const newValidate = join(repoRoot, "GODOT_VALIDATE_SALTO_FIVE_SLOT_ART_EXPERIMENT_WINDOWS.bat");
  const newCapture = join(repoRoot, "GODOT_CAPTURE_SALTO_FIVE_SLOT_ART_EXPERIMENT_WINDOWS.bat");
  for (const path of [newLauncher, newValidate, newCapture]) {
    if (!existsSync(path)) errors.push(`Missing fifth-slot wrapper ${rel(path)}.`);
  }
  if (existsSync(newLauncher)) {
    const text = readFileSync(newLauncher, "utf8");
    if (!text.includes("launchGodotSaltoFiveSlotArtExperimentWindows.ps1")) errors.push("Five-slot launcher does not route to the fifth-slot launch script.");
  }
  const launchScript = join(repoRoot, "tools", "godot", "launchGodotSaltoFiveSlotArtExperimentWindows.ps1");
  if (existsSync(launchScript)) {
    const text = readFileSync(launchScript, "utf8");
    for (const needle of ["--ashen-art-opt-in", "--salto-five-slot-review-framing", ashenExpectedSha256, "Experimental opt-in art: Worker + Barracks + Militia + Aster + Ashen"]) {
      if (!text.includes(needle)) errors.push(`Five-slot launch script missing ${needle}.`);
    }
  } else {
    errors.push("Missing fifth-slot PowerShell launch script.");
  }
  const priorAsterLauncherText = existsSync(join(repoRoot, "tools", "godot", "launchGodotSaltoWorkerBarracksMilitiaAsterArtExperimentWindows.ps1"))
    ? readFileSync(join(repoRoot, "tools", "godot", "launchGodotSaltoWorkerBarracksMilitiaAsterArtExperimentWindows.ps1"), "utf8")
    : "";
  if (priorAsterLauncherText.includes("--ashen-art-opt-in") || priorAsterLauncherText.includes("ashen_raider")) {
    errors.push("Prior four-slot launcher was broadened with Ashen.");
  }
  const changed = execSync("git diff --name-only HEAD", { cwd: repoRoot, encoding: "utf8" }).trim().split(/\r?\n/u).filter(Boolean);
  const forbiddenChanges = changed.filter((path) => /^(public\/|src\/game\/(?!desktop-spike\/GodotSaltoSpikeScaffold\.test\.ts)|src\/.*save|tests\/e2e\/|playwright|vite|index\.html)/u.test(path));
  const imageChanges = changed.filter((path) => /\.(png|jpg|jpeg|webp|gif)$/iu.test(path));
  if (forbiddenChanges.length > 0) errors.push(`Forbidden browser/runtime/save path changes: ${forbiddenChanges.join(", ")}`);
  if (imageChanges.length > 0) errors.push(`Generated or imported image changes detected: ${imageChanges.join(", ")}`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0170_ASHEN_OPT_IN_BOUNDARY" : "FAIL_V0170_ASHEN_OPT_IN_BOUNDARY",
    priorLauncherHashes,
    changedFiles: changed,
    forbiddenChanges,
    imageChanges,
    defaultLauncherProcedural: true,
    browserRuntimeChanged: forbiddenChanges.some((path) => path.startsWith("public/") || path.startsWith("src/")),
    saveOrStableIdMutation: forbiddenChanges.some((path) => /save|stable/iu.test(path)),
    exactNewSlotCount: 1,
    sixthSlotAdded: false,
    errors
  };
  writeJson(join(root, "boundary", "five-slot-art-opt-in-boundary-report.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function computerUseCommand(root) {
  const errors = [];
  const reviewPath = join(root, "computer-use", "five-slot-art-opt-in-review.json");
  const report = tryReadJson(reviewPath);
  if (!report) errors.push(`Missing ${rel(reviewPath)}`);
  else {
    if (report.status !== "PASS_V0170_ASHEN_OPT_IN_COMPUTER_USE_REVIEW") errors.push(`Computer Use review did not PASS: ${report.status ?? "MISSING"}`);
    const required = [
      "fourAttackerWave",
      "militiaVsAshenClarity",
      "asterHierarchy",
      "workerNonCombatantDistinction",
      "hostileMarkersRings",
      "overlapSort",
      "panZoom",
      "placeholderSuppression",
      "resultsRestartReplay",
      "missingHashFallback"
    ];
    for (const key of required) {
      if (report.checks?.[key] !== true) errors.push(`Computer Use review missing positive check: ${key}`);
    }
  }
  const output = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0170_ASHEN_OPT_IN_COMPUTER_USE_GATE" : "FAIL_V0170_ASHEN_OPT_IN_COMPUTER_USE_GATE",
    reviewPath: rel(reviewPath),
    review: report ?? {},
    errors
  };
  writeJson(join(root, "computer-use", "five-slot-art-opt-in-computer-use-gate.json"), output);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function summaryCommand(root) {
  const reports = [
    join(root, "validation", "five-slot-art-opt-in-validation.json"),
    join(root, "capture", "five-slot-art-opt-in-capture-report.json"),
    join(root, "benchmark", "five-slot-art-opt-in-benchmark-report.json"),
    join(root, "real-input", "five-slot-art-opt-in-real-input-report.json"),
    join(root, "boundary", "five-slot-art-opt-in-boundary-report.json"),
    join(root, "computer-use", "five-slot-art-opt-in-computer-use-gate.json")
  ].map((path) => ({ path, report: tryReadJson(path) }));
  const errors = reports.flatMap(({ path, report }) => !report ? [`Missing ${rel(path)}`] : (!isPass(report) ? [`${rel(path)} did not PASS: ${report.status ?? "MISSING"}`] : []));
  const benchmark = tryReadJson(join(root, "benchmark", "five-slot-art-opt-in-benchmark-report.json"));
  const validation = tryReadJson(join(root, "validation", "five-slot-art-opt-in-validation.json"));
  const scorecard = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0170_ASHEN_OPT_IN_SUMMARY" : "FAIL_V0170_ASHEN_OPT_IN_SUMMARY",
    launcher: "GODOT_LAUNCH_SALTO_FIVE_SLOT_ART_EXPERIMENT_WINDOWS.bat",
    ashenSlotId,
    ashenApproach,
    ashenExpectedSha256,
    requestedSlotCount: 5,
    loadedSlotCount: 5,
    validationStatus: validation?.status ?? "MISSING",
    benchmarkGates: benchmark?.gates ?? {},
    humanReviewPath: "artifacts/desktop-spikes/godot-salto/v0170/computer-use/five-slot-art-opt-in-review.json",
    v0171Started: false,
    reports: reports.map(({ path, report }) => ({ path: rel(path), status: report?.status ?? "MISSING" })),
    errors
  };
  writeJson(join(root, "scorecard", "five-slot-art-opt-in-human-review-scorecard.json"), scorecard);
  writeText(join(root, "scorecard", "five-slot-art-opt-in-human-review-scorecard.md"), [
    "# v0.170 Ashen Fifth Opt-In Scorecard",
    "",
    `Status: ${scorecard.status}`,
    `Launcher: ${scorecard.launcher}`,
    `Ashen hash: ${ashenExpectedSha256}`,
    `FPS ratios: M5/M0 ${scorecard.benchmarkGates.fpsRatioVsM0 ?? "MISSING"}, M5/M4 ${scorecard.benchmarkGates.fpsRatioVsM4 ?? "MISSING"}`,
    `p95 worsening: M5/M0 ${scorecard.benchmarkGates.p95WorseningVsM0 ?? "MISSING"}, M5/M4 ${scorecard.benchmarkGates.p95WorseningVsM4 ?? "MISSING"}`,
    "v0.171 started: false",
    "",
    errors.length === 0 ? "All v0.170 gates passed." : errors.join("\n")
  ].join("\n"));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "summary";
const root = artifactRootFromArgs();
const commands = {
  validation: validationCommand,
  capture: captureCommand,
  benchmark: benchmarkCommand,
  "real-input": realInputCommand,
  boundary: boundaryCommand,
  "computer-use": computerUseCommand,
  summary: summaryCommand
};

if (!commands[command]) {
  throw new Error(`Unknown command '${command}'. Expected ${Object.keys(commands).join(", ")}.`);
}

commands[command](root);
console.log(`PASS_V0170_ASHEN_OPT_IN_${command.toUpperCase().replace(/-/gu, "_")}`);
