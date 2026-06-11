import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.221";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0221");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0221-composition-lighting-selection");

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

function capturePath(manifest, id, errors) {
  const capture = captureById(manifest, id);
  const absolutePath = capture?.absolutePath ? resolve(capture.absolutePath) : "";
  if (!absolutePath || !existsSync(absolutePath)) {
    errors.push(`Missing capture '${id}'.`);
    return "";
  }
  return absolutePath;
}

function finalRuntimeStatus(report) {
  if (report?.status && typeof report.status === "object") return report.status;
  const steps = Array.isArray(report?.steps) ? report.steps : [];
  for (let index = steps.length - 1; index >= 0; index -= 1) {
    const status = steps[index]?.status;
    if (status && typeof status === "object") return status;
  }
  return report && typeof report === "object" ? report : {};
}

function compositionStatus(status) {
  return status?.saltoCompositionLightingSelection && typeof status.saltoCompositionLightingSelection === "object"
    ? status.saltoCompositionLightingSelection
    : {};
}

function environmentStatus(status) {
  return status?.saltoEnvironmentDressing && typeof status.saltoEnvironmentDressing === "object" ? status.saltoEnvironmentDressing : {};
}

function averageFps(report) {
  return Number(report?.averageFps ?? report?.fps?.average ?? report?.fpsAverage ?? 0);
}

