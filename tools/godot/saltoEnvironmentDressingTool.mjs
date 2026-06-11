import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.220";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0220");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0220-environment-dressing");
const selectedSha = "fa59ddb29281b12b818c065302af632d7710fd05f419d14e838cc002fc9588df";
const atlasRoot = join(artifactRootDefault, "environment-prop-atlas");
const sourceAtlas = join(atlasRoot, "barrosan_environment_prop_atlas_v0220_1024_chroma.png");
const extractionContactSheet = join(atlasRoot, "extraction_contact_sheet.png");
const metadataPath = join(atlasRoot, "barrosan_environment_prop_atlas_v0220.metadata.json");

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
  if (report?.saltoEnvironmentDressing && typeof report.saltoEnvironmentDressing === "object") return report;
  const steps = Array.isArray(report?.steps) ? report.steps : [];
  for (let index = steps.length - 1; index >= 0; index -= 1) {
    const status = steps[index]?.status;
    if (status && typeof status === "object") return status;
  }
  return report && typeof report === "object" ? report : {};
}

function environmentStatus(status) {
  return status?.saltoEnvironmentDressing && typeof status.saltoEnvironmentDressing === "object" ? status.saltoEnvironmentDressing : {};
}

function atlasStatus(status) {
  return status?.environmentPropAtlasExperiment ?? environmentStatus(status)?.propAtlasExperiment ?? {};
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
  const env = environmentStatus(status);
  for (const key of ["defaultLauncherChanged", "browserRuntimeChanged", "saveWritesAllowed", "stableIdsChanged", "gameplayPathingChanged", "collisionGeometryChanged", "objectiveLogicChanged", "aiLogicChanged", "economyChanged", "balanceChanged", "routeTopologyChanged", "structureLocationsChanged"]) {
    if (status?.[key] === true || env?.[key] === true) errors.push(`${label} reported forbidden ${key}.`);
  }
}

function validateSelectedStatus(status, label, errors) {
  const env = environmentStatus(status);
  const atlas = atlasStatus(status);
  validateNoForbidden(status, label, errors);
  if (status.saltoEnvironmentDressingEnabled !== true || env.enabled !== true) errors.push(`${label} did not enable v0.220 environment dressing.`);
  if (env.atlasSourceLoaded !== true || atlas.sourceLoaded !== true) errors.push(`${label} did not load the prop atlas.`);
  if (env.usesPropAtlasSprites !== true || Number(env.atlasSpriteCount ?? 0) < 10) errors.push(`${label} did not draw enough sparse atlas sprites.`);
  if (env.generatedImageCount !== 1 || env.downloadedAssets !== 0) errors.push(`${label} reported incorrect generation/download counts.`);
  if (env.newArtSlotsAdded !== 0 || env.productionRuntimeArtSlotAdded !== false || env.playerFacingProductionSlotAdded !== false) errors.push(`${label} reported art-slot leakage.`);
  if (String(env.atlasSourceSha256 ?? "") !== selectedSha || String(atlas.actualSha256 ?? "") !== selectedSha) errors.push(`${label} atlas hash mismatch in runtime status.`);
  if (Number(env.acceptedPropCount ?? 0) < 8 || Number(env.rejectedPropCount ?? -1) < 1) errors.push(`${label} did not report accepted/rejected extraction counts.`);
  for (const key of ["lowDensityEdgeDressing", "roadShoulderDetailsReadable", "riverbankStonesAndScrubReadable", "structureAdjacentPracticalPropsReadable", "bridgeApproachDetailsReadable", "tacticalLanesReadable", "clearUnitSilhouettes", "clearRoads", "clearBuildRestorationSites", "propsDoNotImplyCollision"]) {
    if (env[key] !== true) errors.push(`${label} failed ${key}.`);
  }
}

function validateFallbackStatus(status, label, expectedReason, errors) {
  const env = environmentStatus(status);
  const atlas = atlasStatus(status);
  validateNoForbidden(status, label, errors);
  if (status.saltoEnvironmentDressingEnabled !== true || env.enabled !== true) errors.push(`${label} did not keep the v0.220 path enabled for fallback proof.`);
  if (env.atlasSourceLoaded !== false || atlas.sourceLoaded !== false || env.atlasFallbackActive !== true || atlas.fallbackActive !== true) errors.push(`${label} did not fail closed to atlas fallback.`);
  if (env.fallbackClosedToProceduralProps !== true || Number(env.atlasSpriteCount ?? 0) !== 0) errors.push(`${label} still drew atlas sprites during fallback.`);
  if (!String(env.atlasFallbackReason ?? atlas.fallbackReason ?? "").includes(expectedReason)) errors.push(`${label} fallback reason did not include ${expectedReason}.`);
  if (env.retainsProceduralGroundingFallback !== true) errors.push(`${label} did not retain procedural grounding fallback.`);
}

