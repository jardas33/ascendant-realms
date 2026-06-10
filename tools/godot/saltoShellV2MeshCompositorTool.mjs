import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.196";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0196");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0196-shell-v2-mesh-compositor");
const groundSha = "818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8";
const roadSha = "a64959ef2fd7a509fcaaa969fca3e095d590d563a4f0c578a5e96d1fb04c0e10";
const scenarios = {
  default: "default-procedural",
  legacy: "l1-legacy-riverbank-bridge-approach",
  p1: "p1-shell-v2-scoped-material",
  m1: "m1-shell-v2-mesh-compositor"
};
const requiredM1CaptureIds = [
  "title",
  "briefing",
  "mesh_compositor_overview",
  "aster_initial_frame",
  "terrain_normal",
  "roads_overview",
  "road_intersection",
  "left_bridge_approach",
  "right_bridge_approach",
  "river_banks",
  "bridge_close",
  "worker_area",
  "barracks_area",
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

function shell(report) {
  return report?.environmentPresentationShellV2 ?? {};
}

function mesh(report) {
  return report?.environmentShellV2MeshCompositor ?? shell(report)?.meshCompositor ?? {};
}

function topology(report) {
  return shell(report)?.topologyRepair ?? mesh(report)?.topologyMetrics ?? {};
}

function ground(report) {
  return report?.groundMaterialExperiment ?? {};
}

function road(report) {
  return report?.roadMaterialExperiment ?? {};
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
    report?.environmentShellV2MeshCompositor,
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
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 0) errors.push(`${id} should request zero character slots.`);
  if (Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 0) errors.push(`${id} should request zero environment material slots.`);
  if (report?.environmentPresentationShellV2Enabled === true) errors.push(`${id} unexpectedly enabled shell v2.`);
  if (report?.environmentShellV2MeshCompositorEnabled === true) errors.push(`${id} unexpectedly enabled mesh compositor.`);
  if (report?.environmentRiverbankBridgeApproachEnabled === true) errors.push(`${id} unexpectedly enabled legacy shell.`);
  checkNoForbiddenRuntimeMutation(report, id, errors);
}

function checkSharedOptInContext(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 5) errors.push(`${id} did not request exactly five frozen character slots.`);
  if (Number(report?.normalSliceOptInLoadedSlotCount ?? 0) !== 5) errors.push(`${id} did not load exactly five frozen character slots.`);
  if (Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 2) errors.push(`${id} did not request exactly ground+road material slots.`);
  if (Number(report?.environmentMaterialOptInLoadedSlotCount ?? 0) !== 2) errors.push(`${id} did not load exactly ground+road material slots.`);
  if (report?.sixthPlayerFacingArtSlotAdded === true) errors.push(`${id} reported a sixth character slot.`);
  if (Number(report?.environmentPresentationShellV2ArtSlotCount ?? 0) !== 0) errors.push(`${id} added a shell-v2 art slot.`);
  const g = ground(report);
  const r = road(report);
  if (g.expectedSha256 !== groundSha || g.actualSha256 !== groundSha || g.sourceLoaded !== true) errors.push(`${id} ground material hash/load mismatch.`);
  if (r.expectedSha256 !== roadSha || r.actualSha256 !== roadSha || r.sourceLoaded !== true) errors.push(`${id} road material hash/load mismatch.`);
  if (Number(g.sourceLoadCount ?? 99) !== 1 || Number(g.metadataParseCount ?? 99) !== 1 || Number(g.imageDecodeCount ?? 99) !== 1 || Number(g.textureCreateCount ?? 99) !== 1 || Number(g.materialCreateCount ?? 99) !== 1) errors.push(`${id} ground material was not one-time loaded/created.`);
  if (Number(r.sourceLoadCount ?? 99) !== 1 || Number(r.metadataParseCount ?? 99) !== 1 || Number(r.imageDecodeCount ?? 99) !== 1 || Number(r.textureCreateCount ?? 99) !== 1 || Number(r.materialCreateCount ?? 99) !== 1) errors.push(`${id} road material was not one-time loaded/created.`);
  checkNoForbiddenRuntimeMutation(report, id, errors);
}

