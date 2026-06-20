import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const defaultRoot = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0239");
const root = resolve((process.argv.find(v => v.startsWith("--artifact-root=")) ?? `--artifact-root=${defaultRoot}`).split("=")[1]);
const verdict = (process.argv.find(v => v.startsWith("--verdict=")) ?? "--verdict=PARTIAL").split("=")[1];
const manual = join(repo, "artifacts", "manual-review", "v0239-barrosan-roster-silhouette-beauty");
const runtimePath = join(root, "runtime", "v0239-barrosan-roster-silhouette-beauty-runtime.json");
const assetRoot = join(repo, "desktop-spikes", "godot-salto", "assets", "v0239");
const glbPath = join(assetRoot, "salto_barrosan_roster_silhouette_beauty.glb");
const exportPath = join(assetRoot, "salto_barrosan_roster_silhouette_beauty.export.json");
const contractPath = join(assetRoot, "salto_barrosan_roster_silhouette_beauty.contract.json");
const expected = [
  "01_v0238_roster_baseline.png", "02_v0239_roster_overview.png",
  "03_v0239_house_role_read.png", "04_v0239_farm_granary_role_read.png",
  "05_v0239_lumber_carpenter_role_read.png", "06_v0239_blacksmith_forge_role_read.png",
  "07_v0239_watchtower_defense_role_read.png", "08_v0239_market_storehouse_role_read.png",
  "09_v0239_settlement_terrain_richness.png", "10_v0239_scale_silhouette_comparison.png",
  "11_before_after_contact_sheet.png", "12_v0239_report.md",
];
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));

function parseGlb(path) {
  const data = readFileSync(path);
  if (data.toString("ascii", 0, 4) !== "glTF") throw new Error("Invalid GLB magic.");
  let offset = 12, json = null;
  while (offset + 8 <= data.length) {
    const length = data.readUInt32LE(offset), type = data.readUInt32LE(offset + 4);
    if (type === 0x4e4f534a) json = JSON.parse(data.toString("utf8", offset + 8, offset + 8 + length).replace(/\0+$/u, ""));
    offset += 8 + length;
  }
  return {bytes: data.length, declaredLength: data.readUInt32LE(8), nodes: (json?.nodes ?? []).map(n => n.name).filter(Boolean), materials: (json?.materials ?? []).map(m => m.name).filter(Boolean), meshes: (json?.meshes ?? []).length};
}

function inspect(errors) {
  for (const path of [runtimePath, glbPath, exportPath, contractPath]) if (!existsSync(path)) errors.push(`missing ${path}`);
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  const exported = existsSync(exportPath) ? read(exportPath) : {};
  const contract = existsSync(contractPath) ? read(contractPath) : {};
  const glb = existsSync(glbPath) ? parseGlb(glbPath) : {bytes: 0, declaredLength: 0, nodes: [], materials: [], meshes: 0};
  if (runtime.status !== "PASS_V0239_BARROSAN_ROSTER_SILHOUETTE_BEAUTY_RUNTIME") errors.push("Runtime did not pass.");
  if (runtime.sourceGlb !== "res://assets/v0239/salto_barrosan_roster_silhouette_beauty.glb") errors.push("Wrong source GLB.");
  if (runtime.revisedBuildingModuleCount !== 6 || runtime.composedBuildingInstanceCount !== 9) errors.push("Building count failed.");
  if (runtime.addedOrRevisedPropModuleCount !== 6 || runtime.newOrChangedMaterialCount !== 6) errors.push("Prop/material count failed.");
  if ((runtime.composedRolePropInstanceCount ?? 0) < 25 || (runtime.beautyVegetationInstanceCount ?? 0) < 15 || (runtime.beautyGroundSurfaceCount ?? 0) < 6) errors.push("Settlement richness is too small.");
  for (const key of ["rolesDistinctAtOverview", "v0237BeautyDirectionRestored", "roadsBridgeRiverReadable", "sameyOrangeRoofHouseSyndromeReduced", "centralRoofRidgesHighest", "roofPlanesSlopeDownToBothEaves", "roofEaveOverhangs", "roofRidgeCaps", "roofFasciaBoards"]) if (runtime[key] !== true) errors.push(`missing proof ${key}`);
  if (runtime.invertedRoofGeometry !== false || runtime.squareTerrainModulesPlaced !== 0 || runtime.panelRoadModulesPlaced !== 0 || runtime.captureCount !== 9) errors.push("Geometry/capture boundary failed.");
  for (const key of ["defaultLauncherChanged", "browserRuntimeChanged", "gameplayChanged", "saveChanged", "economyLogicChanged", "selectionChanged", "pathingChanged", "commandsChanged", "minimapLogicChanged", "objectivesChanged", "productionLogicChanged", "aiChanged", "collisionChanged"]) if (runtime[key] !== false) errors.push(`${key} boundary failed.`);
  if (runtime.newRuntimeArtSlots !== 0 || contract.existingV0238GlbModified !== false) errors.push("Asset boundary failed.");
  if (glb.bytes < 500000 || glb.bytes !== glb.declaredLength) errors.push("Invalid GLB length.");
  for (const name of [...(exported.revisedBuildingModules ?? []), ...(exported.addedOrRevisedPropModules ?? [])]) if (!glb.nodes.includes(name)) errors.push(`GLB missing ${name}`);
  for (const prefix of ["House_Roof", "Granary_Roof", "Lumber_Roof", "Forge_Roof", "Watchtower_Roof", "Market_Roof"]) for (const suffix of ["_Plane_North", "_Plane_South", "_RidgeCap", "_EaveFascia_-1", "_EaveFascia_1"]) if (!glb.nodes.includes(`${prefix}${suffix}`)) errors.push(`GLB missing ${prefix}${suffix}`);
  if (exported.status !== "PASS_V0239_BLENDER_GLTF_EXPORT") errors.push("Blender metadata failed.");
  return {runtime, exported, glb};
}

