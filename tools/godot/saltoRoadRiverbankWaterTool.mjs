import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.217";
const sourceSha = "b697e7d307199e86b1c275912272dbc252affaa503275594e382c69ba8602358";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0217");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0217-road-riverbank-water");
const sourceImage = join(artifactRootDefault, "road-riverbank-water-material-source", "barrosan_road_riverbank_water_material_v0217_atlas_source.png");
const derivativeSummary = join(artifactRootDefault, "v0217-road-riverbank-water-derivatives.json");
const derivativeRoot = join(artifactRootDefault, "local-road-riverbank-water-material-slot");

const regions = {
  road: {
    sha256: "14de8b84468d66a582f0cf1e5fb9ee82b59ca1d37da7589c21b2673ca5417a0b",
    uvScale: 0.70,
    file: "barrosan_road_riverbank_water_material_v0217_road_1024.png"
  },
  riverbank: {
    sha256: "68b18047ae1dc501d51b57caf2cb118aa7f8b6167d887c83e0f9d5b05d5611ee",
    uvScale: 0.64,
    file: "barrosan_road_riverbank_water_material_v0217_riverbank_1024.png"
  },
  water: {
    sha256: "461e7368d4084d474ce8471ea993633dfc5651a6cfda346ab3c184cf899cfbb9",
    uvScale: 0.58,
    file: "barrosan_road_riverbank_water_material_v0217_water_1024.png"
  },
  wet_edge: {
    sha256: "c015bc67f5e9368532f0d449034f874d78da4b4e0156fbd60ec40ea6eadcc4da",
    uvScale: 0.60,
    file: "barrosan_road_riverbank_water_material_v0217_wet_edge_1024.png"
  }
};

const captureScenarios = {
  "selected-road-riverbank-water": { kind: "selected" },
  "procedural-road-riverbank-water-fallback": { kind: "fallback" },
  "hash-mismatch-fallback": { kind: "fallback" },
  "missing-art-fallback": { kind: "fallback" }
};

const requiredCaptureIds = ["road_overview", "road_junction", "river_banks", "bridge_approaches", "normal_rts_distance", "fallback_comparison"];

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

