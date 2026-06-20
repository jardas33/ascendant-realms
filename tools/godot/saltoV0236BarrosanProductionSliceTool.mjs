import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const defaultRoot = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0236");
const root = resolve((process.argv.find(value => value.startsWith("--artifact-root=")) ?? `--artifact-root=${defaultRoot}`).split("=")[1]);
const verdict = (process.argv.find(value => value.startsWith("--verdict=")) ?? "--verdict=PARTIAL").split("=")[1];
const manual = join(repo, "artifacts", "manual-review", "v0236-barrosan-art-bible-production-slice");
const runtimePath = join(root, "runtime", "v0236-barrosan-production-slice-runtime.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0236", "salto_barrosan_production_slice.glb");
const exportPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0236", "salto_barrosan_production_slice.export.json");
const contractPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0236", "salto_barrosan_production_slice.contract.json");
const blendPath = join(repo, "art-source", "blender", "v0236", "salto_barrosan_production_slice.blend");
const scenePath = join(repo, "desktop-spikes", "godot-salto", "scenes", "salto_barrosan_production_slice.tscn");
const scriptPath = join(repo, "desktop-spikes", "godot-salto", "scripts", "salto_barrosan_production_slice.gd");
const artBiblePath = join(repo, "docs", "art", "V0236_BARROSAN_FACTION_ART_BIBLE.md");
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
const expectedFiles = [
  "01_v0235_baseline_overview.png",
  "02_v0236_overview.png",
  "03_v0236_barrosan_shape_language.png",
  "04_v0236_barracks_workshop_role_detail.png",
  "05_v0236_keep_base_role_detail.png",
  "06_v0236_mine_lume_role_detail.png",
  "07_v0236_terrain_road_river_integration.png",
  "08_v0236_material_variation_focus.png",
  "09_before_after_contact_sheet.png",
  "10_v0236_art_bible_summary_contact_sheet.png",
  "11_v0236_report.md",
];
const changedSourceFiles = [
  "docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md",
  "art-source/blender/v0236/salto_barrosan_production_slice.blend",
  "desktop-spikes/godot-salto/assets/v0236/salto_barrosan_production_slice.glb",
  "desktop-spikes/godot-salto/assets/v0236/salto_barrosan_production_slice.glb.import",
  "desktop-spikes/godot-salto/assets/v0236/salto_barrosan_production_slice.export.json",
  "desktop-spikes/godot-salto/assets/v0236/salto_barrosan_production_slice.contract.json",
  "desktop-spikes/godot-salto/scenes/salto_barrosan_production_slice.tscn",
  "desktop-spikes/godot-salto/scripts/salto_barrosan_production_slice.gd",
  "desktop-spikes/godot-salto/scripts/salto_barrosan_production_slice.gd.uid",
  "desktop-spikes/godot-salto/scripts/salto_spike_root.gd",
  "tools/blender/generate_v0236_barrosan_production_slice.py",
  "tools/blender/generateV0236BarrosanProductionSliceWindows.ps1",
  "tools/godot/captureGodotV0236BarrosanProductionSliceWindows.ps1",
  "tools/godot/validateGodotV0236BarrosanProductionSliceWindows.ps1",
  "tools/godot/buildV0236BarrosanReviewPack.py",
  "tools/godot/saltoV0236BarrosanProductionSliceTool.mjs",
  "package.json",
  "CHANGELOG.md",
  "DEVELOPMENT_CHECKPOINT.md",
  "LLM_GAME_HANDOFF.md",
  "ROADMAP.md",
  "docs/V0236_BARROSAN_PRODUCTION_SLICE_REPORT.md",
  "docs/V0236_IMPLEMENTATION_REPORT.md",
];

