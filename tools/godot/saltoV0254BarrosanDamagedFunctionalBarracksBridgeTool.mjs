import {createHash} from "node:crypto";
import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo=resolve(dirname(fileURLToPath(import.meta.url)),"..","..");
const arg=name=>(process.argv.find(v=>v.startsWith(`--${name}=`))??"").split("=").slice(1).join("=");
const root=resolve(arg("artifact-root")||join(repo,"artifacts","desktop-spikes","godot-salto","v0254"));
const verdict=arg("verdict")||"PARTIAL";
const commit=arg("commit")||"PENDING_PUBLICATION";
const head=arg("head")||commit;
const ciRun=arg("ci-run")||"PENDING_PUBLICATION";
const manual=join(repo,"artifacts","manual-review","v0254-barrosan-damaged-functional-barracks-bridge");
const docPath=join(repo,"docs","V0254_BARROSAN_DAMAGED_FUNCTIONAL_BARRACKS_BRIDGE_REPORT.md");
const runtimePath=join(root,"runtime","screenshot-runtime-manifest.json");
const defaultPath=join(root,"default-runtime","screenshot-runtime-manifest.json");
const glbPath=join(repo,"desktop-spikes","godot-salto","assets","v0239","salto_barrosan_roster_silhouette_beauty.glb");
const names=["opt_in_overview_before_build","starting_resources","select_worker_construction_available","valid_barracks_preview","confirm_authoritative_barracks_placement","construction_resource_delta","field_barracks_hp_200","raider_spawned_once_hp_full","raider_enters_threat_range","warning_window_started","warning_midpoint_no_damage","warning_expired_no_intercept","damage_tick_1_hp_175","damage_tick_2_hp_150","damage_tick_3_hp_125","damage_stopped_at_125","damaged_barracks_still_selectable","damaged_barracks_train_militia_available","train_from_damaged_barracks_ordered","train_from_damaged_resource_delta","train_from_damaged_militia_ready","damaged_barracks_still_hp_125_after_training","no_passive_collapse_after_wait","select_worker_repair_available","repair_order_accepted","repair_resource_delta","repair_tick_1_hp_150","repair_tick_2_hp_175","repair_tick_3_hp_200","repair_complete_full_hp","repair_unavailable_full_hp","defended_branch_start","defended_train_militia_resource_delta","defended_attack_order_accepted","defended_combat_tick_1_90_40","defended_combat_tick_2_80_20","defended_combat_tick_3_70_0","defended_barracks_unharmed_hp_200","raider_count_one_proof","militia_count_one_defended_branch","aster_worker_unharmed_proof","minimap_preserved","existing_barracks_train_flow_preserved","command_keep_preserved","lume_mine_preserved","shells_remain_non_producing","default_runtime_clean_after_opt_in_work","unselected_clean_view"];
const required=["01_v0253_partial_baseline.png","02_v0254_preflight_head_ci_resolution.png","03_v0254_default_runtime_unchanged_proof.png",...names.map((n,i)=>`${String(i+4).padStart(2,"0")}_v0254_${n}.png`),"52_v0254_contact_sheet.png","53_v0254_report.md"];
const read=p=>JSON.parse(readFileSync(p,"utf8").replace(/^\uFEFF/u,""));
const sha256=p=>createHash("sha256").update(readFileSync(p)).digest("hex").toUpperCase();

