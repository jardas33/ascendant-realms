import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.222";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0222");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0222-minimal-contextual-hud");
const fullHudComparatorPath = join(repoRoot, "artifacts", "manual-review", "v0213-full-ui-qa", "02_initial.png");

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

function minimalStatus(status) {
  return status?.saltoMinimalContextualHudOccupancy && typeof status.saltoMinimalContextualHudOccupancy === "object"
    ? status.saltoMinimalContextualHudOccupancy
    : {};
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

function createOccupancyImage(occupancy, outputPath, errors) {
  const script = String.raw`
import json, os
from PIL import Image, ImageDraw, ImageFont
payload = json.loads(os.environ["SALTO_TOOL_PAYLOAD"])
occ = payload["occupancy"]
output = payload["outputPath"]
canvas = Image.new("RGB", (1000, 620), (14, 18, 15))
draw = ImageDraw.Draw(canvas)
try:
    title_font = ImageFont.truetype("arial.ttf", 28)
    font = ImageFont.truetype("arial.ttf", 17)
    small = ImageFont.truetype("arial.ttf", 14)
except Exception:
    title_font = ImageFont.load_default()
    font = title_font
    small = title_font
draw.text((34, 28), "v0.222 minimal contextual HUD occupancy", fill=(230, 226, 188), font=title_font)
rows = [
    ("Default fixed UI area", f"{occ.get('defaultFixedUiAreaRatio', 0):.2%}"),
    ("Expanded worst-case UI area", f"{occ.get('expandedUiAreaRatio', 0):.2%}"),
    ("v0.214 comparator estimate", f"{occ.get('v0214ComparatorEstimatedAreaRatio', 0):.2%}"),
    ("Default exposes more battlefield", str(occ.get('defaultExposesMoreBattlefieldThanV0214', False))),
    ("Event log default", "collapsed" if occ.get('defaultEventLogCollapsed') else "open"),
    ("Production default", "collapsed" if occ.get('defaultProductionGridCollapsed') else "open"),
    ("Right alert default", "hidden" if occ.get('defaultRightAlertHidden') else "visible"),
    ("Tooltip default", "hidden" if occ.get('defaultTooltipHidden') else "visible"),
]
y = 94
for label, value in rows:
    draw.text((48, y), label, fill=(178, 196, 164), font=font)
    draw.text((430, y), value, fill=(232, 218, 150), font=font)
    y += 34
draw.text((48, y + 12), "Supported resolution matrix", fill=(230, 226, 188), font=font)
y += 52
for entry in occ.get("supportedResolutions", []):
    text = f"{entry.get('width')}x{entry.get('height')}  scale {entry.get('scale')}  default {entry.get('defaultAreaRatio', 0):.2%}  expanded {entry.get('expandedAreaRatio', 0):.2%}"
    draw.text((68, y), text, fill=(188, 205, 170), font=small)
    y += 28
draw.rectangle((610, 126, 930, 306), outline=(84, 118, 96), width=2)
draw.text((630, 144), "Battlefield center clear", fill=(208, 220, 178), font=small)
draw.rectangle((642, 170, 898, 278), outline=(60, 86, 68), width=1)
for rect in occ.get("defaultRects", []):
    x = 610 + rect.get("x", 0) / 1600 * 320
    y0 = 126 + rect.get("y", 0) / 900 * 180
    w = rect.get("w", 0) / 1600 * 320
    h = rect.get("h", 0) / 900 * 180
    draw.rectangle((x, y0, x + w, y0 + h), fill=(76, 116, 88), outline=(132, 178, 120))
for rect in occ.get("drawerRects", []):
    x = 610 + rect.get("x", 0) / 1600 * 320
    y0 = 126 + rect.get("y", 0) / 900 * 180
    w = rect.get("w", 0) / 1600 * 320
    h = rect.get("h", 0) / 900 * 180
    draw.rectangle((x, y0, x + w, y0 + h), outline=(215, 180, 88), width=2)
draw.text((610, 332), "green: default HUD surfaces", fill=(170, 210, 158), font=small)
draw.text((610, 358), "gold outline: contextual drawers", fill=(220, 188, 108), font=small)
os.makedirs(os.path.dirname(output), exist_ok=True)
canvas.save(output)
`;
  runPython(script, { occupancy, outputPath }, errors, `Occupancy image ${rel(outputPath)}`);
}

function validateNoForbidden(status, label, errors) {
  const occupancy = minimalStatus(status);
  for (const key of ["defaultLauncherChanged", "browserRuntimeChanged", "saveWritesAllowed", "stableIdsChanged", "routeTopologyChanged", "structureLocationsChanged"]) {
    if (status?.[key] === true || occupancy?.[key] === true) errors.push(`${label} reported forbidden ${key}.`);
  }
  if (occupancy.gameplayPathingCollisionObjectivesAiEconomySaveStableIdBalanceChanged === true) errors.push(`${label} reported forbidden gameplay/pathing boundary mutation.`);
  if (occupancy.aiImagesGenerated !== false || occupancy.downloadedAssets !== false || occupancy.newArtSlotsAdded !== 0) errors.push(`${label} reported generated art, downloaded assets, or slot leakage.`);
}

function validateSelectedStatus(status, label, errors) {
  const occupancy = minimalStatus(status);
  validateNoForbidden(status, label, errors);
  if (status.saltoPresentationRebootEnabled !== true) errors.push(`${label} did not preserve presentation reboot path.`);
  if (status.saltoCompositionLightingSelectionEnabled !== true) errors.push(`${label} did not preserve selected v0.221 composition context.`);
  if (status.saltoMinimalContextualHudEnabled !== true || occupancy.enabled !== true) errors.push(`${label} did not enable v0.222 minimal contextual HUD.`);
  for (const key of [
    "battlefieldDominant",
    "defaultStateCompact",
    "defaultEventLogCollapsed",
    "defaultProductionGridCollapsed",
    "defaultRightAlertHidden",
    "defaultTooltipHidden",
    "objectiveDetailOnDemand",
    "contextualDrawersEnabled",
    "tooltipDockedEdge",
    "defaultExposesMoreBattlefieldThanV0214",
    "noDrawerOverlapsMinimap",
    "noDrawerOverlapsBattlefieldCenter",
    "noDrawerOverlapsCriticalAction",
    "proceduralSvgIconsOnly"
  ]) {
    if (occupancy[key] !== true) errors.push(`${label} failed occupancy gate ${key}.`);
  }
  if (occupancy.centerScreenTooltip !== false || occupancy.defaultAlertBoxVisible !== false) errors.push(`${label} retained default center tooltip or default alert box.`);
  const defaultRatio = Number(occupancy.defaultFixedUiAreaRatio ?? 1);
  const expandedRatio = Number(occupancy.expandedUiAreaRatio ?? 1);
  if (!Number.isFinite(defaultRatio) || defaultRatio <= 0 || defaultRatio >= 0.18) errors.push(`${label} default HUD area ratio outside compact budget: ${defaultRatio}.`);
  if (!Number.isFinite(expandedRatio) || expandedRatio <= 0 || expandedRatio >= 0.34) errors.push(`${label} expanded HUD area ratio outside drawer budget: ${expandedRatio}.`);
  for (const entry of occupancy.supportedResolutions ?? []) {
    if (entry.minimapSafe !== true || entry.centerBattlefieldClear !== true || entry.drawerOverlapSafe !== true) {
      errors.push(`${label} resolution ${entry.width}x${entry.height} reported unsafe drawer/minimap/center overlap.`);
    }
  }
}

function runCapture(root) {
  const errors = [];
  const before = readJson(manifestPath(root, "v0221-before-minimal-contextual-hud"));
  const selected = readJson(manifestPath(root, "selected-minimal-contextual-hud"));
  for (const [label, manifest] of [["before", before], ["selected", selected]]) {
    if (manifest.status !== "PASS_PLAYER_SLICE_CAPTURE") errors.push(`${label} capture manifest did not pass.`);
  }
  if (minimalStatus(finalRuntimeStatus(captureById(before, "default_compact_hud") ?? before)).enabled === true) errors.push("Comparator enabled v0.222 minimal contextual HUD.");
  const selectedStatus = finalRuntimeStatus(captureById(selected, "default_compact_hud") ?? selected);
  validateSelectedStatus(selectedStatus, "selected capture", errors);

  mkdirSync(manualReviewRoot, { recursive: true });
  const copies = [
    ["default_compact_hud", "01_default_compact_hud.png"],
    ["objective_expanded", "02_objective_expanded.png"],
    ["event_drawer_expanded", "03_event_drawer_expanded.png"],
    ["production_drawer_build", "04_production_drawer_build.png"],
    ["production_drawer_train", "05_production_drawer_train.png"],
    ["production_drawer_research", "06_production_drawer_research.png"],
    ["hostile_alert_active", "07_hostile_alert_active.png"],
    ["tooltip_docked", "08_tooltip_docked.png"]
  ];
  const reviewImages = [];
  for (const [captureId, fileName] of copies) {
    const source = capturePath(selected, captureId, errors);
    const target = join(manualReviewRoot, fileName);
    if (source) {
      copyFileSync(source, target);
      reviewImages.push(target);
    }
  }
  const resolutionSources = [
    capturePath(selected, "resolution_1920x1080", errors),
    capturePath(selected, "resolution_1600x900", errors),
    capturePath(selected, "resolution_1366x768", errors)
  ];
  createContactSheet(resolutionSources, join(manualReviewRoot, "09_resolution_matrix.png"), "v0.222 minimal contextual HUD resolution matrix", errors, 2);
  if (!existsSync(fullHudComparatorPath)) {
    errors.push("Missing v0.214/full-HUD comparator evidence at artifacts/manual-review/v0213-full-ui-qa/02_initial.png.");
  }
  createContactSheet([fullHudComparatorPath, reviewImages[0]], join(manualReviewRoot, "10_v0214_vs_reboot_contact_sheet.png"), "v0.214 full HUD comparator vs v0.222 compact reboot", errors, 2);
  createOccupancyImage(minimalStatus(selectedStatus), join(manualReviewRoot, "11_occupancy_measurements.png"), errors);
  createContactSheet(reviewImages, join(manualReviewRoot, "12_review_contact_sheet.png"), "v0.222 minimal contextual HUD review pack", errors, 2);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0222_MINIMAL_CONTEXTUAL_HUD_REVIEW_PACK" : "FAIL_V0222_MINIMAL_CONTEXTUAL_HUD_REVIEW_PACK",
    manualReviewRoot: rel(manualReviewRoot),
    fullHudComparatorEvidence: rel(fullHudComparatorPath),
    requiredPngs: [
      "01_default_compact_hud.png",
      "02_objective_expanded.png",
      "03_event_drawer_expanded.png",
      "04_production_drawer_build.png",
      "05_production_drawer_train.png",
      "06_production_drawer_research.png",
      "07_hostile_alert_active.png",
      "08_tooltip_docked.png",
      "09_resolution_matrix.png",
      "10_v0214_vs_reboot_contact_sheet.png",
      "11_occupancy_measurements.png"
    ],
    optionalContactSheet: "12_review_contact_sheet.png",
    occupancy: minimalStatus(selectedStatus),
    errors
  };
  writeJson(join(root, "v0222-minimal-contextual-hud-capture-report.json"), report);
  if (errors.length > 0) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0222_MINIMAL_CONTEXTUAL_HUD_REVIEW_PACK");
}

