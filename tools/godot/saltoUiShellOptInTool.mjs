import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync, execSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.209";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0209");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0209-ui-shell-opt-in");
const mainCaptures = [
  { id: "initial", manualName: "01_initial.png" },
  { id: "aster", manualName: "02_aster.png" },
  { id: "worker_assignment", manualName: "03_worker_assignment.png" },
  { id: "barracks_restoring", manualName: "04_barracks_restoring.png" },
  { id: "barracks_restored", manualName: "05_barracks_restored.png" },
  { id: "train", manualName: "06_train.png" },
  { id: "defenders", manualName: "07_defenders.png" },
  { id: "ashen_pressure", manualName: "08_ashen_pressure.png" },
  { id: "replay", manualName: "09_replay.png" }
];

function stableSort(value) {
  if (Array.isArray(value)) return value.map(stableSort);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([key, entry]) => [key, stableSort(entry)])
    );
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

function validateManifest(root, scenario, options) {
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
  if (manifest.saltoUiShellFallbackActive !== options.fallback) errors.push(`${scenario} fallback expected ${options.fallback}, received ${manifest.saltoUiShellFallbackActive}.`);
  if (manifest.saltoUiShellLiveOverlayEnabled !== !options.fallback) errors.push(`${scenario} live overlay expected ${!options.fallback}, received ${manifest.saltoUiShellLiveOverlayEnabled}.`);
  if (manifest.saltoUiShellProductionSlotAdded !== false) errors.push(`${scenario} must not add a production UI/art slot.`);
  if (manifest.generatedOrImportedArtIncluded !== false) errors.push(`${scenario} should not generate or import art.`);
  if (manifest.runtimeArtIntegrated !== false) errors.push(`${scenario} should not integrate runtime art.`);
  const captures = Array.isArray(manifest.captures) ? manifest.captures : [];
  const required = options.fallback ? [{ id: "initial" }] : mainCaptures;
  for (const captureSpec of required) {
    const capture = captures.find((entry) => entry?.id === captureSpec.id);
    if (!capture) {
      errors.push(`${scenario} missing capture id ${captureSpec.id}.`);
      continue;
    }
    const absolutePath = resolve(String(capture.absolutePath ?? ""));
    if (!existsSync(absolutePath)) errors.push(`${scenario} missing screenshot for ${captureSpec.id}: ${rel(absolutePath)}.`);
    if (Number(capture.width) !== 1600 || Number(capture.height) !== 900) errors.push(`${scenario} ${captureSpec.id} must be 1600x900.`);
    const status = capture.status ?? {};
    if (status.saltoUiShellLiveOverlayEnabled !== !options.fallback) errors.push(`${scenario} ${captureSpec.id} overlay expected ${!options.fallback}.`);
    if (status.saltoUiShellFallbackActive !== options.fallback) errors.push(`${scenario} ${captureSpec.id} fallback expected ${options.fallback}.`);
  }
  return { errors, manifest };
}

function createContactSheet(sourcePaths, outputPath, errors) {
  const existing = sourcePaths.filter((path) => path && existsSync(path));
  if (existing.length === 0) {
    errors.push(`No source images for contact sheet ${rel(outputPath)}.`);
    return;
  }
  const pythonExe = process.env.SALTO_CONTACT_SHEET_PYTHON || "python";
  const payload = JSON.stringify({ sourcePaths: existing, outputPath, title: "v0.209 Salto UI shell opt-in" });
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
canvas = Image.new("RGB", (cols * thumb_w + (cols + 1) * margin, rows * (thumb_h + label_h) + (rows + 1) * margin + title_h), (16, 20, 17))
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
      stdio: "pipe"
    });
  } catch (error) {
    errors.push(`Contact sheet generation failed: ${error.message}`);
  }
}

