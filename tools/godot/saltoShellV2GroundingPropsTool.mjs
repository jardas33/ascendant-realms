import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync, execSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.205";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0205");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0205-grounding-lighting-props");
const scenarios = {
  default: "default-procedural",
  baseline: "b0-shell-v2-structure-material",
  selected: "p1-shell-v2-grounding-props"
};
const requiredCaptureIds = [
  "overview",
  "ground_roads_props",
  "river_bridge_grounding",
  "structures_grounding",
  "units_grounding",
  "ashen_combat_readability",
  "minimap_pan_zoom",
  "results"
];
const requiredManualPngs = [
  "01_before_after_overview.png",
  "02_final_overview.png",
  "03_ground_roads_props.png",
  "04_river_bridge_grounding.png",
  "05_structures_grounding.png",
  "06_units_grounding.png",
  "07_ashen_combat_readability.png",
  "08_minimap_pan_zoom.png"
];

function stableSort(value) {
  if (Array.isArray(value)) return value.map(stableSort);
  if (value && typeof value === "object") {
    return Object.fromEntries(Object.entries(value).sort(([a], [b]) => a.localeCompare(b)).map(([key, entry]) => [key, stableSort(entry)]));
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
  return relative(repoRoot, path).replaceAll("\\", "/");
}

function artifactRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--artifact-root="));
  return explicit ? resolve(explicit.slice("--artifact-root=".length)) : artifactRootDefault;
}

function finalRuntimeStatus(report) {
  if (!report || typeof report !== "object") return null;
  if (report.finalStatus && typeof report.finalStatus === "object") return report.finalStatus;
  if (Array.isArray(report.captures)) {
    const overview = report.captures.find((capture) => capture?.id === "overview")?.status;
    if (overview && typeof overview === "object") return overview;
    for (let index = report.captures.length - 1; index >= 0; index -= 1) {
      const status = report.captures[index]?.status;
      if (status && typeof status === "object") return status;
    }
  }
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
  return { ...report, ...finalStatus, checkpoint: report.checkpoint ?? finalStatus.checkpoint, status: report.status ?? finalStatus.status };
}

function reportAt(root, group, scenarioId, fileName, errors) {
  const path = join(root, group, scenarioId, fileName);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}.`);
    return { path, report: null };
  }
  return { path, report: effectiveReport(readJson(path)) };
}

function isPass(report) {
  return typeof report?.status === "string" && report.status.startsWith("PASS");
}

function fps(report) {
  return Number(report?.fpsAverage ?? report?.averageFps ?? report?.meanFps ?? 0);
}

function p95(report) {
  return Number(report?.frameTimeP95Ms ?? report?.p95FrameMs ?? report?.frameP95Ms ?? 0);
}

function shell(report) {
  return report?.environmentPresentationShellV2 ?? {};
}

function structureMaterial(report) {
  return report?.environmentShellV2StructureMaterial ?? shell(report)?.structureMaterial ?? {};
}

function groundingProps(report) {
  return report?.environmentShellV2GroundingProps ?? shell(report)?.groundingProps ?? {};
}

function checkNoForbiddenRuntimeMutation(report, id, errors) {
  for (const key of ["browserRuntimeChanged", "saveWritesAllowed", "stableIdsChanged"]) {
    if (report?.[key] === true) errors.push(`${id} reported forbidden ${key}.`);
  }
  for (const status of [
    report?.environmentPresentationShellV2,
    report?.environmentShellV2MeshCompositor,
    report?.environmentShellV2StructureHierarchy,
    report?.environmentShellV2GroundingLighting,
    report?.environmentShellV2EnvironmentalCohesion,
    report?.environmentShellV2StructureMaterial,
    report?.environmentShellV2GroundingProps
  ]) {
    for (const key of [
      "gameplayPathingChanged",
      "collisionGeometryChanged",
      "objectiveLogicChanged",
      "aiLogicChanged",
      "economyChanged",
      "balanceChanged",
      "navigationSemanticsChanged",
      "routeTopologyChanged",
      "structureLocationsChanged"
    ]) {
      if (status?.[key] === true) errors.push(`${id} reported forbidden ${key}.`);
    }
  }
}

function checkDefault(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}.`);
  if (report?.environmentPresentationShellV2Enabled === true) errors.push(`${id} unexpectedly enabled shell v2.`);
  if (report?.environmentShellV2GroundingPropsEnabled === true) errors.push(`${id} unexpectedly enabled v0.205 props.`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 0) errors.push(`${id} requested normal-slice art slots.`);
  if (Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 0) errors.push(`${id} requested environment material slots.`);
  if (report?.structureFinishMaterialPrivateOptInRequested === true) errors.push(`${id} requested structure finish material.`);
  checkNoForbiddenRuntimeMutation(report, id, errors);
}

