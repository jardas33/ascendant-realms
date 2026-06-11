import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync, execSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.212";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0212");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0212-minimap-tooltip-accessibility");
const requiredCaptures = [
  { id: "minimap", manualName: "01_minimap.png", width: 1600, height: 900 },
  { id: "viewport_marker", manualName: "02_viewport_marker.png", width: 1600, height: 900 },
  { id: "tooltips", manualName: "03_tooltips.png", width: 1600, height: 900 },
  { id: "alerts", manualName: "04_alerts.png", width: 1600, height: 900 },
  { id: "resolution_1920x1080", manualName: "05_resolution_1920x1080.png", width: 1920, height: 1080 },
  { id: "resolution_1600x900", manualName: "06_resolution_1600x900.png", width: 1600, height: 900 },
  { id: "resolution_1366x768", manualName: "07_resolution_1366x768.png", width: 1366, height: 768 }
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

function statusForCapture(capture) {
  return capture?.status && typeof capture.status === "object" ? capture.status : {};
}

function validateCaptureManifest(root) {
  const errors = [];
  const path = manifestPath(root, "opt-in");
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}.`);
    return { errors, manifest: null };
  }
  const manifest = readJson(path);
  if (manifest.checkpoint !== checkpoint) errors.push(`Expected checkpoint ${checkpoint}, received ${manifest.checkpoint}.`);
  if (manifest.status !== "PASS_PLAYER_SLICE_CAPTURE") errors.push(`Capture status was ${manifest.status}.`);
  if (manifest.saltoUiShellOptInRequested !== true) errors.push("Salto UI shell opt-in was not requested.");
  if (manifest.saltoSelectionCommandPanelEnabled !== true) errors.push("v0.210 selection command panel must remain enabled.");
  if (manifest.saltoProductionObjectivesLogEnabled !== true) errors.push("v0.211 production objectives log must remain enabled.");
  if (manifest.saltoMinimapTooltipAccessibilityEnabled !== true) errors.push("v0.212 minimap tooltip accessibility flag was not enabled.");
  if (manifest.saltoUiShellFallbackActive !== false) errors.push("Whole-shell fallback should not be active.");
  if (manifest.saltoUiShellLiveOverlayEnabled !== true) errors.push("Live overlay must stay enabled.");
  if (manifest.saltoUiShellProductionSlotAdded !== false) errors.push("Must not add a production UI/art slot.");
  if (manifest.generatedOrImportedArtIncluded !== false) errors.push("Must not integrate runtime art.");
  if (manifest.runtimeArtIntegrated !== false) errors.push("Runtime art should not be integrated by v0.212.");
  const captures = Array.isArray(manifest.captures) ? manifest.captures : [];
  for (const spec of requiredCaptures) {
    const capture = captures.find((entry) => entry?.id === spec.id);
    if (!capture) {
      errors.push(`Missing capture id ${spec.id}.`);
      continue;
    }
    const absolutePath = resolve(String(capture.absolutePath ?? ""));
    if (!existsSync(absolutePath)) errors.push(`Missing screenshot for ${spec.id}: ${rel(absolutePath)}.`);
    if (Number(capture.width) !== spec.width || Number(capture.height) !== spec.height) {
      errors.push(`${spec.id} must be ${spec.width}x${spec.height}; received ${capture.width}x${capture.height}.`);
    }
    const status = statusForCapture(capture);
    if (status.saltoSelectionCommandPanelEnabled !== true) errors.push(`${spec.id} did not report selection panel enabled.`);
    if (status.saltoProductionObjectivesLogEnabled !== true) errors.push(`${spec.id} did not report v0.211 production objectives log enabled.`);
    if (status.saltoMinimapTooltipAccessibilityEnabled !== true) errors.push(`${spec.id} did not report v0.212 minimap tooltip accessibility enabled.`);
    if (status.saltoAsterPortraitGeneratedImages !== false) errors.push(`${spec.id} reported generated portrait image leakage.`);
  }
  return { errors, manifest };
}

function validateRuntimeReport(root, scenario, options) {
  const errors = [];
  const path = validationPath(root, scenario);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}.`);
    return { errors, report: null };
  }
  const report = readJson(path);
  if (report.status !== "PASS_PLAYER_SLICE_VALIDATION") errors.push(`${scenario} validation status was ${report.status}.`);
  if (report.checkpoint !== checkpoint) errors.push(`${scenario} expected checkpoint ${checkpoint}, received ${report.checkpoint}.`);
  if (report.saltoSelectionCommandPanelEnabled !== options.selectionPanel) errors.push(`${scenario} selection panel expected ${options.selectionPanel}, received ${report.saltoSelectionCommandPanelEnabled}.`);
  if (report.saltoProductionObjectivesLogEnabled !== options.productionObjectivesLog) errors.push(`${scenario} v0.211 flag expected ${options.productionObjectivesLog}, received ${report.saltoProductionObjectivesLogEnabled}.`);
  if (report.saltoMinimapTooltipAccessibilityEnabled !== options.minimapTooltipAccessibility) errors.push(`${scenario} v0.212 flag expected ${options.minimapTooltipAccessibility}, received ${report.saltoMinimapTooltipAccessibilityEnabled}.`);
  if (report.saltoUiShellProductionSlotAdded !== false) errors.push(`${scenario} must not add a production UI/art slot.`);
  if (report.runtimeArtIntegrated !== false) errors.push(`${scenario} should not integrate runtime art.`);
  if (report.generatedOrImportedArtIncluded !== false) errors.push(`${scenario} should not integrate imported runtime art.`);
  return { errors, report };
}

