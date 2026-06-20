import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const defaultRoot = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0238");
const root = resolve((process.argv.find(v => v.startsWith("--artifact-root=")) ?? `--artifact-root=${defaultRoot}`).split("=")[1]);
const verdict = (process.argv.find(v => v.startsWith("--verdict=")) ?? "--verdict=PARTIAL").split("=")[1];
const manual = join(repo, "artifacts", "manual-review", "v0238-barrosan-building-roster");
const runtimePath = join(root, "runtime", "v0238-barrosan-building-roster-runtime.json");
const assetRoot = join(repo, "desktop-spikes", "godot-salto", "assets", "v0238");
const glbPath = join(assetRoot, "salto_barrosan_building_roster.glb");
const exportPath = join(assetRoot, "salto_barrosan_building_roster.export.json");
const contractPath = join(assetRoot, "salto_barrosan_building_roster.contract.json");
const blendPath = join(repo, "art-source", "blender", "v0238", "salto_barrosan_building_roster.blend");
const scenePath = join(repo, "desktop-spikes", "godot-salto", "scenes", "salto_barrosan_building_roster.tscn");
const biblePath = join(repo, "docs", "art", "V0236_BARROSAN_FACTION_ART_BIBLE.md");
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
const expected = [
  "01_v0237_baseline_overview.png", "02_v0238_roster_overview.png",
  "03_v0238_house_dwelling.png", "04_v0238_farm_granary.png",
  "05_v0238_lumber_carpenter_yard.png", "06_v0238_blacksmith_forge.png",
  "07_v0238_watchtower_defense.png", "08_v0238_market_storehouse.png",
  "10_v0238_scale_and_role_readability.png", "11_before_after_contact_sheet.png",
  "12_v0238_report.md",
];

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
  for (const path of [runtimePath, glbPath, exportPath, contractPath, blendPath, scenePath, biblePath]) if (!existsSync(path)) errors.push(`missing ${path}`);
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  const exported = existsSync(exportPath) ? read(exportPath) : {};
  const contract = existsSync(contractPath) ? read(contractPath) : {};
  const glb = existsSync(glbPath) ? parseGlb(glbPath) : {bytes: 0, declaredLength: 0, nodes: [], materials: [], meshes: 0};
  const bible = existsSync(biblePath) ? readFileSync(biblePath, "utf8") : "";
  if (runtime.status !== "PASS_V0238_BARROSAN_BUILDING_ROSTER_RUNTIME") errors.push("Runtime did not pass.");
  if (runtime.sourceGlb !== "res://assets/v0238/salto_barrosan_building_roster.glb") errors.push("Wrong source GLB.");
  if (runtime.blenderUsed !== true || runtime.newV0238GlbExported !== true || runtime.existingV0237GlbModified !== false) errors.push("Asset boundary failed.");
  if (runtime.newBuildingModuleCount !== 6 || runtime.newBuildingModules?.length !== 6) errors.push("Expected exactly six new buildings.");
  if (runtime.newPropModuleCount !== 8 || runtime.newPropModules?.length !== 8) errors.push("Expected exactly eight new prop modules.");
  if (runtime.newOrChangedMaterialCount !== 10) errors.push("Expected exactly ten new/changed materials.");
  if (runtime.composedBuildingInstanceCount !== 9 || runtime.composedBuildingInstances?.length !== 9) errors.push("Expected nine composed buildings.");
  if ((runtime.rosterPropInstanceCount ?? 0) < 14) errors.push("Role prop composition is too small.");
  for (const key of ["coherentSettlementLayout", "rolesDistinctBySilhouette", "roleSpecificPropClusterPerBuilding", "doorsAlignedToRoadsAndYards", "existingLandmarkTrioRetained", "keepRemainsTallestCivicLandmark", "mineRemainsPrimaryLumeLandmark", "barracksRemainsPrimaryMilitaryProduction", "centralRoofRidgesHighest", "roofPlanesSlopeDownToBothEaves", "roofEaveOverhangs", "roofRidgeCaps", "roofFasciaBoards"]) if (runtime[key] !== true) errors.push(`missing proof ${key}`);
  if (runtime.floatingCatalogueTiles !== false || runtime.invertedRoofGeometry !== false) errors.push("Catalogue/roof boundary failed.");
  if (runtime.squareTerrainModulesPlaced !== 0 || runtime.panelRoadModulesPlaced !== 0) errors.push("Legacy terrain/road modules placed.");
  if (runtime.captureCount !== 8) errors.push("Expected eight captures.");
  for (const key of ["defaultLauncherChanged", "browserRuntimeChanged", "gameplayChanged", "saveChanged", "economyLogicChanged", "selectionChanged", "pathingChanged", "commandsChanged", "minimapLogicChanged", "objectivesChanged", "productionLogicChanged", "aiChanged", "collisionChanged"]) if (runtime[key] !== false) errors.push(`${key} boundary failed.`);
  if (runtime.newRuntimeArtSlots !== 0) errors.push("Unexpected runtime art slot.");
  if (glb.bytes < 500000 || glb.bytes !== glb.declaredLength) errors.push("Invalid GLB length.");
  for (const name of [...(contract.newBuildingModules ?? []), ...(contract.newPropModules ?? [])]) if (!glb.nodes.includes(name)) errors.push(`GLB missing ${name}`);
  const roofPrefixes = ["House_Roof", "Granary_Roof", "Lumber_Roof", "Forge_Roof", "Watchtower_Roof", "Market_Roof"];
  for (const prefix of roofPrefixes) for (const suffix of ["_Plane_North", "_Plane_South", "_RidgeCap", "_EaveFascia_-1", "_EaveFascia_1"]) if (!glb.nodes.includes(`${prefix}${suffix}`)) errors.push(`GLB missing ${prefix}${suffix}`);
  for (const name of exported.newOrChangedMaterialNames ?? []) if (!glb.materials.includes(name)) errors.push(`GLB missing material ${name}`);
  if (exported.status !== "PASS_V0238_BLENDER_GLTF_EXPORT") errors.push("Blender metadata failed.");
  for (const phrase of ["Domestic buildings", "Economy buildings", "Defense and support buildings", "Coherent future expansion", "Reserved landmark language"]) if (!bible.includes(phrase)) errors.push(`Bible missing ${phrase}.`);
  return {runtime, exported, glb};
}

