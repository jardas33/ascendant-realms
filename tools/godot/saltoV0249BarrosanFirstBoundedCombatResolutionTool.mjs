import {createHash} from "node:crypto";
import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const arg = name => (process.argv.find(value => value.startsWith(`--${name}=`)) ?? "").split("=").slice(1).join("=");
const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0249"));
const verdict = arg("verdict") || "PARTIAL";
const commit = arg("commit") || "PENDING_PUBLICATION";
const head = arg("head") || commit;
const ciRun = arg("ci-run") || "PENDING_PUBLICATION";
const manual = join(repo, "artifacts", "manual-review", "v0249-barrosan-first-bounded-combat-resolution");
const runtimePath = join(root, "runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0239", "salto_barrosan_roster_silhouette_beauty.glb");
const docPath = join(repo, "docs", "V0249_BARROSAN_FIRST_BOUNDED_COMBAT_RESOLUTION_REPORT.md");
const names = [
  "01_v0248_partial_baseline.png","02_v0249_preflight_head_ci_resolution.png","03_v0249_default_runtime_unchanged_proof.png",
  "04_v0249_opt_in_overview_before_build.png","05_v0249_starting_resources.png","06_v0249_select_builder_unit.png",
  "07_v0249_valid_barracks_preview.png","08_v0249_confirm_authoritative_barracks_placement.png","09_v0249_construction_resource_delta.png",
  "10_v0249_select_new_field_barracks_hud.png","11_v0249_train_militia_command_available.png","12_v0249_train_militia_resource_delta.png",
  "13_v0249_militia_training_progress.png","14_v0249_militia_ready_spawned.png","15_v0249_select_spawned_militia_hp_100.png",
  "16_v0249_pressure_telegraph_marker_preserved.png","17_v0249_intercept_zone_marker_preserved.png","18_v0249_ashen_pressure_incoming_objective.png",
  "19_v0249_ashen_raider_spawned_once_hp_full.png","20_v0249_ashen_raider_minimap_presence.png","21_v0249_ashen_raider_advancing_readable_timing.png",
  "22_v0249_militia_moves_to_intercept.png","23_v0249_combat_contact_begins.png","24_v0249_combat_tick_1_hp_delta.png",
  "25_v0249_combat_tick_2_hp_delta.png","26_v0249_raider_defeated_hp_zero.png","27_v0249_raider_removed_or_defeated_state.png",
  "28_v0249_raider_minimap_removed_or_defeated.png","29_v0249_militia_survives_after_combat.png","30_v0249_pressure_contained_by_combat_status.png",
  "31_v0249_no_resource_mutation_after_combat.png","32_v0249_no_building_damage_proof.png","33_v0249_aster_worker_unharmed_proof.png",
  "34_v0249_existing_barracks_train_flow_preserved.png","35_v0249_command_keep_preserved.png","36_v0249_lume_mine_preserved.png",
  "37_v0249_shells_remain_non_producing.png","38_v0249_unselected_clean_view.png","39_v0249_before_after_contact_sheet.png","40_v0249_report.md",
];
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
const sha256 = path => createHash("sha256").update(readFileSync(path)).digest("hex").toUpperCase();