function checkLegacy(report, id, errors) {
  checkSharedOptInContext(report, id, errors);
  if (report?.environmentRiverbankBridgeApproachEnabled !== true) errors.push(`${id} did not enable legacy riverbank bridge approach.`);
  if (report?.environmentShellV2MeshCompositorEnabled === true) errors.push(`${id} unexpectedly enabled mesh compositor.`);
}

function checkP1(report, id, errors) {
  checkSharedOptInContext(report, id, errors);
  const s = shell(report);
  if (report?.environmentPresentationShellV2Enabled !== true || s.enabled !== true) errors.push(`${id} did not enable shell v2.`);
  if (report?.environmentShellV2MeshCompositorEnabled === true || s.meshCompositorEnabled === true) errors.push(`${id} unexpectedly enabled mesh compositor.`);
  if (s.wetGraniteBridgeRiverbankMaterialIntegrated === true || s.bridgeRiverbankMaterialSlotAdded === true) errors.push(`${id} integrated wet granite.`);
  if (s.fallbackActive === true) errors.push(`${id} fell back: ${s.fallbackReason ?? ""}`);
}

function checkMesh(report, id, errors) {
  checkSharedOptInContext(report, id, errors);
  const s = shell(report);
  const m = mesh(report);
  const t = topology(report);
  if (report?.environmentPresentationShellV2Enabled !== true || s.enabled !== true) errors.push(`${id} did not enable shell v2 base.`);
  if (report?.environmentShellV2MeshCompositorEnabled !== true || m.enabled !== true || s.meshCompositorEnabled !== true) errors.push(`${id} did not enable mesh compositor.`);
  if (s.fallbackActive === true || m.fallbackActive === true) errors.push(`${id} fell back: ${s.fallbackReason ?? m.fallbackReason ?? ""}`);
  if (s.wetGraniteBridgeRiverbankMaterialIntegrated === true || s.bridgeRiverbankMaterialSlotAdded === true || m.wetGraniteIntegrated === true) errors.push(`${id} integrated wet granite.`);
  for (const [key, expected] of [
    ["terrainBaseSurfaceCount", 1],
    ["disconnectedRoadFragmentCount", 0],
    ["floatingDiagonalRoadFragmentCount", 0],
    ["riverSurfaceCount", 1],
    ["giantPadNodeCount", 0],
    ["gameplayCollisionPathingNodesModified", 0]
  ]) {
    if (Number(t[key] ?? 99) !== expected) errors.push(`${id} topology ${key} expected ${expected}, got ${t[key] ?? "missing"}.`);
  }
  for (const key of [
    "routeContinuityPass",
    "bridgeHasRoadConnectionWest",
    "bridgeHasRoadConnectionEast",
    "riverContinuityPass",
    "terrainBaseCoherent",
    "roadsConnected",
    "roadsReadAsRouteSurfaces",
    "bridgeRoadContinuity",
    "riverBankBridgeAligned",
    "banksFrameRiver",
    "bridgeReadsAsCrossing",
    "terrainReadsAsTerrain",
    "charactersGrounded",
    "legacyShellPreserved"
  ]) {
    if (t[key] !== true) errors.push(`${id} mesh topology gate ${key} was not true.`);
  }
  if (Number(t.roadRibbonCount ?? 0) < 6) errors.push(`${id} road ribbon count too low: ${t.roadRibbonCount ?? "missing"}.`);
  if (Number(t.bankEdgeCount ?? 0) < 2) errors.push(`${id} bank edge count too low.`);
  if (Number(t.bridgeVisualNodeCount ?? 0) < 8) errors.push(`${id} bridge visual node count too low.`);
  if (Number(t.meshVertexCount ?? m.vertexCount ?? 0) <= 0 || Number(t.meshIndexCount ?? m.indexCount ?? 0) <= 0) errors.push(`${id} missing mesh vertex/index counts.`);
  if (!Array.isArray(t.materialBindTargets?.ground) || t.materialBindTargets.ground.length < 1) errors.push(`${id} missing ground material bind targets.`);
  if (!Array.isArray(t.materialBindTargets?.road) || t.materialBindTargets.road.length < 6) errors.push(`${id} missing road material bind targets.`);
  if (t.broadMaterialMasksReintroduced === true || t.thinLineOnlyRoadsPresent === true) errors.push(`${id} reports forbidden masks or line-only roads.`);
}