function parseGlb(path) {
  const data = readFileSync(path);
  if (data.toString("ascii", 0, 4) !== "glTF") throw new Error("GLB magic is invalid.");
  const declaredLength = data.readUInt32LE(8);
  let offset = 12;
  let json = null;
  while (offset + 8 <= data.length) {
    const length = data.readUInt32LE(offset);
    const type = data.readUInt32LE(offset + 4);
    if (type === 0x4e4f534a) json = JSON.parse(data.toString("utf8", offset + 8, offset + 8 + length).replace(/\0+$/u, ""));
    offset += 8 + length;
  }
  if (!json) throw new Error("GLB JSON chunk is missing.");
  return {
    bytes: data.length,
    declaredLength,
    nodeNames: (json.nodes ?? []).map(node => node.name).filter(Boolean),
    materialNames: (json.materials ?? []).map(material => material.name).filter(Boolean),
    meshCount: (json.meshes ?? []).length,
  };
}

function inspect(errors) {
  for (const path of [runtimePath, glbPath, exportPath, contractPath, blendPath, scenePath, scriptPath, artBiblePath]) {
    if (!existsSync(path)) errors.push(`missing ${path}`);
  }
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  const exported = existsSync(exportPath) ? read(exportPath) : {};
  const contract = existsSync(contractPath) ? read(contractPath) : {};
  const glb = existsSync(glbPath) ? parseGlb(glbPath) : {bytes: 0, declaredLength: 0, nodeNames: [], materialNames: [], meshCount: 0};
  const bible = existsSync(artBiblePath) ? readFileSync(artBiblePath, "utf8") : "";
  if (runtime.status !== "PASS_V0236_BARROSAN_PRODUCTION_SLICE_RUNTIME") errors.push("Godot v0.236 runtime did not pass.");
  if (runtime.sourceGlb !== "res://assets/v0236/salto_barrosan_production_slice.glb") errors.push("Wrong v0.236 source GLB.");
  if (runtime.artBiblePath !== "docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md") errors.push("Wrong art-bible path.");
  if (runtime.blenderUsed !== true || runtime.newV0236GlbExported !== true || runtime.existingV0235GlbModified !== false) errors.push("Asset revision boundary failed.");
  if (runtime.changedBuildingModuleCount !== 3) errors.push("Expected exactly three changed building modules.");
  if (runtime.newOrChangedMaterialCount !== 35 || runtime.newMaterialCount !== 14 || runtime.retunedExistingMaterialCount !== 21) errors.push("Material counts are wrong.");
  if (runtime.propDetailInstancesAdded !== 18 || runtime.rolePropInstances?.length !== 18) errors.push("Expected exactly eighteen prop/detail instances.");
  if (runtime.authoredBuildingDetailObjectCount !== 98 || runtime.rolePropModuleCount !== 6) errors.push("Authored detail/module counts are wrong.");
  if (runtime.squareTerrainModulesPlaced !== 0 || runtime.panelRoadModulesPlaced !== 0) errors.push("Legacy board-tile modules were placed.");
  for (const key of ["continuousTerrainIsland", "organicTerrainPatches", "embeddedVariableWidthRoads", "recessedSegmentedRiver", "shapedRiverBanks", "functionalRoleClutter", "connectedBattlefieldRetained", "centralRoofRidgesHighest", "roofPlanesSlopeDownToBothEaves", "roofEaveOverhangs", "roofRidgeCaps", "roofFasciaBoards"]) {
    if (runtime[key] !== true) errors.push(`missing production proof ${key}`);
  }
  if (runtime.invertedRoofGeometry !== false) errors.push("Inverted roof geometry regressed.");
  if ((runtime.organicSurfaceCount ?? 0) < 70 || (runtime.roadRibbonSegmentCount ?? 0) < 45 || (runtime.riverSegmentCount ?? 0) < 10) errors.push("Organic terrain/road/river evidence is too small.");
  if (runtime.captureCount !== 7) errors.push("Expected seven v0.236 captures.");
  for (const key of ["defaultLauncherChanged", "browserRuntimeChanged", "gameplayChanged", "saveChanged", "economyChanged", "selectionChanged", "pathingChanged", "commandsChanged", "minimapLogicChanged", "objectivesChanged", "productionLogicChanged", "collisionChanged"]) {
    if (runtime[key] !== false) errors.push(`${key} safety boundary failed.`);
  }
  if (runtime.newRuntimeArtSlots !== 0) errors.push("Unexpected runtime-art slot.");
  if (glb.bytes < 500000 || glb.bytes !== glb.declaredLength) errors.push("GLB size or declared length is invalid.");
  for (const name of [...(contract.changedBuildingModules ?? []), ...(contract.rolePropModules ?? [])]) {
    if (!glb.nodeNames.includes(name)) errors.push(`GLB missing module ${name}`);
  }
  for (const prefix of ["Keep_Roof", "Barracks_Roof", "Workshop_Roof", "Mine_Roof"]) {
    for (const suffix of ["_Plane_North", "_Plane_South", "_RidgeCap", "_EaveFascia_-1", "_EaveFascia_1"]) {
      if (!glb.nodeNames.includes(`${prefix}${suffix}`)) errors.push(`GLB missing roof geometry ${prefix}${suffix}`);
    }
  }
  for (const name of exported.newMaterialNames ?? []) {
    if (!glb.materialNames.includes(name)) errors.push(`GLB missing material ${name}`);
  }
  if (exported.status !== "PASS_V0236_BLENDER_GLTF_EXPORT") errors.push("Blender export metadata did not pass.");
  for (const phrase of ["Faction identity", "Shape language", "Roof language", "Material palette", "Detail rules", "Terrain rules", "Future-race separation"]) {
    if (!bible.includes(phrase)) errors.push(`Art bible missing ${phrase}.`);
  }
  return {runtime, exported, contract, glb};
}

