import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const failures = [];
const check = (condition, message) => { if (!condition) failures.push(message); };
const rel = (p) => path.join(root, p);
const exists = (p) => fs.existsSync(rel(p));
const read = (p) => fs.readFileSync(rel(p), 'utf8').replace(/^\uFEFF/, '');
const json = (p) => JSON.parse(read(p));
const sha = (p) => crypto.createHash('sha256').update(fs.readFileSync(rel(p))).digest('hex');
const pngSize = (p) => {
  const data = fs.readFileSync(rel(p));
  if (data.length < 24 || data.readUInt32BE(0) !== 0x89504e47) return null;
  return { width: data.readUInt32BE(16), height: data.readUInt32BE(20) };
};
const gitShowSha = (commit, p) => crypto.createHash('sha256').update(execFileSync('git', ['show', `${commit}:${p}`], { cwd: root })).digest('hex');
if (process.argv[2] !== 'validate') throw new Error('usage: node tools/godot/saltoV0355BarrosanBarnHumanGoldLockTool.mjs validate');

const base = '3e557032976075b06a20f45213d6949c68add314';
const decision = 'V0.354 HUMAN-APPROVED — BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN';
const canonicalScenePath = 'desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn';
const authoringPath = 'desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGoldAuthoring.tscn';
const captureScenePath = 'desktop-spikes/godot-salto/scenes/review/V0355BarrosanBarnHumanGoldLock.tscn';
const captureScriptPath = 'desktop-spikes/godot-salto/scripts/v0355_barrosan_barn_human_gold_lock.gd';
const authoringScriptPath = 'desktop-spikes/godot-salto/scripts/v0355_barrosan_barn_gold_authoring.gd';
const captureToolPath = 'tools/godot/captureGodotV0355BarrosanBarnHumanGoldLockWindows.ps1';
const packToolPath = 'tools/godot/buildV0355BarrosanBarnHumanGoldLockPack.ps1';
const reportPath = 'docs/V0355_BARROSAN_BARN_HUMAN_GOLD_LOCK_REPORT.md';
const manifestPath = 'docs/gold/V0355_BARROSAN_BARN_GOLD_MANIFEST.json';
const ledgerPath = 'docs/gold/V0355_BARROSAN_BARN_ACCEPTANCE_LEDGER.md';
const runtimeManifestPath = 'artifacts/runtime/v0355/v0355-barrosan-barn-human-gold-lock-runtime.json';
const rawDir = 'artifacts/runtime/v0355/screenshots';
const acceptedSourcePath = 'artifacts/runtime/v0354/screenshots/06_square_neutral_256.png';
const packDir = 'artifacts/manual-review/v0355-barrosan-barn-human-gold-lock/UPLOAD_TO_CHAT';
const expectedPack = ['00_READ_ME_FIRST.md','01_V0354_HUMAN_APPROVAL_AND_LINEAGE.png','02_CANONICAL_BARN_VISUAL_SCENE.png','03_CANONICAL_FRONT_REAR_AND_ROOF.png','04_ACCEPTED_CANONICAL_PIXEL_IDENTITY.png','05_TRUE_256_CANONICAL_SOURCE.png','06_GOLD_MANIFEST_AND_HASH_LEDGER.png','compact-evidence-summary.json'];

check(exists(canonicalScenePath), 'passive canonical barn scene missing');
check(exists(authoringPath) && exists(authoringScriptPath), 'canonical authoring path missing');
check(exists(captureScenePath) && exists(captureScriptPath) && exists(captureToolPath) && exists(packToolPath), 'v0.355 capture tooling missing');
check(exists(reportPath) && exists(manifestPath) && exists(ledgerPath), 'v0.355 report/manifest/ledger missing');

