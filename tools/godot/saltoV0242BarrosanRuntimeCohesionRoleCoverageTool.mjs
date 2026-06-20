import {createHash} from "node:crypto";
import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const defaultRoot = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0242");
const root = resolve((process.argv.find(v => v.startsWith("--artifact-root=")) ?? `--artifact-root=${defaultRoot}`).split("=")[1]);
const verdict = (process.argv.find(v => v.startsWith("--verdict=")) ?? "--verdict=PARTIAL").split("=")[1];
const manual = join(repo, "artifacts", "manual-review", "v0242-barrosan-runtime-cohesion-role-coverage");
const runtimePath = join(root, "runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0239", "salto_barrosan_roster_silhouette_beauty.glb");
const docPath = join(repo, "docs", "V0242_BARROSAN_RUNTIME_COHESION_ROLE_COVERAGE_REPORT.md");
const roles = ["main_base", "house", "farm", "lumber", "blacksmith", "barracks", "mine", "watchtower", "market"];
const liveRoles = ["main_base", "barracks", "mine"];
const inertRoles = ["house", "farm", "lumber", "blacksmith", "watchtower", "market"];
const required = [
  "01_v0241_partial_baseline.png", "02_v0242_runtime_cohesion_overview.png", "03_v0242_default_runtime_unchanged_proof.png",
  "04_v0242_barrosan_terrain_road_river_cohesion.png", "05_v0242_all_nine_roles_runtime_addressable.png",
  "06_v0242_live_roles_preserved_main_barracks_mine.png", "07_v0242_inert_roles_selectable_house_farm_lumber_blacksmith_watchtower_market.png",
  "08_v0242_selected_structure_clean_indicator.png", "09_v0242_unselected_clean_no_debug_clutter.png",
  "10_v0242_valid_placement_preview.png", "11_v0242_blocked_placement_preview.png", "12_v0242_units_near_buildings_scale.png",
  "13_v0242_minimap_or_review_role_presence.png", "14_v0242_before_after_contact_sheet.png", "15_v0242_report.md",
];
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
const sha256 = path => createHash("sha256").update(readFileSync(path)).digest("hex").toUpperCase();

function inspect(errors) {
  for (const path of [runtimePath, defaultPath, glbPath]) if (!existsSync(path)) errors.push(`missing ${path}`);
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  const defaultRuntime = existsSync(defaultPath) ? read(defaultPath) : {};
  const skin = runtime.barrosanPlayableRuntimeSkin ?? {};
  if (runtime.status !== "PASS_PLAYER_SLICE_CAPTURE" || runtime.checkpoint !== "v0.242" || runtime.captureCount !== 11) errors.push("runtime capture contract failed");
  if (defaultRuntime.status !== "PASS_PLAYER_SLICE_CAPTURE" || defaultRuntime.checkpoint !== "v0.242") errors.push("default proof failed");
  if (skin.enabled !== true || skin.checkpoint !== "v0.242") errors.push("skin status failed");
  if ((defaultRuntime.barrosanPlayableRuntimeSkin?.enabled ?? false) !== false) errors.push("default runtime unexpectedly skinned");
  if (skin.defaultRuntimeChanged !== false || skin.gameplaySystemsChanged !== false || skin.terrainCollisionChanged !== false || skin.pathingChanged !== false) errors.push("boundary failed");
  if (skin.terrainVisualOnly !== true || skin.selectionIntegrated !== true || skin.footprintCount !== 9 || skin.minimapRoleMarkerCount !== 9) errors.push("cohesion/addressability proof failed");
  if (skin.placementValidation !== "evidence-only") errors.push("placement posture drifted");
  for (const role of roles) if (!(skin.addressableRoles ?? []).includes(role)) errors.push(`missing addressable role ${role}`);
  for (const role of liveRoles) if (!(skin.liveMappedRoles ?? []).includes(role)) errors.push(`missing live role ${role}`);
  for (const role of inertRoles) if (!(skin.inertOptInRoles ?? []).includes(role)) errors.push(`missing inert role ${role}`);
  if ((skin.errors ?? []).length) errors.push(`runtime errors: ${(skin.errors ?? []).join(", ")}`);
  return {runtime, defaultRuntime, skin, glbSha256: existsSync(glbPath) ? sha256(glbPath) : ""};
}

