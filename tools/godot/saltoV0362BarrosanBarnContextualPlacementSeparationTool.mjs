import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const root = process.cwd();
const failures = [];
const abs = (p) => path.join(root, p);
const exists = (p) => fs.existsSync(abs(p));
const check = (value, message) => { if (!value) failures.push(message); };
const sha = (p) => crypto.createHash('sha256').update(fs.readFileSync(abs(p))).digest('hex');
const readStrict = (p) => {
  try { return new TextDecoder('utf-8', { fatal: true }).decode(fs.readFileSync(abs(p))); }
  catch { failures.push(`strict UTF-8 decode failed: ${p}`); return ''; }
};
const json = (p) => JSON.parse(readStrict(p).replace(/^\uFEFF/u, ''));
const nearly = (a, b, tolerance = 1e-6) => Number.isFinite(Number(a)) && Math.abs(Number(a) - Number(b)) <= tolerance;
const scene = 'desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn';
const sceneHash = 'ffaf4c4eeb7c0dabc3a483b0137ad2d92d2b2f6dd496b84b86584ae4a7e86a4a';
const source = 'artifacts/runtime/v0355/screenshots/04_canonical_barn_square_256.png';
const sourceHash = '13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3';
const roofHash = '0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9';
const runtime = 'artifacts/runtime/v0362';
const pack = 'artifacts/manual-review/v0362-barrosan-barn-contextual-placement-separation/UPLOAD_TO_CHAT';
const summaryPath = `${pack}/compact-evidence-summary.json`;
const reportPath = 'docs/V0362_BARROSAN_BARN_CONTEXTUAL_PLACEMENT_SEPARATION_REPORT.md';
const scriptPath = 'desktop-spikes/godot-salto/scripts/v0362_barrosan_barn_contextual_placement_separation.gd';
const capturePath = 'tools/godot/captureGodotV0362BarrosanBarnContextualPlacementSeparationWindows.ps1';
const builderPath = 'tools/godot/buildV0362BarrosanBarnContextualPlacementSeparationPack.ps1';
const expectedFiles = [
  '00_READ_ME_FIRST.md', '01_HUMAN_DECISION_AND_REPAIRED_PLACEMENT.png', '02_BEFORE_VS_AFTER_IDENTICAL_CAMERA.png',
  '03_WORLD_BOUNDS_AND_CLEARANCE_MEASUREMENT.png', '04_CLEAN_PLAYER_RTS_SEPARATION.png', '05_WORKER_PASSAGE_AND_REAL_SCALE.png',
  '06_REAR_ROOF_AND_EAVE_SEPARATION.png', '07_DEFAULT_OPT_IN_AND_EXACT_ROLLBACK.png', '08_HASH_MUTATION_AND_PLACEMENT_LEDGER.png',
  'compact-evidence-summary.json'
];
const pngFiles = expectedFiles.filter((p) => p.endsWith('.png'));
const parsePng = (p) => {
  const b = fs.readFileSync(abs(p));
  return { signature: b.subarray(0, 8).equals(Buffer.from([137,80,78,71,13,10,26,10])), width: b.readUInt32BE(16), height: b.readUInt32BE(20), hasIdat: b.includes(Buffer.from('IDAT')), bytes: b.length };
};
const textScan = (text) => {
  let mojibake = 0, control = 0, replacement = 0, bom = 0;
  for (const ch of text) { const n = ch.codePointAt(0); if (n === 0xc3 || n === 0xc2 || n === 0xe2) mojibake++; if ((n < 32 && !['\t', '\n', '\r'].includes(ch)) || n === 0x7f) control++; if (n === 0xfffd) replacement++; if (n === 0xfeff) bom++; }
  return { mojibake, control, replacement, bom };
};
const summaryShapeValid = (s) => s?.finalMeasurement?.structuralAabbIntersection === false && nearly(s.finalMeasurement.horizontalOverlapDepth, 0) && Number(s.finalMeasurement.closestHorizontalClearance) >= Number(s.finalMeasurement.requiredWorkerClearance) && Number(s.finalMeasurement.closestHorizontalClearance) >= 0.75 && s.fixtureBarnRootRotationMutationCount === 0 && s.fixtureBarnRootScaleMutationCount === 0 && s.changedNonBarnNodeCount === 0 && s.duplicateBarnRootCount === 0;
const negative = (label, altered) => { if (summaryShapeValid(altered)) failures.push(`negative test did not fail closed: ${label}`); };

