import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.216";
const selectedSha = "8049b692b5d89d9abf5da39a79a31d8609ceb944dcb5695af8efc8553cd1eea3";
const selectedSourceSha = "c89cd5c9382d8fa236392c4623729ffb2073c434d06d2992c887e5010429fe3f";
const previousGroundSha = "818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0216");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0216-terrain-material-production");
const selectedDerivative = join(artifactRootDefault, "local-terrain-material-slot", "barrosan_foothold_terrain_material_v0216_1024.png");
const selectedMetadata = join(artifactRootDefault, "local-terrain-material-slot", "barrosan_foothold_terrain_material_v0216_1024.metadata.json");
const sourceImage = join(artifactRootDefault, "terrain-material-source", "barrosan_foothold_terrain_material_v0216_source.png");

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
    label_root = os.path.basename(os.path.dirname(os.path.dirname(path)))
    label = os.path.join(label_root, os.path.basename(path))
    draw.text((x, y), label, fill=(218, 226, 190), font=font)
os.makedirs(os.path.dirname(output), exist_ok=True)
canvas.save(output)
`;
  runPython(script, { sourcePaths: existing, outputPath, title, columns }, errors, `Contact sheet ${rel(outputPath)}`);
}

function validateSourceWorkspace(errors) {
  for (const path of [sourceImage, selectedDerivative, selectedMetadata]) {
    if (!existsSync(path)) errors.push(`Missing v0.216 material workspace path: ${rel(path)}.`);
  }
  if (existsSync(sourceImage) && sha256(sourceImage) !== selectedSourceSha) errors.push("v0.216 source image hash mismatch.");
  if (existsSync(selectedDerivative) && sha256(selectedDerivative) !== selectedSha) errors.push("v0.216 selected derivative hash mismatch.");
  if (existsSync(selectedMetadata)) {
    const metadata = readJson(selectedMetadata);
    if (metadata.sha256 !== selectedSha) errors.push("v0.216 metadata selected SHA mismatch.");
    if (metadata.sourceSha256 !== selectedSourceSha) errors.push("v0.216 metadata source SHA mismatch.");
    if (metadata.generatedImageCountForV0216 !== 1) errors.push("v0.216 metadata did not record exactly one generated source image.");
    if (metadata.v0216MaterialId !== "barrosan_foothold_terrain_material_v0216") errors.push("v0.216 metadata material id mismatch.");
    if (metadata.presentationRebootOnly !== true) errors.push("v0.216 metadata was not presentation-reboot-only.");
    if (metadata.selected !== true) errors.push("v0.216 selected derivative metadata was not marked selected.");
  }
}

function validateGroundStatus(status, expectation, label, errors) {
  const ground = status.groundMaterialExperiment ?? {};
  if (status.saltoPresentationRebootEnabled !== true) errors.push(`${label} reboot flag was not enabled.`);
  if (status.saltoUiShellFallbackActive === true) errors.push(`${label} UI shell fallback unexpectedly active.`);
  if (expectation.kind === "selected") {
    if (ground.sourceLoaded !== true) errors.push(`${label} selected terrain material did not load.`);
    if (ground.actualSha256 !== selectedSha) errors.push(`${label} selected SHA mismatch: ${ground.actualSha256}.`);
    if (ground.v0216MaterialId !== "barrosan_foothold_terrain_material_v0216") errors.push(`${label} v0.216 material id missing.`);
    if (ground.presentationRebootOnly !== true) errors.push(`${label} material was not reboot-only.`);
    if (ground.terrainMeshCompositor !== true) errors.push(`${label} irregular terrain compositor flag missing.`);
    if (Number(ground.v0216IrregularPatchCount ?? 0) < 1) errors.push(`${label} did not record irregular ground patches.`);
    if (Number(ground.v0216EdgeTreatmentCount ?? 0) < 1) errors.push(`${label} did not record edge treatment.`);
    if (Math.abs(Number(ground.uvScale ?? 0) - 0.48) > 0.001) errors.push(`${label} UV scale was ${ground.uvScale}, expected 0.48.`);
  } else if (expectation.kind === "previous") {
    if (ground.sourceLoaded !== true) errors.push(`${label} previous ground material did not load.`);
    if (ground.actualSha256 !== previousGroundSha) errors.push(`${label} previous ground SHA mismatch: ${ground.actualSha256}.`);
    if (ground.v0216MaterialId) errors.push(`${label} unexpectedly reported v0.216 material id.`);
  } else if (expectation.kind === "fallback") {
    if (ground.sourceLoaded !== false) errors.push(`${label} fallback scenario unexpectedly loaded a material.`);
    if (ground.fallbackActive !== true) errors.push(`${label} fallback scenario did not fail closed.`);
    if (!ground.fallbackReason) errors.push(`${label} fallback reason missing.`);
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
  const required = ["terrain_overview", "normal_rts_distance", "zoomed_out_view", "pan_zoom_framing", "fallback_comparison"];
  for (const id of required) {
    const capture = captureById(manifest, id);
    if (!capture) {
      errors.push(`${scenario} missing capture ${id}.`);
      continue;
    }
    if (!existsSync(resolve(capture.absolutePath ?? ""))) errors.push(`${scenario}/${id} image missing.`);
    validateGroundStatus(captureStatus(capture), expectation, `${scenario}/${id}`, errors);
  }
  validateGroundStatus(manifest, expectation, scenario, errors);
  return { errors, manifest };
}

function copyManualReviewPack(root) {
  const errors = [];
  validateSourceWorkspace(errors);
  const selected = validateCaptureScenario(root, "selected-terrain", { kind: "selected" });
  const previous = validateCaptureScenario(root, "previous-ground-material", { kind: "previous" });
  const hashFallback = validateCaptureScenario(root, "hash-mismatch-fallback", { kind: "fallback" });
  const missingFallback = validateCaptureScenario(root, "missing-art-fallback", { kind: "fallback" });
  errors.push(...selected.errors, ...previous.errors, ...hashFallback.errors, ...missingFallback.errors);
  if (!selected.manifest || !previous.manifest || !hashFallback.manifest) return { errors, manualPaths: [] };

  mkdirSync(manualReviewRoot, { recursive: true });
  const prebuilt = [
    join(manualReviewRoot, "01_source_derivative_contact_sheet.png"),
    join(manualReviewRoot, "02_seam_diagnostic.png")
  ];
  for (const path of prebuilt) {
    if (!existsSync(path)) errors.push(`Missing required prebuilt manual review image: ${rel(path)}.`);
  }

  const beforeAfter = join(manualReviewRoot, "03_before_after_terrain_overview.png");
  createContactSheet([
    capturePath(previous.manifest, "terrain_overview", errors),
    capturePath(selected.manifest, "terrain_overview", errors)
  ], beforeAfter, "v0.216 before/after terrain material overview", errors);

  const copies = [
    ["normal_rts_distance", "04_normal_rts_distance.png"],
    ["zoomed_out_view", "05_zoomed_out_view.png"],
    ["pan_zoom_framing", "06_pan_zoom_framing.png"]
  ];
  for (const [id, fileName] of copies) {
    const source = capturePath(selected.manifest, id, errors);
    if (source) copyFileSync(source, join(manualReviewRoot, fileName));
  }

  createContactSheet([
    capturePath(selected.manifest, "fallback_comparison", errors),
    capturePath(hashFallback.manifest, "fallback_comparison", errors),
    missingFallback.manifest ? capturePath(missingFallback.manifest, "fallback_comparison", errors) : ""
  ], join(manualReviewRoot, "07_fallback_comparison.png"), "v0.216 selected terrain vs fail-closed fallback", errors);

  const manualPaths = [
    ...prebuilt,
    beforeAfter,
    join(manualReviewRoot, "04_normal_rts_distance.png"),
    join(manualReviewRoot, "05_zoomed_out_view.png"),
    join(manualReviewRoot, "06_pan_zoom_framing.png"),
    join(manualReviewRoot, "07_fallback_comparison.png")
  ];
  writeJson(join(root, "v0216-terrain-material-review-pack.json"), {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0216_TERRAIN_MATERIAL_REVIEW_PACK" : "FAIL_V0216_TERRAIN_MATERIAL_REVIEW_PACK",
    manualReviewRoot,
    manualPaths: manualPaths.map(rel),
    selectedSha256: selectedSha,
    sourceSha256: selectedSourceSha,
    generatedImageCount: 1,
    downloadedAssets: false,
    presentationRebootOnly: true,
    errors
  });
  return { errors, manualPaths };
}

function validateRuntimeScenario(root, scenario, expectation) {
  const errors = [];
  const path = validationPath(root, scenario);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}.`);
    return errors;
  }
  const report = readJson(path);
  if (report.status !== "PASS_PLAYER_SLICE_VALIDATION") errors.push(`${scenario} validation status was ${report.status}.`);
  if (scenario === "default-procedural") {
    if (report.saltoPresentationRebootEnabled === true) errors.push("default procedural validation unexpectedly enabled presentation reboot.");
    if (report.defaultLauncherChanged === true) errors.push("default procedural validation reported launcher mutation.");
    return errors;
  }
  validateGroundStatus(report, expectation, scenario, errors);
  if (report.browserRuntimeChanged === true) errors.push(`${scenario} reported browser runtime mutation.`);
  if (report.structureFinishMaterialProductionSlotAdded === true) errors.push(`${scenario} reported production slot leakage.`);
  return errors;
}

