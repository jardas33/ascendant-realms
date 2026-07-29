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
const sha = (p) => crypto.createHash('sha256').update(fs.readFileSync(abs(p))).digest('hex');
const png = (p) => {
  const b = fs.readFileSync(abs(p));
  return b.length > 24 && b.readUInt32BE(0) === 0x89504e47
    ? { width: b.readUInt32BE(16), height: b.readUInt32BE(20), bytes: b.length }
    : null;
};
const scenePath = 'desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn';
const sceneHash = 'ffaf4c4eeb7c0dabc3a483b0137ad2d92d2b2f6dd496b84b86584ae4a7e86a4a';
const source = 'artifacts/runtime/v0355/screenshots/04_canonical_barn_square_256.png';
const sourceHash = '13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3';
const roofHash = '0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9';
const manifestPath = 'docs/gold/V0355_BARROSAN_BARN_GOLD_MANIFEST.json';
const ledgerPath = 'docs/gold/V0355_BARROSAN_BARN_ACCEPTANCE_LEDGER.md';
const scriptPath = 'desktop-spikes/godot-salto/scripts/v0357_barrosan_barn_first_opt_in_integration.gd';
const captureScript = 'tools/godot/captureGodotV0357BarrosanBarnFirstOptInWindows.ps1';
const packScript = 'tools/godot/buildV0357BarrosanBarnFirstOptInPack.ps1';
const sceneReviewPath = 'desktop-spikes/godot-salto/scenes/review/V0357BarrosanBarnFirstOptInIntegration.tscn';
const runtime = 'artifacts/runtime/v0357/v0357-barrosan-barn-first-opt-in-capture.json';
const pack = 'artifacts/manual-review/v0357-barrosan-barn-first-opt-in-integration/UPLOAD_TO_CHAT';
const expectedPack = ['00_READ_ME_FIRST.md','01_HUMAN_DECISION_AND_GOLD_SLOT_AUTHORITY.png','02_DEFAULT_VS_OPT_IN_PLAYER_VIEW.png','03_HOUSE02_BARN_WORKER_SCALE_AND_CONTEXT.png','04_RTS_AND_TERRAIN_CONTACT.png','05_FRONT_REAR_AND_EXTERIOR_ROOF.png','06_FAIL_CLOSED_MISSING_AND_HASH_MISMATCH.png','07_ROLLBACK_AND_DEFAULT_RUNTIME_PRESERVATION.png','08_PERFORMANCE_RESOURCE_AND_NODE_LEDGER.png','compact-evidence-summary.json'];
const expectedDecision = 'V0.354 HUMAN-APPROVED — BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN';