function runCapture(root) {
  const errors = [];
  const selected = readJson(manifestPath(root, "selected-environment-dressing"));
  const before = readJson(manifestPath(root, "v0219-before-structure-shell"));
  const missing = readJson(manifestPath(root, "missing-prop-atlas-fallback"));
  const hashMismatch = readJson(manifestPath(root, "hash-mismatch-prop-atlas-fallback"));
  for (const [label, manifest] of [["selected", selected], ["before", before], ["missing", missing], ["hash-mismatch", hashMismatch]]) {
    if (manifest.status !== "PASS_PLAYER_SLICE_CAPTURE") errors.push(`${label} capture manifest did not pass.`);
  }
  const selectedStatus = finalRuntimeStatus(captureById(selected, "tactical_readability") ?? selected);
  validateSelectedStatus(selectedStatus, "selected capture", errors);
  validateFallbackStatus(finalRuntimeStatus(captureById(missing, "fallback") ?? missing), "missing capture", "missing source", errors);
  validateFallbackStatus(finalRuntimeStatus(captureById(hashMismatch, "fallback") ?? hashMismatch), "hash mismatch capture", "hash mismatch", errors);

  mkdirSync(manualReviewRoot, { recursive: true });
  if (!existsSync(sourceAtlas)) errors.push(`Missing source atlas ${rel(sourceAtlas)}.`);
  if (!existsSync(extractionContactSheet)) errors.push(`Missing extraction contact sheet ${rel(extractionContactSheet)}.`);
  if (!existsSync(metadataPath)) errors.push(`Missing atlas metadata ${rel(metadataPath)}.`);
  if (existsSync(sourceAtlas)) copyFileSync(sourceAtlas, join(manualReviewRoot, "01_source_atlas.png"));
  if (existsSync(extractionContactSheet)) copyFileSync(extractionContactSheet, join(manualReviewRoot, "02_extraction_contact_sheet.png"));
  const beforeOverview = capturePath(before, "before_after_overview", errors);
  const selectedOverview = capturePath(selected, "before_after_overview", errors);
  createContactSheet([beforeOverview, selectedOverview], join(manualReviewRoot, "03_before_after_overview.png"), "v0.220 before and after sparse dressing", errors, 2);
  const copies = [
    ["road_shoulders", "04_road_shoulders.png", selected],
    ["riverbanks", "05_riverbanks.png", selected],
    ["structure_adjacent_props", "06_structure_adjacent_props.png", selected],
    ["bridge_approach", "07_bridge_approach.png", selected],
    ["tactical_readability", "08_tactical_readability.png", selected],
    ["fallback", "09_fallback.png", missing]
  ];
  const reviewImages = [join(manualReviewRoot, "01_source_atlas.png"), join(manualReviewRoot, "02_extraction_contact_sheet.png"), join(manualReviewRoot, "03_before_after_overview.png")];
  for (const [captureId, fileName, manifest] of copies) {
    const source = capturePath(manifest, captureId, errors);
    const target = join(manualReviewRoot, fileName);
    if (source) {
      copyFileSync(source, target);
      reviewImages.push(target);
    }
  }
  createContactSheet(reviewImages, join(manualReviewRoot, "10_contact_sheet.png"), "v0.220 environment dressing review pack", errors, 2);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0220_ENVIRONMENT_DRESSING_REVIEW_PACK" : "FAIL_V0220_ENVIRONMENT_DRESSING_REVIEW_PACK",
    manualReviewRoot: rel(manualReviewRoot),
    requiredPngs: [
      "01_source_atlas.png",
      "02_extraction_contact_sheet.png",
      "03_before_after_overview.png",
      "04_road_shoulders.png",
      "05_riverbanks.png",
      "06_structure_adjacent_props.png",
      "07_bridge_approach.png",
      "08_tactical_readability.png",
      "09_fallback.png",
      "10_contact_sheet.png"
    ],
    sourceAtlas: rel(sourceAtlas),
    extractionContactSheet: rel(extractionContactSheet),
    errors
  };
  writeJson(join(root, "v0220-environment-dressing-capture-report.json"), report);
  if (errors.length > 0) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0220_ENVIRONMENT_DRESSING_REVIEW_PACK");
}

