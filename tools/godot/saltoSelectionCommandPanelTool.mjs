import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync, execSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.210";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0210");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0210-selection-command-panel");
const optInCaptures = [
  { id: "aster", manualName: "01_aster.png" },
  { id: "tooltips", manualName: "02_tooltips.png" },
  { id: "worker", manualName: "03_worker.png" },
  { id: "barracks_restoring", manualName: "04_barracks_restoring.png" },
  { id: "queue", manualName: "05_queue.png" },
  { id: "militia", manualName: "06_militia.png" },
  { id: "multi_select", manualName: "07_multi_select.png" }
];
const fallbackManualName = "08_portrait_fallback.png";

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

function validateCaptureManifest(root, scenario, options) {
  const errors = [];
  const path = manifestPath(root, scenario);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}.`);
    return { errors, manifest: null };
  }
  const manifest = readJson(path);
  if (manifest.checkpoint !== checkpoint) errors.push(`${scenario} expected checkpoint ${checkpoint}, received ${manifest.checkpoint}.`);
  if (manifest.status !== "PASS_PLAYER_SLICE_CAPTURE") errors.push(`${scenario} capture status was ${manifest.status}.`);
  if (manifest.saltoUiShellOptInRequested !== true) errors.push(`${scenario} did not request the Salto UI shell opt-in.`);
  if (manifest.saltoUiShellFallbackActive !== false) errors.push(`${scenario} should not use the v0.209 whole-shell fallback.`);
  if (manifest.saltoUiShellLiveOverlayEnabled !== true) errors.push(`${scenario} live overlay must stay enabled.`);
  if (manifest.saltoSelectionCommandPanelEnabled !== true) errors.push(`${scenario} did not enable the v0.210 selection command panel.`);
  if (manifest.saltoUiShellProductionSlotAdded !== false) errors.push(`${scenario} must not add a production UI/art slot.`);
  if (manifest.generatedOrImportedArtIncluded !== false) errors.push(`${scenario} should not integrate runtime art.`);
  if (manifest.runtimeArtIntegrated !== false) errors.push(`${scenario} should not integrate runtime art.`);
  if (manifest.saltoAsterPortraitProductionSlotAdded !== false) errors.push(`${scenario} must not add an Aster portrait production slot.`);
  if (manifest.saltoAsterPortraitGeneratedImages !== false) errors.push(`${scenario} must not generate images.`);
  if (manifest.saltoAsterPortraitSourceLoaded !== options.portraitLoaded) errors.push(`${scenario} portrait loaded expected ${options.portraitLoaded}, received ${manifest.saltoAsterPortraitSourceLoaded}.`);
  if (manifest.saltoAsterPortraitFallbackActive !== options.portraitFallback) errors.push(`${scenario} portrait fallback expected ${options.portraitFallback}, received ${manifest.saltoAsterPortraitFallbackActive}.`);
  const captures = Array.isArray(manifest.captures) ? manifest.captures : [];
  for (const captureSpec of options.requiredCaptures) {
    const capture = captures.find((entry) => entry?.id === captureSpec.id);
    if (!capture) {
      errors.push(`${scenario} missing capture id ${captureSpec.id}.`);
      continue;
    }
    const absolutePath = resolve(String(capture.absolutePath ?? ""));
    if (!existsSync(absolutePath)) errors.push(`${scenario} missing screenshot for ${captureSpec.id}: ${rel(absolutePath)}.`);
    if (Number(capture.width) !== 1600 || Number(capture.height) !== 900) errors.push(`${scenario} ${captureSpec.id} must be 1600x900.`);
    const status = statusForCapture(capture);
    if (status.saltoSelectionCommandPanelEnabled !== true) errors.push(`${scenario} ${captureSpec.id} did not report selection panel enabled.`);
    if (status.saltoAsterPortraitSourceLoaded !== options.portraitLoaded) errors.push(`${scenario} ${captureSpec.id} portrait loaded expected ${options.portraitLoaded}.`);
    if (status.saltoAsterPortraitFallbackActive !== options.portraitFallback) errors.push(`${scenario} ${captureSpec.id} portrait fallback expected ${options.portraitFallback}.`);
    const panel = status.saltoAsterPortraitStatus ?? {};
    if (panel.productionSlotAdded !== false) errors.push(`${scenario} ${captureSpec.id} reported portrait production slot leakage.`);
    if (panel.generatedImages !== false) errors.push(`${scenario} ${captureSpec.id} reported generated portrait image leakage.`);
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
  if (report.checkpoint !== checkpoint) errors.push(`${scenario} validation expected checkpoint ${checkpoint}, received ${report.checkpoint}.`);
  if (report.saltoSelectionCommandPanelEnabled !== options.selectionPanel) errors.push(`${scenario} selection panel expected ${options.selectionPanel}, received ${report.saltoSelectionCommandPanelEnabled}.`);
  if (report.saltoAsterPortraitSourceLoaded !== options.portraitLoaded) errors.push(`${scenario} portrait loaded expected ${options.portraitLoaded}, received ${report.saltoAsterPortraitSourceLoaded}.`);
  if (report.saltoAsterPortraitFallbackActive !== options.portraitFallback) errors.push(`${scenario} portrait fallback expected ${options.portraitFallback}, received ${report.saltoAsterPortraitFallbackActive}.`);
  if (report.saltoUiShellProductionSlotAdded !== false) errors.push(`${scenario} must not add a production UI/art slot.`);
  if (report.runtimeArtIntegrated !== false) errors.push(`${scenario} should not integrate runtime art.`);
  if (report.generatedOrImportedArtIncluded !== false) errors.push(`${scenario} should not integrate imported runtime art.`);
  if (report.saltoAsterPortraitGeneratedImages !== false) errors.push(`${scenario} should not generate Aster portrait images.`);
  return { errors, report };
}

function createContactSheet(sourcePaths, outputPath, errors) {
  const existing = sourcePaths.filter((path) => path && existsSync(path));
  if (existing.length === 0) {
    errors.push(`No source images for contact sheet ${rel(outputPath)}.`);
    return;
  }
  const pythonExe = process.env.SALTO_CONTACT_SHEET_PYTHON || "python";
  const payload = JSON.stringify({ sourcePaths: existing, outputPath, title: "v0.210 Salto selection and command panel" });
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
  try {
    execFileSync(pythonExe, ["-c", script], {
      cwd: repoRoot,
      env: { ...process.env, SALTO_CONTACT_SHEET_PAYLOAD: payload },
      stdio: ["ignore", "pipe", "pipe"]
    });
  } catch (error) {
    errors.push(`Contact sheet generation failed: ${error.message}`);
  }
}

function copyManualReviewPack(root) {
  const main = validateCaptureManifest(root, "opt-in", { portraitLoaded: true, portraitFallback: false, requiredCaptures: optInCaptures });
  const fallback = validateCaptureManifest(root, "portrait-fallback", { portraitLoaded: false, portraitFallback: true, requiredCaptures: [{ id: "portrait_fallback" }] });
  const errors = [...main.errors, ...fallback.errors];
  if (errors.length > 0 || !main.manifest || !fallback.manifest) return { errors, manualPaths: [] };
  mkdirSync(manualReviewRoot, { recursive: true });
  const manualPaths = [];
  for (const required of optInCaptures) {
    const capture = main.manifest.captures.find((entry) => entry.id === required.id);
    const destination = join(manualReviewRoot, required.manualName);
    copyFileSync(resolve(capture.absolutePath), destination);
    manualPaths.push(destination);
  }
  const fallbackCapture = fallback.manifest.captures.find((entry) => entry.id === "portrait_fallback");
  const fallbackPath = join(manualReviewRoot, fallbackManualName);
  copyFileSync(resolve(fallbackCapture.absolutePath), fallbackPath);
  manualPaths.push(fallbackPath);
  const contactSheet = join(manualReviewRoot, "09_contact_sheet.png");
  createContactSheet(manualPaths, contactSheet, errors);
  if (existsSync(contactSheet)) manualPaths.push(contactSheet);
  writeText(
    join(manualReviewRoot, "README.md"),
    [
      "# v0.210 Salto Selection Command Panel",
      "",
      "Ignored manual review PNG pack for the Godot-only Salto UI shell selection and command panel polish.",
      "",
      "- `01_aster.png`",
      "- `02_tooltips.png`",
      "- `03_worker.png`",
      "- `04_barracks_restoring.png`",
      "- `05_queue.png`",
      "- `06_militia.png`",
      "- `07_multi_select.png`",
      "- `08_portrait_fallback.png`",
      "- `09_contact_sheet.png`",
      "",
      "The Aster portrait reuses the approved v0.152 derivative only in this private opt-in UI path and falls back to a procedural silhouette when forced or invalid."
    ].join("\n")
  );
  writeJson(join(root, "v0210-selection-command-panel-review-pack.json"), {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0210_SELECTION_COMMAND_PANEL_REVIEW_PACK" : "FAIL_V0210_SELECTION_COMMAND_PANEL_REVIEW_PACK",
    manualReviewRoot,
    manualPaths: manualPaths.map(rel),
    portraitFallbackCapture: rel(fallbackPath),
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
    /^tools\/godot\/captureGodotSaltoSelectionCommandPanelWindows\.ps1$/u,
    /^tools\/godot\/validateGodotSaltoSelectionCommandPanelWindows\.ps1$/u,
    /^tools\/godot\/saltoSelectionCommandPanelTool\.mjs$/u,
    /^package\.json$/u,
    /^docs\/V0210_SELECTION_COMMAND_PANEL_REPORT\.md$/u,
    /^docs\/V0210_IMPLEMENTATION_REPORT\.md$/u
  ];
  for (const path of changed) {
    if (!allowed.some((pattern) => pattern.test(path))) errors.push(`Unexpected changed path for v0.210 boundary: ${path}`);
    if (path.endsWith(".png") || path.includes("REFERENCE_UI_TARGET")) errors.push(`Tracked image/reference-copy path is not allowed in v0.210 boundary: ${path}`);
    if (path.startsWith("src/")) errors.push(`Browser runtime or web app source changed unexpectedly: ${path}`);
  }
  const requiredLaunchers = [
    "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat",
    "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_FIVE_SLOT_ART_EXPERIMENT_WINDOWS.bat",
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
  if (!rootDiff.includes("--salto-selection-command-panel")) errors.push("Root diff does not include the explicit selection command panel opt-in flag.");
  if (rootDiff.includes("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat")) errors.push("Default player launcher should not be mutated by v0.210.");
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0210_SELECTION_COMMAND_PANEL_BOUNDARY" : "FAIL_V0210_SELECTION_COMMAND_PANEL_BOUNDARY",
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
  writeJson(join(root, "boundary", "v0210-selection-command-panel-boundary.json"), report);
  return report;
}

function runCapture(root) {
  const { errors, manualPaths } = copyManualReviewPack(root);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0210_SELECTION_COMMAND_PANEL_CAPTURE_READY" : "FAIL_V0210_SELECTION_COMMAND_PANEL_CAPTURE_READY",
    manualReviewRoot,
    manualPaths: manualPaths.map(rel),
    generatedImages: false,
    errors
  };
  writeJson(join(root, "capture", "v0210-selection-command-panel-capture-ready.json"), report);
  return report;
}

function runValidation(root) {
  const captureMain = validateCaptureManifest(root, "opt-in", { portraitLoaded: true, portraitFallback: false, requiredCaptures: optInCaptures });
  const captureFallback = validateCaptureManifest(root, "portrait-fallback", { portraitLoaded: false, portraitFallback: true, requiredCaptures: [{ id: "portrait_fallback" }] });
  const validationMain = validateRuntimeReport(root, "opt-in", { selectionPanel: true, portraitLoaded: true, portraitFallback: false });
  const validationFallback = validateRuntimeReport(root, "portrait-fallback", { selectionPanel: true, portraitLoaded: false, portraitFallback: true });
  const validationDefault = validateRuntimeReport(root, "default-procedural", { selectionPanel: false, portraitLoaded: false, portraitFallback: true });
  const errors = [
    ...captureMain.errors,
    ...captureFallback.errors,
    ...validationMain.errors,
    ...validationFallback.errors,
    ...validationDefault.errors
  ];
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0210_SELECTION_COMMAND_PANEL_VALIDATION" : "FAIL_V0210_SELECTION_COMMAND_PANEL_VALIDATION",
    artifactRoot: root,
    optInManifest: rel(manifestPath(root, "opt-in")),
    fallbackManifest: rel(manifestPath(root, "portrait-fallback")),
    optInValidation: rel(validationPath(root, "opt-in")),
    fallbackValidation: rel(validationPath(root, "portrait-fallback")),
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
  writeJson(join(root, "validation", "v0210-selection-command-panel-validation.json"), report);
  return report;
}

const mode = process.argv[2] ?? "";
const root = artifactRootFromArgs();
let report;
if (mode === "capture") report = runCapture(root);
else if (mode === "validation") report = runValidation(root);
else if (mode === "boundary") report = validateBoundary(root);
else {
  console.error("Usage: node tools/godot/saltoSelectionCommandPanelTool.mjs <capture|validation|boundary> [--artifact-root=...]");
  process.exit(2);
}

if (!String(report.status).startsWith("PASS")) {
  for (const error of report.errors ?? []) console.error(error);
  process.exit(1);
}
console.log(report.status);
