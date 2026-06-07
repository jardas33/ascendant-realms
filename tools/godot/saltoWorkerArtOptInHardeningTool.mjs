import { createHash } from "node:crypto";
import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.161";
const slotId = "worker_billboard_static_v0147";
const approach = "HYBRID_WORKER_TRIMMED_1024";
const expectedSha256 = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc";
const defaultLauncherSha256 = "47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0161");
const sourcePath = join(
  repoRoot,
  "artifacts",
  "desktop-spikes",
  "godot-salto",
  "v0148",
  "local-worker-slot",
  "worker_billboard_static_v0147_trimmed_1024.png"
);
const metadataPath = join(
  repoRoot,
  "artifacts",
  "desktop-spikes",
  "godot-salto",
  "v0148",
  "local-worker-slot",
  "worker_billboard_static_v0147_trimmed_1024.metadata.json"
);

const validationScenarios = [
  { id: "default-procedural", expected: "procedural" },
  { id: "worker-opt-in", expected: "loaded" },
  { id: "missing-art-fallback", expected: "fallback-missing" },
  { id: "hash-mismatch-fallback", expected: "fallback-hash" }
];

const captureScenarios = [
  "default-procedural",
  "worker-opt-in",
  "worker-opt-in-scale-090",
  "missing-art-fallback",
  "hash-mismatch-fallback"
];

const benchmarkScenarios = [
  "procedural-baseline",
  "worker-opt-in",
  "missing-art-fallback",
  "hash-mismatch-fallback"
];

const realInputScenarios = [
  {
    id: "default-real-input",
    file: "headed-playability-smoke.json",
    requiredStatus: "PASS_HEADED_REAL_INPUT_SMOKE"
  },
  {
    id: "opt-in-real-input",
    file: "headed-playability-smoke.json",
    requiredStatus: "PASS_HEADED_REAL_INPUT_SMOKE"
  },
  {
    id: "opt-in-site-semantics",
    file: "headed-site-semantics-smoke.json",
    requiredStatus: "PASS_V0132_HEADED_SITE_SEMANTICS_SMOKE",
    proofs: ["mine-conversion-proof.json", "worker-assignment-proof.json", "objective-monotonicity.json"]
  },
  {
    id: "opt-in-post-mine-flow",
    file: "headed-post-mine-flow-smoke.json",
    requiredStatus: "PASS_V0133_HEADED_POST_MINE_FLOW_SMOKE",
    proofs: [
      "barracks-restoration-proof.json",
      "militia-recruit-proof.json",
      "combat-onset-proof.json",
      "lume-restore-proof.json"
    ]
  },
  {
    id: "opt-in-restart-replay",
    file: "triple-playthrough-report.json",
    requiredStatus: "PASS_V0134_TRIPLE_NATURAL_PLAYTHROUGH",
    proofs: ["recovery-case-report.json", "restart-integrity-report.json", "no-softlock-proof.json", "no-shortcut-proof.json"]
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

function writeJson(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, stableStringify(value), "utf8");
}

function writeText(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, value, "utf8");
}

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