function validateBoundary(root) {
  const errors = [];
  const statusLines = execFileSync("git", ["status", "--short", "--untracked-files=all"], { cwd: repoRoot, encoding: "utf8" })
    .split(/\r?\n/u)
    .filter(Boolean);
  const changed = statusLines.map((line) => line.slice(3).replaceAll("\\", "/"));
  const allowed = [
    /^desktop-spikes\/godot-salto\/scripts\/salto_spike_root\.gd$/u,
    /^desktop-spikes\/godot-salto\/scripts\/salto_spike_scene_3d\.gd$/u,
    /^package\.json$/u,
    /^tools\/godot\/launchGodotSaltoPresentationRebootWindows\.ps1$/u,
    /^tools\/godot\/captureGodotSaltoTerrainMaterialProductionWindows\.ps1$/u,
    /^tools\/godot\/validateGodotSaltoTerrainMaterialProductionWindows\.ps1$/u,
    /^tools\/godot\/runGodotSaltoTerrainMaterialProductionBenchmarkWindows\.ps1$/u,
    /^tools\/godot\/saltoTerrainMaterialProductionTool\.mjs$/u,
    /^docs\/V0216_TERRAIN_MATERIAL_INTAKE_REPORT\.md$/u,
    /^docs\/V0216_TERRAIN_COMPOSITOR_REPORT\.md$/u,
    /^docs\/V0216_IMPLEMENTATION_REPORT\.md$/u,
    /^CHANGELOG\.md$/u,
    /^DEVELOPMENT_CHECKPOINT\.md$/u,
    /^LLM_GAME_HANDOFF\.md$/u,
    /^ROADMAP\.md$/u
  ];
  for (const path of changed) {
    if (!allowed.some((pattern) => pattern.test(path))) errors.push(`Unexpected changed path for v0.216 boundary: ${path}`);
    if (path.endsWith(".png")) errors.push(`Tracked PNG path is not allowed in v0.216 boundary: ${path}`);
    if (path.startsWith("src/")) errors.push(`Browser runtime or web app source changed unexpectedly: ${path}`);
  }
  writeJson(join(root, "boundary", "v0216-terrain-material-boundary.json"), {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0216_TERRAIN_MATERIAL_BOUNDARY" : "FAIL_V0216_TERRAIN_MATERIAL_BOUNDARY",
    changed,
    generatedImageCount: 1,
    downloadedAssets: false,
    defaultLauncherChanged: false,
    browserRuntimeChanged: false,
    errors
  });
  return errors;
}