function p95FrameTimeMs(report) {
  return Number(report?.frameTimeMs?.p95 ?? report?.p95FrameTimeMs ?? report?.frameTimeP95Ms ?? 0);
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

function createContactSheet(sourcePaths, outputPath, title, errors, columns = 2) {
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
cols = int(payload.get("columns", 2))
thumb_w = 520
thumb_h = 292
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

function validateNoForbidden(status, label, errors) {
  const comp = compositionStatus(status);
  for (const key of ["defaultLauncherChanged", "browserRuntimeChanged", "saveWritesAllowed", "stableIdsChanged", "gameplayPathingChanged", "collisionGeometryChanged", "objectiveLogicChanged", "aiLogicChanged", "economyChanged", "balanceChanged", "routeTopologyChanged", "structureLocationsChanged"]) {
    if (status?.[key] === true || comp?.[key] === true) errors.push(`${label} reported forbidden ${key}.`);
  }
}

function validateSelectedStatus(status, label, errors) {
  const comp = compositionStatus(status);
  const env = environmentStatus(status);
  validateNoForbidden(status, label, errors);
  if (status.saltoCompositionLightingSelectionEnabled !== true || comp.enabled !== true) errors.push(`${label} did not enable v0.221 composition lighting selection.`);
  if (status.saltoEnvironmentDressingEnabled !== true || env.enabled !== true || env.usesPropAtlasSprites !== true) errors.push(`${label} did not preserve selected v0.220 environment dressing.`);
  for (const key of [
    "compositionNodesStaySparse",
    "terrainOccupiesFrameNaturally",
    "backgroundVoidSubordinate",
    "roadsBridgeCompositionReadable",
    "riverDepthSeparationImproved",
    "structuresGroundedByValue",
    "lightingValueBalanceImproved",
    "warmCoolContrastRestrained",
    "muddyGreenWashReduced",
    "selectionRingsReduced",
    "heroRingRestrained",
    "squadSelectionRestrained",
    "hostileIndicatorDistinctNotDominant",
    "noGiantOpaqueCircles",
    "unitBillboardsNaturalScale",
    "minimapCorrelationPreserved",
    "panZoomPreserved",
    "cameraPitchCoherent",
    "cameraSafeZoom"
  ]) {
    if (comp[key] !== true) errors.push(`${label} failed ${key}.`);
  }
  if (comp.generatedImageCount !== 0 || comp.aiImageGenerated !== false || comp.downloadedAssets !== 0) errors.push(`${label} reported disallowed image generation/download.`);
  if (comp.newArtSlotsAdded !== 0 || comp.productionRuntimeArtSlotAdded !== false || comp.playerFacingProductionSlotAdded !== false) errors.push(`${label} reported art-slot leakage.`);
}

function runCapture(root) {
  const errors = [];
  const before = readJson(manifestPath(root, "v0220-before-composition"));
  const selected = readJson(manifestPath(root, "selected-composition-lighting-selection"));
  for (const [label, manifest] of [["before", before], ["selected", selected]]) {
    if (manifest.status !== "PASS_PLAYER_SLICE_CAPTURE") errors.push(`${label} capture manifest did not pass.`);
  }
  if (compositionStatus(finalRuntimeStatus(captureById(before, "initial_overview") ?? before)).enabled === true) errors.push("Before comparator enabled v0.221 composition.");
  validateSelectedStatus(finalRuntimeStatus(captureById(selected, "squad_selected") ?? selected), "selected capture", errors);

  mkdirSync(manualReviewRoot, { recursive: true });
  const copies = [
    ["initial_overview", "01_initial_overview.png"],
    ["road_bridge_composition", "02_road_bridge_composition.png"],
    ["structures_grounded", "03_structures_grounded.png"],
    ["hero_selected", "04_hero_selected.png"],
    ["squad_selected", "05_squad_selected.png"],
    ["hostile_pressure", "06_hostile_pressure.png"],
    ["pan_zoom_near", "07_pan_zoom_near.png"],
    ["pan_zoom_default", "08_pan_zoom_default.png"],
    ["pan_zoom_wide", "09_pan_zoom_wide.png"],
    ["minimap_correlation", "10_minimap_correlation.png"]
  ];
  const reviewImages = [];
  const beforeOverview = capturePath(before, "initial_overview", errors);
  const selectedOverview = capturePath(selected, "initial_overview", errors);
  for (const [captureId, fileName] of copies) {
    const source = capturePath(selected, captureId, errors);
    const target = join(manualReviewRoot, fileName);
    if (source) {
      copyFileSync(source, target);
      reviewImages.push(target);
    }
  }
  createContactSheet([beforeOverview, selectedOverview], join(manualReviewRoot, "11_before_after_contact_sheet.png"), "v0.221 before and after composition lighting selection", errors, 2);
  createContactSheet(reviewImages, join(manualReviewRoot, "12_review_contact_sheet.png"), "v0.221 composition lighting selection review pack", errors, 2);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0221_COMPOSITION_LIGHTING_SELECTION_REVIEW_PACK" : "FAIL_V0221_COMPOSITION_LIGHTING_SELECTION_REVIEW_PACK",
    manualReviewRoot: rel(manualReviewRoot),
    requiredPngs: [
      "01_initial_overview.png",
      "02_road_bridge_composition.png",
      "03_structures_grounded.png",
      "04_hero_selected.png",
      "05_squad_selected.png",
      "06_hostile_pressure.png",
      "07_pan_zoom_near.png",
      "08_pan_zoom_default.png",
      "09_pan_zoom_wide.png",
      "10_minimap_correlation.png",
      "11_before_after_contact_sheet.png"
    ],
    optionalContactSheet: "12_review_contact_sheet.png",
    errors
  };
  writeJson(join(root, "v0221-composition-lighting-selection-capture-report.json"), report);
  if (errors.length > 0) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0221_COMPOSITION_LIGHTING_SELECTION_REVIEW_PACK");
}

function runValidation(root) {
  const errors = [];
  const defaultReport = readJson(validationPath(root, "default-procedural"));
  const before = readJson(validationPath(root, "v0220-before-composition"));
  const selected = readJson(validationPath(root, "selected-composition-lighting-selection"));
  for (const [label, report] of [["default", defaultReport], ["before", before], ["selected", selected]]) {
    if (report.status !== "PASS_PLAYER_SLICE_VALIDATION") errors.push(`${label} validation did not pass.`);
  }
  if (finalRuntimeStatus(defaultReport).saltoCompositionLightingSelectionEnabled === true) errors.push("Default procedural launcher enabled v0.221 composition.");
  if (compositionStatus(finalRuntimeStatus(before)).enabled === true) errors.push("v0.220 comparator enabled v0.221 composition.");
  validateSelectedStatus(finalRuntimeStatus(selected), "selected validation", errors);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0221_COMPOSITION_LIGHTING_SELECTION_VALIDATION" : "FAIL_V0221_COMPOSITION_LIGHTING_SELECTION_VALIDATION",
    defaultLauncherProcedural: finalRuntimeStatus(defaultReport).saltoCompositionLightingSelectionEnabled !== true,
    beforeComparatorPreserved: compositionStatus(finalRuntimeStatus(before)).enabled !== true,
    errors
  };
  writeJson(join(root, "v0221-composition-lighting-selection-validation-report.json"), report);
  if (errors.length > 0) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0221_COMPOSITION_LIGHTING_SELECTION_VALIDATION");
}

