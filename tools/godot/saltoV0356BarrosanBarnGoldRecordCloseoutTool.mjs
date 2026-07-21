import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const failures = [];
const check = (condition, message) => { if (!condition) failures.push(message); };
const abs = (p) => path.join(root, p);
const exists = (p) => fs.existsSync(abs(p));
const read = (p) => fs.readFileSync(abs(p), 'utf8').replace(/^\uFEFF/, '');
const sha = (p) => crypto.createHash('sha256').update(fs.readFileSync(abs(p))).digest('hex');
const png = (p) => {
  const b = fs.readFileSync(abs(p));
  return b.length > 24 && b.readUInt32BE(0) === 0x89504e47
    ? { width: b.readUInt32BE(16), height: b.readUInt32BE(20), bytes: b.length }
    : null;
};
const expectedDecision = 'V0.354 HUMAN-APPROVED — BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN';
const acceptedHash = '13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3';
const roofHash = '0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9';
const canonicalScene = 'desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn';
const manifestPath = 'docs/gold/V0355_BARROSAN_BARN_GOLD_MANIFEST.json';
const ledgerPath = 'docs/gold/V0355_BARROSAN_BARN_ACCEPTANCE_LEDGER.md';
const pack = 'artifacts/manual-review/v0355-barrosan-barn-human-gold-lock/UPLOAD_TO_CHAT';
const summaryPath = `${pack}/compact-evidence-summary.json`;
const readmePath = `${pack}/00_READ_ME_FIRST.md`;
const reportPath = 'docs/V0356_BARROSAN_BARN_GOLD_RECORD_CLOSEOUT_REPORT.md';
const acceptedSource = 'artifacts/runtime/v0354/screenshots/06_square_neutral_256.png';
const canonicalSource = 'artifacts/runtime/v0355/screenshots/04_canonical_barn_square_256.png';
const expectedPack = ['00_READ_ME_FIRST.md','01_V0354_HUMAN_APPROVAL_AND_LINEAGE.png','02_CANONICAL_BARN_VISUAL_SCENE.png','03_CANONICAL_FRONT_REAR_AND_ROOF.png','04_ACCEPTED_CANONICAL_PIXEL_IDENTITY.png','05_TRUE_256_CANONICAL_SOURCE.png','06_GOLD_MANIFEST_AND_HASH_LEDGER.png','compact-evidence-summary.json'];

if (process.argv[2] !== 'validate') throw new Error('usage: node tools/godot/saltoV0356BarrosanBarnGoldRecordCloseoutTool.mjs validate');

for (const p of [canonicalScene, manifestPath, ledgerPath, reportPath, summaryPath, readmePath, acceptedSource, canonicalSource]) check(exists(p), `missing required record: ${p}`);
const scene = exists(canonicalScene) ? read(canonicalScene) : '';
check(scene.includes('barn_final_material_harmony.glb') && scene.includes('HUMAN_APPROVED_VISUAL_GOLD'), 'canonical scene binding/status changed');
check(!scene.includes('script =') && !scene.includes('Camera3D') && !scene.includes('DirectionalLight3D'), 'canonical scene is no longer passive');
check(sha(acceptedSource) === acceptedHash, 'accepted v0.354 raw source hash changed');
check(sha(canonicalSource) === acceptedHash, 'canonical v0.355 raw source hash changed');
check(sha(acceptedSource) === sha(canonicalSource), 'accepted/canonical raw hashes differ');
const canonicalInfo = exists(canonicalSource) ? png(canonicalSource) : null;
check(canonicalInfo?.width === 256 && canonicalInfo?.height === 256, 'canonical source is not a 256x256 PNG');

const manifest = exists(manifestPath) ? JSON.parse(read(manifestPath)) : {};
check(manifest.humanDecision === expectedDecision, 'manifest human decision is not exact UTF-8');
check(manifest.canonicalScenePath === canonicalScene && manifest.assetStatus === 'HUMAN_APPROVED_VISUAL_GOLD', 'manifest status/path invalid');
for (const [k,v] of Object.entries({ geometryLineage:'v0.347', materialLineage:'v0.350', shuttersLineage:'v0.351', roofLineage:'v0.352', workersAndContactLineage:'v0.353', finalEvidenceLineage:'v0.354', frozenRoofRepairHash:roofHash, acceptedV0354Raw256SourceHash:acceptedHash, canonical256SourceHash:acceptedHash })) check(manifest[k] === v, `manifest field invalid: ${k}`);
for (const k of ['visualGold','canonicalMatchesAcceptedSource']) check(manifest[k] === true, `manifest true field invalid: ${k}`);
for (const k of ['productionIntegrated','defaultRuntimeIntegrated','gameplayIntegrated','automatedVisualApproval']) check(manifest[k] === false, `manifest false field invalid: ${k}`);
const ledger = exists(ledgerPath) ? read(ledgerPath) : '';
check(ledger.includes(expectedDecision) && ledger.includes('must not silently edit the gold source'), 'acceptance ledger authority/protection record incomplete');
for (const p of [readmePath, summaryPath, manifestPath, ledgerPath, reportPath]) { const s = read(p); check(!/[ÃƒÃ‚]|â€”|â€“|�/.test(s), `UTF-8 record contains mojibake/replacement: ${p}`); }
const readme = exists(readmePath) ? read(readmePath) : '';
check(readme.includes(expectedDecision) && readme.includes(canonicalScene) && readme.includes('v0.356 is documentary repair only'), 'README documentary contract incomplete');

