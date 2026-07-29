import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const repo = process.cwd();
const pack = path.join(repo, 'artifacts/manual-review/v0364-barrosan-foreground-prop-provenance-and-non-destructive-cleanup-preview/UPLOAD_TO_CHAT');
const capture = path.join(repo, 'artifacts/runtime/v0364/capture');
const report = path.join(repo, 'docs/V0364_BARROSAN_FOREGROUND_PROP_PROVENANCE_AND_NON_DESTRUCTIVE_CLEANUP_PREVIEW_REPORT.md');
const fail = []; const need = [
  '00_READ_ME_FIRST.md','01_HUMAN_DECISION_AND_SCOPE.png','02_ORIGINAL_PLAYER_VIEW_WITH_CALLOUTS.png',
  '03_HOUSE02_GROUND_OBJECT_ISOLATION.png','04_HOUSE02_UPPER_TIMBER_ISOLATION.png','05_BARN_FRONT_TIMBER_ISOLATION.png',
  '06_COMBINED_NON_DESTRUCTIVE_CLEAN_PLAYER_PREVIEW.png','07_PROVENANCE_AND_OWNERSHIP_LEDGER.png',
  '08_R0_R1_R2_AND_SOURCE_PRESERVATION.png','compact-evidence-summary.json'
];
function readJson(file){try{return JSON.parse(fs.readFileSync(file,'utf8'));}catch(e){fail.push(`invalid JSON ${file}: ${e.message}`);return {};}}
function sha(file){return crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');}
function requireValue(v,label){if(v===undefined||v===null||v==='')fail.push(`missing ${label}`);}
function assert(v,label){if(!v)fail.push(label);}
function assertZero(v,label){assert(v===0,`${label} expected 0 got ${v}`);}
function utf8Check(file){const b=fs.readFileSync(file);assert(!(b[0]===0xef&&b[1]===0xbb&&b[2]===0xbf),`BOM leakage in ${file}`);const s=b.toString('utf8');assert(!s.includes('\ufffd'),`replacement character in ${file}`);assert(!/[\x00-\x08\x0b\x0c\x0e-\x1f]/.test(s),`control character in ${file}`);assert(!/[ÃÂâ€™â€œâ€]/.test(s),`mojibake in ${file}`);}
function run(){
  assert(fs.existsSync(pack),'review pack missing'); assert(fs.existsSync(report),'v0.364 report missing');
  const actual=fs.existsSync(pack)?fs.readdirSync(pack).sort():[]; assert(actual.length===10,`upload pack must contain exactly 10 files, got ${actual.length}`);
  for(const name of need){const file=path.join(pack,name);assert(fs.existsSync(file),`missing upload file ${name}`);if(fs.existsSync(file)&&!name.endsWith('.png'))utf8Check(file);}
  const pngs=actual.filter(x=>x.toLowerCase().endsWith('.png'));assert(pngs.length===8,`upload pack must contain exactly 8 PNG boards, got ${pngs.length}`);
  for(const name of pngs){const file=path.join(pack,name);const b=fs.readFileSync(file);assert(b.length>5000,`PNG board too small or blank: ${name}`);assert(b[0]===0x89&&b[1]===0x50&&b[2]===0x4e&&b[3]===0x47,`invalid PNG signature: ${name}`);}
  const readme=fs.existsSync(path.join(pack,'00_READ_ME_FIRST.md'))?fs.readFileSync(path.join(pack,'00_READ_ME_FIRST.md'),'utf8'):'';assert(readme.startsWith('READY FOR HUMAN V0364 BARROSAN FOREGROUND PROP AND NON-DESTRUCTIVE CLEANUP PREVIEW REVIEW.')||readme.startsWith('READY FOR HUMAN V0364 BARROSAN FOREGROUND PROP PROVENANCE AND NON-DESTRUCTIVE CLEANUP PREVIEW REVIEW.'),'README does not begin with exact required sentence');
  const s=readJson(path.join(pack,'compact-evidence-summary.json')); for(const k of ['checkpoint','previousCheckpoint','previousCommit','objectANodePaths','objectBNodePaths','objectCNodePaths','objectAOwnerClassification','objectBOwnerClassification','objectCOwnerClassification'])requireValue(s[k],k);
  assert(s.checkpoint==='v0.364','checkpoint mismatch');assert(s.previousCheckpoint==='v0.363','previous checkpoint mismatch');assert(s.previousCommit==='277f4d1d5a44660c0e9132efc45a001a319669df','base commit mismatch');assert(s.v0363Accepted===true,'v0.363 not accepted');assert(s.placementStillAccepted===true,'placement not retained');
  assert(Math.abs(s.acceptedBarnRootTransform.x-4)<1e-5&&Math.abs(s.acceptedBarnRootTransform.y-0.18)<1e-5&&Math.abs(s.acceptedBarnRootTransform.z+1)<1e-5,'Barn root changed');assert(Math.abs(s.structuralGap-2.48)<1e-5,'structural gap changed');assert(Math.abs(s.roofEaveGap-2.51)<1e-5,'roof/eave gap changed');assert(Math.abs(s.requiredWorkerGap-1.875)<1e-5,'worker gap changed');
  assert(s.objectAIndependentToggle===false,'A must be reported merged');assert(s.objectBIndependentToggle===true,'B independent toggle missing');assert(s.objectCIndependentToggle===false,'C must be reported merged');
  assert(s.combinedPreviewReviewOnly===true,'combined preview not review-only');for(const k of ['combinedPreviewRuntimeMutationCount','canonicalBarnMutationCount','house02SourceMutationCount','geometryMutationCount','materialMutationCount','textureMutationCount','transformMutationCount','placementMutationCount','defaultRuntimeMutationCount','gameplayMutationCount','collisionMutationCount','navigationMutationCount','saveMutationCount','stableIdMutationCount','benchmarkRerunCount'])assertZero(s[k],k);
  assert(s.r0BarnRootCount===0&&s.r1BarnRootCount===1&&s.r2BarnRootCount===0,'R0/R1/R2 counts mismatch');assert(s.r0R2RawCaptureMatch===true&&s.r0R2StateSignatureMatch===true,'R0/R2 match not retained');assert(s.r1DuplicateBarnRootCount===0&&s.retainedBarnNodeCountAfterRollback===0,'rollback evidence mismatch');assert(s.humanReviewStop===true,'human review stop missing');
  const probe=readJson(path.join(capture,'v0364-provenance-probe.json'));assert(probe.status==='PASS_PROVENANCE_PROBE','provenance probe missing/pass status wrong');const rec=probe.records||[];for(const p of ['/V0358_House02_Shared_Baseline_Unmodified/LOD0_Granite','/V0358_House02_Shared_Baseline_Unmodified/LOD0_Weathered_Timber','/V0358_Barrosan_Barn_Gold_OptIn_Single_Instance/V0347_Barn_Rendered_Geometry_Truth']){const r=rec.find(x=>x.nodePath===p);assert(!!r,`missing exact provenance path ${p}`);if(r){requireValue(r.ownerScene,`${p} owner`);requireValue(r.parentNodePath,`${p} parent`);requireValue(r.localTransform,`${p} local transform`);requireValue(r.worldTransform,`${p} world transform`);requireValue(r.localAabb,`${p} local AABB`);requireValue(r.worldAabb,`${p} world AABB`);requireValue(r.materialIdentity,`${p} materials`);}}
  assert(fs.existsSync(path.join(capture,'screenshots/original.png')),'actual Godot original capture missing');assert(fs.existsSync(path.join(capture,'screenshots/house-a.png')),'actual Godot A capture missing');assert(fs.existsSync(path.join(capture,'screenshots/house-b.png')),'actual Godot B capture missing');assert(fs.existsSync(path.join(capture,'screenshots/barn-c.png')),'actual Godot C capture missing');assert(fs.existsSync(path.join(capture,'screenshots/combined-preview.png')),'actual Godot combined preview missing');
  try{const diff=execFileSync('git',['diff','--name-only','--','assets/v0338/barrosan_house_02_material_gold_candidate.glb','scenes/gold/barrosan/BarrosanBarnGold.tscn','assets/v0350/barn_final_material_harmony.glb'],{encoding:'utf8'});assert(diff.trim()==='','canonical source files changed');}catch(e){if(e.status!==0)fail.push(`git source diff check failed: ${e.message}`);}
  if(fail.length){console.error('FAIL_V0364\n- '+fail.join('\n- '));process.exit(1);}console.log('PASS_V0364_BARROSAN_FOREGROUND_PROP_PROVENANCE_AND_NON_DESTRUCTIVE_CLEANUP_PREVIEW');console.log(JSON.stringify({uploadFileCount:actual.length,pngBoardCount:pngs.length,provenanceRecords:rec.length,originalCaptureSha256:sha(path.join(capture,'screenshots/original.png'))},null,2));
}
if(process.argv[2]==='validate')run();else console.log('Usage: node tools/godot/saltoV0364BarrosanForegroundPropProvenanceTool.mjs validate');