function runBoundary(root) {
  const validation = readJson(join(root, "v0221-composition-lighting-selection-validation-report.json"));
  const errors = [];
  if (validation.status !== "PASS_V0221_COMPOSITION_LIGHTING_SELECTION_VALIDATION") errors.push("Validation report is not PASS.");
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0221_COMPOSITION_LIGHTING_SELECTION_BOUNDARY" : "FAIL_V0221_COMPOSITION_LIGHTING_SELECTION_BOUNDARY",
    generatedImages: 0,
    downloadedAssets: 0,
    productionRuntimeSlotsAdded: 0,
    browserRuntimeChanged: false,
    defaultLauncherChanged: false,
    gameplayPathingCollisionObjectivesAiEconomySaveStableIdBalanceChanged: false,
    errors
  };
  writeJson(join(root, "v0221-composition-lighting-selection-boundary-report.json"), report);
  if (errors.length > 0) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0221_COMPOSITION_LIGHTING_SELECTION_BOUNDARY");
}

function runBenchmark(root) {
  const errors = [];
  const before = readJson(benchmarkPath(root, "v0220-before-composition"));
  const selected = readJson(benchmarkPath(root, "selected-composition-lighting-selection"));
  if (compositionStatus(finalRuntimeStatus(before)).enabled === true) errors.push("Benchmark comparator enabled v0.221 composition.");
  validateSelectedStatus(finalRuntimeStatus(selected), "selected benchmark", errors);
  const beforeFps = averageFps(before);
  const selectedFps = averageFps(selected);
  const beforeP95 = p95FrameTimeMs(before);
  const selectedP95 = p95FrameTimeMs(selected);
  const p95Ratio = beforeP95 > 0 ? selectedP95 / beforeP95 : 0;
  if (!Number.isFinite(p95Ratio) || p95Ratio <= 0 || p95Ratio > 1.18) errors.push(`p95 frame-time ratio outside budget: ${p95Ratio}.`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0221_COMPOSITION_LIGHTING_SELECTION_BENCHMARK" : "FAIL_V0221_COMPOSITION_LIGHTING_SELECTION_BENCHMARK",
    scenarios: {
      before: { averageFps: beforeFps, p95FrameTimeMs: beforeP95 },
      selected: { averageFps: selectedFps, p95FrameTimeMs: selectedP95 }
    },
    p95FrameTimeRatio: p95Ratio,
    errors
  };
  writeJson(join(root, "v0221-composition-lighting-selection-benchmark-report.json"), report);
  if (errors.length > 0) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0221_COMPOSITION_LIGHTING_SELECTION_BENCHMARK");
}

const root = artifactRootFromArgs();
const command = process.argv[2] ?? "";
if (command === "capture") runCapture(root);
else if (command === "validation") runValidation(root);
else if (command === "boundary") runBoundary(root);
else if (command === "benchmark") runBenchmark(root);
else {
  console.error("Usage: node tools/godot/saltoCompositionLightingSelectionTool.mjs <capture|validation|boundary|benchmark> [--artifact-root=...]");
  process.exit(2);
}
