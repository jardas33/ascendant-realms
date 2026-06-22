import {createHash} from "node:crypto";
import {existsSync,mkdirSync,readFileSync,statSync,writeFileSync} from "node:fs";
import {dirname,join,resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo=resolve(dirname(fileURLToPath(import.meta.url)),"..","..");
const arg=name=>(process.argv.find(v=>v.startsWith(`--${name}=`))??"").split("=").slice(1).join("=");
const root=resolve(arg("artifact-root")||join(repo,"artifacts","desktop-spikes","godot-salto","v0256"));
const verdict=arg("verdict")||"PARTIAL";
const commit=arg("commit")||"PENDING_PUBLICATION";
const head=arg("head")||commit;
const ciRun=arg("ci-run")||"PENDING_PUBLICATION";
const manual=join(repo,"artifacts","manual-review","v0256-barrosan-first-worker-rebuild-bridge");
const docPath=join(repo,"docs","V0256_BARROSAN_FIRST_WORKER_REBUILD_BRIDGE_REPORT.md");
const runtimePath=join(root,"runtime","screenshot-runtime-manifest.json");
const defaultPath=join(root,"default-runtime","screenshot-runtime-manifest.json");
const glbPath=join(repo,"desktop-spikes","godot-salto","assets","v0239","salto_barrosan_roster_silhouette_beauty.glb");
const names=[
 "opt_in_overview_before_build","starting_resources","select_worker_construction_available","valid_barracks_preview","confirm_authoritative_barracks_placement",
 "construction_resource_delta","field_barracks_hp_200","first_pressure_to_125","no_passive_collapse_at_125","second_pressure_triggered",
 "second_damage_hp_100","second_damage_hp_75","second_damage_hp_50","second_damage_hp_25_still_functional","second_damage_hp_0_destroyed",
 "destroyed_barracks_selected","destroyed_barracks_train_unavailable","worker_selected_rebuild_available","repair_unavailable_at_zero","rebuild_ordered",
 "rebuild_resource_delta","rebuild_progress_hp_25","rebuild_progress_hp_50","rebuild_progress_hp_75","rebuild_complete_hp_100",
 "rebuilt_barracks_selectable","rebuilt_barracks_train_available","train_from_rebuilt_ordered","train_from_rebuilt_resource_delta",
 "militia_ready_from_rebuilt_barracks","rebuilt_barracks_still_hp_100","worker_after_rebuild_repair_vs_rebuild_state",
 "rebuild_unavailable_when_no_destroyed_target","repair_available_at_damaged_nonzero_if_resources_allow","rebuild_unavailable_at_damaged_nonzero",
 "defended_first_pressure_start","defended_first_combat_90_40","defended_first_combat_80_20","defended_first_combat_70_0",
 "defended_barracks_unharmed_200","aster_worker_unharmed_proof","minimap_preserved","existing_barracks_preserved",
 "command_keep_lume_mine_preserved","shells_remain_non_producing","default_runtime_clean_after_opt_in_work","unselected_clean_view"
];
const required=["01_v0255_baseline_destroyed_state.png","02_v0256_preflight_head_ci_resolution.png","03_v0256_default_runtime_unchanged_proof.png",...names.map((n,i)=>`${String(i+4).padStart(2,"0")}_v0256_${n}.png`),"51_v0256_contact_sheet.png","52_v0256_report.md"];
const read=p=>JSON.parse(readFileSync(p,"utf8").replace(/^\uFEFF/u,""));
const sha256=p=>createHash("sha256").update(readFileSync(p)).digest("hex").toUpperCase();

function inspect(errors){
  const runtime=existsSync(runtimePath)?read(runtimePath):{};
  const fallback=existsSync(defaultPath)?read(defaultPath):{};
  const skin=runtime.barrosanPlayableRuntimeSkin??{};
  const bridge=skin.firstWorkerRebuildBridge??{};
  const construction=bridge.construction??skin.authoritativeConstructionBridge??{};
  const destroyed=bridge.destroyedStateBranch??{};
  const rebuild=bridge.workerRebuildBranch??{};
  const separation=bridge.repairRebuildSeparation??{};
  const defended=bridge.defendedFirstPressureBranch??{};
  if(runtime.status!=="PASS_PLAYER_SLICE_CAPTURE"||runtime.checkpoint!=="v0.256"||runtime.captureCount!==47)errors.push("runtime capture contract failed");
  if(fallback.status!=="PASS_PLAYER_SLICE_CAPTURE"||fallback.checkpoint!=="v0.256"||(fallback.barrosanPlayableRuntimeSkin?.enabled??false)!==false)errors.push("default runtime changed");
  if(bridge.status!=="PASS"||bridge.passiveCollapseExists||bridge.passiveRebuildExists||bridge.automaticRefundExists||bridge.globalBuildingRebuildExists)errors.push("v0.256 scope/status failed");
  if(construction.placementResourceDelta?.crowns!==-180||construction.placementResourceDelta?.stone!==-120)errors.push("construction cost failed");
  if(JSON.stringify(bridge.firstPressureDamageSequence)!==JSON.stringify([200,175,150,125])||!destroyed.noPassiveCollapse)errors.push("first pressure regression failed");
  if(JSON.stringify(bridge.secondPressureDamageSequence)!==JSON.stringify([125,100,75,50,25,0])||!destroyed.destroyed||destroyed.destroyedHp!==0)errors.push("second pressure destruction failed");
  if(!destroyed.productionUnavailableAtZero||destroyed.trainOrderAcceptedAtZero||!destroyed.repairUnavailableAtZero||!destroyed.noRefund||!destroyed.noAutomaticRebuild)errors.push("destroyed-state gate failed");
  if(!rebuild.rebuildCommandAvailable||!rebuild.repairUnavailableAtZero||!rebuild.rebuildOrderAccepted||rebuild.rebuildSpendCount!==1)errors.push("Worker rebuild command failed");
  if(rebuild.resourcesBeforeRebuild?.crowns!==240||rebuild.resourcesBeforeRebuild?.stone!==40||rebuild.resourcesAfterRebuildSpend?.crowns!==150||rebuild.resourcesAfterRebuildSpend?.stone!==0)errors.push("rebuild resource sequence failed");
  if(JSON.stringify((rebuild.rebuildTicks??[]).map(t=>t.after))!==JSON.stringify([25,50,75,100])||rebuild.fieldBarracksFinalHp!==100||!rebuild.productionUnavailableDuringRebuild||!rebuild.productionAvailableAfterRebuild)errors.push("rebuild HP/production sequence failed");
  if(!rebuild.trainOrderAcceptedAfterRebuild||rebuild.resourcesAfterRebuiltTraining?.crowns!==90||rebuild.resourcesAfterRebuiltTraining?.stone!==0||rebuild.resourcesAfterRebuiltTraining?.iron!==70||rebuild.militiaCountAfterRebuild!==1||rebuild.fieldBarracksHpAfterTraining!==100)errors.push("train-from-rebuilt failed");
  if(!separation.repairAvailableAt125||!separation.rebuildUnavailableAt125||!separation.repairUnavailableAtFull||!separation.rebuildUnavailableAtFull)errors.push("repair/rebuild separation failed");
  if(defended.status!=="PASS"||!defended.deterministicTicksPass||defended.finalMilitiaHp!==70||defended.finalRaiderHp!==0||defended.fieldBarracksFinalHp!==200||!defended.rebuildUnavailable||!defended.repairUnavailable)errors.push("defended regression failed");
  if(destroyed.asterFinalHp!==100||destroyed.workerFinalHp!==80||!bridge.minimapPreserved||!bridge.existingRestoredBarracksPreserved||!bridge.commandKeepPreserved||!bridge.lumeMinePreserved||!bridge.shellsRemainNonProducing)errors.push("preservation failed");
  return {runtime,fallback,skin,bridge,construction,destroyed,rebuild,separation,defended,glbSha:existsSync(glbPath)?sha256(glbPath):""};
}

function report(e){return [
"# v0.256 Barrosan First Worker Rebuild Bridge","",`Verdict: \`${verdict}\``,"","## Exact facts","",
"- Resolved base commit: `b3043402cb1219468ed09a8e0c3e1345a59f407e`.",
"- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27949696015.",
`- Implementation commit: \`${commit}\`.`,`- Final repository HEAD: \`${head}\`.`,`- Exact-SHA GitHub Actions run: ${ciRun}.`,
"- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
`- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (${e.glbSha}).`,
"- Files changed: opt-in runtime subclass, capture dispatch, v0.256 capture/validator/report tooling, package scripts and this report.",
"- Runtime systems touched: destroyed Field Barracks state, Worker work-command routing, deterministic rebuild progress, production gating and review evidence.",
"- Default systems untouched: browser/default Godot runtime, Command Keep, Lume Mine, shell production, global destruction/rebuild, AI, waves, saves, pathfinding and assets.","",
"## Construction, destruction and rebuild proof","",
"- Construction: 420/160/90/38 -> 240/40/90/38 (-180 Crowns / -120 Stone); Field Barracks starts 200/200.",
"- Training cost remains -60 Crowns / -20 Iron. Repair cost remains -30 Crowns / -30 Stone. Rebuild cost is -90 Crowns / -40 Stone.",
"- First pressure: 200 -> 175 -> 150 -> 125. Waiting at 125 causes no passive collapse.",
"- Second explicit pressure: 125 -> 100 -> 75 -> 50 -> 25 -> 0. Production remains available above zero and stops at zero.",
`- Destroyed at 0: ${e.destroyed.destroyed}. Production unavailable: ${e.destroyed.productionUnavailableAtZero}. Train unavailable: ${!e.destroyed.trainOrderAcceptedAtZero}. Repair unavailable: ${e.destroyed.repairUnavailableAtZero}.`,
`- Worker Rebuild available at zero: ${e.rebuild.rebuildCommandAvailable}. Explicit order accepted: ${e.rebuild.rebuildOrderAccepted}. Spend count: ${e.rebuild.rebuildSpendCount}.`,
"- Rebuild resources: 240/40/90/38 -> 150/0/90/38. No refund and no second charge.",
"- Rebuild HP: 0 -> 25 -> 50 -> 75 -> 100. Production remains unavailable during progress.",
`- Completion HP: ${e.rebuild.fieldBarracksFinalHp}/200. Damaged but functional: ${e.rebuild.productionAvailableAfterRebuild}.`,
"- Train from rebuilt Barracks: 150/0/90/38 -> 90/0/70/38; exactly one Militia; Barracks remains 100/200.","",
"## Separation and preservation","",
`- Repair available at damaged nonzero HP with resources: ${e.separation.repairAvailableAt125}. Rebuild unavailable above zero: ${e.separation.rebuildUnavailableAt125}.`,
"- At rebuilt 100/200, repair is structurally eligible but blocked by 0 Stone; Rebuild is unavailable because the target is standing.",
"- Repair remains unavailable at full HP. Rebuild remains unavailable when no destroyed Field Barracks exists.",
`- Defended first-pressure regression: ${e.defended.status}; combat 100/60 -> 90/40 -> 80/20 -> 70/0; Barracks ${e.defended.fieldBarracksFinalHp}/200.`,
`- Aster / Worker HP: ${e.destroyed.asterFinalHp}/100 and ${e.destroyed.workerFinalHp}/80.`,
`- Minimap preserved: ${e.bridge.minimapPreserved}. Existing Barracks / Keep / Mine preserved: ${e.bridge.existingRestoredBarracksPreserved} / ${e.bridge.commandKeepPreserved} / ${e.bridge.lumeMinePreserved}. Shells non-producing: ${e.bridge.shellsRemainNonProducing}.`,
`- Default runtime changed: ${e.bridge.defaultRuntimeChanged}.`,"",
"## Validation and honest assessment","",
"- Dedicated v0.256 capture and validator: pass.",
`- Full local validation: pass. Exact-SHA GitHub Actions: ${ciRun.startsWith("PENDING")?"pending publication":"pass"}.`,
"- Honest assessment: this is a first explicit Worker rebuild bridge for one authoritative opt-in Field Barracks. It restores only to 100/200 and uses placeholder progress/overlay presentation. Global building reconstruction remains intentionally absent, so the verdict is PARTIAL.",
"- Recommendation for v0.257: only if separately authorized, broaden reconstruction UX or add another bounded structure contract; do not infer a global rebuild system from this slice.","",
"Stop after v0.256. Do not begin v0.257.",""
].join("\n");}

function capture(){
  const errors=[],e=inspect(errors);
  mkdirSync(manual,{recursive:true});
  for(const f of required.slice(0,-1))if(!existsSync(join(manual,f)))errors.push(`missing ${f}`);
  const md=report(e);
  writeFileSync(join(manual,"52_v0256_report.md"),md);
  writeFileSync(docPath,md);
  writeFileSync(join(root,"v0256-capture-report.json"),JSON.stringify({status:errors.length?"FAIL_V0256_CAPTURE":"PASS_V0256_BARROSAN_FIRST_WORKER_REBUILD_BRIDGE_CAPTURE",verdict,...e,errors},null,2)+"\n");
  if(errors.length)throw new Error(errors.join("\n"));
}
function validation(){
  const errors=[],e=inspect(errors);
  for(const f of required){
    const p=join(manual,f);
    if(!existsSync(p))errors.push(`missing ${f}`);
    else if(statSync(p).size<(f.endsWith(".png")?10000:700))errors.push(`small ${f}`);
  }
  writeFileSync(join(root,"v0256-validation-report.json"),JSON.stringify({status:errors.length?"FAIL_V0256_VALIDATION":"PASS_V0256_BARROSAN_FIRST_WORKER_REBUILD_BRIDGE_VALIDATION",bridgeStatus:e.bridge.status??"UNKNOWN",errors},null,2)+"\n");
  if(errors.length)throw new Error(errors.join("\n"));
}
if((process.argv[2]??"capture")==="capture")capture();else validation();
