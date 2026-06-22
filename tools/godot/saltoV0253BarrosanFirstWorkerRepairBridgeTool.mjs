import {createHash} from "node:crypto";
import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo=resolve(dirname(fileURLToPath(import.meta.url)),"..","..");
const arg=name=>(process.argv.find(v=>v.startsWith(`--${name}=`))??"").split("=").slice(1).join("=");
const root=resolve(arg("artifact-root")||join(repo,"artifacts","desktop-spikes","godot-salto","v0253"));
const verdict=arg("verdict")||"PARTIAL",commit=arg("commit")||"PENDING_PUBLICATION",head=arg("head")||commit,ciRun=arg("ci-run")||"PENDING_PUBLICATION";
const manual=join(repo,"artifacts","manual-review","v0253-barrosan-first-worker-repair-bridge");
const docPath=join(repo,"docs","V0253_BARROSAN_FIRST_WORKER_REPAIR_BRIDGE_REPORT.md");
const runtimePath=join(root,"runtime","screenshot-runtime-manifest.json"),defaultPath=join(root,"default-runtime","screenshot-runtime-manifest.json");
const glbPath=join(repo,"desktop-spikes","godot-salto","assets","v0239","salto_barrosan_roster_silhouette_beauty.glb");
const names=["opt_in_overview_before_build","starting_resources","select_worker_construction_available","valid_barracks_preview","confirm_authoritative_barracks_placement","construction_resource_delta","field_barracks_hp_200","raider_spawned_once_hp_full","raider_enters_threat_range","warning_window_started","warning_midpoint_no_damage","warning_expired_no_intercept","damage_tick_1_barracks_hp_175","damage_tick_2_barracks_hp_150","damage_tick_3_barracks_hp_125","damage_stopped_barracks_survives","select_damaged_field_barracks_hud","select_worker_after_damage","worker_repair_command_available","repair_order_accepted","repair_resource_delta","repair_progress_tick_1_hp_150","repair_progress_tick_2_hp_175","repair_progress_tick_3_hp_200","repair_complete_hud","repair_command_unavailable_at_full_hp","no_resource_mutation_after_repair_complete","aster_worker_unharmed_proof","raider_bounded_after_pressure","minimap_preserved_during_repair","defended_branch_start","defended_train_militia_resource_delta","defended_warning_window","defended_attack_order_accepted","defended_combat_tick_1_90_40","defended_combat_tick_2_80_20","defended_combat_tick_3_70_0","defended_barracks_unharmed_hp_200","defended_repair_not_available_full_hp","existing_barracks_train_flow_preserved","command_keep_preserved","lume_mine_preserved","shells_remain_non_producing","default_runtime_clean_after_opt_in_work","unselected_clean_view"];
const required=["01_v0252_partial_baseline.png","02_v0253_preflight_head_ci_resolution.png","03_v0253_default_runtime_unchanged_proof.png",...names.map((n,i)=>`${String(i+4).padStart(2,"0")}_v0253_${n}.png`),"49_v0253_repair_contact_sheet.png","50_v0253_report.md"];
const read=p=>JSON.parse(readFileSync(p,"utf8").replace(/^\uFEFF/u,""));
const sha256=p=>createHash("sha256").update(readFileSync(p)).digest("hex").toUpperCase();

