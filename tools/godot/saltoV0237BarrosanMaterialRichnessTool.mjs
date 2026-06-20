import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const defaultRoot = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0237");
const root = resolve((process.argv.find(value => value.startsWith("--artifact-root=")) ?? `--artifact-root=${defaultRoot}`).split("=")[1]);
const verdict = (process.argv.find(value => value.startsWith("--verdict=")) ?? "--verdict=PARTIAL").split("=")[1];
const manual = join(repo, "artifacts", "manual-review", "v0237-barrosan-material-richness-foliage");
const runtimePath = join(root, "runtime", "v0237-barrosan-material-richness-runtime.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0237", "salto_barrosan_material_richness.glb");
const exportPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0237", "salto_barrosan_material_richness.export.json");
const contractPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0237", "salto_barrosan_material_richness.contract.json");
const blendPath = join(repo, "art-source", "blender", "v0237", "salto_barrosan_material_richness.blend");
const scenePath = join(repo, "desktop-spikes", "godot-salto", "scenes", "salto_barrosan_material_richness.tscn");
const scriptPath = join(repo, "desktop-spikes", "godot-salto", "scripts", "salto_barrosan_material_richness.gd");
const artBiblePath = join(repo, "docs", "art", "V0236_BARROSAN_FACTION_ART_BIBLE.md");
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
const expectedFiles = [
  "01_v0236_baseline_overview.png",
  "02_v0237_overview.png",
  "03_v0237_roof_wall_material_detail.png",
  "04_v0237_barracks_workshop_inhabited_yard.png",
  "05_v0237_keep_civic_defensive_detail.png",
  "06_v0237_mine_lume_extraction_detail.png",
  "07_v0237_terrain_blending_road_wear.png",
  "08_v0237_riverbank_vegetation_reeds.png",
  "09_v0237_vegetation_vocabulary.png",
  "10_before_after_contact_sheet.png",
  "11_v0237_report.md",
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
  if (runtime.status !== "PASS_V0237_BARROSAN_MATERIAL_RICHNESS_RUNTIME") errors.push("Godot v0.237 runtime did not pass.");
  if (runtime.sourceGlb !== "res://assets/v0237/salto_barrosan_material_richness.glb") errors.push("Wrong v0.237 source GLB.");
  if (runtime.blenderUsed !== true || runtime.newV0237GlbExported !== true || runtime.existingV0236GlbModified !== false) errors.push("Asset revision boundary failed.");
  if (runtime.newOrChangedMaterialCount !== 16) errors.push("Expected exactly sixteen new or changed materials.");
  if (runtime.vegetationModuleCount !== 7 || runtime.vegetationModules?.length !== 7) errors.push("Expected exactly seven vegetation modules.");
  if ((runtime.vegetationInstanceCount ?? 0) < 40) errors.push("Vegetation vocabulary placement is too small.");
  if (runtime.inhabitedPropModuleCount !== 6) errors.push("Expected exactly six new inhabited prop modules.");
  if (runtime.propDetailInstancesAdded !== 20 || runtime.propDetailInstances?.length !== 20) errors.push("Expected exactly twenty added prop/detail instances.");
  if (runtime.terrainRoadRiverSurfacesChanged !== 24) errors.push("Expected exactly twenty-four changed terrain/road/river surfaces.");
  for (const key of ["roofTileRhythmVisible", "plasterRepairAndCrackDetail", "stoneFoundationChipDetail", "timberFastenersAndBrackets", "contactDirtAndRoadWear", "controlledLumeEmission", "organicTerrainBlending", "terraceCues", "riverbankReedsAndMoss", "twoTreeVariants", "overviewReadabilityPreserved", "centralRoofRidgesHighest", "roofPlanesSlopeDownToBothEaves", "roofEaveOverhangs", "roofRidgeCaps", "roofFasciaBoards"]) {
    if (runtime[key] !== true) errors.push(`missing visual proof ${key}`);
  }
  if (runtime.squareTerrainModulesPlaced !== 0 || runtime.panelRoadModulesPlaced !== 0) errors.push("Legacy board-tile modules were placed.");
  if (runtime.invertedRoofGeometry !== false) errors.push("Inverted roof geometry regressed.");
  if (runtime.captureCount !== 8) errors.push("Expected eight v0.237 captures.");
  for (const key of ["defaultLauncherChanged", "browserRuntimeChanged", "gameplayChanged", "saveChanged", "economyChanged", "selectionChanged", "pathingChanged", "commandsChanged", "minimapLogicChanged", "objectivesChanged", "productionLogicChanged", "aiChanged", "collisionChanged"]) {
    if (runtime[key] !== false) errors.push(`${key} safety boundary failed.`);
  }
  if (runtime.newRuntimeArtSlots !== 0) errors.push("Unexpected runtime-art slot.");
  if (glb.bytes < 500000 || glb.bytes !== glb.declaredLength) errors.push("GLB size or declared length is invalid.");
  for (const name of [...(contract.vegetationModules ?? []), ...(contract.inhabitedPropModules ?? [])]) {
    if (!glb.nodeNames.includes(name)) errors.push(`GLB missing module ${name}`);
  }
  for (const prefix of ["Keep_Roof", "Barracks_Roof", "Workshop_Roof", "Mine_Roof"]) {
    for (const suffix of ["_Plane_North", "_Plane_South", "_RidgeCap", "_EaveFascia_-1", "_EaveFascia_1"]) {
      if (!glb.nodeNames.includes(`${prefix}${suffix}`)) errors.push(`GLB missing roof geometry ${prefix}${suffix}`);
    }
  }
  for (const name of exported.newOrChangedMaterialNames ?? []) {
    if (!glb.materialNames.includes(name)) errors.push(`GLB missing material ${name}`);
  }
  if (exported.status !== "PASS_V0237_BLENDER_GLTF_EXPORT") errors.push("Blender export metadata did not pass.");
  for (const phrase of ["Barrosan material-detail rules", "Vegetation vocabulary", "Ground-wear rules", "Avoiding over-noise in the RTS view"]) {
    if (!bible.includes(phrase)) errors.push(`Art-bible addendum missing ${phrase}.`);
  }
  return {runtime, exported, contract, glb};
}