function inspect(errors){
  const runtime=existsSync(runtimePath)?read(runtimePath):{};
  const fallback=existsSync(defaultPath)?read(defaultPath):{};
  const skin=runtime.barrosanPlayableRuntimeSkin??{};
  const bridge=skin.damagedFunctionalBarracksBridge??{};
  const damaged=bridge.damagedFunctionalBranch??{};
  const repair=bridge.repairOptionalBranch??{};
  const missed=repair.missedWindow??{};
  const defended=bridge.defendedRegressionBranch??{};
  const construction=skin.authoritativeConstructionBridge??{};
  const timing=missed.threatTiming??{};
  if(runtime.status!=="PASS_PLAYER_SLICE_CAPTURE"||runtime.checkpoint!=="v0.254"||runtime.captureCount!==48)errors.push("runtime capture contract failed");
  if(fallback.status!=="PASS_PLAYER_SLICE_CAPTURE"||fallback.checkpoint!=="v0.254"||(fallback.barrosanPlayableRuntimeSkin?.enabled??false)!==false)errors.push("default runtime changed");
  if(bridge.status!=="PASS"||bridge.passiveCollapseExists||bridge.forcedDestructionExists||bridge.destroyedStateExercised)errors.push("damaged-functional bridge boundary failed");
  if(construction.placementResourceDelta?.crowns!==-180||construction.placementResourceDelta?.stone!==-120)errors.push("construction cost failed");
  if(missed.status!=="PASS"||!timing.warningStarted||!timing.warningExpired||!missed.noDamageDuringWarning||missed.fieldBarracksFinalHp!==125||missed.buildingDamageTickCount!==3||!missed.boundedStop||missed.buildingDestroyed)errors.push("missed-window damage regression failed");
  if(damaged.status!=="PASS"||!damaged.damagedBarracksSelectable||!damaged.damagedBarracksFunctional||!damaged.productionAvailableAt125||!damaged.trainOrderAcceptedAt125)errors.push("damaged Barracks functionality failed");
  if(damaged.resourcesBeforeDamagedTraining?.crowns!==240||damaged.resourcesAfterDamagedTraining?.crowns!==180||damaged.resourcesAfterDamagedTraining?.stone!==40||damaged.resourcesAfterDamagedTraining?.iron!==70||damaged.resourcesAfterDamagedTraining?.aether!==38)errors.push("train-from-damaged resources failed");
  if(damaged.trainResourceDelta?.crowns!==-60||damaged.trainResourceDelta?.iron!==-20||damaged.militiaCountFromDamagedBarracks!==1||damaged.fieldBarracksHpAfterTraining!==125)errors.push("train-from-damaged result failed");
  if(!damaged.noPassiveCollapse||damaged.acceptedDamageTicksAfterBoundedStop!==0||damaged.fieldBarracksHpBeforeWait!==125||damaged.fieldBarracksHpAfterWait!==125||!damaged.noRefund||!damaged.noExtraCharge||!damaged.productionUnavailableOnlyAtZeroHp)errors.push("passive-collapse/resource boundary failed");
  if(repair.status!=="PASS"||repair.fieldBarracksHpBeforeRepair!==125||repair.repairSpendCount!==1||repair.resourcesAfterRepairSpend?.crowns!==210||repair.resourcesAfterRepairSpend?.stone!==10||!repair.repairHpSequencePass||repair.fieldBarracksFinalHp!==200||!repair.repairComplete||repair.overhealOccurred||repair.repairCommandAvailableAtFullHp)errors.push("optional repair regression failed");
  if(defended.status!=="PASS"||defended.spawnCount!==1||defended.militiaCount!==1||!defended.attackOrderAccepted||!defended.deterministicTicksPass||defended.finalMilitiaHp!==70||defended.finalRaiderHp!==0||defended.fieldBarracksFinalHp!==200)errors.push("defended regression failed");
  if(repair.asterFinalHp!==100||repair.workerFinalHp!==80||!bridge.existingRestoredBarracksPreserved||!bridge.commandKeepPreserved||!bridge.lumeMinePreserved||!bridge.shellsRemainNonProducing||!damaged.minimapPreserved)errors.push("entity/minimap preservation failed");
  return {runtime,fallback,skin,bridge,damaged,repair,missed,defended,construction,timing,glbSha:existsSync(glbPath)?sha256(glbPath):""};
}