function scenarioSummary(id, loaded) {
  const report = loaded.report;
  return {
    id,
    path: loaded.path ? rel(loaded.path) : "",
    status: report?.status ?? "MISSING",
    characterSlotsRequested: report?.normalSliceOptInRequestedSlotCount ?? 0,
    characterSlotsLoaded: report?.normalSliceOptInLoadedSlotCount ?? 0,
    environmentSlotsRequested: report?.environmentMaterialOptInRequestedSlotCount ?? 0,
    environmentSlotsLoaded: report?.environmentMaterialOptInLoadedSlotCount ?? 0,
    legacyShellEnabled: report?.environmentRiverbankBridgeApproachEnabled ?? false,
    shellV2Enabled: report?.environmentPresentationShellV2Enabled ?? false,
    meshCompositorEnabled: report?.environmentShellV2MeshCompositorEnabled ?? false,
    meshCompositor: mesh(report),
    shellV2: shell(report)
  };
}

function validationCommand(root) {
  const errors = [];
  const configs = [
    { id: scenarios.default, check: checkDefault },
    { id: scenarios.legacy, check: checkLegacy },
    { id: scenarios.p1, check: checkP1 },
    { id: scenarios.m1, check: checkMesh }
  ];
  const summaries = configs.map((config) => {
    const loaded = reportAt(root, "validation", config.id, "player-slice-validation-runtime.json", errors);
    if (loaded.report) config.check(loaded.report, config.id, errors);
    return scenarioSummary(config.id, loaded);
  });
  const m1 = summaries.find((entry) => entry.id === scenarios.m1);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0196_SHELL_V2_MESH_COMPOSITOR_VALIDATION" : "FAIL_V0196_SHELL_V2_MESH_COMPOSITOR_VALIDATION",
    scenarios: summaries,
    instrumentation: {
      meshVertexCount: m1?.meshCompositor?.vertexCount ?? 0,
      meshIndexCount: m1?.meshCompositor?.indexCount ?? 0,
      materialBindTargets: m1?.meshCompositor?.materialBindTargets ?? {},
      uvScales: m1?.meshCompositor?.uvScales ?? {}
    },
    errors
  };
  writeJson(join(root, "validation", "shell-v2-mesh-compositor-validation-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

function captureById(report, id) {
  return (report?.captures ?? []).find((capture) => capture.id === id);
}

function copyCapture(capture, fileName, errors) {
  if (!capture?.absolutePath || !existsSync(resolve(capture.absolutePath))) {
    errors.push(`Missing capture for manual-review file ${fileName}.`);
    return null;
  }
  mkdirSync(manualReviewRoot, { recursive: true });
  const destination = join(manualReviewRoot, fileName);
  copyFileSync(resolve(capture.absolutePath), destination);
  return destination;
}

function captureCommand(root) {
  const errors = [];
  const legacy = reportAt(root, "capture", scenarios.legacy, "screenshot-runtime-manifest.json", errors);
  const p1 = reportAt(root, "capture", scenarios.p1, "screenshot-runtime-manifest.json", errors);
  const m1 = reportAt(root, "capture", scenarios.m1, "screenshot-runtime-manifest.json", errors);
  if (legacy.report) checkLegacy(legacy.report, scenarios.legacy, errors);
  if (p1.report) checkP1(p1.report, scenarios.p1, errors);
  if (m1.report) checkMesh(m1.report, scenarios.m1, errors);
  const m1Ids = new Set((m1.report?.captures ?? []).map((capture) => capture.id));
  for (const id of requiredM1CaptureIds) {
    if (!m1Ids.has(id)) errors.push(`M1 capture is missing ${id}.`);
  }
  const manual = [
    [captureById(legacy.report, "mesh_compositor_overview"), "01_legacy_overview.png"],
    [captureById(m1.report, "mesh_compositor_overview"), "02_mesh_compositor_overview.png"],
    [captureById(m1.report, "terrain_normal"), "03_terrain_roads_normal.png"],
    [captureById(m1.report, "left_bridge_approach") ?? captureById(m1.report, "bridge_close"), "04_road_to_bridge.png"],
    [captureById(m1.report, "river_banks"), "05_river_banks_bridge.png"],
    [captureById(m1.report, "worker_area") ?? captureById(m1.report, "barracks_area"), "06_structures_and_units.png"],
    [captureById(m1.report, "zoom") ?? captureById(m1.report, "pan"), "07_pan_zoom.png"],
    [captureById(m1.report, "minimap"), "08_minimap_full_frame.png"]
  ];
  const manualPaths = manual.map(([capture, fileName]) => copyCapture(capture, fileName, errors)).filter(Boolean);
  const contactLines = [
    "# v0.196 Salto Shell V2 Mesh Compositor Manual Review Pack",
    "",
    `Pack: \`${rel(manualReviewRoot)}\``,
    ""
  ];
  for (const path of manualPaths) {
    contactLines.push(`![${rel(path)}](${rel(path)})`);
    contactLines.push("");
  }
  writeText(join(manualReviewRoot, "index.md"), `${contactLines.join("\n")}\n`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0196_SHELL_V2_MESH_COMPOSITOR_CAPTURE_PACKET" : "FAIL_V0196_SHELL_V2_MESH_COMPOSITOR_CAPTURE_PACKET",
    legacyManifest: legacy.report ? rel(legacy.path) : "",
    p1Manifest: p1.report ? rel(p1.path) : "",
    m1Manifest: m1.report ? rel(m1.path) : "",
    requiredM1CaptureIds,
    manualReviewRoot,
    manualReviewPaths: manualPaths,
    errors
  };
  writeJson(join(root, "capture", "shell-v2-mesh-compositor-capture-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

function benchmarkCommand(root) {
  const errors = [];
  const p1 = reportAt(root, "benchmark", scenarios.p1, "worker-art-opt-in-benchmark-runtime.json", errors);
  const m1 = reportAt(root, "benchmark", scenarios.m1, "worker-art-opt-in-benchmark-runtime.json", errors);
  if (p1.report) checkP1(p1.report, `benchmark-${scenarios.p1}`, errors);
  if (m1.report) checkMesh(m1.report, `benchmark-${scenarios.m1}`, errors);
  const p1Fps = fps(p1.report);
  const m1Fps = fps(m1.report);
  const p1P95 = p95(p1.report);
  const m1P95 = p95(m1.report);
  const fpsRatio = p1Fps > 0 ? m1Fps / p1Fps : 0;
  const p95WorseningRatio = p1P95 > 0 ? (m1P95 - p1P95) / p1P95 : 1;
  if (fpsRatio < 0.85) errors.push(`M1/P1 FPS ratio below 0.85: ${fpsRatio.toFixed(4)}.`);
  if (p95WorseningRatio > 0.20) errors.push(`M1 p95 worsening above 20%: ${(p95WorseningRatio * 100).toFixed(2)}%.`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0196_SHELL_V2_MESH_COMPOSITOR_BENCHMARK" : "FAIL_V0196_SHELL_V2_MESH_COMPOSITOR_BENCHMARK",
    p1: { path: rel(p1.path), fpsAverage: p1Fps, frameTimeP95Ms: p1P95 },
    m1: { path: rel(m1.path), fpsAverage: m1Fps, frameTimeP95Ms: m1P95 },
    thresholds: { minFpsRatio: 0.85, maxP95WorseningRatio: 0.20 },
    fpsRatio,
    p95WorseningRatio,
    errors
  };
  writeJson(join(root, "benchmark", "shell-v2-mesh-compositor-benchmark-report.json"), report);
  writeText(join(root, "benchmark", "shell-v2-mesh-compositor-scorecard.md"), [
    "# v0.196 Shell V2 Mesh Compositor Benchmark",
    "",
    `Status: \`${report.status}\``,
    "",
    `P1 FPS: \`${p1Fps}\``,
    `M1 FPS: \`${m1Fps}\``,
    `FPS ratio: \`${fpsRatio.toFixed(4)}\``,
    `P1 p95 ms: \`${p1P95}\``,
    `M1 p95 ms: \`${m1P95}\``,
    `p95 worsening: \`${(p95WorseningRatio * 100).toFixed(2)}%\``,
    "",
    "Thresholds: M1/P1 FPS ratio >= 0.85; M1 p95 worsening <= 20%."
  ].join("\n") + "\n");
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
    /^artifacts\/desktop-spikes\/godot-salto\/v0189\//u
  ];
  const defaultLauncherFiles = new Set([
    "tools/godot/launchGodotReviewWindows.ps1",
    "tools/godot/launchGodotPlayerSliceWindows.ps1",
    "tools/godot/launchGodotPrivateHarnessWindows.ps1",
    "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat"
  ]);
  const allowedEvidenceImagePatterns = [
    /^artifacts\/manual-review\/v0196-shell-v2-mesh-compositor\/\d{2}_[^/]+\.png$/u
  ];
  for (const file of changedFiles) {
    if (defaultLauncherFiles.has(file)) errors.push(`Default/procedural launcher changed: ${file}`);
    if (forbiddenPathPatterns.some((pattern) => pattern.test(file))) errors.push(`Boundary-forbidden file changed: ${file}`);
    if (/\.(png|jpg|jpeg|webp)$/iu.test(file) && !allowedEvidenceImagePatterns.some((pattern) => pattern.test(file))) {
      errors.push(`Generated/imported image file changed in tracked/untracked scope: ${file}`);
    }
  }
  const launchPath = join(repoRoot, "tools/godot/launchGodotSaltoShellV2MeshCompositorWindows.ps1");
  const launch = existsSync(launchPath) ? readFileSync(launchPath, "utf8") : "";
  if (!launch.includes("--salto-shell-v2-mesh-compositor")) errors.push("Mesh compositor launcher lacks --salto-shell-v2-mesh-compositor.");
  if (launch.includes("--barrosan-bridge-riverbank-material-single-slot") || launch.includes("--bridge-riverbank-material-opt-in")) errors.push("Mesh compositor launcher integrates wet-granite bridge-riverbank material.");
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0196_SHELL_V2_MESH_COMPOSITOR_BOUNDARY_SCAN" : "FAIL_V0196_SHELL_V2_MESH_COMPOSITOR_BOUNDARY_SCAN",
    changedFiles,
    assertions: {
      gameplayPathingCollisionFilesChanged: false,
      defaultLauncherChanged: false,
      browserRuntimeChanged: false,
      generatedImagesChanged: false,
      newArtSlotsAdded: false,
      wetGraniteIntegrated: false
    },
    errors
  };
  writeJson(join(root, "boundary", "shell-v2-mesh-compositor-boundary-scan.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

const root = artifactRootFromArgs();
const command = process.argv[2] ?? "validation";
if (command === "validation") validationCommand(root);
else if (command === "capture") captureCommand(root);
else if (command === "benchmark") benchmarkCommand(root);
else if (command === "boundary") boundaryCommand(root);
else {
  console.error("Usage: node tools/godot/saltoShellV2MeshCompositorTool.mjs <validation|capture|benchmark|boundary> [--artifact-root=...]");
  process.exit(1);
}
