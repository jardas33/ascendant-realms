import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const repo = process.cwd();
const pack = path.join(repo, 'artifacts/manual-review/v0365-barrosan-foreground-prop-presence-state-and-preview-board-truth-repair/UPLOAD_TO_CHAT');
const capture = path.join(repo, 'artifacts/runtime/v0365/capture');
const required = [
  '00_READ_ME_FIRST.md','01_HUMAN_DECISION_AND_SCOPE.png','02_ORIGINAL_PLAYER_VIEW_WITH_CALLOUTS.png',
  '03_HOUSE02_GROUND_OBJECT_ISOLATION.png','04_HOUSE02_UPPER_TIMBER_ISOLATION.png','05_BARN_FRONT_TIMBER_ISOLATION.png',
  '06_BROAD_HOUSE02_TIMBER_NODE_VISIBILITY_DIAGNOSTIC.png','07_PROVENANCE_OWNERSHIP_AND_STATE_PRESENCE_LEDGER.png',
  '08_R0_R1_R2_AND_SOURCE_PRESERVATION.png','compact-evidence-summary.json'
];
const mutationFields = ['canonicalBarnMutationCount','house02SourceMutationCount','geometryMutationCount','materialMutationCount','textureMutationCount','transformMutationCount','placementMutationCount','defaultRuntimeMutationCount','gameplayMutationCount','collisionMutationCount','navigationMutationCount','saveMutationCount','stableIdMutationCount','benchmarkRerunCount'];
const fail = [];
const assert = (condition, message) => { if (!condition) fail.push(message); };
const readJson = file => JSON.parse(fs.readFileSync(file, 'utf8'));
const same = (a, b) => JSON.stringify(a) === JSON.stringify(b);
const sha = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const textFiles = dir => fs.readdirSync(dir).filter(name => /\.(md|json)$/i.test(name));

assert(fs.existsSync(pack), 'review pack missing');
if (fs.existsSync(pack)) {
  const actual = fs.readdirSync(pack).sort();
  assert(same(actual, [...required].sort()), `exact review pack mismatch: ${actual.join(', ')}`);
  assert(actual.filter(name => name.toLowerCase().endsWith('.png')).length === 8, 'review pack must contain exactly 8 PNG boards');
  for (const name of textFiles(pack)) {
    const buf = fs.readFileSync(path.join(pack, name));
    const text = buf.toString('utf8');
    assert(!buf.subarray(0, 3).equals(Buffer.from([0xef, 0xbb, 0xbf])), `${name} has UTF-8 BOM`);
    assert(!text.includes('\uFFFD'), `${name} has replacement character`);
    assert(!/[\u0000-\u0008\u000B\u000C\u000E-\u001F]/.test(text), `${name} has control characters`);
    assert(!/[âÃÂ�]/.test(text), `${name} has mojibake`);
  }
  const readme = fs.readFileSync(path.join(pack, '00_READ_ME_FIRST.md'), 'utf8');
  assert(readme.startsWith('READY FOR HUMAN V0365 BARROSAN FOREGROUND PROP PRESENCE-STATE AND PREVIEW-BOARD TRUTH REPAIR REVIEW.'), 'README opening line mismatch');
  assert(readme.includes('C is present only in R1'), 'README does not explain C R1-only presence');
  assert(readme.includes('broad-node visibility diagnostic, not a cleanup preview'), 'README does not classify Board 06 as diagnostic');
}

