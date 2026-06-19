import {copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const defaultRoot = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0233");
const root = resolve((process.argv.find(value => value.startsWith("--artifact-root=")) ?? `--artifact-root=${defaultRoot}`).split("=")[1]);
const manual = join(repo, "artifacts", "manual-review", "v0233-blender-modular-kit");
const runtimePath = join(root, "runtime", "v0233-blender-modular-kit-runtime.json");
const toolingPath = join(root, "blender-tooling-report.json");
const baselinePath = join(repo, "artifacts", "manual-review", "v0232-visual-pipeline-reset", "02_new_visual_spike_overview.png");
const contractPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0233", "salto_modular_environment_kit.contract.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0233", "salto_modular_environment_kit.glb");
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));

function inspect(errors) {
  for (const path of [runtimePath, toolingPath, contractPath]) if (!existsSync(path)) errors.push(`missing ${path}`);
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  const tooling = existsSync(toolingPath) ? read(toolingPath) : {};
  const contract = existsSync(contractPath) ? read(contractPath) : {};
  if (tooling.blenderAvailable !== false || tooling.status !== "BLOCKED_FOR_LOCAL_BLENDER_EXPORT") errors.push("tooling blocker not recorded");
  if (runtime.status !== "BLOCKED_FOR_LOCAL_BLENDER_EXPORT") errors.push("Godot importer did not fail closed");
  if (runtime.actualGlbPresent !== false || runtime.actualGlbImported !== false || existsSync(glbPath)) errors.push("unexpected GLB or import success");
  if ((contract.modules ?? []).length < 19 || (contract.materials ?? []).length < 12) errors.push("asset contract incomplete");
  for (const key of ["defaultLauncherChanged", "browserRuntimeChanged", "gameplayChanged", "saveChanged", "pathingChanged", "collisionChanged"]) {
    if (runtime[key] !== false) errors.push(`${key} safety boundary failed`);
  }
  if (runtime.newRuntimeArtSlots !== 0 || runtime.generatedAiImages !== 0 || runtime.downloadedAssets !== 0) errors.push("unexpected asset/runtime-slot count");
  return {runtime, tooling, contract};
}

function reportMarkdown(contract) {
  return [
    "# v0.233 Blender Modular Kit Report",
    "",
    "Verdict: `BLOCKED_FOR_LOCAL_BLENDER_EXPORT`",
    "",
    "## Blender availability",
    "",
    "Blender was not available. The environment was checked through PATH, standard Blender Foundation installs, Windows uninstall registry entries, user-local programs, Scoop, Chocolatey and common Steam libraries.",
    "",
    "## Exported/imported assets",
    "",
    "- Actual `.blend` created: no.",
    "- Actual `.glb` created: no.",
    "- Actual GLTF/GLB imported into Godot: no.",
    "- Intended GLB path: `desktop-spikes/godot-salto/assets/v0233/salto_modular_environment_kit.glb`.",
    "- Blender authoring source: `tools/blender/generate_v0233_salto_modular_kit.py`.",
    "- Godot importer scene: `res://scenes/salto_blender_modular_kit_spike.tscn`.",
    "",
    "## Authored module contract",
    "",
    ...(contract.modules ?? []).map(value => `- \`${value}\``),
    "",
    "## Material contract",
    "",
    ...(contract.materials ?? []).map(value => `- \`${value}\``),
    "",
    "## What is actually better than v0.232?",
    "",
    "No visual improvement is claimed because no Blender export exists. The only improvement is pipeline readiness: a checked-in Blender authoring source, named module/material contract and fail-closed Godot importer now replace ambiguity about how the first authored kit should be produced.",
    "",
    "## What still looks bad?",
    "",
    "The only rendered battlefield remains v0.232's code-built low-poly prototype. v0.233 has no authored visual result to review.",
    "",
    "## Is this pipeline worth continuing?",
    "",
    "Yes, but only after running the script in a real Blender installation and reviewing the resulting imported GLB. This blocked checkpoint is not evidence that the asset quality bar has been met.",
    "",
    "## Should Godot still be kept?",
    "",
    "Yes. The blocker is the missing authoring tool, not Godot.",
    "",
    "## Next recommended milestone",
    "",
    "Install or provide Blender locally, run the checked-in generation command, import the resulting GLB, then rerun the exact v0.233 visual gate. Do not begin v0.234 before v0.233 has real authored-asset evidence.",
    ""
  ].join("\n");
}

function capture() {
  const errors = [];
  const {contract} = inspect(errors);
  if (!existsSync(baselinePath)) errors.push("missing v0.232 comparator");
  mkdirSync(manual, {recursive: true});
  if (existsSync(baselinePath)) copyFileSync(baselinePath, join(manual, "01_v0232_baseline.png"));
  writeFileSync(join(manual, "10_v0233_report.md"), reportMarkdown(contract));
  writeFileSync(join(root, "v0233-capture-report.json"), `${JSON.stringify({
    status: errors.length ? "FAIL_V0233_BLOCKED_CAPTURE" : "BLOCKED_FOR_LOCAL_BLENDER_EXPORT",
    exactReviewFilesExpected: 10,
    actualGlbProduced: false,
    actualGlbImported: false,
    errors
  }, null, 2)}\n`);
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  inspect(errors);
  for (const fileName of [
    "01_v0232_baseline.png", "02_v0233_overview.png", "03_v0233_base_structure_focus.png",
    "04_v0233_barracks_workshop_focus.png", "05_v0233_mine_lume_focus.png",
    "06_v0233_road_bridge_river_focus.png", "07_v0233_props_and_scale.png",
    "08_before_after_contact_sheet.png", "09_asset_kit_contact_sheet.png", "10_v0233_report.md"
  ]) if (!existsSync(join(manual, fileName))) errors.push(`missing review file ${fileName}`);
  writeFileSync(join(root, "v0233-validation-report.json"), `${JSON.stringify({
    status: errors.length ? "FAIL_V0233_BLOCKED_VALIDATION" : "PASS_V0233_BLOCKED_SCAFFOLD_VALIDATION",
    verdict: "BLOCKED_FOR_LOCAL_BLENDER_EXPORT",
    blockerHonestyChecked: true,
    noFakeGlbChecked: true,
    runtimeArtSlotsAdded: 0,
    errors
  }, null, 2)}\n`);
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
