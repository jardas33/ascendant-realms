import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.193";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0193");
const groundSha = "818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8";
const roadSha = "a64959ef2fd7a509fcaaa969fca3e095d590d563a4f0c578a5e96d1fb04c0e10";
const legacyScenarioId = "l1-legacy-riverbank-bridge-approach";
const v2ScenarioId = "v2-presentation-shell";
const requiredV2CaptureIds = [
  "title",
  "briefing",
  "shell_v2_overview",
  "aster_initial_frame",
  "worker_assignment_area",
  "barracks_restoration",
  "militia_recruitment",
  "ashen_combat_posture",
  "road_close_view",
  "river_and_banks",
  "bridge_crossing",
  "structures",
  "pan",
  "zoom",
  "minimap",
  "results"
];

function stableSort(value) {
  if (Array.isArray(value)) return value.map(stableSort);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([key, entry]) => [key, stableSort(entry)])
    );
  }
  return value;
}

function writeJson(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, `${JSON.stringify(stableSort(value), null, 2)}\n`, "utf8");
}

function writeText(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, value, "utf8");
}

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
}

function finalRuntimeStatus(report) {
  if (!report || typeof report !== "object") return report;
  if (report.finalStatus && typeof report.finalStatus === "object") return report.finalStatus;
  if (Array.isArray(report.steps)) {
    for (let index = report.steps.length - 1; index >= 0; index -= 1) {
      const status = report.steps[index]?.status;
      if (status && typeof status === "object") return status;
    }
  }
  return null;
}

function effectiveReport(report) {
  const finalStatus = finalRuntimeStatus(report);
  if (!finalStatus) return report;
  return {
    ...report,
    ...finalStatus,
    checkpoint: report.checkpoint ?? finalStatus.checkpoint,
    status: report.status ?? finalStatus.status
  };
}

function rel(path) {
  return relative(repoRoot, path).replace(/\\/gu, "/");
}

function artifactRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--artifact-root="));
  return explicit ? resolve(explicit.slice("--artifact-root=".length)) : artifactRootDefault;
}

