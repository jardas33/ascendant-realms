import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const base = '38545b27a14a5a191b0d66b94f8752e5d0774214';
const abs = (value) => path.join(root, value);
const exists = (value) => fs.existsSync(abs(value));
const read = (value) => fs.readFileSync(abs(value), 'utf8');
const json = (value) => JSON.parse(read(value));
const sha = (value) => crypto.createHash('sha256').update(fs.readFileSync(abs(value))).digest('hex');
const errors = [];
const assert = (condition, message) => { if (!condition) errors.push(message); };
const pack = 'artifacts/manual-review/v0336-granite-evidence-repair/UPLOAD_TO_CHAT';
const expectedPack = ['00_READ_ME_FIRST.md', '01_ACTUAL_RUNTIME_BINDING_LEDGER.png', '02_MATERIAL_1_COMPLETE_EVIDENCE.png', '03_MATERIAL_2_COMPLETE_EVIDENCE.png', '04_MATERIAL_3_COMPLETE_EVIDENCE.png', '05_MATCHED_BLIND_COMPARISON.png', '06_THREE_STONE_MASKS_AND_METRICS.png', '07_ALL_THREE_PBR_SETS_AND_NORMAL_DIAGNOSTICS.png', '08_CONTINUOUS_V0336_THREE_MATERIAL_COMPARISON.mp4', 'compact-evidence-summary.json'];
const frozenGlb = 'desktop-spikes/godot-salto/assets/v0334/barrosan_house_gold_02.glb';
const frozenSource = 'art-source/blender/v0334/barrosan_house_gold_02.blend';
const frozenImport = 'desktop-spikes/godot-salto/assets/v0334/barrosan_house_gold_02.glb.import';
const frozenRecord = 'artifacts/runtime/v0334/barrosan-house-02-godot-import-record.json';
const candidateByMaterial = ['candidate_c', 'candidate_b', 'candidate_a'];
const v0334GlbSha = 'f85cf2e7a448015638455f5de5cd49c18b085cbb1103a1fd5dfa8f7706d24be5';
const v0334ImportSha = 'b3be51e7d6e52fdfb829400afafbf26e9e0f9983b902b8ccba83f38306bba531';

function pngInfo(relative) {
  const buffer = fs.readFileSync(abs(relative));
  if (buffer.readUInt32BE(0) !== 0x89504e47) return null;
  const width = buffer.readUInt32BE(16); const height = buffer.readUInt32BE(20);
  let sum = 0; let sum2 = 0; const step = Math.max(1, Math.floor(buffer.length / 4000));
  for (let i = 100; i < buffer.length; i += step) { const value = buffer[i]; sum += value; sum2 += value * value; }
  const n = Math.max(1, Math.ceil((buffer.length - 100) / step));
  return { width, height, bytes: buffer.length, variance: sum2 / n - (sum / n) ** 2 };
}

function unchangedFromBase(relative) {
  try { execFileSync('git', ['diff', '--quiet', base, '--', relative], { cwd: root, stdio: 'ignore' }); return true; } catch { return false; }
}

assert(exists('desktop-spikes/godot-salto/scenes/review/V0336GraniteEvidenceRepair.tscn'), 'v0.336 isolated scene missing');
assert(exists('desktop-spikes/godot-salto/scripts/v0336_granite_evidence_repair.gd'), 'v0.336 Godot evidence script missing');
assert(exists('tools/godot/captureGodotV0336GraniteEvidenceRepairWindows.ps1'), 'v0.336 capture command missing');
assert(exists('tools/godot/buildV0336GraniteEvidenceRepairPack.py'), 'v0.336 pack builder missing');
assert(exists('artifacts/runtime/v0336/candidate-binding-ledger.json'), 'Godot-generated binding ledger missing');
assert(exists('artifacts/runtime/v0336/matched-camera-ledger.json'), 'matched-camera ledger missing');
assert(exists('artifacts/runtime/v0336/v0336-granite-evidence-runtime.json'), 'runtime capture manifest missing');
assert(exists('artifacts/runtime/v0336/candidate-distinctness.json'), 'candidate distinctness ledger missing');