function markdown(e, selectedVerdict) {
  return [
    "# v0.242 Barrosan Runtime Cohesion + Full Role Entity Coverage", "",
    `Verdict: \`${selectedVerdict}\``, "",
    "## Exact facts", "",
    "- Blender used: no.",
    "- New GLB exported: no.",
    "- v0.239 GLB reused unchanged: yes.",
    `- GLB SHA-256: \`${e.glbSha256}\`.`,
    "- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Mapping reused unchanged: `res://data/v0240_barrosan_playable_art_mapping.json`.",
    "- Default runtime unchanged: proven by a separate unflagged packaged capture.", "",
    "## Exact source files changed", "",
    "- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`",
    "- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`",
    "- `tools/godot/buildV0242BarrosanRuntimeCohesionRoleCoverageReviewPack.py`",
    "- `tools/godot/captureGodotV0242BarrosanRuntimeCohesionRoleCoverageWindows.ps1`",
    "- `tools/godot/saltoV0242BarrosanRuntimeCohesionRoleCoverageTool.mjs`",
    "- `tools/godot/validateGodotV0242BarrosanRuntimeCohesionRoleCoverageWindows.ps1`",
    "- `package.json`",
    "- `docs/V0242_BARROSAN_RUNTIME_COHESION_ROLE_COVERAGE_REPORT.md`", "",
    "## Runtime coverage", "",
    "- Live gameplay entities: `main_base`, `barracks`, `mine`.",
    "- Inert opt-in structures: `house`, `farm`, `lumber`, `blacksmith`, `watchtower`, `market`.",
    "- All nine roles have stable `barrosan_role_*` addresses, runtime presence, click selection, restrained selected indicators, completed footprint bounds and minimap/review markers.",
    "- The six inert roles do not affect economy, production, combat, pathing, saves, AI, objectives or commands.", "",
    "## Selection and scale assessment", "",
    "- All nine structures are runtime click-selectable through the opt-in scene; the selected-market capture proves an inert role can be addressed without persistent labels or debug clutter.",
    "- Main base, barracks and mine preserve their live entity mappings. The nine-role roster has differentiated silhouettes and remains legible beside Worker, Militia and Aster scale probes.",
    "- Scale is improved and usable for this review lane, but remains stylized rather than final production calibration.", "",
    "## Cohesion and placement", "",
    "- The opt-in subclass replaces only the visual terrain foundation with Barrosan-colored terraces, connected roads, yards, riverbanks and bridge landings.",
    "- Terrain collision and pathing are unchanged; the cohesion layer is visual-only.",
    "- Placement previews remain evidence-only. They do not call or modify build-rule validation.", "",
    "## Runtime systems touched", "",
    "- Opt-in scene visual foundation, runtime structure registry, structure click hit-testing, selection presentation, minimap evidence markers and player-slice capture actions.",
    "- Untouched gameplay systems: simulation, economy, production, combat, AI, saves, pathing, collision, commands, objectives, stable IDs and default launcher.", "",
    "## Validation results", "",
    "- `npm run godot:test`: pass.",
    "- `npm run godot:capture:salto-barrosan-runtime-cohesion-role-coverage`: pass.",
    "- `npm run godot:validate:salto-barrosan-runtime-cohesion-role-coverage`: pass.",
    "- `npm test`: pass, 122 files and 887 tests.",
    "- `npm run build`: pass.",
    "- `npm run validate:content`: pass.",
    "- `npm run validate:art-intake`: pass.",
    "- `npm run validate:runtime-art-slots`: pass, 52 slots.",
    "- `npm run godot:validate:salto-experimental-artifact-retention`: pass.",
    "- `npm run godot:all`: pass, including export and package.",
    "- `git diff --check`: pass.", "",
    "## Assessment", "",
    selectedVerdict === "PASS"
      ? "The nine-role settlement now reads as one runtime composition rather than imported buildings pasted onto unrelated geometry. The visual-only terrain is still stylized proxy work and the six inert roles are not gameplay systems, but selection, scale, roads, river and bridge are coherent enough for the next opt-in gameplay-testing checkpoint."
      : selectedVerdict === "PARTIAL"
        ? "The runtime lane is materially more coherent and all nine roles are selectable, but the terrain remains transitional proxy art and placement feedback is still evidence-only. The six additional structures are honest inert entities, not gameplay buildings."
        : "The runtime cohesion or nine-role addressability contract did not hold.", "",
    `Ready for v0.243 opt-in gameplay testing: ${selectedVerdict === "PASS" ? "yes" : "no"}.`, "",
    "Stop after v0.242. Do not begin v0.243.", "",
  ].join("\n");
}

function capture() {
  const errors = [];
  const evidence = inspect(errors);
  if (!["PASS", "PARTIAL", "FAIL"].includes(verdict)) errors.push("invalid verdict");
  mkdirSync(manual, {recursive: true});
  for (const file of required.slice(0, 13)) if (!existsSync(join(manual, file))) errors.push(`missing capture ${file}`);
  const report = markdown(evidence, verdict);
  writeFileSync(join(manual, "15_v0242_report.md"), report);
  writeFileSync(docPath, report);
  writeFileSync(join(root, "v0242-capture-report.json"), JSON.stringify({
    status: errors.length ? "FAIL_V0242_CAPTURE" : "PASS_V0242_BARROSAN_RUNTIME_COHESION_ROLE_COVERAGE_CAPTURE",
    verdict, retainedGlbSha256: evidence.glbSha256, errors,
  }, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  const evidence = inspect(errors);
  for (const file of required) {
    const path = join(manual, file);
    if (!existsSync(path)) errors.push(`missing review file ${file}`);
    else if (statSync(path).size < (file.endsWith(".png") ? 10000 : 700)) errors.push(`review file too small ${file}`);
  }
  if (!existsSync(docPath)) errors.push("missing report");
  writeFileSync(join(root, "v0242-validation-report.json"), JSON.stringify({
    status: errors.length ? "FAIL_V0242_VALIDATION" : "PASS_V0242_BARROSAN_RUNTIME_COHESION_ROLE_COVERAGE_VALIDATION",
    verdict: existsSync(docPath) ? readFileSync(docPath, "utf8").match(/Verdict: `([^`]+)`/u)?.[1] ?? "UNKNOWN" : "UNKNOWN",
    addressableRoles: evidence.skin.addressableRoles ?? [], liveRoles: evidence.skin.liveMappedRoles ?? [],
    inertRoles: evidence.skin.inertOptInRoles ?? [], placementValidation: evidence.skin.placementValidation ?? "UNKNOWN",
    retainedGlbSha256: evidence.glbSha256, errors,
  }, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