function runValidation(root) {
  const errors = [];
  const defaultReport = readJson(validationPath(root, "default-procedural"));
  const before = readJson(validationPath(root, "v0219-before-structure-shell"));
  const selected = readJson(validationPath(root, "selected-environment-dressing"));
  const missing = readJson(validationPath(root, "missing-prop-atlas-fallback"));
  const hashMismatch = readJson(validationPath(root, "hash-mismatch-prop-atlas-fallback"));
  for (const [label, report] of [["default", defaultReport], ["before", before], ["selected", selected], ["missing", missing], ["hash-mismatch", hashMismatch]]) {
    if (report.status !== "PASS_PLAYER_SLICE_VALIDATION") errors.push(`${label} validation did not pass.`);
  }
  if (finalRuntimeStatus(defaultReport).saltoEnvironmentDressingEnabled === true) errors.push("Default procedural launcher enabled v0.220 dressing.");
  if (finalRuntimeStatus(before).saltoEnvironmentDressingEnabled === true) errors.push("v0.219 comparator enabled v0.220 dressing.");
  validateSelectedStatus(finalRuntimeStatus(selected), "selected validation", errors);
  validateFallbackStatus(finalRuntimeStatus(missing), "missing validation", "missing source", errors);
  validateFallbackStatus(finalRuntimeStatus(hashMismatch), "hash mismatch validation", "hash mismatch", errors);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0220_ENVIRONMENT_DRESSING_VALIDATION" : "FAIL_V0220_ENVIRONMENT_DRESSING_VALIDATION",
    selectedSha256: selectedSha,
    defaultLauncherProcedural: finalRuntimeStatus(defaultReport).saltoEnvironmentDressingEnabled !== true,
    beforeComparatorPreserved: finalRuntimeStatus(before).saltoEnvironmentDressingEnabled !== true,
    errors
  };
  writeJson(join(root, "v0220-environment-dressing-validation-report.json"), report);
  if (errors.length > 0) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0220_ENVIRONMENT_DRESSING_VALIDATION");
}

function runBoundary(root) {
  const validation = readJson(join(root, "v0220-environment-dressing-validation-report.json"));
  const errors = [];
  if (validation.status !== "PASS_V0220_ENVIRONMENT_DRESSING_VALIDATION") errors.push("Validation report is not PASS.");
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0220_ENVIRONMENT_DRESSING_BOUNDARY" : "FAIL_V0220_ENVIRONMENT_DRESSING_BOUNDARY",
    generatedImages: 1,
    downloadedAssets: 0,
    productionRuntimeSlotsAdded: 0,
    browserRuntimeChanged: false,
    defaultLauncherChanged: false,
    gameplayPathingCollisionObjectivesAiEconomySaveStableIdBalanceChanged: false,
    errors
  };
  writeJson(join(root, "v0220-environment-dressing-boundary-report.json"), report);
  if (errors.length > 0) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0220_ENVIRONMENT_DRESSING_BOUNDARY");
}

function runBenchmark(root) {
  const errors = [];
  const before = readJson(benchmarkPath(root, "v0219-before-structure-shell"));
  const selected = readJson(benchmarkPath(root, "selected-environment-dressing"));
  validateSelectedStatus(finalRuntimeStatus(selected), "selected benchmark", errors);
  if (finalRuntimeStatus(before).saltoEnvironmentDressingEnabled === true) errors.push("Benchmark comparator enabled v0.220 dressing.");
  const beforeFps = averageFps(before);
  const selectedFps = averageFps(selected);
  const beforeP95 = p95FrameTimeMs(before);
  const selectedP95 = p95FrameTimeMs(selected);
  const p95Ratio = beforeP95 > 0 ? selectedP95 / beforeP95 : 0;
  if (!Number.isFinite(p95Ratio) || p95Ratio <= 0 || p95Ratio > 1.18) errors.push(`p95 frame-time ratio outside budget: ${p95Ratio}.`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0220_ENVIRONMENT_DRESSING_BENCHMARK" : "FAIL_V0220_ENVIRONMENT_DRESSING_BENCHMARK",
    scenarios: {
      before: { averageFps: beforeFps, p95FrameTimeMs: beforeP95 },
      selected: { averageFps: selectedFps, p95FrameTimeMs: selectedP95 }
    },
    p95FrameTimeRatio: p95Ratio,
    selectedAtlasSpriteCount: Number(environmentStatus(finalRuntimeStatus(selected)).atlasSpriteCount ?? 0),
    errors
  };
  writeJson(join(root, "v0220-environment-dressing-benchmark-report.json"), report);
  if (errors.length > 0) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0220_ENVIRONMENT_DRESSING_BENCHMARK");
}

const root = artifactRootFromArgs();
const command = process.argv[2] ?? "";
if (command === "capture") runCapture(root);
else if (command === "validation") runValidation(root);
else if (command === "boundary") runBoundary(root);
else if (command === "benchmark") runBenchmark(root);
else {
  console.error("Usage: node tools/godot/saltoEnvironmentDressingTool.mjs <capture|validation|boundary|benchmark> [--artifact-root=...]");
  process.exit(2);
}