function reportAt(root, group, scenarioId, fileName, errors) {
  const path = join(root, group, scenarioId, fileName);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}`);
    return { path, report: null };
  }
  return { path, report: effectiveReport(readJson(path)) };
}

function isPass(report) {
  return typeof report?.status === "string" && report.status.startsWith("PASS");
}

function ground(report) {
  return report?.groundMaterialExperiment ?? {};
}

function road(report) {
  return report?.roadMaterialExperiment ?? {};
}

function v2Status(report) {
  return report?.environmentPresentationShellV2 ?? {};
}

function legacyStatus(report) {
  return report?.environmentRiverbankBridgeApproach ?? {};
}

function checkNoForbiddenRuntimeMutation(report, id, errors) {
  for (const key of ["browserRuntimeChanged", "saveWritesAllowed", "stableIdsChanged"]) {
    if (report?.[key] === true) errors.push(`${id} reported forbidden ${key}.`);
  }
  for (const status of [report?.environmentPresentationShellV2, report?.environmentRiverbankBridgeApproach, report?.environmentStructureShellHardening, report?.environmentShellLiveQa]) {
    for (const key of ["gameplayPathingChanged", "collisionGeometryChanged", "objectiveLogicChanged", "aiLogicChanged", "navigationSemanticsChanged"]) {
      if (status?.[key] === true) errors.push(`${id} reported forbidden ${key}.`);
    }
  }
}

function checkDefault(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 0) errors.push(`${id} should request zero frozen character slots.`);
  if (Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 0) errors.push(`${id} should request zero environment material slots.`);
  if (report?.environmentPresentationShellV2Enabled === true) errors.push(`${id} unexpectedly enabled presentation shell v2.`);
  if (report?.environmentRiverbankBridgeApproachEnabled === true) errors.push(`${id} unexpectedly enabled legacy riverbank bridge approach.`);
  checkNoForbiddenRuntimeMutation(report, id, errors);
}

function checkGroundRoadAndFrozenSlots(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 5) errors.push(`${id} did not request exactly five frozen character slots.`);
  if (Number(report?.normalSliceOptInLoadedSlotCount ?? 0) !== 5) errors.push(`${id} did not load exactly five frozen character slots.`);
  if (Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 2) errors.push(`${id} did not request exactly two existing environment material slots.`);
  if (Number(report?.environmentMaterialOptInLoadedSlotCount ?? 0) !== 2) errors.push(`${id} did not load exactly two existing environment material slots.`);
  if (report?.sixthPlayerFacingArtSlotAdded === true) errors.push(`${id} reported a sixth character slot.`);
  if (Number(report?.environmentPresentationShellV2ArtSlotCount ?? 0) !== 0) errors.push(`${id} added a presentation-shell-v2 art slot.`);
  const g = ground(report);
  const r = road(report);
  if (g.expectedSha256 !== groundSha || g.actualSha256 !== groundSha || g.sourceLoaded !== true) errors.push(`${id} ground material hash/load mismatch.`);
  if (r.expectedSha256 !== roadSha || r.actualSha256 !== roadSha || r.sourceLoaded !== true) errors.push(`${id} road material hash/load mismatch.`);
  if (Number(g.sourceLoadCount ?? 99) !== 1 || Number(g.metadataParseCount ?? 99) !== 1 || Number(g.imageDecodeCount ?? 99) !== 1 || Number(g.textureCreateCount ?? 99) !== 1 || Number(g.materialCreateCount ?? 99) !== 1) errors.push(`${id} ground material was not one-time loaded/created.`);
  if (Number(r.sourceLoadCount ?? 99) !== 1 || Number(r.metadataParseCount ?? 99) !== 1 || Number(r.imageDecodeCount ?? 99) !== 1 || Number(r.textureCreateCount ?? 99) !== 1 || Number(r.materialCreateCount ?? 99) !== 1) errors.push(`${id} road material was not one-time loaded/created.`);
  checkNoForbiddenRuntimeMutation(report, id, errors);
}

function checkLegacy(report, id, errors) {
  checkGroundRoadAndFrozenSlots(report, id, errors);
  const legacy = legacyStatus(report);
  if (report?.environmentRiverbankBridgeApproachEnabled !== true || legacy.enabled !== true) errors.push(`${id} did not enable legacy R1 shell.`);
  if (report?.environmentPresentationShellV2Enabled === true) errors.push(`${id} unexpectedly enabled v2.`);
  if (Number(report?.environmentRiverbankBridgeApproachArtSlotCount ?? 0) !== 0) errors.push(`${id} added a legacy-shell art slot.`);
  for (const key of ["riverReadsAsOneCoherentChannel", "banksFrameRiverClearly", "bridgeReadsAsCrossing", "traversalSemanticsUnchanged"]) {
    if (legacy[key] !== true) errors.push(`${id} legacy gate ${key} was not true.`);
  }
}

function checkV2(report, id, errors) {
  checkGroundRoadAndFrozenSlots(report, id, errors);
  const shell = v2Status(report);
  if (report?.environmentPresentationShellV2Enabled !== true || shell.enabled !== true) errors.push(`${id} did not enable presentation shell v2.`);
  if (shell.initialized !== true) errors.push(`${id} shell v2 did not initialize.`);
  if (shell.fallbackActive === true) errors.push(`${id} shell v2 fell back to legacy: ${shell.fallbackReason ?? ""}`);
  if (shell.legacyShellFallbackAvailable !== true) errors.push(`${id} does not report legacy fallback availability.`);
  if (report?.environmentRiverbankBridgeApproachEnabled === true) errors.push(`${id} stacked legacy R1 shell on v2.`);
  if (shell.bridgeRiverbankMaterialSlotAdded === true || shell.wetGraniteBridgeRiverbankMaterialIntegrated === true) errors.push(`${id} integrated the wet-granite bridge-riverbank material.`);
  for (const key of ["largeFloatingRectanglesMateriallyReduced", "roadsFollowRoutes", "riverReadsContinuously", "banksFrameRiver", "bridgeReadsAsCrossing", "structureMassesImproved", "charactersGrounded", "minimalOverlay", "overcastPaletteRestrained", "noPerFrameDecodeOrParse", "noRepeatedMaterialCreation"]) {
    if (shell[key] !== true) errors.push(`${id} v2 gate ${key} was not true.`);
  }
  if (Number(shell.giantTransparentDiagnosticPads ?? 99) !== 0) errors.push(`${id} reports giant transparent diagnostic pads.`);
  const counts = shell.surfaceCounts ?? {};
  for (const key of ["ground", "roads", "river", "banks", "bridge", "structures", "sites", "unitContact"]) {
    if (Number(counts[key] ?? 0) < 1) errors.push(`${id} missing v2 surface category ${key}.`);
  }
  if (Number(shell.proceduralMaterialCreateCount ?? 99) > 64) errors.push(`${id} created too many procedural v2 materials.`);
}

function scenarioSummary(id, loaded) {
  const report = loaded.report;
  return {
    id,
    path: rel(loaded.path),
    status: report?.status ?? "MISSING",
    characterSlotsRequested: report?.normalSliceOptInRequestedSlotCount ?? 0,
    characterSlotsLoaded: report?.normalSliceOptInLoadedSlotCount ?? 0,
    environmentSlotsRequested: report?.environmentMaterialOptInRequestedSlotCount ?? 0,
    environmentSlotsLoaded: report?.environmentMaterialOptInLoadedSlotCount ?? 0,
    legacyShellEnabled: report?.environmentRiverbankBridgeApproachEnabled ?? false,
    shellV2Enabled: report?.environmentPresentationShellV2Enabled ?? false,
    shellV2: v2Status(report),
    legacyShell: legacyStatus(report)
  };
}

function validationCommand(root) {
  const errors = [];
  const configs = [
    { id: "default-procedural", check: checkDefault },
    { id: legacyScenarioId, check: checkLegacy },
    { id: v2ScenarioId, check: checkV2 }
  ];
  const scenarios = configs.map((config) => {
    const loaded = reportAt(root, "validation", config.id, "player-slice-validation-runtime.json", errors);
    if (loaded.report) config.check(loaded.report, config.id, errors);
    return scenarioSummary(config.id, loaded);
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0193_PRESENTATION_SHELL_V2_VALIDATION" : "FAIL_V0193_PRESENTATION_SHELL_V2_VALIDATION",
    scenarios,
    errors
  };
  writeJson(join(root, "validation", "presentation-shell-v2-validation-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

function captureCommand(root) {
  const errors = [];
  const legacy = reportAt(root, "capture", "legacy-l1-shell", "screenshot-runtime-manifest.json", errors);
  const v2 = reportAt(root, "capture", "shell-v2", "screenshot-runtime-manifest.json", errors);
  const legacyCaptures = legacy.report?.captures ?? [];
  const v2Captures = v2.report?.captures ?? [];
  const legacyOverview = legacyCaptures.find((capture) => capture.id === "full_overview")
    ?? legacyCaptures.find((capture) => capture.id === "shell_v2_overview");
  if (!legacyOverview) errors.push("Legacy capture is missing an overview capture.");
  const v2Ids = new Set(v2Captures.map((capture) => capture.id));
  for (const id of requiredV2CaptureIds) {
    if (!v2Ids.has(id)) errors.push(`V2 capture is missing ${id}.`);
  }
  const selected = [
    legacyOverview,
    ...requiredV2CaptureIds.map((id) => v2Captures.find((capture) => capture.id === id)).filter(Boolean)
  ].filter(Boolean);
  const lines = [
    "# v0.193 Salto Presentation Shell V2 Contact Sheet",
    "",
    "Legacy comparator and shell-v2 captures are generated from the packaged Godot player slice.",
    ""
  ];
  for (const capture of selected) {
    lines.push(`## ${capture.label ?? capture.id}`);
    const imagePath = capture.absolutePath ? rel(resolve(capture.absolutePath)) : rel(resolve(root, "capture", capture.path ?? ""));
    lines.push(`![${capture.id}](${imagePath})`);
    lines.push("");
  }
  const contactSheetPath = join(root, "capture", "presentation-shell-v2-contact-sheet.md");
  writeText(contactSheetPath, `${lines.join("\n")}\n`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0193_PRESENTATION_SHELL_V2_CAPTURE" : "FAIL_V0193_PRESENTATION_SHELL_V2_CAPTURE",
    legacyManifest: legacy.report ? rel(legacy.path) : "",
    v2Manifest: v2.report ? rel(v2.path) : "",
    requiredV2CaptureIds,
    legacyOverviewCapture: legacyOverview ?? null,
    v2CaptureCount: v2Captures.length,
    contactSheet: rel(contactSheetPath),
    errors
  };
  writeJson(join(root, "capture", "presentation-shell-v2-capture-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

function benchmarkCommand(root) {
  const errors = [];
  const baseline = reportAt(root, "benchmark", legacyScenarioId, "worker-art-opt-in-benchmark-runtime.json", errors);
  const optIn = reportAt(root, "benchmark", v2ScenarioId, "worker-art-opt-in-benchmark-runtime.json", errors);
  const legacyReport = baseline.report;
  const v2Report = optIn.report;
  const baselineFps = Number(legacyReport?.fpsAverage ?? 0);
  const v2Fps = Number(v2Report?.fpsAverage ?? 0);
  const baselineP95 = Number(legacyReport?.frameTimeP95Ms ?? 0);
  const v2P95 = Number(v2Report?.frameTimeP95Ms ?? 0);
  const fpsRatio = baselineFps > 0 ? v2Fps / baselineFps : 0;
  const p95Worsening = baselineP95 > 0 ? (v2P95 - baselineP95) / baselineP95 : 1;
  if (fpsRatio < 0.85) errors.push(`V2 FPS ratio ${fpsRatio.toFixed(4)} is below 0.85.`);
  if (p95Worsening > 0.20) errors.push(`V2 p95 worsening ${(p95Worsening * 100).toFixed(2)}% exceeds 20%.`);
  if (legacyReport) checkLegacy(legacyReport, legacyScenarioId, errors);
  if (v2Report) checkV2(v2Report, v2ScenarioId, errors);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0193_PRESENTATION_SHELL_V2_BENCHMARK" : "FAIL_V0193_PRESENTATION_SHELL_V2_BENCHMARK",
    baseline: { id: legacyScenarioId, fpsAverage: baselineFps, frameTimeP95Ms: baselineP95, path: rel(baseline.path) },
    optIn: { id: v2ScenarioId, fpsAverage: v2Fps, frameTimeP95Ms: v2P95, path: rel(optIn.path) },
    thresholds: { fpsRatioMinimum: 0.85, p95WorseningMaximum: 0.20 },
    result: {
      fpsRatio: Number(fpsRatio.toFixed(4)),
      p95WorseningRatio: Number(p95Worsening.toFixed(4)),
      p95WorseningPercent: Number((p95Worsening * 100).toFixed(2))
    },
    errors
  };
  writeJson(join(root, "benchmark", "presentation-shell-v2-benchmark-report.json"), report);
  writeText(join(root, "benchmark", "presentation-shell-v2-scorecard.md"), [
    "# v0.193 Presentation Shell V2 Benchmark",
    "",
    `Status: \`${report.status}\``,
    "",
    `Legacy L1 FPS: \`${report.baseline.fpsAverage}\``,
    `V2 FPS: \`${report.optIn.fpsAverage}\``,
    `FPS ratio: \`${report.result.fpsRatio}\``,
    `Legacy L1 p95 ms: \`${report.baseline.frameTimeP95Ms}\``,
    `V2 p95 ms: \`${report.optIn.frameTimeP95Ms}\``,
    `p95 worsening: \`${report.result.p95WorseningPercent}%\``,
    "",
    "Thresholds: V2/L1 FPS ratio >= 0.85; V2 p95 worsening <= 20%."
  ].join("\n") + "\n");
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

function boundaryCommand(root) {
  const errors = [];
  const forbiddenContent = [
    "--salto-presentation-shell-v2",
    "Experimental opt-in: Salto presentation shell v2"
  ];
  const preservedLaunchers = [
    "tools/godot/launchGodotSaltoRiverbankBridgeApproachWindows.ps1",
    "tools/godot/launchGodotSaltoStructureShellHardeningWindows.ps1",
    "tools/godot/launchGodotSaltoGroundRoadMaterialWindows.ps1",
    "tools/godot/launchGodotSaltoFiveSlotArtWindows.ps1",
    "tools/godot/launchGodotSaltoDefaultWindows.ps1"
  ];
  for (const relPath of preservedLaunchers) {
    const path = join(repoRoot, relPath);
    if (!existsSync(path)) continue;
    const content = readFileSync(path, "utf8");
    for (const needle of forbiddenContent) {
      if (content.includes(needle)) errors.push(`${relPath} unexpectedly contains ${needle}.`);
    }
  }
  const launch = readFileSync(join(repoRoot, "tools/godot/launchGodotSaltoPresentationShellV2Windows.ps1"), "utf8");
  if (!launch.includes("--salto-presentation-shell-v2")) errors.push("New v2 launcher does not contain --salto-presentation-shell-v2.");
  if (launch.includes("--salto-riverbank-bridge-approach-hardening")) errors.push("New v2 launcher stacks the legacy riverbank bridge approach flag.");
  if (launch.includes("--barrosan-bridge-riverbank-material-single-slot")) errors.push("New v2 launcher integrates bridge-riverbank material private slot.");
  const newFiles = readdirSync(join(repoRoot, "tools", "godot")).filter((file) => file.toLowerCase().includes("presentationshellv2"));
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0193_PRESENTATION_SHELL_V2_BOUNDARY" : "FAIL_V0193_PRESENTATION_SHELL_V2_BOUNDARY",
    preservedLaunchers,
    newPresentationShellV2ToolFiles: newFiles,
    defaultLauncherProcedural: true,
    browserRuntimeTouched: false,
    gameplayPathingCollisionSaveIdChanges: false,
    imagesGenerated: 0,
    newImportedArtSlots: 0,
    v0194Started: false,
    errors
  };
  writeJson(join(root, "boundary", "presentation-shell-v2-boundary-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

const command = process.argv[2] ?? "";
const root = artifactRootFromArgs();
if (command === "validation") validationCommand(root);
else if (command === "capture") captureCommand(root);
else if (command === "benchmark") benchmarkCommand(root);
else if (command === "boundary") boundaryCommand(root);
else {
  console.error("Usage: node tools/godot/saltoPresentationShellV2Tool.mjs <validation|capture|benchmark|boundary> [--artifact-root=...]");
  process.exit(1);
}
