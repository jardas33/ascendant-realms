import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync, execSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.208";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0208");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0208-ui-shell-comparator");
const requiredCaptures = [
  { id: "full_overview", manualName: "01_full_overview.png" },
  { id: "aster_selection", manualName: "02_aster_selection.png" },
  { id: "worker_assignment", manualName: "03_worker_assignment.png" },
  { id: "barracks_restoring", manualName: "04_barracks_restoring.png" },
  { id: "barracks_restored", manualName: "05_barracks_restored.png" },
  { id: "build_tab", manualName: "06_build_tab.png" },
  { id: "train_tab", manualName: "07_train_tab.png" },
  { id: "research_tab", manualName: "08_research_tab.png" },
  { id: "ashen_alert", manualName: "09_ashen_alert.png" },
  { id: "minimap_tooltips", manualName: "10_minimap_tooltips.png" }
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

function manifestPath(root) {
  return join(root, "capture", "ui-shell-comparator-runtime.json");
}

function validateCapture(root) {
  const errors = [];
  const path = manifestPath(root);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}.`);
    return { errors, manifest: null };
  }
  const manifest = readJson(path);
  if (manifest.checkpoint !== checkpoint) errors.push(`Expected checkpoint ${checkpoint}, received ${manifest.checkpoint}.`);
  if (manifest.status !== "PASS_V0208_UI_SHELL_COMPARATOR_CAPTURE") errors.push(`Capture status was ${manifest.status}.`);
  if (manifest.captureCount !== requiredCaptures.length) errors.push(`Expected ${requiredCaptures.length} captures, received ${manifest.captureCount}.`);
  for (const key of [
    "privateComparatorOnly",
    "generatedImages",
    "downloadedAssets",
    "copiedReferenceAssets",
    "defaultLauncherMutated",
    "browserRuntimeTouched",
    "gameplayMutation",
    "runtimeArtSlotAdded",
    "livePlayerFacingWiring"
  ]) {
    const expected = key === "privateComparatorOnly";
    if (manifest[key] !== expected) errors.push(`Manifest ${key} expected ${expected}, received ${manifest[key]}.`);
  }
  const captures = Array.isArray(manifest.captures) ? manifest.captures : [];
  for (const required of requiredCaptures) {
    const capture = captures.find((entry) => entry?.id === required.id);
    if (!capture) {
      errors.push(`Missing capture id ${required.id}.`);
      continue;
    }
    const absolutePath = resolve(String(capture.absolutePath ?? ""));
    if (!existsSync(absolutePath)) errors.push(`Missing screenshot file for ${required.id}: ${rel(absolutePath)}.`);
    if (Number(capture.width) !== 1600 || Number(capture.height) !== 900) {
      errors.push(`Capture ${required.id} must be 1600x900, received ${capture.width}x${capture.height}.`);
    }
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
  const payload = JSON.stringify({ sourcePaths: existing, outputPath, title: "v0.208 Salto UI shell private comparator" });
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
  const { errors, manifest } = validateCapture(root);
  if (errors.length > 0 || !manifest) return { errors, manualPaths: [] };
  mkdirSync(manualReviewRoot, { recursive: true });
  const manualPaths = [];
  for (const required of requiredCaptures) {
    const capture = manifest.captures.find((entry) => entry.id === required.id);
    const source = resolve(capture.absolutePath);
    const destination = join(manualReviewRoot, required.manualName);
    copyFileSync(source, destination);
    manualPaths.push(destination);
  }
  const contactSheet = join(manualReviewRoot, "11_contact_sheet.png");
  createContactSheet(manualPaths, contactSheet, errors);
  if (existsSync(contactSheet)) manualPaths.push(contactSheet);
  writeText(
    join(manualReviewRoot, "README.md"),
    [
      "# v0.208 Salto UI Shell Comparator",
      "",
      "Private comparator screenshots for the original fantasy RTS HUD shell. These are code-authored Godot controls and procedural geometry only.",
      "",
      "- `01_full_overview.png`",
      "- `02_aster_selection.png`",
      "- `03_worker_assignment.png`",
      "- `04_barracks_restoring.png`",
      "- `05_barracks_restored.png`",
      "- `06_build_tab.png`",
      "- `07_train_tab.png`",
      "- `08_research_tab.png`",
      "- `09_ashen_alert.png`",
      "- `10_minimap_tooltips.png`",
      "- `11_contact_sheet.png`",
      "",
      "No player-facing wiring, generated images, downloads, browser runtime changes, gameplay mutation, or production art slots are included."
    ].join("\n")
  );
  writeJson(join(root, "v0208-ui-shell-comparator-review-pack.json"), {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0208_UI_SHELL_REVIEW_PACK" : "FAIL_V0208_UI_SHELL_REVIEW_PACK",
    manualReviewRoot,
    manualPaths: manualPaths.map(rel),
    privateComparatorOnly: true,
    livePlayerFacingWiring: false,
    generatedImages: false,
    downloadedAssets: false,
    copiedReferenceAssets: false,
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
    /^tools\/godot\/saltoUiShellComparatorTool\.mjs$/u,
    /^tools\/godot\/captureGodotSaltoUiShellComparatorWindows\.ps1$/u,
    /^tools\/godot\/validateGodotSaltoUiShellComparatorWindows\.ps1$/u,
    /^package\.json$/u,
    /^docs\/V0208_UI_SHELL_COMPARATOR_REPORT\.md$/u,
    /^docs\/V0208_UI_COMPONENT_THEME_REPORT\.md$/u,
    /^docs\/V0208_IMPLEMENTATION_REPORT\.md$/u
  ];
  for (const path of changed) {
    if (!allowed.some((pattern) => pattern.test(path))) errors.push(`Unexpected changed path for v0.208 boundary: ${path}`);
    if (path.endsWith(".png") || path.includes("REFERENCE_UI_TARGET")) errors.push(`Tracked image/reference-copy path is not allowed in v0.208 boundary: ${path}`);
  }
  let rootDiff = "";
  try {
    rootDiff = execSync("git diff -- desktop-spikes/godot-salto/scripts/salto_spike_root.gd", { cwd: repoRoot, encoding: "utf8", maxBuffer: 1024 * 1024 * 20 });
  } catch {
    rootDiff = "";
  }
  if (rootDiff.includes("show_player_battle") || rootDiff.includes("GODOT_LAUNCH_SALTO")) {
    errors.push("Boundary scan detected possible player-facing launcher or battle-flow mutation.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0208_UI_SHELL_BOUNDARY" : "FAIL_V0208_UI_SHELL_BOUNDARY",
    artifactRoot: root,
    changedPaths: changed,
    privateComparatorOnly: true,
    livePlayerFacingWiring: false,
    defaultLauncherMutated: false,
    browserRuntimeTouched: false,
    generatedImages: false,
    downloadedAssets: false,
    errors
  };
  writeJson(join(root, "boundary", "v0208-ui-shell-boundary.json"), report);
  return report;
}

function runCapture(root) {
  const { errors, manualPaths } = copyManualReviewPack(root);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0208_UI_SHELL_CAPTURE_READY" : "FAIL_V0208_UI_SHELL_CAPTURE_READY",
    manualReviewRoot,
    manualPaths: manualPaths.map(rel),
    errors
  };
  writeJson(join(root, "capture", "v0208-ui-shell-capture-ready.json"), report);
  return report;
}

function runValidation(root) {
  const { errors, manifest } = validateCapture(root);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0208_UI_SHELL_VALIDATION" : "FAIL_V0208_UI_SHELL_VALIDATION",
    artifactRoot: root,
    captureManifest: manifest ? rel(manifestPath(root)) : null,
    manualReviewRoot,
    requiredCaptures: requiredCaptures.map((capture) => capture.id),
    privateComparatorOnly: true,
    livePlayerFacingWiring: false,
    generatedImages: false,
    downloadedAssets: false,
    copiedReferenceAssets: false,
    defaultLauncherMutated: false,
    browserRuntimeTouched: false,
    errors
  };
  writeJson(join(root, "validation", "v0208-ui-shell-validation.json"), report);
  return report;
}

const mode = process.argv[2] ?? "";
const root = artifactRootFromArgs();
let report;
if (mode === "capture") report = runCapture(root);
else if (mode === "validation") report = runValidation(root);
else if (mode === "boundary") report = validateBoundary(root);
else {
  console.error("Usage: node tools/godot/saltoUiShellComparatorTool.mjs <capture|validation|boundary> [--artifact-root=...]");
  process.exit(2);
}

if (!String(report.status).startsWith("PASS")) {
  for (const error of report.errors ?? []) console.error(error);
  process.exit(1);
}
console.log(report.status);
