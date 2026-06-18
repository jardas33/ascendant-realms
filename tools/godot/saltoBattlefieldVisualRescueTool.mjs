import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0227");
const manualRoot = join(repoRoot, "artifacts", "manual-review", "v0227-battlefield-visual-rescue");
const ids = [
  "initial_overview", "terrain_focus", "bridge_river_focus", "structure_focus", "hostile_pressure",
  "train_drawer", "resolution_1366x768", "resolution_1600x900", "resolution_1920x1080"
];

function rootFromArgs() {
  const arg = process.argv.find((value) => value.startsWith("--artifact-root="));
  return arg ? resolve(arg.slice("--artifact-root=".length)) : artifactRootDefault;
}
function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
}
function writeJson(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, `${JSON.stringify(value, null, 2)}\n`, "utf8");
}
function writeText(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, `${value.trim()}\n`, "utf8");
}
function rel(path) {
  return relative(repoRoot, path).replace(/\\/gu, "/");
}
function statusFrom(report) {
  return report?.saltoBattlefieldVisualRescueEnabled === true
    ? report
    : report?.captures?.[0]?.status ?? report?.steps?.[0]?.status ?? report;
}
function checkSelected(report, errors) {
  if (!String(report?.status ?? "").startsWith("PASS")) errors.push(`Selected v0.227 runtime did not pass: ${report?.status ?? "MISSING"}`);
  const status = statusFrom(report);
  if (status?.saltoBattlefieldVisualRescueEnabled !== true) errors.push("v0.227 opt-in flag was not enabled.");
  const scene = status?.saltoBattlefieldVisualRescue ?? {};
  if (scene.enabled !== true || scene.visualOnly !== true || scene.gameplayChanged !== false) errors.push("v0.227 scene status did not prove visual-only rescue.");
  if (Number(scene.newArtSlotsAdded ?? -1) !== 0 || Number(scene.generatedImageCount ?? -1) !== 0) errors.push("v0.227 unexpectedly added art slots or generated images.");
}
function capture(root) {
  const errors = [];
  const manifestPath = join(root, "capture", "selected-battlefield-visual-rescue", "screenshot-runtime-manifest.json");
  if (!existsSync(manifestPath)) errors.push(`Missing ${rel(manifestPath)}`);
  const manifest = errors.length === 0 ? readJson(manifestPath) : null;
  if (manifest) checkSelected(manifest, errors);
  const captures = Array.isArray(manifest?.captures) ? manifest.captures : [];
  const byId = new Map(captures.map((entry) => [entry.id, entry]));
  mkdirSync(manualRoot, { recursive: true });
  ids.forEach((id, index) => {
    const entry = byId.get(id);
    if (!entry?.absolutePath || !existsSync(entry.absolutePath)) {
      errors.push(`Missing v0.227 capture ${id}`);
      return;
    }
    copyFileSync(entry.absolutePath, join(manualRoot, `${String(index + 1).padStart(2, "0")}_${id}.png`));
  });
  writeText(join(manualRoot, "11_notes.md"), [
    "# v0.227 Battlefield Visual Rescue Notes", "",
    "- New source images generated: none.",
    "- Replaced the broad translucent cohesion/composition stack in the v0.227 path with opaque terrain value regions and restrained local accents.",
    "- Deepened and cooled the river, made bank lips solid, blended road approaches into the bridge, and strengthened abutment/contact depth.",
    "- Added restrained roof, stone-course, entry and foundation separation to the existing structure shells without changing footprints.",
    "- Preserved the compact reboot HUD and all gameplay/default-launcher boundaries.",
    "", "Candid review: inspect the before/after sheet before accepting the milestone; technical PASS alone is not an artistic PASS."
  ].join("\n"));
  writeJson(join(root, "v0227-battlefield-visual-rescue-capture-report.json"), {
    schemaVersion: 1,
    checkpoint: "v0.227",
    status: errors.length === 0 ? "PASS_V0227_BATTLEFIELD_VISUAL_RESCUE_REVIEW_PACK" : "FAIL_V0227_BATTLEFIELD_VISUAL_RESCUE_REVIEW_PACK",
    generatedImageCount: 0,
    reviewPack: rel(manualRoot),
    errors
  });
  if (errors.length > 0) throw new Error(errors.join("\n"));
}
function validation(root) {
  const errors = [];
  for (const scenario of ["selected-battlefield-visual-rescue", "selected-v0224-comparator", "ground-missing-fallback", "default-procedural"]) {
    const path = join(root, "validation", scenario, "player-slice-validation-runtime.json");
    if (!existsSync(path)) {
      errors.push(`Missing ${rel(path)}`);
      continue;
    }
    const report = readJson(path);
    if (report.status !== "PASS_PLAYER_SLICE_VALIDATION") errors.push(`${scenario} did not pass validation.`);
    if (scenario === "selected-battlefield-visual-rescue" || scenario === "ground-missing-fallback") checkSelected(report, errors);
    if (scenario === "default-procedural" && report.saltoPresentationRebootEnabled === true) errors.push("Default procedural path enabled the reboot.");
  }
  writeJson(join(root, "v0227-battlefield-visual-rescue-validation-report.json"), {
    schemaVersion: 1,
    checkpoint: "v0.227",
    status: errors.length === 0 ? "PASS_V0227_BATTLEFIELD_VISUAL_RESCUE_VALIDATION" : "FAIL_V0227_BATTLEFIELD_VISUAL_RESCUE_VALIDATION",
    errors
  });
  if (errors.length > 0) throw new Error(errors.join("\n"));
}
function benchmark(root) {
  const errors = [];
  const load = (id) => {
    const path = join(root, "benchmark", id, "worker-art-opt-in-benchmark-runtime.json");
    if (!existsSync(path)) {
      errors.push(`Missing ${rel(path)}`);
      return {};
    }
    return readJson(path);
  };
  const procedural = load("default-procedural");
  const comparator = load("selected-v0224-comparator");
  const selected = load("selected-battlefield-visual-rescue");
  for (const [id, report] of Object.entries({ procedural, comparator, selected })) {
    if (!String(report.status ?? "").startsWith("PASS")) errors.push(`${id} benchmark did not pass.`);
  }
  checkSelected(selected, errors);
  const fpsRatioVsComparator = Number(selected.fpsAverage ?? 0) / Math.max(1, Number(comparator.fpsAverage ?? 0));
  if (fpsRatioVsComparator < 0.80) errors.push("v0.227 FPS regressed more than 20% versus v0.224.");
  writeJson(join(root, "v0227-battlefield-visual-rescue-benchmark-report.json"), {
    schemaVersion: 1,
    checkpoint: "v0.227",
    status: errors.length === 0 ? "PASS_V0227_BATTLEFIELD_VISUAL_RESCUE_BENCHMARK" : "FAIL_V0227_BATTLEFIELD_VISUAL_RESCUE_BENCHMARK",
    procedural: { fpsAverage: procedural.fpsAverage, frameTimeP95Ms: procedural.frameTimeP95Ms },
    v0224Comparator: { fpsAverage: comparator.fpsAverage, frameTimeP95Ms: comparator.frameTimeP95Ms },
    selected: { fpsAverage: selected.fpsAverage, frameTimeP95Ms: selected.frameTimeP95Ms },
    fpsRatioVsComparator: Number(fpsRatioVsComparator.toFixed(4)),
    errors
  });
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
const root = rootFromArgs();
try {
  if (command === "capture") capture(root);
  else if (command === "validation") validation(root);
  else if (command === "benchmark") benchmark(root);
  else throw new Error(`Unknown command: ${command}`);
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
}
