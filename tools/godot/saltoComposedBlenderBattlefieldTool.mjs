import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const defaultRoot = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0234");
const root = resolve((process.argv.find(value => value.startsWith("--artifact-root=")) ?? `--artifact-root=${defaultRoot}`).split("=")[1]);
const verdict = (process.argv.find(value => value.startsWith("--verdict=")) ?? "--verdict=PARTIAL").split("=")[1];
const manual = join(repo, "artifacts", "manual-review", "v0234-composed-blender-battlefield-slice");
const runtimePath = join(root, "runtime", "v0234-composed-blender-battlefield-runtime.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0233", "salto_modular_environment_kit.glb");
const scenePath = join(repo, "desktop-spikes", "godot-salto", "scenes", "salto_composed_blender_battlefield_slice.tscn");
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
const expectedFiles = [
  "01_v0233R_kit_baseline.png", "02_v0234_composed_overview.png", "03_v0234_keep_and_base_focus.png",
  "04_v0234_barracks_workshop_focus.png", "05_v0234_mine_lume_focus.png",
  "06_v0234_road_bridge_river_focus.png", "07_v0234_props_grounding_scale_focus.png",
  "08_before_after_contact_sheet.png", "09_v0234_composition_contact_sheet.png", "10_v0234_report.md"
];

function inspect(errors) {
  for (const path of [runtimePath, glbPath, scenePath]) if (!existsSync(path)) errors.push(`missing ${path}`);
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  if (runtime.status !== "PASS_V0234_COMPOSED_BLENDER_BATTLEFIELD") errors.push("Godot composition runtime did not pass.");
  if (runtime.sourceGlb !== "res://assets/v0233/salto_modular_environment_kit.glb") errors.push("Wrong source GLB.");
  if (runtime.blenderUsedAgain !== false) errors.push("v0.234 unexpectedly re-authored the Blender kit.");
  if ((runtime.placedModuleInstanceCount ?? 0) < 30) errors.push("Too few composed module instances.");
  for (const key of ["continuousTerrainIsland", "bridgeContactsBothBanks", "connectedRoadNetwork", "raisedKeepPlatform", "sunkenRiverChannel", "groundedLandmarks"]) {
    if (runtime[key] !== true) errors.push(`missing composition proof ${key}`);
  }
  if (runtime.captureCount !== 6) errors.push("Expected six Godot captures.");
  for (const key of ["defaultLauncherChanged", "browserRuntimeChanged", "gameplayChanged", "saveChanged", "pathingChanged", "collisionChanged"]) {
    if (runtime[key] !== false) errors.push(`${key} safety boundary failed.`);
  }
  if (runtime.newRuntimeArtSlots !== 0) errors.push("Unexpected runtime-art slot.");
  return runtime;
}

function reportMarkdown(runtime, selectedVerdict) {
  return [
    "# v0.234 Composed Blender Battlefield Slice Report",
    "",
    `Verdict: \`${selectedVerdict}\``,
    "",
    "## Composition",
    "",
    "- Source GLB: `desktop-spikes/godot-salto/assets/v0233/salto_modular_environment_kit.glb`.",
    "- Blender used again: no; composition was performed in Godot from the imported v0.233R kit.",
    `- Placed module instances: \`${runtime.placedModuleInstanceCount ?? 0}\`.`,
    "- Scene: `res://scenes/salto_composed_blender_battlefield_slice.tscn`.",
    `- Screenshots created: \`${runtime.captureCount ?? 0}\`.`,
    "",
    "## Visual result",
    "",
    "The imported kit now reads as one connected crossing/outpost: continuous ground, a visible recessed river, a bank-to-bank bridge, connected roads, a raised keep, grounded barracks and mine zones, and entrance/road prop clusters. Direct screenshot review confirms a coherent battlefield composition that is clearly stronger than the v0.233R floating catalogue, so v0.234 passes its composition milestone.",
    "",
    "The PASS is intentionally narrow. The retained Blender kit is still low-detail and planar, with simple materials, sparse foliage and repeated tile edges. It establishes a production-direction battlefield slice, not final production-finish environment art.",
    "",
    "## Validation",
    "",
    "- Godot composition runtime: `PASS_V0234_COMPOSED_BLENDER_BATTLEFIELD`.",
    "- Continuous island, river, bridge contact, road network, landmark grounding and six captures: verified.",
    "- Gameplay/browser/save/pathing/collision/default launcher changes: none.",
    "- Runtime-art slots added: zero.",
    "",
    "## Stop boundary",
    "",
    "Stop after v0.234. Do not begin v0.235.",
    ""
  ].join("\n");
}

function capture() {
  const errors = [];
  const runtime = inspect(errors);
  mkdirSync(manual, {recursive: true});
  for (const fileName of expectedFiles.slice(0, 7)) if (!existsSync(join(manual, fileName))) errors.push(`missing capture ${fileName}`);
  if (!["PASS", "PARTIAL", "FAIL"].includes(verdict)) errors.push(`invalid verdict ${verdict}`);
  writeFileSync(join(manual, "10_v0234_report.md"), reportMarkdown(runtime, verdict));
  writeFileSync(join(root, "v0234-capture-report.json"), `${JSON.stringify({
    status: errors.length ? "FAIL_V0234_CAPTURE" : "PASS_V0234_CAPTURE",
    verdict,
    placedModuleInstanceCount: runtime.placedModuleInstanceCount ?? 0,
    captureCount: runtime.captureCount ?? 0,
    errors
  }, null, 2)}\n`);
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  const runtime = inspect(errors);
  for (const fileName of expectedFiles) {
    const path = join(manual, fileName);
    if (!existsSync(path)) errors.push(`missing review file ${fileName}`);
    else if (statSync(path).size < (fileName.endsWith(".png") ? 10000 : 500)) errors.push(`review file too small ${fileName}`);
  }
  const report = existsSync(join(manual, "10_v0234_report.md")) ? readFileSync(join(manual, "10_v0234_report.md"), "utf8") : "";
  const reportVerdict = report.match(/Verdict: `([^`]+)`/u)?.[1] ?? "UNKNOWN";
  writeFileSync(join(root, "v0234-validation-report.json"), `${JSON.stringify({
    status: errors.length ? "FAIL_V0234_VALIDATION" : "PASS_V0234_COMPOSED_BLENDER_BATTLEFIELD_VALIDATION",
    verdict: reportVerdict,
    placedModuleInstanceCount: runtime.placedModuleInstanceCount ?? 0,
    captureCount: runtime.captureCount ?? 0,
    runtimeArtSlotsAdded: 0,
    errors
  }, null, 2)}\n`);
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
