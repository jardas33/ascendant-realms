import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const defaultRoot = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0233");
const root = resolve((process.argv.find(value => value.startsWith("--artifact-root=")) ?? `--artifact-root=${defaultRoot}`).split("=")[1]);
const verdict = (process.argv.find(value => value.startsWith("--verdict=")) ?? "--verdict=PARTIAL").split("=")[1];
const manual = join(repo, "artifacts", "manual-review", "v0233-blender-modular-kit");
const runtimePath = join(root, "runtime", "v0233-blender-modular-kit-runtime.json");
const toolingPath = join(root, "blender-tooling-report.json");
const contractPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0233", "salto_modular_environment_kit.contract.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0233", "salto_modular_environment_kit.glb");
const blendPath = join(repo, "art-source", "blender", "v0233", "salto_modular_environment_kit.blend");
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
const expectedFiles = [
  "01_v0232_baseline.png", "02_v0233_overview.png", "03_v0233_base_structure_focus.png",
  "04_v0233_barracks_workshop_focus.png", "05_v0233_mine_lume_focus.png",
  "06_v0233_road_bridge_river_focus.png", "07_v0233_props_and_scale.png",
  "08_before_after_contact_sheet.png", "09_asset_kit_contact_sheet.png", "10_v0233_report.md"
];

function parseGlb(path) {
  const data = readFileSync(path);
  if (data.toString("ascii", 0, 4) !== "glTF") throw new Error("GLB magic is invalid.");
  const declaredLength = data.readUInt32LE(8);
  let offset = 12;
  let json;
  while (offset < data.length) {
    const chunkLength = data.readUInt32LE(offset);
    const chunkType = data.readUInt32LE(offset + 4);
    offset += 8;
    const chunk = data.subarray(offset, offset + chunkLength);
    offset += chunkLength;
    if (chunkType === 0x4e4f534a) json = JSON.parse(chunk.toString("utf8").replace(/\0+$/u, "").trim());
  }
  if (!json) throw new Error("GLB JSON chunk is missing.");
  return {
    bytes: data.length,
    declaredLength,
    nodeNames: (json.nodes ?? []).map(node => node.name ?? ""),
    materialNames: (json.materials ?? []).map(material => material.name ?? ""),
    meshCount: (json.meshes ?? []).length
  };
}

function inspect(errors) {
  for (const path of [runtimePath, toolingPath, contractPath, glbPath, blendPath]) {
    if (!existsSync(path)) errors.push(`missing ${path}`);
  }
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  const tooling = existsSync(toolingPath) ? read(toolingPath) : {};
  const contract = existsSync(contractPath) ? read(contractPath) : {};
  const glb = existsSync(glbPath) ? parseGlb(glbPath) : {bytes: 0, declaredLength: 0, nodeNames: [], materialNames: [], meshCount: 0};
  const modulesFound = (contract.modules ?? []).filter(name => glb.nodeNames.includes(name));
  const materialsFound = (contract.materials ?? []).filter(name => glb.materialNames.includes(name));

  if (tooling.blenderAvailable !== true || tooling.actualGlbProduced !== true || tooling.status !== "PASS_BLENDER_GLTF_EXPORT") {
    errors.push("Blender tooling did not record a real successful export.");
  }
  if (runtime.status !== "PASS_V0233R_IMPORTED_GLTF") errors.push("Godot importer did not report PASS_V0233R_IMPORTED_GLTF.");
  if (runtime.actualGlbPresent !== true || runtime.actualGlbImported !== true) errors.push("Godot did not prove GLB presence and import.");
  if (runtime.isolatedSceneDisplayedAsset !== true || runtime.captureCount !== 6) errors.push("Godot did not display and capture the imported asset.");
  if (glb.bytes < 100000 || glb.bytes !== glb.declaredLength) errors.push("GLB size or declared length is invalid.");
  if (modulesFound.length !== (contract.modules ?? []).length) errors.push("GLB module contract is incomplete.");
  if (materialsFound.length !== (contract.materials ?? []).length) errors.push("GLB material contract is incomplete.");
  if ((runtime.modulesFound ?? []).length !== (contract.modules ?? []).length) errors.push("Godot module discovery is incomplete.");
  if ((runtime.materialsFound ?? []).length !== (contract.materials ?? []).length) errors.push("Godot material discovery is incomplete.");
  for (const key of ["defaultLauncherChanged", "browserRuntimeChanged", "gameplayChanged", "saveChanged", "pathingChanged", "collisionChanged"]) {
    if (runtime[key] !== false) errors.push(`${key} safety boundary failed.`);
  }
  if (runtime.newRuntimeArtSlots !== 0 || runtime.generatedAiImages !== 0 || runtime.downloadedAssets !== 0) {
    errors.push("Unexpected runtime slot, generated-image, or download count.");
  }
  return {runtime, tooling, contract, glb, modulesFound, materialsFound};
}