function createContactSheet(sourcePaths, outputPath, errors) {
  const existing = sourcePaths.filter((path) => path && existsSync(path));
  if (existing.length === 0) {
    errors.push(`No source images for contact sheet ${rel(outputPath)}.`);
    return;
  }
  const bundledPython = join(process.env.USERPROFILE || "", ".cache", "codex-runtimes", "codex-primary-runtime", "dependencies", "python", "python.exe");
  const pythonCandidates = [
    process.env.SALTO_CONTACT_SHEET_PYTHON,
    existsSync(bundledPython) ? bundledPython : null,
    "python"
  ].filter(Boolean);
  const payload = JSON.stringify({ sourcePaths: existing, outputPath, title: "v0.212 Salto minimap tooltip accessibility" });
  const script = String.raw`
import json
import os
from PIL import Image, ImageDraw, ImageFont

payload = json.loads(os.environ["SALTO_CONTACT_SHEET_PAYLOAD"])
sources = payload["sourcePaths"]
output = payload["outputPath"]
title = payload["title"]
thumb_w = 500
thumb_h = 281
margin = 18
label_h = 28
title_h = 36
cols = 2
rows = (len(sources) + cols - 1) // cols
canvas = Image.new("RGB", (cols * thumb_w + (cols + 1) * margin, rows * (thumb_h + label_h) + (rows + 1) * margin + title_h), (17, 21, 18))
draw = ImageDraw.Draw(canvas)
try:
    font = ImageFont.truetype("arial.ttf", 16)
    title_font = ImageFont.truetype("arial.ttf", 22)
except Exception:
    font = ImageFont.load_default()
    title_font = font
draw.text((margin, margin), title, fill=(226, 222, 180), font=title_font)
for index, path in enumerate(sources):
    image = Image.open(path).convert("RGB")
    image.thumbnail((thumb_w, thumb_h), Image.Resampling.LANCZOS)
    col = index % cols
    row = index // cols
    x = margin + col * (thumb_w + margin)
    y = margin + title_h + row * (thumb_h + label_h + margin)
    frame = Image.new("RGB", (thumb_w, thumb_h), (28, 35, 29))
    frame.paste(image, ((thumb_w - image.width) // 2, (thumb_h - image.height) // 2))
    canvas.paste(frame, (x, y + label_h))
    draw.text((x, y), os.path.basename(path), fill=(218, 226, 190), font=font)
os.makedirs(os.path.dirname(output), exist_ok=True)
canvas.save(output)
`;
  let lastError = null;
  for (const pythonExe of pythonCandidates) {
    try {
      execFileSync(pythonExe, ["-c", script], {
        cwd: repoRoot,
        env: { ...process.env, SALTO_CONTACT_SHEET_PAYLOAD: payload },
        stdio: ["ignore", "pipe", "pipe"]
      });
      return;
    } catch (error) {
      lastError = error;
    }
  }
  errors.push(`Contact sheet generation failed: ${lastError?.message ?? "no Python runtime available"}`);
}