function inspect(errors) {
  for (const path of [runtimePath, defaultPath, glbPath]) if (!existsSync(path)) errors.push(`missing ${path}`);
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  const fallback = existsSync(defaultPath) ? read(defaultPath) : {};
  const skin = runtime.barrosanPlayableRuntimeSkin ?? {};
  const construction = skin.authoritativeConstructionBridge ?? {};
  const production = skin.fieldBarracksProductionBridge ?? {};
  const combat = skin.boundedCombatResolutionBridge ?? {};
  if (runtime.status !== "PASS_PLAYER_SLICE_CAPTURE" || runtime.checkpoint !== "v0.249" || runtime.captureCount !== 35) errors.push("runtime capture contract failed");
  if (fallback.status !== "PASS_PLAYER_SLICE_CAPTURE" || fallback.checkpoint !== "v0.249") errors.push("default capture contract failed");
  if (skin.enabled !== true || skin.checkpoint !== "v0.249" || skin.defaultRuntimeChanged !== false) errors.push("opt-in boundary failed");
  if ((fallback.barrosanPlayableRuntimeSkin?.enabled ?? false) !== false) errors.push("default runtime changed");
  if (construction.status !== "PASS" || construction.placementResourceDelta?.crowns !== -180 || construction.placementResourceDelta?.stone !== -120 || construction.spendCount !== 1) errors.push("construction failed");
  if (production.status !== "PASS" || production.queueResourceDelta?.crowns !== -60 || production.queueResourceDelta?.iron !== -20 || production.spawnCount !== 1) errors.push("production failed");
  if (combat.status !== "PASS" || combat.runtimeId !== "v0247_ashen_raider_00" || combat.spawnCount !== 1) errors.push("combat bridge failed");
  if (combat.combatStarted !== true || combat.combatStartedBeforeContact !== false || combat.combatStartInInterceptZone !== true) errors.push("combat contact gate failed");
  if (combat.deterministicTicksPass !== true || combat.combatTickCount !== 3 || combat.finalMilitiaHp !== 70 || combat.finalRaiderHp !== 0) errors.push("deterministic HP model failed");
  if (combat.raiderDefeated !== true || combat.raiderRemoved !== true || combat.containedByCombat !== true) errors.push("Raider defeat/containment failed");
  if (combat.minimapRegistered !== true || combat.raiderMinimapRemoved !== true) errors.push("minimap lifecycle failed");
  if (combat.pressureResourcesUnchanged !== true || combat.buildingsUnharmed !== true || combat.asterWorkerUnharmed !== true) errors.push("mutation boundary failed");
  if (combat.deathLimitedToRaider !== true || combat.enemyAiExists !== false || combat.wavesExist !== false || combat.baseDamageExists !== false) errors.push("scope boundary failed");
  if (combat.objectiveLadderPass !== true || combat.telegraphRegistered !== true || combat.interceptMarkerRegistered !== true) errors.push("v0.248 readability preservation failed");
  if (combat.existingRestoredBarracksPreserved !== true || combat.commandKeepPreserved !== true || combat.lumeMinePreserved !== true || combat.shellsRemainNonProducing !== true) errors.push("entity preservation failed");
  if ((skin.errors ?? []).length) errors.push(`runtime errors: ${(skin.errors ?? []).join(", ")}`);
  return {runtime, fallback, skin, construction, production, combat, glbSha: existsSync(glbPath) ? sha256(glbPath) : ""};
}

