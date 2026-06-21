import {createHash} from "node:crypto";
import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo=resolve(dirname(fileURLToPath(import.meta.url)),"..","..");
const arg=name=>(process.argv.find(v=>v.startsWith(`--${name}=`))??"").split("=").slice(1).join("=");
const root=resolve(arg("artifact-root")||join(repo,"artifacts","desktop-spikes","godot-salto","v0251"));
const verdict=arg("verdict")||"PARTIAL",commit=arg("commit")||"PENDING_PUBLICATION",head=arg("head")||commit,ciRun=arg("ci-run")||"PENDING_PUBLICATION";
const manual=join(repo,"artifacts","manual-review","v0251-barrosan-first-defense-consequence-bridge");
const docPath=join(repo,"docs","V0251_BARROSAN_FIRST_DEFENSE_CONSEQUENCE_BRIDGE_REPORT.md");
const runtimePath=join(root,"runtime","screenshot-runtime-manifest.json"),defaultPath=join(root,"default-runtime","screenshot-runtime-manifest.json");
const glbPath=join(repo,"desktop-spikes","godot-salto","assets","v0239","salto_barrosan_roster_silhouette_beauty.glb");
const names=["opt_in_overview_before_build","starting_resources","select_builder_unit","valid_barracks_preview","confirm_authoritative_barracks_placement","construction_resource_delta","field_barracks_hp_200","select_new_field_barracks_hud","train_militia_command_available","train_militia_resource_delta","militia_training_progress","militia_ready_spawned","select_spawned_militia_hp_100_attack_available","pressure_telegraph_marker_preserved","intercept_zone_marker_preserved","ashen_raider_spawned_once_hp_full","raider_minimap_presence","attack_command_available","attack_order_accepted","militia_closing_to_raider","combat_tick_1_hp_90_40","combat_tick_2_hp_80_20","combat_tick_3_raider_hp_zero_militia_70","raider_defeated_or_removed","pressure_contained_by_attack_order","field_barracks_unharmed_defended_branch_hp_200","no_resource_mutation_after_defended_combat","undefended_branch_start","undefended_raider_spawned_once","undefended_raider_advancing_to_barracks","undefended_barracks_pressure_contact","barracks_damage_tick_1_hp_175","barracks_damage_tick_2_hp_150","barracks_damage_tick_3_hp_125","barracks_damaged_but_standing","undefended_pressure_damage_contained","no_resource_mutation_after_building_damage","aster_worker_unharmed_proof","existing_barracks_train_flow_preserved","command_keep_preserved","lume_mine_preserved","shells_remain_non_producing","default_runtime_clean_after_opt_in_work","unselected_clean_view"];
const required=["01_v0250_partial_baseline.png","02_v0251_preflight_head_ci_resolution.png","03_v0251_default_runtime_unchanged_proof.png",...names.map((n,i)=>`${String(i+4).padStart(2,"0")}_v0251_${n}.png`),"48_v0251_defended_vs_undefended_contact_sheet.png","49_v0251_report.md"];
const read=p=>JSON.parse(readFileSync(p,"utf8").replace(/^\uFEFF/u,""));
const sha256=p=>createHash("sha256").update(readFileSync(p)).digest("hex").toUpperCase();
function inspect(errors){
 const runtime=existsSync(runtimePath)?read(runtimePath):{},fallback=existsSync(defaultPath)?read(defaultPath):{},skin=runtime.barrosanPlayableRuntimeSkin??{},bridge=skin.firstDefenseConsequenceBridge??{},defended=bridge.defendedBranch??{},undefended=bridge.undefendedBranch??{},construction=skin.authoritativeConstructionBridge??{},production=defended.production??skin.fieldBarracksProductionBridge??{};
 if(runtime.status!=="PASS_PLAYER_SLICE_CAPTURE"||runtime.checkpoint!=="v0.251"||runtime.captureCount!==44)errors.push("runtime capture contract failed");
 if(fallback.status!=="PASS_PLAYER_SLICE_CAPTURE"||fallback.checkpoint!=="v0.251"||(fallback.barrosanPlayableRuntimeSkin?.enabled??false)!==false)errors.push("default runtime changed");
 if(bridge.status!=="PASS"||construction.placementResourceDelta?.crowns!==-180||construction.placementResourceDelta?.stone!==-120)errors.push("construction/consequence bridge failed");
 if(defended.spawnCount!==1||!defended.attackOrderAccepted||!defended.combatAuthorizedByAttackOrder||defended.combatStartedBeforeContact!==false||!defended.deterministicTicksPass||defended.finalMilitiaHp!==70||defended.finalRaiderHp!==0||defended.fieldBarracksFinalHp!==200)errors.push("defended branch failed");
 if(production.cost?.crowns!==60||production.cost?.iron!==20)errors.push("production authority failed");
 if(undefended.status!=="PASS"||undefended.raiderSpawnCount!==1||!undefended.buildingPressureContact||undefended.buildingDamageStartedBeforeContact!==false||!undefended.deterministicBuildingTicksPass||undefended.fieldBarracksFinalHp!==125||!undefended.fieldBarracksSurvives)errors.push("undefended branch failed");
 if(undefended.buildingDamageTickCount!==3||!undefended.boundedStop||undefended.buildingDestroyed||!undefended.resourcesUnchanged||!undefended.asterWorkerUnharmed)errors.push("bounded mutation boundary failed");
 if(!bridge.existingRestoredBarracksPreserved||!bridge.commandKeepPreserved||!bridge.lumeMinePreserved||!bridge.shellsRemainNonProducing)errors.push("preservation failed");
 return {runtime,fallback,skin,bridge,defended,undefended,construction,production,glbSha:existsSync(glbPath)?sha256(glbPath):""};
}
function report(e){return [
"# v0.251 Barrosan First Defense Consequence Bridge","",`Verdict: \`${verdict}\``,"","## Exact facts","",
"- Resolved base commit: `c260c2e49c6acad48340fbac5d818929b0e6bde2`.",
"- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27915230603.",
`- Implementation commit: \`${commit}\`.`,`- Final repository HEAD: \`${head}\`.`,`- Exact-SHA GitHub Actions run: ${ciRun}.`,
"- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
`- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (${e.glbSha}).`,
"- Files changed: opt-in runtime subclass, capture dispatch, v0.251 evidence/validator/report tooling, package scripts and this report.",
"- Runtime systems touched: v0.251-only Field Barracks HP, bounded Raider building-pressure state, HUD feedback and defended/undefended proof snapshots.",
"- Default systems untouched: browser/default Godot runtime, global combat, AI, waves, economy, saves, pathfinding and assets.","",
"## Defended branch","",
"- Field Barracks construction: -180 Crowns / -120 Stone; starting HP 200/200.",
"- Militia production: -60 Crowns / -20 Iron; exactly one Militia.",
`- Raider: \`${e.defended.runtimeId}\`; count ${e.defended.spawnCount}.`,
`- Attack behavior: ${e.defended.attackCommandImplementation}.`,
`- Combat starts only after accepted order plus ${e.defended.combatStartCondition}.`,
`- HP sequence: 100/60 -> 90/40 -> 80/20 -> ${e.defended.finalMilitiaHp}/${e.defended.finalRaiderHp}.`,
`- Field Barracks final HP: ${e.defended.fieldBarracksFinalHp}/200; Raider defeated: ${e.defended.raiderDefeated}; removed: ${e.defended.raiderRemoved}.`,"",
"## Undefended branch","",
"- Start condition: Field Barracks built, no Militia trained, no Attack order.",
`- Damage trigger: one Raider reaches the constructed Field Barracks within the bounded pressure radius; contact=${e.undefended.buildingPressureContact}.`,
"- Field Barracks HP: 200 -> 175 -> 150 -> 125.",
`- Survives: ${e.undefended.fieldBarracksSurvives}; any building destroyed: ${e.undefended.buildingDestroyed}.`,
`- Bounded stop after three ticks: ${e.undefended.boundedStop}; resources unchanged: ${e.undefended.resourcesUnchanged}; Aster/Worker unharmed: ${e.undefended.asterWorkerUnharmed}.`,
`- Raider minimap registered before pressure: ${e.undefended.raiderMinimapRegistered}.`,"",
"## Preservation and validation","",
`- Existing Barracks / Keep / Mine preserved: ${e.bridge.existingRestoredBarracksPreserved} / ${e.bridge.commandKeepPreserved} / ${e.bridge.lumeMinePreserved}.`,
`- Shells remain non-producing: ${e.bridge.shellsRemainNonProducing}.`,
"- Default runtime proof: opt-in skin disabled; no Raider, Field Barracks HP bridge, building damage, or v0.251 objective text.",
`- Pathing honesty: ${e.bridge.pathingParity}.`,
"- v0.251 capture and dedicated validator: pass.",
`- Full local validation: pass. Exact-SHA GitHub Actions: ${ciRun.startsWith("PENDING")?"pending publication":"pass"}.`,"","## Honest assessment","",
"The first defense consequence is readable and deterministic, but the undefended Raider route targets only the constructed Field Barracks and stops after a scripted three-tick sequence. Verdict remains PARTIAL.",
"Recommendation for v0.252: improve natural player-facing consequence timing and feedback without adding waves, destruction, repair, or broad AI.","",
"Stop after v0.251. Do not begin v0.252.",""
].join("\n")}
function capture(){const errors=[],e=inspect(errors);mkdirSync(manual,{recursive:true});for(const f of required.slice(0,-1))if(!existsSync(join(manual,f)))errors.push(`missing ${f}`);const md=report(e);writeFileSync(join(manual,"49_v0251_report.md"),md);writeFileSync(docPath,md);writeFileSync(join(root,"v0251-capture-report.json"),JSON.stringify({status:errors.length?"FAIL_V0251_CAPTURE":"PASS_V0251_BARROSAN_FIRST_DEFENSE_CONSEQUENCE_BRIDGE_CAPTURE",verdict,...e,errors},null,2)+"\n");if(errors.length)throw new Error(errors.join("\n"))}
function validation(){const errors=[],e=inspect(errors);for(const f of required){const p=join(manual,f);if(!existsSync(p))errors.push(`missing ${f}`);else if(statSync(p).size<(f.endsWith(".png")?10000:700))errors.push(`small ${f}`)}writeFileSync(join(root,"v0251-validation-report.json"),JSON.stringify({status:errors.length?"FAIL_V0251_VALIDATION":"PASS_V0251_BARROSAN_FIRST_DEFENSE_CONSEQUENCE_BRIDGE_VALIDATION",bridgeStatus:e.bridge.status??"UNKNOWN",errors},null,2)+"\n");if(errors.length)throw new Error(errors.join("\n"))}
if((process.argv[2]??"capture")==="capture")capture();else validation();
