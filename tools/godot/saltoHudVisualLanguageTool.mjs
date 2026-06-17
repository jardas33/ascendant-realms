import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.223";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0223");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0223-hud-visual-language");

const requiredCopies = [
  ["compact_default", "01_compact_default.png"],
  ["icon_sheet", "02_icon_sheet.png"],
  ["hover_active_disabled_matrix", "03_hover_active_disabled_matrix.png"],
  ["docked_tooltip", "04_docked_tooltip.png"],
  ["build_drawer", "05_build_drawer.png"],
  ["train_drawer", "06_train_drawer.png"],
  ["hostile_alert", "07_hostile_alert.png"],
  ["keyboard_focus", "08_keyboard_focus.png"],
  ["resolution_1366x768", "09_1366x768.png"],
  ["resolution_1600x900", "10_1600x900.png"],
  ["resolution_1920x1080", "11_1920x1080.png"]
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
  const captures = Array.isArray(report?.captures) ? report.captures : [];
  for (let index = captures.length - 1; index >= 0; index -= 1) {
    const status = captures[index]?.status;
    if (status && typeof status === "object") return status;
  }
  return report && typeof report === "object" ? report : {};
}

function minimalStatus(status) {
  return status?.saltoMinimalContextualHudOccupancy && typeof status.saltoMinimalContextualHudOccupancy === "object"
    ? status.saltoMinimalContextualHudOccupancy
    : {};
}

function hudReport(status) {
  return status?.saltoHudVisualLanguageReport && typeof status.saltoHudVisualLanguageReport === "object"
    ? status.saltoHudVisualLanguageReport
    : {};
}

function averageFps(report) {
  return Number(report?.averageFps ?? report?.fpsAverage ?? report?.fps?.average ?? 0);
}

function p95FrameTimeMs(report) {
  return Number(report?.frameTimeMs?.p95 ?? report?.p95FrameTimeMs ?? report?.frameTimeP95Ms ?? 0);
}