function markdown(e, selectedVerdict) {
  return [
    "# v0.238 Barrosan Building Roster Expansion",
    "", `Verdict: \`${selectedVerdict}\``, "",
    "## Asset and scene revision", "",
    "- Blender used: yes, Blender 5.1.2.",
    "- New GLB exported: yes, `desktop-spikes/godot-salto/assets/v0238/salto_barrosan_building_roster.glb`.",
    `- New GLB size: \`${e.glb.bytes}\` bytes; meshes: \`${e.glb.meshes}\`.`,
    "- Existing v0.237 GLB modified: no.",
    "- Scene: `res://scenes/salto_barrosan_building_roster.tscn`.",
    "- Art bible updated: `docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md`.", "",
    "## Exact counts", "",
    "- New building modules: `6`.", "- New prop modules: `8`.", "- New or changed materials: `10`.",
    "- Composed building instances: `9` (three retained landmarks plus six new roles).",
    `- Composed role-prop instances: \`${e.runtime.rosterPropInstanceCount}\`.`, "",
    "## Exact source files changed", "",
    "- `tools/blender/generate_v0238_barrosan_building_roster.py`",
    "- `tools/blender/generateV0238BarrosanBuildingRosterWindows.ps1`",
    "- `tools/godot/captureGodotV0238BarrosanBuildingRosterWindows.ps1`",
    "- `tools/godot/validateGodotV0238BarrosanBuildingRosterWindows.ps1`",
    "- `tools/godot/buildV0238BarrosanReviewPack.py`",
    "- `tools/godot/saltoV0238BarrosanBuildingRosterTool.mjs`",
    "- `desktop-spikes/godot-salto/scripts/salto_barrosan_building_roster.gd`",
    "- `desktop-spikes/godot-salto/scenes/salto_barrosan_building_roster.tscn`",
    "- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`",
    "- `package.json`",
    "- `docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md`", "",
    "## Roster result", "",
    "- House/dwelling: compact porch, garden and warm domestic scale.",
    "- Farm/granary: broad raised storage, loft vent, sacks, hay and food-yard massing.",
    "- Lumber/carpenter yard: open civilian work bay, canopy, logs, planks and saw bench.",
    "- Blacksmith/forge: dark masonry, tall chimney, anvil and restrained hot hearth.",
    "- Watchtower: vertical stone/timber lookout clearly below keep authority.",
    "- Market/storehouse: open counter, awning, goods and supply-stall logistics read.", "",
    "## Honest visual assessment", "",
    selectedVerdict === "PASS"
      ? "The full overview reads as a substantially more complete RTS base. All six additions remain Barrosan, but their silhouettes and yards communicate different jobs before close inspection. The keep, barracks and mine still dominate their reserved landmark roles."
      : selectedVerdict === "PARTIAL"
        ? "The roster is authored and grounded, but one or more roles remain too similar or weak at overview scale."
        : "The roster does not meet the required silhouette and settlement-readability bar.",
    "",
    "Even at PASS, this is a focused faction-roster proof rather than final production content. The six modules establish a convincing breadth of roles, but final game integration, construction states, damage states and hand-textured polish are outside v0.238.", "",
    "## Validation", "",
    "- Six module hierarchies, six true roof assemblies, eight props, ten materials, connected settlement composition, captures and hard boundaries: validated.",
    "- Gameplay, saves, economy logic, selection, pathing, commands, minimap, objectives, production, AI, collision, browser runtime and launcher defaults: unchanged.", "",
    "## Stop boundary", "", "Stop after v0.238. Do not begin v0.239.", "",
  ].join("\n");
}

