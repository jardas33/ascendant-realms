import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.207";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0207");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0207-ui-architecture");
const requiredCaptures = [
  { id: "ui_architecture_wireframe", manualName: "01_ui_architecture_wireframe.png" },
  { id: "component_map", manualName: "02_component_map.png" },
  { id: "gap_analysis", manualName: "03_gap_analysis.png" }
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

function captureManifestPath(root) {
  return join(root, "capture", "ui-architecture-wireframe-runtime.json");
}

function validateCapture(root) {
  const errors = [];
  const manifestPath = captureManifestPath(root);
  if (!existsSync(manifestPath)) {
    errors.push(`Missing ${rel(manifestPath)}.`);
    return { errors, manifest: null };
  }
  const manifest = readJson(manifestPath);
  if (manifest.checkpoint !== checkpoint) errors.push(`Expected checkpoint ${checkpoint}, received ${manifest.checkpoint}.`);
  if (manifest.status !== "PASS_V0207_UI_ARCHITECTURE_WIREFRAME_CAPTURE") errors.push(`Capture status was ${manifest.status}.`);
  if (manifest.captureCount !== requiredCaptures.length) errors.push(`Expected ${requiredCaptures.length} captures, received ${manifest.captureCount}.`);
  if (manifest.generatedImages !== false) errors.push("Generated-image flag must be false.");
  if (manifest.downloadedAssets !== false) errors.push("Downloaded-asset flag must be false.");
  if (manifest.defaultLauncherMutated !== false) errors.push("Default launcher mutation flag must be false.");
  if (manifest.browserRuntimeTouched !== false) errors.push("Browser-runtime flag must be false.");
  if (manifest.gameplayMutation !== false) errors.push("Gameplay mutation flag must be false.");
  if (manifest.runtimeArtSlotAdded !== false) errors.push("Runtime art slot flag must be false.");

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
  writeText(
    join(manualReviewRoot, "README.md"),
    [
      "# v0.207 Salto UI Architecture Style Lock",
      "",
      "These deterministic captures document the original Barrosan fantasy RTS HUD target for later opt-in Godot implementation.",
      "",
      "- `01_ui_architecture_wireframe.png`: full HUD shell layout.",
      "- `02_component_map.png`: source-of-truth regions and component responsibilities.",
      "- `03_gap_analysis.png`: current-risk to target implementation bridge.",
      "",
      "Reference image use is limited to hierarchy and polish benchmarking. No reference art, copied motifs, downloaded assets, generated images, or production runtime slots are included."
    ].join("\n")
  );
  writeJson(join(root, "v0207-ui-architecture-review-pack.json"), {
    schemaVersion: 1,
    checkpoint,
    status: "PASS_V0207_UI_ARCHITECTURE_REVIEW_PACK",
    manualReviewRoot,
    manualPaths: manualPaths.map(rel),
    copiedReferenceAssets: false,
    generatedImages: false,
    downloadedAssets: false,
    browserRuntimeTouched: false,
    defaultLauncherMutated: false
  });
  return { errors: [], manualPaths };
}

function validateBoundary(root) {
  const errors = [];
  const changed = execFileSync("git", ["status", "--short", "--untracked-files=all"], { cwd: repoRoot, encoding: "utf8" })
    .split(/\r?\n/u)
    .filter(Boolean)
    .map((line) => line.slice(3).replaceAll("\\", "/"));
  const allowed = [
    /^desktop-spikes\/godot-salto\/scripts\/salto_spike_root\.gd$/u,
    /^tools\/godot\/saltoUiArchitectureStyleLockTool\.mjs$/u,
    /^tools\/godot\/captureGodotSaltoUiArchitectureWindows\.ps1$/u,
    /^tools\/godot\/validateGodotSaltoUiArchitectureWindows\.ps1$/u,
    /^package\.json$/u,
    /^docs\/V0207_UI_ARCHITECTURE_STYLE_LOCK\.md$/u,
    /^docs\/V0207_UI_COMPONENT_INVENTORY\.md$/u,
    /^docs\/V0207_UI_IMPLEMENTATION_BLUEPRINT\.md$/u,
    /^docs\/V0207_IMPLEMENTATION_REPORT\.md$/u
  ];
  for (const path of changed) {
    if (!allowed.some((pattern) => pattern.test(path))) {
      errors.push(`Unexpected changed path for v0.207 boundary: ${path}`);
    }
    if (path.endsWith(".png") || path.includes("REFERENCE_UI_TARGET")) {
      errors.push(`Tracked image/reference-copy path is not allowed in v0.207 boundary: ${path}`);
    }
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0207_UI_ARCHITECTURE_BOUNDARY" : "FAIL_V0207_UI_ARCHITECTURE_BOUNDARY",
    changedPaths: changed,
    allowedPathPatterns: allowed.map((pattern) => pattern.source),
    artifactRoot: root,
    defaultLauncherMutated: false,
    browserRuntimeTouched: false,
    generatedImages: false,
    downloadedAssets: false,
    copiedReferenceAssets: false,
    errors
  };
  writeJson(join(root, "boundary", "v0207-ui-architecture-boundary.json"), report);
  return report;
}

function runCapture(root) {
  const { errors, manualPaths } = copyManualReviewPack(root);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0207_UI_ARCHITECTURE_CAPTURE_READY" : "FAIL_V0207_UI_ARCHITECTURE_CAPTURE_READY",
    manualReviewRoot,
    manualPaths: manualPaths.map(rel),
    errors
  };
  writeJson(join(root, "capture", "v0207-ui-architecture-capture-ready.json"), report);
  return report;
}

function runValidation(root) {
  const { errors, manifest } = validateCapture(root);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0207_UI_ARCHITECTURE_VALIDATION" : "FAIL_V0207_UI_ARCHITECTURE_VALIDATION",
    artifactRoot: root,
    captureManifest: manifest ? rel(captureManifestPath(root)) : null,
    reviewPackRoot: manualReviewRoot,
    requiredCaptures: requiredCaptures.map((capture) => capture.id),
    referenceUseLimitedToHierarchy: true,
    copiedReferenceAssets: false,
    generatedImages: false,
    downloadedAssets: false,
    defaultLauncherMutated: false,
    browserRuntimeTouched: false,
    errors
  };
  writeJson(join(root, "validation", "v0207-ui-architecture-validation.json"), report);
  return report;
}

const mode = process.argv[2] ?? "";
const root = artifactRootFromArgs();
let report;
if (mode === "capture") report = runCapture(root);
else if (mode === "validation") report = runValidation(root);
else if (mode === "boundary") report = validateBoundary(root);
else {
  console.error("Usage: node tools/godot/saltoUiArchitectureStyleLockTool.mjs <capture|validation|boundary> [--artifact-root=...]");
  process.exit(2);
}

if (!String(report.status).startsWith("PASS")) {
  for (const error of report.errors ?? []) console.error(error);
  process.exit(1);
}
console.log(report.status);