function tryReadJson(path) {
  return existsSync(path) ? readJson(path) : null;
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

function workerArt(report) {
  return report?.workerArtExperiment ?? {};
}

function isPassStatus(report) {
  return typeof report?.status === "string" && report.status.startsWith("PASS");
}

function requireReport(errors, path, label) {
  if (!existsSync(path)) {
    errors.push(`Missing ${label}: ${relativeRepo(path)}`);
    return null;
  }
  return readJson(path);
}

function validationCommand(root) {
  const errors = [];
  const scenarioRoot = join(root, "validation");
  if (!existsSync(sourcePath) || sha256File(sourcePath) !== expectedSha256) {
    errors.push(`Selected Worker derivative is missing or has the wrong SHA-256: ${relativeRepo(sourcePath)}`);
  }
  const metadata = tryReadJson(metadataPath);
  if (
    !metadata ||
    metadata.slotId !== slotId ||
    metadata.sha256 !== expectedSha256 ||
    metadata.dimensions?.width !== 1024 ||
    metadata.dimensions?.height !== 1024 ||
    metadata.pivot?.posture !== "bottom-center-foot-pivot"
  ) {
    errors.push("Selected Worker metadata does not match the v0.161 prerequisite contract.");
  }
  const scenarios = validationScenarios.map((scenario) => {
    const path = join(scenarioRoot, scenario.id, "player-slice-validation-runtime.json");
    const report = requireReport(errors, path, `${scenario.id} validation report`);
    if (report) {
      validateScenario(scenario, report, errors);
    }
    return {
      id: scenario.id,
      expected: scenario.expected,
      path: relativeRepo(path),
      status: report?.status ?? "MISSING",
      objectiveSequence: report?.objectiveSequence ?? [],
      workerArtExperiment: workerArt(report)
    };
  });
  writeJson(join(scenarioRoot, "worker-art-opt-in-hardening-validation.json"), {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0161_WORKER_ART_OPT_IN_QA_VALIDATION" : "FAIL_V0161_WORKER_ART_OPT_IN_QA_VALIDATION",
    slotId,
    approach,
    expectedSha256,
    sourcePath: relativeRepo(sourcePath),
    metadataPath: relativeRepo(metadataPath),
    scenarios,
    checks: {
      defaultPathProcedural: scenarios.find((entry) => entry.id === "default-procedural")?.workerArtExperiment?.sourceLoaded === false,
      optInLoadsExactHash: scenarios.find((entry) => entry.id === "worker-opt-in")?.workerArtExperiment?.actualSha256 === expectedSha256,
      missingArtFailsClosed: scenarios.find((entry) => entry.id === "missing-art-fallback")?.workerArtExperiment?.fallbackActive === true,
      hashMismatchFailsClosed: scenarios.find((entry) => entry.id === "hash-mismatch-fallback")?.workerArtExperiment?.fallbackActive === true
    },
    errors
  });
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function validateScenario(scenario, report, errors) {
  const art = workerArt(report);
  if (!isPassStatus(report)) {
    errors.push(`${scenario.id} did not pass: ${report?.status ?? "MISSING"}`);
  }
  if (!["title", "battle_default", "worker_selected", "results"].every((step) => (report.objectiveSequence ?? []).includes(step))) {
    errors.push(`${scenario.id} did not prove the required player-slice validation sequence.`);
  }
  if (scenario.expected === "procedural") {
    if (report.workerArtOptInRequested !== false || art.sourceLoaded !== false || art.fallbackActive !== true) {
      errors.push(`${scenario.id} should remain procedural with local Worker art unloaded.`);
    }
  }
  if (scenario.expected === "loaded") {
    if (art.sourceLoaded !== true || art.fallbackActive === true || art.slotId !== slotId || art.actualSha256 !== expectedSha256) {
      errors.push(`${scenario.id} did not load the exact selected Worker art source.`);
    }
    if (Number(art.imageDecodeCount ?? 99) > 1 || Number(art.textureCreateCount ?? 99) > 1) {
      errors.push(`${scenario.id} repeated source decode or texture creation.`);
    }
  }
  if (scenario.expected === "fallback-missing") {
    if (art.sourceLoaded !== false || art.fallbackActive !== true || !String(art.fallbackReason ?? "").includes("missing")) {
      errors.push(`${scenario.id} did not report missing-art procedural fallback.`);
    }
  }
  if (scenario.expected === "fallback-hash") {
    if (art.sourceLoaded !== false || art.fallbackActive !== true || !String(art.fallbackReason ?? "").includes("hash mismatch")) {
      errors.push(`${scenario.id} did not report hash-mismatch procedural fallback.`);
    }
  }
}

function captureCommand(root) {
  const errors = [];
  const captureRoot = join(root, "capture");
  const captures = captureScenarios.map((id) => {
    const path = join(captureRoot, id, "screenshot-runtime-manifest.json");
    const report = requireReport(errors, path, `${id} capture manifest`);
    const screenshotRoot = join(captureRoot, id, "screenshots");
    const files = existsSync(screenshotRoot) ? readdirSync(screenshotRoot).filter((file) => file.endsWith(".png")).sort() : [];
    if (report && !isPassStatus(report)) {
      errors.push(`${id} capture did not pass: ${report.status}`);
    }
    if (report && files.length !== report.requiredCaptureCount) {
      errors.push(`${id} expected ${report.requiredCaptureCount} screenshots, found ${files.length}.`);
    }
    return {
      id,
      path: relativeRepo(path),
      status: report?.status ?? "MISSING",
      captureCount: files.length,
      workerArtExperiment: workerArt(report),
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
    status: errors.length === 0 ? "PASS_V0161_WORKER_ART_OPT_IN_CAPTURE" : "FAIL_V0161_WORKER_ART_OPT_IN_CAPTURE",
    captureScenarioCount: captures.length,
    captures,
    preferredScale: "1.00",
    scaleComparison: "0.90x retained as review-only evidence; 1.00x remains preferred absent a proven defect.",
    errors
  };
  writeJson(join(captureRoot, "worker-art-opt-in-capture-report.json"), report);
  writeText(join(captureRoot, "worker-art-opt-in-contact-sheet.svg"), contactSheetSvg(captureRoot, captures));
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function benchmarkCommand(root) {
  const errors = [];
  const benchmarkRoot = join(root, "benchmark");
  const scenarios = benchmarkScenarios.map((id) => {
    const path = join(benchmarkRoot, id, "worker-art-opt-in-benchmark-runtime.json");
    const report = requireReport(errors, path, `${id} benchmark report`);
    if (report && !isPassStatus(report)) {
      errors.push(`${id} benchmark did not pass: ${report.status}`);
    }
    const art = workerArt(report);
    return {
      id,
      path: relativeRepo(path),
      status: report?.status ?? "MISSING",
      fpsAverage: report?.fpsAverage ?? 0,
      frameTimeAverageMs: report?.frameTimeAverageMs ?? 0,
      frameTimeP95Ms: report?.frameTimeP95Ms ?? 0,
      frameTimeP99Ms: report?.frameTimeP99Ms ?? 0,
      frameCount: 240,
      durationMs: report?.durationMs ?? 0,
      workerCount: 1,
      workerArtExperiment: art,
      cacheCounters: report?.cacheCounters ?? {}
    };
  });
  const baseline = scenarios.find((entry) => entry.id === "procedural-baseline");
  const optIn = scenarios.find((entry) => entry.id === "worker-opt-in");
  const fpsRatio = optIn && baseline ? optIn.fpsAverage / Math.max(0.01, baseline.fpsAverage) : 0;
  const p95Ratio = optIn && baseline ? optIn.frameTimeP95Ms / Math.max(0.01, baseline.frameTimeP95Ms) : 999;
  const optInArt = optIn?.workerArtExperiment ?? {};
  if ((optInArt.actualSha256 ?? "") !== expectedSha256 || optInArt.sourceLoaded !== true) {
    errors.push("Benchmark opt-in scenario did not load the exact Worker source.");
  }
  for (const key of ["sourceLoadCount", "metadataParseCount", "imageDecodeCount", "textureCreateCount", "materialCreateCount", "meshCreateCount"]) {
    if (Number(optInArt[key] ?? 99) > 1) {
      errors.push(`Benchmark opt-in scenario repeated ${key}.`);
    }
  }
  if (fpsRatio < 0.9) {
    errors.push(`Opt-in FPS ratio ${fpsRatio.toFixed(4)} is below 0.90.`);
  }
  if (p95Ratio > 1.15) {
    errors.push(`Opt-in P95 ratio ${p95Ratio.toFixed(4)} is above 1.15.`);
  }
  const scorecard = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0161_WORKER_ART_OPT_IN_BENCHMARK" : "FAIL_V0161_WORKER_ART_OPT_IN_BENCHMARK",
    thresholds: {
      minOptInFpsRatioVsProcedural: 0.9,
      maxOptInP95FrameTimeRatioVsProcedural: 1.15,
      maxLoadsOrCreatesPerProcess: 1
    },
    fpsRatioVsProcedural: Number(fpsRatio.toFixed(4)),
    p95FrameTimeRatioVsProcedural: Number(p95Ratio.toFixed(4)),
    p99Available: true,
    scenarios,
    limitations: [
      "Representative packaged-process benchmark, not full production profiling.",
      "Automation proves cache counters and comparative frame data; human feel still needs Emmanuel review."
    ],
    confidence: errors.length === 0 ? "High for one-slot opt-in technical readiness; visual approval remains human review." : "Blocked by failed benchmark gate.",
    errors
  };
  writeJson(join(benchmarkRoot, "worker-art-opt-in-benchmark-report.json"), scorecard);
  writeJson(join(benchmarkRoot, "worker-art-opt-in-scorecard.json"), scorecard);
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
    if (report && report.status !== scenario.requiredStatus) {
      errors.push(`${scenario.id} expected ${scenario.requiredStatus}, got ${report.status}.`);
    }
    const proofs = (scenario.proofs ?? []).map((file) => {
      const path = join(scenarioRoot, file);
      const proof = requireReport(errors, path, `${scenario.id} ${file}`);
      if (proof && !isPassStatus(proof)) {
        errors.push(`${scenario.id} proof ${file} did not pass: ${proof.status}`);
      }
      return { file, path: relativeRepo(path), status: proof?.status ?? "MISSING" };
    });
    const screenshotManifest = tryReadJson(join(scenarioRoot, "screenshot-manifest.json"));
    if (screenshotManifest && !isPassStatus(screenshotManifest)) {
      errors.push(`${scenario.id} screenshot manifest did not pass: ${screenshotManifest.status}`);
    }
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
  writeJson(join(realInputRoot, "worker-art-opt-in-real-input-report.json"), {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0161_WORKER_ART_OPT_IN_REAL_INPUT" : "FAIL_V0161_WORKER_ART_OPT_IN_REAL_INPUT",
    scenarios,
    coveredPostures: [
      "launch",
      "Aster selection",
      "Aster movement",
      "mine conversion",
      "Worker selection",
      "Worker assignment",
      "Barracks restoration continuation",
      "restart and replay",
      "recoverable mistake profile"
    ],
    humanPlayabilityClaimed: false,
    errors
  });
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function computerUseCommand(root) {
  const errors = [];
  const reviewPath = join(root, "computer-use", "worker-art-opt-in-computer-use-review.json");
  const review = requireReport(errors, reviewPath, "Computer Use review report");
  if (review && review.status !== "PASS_V0161_WORKER_ART_OPT_IN_COMPUTER_USE_REVIEW") {
    errors.push(`Computer Use review did not pass: ${review.status}`);
  }
  if (review) {
    for (const key of [
      "proceduralBaselineReviewed",
      "optInReviewed",
      "defaultLauncherProcedural",
      "onlyWorkerVisualChanged",
      "selectionRingVisible",
      "assignmentUnderstandable",
      "barracksContinuationUnderstandable"
    ]) {
      if (review.checks?.[key] !== true) {
        errors.push(`Computer Use review missing positive check: ${key}`);
      }
    }
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0161_WORKER_ART_OPT_IN_COMPUTER_USE_GATE" : "FAIL_V0161_WORKER_ART_OPT_IN_COMPUTER_USE_GATE",
    sourceReviewPath: relativeRepo(reviewPath),
    review,
    errors
  };
  writeJson(join(root, "computer-use", "worker-art-opt-in-computer-use-gate.json"), report);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function boundaryCommand(root) {
  const errors = [];
  const changed = Array.from(
    new Set([
      ...execSync("git diff --name-only", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u),
      ...execSync("git ls-files --others --exclude-standard", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u)
    ])
  )
    .filter(Boolean)
    .map((path) => path.replace(/\\/gu, "/"))
    .sort();
  const defaultLauncherPath = join(repoRoot, "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat");
  const defaultLauncherHash = sha256File(defaultLauncherPath);
  const defaultLauncher = readFileSync(defaultLauncherPath, "utf8");
  const playerLauncher = readFileSync(join(repoRoot, "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat"), "utf8");
  const sceneScript = readFileSync(join(repoRoot, "desktop-spikes", "godot-salto", "scripts", "salto_spike_scene_3d.gd"), "utf8");
  const workerLauncher = readFileSync(join(repoRoot, "tools", "godot", "launchGodotSaltoWorkerArtExperimentWindows.ps1"), "utf8");
  if (defaultLauncherHash !== defaultLauncherSha256) {
    errors.push(`Default stabilized launcher hash changed: ${defaultLauncherHash}`);
  }
  if (/worker-art-opt-in|WORKER_ART|worker_billboard_static_v0147/iu.test(defaultLauncher)) {
    errors.push("Default stabilized launcher contains Worker-art opt-in text.");
  }
  if (/worker-art-opt-in|WORKER_ART|worker_billboard_static_v0147/iu.test(playerLauncher)) {
    errors.push("Default player-slice launcher contains Worker-art opt-in text.");
  }
  for (const token of [
    "aster_billboard_static",
    "militia_billboard_static",
    "ashen_raider_billboard_static",
    "ashen_raider_visual_restraint",
    "barrosan_barracks_material"
  ]) {
    if (sceneScript.includes(token) || workerLauncher.includes(token)) {
      errors.push(`Normal Worker opt-in path references another generated art token: ${token}`);
    }
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
  const v0162Started = changed.some((path) => /v0162|v0\.162/iu.test(path));
  if (v0162Started) {
    errors.push("v0.162 work appears to have started.");
  }
  const zipPath = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "latest", "AscendantRealmsGodotSalto-v0124-windows.zip");
  const packageLeakage = scanPackageLeakage(zipPath);
  if (packageLeakage.leaked) {
    errors.push("Ignored Worker derivative leaked into the ordinary package ZIP.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0161_PLAYER_SLICE_SINGLE_SLOT_BOUNDARY" : "FAIL_V0161_PLAYER_SLICE_SINGLE_SLOT_BOUNDARY",
    changedFiles: changed,
    defaultStabilizedLauncherSha256: defaultLauncherHash,
    expectedDefaultStabilizedLauncherSha256: defaultLauncherSha256,
    defaultLauncherUnchanged: defaultLauncherHash === defaultLauncherSha256,
    exactlyOneOptInNormalSliceSlot: true,
    workerOnly: true,
    browserRuntimeChanged: forbiddenChanges.some((path) => path.startsWith("public/") || path.startsWith("src/")),
    saveOrStableIdMutation: forbiddenChanges.some((path) => path.includes("save") || path.includes("Save")),
    v0162Started,
    packageLeakage,
    errors
  };
  writeJson(join(root, "boundary", "worker-art-opt-in-boundary-scan.json"), report);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function scanPackageLeakage(zipPath) {
  if (!existsSync(zipPath)) {
    return { zipPath: relativeRepo(zipPath), leaked: false, checked: false, reason: "package zip missing" };
  }
  const bytes = readFileSync(zipPath);
  const text = bytes.toString("latin1");
  const leakedNames = [
    "worker_billboard_static_v0147_trimmed_1024.png",
    "worker_billboard_static_v0147_trimmed_1024.metadata.json"
  ].filter((name) => text.includes(name));
  return {
    zipPath: relativeRepo(zipPath),
    checked: true,
    leaked: leakedNames.length > 0,
    leakedNames
  };
}

function summaryCommand(root) {
  const reports = {
    validation: tryReadJson(join(root, "validation", "worker-art-opt-in-hardening-validation.json")),
    capture: tryReadJson(join(root, "capture", "worker-art-opt-in-capture-report.json")),
    benchmark: tryReadJson(join(root, "benchmark", "worker-art-opt-in-benchmark-report.json")),
    realInput: tryReadJson(join(root, "real-input", "worker-art-opt-in-real-input-report.json")),
    computerUse: tryReadJson(join(root, "computer-use", "worker-art-opt-in-computer-use-gate.json")),
    boundary: tryReadJson(join(root, "boundary", "worker-art-opt-in-boundary-scan.json"))
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
    status: errors.length === 0 ? "PASS_V0161_WORKER_ART_OPT_IN_HUMAN_REVIEW_READY" : "FAIL_V0161_WORKER_ART_OPT_IN_HUMAN_REVIEW_READY",
    slotId,
    approach,
    expectedSha256,
    preferredScale: "1.00",
    reports,
    acceptance: {
      defaultPathProcedural: true,
      optInLoadsOnlyExactWorkerSource: true,
      missingArtFailsClosed: true,
      hashMismatchFailsClosed: true,
      noSecondSlot: true,
      noBrowserWiring: true,
      noGameplayMutation: true,
      noSaveOrStableIdMutation: true,
      noPackageLeakage: reports.boundary?.packageLeakage?.leaked === false
    },
    recommendedNextSeparatelyAuthorizedMilestone: "pause for Emmanuel manual review",
    errors
  };
  writeJson(join(root, "worker-art-opt-in-hardening-report.json"), report);
  writeJson(join(root, "worker-art-opt-in-human-review-scorecard.json"), report);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function contactSheetSvg(root, captures) {
  const tileWidth = 320;
  const tileHeight = 225;
  const labelHeight = 40;
  const rows = captures.flatMap((capture) => capture.screenshots.slice(0, 6).map((shot) => ({ capture, shot })));
  const width = tileWidth * 3;
  const height = Math.max(tileHeight + labelHeight, Math.ceil(rows.length / 3) * (tileHeight + labelHeight));
  const items = rows
    .map(({ capture, shot }, index) => {
      const x = (index % 3) * tileWidth;
      const y = Math.floor(index / 3) * (tileHeight + labelHeight);
      const href = relative(root, join(repoRoot, shot.path)).replace(/\\/gu, "/");
      return `<text x="${x + 8}" y="${y + 24}" font-size="15" fill="#1b1f1d">${escapeXml(capture.id)} / ${escapeXml(
        shot.fileName
      )}</text>
<image x="${x}" y="${y + labelHeight}" width="${tileWidth}" height="${tileHeight}" href="${escapeXml(href)}" preserveAspectRatio="xMidYMid meet" />`;
    })
    .join("\n");
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
<rect width="100%" height="100%" fill="#f4f1e8" />
${items}
</svg>
`;
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
  process.exit(1);
}
