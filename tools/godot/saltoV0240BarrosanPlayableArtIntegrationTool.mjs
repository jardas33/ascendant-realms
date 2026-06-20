import {createHash} from "node:crypto";
import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const defaultRoot = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0240");
const root = resolve((process.argv.find(value => value.startsWith("--artifact-root=")) ?? `--artifact-root=${defaultRoot}`).split("=")[1]);
const verdict = (process.argv.find(value => value.startsWith("--verdict=")) ?? "--verdict=PARTIAL").split("=")[1];
const manual = join(repo, "artifacts", "manual-review", "v0240-barrosan-playable-art-integration");
const runtimePath = join(root, "runtime", "v0240-barrosan-playable-art-integration-runtime.json");
const mappingPath = join(repo, "desktop-spikes", "godot-salto", "data", "v0240_barrosan_playable_art_mapping.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0239", "salto_barrosan_roster_silhouette_beauty.glb");
const expectedRoles = ["main_base", "house", "farm", "lumber", "blacksmith", "barracks", "mine", "watchtower", "market"];
const expected = [
  "01_v0239_art_baseline_overview.png",
  "02_v0240_playable_art_overview.png",
  "03_v0240_runtime_role_mapping.png",
  "04_v0240_selection_readability.png",
  "05_v0240_scale_with_units.png",
  "06_v0240_footprint_collision_readability.png",
  "07_v0240_base_cluster_game_camera.png",
  "08_v0240_economy_cluster_game_camera.png",
  "09_v0240_defense_market_resource_cluster.png",
  "10_v0240_before_after_contact_sheet.png",
  "11_v0240_report.md",
];
const sourceFiles = [
  "desktop-spikes/godot-salto/data/v0240_barrosan_playable_art_mapping.json",
  "desktop-spikes/godot-salto/scripts/salto_barrosan_playable_art_integration.gd",
  "desktop-spikes/godot-salto/scenes/salto_barrosan_playable_art_integration.tscn",
  "desktop-spikes/godot-salto/scripts/salto_spike_root.gd",
  "tools/godot/captureGodotV0240BarrosanPlayableArtIntegrationWindows.ps1",
  "tools/godot/validateGodotV0240BarrosanPlayableArtIntegrationWindows.ps1",
  "tools/godot/buildV0240BarrosanPlayableArtIntegrationReviewPack.py",
  "tools/godot/saltoV0240BarrosanPlayableArtIntegrationTool.mjs",
  "package.json",
];

const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
const sha256 = path => createHash("sha256").update(readFileSync(path)).digest("hex").toUpperCase();

function inspect(errors) {
  for (const path of [runtimePath, mappingPath, glbPath]) if (!existsSync(path)) errors.push(`missing ${path}`);
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  const mapping = existsSync(mappingPath) ? read(mappingPath) : {};
  if (runtime.status !== "PASS_V0240_BARROSAN_PLAYABLE_ART_INTEGRATION_RUNTIME") errors.push("Runtime did not pass.");
  if (runtime.sourceGlb !== "res://assets/v0239/salto_barrosan_roster_silhouette_beauty.glb") errors.push("Wrong source GLB.");
  if (runtime.mappingPath !== "res://data/v0240_barrosan_playable_art_mapping.json") errors.push("Wrong mapping path.");
  if (runtime.scenePath !== "res://scenes/salto_barrosan_playable_art_integration.tscn") errors.push("Wrong scene path.");
  if (mapping.posture !== "opt-in-review-only" || runtime.optInReviewOnly !== true) errors.push("Opt-in boundary failed.");
  if (runtime.blenderUsed !== false || runtime.newGlbExported !== false || runtime.v0239GlbReused !== true || runtime.v0239GlbSuperseded !== false) errors.push("GLB reuse facts failed.");
  if (runtime.mappedRoleCount !== 9 || mapping.roles?.length !== 9) errors.push("Mapped role count failed.");
  const runtimeRoles = new Set(runtime.mappedRoles ?? []);
  const mappingRoles = new Set((mapping.roles ?? []).map(entry => entry.gameplayRole));
  for (const role of expectedRoles) {
    if (!runtimeRoles.has(role)) errors.push(`runtime missing role ${role}`);
    if (!mappingRoles.has(role)) errors.push(`mapping missing role ${role}`);
  }
  if (runtime.selectionRingCount !== 9 || runtime.collisionShapeCount !== 9 || runtime.footprintDebugCount < 11 || runtime.unitScaleDummyCount !== 3) errors.push("Review debug count failed.");
  for (const key of [
    "completedPlacementReadabilityOnly", "constructionStateIntegrationOutOfScope",
    "selectionReadabilityPassed", "footprintReadabilityPassed", "scaleReadabilityPassed",
    "roadsBridgeRiverReadable", "roleSilhouettesRetained", "blacksmithChimneyRetained",
    "lumberYardOpennessRetained", "marketAwningRetained", "watchtowerVerticalityRetained",
    "farmGranaryStorageCuesRetained", "domesticHouseCalmRetained",
  ]) if (runtime[key] !== true) errors.push(`missing proof ${key}`);
  if (runtime.captureCount !== 8) errors.push("Capture count failed.");
  for (const key of [
    "defaultLauncherChanged", "browserRuntimeChanged", "gameplayChanged", "saveChanged",
    "economyLogicChanged", "selectionLogicChanged", "pathingChanged", "commandsChanged",
    "minimapLogicChanged", "objectivesChanged", "productionLogicChanged", "aiChanged",
    "collisionLogicChanged",
  ]) if (runtime[key] !== false) errors.push(`${key} boundary failed.`);
  if (runtime.newRuntimeArtSlots !== 0 || mapping.defaultRuntimeChanged !== false || mapping.gameplaySystemsChanged !== false) errors.push("Runtime boundary failed.");
  return {runtime, mapping, glbBytes: existsSync(glbPath) ? statSync(glbPath).size : 0, glbSha256: existsSync(glbPath) ? sha256(glbPath) : ""};
}

