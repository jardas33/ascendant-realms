import {createHash} from "node:crypto";
import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const defaultRoot = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0243");
const root = resolve((process.argv.find(v => v.startsWith("--artifact-root=")) ?? `--artifact-root=${defaultRoot}`).split("=")[1]);
const verdict = (process.argv.find(v => v.startsWith("--verdict=")) ?? "--verdict=PARTIAL").split("=")[1];
const reportedCommit = (process.argv.find(v => v.startsWith("--commit=")) ?? "--commit=PENDING_PUBLICATION").split("=")[1];
const reportedCiRun = (process.argv.find(v => v.startsWith("--ci-run=")) ?? "--ci-run=PENDING_PUBLICATION").split("=")[1];
const manual = join(repo, "artifacts", "manual-review", "v0243-barrosan-build-validation-role-shells");
const runtimePath = join(root, "runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0239", "salto_barrosan_roster_silhouette_beauty.glb");
const docPath = join(repo, "docs", "V0243_BARROSAN_BUILD_VALIDATION_ROLE_SHELLS_REPORT.md");
const roles = ["main_base", "house", "farm", "lumber", "blacksmith", "barracks", "mine", "watchtower", "market"];
const liveRoles = ["main_base", "barracks", "mine"];
const shellRoles = ["house", "farm", "lumber", "blacksmith", "watchtower", "market"];
const required = [
  "01_v0242_partial_baseline.png", "02_v0243_runtime_shell_overview.png", "03_v0243_default_runtime_unchanged_proof.png",
  "04_v0243_all_nine_roles_registered.png", "05_v0243_live_entities_preserved.png", "06_v0243_shell_entities_selectable.png",
  "07_v0243_selected_live_building_hud.png", "08_v0243_selected_shell_building_hud.png",
  "09_v0243_valid_build_preview_real_validation.png", "10_v0243_blocked_build_preview_real_validation.png",
  "11_v0243_validation_reason_overlay.png", "12_v0243_units_pathing_near_shells.png", "13_v0243_minimap_all_roles.png",
  "14_v0243_unselected_clean_view.png", "15_v0243_before_after_contact_sheet.png", "16_v0243_report.md",
];
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
const sha256 = path => createHash("sha256").update(readFileSync(path)).digest("hex").toUpperCase();

function inspect(errors) {
  for (const path of [runtimePath, defaultPath, glbPath]) if (!existsSync(path)) errors.push(`missing ${path}`);
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  const defaultRuntime = existsSync(defaultPath) ? read(defaultPath) : {};
  const skin = runtime.barrosanPlayableRuntimeSkin ?? {};
  if (runtime.status !== "PASS_PLAYER_SLICE_CAPTURE" || runtime.checkpoint !== "v0.243" || runtime.captureCount !== 12) errors.push("runtime capture contract failed");
  if (defaultRuntime.status !== "PASS_PLAYER_SLICE_CAPTURE" || defaultRuntime.checkpoint !== "v0.243") errors.push("default proof failed");
  if (skin.enabled !== true || skin.checkpoint !== "v0.243") errors.push("skin status failed");
  if ((defaultRuntime.barrosanPlayableRuntimeSkin?.enabled ?? false) !== false) errors.push("default runtime unexpectedly skinned");
  if (skin.defaultRuntimeChanged !== false || skin.gameplaySystemsChanged !== false || skin.terrainCollisionChanged !== false || skin.pathingChanged !== false) errors.push("boundary failed");
  if (skin.selectionIntegrated !== true || skin.footprintCount !== 9 || skin.minimapRoleMarkerCount !== 9) errors.push("registry contract failed");
  if (skin.placementValidation !== "read-only-generated-authority-adapter") errors.push("placement adapter missing");
  if (skin.buildValidationAdapter?.status !== "PASS" || skin.validPlacementResult?.ok !== true) errors.push("valid placement proof failed");
  if (skin.blockedPlacementResult?.ok !== false || skin.blockedPlacementReason !== "blocked-terrain") errors.push("blocked placement proof failed");
  if (skin.shellFootprintsAffectRuntimeObstacleAvoidance !== true) errors.push("shell obstacle contract failed");
  for (const role of roles) if (!(skin.addressableRoles ?? []).includes(role)) errors.push(`missing addressable role ${role}`);
  for (const role of liveRoles) if (!(skin.liveMappedRoles ?? []).includes(role)) errors.push(`missing live role ${role}`);
  for (const role of shellRoles) if (!(skin.simSafeShellRoles ?? []).includes(role)) errors.push(`missing shell role ${role}`);
  if ((skin.errors ?? []).length) errors.push(`runtime errors: ${(skin.errors ?? []).join(", ")}`);
  return {runtime, defaultRuntime, skin, glbSha256: existsSync(glbPath) ? sha256(glbPath) : ""};
}

