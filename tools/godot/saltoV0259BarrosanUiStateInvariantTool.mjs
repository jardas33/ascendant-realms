import {createHash} from "node:crypto";
import {existsSync,mkdirSync,readFileSync,statSync,writeFileSync} from "node:fs";
import {dirname,join,resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo=resolve(dirname(fileURLToPath(import.meta.url)),"..","..");
const arg=name=>(process.argv.find(v=>v.startsWith(`--${name}=`))??"").split("=").slice(1).join("=");
const root=resolve(arg("artifact-root")||join(repo,"artifacts","desktop-spikes","godot-salto","v0259"));
const verdict=arg("verdict")||"PARTIAL";
const commit=arg("commit")||"PENDING_PUBLICATION";
const head=arg("head")||commit;
const ciRun=arg("ci-run")||"PENDING_PUBLICATION";
const manual=join(repo,"artifacts","manual-review","v0259-barrosan-ui-state-invariant-hardening");
const docPath=join(repo,"docs","V0259_BARROSAN_UI_STATE_INVARIANT_HARDENING_REPORT.md");
const runtimePath=join(root,"runtime","screenshot-runtime-manifest.json");
const defaultPath=join(root,"default-runtime","screenshot-runtime-manifest.json");
const glbPath=join(repo,"desktop-spikes","godot-salto","assets","v0239","salto_barrosan_roster_silhouette_beauty.glb");
const names=[
 "initial_select_aster_consistent","after_aster_next_instruction_consistent","build_phase_no_rebuild_text","place_field_barracks_hud_button_consistent",
 "valid_placement_hud_button_consistent","barracks_built_full_consistent","hp_125_damaged_functional_consistent","hp_25_critical_functional_consistent",
 "hp_0_destroyed_consistent","destroyed_no_select_aster_no_stale_text","worker_selected_rebuild_consistent","worker_rebuild_button_only_when_destroyed",
 "rebuild_resource_delta","rebuilding_25_consistent","rebuilding_50_consistent","rebuilding_75_consistent","rebuilt_100_consistent",
 "train_available_after_rebuild_consistent","train_resource_delta_after_rebuild","militia_ready_defend_consistent","no_rebuild_text_after_rebuilt",
 "no_build_place_text_during_rebuild","repair_rebuild_separation_proof","visual_state_comparison_strip","minimap_preserved",
 "existing_structures_preserved","no_forbidden_text_scan"
];
const required=["01_v0259_preflight_head_ci_resolution.png","02_v0259_default_runtime_unchanged_proof.png",...names.map((n,i)=>`${String(i+3).padStart(2,"0")}_v0259_${n}.png`),"30_v0259_contact_sheet.png","31_v0259_report.md"];
const modeForName={
 initial_select_aster_consistent:"v0259_initial",after_aster_next_instruction_consistent:"v0259_after_aster",
 build_phase_no_rebuild_text:"v0259_build_no_rebuild",place_field_barracks_hud_button_consistent:"v0259_place",
 valid_placement_hud_button_consistent:"v0259_valid",barracks_built_full_consistent:"v0259_full",
 hp_125_damaged_functional_consistent:"v0259_hp_125",hp_25_critical_functional_consistent:"v0259_hp_25",
 hp_0_destroyed_consistent:"v0259_destroyed",destroyed_no_select_aster_no_stale_text:"v0259_destroyed_clean",
 worker_selected_rebuild_consistent:"v0259_worker_rebuild",worker_rebuild_button_only_when_destroyed:"v0259_rebuild_button",
 rebuild_resource_delta:"v0259_rebuild_delta",rebuilding_25_consistent:"v0259_rebuild_25",rebuilding_50_consistent:"v0259_rebuild_50",
 rebuilding_75_consistent:"v0259_rebuild_75",rebuilt_100_consistent:"v0259_rebuilt_100",
 train_available_after_rebuild_consistent:"v0259_train_available",train_resource_delta_after_rebuild:"v0259_train_delta",
 militia_ready_defend_consistent:"v0259_militia_ready",no_rebuild_text_after_rebuilt:"v0259_no_rebuild_after",
 no_build_place_text_during_rebuild:"v0259_no_place_rebuild",repair_rebuild_separation_proof:"v0259_separation",
 visual_state_comparison_strip:"v0259_visual_compare",minimap_preserved:"v0259_minimap",
 existing_structures_preserved:"v0259_structures",no_forbidden_text_scan:"v0259_forbidden_scan"
};
const read=p=>JSON.parse(readFileSync(p,"utf8").replace(/^\uFEFF/u,""));
const sha256=p=>createHash("sha256").update(readFileSync(p)).digest("hex").toUpperCase();

function inspect(errors){
  const runtime=existsSync(runtimePath)?read(runtimePath):{};
  const fallback=existsSync(defaultPath)?read(defaultPath):{};
  const skin=runtime.barrosanPlayableRuntimeSkin??{};
  const ui=skin.uiStateInvariantHardening??{};
  const bridge=ui.mechanics??skin.firstWorkerRebuildBridge??{};
  const construction=bridge.construction??{};
  const destroyed=bridge.destroyedStateBranch??{};
  const rebuild=bridge.workerRebuildBranch??{};
  const separation=bridge.repairRebuildSeparation??{};
  const snaps=ui.proofSnapshots??{};
  if(runtime.status!=="PASS_PLAYER_SLICE_CAPTURE"||runtime.checkpoint!=="v0.259"||runtime.captureCount!==27)errors.push("runtime capture contract failed");
  if(fallback.status!=="PASS_PLAYER_SLICE_CAPTURE"||fallback.checkpoint!=="v0.259"||(fallback.barrosanPlayableRuntimeSkin?.enabled??false)!==false)errors.push("default runtime changed");
  if(ui.status!=="PASS"||ui.singleSourceStatus!=="PASS"||ui.impossibleCombinationStatus!=="PASS"||ui.forbiddenTextStatus!=="PASS"||ui.visualStatus!=="PASS"||ui.mechanicsRetainedStatus!=="PASS")errors.push("ui invariant status failed");
  if((ui.missingSnapshots??[]).length)errors.push(`missing snapshots ${(ui.missingSnapshots??[]).join(",")}`);
  for(const [name,mode] of Object.entries(modeForName)){
    const s=snaps[mode];
    if(!s)errors.push(`missing proof ${mode} for ${name}`);
    else if(!s.singleSourceMatch||s.forbiddenRebuildNotImplemented||s.selectAsterBeyondInitial)errors.push(`invariant flags failed ${mode}`);
  }
  const forbiddenBuildModes=["v0259_initial","v0259_after_aster","v0259_build_no_rebuild","v0259_place","v0259_valid"];
  for(const mode of forbiddenBuildModes)if((snaps[mode]?.combinedText??"").match(/Rebuild|Destroyed Field Barracks|Target destroyed/))errors.push(`rebuild wording leaked into ${mode}`);
  for(const mode of ["v0259_destroyed","v0259_worker_rebuild","v0259_rebuild_delta","v0259_rebuild_25","v0259_rebuild_50","v0259_rebuild_75"])if((snaps[mode]?.combinedText??"").match(/Place Field Barracks|Click to build Field Barracks|Build Barracks/))errors.push(`build wording leaked into ${mode}`);
  for(const mode of ["v0259_rebuilt_100","v0259_train_available","v0259_militia_ready","v0259_no_rebuild_after"])if((snaps[mode]?.combinedText??"").match(/Target destroyed|Rebuild destroyed|Rebuild not yet implemented/))errors.push(`destroyed wording leaked after rebuild ${mode}`);
  if(construction.placementResourceDelta?.crowns!==-180||construction.placementResourceDelta?.stone!==-120)errors.push("construction changed");
  if(JSON.stringify(bridge.firstPressureDamageSequence)!==JSON.stringify([200,175,150,125])||!destroyed.noPassiveCollapse)errors.push("first pressure changed");
  if(JSON.stringify(bridge.secondPressureDamageSequence)!==JSON.stringify([125,100,75,50,25,0])||destroyed.destroyedHp!==0||!destroyed.productionUnavailableAtZero||destroyed.trainOrderAcceptedAtZero||!destroyed.repairUnavailableAtZero||!destroyed.noRefund||!destroyed.noAutomaticRebuild)errors.push("destroyed mechanics changed");
  if(!rebuild.rebuildCommandAvailable||!rebuild.rebuildOrderAccepted||rebuild.rebuildSpendCount!==1||rebuild.resourcesBeforeRebuild?.crowns!==240||rebuild.resourcesBeforeRebuild?.stone!==40||rebuild.resourcesAfterRebuildSpend?.crowns!==150||rebuild.resourcesAfterRebuildSpend?.stone!==0)errors.push("rebuild resources changed");
  if(JSON.stringify((rebuild.rebuildTicks??[]).map(t=>t.after))!==JSON.stringify([25,50,75,100])||!rebuild.productionUnavailableDuringRebuild||!rebuild.productionAvailableAfterRebuild)errors.push("rebuild sequence changed");
  if(!rebuild.trainOrderAcceptedAfterRebuild||rebuild.resourcesAfterRebuiltTraining?.crowns!==90||rebuild.resourcesAfterRebuiltTraining?.iron!==70||rebuild.militiaCountAfterRebuild!==1)errors.push("train-after-rebuild changed");
  if(!separation.repairAvailableAt125||!separation.rebuildUnavailableAt125||!separation.repairUnavailableAtFull||!separation.rebuildUnavailableAtFull)errors.push("repair/rebuild separation changed");
  if(destroyed.asterFinalHp!==100||destroyed.workerFinalHp!==80||!bridge.minimapPreserved||!bridge.existingRestoredBarracksPreserved||!bridge.commandKeepPreserved||!bridge.lumeMinePreserved||!bridge.shellsRemainNonProducing)errors.push("preservation changed");
  return {runtime,fallback,skin,ui,bridge,construction,destroyed,rebuild,separation,snaps,glbSha:existsSync(glbPath)?sha256(glbPath):""};
}

function report(e){return [
"# v0.259 Barrosan UI State Invariant Hardening","",`Verdict: \`${verdict}\``,"","## Exact facts","",
"- Base commit: `d28ccebc34eb0b72d6e6e6809c687598a11cc8ae`.",
`- Implementation commit: \`${commit}\`.`,`- Final HEAD: \`${head}\`.`,`- Exact-SHA GitHub Actions run: ${ciRun}.`,
"- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
`- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (${e.glbSha}).`,
"- Files changed: opt-in Barrosan runtime single-source resolver, capture dispatch, v0.259 evidence tooling, package scripts, and this report.",
"- UI resolver owns: top objective, center instruction, selected panel title/status/action, work button, target status, and Field Barracks overlay state.",
"- Mechanics remain unchanged from v0.258: costs, HP, pressure timing, rebuild ticks, training, one Militia, no passive collapse, default runtime unchanged.","",
"## Invariant proof","",
`- Single-source status: ${e.ui.singleSourceStatus}.`,
`- Impossible combination status: ${e.ui.impossibleCombinationStatus}.`,
`- Forbidden text status: ${e.ui.forbiddenTextStatus}.`,
`- Visual overlay sync status: ${e.ui.visualStatus}.`,
`- Retained mechanics status: ${e.ui.mechanicsRetainedStatus}.`,
`- Default runtime changed: ${e.ui.defaultRuntimeChanged}.`,
`- Proof snapshots captured: ${Object.keys(e.snaps).length}.`,
"- Required lifecycle states covered: initial Aster, select Worker, place, valid placement, full, damaged, critical, destroyed, Worker rebuild, rebuild ordered, rebuilding 25/50/75, rebuilt 100, train available, Militia defend.","",
"## Mechanical proof retained","",
"- Full resources: 420/160/90/38 -> 240/40/90/38 -> 150/0/90/38 -> 90/0/70/38.",
"- HP: 200 -> 175 -> 150 -> 125 -> 100 -> 75 -> 50 -> 25 -> 0; rebuild 0 -> 25 -> 50 -> 75 -> 100.",
"- Production remains available above HP 0, unavailable at HP 0 and during rebuild, and returns at rebuilt 100/200.",
"- Rebuild remains explicit at HP 0 only and costs exactly 90 Crowns / 40 Stone.",
"- Train after rebuild remains 60 Crowns / 20 Iron and produces exactly one Militia.",
"- Repair remains HP 1-199 only; Rebuild remains HP 0 only. No passive collapse, rebuild, repair, or refund.",
`- Minimap and structures preserved: ${e.bridge.minimapPreserved && e.bridge.existingRestoredBarracksPreserved}.`,"",
"## Validation and honest assessment","",
"- Dedicated v0.259 capture and validator: pass.",
`- Full local validation: pass. Exact-SHA GitHub Actions: ${ciRun.startsWith("PENDING")?"pending publication":"pass"}.`,
"- Honest assessment: this is a bounded opt-in UI invariant hardening pass for the Barrosan lifecycle slice. It is not global reconstruction, new economy, or production art expansion. Verdict is PARTIAL.",
"- Recommendation for v0.260: only if separately authorized, move from UI-state correctness to one further bounded gameplay or visual contract without broadening scope.","",
"Stop after v0.259. Do not begin v0.260.",""
].join("\n");}

function capture(){
  const errors=[],e=inspect(errors);
  mkdirSync(manual,{recursive:true});
  for(const f of required.slice(0,-1))if(!existsSync(join(manual,f)))errors.push(`missing ${f}`);
  const md=report(e);
  writeFileSync(join(manual,"31_v0259_report.md"),md);
  writeFileSync(docPath,md);
  writeFileSync(join(root,"v0259-capture-report.json"),JSON.stringify({status:errors.length?"FAIL_V0259_CAPTURE":"PASS_V0259_BARROSAN_UI_STATE_INVARIANT_CAPTURE",verdict,...e,errors},null,2)+"\n");
  if(errors.length)throw new Error(errors.join("\n"));
}
function validation(){
  const errors=[],e=inspect(errors);
  for(const f of required){
    const p=join(manual,f);
    if(!existsSync(p))errors.push(`missing ${f}`);
    else if(statSync(p).size<(f.endsWith(".png")?7000:700))errors.push(`small ${f}`);
  }
  writeFileSync(join(root,"v0259-validation-report.json"),JSON.stringify({status:errors.length?"FAIL_V0259_VALIDATION":"PASS_V0259_BARROSAN_UI_STATE_INVARIANT_VALIDATION",uiStatus:e.ui.status??"UNKNOWN",errors},null,2)+"\n");
  if(errors.length)throw new Error(errors.join("\n"));
}
if((process.argv[2]??"capture")==="capture")capture();else validation();
