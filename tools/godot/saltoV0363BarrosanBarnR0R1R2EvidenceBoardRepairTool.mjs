import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const root = process.cwd();
const failures = [];
const abs = (p) => path.join(root, p);
const exists = (p) => fs.existsSync(abs(p));
const fail = (m) => failures.push(m);
const check = (v, m) => { if (!v) fail(m); };
const sha = (p) => crypto.createHash('sha256').update(fs.readFileSync(abs(p))).digest('hex');
const readStrict = (p) => { try { return new TextDecoder('utf-8', { fatal: true }).decode(fs.readFileSync(abs(p))); } catch { fail(`strict UTF-8 decode failed: ${p}`); return ''; } };
const json = (p) => JSON.parse(readStrict(p).replace(/^\uFEFF/u, ''));
const nearly = (a, b, t = 1e-6) => Number.isFinite(Number(a)) && Math.abs(Number(a) - Number(b)) <= t;
const parsePng = (p) => { const b = fs.readFileSync(abs(p)); return { sig: b.subarray(0, 8).equals(Buffer.from([137,80,78,71,13,10,26,10])), width: b.readUInt32BE(16), height: b.readUInt32BE(20), idat: b.includes(Buffer.from('IDAT')), bytes: b.length }; };
const textScan = (s) => { let control=0, replacement=0, bom=0; for (const c of s) { const n=c.codePointAt(0); if ((n<32 && !['\t','\n','\r'].includes(c)) || n===127) control++; if (n===0xfffd) replacement++; if (n===0xfeff) bom++; } return {control,replacement,bom}; };
const pack = 'artifacts/manual-review/v0363-barrosan-barn-r0-r1-r2-evidence-board-repair/UPLOAD_TO_CHAT';
const previousPack = 'artifacts/manual-review/v0362-barrosan-barn-contextual-placement-separation/UPLOAD_TO_CHAT';
const runtime = 'artifacts/runtime/v0363/board07';
const reportPath = 'docs/V0363_BARROSAN_BARN_R0_R1_R2_EVIDENCE_BOARD_REPAIR_REPORT.md';
const summaryPath = `${pack}/compact-evidence-summary.json`;
const expected = ['00_READ_ME_FIRST.md','01_HUMAN_DECISION_AND_REPAIRED_PLACEMENT.png','02_BEFORE_VS_AFTER_IDENTICAL_CAMERA.png','03_WORLD_BOUNDS_AND_CLEARANCE_MEASUREMENT.png','04_CLEAN_PLAYER_RTS_SEPARATION.png','05_WORKER_PASSAGE_AND_REAL_SCALE.png','06_REAR_ROOF_AND_EAVE_SEPARATION.png','07_DEFAULT_OPT_IN_AND_EXACT_ROLLBACK.png','08_HASH_MUTATION_AND_PLACEMENT_LEDGER.png','compact-evidence-summary.json'];
const retained = expected.filter((p) => /^0[1-6]_/.test(p) || p.startsWith('08_'));
const sourceHash = '13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3';
const roofHash = '0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9';
const canonicalScene = 'desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn';
const canonicalSceneHash = 'ffaf4c4eeb7c0dabc3a483b0137ad2d92d2b2f6dd496b84b86584ae4a7e86a4a';
check(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0363BarrosanBarnR0R1R2EvidenceBoardRepairTool.mjs validate');
for (const p of [pack, summaryPath, reportPath, `${runtime}/v0363-board07-capture-manifest.json`, `${runtime}/v0359-barrosan-barn-runtime.json`, `${runtime}/screenshots/r0.png`, `${runtime}/screenshots/r1.png`, `${runtime}/screenshots/r2.png`, canonicalScene, 'artifacts/runtime/v0355/screenshots/04_canonical_barn_square_256.png']) check(exists(p), `missing ${p}`);
if (!failures.length) {
  const names = fs.readdirSync(abs(pack)); const s = json(summaryPath); const m = json(`${runtime}/v0363-board07-capture-manifest.json`); const prior = json(`${previousPack}/compact-evidence-summary.json`); const priorNames = fs.readdirSync(abs(previousPack));
  check(names.length === 10 && expected.every((p) => names.includes(p)), 'upload pack is not exactly ten files');
  check(names.filter((p) => p.endsWith('.png')).length === 8, 'upload pack must contain eight PNG boards');
  check(!names.some((p) => /\.(mp4|webm|mov|avi|csv)$/i.test(p)), 'raw video or capture file leaked into upload pack');
  for (const p of expected.filter((x) => x.endsWith('.md') || x.endsWith('.json'))) { const t=textScan(readStrict(`${pack}/${p}`)); check(t.control===0 && t.replacement===0 && t.bom===0, `text integrity failed: ${p}`); }
  for (const p of expected.filter((x) => x.endsWith('.png'))) { const i=parsePng(`${pack}/${p}`); check(i.sig && i.width===1600 && i.height===900 && i.idat && i.bytes>10000, `nonblank 1600x900 PNG required: ${p}`); }
  for (const p of retained) check(sha(`${pack}/${p}`) === sha(`${previousPack}/${p}`), `retained v0.362 board mutated: ${p}`);
  const report=readStrict(reportPath); const rs=textScan(report); check(rs.control===0 && rs.replacement===0 && rs.bom===0, 'report text integrity'); const begin='<!-- V0363_R0_R1_R2_BEGIN -->', end='<!-- V0363_R0_R1_R2_END -->'; check(report.includes(begin)&&report.includes(end), 'report machine block missing'); let block={}; try { block=JSON.parse(report.split(begin)[1].split(end)[0].trim()); } catch { fail('report machine block is not JSON'); }
  check(m.captureMode === 'non-headless Godot runtime rollback sequence' && m.genuineNonHeadlessCaptures === true, 'capture provenance missing'); check(m.panelCount===3 && m.cameraMatch===true, 'three-state capture contract incomplete');
  check(m.r0BarnRootCount===0 && m.r1BarnRootCount===1 && m.r2BarnRootCount===0, 'R0/R1/R2 Barn counts incorrect'); check(m.r0R2RawCaptureMatch===true && m.r0R1RawCaptureDistinct===true && m.r1R2RawCaptureDistinct===true, 'raw capture hash relationships incorrect'); check(m.r0R2StateSignatureMatch===true && m.r0R1StateSignatureDistinct===true, 'state signature relationships incorrect');
  check(m.r0.rawCaptureSha256===m.r0RawCaptureHash && m.r1.rawCaptureSha256===m.r1RawCaptureHash && m.r2.rawCaptureSha256===m.r2RawCaptureHash, 'manifest hash duplication mismatch');
  check(m.r0.rawCaptureSha256 !== m.r1.rawCaptureSha256 && m.r1.rawCaptureSha256 !== m.r2.rawCaptureSha256, 'R1 raw hash is not distinct');
  for (const c of [m.r0,m.r1,m.r2]) { check(c.projectionType==='orthographic' && c.viewportWidth===m.r0.viewportWidth && c.viewportHeight===m.r0.viewportHeight && nearly(c.orthographicSize,m.r0.orthographicSize) && JSON.stringify(c.cameraPosition)===JSON.stringify(m.r0.cameraPosition) && JSON.stringify(c.cameraTarget)===JSON.stringify(m.r0.cameraTarget), 'camera/viewport mismatch'); check(fs.existsSync(c.rawCapturePath), `raw capture path missing: ${c.rawCapturePath}`); }
  check(s.checkpoint==='v0.363' && s.previousCheckpoint==='v0.362' && s.previousCommit==='faa240784fef1898e3710500275dae4f018bb169', 'summary lineage missing'); check(s.placementHumanApproved===true && s.v0362Board07Rejected===true && s.v0363Board07Repaired===true, 'human decision fields missing'); check(s.r0BarnRootCount===0&&s.r1BarnRootCount===1&&s.r2BarnRootCount===0&&s.board07PanelCount===3&&s.board07R1BarnVisible===true&&s.board07LabelsCorrect===true, 'summary R0/R1/R2 truth fields missing'); check(s.r0R2RawCaptureMatch===true&&s.r0R1RawCaptureDistinct===true&&s.r1R2RawCaptureDistinct===true&&s.r0R2StateSignatureMatch===true&&s.r0R1StateSignatureDistinct===true, 'summary hash/signature fields incorrect'); check(s.r1DuplicateBarnRootCount===0&&s.r1ChangedNonBarnNodeCount===0&&s.retainedBarnNodeCountAfterRollback===0&&s.placementMutationCountThisCheckpoint===0&&s.canonicalAssetMutationCountThisCheckpoint===0&&s.benchmarkRerunCountThisCheckpoint===0&&s.humanReviewStop===true, 'summary mutation/stop fields incorrect');
  check(sha(canonicalScene)===canonicalSceneHash && prior.canonicalSourceHash===sourceHash && prior.canonicalRoofHash===roofHash, 'canonical authority changed'); check(nearly(prior.newFixtureBarnTransform.position.x,4) && nearly(prior.newFixtureBarnTransform.position.y,0.18) && nearly(prior.newFixtureBarnTransform.position.z,-1), 'accepted Barn transform changed'); check(nearly(prior.finalMeasurement.closestHorizontalClearance,2.48)&&nearly(prior.finalMeasurement.closestRoofEaveClearance,2.51)&&nearly(prior.finalMeasurement.requiredWorkerClearance,1.875), 'accepted clearances changed'); check(prior.failClosedCount===4, 'v0.362 fail-closed evidence not retained'); check(priorNames.length===10, 'v0.362 retained pack no longer exact');
  check(block.r0BarnRootCount===0&&block.r1BarnRootCount===1&&block.r2BarnRootCount===0&&block.r0R2RawCaptureMatch===true&&block.r0R2StateSignatureMatch===true, 'report truth block mismatch');
}
if (failures.length) { console.error(`FAIL_V0363_BARROSAN_BARN_R0_R1_R2_EVIDENCE_BOARD_REPAIR\n- ${failures.join('\n- ')}`); process.exit(1); }
console.log('PASS_V0363_BARROSAN_BARN_R0_R1_R2_EVIDENCE_BOARD_REPAIR');
