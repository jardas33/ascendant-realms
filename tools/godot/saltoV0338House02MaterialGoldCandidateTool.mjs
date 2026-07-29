import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const base = '24c34723f930d6db5f07a540ae4b12ba91df369e';
const abs = (value) => path.join(root, value);
const exists = (value) => fs.existsSync(abs(value));
const read = (value) => fs.readFileSync(abs(value), 'utf8');
const json = (value) => JSON.parse(read(value));
const sha = (value) => crypto.createHash('sha256').update(fs.readFileSync(abs(value))).digest('hex');
const errors = [];
const assert = (condition, message) => { if (!condition) errors.push(message); };
const pack = 'artifacts/manual-review/v0338-house02-material-gold-candidate/UPLOAD_TO_CHAT';
const expectedPack = [
  '00_READ_ME_FIRST.md', '01_HUMAN_DECISION_AND_DERIVED_LINEAGE.png', '02_FULL_HOUSE_LIGHTING_AND_RTS.png',
  '03_ORTHOGRAPHIC_AND_ARCHITECTURE_PRESERVATION.png', '04_RUBBLE_MORTAR_AND_CORNER_CLOSEUPS.png',
  '05_DRESSED_STONE_FOUNDATION_AND_STAIR.png', '06_SLATE_TIMBER_AND_MATERIAL_HARMONY.png',
  '07_V0337_VERSUS_V0338_MATCHED_COMPARISON.png', '08_CONTINUOUS_V0338_HOUSE02_MATERIAL_GOLD_CANDIDATE.mp4',
  '09_PBR_UV_NORMAL_REPETITION_AND_PERFORMANCE.png', 'compact-evidence-summary.json',
];
const sourceMaps = {
  albedo: 'albedo.jpg', height: 'height.png', normal: 'normal.png', roughness: 'roughness.jpg', ao: 'ao.png',
};
const derivedMaps = [
  'gold_candidate_rubble_albedo.png', 'gold_candidate_rear_albedo.png', 'gold_candidate_gable_albedo.png',
  'gold_candidate_dressed_albedo.png', 'gold_candidate_foundation_albedo.png', 'gold_candidate_normal.png',
  'gold_candidate_roughness.png', 'gold_candidate_height.png', 'gold_candidate_ao.png',
];

function unchangedFromBase(relative) {
  try { execFileSync('git', ['diff', '--quiet', base, '--', relative], { cwd: root, stdio: 'ignore' }); return true; } catch { return false; }
}
function pngInfo(relative) {
  if (!exists(relative)) return null;
  const buffer = fs.readFileSync(abs(relative));
  if (buffer.length < 24 || buffer.readUInt32BE(0) !== 0x89504e47) return null;
  const width = buffer.readUInt32BE(16); const height = buffer.readUInt32BE(20);
  let sum = 0; let sum2 = 0; const step = Math.max(1, Math.floor(buffer.length / 5000));
  for (let i = 100; i < buffer.length; i += step) { const value = buffer[i]; sum += value; sum2 += value * value; }
  const n = Math.max(1, Math.ceil((buffer.length - 100) / step));
  return { width, height, bytes: buffer.length, variance: sum2 / n - (sum / n) ** 2 };
}
function ffprobe(relative) {
  const ffprobePath = 'C:/Users/barro/.cache/codex-runtimes/ffmpeg-v0322/bin/ffprobe.exe';
  return JSON.parse(execFileSync(ffprobePath, ['-v', 'error', '-count_frames', '-show_entries', 'stream=codec_name,width,height,r_frame_rate,duration,nb_read_frames', '-of', 'json', abs(relative)], { encoding: 'utf8' })).streams?.[0] || {};
}

