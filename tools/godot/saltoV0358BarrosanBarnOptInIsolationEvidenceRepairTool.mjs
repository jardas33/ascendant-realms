import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const failures = [];
const check = (condition, message) => { if (!condition) failures.push(message); };
const abs = (p) => path.join(root, p);
const exists = (p) => fs.existsSync(abs(p));
const read = (p) => fs.readFileSync(abs(p), 'utf8').replace(/^\uFEFF/u, '');
const json = (p) => JSON.parse(read(p));
const sha = (p) => crypto.createHash('sha256').update(fs.readFileSync(abs(p))).digest('hex');
const noMojibake = (value) => !/[ÃÂâ][\x80-\xBFÃÂâ]/u.test(value) && !/Ãƒ|Ã‚/u.test(value);
const scenePath = 'desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn';
const sceneHash = 'ffaf4c4eeb7c0dabc3a483b0137ad2d92d2b2f6dd496b84b86584ae4a7e86a4a';
const sourcePath = 'artifacts/runtime/v0355/screenshots/04_canonical_barn_square_256.png';
const sourceHash = '13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3';
const roofHash = '0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9';
const manifestPath = 'docs/gold/V0355_BARROSAN_BARN_GOLD_MANIFEST.json';
const ledgerPath = 'docs/gold/V0355_BARROSAN_BARN_ACCEPTANCE_LEDGER.md';
const scriptPath = 'desktop-spikes/godot-salto/scripts/v0358_barrosan_barn_opt_in_isolation_evidence_repair.gd';
const inheritedScriptPath = 'desktop-spikes/godot-salto/scripts/v0357_barrosan_barn_first_opt_in_integration.gd';
const sceneReviewPath = 'desktop-spikes/godot-salto/scenes/review/V0358BarrosanBarnOptInIsolationEvidenceRepair.tscn';
const captureScript = 'tools/godot/captureGodotV0358BarrosanBarnOptInIsolationEvidenceRepairWindows.ps1';
const packScript = 'tools/godot/buildV0358BarrosanBarnOptInIsolationEvidenceRepairPack.ps1';
const reportPath = 'docs/V0358_BARROSAN_BARN_OPT_IN_ISOLATION_EVIDENCE_REPAIR_REPORT.md';
const aggregatePath = 'artifacts/runtime/v0358/v0358-barrosan-barn-opt-in-isolation-evidence-repair-capture.json';
const pack = 'artifacts/manual-review/v0358-barrosan-barn-opt-in-isolation-evidence-repair/UPLOAD_TO_CHAT';
const expectedPack = ['00_READ_ME_FIRST.md','01_HUMAN_DECISION_AND_SINGLE_SLOT_AUTHORITY.png','02_EXACT_SINGLE_SLOT_DEFAULT_VS_OPT_IN.png','03_HOUSE02_BARN_WORKER_SCALE_AND_CONTEXT.png','04_RTS_DISTANCE_AND_TERRAIN_CONTACT.png','05_FRONT_REAR_AND_EXTERIOR_ROOF.png','06_FOUR_FAIL_CLOSED_STATES.png','07_EXACT_ROLLBACK_AND_DEFAULT_PRESERVATION.png','08_REAL_PERFORMANCE_RESOURCE_AND_NODE_LEDGER.png','compact-evidence-summary.json'];
const decision = `V0.354 HUMAN-APPROVED ${String.fromCharCode(0x2014)} BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN`;

