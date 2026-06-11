import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.215";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0215");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0215-presentation-reboot-declutter");
const rejectedBaselineManual = join(repoRoot, "artifacts", "manual-review", "v0213-full-ui-qa", "02_initial.png");
const rejectedBaselineManifest = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0213", "capture", "full-ui", "screenshot-runtime-manifest.json");

const requiredRebootCaptures = [
  { id: "initial", manualName: "02_reboot_initial.png" },
  { id: "context_expanded", manualName: "03_reboot_context_expanded.png" },
  { id: "hostile_alert", manualName: "04_reboot_hostile_alert.png" },
  { id: "tooltip_docked", manualName: "05_tooltip_docked.png" }
];

const resolutionCaptures = [
  { id: "resolution_1920x1080", label: "1920x1080" },
  { id: "resolution_1600x900", label: "1600x900" },
  { id: "resolution_1366x768", label: "1366x768" }
];

const validationScenarios = [
  { id: "default-procedural", selection: false, production: false, minimap: false, reboot: false, uiFallback: false },
  { id: "full-ui-comparator", selection: true, production: true, minimap: true, reboot: false, uiFallback: false },
  { id: "presentation-reboot", selection: true, production: true, minimap: true, reboot: true, uiFallback: false },
  { id: "procedural-fallback", selection: true, production: true, minimap: true, reboot: false, uiFallback: true }
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

function createContactSheet(sourcePaths, outputPath, title, errors) {
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
thumb_w = 500
thumb_h = 281
cols = 2
margin = 18
label_h = 28
title_h = 38
rows = max(1, (len(sources) + cols - 1) // cols)
canvas = Image.new("RGB", (cols * thumb_w + (cols + 1) * margin, rows * (thumb_h + label_h) + (rows + 1) * margin + title_h), (16, 19, 17))
draw = ImageDraw.Draw(canvas)
try:
    font = ImageFont.truetype("arial.ttf", 16)
    title_font = ImageFont.truetype("arial.ttf", 22)
except Exception:
    font = ImageFont.load_default()
    title_font = font
draw.text((margin, margin), title, fill=(226, 222, 184), font=title_font)
for index, path in enumerate(sources):
    image = Image.open(path).convert("RGB")
    image.thumbnail((thumb_w, thumb_h), Image.Resampling.LANCZOS)
    col = index % cols
    row = index // cols
    x = margin + col * (thumb_w + margin)
    y = margin + title_h + row * (thumb_h + label_h + margin)
    frame = Image.new("RGB", (thumb_w, thumb_h), (29, 35, 30))
    frame.paste(image, ((thumb_w - image.width) // 2, (thumb_h - image.height) // 2))
    canvas.paste(frame, (x, y + label_h))
    draw.text((x, y), os.path.basename(path), fill=(218, 226, 190), font=font)
os.makedirs(os.path.dirname(output), exist_ok=True)
canvas.save(output)
`;
  runPython(script, { sourcePaths: existing, outputPath, title }, errors, `Contact sheet ${rel(outputPath)}`);
}

function validateOccupancy(occupancy, errors, prefix) {
  if (!occupancy || typeof occupancy !== "object") {
    errors.push(`${prefix} missing presentation reboot occupancy budget.`);
    return;
  }
  if (occupancy.topStripWithinFivePercent !== true) errors.push(`${prefix} top strip exceeded 5 percent height budget.`);
  if (occupancy.minimapWithinBudget !== true) errors.push(`${prefix} minimap exceeded budget.`);
  if (occupancy.selectedContextWithinBudget !== true) errors.push(`${prefix} selected context exceeded budget.`);
  if (occupancy.productionDrawerWithinBudget !== true) errors.push(`${prefix} production drawer exceeded budget.`);
  if (occupancy.objectiveSummaryOneLineDefault !== true) errors.push(`${prefix} objective summary was not one-line by default.`);
  if (occupancy.eventLogCollapsed !== true) errors.push(`${prefix} event log was not collapsed.`);
  if (occupancy.tooltipDockedEdge !== true) errors.push(`${prefix} tooltip was not docked.`);
}

function validateCaptureManifest(root, scenario, options) {
  const errors = [];
  const path = manifestPath(root, scenario);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}.`);
    return { errors, manifest: null };
  }
  const manifest = readJson(path);
  if (manifest.status !== "PASS_PLAYER_SLICE_CAPTURE") errors.push(`${scenario} capture status was ${manifest.status}.`);
  if (manifest.checkpoint !== checkpoint) errors.push(`${scenario} expected ${checkpoint}, received ${manifest.checkpoint}.`);
  if (manifest.saltoSelectionCommandPanelEnabled !== options.selection) errors.push(`${scenario} selection panel expected ${options.selection}.`);
  if (manifest.saltoProductionObjectivesLogEnabled !== options.production) errors.push(`${scenario} production log expected ${options.production}.`);
  if (manifest.saltoMinimapTooltipAccessibilityEnabled !== options.minimap) errors.push(`${scenario} minimap tooltip expected ${options.minimap}.`);
  if (manifest.saltoPresentationRebootEnabled !== options.reboot) errors.push(`${scenario} reboot flag expected ${options.reboot}.`);
  if (manifest.saltoUiShellFallbackActive !== options.uiFallback) errors.push(`${scenario} UI fallback expected ${options.uiFallback}.`);
  const expected = options.reboot ? [...requiredRebootCaptures, ...resolutionCaptures] : requiredRebootCaptures;
  for (const spec of expected) {
    const capture = captureById(manifest, spec.id);
    if (!capture) {
      errors.push(`${scenario} missing capture ${spec.id}.`);
      continue;
    }
    if (!existsSync(resolve(capture.absolutePath ?? ""))) errors.push(`${scenario}/${spec.id} image missing.`);
    const status = captureStatus(capture);
    if (status.saltoPresentationRebootEnabled !== options.reboot) errors.push(`${scenario}/${spec.id} reboot flag expected ${options.reboot}.`);
    if (options.reboot) validateOccupancy(status.saltoPresentationRebootUiOccupancy, errors, `${scenario}/${spec.id}`);
  }
  if (options.reboot) validateOccupancy(manifest.saltoPresentationRebootUiOccupancy, errors, scenario);
  return { errors, manifest };
}

function rejectedBaselinePath(errors) {
  if (existsSync(rejectedBaselineManual)) return rejectedBaselineManual;
  if (existsSync(rejectedBaselineManifest)) {
    const manifest = readJson(rejectedBaselineManifest);
    const path = capturePath(manifest, "initial", errors);
    if (path) return path;
  }
  errors.push("Missing v0.214 rejected/full-HUD baseline screenshot evidence.");
  return "";
}

function writeOccupancyMarkdown(manifest, outputPath, errors) {
  const occupancy = manifest.saltoPresentationRebootUiOccupancy ?? captureStatus(captureById(manifest, "initial")).saltoPresentationRebootUiOccupancy ?? {};
  validateOccupancy(occupancy, errors, "manual review");
  const lines = [
    "# v0.215 UI Occupancy Measurements",
    "",
    `Status: ${errors.length === 0 ? "PASS" : "CHECK"}`,
    "",
    "| Surface | Measurement | Budget | Pass |",
    "| --- | ---: | ---: | --- |",
    `| Top strip height | ${occupancy.topStripHeightPx ?? "n/a"} px (${Number(occupancy.topStripHeightRatio ?? 0).toFixed(3)}) | <= 0.050 height | ${occupancy.topStripWithinFivePercent === true ? "PASS" : "FAIL"} |`,
    `| Minimap | ${occupancy.minimapWidthPx ?? "n/a"} x ${occupancy.minimapHeightPx ?? "n/a"} px | <= 16% width, <= 20% height | ${occupancy.minimapWithinBudget === true ? "PASS" : "FAIL"} |`,
    `| Selected context | ${occupancy.selectedContextWidthPx ?? "n/a"} x ${occupancy.selectedContextHeightPx ?? "n/a"} px | <= 38% width, <= 18% height | ${occupancy.selectedContextWithinBudget === true ? "PASS" : "FAIL"} |`,
    `| Production drawer | ${occupancy.productionDrawerWidthPx ?? "n/a"} x ${occupancy.productionDrawerHeightPx ?? "n/a"} px | <= 28% width, <= 20% height | ${occupancy.productionDrawerWithinBudget === true ? "PASS" : "FAIL"} |`,
    "",
    `Objective summary one-line default: ${occupancy.objectiveSummaryOneLineDefault === true ? "PASS" : "FAIL"}`,
    `Event log collapsed/toast posture: ${occupancy.eventLogCollapsed === true ? "PASS" : "FAIL"}`,
    `Tooltip docked edge posture: ${occupancy.tooltipDockedEdge === true ? "PASS" : "FAIL"}`,
    "",
    "The battlefield remains the dominant first-read surface; production expands only in active build/train/research contexts."
  ];
  writeText(outputPath, `${lines.join("\n")}\n`);
}

function copyManualReviewPack(root) {
  const errors = [];
  const { errors: rebootErrors, manifest: rebootManifest } = validateCaptureManifest(root, "presentation-reboot", { selection: true, production: true, minimap: true, reboot: true, uiFallback: false });
  const { errors: fallbackErrors } = validateCaptureManifest(root, "procedural-fallback", { selection: true, production: true, minimap: true, reboot: false, uiFallback: true });
  errors.push(...rebootErrors, ...fallbackErrors);
  if (!rebootManifest) return { errors, manualPaths: [] };
  mkdirSync(manualReviewRoot, { recursive: true });
  const manualPaths = [];
  const baseline = rejectedBaselinePath(errors);
  if (baseline) {
    const destination = join(manualReviewRoot, "01_v0214_rejected_baseline.png");
    copyFileSync(baseline, destination);
    manualPaths.push(destination);
  }
  for (const spec of requiredRebootCaptures) {
    const source = capturePath(rebootManifest, spec.id, errors);
    if (!source) continue;
    const destination = join(manualReviewRoot, spec.manualName);
    copyFileSync(source, destination);
    manualPaths.push(destination);
  }
  const contactSheet = join(manualReviewRoot, "06_before_after_contact_sheet.png");
  createContactSheet(manualPaths, contactSheet, "v0.215 rejected full HUD vs presentation reboot", errors);
  if (existsSync(contactSheet)) manualPaths.push(contactSheet);
  const occupancyMd = join(manualReviewRoot, "07_ui_occupancy_measurements.md");
  writeOccupancyMarkdown(rebootManifest, occupancyMd, errors);
  manualPaths.push(occupancyMd);
  writeJson(join(root, "v0215-presentation-reboot-review-pack.json"), {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0215_PRESENTATION_REBOOT_REVIEW_PACK" : "FAIL_V0215_PRESENTATION_REBOOT_REVIEW_PACK",
    manualReviewRoot,
    manualPaths: manualPaths.map(rel),
    generatedImages: false,
    downloadedAssets: false,
    defaultLauncherChanged: false,
    browserRuntimeChanged: false,
    errors
  });
  return { errors, manualPaths };
}

function validateRuntimeReport(root, scenario) {
  const errors = [];
  const path = validationPath(root, scenario.id);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}.`);
    return errors;
  }
  const report = readJson(path);
  if (report.status !== "PASS_PLAYER_SLICE_VALIDATION") errors.push(`${scenario.id} validation status was ${report.status}.`);
  if (report.saltoSelectionCommandPanelEnabled !== scenario.selection) errors.push(`${scenario.id} selection expected ${scenario.selection}.`);
  if (report.saltoProductionObjectivesLogEnabled !== scenario.production) errors.push(`${scenario.id} production expected ${scenario.production}.`);
  if (report.saltoMinimapTooltipAccessibilityEnabled !== scenario.minimap) errors.push(`${scenario.id} minimap expected ${scenario.minimap}.`);
  if (report.saltoPresentationRebootEnabled !== scenario.reboot) errors.push(`${scenario.id} reboot expected ${scenario.reboot}.`);
  if (report.saltoUiShellFallbackActive !== scenario.uiFallback) errors.push(`${scenario.id} UI fallback expected ${scenario.uiFallback}.`);
  if (scenario.reboot) validateOccupancy(report.saltoPresentationRebootUiOccupancy, errors, scenario.id);
  if (report.saltoAsterPortraitProductionSlotAdded !== false) errors.push(`${scenario.id} reported production slot leakage.`);
  return errors;
}

function validateBoundary(root) {
  const errors = [];
  const statusLines = execFileSync("git", ["status", "--short", "--untracked-files=all"], { cwd: repoRoot, encoding: "utf8" })
    .split(/\r?\n/u)
    .filter(Boolean);
  const changed = statusLines.map((line) => line.slice(3).replaceAll("\\", "/"));
  const allowed = [
    /^GODOT_LAUNCH_SALTO_PRESENTATION_REBOOT_EXPERIMENT_WINDOWS\.bat$/u,
    /^desktop-spikes\/godot-salto\/scripts\/salto_spike_root\.gd$/u,
    /^desktop-spikes\/godot-salto\/scripts\/salto_spike_scene_3d\.gd$/u,
    /^package\.json$/u,
    /^tools\/godot\/launchGodotSaltoPresentationRebootWindows\.ps1$/u,
    /^tools\/godot\/captureGodotSaltoPresentationRebootWindows\.ps1$/u,
    /^tools\/godot\/validateGodotSaltoPresentationRebootWindows\.ps1$/u,
    /^tools\/godot\/runGodotSaltoPresentationRebootBenchmarkWindows\.ps1$/u,
    /^tools\/godot\/saltoPresentationRebootTool\.mjs$/u,
    /^docs\/V0215_PRESENTATION_REBOOT_BASELINE\.md$/u,
    /^docs\/V0215_UI_DECLUTTER_REPORT\.md$/u,
    /^docs\/V0215_IMPLEMENTATION_REPORT\.md$/u,
    /^CHANGELOG\.md$/u,
    /^DEVELOPMENT_CHECKPOINT\.md$/u,
    /^LLM_GAME_HANDOFF\.md$/u,
    /^ROADMAP\.md$/u
  ];
  for (const path of changed) {
    if (!allowed.some((pattern) => pattern.test(path))) errors.push(`Unexpected changed path for v0.215 boundary: ${path}`);
    if (path.endsWith(".png")) errors.push(`Tracked PNG path is not allowed in v0.215 boundary: ${path}`);
    if (path.startsWith("src/")) errors.push(`Browser runtime or web app source changed unexpectedly: ${path}`);
  }
  writeJson(join(root, "boundary", "v0215-presentation-reboot-boundary.json"), {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0215_PRESENTATION_REBOOT_BOUNDARY" : "FAIL_V0215_PRESENTATION_REBOOT_BOUNDARY",
    changed,
    generatedImages: false,
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
    drawNodeCount: Number(report?.drawNodeCount ?? report?.renderedObjectProxy ?? report?.renderNodeCount ?? 0),
    uiNodeCount: Number(report?.uiNodeCount ?? report?.controlNodeCount ?? 0)
  };
}

function runBenchmarkSummary(root) {
  const scenarios = ["full-ui-comparator", "presentation-reboot", "procedural-fallback"];
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
  const comparator = rows.find((row) => row.id === "full-ui-comparator");
  const reboot = rows.find((row) => row.id === "presentation-reboot");
  const ratios = {
    rebootAverageFpsVsComparator: comparator?.averageFps ? Number((reboot.averageFps / comparator.averageFps).toFixed(3)) : 0,
    rebootP95FrameTimeVsComparator: comparator?.p95FrameTimeMs ? Number((reboot.p95FrameTimeMs / comparator.p95FrameTimeMs).toFixed(3)) : 0
  };
  if (ratios.rebootAverageFpsVsComparator && ratios.rebootAverageFpsVsComparator < 0.65) errors.push("Reboot average FPS ratio fell below 0.65 comparator threshold.");
  if (ratios.rebootP95FrameTimeVsComparator && ratios.rebootP95FrameTimeVsComparator > 1.75) errors.push("Reboot p95 frame-time ratio exceeded 1.75 comparator threshold.");
  const summary = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0215_PRESENTATION_REBOOT_BENCHMARK" : "FAIL_V0215_PRESENTATION_REBOOT_BENCHMARK",
    rows,
    ratios,
    errors
  };
  writeJson(join(root, "benchmark", "v0215-presentation-reboot-benchmark-summary.json"), summary);
  writeText(join(root, "benchmark", "v0215-presentation-reboot-benchmark-summary.md"), [
    "# v0.215 Presentation Reboot Benchmark",
    "",
    `Status: ${summary.status}`,
    "",
    "| Scenario | Average FPS | p95 frame ms | entity count | draw/node count | UI nodes |",
    "| --- | ---: | ---: | ---: | ---: | ---: |",
    ...rows.map((row) => `| ${row.id} | ${row.averageFps} | ${row.p95FrameTimeMs} | ${row.entityCount} | ${row.drawNodeCount} | ${row.uiNodeCount} |`),
    "",
    `Reboot FPS ratio vs full-HUD comparator: ${summary.ratios.rebootAverageFpsVsComparator}`,
    `Reboot p95 frame-time ratio vs full-HUD comparator: ${summary.ratios.rebootP95FrameTimeVsComparator}`,
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
    if (errors.length === 0) console.log("PASS_V0215_PRESENTATION_REBOOT_REVIEW_PACK");
  } else if (command === "validation") {
    errors = [
      ...validationScenarios.flatMap((scenario) => validateRuntimeReport(root, scenario)),
      ...validateCaptureManifest(root, "presentation-reboot", { selection: true, production: true, minimap: true, reboot: true, uiFallback: false }).errors,
      ...validateCaptureManifest(root, "procedural-fallback", { selection: true, production: true, minimap: true, reboot: false, uiFallback: true }).errors
    ];
    writeJson(join(root, "validation", "v0215-presentation-reboot-validation.json"), {
      schemaVersion: 1,
      checkpoint,
      status: errors.length === 0 ? "PASS_V0215_PRESENTATION_REBOOT_VALIDATION" : "FAIL_V0215_PRESENTATION_REBOOT_VALIDATION",
      errors
    });
    if (errors.length === 0) console.log("PASS_V0215_PRESENTATION_REBOOT_VALIDATION");
  } else if (command === "boundary") {
    errors = validateBoundary(root);
    if (errors.length === 0) console.log("PASS_V0215_PRESENTATION_REBOOT_BOUNDARY");
  } else if (command === "benchmark") {
    errors = runBenchmarkSummary(root);
    if (errors.length === 0) console.log("PASS_V0215_PRESENTATION_REBOOT_BENCHMARK");
  } else {
    errors = [`Unknown command ${command}.`];
  }
  if (errors.length > 0) {
    for (const error of errors) console.error(error);
    process.exitCode = 1;
  }
}

main();
