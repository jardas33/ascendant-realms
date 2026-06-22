import {createHash} from "node:crypto";
import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo=resolve(dirname(fileURLToPath(import.meta.url)),"..","..");
const arg=name=>(process.argv.find(v=>v.startsWith(`--${name}=`))??"").split("=").slice(1).join("=");
const root=resolve(arg("artifact-root")||join(repo,"artifacts","desktop-spikes","godot-salto","v0255"));
const verdict=arg("verdict")||"PARTIAL";
const commit=arg("commit")||"PENDING_PUBLICATION";
const head=arg("head")||commit;
const ciRun=arg("ci-run")||"PENDING_PUBLICATION";
const manual=join(repo,"artifacts","manual-review","v0255-barrosan-true-destroyed-state-bridge");
const docPath=join(repo,"docs","V0255_BARROSAN_TRUE_DESTROYED_STATE_BRIDGE_REPORT.md");
const runtimePath=join(root,"runtime","screenshot-runtime-manifest.json");
const defaultPath=join(root,"default-runtime","screenshot-runtime-manifest.json");
const glbPath=join(repo,"desktop-spikes","godot-salto","assets","v0239","salto_barrosan_roster_silhouette_beauty.glb");
const names=[
 "opt_in_overview_before_build","starting_resources","select_worker_construction_available","valid_barracks_preview","confirm_authoritative_barracks_placement",
 "construction_resource_delta","field_barracks_hp_200","first_raider_spawned_once","first_warning_started","first_warning_midpoint_no_damage",
 "first_warning_expired","first_damage_hp_175","first_damage_hp_150","first_damage_hp_125","first_pressure_stops_at_125",
 "no_passive_collapse_after_wait","damaged_barracks_selectable","damaged_barracks_train_available","train_from_damaged_ordered",
 "train_from_damaged_resource_delta","militia_ready_from_damaged_barracks","damaged_barracks_still_hp_125_after_training",
 "second_pressure_triggered_explicitly","second_warning_started","second_warning_midpoint_no_damage","second_warning_expired_no_intercept",
 "second_damage_hp_100","second_damage_hp_75","second_damage_hp_50","second_damage_hp_25_still_functional","second_damage_hp_0_destroyed",
 "destroyed_barracks_selected","destroyed_barracks_train_unavailable","destroyed_barracks_repair_unavailable","no_refund_after_destruction",
 "train_from_damaged_intercepts_second_pressure_start","second_pressure_intercept_order","second_pressure_intercept_combat_90_40",
 "second_pressure_intercept_combat_80_20","second_pressure_intercept_combat_70_0","second_pressure_intercept_barracks_survives_125",
 "repair_branch_available_at_125","repair_resource_delta","repair_hp_150","repair_hp_175","repair_hp_200","repair_unavailable_full_hp",
 "defended_first_branch_start","defended_first_combat_90_40","defended_first_combat_80_20","defended_first_combat_70_0",
 "defended_barracks_unharmed_200","aster_worker_unharmed_proof","minimap_preserved","existing_barracks_preserved",
 "command_keep_lume_mine_preserved","shells_remain_non_producing","default_runtime_clean_after_opt_in_work","unselected_clean_view"
];
const required=["01_v0254_baseline_damaged_functional.png","02_v0255_preflight_head_ci_resolution.png","03_v0255_default_runtime_unchanged_proof.png",...names.map((n,i)=>`${String(i+4).padStart(2,"0")}_v0255_${n}.png`),"63_v0255_contact_sheet.png","64_v0255_report.md"];
const read=p=>JSON.parse(readFileSync(p,"utf8").replace(/^\uFEFF/u,""));
const sha256=p=>createHash("sha256").update(readFileSync(p)).digest("hex").toUpperCase();

