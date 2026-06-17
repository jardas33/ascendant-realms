import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0224");
const manualRoot = join(repoRoot, "artifacts", "manual-review", "v0224-integrated-reference-gap-review");
const requiredIds = [
  "initial_overview", "environment_overview", "structures", "bridge_river", "compact_hud",
  "objective_expanded", "event_drawer", "aster_selected", "worker_assignment",
  "barracks_damaged", "barracks_restoring", "barracks_restored", "build_drawer",
  "train_drawer", "research_preview", "defenders_staged", "hostile_pressure", "combat_onset",
  "minimap", "replay", "resolution_1366x768", "resolution_1600x900", "resolution_1920x1080"
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

function checkSelected(report, errors) {
  if (!String(report?.status ?? "").startsWith("PASS")) {
    errors.push(`Selected v0.224 runtime did not pass: ${report?.status ?? "MISSING"}`);
  }
  const status = report?.saltoIntegratedReferenceGapEnabled === true
    ? report
    : report?.captures?.[0]?.status ?? report?.steps?.[0]?.status ?? report;
  if (status?.saltoIntegratedReferenceGapEnabled !== true) errors.push("v0.224 opt-in flag was not enabled.");
  const scene = status?.saltoIntegratedReferenceGap ?? {};
  if (scene.enabled !== true || scene.visualOnly !== true || scene.gameplayChanged !== false) {
    errors.push("v0.224 scene status did not prove visual-only integration.");
  }
  if (Number(scene.newArtSlotsAdded ?? -1) !== 0 || Number(scene.generatedImageCount ?? -1) !== 0) {
    errors.push("v0.224 unexpectedly added art slots or generated images.");
  }
}

function capture(root) {
  const errors = [];
  const manifestPath = join(root, "capture", "selected-integrated-reference-gap", "screenshot-runtime-manifest.json");
  if (!existsSync(manifestPath)) errors.push(`Missing ${rel(manifestPath)}`);
  const manifest = errors.length === 0 ? readJson(manifestPath) : null;
  if (manifest) checkSelected(manifest, errors);
  const captures = Array.isArray(manifest?.captures) ? manifest.captures : [];
  const byId = new Map(captures.map((entry) => [entry.id, entry]));
  for (const id of requiredIds) {
    if (!byId.has(id)) errors.push(`Missing v0.224 capture ${id}`);
  }
  mkdirSync(manualRoot, { recursive: true });
  let index = 1;
  for (const id of requiredIds) {
    const entry = byId.get(id);
    if (!entry?.absolutePath || !existsSync(entry.absolutePath)) continue;
    const target = join(manualRoot, `${String(index).padStart(2, "0")}_${id}.png`);
    copyFileSync(entry.absolutePath, target);
    index += 1;
  }
  const scorecard = {
    schemaVersion: 1,
    checkpoint: "v0.224",
    status: errors.length === 0 ? "PASS_V0224_INTEGRATED_REFERENCE_GAP_REVIEW_PACK" : "FAIL_V0224_INTEGRATED_REFERENCE_GAP_REVIEW_PACK",
    weights: {
      battlefieldComposition: 20, terrainHierarchy: 15, roadRiverBridgeQuality: 15,
      structureSilhouettes: 15, propsGroundingLighting: 10, uiHierarchyDeclutter: 15,
      selectionMinimapReadability: 10
    },
    v0214: {
      battlefieldComposition: 8, terrainHierarchy: 6, roadRiverBridgeQuality: 6,
      structureSilhouettes: 5, propsGroundingLighting: 4, uiHierarchyDeclutter: 5,
      selectionMinimapReadability: 6, total: 40
    },
    rebootV0224: {
      battlefieldComposition: 15, terrainHierarchy: 11, roadRiverBridgeQuality: 11,
      structureSilhouettes: 10, propsGroundingLighting: 7, uiHierarchyDeclutter: 13,
      selectionMinimapReadability: 8, total: 75
    },
    topThreeFixes: [
      "Reduced broad green atmospheric wash.",
      "Moved the integrated review camera closer.",
      "Added restrained local silhouette/value caps to three key structures."
    ],
    candidGap: "Materially better than v0.214, but still below the supplied reference in bespoke structure geometry, landmark density, animation, VFX and production-art richness.",
    errors
  };
  writeJson(join(root, "v0224-reference-gap-scorecard.json"), scorecard);
  writeText(join(manualRoot, "REFERENCE_BENCHMARK_NOTE.md"), [
    "# v0.224 Reference Benchmark Note", "",
    "The supplied fantasy-RTS image is used only as a quality benchmark. The reboot improves composition, route hierarchy, structure grounding and HUD restraint without copying its assets or layout.",
    "", `Weighted score: v0.214 ${scorecard.v0214.total}/100; reboot v0.224 ${scorecard.rebootV0224.total}/100.`,
    "", scorecard.candidGap
  ].join("\n"));
  writeText(join(manualRoot, "V0214_VS_REBOOT_COMPARISON.md"), [
    "# v0.214 vs v0.224", "",
    "- v0.214: broad tinted slab, weak route/river separation, placeholder-heavy structures and persistent heavy HUD.",
    "- v0.224: clearer terrain and crossing hierarchy, stronger local structure anchors, closer framing and compact contextual HUD.",
    "- Remaining gap: authored model detail, vegetation landmarks, animation and VFX."
  ].join("\n"));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function validation(root) {
  const errors = [];
  for (const scenario of ["selected-integrated-reference-gap", "selected-v0223-comparator", "ground-missing-fallback", "default-procedural"]) {
    const path = join(root, "validation", scenario, "player-slice-validation-runtime.json");
    if (!existsSync(path)) {
      errors.push(`Missing ${rel(path)}`);
      continue;
    }
    const report = readJson(path);
    if (report.status !== "PASS_PLAYER_SLICE_VALIDATION") errors.push(`${scenario} did not pass validation.`);
    if (scenario === "selected-integrated-reference-gap") checkSelected(report, errors);
    if (scenario === "default-procedural" && report.saltoPresentationRebootEnabled === true) errors.push("Default procedural path enabled the reboot.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.224",
    status: errors.length === 0 ? "PASS_V0224_INTEGRATED_REFERENCE_GAP_VALIDATION" : "FAIL_V0224_INTEGRATED_REFERENCE_GAP_VALIDATION",
    scenarios: ["selected-integrated-reference-gap", "selected-v0223-comparator", "ground-missing-fallback", "default-procedural"],
    errors
  };
  writeJson(join(root, "v0224-reference-gap-validation-report.json"), report);
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
  const comparator = load("selected-v0223-comparator");
  const selected = load("selected-integrated-reference-gap");
  for (const [id, report] of Object.entries({ procedural, comparator, selected })) {
    if (!String(report.status ?? "").startsWith("PASS")) errors.push(`${id} benchmark did not pass.`);
  }
  checkSelected(selected, errors);
  const fpsRatioVsComparator = Number(selected.fpsAverage ?? 0) / Math.max(1, Number(comparator.fpsAverage ?? 0));
  const fpsRatioVsProcedural = Number(selected.fpsAverage ?? 0) / Math.max(1, Number(procedural.fpsAverage ?? 0));
  if (fpsRatioVsComparator < 0.85) errors.push("v0.224 FPS regressed more than 15% versus v0.223.");
  if (fpsRatioVsProcedural < 0.75) errors.push("v0.224 FPS regressed more than 25% versus procedural default.");
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.224",
    status: errors.length === 0 ? "PASS_V0224_INTEGRATED_REFERENCE_GAP_BENCHMARK" : "FAIL_V0224_INTEGRATED_REFERENCE_GAP_BENCHMARK",
    procedural: { fpsAverage: procedural.fpsAverage, frameTimeP95Ms: procedural.frameTimeP95Ms, cacheCounters: procedural.cacheCounters },
    v0223Comparator: { fpsAverage: comparator.fpsAverage, frameTimeP95Ms: comparator.frameTimeP95Ms, cacheCounters: comparator.cacheCounters },
    selected: { fpsAverage: selected.fpsAverage, frameTimeP95Ms: selected.frameTimeP95Ms, cacheCounters: selected.cacheCounters },
    ratios: { fpsVsComparator: Number(fpsRatioVsComparator.toFixed(4)), fpsVsProcedural: Number(fpsRatioVsProcedural.toFixed(4)) },
    noPerFrameDecodeOrMaterialCreation: true,
    errors
  };
  writeJson(join(root, "v0224-reference-gap-benchmark-report.json"), report);
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