for (const [file, expected] of [[frozenGlb, v0334GlbSha], [frozenRecord, v0334ImportSha]]) {
  assert(exists(file), `frozen record missing: ${file}`);
  if (exists(file) && file === frozenGlb) assert(sha(file) === expected, 'v0.334 source GLB SHA changed');
  if (exists(file) && file === frozenRecord) assert(json(file).importedResource?.sha256 === expected, 'v0.334 imported resource SHA changed');
}
for (const frozen of [frozenSource, frozenGlb, frozenImport, frozenRecord]) assert(unchangedFromBase(frozen), `v0.334 frozen file changed: ${frozen}`);
assert(!exists('art-source/blender/v0336'), 'complete v0.336 Blender House 02 asset exists');
assert(!fs.readdirSync(abs('desktop-spikes/godot-salto/assets/v0336'), { withFileTypes: true }).some((entry) => entry.name.endsWith('.glb')), 'complete v0.336 House 02 GLB exists');

const runtime = json('artifacts/runtime/v0336/v0336-granite-evidence-runtime.json');
assert(runtime.prototypeOptIn === true && runtime.noHouse02Application === true && runtime.noGameplay === true && runtime.noMovement === true && runtime.noPathfinding === true && runtime.noCombat === true && runtime.noEconomy === true && runtime.noResources === true, 'runtime isolation contract incomplete');
assert(runtime.candidateSets === 3 && runtime.captureCountPerCandidate === 14 && runtime.videoFrames === 432, 'runtime capture count contract incomplete');

const ledger = json('artifacts/runtime/v0336/candidate-binding-ledger.json');
assert(ledger.generatedBy === 'instantiated Godot scene' && ledger.records?.length === 3, 'binding ledger is not runtime-generated or incomplete');
for (const [index, record] of (ledger.records || []).entries()) {
  const expectedLabel = `MATERIAL ${index + 1}`;
  const expectedCandidate = candidateByMaterial[index];
  assert(record.displayedLabel === expectedLabel, `displayed label mismatch at ${expectedLabel}`);
  assert(record.candidateKey === expectedCandidate, `${expectedLabel} candidate mapping mismatch`);
  assert(record.sourceCandidateDirectory?.endsWith(expectedCandidate), `${expectedLabel} source directory mismatch`);
  assert(record.materialOverrideResource === `res://assets/v0336/materials/material_${index + 1}.tres`, `${expectedLabel} material resource mismatch`);
  assert(record.meshInstanceNodePath?.includes('PrincipalWall_Left'), `${expectedLabel} mesh path missing`);
  for (const textureName of ['albedo', 'height', 'normal', 'roughness']) {
    assert(record.textureSha256?.[textureName]?.length === 64, `${expectedLabel} ${textureName} texture hash missing`);
    const extension = textureName === 'albedo' || textureName === 'roughness' ? (expectedCandidate === 'candidate_a' ? 'jpg' : 'png') : 'png';
    const sourceTexture = `art-source/materials/v0335/candidates/${expectedCandidate}/${textureName}.${extension}`;
    assert(exists(sourceTexture) && record.textureSha256?.[textureName] === sha(sourceTexture), `${expectedLabel} ${textureName} texture hash does not match source candidate`);
  }
  const resourceText = read(`desktop-spikes/godot-salto/assets/v0336/materials/material_${index + 1}.tres`);
  assert(resourceText.includes(`candidate_${expectedCandidate.slice(-1)}`), `${expectedLabel} material resource does not bind expected candidate`);
}

const camera = json('artifacts/runtime/v0336/matched-camera-ledger.json');
assert(camera.camera?.projection === 'orthographic' && camera.camera?.viewportWidth === 1280 && camera.camera?.viewportHeight === 720, 'matched orthographic camera contract missing');
assert(camera.matchedAcrossMaterials === true && camera.keyLight?.energy === 0.9 && camera.fillLight?.energy === 0.24, 'matched light contract changed');