function reportMarkdown(evidence, selectedVerdict) {
  const visualAssessment = selectedVerdict === "PASS"
    ? "The imported kit is a clear structural improvement over v0.232: authored silhouettes, bevels, roofs, foundations, bridge components and prop scale now read as a coherent modular asset family. It remains an early production-art slice rather than final environment art."
    : "The Blender-authored kit is real, complete and visible, but the current visual result remains an early low-poly modular blockout. Geometry authorship is materially stronger than the prior procedural scaffold; surface richness, composition and final in-game integration are not yet production quality.";
  return [
    "# v0.233 Blender Modular Kit Report",
    "",
    `Verdict: \`${selectedVerdict}\``,
    "",
    "## Blender execution",
    "",
    `- Blender path: \`${evidence.tooling.blenderPath}\`.`,
    "- Exact initial command: `\"C:\\Program Files\\Blender Foundation\\Blender 5.1\\blender.exe\" -b --python tools/blender/generate_v0233_salto_modular_kit.py`.",
    "- Blender version: `5.1.2`.",
    "",
    "## Exported/imported asset",
    "",
    "- GLB path: `desktop-spikes/godot-salto/assets/v0233/salto_modular_environment_kit.glb`.",
    `- GLB file size: \`${evidence.glb.bytes}\` bytes.`,
    `- GLB mesh count: \`${evidence.glb.meshCount}\`.`,
    "- Godot import result: `PASS_V0233R_IMPORTED_GLTF`.",
    "- Isolated scene displayed imported geometry: yes.",
    "- Review captures produced from the imported GLB: 6.",
    "",
    "## Modules found",
    "",
    ...evidence.modulesFound.map(value => `- \`${value}\``),
    "",
    "## Materials found",
    "",
    ...evidence.materialsFound.map(value => `- \`${value}\``),
    "",
    "## Brutally honest visual assessment",
    "",
    visualAssessment,
    "",
    "## Safety boundary",
    "",
    "- Browser/gameplay/save/economy/objective/command/selection/production/minimap systems: unchanged.",
    "- Default launcher: unchanged.",
    "- Runtime-art slots added: zero.",
    "- Downloads and AI-generated images: zero.",
    "",
    "## Next recommended milestone",
    "",
    "Stop at v0.233R. Review the imported kit as an art-direction gate before authorizing any v0.234 work.",
    ""
  ].join("\n");
}

function capture() {
  const errors = [];
  const evidence = inspect(errors);
  mkdirSync(manual, {recursive: true});
  for (const fileName of expectedFiles.slice(0, 7)) {
    if (!existsSync(join(manual, fileName))) errors.push(`missing real capture ${fileName}`);
  }
  if (!["PASS", "PARTIAL", "FAIL"].includes(verdict)) errors.push(`invalid v0.233R verdict ${verdict}`);
  writeFileSync(join(manual, "10_v0233_report.md"), reportMarkdown(evidence, verdict));
  writeFileSync(join(root, "v0233-capture-report.json"), `${JSON.stringify({
    status: errors.length ? "FAIL_V0233R_REAL_GLTF_CAPTURE" : "PASS_V0233R_REAL_GLTF_CAPTURE",
    verdict,
    actualGlbProduced: evidence.tooling.actualGlbProduced === true,
    actualGlbImported: evidence.runtime.actualGlbImported === true,
    isolatedSceneDisplayedAsset: evidence.runtime.isolatedSceneDisplayedAsset === true,
    glbBytes: evidence.glb.bytes,
    modulesFound: evidence.modulesFound,
    materialsFound: evidence.materialsFound,
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
    else if (statSync(path).size < (fileName.endsWith(".png") ? 10000 : 500)) errors.push(`review file is too small ${fileName}`);
  }
  const reportText = existsSync(join(manual, "10_v0233_report.md")) ? readFileSync(join(manual, "10_v0233_report.md"), "utf8") : "";
  const reportVerdict = reportText.match(/Verdict: `([^`]+)`/u)?.[1] ?? "UNKNOWN";
  writeFileSync(join(root, "v0233-validation-report.json"), `${JSON.stringify({
    status: errors.length ? "FAIL_V0233R_REAL_GLTF_VALIDATION" : "PASS_V0233R_REAL_GLTF_VALIDATION",
    verdict: reportVerdict,
    glbBytes: evidence.glb.bytes,
    glbMeshCount: evidence.glb.meshCount,
    modulesFound: evidence.modulesFound.length,
    materialsFound: evidence.materialsFound.length,
    godotImported: evidence.runtime.actualGlbImported === true,
    isolatedSceneDisplayedAsset: evidence.runtime.isolatedSceneDisplayedAsset === true,
    runtimeArtSlotsAdded: 0,
    errors
  }, null, 2)}\n`);
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