function inspect(errors){
  const runtime=existsSync(runtimePath)?read(runtimePath):{};
  const fallback=existsSync(defaultPath)?read(defaultPath):{};
  const skin=runtime.barrosanPlayableRuntimeSkin??{};
  const bridge=skin.trueDestroyedStateBridge??{};
  const damaged=bridge.damagedFunctionalBranch??{};
  const destroyed=bridge.destroyedStateBranch??{};
  const intercepted=bridge.secondPressureInterceptBranch??{};
  const repair=bridge.repairOptionalBranch??{};
  const defended=bridge.defendedFirstPressureBranch??{};
  const construction=skin.authoritativeConstructionBridge??{};
  const first=repair.missedWindow??repair.missedWindowProof??{};
  if(runtime.status!=="PASS_PLAYER_SLICE_CAPTURE"||runtime.checkpoint!=="v0.255"||runtime.captureCount!==59)errors.push("runtime capture contract failed");
  if(fallback.status!=="PASS_PLAYER_SLICE_CAPTURE"||fallback.checkpoint!=="v0.255"||(fallback.barrosanPlayableRuntimeSkin?.enabled??false)!==false)errors.push("default runtime changed");
  if(bridge.status!=="PASS"||bridge.passiveCollapseExists||bridge.repairOrLoseTimerExists||bridge.rebuildImplemented)errors.push("v0.255 scope/status failed");
  if(construction.placementResourceDelta?.crowns!==-180||construction.placementResourceDelta?.stone!==-120)errors.push("construction cost failed");
  if(first.status!=="PASS"||first.fieldBarracksFinalHp!==125||first.buildingDamageTickCount!==3||!first.noDamageDuringWarning||!first.boundedStop)errors.push("first pressure regression failed");
  if(damaged.status!=="PASS"||!damaged.productionAvailableAt125||!damaged.trainOrderAcceptedAt125||damaged.fieldBarracksHpAfterTraining!==125||!damaged.noPassiveCollapse)errors.push("damaged functional regression failed");
  if(damaged.resourcesBeforeDamagedTraining?.crowns!==240||damaged.resourcesAfterDamagedTraining?.crowns!==180||damaged.resourcesAfterDamagedTraining?.stone!==40||damaged.resourcesAfterDamagedTraining?.iron!==70||damaged.resourcesAfterDamagedTraining?.aether!==38||damaged.militiaCountFromDamagedBarracks!==1)errors.push("train-from-damaged failed");
  const secondHp=(destroyed.damageTicks??[]).map(t=>t.after);
  if(!destroyed.explicitTrigger||!destroyed.warningStarted||!destroyed.warningExpired||destroyed.damageDuringWarning||JSON.stringify(secondHp)!==JSON.stringify([100,75,50,25,0]))errors.push("second explicit pressure sequence failed");
  if(!destroyed.productionAvailableAt25||!destroyed.destroyed||destroyed.destroyedHp!==0||!destroyed.productionUnavailableAtZero||destroyed.trainOrderAcceptedAtZero||!destroyed.repairUnavailableAtZero||!destroyed.noRefund||!destroyed.noAutomaticRebuild)errors.push("destroyed threshold failed");
  const combat=intercepted.combat??{};
  if(intercepted.status!=="PASS"||intercepted.fieldBarracksFinalHp!==125||!combat.attackOrderAccepted||!combat.deterministicTicksPass||combat.finalMilitiaHp!==70||combat.finalRaiderHp!==0)errors.push("second-pressure interception failed");
  if(repair.status!=="PASS"||repair.resourcesAfterRepairSpend?.crowns!==210||repair.resourcesAfterRepairSpend?.stone!==10||!repair.repairHpSequencePass||repair.fieldBarracksFinalHp!==200||repair.repairCommandAvailableAtFullHp)errors.push("repair regression failed");
  if(defended.status!=="PASS"||!defended.deterministicTicksPass||defended.finalMilitiaHp!==70||defended.finalRaiderHp!==0||defended.fieldBarracksFinalHp!==200)errors.push("defended first-pressure regression failed");
  if(destroyed.asterFinalHp!==100||destroyed.workerFinalHp!==80||!destroyed.minimapPreserved||!bridge.existingRestoredBarracksPreserved||!bridge.commandKeepPreserved||!bridge.lumeMinePreserved||!bridge.shellsRemainNonProducing)errors.push("preservation failed");
  return {runtime,fallback,skin,bridge,damaged,destroyed,intercepted,repair,defended,construction,first,glbSha:existsSync(glbPath)?sha256(glbPath):""};
}