function runValidation(root) {
  const errors = [];
  const defaultReport = readJson(validationPath(root, "default-procedural"));
  const before = readJson(validationPath(root, "v0221-before-minimal-contextual-hud"));
  const selected = readJson(validationPath(root, "selected-minimal-contextual-hud"));
  for (const [label, report] of [["default", defaultReport], ["before", before], ["selected", selected]]) {
    if (report.status !== "PASS_PLAYER_SLICE_VALIDATION") errors.push(`${label} validation did not pass.`);
  }
  if (finalRuntimeStatus(defaultReport).saltoMinimalContextualHudEnabled === true) errors.push("Default procedural launcher enabled v0.222 minimal HUD.");
  if (finalRuntimeStatus(defaultReport).saltoPresentationRebootEnabled === true) errors.push("Default procedural launcher enabled presentation reboot.");
  if (finalRuntimeStatus(before).saltoMinimalContextualHudEnabled === true) errors.push("v0.221 comparator enabled v0.222 minimal HUD.");
  validateSelectedStatus(finalRuntimeStatus(selected), "selected validation", errors);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0222_MINIMAL_CONTEXTUAL_HUD_VALIDATION" : "FAIL_V0222_MINIMAL_CONTEXTUAL_HUD_VALIDATION",
    defaultLauncherProcedural: finalRuntimeStatus(defaultReport).saltoPresentationRebootEnabled !== true && finalRuntimeStatus(defaultReport).saltoMinimalContextualHudEnabled !== true,
    priorRebootComparatorPreserved: finalRuntimeStatus(before).saltoMinimalContextualHudEnabled !== true,
    selectedOccupancy: minimalStatus(finalRuntimeStatus(selected)),
    errors
  };
  writeJson(join(root, "v0222-minimal-contextual-hud-validation-report.json"), report);
  if (errors.length > 0) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0222_MINIMAL_CONTEXTUAL_HUD_VALIDATION");
}

