import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const base = '94235691e12670fa9f7efc3fbd1d8e9df984a4d0';
const abs = (value) => path.join(root, value);
const exists = (value) => fs.existsSync(abs(value));
const read = (value) => fs.readFileSync(abs(value), 'utf8');
const json = (value) => JSON.parse(read(value));
const sha = (value) => crypto.createHash('sha256').update(fs.readFileSync(abs(value))).digest('hex');
const errors = [];
const assert = (condition, message) => { if (!condition) errors.push(message); };
const expectedPack = ['00_READ_ME_FIRST.md', '01_CC0_SOURCE_LICENCE_AND_DOCUMENTARY_TARGET.png', '02_MATERIAL_1_COMPLETE_TEST_STRUCTURE.png', '03_MATERIAL_2_COMPLETE_TEST_STRUCTURE.png', '04_MATERIAL_3_COMPLETE_TEST_STRUCTURE.png', '05_BLIND_THREE_MATERIAL_COMPARISON.png', '06_STONE_MASKS_AND_ANTI_BRICK_METRICS.png', '07_ACTUAL_PBR_MAPS_AND_GODOT_MATERIAL_RESPONSE.png', '08_CONTINUOUS_V0335_THREE_MATERIAL_TEST.mp4', 'compact-evidence-summary.json'];
const v0334Glb = 'desktop-spikes/godot-salto/assets/v0334/barrosan_house_gold_02.glb';

function pngInfo(relative) {
  const buffer = fs.readFileSync(abs(relative));
  if (buffer.readUInt32BE(0) !== 0x89504e47) return null;
  const width = buffer.readUInt32BE(16); const height = buffer.readUInt32BE(20);
  let sum = 0; let sum2 = 0; const step = Math.max(1, Math.floor(buffer.length / 4000));
  for (let i = 100; i < buffer.length; i += step) { const v = buffer[i]; sum += v; sum2 += v * v; }
  const n = Math.max(1, Math.ceil((buffer.length - 100) / step));
  return { width, height, bytes: buffer.length, variance: sum2 / n - (sum / n) ** 2 };
}

function unchangedFromBase(relative) {
  try { execFileSync('git', ['diff', '--quiet', base, '--', relative], { cwd: root, stdio: 'ignore' }); return true; } catch { return false; }
}

assert(exists('desktop-spikes/godot-salto/scenes/review/V0335GraniteSourceProof.tscn'), 'isolated v0.335 scene missing');
assert(exists('desktop-spikes/godot-salto/scripts/v0335_granite_source_proof.gd'), 'isolated v0.335 Godot proof script missing');
assert(exists('tools/godot/captureGodotV0335GraniteSourceProofWindows.ps1'), 'v0.335 capture command missing');
assert(exists('tools/godot/generateV0335GraniteSourceProofMaps.py'), 'v0.335 source-map generator missing');
assert(exists('tools/godot/buildV0335GraniteSourceProofPack.py'), 'v0.335 pack builder missing');
assert(exists('art-source/materials/v0335/v0335-source-provenance.json'), 'source provenance record missing');
assert(exists('art-source/materials/v0335/v0335-candidate-metrics.json'), 'candidate metrics record missing');
assert(exists('artifacts/desktop-spikes/godot-salto/v0335/v0335-granite-source-proof-runtime.json'), 'runtime capture manifest missing');
assert(exists('artifacts/manual-review/v0335-granite-source-proof/UPLOAD_TO_CHAT'), 'canonical upload pack missing');