const summary = exists(summaryPath) ? JSON.parse(read(summaryPath)) : {};
const required = ['checkpoint','outcome','humanDecision','humanApprovalCheckpoint','humanApprovalCommit','visualGold','productionIntegrated','defaultRuntimeIntegrated','gameplayIntegrated','canonicalScenePath','goldManifestPath','acceptanceLedgerPath','geometryLineage','materialLineage','shutterLineage','roofLineage','workerEvidenceLineage','finalEvidenceLineage','frozenRoofRepairHash','acceptedRaw256SourceHash','canonicalRaw256SourceHash','canonicalMatchesAcceptedSource','geometryMutationCount','materialMutationCount','textureMutationCount','transformMutationCount','gameplayMutationCount','defaultRuntimeMutationCount','exactEightFiles','exactlySixPng','noVideo','repositoryConventionReused','automatedVisualApproval'];
for (const k of required) check(Object.prototype.hasOwnProperty.call(summary, k), `compact summary missing exact field: ${k}`);
for (const [k,v] of Object.entries({ checkpoint:'v0.356', outcome:'READY FOR HUMAN V0356 BARROSAN BARN RECORD-CLOSEOUT REVIEW', humanDecision:expectedDecision, humanApprovalCheckpoint:'v0.354', humanApprovalCommit:'3e557032976075b06a20f45213d6949c68add314', visualGold:true, productionIntegrated:false, defaultRuntimeIntegrated:false, gameplayIntegrated:false, canonicalScenePath:canonicalScene, goldManifestPath:manifestPath, acceptanceLedgerPath:ledgerPath, geometryLineage:'v0.347', materialLineage:'v0.350', shutterLineage:'v0.351', roofLineage:'v0.352', workerEvidenceLineage:'v0.353', finalEvidenceLineage:'v0.354', frozenRoofRepairHash:roofHash, acceptedRaw256SourceHash:acceptedHash, canonicalRaw256SourceHash:acceptedHash, canonicalMatchesAcceptedSource:true, geometryMutationCount:0, materialMutationCount:0, textureMutationCount:0, transformMutationCount:0, gameplayMutationCount:0, defaultRuntimeMutationCount:0, exactEightFiles:true, exactlySixPng:true, noVideo:true, repositoryConventionReused:true, automatedVisualApproval:false })) check(summary[k] === v, `compact summary value invalid: ${k}`);

const files = exists(pack) ? fs.readdirSync(abs(pack)).filter((f) => fs.statSync(abs(`${pack}/${f}`)).isFile()).sort() : [];
check(JSON.stringify(files) === JSON.stringify([...expectedPack].sort()), 'review pack must contain exactly eight files');
check(files.filter((f) => f.endsWith('.png')).length === 6, 'review pack must contain exactly six PNG files');
check(!files.some((f) => /\.(mp4|webm|mov)$/i.test(f)), 'review pack contains video');
for (const file of files.filter((f) => f.endsWith('.png'))) { const info = png(`${pack}/${file}`); check(info && info.bytes > 1024, `review board invalid: ${file}`); }
check(execFileSync('git', ['diff', '--name-only', '3e557032976075b06a20f45213d6949c68add314', '--', 'art-source', 'desktop-spikes/godot-salto/assets', canonicalScene], { cwd: root, encoding: 'utf8' }).trim() === canonicalScene, 'asset freeze scope changed outside canonical registration');

if (failures.length) { console.error('FAIL_V0356_BARROSAN_BARN_GOLD_RECORD_CLOSEOUT'); for (const failure of failures) console.error(`- ${failure}`); process.exit(1); }
console.log('PASS_V0356_BARROSAN_BARN_GOLD_RECORD_CLOSEOUT');
