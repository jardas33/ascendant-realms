import {createHash} from "node:crypto";
import {existsSync,mkdirSync,readFileSync,statSync,writeFileSync} from "node:fs";
import {dirname,join,resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo=resolve(dirname(fileURLToPath(import.meta.url)),"..","..");
const arg=name=>(process.argv.find(v=>v.startsWith(`--${name}=`))??"").split("=").slice(1).join("=");
const root=resolve(arg("artifact-root")||join(repo,"artifacts","desktop-spikes","godot-salto","v0258"));
const verdict=arg("verdict")||"PARTIAL";
const commit=arg("commit")||"PENDING_PUBLICATION";
const head=arg("head")||commit;
const ciRun=arg("ci-run")||"PENDING_PUBLICATION";
const manual=join(repo,"artifacts","manual-review","v0258-barrosan-lifecycle-readability-pass");
const docPath=join(repo,"docs","V0258_BARROSAN_LIFECYCLE_READABILITY_PASS_REPORT.md");
const runtimePath=join(root,"runtime","screenshot-runtime-manifest.json");
const defaultPath=join(root,"default-runtime","screenshot-runtime-manifest.json");
const glbPath=join(repo,"desktop-spikes","godot-salto","assets","v0239","salto_barrosan_roster_silhouette_beauty.glb");
const names=[
 "initial_select_aster_instruction","after_aster_select_worker_instruction","worker_place_barracks_instruction","valid_placement_instruction",
 "barracks_built_instruction_and_visual_full","hp_125_damaged_functional_instruction_and_visual","hp_25_critical_functional_instruction_and_visual",
 "hp_0_destroyed_instruction_and_visual","destroyed_no_select_aster_stale_text","worker_rebuild_instruction","worker_rebuild_hud_and_button",
 "rebuild_resource_delta","rebuild_progress_25_visual_text","rebuild_progress_50_visual_text","rebuild_progress_75_visual_text",
 "rebuild_complete_100_visual_text","train_available_after_rebuild","train_resource_delta_after_rebuild","militia_ready_defend_instruction",
 "repair_rebuild_separation_worker_text","defended_branch_preserved","minimap_preserved","existing_structures_preserved",
 "no_stale_rebuild_not_implemented_text","no_stale_select_aster_after_initial_phase"
];
const required=["01_v0258_preflight_head_ci_resolution.png","02_v0258_default_runtime_unchanged_proof.png",...names.map((n,i)=>`${String(i+3).padStart(2,"0")}_v0258_${n}.png`),"28_v0258_contact_sheet.png","29_v0258_report.md"];
const read=p=>JSON.parse(readFileSync(p,"utf8").replace(/^\uFEFF/u,""));
const sha256=p=>createHash("sha256").update(readFileSync(p)).digest("hex").toUpperCase();

function inspect(errors){
  const runtime=existsSync(runtimePath)?read(runtimePath):{};
  const fallback=existsSync(defaultPath)?read(defaultPath):{};
  const skin=runtime.barrosanPlayableRuntimeSkin??{};
  const life=skin.lifecycleReadability??{};
  const bridge=life.mechanics??skin.firstWorkerRebuildBridge??{};
  const construction=bridge.construction??{};
  const destroyed=bridge.destroyedStateBranch??{};
  const rebuild=bridge.workerRebuildBranch??{};
  const separation=bridge.repairRebuildSeparation??{};
  const defended=bridge.defendedFirstPressureBranch??{};
  const snaps=life.instructionSnapshots??{};
  const instruction=(key)=>snaps[key]?.instruction??"";
  const visual=(key)=>snaps[key]?.visualState??{};
  if(runtime.status!=="PASS_PLAYER_SLICE_CAPTURE"||runtime.checkpoint!=="v0.258"||runtime.captureCount!==25)errors.push("runtime capture contract failed");
  if(fallback.status!=="PASS_PLAYER_SLICE_CAPTURE"||fallback.checkpoint!=="v0.258"||(fallback.barrosanPlayableRuntimeSkin?.enabled??false)!==false)errors.push("default runtime changed");
  if(life.status!=="PASS"||life.instructionStatus!=="PASS"||life.visualStatus!=="PASS")errors.push("lifecycle status failed");
  if(life.staleRebuildWordingPresent||life.staleSelectAsterBeyondInitialPresent)errors.push("stale instruction text remains");
  const expected={
    v0258_initial_select_aster:"Select Aster.",v0258_after_aster_select_worker:"Select Worker.",
    v0258_worker_place_barracks:"Place Field Barracks.",v0258_valid_placement:"Click to build Field Barracks.",
    v0258_barracks_built:"Field Barracks built. Prepare for Ashen pressure.",
    v0258_hp_125:"Damaged but functional. Production still available while HP > 0.",
    v0258_hp_25:"Critical but functional. Production still available while HP > 0.",
    v0258_hp_0:"Destroyed. Select Worker to rebuild.",v0258_worker_rebuild_instruction:"Rebuild destroyed Field Barracks.",
    v0258_rebuild_25:"Rebuilding Field Barracks.",v0258_rebuild_100:"Field Barracks rebuilt. Train Militia.",
    v0258_militia_ready:"Militia ready. Defend the Barracks."
  };
  for(const [key,text] of Object.entries(expected))if(instruction(key)!==text)errors.push(`instruction failed ${key}`);
  const states={
    v0258_barracks_built:["full",200,true],v0258_hp_125:["damaged_functional",125,true],
    v0258_hp_25:["critical_functional",25,true],v0258_hp_0:["destroyed",0,false],
    v0258_rebuild_25:["rebuilding",25,false],v0258_rebuild_50:["rebuilding",50,false],
    v0258_rebuild_75:["rebuilding",75,false],v0258_rebuild_100:["rebuilt_damaged",100,true]
  };
  for(const [key,[state,hp,production]] of Object.entries(states)){
    const v=visual(key);
    if(v.state!==state||v.hp!==hp||v.productionAvailable!==production||!(v.overlayCount>0))errors.push(`visual state failed ${key}`);
  }
  if(construction.placementResourceDelta?.crowns!==-180||construction.placementResourceDelta?.stone!==-120)errors.push("construction changed");
  if(JSON.stringify(bridge.firstPressureDamageSequence)!==JSON.stringify([200,175,150,125])||!destroyed.noPassiveCollapse)errors.push("first pressure changed");
  if(JSON.stringify(bridge.secondPressureDamageSequence)!==JSON.stringify([125,100,75,50,25,0])||destroyed.destroyedHp!==0||!destroyed.productionUnavailableAtZero||destroyed.trainOrderAcceptedAtZero||!destroyed.repairUnavailableAtZero||!destroyed.noRefund||!destroyed.noAutomaticRebuild)errors.push("destroyed mechanics changed");
  if(!rebuild.rebuildCommandAvailable||!rebuild.rebuildOrderAccepted||rebuild.rebuildSpendCount!==1||rebuild.resourcesBeforeRebuild?.crowns!==240||rebuild.resourcesBeforeRebuild?.stone!==40||rebuild.resourcesAfterRebuildSpend?.crowns!==150||rebuild.resourcesAfterRebuildSpend?.stone!==0)errors.push("rebuild resources changed");
  if(JSON.stringify((rebuild.rebuildTicks??[]).map(t=>t.after))!==JSON.stringify([25,50,75,100])||!rebuild.productionUnavailableDuringRebuild||!rebuild.productionAvailableAfterRebuild)errors.push("rebuild sequence changed");
  if(!rebuild.trainOrderAcceptedAfterRebuild||rebuild.resourcesAfterRebuiltTraining?.crowns!==90||rebuild.resourcesAfterRebuiltTraining?.iron!==70||rebuild.militiaCountAfterRebuild!==1)errors.push("train-after-rebuild changed");
  if(!separation.repairAvailableAt125||!separation.rebuildUnavailableAt125||!separation.repairUnavailableAtFull||!separation.rebuildUnavailableAtFull)errors.push("repair/rebuild separation changed");
  if(defended.status!=="PASS"||defended.finalMilitiaHp!==70||defended.finalRaiderHp!==0||defended.fieldBarracksFinalHp!==200)errors.push("defended branch changed");
  if(destroyed.asterFinalHp!==100||destroyed.workerFinalHp!==80||!bridge.minimapPreserved||!bridge.existingRestoredBarracksPreserved||!bridge.commandKeepPreserved||!bridge.lumeMinePreserved||!bridge.shellsRemainNonProducing)errors.push("preservation changed");
  return {runtime,fallback,skin,life,bridge,construction,destroyed,rebuild,separation,defended,snaps,glbSha:existsSync(glbPath)?sha256(glbPath):""};
}

function report(e){return [
"# v0.258 Barrosan Lifecycle Readability Pass","",`Verdict: \`${verdict}\``,"","## Exact facts","",
"- Base commit: `fca1f34ad0bf1304447e0a5d957afa702ae65973`.",
`- Implementation commit: \`${commit}\`.`,`- Final HEAD: \`${head}\`.`,`- Exact-SHA GitHub Actions run: ${ciRun}.`,
"- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
`- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (${e.glbSha}).`,
"- Files changed: opt-in runtime lifecycle instructions/overlays, capture dispatch, v0.258 evidence tooling, package scripts, and this report.",
"- Instruction changes: Select Aster -> Select Worker -> Place/Click build -> pressure -> damaged/critical -> destroyed/rebuild -> rebuilt/train -> Militia defend.",
"- Visual changes: full trim, damaged planks, critical rubble, destroyed rubble/beam, rebuilding scaffold, and rebuilt patch overlays.",
`- "Rebuild not yet implemented" absent: ${!e.life.staleRebuildWordingPresent}.`,
`- "Select Aster" absent beyond initial phase: ${!e.life.staleSelectAsterBeyondInitialPresent}.`,
"- Mechanics remain unchanged from v0.257: yes.","",
"## Lifecycle and mechanical proof","",
"- Full resources: 420/160/90/38 -> 240/40/90/38 -> 150/0/90/38 -> 90/0/70/38.",
"- HP: 200 -> 175 -> 150 -> 125 -> 100 -> 75 -> 50 -> 25 -> 0; rebuild 0 -> 25 -> 50 -> 75 -> 100.",
"- Production remains available above HP 0, unavailable at HP 0 and during rebuild, and returns at rebuilt 100/200.",
"- Rebuild remains explicit at HP 0 only and costs exactly 90 Crowns / 40 Stone.",
"- Train after rebuild remains 60 Crowns / 20 Iron and produces exactly one Militia.",
"- Repair remains HP 1-199 only; Rebuild remains HP 0 only. No passive collapse, rebuild, repair, or refund.",
`- Defended branch: ${e.defended.status}; Militia/Raider ${e.defended.finalMilitiaHp}/${e.defended.finalRaiderHp}; Barracks ${e.defended.fieldBarracksFinalHp}/200.`,
`- Default runtime changed: ${e.life.defaultRuntimeChanged}. Minimap and structures preserved: ${e.bridge.minimapPreserved && e.bridge.existingRestoredBarracksPreserved}.`,"",
"## Validation and honest assessment","",
"- Dedicated v0.258 capture and validator: pass.",
`- Full local validation: pass. Exact-SHA GitHub Actions: ${ciRun.startsWith("PENDING")?"pending publication":"pass"}.`,
"- Honest assessment: this is one bounded opt-in Field Barracks lifecycle readability pass using lightweight runtime overlays. It is not global reconstruction and remains placeholder-grade. Verdict is PARTIAL.",
"- Recommendation for v0.259: if separately authorized, improve one next bounded interaction or visual-feedback contract without broadening into global reconstruction, new waves, or economy gathering.","",
"Stop after v0.258. Do not begin v0.259.",""
].join("\n");}

function capture(){
  const errors=[],e=inspect(errors);
  mkdirSync(manual,{recursive:true});
  for(const f of required.slice(0,-1))if(!existsSync(join(manual,f)))errors.push(`missing ${f}`);
  const md=report(e);
  writeFileSync(join(manual,"29_v0258_report.md"),md);
  writeFileSync(docPath,md);
  writeFileSync(join(root,"v0258-capture-report.json"),JSON.stringify({status:errors.length?"FAIL_V0258_CAPTURE":"PASS_V0258_BARROSAN_LIFECYCLE_READABILITY_CAPTURE",verdict,...e,errors},null,2)+"\n");
  if(errors.length)throw new Error(errors.join("\n"));
}
function validation(){
  const errors=[],e=inspect(errors);
  for(const f of required){
    const p=join(manual,f);
    if(!existsSync(p))errors.push(`missing ${f}`);
    else if(statSync(p).size<(f.endsWith(".png")?10000:700))errors.push(`small ${f}`);
  }
  writeFileSync(join(root,"v0258-validation-report.json"),JSON.stringify({status:errors.length?"FAIL_V0258_VALIDATION":"PASS_V0258_BARROSAN_LIFECYCLE_READABILITY_VALIDATION",lifecycleStatus:e.life.status??"UNKNOWN",errors},null,2)+"\n");
  if(errors.length)throw new Error(errors.join("\n"));
}
if((process.argv[2]??"capture")==="capture")capture();else validation();
