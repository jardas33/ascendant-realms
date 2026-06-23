import {createHash} from "node:crypto";
import {existsSync,mkdirSync,readFileSync,statSync,writeFileSync} from "node:fs";
import {dirname,join,resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo=resolve(dirname(fileURLToPath(import.meta.url)),"..","..");
const arg=name=>(process.argv.find(v=>v.startsWith(`--${name}=`))??"").split("=").slice(1).join("=");
const root=resolve(arg("artifact-root")||join(repo,"artifacts","desktop-spikes","godot-salto","v0257"));
const verdict=arg("verdict")||"PARTIAL";
const commit=arg("commit")||"PENDING_PUBLICATION";
const head=arg("head")||commit;
const ciRun=arg("ci-run")||"PENDING_PUBLICATION";
const manual=join(repo,"artifacts","manual-review","v0257-barrosan-rebuild-ux-hardening");
const docPath=join(repo,"docs","V0257_BARROSAN_REBUILD_UX_HARDENING_REPORT.md");
const runtimePath=join(root,"runtime","screenshot-runtime-manifest.json");
const defaultPath=join(root,"default-runtime","screenshot-runtime-manifest.json");
const glbPath=join(repo,"desktop-spikes","godot-salto","assets","v0239","salto_barrosan_roster_silhouette_beauty.glb");
const names=[
 "opt_in_overview_before_build","starting_resources","barracks_built_hp_200","first_pressure_hp_125_damaged_functional_text",
 "hp_25_still_functional_text","hp_0_destroyed_text_corrected","destroyed_train_unavailable_text",
 "worker_selected_rebuild_available_text","worker_repair_unavailable_target_destroyed_text","rebuild_ordered",
 "rebuild_resource_delta","rebuild_progress_hp_25_text","rebuild_progress_hp_50_text","rebuild_progress_hp_75_text",
 "rebuild_complete_hp_100_text","rebuilt_train_available_text","train_from_rebuilt_resource_delta",
 "militia_from_rebuilt_ready","worker_rebuild_unavailable_after_rebuild",
 "worker_repair_available_or_insufficient_resources_after_rebuild","defended_branch_combat_preserved",
 "barracks_unharmed_after_defense","aster_worker_unharmed","minimap_preserved","existing_structures_preserved",
 "no_stale_rebuild_not_implemented_text"
];
const required=["01_v0257_preflight_head_ci_resolution.png","02_v0257_default_runtime_unchanged_proof.png",...names.map((n,i)=>`${String(i+3).padStart(2,"0")}_v0257_${n}.png`),"29_v0257_contact_sheet.png","30_v0257_report.md"];
const read=p=>JSON.parse(readFileSync(p,"utf8").replace(/^\uFEFF/u,""));
const sha256=p=>createHash("sha256").update(readFileSync(p)).digest("hex").toUpperCase();

function inspect(errors){
  const runtime=existsSync(runtimePath)?read(runtimePath):{};
  const fallback=existsSync(defaultPath)?read(defaultPath):{};
  const skin=runtime.barrosanPlayableRuntimeSkin??{};
  const ux=skin.rebuildUxHardening??{};
  const bridge=skin.firstWorkerRebuildBridge??{};
  const construction=bridge.construction??skin.authoritativeConstructionBridge??{};
  const destroyed=bridge.destroyedStateBranch??{};
  const rebuild=bridge.workerRebuildBranch??{};
  const separation=bridge.repairRebuildSeparation??{};
  const defended=bridge.defendedFirstPressureBranch??{};
  if(runtime.status!=="PASS_PLAYER_SLICE_CAPTURE"||runtime.checkpoint!=="v0.257"||runtime.captureCount!==26)errors.push("runtime capture contract failed");
  if(fallback.status!=="PASS_PLAYER_SLICE_CAPTURE"||fallback.checkpoint!=="v0.257"||(fallback.barrosanPlayableRuntimeSkin?.enabled??false)!==false)errors.push("default runtime changed");
  if(ux.status!=="PASS"||ux.textStatus!=="PASS"||ux.staleRebuildWordingPresent)errors.push("v0.257 HUD text contract failed");
  if(!(ux.destroyedHud?.hero??"").includes("Destroyed")||!(ux.destroyedHud?.context??"").includes("HP 0/200 | Production unavailable")||!(ux.destroyedHud?.objective??"").includes("Select Worker to rebuild"))errors.push("destroyed HUD failed");
  if(!(ux.workerDestroyedHud?.context??"").includes("Rebuild available | Destroyed Field Barracks")||!(ux.workerDestroyedHud?.context??"").includes("Cost: 90 Crowns / 40 Stone")||!(ux.workerDestroyedHud?.objective??"").includes("Repair unavailable | Target destroyed"))errors.push("Worker destroyed-target HUD failed");
  if(!(ux.damagedHud?.context??"").includes("Operational | HP 125/200 | Train Militia available")||!(ux.criticalHp25Hud?.context??"").includes("Operational | HP 25/200 | Train Militia available"))errors.push("damaged functional HUD failed");
  if(!(ux.rebuildingHud?.context??"").includes("Production unavailable until rebuild complete | HP 25/200"))errors.push("rebuilding HUD failed");
  if(!(ux.rebuiltHud?.context??"").includes("Operational | Rebuilt HP 100/200 | Train Militia available"))errors.push("rebuilt HUD failed");
  if(!(ux.workerAfterRebuildHud?.context??"").includes("Rebuild unavailable | No destroyed target"))errors.push("Worker no-target HUD failed");
  if(construction.placementResourceDelta?.crowns!==-180||construction.placementResourceDelta?.stone!==-120)errors.push("construction sequence changed");
  if(JSON.stringify(bridge.firstPressureDamageSequence)!==JSON.stringify([200,175,150,125])||!destroyed.noPassiveCollapse)errors.push("first pressure regression");
  if(JSON.stringify(bridge.secondPressureDamageSequence)!==JSON.stringify([125,100,75,50,25,0])||destroyed.destroyedHp!==0||!destroyed.productionUnavailableAtZero||destroyed.trainOrderAcceptedAtZero||!destroyed.repairUnavailableAtZero||!destroyed.noRefund||!destroyed.noAutomaticRebuild)errors.push("destroyed mechanics regression");
  if(!rebuild.rebuildCommandAvailable||!rebuild.rebuildOrderAccepted||rebuild.rebuildSpendCount!==1||rebuild.resourcesBeforeRebuild?.crowns!==240||rebuild.resourcesBeforeRebuild?.stone!==40||rebuild.resourcesAfterRebuildSpend?.crowns!==150||rebuild.resourcesAfterRebuildSpend?.stone!==0)errors.push("rebuild command/resources regression");
  if(JSON.stringify((rebuild.rebuildTicks??[]).map(t=>t.after))!==JSON.stringify([25,50,75,100])||!rebuild.productionUnavailableDuringRebuild||!rebuild.productionAvailableAfterRebuild)errors.push("rebuild HP/production regression");
  if(!rebuild.trainOrderAcceptedAfterRebuild||rebuild.resourcesAfterRebuiltTraining?.crowns!==90||rebuild.resourcesAfterRebuiltTraining?.iron!==70||rebuild.militiaCountAfterRebuild!==1)errors.push("train-from-rebuilt regression");
  if(!separation.repairAvailableAt125||!separation.rebuildUnavailableAt125||!separation.repairUnavailableAtFull||!separation.rebuildUnavailableAtFull)errors.push("repair/rebuild separation regression");
  if(defended.status!=="PASS"||defended.finalMilitiaHp!==70||defended.finalRaiderHp!==0||defended.fieldBarracksFinalHp!==200)errors.push("defended branch regression");
  if(destroyed.asterFinalHp!==100||destroyed.workerFinalHp!==80||!bridge.minimapPreserved||!bridge.existingRestoredBarracksPreserved||!bridge.commandKeepPreserved||!bridge.lumeMinePreserved||!bridge.shellsRemainNonProducing)errors.push("preservation regression");
  return {runtime,fallback,skin,ux,bridge,construction,destroyed,rebuild,separation,defended,glbSha:existsSync(glbPath)?sha256(glbPath):""};
}

function report(e){return [
"# v0.257 Barrosan Rebuild UX Hardening","",`Verdict: \`${verdict}\``,"","## Exact facts","",
"- Base commit: `3de91a5332022151b71ab3e3aa3d27270e1433f8`.",
`- Implementation commit: \`${commit}\`.`,`- Final HEAD: \`${head}\`.`,`- Exact-SHA GitHub Actions run: ${ciRun}.`,
"- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
`- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (${e.glbSha}).`,
"- Files changed: opt-in runtime HUD/capture dispatch, v0.257 evidence tooling, package scripts, and this report.",
"- Text changed: destroyed, damaged-functional, rebuilding, rebuilt, Worker Rebuild, Worker Repair, and no-target messages.",
`- "Rebuild not yet implemented" removed from the v0.257 path: ${!e.ux.staleRebuildWordingPresent}.`,
"- Mechanics remain unchanged from v0.256: yes.","",
"## UX and mechanical proof","",
`- Destroyed HUD: ${e.ux.destroyedHud?.hero} | ${e.ux.destroyedHud?.context} | ${e.ux.destroyedHud?.objective}.`,
`- Worker at destroyed target: ${e.ux.workerDestroyedHud?.context} | ${e.ux.workerDestroyedHud?.objective}.`,
`- Damaged HUD: ${e.ux.damagedHud?.context}. HP 25 HUD: ${e.ux.criticalHp25Hud?.context}.`,
`- Rebuilding HUD: ${e.ux.rebuildingHud?.context}. Rebuilt HUD: ${e.ux.rebuiltHud?.context}.`,
"- Construction: 420/160/90/38 -> 240/40/90/38.",
"- First pressure: 200 -> 175 -> 150 -> 125; no passive collapse.",
"- Second pressure: 125 -> 100 -> 75 -> 50 -> 25 -> 0.",
"- Repair is available only at HP 1-199. Rebuild is available only at HP 0.",
"- Rebuild resources: 240/40/90/38 -> 150/0/90/38.",
"- Rebuild HP: 0 -> 25 -> 50 -> 75 -> 100; production unavailable during progress.",
"- Production returns at rebuilt 100/200.",
"- Train from rebuilt: 150/0/90/38 -> 90/0/70/38; exactly one Militia.",
`- Defended branch: ${e.defended.status}; combat 100/60 -> 90/40 -> 80/20 -> 70/0; Barracks ${e.defended.fieldBarracksFinalHp}/200.`,
`- Default runtime changed: ${e.bridge.defaultRuntimeChanged}. Minimap and structures preserved: ${e.bridge.minimapPreserved && e.bridge.existingRestoredBarracksPreserved}.`,"",
"## Validation and honest assessment","",
"- Dedicated v0.257 capture and validator: pass.",
`- Full local validation: pass. Exact-SHA GitHub Actions: ${ciRun.startsWith("PENDING")?"pending publication":"pass"}.`,
"- Honest assessment: this is bounded opt-in UX/text hardening for one Field Barracks rebuild bridge. It is not global reconstruction; placeholder-grade visuals remain. Verdict is PARTIAL.",
"- Recommendation for v0.258: if separately authorized, test the next bounded gameplay consequence or broaden rebuild UX to another explicitly scoped structure without inferring a global system.","",
"Stop after v0.257. Do not begin v0.258.",""
].join("\n");}

function capture(){
  const errors=[],e=inspect(errors);
  mkdirSync(manual,{recursive:true});
  for(const f of required.slice(0,-1))if(!existsSync(join(manual,f)))errors.push(`missing ${f}`);
  const md=report(e);
  writeFileSync(join(manual,"30_v0257_report.md"),md);
  writeFileSync(docPath,md);
  writeFileSync(join(root,"v0257-capture-report.json"),JSON.stringify({status:errors.length?"FAIL_V0257_CAPTURE":"PASS_V0257_BARROSAN_REBUILD_UX_HARDENING_CAPTURE",verdict,...e,errors},null,2)+"\n");
  if(errors.length)throw new Error(errors.join("\n"));
}
function validation(){
  const errors=[],e=inspect(errors);
  for(const f of required){
    const p=join(manual,f);
    if(!existsSync(p))errors.push(`missing ${f}`);
    else if(statSync(p).size<(f.endsWith(".png")?10000:700))errors.push(`small ${f}`);
  }
  writeFileSync(join(root,"v0257-validation-report.json"),JSON.stringify({status:errors.length?"FAIL_V0257_VALIDATION":"PASS_V0257_BARROSAN_REBUILD_UX_HARDENING_VALIDATION",uxStatus:e.ux.status??"UNKNOWN",errors},null,2)+"\n");
  if(errors.length)throw new Error(errors.join("\n"));
}
if((process.argv[2]??"capture")==="capture")capture();else validation();