assert(unchangedFromBase('art-source/blender/v0337/barrosan_house_02_selected_granite.blend'), 'frozen v0.337 Blend changed');
assert(unchangedFromBase('desktop-spikes/godot-salto/assets/v0337/barrosan_house_02_selected_granite.glb'), 'frozen v0.337 GLB changed');
assert(sha('art-source/blender/v0337/barrosan_house_02_selected_granite.blend') === '517a9aaa6d9debe2bcf8047de774bdfa252e0376709b2ddafa0c7f9cc72bfe79', 'v0.337 Blend hash mismatch');
assert(sha('desktop-spikes/godot-salto/assets/v0337/barrosan_house_02_selected_granite.glb') === 'ad700395cf0fbc7e396d0f1ef7babff3710f01ce268b34c9720e2d70b24c5dbb', 'v0.337 GLB hash mismatch');

for (const required of [
  'art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend',
  'desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb',
  'art-source/blender/v0338/v0337-v0338-architecture-fingerprint-comparison.json',
  'art-source/materials/v0338/gold_candidate/v0338-material-gold-candidate-lineage.json',
  'desktop-spikes/godot-salto/scenes/review/V0338BarrosanHouse02MaterialGoldCandidateReview.tscn',
  'desktop-spikes/godot-salto/scripts/v0338_barrosan_house_02_material_gold_candidate_review.gd',
  'tools/blender/generateV0338BarrosanHouse02MaterialGoldCandidate.py',
  'tools/godot/calibrateV0338House02MaterialGoldCandidateMaps.py',
  'tools/godot/buildV0338House02MaterialGoldCandidatePack.py',
  'tools/godot/captureGodotV0338House02MaterialGoldCandidateWindows.ps1',
]) assert(exists(required), `required v0.338 file missing: ${required}`);

assert(!exists('art-source/materials/v0338/candidate_b') && !exists('art-source/materials/v0338/candidate_c'), 'v0.338 introduced forbidden candidate_b/c search outputs');
const lineage = exists('art-source/materials/v0338/gold_candidate/v0338-material-gold-candidate-lineage.json') ? json('art-source/materials/v0338/gold_candidate/v0338-material-gold-candidate-lineage.json') : {};
assert(lineage.checkpoint === 'v0.338' && lineage.selectedCandidate === 'candidate_a', 'v0.338 lineage identity mismatch');
assert(lineage.sourceDirectory === 'art-source/materials/v0335/candidates/candidate_a', 'v0.338 source family mismatch');
assert(lineage.textureResolution?.[0] === 2048 && lineage.textureResolution?.[1] === 2048, 'v0.338 maps are not 2048 square');
assert(lineage.normalStrength === 0.42 && lineage.heightParallax?.enabled === false, 'v0.338 normal/height contract mismatch');
assert(lineage.weathering?.mortar?.includes('recessed') && lineage.weathering?.foundation?.includes('coverage'), 'v0.338 weathering contract missing');
for (const [name, source] of Object.entries(sourceMaps)) {
  const relative = `art-source/materials/v0335/candidates/candidate_a/${source}`;
  assert(exists(relative) && lineage.sourceMapHashes?.[name] === sha(relative), `candidate_a source hash mismatch: ${name}`);
}
for (const name of derivedMaps) {
  const source = `art-source/materials/v0338/gold_candidate/${name}`;
  const project = `desktop-spikes/godot-salto/assets/v0338/gold_candidate/${name}`;
  assert(exists(source) && exists(project), `v0.338 derived map missing: ${name}`);
  assert(lineage.maps?.[name.replace(/\.png$/, '')] === sha(source), `v0.338 derived map lineage mismatch: ${name}`);
  assert(sha(source) === sha(project), `v0.338 project map differs: ${name}`);
  const info = pngInfo(source);
  assert(info && info.width === 2048 && info.height === 2048 && info.bytes > 1000, `invalid v0.338 map: ${name}`);
}