function copyManualReviewPack(root) {
  const { errors, manifest } = validateCaptureManifest(root);
  if (errors.length > 0 || !manifest) return { errors, manualPaths: [] };
  mkdirSync(manualReviewRoot, { recursive: true });
  const manualPaths = [];
  for (const spec of requiredCaptures) {
    const capture = manifest.captures.find((entry) => entry.id === spec.id);
    const destination = join(manualReviewRoot, spec.manualName);
    copyFileSync(resolve(capture.absolutePath), destination);
    manualPaths.push(destination);
  }
  const contactSheet = join(manualReviewRoot, "08_contact_sheet.png");
  createContactSheet(manualPaths, contactSheet, errors);
  if (existsSync(contactSheet)) manualPaths.push(contactSheet);
  writeText(
    join(manualReviewRoot, "README.md"),
    [
      "# v0.212 Salto Minimap Tooltip Accessibility",
      "",
      "Ignored manual review PNG pack for the Godot-only opt-in minimap, alert, tooltip and resolution hardening pass.",
      "",
      "- `01_minimap.png`",
      "- `02_viewport_marker.png`",
      "- `03_tooltips.png`",
      "- `04_alerts.png`",
      "- `05_resolution_1920x1080.png`",
      "- `06_resolution_1600x900.png`",
      "- `07_resolution_1366x768.png`",
      "- `08_contact_sheet.png`",
      "",
      "The path remains opt-in-only behind `--salto-selection-command-panel --salto-production-objectives-log --salto-minimap-tooltip-accessibility`."
    ].join("\n")
  );
  writeJson(join(root, "v0212-minimap-tooltip-accessibility-review-pack.json"), {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0212_MINIMAP_TOOLTIP_ACCESSIBILITY_REVIEW_PACK" : "FAIL_V0212_MINIMAP_TOOLTIP_ACCESSIBILITY_REVIEW_PACK",
    manualReviewRoot,
    manualPaths: manualPaths.map(rel),
    generatedImages: false,
    downloadedAssets: false,
    errors
  });
  return { errors, manualPaths };
}

function validateBoundary(root) {
  const errors = [];
  const statusLines = execFileSync("git", ["status", "--short", "--untracked-files=all"], { cwd: repoRoot, encoding: "utf8" })
    .split(/\r?\n/u)
    .filter(Boolean);
  const changed = statusLines.map((line) => line.slice(3).replaceAll("\\", "/"));
  const allowed = [
    /^desktop-spikes\/godot-salto\/scripts\/salto_spike_root\.gd$/u,
    /^tools\/godot\/captureGodotSaltoMinimapTooltipAccessibilityWindows\.ps1$/u,
    /^tools\/godot\/validateGodotSaltoMinimapTooltipAccessibilityWindows\.ps1$/u,
    /^tools\/godot\/saltoMinimapTooltipAccessibilityTool\.mjs$/u,
    /^package\.json$/u,
    /^docs\/V0212_MINIMAP_TOOLTIP_ACCESSIBILITY_REPORT\.md$/u,
    /^docs\/V0212_IMPLEMENTATION_REPORT\.md$/u
  ];
  for (const path of changed) {
    if (!allowed.some((pattern) => pattern.test(path))) errors.push(`Unexpected changed path for v0.212 boundary: ${path}`);
    if (path.endsWith(".png") || path.includes("REFERENCE_UI_TARGET")) errors.push(`Tracked image/reference-copy path is not allowed in v0.212 boundary: ${path}`);
    if (path.startsWith("src/")) errors.push(`Browser runtime or web app source changed unexpectedly: ${path}`);
  }
  const requiredLaunchers = [
    "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat",
    "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_UI_SHELL_EXPERIMENT_WINDOWS.bat"
  ];
  for (const launcher of requiredLaunchers) {
    if (!existsSync(join(repoRoot, launcher))) errors.push(`Required launcher missing: ${launcher}`);
  }
  let rootDiff = "";
  try {
    rootDiff = execSync("git diff -- desktop-spikes/godot-salto/scripts/salto_spike_root.gd", { cwd: repoRoot, encoding: "utf8", maxBuffer: 1024 * 1024 * 20 });
  } catch {
    rootDiff = "";
  }
  if (!rootDiff.includes("--salto-minimap-tooltip-accessibility")) errors.push("Root diff does not include the explicit v0.212 opt-in flag.");
  if (rootDiff.includes("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat")) errors.push("Default player launcher should not be mutated by v0.212.");
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0212_MINIMAP_TOOLTIP_ACCESSIBILITY_BOUNDARY" : "FAIL_V0212_MINIMAP_TOOLTIP_ACCESSIBILITY_BOUNDARY",
    artifactRoot: root,
    changedPaths: changed,
    requiredLaunchers,
    browserRuntimeTouched: false,
    defaultLauncherMutated: false,
    productionSlotAdded: false,
    generatedImages: false,
    downloadedAssets: false,
    errors
  };
  writeJson(join(root, "boundary", "v0212-minimap-tooltip-accessibility-boundary.json"), report);
  return report;
}