function copyManualReviewPack(root) {
  const main = validateManifest(root, "opt-in", { fallback: false });
  const fallback = validateManifest(root, "fallback", { fallback: true });
  const errors = [...main.errors, ...fallback.errors];
  if (errors.length > 0 || !main.manifest || !fallback.manifest) return { errors, manualPaths: [] };
  mkdirSync(manualReviewRoot, { recursive: true });
  const manualPaths = [];
  for (const required of mainCaptures) {
    const capture = main.manifest.captures.find((entry) => entry.id === required.id);
    const destination = join(manualReviewRoot, required.manualName);
    copyFileSync(resolve(capture.absolutePath), destination);
    manualPaths.push(destination);
  }
  const fallbackCapture = fallback.manifest.captures.find((entry) => entry.id === "initial");
  const fallbackPath = join(manualReviewRoot, "10_fallback.png");
  copyFileSync(resolve(fallbackCapture.absolutePath), fallbackPath);
  manualPaths.push(fallbackPath);
  const contactSheet = join(manualReviewRoot, "11_contact_sheet.png");
  createContactSheet(manualPaths, contactSheet, errors);
  if (existsSync(contactSheet)) manualPaths.push(contactSheet);
  writeText(
    join(manualReviewRoot, "README.md"),
    [
      "# v0.209 Salto UI Shell Opt-In",
      "",
      "Ignored manual review PNG pack for the Godot-only Salto UI shell opt-in path.",
      "",
      "- `01_initial.png`",
      "- `02_aster.png`",
      "- `03_worker_assignment.png`",
      "- `04_barracks_restoring.png`",
      "- `05_barracks_restored.png`",
      "- `06_train.png`",
      "- `07_defenders.png`",
      "- `08_ashen_pressure.png`",
      "- `09_replay.png`",
      "- `10_fallback.png`",
      "- `11_contact_sheet.png`",
      "",
      "No browser runtime, generated art, downloaded assets, default launcher change, gameplay mutation, or production UI/art slot is included."
    ].join("\n")
  );
  writeJson(join(root, "v0209-ui-shell-review-pack.json"), {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0209_UI_SHELL_REVIEW_PACK" : "FAIL_V0209_UI_SHELL_REVIEW_PACK",
    manualReviewRoot,
    manualPaths: manualPaths.map(rel),
    fallbackCapture: rel(fallbackPath),
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
    /^GODOT_LAUNCH_SALTO_UI_SHELL_EXPERIMENT_WINDOWS\.bat$/u,
    /^desktop-spikes\/godot-salto\/scripts\/salto_spike_root\.gd$/u,
    /^desktop-spikes\/godot-salto\/scripts\/salto_spike_scene_3d\.gd$/u,
    /^tools\/godot\/launchGodotSaltoUiShellExperimentWindows\.ps1$/u,
    /^tools\/godot\/captureGodotSaltoUiShellOptInWindows\.ps1$/u,
    /^tools\/godot\/validateGodotSaltoUiShellOptInWindows\.ps1$/u,
    /^tools\/godot\/saltoUiShellOptInTool\.mjs$/u,
    /^package\.json$/u,
    /^docs\/V0209_UI_SHELL_OPT_IN_REPORT\.md$/u,
    /^docs\/V0209_UI_SHELL_FALLBACK_REPORT\.md$/u,
    /^docs\/V0209_IMPLEMENTATION_REPORT\.md$/u
  ];
  for (const path of changed) {
    if (!allowed.some((pattern) => pattern.test(path))) errors.push(`Unexpected changed path for v0.209 boundary: ${path}`);
    if (path.endsWith(".png") || path.includes("REFERENCE_UI_TARGET")) errors.push(`Tracked image/reference-copy path is not allowed in v0.209 boundary: ${path}`);
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
  if (!rootDiff.includes("--salto-ui-shell-experiment")) errors.push("Root diff does not include the explicit UI shell opt-in flag.");
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0209_UI_SHELL_BOUNDARY" : "FAIL_V0209_UI_SHELL_BOUNDARY",
    artifactRoot: root,
    changedPaths: changed,
    requiredLaunchers,
    browserRuntimeTouched: false,
    defaultLauncherMutated: false,
    productionSlotAdded: false,
    errors
  };
  writeJson(join(root, "boundary", "v0209-ui-shell-boundary.json"), report);
  return report;
}

function runCapture(root) {
  const { errors, manualPaths } = copyManualReviewPack(root);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0209_UI_SHELL_CAPTURE_READY" : "FAIL_V0209_UI_SHELL_CAPTURE_READY",
    manualReviewRoot,
    manualPaths: manualPaths.map(rel),
    errors
  };
  writeJson(join(root, "capture", "v0209-ui-shell-capture-ready.json"), report);
  return report;
}

function runValidation(root) {
  const main = validateManifest(root, "opt-in", { fallback: false });
  const fallback = validateManifest(root, "fallback", { fallback: true });
  const errors = [...main.errors, ...fallback.errors];
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0209_UI_SHELL_VALIDATION" : "FAIL_V0209_UI_SHELL_VALIDATION",
    artifactRoot: root,
    optInManifest: rel(manifestPath(root, "opt-in")),
    fallbackManifest: rel(manifestPath(root, "fallback")),
    manualReviewRoot,
    optInOnly: true,
    defaultLauncherMutated: false,
    browserRuntimeTouched: false,
    generatedImages: false,
    downloadedAssets: false,
    productionSlotAdded: false,
    errors
  };
  writeJson(join(root, "validation", "v0209-ui-shell-validation.json"), report);
  return report;
}

const mode = process.argv[2] ?? "";
const root = artifactRootFromArgs();
let report;
if (mode === "capture") report = runCapture(root);
else if (mode === "validation") report = runValidation(root);
else if (mode === "boundary") report = validateBoundary(root);
else {
  console.error("Usage: node tools/godot/saltoUiShellOptInTool.mjs <capture|validation|boundary> [--artifact-root=...]");
  process.exit(2);
}

if (!String(report.status).startsWith("PASS")) {
  for (const error of report.errors ?? []) console.error(error);
  process.exit(1);
}
console.log(report.status);