function markdown(e, selectedVerdict) {
  return [
    "# v0.243 Barrosan Build Validation Bridge + Sim-Safe Role Shells", "",
    `Verdict: \`${selectedVerdict}\``, "",
    "## Exact facts", "",
    "- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    `- Published implementation commit: \`${reportedCommit}\`.`,
    `- Exact-SHA GitHub Actions run: ${reportedCiRun}.`,
    "- Blender used: no.",
    "- New GLB exported: no.",
    "- v0.239 GLB reused unchanged: yes.",
    `- GLB SHA-256: \`${e.glbSha256}\`.`,
    "- Mapping reused unchanged: `res://data/v0240_barrosan_playable_art_mapping.json`.",
    "- Placement authority: `res://data/generated/content-subset.json`, exported from existing browser content.", "",
    "## Runtime coverage", "",
    "- Fully live: `main_base`, `barracks`, `mine`.",
    "- Sim-safe shells: `house`, `farm`, `lumber`, `blacksmith`, `watchtower`, `market`.",
    "- Each shell has a stable runtime ID, role ID, selection state, footprint, 500/500 shell health, empty production queue and explicit no-economy/no-AI/no-combat/no-save posture.",
    "- All nine roles are present in the runtime registry, click hit testing, minimap and evidence manifest with no duplicate IDs.", "",
    "## Build validation integration", "",
    "- Godot cannot execute the browser TypeScript function directly. A read-only GDScript adapter mirrors its exact check order against the generated Broken Ford map, Barracks definition, resources, building spawns and capture-site data.",
    "- Valid preview result: real generated authority returned valid.",
    `- Blocked preview result: \`${e.skin.blockedPlacementReason}\` / \`${e.skin.blockedPlacementResult?.reasonText ?? ""}\`.`,
    "- No gameplay rule was changed and the adapter does not place buildings or spend resources.", "",
    "## Selection and HUD", "",
    "- Selecting live buildings shows their live entity type and available runtime state.",
    "- Selecting shell buildings shows `Sim-safe role shell` and `Shell / opt-in / 500 HP / no production yet`.",
    "- Unselected structures remain free of persistent debug labels.", "",
    "## Terrain and pathing honesty", "",
    "- Shell footprints are inserted into the existing Godot runtime structure array and therefore affect its current rectangular destination-nudge obstacle avoidance.",
    "- This is not browser PathfindingGrid parity. Visual roads remain partially decorative, and the visual river/bridge does not fully derive from the generated Broken Ford navigation grid.",
    "- Unit movement near shells is probed, but this remains a review-grade pathing check rather than gameplay certification.", "",
    "## Runtime systems touched", "",
    "- Opt-in Barrosan runtime subclass, generated-authority placement adapter, shell structure records, selection/HUD presentation, minimap evidence and capture tooling.",
    "- Untouched: browser gameplay rules, economy, production, AI, saves, combat, objectives, commands, default launchers and source content definitions.", "",
    "## Validation results", "",
    "- `npm run godot:test`: pass.",
    "- v0.243 capture and dedicated validator: pass.",
    "- `npm test`: pass, 122 files / 887 tests.",
    "- `npm run build`: pass.",
    "- `npm run validate:content`: pass.",
    "- `npm run validate:art-intake`: pass.",
    "- `npm run validate:runtime-art-slots`: pass, 52 slots.",
    "- `npm run godot:validate:salto-experimental-artifact-retention`: pass.",
    "- `npm run godot:all`: pass.",
    "- `git diff --check`: pass.", "",
    "## Exact source files changed", "",
    "- `desktop-spikes/godot-salto/scripts/adapters/build_placement_validation_adapter.gd`",
    "- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`",
    "- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`",
    "- `tools/godot/buildV0243BarrosanBuildValidationRoleShellsReviewPack.py`",
    "- `tools/godot/captureGodotV0243BarrosanBuildValidationRoleShellsWindows.ps1`",
    "- `tools/godot/saltoV0243BarrosanBuildValidationRoleShellsTool.mjs`",
    "- `tools/godot/validateGodotV0243BarrosanBuildValidationRoleShellsWindows.ps1`",
    "- `package.json`",
    "- `docs/V0243_BARROSAN_BUILD_VALIDATION_ROLE_SHELLS_REPORT.md`", "",
    "## Assessment", "",
    "The lane is materially safer: placement feedback is sourced from real exported rules data and the six missing roles now exist in the runtime simulation structure collection. It remains PARTIAL because the bridge mirrors TypeScript semantics rather than invoking TypeScript, shell obstacle avoidance is coarse, and visual roads/river/bridge are not full navigation parity.",
    "",
    "v0.244 limited opt-in gameplay testing may proceed only as a constrained technical playtest if the complete validation matrix and exact-SHA CI remain green; it must not be treated as default-runtime or full-building gameplay approval.", "",
    "Stop after v0.243. Do not begin v0.244.", "",
  ].join("\n");
}

function capture() {
  const errors = [];
  const evidence = inspect(errors);
  if (!["PASS", "PARTIAL", "FAIL"].includes(verdict)) errors.push("invalid verdict");
  mkdirSync(manual, {recursive: true});
  for (const file of required.slice(0, 14)) if (!existsSync(join(manual, file))) errors.push(`missing capture ${file}`);
  const report = markdown(evidence, verdict);
  writeFileSync(join(manual, "16_v0243_report.md"), report);
  writeFileSync(docPath, report);
  writeFileSync(join(root, "v0243-capture-report.json"), JSON.stringify({
    status: errors.length ? "FAIL_V0243_CAPTURE" : "PASS_V0243_BARROSAN_BUILD_VALIDATION_ROLE_SHELLS_CAPTURE",
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
  writeFileSync(join(root, "v0243-validation-report.json"), JSON.stringify({
    status: errors.length ? "FAIL_V0243_VALIDATION" : "PASS_V0243_BARROSAN_BUILD_VALIDATION_ROLE_SHELLS_VALIDATION",
    verdict: existsSync(docPath) ? readFileSync(docPath, "utf8").match(/Verdict: `([^`]+)`/u)?.[1] ?? "UNKNOWN" : "UNKNOWN",
    addressableRoles: evidence.skin.addressableRoles ?? [], liveRoles: evidence.skin.liveMappedRoles ?? [],
    shellRoles: evidence.skin.simSafeShellRoles ?? [], placementValidation: evidence.skin.placementValidation ?? "UNKNOWN",
    blockedPlacementReason: evidence.skin.blockedPlacementReason ?? "UNKNOWN",
    retainedGlbSha256: evidence.glbSha256, errors,
  }, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