function runCapture(root) {
  const { errors, manualPaths } = copyManualReviewPack(root);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0212_MINIMAP_TOOLTIP_ACCESSIBILITY_CAPTURE_READY" : "FAIL_V0212_MINIMAP_TOOLTIP_ACCESSIBILITY_CAPTURE_READY",
    manualReviewRoot,
    manualPaths: manualPaths.map(rel),
    generatedImages: false,
    downloadedAssets: false,
    errors
  };
  writeJson(join(root, "capture", "v0212-minimap-tooltip-accessibility-capture-ready.json"), report);
  return report;
}

function runValidation(root) {
  const captureMain = validateCaptureManifest(root);
  const validationMain = validateRuntimeReport(root, "opt-in", { selectionPanel: true, productionObjectivesLog: true, minimapTooltipAccessibility: true });
  const validationPrior = validateRuntimeReport(root, "prior-production-objectives-log", { selectionPanel: true, productionObjectivesLog: true, minimapTooltipAccessibility: false });
  const validationDefault = validateRuntimeReport(root, "default-procedural", { selectionPanel: false, productionObjectivesLog: false, minimapTooltipAccessibility: false });
  const errors = [
    ...captureMain.errors,
    ...validationMain.errors,
    ...validationPrior.errors,
    ...validationDefault.errors
  ];
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0212_MINIMAP_TOOLTIP_ACCESSIBILITY_VALIDATION" : "FAIL_V0212_MINIMAP_TOOLTIP_ACCESSIBILITY_VALIDATION",
    artifactRoot: root,
    optInManifest: rel(manifestPath(root, "opt-in")),
    optInValidation: rel(validationPath(root, "opt-in")),
    priorProductionObjectivesLogValidation: rel(validationPath(root, "prior-production-objectives-log")),
    defaultValidation: rel(validationPath(root, "default-procedural")),
    manualReviewRoot,
    optInOnly: true,
    defaultLauncherMutated: false,
    browserRuntimeTouched: false,
    generatedImages: false,
    downloadedAssets: false,
    productionSlotAdded: false,
    errors
  };
  writeJson(join(root, "validation", "v0212-minimap-tooltip-accessibility-validation.json"), report);
  return report;
}

const mode = process.argv[2] ?? "";
const root = artifactRootFromArgs();
let report;
if (mode === "capture") report = runCapture(root);
else if (mode === "validation") report = runValidation(root);
else if (mode === "boundary") report = validateBoundary(root);
else {
  console.error("Usage: node tools/godot/saltoMinimapTooltipAccessibilityTool.mjs <capture|validation|boundary> [--artifact-root=...]");
  process.exit(2);
}

if (!String(report.status).startsWith("PASS")) {
  for (const error of report.errors ?? []) console.error(error);
  process.exit(1);
}
console.log(report.status);