function runBoundary(root) {
  const validation = readJson(join(root, "v0222-minimal-contextual-hud-validation-report.json"));
  const errors = [];
  if (validation.status !== "PASS_V0222_MINIMAL_CONTEXTUAL_HUD_VALIDATION") errors.push("Validation report is not PASS.");
  const statusLines = execFileSync("git", ["status", "--short", "--untracked-files=all"], { cwd: repoRoot, encoding: "utf8" })
    .split(/\r?\n/u)
    .filter(Boolean);
  const changed = statusLines.map((line) => line.slice(3).replaceAll("\\", "/"));
  const allowed = [
    /^desktop-spikes\/godot-salto\/scripts\/salto_spike_root\.gd$/u,
    /^package\.json$/u,
    /^tools\/godot\/launchGodotSaltoPresentationRebootWindows\.ps1$/u,
    /^tools\/godot\/captureGodotSaltoMinimalContextualHudWindows\.ps1$/u,
    /^tools\/godot\/validateGodotSaltoMinimalContextualHudWindows\.ps1$/u,
    /^tools\/godot\/runGodotSaltoMinimalContextualHudBenchmarkWindows\.ps1$/u,
    /^tools\/godot\/saltoMinimalContextualHudTool\.mjs$/u,
    /^tools\/godot\/saltoPresentationRebootTool\.mjs$/u,
    /^tools\/godot\/saltoCompositionLightingSelectionTool\.mjs$/u,
    /^docs\/V0222_MINIMAL_CONTEXTUAL_HUD_REPORT\.md$/u,
    /^docs\/V0222_UI_OCCUPANCY_REPORT\.md$/u,
    /^docs\/V0222_IMPLEMENTATION_REPORT\.md$/u,
    /^CHANGELOG\.md$/u,
    /^DEVELOPMENT_CHECKPOINT\.md$/u,
    /^LLM_GAME_HANDOFF\.md$/u,
    /^ROADMAP\.md$/u
  ];
  for (const path of changed) {
    if (!allowed.some((pattern) => pattern.test(path))) errors.push(`Unexpected changed path for v0.222 boundary: ${path}`);
    if (path.endsWith(".png")) errors.push(`Tracked PNG path is not allowed in v0.222 boundary: ${path}`);
    if (path.startsWith("src/")) errors.push(`Browser runtime or web app source changed unexpectedly: ${path}`);
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0222_MINIMAL_CONTEXTUAL_HUD_BOUNDARY" : "FAIL_V0222_MINIMAL_CONTEXTUAL_HUD_BOUNDARY",
    changed,
    generatedImages: false,
    downloadedAssets: false,
    productionRuntimeSlotsAdded: 0,
    defaultLauncherChanged: false,
    browserRuntimeChanged: false,
    gameplayPathingCollisionObjectivesAiEconomySaveStableIdBalanceChanged: false,
    errors
  };
  writeJson(join(root, "v0222-minimal-contextual-hud-boundary-report.json"), report);
  if (errors.length > 0) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0222_MINIMAL_CONTEXTUAL_HUD_BOUNDARY");
}