function checkSharedOptInContext(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}.`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 5) errors.push(`${id} did not preserve exactly five frozen character slots.`);
  if (Number(report?.normalSliceOptInLoadedSlotCount ?? 0) !== 5) errors.push(`${id} did not load exactly five frozen character slots.`);
  if (Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 3) errors.push(`${id} did not preserve exactly three existing environment material slots.`);
  if (Number(report?.environmentMaterialOptInLoadedSlotCount ?? 0) !== 3) errors.push(`${id} did not load exactly three existing environment material slots.`);
  if (Number(report?.environmentPresentationShellV2ArtSlotCount ?? 0) !== 0) errors.push(`${id} leaked a shell-v2 art slot.`);
  if (report?.sixthPlayerFacingArtSlotAdded === true) errors.push(`${id} reported a sixth character slot.`);
  checkNoForbiddenRuntimeMutation(report, id, errors);
}

function checkBaseline(report, id, errors) {
  checkSharedOptInContext(report, id, errors);
  const material = structureMaterial(report);
  if (report?.environmentShellV2StructureMaterialEnabled !== true || material.enabled !== true) errors.push(`${id} did not enable v0.204 structure material.`);
  if (report?.environmentShellV2GroundingPropsEnabled === true) errors.push(`${id} unexpectedly enabled v0.205 grounding props.`);
  if (material.materialActive !== true || material.fallbackActive === true) errors.push(`${id} did not keep selected v0.204 material active.`);
}

function checkSelected(report, id, errors) {
  checkSharedOptInContext(report, id, errors);
  const activeShell = shell(report);
  const material = structureMaterial(report);
  const props = groundingProps(report);
  if (activeShell.checkpoint !== checkpoint) errors.push(`${id} shell checkpoint mismatch: ${activeShell.checkpoint ?? "missing"}.`);
  if (report?.environmentShellV2StructureMaterialEnabled !== true || material.enabled !== true) errors.push(`${id} did not preserve v0.204 structure material.`);
  if (material.materialActive !== true || material.fallbackActive === true) errors.push(`${id} did not keep selected structure material active.`);
  if (report?.environmentShellV2GroundingPropsEnabled !== true || props.enabled !== true) errors.push(`${id} did not enable v0.205 grounding props.`);
  for (const key of [
    "initialized",
    "isolatedShellV2ReviewPathOnly",
    "visualOnly",
    "sparseDeterministicProps",
    "propsStaySparse",
    "usesDeterministicPlacement",
    "usesProceduralGeometryOnly",
    "tacticalLanesReadable",
    "propsDoNotImplyCollision",
    "lightingValueBalanceImproved",
    "muddyGreenSamenessReduced",
    "notOverDarkened",
    "noCinematicOverlighting",
    "markersRemainReadable",
    "friendlyHostileReadabilityMaintained",
    "charactersGrounded",
    "structuresGrounded",
    "workerAsterMilitiaAshenSilhouettesDistinct",
    "riverReadableAtOverview",
    "bankShelfVariationUsed",
    "waterValueVariationUsed",
    "wetEdgeTreatmentUsed",
    "bridgeLandingContactDetailsUsed",
    "minimapCorrelationPreserved",
    "panZoomPreserved",
    "cameraFramingAvoidsGiantUnusedEmptySpace",
    "performanceBudgeted"
  ]) {
    if (props[key] !== true) errors.push(`${id} grounding props gate ${key} was not true.`);
  }
  if (props.aiImageGenerated !== false || Number(props.downloadedAssets ?? 0) !== 0) errors.push(`${id} generated or downloaded assets.`);
  if (Number(props.newArtSlotsAdded ?? 1) !== 0 || Number(props.newImportedTextures ?? 1) !== 0) errors.push(`${id} added art slots or imported textures.`);
  if (props.productionRuntimeArtSlotAdded !== false) errors.push(`${id} reported production runtime art slot leakage.`);
  if (props.nodeCountExplosion === true) errors.push(`${id} reported node count explosion.`);
  const count = Number(props.visualNodeCount ?? 0);
  if (count < 32 || count > Number(props.nodeCountBudget ?? 80)) errors.push(`${id} visual node count outside sparse budget: ${count}.`);
  if (Number(props.roadsideStonesUsed ?? 0) < 5) errors.push(`${id} has too few roadside stones.`);
  if (Number(props.timberStakesOrPostsUsed ?? 0) < 4) errors.push(`${id} has too few timber posts.`);
  if (Number(props.restrainedBankRocksUsed ?? 0) < 5) errors.push(`${id} has too few bank rocks.`);
  if (Number(props.tinyGrassScrubClumpsUsed ?? 0) < 5) errors.push(`${id} has too few scrub clumps.`);
  if (Number(props.bridgeSideGroundingDetailsUsed ?? 0) < 5) errors.push(`${id} has too few bridge grounding details.`);
  if (Number(props.structureContactDetailsUsed ?? 0) < 6) errors.push(`${id} has too few structure contact details.`);
  if (Number(props.unitContactDetailsUsed ?? 0) < 4) errors.push(`${id} has too few unit contact details.`);
  if (Number(props.giantOpaqueCircles ?? 1) !== 0) errors.push(`${id} reported giant opaque circles.`);
  if (activeShell.groundingPropsMateriallyImproved !== true) errors.push(`${id} shell did not report groundingPropsMateriallyImproved.`);
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
    shell: shell(report),
    structureMaterial: structureMaterial(report),
    groundingProps: groundingProps(report)
  };
}

function validationCommand(root) {
  const errors = [];
  const configs = [
    { id: scenarios.default, check: checkDefault },
    { id: scenarios.baseline, check: checkBaseline },
    { id: scenarios.selected, check: checkSelected }
  ];
  const summaries = configs.map((config) => {
    const loaded = reportAt(root, "validation", config.id, "player-slice-validation-runtime.json", errors);
    if (loaded.report) config.check(loaded.report, config.id, errors);
    return scenarioSummary(config.id, loaded);
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0205_GROUNDING_LIGHTING_PROPS_VALIDATION" : "FAIL_V0205_GROUNDING_LIGHTING_PROPS_VALIDATION",
    scenarios: summaries,
    errors
  };
  writeJson(join(root, "validation", "grounding-lighting-props-validation-report.json"), report);
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
rows = max(1, (len(sources) + 1) // 2)
canvas = Image.new("RGB", (cols * thumb_w + (cols + 1) * margin, rows * (thumb_h + label_h) + (rows + 1) * margin), (22, 27, 21))
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
    frame = Image.new("RGB", (thumb_w, thumb_h), (34, 39, 31))
    frame.paste(image, ((thumb_w - image.width) // 2, (thumb_h - image.height) // 2))
    canvas.paste(frame, (x, y + label_h))
    draw.text((x, y), os.path.basename(path), fill=(218, 224, 188), font=font)
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
  const selected = reportAt(root, "capture", scenarios.selected, "screenshot-runtime-manifest.json", errors);
  if (baseline.report) checkBaseline(baseline.report, scenarios.baseline, errors);
  if (selected.report) checkSelected(selected.report, scenarios.selected, errors);
  const selectedIds = new Set((selected.report?.captures ?? []).map((capture) => capture.id));
  for (const id of requiredCaptureIds) {
    if (!selectedIds.has(id)) errors.push(`P1 capture is missing ${id}.`);
  }
  const beforeOverview = captureById(baseline.report, "overview")?.absolutePath ? resolve(captureById(baseline.report, "overview").absolutePath) : null;
  const selectedOverview = captureById(selected.report, "overview");
  const selectedOverviewPath = selectedOverview?.absolutePath ? resolve(selectedOverview.absolutePath) : null;
  if (beforeOverview && selectedOverviewPath) {
    createContactSheet([beforeOverview, selectedOverviewPath], join(manualReviewRoot, "01_before_after_overview.png"), errors);
  } else {
    errors.push("Missing baseline/selected overview for before-after sheet.");
  }
  copyCapture(selectedOverview, "02_final_overview.png", errors);
  copyCapture(captureById(selected.report, "ground_roads_props"), "03_ground_roads_props.png", errors);
  copyCapture(captureById(selected.report, "river_bridge_grounding"), "04_river_bridge_grounding.png", errors);
  copyCapture(captureById(selected.report, "structures_grounding"), "05_structures_grounding.png", errors);
  copyCapture(captureById(selected.report, "units_grounding"), "06_units_grounding.png", errors);
  copyCapture(captureById(selected.report, "ashen_combat_readability"), "07_ashen_combat_readability.png", errors);
  copyCapture(captureById(selected.report, "minimap_pan_zoom"), "08_minimap_pan_zoom.png", errors);
  const manualPaths = requiredManualPngs.map((name) => join(manualReviewRoot, name));
  for (const path of manualPaths) {
    if (!existsSync(path)) errors.push(`Missing manual-review PNG ${rel(path)}.`);
  }
  writeText(join(manualReviewRoot, "index.md"), [
    "# v0.205 Grounding Lighting Props Manual Review Pack",
    "",
    `Pack: \`${rel(manualReviewRoot)}\``,
    "",
    ...manualPaths.flatMap((path) => [`![${rel(path)}](${rel(path)})`, ""])
  ].join("\n"));
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0205_GROUNDING_LIGHTING_PROPS_CAPTURE_PACKET" : "FAIL_V0205_GROUNDING_LIGHTING_PROPS_CAPTURE_PACKET",
    baselineManifest: baseline.report ? rel(baseline.path) : "",
    selectedManifest: selected.report ? rel(selected.path) : "",
    requiredCaptureIds,
    manualReviewRoot,
    manualReviewPaths: manualPaths,
    errors
  };
  writeJson(join(root, "capture", "grounding-lighting-props-capture-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

function benchmarkCommand(root) {
  const errors = [];
  const baseline = reportAt(root, "benchmark", scenarios.baseline, "worker-art-opt-in-benchmark-runtime.json", errors);
  const selected = reportAt(root, "benchmark", scenarios.selected, "worker-art-opt-in-benchmark-runtime.json", errors);
  if (baseline.report) checkBaseline(baseline.report, `benchmark-${scenarios.baseline}`, errors);
  if (selected.report) checkSelected(selected.report, `benchmark-${scenarios.selected}`, errors);
  const baselineFps = fps(baseline.report);
  const selectedFps = fps(selected.report);
  const baselineP95 = p95(baseline.report);
  const selectedP95 = p95(selected.report);
  const fpsRatio = baselineFps > 0 ? selectedFps / baselineFps : 0;
  const p95WorseningRatio = baselineP95 > 0 ? (selectedP95 - baselineP95) / baselineP95 : 1;
  if (fpsRatio < 0.90) errors.push(`P1/B0 FPS ratio below 0.90: ${fpsRatio.toFixed(4)}.`);
  if (p95WorseningRatio > 0.15) errors.push(`P1 p95 worsening above 15%: ${(p95WorseningRatio * 100).toFixed(2)}%.`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0205_GROUNDING_LIGHTING_PROPS_BENCHMARK" : "FAIL_V0205_GROUNDING_LIGHTING_PROPS_BENCHMARK",
    baseline: { path: baseline.path ? rel(baseline.path) : "", fpsAverage: baselineFps, frameTimeP95Ms: baselineP95 },
    selected: { path: selected.path ? rel(selected.path) : "", fpsAverage: selectedFps, frameTimeP95Ms: selectedP95 },
    thresholds: { minFpsRatio: 0.90, maxP95WorseningRatio: 0.15 },
    fpsRatio,
    p95WorseningRatio,
    errors
  };
  writeJson(join(root, "benchmark", "grounding-lighting-props-benchmark-report.json"), report);
  writeText(join(root, "benchmark", "grounding-lighting-props-scorecard.md"), [
    "# v0.205 Grounding Lighting Props Benchmark",
    "",
    `Status: \`${report.status}\``,
    "",
    `B0 v0.204 FPS: \`${baselineFps}\``,
    `P1 v0.205 FPS: \`${selectedFps}\``,
    `FPS ratio: \`${fpsRatio.toFixed(4)}\``,
    `B0 v0.204 p95 ms: \`${baselineP95}\``,
    `P1 v0.205 p95 ms: \`${selectedP95}\``,
    `p95 worsening: \`${(p95WorseningRatio * 100).toFixed(2)}%\``,
    "",
    "Thresholds: P1/B0 FPS ratio >= 0.90; P1 p95 worsening <= 15%."
  ].join("\n") + "\n");
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

function boundaryCommand(root) {
  const errors = [];
  const trackedChangedFiles = execSync("git diff --name-only HEAD", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u).filter(Boolean).map((path) => path.replaceAll("\\", "/"));
  const untrackedFiles = execSync("git ls-files --others --exclude-standard", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u).filter(Boolean).map((path) => path.replaceAll("\\", "/"));
  const changedFiles = [...new Set([...trackedChangedFiles, ...untrackedFiles])];
  const defaultLauncherFiles = new Set([
    "tools/godot/launchGodotReviewWindows.ps1",
    "tools/godot/launchGodotPlayerSliceWindows.ps1",
    "tools/godot/launchGodotPrivateHarnessWindows.ps1",
    "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat"
  ]);
  const forbiddenPathPatterns = [
    /^src\//u,
    /^tests\/e2e\//u,
    /^desktop-spikes\/godot-salto\/data\/generated\//u,
    /^desktop-spikes\/godot-salto\/scripts\/adapters\//u,
    /^desktop-spikes\/godot-salto\/scripts\/salto_spike_workload_runtime\.gd$/u
  ];
  const allowedImagePatterns = [
    /^artifacts\/manual-review\/v0205-grounding-lighting-props\/0[1-8]_[a-z0-9_]+\.png$/u
  ];
  for (const file of changedFiles) {
    if (defaultLauncherFiles.has(file)) errors.push(`Default/procedural launcher changed: ${file}.`);
    if (forbiddenPathPatterns.some((pattern) => pattern.test(file))) errors.push(`Boundary-forbidden file changed: ${file}.`);
    if (/\.(png|jpg|jpeg|webp)$/iu.test(file) && !allowedImagePatterns.some((pattern) => pattern.test(file))) {
      errors.push(`Generated/imported image file changed outside v0.205 manual review scope: ${file}.`);
    }
  }
  const launchPath = join(repoRoot, "tools", "godot", "launchGodotSaltoShellV2GroundingPropsWindows.ps1");
  const launch = existsSync(launchPath) ? readFileSync(launchPath, "utf8") : "";
  if (!launch.includes("--salto-shell-v2-grounding-props")) errors.push("v0.205 launcher lacks --salto-shell-v2-grounding-props.");
  if (!launch.includes("launchGodotSaltoShellV2StructureMaterialWindows.ps1")) errors.push("v0.205 launcher does not preserve v0.204 structure-material comparator chain.");
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0205_GROUNDING_LIGHTING_PROPS_BOUNDARY_SCAN" : "FAIL_V0205_GROUNDING_LIGHTING_PROPS_BOUNDARY_SCAN",
    changedFiles,
    assertions: {
      defaultLauncherChanged: false,
      browserRuntimeChanged: false,
      gameplayPathingCollisionFilesChanged: false,
      productionRuntimeArtSlotAdded: false,
      generatedImages: 0,
      downloadedAssets: 0
    },
    errors
  };
  writeJson(join(root, "boundary", "grounding-lighting-props-boundary-scan.json"), report);
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
  console.error("Usage: node tools/godot/saltoShellV2GroundingPropsTool.mjs <validation|capture|benchmark|boundary> [--artifact-root=...]");
  process.exit(1);
}