check(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0362BarrosanBarnContextualPlacementSeparationTool.mjs validate');
for (const p of [scene, source, scriptPath, capturePath, builderPath, reportPath, pack, summaryPath, `${runtime}/v0362-capture-manifest.json`, `${runtime}/opt-in-wide/v0362-barrosan-barn-placement-runtime.json`, `${runtime}/default/v0362-barrosan-barn-placement-runtime.json`, `${runtime}/rollback/v0362-barrosan-barn-placement-runtime.json`]) check(exists(p), `missing ${p}`);

if (!failures.length) {
  const s = json(summaryPath); const capture = json(`${runtime}/v0362-capture-manifest.json`); const final = json(`${runtime}/opt-in-wide/v0362-barrosan-barn-placement-runtime.json`); const def = json(`${runtime}/default/v0362-barrosan-barn-placement-runtime.json`); const rollback = json(`${runtime}/rollback/v0362-barrosan-barn-placement-runtime.json`); const beforeBase = json(`${runtime}/before-rejected/v0359-barrosan-barn-runtime.json`); const afterBase = json(`${runtime}/opt-in-wide/v0359-barrosan-barn-runtime.json`); const names = fs.readdirSync(abs(pack));
  check(names.length === 10 && expectedFiles.every((p) => names.includes(p)), 'exact ten-file upload contract');
  check(names.filter((p) => p.endsWith('.png')).length === 8, 'exactly eight PNG boards');
  check(!names.some((p) => /\.(mp4|webm|mov|avi|csv)$/i.test(p)), 'video or raw capture file inside pack');
  check(sha(scene) === sceneHash, 'canonical Barn scene hash changed'); check(sha(source) === sourceHash, 'canonical source hash changed');
  check(s.canonicalSourceHash === sourceHash && s.canonicalRoofHash === roofHash, 'canonical source/roof authority changed');
  check(s.genuineNonHeadlessCaptures === true && s.noVideo === true, 'capture provenance flags');
  for (const p of pngFiles) { const image = parsePng(`${pack}/${p}`); check(image.signature && image.width === 1600 && image.height === 900 && image.hasIdat && image.bytes > 10000, `nonblank 1600x900 PNG required: ${p}`); }
  for (const p of expectedFiles.filter((x) => x.endsWith('.md') || x.endsWith('.json'))) { const scan = textScan(readStrict(`${pack}/${p}`)); check(scan.mojibake === 0 && scan.control === 0 && scan.replacement === 0 && scan.bom === 0, `UTF-8 text integrity: ${p}`); }
  const report = readStrict(reportPath); const reportScan = textScan(report); check(reportScan.mojibake === 0 && reportScan.control === 0 && reportScan.replacement === 0 && reportScan.bom === 0, 'report UTF-8 integrity');
  const begin = '<!-- V0362_PLACEMENT_BEGIN -->'; const end = '<!-- V0362_PLACEMENT_END -->'; check(report.includes(begin) && report.includes(end), 'report placement block missing');
  let block = {}; try { block = JSON.parse(report.split(begin)[1].split(end)[0].trim()); } catch { failures.push('report placement block is not JSON'); }
  const m = s.finalMeasurement; check(s.scenePath === 'res://scenes/review/V0362BarrosanBarnContextualPlacementSeparation.tscn', 'prototype scene path'); check(s.authorizedSlot === 'barrosan_barn_gold_v0355', 'authorized slot'); check(s.oldFixtureBarnTransform.position.x < 0 && nearly(s.newFixtureBarnTransform.position.x, 4), 'old/new Barn root transform'); check(nearly(s.newFixtureBarnTransform.position.y, 0.18) && nearly(s.newFixtureBarnTransform.position.z, -1), 'Barn Y/Z transform changed'); check(nearly(s.newFixtureBarnTransform.rotation.x, 0) && nearly(s.newFixtureBarnTransform.rotation.y, 0) && nearly(s.newFixtureBarnTransform.rotation.z, 0), 'Barn rotation changed'); check(nearly(s.newFixtureBarnTransform.scale.x, 1) && nearly(s.newFixtureBarnTransform.scale.y, 1) && nearly(s.newFixtureBarnTransform.scale.z, 1), 'Barn scale changed');
  check(m.structuralAabbIntersection === false && nearly(m.horizontalOverlapDepth, 0), 'structural intersection or XZ overlap'); check(m.roofEaveIntersection === false && nearly(m.roofEaveOverlapDepth, 0), 'roof/eave intersection or overlap'); check(Number(m.closestHorizontalClearance) >= Number(m.requiredWorkerClearance) && Number(m.closestHorizontalClearance) >= 0.75, 'worker clearance below requirement'); check(m.workerClearancePassed === true && m.ordinaryRtsGapVisible === true, 'gap evidence'); check(m.house02MeshCount > 0 && m.barnMeshCount > 0 && m.house02RoofMeshCount > 0 && m.barnRoofMeshCount > 0, 'world-space mesh/roof inventory missing');
  for (const key of ['canonicalAssetMutationCount','geometryMutationCount','materialMutationCount','textureMutationCount','canonicalTransformMutationCount','fixtureBarnRootRotationMutationCount','fixtureBarnRootScaleMutationCount','changedNonBarnNodeCount','duplicateBarnRootCount','gameplayMutationCount','defaultRuntimeMutationCount','browserMutationCount','saveMutationCount','stableIdMutationCount','performanceBenchmarkRerunCount']) check(s[key] === 0, `mutation ledger nonzero: ${key}`); check(s.fixtureBarnRootPositionMutationCount === 1, 'fixture position mutation count');
  check(def.defaultBarnInstanceCount === 0 && s.defaultBarnInstanceCount === 0, 'default Barn count not zero'); check(s.optInBarnInstanceCount === 1 && s.validOptInLoadedOnce === true, 'valid opt-in count/load'); check(s.rollbackClean === true && s.baselineRollbackStateMatch === true && s.rollbackR0R2PixelMatch === true && capture.rollbackR0R2PixelMatch === true, 'rollback evidence');
  check(capture.failClosedCount === 4 && capture.results.filter((r) => String(r.id).includes('fail-closed') || String(r.id).includes('unknown-slot')).length === 4, 'four fail-closed scenarios'); check(capture.results.some((r) => r.id === 'before-rejected') && capture.results.some((r) => r.id === 'opt-in-wide') && capture.results.some((r) => r.id === 'opt-in-gap') && capture.results.some((r) => r.id === 'opt-in-measurement') && capture.results.some((r) => r.id === 'opt-in-roof'), 'capture matrix incomplete');
  const beforeCapture = beforeBase.captures[0]; const afterCapture = afterBase.captures[0]; check(beforeCapture.projectionType === 'orthographic' && afterCapture.projectionType === 'orthographic' && nearly(beforeCapture.orthographicSize, afterCapture.orthographicSize) && JSON.stringify(beforeCapture.cameraPosition) === JSON.stringify(afterCapture.cameraPosition) && JSON.stringify(beforeCapture.cameraTarget) === JSON.stringify(afterCapture.cameraTarget), 'before/after camera is not identical'); check(sha(`${runtime}/before-rejected/screenshots/before.png`) !== sha(`${runtime}/opt-in-wide/screenshots/wide.png`), 'before/after rendered pixels did not differ');
  check(summaryShapeValid(s), 'summary final shape invalid');
  for (const [key, value] of Object.entries({ oldBarnX: -1.8, newBarnX: 4, structuralAabbIntersection: false, horizontalOverlapDepth: 0, closestHorizontalClearance: 2.48, roofEaveIntersection: false, roofEaveOverlapDepth: 0, closestRoofEaveClearance: 2.51, workerWidthReference: 1.25, requiredWorkerClearance: 1.875, workerClearancePassed: true, defaultBarnInstanceCount: 0, optInBarnInstanceCount: 1, fixtureBarnRootPositionMutationCount: 1, fixtureBarnRootRotationMutationCount: 0, fixtureBarnRootScaleMutationCount: 0, changedNonBarnNodeCount: 0, duplicateBarnRootCount: 0, rollbackClean: true, baselineRollbackStateMatch: true, rollbackR0R2PixelMatch: true })) check(block[key] === value || nearly(block[key], value), `report/summary placement mismatch: ${key}`);
  const badIntersection = JSON.parse(JSON.stringify(s)); badIntersection.finalMeasurement.structuralAabbIntersection = true; negative('structural intersection', badIntersection); const badClearance = JSON.parse(JSON.stringify(s)); badClearance.finalMeasurement.closestHorizontalClearance = 0.1; negative('below worker clearance', badClearance); const badScale = JSON.parse(JSON.stringify(s)); badScale.fixtureBarnRootScaleMutationCount = 1; negative('scale mutation', badScale); const badHouse = JSON.parse(JSON.stringify(s)); badHouse.changedNonBarnNodeCount = 1; negative('non-Barn mutation', badHouse); const missing = JSON.parse(JSON.stringify(s)); delete missing.finalMeasurement; negative('missing measurement', missing); const duplicate = JSON.parse(JSON.stringify(s)); duplicate.duplicateBarnRootCount = 1; negative('duplicate Barn root', duplicate); check(failures.filter((x) => x.startsWith('negative test')).length === 0, 'negative tests not enforced');
  const code = readStrict(scriptPath); check(code.includes('NEW_BARN_POSITION := Vector3(4.0, 0.18, -1.0)') && code.includes('world-space transformed mesh AABBs'), 'fixture-only implementation markers missing'); check(!/instantiate.*(?:combat|projectile|enemy|wave|ai)/i.test(code), 'forbidden gameplay instantiation in v0.362 script');
}

if (failures.length) { console.error(`FAIL_V0362_BARROSAN_BARN_CONTEXTUAL_PLACEMENT_SEPARATION\n- ${failures.join('\n- ')}`); process.exit(1); }
console.log('PASS_V0362_BARROSAN_BARN_CONTEXTUAL_PLACEMENT_SEPARATION');
