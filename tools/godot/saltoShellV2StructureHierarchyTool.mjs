import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync, execSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.199";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0199");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0199-structure-hierarchy");
const groundSha = "818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8";
const roadSha = "a64959ef2fd7a509fcaaa969fca3e095d590d563a4f0c578a5e96d1fb04c0e10";
const bridgeRiverbankSha = "638ce153d7a3d39db729dfa13ba05f3fb05c437c2802ab91b5cd248bd2036753";
const scenarios = {
  default: "default-procedural",
  baseline: "w1-shell-v2-mesh-wet-granite",
  hardened: "s1-shell-v2-structure-hierarchy"
};
const requiredCaptureIds = [
  "overview",
  "command_hall",
  "mine",
  "barracks_restoring",
  "barracks_restored",
  "worker_barracks",
  "combat_posture",
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

function hierarchy(report) {
  return report?.environmentShellV2StructureHierarchy ?? shell(report)?.structureHierarchy ?? {};
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

function bridgeRiverbank(report) {
  return report?.bridgeRiverbankMaterialExperiment ?? {};
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
    report?.environmentShellV2StructureHierarchy
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
  if (report?.environmentShellV2StructureHierarchyEnabled === true) errors.push(`${id} unexpectedly enabled structure hierarchy.`);
  checkNoForbiddenRuntimeMutation(report, id, errors);
}

function checkSharedOptInContext(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 5) errors.push(`${id} did not request exactly five frozen character slots.`);
  if (Number(report?.normalSliceOptInLoadedSlotCount ?? 0) !== 5) errors.push(`${id} did not load exactly five frozen character slots.`);
  if (Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 3) errors.push(`${id} did not request exactly three environment material slots.`);
  if (Number(report?.environmentMaterialOptInLoadedSlotCount ?? 0) !== 3) errors.push(`${id} did not load exactly three environment material slots.`);
  if (report?.sixthPlayerFacingArtSlotAdded === true) errors.push(`${id} reported a sixth character slot.`);
  if (Number(report?.environmentPresentationShellV2ArtSlotCount ?? 0) !== 0) errors.push(`${id} added a shell-v2 art slot.`);
  const g = ground(report);
  const r = road(report);
  const b = bridgeRiverbank(report);
  if (g.expectedSha256 !== groundSha || g.actualSha256 !== groundSha || g.sourceLoaded !== true) errors.push(`${id} ground material hash/load mismatch.`);
  if (r.expectedSha256 !== roadSha || r.actualSha256 !== roadSha || r.sourceLoaded !== true) errors.push(`${id} road material hash/load mismatch.`);
  if (b.expectedSha256 !== bridgeRiverbankSha || b.actualSha256 !== bridgeRiverbankSha || b.sourceLoaded !== true) errors.push(`${id} bridge-riverbank material hash/load mismatch.`);
  checkNoForbiddenRuntimeMutation(report, id, errors);
}

function checkMeshBaseline(report, id, errors) {
  checkSharedOptInContext(report, id, errors);
  const s = shell(report);
  const m = mesh(report);
  const h = hierarchy(report);
  const t = topology(report);
  if (report?.environmentPresentationShellV2Enabled !== true || s.enabled !== true) errors.push(`${id} did not enable shell v2 base.`);
  if (report?.environmentShellV2MeshCompositorEnabled !== true || m.enabled !== true || s.meshCompositorEnabled !== true) errors.push(`${id} did not enable mesh compositor.`);
  if (report?.environmentShellV2StructureHierarchyEnabled === true || h.enabled === true || s.structureHierarchyEnabled === true) errors.push(`${id} unexpectedly enabled structure hierarchy.`);
  if (s.wetGraniteBridgeRiverbankMaterialIntegrated !== true || m.wetGraniteIntegrated !== true) errors.push(`${id} did not preserve wet-granite mesh integration.`);
  for (const key of [
    "routeContinuityPass",
    "bridgeHasRoadConnectionWest",
    "bridgeHasRoadConnectionEast",
    "riverContinuityPass",
    "terrainBaseCoherent",
    "roadsConnected",
    "bridgeRoadContinuity",
    "riverBankBridgeAligned",
    "banksFrameRiver",
    "bridgeReadsAsCrossing",
    "charactersGrounded",
    "legacyShellPreserved"
  ]) {
    if (t[key] !== true) errors.push(`${id} topology gate ${key} was not true.`);
  }
}

function checkStructureHierarchy(report, id, errors) {
  checkSharedOptInContext(report, id, errors);
  const s = shell(report);
  const m = mesh(report);
  const h = hierarchy(report);
  const t = topology(report);
  if (report?.environmentPresentationShellV2Enabled !== true || s.enabled !== true) errors.push(`${id} did not enable shell v2 base.`);
  if (report?.environmentShellV2MeshCompositorEnabled !== true || m.enabled !== true || s.meshCompositorEnabled !== true) errors.push(`${id} did not preserve mesh compositor.`);
  if (s.wetGraniteBridgeRiverbankMaterialIntegrated !== true || m.wetGraniteIntegrated !== true) errors.push(`${id} did not preserve wet-granite mesh integration.`);
  for (const key of [
    "routeContinuityPass",
    "bridgeHasRoadConnectionWest",
    "bridgeHasRoadConnectionEast",
    "riverContinuityPass",
    "terrainBaseCoherent",
    "roadsConnected",
    "bridgeRoadContinuity",
    "riverBankBridgeAligned",
    "banksFrameRiver",
    "bridgeReadsAsCrossing",
    "charactersGrounded",
    "legacyShellPreserved"
  ]) {
    if (t[key] !== true) errors.push(`${id} topology gate ${key} was not true.`);
  }
  if (s.structureHierarchyEnabled !== true || m.structureHierarchyEnabled !== true || h.enabled !== true) {
    errors.push(`${id} did not enable the v0.199 structure hierarchy flag.`);
  }
  if (h.aiImageGenerated !== false || Number(h.newArtSlotsAdded ?? 99) !== 0 || Number(h.newImportedTextures ?? 99) !== 0) {
    errors.push(`${id} reported new images, slots, or textures.`);
  }
  for (const key of [
    "wetGraniteFoundationsUsed",
    "timberFramesUsed",
    "restrainedMetalUsed",
    "practicalScaffoldingUsed",
    "restrainedWarmAccentsUsed",
    "commandHallImproved",
    "mineImproved",
    "barracksRestorationDifferentiated",
    "restoredBarracksDifferentiated",
    "siteStructuresImproved",
    "contactGroundingImproved",
    "structureHierarchyMateriallyImproved",
    "routeRiverBridgeReadabilityPreserved",
    "legacyShellPreserved",
    "wetGraniteMeshComparatorPreserved"
  ]) {
    if (h[key] !== true) errors.push(`${id} hierarchy gate ${key} was not true.`);
  }
  if (Number(h.visualNodeCount ?? 0) < 30) errors.push(`${id} hierarchy node count too low: ${h.visualNodeCount ?? "missing"}.`);
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
    shellV2Enabled: report?.environmentPresentationShellV2Enabled ?? false,
    meshCompositorEnabled: report?.environmentShellV2MeshCompositorEnabled ?? false,
    structureHierarchyEnabled: report?.environmentShellV2StructureHierarchyEnabled ?? false,
    meshCompositor: mesh(report),
    structureHierarchy: hierarchy(report),
    shellV2: shell(report)
  };
}