for (const frozen of [
  'desktop-spikes/godot-salto/scripts/v0354_barn_final_evidence.gd',
  'desktop-spikes/godot-salto/scenes/review/V0354BarnFinalEvidence.tscn',
  'desktop-spikes/godot-salto/scripts/v0353_barn_gold_closeout.gd',
  'desktop-spikes/godot-salto/scenes/review/V0353BarnGoldCloseout.tscn'
]) check(exists(frozen) && sha(frozen) === gitShowSha(base, frozen), `accepted v0.354/v0.353 file changed: ${frozen}`);
check(sha('art-source/blender/v0350/barn_final_material_harmony.blend') === '1d0645cc258e76fea3f3af744b04314e1e692f0db81d3710123857a594199d6b', 'frozen v0.350 blend changed');
check(sha('desktop-spikes/godot-salto/assets/v0350/barn_final_material_harmony.glb') === '0b4944d8a15006664dad84cec5e8b41546497588d14194d5b2e49621071e209c', 'frozen v0.350 GLB changed');
check(sha('desktop-spikes/godot-salto/assets/v0350/v0350_traditional_slate_courses_albedo.png') === 'cb14b8726702843f8b8811068d9f9d0c17abf3cc278c82070916813bb4ec4f34', 'frozen slate texture changed');
check(sha('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate_gold_candidate_rubble_albedo.png') === '2b363f0b7cf1d023712d3a12041045f18890e0f4d4f5ed6f4ca3f48ef8d6d083', 'frozen granite texture changed');

const scene = exists(canonicalScenePath) ? read(canonicalScenePath) : '';
check(scene.includes('barn_final_material_harmony.glb'), 'canonical scene does not register frozen v0.350 GLB');
check(scene.includes('asset_status = "HUMAN_APPROVED_VISUAL_GOLD"') && scene.includes('passive_visual_only = true'), 'canonical scene metadata contract missing');
for (const forbidden of ['Camera3D','DirectionalLight3D','WorldEnvironment','Label3D','Worker','Terrain','capture']) check(!scene.includes(forbidden), `forbidden canonical scene content present: ${forbidden}`);
check(!scene.includes('script ='), 'canonical scene is not passive');

const captureScript = exists(captureScriptPath) ? read(captureScriptPath) : '';
check(captureScript.includes('extends "res://scripts/v0354_barn_final_evidence.gd"'), 'capture does not reuse accepted v0.354 environment');
check(captureScript.includes('_apply_frozen_v0350_material_skin()') && captureScript.includes('_apply_roof_visibility_repair()') && captureScript.includes('_apply_upper_loading_shutters()') && captureScript.includes('_apply_terrain_integrated_contact()'), 'frozen accepted visual recipe is incomplete');
check(captureScript.includes('V0355_ACCEPTED_SOURCE_HASH') && captureScript.includes('v0355_canonical_hash != V0355_ACCEPTED_SOURCE_HASH'), 'exact hash gate missing');
check(captureScript.includes('SubViewport') || read('desktop-spikes/godot-salto/scripts/v0354_barn_final_evidence.gd').includes('SubViewport'), 'direct square SubViewport contract missing');
check(!captureScript.includes('move_to') && !captureScript.includes('combat') && !captureScript.includes('economy'), 'v0.355 capture contains gameplay mutation language');

check(exists(runtimeManifestPath), 'v0.355 runtime manifest missing; run capture first');
const runtime = exists(runtimeManifestPath) ? json(runtimeManifestPath) : {};
check(runtime.status === 'PASS_V0355_BARROSAN_BARN_HUMAN_GOLD_LOCK_RUNTIME', 'v0.355 runtime capture did not pass');
check(runtime.outcome === 'READY FOR HUMAN V0355 BARROSAN BARN GOLD-LOCK RECORD REVIEW', 'v0.355 runtime outcome invalid');
check(runtime.canonicalMatchesAcceptedSource === true && runtime.canonical256SourceHash === '13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3', 'canonical 256 source is not exact accepted hash');
check(runtime.rawCaptureCount === 4 && (runtime.requiredRawNames ?? []).length === 4, 'v0.355 raw capture count/name contract invalid');
for (const name of runtime.requiredRawNames ?? []) check(exists(`${rawDir}/${name}`) && fs.statSync(rel(`${rawDir}/${name}`)).size > 1024, `required raw canonical capture missing: ${name}`);
check(JSON.stringify(pngSize(`${rawDir}/04_canonical_barn_square_256.png`)) === JSON.stringify({ width:256, height:256 }), 'canonical raw source is not 256x256');
check(sha(`${rawDir}/04_canonical_barn_square_256.png`) === sha(acceptedSourcePath), 'fresh canonical source does not byte-match accepted v0.354 source');