function sha256(path) {
  return createHash("sha256").update(readFileSync(path)).digest("hex");
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
  return [
    process.env.SALTO_CONTACT_SHEET_PYTHON,
    existsSync(bundledPython) ? bundledPython : null,
    "python"
  ].filter(Boolean);
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
thumb_w = 500
thumb_h = 281
margin = 18
label_h = 30
title_h = 38
rows = max(1, (len(sources) + cols - 1) // cols)
canvas = Image.new("RGB", (cols * thumb_w + (cols + 1) * margin, rows * (thumb_h + label_h) + (rows + 1) * margin + title_h), (15, 18, 15))
draw = ImageDraw.Draw(canvas)
try:
    font = ImageFont.truetype("arial.ttf", 15)
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
    frame = Image.new("RGB", (thumb_w, thumb_h), (27, 33, 27))
    frame.paste(image, ((thumb_w - image.width) // 2, (thumb_h - image.height) // 2))
    canvas.paste(frame, (x, y + label_h))
    label = os.path.basename(path)
    draw.text((x, y), label, fill=(218, 226, 190), font=font)
os.makedirs(os.path.dirname(output), exist_ok=True)
canvas.save(output)
`;
  runPython(script, { sourcePaths: existing, outputPath, title, columns }, errors, `Contact sheet ${rel(outputPath)}`);
}

function validateSourceWorkspace(errors) {
  if (!existsSync(sourceImage)) errors.push(`Missing v0.217 atlas source: ${rel(sourceImage)}.`);
  if (existsSync(sourceImage) && sha256(sourceImage) !== sourceSha) errors.push("v0.217 atlas source hash mismatch.");
  if (!existsSync(derivativeSummary)) {
    errors.push(`Missing v0.217 derivative summary: ${rel(derivativeSummary)}.`);
  } else {
    const summary = readJson(derivativeSummary);
    if (summary.status !== "PASS_V0217_DERIVATIVES_READY") errors.push(`Derivative summary status was ${summary.status}.`);
    if (summary.generatedImageCountForV0217 !== 1) errors.push("Derivative summary did not record exactly one generated image.");
    if (summary.sourceSha256 !== sourceSha) errors.push("Derivative summary source hash mismatch.");
  }
  for (const [region, spec] of Object.entries(regions)) {
    const imagePath = join(derivativeRoot, spec.file);
    const metadataPath = imagePath.replace(/\.png$/u, ".metadata.json");
    if (!existsSync(imagePath)) {
      errors.push(`Missing v0.217 ${region} derivative: ${rel(imagePath)}.`);
      continue;
    }
    if (sha256(imagePath) !== spec.sha256) errors.push(`v0.217 ${region} derivative hash mismatch.`);
    if (!existsSync(metadataPath)) {
      errors.push(`Missing v0.217 ${region} metadata: ${rel(metadataPath)}.`);
      continue;
    }
    const metadata = readJson(metadataPath);
    if (metadata.slotId !== "barrosan_road_riverbank_water_material_v0217") errors.push(`${region} metadata slot id mismatch.`);
    if (metadata.approach !== "ROAD_RIVERBANK_WATER_MATERIAL_ATLAS_LOCAL_1024") errors.push(`${region} metadata approach mismatch.`);
    if (metadata.region !== region) errors.push(`${region} metadata region mismatch.`);
    if (metadata.sourceSha256 !== sourceSha) errors.push(`${region} metadata source hash mismatch.`);
    if (metadata.sha256 !== spec.sha256) errors.push(`${region} metadata derivative hash mismatch.`);
    if (metadata.generatedImageCountForV0217 !== 1) errors.push(`${region} metadata generated image count mismatch.`);
    if (metadata.presentationRebootOnly !== true) errors.push(`${region} metadata was not presentation-reboot-only.`);
    if (metadata.runtimeArtSlotAdded !== false) errors.push(`${region} metadata unexpectedly added runtime art slot.`);
    if (metadata.productionManifestMutated !== false) errors.push(`${region} metadata unexpectedly mutated production manifest.`);
    if (metadata.dimensions?.width !== 1024 || metadata.dimensions?.height !== 1024) errors.push(`${region} metadata dimensions mismatch.`);
  }
}

function validateRoadWaterStatus(status, expectation, label, errors) {
  const material = status.roadRiverbankWaterMaterialExperiment ?? {};
  if ("saltoPresentationRebootEnabled" in status && status.saltoPresentationRebootEnabled !== true) errors.push(`${label} reboot flag was not enabled.`);
  if ("saltoUiShellFallbackActive" in status && status.saltoUiShellFallbackActive === true) errors.push(`${label} UI shell fallback unexpectedly active.`);
  if (status.roadRiverbankWaterMaterialRuntimeSlotAdded === true) errors.push(`${label} reported runtime slot addition.`);
  if (status.roadRiverbankWaterMaterialProductionSlotAdded === true) errors.push(`${label} reported production slot addition.`);
  if (expectation.kind === "selected") {
    if (material.sourceLoaded !== true) errors.push(`${label} selected v0.217 material bundle did not load.`);
    if (material.sourceAtlasSha256 !== sourceSha) errors.push(`${label} atlas source hash mismatch: ${material.sourceAtlasSha256}.`);
    if (Number(material.generatedImageCountForV0217 ?? 0) !== 1) errors.push(`${label} did not report exactly one generated v0.217 source.`);
    if (Number(material.loadedRegionCount ?? 0) !== 4) errors.push(`${label} loaded region count was ${material.loadedRegionCount}.`);
    if (Number(material.appliedSurfaceCount ?? 0) < 8) errors.push(`${label} applied too few v0.217 material surfaces.`);
    for (const [region, spec] of Object.entries(regions)) {
      const regionStatus = material.regions?.[region] ?? {};
      if (regionStatus.sourceLoaded !== true) errors.push(`${label}/${region} did not load.`);
      if (regionStatus.actualSha256 !== spec.sha256) errors.push(`${label}/${region} derivative SHA mismatch: ${regionStatus.actualSha256}.`);
      if (Math.abs(Number(regionStatus.uvScale ?? 0) - spec.uvScale) > 0.02) errors.push(`${label}/${region} UV scale was ${regionStatus.uvScale}, expected ${spec.uvScale}.`);
      if (Number(regionStatus.appliedSurfaceCount ?? 0) < 1) errors.push(`${label}/${region} did not bind to any surface.`);
    }
  } else {
    if (material.sourceLoaded !== false) errors.push(`${label} fallback scenario unexpectedly loaded the v0.217 material bundle.`);
    if (material.fallbackActive !== true) errors.push(`${label} fallback scenario did not fail closed.`);
    if (!material.fallbackReason) errors.push(`${label} fallback reason missing.`);
    if (Number(material.appliedSurfaceCount ?? 0) !== 0) errors.push(`${label} fallback scenario still reported applied v0.217 surfaces.`);
  }
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
    validateRoadWaterStatus(captureStatus(capture), expectation, `${scenario}/${id}`, errors);
  }
  validateRoadWaterStatus(manifest, expectation, scenario, errors);
  return { errors, manifest };
}

function copyManualReviewPack(root) {
  const errors = [];
  validateSourceWorkspace(errors);
  const selected = validateCaptureScenario(root, "selected-road-riverbank-water", { kind: "selected" });
  const procedural = validateCaptureScenario(root, "procedural-road-riverbank-water-fallback", { kind: "fallback" });
  const hashFallback = validateCaptureScenario(root, "hash-mismatch-fallback", { kind: "fallback" });
  const missingFallback = validateCaptureScenario(root, "missing-art-fallback", { kind: "fallback" });
  errors.push(...selected.errors, ...procedural.errors, ...hashFallback.errors, ...missingFallback.errors);
  if (!selected.manifest || !procedural.manifest || !hashFallback.manifest || !missingFallback.manifest) return { errors, manualPaths: [] };

  mkdirSync(manualReviewRoot, { recursive: true });
  for (const path of [
    join(manualReviewRoot, "01_atlas_contact_sheet.png"),
    join(manualReviewRoot, "02_seam_diagnostics.png")
  ]) {
    if (!existsSync(path)) errors.push(`Missing required prebuilt manual review image: ${rel(path)}.`);
  }

  const copies = [
    ["road_overview", "03_road_overview.png"],
    ["road_junction", "04_road_junction.png"],
    ["river_banks", "05_river_banks.png"],
    ["bridge_approaches", "06_bridge_approaches.png"]
  ];
  for (const [id, fileName] of copies) {
    const source = capturePath(selected.manifest, id, errors);
    if (source) copyFileSync(source, join(manualReviewRoot, fileName));
  }

  createContactSheet([
    capturePath(procedural.manifest, "road_overview", errors),
    capturePath(selected.manifest, "road_overview", errors)
  ], join(manualReviewRoot, "07_before_after.png"), "v0.217 before/after road riverbank water hierarchy", errors);

  createContactSheet([
    capturePath(selected.manifest, "fallback_comparison", errors),
    capturePath(hashFallback.manifest, "fallback_comparison", errors),
    capturePath(missingFallback.manifest, "fallback_comparison", errors)
  ], join(manualReviewRoot, "08_fallback.png"), "v0.217 selected versus hash/missing fallback", errors, 3);

  const manualPaths = [
    "01_atlas_contact_sheet.png",
    "02_seam_diagnostics.png",
    "03_road_overview.png",
    "04_road_junction.png",
    "05_river_banks.png",
    "06_bridge_approaches.png",
    "07_before_after.png",
    "08_fallback.png"
  ].map((file) => join(manualReviewRoot, file));
  for (const path of manualPaths) {
    if (!existsSync(path)) errors.push(`Missing manual review output ${rel(path)}.`);
  }
  return { errors, manualPaths };
}

function runCapture(root) {
  const result = copyManualReviewPack(root);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: result.errors.length === 0 ? "PASS_V0217_ROAD_RIVERBANK_WATER_REVIEW_PACK" : "FAIL_V0217_ROAD_RIVERBANK_WATER_REVIEW_PACK",
    artifactRoot: root,
    manualReviewRoot,
    manualReviewPngs: result.manualPaths.map(rel),
    errors: result.errors
  };
  writeJson(join(root, "v0217-road-riverbank-water-capture-report.json"), report);
  if (result.errors.length) {
    console.error(result.errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0217_ROAD_RIVERBANK_WATER_REVIEW_PACK");
}

function validateValidationScenario(root, scenario, expectation) {
  const errors = [];
  const path = validationPath(root, scenario);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}.`);
    return errors;
  }
  const manifest = readJson(path);
  if (manifest.status !== "PASS_PLAYER_SLICE_VALIDATION") errors.push(`${scenario} validation status was ${manifest.status}.`);
  if (manifest.checkpoint !== checkpoint) errors.push(`${scenario} validation expected ${checkpoint}, received ${manifest.checkpoint}.`);
  if (scenario === "default-procedural") {
    if (manifest.saltoPresentationRebootEnabled === true) errors.push("default-procedural unexpectedly enabled presentation reboot.");
    if (manifest.roadRiverbankWaterMaterialOptInRequested === true) errors.push("default-procedural unexpectedly requested v0.217 material bundle.");
    return errors;
  }
  validateRoadWaterStatus(manifest, expectation, `${scenario} validation`, errors);
  return errors;
}

function runValidation(root) {
  const errors = [];
  validateSourceWorkspace(errors);
  errors.push(...validateValidationScenario(root, "default-procedural", { kind: "fallback" }));
  errors.push(...validateValidationScenario(root, "selected-road-riverbank-water", { kind: "selected" }));
  errors.push(...validateValidationScenario(root, "hash-mismatch-fallback", { kind: "fallback" }));
  errors.push(...validateValidationScenario(root, "missing-art-fallback", { kind: "fallback" }));
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0217_ROAD_RIVERBANK_WATER_VALIDATION" : "FAIL_V0217_ROAD_RIVERBANK_WATER_VALIDATION",
    artifactRoot: root,
    errors
  };
  writeJson(join(root, "v0217-road-riverbank-water-validation-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0217_ROAD_RIVERBANK_WATER_VALIDATION");
}

function runBoundary(root) {
  const errors = [];
  const output = execFileSync("git", ["diff", "--name-only"], { cwd: repoRoot, encoding: "utf8" });
  const changed = output.split(/\r?\n/u).filter(Boolean);
  const allowedPrefixes = [
    "desktop-spikes/godot-salto/scripts/",
    "tools/godot/",
    "package.json",
    "docs/",
    "artifacts/manual-review/v0217-road-riverbank-water/"
  ];
  const forbidden = changed.filter((path) => !allowedPrefixes.some((prefix) => path.startsWith(prefix)));
  for (const path of forbidden) {
    if (path.startsWith("src/") || path.startsWith("public/") || path.includes("browser")) {
      errors.push(`Forbidden browser/runtime path changed: ${path}.`);
    }
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0217_ROAD_RIVERBANK_WATER_BOUNDARY" : "FAIL_V0217_ROAD_RIVERBANK_WATER_BOUNDARY",
    changedPaths: changed,
    errors
  };
  writeJson(join(root, "v0217-road-riverbank-water-boundary-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0217_ROAD_RIVERBANK_WATER_BOUNDARY");
}

function readBenchmark(root, scenario) {
  const path = benchmarkPath(root, scenario);
  return existsSync(path) ? readJson(path) : null;
}

function runBenchmark(root) {
  const errors = [];
  const selected = readBenchmark(root, "selected-road-riverbank-water");
  const fallback = readBenchmark(root, "procedural-road-riverbank-water-fallback");
  if (!selected) errors.push("Missing selected v0.217 benchmark manifest.");
  if (!fallback) errors.push("Missing procedural fallback benchmark manifest.");
  if (selected) {
    if (!String(selected.status ?? "").startsWith("PASS_")) errors.push(`Selected benchmark status was ${selected.status}.`);
    validateRoadWaterStatus(selected, { kind: "selected" }, "selected benchmark", errors);
    const material = selected.roadRiverbankWaterMaterialExperiment ?? {};
    if (Number(material.textureCreateCount ?? 0) !== 4) errors.push(`Selected benchmark texture create count was ${material.textureCreateCount}, expected 4.`);
    if (Number(material.imageDecodeCount ?? 0) !== 4) errors.push(`Selected benchmark image decode count was ${material.imageDecodeCount}, expected 4.`);
  }
  if (fallback) {
    if (!String(fallback.status ?? "").startsWith("PASS_")) errors.push(`Fallback benchmark status was ${fallback.status}.`);
    validateRoadWaterStatus(fallback, { kind: "fallback" }, "fallback benchmark", errors);
  }
  const selectedFrame = Number(selected?.frameTimeP95Ms ?? 0);
  const fallbackFrame = Number(fallback?.frameTimeP95Ms ?? 0);
  const p95Ratio = selectedFrame > 0 && fallbackFrame > 0 ? selectedFrame / fallbackFrame : null;
  if (p95Ratio !== null && p95Ratio > 1.35) errors.push(`Selected p95 frame-time ratio too high: ${p95Ratio.toFixed(3)}.`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0217_ROAD_RIVERBANK_WATER_BENCHMARK" : "FAIL_V0217_ROAD_RIVERBANK_WATER_BENCHMARK",
    selected: selected ? {
      fpsAverage: selected.fpsAverage,
      frameTimeP95Ms: selected.frameTimeP95Ms,
      roadRiverbankWaterMaterialExperiment: selected.roadRiverbankWaterMaterialExperiment
    } : null,
    fallback: fallback ? {
      fpsAverage: fallback.fpsAverage,
      frameTimeP95Ms: fallback.frameTimeP95Ms,
      roadRiverbankWaterMaterialExperiment: fallback.roadRiverbankWaterMaterialExperiment
    } : null,
    p95FrameTimeRatio: p95Ratio,
    errors
  };
  writeJson(join(root, "v0217-road-riverbank-water-benchmark-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0217_ROAD_RIVERBANK_WATER_BENCHMARK");
}

function main() {
  const command = process.argv[2] ?? "";
  const root = artifactRootFromArgs();
  if (command === "capture") return runCapture(root);
  if (command === "validation") return runValidation(root);
  if (command === "boundary") return runBoundary(root);
  if (command === "benchmark") return runBenchmark(root);
  console.error("Usage: node tools/godot/saltoRoadRiverbankWaterTool.mjs <capture|validation|boundary|benchmark> [--artifact-root=...]");
  process.exit(1);
}

main();