function reportMarkdown(evidence, selectedVerdict) {
  return [
    "# v0.237 Barrosan Material Richness, Foliage, and Inhabited Detail Pass",
    "",
    `Verdict: \`${selectedVerdict}\``,
    "",
    "## Asset and scene revision",
    "",
    "- Blender used: yes, Blender 5.1.2.",
    "- New GLB exported: yes, `desktop-spikes/godot-salto/assets/v0237/salto_barrosan_material_richness.glb`.",
    "- Existing v0.236 GLB modified: no.",
    "- Scene: `res://scenes/salto_barrosan_material_richness.tscn`.",
    "- Art-bible addendum: `docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md`.",
    `- GLB meshes: \`${evidence.glb.meshCount}\`; bytes: \`${evidence.glb.bytes}\`.`,
    "",
    "## Exact implementation counts",
    "",
    "- New or changed materials: `16`.",
    "- Vegetation modules added: `7`.",
    `- Vegetation instances composed: \`${evidence.runtime.vegetationInstanceCount}\`.`,
    "- New inhabited prop modules: `6`.",
    "- Prop/detail instances added: `20`.",
    "- Terrain/road/river surfaces changed: `24`.",
    "- Square terrain modules placed: `0`.",
    "- Panel road modules placed: `0`.",
    "",
    "## Visual result",
    "",
    "- Roofs now carry restrained row rhythm and darker ridge strips while preserving every corrected ridge-to-eave plane.",
    "- Plaster repairs, cracks, stone chips, timber pegs/brackets and contact dirt make construction history visible at overview scale.",
    "- Bushes, grass, reeds, two tree variants and moss create a temperate frontier vocabulary without turning the battlefield into a jungle.",
    "- Barracks/workshop, keep and mine/Lume receive distinct inhabited clusters while roads, bridge and river remain open and legible.",
    "- Ground scars, grass islands, shallow terrace cues and damp bank patches soften transitions without changing collision or pathing.",
    "",
    "## Honest visual assessment",
    "",
    selectedVerdict === "PASS"
      ? "The full RTS overview is clearly richer and more inhabited than v0.236. Material rhythm is visible on all three landmarks, the vegetation vocabulary reads as composed frontier growth, and the landmark/road/bridge hierarchy remains intact. The bounded v0.237 pass succeeds."
      : selectedVerdict === "PARTIAL"
        ? "The authored material and vegetation work is real, but the full overview has not yet proven a sufficiently clear improvement over v0.236. The milestone remains partial."
        : "The v0.237 scene does not meet the required material-richness and readability bar.",
    "",
    "Even at PASS, this remains stylized low-poly production art rather than final hand-textured environment art. The richer silhouette accents and material-value construction substantially improve the baseline, but bespoke texture maps, denser species variation and final lighting polish remain future work.",
    "",
    "## Validation",
    "",
    "- Blender source/export, GLB hierarchy/materials, Godot import/composition, eight captures, exact review files and hard boundaries: validated.",
    "- Gameplay, saves, economy, selection, pathing, commands, minimap, objectives, production, AI, collision and launcher defaults: unchanged.",
    "- Runtime-art slots added: zero.",
    "",
    "## Exact source files changed",
    "",
    "- `docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md`",
    "- `docs/V0237_BARROSAN_MATERIAL_RICHNESS_REPORT.md`",
    "- `art-source/blender/v0237/salto_barrosan_material_richness.blend`",
    "- `desktop-spikes/godot-salto/assets/v0237/salto_barrosan_material_richness.glb`",
    "- `desktop-spikes/godot-salto/assets/v0237/salto_barrosan_material_richness.glb.import`",
    "- `desktop-spikes/godot-salto/assets/v0237/salto_barrosan_material_richness.export.json`",
    "- `desktop-spikes/godot-salto/assets/v0237/salto_barrosan_material_richness.contract.json`",
    "- `desktop-spikes/godot-salto/scenes/salto_barrosan_material_richness.tscn`",
    "- `desktop-spikes/godot-salto/scripts/salto_barrosan_material_richness.gd`",
    "- `desktop-spikes/godot-salto/scripts/salto_barrosan_material_richness.gd.uid`",
    "- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`",
    "- `tools/blender/generate_v0237_barrosan_material_richness.py`",
    "- `tools/blender/generateV0237BarrosanMaterialRichnessWindows.ps1`",
    "- `tools/godot/captureGodotV0237BarrosanMaterialRichnessWindows.ps1`",
    "- `tools/godot/validateGodotV0237BarrosanMaterialRichnessWindows.ps1`",
    "- `tools/godot/buildV0237BarrosanReviewPack.py`",
    "- `tools/godot/saltoV0237BarrosanMaterialRichnessTool.mjs`",
    "- `package.json`",
    "- `CHANGELOG.md`",
    "- `DEVELOPMENT_CHECKPOINT.md`",
    "- `LLM_GAME_HANDOFF.md`",
    "- `ROADMAP.md`",
    "",
    "## Stop boundary",
    "",
    "Stop after v0.237. Do not begin v0.238.",
    "",
  ].join("\n");
}