function benchmarkPassed(report) {
  return typeof report?.status === "string" && report.status.startsWith("PASS_") && report.status.includes("BENCHMARK");
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
thumb_w = 390
thumb_h = 219
margin = 14
label_h = 24
title_h = 36
rows = max(1, (len(sources) + cols - 1) // cols)
canvas = Image.new("RGB", (cols * thumb_w + (cols + 1) * margin, rows * (thumb_h + label_h) + (rows + 1) * margin + title_h), (13, 17, 14))
draw = ImageDraw.Draw(canvas)
try:
    font = ImageFont.truetype("arial.ttf", 13)
    title_font = ImageFont.truetype("arial.ttf", 22)
except Exception:
    font = ImageFont.load_default()
    title_font = font
draw.text((margin, margin), title, fill=(228, 224, 186), font=title_font)
for index, path in enumerate(sources):
    image = Image.open(path).convert("RGB")
    image.thumbnail((thumb_w, thumb_h))
    col = index % cols
    row = index // cols
    x = margin + col * (thumb_w + margin)
    y = margin + title_h + row * (thumb_h + label_h + margin)
    frame = Image.new("RGB", (thumb_w, thumb_h), (22, 28, 23))
    frame.paste(image, ((thumb_w - image.width) // 2, (thumb_h - image.height) // 2))
    canvas.paste(frame, (x, y))
    draw.text((x, y + thumb_h + 4), os.path.basename(path), fill=(196, 207, 180), font=font)
os.makedirs(os.path.dirname(output), exist_ok=True)
canvas.save(output)
`;
  runPython(script, { sourcePaths: existing, outputPath, title, columns }, errors, `contact sheet ${rel(outputPath)}`);
}

function validateNoForbidden(status, label, errors) {
  const occupancy = minimalStatus(status);
  const report = hudReport(status);
  for (const key of ["defaultLauncherChanged", "browserRuntimeChanged", "saveWritesAllowed", "stableIdsChanged", "routeTopologyChanged", "structureLocationsChanged"]) {
    if (status?.[key] === true || occupancy?.[key] === true || report?.[key] === true) errors.push(`${label} reported forbidden ${key}.`);
  }
  if (occupancy.gameplayPathingCollisionObjectivesAiEconomySaveStableIdBalanceChanged === true || report.gameplayPathingCollisionObjectivesAiEconomySaveStableIdBalanceChanged === true) {
    errors.push(`${label} reported forbidden gameplay/pathing boundary mutation.`);
  }
  if (report.aiImagesGenerated !== false || report.downloadedAssets !== false || report.newArtSlotsAdded !== 0) {
    errors.push(`${label} reported generated art, downloaded assets, or slot leakage.`);
  }
}

function validateSelectedStatus(status, label, errors) {
  const occupancy = minimalStatus(status);
  const report = hudReport(status);
  validateNoForbidden(status, label, errors);
  if (status.saltoPresentationRebootEnabled !== true) errors.push(`${label} did not preserve presentation reboot path.`);
  if (status.saltoCompositionLightingSelectionEnabled !== true) errors.push(`${label} did not preserve selected v0.221 composition context.`);
  if (status.saltoMinimalContextualHudEnabled !== true) errors.push(`${label} did not enable v0.222 minimal HUD base.`);
  if (status.saltoHudVisualLanguageEnabled !== true || report.enabled !== true) errors.push(`${label} did not enable v0.223 HUD visual language.`);
  if (report.charcoalPanels !== true || report.restrainedTimberGraniteIronCues !== true || report.emberHostileAccent !== true) errors.push(`${label} did not report required Barrosan visual language.`);
  if (report.proceduralSvgIconsOnly !== true || report.resourceIconsPresent !== true || report.commandIconsPresent !== true || report.utilityIconsPresent !== true) errors.push(`${label} did not report required procedural icon coverage.`);
  const expectedStates = ["hover", "pressed", "active", "queued", "disabled", "insufficient", "future", "hostile", "keyboardFocus", "mouseFocus"];
  const states = new Set(Array.isArray(report.interactionStatesRepresented) ? report.interactionStatesRepresented : []);
  for (const state of expectedStates) {
    if (!states.has(state)) errors.push(`${label} missing interaction state '${state}'.`);
  }
  if (report.tooltipViewportSafe1366x768 !== true || report.tooltipDockedEdge !== true || report.centerScreenTooltip !== false) errors.push(`${label} tooltip safety gate failed.`);
  if (report.paragraphHeavyCards !== false) errors.push(`${label} reported paragraph-heavy cards.`);
  if (occupancy.defaultFixedUiAreaRatio > 0.09 || occupancy.expandedUiAreaRatio > 0.24) errors.push(`${label} exceeded v0.222 occupancy budget.`);
}

function validateBeforeStatus(status, label, errors) {
  validateNoForbidden(status, label, errors);
  if (status.saltoPresentationRebootEnabled !== true) errors.push(`${label} did not preserve presentation reboot path.`);
  if (status.saltoMinimalContextualHudEnabled !== true) errors.push(`${label} did not preserve v0.222 minimal HUD comparator.`);
  if (status.saltoHudVisualLanguageEnabled === true) errors.push(`${label} unexpectedly enabled v0.223 HUD visual language.`);
}

function runCapture(root) {
  const errors = [];
  const before = readJson(manifestPath(root, "v0222-before-hud-visual-language"));
  const selected = readJson(manifestPath(root, "selected-hud-visual-language"));
  if (before.status !== "PASS_PLAYER_SLICE_CAPTURE") errors.push("v0.222 comparator capture did not pass.");
  if (selected.status !== "PASS_PLAYER_SLICE_CAPTURE") errors.push("v0.223 selected capture did not pass.");
  validateBeforeStatus(finalRuntimeStatus(before), "v0.222 comparator capture", errors);
  validateSelectedStatus(finalRuntimeStatus(selected), "v0.223 selected capture", errors);
  mkdirSync(manualReviewRoot, { recursive: true });
  const copied = [];
  for (const [captureId, outputName] of requiredCopies) {
    const source = capturePath(selected, captureId, errors);
    if (source) {
      const output = join(manualReviewRoot, outputName);
      copyFileSync(source, output);
      copied.push(output);
    }
  }
  createContactSheet(copied, join(manualReviewRoot, "12_contact_sheet.png"), "v0.223 HUD visual language review", errors, 3);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0223_HUD_VISUAL_LANGUAGE_REVIEW_PACK" : "FAIL_V0223_HUD_VISUAL_LANGUAGE_REVIEW_PACK",
    manualReviewRoot: rel(manualReviewRoot),
    v0222ComparatorScenario: "v0222-before-hud-visual-language",
    requiredPngs: [...requiredCopies.map((entry) => entry[1]), "12_contact_sheet.png"],
    selectedHudVisualLanguageReport: hudReport(finalRuntimeStatus(selected)),
    selectedMinimalOccupancy: minimalStatus(finalRuntimeStatus(selected)),
    errors
  };
  writeJson(join(root, "v0223-hud-visual-language-capture-report.json"), report);
  if (errors.length > 0) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0223_HUD_VISUAL_LANGUAGE_REVIEW_PACK");
}

function runValidation(root) {
  const errors = [];
  const captureReport = readJson(join(root, "v0223-hud-visual-language-capture-report.json"));
  if (captureReport.status !== "PASS_V0223_HUD_VISUAL_LANGUAGE_REVIEW_PACK") errors.push("Capture report is not PASS.");
  const defaultReport = readJson(validationPath(root, "default-procedural"));
  const before = readJson(validationPath(root, "v0222-before-hud-visual-language"));
  const selected = readJson(validationPath(root, "selected-hud-visual-language"));
  for (const [label, report] of [["default procedural", defaultReport], ["v0.222 comparator", before], ["v0.223 selected", selected]]) {
    if (report.status !== "PASS_PLAYER_SLICE_VALIDATION") errors.push(`${label} validation did not pass.`);
  }
  const defaultStatus = finalRuntimeStatus(defaultReport);
  if (defaultStatus.saltoPresentationRebootEnabled === true || defaultStatus.saltoMinimalContextualHudEnabled === true || defaultStatus.saltoHudVisualLanguageEnabled === true) errors.push("Default procedural launcher unexpectedly enabled opt-in HUD paths.");
  validateBeforeStatus(finalRuntimeStatus(before), "v0.222 comparator validation", errors);
  validateSelectedStatus(finalRuntimeStatus(selected), "v0.223 selected validation", errors);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0223_HUD_VISUAL_LANGUAGE_VALIDATION" : "FAIL_V0223_HUD_VISUAL_LANGUAGE_VALIDATION",
    defaultLauncherProcedural: defaultStatus.saltoPresentationRebootEnabled !== true && defaultStatus.saltoMinimalContextualHudEnabled !== true && defaultStatus.saltoHudVisualLanguageEnabled !== true,
    priorMinimalHudComparatorPreserved: finalRuntimeStatus(before).saltoHudVisualLanguageEnabled !== true,
    selectedHudVisualLanguageReport: hudReport(finalRuntimeStatus(selected)),
    errors
  };
  writeJson(join(root, "v0223-hud-visual-language-validation-report.json"), report);
  if (errors.length > 0) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0223_HUD_VISUAL_LANGUAGE_VALIDATION");
}

function runBoundary(root) {
  const validation = readJson(join(root, "v0223-hud-visual-language-validation-report.json"));
  const errors = [];
  if (validation.status !== "PASS_V0223_HUD_VISUAL_LANGUAGE_VALIDATION") errors.push("Validation report is not PASS.");
  const statusLines = execFileSync("git", ["status", "--short", "--untracked-files=all"], { cwd: repoRoot, encoding: "utf8" })
    .split(/\r?\n/u)
    .filter(Boolean);
  const changed = statusLines.map((line) => line.slice(3).replace(/\\/gu, "/"));
  const allowed = [
    /^CHANGELOG\.md$/u,
    /^DEVELOPMENT_CHECKPOINT\.md$/u,
    /^LLM_GAME_HANDOFF\.md$/u,
    /^ROADMAP\.md$/u,
    /^package\.json$/u,
    /^desktop-spikes\/godot-salto\/scripts\/salto_spike_root\.gd$/u,
    /^docs\/V0223_HUD_VISUAL_LANGUAGE_REPORT\.md$/u,
    /^docs\/V0223_INTERACTION_QA_REPORT\.md$/u,
    /^docs\/V0223_IMPLEMENTATION_REPORT\.md$/u,
    /^tools\/godot\/captureGodotSaltoHudVisualLanguageWindows\.ps1$/u,
    /^tools\/godot\/validateGodotSaltoHudVisualLanguageWindows\.ps1$/u,
    /^tools\/godot\/runGodotSaltoHudVisualLanguageBenchmarkWindows\.ps1$/u,
    /^tools\/godot\/saltoHudVisualLanguageTool\.mjs$/u,
    /^tools\/godot\/saltoMinimalContextualHudTool\.mjs$/u,
    /^tools\/godot\/launchGodotSaltoPresentationRebootWindows\.ps1$/u
  ];
  for (const path of changed) {
    if (!allowed.some((pattern) => pattern.test(path))) errors.push(`Unexpected changed path for v0.223 boundary: ${path}`);
    if (path.endsWith(".png")) errors.push(`Tracked PNG path is not allowed in v0.223 boundary: ${path}`);
    if (path.startsWith("src/")) errors.push(`Browser runtime or web app source changed unexpectedly: ${path}`);
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0223_HUD_VISUAL_LANGUAGE_BOUNDARY" : "FAIL_V0223_HUD_VISUAL_LANGUAGE_BOUNDARY",
    changed,
    generatedImages: false,
    downloadedAssets: false,
    newArtSlots: 0,
    defaultLauncherChanged: false,
    browserRuntimeChanged: false,
    errors
  };
  writeJson(join(root, "v0223-hud-visual-language-boundary-report.json"), report);
  if (errors.length > 0) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0223_HUD_VISUAL_LANGUAGE_BOUNDARY");
}

function runBenchmark(root) {
  const before = readJson(benchmarkPath(root, "v0222-before-hud-visual-language"));
  const selected = readJson(benchmarkPath(root, "selected-hud-visual-language"));
  const beforeFps = averageFps(before);
  const selectedFps = averageFps(selected);
  const beforeP95 = p95FrameTimeMs(before);
  const selectedP95 = p95FrameTimeMs(selected);
  const errors = [];
  if (!benchmarkPassed(before) || !benchmarkPassed(selected)) errors.push("Benchmark scenario did not pass.");
  if (beforeFps <= 0 || selectedFps <= 0) errors.push("Benchmark FPS values are missing.");
  if (beforeFps > 0 && selectedFps / beforeFps < 0.70) errors.push(`Selected FPS ratio too low: ${(selectedFps / beforeFps).toFixed(3)}.`);
  if (beforeP95 > 0 && selectedP95 / beforeP95 > 1.50) errors.push(`Selected p95 frame time ratio too high: ${(selectedP95 / beforeP95).toFixed(3)}.`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0223_HUD_VISUAL_LANGUAGE_BENCHMARK" : "FAIL_V0223_HUD_VISUAL_LANGUAGE_BENCHMARK",
    scenarios: {
      before: { averageFps: beforeFps, p95FrameTimeMs: beforeP95 },
      selected: { averageFps: selectedFps, p95FrameTimeMs: selectedP95 }
    },
    averageFpsRatio: beforeFps > 0 ? Number((selectedFps / beforeFps).toFixed(4)) : null,
    p95FrameTimeRatio: beforeP95 > 0 ? Number((selectedP95 / beforeP95).toFixed(4)) : null,
    errors
  };
  writeJson(join(root, "v0223-hud-visual-language-benchmark-report.json"), report);
  if (errors.length > 0) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0223_HUD_VISUAL_LANGUAGE_BENCHMARK");
}

const command = process.argv[2];
const root = artifactRootFromArgs();
if (command === "capture") runCapture(root);
else if (command === "validation") runValidation(root);
else if (command === "boundary") runBoundary(root);
else if (command === "benchmark") runBenchmark(root);
else {
  console.error("Usage: node tools/godot/saltoHudVisualLanguageTool.mjs <capture|validation|boundary|benchmark> [--artifact-root=...]");
  process.exit(2);
}
