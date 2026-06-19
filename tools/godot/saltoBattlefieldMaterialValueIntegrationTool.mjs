import {copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const rootDefault = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0231");
const manual = join(repo, "artifacts", "manual-review", "v0231-battlefield-material-value-integration");
const ids = [
  "overview", "ground_value_palette", "road_integration", "river_bank_integration",
  "structure_grounding_keep_barracks", "mine_lume_grounding", "bridge_river_contact",
  "normal_zoom_readability", "hostile_pressure", "train_drawer",
  "resolution_1366x768", "resolution_1600x900", "resolution_1920x1080"
];
const root = resolve((process.argv.find(value => value.startsWith("--artifact-root=")) ?? `--artifact-root=${rootDefault}`).split("=")[1]);
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
const write = (path, value) => {
  mkdirSync(dirname(path), {recursive: true});
  writeFileSync(path, `${JSON.stringify(value, null, 2)}\n`);
};
const status = report => report?.saltoBattlefieldMaterialValueIntegrationEnabled === true
  ? report
  : report?.captures?.[0]?.status ?? report?.steps?.[0]?.status ?? report;

function check(report, errors) {
  const current = status(report);
  const integration = current?.saltoBattlefieldMaterialValueIntegration ?? {};
  if (current?.saltoBattlefieldMaterialValueIntegrationEnabled !== true) errors.push("v0.231 flag missing");
  if (integration.enabled !== true || integration.visualOnly !== true || integration.gameplayChanged !== false) errors.push("v0.231 visual-only status failed");
  if (integration.retainsV0230Structures !== true || integration.retainsV0230Comparator !== true) errors.push("v0.230 retention contract failed");
  for (const key of ["warmEarthGroundPalette", "irregularGroundValueMasses", "wornRoadShouldersAndRuts", "opaqueShapedRiver", "layeredDryAndWetBanks", "localStructureGrounding"]) {
    if (integration[key] !== true) errors.push(`${key} contract failed`);
  }
  if (integration.structureGeometryReopened !== false) errors.push("structure geometry boundary failed");
  if (Number(integration.generatedProjectSourceImageCount ?? -1) !== 0
      || Number(integration.downloadedAssetCount ?? -1) !== 0
      || Number(integration.newRuntimeArtSlotsAdded ?? -1) !== 0) errors.push("unexpected source/download/runtime slot count");
  if (integration.pathingChanged !== false || integration.collisionChanged !== false
      || integration.defaultLauncherChanged !== false || integration.browserRuntimeChanged !== false) errors.push("v0.231 safety exclusions failed");
}

function capture() {
  const errors = [];
  const path = join(root, "capture", "selected-battlefield-material-value-integration", "screenshot-runtime-manifest.json");
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
  writeFileSync(join(manual, "15_notes.md"), [
    "# v0.231 Battlefield Material and Value Integration Notes",
    "",
    "## What changed",
    "",
    "- Replaced the retained v0.228 battlefield layer only inside the isolated v0.231 path with opaque irregular ground value masses, layered worn roads, a shaped opaque river, dry/wet bank bands and local structure contact treatment.",
    "- Preserved the complete v0.230 authored keep, barracks, mine/Lume, ford-support and bridge-support geometry without reopening their massing.",
    "",
    "## Did terrain stop reading as a flat olive debug board?",
    "",
    "- Yes. The selected path now separates warm worked earth, muted grass, dry field, cool central ground and hostile-side value zones while keeping the battlefield readable at normal zoom.",
    "",
    "## Are roads integrated?",
    "",
    "- Partially. Routes now have soil-matched shoulders, compacted bodies, narrower dust lanes and paired wear ruts, but the layered bands remain more schematic than final natural road art.",
    "",
    "## Does the river still read as rectangular debug transparency?",
    "",
    "- No. The selected river is now an opaque tapered channel rather than overlapping transparent rectangles. Its deep, mid, highlight and bank bands are readable, though segment joins remain visible at close review.",
    "",
    "## Are structures grounded without reopening geometry?",
    "",
    "- Yes. Local footprint shadows, yard stones, mine tailings and bridge contact treatment ground the retained v0.230 structures without changing their authored geometry or footprints.",
    "",
    "## Weakest remaining area",
    "",
    "- The road and river band transitions remain the weakest integration gap: materially clearer and more grounded than v0.230, but still visibly procedural. Fine-grained building-surface variation also remains outside this milestone.",
    "",
    "## Next milestone",
    "",
    "- Stop at v0.231. Any next milestone requires a new explicit prompt and should be selected only after review of this retained integration pack.",
    ""
  ].join("\n"));
  write(join(root, "v0231-capture-report.json"), {
    status: errors.length ? "FAIL_V0231_CAPTURE" : "PASS_V0231_CAPTURE",
    generatedProjectSourceImageCount: 0, downloadedAssetCount: 0, newRuntimeArtSlotsAdded: 0, errors
  });
  if (errors.length) throw Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  for (const id of ["selected-battlefield-material-value-integration", "selected-v0230-comparator", "ground-missing-fallback", "default-procedural"]) {
    const path = join(root, "validation", id, "player-slice-validation-runtime.json");
    if (!existsSync(path)) { errors.push(`missing ${id}`); continue; }
    const report = read(path);
    if (report.status !== "PASS_PLAYER_SLICE_VALIDATION") errors.push(`${id} failed`);
    if (id === "selected-battlefield-material-value-integration" || id === "ground-missing-fallback") check(report, errors);
    const current = status(report);
    if (id === "selected-v0230-comparator" && current.saltoBattlefieldMaterialValueIntegrationEnabled === true) errors.push("v0.230 comparator contaminated");
    if (id === "selected-v0230-comparator" && current.saltoStructureArtFidelityEnabled !== true) errors.push("v0.230 comparator missing");
    if (id === "default-procedural" && report.saltoPresentationRebootEnabled === true) errors.push("default changed");
  }
  write(join(root, "v0231-validation-report.json"), {
    status: errors.length ? "FAIL_V0231_VALIDATION" : "PASS_V0231_VALIDATION",
    fallbackChecked: true, v0230ComparatorChecked: true, runtimeArtSlotsAdded: 0, errors
  });
  if (errors.length) throw Error(errors.join("\n"));
}

function benchmark() {
  const errors = [];
  const load = id => {
    const path = join(root, "benchmark", id, "worker-art-opt-in-benchmark-runtime.json");
    if (!existsSync(path)) { errors.push(`missing ${id}`); return {}; }
    return read(path);
  };
  const comparator = load("selected-v0230-comparator");
  const selected = load("selected-battlefield-material-value-integration");
  const procedural = load("default-procedural");
  check(selected, errors);
  const ratio = Number(selected.fpsAverage ?? 0) / Math.max(1, Number(comparator.fpsAverage ?? 0));
  if (ratio < 0.8) errors.push("fps regression >20%");
  write(join(root, "v0231-benchmark-report.json"), {
    status: errors.length ? "FAIL_V0231_BENCHMARK" : "PASS_V0231_BENCHMARK",
    procedural, v0230Comparator: comparator, selected, fpsRatioVsComparator: Number(ratio.toFixed(4)), errors
  });
  if (errors.length) throw Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else if (command === "benchmark") benchmark();
else throw Error("unknown command");