if (exists(v0334Glb)) assert(sha(v0334Glb) === 'f85cf2e7a448015638455f5de5cd49c18b085cbb1103a1fd5dfa8f7706d24be5', 'v0.334 source GLB hash changed');
const importRecordPath = 'artifacts/runtime/v0334/barrosan-house-02-godot-import-record.json';
assert(exists(importRecordPath) && json(importRecordPath).importedResource?.sha256 === 'b3be51e7d6e52fdfb829400afafbf26e9e0f9983b902b8ccba83f38306bba531', 'v0.334 imported resource hash record changed');
for (const frozen of ['art-source/blender/v0334/barrosan_house_gold_02.blend', v0334Glb, 'desktop-spikes/godot-salto/assets/v0334/barrosan_house_gold_02.glb.import', 'artifacts/runtime/v0334/barrosan-house-02-godot-import-record.json']) assert(unchangedFromBase(frozen), `v0.334 frozen file changed: ${frozen}`);
assert(!fs.existsSync(abs('art-source/blender/v0335')), 'complete v0.335 Blender source must not exist');
assert(!fs.readdirSync(abs('desktop-spikes/godot-salto/assets/v0335'), { withFileTypes: true }).some((entry) => entry.name.endsWith('.glb')), 'complete v0.335 House GLB must not exist');

const provenance = json('art-source/materials/v0335/v0335-source-provenance.json');
assert(provenance.license?.includes('CC0'), 'source licence is not explicit CC0');
assert(provenance.sourcePage?.includes('polyhaven.com/a/stone_wall'), 'source page provenance missing');
assert(provenance.originalFiles && Object.keys(provenance.originalFiles).length === 5, 'five original source files not recorded');
assert(exists('art-source/materials/v0335/source/polyhaven_stone_wall_original_2k.zip'), 'vendored source bundle missing');
assert(provenance.vendoredSourceBundleSha256 === sha('art-source/materials/v0335/source/polyhaven_stone_wall_original_2k.zip'), 'vendored source bundle hash mismatch');
for (const file of Object.keys(provenance.originalFiles)) assert(exists(`art-source/materials/v0335/source/polyhaven_stone_wall_original/${file}`) && sha(`art-source/materials/v0335/source/polyhaven_stone_wall_original/${file}`) === provenance.originalFiles[file].sha256, `original source hash mismatch: ${file}`);

const metrics = json('art-source/materials/v0335/v0335-candidate-metrics.json');
assert(metrics.candidates?.length === 3, 'exactly three candidate metric records required');
for (const [index, candidate] of (metrics.candidates || []).entries()) {
  const m = candidate.metrics || {};
  assert(m.visibleStoneCount >= 70 && m.visibleStoneCount <= 180, `candidate ${index + 1} stone count out of range`);
  assert(m.medianStoneHeightM >= 0.16 && m.medianStoneHeightM <= 0.38, `candidate ${index + 1} median stone height out of range`);
  assert(m.p90StoneHeightM <= 0.65, `candidate ${index + 1} p90 stone height out of range`);
  assert(m.stoneAreaCV >= 0.45, `candidate ${index + 1} stone area CV too low`);
  assert(m.highRectangularityShare < 0.25, `candidate ${index + 1} rectangularity too high`);
  assert(m.nonAxisJointShare >= 0.30, `candidate ${index + 1} non-axis joint share too low`);
  assert(m.longestContinuousHorizontalMortarM <= 1.20 && m.maxInternalMortarFraction <= 0.35, `candidate ${index + 1} continuous mortar too long`);
  assert(m.repeatedDimensionShare <= 0.15 && m.maxVerticalJointChain <= 2 && m.mortarWidthCV >= 0.30, `candidate ${index + 1} repetition/joint metrics failed`);
}
const candidateMapFiles = ['albedo', 'height', 'normal', 'roughness'];
const combinedHashes = [];
for (const candidate of ['candidate_a', 'candidate_b', 'candidate_c']) {
  const files = candidateMapFiles.map((name) => {
    const extension = candidate === 'candidate_a' && (name === 'albedo' || name === 'roughness') ? 'jpg' : 'png';
    const relative = `art-source/materials/v0335/candidates/${candidate}/${name}.${extension}`;
    assert(exists(relative), `candidate map missing: ${relative}`);
    return exists(relative) ? sha(relative) : '';
  });
  combinedHashes.push(files.join(':'));
}
assert(new Set(combinedHashes).size === 3, 'candidate source maps are not genuinely distinct');
assert(exists('art-source/materials/v0335/candidates/candidate_b/stone_mask.png'), 'procedural labelled stone mask missing');