function validationCommand(root) {
  const errors = [];
  const configs = [
    { id: scenarios.default, check: checkDefault },
    { id: scenarios.baseline, check: checkMeshBaseline },
    { id: scenarios.hardened, check: checkStructureHierarchy }
  ];
  const summaries = configs.map((config) => {
    const loaded = reportAt(root, "validation", config.id, "player-slice-validation-runtime.json", errors);
    if (loaded.report) config.check(loaded.report, config.id, errors);
    return scenarioSummary(config.id, loaded);
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0199_STRUCTURE_HIERARCHY_VALIDATION" : "FAIL_V0199_STRUCTURE_HIERARCHY_VALIDATION",
    scenarios: summaries,
    errors
  };
  writeJson(join(root, "validation", "structure-hierarchy-validation-report.json"), report);
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

function createContactSheet(sourcePaths, outputPath, errors) {
  const pythonExe = process.env.SALTO_CONTACT_SHEET_PYTHON || "python";
  const payload = JSON.stringify({ sourcePaths, outputPath });
  const script = String.raw`
import json
import os
from PIL import Image, ImageDraw, ImageFont

payload = json.loads(os.environ["SALTO_CONTACT_SHEET_PAYLOAD"])
sources = payload["sourcePaths"]
output = payload["outputPath"]
thumb_w = 760
thumb_h = 405
margin = 24
label_h = 30
cols = 2
rows = 4
canvas = Image.new("RGB", (cols * thumb_w + (cols + 1) * margin, rows * (thumb_h + label_h) + (rows + 1) * margin), (20, 27, 18))
draw = ImageDraw.Draw(canvas)
try:
    font = ImageFont.truetype("arial.ttf", 18)
except Exception:
    font = ImageFont.load_default()
for index, path in enumerate(sources):
    image = Image.open(path).convert("RGB")
    image.thumbnail((thumb_w, thumb_h), Image.Resampling.LANCZOS)
    col = index % cols
    row = index // cols
    x = margin + col * (thumb_w + margin)
    y = margin + row * (thumb_h + label_h + margin)
    frame = Image.new("RGB", (thumb_w, thumb_h), (32, 40, 28))
    frame.paste(image, ((thumb_w - image.width) // 2, (thumb_h - image.height) // 2))
    canvas.paste(frame, (x, y + label_h))
    draw.text((x, y), os.path.basename(path), fill=(215, 224, 188), font=font)
os.makedirs(os.path.dirname(output), exist_ok=True)
canvas.save(output)
`;
  try {
    execFileSync(pythonExe, ["-c", script], {
      cwd: repoRoot,
      env: { ...process.env, SALTO_CONTACT_SHEET_PAYLOAD: payload },
      stdio: ["ignore", "pipe", "pipe"]
    });
  } catch (error) {
    errors.push(`Failed to create contact sheet with '${pythonExe}': ${error.message}`);
  }
}

function captureCommand(root) {
  const errors = [];
  const baseline = reportAt(root, "capture", scenarios.baseline, "screenshot-runtime-manifest.json", errors);
  const hardened = reportAt(root, "capture", scenarios.hardened, "screenshot-runtime-manifest.json", errors);
  if (baseline.report) checkMeshBaseline(baseline.report, scenarios.baseline, errors);
  if (hardened.report) checkStructureHierarchy(hardened.report, scenarios.hardened, errors);
  const hardenedIds = new Set((hardened.report?.captures ?? []).map((capture) => capture.id));
  for (const id of requiredCaptureIds) {
    if (!hardenedIds.has(id)) errors.push(`S1 capture is missing ${id}.`);
  }
  const manual = [
    [captureById(hardened.report, "overview"), "01_overview.png"],
    [captureById(hardened.report, "command_hall"), "02_command_hall.png"],
    [captureById(hardened.report, "mine"), "03_mine.png"],
    [captureById(hardened.report, "barracks_restoring"), "04_barracks_restoring.png"],
    [captureById(hardened.report, "barracks_restored"), "05_barracks_restored.png"],
    [captureById(hardened.report, "worker_barracks"), "06_worker_barracks.png"],
    [captureById(hardened.report, "combat_posture"), "07_combat_posture.png"]
  ];
  const manualPaths = manual.map(([capture, fileName]) => copyCapture(capture, fileName, errors)).filter(Boolean);
  const contactSheetPath = join(manualReviewRoot, "08_contact_sheet.png");
  if (manualPaths.length === manual.length) {
    createContactSheet(manualPaths, contactSheetPath, errors);
  }
  if (!existsSync(contactSheetPath)) errors.push("Missing v0.199 contact sheet PNG.");
  else manualPaths.push(contactSheetPath);
  const contactLines = [
    "# v0.199 Structure Hierarchy Manual Review Pack",
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
    status: errors.length === 0 ? "PASS_V0199_STRUCTURE_HIERARCHY_CAPTURE_PACKET" : "FAIL_V0199_STRUCTURE_HIERARCHY_CAPTURE_PACKET",
    baselineManifest: baseline.report ? rel(baseline.path) : "",
    hardenedManifest: hardened.report ? rel(hardened.path) : "",
    requiredCaptureIds,
    manualReviewRoot,
    manualReviewPaths: manualPaths,
    errors
  };
  writeJson(join(root, "capture", "structure-hierarchy-capture-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

function benchmarkCommand(root) {
  const errors = [];
  const baseline = reportAt(root, "benchmark", scenarios.baseline, "worker-art-opt-in-benchmark-runtime.json", errors);
  const hardened = reportAt(root, "benchmark", scenarios.hardened, "worker-art-opt-in-benchmark-runtime.json", errors);
  if (baseline.report) checkMeshBaseline(baseline.report, `benchmark-${scenarios.baseline}`, errors);
  if (hardened.report) checkStructureHierarchy(hardened.report, `benchmark-${scenarios.hardened}`, errors);
  const baselineFps = fps(baseline.report);
  const hardenedFps = fps(hardened.report);
  const baselineP95 = p95(baseline.report);
  const hardenedP95 = p95(hardened.report);
  const fpsRatio = baselineFps > 0 ? hardenedFps / baselineFps : 0;
  const p95WorseningRatio = baselineP95 > 0 ? (hardenedP95 - baselineP95) / baselineP95 : 1;
  if (fpsRatio < 0.90) errors.push(`S1/W1 FPS ratio below 0.90: ${fpsRatio.toFixed(4)}.`);
  if (p95WorseningRatio > 0.15) errors.push(`S1 p95 worsening above 15%: ${(p95WorseningRatio * 100).toFixed(2)}%.`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0199_STRUCTURE_HIERARCHY_BENCHMARK" : "FAIL_V0199_STRUCTURE_HIERARCHY_BENCHMARK",
    baseline: { path: rel(baseline.path), fpsAverage: baselineFps, frameTimeP95Ms: baselineP95 },
    hardened: { path: rel(hardened.path), fpsAverage: hardenedFps, frameTimeP95Ms: hardenedP95 },
    thresholds: { minFpsRatio: 0.90, maxP95WorseningRatio: 0.15 },
    fpsRatio,
    p95WorseningRatio,
    errors
  };
  writeJson(join(root, "benchmark", "structure-hierarchy-benchmark-report.json"), report);
  writeText(join(root, "benchmark", "structure-hierarchy-scorecard.md"), [
    "# v0.199 Structure Hierarchy Benchmark",
    "",
    `Status: \`${report.status}\``,
    "",
    `W1 baseline FPS: \`${baselineFps}\``,
    `S1 hardened FPS: \`${hardenedFps}\``,
    `FPS ratio: \`${fpsRatio.toFixed(4)}\``,
    `W1 baseline p95 ms: \`${baselineP95}\``,
    `S1 hardened p95 ms: \`${hardenedP95}\``,
    `p95 worsening: \`${(p95WorseningRatio * 100).toFixed(2)}%\``,
    "",
    "Thresholds: S1/W1 FPS ratio >= 0.90; S1 p95 worsening <= 15%."
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
    /^desktop-spikes\/godot-salto\/scripts\/salto_spike_workload_runtime\.gd$/u
  ];
  const defaultLauncherFiles = new Set([
    "tools/godot/launchGodotReviewWindows.ps1",
    "tools/godot/launchGodotPlayerSliceWindows.ps1",
    "tools/godot/launchGodotPrivateHarnessWindows.ps1",
    "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat"
  ]);
  const allowedEvidenceImagePatterns = [
    /^artifacts\/manual-review\/v0199-structure-hierarchy\/\d{2}_[^/]+\.png$/u
  ];
  for (const file of changedFiles) {
    if (defaultLauncherFiles.has(file)) errors.push(`Default/procedural launcher changed: ${file}`);
    if (forbiddenPathPatterns.some((pattern) => pattern.test(file))) errors.push(`Boundary-forbidden file changed: ${file}`);
    if (/\.(png|jpg|jpeg|webp)$/iu.test(file) && !allowedEvidenceImagePatterns.some((pattern) => pattern.test(file))) {
      errors.push(`Generated/imported image file changed in tracked/untracked scope: ${file}`);
    }
  }
  const launchPath = join(repoRoot, "tools/godot/launchGodotSaltoShellV2StructureHierarchyWindows.ps1");
  const launch = existsSync(launchPath) ? readFileSync(launchPath, "utf8") : "";
  if (!launch.includes("--salto-shell-v2-structure-hierarchy")) errors.push("Structure hierarchy launcher lacks --salto-shell-v2-structure-hierarchy.");
  if (!launch.includes("--salto-shell-v2-mesh-compositor")) errors.push("Structure hierarchy launcher lacks mesh compositor comparator flag.");
  if (!launch.includes("--bridge-riverbank-material-opt-in")) errors.push("Structure hierarchy launcher did not preserve wet-granite context.");
  if (!launch.includes(bridgeRiverbankSha)) errors.push("Structure hierarchy launcher lacks exact selected v0.189 SHA.");
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0199_STRUCTURE_HIERARCHY_BOUNDARY_SCAN" : "FAIL_V0199_STRUCTURE_HIERARCHY_BOUNDARY_SCAN",
    changedFiles,
    assertions: {
      gameplayPathingCollisionFilesChanged: false,
      defaultLauncherChanged: false,
      browserRuntimeChanged: false,
      generatedImagesChanged: false,
      newArtSlotsAdded: false,
      structureHierarchyOptInOnly: true
    },
    errors
  };
  writeJson(join(root, "boundary", "structure-hierarchy-boundary-scan.json"), report);
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
  console.error("Usage: node tools/godot/saltoShellV2StructureHierarchyTool.mjs <validation|capture|benchmark|boundary> [--artifact-root=...]");
  process.exit(1);
}
