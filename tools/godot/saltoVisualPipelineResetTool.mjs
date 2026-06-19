import {copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const defaultRoot = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0232");
const manual = join(repo, "artifacts", "manual-review", "v0232-visual-pipeline-reset");
const root = resolve((process.argv.find(value => value.startsWith("--artifact-root=")) ?? `--artifact-root=${defaultRoot}`).split("=")[1]);
const manifestPath = join(root, "production-target-spike", "v0232-production-target-spike-runtime.json");
const baselinePath = join(repo, "artifacts", "manual-review", "v0231-battlefield-material-value-integration", "01_overview.png");
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));

function validateManifest(manifest, errors) {
  if (manifest.status !== "PASS_V0232_PRODUCTION_TARGET_SPIKE") errors.push("production-target spike did not pass");
  if (manifest.pipeline !== "Godot 3D orthographic authored low-poly geometry") errors.push("unexpected pipeline");
  if (manifest.isolatedScene !== "res://scenes/salto_production_target_spike.tscn") errors.push("isolated scene missing");
  for (const key of ["defaultLauncherChanged", "browserRuntimeChanged", "gameplayChanged", "pathingChanged", "collisionChanged", "saveChanged"]) {
    if (manifest[key] !== false) errors.push(`${key} safety boundary failed`);
  }
  if (manifest.generatedExternalImages !== 0 || manifest.downloadedAssets !== 0 || manifest.newRuntimeArtSlots !== 0) {
    errors.push("unexpected image/download/runtime-slot count");
  }
  if (manifest.retainsV0231Comparator !== true || manifest.nonPlayable !== true) errors.push("comparator or non-playable contract failed");
}

function capture() {
  const errors = [];
  if (!existsSync(manifestPath)) errors.push("missing production-target manifest");
  if (!existsSync(baselinePath)) errors.push("missing v0.231 baseline capture");
  const manifest = errors.length ? {} : read(manifestPath);
  validateManifest(manifest, errors);
  const byId = new Map((manifest.captures ?? []).map(capture => [capture.id, capture]));
  const outputs = [
    ["overview", "02_new_visual_spike_overview.png"],
    ["base_focus", "03_new_visual_spike_base_focus.png"],
    ["road_river_bridge", "04_new_visual_spike_road_river_bridge.png"],
    ["units_scale", "05_new_visual_spike_units_scale.png"]
  ];
  mkdirSync(manual, {recursive: true});
  if (existsSync(baselinePath)) copyFileSync(baselinePath, join(manual, "01_v0231_baseline.png"));
  for (const [id, fileName] of outputs) {
    const capture = byId.get(id);
    if (!capture?.absolutePath || !existsSync(capture.absolutePath)) errors.push(`missing ${id} capture`);
    else copyFileSync(capture.absolutePath, join(manual, fileName));
  }
  writeFileSync(join(manual, "07_pipeline_diagnosis_summary.md"), [
    "# v0.232 Pipeline Diagnosis Summary",
    "",
    "## Does the new visual spike look substantially better than v0.231?",
    "",
    "Yes in the dimensions this spike tests: depth, silhouette, lighting, terrain elevation, water recession, bridge contact and scene hierarchy. It reads as a small RTS diorama rather than a translucent editor board. It is still a low-detail direction proof, not production-quality environment art.",
    "",
    "## Which pipeline was used?",
    "",
    "A standalone Godot 3D orthographic scene using deliberately authored low-poly massing, continuous road and river meshes, real elevation, directional and local lighting, cast shadows and a restrained retained-style HUD overlay. No external or generated imagery was used.",
    "",
    "## What current v0.231 systems can be reused?",
    "",
    "Gameplay data, stable IDs, command and selection logic, objective flow, production rules, minimap semantics, HUD information architecture, unit identity and the existing capture/validation infrastructure can be retained. v0.231 remains useful as comparator evidence only.",
    "",
    "## What must be discarded?",
    "",
    "The production battlefield must stop being assembled from broad transparent rectangles, stacked color bands and code-authored primitive sheets. Those techniques can remain for debug overlays and deterministic fallbacks, not final terrain, roads, rivers or landmark art.",
    "",
    "## Is changing engine recommended now?",
    "",
    "No. The spike shows that Godot can deliver the required camera, depth, lighting, water separation, silhouettes and shadow hierarchy. Unity or Unreal would not supply art direction or authored assets automatically; changing engine now would add migration cost without solving the pipeline failure.",
    "",
    "## Recommended next milestone",
    "",
    "Build one Blender-authored modular environment kit and import it as GLTF into this isolated Godot 3D direction: terrain chunks, road splines/decals, river banks, bridge, keep, barracks and mine. Establish scale, palette, material, lighting and LOD budgets before reconnecting any gameplay.",
    ""
  ].join("\n"));
  const report = {
    status: errors.length ? "FAIL_V0232_CAPTURE" : "PASS_V0232_CAPTURE",
    exactReviewFilesExpected: 7,
    generatedExternalImages: 0,
    downloadedAssets: 0,
    newRuntimeArtSlots: 0,
    errors
  };
  writeFileSync(join(root, "v0232-capture-report.json"), `${JSON.stringify(report, null, 2)}\n`);
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  if (!existsSync(manifestPath)) errors.push("missing production-target manifest");
  const manifest = errors.length ? {} : read(manifestPath);
  validateManifest(manifest, errors);
  for (const fileName of [
    "01_v0231_baseline.png",
    "02_new_visual_spike_overview.png",
    "03_new_visual_spike_base_focus.png",
    "04_new_visual_spike_road_river_bridge.png",
    "05_new_visual_spike_units_scale.png",
    "06_before_after_contact_sheet.png",
    "07_pipeline_diagnosis_summary.md"
  ]) {
    if (!existsSync(join(manual, fileName))) errors.push(`missing review file ${fileName}`);
  }
  const report = {
    status: errors.length ? "FAIL_V0232_VALIDATION" : "PASS_V0232_VALIDATION",
    isolatedSceneChecked: true,
    v0231ComparatorChecked: true,
    runtimeArtSlotsAdded: 0,
    errors
  };
  writeFileSync(join(root, "v0232-validation-report.json"), `${JSON.stringify(report, null, 2)}\n`);
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`Unknown command: ${command}`);