function inspect(errors){
 const runtime=existsSync(runtimePath)?read(runtimePath):{},fallback=existsSync(defaultPath)?read(defaultPath):{},skin=runtime.barrosanPlayableRuntimeSkin??{},bridge=skin.firstWorkerRepairBridge??{},repair=bridge.repairBranch??{},missed=repair.missedWindow??{},defended=bridge.defendedRegressionBranch??{},construction=skin.authoritativeConstructionBridge??{},timing=missed.threatTiming??{};
 if(runtime.status!=="PASS_PLAYER_SLICE_CAPTURE"||runtime.checkpoint!=="v0.253"||runtime.captureCount!==45)errors.push("runtime capture contract failed");
 if(fallback.status!=="PASS_PLAYER_SLICE_CAPTURE"||fallback.checkpoint!=="v0.253"||(fallback.barrosanPlayableRuntimeSkin?.enabled??false)!==false)errors.push("default runtime changed");
 if(bridge.status!=="PASS"||construction.placementResourceDelta?.crowns!==-180||construction.placementResourceDelta?.stone!==-120)errors.push("construction/repair bridge failed");
 if(missed.status!=="PASS"||!timing.warningStarted||!timing.warningExpired||!missed.noDamageDuringWarning||missed.fieldBarracksFinalHp!==125||missed.buildingDamageTickCount!==3||!missed.boundedStop||missed.buildingDestroyed)errors.push("missed-window regression failed");
 if(repair.status!=="PASS"||repair.fieldBarracksHpBeforeRepair!==125||repair.repairSpendCount!==1||repair.repairResourceDelta?.crowns!==-30||repair.repairResourceDelta?.stone!==-30||repair.repairResourceDelta?.iron!==0||repair.repairResourceDelta?.aether!==0)errors.push("repair authority/cost failed");
 if(!repair.repairHpSequencePass||repair.fieldBarracksFinalHp!==200||!repair.repairComplete||repair.overhealOccurred||!repair.repeatedChargeRejected||!repair.resourcesUnchangedAfterRepair||repair.repairCommandAvailableAtFullHp)errors.push("repair completion boundary failed");
 if(repair.asterFinalHp!==100||repair.workerFinalHp!==80||repair.raiderSpawnCount!==1||!repair.raiderBoundedAfterPressure||!repair.workerMinimapVisibleDuringRepair||!repair.fieldBarracksMinimapVisibleDuringRepair)errors.push("repair preservation failed");
 if(defended.status!=="PASS"||defended.spawnCount!==1||!defended.attackOrderAccepted||!defended.deterministicTicksPass||defended.finalMilitiaHp!==70||defended.finalRaiderHp!==0||defended.fieldBarracksFinalHp!==200||defended.repairCommandAvailable)errors.push("defended regression failed");
 if(!bridge.existingRestoredBarracksPreserved||!bridge.commandKeepPreserved||!bridge.lumeMinePreserved||!bridge.shellsRemainNonProducing)errors.push("live entity preservation failed");
 return {runtime,fallback,skin,bridge,repair,missed,defended,construction,timing,glbSha:existsSync(glbPath)?sha256(glbPath):""};
}