const summaryFile = path.join(pack, 'compact-evidence-summary.json');
const manifestFile = path.join(capture, 'v0365-manifest.json');
const probeFile = path.join(capture, 'v0365-provenance-probe.json');
const stateFile = path.join(capture, 'v0365-state-presence.json');
if (fs.existsSync(summaryFile) && fs.existsSync(manifestFile) && fs.existsSync(probeFile) && fs.existsSync(stateFile)) {
  const s = readJson(summaryFile); const m = readJson(manifestFile); const p = readJson(probeFile); const states = readJson(stateFile);
  assert(s.checkpoint === 'v0.365' && m.checkpoint === 'v0.365' && p.checkpoint === 'v0.365', 'v0.365 checkpoint identity missing');
  assert(m.status === 'PASS_PRESENCE_STATE_AND_DIAGNOSTIC', 'v0.365 runtime manifest is not passing');
  assert(s.v0364ProvenanceFindingsRetained === true && s.v0364PresenceStateContradictionFound === true && s.v0365PresenceStateContradictionRepaired === true, 'v0.364 contradiction-retention/repair flags incorrect');
  assert(s.objectAPresentStates?.join(',') === 'R0,R1,R2' && s.objectBPresentStates?.join(',') === 'R0,R1,R2', 'A/B state presence incorrect');
  assert(s.objectCPresentStates?.join(',') === 'R1', 'C must be present only in R1');
  assert(s.objectAStatePresenceDerived === true && s.objectBStatePresenceDerived === true && s.objectCStatePresenceDerived === true, 'state presence is not marked derived');
  assert(s.objectCR0AbsenceReason === 'BARN_ROOT_NOT_INSTANTIATED', 'C R0 absence reason incorrect');
  assert(s.objectCR2AbsenceReason === 'BARN_ROOT_REMOVED_BY_ROLLBACK', 'C R2 absence reason incorrect');
  assert(s.objectBBroadNodeWarning === true, 'B broad-node warning missing');
  assert(s.board06DiagnosticOnly === true && s.board06SameCamera === true && s.board06EqualPanelDimensions === true && s.board06ExtraDuplicateSceneObjects === 0 && s.board06CroppingDetected === false, 'Board 06 geometry/presentation contract failed');
  assert(s.board06Title === 'BROAD HOUSE02 TIMBER-NODE VISIBILITY DIAGNOSTIC', 'Board 06 title contract failed');
  assert(s.board06Warning.includes('ALSO REMOVES HOUSE02 DOORS, WINDOWS AND OTHER TIMBER SURFACES'), 'Board 06 broad-removal warning missing');
  assert(s.r0BarnRootCount === 0 && s.r1BarnRootCount === 1 && s.r2BarnRootCount === 0, 'R0/R1/R2 Barn counts incorrect');
  assert(s.r0R2RawCaptureMatch === true && s.r0R2StateSignatureMatch === true && s.r1DuplicateBarnRootCount === 0 && s.retainedBarnNodeCountAfterRollback === 0, 'rollback evidence incorrect');
  assert(s.acceptedBarnRootTransform?.x === 4 && s.acceptedBarnRootTransform?.y === 0.18 && s.acceptedBarnRootTransform?.z === -1, 'accepted Barn transform changed');
  assert(s.structuralGap === 2.48 && s.roofEaveGap === 2.51 && s.requiredWorkerGap === 1.875, 'accepted clearances changed');
  for (const field of mutationFields) assert(s[field] === 0, `${field} must remain zero`);
  assert(s.humanReviewStop === true, 'human review stop missing');
  assert(s.objectCNodePaths?.[0] === '/V0358_Barrosan_Barn_Gold_OptIn_Single_Instance/V0347_Barn_Rendered_Geometry_Truth', 'C exact NodePath mismatch');
  const c = p.statePresence?.C; const a = p.statePresence?.A; const b = p.statePresence?.B;
  assert(c && a && b, 'probe statePresence A/B/C missing');
  if (c && a && b) {
    assert(same(c.presentStates, ['R1']), 'probe C presentStates are not R1 only');
    assert(same(a.presentStates, ['R0','R1','R2']) && same(b.presentStates, ['R0','R1','R2']), 'probe A/B presentStates incorrect');
    const cp = c.statePresenceProof;
    assert(cp.R0.ownerRootInstantiated === false && cp.R0.targetNodeExists === false && cp.R0.present === false && cp.R0.absenceReason === 'BARN_ROOT_NOT_INSTANTIATED', 'C R0 live-state proof incorrect');
    assert(cp.R1.ownerRootInstantiated === true && cp.R1.targetNodeExists === true && cp.R1.present === true, 'C R1 live-state proof incorrect');
    assert(cp.R2.ownerRootInstantiated === false && cp.R2.targetNodeExists === false && cp.R2.present === false && cp.R2.absenceReason === 'BARN_ROOT_REMOVED_BY_ROLLBACK', 'C R2 live-state proof incorrect');
    for (const object of [a,b]) for (const state of ['R0','R1','R2']) assert(object.statePresenceProof[state].ownerRootInstantiated === true && object.statePresenceProof[state].targetNodeExists === true && object.statePresenceProof[state].present === true, `A/B live-state proof failed for ${state}`);
  }
  const cRecord = (p.records || []).find(record => record.nodePath === '/V0358_Barrosan_Barn_Gold_OptIn_Single_Instance/V0347_Barn_Rendered_Geometry_Truth');
  assert(cRecord && same(cRecord.presentInStates, ['R1']) && cRecord.statePresenceDerived === true, 'C provenance record not repaired from derived state presence');
  assert(states.statePresence?.C && same(states.statePresence.C.presentStates, ['R1']), 'standalone state-presence artifact disagrees with C R1-only truth');
  const diagnostic = (m.captures || []).find(record => record.file === 'combined-diagnostic.png');
  assert(diagnostic && diagnostic.diagnosticOnly === true && diagnostic.sameCamera === true && diagnostic.equalPanelDimensions === true && diagnostic.extraDuplicateSceneObjects === 0 && diagnostic.croppingDetected === false, 'raw Board 06 diagnostic capture metadata missing');
  assert(diagnostic && typeof diagnostic.sha256 === 'string' && /^[0-9a-f]{64}$/.test(diagnostic.sha256), 'Board 06 manifest SHA-256 missing or invalid');
  for (const file of ['original.png','house-a.png','house-b.png','barn-c.png','combined-diagnostic.png','callouts.png','r0r1r2.png']) assert(fs.existsSync(path.join(capture,'screenshots',file)), `raw v0.365 capture missing: ${file}`);
  assert(sha(path.join(capture,'screenshots','combined-diagnostic.png')).length === 64, 'combined diagnostic capture hash missing');
} else {
  fail.push('v0.365 manifest/probe/state-presence artifacts missing');
}

try {
  const changed = execFileSync('git', ['diff','--name-only','--','assets/v0338/barrosan_house_02_material_gold_candidate.glb','scenes/gold/barrosan/BarrosanBarnGold.tscn','assets/v0350/barn_final_material_harmony.glb'], { cwd: path.join(repo,'desktop-spikes/godot-salto'), encoding:'utf8' }).trim();
  assert(changed === '', `canonical source files changed: ${changed}`);
} catch (error) { fail.push(`canonical source diff check failed: ${error.message}`); }

if (fail.length) { console.error('FAIL_V0365\n- ' + fail.join('\n- ')); process.exit(1); }
console.log('PASS_V0365_BARROSAN_FOREGROUND_PROP_PRESENCE_STATE_AND_PREVIEW_BOARD_TRUTH_REPAIR');
console.log(JSON.stringify({uploadFileCount:fs.readdirSync(pack).length,pngBoardCount:fs.readdirSync(pack).filter(name=>name.endsWith('.png')).length,objectCPresentStates:['R1'],combinedDiagnosticSha256:sha(path.join(capture,'screenshots','combined-diagnostic.png'))}, null, 2));