const architecture = json('art-source/blender/v0338/v0337-v0338-architecture-fingerprint-comparison.json');
assert(architecture.checkpoint === 'v0.338' && architecture.selectedCandidate === 'candidate_a', 'v0.338 architecture ledger identity mismatch');
assert(architecture.architectureEqualBeforeExport === true && architecture.materialSlotChangesOnly === true, 'v0.338 changed geometry instead of material slots');
assert(architecture.candidateBRejected === true && architecture.candidateCNotSelected === true, 'v0.338 candidate rejection ledger incomplete');
assert(architecture.sourceBlendSha256 === '517a9aaa6d9debe2bcf8047de774bdfa252e0376709b2ddafa0c7f9cc72bfe79' && architecture.sourceGLBSha256 === 'ad700395cf0fbc7e396d0f1ef7babff3710f01ce268b34c9720e2d70b24c5dbb', 'v0.337 frozen lineage mismatch');
assert(architecture.preservation?.defaultRuntimeIntegrated === false && architecture.preservation?.gameplayChanged === false, 'v0.338 isolation preservation flags incomplete');
assert(sha('art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend') === architecture.derivedBlendSha256, 'v0.338 Blend ledger hash mismatch');
assert(sha('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb') === architecture.derivedGLBSha256, 'v0.338 GLB ledger hash mismatch');

const scene = read('desktop-spikes/godot-salto/scenes/review/V0338BarrosanHouse02MaterialGoldCandidateReview.tscn');
const script = read('desktop-spikes/godot-salto/scripts/v0338_barrosan_house_02_material_gold_candidate_review.gd');
assert(scene.includes('V0338BarrosanHouse02MaterialGoldCandidateReview'), 'v0.338 opt-in scene identity missing');
for (const token of ['V0338_GLB', 'V0338_CAPTURE_COUNT := 432', 'V0338_BENCHMARK', 'defaultRuntimeIntegrated', 'orthographic']) assert(script.toLowerCase().includes(token.toLowerCase()), `v0.338 runtime evidence token missing: ${token}`);
for (const forbidden of ['move_and_slide', 'NavigationAgent3D', 'Area3D', 'damage', 'projectile', 'resource_mutation', 'change_pressure', 'save_game']) assert(!script.toLowerCase().includes(forbidden.toLowerCase()), `forbidden gameplay coupling in v0.338 review script: ${forbidden}`);

const runtime = json('artifacts/runtime/v0338/v0338-house02-material-gold-candidate-runtime.json');
assert(runtime.checkpoint === 'v0.338' && runtime.prototypeOptIn === true && runtime.defaultRuntimeIntegrated === false, 'v0.338 runtime isolation gate mismatch');
assert(runtime.selectedCandidate === 'candidate_a' && runtime.candidateBRejected === true && runtime.candidateCNotSelected === true, 'v0.338 runtime selection ledger mismatch');
assert(runtime.noGameplay === true && runtime.noMovement === true && runtime.noPathfinding === true && runtime.noCombat === true && runtime.noEconomy === true && runtime.noResources === true && runtime.noSaves === true && runtime.noStableIDChanges === true, 'v0.338 no-gameplay preservation ledger incomplete');
assert(runtime.continuousFrames === 432 && runtime.videoSeconds === 18.0 && Array.isArray(runtime.captures) && runtime.captures.length === 31 && runtime.errors?.length === 0, 'v0.338 capture manifest incomplete');
for (const capture of runtime.captures) { const info = pngInfo(`artifacts/runtime/v0338/screenshots/${capture.fileName}`); assert(info && info.width === 1280 && info.height === 720 && info.bytes > 10000 && info.variance > 2, `invalid v0.338 capture: ${capture.fileName}`); }
assert(pngInfo('artifacts/runtime/v0338/screenshots/07_256_readability.png')?.width === 256, 'v0.338 256-pixel readability derivative missing');

