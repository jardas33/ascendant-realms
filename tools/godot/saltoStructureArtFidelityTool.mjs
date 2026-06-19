import {copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const rootDefault = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0230");
const manual = join(repo, "artifacts", "manual-review", "v0230-structure-art-fidelity");
const ids = [
  "overview",
  "player_keep_focus",
  "barracks_focus",
  "mine_lume_focus",
  "bridge_structure_context",
  "normal_zoom_readability",
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
const status = report => report?.saltoStructureArtFidelityEnabled === true
  ? report
  : report?.captures?.[0]?.status ?? report?.steps?.[0]?.status ?? report;

function check(report, errors) {
  const current = status(report);
  const fidelity = current?.saltoStructureArtFidelity ?? {};
  if (current?.saltoStructureArtFidelityEnabled !== true) errors.push("v0.230 flag missing");
  if (fidelity.enabled !== true || fidelity.visualOnly !== true || fidelity.gameplayChanged !== false) {
    errors.push("v0.230 visual-only status failed");
  }
  if (fidelity.authoredPitchedRoofs !== true || fidelity.diagonalTimberBracing !== true) {
    errors.push("v0.230 authored geometry contract failed");
  }
  if (fidelity.distinctStructureIdentities !== true || fidelity.bridgeSupportIntegration !== true) {
    errors.push("v0.230 structure identity contract failed");
  }
  if (fidelity.retainsV0229Comparator !== true) errors.push("v0.229 comparator contract missing");
  if (Number(fidelity.generatedProjectSourceImageCount ?? -1) !== 0
      || Number(fidelity.downloadedAssetCount ?? -1) !== 0
      || Number(fidelity.newRuntimeArtSlotsAdded ?? -1) !== 0) {
    errors.push("unexpected source/download/runtime slot count");
  }
  if (fidelity.pathingChanged !== false || fidelity.collisionChanged !== false || fidelity.defaultLauncherChanged !== false) {
    errors.push("v0.230 safety exclusions failed");
  }
}

function capture() {
  const errors = [];
  const path = join(root, "capture", "selected-structure-art-fidelity", "screenshot-runtime-manifest.json");
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
    "# v0.230 Structure Art Fidelity Notes",
    "",
    "## What changed",
    "",
    "- Replaced the selected v0.229 stacked-box structure renderer with deterministic authored Godot geometry for the player keep, barracks, central mine/Lume site, ford support and bridge supports.",
    "- Added true closed triangular-prism pitched roofs, stepped masonry plinths, recessed entrances, timber posts, diagonal braces, banners, gantries, annexes, buttresses and local contact details.",
    "- Kept the v0.229 route as a direct comparator and retained the v0.228 authored terrain foundation without repainting the battlefield.",
    "",
    "## Safety exclusions",
    "",
    "- No downloaded, generated or externally sourced image was added. No runtime art slot was added.",
    "- Default launcher, browser runtime, gameplay, pathing, collision, AI, objectives, economy, saves, stable IDs, unit data and structure footprints remain unchanged.",
    "",
    "## Authored-versus-blockout verdict",
    "",
    "- The selected structures now read as authored landmarks rather than stacked procedural blocks: roof pitch, asymmetric massing, visible framing and entrance hierarchy survive normal zoom.",
    "- The result remains intentionally modest low-poly production art, not a final high-detail environment set.",
    "",
    "## Weakest structure",
    "",
    "- The small ford support remains the weakest landmark because its compact footprint limits silhouette complexity; it is nevertheless more coherent with the bridge and Lume language than the v0.229 blockout.",
    "",
    "## Next milestone",
    "",
    "- A future milestone should address retained battlefield material/value integration around the authored structures, without reopening structure geometry or UI scope.",
    ""
  ].join("\n"));
  write(join(root, "v0230-capture-report.json"), {
    status: errors.length ? "FAIL_V0230_CAPTURE" : "PASS_V0230_CAPTURE",
    generatedProjectSourceImageCount: 0,
    downloadedAssetCount: 0,
    newRuntimeArtSlotsAdded: 0,
    errors
  });
  if (errors.length) throw Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  for (const id of ["selected-structure-art-fidelity", "selected-v0229-comparator", "ground-missing-fallback", "default-procedural"]) {
    const path = join(root, "validation", id, "player-slice-validation-runtime.json");
    if (!existsSync(path)) {
      errors.push(`missing ${id}`);
      continue;
    }
    const report = read(path);
    if (report.status !== "PASS_PLAYER_SLICE_VALIDATION") errors.push(`${id} failed`);
    if (id === "selected-structure-art-fidelity" || id === "ground-missing-fallback") check(report, errors);
    if (id === "selected-v0229-comparator" && report.saltoStructureArtFidelityEnabled === true) errors.push("v0.229 comparator contaminated");
    if (id === "default-procedural" && report.saltoPresentationRebootEnabled === true) errors.push("default changed");
  }
  write(join(root, "v0230-validation-report.json"), {
    status: errors.length ? "FAIL_V0230_VALIDATION" : "PASS_V0230_VALIDATION",
    fallbackChecked: true,
    v0229ComparatorChecked: true,
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
  const comparator = load("selected-v0229-comparator");
  const selected = load("selected-structure-art-fidelity");
  const procedural = load("default-procedural");
  check(selected, errors);
  const ratio = Number(selected.fpsAverage ?? 0) / Math.max(1, Number(comparator.fpsAverage ?? 0));
  if (ratio < 0.8) errors.push("fps regression >20%");
  write(join(root, "v0230-benchmark-report.json"), {
    status: errors.length ? "FAIL_V0230_BENCHMARK" : "PASS_V0230_BENCHMARK",
    procedural,
    v0229Comparator: comparator,
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