check(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0358BarrosanBarnOptInIsolationEvidenceRepairTool.mjs validate');
for (const p of [scenePath, sourcePath, manifestPath, ledgerPath, scriptPath, inheritedScriptPath, sceneReviewPath, captureScript, packScript, reportPath, aggregatePath, `${pack}/00_READ_ME_FIRST.md`, `${pack}/compact-evidence-summary.json`]) check(exists(p), `missing v0.358 artifact: ${p}`);
check(exists(scenePath) && sha(scenePath) === sceneHash, 'canonical BarnGold scene changed');
check(exists(sourcePath) && sha(sourcePath) === sourceHash, 'accepted canonical 256 source changed');
const manifest = exists(manifestPath) ? json(manifestPath) : {};
const ledger = exists(ledgerPath) ? read(ledgerPath) : '';
check(manifest.assetStatus === 'HUMAN_APPROVED_VISUAL_GOLD' && manifest.canonicalScenePath === scenePath, 'gold manifest authority/path invalid');
check(manifest.humanDecision === decision && ledger.includes(decision), 'frozen human authority invalid');
check(manifest.acceptedV0354Raw256SourceHash === sourceHash && manifest.frozenRoofRepairHash === roofHash, 'frozen source/roof hashes invalid');
const integration = `${exists(inheritedScriptPath) ? read(inheritedScriptPath) : ''}\n${exists(scriptPath) ? read(scriptPath) : ''}`;
for (const required of ['barrosan_barn_gold_v0355','V0358_House02_Shared_Baseline_Unmodified','BASELINE_HOUSE02_NO_BARN','MISSING_SCENE_FAIL_CLOSED','HASH_MISMATCH_FAIL_CLOSED','UNKNOWN_SLOT_REJECTED','ROLLED_BACK_CLEAN','V0357_River_Recessed_Water','V0357_Bridge_Deck_Spanning_River','_run_real_performance_harness','rawFrameTimesMs']) check(integration.includes(required), `v0.358 implementation contract missing: ${required}`);
check(!integration.includes('StaticBody3D') && !integration.includes('NavigationRegion3D') && !integration.includes('CollisionShape3D'), 'v0.358 visual fixture contains gameplay collision/navigation');
const changed = Array.from(new Set([
  ...execFileSync('git', ['diff', '--name-only'], { cwd: root, encoding: 'utf8' }).split(/\r?\n/u),
  ...execFileSync('git', ['ls-files', '--others', '--exclude-standard'], { cwd: root, encoding: 'utf8' }).split(/\r?\n/u)
])).filter(Boolean).map((p) => p.replace(/\\/gu, '/'));
check(!changed.some((p) => p.startsWith('src/') || p.startsWith('public/') || p.startsWith('src/game/save/') || p.includes('GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat') || p.includes('GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat')), 'default/browser/save launcher boundary changed');
const aggregate = exists(aggregatePath) ? json(aggregatePath) : {};
for (const [key, expected] of Object.entries({checkpoint:'v0.358',authorizedSlotId:'barrosan_barn_gold_v0355',canonicalScenePath:scenePath,optInOnly:true,defaultRuntimeIntegrated:false,productionIntegrated:false,gameplayIntegrated:false,browserIntegrated:false,canonicalAssetMutationCount:0,geometryMutationCount:0,materialMutationCount:0,textureMutationCount:0,canonicalTransformMutationCount:0,gameplayMutationCount:0,defaultRuntimeMutationCount:0,changedNonBarnNodeCount:0,validOptInLoadedOnce:true,duplicateInstanceCount:0,missingSceneFailClosed:true,hashMismatchFailClosed:true,invalidAuthorityFailClosed:true,unknownSlotRejected:true,failClosedBarnInstanceCount:0,failClosedFallbackAssetCount:0,rollbackClean:true,rollbackBarnInstanceCount:0,retainedBarnNodeCount:0,baselineRollbackStateMatch:true,performanceMeasurementValid:true,exactTenFiles:true,exactlyEightPng:true,noVideo:true,genuineNonHeadlessCaptures:true,utf8Valid:true,mojibakeCount:0,automatedVisualApproval:false,humanReviewStop:true})) check(aggregate[key] === expected, `aggregate field invalid: ${key}`);
check(aggregate.requiredSourceHash === sourceHash && aggregate.observedSourceHash === sourceHash && aggregate.sourceHashMatch === true, 'aggregate source hash evidence invalid');
check(aggregate.requiredRoofHash === roofHash && aggregate.observedRoofHash === roofHash && aggregate.roofHashMatch === true, 'aggregate roof hash evidence invalid');
check(Array.isArray(aggregate.addedNodePaths) && aggregate.addedNodePaths.length > 0 && aggregate.addedNodePaths.every((p) => p === 'V0358_Barrosan_Barn_Gold_OptIn_Single_Instance' || p.startsWith('V0358_Barrosan_Barn_Gold_OptIn_Single_Instance/')), 'added node paths are not exactly the Barn root and canonical children');
check(Array.isArray(aggregate.removedNodePaths) && aggregate.removedNodePaths.length === 0, 'non-empty removed node paths');
const failureDirs = ['missing-scene-fail-closed','hash-mismatch-fail-closed','invalid-authority-fail-closed','unknown-slot-rejected'];
for (const dir of failureDirs) {
  const runtimePath = `artifacts/runtime/v0358/${dir}/v0358-barrosan-barn-runtime.json`;
  check(exists(runtimePath), `missing fail-closed evidence: ${dir}`);
  if (exists(runtimePath)) {
    const runtime = json(runtimePath);
    check(runtime.loadSucceeded === false && runtime.barnInstanceCount === 0 && runtime.fallbackAssetUsed === false && runtime.runtimeContinued === true, `fail-closed state invalid: ${dir}`);
    check(exists(`artifacts/runtime/v0358/${dir}/screenshots`), `missing fail-closed capture directory: ${dir}`);
  }
}
const performance = exists('artifacts/runtime/v0358/performance/v0358-performance.json') ? json('artifacts/runtime/v0358/performance/v0358-performance.json') : {};
check(performance.performanceMeasurementValid === true, 'real performance measurement is not valid');
check(performance.warmupFrames >= 300 && performance.measurementFramesPerPass >= 600 && performance.performancePassCount >= 3, 'performance protocol below required minimum');
check(performance.default.sample_count >= 1800 && performance.optIn.sample_count >= 1800, 'raw performance sample counts below 1800 per mode');
check(performance.default.median_fps > 5 && performance.optIn.median_fps > 5 && performance.default.p95_frame_time_ms < 200 && performance.optIn.p95_frame_time_ms < 200, 'performance values are startup placeholders or invalid');
check(Array.isArray(performance.default.rawFrameTimesMs) && performance.default.rawFrameTimesMs.length >= 1800 && Array.isArray(performance.optIn.rawFrameTimesMs) && performance.optIn.rawFrameTimesMs.length >= 1800, 'raw frame measurements missing');
const files = exists(pack) ? fs.readdirSync(abs(pack)).filter((f) => fs.statSync(abs(`${pack}/${f}`)).isFile()).sort() : [];
check(JSON.stringify(files) === JSON.stringify([...expectedPack].sort()), 'v0.358 review pack must contain exactly ten files');
check(files.filter((f) => f.endsWith('.png')).length === 8 && !files.some((f) => /\.(mp4|webm|mov)$/iu.test(f)), 'v0.358 review pack must contain exactly eight PNGs and no video');
for (const file of files.filter((f) => f.endsWith('.png'))) {
  const bytes = fs.readFileSync(abs(`${pack}/${file}`));
  check(bytes.length > 10000 && bytes.readUInt32BE(0) === 0x89504e47 && bytes.readUInt32BE(16) >= 1200 && bytes.readUInt32BE(20) >= 700, `review board is not a genuine wide render: ${file}`);
}
for (const p of [`${pack}/00_READ_ME_FIRST.md`,`${pack}/compact-evidence-summary.json`,reportPath]) {
  const contents = read(p);
  check(noMojibake(contents), `mojibake detected in ${p}`);
  check(contents.includes(decision), `exact human decision missing from ${p}`);
}
const v0357PackReadme = 'artifacts/manual-review/v0357-barrosan-barn-first-opt-in-integration/UPLOAD_TO_CHAT/00_READ_ME_FIRST.md';
if (exists(v0357PackReadme)) check(noMojibake(read(v0357PackReadme)), 'retained v0.357 README still contains mojibake');
check(read('package.json').includes('godot:validate:salto-v0358-barrosan-barn-opt-in-evidence-repair'), 'v0.358 package validator command missing');
if (failures.length) { console.error('FAIL_V0358_BARROSAN_BARN_OPT_IN_ISOLATION_EVIDENCE_REPAIR_VALIDATION'); for (const failure of failures) console.error(`- ${failure}`); process.exit(1); }
console.log('PASS_V0358_BARROSAN_BARN_OPT_IN_ISOLATION_EVIDENCE_REPAIR_VALIDATION');