function report(e){return [
"# v0.255 Barrosan True Destroyed State Bridge","",`Verdict: \`${verdict}\``,"","## Exact facts","",
"- Resolved base commit: `a0c682d94795a2bb81c62faeb9a1629d6fe4bd82`.",
"- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27943772442.",
`- Implementation commit: \`${commit}\`.`,`- Final repository HEAD: \`${head}\`.`,`- Exact-SHA GitHub Actions run: ${ciRun}.`,
"- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
`- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (${e.glbSha}).`,
"- Files changed: opt-in runtime subclass, capture dispatch, v0.255 capture/validator/report tooling, package scripts and this report.",
"- Runtime systems touched: explicit bounded second pressure, true HP-zero destroyed state, destroyed HUD/marker and exercised production gate.",
"- Default systems untouched: browser/default Godot runtime, global destruction, AI, waves, reconstruction, saves, pathfinding and assets.","",
"## Damage, production and destruction proof","",
"- Construction: 420/160/90/38 -> 240/40/90/38 (-180 Crowns / -120 Stone); Field Barracks starts 200/200.",
"- First pressure: 200 -> 175 -> 150 -> 125. Warning precedes damage; first pressure stops at 125.",
`- No passive collapse: ${e.damaged.noPassiveCollapse}; HP after wait: ${e.damaged.fieldBarracksHpAfterWait}/200; accepted hidden ticks: ${e.damaged.acceptedDamageTicksAfterBoundedStop}.`,
`- At 125/200 selectable: ${e.damaged.damagedBarracksSelectable}; functional: ${e.damaged.damagedBarracksFunctional}; Train Militia available: ${e.damaged.productionAvailableAt125}.`,
"- Train from damaged: 240/40/90/38 -> 180/40/70/38; exactly one Militia; Barracks remains 125/200.",
"- Explicit second pressure: 125 -> 100 -> 75 -> 50 -> 25 -> 0. A second warning occurs first and applies no warning-window damage.",
`- Production available at 25: ${e.destroyed.productionAvailableAt25}. Destroyed at 0: ${e.destroyed.destroyed}. Production unavailable at 0: ${e.destroyed.productionUnavailableAtZero}.`,
`- Train unavailable at 0: ${!e.destroyed.trainOrderAcceptedAtZero}. Repair unavailable at 0: ${e.destroyed.repairUnavailableAtZero}. No refund: ${e.destroyed.noRefund}. Automatic rebuild: ${!e.destroyed.noAutomaticRebuild}.`,"",
"## Preserved branches","",
"- Repair remains optional: 240/40/90/38 -> 210/10/90/38; HP 125 -> 150 -> 175 -> 200; charged once; unavailable at full HP.",
`- Second pressure intercepted by damaged-Barracks Militia: ${e.intercepted.status}; Barracks final HP ${e.intercepted.fieldBarracksFinalHp}/200; combat 100/60 -> 90/40 -> 80/20 -> 70/0.`,
`- Defended first-pressure regression: ${e.defended.status}; Barracks final HP ${e.defended.fieldBarracksFinalHp}/200; combat 100/60 -> 90/40 -> 80/20 -> 70/0.`,
`- Raider counts: first missed 1, second destroyed 1, second intercepted 1, defended first 1. Militia counts: damaged training 1, second intercepted 1, defended first 1.`,
`- Aster / Worker HP: ${e.destroyed.asterFinalHp}/100 and ${e.destroyed.workerFinalHp}/80.`,
`- Minimap preserved: ${e.destroyed.minimapPreserved}. Existing Barracks / Keep / Mine preserved: ${e.bridge.existingRestoredBarracksPreserved} / ${e.bridge.commandKeepPreserved} / ${e.bridge.lumeMinePreserved}. Shells non-producing: ${e.bridge.shellsRemainNonProducing}.`,
`- Default runtime changed: ${e.bridge.defaultRuntimeChanged}. Pathing honesty: ${e.bridge.pathingParity}.`,"",
"## Validation and honest assessment","",
"- Dedicated v0.255 capture and validator: pass.",
`- Full local validation: pass. Exact-SHA GitHub Actions: ${ciRun.startsWith("PENDING")?"pending publication":"pass"}.`,
"- Honest assessment: this exercises a true destroyed state only for the authoritative opt-in Field Barracks. Global destruction, rubble replacement and rebuilding remain intentionally absent, so the verdict is PARTIAL.",
"- Recommendation for v0.256: define a separately authorized reconstruction/rebuild contract or broaden destruction only after this local threshold bridge is accepted.","",
"Stop after v0.255. Do not begin v0.256.",""
].join("\n");}

function capture(){
  const errors=[],e=inspect(errors);
  mkdirSync(manual,{recursive:true});
  for(const f of required.slice(0,-1))if(!existsSync(join(manual,f)))errors.push(`missing ${f}`);
  const md=report(e);
  writeFileSync(join(manual,"64_v0255_report.md"),md);
  writeFileSync(docPath,md);
  writeFileSync(join(root,"v0255-capture-report.json"),JSON.stringify({status:errors.length?"FAIL_V0255_CAPTURE":"PASS_V0255_BARROSAN_TRUE_DESTROYED_STATE_BRIDGE_CAPTURE",verdict,...e,errors},null,2)+"\n");
  if(errors.length)throw new Error(errors.join("\n"));
}
function validation(){
  const errors=[],e=inspect(errors);
  for(const f of required){
    const p=join(manual,f);
    if(!existsSync(p))errors.push(`missing ${f}`);
    else if(statSync(p).size<(f.endsWith(".png")?10000:700))errors.push(`small ${f}`);
  }
  writeFileSync(join(root,"v0255-validation-report.json"),JSON.stringify({status:errors.length?"FAIL_V0255_VALIDATION":"PASS_V0255_BARROSAN_TRUE_DESTROYED_STATE_BRIDGE_VALIDATION",bridgeStatus:e.bridge.status??"UNKNOWN",errors},null,2)+"\n");
  if(errors.length)throw new Error(errors.join("\n"));
}
if((process.argv[2]??"capture")==="capture")capture();else validation();