function runBenchmark(root) {
  const errors = [];
  const before = readJson(benchmarkPath(root, "v0221-before-minimal-contextual-hud"));
  const selected = readJson(benchmarkPath(root, "selected-minimal-contextual-hud"));
  if (finalRuntimeStatus(before).saltoMinimalContextualHudEnabled === true) errors.push("Benchmark comparator enabled v0.222 minimal HUD.");
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
    status: errors.length === 0 ? "PASS_V0222_MINIMAL_CONTEXTUAL_HUD_BENCHMARK" : "FAIL_V0222_MINIMAL_CONTEXTUAL_HUD_BENCHMARK",
    scenarios: {
      before: { averageFps: beforeFps, p95FrameTimeMs: beforeP95 },
      selected: { averageFps: selectedFps, p95FrameTimeMs: selectedP95 }
    },
    p95FrameTimeRatio: p95Ratio,
    errors
  };
  writeJson(join(root, "v0222-minimal-contextual-hud-benchmark-report.json"), report);
  if (errors.length > 0) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0222_MINIMAL_CONTEXTUAL_HUD_BENCHMARK");
}

const root = artifactRootFromArgs();
const command = process.argv[2] ?? "";
if (command === "capture") runCapture(root);
else if (command === "validation") runValidation(root);
else if (command === "boundary") runBoundary(root);
else if (command === "benchmark") runBenchmark(root);
else {
  console.error("Usage: node tools/godot/saltoMinimalContextualHudTool.mjs <capture|validation|boundary|benchmark> [--artifact-root=...]");
  process.exit(2);
}