function benchmarkMetrics(report) {
  return {
    averageFps: Number(report?.averageFps ?? report?.fpsAverage ?? report?.meanFps ?? 0),
    p95FrameTimeMs: Number(report?.p95FrameTimeMs ?? report?.frameTimeP95Ms ?? report?.p95FrameMs ?? 0),
    entityCount: Number(report?.entityCount ?? report?.entities ?? 0),
    drawNodeCount: Number(report?.drawNodeCount ?? report?.renderedObjectProxy ?? report?.renderNodeCount ?? 0)
  };
}

function runBenchmarkSummary(root) {
  const scenarios = ["selected-terrain", "previous-ground-material", "procedural-fallback"];
  const errors = [];
  const rows = [];
  for (const id of scenarios) {
    const path = benchmarkPath(root, id);
    if (!existsSync(path)) {
      errors.push(`Missing ${rel(path)}.`);
      continue;
    }
    const report = readJson(path);
    if (!String(report.status ?? "").startsWith("PASS")) errors.push(`${id} benchmark status was ${report.status}.`);
    rows.push({ id, ...benchmarkMetrics(report), path: rel(path) });
  }
  const selected = rows.find((row) => row.id === "selected-terrain");
  const previous = rows.find((row) => row.id === "previous-ground-material");
  const procedural = rows.find((row) => row.id === "procedural-fallback");
  const ratios = {
    selectedAverageFpsVsPrevious: previous?.averageFps ? Number((selected.averageFps / previous.averageFps).toFixed(3)) : 0,
    selectedP95FrameTimeVsPrevious: previous?.p95FrameTimeMs ? Number((selected.p95FrameTimeMs / previous.p95FrameTimeMs).toFixed(3)) : 0,
    selectedAverageFpsVsProcedural: procedural?.averageFps ? Number((selected.averageFps / procedural.averageFps).toFixed(3)) : 0,
    selectedP95FrameTimeVsProcedural: procedural?.p95FrameTimeMs ? Number((selected.p95FrameTimeMs / procedural.p95FrameTimeMs).toFixed(3)) : 0
  };
  if (ratios.selectedAverageFpsVsPrevious && ratios.selectedAverageFpsVsPrevious < 0.65) errors.push("Selected v0.216 average FPS ratio fell below 0.65 previous-material threshold.");
  if (ratios.selectedP95FrameTimeVsPrevious && ratios.selectedP95FrameTimeVsPrevious > 1.85) errors.push("Selected v0.216 p95 frame-time ratio exceeded 1.85 previous-material threshold.");
  const summary = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0216_TERRAIN_MATERIAL_BENCHMARK" : "FAIL_V0216_TERRAIN_MATERIAL_BENCHMARK",
    rows,
    ratios,
    errors
  };
  writeJson(join(root, "benchmark", "v0216-terrain-material-benchmark-summary.json"), summary);
  writeText(join(root, "benchmark", "v0216-terrain-material-benchmark-summary.md"), [
    "# v0.216 Terrain Material Production Benchmark",
    "",
    `Status: ${summary.status}`,
    "",
    "| Scenario | Average FPS | p95 frame ms | entity count | draw/node count |",
    "| --- | ---: | ---: | ---: | ---: |",
    ...rows.map((row) => `| ${row.id} | ${row.averageFps} | ${row.p95FrameTimeMs} | ${row.entityCount} | ${row.drawNodeCount} |`),
    "",
    `Selected FPS ratio vs previous ground material: ${ratios.selectedAverageFpsVsPrevious}`,
    `Selected p95 frame-time ratio vs previous ground material: ${ratios.selectedP95FrameTimeVsPrevious}`,
    `Selected FPS ratio vs procedural fallback: ${ratios.selectedAverageFpsVsProcedural}`,
    `Selected p95 frame-time ratio vs procedural fallback: ${ratios.selectedP95FrameTimeVsProcedural}`,
    ...(errors.length ? ["", "Errors:", ...errors.map((error) => `- ${error}`)] : [])
  ].join("\n") + "\n");
  return errors;
}