function capture() {
  const errors = [], evidence = inspect(errors);
  mkdirSync(manual, {recursive: true});
  for (const file of expected.slice(0, 9)) if (!existsSync(join(manual, file))) errors.push(`missing capture ${file}`);
  if (!["PASS", "PARTIAL", "FAIL"].includes(verdict)) errors.push("invalid verdict");
  writeFileSync(join(manual, "12_v0238_report.md"), markdown(evidence, verdict));
  writeFileSync(join(root, "v0238-capture-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0238_CAPTURE" : "PASS_V0238_CAPTURE", verdict, errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [], evidence = inspect(errors);
  for (const file of expected) {
    const path = join(manual, file);
    if (!existsSync(path)) errors.push(`missing review file ${file}`);
    else if (statSync(path).size < (file.endsWith(".png") ? 10000 : 1000)) errors.push(`review file too small ${file}`);
  }
  const report = existsSync(join(manual, "12_v0238_report.md")) ? readFileSync(join(manual, "12_v0238_report.md"), "utf8") : "";
  writeFileSync(join(root, "v0238-validation-report.json"), JSON.stringify({
    status: errors.length ? "FAIL_V0238_VALIDATION" : "PASS_V0238_BARROSAN_BUILDING_ROSTER_VALIDATION",
    verdict: report.match(/Verdict: `([^`]+)`/u)?.[1] ?? "UNKNOWN",
    glbMeshCount: evidence.glb.meshes, newBuildingModuleCount: evidence.runtime.newBuildingModuleCount ?? 0,
    newPropModuleCount: evidence.runtime.newPropModuleCount ?? 0, composedBuildingInstanceCount: evidence.runtime.composedBuildingInstanceCount ?? 0,
    errors,
  }, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