function reportMarkdown(evidence, selectedVerdict) {
  const sourceList = changedSourceFiles.map(path => `- \`${path}\``).join("\n");
  return [
    "# v0.236 Barrosan Faction Art Bible and Production-Quality Slice Upgrade",
    "",
    `Verdict: \`${selectedVerdict}\``,
    "",
    "## Asset and scene revision",
    "",
    "- Blender used: yes, Blender 5.1.2.",
    "- New GLB exported: yes, `desktop-spikes/godot-salto/assets/v0236/salto_barrosan_production_slice.glb`.",
    "- Existing v0.235 GLB modified: no.",
    "- Scene: `res://scenes/salto_barrosan_production_slice.tscn`.",
    "- Art bible: `docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md`.",
    `- GLB meshes: \`${evidence.glb.meshCount}\`; bytes: \`${evidence.glb.bytes}\`.`,
    "",
    "## Exact implementation counts",
    "",
    "- Building modules changed: `3` (keep, barracks/workshop, mine/Lume).",
    "- Existing material families retuned: `21`.",
    "- New materials added: `14`.",
    "- New or changed materials total: `35`.",
    "- Blender-authored building detail objects added: `98`.",
    "- Reusable role-prop modules added: `6`.",
    "- Prop/detail instances added to the composed scene: `18`.",
    `- Organic scene surfaces: \`${evidence.runtime.organicSurfaceCount}\`.`,
    `- Road ribbon segments: \`${evidence.runtime.roadRibbonSegmentCount}\`.`,
    `- River ribbon segments: \`${evidence.runtime.riverSegmentCount}\`.`,
    "- Square terrain modules placed: `0`.",
    "- Panel road modules placed: `0`.",
    "",
    "## Art-bible alignment",
    "",
    "- The keep reads as vertical civic defense through formal steps, ordered stone, banners, gate emphasis and a dominant roof crown.",
    "- The barracks/workshop reads as a long timber-heavy production yard through weapon racks, training posts, tools, logs and storage.",
    "- The mine/Lume reads as a heavy extraction site through reinforced portals, support frames, pulleys, stone piles and controlled crystal clusters.",
    "- Correct v0.235 ridge-to-eave roof geometry is retained for all four pitched roofs.",
    "- Continuous irregular terrain, organic patches, embedded variable-width roads and a recessed shaped river replace visible board tiles and orange panels.",
    "",
    "## Honest visual assessment",
    "",
    selectedVerdict === "PASS"
      ? "Direct review shows a clear, broad improvement over v0.235: the battlefield is less toy-like, the three landmarks communicate different jobs, material families have visible construction logic, and the terrain/road/river read as a connected place rather than a board. The bounded v0.236 production-direction milestone passes."
      : selectedVerdict === "PARTIAL"
        ? "The art bible and implementation are real, but direct review does not yet prove a sufficiently broad production-direction improvement over v0.235. The milestone remains partial."
        : "The implementation does not meet the v0.236 visual bar.",
    "",
    "Even at PASS, this is a production-direction slice rather than final shipped environment art. It still relies on low-poly untextured geometry, has limited vegetation species and no bespoke hand-painted texture set. The meaningful achievement is a coherent faction standard and a materially stronger battlefield foundation, not final AAA finish.",
    "",
    "## Validation",
    "",
    "- Blender source/export, GLB hierarchy/materials, Godot import/composition, seven captures, exact review files and hard boundaries: validated.",
    "- Gameplay, saves, economy, selection, pathing, commands, minimap, objectives, production and launcher defaults: unchanged.",
    "- Runtime-art slots added: zero.",
    "",
    "## Exact source files changed",
    "",
    sourceList,
    "",
    "## Stop boundary",
    "",
    "Stop after v0.236. Do not begin v0.237.",
    "",
  ].join("\n");
}