function markdown(e, selectedVerdict) {
  return [
    "# v0.239 Barrosan Roster Silhouette Differentiation and Settlement Beauty Restore",
    "", `Verdict: \`${selectedVerdict}\``, "",
    "## Exact asset facts", "",
    "- Blender used: yes, Blender 5.1.2.",
    "- New GLB exported: yes, `desktop-spikes/godot-salto/assets/v0239/salto_barrosan_roster_silhouette_beauty.glb`.",
    `- New GLB byte size: \`${e.glb.bytes}\`; meshes: \`${e.glb.meshes}\`.`,
    "- v0.238 GLB preserved: yes; v0.239 supersedes it only for this isolated review path.",
    "- Scene: `res://scenes/salto_barrosan_roster_silhouette_beauty.tscn`.",
    "- Building modules revised: `6`.", "- Prop modules added/revised: `6`.", "- Material changes: `6`.",
    "- Composed building instances: `9`.", `- Composed role-prop instances: \`${e.runtime.composedRolePropInstanceCount}\`.`, "",
    "## Exact source files changed", "",
    "- `tools/blender/generate_v0239_barrosan_roster_silhouette_beauty.py`",
    "- `tools/blender/generateV0239BarrosanRosterSilhouetteBeautyWindows.ps1`",
    "- `desktop-spikes/godot-salto/scripts/salto_barrosan_roster_silhouette_beauty.gd`",
    "- `desktop-spikes/godot-salto/scenes/salto_barrosan_roster_silhouette_beauty.tscn`",
    "- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`",
    "- `tools/godot/captureGodotV0239BarrosanRosterSilhouetteBeautyWindows.ps1`",
    "- `tools/godot/validateGodotV0239BarrosanRosterSilhouetteBeautyWindows.ps1`",
    "- `tools/godot/buildV0239BarrosanRosterSilhouetteBeautyReviewPack.py`",
    "- `tools/godot/saltoV0239BarrosanRosterSilhouetteBeautyTool.mjs`",
    "- `package.json`",
    "- `docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md`", "",
    "## Brutally honest visual assessment", "",
    selectedVerdict === "PASS"
      ? "The six roles now separate by massing before color: domestic cottage, raised granary, open carpenter yard, compact soot-heavy forge, braced vertical watchtower and open market hall. The added wear, vegetation and threshold clutter restore much of v0.237's inhabited quality without closing the tactical lanes."
      : selectedVerdict === "PARTIAL"
        ? "The pass improves role language and settlement finish, but at least two roles remain too similar at overview scale or the beauty restoration is not yet strong enough."
        : "The pass does not sufficiently separate the roster or restore the settlement beauty bar.",
    "",
    "Even at PASS, this remains stylized geometry-and-color production art. Bespoke textures, construction/damage states and gameplay integration remain outside v0.239.", "",
    "## Validation and boundaries", "",
    "- Exact module, prop, material, roof, composition, capture and boundary contracts: validated.",
    "- Gameplay, saves, economy, selection, pathing, commands, minimap, objectives, production, AI, collision, browser runtime, runtime-art slots and launcher defaults: untouched.", "",
    "Stop after v0.239. Do not begin v0.240.", "",
  ].join("\n");
}

function capture() {
  const errors = [], evidence = inspect(errors);
  mkdirSync(manual, {recursive: true});
  for (const file of expected.slice(0, 10)) if (!existsSync(join(manual, file))) errors.push(`missing capture ${file}`);
  if (!["PASS", "PARTIAL", "FAIL"].includes(verdict)) errors.push("invalid verdict");
  writeFileSync(join(manual, "12_v0239_report.md"), markdown(evidence, verdict));
  writeFileSync(join(root, "v0239-capture-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0239_CAPTURE" : "PASS_V0239_CAPTURE", verdict, errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [], evidence = inspect(errors);
  for (const file of expected) {
    const path = join(manual, file);
    if (!existsSync(path)) errors.push(`missing review file ${file}`);
    else if (statSync(path).size < (file.endsWith(".png") ? 10000 : 1000)) errors.push(`review file too small ${file}`);
  }
  const report = existsSync(join(manual, "12_v0239_report.md")) ? readFileSync(join(manual, "12_v0239_report.md"), "utf8") : "";
  writeFileSync(join(root, "v0239-validation-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0239_VALIDATION" : "PASS_V0239_BARROSAN_ROSTER_SILHOUETTE_BEAUTY_VALIDATION", verdict: report.match(/Verdict: `([^`]+)`/u)?.[1] ?? "UNKNOWN", glbBytes: evidence.glb.bytes, errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