const manifest = exists(manifestPath) ? json(manifestPath) : {};
for (const [key,value] of Object.entries({assetName:'Barrosan Barn',assetFamily:'Barrosan Human Settlement',assetStatus:'HUMAN_APPROVED_VISUAL_GOLD',humanDecision:decision,humanApprovalCheckpoint:'v0.354',humanApprovalCommit:base,canonicalScenePath,geometryLineage:'v0.347',materialLineage:'v0.350',shuttersLineage:'v0.351',roofLineage:'v0.352',workersAndContactLineage:'v0.353',finalEvidenceLineage:'v0.354',canonicalRegistrationCheckpoint:'v0.355',frozenRoofRepairHash:'0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9',acceptedV0354Raw256SourceHash:'13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3',canonical256SourceHash:'13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3'})) check(manifest[key] === value, `gold manifest field invalid: ${key}`);
for (const key of ['canonicalMatchesAcceptedSource','visualGold','canonicalScenePassive']) check(manifest[key] === true, `gold manifest true field invalid: ${key}`);
for (const key of ['productionIntegrated','defaultRuntimeIntegrated','gameplayIntegrated','automatedVisualApproval','collisionIntegrated','canonicalSceneHasReviewCamera','canonicalSceneHasLights','canonicalSceneHasTerrain','canonicalSceneHasWorkers','canonicalSceneHasLabels','canonicalSceneHasGameplay']) check(manifest[key] === false, `gold manifest false field invalid: ${key}`);
check(manifest.stableGameplayId === null, 'stable gameplay ID was registered');

const packFiles = exists(packDir) ? fs.readdirSync(rel(packDir)).filter((file) => fs.statSync(rel(`${packDir}/${file}`)).isFile()).sort() : [];
check(JSON.stringify(packFiles) === JSON.stringify(expectedPack), 'v0.355 upload pack is not exactly eight files');
check(packFiles.filter((file) => file.toLowerCase().endsWith('.png')).length === 6, 'v0.355 pack does not contain exactly six PNG files');
check(!packFiles.some((file) => /\.mp4$|\.webm$|\.mov$/i.test(file)), 'v0.355 pack contains video');
for (const file of packFiles.filter((file) => file.endsWith('.png'))) check(fs.statSync(rel(`${packDir}/${file}`)).size > 1024, `review board is empty: ${file}`);
const summary = exists(`${packDir}/compact-evidence-summary.json`) ? json(`${packDir}/compact-evidence-summary.json`) : {};
for (const [key,value] of Object.entries({checkpoint:'v0.355',outcome:'READY FOR HUMAN V0355 BARROSAN BARN GOLD-LOCK RECORD REVIEW',visualGold:true,productionIntegrated:false,defaultRuntimeIntegrated:false,gameplayIntegrated:false,canonicalMatchesAcceptedSource:true,exactEightFiles:true,exactlySixPng:true,noVideo:true,automatedVisualApproval:false})) check(summary[key] === value, `compact summary field invalid: ${key}`);
check(JSON.stringify(summary.mutationCounts) === JSON.stringify({ gameplay:0, defaultRuntime:0, economy:0, resources:0, stableIds:0 }), 'compact summary mutation counts are not zero');

if (failures.length) { console.error('FAIL_V0355_BARROSAN_BARN_HUMAN_GOLD_LOCK_VALIDATION'); for (const failure of failures) console.error(`- ${failure}`); process.exit(1); }
console.log('PASS_V0355_BARROSAN_BARN_HUMAN_GOLD_LOCK_VALIDATION');