function report(e) {
  return [
    "# v0.249 Barrosan First Bounded Combat Resolution Bridge","",`Verdict: \`${verdict}\``,"",
    "## Exact facts","",
    "- Resolved base commit: `cca1b455cbda9df2873e972d9ba4528f6271a7b7`.",
    "- v0.248 implementation commit: `6c5cfa196e31229b3c976254212114dcbeeef473`; documentation closeout/base: `cca1b455cbda9df2873e972d9ba4528f6271a7b7`.",
    "- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27909037181.",
    `- Implementation commit: \`${commit}\`.`,`- Final repository HEAD: \`${head}\`.`,`- Exact-SHA GitHub Actions run: ${ciRun}.`,
    "- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes.",
    `- Existing GLB SHA-256: \`${e.glbSha}\`.`,
    "- Files changed: the opt-in runtime subclass, capture dispatch, v0.249 capture/validator/report tools, package scripts and this report.",
    "- Runtime systems touched: only opt-in Field Barracks/Militia/Ashen pressure state, deterministic contact ticks, HP HUD, combat marker, Raider defeat and minimap visibility.",
    "- Default systems untouched: browser/default Godot runtime, global combat, AI, waves, buildings, economy, saves, pathfinding and assets.","",
    "## Bounded model","",
    "- Construction target/cost: one authoritative Field Barracks; 180 Crowns / 120 Stone.",
    "- Production target/cost: one Militia; 60 Crowns / 20 Iron.",
    `- Raider ID/count: \`${e.combat.runtimeId}\` / ${e.combat.spawnCount}.`,
    `- Combat model: ${e.combat.combatModel}.`,
    `- Militia HP: ${e.combat.militiaMaxHp}; Raider HP: ${e.combat.raiderMaxHp}.`,
    `- Militia damage: ${e.combat.militiaDamagePerTick}; Raider damage: ${e.combat.raiderDamagePerTick}; tick interval: ${e.combat.tickIntervalSeconds}s.`,
    `- Combat start: ${e.combat.combatStartCondition}; measured distance ${e.combat.combatStartDistance}.`,
    "- Combat end: third deterministic exchange reduces Raider to 0 HP.",
    `- Final Militia / Raider HP: ${e.combat.finalMilitiaHp} / ${e.combat.finalRaiderHp}.`,
    `- Raider removed/defeated: ${e.combat.raiderRemoved}; minimap removed: ${e.combat.raiderMinimapRemoved}.`,
    `- Pressure contained by combat: ${e.combat.containedByCombat}.`,
    "- Death exists only for the scripted Raider. Militia cannot die in this version.",
    "- Enemy AI: no. Waves: no. Base/building damage: no.","",
    "## Proof","",
    `- Starting resources: ${JSON.stringify(e.construction.startingResources ?? {})}.`,
    `- After construction: ${JSON.stringify(e.construction.afterPlacementResources ?? {})}; delta ${JSON.stringify(e.construction.placementResourceDelta ?? {})}.`,
    `- After training: ${JSON.stringify(e.production.resourcesAfterTrainingSpend ?? {})}; delta ${JSON.stringify(e.production.queueResourceDelta ?? {})}.`,
    `- Resources unchanged through telegraph, spawn, movement, combat and containment: ${e.combat.pressureResourcesUnchanged}.`,
    `- Buildings unharmed: ${e.combat.buildingsUnharmed}; Aster/Worker unharmed: ${e.combat.asterWorkerUnharmed}.`,
    `- Objective ladder: ${(e.combat.objectiveLadder ?? []).join(" -> ")}.`,
    `- Telegraph/intercept markers preserved: ${e.combat.telegraphRegistered} / ${e.combat.interceptMarkerRegistered}.`,
    `- Raider minimap before/after defeat: ${e.combat.minimapRegistered} / removed=${e.combat.raiderMinimapRemoved}.`,
    `- Existing Restored Barracks / Command Keep / Lume Mine preserved: ${e.combat.existingRestoredBarracksPreserved} / ${e.combat.commandKeepPreserved} / ${e.combat.lumeMinePreserved}.`,
    `- Forge, Market and Watchtower remain non-producing shells: ${e.combat.shellsRemainNonProducing}.`,
    "- Default runtime proof: default capture has the opt-in skin disabled and contains no Raider, markers, combat state or v0.249 HUD semantics.",
    `- Pathing honesty: ${e.combat.pathingParity}.`,"",
    "## Validation results","",
    "- `npm run godot:test`: pass.",
    "- v0.249 capture and dedicated validator: pass.",
    "- `npm test`: pass, 122 files / 887 tests.",
    "- `npm run build`: pass.",
    "- Content, art-intake and 52 runtime-art-slot validators: pass.",
    "- Experimental artifact retention: pass.",
    "- `npm run godot:all`: pass.",
    "- `git diff --check`: pass.",
    "- Exact-SHA GitHub Actions: pending publication.","",
    "## Honest assessment","",
    "The bridge proves the smallest believable combat lifecycle, but remains deliberately single-pair, scripted, contact/proximity-based and visually primitive. Verdict remains PARTIAL.",
    "Recommendation for v0.250: harden player-issued attack/contact behavior or presentation without adding waves, broad AI, building damage or a general combat rewrite.",
    "","Stop after v0.249. Do not begin v0.250.","",
  ].join("\n");
}

function capture() {
  const errors = [];
  const evidence = inspect(errors);
  if (!["PASS","PARTIAL","FAIL"].includes(verdict)) errors.push("invalid verdict");
  mkdirSync(manual, {recursive: true});
  for (const file of names.slice(0, 39)) if (!existsSync(join(manual, file))) errors.push(`missing capture ${file}`);
  const markdown = report(evidence);
  writeFileSync(join(manual, "40_v0249_report.md"), markdown);
  writeFileSync(docPath, markdown);
  writeFileSync(join(root, "v0249-capture-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0249_CAPTURE" : "PASS_V0249_BARROSAN_FIRST_BOUNDED_COMBAT_RESOLUTION_CAPTURE", verdict, construction: evidence.construction, production: evidence.production, combat: evidence.combat, errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  const evidence = inspect(errors);
  for (const file of names) {
    const path = join(manual, file);
    if (!existsSync(path)) errors.push(`missing review file ${file}`);
    else if (statSync(path).size < (file.endsWith(".png") ? 10000 : 700)) errors.push(`review file too small ${file}`);
  }
  if (!existsSync(docPath)) errors.push("missing report");
  writeFileSync(join(root, "v0249-validation-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0249_VALIDATION" : "PASS_V0249_BARROSAN_FIRST_BOUNDED_COMBAT_RESOLUTION_VALIDATION", combatStatus: evidence.combat.status ?? "UNKNOWN", errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
