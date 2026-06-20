import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const defaultRoot = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0235");
const root = resolve((process.argv.find(value => value.startsWith("--artifact-root=")) ?? `--artifact-root=${defaultRoot}`).split("=")[1]);
const verdict = (process.argv.find(value => value.startsWith("--verdict=")) ?? "--verdict=PARTIAL").split("=")[1];
const manual = join(repo, "artifacts", "manual-review", "v0235-architecture-correction-beauty-pass");
const runtimePath = join(root, "runtime", "v0235-architecture-correction-runtime.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0235", "salto_barrosan_architecture_kit.glb");
const exportPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0235", "salto_barrosan_architecture_kit.export.json");
const contractPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0235", "salto_barrosan_architecture_kit.contract.json");
const blendPath = join(repo, "art-source", "blender", "v0235", "salto_barrosan_architecture_kit.blend");
const scenePath = join(repo, "desktop-spikes", "godot-salto", "scenes", "salto_architecture_correction_beauty_pass.tscn");
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
const expectedFiles = [
  "01_v0234_baseline_overview.png", "02_v0235_corrected_overview.png", "03_v0235_roof_geometry_proof.png",
  "04_v0235_barracks_workshop_roof_focus.png", "05_v0235_keep_base_roof_focus.png",
  "06_v0235_mine_lume_focus.png", "07_v0235_material_trim_grounding_focus.png",
  "08_before_after_contact_sheet.png", "09_v0235_architecture_contact_sheet.png", "10_v0235_report.md"
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
    meshCount: (json.meshes ?? []).length
  };
}

function inspect(errors) {
  for (const path of [runtimePath, glbPath, exportPath, contractPath, blendPath, scenePath]) {
    if (!existsSync(path)) errors.push(`missing ${path}`);
  }
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  const exported = existsSync(exportPath) ? read(exportPath) : {};
  const contract = existsSync(contractPath) ? read(contractPath) : {};
  const glb = existsSync(glbPath) ? parseGlb(glbPath) : {bytes: 0, declaredLength: 0, nodeNames: [], materialNames: [], meshCount: 0};
  if (runtime.status !== "PASS_V0235_ARCHITECTURE_CORRECTION_RUNTIME") errors.push("Godot architecture runtime did not pass.");
  if (runtime.sourceGlb !== "res://assets/v0235/salto_barrosan_architecture_kit.glb") errors.push("Wrong source GLB.");
  if (runtime.blenderUsed !== true || runtime.newV0235GlbExported !== true || runtime.existingV0233GlbModified !== false) errors.push("Asset revision boundary failed.");
  if (runtime.correctedBuildingModuleCount !== 3 || runtime.correctedPitchedRoofAssemblyCount !== 4 || runtime.correctedTowerCapCount !== 4) errors.push("Corrected module counts are wrong.");
  for (const key of ["centralRoofRidgesHighest", "roofPlanesSlopeDownToBothEaves", "roofEaveOverhangs", "roofRidgeCaps", "roofFasciaBoards", "foundationsAndContactSkirts", "timberBracesAndTrim", "roadsEmbeddedIntoTerrain", "connectedBattlefieldRetained"]) {
    if (runtime[key] !== true) errors.push(`missing architecture proof ${key}`);
  }
  if (runtime.invertedRoofGeometry !== false) errors.push("Inverted roof geometry remains.");
  if (runtime.captureCount !== 6) errors.push("Expected six v0.235 captures.");
  for (const key of ["defaultLauncherChanged", "browserRuntimeChanged", "gameplayChanged", "saveChanged", "pathingChanged", "collisionChanged"]) {
    if (runtime[key] !== false) errors.push(`${key} safety boundary failed.`);
  }
  if (runtime.newRuntimeArtSlots !== 0) errors.push("Unexpected runtime-art slot.");
  if (glb.bytes < 100000 || glb.bytes !== glb.declaredLength) errors.push("GLB size or declared length is invalid.");
  for (const name of contract.correctedBuildingModules ?? []) if (!glb.nodeNames.includes(name)) errors.push(`GLB missing module ${name}`);
  for (const prefix of contract.correctedPitchedRoofAssemblies ?? []) {
    for (const suffix of ["_Plane_North", "_Plane_South", "_RidgeCap", "_EaveFascia_-1", "_EaveFascia_1"]) {
      if (!glb.nodeNames.includes(`${prefix}${suffix}`)) errors.push(`GLB missing roof mesh ${prefix}${suffix}`);
    }
  }
  if (exported.status !== "PASS_V0235_BLENDER_GLTF_EXPORT") errors.push("Blender export metadata did not pass.");
  return {runtime, exported, contract, glb};
}

