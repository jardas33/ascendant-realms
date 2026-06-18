import {copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const rootDefault = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0229");
const manual = join(repo, "artifacts", "manual-review", "v0229-structure-landmark-fidelity");
const ids = [
  "overview",
  "haze_value_cleanup",
  "player_base_focus",
  "barracks_focus",
  "central_landmark_focus",
  "bridge_river_context",
  "hostile_pressure",
  "train_drawer",
  "resolution_1366x768",
  "resolution_1600x900",
  "resolution_1920x1080"
];
const root = resolve((process.argv.find(value => value.startsWith("--artifact-root=")) ?? `--artifact-root=${rootDefault}`).split("=")[1]);
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
const write = (path, value) => {
  mkdirSync(dirname(path), {recursive: true});
  writeFileSync(path, `${JSON.stringify(value, null, 2)}\n`);
};
const status = report => report?.saltoStructureLandmarkFidelityEnabled === true
  ? report
  : report?.captures?.[0]?.status ?? report?.steps?.[0]?.status ?? report;

function check(report, errors) {
  const current = status(report);
  const fidelity = current?.saltoStructureLandmarkFidelity ?? {};
  if (current?.saltoStructureLandmarkFidelityEnabled !== true) errors.push("v0.229 flag missing");
  if (fidelity.enabled !== true || fidelity.visualOnly !== true || fidelity.gameplayChanged !== false) {
    errors.push("v0.229 visual-only status failed");
  }
  if (fidelity.broadFieldOverlaysRemoved !== true || fidelity.opaqueStructureSilhouettes !== true) {
    errors.push("v0.229 haze or structure contract failed");
  }
  if (Number(fidelity.generatedProjectSourceImageCount ?? -1) !== 0 || Number(fidelity.newRuntimeArtSlotsAdded ?? -1) !== 0) {
    errors.push("unexpected source/runtime slot count");
  }
}

function capture() {
  const errors = [];
  const path = join(root, "capture", "selected-structure-landmark-fidelity", "screenshot-runtime-manifest.json");
  if (!existsSync(path)) errors.push("missing capture manifest");
  const manifest = errors.length ? {} : read(path);
  check(manifest, errors);
  const byId = new Map((manifest.captures ?? []).map(capture => [capture.id, capture]));
  mkdirSync(manual, {recursive: true});
  ids.forEach((id, index) => {
    const capture = byId.get(id);
    if (!capture?.absolutePath || !existsSync(capture.absolutePath)) errors.push(`missing ${id}`);
    else copyFileSync(capture.absolutePath, join(manual, `${String(index + 1).padStart(2, "0")}_${id}.png`));
  });
  writeFileSync(join(manual, "13_notes.md"), [
    "# v0.229 Structure Landmark Fidelity Notes",
    "",
    "- No new source image or atlas was created. The selected review path uses retained procedural Godot geometry and existing approved ground, road, riverbank and water materials.",
    "- Broad legacy review-value strips and translucent field dressing are excluded from the v0.229 path; only local contact shadows and small physical props remain.",
    "- The player keep, barracks and central mine/Lume utility site receive opaque roof, wall, foundation, entrance and landmark geometry without changing gameplay footprints.",
    "- The existing v0.202 structure-finish texture remains preserved as a fallback/comparator asset but is intentionally not bound on this path because its box-wide projection read as texture cards.",
    "- Default launcher, browser runtime, gameplay, pathing, collision, objectives, AI, saves, economy, stable IDs and unit data remain unchanged.",
    ""
  ].join("\n"));
  write(join(root, "v0229-capture-report.json"), {
    status: errors.length ? "FAIL_V0229_CAPTURE" : "PASS_V0229_CAPTURE",
    generatedProjectSourceImageCount: 0,
    newRuntimeArtSlotsAdded: 0,
    errors
  });
  if (errors.length) throw Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  for (const id of ["selected-structure-landmark-fidelity", "selected-v0228-comparator", "ground-missing-fallback", "default-procedural"]) {
    const path = join(root, "validation", id, "player-slice-validation-runtime.json");
    if (!existsSync(path)) {
      errors.push(`missing ${id}`);
      continue;
    }
    const report = read(path);
    if (report.status !== "PASS_PLAYER_SLICE_VALIDATION") errors.push(`${id} failed`);
    if (id === "selected-structure-landmark-fidelity" || id === "ground-missing-fallback") check(report, errors);
    if (id === "default-procedural" && report.saltoPresentationRebootEnabled === true) errors.push("default changed");
  }
  write(join(root, "v0229-validation-report.json"), {
    status: errors.length ? "FAIL_V0229_VALIDATION" : "PASS_V0229_VALIDATION",
    fallbackChecked: true,
    runtimeArtSlotsAdded: 0,
    errors
  });
  if (errors.length) throw Error(errors.join("\n"));
}

function benchmark() {
  const errors = [];
  const load = id => {
    const path = join(root, "benchmark", id, "worker-art-opt-in-benchmark-runtime.json");
    if (!existsSync(path)) {
      errors.push(`missing ${id}`);
      return {};
    }
    return read(path);
  };
  const comparator = load("selected-v0228-comparator");
  const selected = load("selected-structure-landmark-fidelity");
  const procedural = load("default-procedural");
  check(selected, errors);
  const ratio = Number(selected.fpsAverage ?? 0) / Math.max(1, Number(comparator.fpsAverage ?? 0));
  if (ratio < 0.8) errors.push("fps regression >20%");
  write(join(root, "v0229-benchmark-report.json"), {
    status: errors.length ? "FAIL_V0229_BENCHMARK" : "PASS_V0229_BENCHMARK",
    procedural,
    v0228Comparator: comparator,
    selected,
    fpsRatioVsComparator: Number(ratio.toFixed(4)),
    errors
  });
  if (errors.length) throw Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else if (command === "benchmark") benchmark();
else throw Error("unknown command");