for (let index = 1; index <= 3; index += 1) {
  const directory = `artifacts/runtime/v0336/material-${index}`;
  for (const name of ['01_near_corner_window.png', '02_front_material_inspection.png', '03_normal_rts.png', '04_far_rts.png', '05_greyscale_normal_rts.png', '06_thumbnail_256.png', '07_neutral_overcast.png', '08_warm_directional.png', '09_albedo_only.png', '10_normal_only.png', '11_normal_disabled.png', '12_roughness_isolation.png', '13_top_down.png', '14_side_view.png']) {
    assert(exists(`${directory}/${name}`), `candidate-specific capture missing: ${directory}/${name}`);
    if (exists(`${directory}/${name}`)) { const info = pngInfo(`${directory}/${name}`); assert(info && info.bytes > 1000 && info.variance > 2, `blank/low-variance candidate capture: ${directory}/${name}`); }
  }
  const names = fs.readdirSync(abs(directory)).filter((name) => name.endsWith('.png'));
  assert(names.length === 14, `candidate ${index} has extra/missing captures`);
}
for (const name of ['01_near_corner_window.png', '03_normal_rts.png', '04_far_rts.png']) {
  const hashes = [1, 2, 3].map((index) => sha(`artifacts/runtime/v0336/material-${index}/${name}`));
  assert(new Set(hashes).size === 3, `candidate images reused or identical: ${name}`);
}

const masks = ['artifacts/runtime/v0336/stone-masks/material-1-source-stone-mask.png', 'artifacts/runtime/v0336/stone-masks/material-1-authored-relief-selection-mask.png', 'artifacts/runtime/v0336/stone-masks/material-2-authored-polygon-mask.png', 'artifacts/runtime/v0336/stone-masks/material-3-source-stone-mask.png'];
for (const mask of masks) assert(exists(mask) && pngInfo(mask)?.variance > 2, `labelled stone mask missing/blank: ${mask}`);
assert(exists('artifacts/runtime/v0336/normal-only-diagnostics.json'), 'normal-only diagnostics missing');
const diagnostics = json('artifacts/runtime/v0336/normal-only-diagnostics.json');
for (const key of ['material1', 'material2', 'material3']) {
  const diagnostic = diagnostics[key];
  assert(diagnostic && diagnostic.luminanceStdDev > 1 && diagnostic.clippedWhitePercent <= 2, `normal-only diagnostic failed: ${key}`);
  assert(diagnostic.differenceFromNormalDisabled > 0.5, `normal-only does not differ from disabled render: ${key}`);
}
if (exists('artifacts/runtime/v0336/candidate-distinctness.json')) {
  const distinctness = json('artifacts/runtime/v0336/candidate-distinctness.json');
  assert(distinctness.pairs?.length === 3, 'all three candidate pairs are not measured');
  for (const pair of distinctness.pairs || []) {
    assert(pair.materialResourceDifferent === true, `material resources are not distinct: ${pair.pair}`);
    assert(pair.renderedNearViewSSIM < 0.99999 && pair.renderedNormalRtsSSIM < 0.99999, `rendered candidate pair is functionally identical: ${pair.pair}`);
    for (const mapName of ['albedo', 'height', 'normal', 'roughness']) assert(pair.mapDifferences?.[mapName]?.meanAbsoluteDifference >= 0 || pair.mapDifferences?.[mapName]?.leftSha256 !== pair.mapDifferences?.[mapName]?.rightSha256, `map difference missing: ${pair.pair}/${mapName}`);
  }
  assert(distinctness.hybrid?.reliefMeshName === 'HybridMergedLimitedRelief' && distinctness.hybrid?.mergedObjectCount === 1 && distinctness.hybrid?.reliefTriangleCount === 84, 'hybrid relief proof incomplete');
}

assert(exists('artifacts/runtime/v0336/08_CONTINUOUS_V0336_THREE_MATERIAL_COMPARISON.mp4'), 'v0.336 video missing');
if (exists('artifacts/runtime/v0336/08_CONTINUOUS_V0336_THREE_MATERIAL_COMPARISON.mp4')) {
  try {
    const ffprobe = 'C:/Users/barro/.cache/codex-runtimes/ffmpeg-v0322/bin/ffprobe.exe';
    const probe = JSON.parse(execFileSync(ffprobe, ['-v', 'error', '-count_frames', '-show_entries', 'stream=width,height,r_frame_rate,duration,nb_read_frames', '-of', 'json', abs('artifacts/runtime/v0336/08_CONTINUOUS_V0336_THREE_MATERIAL_COMPARISON.mp4')], { encoding: 'utf8' }));
    const stream = probe.streams?.[0] || {};
    assert(stream.width === 1280 && stream.height === 720 && stream.r_frame_rate === '24/1' && Number(stream.nb_read_frames) === 432, 'v0.336 video dimensions/fps/frame count mismatch');
    assert(Number(stream.duration) >= 17.8 && Number(stream.duration) <= 18.2, 'v0.336 video duration mismatch');
  } catch (error) { errors.push(`ffprobe failed: ${error.message}`); }
}
assert(exists('artifacts/runtime/v0336/video-frame-comparisons.json'), 'equivalent-frame video comparison missing');
if (exists('artifacts/runtime/v0336/video-frame-comparisons.json')) assert(json('artifacts/runtime/v0336/video-frame-comparisons.json').equivalentFramePairs?.every((pair) => pair.meanAbsoluteDifferenceM1M2 > 1), 'equivalent video frames are not distinct');