function markdown(e, selectedVerdict) {
  const mappings = (e.runtime.roleMappings ?? []).map(entry => `- \`${entry.gameplayRole}\` -> \`${entry.module}\` (${entry.displayName})`).join("\n");
  const changedFiles = sourceFiles.map(path => `- \`${path}\``).join("\n");
  return [
    "# v0.240 Barrosan Playable Art Integration Lane",
    "",
    `Verdict: \`${selectedVerdict}\``,
    "",
    "## Exact asset and integration facts",
    "",
    "- Blender used: no.",
    "- New GLB exported: no.",
    "- v0.239 GLB reused: yes; it was not superseded or modified.",
    `- Reused GLB SHA-256: \`${e.glbSha256}\`; bytes: \`${e.glbBytes}\`.`,
    "- Scene: `res://scenes/salto_barrosan_playable_art_integration.tscn`.",
    "- Runtime mapping: `res://data/v0240_barrosan_playable_art_mapping.json`.",
    "- Integration posture: explicit opt-in review lane; default runtime remains unchanged.",
    "",
    "## Mapped building roles",
    "",
    mappings,
    "",
    "Missing or placeholder roles: none within the nine-role v0.240 contract.",
    "",
    "## Selection, footprint and scale checks",
    "",
    "- Nine selection rings and nine review collision shapes are present.",
    "- Every completed building has a readable footprint overlay.",
    "- Valid and river-blocked placement footprints are demonstrated without changing build rules.",
    "- Worker, Militia and Aster scale probes are visible beside the base cluster.",
    "- Construction-state and placement-ghost integration are intentionally out of scope; v0.240 proves completed-placement readability only.",
    "",
    "## Exact source files changed",
    "",
    changedFiles,
    "",
    "## Gameplay systems untouched",
    "",
    "- Economy, production rules, build logic, selection logic, collision logic, pathing, commands, AI, saves, minimap, objectives, browser runtime and launcher defaults.",
    "",
    "## Brutally honest visual assessment",
    "",
    selectedVerdict === "PASS"
      ? "The authored roster survives the move to game-scale presentation: the keep, barracks and mine remain landmarks, the six support roles stay distinguishable, and the selection/footprint overlays are legible without swallowing roads, bridge or river. The weakest area is the debug layer itself: labels and translucent footprint fills are intentionally utilitarian and should not be mistaken for shipped UI. The buildings still lack construction, damage and faction-state variants, so this is ready for a broader opt-in gameplay-integration experiment, not ready for default-runtime replacement."
      : selectedVerdict === "PARTIAL"
        ? "The mapping and review scaffolding work, but at least one of game-scale selection, footprint clarity or unit-relative scale still needs correction before broader gameplay integration."
        : "The roster does not survive game-scale integration clearly enough to continue.",
    "",
    "## Readiness",
    "",
    selectedVerdict === "PASS"
      ? "Ready for broader opt-in gameplay integration: yes, with construction/damage states and real selection wiring still explicitly future work."
      : "Ready for broader gameplay integration: no.",
    "",
    "Stop after v0.240. Do not begin v0.241.",
    "",
  ].join("\n");
}

function capture() {
  const errors = [];
  const evidence = inspect(errors);
  mkdirSync(manual, {recursive: true});
  for (const file of expected.slice(0, 9)) if (!existsSync(join(manual, file))) errors.push(`missing capture ${file}`);
  if (!["PASS", "PARTIAL", "FAIL"].includes(verdict)) errors.push("invalid verdict");
  writeFileSync(join(manual, "11_v0240_report.md"), markdown(evidence, verdict));
  writeFileSync(join(root, "v0240-capture-report.json"), JSON.stringify({
    status: errors.length ? "FAIL_V0240_CAPTURE" : "PASS_V0240_CAPTURE",
    verdict,
    reusedV0239GlbSha256: evidence.glbSha256,
    errors,
  }, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  const evidence = inspect(errors);
  for (const file of expected) {
    const path = join(manual, file);
    if (!existsSync(path)) errors.push(`missing review file ${file}`);
    else if (statSync(path).size < (file.endsWith(".png") ? 10000 : 1000)) errors.push(`review file too small ${file}`);
  }
  const report = existsSync(join(manual, "11_v0240_report.md")) ? readFileSync(join(manual, "11_v0240_report.md"), "utf8") : "";
  writeFileSync(join(root, "v0240-validation-report.json"), JSON.stringify({
    status: errors.length ? "FAIL_V0240_VALIDATION" : "PASS_V0240_BARROSAN_PLAYABLE_ART_INTEGRATION_VALIDATION",
    verdict: report.match(/Verdict: `([^`]+)`/u)?.[1] ?? "UNKNOWN",
    mappedRoleCount: evidence.runtime.mappedRoleCount ?? 0,
    reusedV0239GlbSha256: evidence.glbSha256,
    errors,
  }, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