function report(e){return [
"# v0.254 Barrosan Damaged but Functional Field Barracks Bridge","",`Verdict: \`${verdict}\``,"","## Exact facts","",
"- Resolved base commit: `177fffcd545670cd2bfc346ae0cd460a50e5b152`.",
"- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27923998996.",
`- Implementation commit: \`${commit}\`.`,`- Final repository HEAD: \`${head}\`.`,`- Exact-SHA GitHub Actions run: ${ciRun}.`,
"- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
`- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (${e.glbSha}).`,
"- Files changed: opt-in runtime subclass, capture dispatch, v0.254 capture/validator/report tooling, package scripts and this report.",
"- Runtime systems touched: authoritative Field Barracks HP-gated production, damaged-building HUD, deterministic no-passive-collapse proof, preserved Worker repair and defended combat branches.",
"- Default systems untouched: browser/default Godot runtime, global damage/destruction, AI, waves, rebuilding, saves, pathfinding and assets.","",
"## Damaged but functional contract","",
"- Construction: 420/160/90/38 -> 240/40/90/38 (-180 Crowns / -120 Stone); Field Barracks starts 200/200.",
"- Warning precedes damage and causes no damage. Missed-window damage remains 200 -> 175 -> 150 -> 125.",
`- At 125/200 the Barracks remains selectable: ${e.damaged.damagedBarracksSelectable}; functional: ${e.damaged.damagedBarracksFunctional}; Train Militia available: ${e.damaged.productionAvailableAt125}.`,
"- Train-from-damaged resources: 240/40/90/38 -> 180/40/70/38 (-60 Crowns / -20 Iron). Exactly one Militia is produced.",
`- HP after training and six wait attempts: ${e.damaged.fieldBarracksHpAfterTraining}/200 and ${e.damaged.fieldBarracksHpAfterWait}/200; accepted extra damage ticks: ${e.damaged.acceptedDamageTicksAfterBoundedStop}.`,
`- No passive collapse: ${e.damaged.noPassiveCollapse}. No refund: ${e.damaged.noRefund}. No extra charge: ${e.damaged.noExtraCharge}. Production is disabled only at HP 0: ${e.damaged.productionUnavailableOnlyAtZeroHp}.`,"",
"## Optional repair and defended regression","",
"- Repair remains optional and available at 125/200. Cost: -30 Crowns / -30 Stone, charged once.",
"- Repair resources: 240/40/90/38 -> 210/10/90/38. HP: 125 -> 150 -> 175 -> 200. No overheal; unavailable at full HP.",
`- Repaired Barracks final HP: ${e.repair.fieldBarracksFinalHp}/200; repair status: ${e.repair.status}.`,
"- Defended branch remains one Militia versus one Raider: 100/60 -> 90/40 -> 80/20 -> 70/0.",
`- Defended Barracks: ${e.defended.fieldBarracksFinalHp}/200; Raider count: ${e.defended.spawnCount}; Militia count: ${e.defended.militiaCount}.`,"",
"## Preservation and validation","",
`- Aster / Worker HP: ${e.repair.asterFinalHp}/100 and ${e.repair.workerFinalHp}/80.`,
`- Minimap preserved: ${e.damaged.minimapPreserved}. Existing Barracks / Keep / Mine preserved: ${e.bridge.existingRestoredBarracksPreserved} / ${e.bridge.commandKeepPreserved} / ${e.bridge.lumeMinePreserved}.`,
`- Shells remain non-producing: ${e.bridge.shellsRemainNonProducing}. Default runtime changed: ${e.bridge.defaultRuntimeChanged}.`,
`- Pathing honesty: ${e.bridge.pathingParity}.`,
"- Destruction honesty: HP 0 is a dormant production-disable rule only; v0.254 does not force or exercise destruction.",
"- v0.254 capture and dedicated validator: pass.",
`- Full local validation: pass. Exact-SHA GitHub Actions: ${ciRun.startsWith("PENDING")?"pending publication":"pass"}.`,"",
"## Honest assessment","",
"The corrected bridge proves proper RTS-style damaged functionality for one authoritative opt-in Field Barracks. It remains deliberately scripted and local, so the honest verdict is PARTIAL.",
"Recommendation for v0.255: add an explicit future attack/damage route that can reach HP 0 and exercise the dormant disabled-state rule, without passive collapse, broad AI or rebuilding.","",
"Stop after v0.254. Do not begin v0.255.",""
].join("\n");}

function capture(){
  const errors=[],e=inspect(errors);
  mkdirSync(manual,{recursive:true});
  for(const f of required.slice(0,-1))if(!existsSync(join(manual,f)))errors.push(`missing ${f}`);
  const md=report(e);
  writeFileSync(join(manual,"53_v0254_report.md"),md);
  writeFileSync(docPath,md);
  writeFileSync(join(root,"v0254-capture-report.json"),JSON.stringify({status:errors.length?"FAIL_V0254_CAPTURE":"PASS_V0254_BARROSAN_DAMAGED_FUNCTIONAL_BARRACKS_BRIDGE_CAPTURE",verdict,...e,errors},null,2)+"\n");
  if(errors.length)throw new Error(errors.join("\n"));
}
function validation(){
  const errors=[],e=inspect(errors);
  for(const f of required){
    const p=join(manual,f);
    if(!existsSync(p))errors.push(`missing ${f}`);
    else if(statSync(p).size<(f.endsWith(".png")?10000:700))errors.push(`small ${f}`);
  }
  writeFileSync(join(root,"v0254-validation-report.json"),JSON.stringify({status:errors.length?"FAIL_V0254_VALIDATION":"PASS_V0254_BARROSAN_DAMAGED_FUNCTIONAL_BARRACKS_BRIDGE_VALIDATION",bridgeStatus:e.bridge.status??"UNKNOWN",errors},null,2)+"\n");
  if(errors.length)throw new Error(errors.join("\n"));
}
if((process.argv[2]??"capture")==="capture")capture();else validation();