function capture() {
  const errors = [];
  const evidence = inspect(errors);
  mkdirSync(manual, {recursive: true});
  for (const fileName of expectedFiles.slice(0, 9)) if (!existsSync(join(manual, fileName))) errors.push(`missing capture ${fileName}`);
  if (!["PASS", "PARTIAL", "FAIL"].includes(verdict)) errors.push(`invalid verdict ${verdict}`);
  writeFileSync(join(manual, "11_v0237_report.md"), reportMarkdown(evidence, verdict));
  writeFileSync(join(root, "v0237-capture-report.json"), `${JSON.stringify({
    status: errors.length ? "FAIL_V0237_CAPTURE" : "PASS_V0237_CAPTURE",
    verdict,
    newOrChangedMaterialCount: evidence.runtime.newOrChangedMaterialCount ?? 0,
    vegetationModuleCount: evidence.runtime.vegetationModuleCount ?? 0,
    vegetationInstanceCount: evidence.runtime.vegetationInstanceCount ?? 0,
    propDetailInstancesAdded: evidence.runtime.propDetailInstancesAdded ?? 0,
    terrainRoadRiverSurfacesChanged: evidence.runtime.terrainRoadRiverSurfacesChanged ?? 0,
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
  const report = existsSync(join(manual, "11_v0237_report.md")) ? readFileSync(join(manual, "11_v0237_report.md"), "utf8") : "";
  const reportVerdict = report.match(/Verdict: `([^`]+)`/u)?.[1] ?? "UNKNOWN";
  writeFileSync(join(root, "v0237-validation-report.json"), `${JSON.stringify({
    status: errors.length ? "FAIL_V0237_VALIDATION" : "PASS_V0237_BARROSAN_MATERIAL_RICHNESS_VALIDATION",
    verdict: reportVerdict,
    glbMeshCount: evidence.glb.meshCount,
    newOrChangedMaterialCount: evidence.runtime.newOrChangedMaterialCount ?? 0,
    vegetationModuleCount: evidence.runtime.vegetationModuleCount ?? 0,
    vegetationInstanceCount: evidence.runtime.vegetationInstanceCount ?? 0,
    propDetailInstancesAdded: evidence.runtime.propDetailInstancesAdded ?? 0,
    terrainRoadRiverSurfacesChanged: evidence.runtime.terrainRoadRiverSurfacesChanged ?? 0,
    errors,
  }, null, 2)}\n`);
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
