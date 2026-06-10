import { createHash } from "node:crypto";
import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync, execSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.204";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0204");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0204-structure-shell-material");
const selectedSource = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0202", "local-structure-finish-material-slot", "barrosan_structure_finish_material_v0202_1024.png");
const selectedMetadata = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0202", "local-structure-finish-material-slot", "barrosan_structure_finish_material_v0202_1024.metadata.json");
const selectedSha = "94d4975f9e6f13453103439135da930b74d1d66b56d2b10e43219de408f508ef";
const selectedApproach = "STRUCTURE_FINISH_MATERIAL_LOCAL_1024";
const scenarios = {
  default: "default-procedural",
  baseline: "b0-shell-v2-environmental-cohesion",
  selected: "m1-shell-v2-structure-material",
  missing: "f1-missing-structure-material-fallback",
  mismatch: "f2-hash-mismatch-structure-material-fallback"
};

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

function sha256File(path) {
  return createHash("sha256").update(readFileSync(path)).digest("hex");
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

function structureMaterial(report) {
  return report?.environmentShellV2StructureMaterial ?? shell(report)?.structureMaterial ?? {};
}

function materialExperiment(report) {
  return report?.structureFinishMaterialExperiment ?? structureMaterial(report)?.structureFinishMaterialExperiment ?? {};
}

function checkMaterialIdentity(errors) {
  if (!existsSync(selectedSource)) errors.push(`Missing selected source ${rel(selectedSource)}.`);
  if (!existsSync(selectedMetadata)) errors.push(`Missing selected metadata ${rel(selectedMetadata)}.`);
  if (!existsSync(selectedSource) || !existsSync(selectedMetadata)) return null;
  const metadata = readJson(selectedMetadata);
  const actualSha = sha256File(selectedSource);
  if (actualSha !== selectedSha) errors.push(`Selected source hash mismatch: ${actualSha}.`);
  if (metadata.sha256 !== selectedSha) errors.push(`Selected metadata hash mismatch: ${metadata.sha256}.`);
  if (metadata.approach !== selectedApproach) errors.push(`Selected metadata approach mismatch: ${metadata.approach}.`);
  if (metadata.privateComparatorOnly !== true) errors.push("Selected metadata is not privateComparatorOnly.");
  if (metadata.playerSliceIntegration !== "forbidden") errors.push("Selected metadata does not forbid player-slice integration.");
  if (metadata.productionApproval !== "forbidden") errors.push("Selected metadata does not forbid production approval.");
  if (metadata.browserIntegration !== "forbidden") errors.push("Selected metadata does not forbid browser integration.");
  if (metadata.runtimeArtSlotAdded !== false) errors.push("Selected metadata reports a runtime art slot.");
  const dims = metadata.dimensions ?? {};
  if (dims.width !== 1024 || dims.height !== 1024) errors.push(`Selected metadata dimensions mismatch: ${JSON.stringify(dims)}.`);
  return { path: rel(selectedSource), metadataPath: rel(selectedMetadata), sha256: actualSha, metadata };
}

function checkNoForbiddenRuntimeMutation(report, id, errors) {
  for (const key of ["browserRuntimeChanged", "saveWritesAllowed", "stableIdsChanged"]) {
    if (report?.[key] === true) errors.push(`${id} reported forbidden ${key}.`);
  }
  for (const status of [report?.environmentPresentationShellV2, report?.environmentShellV2MeshCompositor, report?.environmentShellV2StructureMaterial]) {
    for (const key of ["gameplayPathingChanged", "collisionGeometryChanged", "objectiveLogicChanged", "aiLogicChanged", "navigationSemanticsChanged"]) {
      if (status?.[key] === true) errors.push(`${id} reported forbidden ${key}.`);
    }
  }
}

function checkDefault(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}.`);
  if (report?.environmentPresentationShellV2Enabled === true) errors.push(`${id} unexpectedly enabled shell v2.`);
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
  if (report?.environmentShellV2EnvironmentalCohesionEnabled !== true) errors.push(`${id} did not enable v0.203 environmental cohesion.`);
  if (report?.environmentShellV2StructureMaterialEnabled === true) errors.push(`${id} unexpectedly enabled v0.204 structure material.`);
  if (materialExperiment(report).sourceLoaded === true) errors.push(`${id} loaded the v0.202 structure-finish material.`);
}

function checkSelected(report, id, errors) {
  checkSharedOptInContext(report, id, errors);
  const material = structureMaterial(report);
  const experiment = materialExperiment(report);
  if (report?.environmentShellV2StructureMaterialEnabled !== true || material.enabled !== true) errors.push(`${id} did not enable the v0.204 structure-material shell.`);
  if (material.environmentalCohesionEnabled !== true) errors.push(`${id} did not preserve v0.203 environmental cohesion.`);
  if (material.privateComparatorOnly !== true || experiment.privateComparatorOnly !== true) errors.push(`${id} did not preserve private-comparator provenance.`);
  if (material.expectedSha256 !== selectedSha || material.actualSha256 !== selectedSha || experiment.actualSha256 !== selectedSha) errors.push(`${id} structure material SHA mismatch.`);
  if (experiment.approach !== selectedApproach) errors.push(`${id} structure material approach mismatch.`);
  if (material.sourceLoaded !== true || material.materialActive !== true || material.fallbackActive === true) errors.push(`${id} structure material was not active without fallback.`);
  if (material.runtimeArtSlotAdded !== false || report?.structureFinishMaterialRuntimeSlotAdded !== false) errors.push(`${id} reported production/runtime-slot leakage.`);
  if (Number(material.appliedSurfaceCount ?? 0) < 12) errors.push(`${id} applied too few structure material surfaces: ${material.appliedSurfaceCount ?? "missing"}.`);
  for (const key of [
    "appliedOnlyToShellV2StructureSurfaces",
    "commandHallMaterialBound",
    "mineMaterialBound",
    "barracksMaterialBound",
    "commandHallDistinguishable",
    "mineDistinguishable",
    "barracksRestoringReadable",
    "barracksRestoredReadable",
    "lumeVisualsRemainDistinct",
    "textureScalePlausibleAtRtsDistance",
    "noGiantMaterialScaling",
    "noStretchedTexturePanels",
    "noDistractingSeamRepetition",
    "structuresGrounded",
    "foundationsMeetGroundCleanly"
  ]) {
    if (material[key] !== true) errors.push(`${id} material gate ${key} was not true.`);
  }
  if (material.unitOcclusionRegression !== false || material.markerOcclusionRegression !== false) errors.push(`${id} reported unit/marker occlusion regression.`);
}

function checkFallback(report, id, expectedReason, errors) {
  checkSharedOptInContext(report, id, errors);
  const material = structureMaterial(report);
  if (report?.environmentShellV2StructureMaterialEnabled !== true || material.enabled !== true) errors.push(`${id} did not keep the opt-in shell active for fallback proof.`);
  if (material.sourceLoaded !== false || material.materialActive !== false || material.fallbackActive !== true) errors.push(`${id} did not fail closed to fallback.`);
  if (material.fallbackClosedToPriorShellV2 !== true || material.priorShellV2PresentationPreserved !== true) errors.push(`${id} did not preserve prior shell-v2 fallback.`);
  if (!String(material.fallbackReason ?? "").includes(expectedReason)) errors.push(`${id} fallback reason did not include '${expectedReason}': ${material.fallbackReason ?? "missing"}.`);
  if (Number(material.appliedSurfaceCount ?? 99) !== 0) errors.push(`${id} applied material surfaces during fallback.`);
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
    structureMaterial: structureMaterial(report),
    structureFinishMaterialExperiment: materialExperiment(report)
  };
}

function validationCommand(root) {
  const errors = [];
  const identity = checkMaterialIdentity(errors);
  const configs = [
    { id: scenarios.default, check: checkDefault },
    { id: scenarios.baseline, check: checkBaseline },
    { id: scenarios.selected, check: checkSelected },
    { id: scenarios.missing, check: (report, id, innerErrors) => checkFallback(report, id, "missing source file", innerErrors) },
    { id: scenarios.mismatch, check: (report, id, innerErrors) => checkFallback(report, id, "metadata hash mismatch", innerErrors) }
  ];
  const summaries = configs.map((config) => {
    const loaded = reportAt(root, "validation", config.id, "player-slice-validation-runtime.json", errors);
    if (loaded.report) config.check(loaded.report, config.id, errors);
    return scenarioSummary(config.id, loaded);
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0204_STRUCTURE_SHELL_MATERIAL_VALIDATION" : "FAIL_V0204_STRUCTURE_SHELL_MATERIAL_VALIDATION",
    selectedMaterial: identity,
    scenarios: summaries,
    errors
  };
  writeJson(join(root, "validation", "structure-shell-material-validation-report.json"), report);
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
canvas = Image.new("RGB", (cols * thumb_w + (cols + 1) * margin, rows * (thumb_h + label_h) + (rows + 1) * margin), (22, 26, 20))
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
    frame = Image.new("RGB", (thumb_w, thumb_h), (35, 39, 30))
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
  const missing = reportAt(root, "capture", scenarios.missing, "screenshot-runtime-manifest.json", errors);
  const mismatch = reportAt(root, "capture", scenarios.mismatch, "screenshot-runtime-manifest.json", errors);
  if (baseline.report) checkBaseline(baseline.report, scenarios.baseline, errors);
  if (selected.report) checkSelected(selected.report, scenarios.selected, errors);
  if (missing.report) checkFallback(missing.report, scenarios.missing, "missing source file", errors);
  if (mismatch.report) checkFallback(mismatch.report, scenarios.mismatch, "metadata hash mismatch", errors);
  const beforeOverview = captureById(baseline.report, "overview")?.absolutePath ? resolve(captureById(baseline.report, "overview").absolutePath) : null;
  const selectedOverview = captureById(selected.report, "overview");
  const selectedOverviewPath = selectedOverview?.absolutePath ? resolve(selectedOverview.absolutePath) : null;
  const commandHall = copyCapture(captureById(selected.report, "command_hall"), "03_command_hall.png", errors);
  const mine = copyCapture(captureById(selected.report, "mine"), "04_mine.png", errors);
  const barracksRestoring = copyCapture(captureById(selected.report, "barracks_restoring"), "05_barracks_restoring.png", errors);
  const barracksRestored = copyCapture(captureById(selected.report, "barracks_restored"), "06_barracks_restored.png", errors);
  const overview = copyCapture(selectedOverview, "02_overview.png", errors);
  if (beforeOverview && selectedOverviewPath) {
    createContactSheet([beforeOverview, selectedOverviewPath], join(manualReviewRoot, "01_before_after_structures.png"), errors);
  } else {
    errors.push("Missing baseline/selected overview for before-after sheet.");
  }
  if (commandHall && mine && barracksRestored) {
    createContactSheet([commandHall, mine, barracksRestoring ?? barracksRestored, barracksRestored], join(manualReviewRoot, "07_material_scale_seam_diagnostic.png"), errors);
  }
  const missingOverview = captureById(missing.report, "overview")?.absolutePath ? resolve(captureById(missing.report, "overview").absolutePath) : null;
  const mismatchOverview = captureById(mismatch.report, "overview")?.absolutePath ? resolve(captureById(mismatch.report, "overview").absolutePath) : null;
  if (missingOverview && mismatchOverview) {
    createContactSheet([missingOverview, mismatchOverview], join(manualReviewRoot, "08_missing_hash_mismatch_fallback.png"), errors);
  } else {
    errors.push("Missing fallback overview captures.");
  }
  const required = [
    "01_before_after_structures.png",
    "02_overview.png",
    "03_command_hall.png",
    "04_mine.png",
    "05_barracks_restoring.png",
    "06_barracks_restored.png",
    "07_material_scale_seam_diagnostic.png",
    "08_missing_hash_mismatch_fallback.png"
  ].map((name) => join(manualReviewRoot, name));
  for (const path of required) {
    if (!existsSync(path)) errors.push(`Missing manual-review PNG ${rel(path)}.`);
  }
  writeText(join(manualReviewRoot, "index.md"), [
    "# v0.204 Structure Shell Material Manual Review Pack",
    "",
    `Pack: \`${rel(manualReviewRoot)}\``,
    "",
    ...required.flatMap((path) => [`![${rel(path)}](${rel(path)})`, ""])
  ].join("\n"));
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0204_STRUCTURE_SHELL_MATERIAL_CAPTURE_PACKET" : "FAIL_V0204_STRUCTURE_SHELL_MATERIAL_CAPTURE_PACKET",
    baselineManifest: baseline.report ? rel(baseline.path) : "",
    selectedManifest: selected.report ? rel(selected.path) : "",
    missingFallbackManifest: missing.report ? rel(missing.path) : "",
    mismatchFallbackManifest: mismatch.report ? rel(mismatch.path) : "",
    manualReviewRoot,
    manualReviewPaths: required,
    errors
  };
  writeJson(join(root, "capture", "structure-shell-material-capture-report.json"), report);
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
    /^artifacts\/manual-review\/v0204-structure-shell-material\/0[1-8]_[a-z0-9_]+\.png$/u
  ];
  for (const file of changedFiles) {
    if (defaultLauncherFiles.has(file)) errors.push(`Default/procedural launcher changed: ${file}.`);
    if (forbiddenPathPatterns.some((pattern) => pattern.test(file))) errors.push(`Boundary-forbidden file changed: ${file}.`);
    if (/\.(png|jpg|jpeg|webp)$/iu.test(file) && !allowedImagePatterns.some((pattern) => pattern.test(file))) {
      errors.push(`Generated/imported image file changed outside v0.204 manual review scope: ${file}.`);
    }
  }
  const launchPath = join(repoRoot, "tools", "godot", "launchGodotSaltoShellV2StructureMaterialWindows.ps1");
  const launch = existsSync(launchPath) ? readFileSync(launchPath, "utf8") : "";
  if (!launch.includes("--salto-shell-v2-structure-material")) errors.push("v0.204 launcher lacks --salto-shell-v2-structure-material.");
  if (!launch.includes("--structure-finish-material-opt-in")) errors.push("v0.204 launcher lacks --structure-finish-material-opt-in.");
  if (!launch.includes(selectedSha)) errors.push("v0.204 launcher lacks exact selected v0.202 SHA.");
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0204_STRUCTURE_SHELL_MATERIAL_BOUNDARY_SCAN" : "FAIL_V0204_STRUCTURE_SHELL_MATERIAL_BOUNDARY_SCAN",
    changedFiles,
    assertions: {
      defaultLauncherChanged: false,
      browserRuntimeChanged: false,
      gameplayPathingCollisionFilesChanged: false,
      productionRuntimeArtSlotAdded: false,
      selectedMaterialPrivateComparatorOnly: true
    },
    errors
  };
  writeJson(join(root, "boundary", "structure-shell-material-boundary-scan.json"), report);
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
else if (command === "boundary") boundaryCommand(root);
else if (command === "material") {
  const errors = [];
  const identity = checkMaterialIdentity(errors);
  const report = { schemaVersion: 1, checkpoint, status: errors.length === 0 ? "PASS_V0204_STRUCTURE_MATERIAL_IDENTITY" : "FAIL_V0204_STRUCTURE_MATERIAL_IDENTITY", selectedMaterial: identity, errors };
  writeJson(join(root, "validation", "structure-material-identity-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
} else {
  console.error("Usage: node tools/godot/saltoShellV2StructureMaterialTool.mjs <material|validation|capture|boundary> [--artifact-root=...]");
  process.exit(1);
}