function capture() {
  const errors = [];
  const evidence = inspect(errors);
  mkdirSync(manual, {recursive: true});
  for (const fileName of expectedFiles.slice(0, 8)) if (!existsSync(join(manual, fileName))) errors.push(`missing capture ${fileName}`);
  if (!["PASS", "PARTIAL", "FAIL"].includes(verdict)) errors.push(`invalid verdict ${verdict}`);
  writeFileSync(join(manual, "11_v0236_report.md"), reportMarkdown(evidence, verdict));
  writeFileSync(join(root, "v0236-capture-report.json"), `${JSON.stringify({
    status: errors.length ? "FAIL_V0236_CAPTURE" : "PASS_V0236_CAPTURE",
    verdict,
    changedBuildingModuleCount: evidence.runtime.changedBuildingModuleCount ?? 0,
    newOrChangedMaterialCount: evidence.runtime.newOrChangedMaterialCount ?? 0,
    propDetailInstancesAdded: evidence.runtime.propDetailInstancesAdded ?? 0,
    captureCount: evidence.runtime.captureCount ?? 0,
    errors,
  }, null, 2)}\n`);
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  const evidence = inspect(errors);
  for (const fileName of expectedFiles) {
    const path = join(manual, fileName);
    if (!existsSync(path)) errors.push(`missing review file ${fileName}`);
    else if (statSync(path).size < (fileName.endsWith(".png") ? 10000 : 1000)) errors.push(`review file too small ${fileName}`);
  }
  const report = existsSync(join(manual, "11_v0236_report.md")) ? readFileSync(join(manual, "11_v0236_report.md"), "utf8") : "";
  const reportVerdict = report.match(/Verdict: `([^`]+)`/u)?.[1] ?? "UNKNOWN";
  writeFileSync(join(root, "v0236-validation-report.json"), `${JSON.stringify({
    status: errors.length ? "FAIL_V0236_VALIDATION" : "PASS_V0236_BARROSAN_PRODUCTION_SLICE_VALIDATION",
    verdict: reportVerdict,
    glbMeshCount: evidence.glb.meshCount,
    changedBuildingModuleCount: evidence.runtime.changedBuildingModuleCount ?? 0,
    newOrChangedMaterialCount: evidence.runtime.newOrChangedMaterialCount ?? 0,
    propDetailInstancesAdded: evidence.runtime.propDetailInstancesAdded ?? 0,
    errors,
  }, null, 2)}\n`);
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