const runtime = json('artifacts/desktop-spikes/godot-salto/v0335/v0335-granite-source-proof-runtime.json');
assert(runtime.prototypeOptIn === true && runtime.noCompleteHouseExport === true, 'prototype is not isolated/opt-in');
assert(runtime.testStructure?.principalWallWidthM === 4.0 && runtime.testStructure?.principalWallHeightM === 3.0 && runtime.testStructure?.sideWallLengthM >= 1.5 && runtime.testStructure?.openingRecessed === true && runtime.testStructure?.lintel === true && runtime.testStructure?.sill === true && runtime.testStructure?.foundation === true && runtime.testStructure?.humanHeightM === 1.75, 'real metric test structure contract incomplete');
const script = read('desktop-spikes/godot-salto/scripts/v0335_granite_source_proof.gd');
for (const token of ['Camera3D.PROJECTION_ORTHOGONAL', 'SurfaceTool', 'Window_Recess_Dark', 'Roof_Front_Slope', 'HumanScale_1_75m', 'normal_only.png']) assert(script.includes(token), `required prototype evidence token missing: ${token}`);
for (const forbidden of ['barrosan_house_gold_02.glb', 'move_and_slide', 'NavigationAgent3D', 'Area3D', 'damage', 'projectile']) assert(!script.toLowerCase().includes(forbidden.toLowerCase()), `forbidden runtime/gameplay coupling in prototype script: ${forbidden}`);

const packPath = 'artifacts/manual-review/v0335-granite-source-proof/UPLOAD_TO_CHAT';
const names = fs.readdirSync(abs(packPath)).sort();
assert(JSON.stringify(names) === JSON.stringify([...expectedPack].sort()), `exact canonical ten-file pack mismatch: ${names.join(', ')}`);
if (exists(`${packPath}/compact-evidence-summary.json`)) {
  const summary = json(`${packPath}/compact-evidence-summary.json`);
  assert(summary.checkpoint === 'v0.335' && summary.humanReviewRequired === true && summary.automatedVisualApproval === false && summary.house02Modified === false, 'summary gate mismatch');
  assert(Array.isArray(summary.exactUploadFiles) && !summary.payloadFiles && summary.exactUploadFiles.length === 9, 'summary exactUploadFiles contract mismatch');
  const records = summary.exactUploadFiles;
  for (const record of records) assert(exists(`${packPath}/${record.filename}`) && fs.statSync(abs(`${packPath}/${record.filename}`)).size === record.bytes && sha(`${packPath}/${record.filename}`) === record.sha256, `manifest record mismatch: ${record.filename}`);
  assert(summary.manifestSha256 === crypto.createHash('sha256').update(JSON.stringify(records, null, 0)).digest('hex'), 'manifestSha256 mismatch');
  assert(fs.statSync(abs(`${packPath}/compact-evidence-summary.json`)).size < 250000, 'compact summary exceeds 250KB');
  for (const image of expectedPack.filter((name) => name.endsWith('.png'))) {
    const info = pngInfo(`${packPath}/${image}`);
    assert(info && info.width >= 256 && info.height >= 144 && info.bytes > 1000 && info.variance > 4, `non-rendered or low-variance evidence image: ${image}`);
  }
  const media = abs(`${packPath}/08_CONTINUOUS_V0335_THREE_MATERIAL_TEST.mp4`);
  assert(fs.statSync(media).size > 10000 && fs.readFileSync(media).subarray(4, 8).toString() === 'ftyp', 'continuous MP4 invalid');
}

function finish() {
  if (errors.length) { console.error(JSON.stringify({ status: 'FAIL_V0335_GRANITE_SOURCE_PROOF', base, errors }, null, 2)); process.exit(1); }
  console.log(JSON.stringify({ status: 'PASS_V0335_GRANITE_SOURCE_PROOF', base, checks: 50, humanReviewRequired: true, automatedVisualApproval: false }, null, 2));
}
finish();