function main() {
  const root = artifactRootFromArgs();
  const command = process.argv[2] ?? "capture";
  let errors = [];
  if (command === "capture") {
    errors = copyManualReviewPack(root).errors;
    if (errors.length === 0) console.log("PASS_V0216_TERRAIN_MATERIAL_REVIEW_PACK");
  } else if (command === "validation") {
    validateSourceWorkspace(errors);
    errors.push(
      ...validateRuntimeScenario(root, "default-procedural", { kind: "procedural" }),
      ...validateRuntimeScenario(root, "selected-terrain", { kind: "selected" }),
      ...validateRuntimeScenario(root, "previous-ground-material", { kind: "previous" }),
      ...validateRuntimeScenario(root, "hash-mismatch-fallback", { kind: "fallback" }),
      ...validateRuntimeScenario(root, "missing-art-fallback", { kind: "fallback" }),
      ...validateCaptureScenario(root, "selected-terrain", { kind: "selected" }).errors,
      ...validateCaptureScenario(root, "hash-mismatch-fallback", { kind: "fallback" }).errors,
      ...validateCaptureScenario(root, "missing-art-fallback", { kind: "fallback" }).errors
    );
    writeJson(join(root, "validation", "v0216-terrain-material-validation.json"), {
      schemaVersion: 1,
      checkpoint,
      status: errors.length === 0 ? "PASS_V0216_TERRAIN_MATERIAL_VALIDATION" : "FAIL_V0216_TERRAIN_MATERIAL_VALIDATION",
      selectedSha256: selectedSha,
      generatedImageCount: 1,
      presentationRebootOnly: true,
      errors
    });
    if (errors.length === 0) console.log("PASS_V0216_TERRAIN_MATERIAL_VALIDATION");
  } else if (command === "boundary") {
    errors = validateBoundary(root);
    if (errors.length === 0) console.log("PASS_V0216_TERRAIN_MATERIAL_BOUNDARY");
  } else if (command === "benchmark") {
    errors = runBenchmarkSummary(root);
    if (errors.length === 0) console.log("PASS_V0216_TERRAIN_MATERIAL_BENCHMARK");
  } else {
    errors = [`Unknown command ${command}.`];
  }
  if (errors.length > 0) {
    for (const error of errors) console.error(error);
    process.exitCode = 1;
  }
}

main();
