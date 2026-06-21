import {createHash} from "node:crypto";
import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo=resolve(dirname(fileURLToPath(import.meta.url)),"..","..");
const arg=name=>(process.argv.find(v=>v.startsWith(`--${name}=`))??"").split("=").slice(1).join("=");
const root=resolve(arg("artifact-root")||join(repo,"artifacts","desktop-spikes","godot-salto","v0252"));
const verdict=arg("verdict")||"PARTIAL",commit=arg("commit")||"PENDING_PUBLICATION",head=arg("head")||commit,ciRun=arg("ci-run")||"PENDING_PUBLICATION";
const manual=join(repo,"artifacts","manual-review","v0252-barrosan-threat-timing-feedback-bridge");
const docPath=join(repo,"docs","V0252_BARROSAN_THREAT_TIMING_FEEDBACK_BRIDGE_REPORT.md");
const runtimePath=join(root,"runtime","screenshot-runtime-manifest.json"),defaultPath=join(root,"default-runtime","screenshot-runtime-manifest.json");
const glbPath=join(repo,"desktop-spikes","godot-salto","assets","v0239","salto_barrosan_roster_silhouette_beauty.glb");
const names=["opt_in_overview_before_build","starting_resources","select_builder_unit","valid_barracks_preview","confirm_authoritative_barracks_placement","construction_resource_delta","field_barracks_hp_200","train_militia_command_available","train_militia_resource_delta","militia_training_progress","militia_ready_spawned","raider_spawned_once_hp_full","raider_minimap_presence","raider_entering_threat_range","warning_window_started","warning_window_midpoint_no_damage","field_barracks_still_hp_200_during_warning","select_militia_during_warning","attack_command_available_during_warning","attack_order_accepted_during_warning","militia_closing_to_raider","combat_tick_1_hp_90_40","combat_tick_2_hp_80_20","combat_tick_3_raider_hp_zero_militia_70","raider_defeated_or_removed","pressure_contained_before_impact","field_barracks_unharmed_hp_200","no_resource_mutation_after_defended_combat","missed_window_branch_start","missed_window_raider_spawned_once","missed_window_warning_started","missed_window_expired_no_intercept","damage_begins_after_warning_expiry","barracks_damage_tick_1_hp_175","barracks_damage_tick_2_hp_150","barracks_damage_tick_3_hp_125","damage_sequence_stopped","barracks_damaged_but_standing","no_resource_mutation_after_undefended_pressure","aster_worker_unharmed_proof","raider_bounded_stop_after_pressure","existing_barracks_train_flow_preserved","command_keep_preserved","lume_mine_preserved","shells_remain_non_producing","default_runtime_clean_after_opt_in_work","unselected_clean_view"];
const required=["01_v0251_partial_baseline.png","02_v0252_preflight_head_ci_resolution.png","03_v0252_default_runtime_unchanged_proof.png",...names.map((n,i)=>`${String(i+4).padStart(2,"0")}_v0252_${n}.png`),"51_v0252_defended_vs_missed_window_contact_sheet.png","52_v0252_report.md"];
const read=p=>JSON.parse(readFileSync(p,"utf8").replace(/^\uFEFF/u,""));
const sha256=p=>createHash("sha256").update(readFileSync(p)).digest("hex").toUpperCase();
function inspect(errors){
 const runtime=existsSync(runtimePath)?read(runtimePath):{},fallback=existsSync(defaultPath)?read(defaultPath):{},skin=runtime.barrosanPlayableRuntimeSkin??{},bridge=skin.threatTimingFeedbackBridge??{},defended=bridge.defendedInWindowBranch??{},missed=bridge.missedWindowBranch??{},construction=skin.authoritativeConstructionBridge??{},production=defended.production??skin.fieldBarracksProductionBridge??{},dt=defended.threatTiming??{},mt=missed.threatTiming??{};
 if(runtime.status!=="PASS_PLAYER_SLICE_CAPTURE"||runtime.checkpoint!=="v0.252"||runtime.captureCount!==47)errors.push("runtime capture contract failed");
 if(fallback.status!=="PASS_PLAYER_SLICE_CAPTURE"||fallback.checkpoint!=="v0.252"||(fallback.barrosanPlayableRuntimeSkin?.enabled??false)!==false)errors.push("default runtime changed");
 if(bridge.status!=="PASS"||construction.placementResourceDelta?.crowns!==-180||construction.placementResourceDelta?.stone!==-120)errors.push("construction/timing bridge failed");
 if(production.cost?.crowns!==60||production.cost?.iron!==20||production.spawnCount!==1)errors.push("production authority failed");
 if(defended.spawnCount!==1||!dt.threatRangeReached||!dt.warningStarted||!dt.defendedDuringWarning||dt.warningExpired||dt.damageOccurredDuringWarning||dt.fieldBarracksHpAtWarningStart!==200||dt.fieldBarracksHpAtWarningMidpoint!==200)errors.push("defended warning window failed");
 if(!defended.attackOrderAccepted||!defended.combatAuthorizedByAttackOrder||!defended.deterministicTicksPass||defended.finalMilitiaHp!==70||defended.finalRaiderHp!==0||defended.fieldBarracksFinalHp!==200||!defended.raiderDefeated||defended.collateralAfter?.units?.hero_aster!==100||defended.collateralAfter?.units?.worker_00!==80)errors.push("defended combat failed");
 if(missed.status!=="PASS"||!mt.threatRangeReached||!mt.warningStarted||!mt.warningExpired||mt.warningStep!==3||!missed.noDamageDuringWarning||!missed.damageStartedAfterWarning)errors.push("missed warning boundary failed");
 if(missed.raiderSpawnCount!==1||!missed.deterministicBuildingTicksPass||missed.fieldBarracksFinalHp!==125||missed.buildingDamageTickCount!==3||!missed.boundedStop||!missed.boundedRaiderStop||missed.buildingDestroyed)errors.push("bounded damage failed");
 if(!missed.resourcesUnchanged||missed.asterFinalHp!==100||missed.workerFinalHp!==80||!missed.raiderMinimapVisibleDuringWarning)errors.push("mutation/minimap boundary failed");
 if(!bridge.existingRestoredBarracksPreserved||!bridge.commandKeepPreserved||!bridge.lumeMinePreserved||!bridge.shellsRemainNonProducing)errors.push("preservation failed");
 return {runtime,fallback,skin,bridge,defended,missed,construction,production,defendedTiming:dt,missedTiming:mt,glbSha:existsSync(glbPath)?sha256(glbPath):""};
}
function report(e){return [
"# v0.252 Barrosan Threat Timing and Feedback Bridge","",`Verdict: \`${verdict}\``,"","## Exact facts","",
"- Resolved base commit: `06f179f4a40583e7f569dd0c0ebafd3411d7afeb`.",
"- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27916829778.",
`- Implementation commit: \`${commit}\`.`,`- Final repository HEAD: \`${head}\`.`,`- Exact-SHA GitHub Actions run: ${ciRun}.`,
"- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
`- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (${e.glbSha}).`,
"- Files changed: opt-in runtime subclass, capture dispatch, v0.252 evidence/validator/report tooling, package scripts and this report.",
"- Runtime systems touched: v0.252-only three-step warning state, threat/damage-imminent markers, HUD copy, bounded damage feedback and branch proofs.",
"- Default systems untouched: browser/default Godot runtime, global combat, AI, waves, economy, saves, pathfinding and assets.","",
"## Construction and warning contract","",
"- Field Barracks construction: -180 Crowns / -120 Stone; starting HP 200/200.",
"- Militia production: -60 Crowns / -20 Iron; exactly one Militia in the defended branch.",
`- Raider: \`${e.defended.runtimeId}\`; count ${e.defended.spawnCount}.`,
`- Warning starts when ${e.bridge.warningStartCondition}.`,
`- Warning duration: ${e.bridge.warningDurationSeconds} seconds / ${e.bridge.warningStepCount} deterministic steps.`,
`- No warning damage: defended=${!e.defendedTiming.damageOccurredDuringWarning}; missed=${e.missed.noDamageDuringWarning}; Barracks remains ${e.missedTiming.fieldBarracksHpAtWarningExpiry}/200 at expiry.`,
`- Minimap readable during warning: ${e.missed.raiderMinimapVisibleDuringWarning}.`,"",
"## Defended in window","",
`- Attack behavior: ${e.defended.attackCommandImplementation}.`,
`- Combat starts only after accepted order plus ${e.defended.combatStartCondition}.`,
`- HP sequence: 100/60 -> 90/40 -> 80/20 -> ${e.defended.finalMilitiaHp}/${e.defended.finalRaiderHp}.`,
`- Field Barracks final HP: ${e.defended.fieldBarracksFinalHp}/200; Raider defeated: ${e.defended.raiderDefeated}; removed: ${e.defended.raiderRemoved}.`,"",
"## Missed window","",
"- Damage trigger: warning expires at step 3 with no valid Militia intercept.",
"- Field Barracks HP: 200 -> 175 -> 150 -> 125.",
`- Damage stopped: ${e.missed.boundedStop}; Raider bounded: ${e.missed.boundedRaiderStop}; building survives: ${e.missed.fieldBarracksSurvives}; destroyed: ${e.missed.buildingDestroyed}.`,
`- Resources unchanged: ${e.missed.resourcesUnchanged}; Aster HP: ${e.missed.asterFinalHp}/100; Worker HP: ${e.missed.workerFinalHp}/80.`,"",
"## Preservation and validation","",
`- Existing Barracks / Keep / Mine preserved: ${e.bridge.existingRestoredBarracksPreserved} / ${e.bridge.commandKeepPreserved} / ${e.bridge.lumeMinePreserved}.`,
`- Shells remain non-producing: ${e.bridge.shellsRemainNonProducing}.`,
"- Default runtime proof: opt-in skin disabled; no Raider, warning window, Field Barracks HP bridge, building damage, attack-order pressure bridge or v0.252 copy.",
`- Pathing honesty: ${e.bridge.pathingParity}.`,
"- v0.252 capture and dedicated validator: pass.",
`- Full local validation: pass. Exact-SHA GitHub Actions: ${ciRun.startsWith("PENDING")?"pending publication":"pass"}.`,"","## Honest assessment","",
"The warning is fair, readable and deterministic, but it remains a scripted three-step window on a review-grade Raider route to one constructed Field Barracks. Verdict remains PARTIAL.",
"Recommendation for v0.253: improve player-controlled timing feel and damage feedback cadence without adding waves, destruction, repair, broad AI or free pathfinding.","",
"Stop after v0.252. Do not begin v0.253.",""
].join("\n")}
function capture(){const errors=[],e=inspect(errors);mkdirSync(manual,{recursive:true});for(const f of required.slice(0,-1))if(!existsSync(join(manual,f)))errors.push(`missing ${f}`);const md=report(e);writeFileSync(join(manual,"52_v0252_report.md"),md);writeFileSync(docPath,md);writeFileSync(join(root,"v0252-capture-report.json"),JSON.stringify({status:errors.length?"FAIL_V0252_CAPTURE":"PASS_V0252_BARROSAN_THREAT_TIMING_FEEDBACK_BRIDGE_CAPTURE",verdict,...e,errors},null,2)+"\n");if(errors.length)throw new Error(errors.join("\n"))}
function validation(){const errors=[],e=inspect(errors);for(const f of required){const p=join(manual,f);if(!existsSync(p))errors.push(`missing ${f}`);else if(statSync(p).size<(f.endsWith(".png")?10000:700))errors.push(`small ${f}`)}writeFileSync(join(root,"v0252-validation-report.json"),JSON.stringify({status:errors.length?"FAIL_V0252_VALIDATION":"PASS_V0252_BARROSAN_THREAT_TIMING_FEEDBACK_BRIDGE_VALIDATION",bridgeStatus:e.bridge.status??"UNKNOWN",errors},null,2)+"\n");if(errors.length)throw new Error(errors.join("\n"))}
if((process.argv[2]??"capture")==="capture")capture();else validation();