const diagnostics = json(`${pack}/compact-evidence-summary.json`).normalDiagnostics;
assert(diagnostics?.normalResponsePass === true && diagnostics.meanAbsoluteDifference >= 2 && diagnostics.ssimNormalVsDisabled < 0.995 && diagnostics.clippedWhitePercent < 1 && diagnostics.clippedBlackPercent < 1, 'v0.338 normal-response/clipping diagnostics failed');
const videoPath = `${pack}/08_CONTINUOUS_V0338_HOUSE02_MATERIAL_GOLD_CANDIDATE.mp4`;
try { const stream = ffprobe(videoPath); assert(stream.codec_name === 'h264' && stream.width === 1280 && stream.height === 720 && stream.r_frame_rate === '24/1' && Number(stream.nb_read_frames) === 432, 'v0.338 video codec/dimensions/fps/frame count mismatch'); assert(Number(stream.duration) >= 17.8 && Number(stream.duration) <= 18.2, 'v0.338 video duration mismatch'); } catch (error) { errors.push(`v0.338 ffprobe failed: ${error.message}`); }

const names = exists(pack) ? fs.readdirSync(abs(pack)).sort() : [];
assert(JSON.stringify(names) === JSON.stringify([...expectedPack].sort()), `v0.338 pack named-file set mismatch: ${names.join(', ')}`);
if (exists(`${pack}/compact-evidence-summary.json`)) {
  const summary = json(`${pack}/compact-evidence-summary.json`);
  assert(summary.checkpoint === 'v0.338' && summary.humanReviewRequired === true && summary.automatedVisualApproval === false, 'v0.338 compact summary gate mismatch');
  assert(summary.selectedSource?.candidate === 'candidate_a' && summary.selectedSource?.label === 'Material 3', 'v0.338 compact selected-source identity mismatch');
  assert(summary.architectureComparison?.includes('architecture-fingerprint-comparison') && summary.defaultRuntimeIntegrated === false, 'v0.338 compact architecture/default-runtime gate mismatch');
  assert(summary.video?.codec === 'h264' && summary.video?.decodedFrames === 432 && summary.video?.allNonBlank === true && summary.video?.frozenAdjacentFrames === 0, 'v0.338 compact video integrity gate mismatch');
  assert(summary.captures?.count === 31 && Array.isArray(summary.captures?.errors) && summary.captures.errors.length === 0, 'v0.338 compact capture count/error mismatch');
  assert(Array.isArray(summary.exactUploadFiles) && summary.exactUploadFiles.length === 10, 'v0.338 compact upload manifest must cover the ten non-summary files');
  for (const record of summary.exactUploadFiles) assert(exists(`${pack}/${record.path}`) && fs.statSync(abs(`${pack}/${record.path}`)).size === record.bytes && sha(`${pack}/${record.path}`) === record.sha256, `v0.338 pack manifest mismatch: ${record.path}`);
  assert(fs.statSync(abs(`${pack}/compact-evidence-summary.json`)).size < 250000, 'v0.338 compact summary exceeds 250KB');
  for (const name of expectedPack.filter((item) => item.endsWith('.png'))) { const info = pngInfo(`${pack}/${name}`); assert(info && info.width >= 256 && info.height >= 144 && info.bytes > 1000 && info.variance > 2, `v0.338 pack image invalid/low variance: ${name}`); }
  assert(fs.statSync(abs(videoPath)).size > 100000, 'v0.338 pack video too small');
}

const packageText = read('package.json');
assert(packageText.includes('godot:validate:salto-v0338-house-02-material-gold-candidate'), 'dedicated v0.338 validator package command missing');
assert(packageText.includes('godot:capture:salto-v0338-house-02-material-gold-candidate'), 'dedicated v0.338 capture package command missing');
assert(packageText.includes('godot:pack:salto-v0338-house-02-material-gold-candidate'), 'dedicated v0.338 pack package command missing');

if (errors.length) {
  console.error(JSON.stringify({ status: 'FAIL_V0338_HOUSE02_MATERIAL_GOLD_CANDIDATE', base, errors }, null, 2));
  process.exit(1);
}
console.log(JSON.stringify({ status: 'PASS_V0338_HOUSE02_MATERIAL_GOLD_CANDIDATE', base, checks: 76, outcome: 'READY FOR HUMAN HOUSE 02 GOLD-CANDIDATE MATERIAL REVIEW', humanReviewRequired: true, automatedVisualApproval: false }, null, 2));