const packNames = exists(pack) ? fs.readdirSync(abs(pack)).sort() : [];
assert(JSON.stringify(packNames) === JSON.stringify([...expectedPack].sort()), `canonical v0.336 pack must contain exactly ten files: ${packNames.join(', ')}`);
if (exists(`${pack}/compact-evidence-summary.json`)) {
  const summary = json(`${pack}/compact-evidence-summary.json`);
  assert(summary.checkpoint === 'v0.336' && summary.humanReviewRequired === true && summary.automatedVisualApproval === false && summary.house02Modified === false, 'compact summary gate mismatch');
  assert(summary.recoveredCandidateBlindMapping?.['MATERIAL 1'] === 'candidate_c' && summary.recoveredCandidateBlindMapping?.['MATERIAL 2'] === 'candidate_b' && summary.recoveredCandidateBlindMapping?.['MATERIAL 3'] === 'candidate_a', 'corrected compact mapping missing');
  assert(summary.exactUploadFiles?.length === 9 && !summary.payloadFiles, 'exactUploadFiles contract mismatch');
  for (const record of summary.exactUploadFiles || []) assert(exists(`${pack}/${record.filename}`) && fs.statSync(abs(`${pack}/${record.filename}`)).size === record.bytes && sha(`${pack}/${record.filename}`) === record.sha256, `pack manifest mismatch: ${record.filename}`);
  assert(summary.manifestSha256 === crypto.createHash('sha256').update(JSON.stringify(summary.exactUploadFiles, null, 0)).digest('hex'), 'pack manifest SHA mismatch');
  assert(fs.statSync(abs(`${pack}/compact-evidence-summary.json`)).size < 250000, 'compact summary exceeds 250KB');
  for (const file of expectedPack.filter((name) => name.endsWith('.png'))) { const info = pngInfo(`${pack}/${file}`); assert(info && info.width >= 256 && info.height >= 144 && info.bytes > 1000 && info.variance > 2, `pack evidence image invalid: ${file}`); }
  assert(fs.statSync(abs(`${pack}/08_CONTINUOUS_V0336_THREE_MATERIAL_COMPARISON.mp4`)).size > 10000, 'pack video too small');
}

const script = read('desktop-spikes/godot-salto/scripts/v0336_granite_evidence_repair.gd');
for (const token of ['Label3D', 'MATERIAL 1', 'MATERIAL 2', 'MATERIAL 3', 'PROJECTION_ORTHOGONAL', 'candidate-binding-ledger.json', 'VIDEO_FRAMES := 432']) assert(script.includes(token), `required v0.336 runtime token missing: ${token}`);
for (const forbidden of ['barrosan_house_gold_02.glb', 'move_and_slide', 'NavigationAgent3D', 'Area3D', 'damage', 'projectile']) assert(!script.toLowerCase().includes(forbidden.toLowerCase()), `forbidden House/gameplay coupling: ${forbidden}`);

if (errors.length) { console.error(JSON.stringify({ status: 'FAIL_V0336_GRANITE_EVIDENCE_REPAIR', base, errors }, null, 2)); process.exit(1); }
console.log(JSON.stringify({ status: 'PASS_V0336_GRANITE_EVIDENCE_REPAIR', base, checks: 62, outcome: 'READY FOR HUMAN FINAL GRANITE CANDIDATE SELECTION', humanReviewRequired: true, automatedVisualApproval: false }, null, 2));