check(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0357BarrosanBarnFirstOptInTool.mjs validate');
for (const p of [scenePath, source, manifestPath, ledgerPath, scriptPath, captureScript, packScript, sceneReviewPath, runtime, `${pack}/00_READ_ME_FIRST.md`, `${pack}/compact-evidence-summary.json`]) check(exists(p), `missing v0.357 artifact: ${p}`);
const scene = exists(scenePath) ? read(scenePath) : '';
const sourceInfo = exists(source) ? png(source) : null;
check(exists(scenePath) && sha(scenePath) === sceneHash, 'canonical BarnGold scene changed from v0.355 hash');
check(sourceInfo?.width === 256 && sourceInfo?.height === 256 && sha(source) === sourceHash, 'accepted canonical source hash/dimensions changed');
const manifest = exists(manifestPath) ? JSON.parse(read(manifestPath)) : {};
const ledger = exists(ledgerPath) ? read(ledgerPath) : '';
check(manifest.assetStatus === 'HUMAN_APPROVED_VISUAL_GOLD' && manifest.canonicalScenePath === scenePath, 'gold manifest authority/path invalid');
check(manifest.humanDecision === expectedDecision && ledger.includes(expectedDecision), 'human authority decision is not exact');
check(manifest.acceptedV0354Raw256SourceHash === sourceHash && manifest.frozenRoofRepairHash === roofHash, 'gold lineage hashes invalid');
check(scene.includes('barn_final_material_harmony.glb') && scene.includes('HUMAN_APPROVED_VISUAL_GOLD') && !scene.includes('script ='), 'canonical scene is not passive gold content');
const integration = read(scriptPath);
for (const required of ['barrosan_barn_gold_v0355','MISSING_SCENE_FAIL_CLOSED','HASH_MISMATCH_FAIL_CLOSED','UNKNOWN_SLOT_REJECTED','ROLLED_BACK_CLEAN','V0357_River_Recessed_Water','V0357_Bridge_Deck_Spanning_River','_apply_frozen_v0350_material_skin','defaultRuntimeIntegrated']) check(integration.includes(required), `v0.357 implementation contract missing: ${required}`);
check(integration.includes('if not v0357_opt_in_requested') && integration.includes('OFF_DEFAULT_NO_BARN_LOAD'), 'opt-in is not off by default');
check(!integration.includes('StaticBody3D') && !integration.includes('NavigationRegion3D') && !integration.includes('CollisionShape3D'), 'v0.357 visual-only script adds gameplay collision/navigation');
const changed = Array.from(new Set([
  ...execFileSync('git', ['diff', '--name-only'], { cwd: root, encoding: 'utf8' }).split(/\r?\n/u),
  ...execFileSync('git', ['ls-files', '--others', '--exclude-standard'], { cwd: root, encoding: 'utf8' }).split(/\r?\n/u)
])).filter(Boolean).map((p) => p.replace(/\\/gu, '/'));
check(!changed.some((p) => p.startsWith('src/') || p.startsWith('public/') || p.startsWith('artifacts/runtime-art/') || p.startsWith('src/game/save/')), 'browser/save/runtime-art paths changed');
check(!changed.some((p) => p.includes('GODOT_LAUNCH_PLAYER_SLICE_WINDOWS') || p.includes('GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS')), 'default launcher changed');
const capture = exists(runtime) ? JSON.parse(read(runtime)) : {};
check(capture.status === 'PASS_V0357_BARROSAN_BARN_FIRST_OPT_IN_CAPTURE' && capture.optInOnly === true, 'runtime capture did not pass opt-in-only contract');
for (const [key, expected] of Object.entries({ validOptInLoadedOnce:true, missingSceneFailClosed:true, hashMismatchFailClosed:true, invalidAuthorityFailClosed:true, unknownSlotRejected:true, rollbackClean:true })) check(capture[key] === expected, `runtime failure/rollback scenario invalid: ${key}`);
check(capture.defaultRuntimeIntegrated === false && capture.gameplayIntegrated === false && capture.browserIntegrated === false && capture.gameplayMutationCount === 0 && capture.defaultRuntimeMutationCount === 0, 'runtime mutation boundary invalid');
check(Number(capture.medianFpsRatio) >= 0.75 && Number(capture.p95FrameTimeRatio) <= 1.5, 'performance ratio outside retained opt-in threshold');
const files = exists(pack) ? fs.readdirSync(abs(pack)).filter((f) => fs.statSync(abs(`${pack}/${f}`)).isFile()).sort() : [];
check(JSON.stringify(files) === JSON.stringify([...expectedPack].sort()), 'v0.357 review pack must contain exactly ten files');
check(files.filter((f) => f.endsWith('.png')).length === 8 && !files.some((f) => /\.(mp4|webm|mov)$/iu.test(f)), 'v0.357 review pack must contain exactly eight PNGs and no video');
for (const file of files.filter((f) => f.endsWith('.png'))) { const info = png(`${pack}/${file}`); check(info && info.width >= 1200 && info.height >= 700 && info.bytes > 10000, `review board is not a genuine wide render: ${file}`); }
const summary = exists(`${pack}/compact-evidence-summary.json`) ? JSON.parse(read(`${pack}/compact-evidence-summary.json`)) : {};
for (const [key, expected] of Object.entries({ checkpoint:'v0.357', authorizedSlotId:'barrosan_barn_gold_v0355', canonicalScenePath:scenePath, requiredSourceHash:sourceHash, requiredRoofHash:roofHash, optInOnly:true, defaultRuntimeIntegrated:false, productionIntegrated:false, gameplayIntegrated:false, browserIntegrated:false, gameplayMutationCount:0, defaultRuntimeMutationCount:0, canonicalAssetMutationCount:0, geometryMutationCount:0, materialMutationCount:0, textureMutationCount:0, canonicalTransformMutationCount:0, exactTenFiles:true, exactlyEightPng:true, noVideo:true, automatedVisualApproval:false })) check(summary[key] === expected, `compact summary field invalid: ${key}`);
check(summary.sourceHashMatch === true && summary.roofHashMatch === true && summary.validOptInLoadedOnce === true, 'compact summary hash/slot result invalid');
const captureDirs = ['default-off','opt-in-front','opt-in-rts','opt-in-contact','opt-in-rear','opt-in-roof','debug-review','rollback'];
for (const dir of captureDirs) { const shots = exists(`${'artifacts/runtime/v0357'}/${dir}/screenshots`) ? fs.readdirSync(abs(`artifacts/runtime/v0357/${dir}/screenshots`)).filter((f) => f.endsWith('.png')) : []; check(shots.length >= 1, `missing genuine non-headless capture for ${dir}`); }
if (failures.length) { console.error('FAIL_V0357_BARROSAN_BARN_FIRST_OPT_IN_VALIDATION'); for (const failure of failures) console.error(`- ${failure}`); process.exit(1); }
console.log('PASS_V0357_BARROSAN_BARN_FIRST_OPT_IN_VALIDATION');