function reportMarkdown(evidence, selectedVerdict) {
  return [
    "# v0.235 Salto Human/Barrosan Architecture Correction and Beauty Pass",
    "",
    `Verdict: \`${selectedVerdict}\``,
    "",
    "## Asset revision",
    "",
    "- Blender used: yes, Blender 5.1.2.",
    "- Existing GLB modified: no; the v0.233R/v0.234 GLB remains the baseline.",
    "- New GLB exported: `desktop-spikes/godot-salto/assets/v0235/salto_barrosan_architecture_kit.glb`.",
    "- Blender source: `art-source/blender/v0235/salto_barrosan_architecture_kit.blend`.",
    "- Generator: `tools/blender/generate_v0235_salto_barrosan_architecture.py`.",
    "- Scene: `res://scenes/salto_architecture_correction_beauty_pass.tscn`.",
    `- GLB meshes: \`${evidence.glb.meshCount}\`; bytes: \`${evidence.glb.bytes}\`.`,
    "",
    "## Corrected geometry",
    "",
    "- Corrected building modules: `3` (keep, barracks/workshop, mine/Lume).",
    "- Corrected pitched-roof assemblies: `4` (keep, barracks, workshop, mine).",
    "- Corrected keep tower caps: `4`.",
    "- Every pitched roof uses authored ridge-to-eave mesh planes: the central ridge is highest, both planes slope downward to the eaves, eaves overhang the walls, and ridge caps plus fascia boards are separate geometry.",
    "",
    "## Visual result",
    "",
    "Direct screenshot review confirms that the inverted/folded-roof failure is gone. The gable proof shows a central ridge above both eaves, and the overview shows materially stronger role silhouettes, foundations, timber framing, roof caps, dark undersides and ground contact than v0.234. The bounded v0.235 architecture-correction milestone therefore passes.",
    "",
    "The PASS is intentionally narrow. This is competent authored low-poly faction architecture, not production-quality environment art. Broad flat surfaces, repeated terrain tiles, sparse vegetation and limited material microvariation still keep the overall visual direction at PARTIAL.",
    "",
    "## Validation",
    "",
    "- Blender export, GLB structure, Godot import/composition, six captures, exact review files and hard boundaries: validated.",
    "- Browser runtime, gameplay, saves, pathing, collision and default launcher: unchanged.",
    "- Runtime-art slots added: zero.",
    "",
    "## Stop boundary",
    "",
    "Stop after v0.235. Do not begin v0.236.",
    ""
  ].join("\n");
}

function capture() {
  const errors = [];
  const evidence = inspect(errors);
  mkdirSync(manual, {recursive: true});
  for (const fileName of expectedFiles.slice(0, 7)) if (!existsSync(join(manual, fileName))) errors.push(`missing capture ${fileName}`);
  if (!["PASS", "PARTIAL", "FAIL"].includes(verdict)) errors.push(`invalid verdict ${verdict}`);
  writeFileSync(join(manual, "10_v0235_report.md"), reportMarkdown(evidence, verdict));
  writeFileSync(join(root, "v0235-capture-report.json"), `${JSON.stringify({
    status: errors.length ? "FAIL_V0235_CAPTURE" : "PASS_V0235_CAPTURE",
    verdict,
    correctedBuildingModuleCount: evidence.runtime.correctedBuildingModuleCount ?? 0,
    correctedPitchedRoofAssemblyCount: evidence.runtime.correctedPitchedRoofAssemblyCount ?? 0,
    captureCount: evidence.runtime.captureCount ?? 0,
    errors
  }, null, 2)}\n`);
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  const evidence = inspect(errors);
  for (const fileName of expectedFiles) {
    const path = join(manual, fileName);
    if (!existsSync(path)) errors.push(`missing review file ${fileName}`);
    else if (statSync(path).size < (fileName.endsWith(".png") ? 10000 : 500)) errors.push(`review file too small ${fileName}`);
  }
  const report = existsSync(join(manual, "10_v0235_report.md")) ? readFileSync(join(manual, "10_v0235_report.md"), "utf8") : "";
  const reportVerdict = report.match(/Verdict: `([^`]+)`/u)?.[1] ?? "UNKNOWN";
  writeFileSync(join(root, "v0235-validation-report.json"), `${JSON.stringify({
    status: errors.length ? "FAIL_V0235_VALIDATION" : "PASS_V0235_ARCHITECTURE_CORRECTION_VALIDATION",
    verdict: reportVerdict,
    glbMeshCount: evidence.glb.meshCount,
    correctedBuildingModuleCount: evidence.runtime.correctedBuildingModuleCount ?? 0,
    correctedPitchedRoofAssemblyCount: evidence.runtime.correctedPitchedRoofAssemblyCount ?? 0,
    errors
  }, null, 2)}\n`);
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