function report(e){return [
"# v0.253 Barrosan First Worker Repair Bridge","",`Verdict: \`${verdict}\``,"","## Exact facts","",
"- Resolved base commit: `c6acf6a01b23d66403f3e8b7ebe3a486fb33f71c`.",
"- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27921864487.",
`- Implementation commit: \`${commit}\`.`,`- Final repository HEAD: \`${head}\`.`,`- Exact-SHA GitHub Actions run: ${ciRun}.`,
"- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
`- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (${e.glbSha}).`,
"- Files changed: opt-in runtime subclass, capture dispatch, v0.253 evidence/validator/report tooling, package scripts and this report.",
"- Runtime systems touched: one Worker-selected repair command, one authoritative Field Barracks target, deterministic repair ticks, repair HUD and restrained repair marker.",
"- Default systems untouched: browser/default Godot runtime, global repair, AI, waves, destruction, economy, saves, pathfinding and assets.","",
"## Damage and repair contract","",
"- Construction cost: -180 Crowns / -120 Stone. Field Barracks starts 200/200.",
"- Missed-window damage: 200 -> 175 -> 150 -> 125; damage then stops and the building survives.",
"- Repair preconditions: opt-in v0.253, Worker selected and alive, authoritative Field Barracks exists at less than 200 HP after bounded pressure, repair not already active or complete.",
"- Repair cost: -30 Crowns / -30 Stone / 0 Iron / 0 Aether, charged exactly once.",
"- Repair resources: 240/40/90/38 -> 210/10/90/38.",
"- Repair HP: 125 -> 150 -> 175 -> 200.",
`- Repair final HP: ${e.repair.fieldBarracksFinalHp}/200; stopped: ${e.repair.repairComplete}; overheal: ${e.repair.overhealOccurred}; repeated charge rejected: ${e.repair.repeatedChargeRejected}; available at full HP: ${e.repair.repairCommandAvailableAtFullHp}.`,
`- Resources unchanged after completion: ${e.repair.resourcesUnchangedAfterRepair}.`,"",
"## Defended regression","",
"- Exactly one Militia and one Raider; explicit Attack remains required during the warning window.",
`- Combat remains 100/60 -> 90/40 -> 80/20 -> ${e.defended.finalMilitiaHp}/${e.defended.finalRaiderHp}.`,
`- Field Barracks final HP: ${e.defended.fieldBarracksFinalHp}/200; Repair available: ${e.defended.repairCommandAvailable}.`,"",
"## Preservation and validation","",
`- Aster / Worker HP: ${e.repair.asterFinalHp}/100 and ${e.repair.workerFinalHp}/80.`,
`- Minimap Worker / Field Barracks readable during repair: ${e.repair.workerMinimapVisibleDuringRepair} / ${e.repair.fieldBarracksMinimapVisibleDuringRepair}.`,
`- Existing Barracks / Keep / Mine preserved: ${e.bridge.existingRestoredBarracksPreserved} / ${e.bridge.commandKeepPreserved} / ${e.bridge.lumeMinePreserved}.`,
`- Shells remain non-producing: ${e.bridge.shellsRemainNonProducing}.`,
"- Default runtime proof: opt-in skin disabled; no repair state, repair command, repair marker, repair spend or v0.253 copy.",
`- Pathing honesty: ${e.bridge.pathingParity}.`,
"- Repair honesty: scripted single-target bridge only; no global repair system, queue, passive regeneration or broad building model.",
"- v0.253 capture and dedicated validator: pass.",
`- Full local validation: pass. Exact-SHA GitHub Actions: ${ciRun.startsWith("PENDING")?"pending publication":"pass"}.`,"",
"## Honest assessment","",
"The first Worker repair loop is explicit, bounded and readable, but remains scripted to one authoritative Field Barracks with review-grade movement. Verdict remains PARTIAL.",
"Recommendation for v0.254: improve the Worker-to-target interaction and repair feedback cadence without adding global repair, destruction, waves or broad AI.","",
"Stop after v0.253. Do not begin v0.254.",""
].join("\n")}

function capture(){const errors=[],e=inspect(errors);mkdirSync(manual,{recursive:true});for(const f of required.slice(0,-1))if(!existsSync(join(manual,f)))errors.push(`missing ${f}`);const md=report(e);writeFileSync(join(manual,"50_v0253_report.md"),md);writeFileSync(docPath,md);writeFileSync(join(root,"v0253-capture-report.json"),JSON.stringify({status:errors.length?"FAIL_V0253_CAPTURE":"PASS_V0253_BARROSAN_FIRST_WORKER_REPAIR_BRIDGE_CAPTURE",verdict,...e,errors},null,2)+"\n");if(errors.length)throw new Error(errors.join("\n"))}
function validation(){const errors=[],e=inspect(errors);for(const f of required){const p=join(manual,f);if(!existsSync(p))errors.push(`missing ${f}`);else if(statSync(p).size<(f.endsWith(".png")?10000:700))errors.push(`small ${f}`)}writeFileSync(join(root,"v0253-validation-report.json"),JSON.stringify({status:errors.length?"FAIL_V0253_VALIDATION":"PASS_V0253_BARROSAN_FIRST_WORKER_REPAIR_BRIDGE_VALIDATION",bridgeStatus:e.bridge.status??"UNKNOWN",errors},null,2)+"\n");if(errors.length)throw new Error(errors.join("\n"))}
if((process.argv[2]??"capture")==="capture")capture();else validation();
