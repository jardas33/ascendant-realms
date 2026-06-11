import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.219";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0219");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0219-structure-shells");
const selectedSha = "94d4975f9e6f13453103439135da930b74d1d66b56d2b10e43219de408f508ef";
const requiredCaptureIds = [
  "structure_overview",
  "command_hall",
  "barracks_damaged",
  "barracks_restoring",
  "barracks_restored",
  "mine_site",
  "aether_support",
  "units_beside_structures"
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

function manifestPath(root, scenario) {
  return join(root, "capture", scenario, "screenshot-runtime-manifest.json");
}

function validationPath(root, scenario) {
  return join(root, "validation", scenario, "player-slice-validation-runtime.json");
}

function benchmarkPath(root, scenario) {
  return join(root, "benchmark", scenario, "worker-art-opt-in-benchmark-runtime.json");
}

function captureById(manifest, id) {
  return (manifest?.captures ?? []).find((capture) => capture?.id === id);
}

function captureStatus(capture) {
  return capture?.status && typeof capture.status === "object" ? capture.status : {};
}

function finalRuntimeStatus(report) {
  if (report?.saltoStructureShellProduction && typeof report.saltoStructureShellProduction === "object") {
    return report;
  }
  const steps = Array.isArray(report?.steps) ? report.steps : [];
  for (let index = steps.length - 1; index >= 0; index -= 1) {
    const status = steps[index]?.status;
    if (status && typeof status === "object") {
      return status;
    }
  }
  return report && typeof report === "object" ? report : {};
}

function averageFps(report) {
  return Number(report?.averageFps ?? report?.fps?.average ?? report?.fpsAverage ?? 0);
}

function p95FrameTimeMs(report) {
  return Number(report?.frameTimeMs?.p95 ?? report?.p95FrameTimeMs ?? report?.frameTimeP95Ms ?? 0);
}

function structureStatus(status) {
  return status?.saltoStructureShellProduction && typeof status.saltoStructureShellProduction === "object" ? status.saltoStructureShellProduction : {};
}

function materialStatus(status) {
  return status?.environmentShellV2StructureMaterial ?? status?.environmentPresentationShellV2?.structureMaterial ?? {};
}

function capturePath(manifest, id, errors) {
  const capture = captureById(manifest, id);
  const absolutePath = capture?.absolutePath ? resolve(capture.absolutePath) : "";
  if (!absolutePath || !existsSync(absolutePath)) {
    errors.push(`Missing capture '${id}'.`);
    return "";
  }
  return absolutePath;
}

function pythonCandidates() {
  const bundledPython = join(process.env.USERPROFILE || "", ".cache", "codex-runtimes", "codex-primary-runtime", "dependencies", "python", "python.exe");
  return [process.env.SALTO_CONTACT_SHEET_PYTHON, existsSync(bundledPython) ? bundledPython : null, "python"].filter(Boolean);
}

function runPython(script, payload, errors, label) {
  let lastError = null;
  for (const pythonExe of pythonCandidates()) {
    try {
      execFileSync(pythonExe, ["-c", script], {
        cwd: repoRoot,
        env: { ...process.env, SALTO_TOOL_PAYLOAD: JSON.stringify(payload) },
        stdio: ["ignore", "pipe", "pipe"]
      });
      return true;
    } catch (error) {
      lastError = error;
    }
  }
  errors.push(`${label} failed: ${lastError?.message ?? "no Python runtime available"}`);
  return false;
}

function createContactSheet(sourcePaths, outputPath, title, errors, columns = 3) {
  const existing = sourcePaths.filter((path) => path && existsSync(path));
  if (existing.length === 0) {
    errors.push(`No source images for contact sheet ${rel(outputPath)}.`);
    return;
  }
  const script = String.raw`
import json, os
from PIL import Image, ImageDraw, ImageFont
payload = json.loads(os.environ["SALTO_TOOL_PAYLOAD"])
sources = payload["sourcePaths"]
output = payload["outputPath"]
title = payload["title"]
cols = int(payload.get("columns", 3))
thumb_w = 440
thumb_h = 248
margin = 16
label_h = 28
title_h = 38
rows = max(1, (len(sources) + cols - 1) // cols)
canvas = Image.new("RGB", (cols * thumb_w + (cols + 1) * margin, rows * (thumb_h + label_h) + (rows + 1) * margin + title_h), (13, 17, 14))
draw = ImageDraw.Draw(canvas)
try:
    font = ImageFont.truetype("arial.ttf", 14)
    title_font = ImageFont.truetype("arial.ttf", 22)
except Exception:
    font = ImageFont.load_default()
    title_font = font
draw.text((margin, margin), title, fill=(228, 224, 186), font=title_font)
for index, path in enumerate(sources):
    image = Image.open(path).convert("RGB")
    image.thumbnail((thumb_w, thumb_h), Image.Resampling.LANCZOS)
    col = index % cols
    row = index // cols
    x = margin + col * (thumb_w + margin)
    y = margin + title_h + row * (thumb_h + label_h + margin)
    frame = Image.new("RGB", (thumb_w, thumb_h), (29, 36, 29))
    frame.paste(image, ((thumb_w - image.width) // 2, (thumb_h - image.height) // 2))
    canvas.paste(frame, (x, y + label_h))
    draw.text((x, y), os.path.basename(path), fill=(218, 226, 190), font=font)
os.makedirs(os.path.dirname(output), exist_ok=True)
canvas.save(output)
`;
  runPython(script, { sourcePaths: existing, outputPath, title, columns }, errors, `Contact sheet ${rel(outputPath)}`);
}

function isPass(report) {
  return typeof report?.status === "string" && report.status.startsWith("PASS");
}

function checkNoForbiddenMutation(status, label, errors) {
  for (const key of ["defaultLauncherChanged", "browserRuntimeChanged", "saveWritesAllowed", "stableIdsChanged", "gameplayPathingChanged", "collisionGeometryChanged", "objectiveLogicChanged", "aiLogicChanged", "economyChanged", "balanceChanged", "routeTopologyChanged", "structureLocationsChanged"]) {
    if (structureStatus(status)?.[key] === true || materialStatus(status)?.[key] === true || status?.[key] === true) {
      errors.push(`${label} reported forbidden ${key}.`);
    }
  }
}

function validateStructureStatus(status, expectation, label, errors) {
  const structure = structureStatus(status);
  const material = materialStatus(status);
  checkNoForbiddenMutation(status, label, errors);
  if (expectation.kind === "default") {
    if (status.saltoPresentationRebootEnabled === true) errors.push(`${label} default launcher unexpectedly enabled presentation reboot.`);
    if (status.saltoStructureShellProductionEnabled === true) errors.push(`${label} default launcher unexpectedly enabled v0.219 structure shell.`);
    return;
  }
  if (status.saltoPresentationRebootEnabled !== true && structure.presentationRebootOnly !== true) errors.push(`${label} did not enable presentation reboot.`);
  if (status.saltoStructureShellProductionEnabled !== true || structure.enabled !== true) errors.push(`${label} did not enable v0.219 structure shell.`);
  if (structure.generatedImageCount !== 0 || structure.aiImageGenerated !== false || structure.downloadedAssets !== 0) errors.push(`${label} reported generated/downloaded asset usage.`);
  if (structure.newRuntimeArtSlots !== 0 || structure.newArtSlotsAdded !== 0 || structure.productionRuntimeArtSlotAdded !== false) errors.push(`${label} reported art-slot leakage.`);
  if (structure.interactionFootprintsPreserved !== true || structure.clickTargetsPreserved !== true || structure.selectionStatesPreserved !== true) errors.push(`${label} did not preserve interaction footprints/click/selection.`);
  if (structure.unitOcclusionRegression !== false || structure.markerOcclusionRegression !== false) errors.push(`${label} reported unit/marker occlusion regression.`);
  if (expectation.kind === "legacy") {
    if (structure.legacyStructureShellComparatorActive !== true) errors.push(`${label} legacy structure comparator was not active.`);
    if (structure.selectedStructureShellActive === true) errors.push(`${label} legacy comparator still reported selected structure shell.`);
    if (Number(structure.visualNodeCount ?? 0) !== 0) errors.push(`${label} legacy comparator unexpectedly recorded v0.219 nodes.`);
    return;
  }
  if (expectation.kind === "fallback") {
    if (structure.selectedStructureShellActive !== true) errors.push(`${label} fallback scenario did not keep selected shell active.`);
    if (material.sourceLoaded !== false || material.materialActive !== false || material.fallbackActive !== true) errors.push(`${label} structure material did not fail closed.`);
    if (material.fallbackClosedToPriorShellV2 !== true || material.priorShellV2PresentationPreserved !== true) errors.push(`${label} did not preserve prior shell-v2 fallback.`);
    if (!String(material.fallbackReason ?? "").includes(expectation.reason)) errors.push(`${label} fallback reason did not include '${expectation.reason}': ${material.fallbackReason ?? "missing"}.`);
    return;
  }
  if (structure.selectedStructureShellActive !== true) errors.push(`${label} selected structure shell was not active.`);
  if (structure.legacyStructureShellComparatorActive === true) errors.push(`${label} selected shell reported legacy comparator.`);
  if (structure.usesApprovedV0202StructureFinishMaterial !== true || structure.structureFinishMaterialSha256 !== selectedSha) errors.push(`${label} did not use the approved v0.202 structure finish material.`);
  for (const key of [
    "commandHallImproved",
    "barracksImproved",
    "mineSiteImproved",
    "aetherSupportImproved",
    "damagedBarracksReadable",
    "restorationProgressReadable",
    "restoredBarracksReadable",
    "activeSiteReadable",
    "inactiveSiteReadable",
    "cuboidStacksAvoided",
    "readableRoofsUsed",
    "timberFramesUsed",
    "stoneBasesUsed",
    "entrancesUsed",
    "limitedTrimUsed",
    "lumeVisualsRemainDistinct",
    "materialAppliedOnlyToSuitableStructureSurfaces",
    "materialTextureScalePlausible",
    "noGiantMaterialScaling",
    "noStretchedTexturePanels",
    "noDistractingSeamRepetition",
    "structuresGrounded",
    "foundationsMeetGroundCleanly",
    "bridgeShellPreserved",
    "visualNodeBudgetPass"
  ]) {
    if (structure[key] !== true) errors.push(`${label} structure gate ${key} was not true.`);
  }
  if (Number(structure.visualNodeCount ?? 0) < 36) errors.push(`${label} visual node count too low: ${structure.visualNodeCount ?? "missing"}.`);
  if (Number(structure.materialSurfaceCount ?? 0) < 12) errors.push(`${label} material surface count too low: ${structure.materialSurfaceCount ?? "missing"}.`);
}

function validateCaptureScenario(root, scenario, expectation) {
  const errors = [];
  const path = manifestPath(root, scenario);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}.`);
    return { errors, manifest: null };
  }
  const manifest = readJson(path);
  if (manifest.status !== "PASS_PLAYER_SLICE_CAPTURE") errors.push(`${scenario} capture status was ${manifest.status}.`);
  if (manifest.checkpoint !== checkpoint) errors.push(`${scenario} expected ${checkpoint}, received ${manifest.checkpoint}.`);
  for (const id of requiredCaptureIds) {
    const capture = captureById(manifest, id);
    if (!capture) {
      errors.push(`${scenario} missing capture ${id}.`);
      continue;
    }
    if (!existsSync(resolve(capture.absolutePath ?? ""))) errors.push(`${scenario}/${id} image missing.`);
    validateStructureStatus(captureStatus(capture), expectation, `${scenario}/${id}`, errors);
  }
  return { errors, manifest };
}

function copyManualReviewPack(root) {
  const errors = [];
  const selected = validateCaptureScenario(root, "selected-structure-shell", { kind: "selected" });
  const legacy = validateCaptureScenario(root, "legacy-structure-comparator", { kind: "legacy" });
  errors.push(...selected.errors, ...legacy.errors);
  if (!selected.manifest || !legacy.manifest) return { errors, manualPaths: [] };

  mkdirSync(manualReviewRoot, { recursive: true });
  const copies = [
    [selected.manifest, "structure_overview", "01_structure_overview.png"],
    [selected.manifest, "command_hall", "02_command_hall.png"],
    [selected.manifest, "barracks_damaged", "03_barracks_damaged.png"],
    [selected.manifest, "barracks_restoring", "04_barracks_restoring.png"],
    [selected.manifest, "barracks_restored", "05_barracks_restored.png"],
    [selected.manifest, "mine_site", "06_mine_site.png"],
    [selected.manifest, "aether_support", "07_aether_support.png"],
    [selected.manifest, "units_beside_structures", "08_units_beside_structures.png"]
  ];
  const copiedPaths = [];
  for (const [manifest, id, fileName] of copies) {
    const source = capturePath(manifest, id, errors);
    const target = join(manualReviewRoot, fileName);
    if (source) {
      copyFileSync(source, target);
      copiedPaths.push(target);
    }
  }
  const oldOverview = capturePath(legacy.manifest, "structure_overview", errors);
  createContactSheet([oldOverview, ...copiedPaths], join(manualReviewRoot, "09_old_new_contact_sheet.png"), "v0.219 structure shell old/new review", errors, 3);
  const manualPaths = [
    "01_structure_overview.png",
    "02_command_hall.png",
    "03_barracks_damaged.png",
    "04_barracks_restoring.png",
    "05_barracks_restored.png",
    "06_mine_site.png",
    "07_aether_support.png",
    "08_units_beside_structures.png",
    "09_old_new_contact_sheet.png"
  ].map((fileName) => join(manualReviewRoot, fileName));
  for (const path of manualPaths) {
    if (!existsSync(path)) errors.push(`Manual review PNG missing: ${rel(path)}.`);
  }
  return { errors, manualPaths };
}

function validateReport(root) {
  const errors = [];
  const scenarios = [
    ["default-procedural", { kind: "default" }],
    ["selected-structure-shell", { kind: "selected" }],
    ["legacy-structure-comparator", { kind: "legacy" }],
    ["missing-structure-material-fallback", { kind: "fallback", reason: "missing" }],
    ["hash-mismatch-structure-material-fallback", { kind: "fallback", reason: "hash mismatch" }]
  ];
  const summaries = [];
  for (const [scenario, expectation] of scenarios) {
    const path = validationPath(root, scenario);
    if (!existsSync(path)) {
      errors.push(`Missing ${rel(path)}.`);
      continue;
    }
    const report = readJson(path);
    if (!isPass(report)) errors.push(`${scenario} validation did not PASS: ${report.status ?? "missing"}.`);
    if (report.checkpoint !== checkpoint) errors.push(`${scenario} expected ${checkpoint}, received ${report.checkpoint}.`);
    const status = finalRuntimeStatus(report);
    validateStructureStatus(status, expectation, scenario, errors);
    summaries.push({ scenario, status: report.status, structureShell: structureStatus(status), material: materialStatus(status) });
  }
  const output = { checkpoint, schemaVersion: 1, status: errors.length === 0 ? "PASS_V0219_STRUCTURE_SHELL_VALIDATION" : "FAIL_V0219_STRUCTURE_SHELL_VALIDATION", errors, scenarios: summaries };
  writeJson(join(root, "v0219-structure-shell-validation-report.json"), output);
  return output;
}

function boundaryReport(root) {
  const errors = [];
  const launcher = readFileSync(join(repoRoot, "tools", "godot", "launchGodotSaltoPresentationRebootWindows.ps1"), "utf8");
  if (!launcher.includes("--salto-structure-shell-production")) errors.push("Presentation reboot launcher lacks v0.219 opt-in flag.");
  if (!launcher.includes(selectedSha)) errors.push("Presentation reboot launcher lacks selected v0.202 structure-finish SHA.");
  for (const [path, forbidden] of [
    ["src/main.ts", "salto-structure-shell-production"],
    ["index.html", "barrosan_structure_finish_material_v0202"],
    ["desktop-spikes/godot-salto/project.godot", "v0219"]
  ]) {
    const full = join(repoRoot, path);
    if (existsSync(full) && readFileSync(full, "utf8").includes(forbidden)) {
      errors.push(`${path} unexpectedly references ${forbidden}.`);
    }
  }
  const report = { checkpoint, schemaVersion: 1, status: errors.length === 0 ? "PASS_V0219_STRUCTURE_SHELL_BOUNDARY" : "FAIL_V0219_STRUCTURE_SHELL_BOUNDARY", errors };
  writeJson(join(root, "v0219-structure-shell-boundary-report.json"), report);
  return report;
}

function benchmarkReport(root) {
  const errors = [];
  const selectedPath = benchmarkPath(root, "selected-structure-shell");
  const legacyPath = benchmarkPath(root, "legacy-structure-comparator");
  if (!existsSync(selectedPath)) errors.push(`Missing ${rel(selectedPath)}.`);
  if (!existsSync(legacyPath)) errors.push(`Missing ${rel(legacyPath)}.`);
  const selected = existsSync(selectedPath) ? readJson(selectedPath) : null;
  const legacy = existsSync(legacyPath) ? readJson(legacyPath) : null;
  if (selected && !isPass(selected)) errors.push(`selected benchmark did not PASS: ${selected.status}.`);
  if (legacy && !isPass(legacy)) errors.push(`legacy benchmark did not PASS: ${legacy.status}.`);
  const selectedStatus = finalRuntimeStatus(selected);
  const legacyStatus = finalRuntimeStatus(legacy);
  if (selected) validateStructureStatus(selectedStatus, { kind: "selected" }, "benchmark/selected", errors);
  if (legacy) validateStructureStatus(legacyStatus, { kind: "legacy" }, "benchmark/legacy", errors);
  const selectedP95 = p95FrameTimeMs(selected);
  const legacyP95 = p95FrameTimeMs(legacy);
  const ratio = legacyP95 > 0 ? selectedP95 / legacyP95 : 999;
  if (ratio > 1.35) errors.push(`Selected p95 frame-time ratio too high: ${ratio}.`);
  const report = {
    checkpoint,
    schemaVersion: 1,
    status: errors.length === 0 ? "PASS_V0219_STRUCTURE_SHELL_BENCHMARK" : "FAIL_V0219_STRUCTURE_SHELL_BENCHMARK",
    errors,
    selected: { averageFps: averageFps(selected), p95FrameTimeMs: selectedP95, structureShell: structureStatus(selectedStatus) },
    legacy: { averageFps: averageFps(legacy), p95FrameTimeMs: legacyP95, structureShell: structureStatus(legacyStatus) },
    p95FrameTimeRatio: ratio
  };
  writeJson(join(root, "v0219-structure-shell-benchmark-report.json"), report);
  return report;
}

function captureReport(root) {
  const pack = copyManualReviewPack(root);
  const report = {
    checkpoint,
    schemaVersion: 1,
    status: pack.errors.length === 0 ? "PASS_V0219_STRUCTURE_SHELL_REVIEW_PACK" : "FAIL_V0219_STRUCTURE_SHELL_REVIEW_PACK",
    errors: pack.errors,
    manualReviewRoot,
    manualReviewPngs: pack.manualPaths.map(rel),
    generatedImageCount: 0
  };
  writeJson(join(root, "v0219-structure-shell-capture-report.json"), report);
  return report;
}

const command = process.argv[2];
const root = artifactRootFromArgs();
let report;
if (command === "capture") {
  report = captureReport(root);
} else if (command === "validation") {
  report = validateReport(root);
} else if (command === "boundary") {
  report = boundaryReport(root);
} else if (command === "benchmark") {
  report = benchmarkReport(root);
} else {
  console.error("Usage: node tools/godot/saltoStructureShellProductionTool.mjs <capture|validation|boundary|benchmark> [--artifact-root=...]");
  process.exit(2);
}

console.log(report.status);
if (report.errors?.length) {
  console.error(report.errors.join("\n"));
  process.exit(1);
}
