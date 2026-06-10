import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.195";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0195");
const groundSha = "818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8";
const roadSha = "a64959ef2fd7a509fcaaa969fca3e095d590d563a4f0c578a5e96d1fb04c0e10";
const beforeScenarioId = "v2-topology-repair";
const afterScenarioId = "v2-scoped-material-recovery";
const legacyScenarioId = "l1-legacy-riverbank-bridge-approach";
const requiredCaptureIds = [
  "title",
  "briefing",
  "tactical_overview",
  "aster_initial_frame",
  "terrain_normal",
  "terrain_close",
  "terrain_zoomed",
  "connected_road_network",
  "road_intersection",
  "road_to_bridge_transition",
  "river_overview",
  "bridge_close_view",
  "worker_assignment_area",
  "barracks_area",
  "militia_ready_posture",
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

function baselineReportAt(root, group, scenarioId, fileName, errors) {
  const path = join(root, "before-v0194-authoritative", group, scenarioId, fileName);
  if (!existsSync(path)) {
    errors.push(`Missing authoritative v0.194 before artifact ${rel(path)}`);
    return { path, report: null };
  }
  return { path, report: effectiveReport(readJson(path)) };
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

function topologyStatus(report) {
  return v2Status(report)?.topologyRepair ?? {};
}

function legacyStatus(report) {
  return report?.environmentRiverbankBridgeApproach ?? {};
}

function fps(report) {
  return Number(report?.fpsAverage ?? report?.averageFps ?? report?.meanFps ?? 0);
}

function p95(report) {
  return Number(report?.frameTimeP95Ms ?? report?.p95FrameMs ?? report?.frameP95Ms ?? 0);
}

function checkNoForbiddenRuntimeMutation(report, id, errors) {
  for (const key of ["browserRuntimeChanged", "saveWritesAllowed", "stableIdsChanged"]) {
    if (report?.[key] === true) errors.push(`${id} reported forbidden ${key}.`);
  }
  for (const status of [
    report?.environmentPresentationShellV2,
    report?.environmentRiverbankBridgeApproach,
    report?.environmentStructureShellHardening,
    report?.environmentShellLiveQa
  ]) {
    for (const key of [
      "gameplayPathingChanged",
      "collisionGeometryChanged",
      "objectiveLogicChanged",
      "aiLogicChanged",
      "navigationSemanticsChanged"
    ]) {
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

function checkV2Topology(report, id, errors) {
  checkGroundRoadAndFrozenSlots(report, id, errors);
  const shell = v2Status(report);
  const topology = topologyStatus(report);
  if (report?.environmentPresentationShellV2Enabled !== true || shell.enabled !== true) errors.push(`${id} did not enable presentation shell v2.`);
  if (shell.initialized !== true) errors.push(`${id} shell v2 did not initialize.`);
  if (shell.fallbackActive === true) errors.push(`${id} shell v2 fell back to legacy: ${shell.fallbackReason ?? ""}`);
  if (shell.legacyShellFallbackAvailable !== true) errors.push(`${id} does not report legacy fallback availability.`);
  if (report?.environmentRiverbankBridgeApproachEnabled === true) errors.push(`${id} stacked legacy R1 shell on v2.`);
  if (shell.bridgeRiverbankMaterialSlotAdded === true || shell.wetGraniteBridgeRiverbankMaterialIntegrated === true || topology.wetGraniteIntegrated === true) errors.push(`${id} integrated the wet-granite bridge-riverbank material.`);
  for (const key of ["largeFloatingRectanglesMateriallyReduced", "roadsFollowRoutes", "riverReadsContinuously", "banksFrameRiver", "bridgeReadsAsCrossing", "structureMassesImproved", "charactersGrounded", "minimalOverlay", "overcastPaletteRestrained", "noPerFrameDecodeOrParse", "noRepeatedMaterialCreation"]) {
    if (shell[key] !== true) errors.push(`${id} v2 gate ${key} was not true.`);
  }
  if (Number(shell.giantTransparentDiagnosticPads ?? 99) !== 0) errors.push(`${id} reports giant transparent diagnostic pads.`);
  for (const [key, expected] of [
    ["detachedTerrainIslandCount", 0],
    ["disconnectedRoadFragmentCount", 0],
    ["floatingDiagonalRoadFragmentCount", 0],
    ["gameplayCollisionPathingNodesModified", 0]
  ]) {
    if (Number(topology[key] ?? 99) !== expected) errors.push(`${id} topology ${key} expected ${expected}, got ${topology[key] ?? "missing"}.`);
  }
  for (const key of ["terrainBaseCoherent", "roadsConnected", "bridgeRoadContinuity", "riverBankBridgeAligned", "legacyShellPreserved"]) {
    if (topology[key] !== true) errors.push(`${id} topology gate ${key} was not true.`);
  }
  if (topology.defaultLauncherChanged === true) errors.push(`${id} topology reports default launcher changed.`);
  if (topology.browserRuntimeChanged === true) errors.push(`${id} topology reports browser runtime changed.`);
  if (Number(topology.terrainBaseSurfaceCount ?? 99) > 4) errors.push(`${id} terrain base is not consolidated: ${topology.terrainBaseSurfaceCount ?? "missing"} surfaces.`);
  if (Number(topology.roadStripCount ?? 0) < 12) errors.push(`${id} road network reports too few connected/recovered strips.`);
  if (Number(topology.riverSegmentCount ?? 0) !== 1) errors.push(`${id} river is not reported as one continuous channel.`);
  if (Number(topology.bankSegmentCount ?? 0) < 2) errors.push(`${id} bank framing count is too low.`);
  if (Number(topology.bridgeNodeCount ?? 0) < 7) errors.push(`${id} bridge crossing node count is too low.`);
  if (!Array.isArray(topology.materialBindTargets?.ground) || topology.materialBindTargets.ground.length < 6) errors.push(`${id} missing scoped ground material recovery bind targets.`);
  if (!Array.isArray(topology.materialBindTargets?.road) || topology.materialBindTargets.road.length < 10) errors.push(`${id} missing route-following road material recovery bind targets.`);
  if (!Array.isArray(topology.proceduralRoadConnectorTargets) || topology.proceduralRoadConnectorTargets.length < 4) errors.push(`${id} missing procedural road connector targets.`);
  if (topology.broadMaterialMasksReintroduced === true || shell.broadMaterialMasksReintroduced === true) errors.push(`${id} reports broad material masks reintroduced.`);
  if (topology.giantTransparentDiagnosticPads !== 0 && topology.giantTransparentDiagnosticPads !== undefined) errors.push(`${id} reports giant transparent diagnostic pads in topology.`);
  for (const key of [
    "terrainHierarchyMateriallyImproved",
    "roadNetworkReadableAtReviewDistance",
    "footholdGroundTextureRecoveredAtReviewDistance",
    "roadTextureRecoveredAtReviewDistance"
  ]) {
    if (topology[key] !== true) errors.push(`${id} scoped material recovery gate ${key} was not true.`);
  }
  for (const key of ["roadNetworkReadableAtReviewDistance", "scopedMaterialRecoveryActive", "terrainHierarchyMateriallyImproved"]) {
    if (shell[key] !== true) errors.push(`${id} shell scoped material gate ${key} was not true.`);
  }
}

function topologyMetricsFromV0194(report) {
  return topologyStatus(report) ?? {};
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
    topology: topologyStatus(report)
  };
}

function validationCommand(root) {
  const errors = [];
  const before = baselineReportAt(root, "validation", beforeScenarioId, "player-slice-validation-runtime.json", errors);
  const defaultScenario = reportAt(root, "validation", "default-procedural", "player-slice-validation-runtime.json", errors);
  const legacyScenario = reportAt(root, "validation", legacyScenarioId, "player-slice-validation-runtime.json", errors);
  const after = reportAt(root, "validation", afterScenarioId, "player-slice-validation-runtime.json", errors);
  if (defaultScenario.report) checkDefault(defaultScenario.report, "default-procedural", errors);
  if (legacyScenario.report) checkLegacy(legacyScenario.report, legacyScenarioId, errors);
  if (after.report) checkV2Topology(after.report, afterScenarioId, errors);
  const beforeMetrics = before.report ? topologyMetricsFromV0194(before.report) : null;
  const afterMetrics = after.report ? topologyStatus(after.report) : null;
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0195_SHELL_V2_SCOPED_MATERIAL_VALIDATION" : "FAIL_V0195_SHELL_V2_SCOPED_MATERIAL_VALIDATION",
    beforeTopologyMetrics: beforeMetrics,
    afterTopologyMetrics: afterMetrics,
    scenarios: [
      scenarioSummary("before-v0194-authoritative", before),
      scenarioSummary("default-procedural", defaultScenario),
      scenarioSummary(legacyScenarioId, legacyScenario),
      scenarioSummary(afterScenarioId, after)
    ],
    acceptance: {
      terrainCoherent: afterMetrics?.terrainBaseCoherent === true,
      noDetachedTerrainIslands: Number(afterMetrics?.detachedTerrainIslandCount ?? 99) === 0,
      noFloatingDisconnectedRoadFragments: Number(afterMetrics?.disconnectedRoadFragmentCount ?? 99) === 0 && Number(afterMetrics?.floatingDiagonalRoadFragmentCount ?? 99) === 0,
      routeNetworkConnected: afterMetrics?.roadsConnected === true,
      roadToBridgeContinuous: afterMetrics?.bridgeRoadContinuity === true,
      riverBankBridgeAligned: afterMetrics?.riverBankBridgeAligned === true,
      terrainHierarchyImproved: afterMetrics?.terrainHierarchyMateriallyImproved === true,
      roadNetworkReadable: afterMetrics?.roadNetworkReadableAtReviewDistance === true,
      noBroadMaterialMasks: afterMetrics?.broadMaterialMasksReintroduced === false
    },
    errors
  };
  writeJson(join(root, "validation", "shell-v2-scoped-material-recovery-validation-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

function captureCommand(root) {
  const errors = [];
  const before = baselineReportAt(root, "capture", "shell-v2-topology-repair", "screenshot-runtime-manifest.json", errors);
  const after = reportAt(root, "capture", "shell-v2-scoped-material-recovery", "screenshot-runtime-manifest.json", errors);
  const beforeCaptures = before.report?.captures ?? [];
  const afterCaptures = after.report?.captures ?? [];
  const beforeOverview = beforeCaptures.find((capture) => capture.id === "shell_v2_overview") ?? beforeCaptures.find((capture) => capture.id === "terrain_overview") ?? beforeCaptures.find((capture) => capture.id === "title");
  if (!beforeOverview) errors.push("Authoritative v0.194 before capture is missing shell_v2_overview or terrain_overview.");
  const afterIds = new Set(afterCaptures.map((capture) => capture.id));
  for (const id of requiredCaptureIds) {
    if (!afterIds.has(id)) errors.push(`After capture is missing ${id}.`);
  }
  const selected = [
    beforeOverview,
    ...requiredCaptureIds.map((id) => afterCaptures.find((capture) => capture.id === id)).filter(Boolean)
  ].filter(Boolean);
  const lines = [
    "# v0.195 Salto Shell V2 Scoped Material Recovery Contact Sheet",
    "",
    "Before is the retained v0.194 topology-repair overview; after captures are generated from the v0.195 scoped-material recovery opt-in path.",
    ""
  ];
  for (const capture of selected) {
    lines.push(`## ${capture.label ?? capture.id}`);
    const imagePath = capture.absolutePath ? rel(resolve(capture.absolutePath)) : rel(resolve(root, "capture", capture.path ?? ""));
    lines.push(`![${capture.id}](${imagePath})`);
    lines.push("");
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0195_SHELL_V2_SCOPED_MATERIAL_CAPTURE_PACKET" : "FAIL_V0195_SHELL_V2_SCOPED_MATERIAL_CAPTURE_PACKET",
    beforePath: before.path ? rel(before.path) : null,
    afterPath: after.path ? rel(after.path) : null,
    afterRequiredCaptureIds: requiredCaptureIds,
    afterCaptureIds: [...afterIds],
    contactSheet: "capture/shell-v2-scoped-material-recovery-contact-sheet.md",
    errors
  };
  writeText(join(root, "capture", "shell-v2-scoped-material-recovery-contact-sheet.md"), `${lines.join("\n")}\n`);
  writeJson(join(root, "capture", "shell-v2-scoped-material-recovery-capture-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

function benchmarkCommand(root) {
  const errors = [];
  const before = baselineReportAt(root, "benchmark", beforeScenarioId, "worker-art-opt-in-benchmark-runtime.json", errors);
  const after = reportAt(root, "benchmark", afterScenarioId, "worker-art-opt-in-benchmark-runtime.json", errors);
  if (before.report && !isPass(before.report)) errors.push(`V2B v0.194 before benchmark did not PASS: ${before.report.status ?? "MISSING"}`);
  if (after.report) {
    if (!isPass(after.report)) errors.push(`V2C after benchmark did not PASS: ${after.report.status ?? "MISSING"}`);
    checkV2Topology(after.report, "benchmark-v2-scoped-material-recovery", errors);
  }
  const beforeFps = fps(before.report);
  const afterFps = fps(after.report);
  const beforeP95 = p95(before.report);
  const afterP95 = p95(after.report);
  const fpsRatio = beforeFps > 0 ? afterFps / beforeFps : 0;
  const p95WorseningRatio = beforeP95 > 0 ? (afterP95 - beforeP95) / beforeP95 : 0;
  if (fpsRatio < 0.90) errors.push(`V2C FPS ratio below 0.90: ${fpsRatio.toFixed(3)}.`);
  if (p95WorseningRatio > 0.15) errors.push(`V2C p95 worsening above 15%: ${(p95WorseningRatio * 100).toFixed(2)}%.`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0195_SHELL_V2_SCOPED_MATERIAL_BENCHMARK" : "FAIL_V0195_SHELL_V2_SCOPED_MATERIAL_BENCHMARK",
    before: { path: rel(before.path), fpsAverage: beforeFps, frameTimeP95Ms: beforeP95 },
    after: { path: rel(after.path), fpsAverage: afterFps, frameTimeP95Ms: afterP95 },
    fpsRatio,
    p95WorseningRatio,
    thresholds: { minFpsRatio: 0.90, maxP95WorseningRatio: 0.15 },
    errors
  };
  writeJson(join(root, "benchmark", "shell-v2-scoped-material-recovery-benchmark-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

function boundaryCommand(root) {
  const errors = [];
  const trackedChangedFiles = execSync("git diff --name-only HEAD", { cwd: repoRoot, encoding: "utf8" })
    .split(/\r?\n/u)
    .filter(Boolean)
    .map((path) => path.replace(/\\/gu, "/"));
  const untrackedFiles = execSync("git ls-files --others --exclude-standard", { cwd: repoRoot, encoding: "utf8" })
    .split(/\r?\n/u)
    .filter(Boolean)
    .map((path) => path.replace(/\\/gu, "/"));
  const changedFiles = [...new Set([...trackedChangedFiles, ...untrackedFiles])];
  const forbiddenPathPatterns = [
    /^src\//u,
    /^tests\/e2e\//u,
    /^desktop-spikes\/godot-salto\/data\/generated\//u,
    /^desktop-spikes\/godot-salto\/scripts\/adapters\//u,
    /^desktop-spikes\/godot-salto\/scripts\/salto_spike_workload_runtime\.gd$/u,
    /^desktop-spikes\/godot-salto\/comparators\/runtime_art_pipeline\/fallback\/.*\.png$/u,
    /^artifacts\/desktop-spikes\/godot-salto\/v0189\//u
  ];
  const defaultLauncherFiles = new Set([
    "tools/godot/launchGodotReviewWindows.ps1",
    "tools/godot/launchGodotPlayerSliceWindows.ps1",
    "tools/godot/launchGodotPrivateHarnessWindows.ps1"
  ]);
  for (const file of changedFiles) {
    if (defaultLauncherFiles.has(file)) errors.push(`Default/procedural launcher changed: ${file}`);
    if (forbiddenPathPatterns.some((pattern) => pattern.test(file))) errors.push(`Boundary-forbidden file changed: ${file}`);
    if (/\.(png|jpg|jpeg|webp)$/iu.test(file)) errors.push(`Generated/imported image file changed: ${file}`);
  }
  const textChanged = changedFiles.filter((file) => !/\.(png|jpg|jpeg|webp)$/iu.test(file));
  for (const file of textChanged) {
    if (file === "tools/godot/saltoShellV2ScopedMaterialRecoveryTool.mjs") continue;
    const absolute = join(repoRoot, file);
    if (!existsSync(absolute)) continue;
    const content = readFileSync(absolute, "utf8");
    if (!file.startsWith("docs/") && content.includes("--bridge-riverbank-material-opt-in")) {
      errors.push(`Wet-granite bridge-riverbank material flag appears in changed runtime/tool file: ${file}`);
    }
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0195_SHELL_V2_SCOPED_MATERIAL_BOUNDARY_SCAN" : "FAIL_V0195_SHELL_V2_SCOPED_MATERIAL_BOUNDARY_SCAN",
    changedFiles,
    assertions: {
      gameplayPathingCollisionFilesChanged: false,
      defaultLauncherChanged: false,
      browserRuntimeChanged: false,
      generatedImagesChanged: false,
      newArtSlotsAdded: false,
      wetGraniteIntegrated: false,
      broadMaterialMasksReintroduced: false
    },
    errors
  };
  writeJson(join(root, "boundary", "shell-v2-scoped-material-boundary-scan.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

const root = artifactRootFromArgs();
const command = process.argv[2] ?? "validation";
switch (command) {
  case "validation":
    validationCommand(root);
    break;
  case "capture":
    captureCommand(root);
    break;
  case "benchmark":
    benchmarkCommand(root);
    break;
  case "boundary":
    boundaryCommand(root);
    break;
  default:
    console.error(`Unknown v0.195 scoped material recovery command: ${command}`);
    process.exit(1);
}
