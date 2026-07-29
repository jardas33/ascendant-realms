import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const base = '0e5c998b7f3c0a709ade35159422923bcb2eecfe';
const abs = (value) => path.join(root, value);
const exists = (value) => fs.existsSync(abs(value));
const read = (value) => fs.readFileSync(abs(value), 'utf8');
const json = (value) => JSON.parse(read(value));
const sha = (value) => crypto.createHash('sha256').update(fs.readFileSync(abs(value))).digest('hex');
const errors = [];
const assert = (condition, message) => { if (!condition) errors.push(message); };
const pack = 'artifacts/manual-review/v0337-house02-selected-granite-application/UPLOAD_TO_CHAT';
const expectedPack = ['00_READ_ME_FIRST.md', '01_SELECTION_AND_SOURCE_LINEAGE.png', '02_FULL_HOUSE_NORMAL_RTS_AND_NEAR.png', '03_ORTHOGRAPHIC_AND_ARCHITECTURE_PRESERVATION.png', '04_GRANITE_MATERIAL_CLOSEUPS.png', '05_V0334_VERSUS_V0337_MATCHED_COMPARISON.png', '06_LIGHTING_COLOUR_AND_READABILITY.png', '07_PBR_UV_NORMAL_AND_REPETITION_EVIDENCE.png', '08_CONTINUOUS_V0337_HOUSE02_SELECTED_GRANITE.mp4', 'compact-evidence-summary.json'];
const sourceBlend = 'art-source/blender/v0334/barrosan_house_gold_02.blend';
const sourceGlb = 'desktop-spikes/godot-salto/assets/v0334/barrosan_house_gold_02.glb';

function unchangedFromBase(relative) {
  try { execFileSync('git', ['diff', '--quiet', base, '--', relative], { cwd: root, stdio: 'ignore' }); return true; } catch { return false; }
}
function pngInfo(relative) {
  const buffer = fs.readFileSync(abs(relative));
  if (buffer.readUInt32BE(0) !== 0x89504e47) return null;
  const width = buffer.readUInt32BE(16); const height = buffer.readUInt32BE(20);
  let sum = 0; let sum2 = 0; const step = Math.max(1, Math.floor(buffer.length / 5000));
  for (let i = 100; i < buffer.length; i += step) { const value = buffer[i]; sum += value; sum2 += value * value; }
  const n = Math.max(1, Math.ceil((buffer.length - 100) / step));
  return { width, height, bytes: buffer.length, variance: sum2 / n - (sum / n) ** 2 };
}
function ffprobe(relative) {
  const ffprobePath = 'C:/Users/barro/.cache/codex-runtimes/ffmpeg-v0322/bin/ffprobe.exe';
  return JSON.parse(execFileSync(ffprobePath, ['-v', 'error', '-count_frames', '-show_entries', 'stream=width,height,r_frame_rate,duration,nb_read_frames', '-of', 'json', abs(relative)], { encoding: 'utf8' })).streams?.[0] || {};
}

assert(unchangedFromBase(sourceBlend), 'frozen v0.334 Blender source changed');
assert(unchangedFromBase(sourceGlb), 'frozen v0.334 GLB changed');
assert(unchangedFromBase('desktop-spikes/godot-salto/assets/v0334/barrosan_house_gold_02.glb.import'), 'frozen v0.334 import record changed');
assert(unchangedFromBase('artifacts/runtime/v0334/barrosan-house-02-godot-import-record.json'), 'frozen v0.334 imported-resource evidence changed');
assert(sha(sourceGlb) === 'f85cf2e7a448015638455f5de5cd49c18b085cbb1103a1fd5dfa8f7706d24be5', 'frozen v0.334 GLB hash mismatch');

for (const required of [
  'art-source/blender/v0337/barrosan_house_02_selected_granite.blend',
  'desktop-spikes/godot-salto/assets/v0337/barrosan_house_02_selected_granite.glb',
  'art-source/blender/v0337/v0337-architecture-fingerprint-comparison.json',
  'desktop-spikes/godot-salto/scenes/review/V0337BarrosanHouse02SelectedGraniteReview.tscn',
  'desktop-spikes/godot-salto/scripts/v0337_barrosan_house_02_selected_granite_review.gd',
  'tools/blender/generateV0337BarrosanHouse02SelectedGranite.py',
  'tools/godot/calibrateV0337House02GraniteMaps.py',
  'tools/godot/buildV0337House02SelectedGranitePack.py',
  'tools/godot/captureGodotV0337House02SelectedGraniteWindows.ps1',
]) assert(exists(required), `required v0.337 file missing: ${required}`);

const lineage = exists('art-source/materials/v0337/selected_granite/v0337-selected-granite-lineage.json') ? json('art-source/materials/v0337/selected_granite/v0337-selected-granite-lineage.json') : {};
assert(lineage.selectedCandidate === 'candidate_a', 'selected source is not candidate_a');
assert(lineage.sourceDirectory === 'art-source/materials/v0335/candidates/candidate_a', 'selected source directory mismatch');
for (const [name, source] of Object.entries({ albedo: 'albedo.jpg', height: 'height.png', normal: 'normal.png', roughness: 'roughness.jpg', ao: 'ao.png' })) {
  const relative = `art-source/materials/v0335/candidates/candidate_a/${source}`;
  assert(exists(relative) && lineage.sourceMapHashes?.[name] === sha(relative), `candidate_a source hash mismatch: ${name}`);
}
for (const name of ['selected_granite_albedo.png', 'selected_granite_dressed_albedo.png', 'selected_granite_foundation_albedo.png', 'selected_granite_normal.png', 'selected_granite_roughness.png', 'selected_granite_height.png', 'selected_granite_ao.png']) {
  const relative = `art-source/materials/v0337/selected_granite/${name}`;
  assert(exists(relative) && lineage.calibratedMapHashes?.[name.replace(/\.png$/, '')] === sha(relative), `calibrated selected map hash mismatch: ${name}`);
  assert(exists(`desktop-spikes/godot-salto/assets/v0337/selected_granite/${name}`) && sha(relative) === sha(`desktop-spikes/godot-salto/assets/v0337/selected_granite/${name}`), `project selected map differs: ${name}`);
}
assert(lineage.textureResolution?.[0] === 2048 && lineage.textureResolution?.[1] === 2048, 'selected maps are not 2048 square');
assert(lineage.heightParallax?.enabled === false && lineage.normalStrength === 0.42, 'normal/height calibration contract changed');

const architecture = json('art-source/blender/v0337/v0337-architecture-fingerprint-comparison.json');
assert(architecture.checkpoint === 'v0.337' && architecture.selectedCandidate === 'candidate_a', 'architecture ledger identity mismatch');
assert(architecture.materialSlotChangesOnly === true && architecture.architectureEqualBeforeExport === true, 'derived asset is not a material-slot-only architecture-preserving export');
assert(architecture.preservation?.architecture && architecture.preservation?.roof && architecture.preservation?.chimney && architecture.preservation?.stairLanding && architecture.preservation?.openings, 'frozen House 02 architecture preservation flags incomplete');
assert(architecture.preservation?.defaultRuntimeIntegrated === false && architecture.preservation?.gameplayChanged === false, 'v0.337 is not isolated from runtime/gameplay');
assert(sha('art-source/blender/v0337/barrosan_house_02_selected_granite.blend') === architecture.derivedBlendSha256, 'derived Blend hash mismatch');
assert(sha('desktop-spikes/godot-salto/assets/v0337/barrosan_house_02_selected_granite.glb') === architecture.derivedGLBSha256, 'derived GLB hash mismatch');
assert(architecture.materialBindings?.slatePreserved === 'V0334_Weathered_Slate', 'slate preservation binding missing');
assert(architecture.wallUV?.texelDensityTarget?.includes('220..240'), 'wall UV / texel-density contract missing');

const runtime = json('artifacts/runtime/v0337/v0337-house02-selected-granite-runtime.json');
assert(runtime.prototypeOptIn === true && runtime.defaultRuntimeIntegrated === false && runtime.humanReviewRequired === true && runtime.automatedVisualApproval === false, 'runtime isolation/review gate mismatch');
assert(runtime.selectedCandidate === 'candidate_a' && runtime.candidateBRejected === true && runtime.candidateCNotSelected === true && runtime.noMaterial1Relief === true, 'candidate selection/rejection ledger mismatch');
for (const forbidden of ['move_and_slide', 'NavigationAgent3D', 'Area3D', 'damage', 'projectile', 'resource_mutation']) {
  const script = read('desktop-spikes/godot-salto/scripts/v0337_barrosan_house_02_selected_granite_review.gd').toLowerCase();
  assert(!script.includes(forbidden.toLowerCase()), `forbidden gameplay coupling in isolated v0.337 script: ${forbidden}`);
}
const v337Script = read('desktop-spikes/godot-salto/scripts/v0337_barrosan_house_02_selected_granite_review.gd');
const inheritedScript = read('desktop-spikes/godot-salto/scripts/v0331_barrosan_house_02_review.gd');
for (const token of ['V0337_GLB', 'V0337_NORMAL', 'V0337_CAPTURE_COUNT := 360', 'v0337-house02-selected-granite-runtime.json', 'defaultRuntimeIntegrated']) assert(v337Script.includes(token), `v0.337 runtime evidence token missing: ${token}`);
assert(inheritedScript.includes('PROJECTION_ORTHOGONAL') || inheritedScript.includes('camera.projection'), 'v0.337 inherited orthographic camera contract missing');
const sceneText = read('desktop-spikes/godot-salto/scenes/review/V0337BarrosanHouse02SelectedGraniteReview.tscn');
assert(sceneText.includes('V0337BarrosanHouse02SelectedGraniteReview'), 'opt-in v0.337 scene identity missing');

for (const name of ['01_normal_rts.png', '02_near_front_three_quarter.png', '03_near_rear_three_quarter.png', '09_direct_top_down.png', '15_front_wall_material_closeup.png', '19_normal_only.png', '20_normal_disabled.png', '23_uv_checker_front_rear.png', '25_v0334_v0337_matched_normal_rts.png']) {
  const info = pngInfo(`artifacts/runtime/v0337/screenshots/${name}`);
  assert(info && info.width === 1280 && info.height === 720 && info.bytes > 10000 && info.variance > 2, `invalid/blank v0.337 capture: ${name}`);
}
const diagnostics = json(`${pack}/compact-evidence-summary.json`).normalDiagnostics;
assert(diagnostics?.normalResponsePass === true && diagnostics.meanAbsoluteDifference >= 2 && diagnostics.ssimNormalVsDisabled < 0.995 && diagnostics.clippedWhitePercent < 1, 'normal-response diagnostics failed');

assert(exists('artifacts/runtime/v0337/08_CONTINUOUS_V0337_HOUSE02_SELECTED_GRANITE.mp4'), 'v0.337 continuous MP4 missing');
try {
  const stream = ffprobe('artifacts/runtime/v0337/08_CONTINUOUS_V0337_HOUSE02_SELECTED_GRANITE.mp4');
  assert(stream.width === 1280 && stream.height === 720 && stream.r_frame_rate === '24/1' && Number(stream.nb_read_frames) === 360, 'v0.337 video dimensions/fps/frame count mismatch');
  assert(Number(stream.duration) >= 14.7 && Number(stream.duration) <= 15.3, 'v0.337 video duration mismatch');
} catch (error) { errors.push(`v0.337 ffprobe failed: ${error.message}`); }

const names = exists(pack) ? fs.readdirSync(abs(pack)).sort() : [];
assert(JSON.stringify(names) === JSON.stringify([...expectedPack].sort()), `canonical v0.337 pack must contain exactly ten files: ${names.join(', ')}`);
if (exists(`${pack}/compact-evidence-summary.json`)) {
  const summary = json(`${pack}/compact-evidence-summary.json`);
  assert(summary.checkpoint === 'v0.337' && summary.humanReviewRequired === true && summary.automatedVisualApproval === false, 'compact v0.337 summary gate mismatch');
  assert(summary.selectedSource?.candidate === 'candidate_a' && summary.selectedSource?.label === 'Material 3', 'compact selected-source identity mismatch');
  assert(summary.architecture?.architectureEqualBeforeExport === true && summary.architecture?.defaultRuntimeIntegrated === false, 'compact architecture/default-runtime gate mismatch');
  assert(summary.video?.continuousPass === true && summary.video?.blackFrameRejection?.allNonBlank === true, 'compact video integrity gate mismatch');
  assert(Array.isArray(summary.exactUploadFiles) && summary.exactUploadFiles.length === 9 && !summary.payloadFiles, 'compact exact upload manifest mismatch');
  for (const record of summary.exactUploadFiles) assert(exists(`${pack}/${record.filename}`) && fs.statSync(abs(`${pack}/${record.filename}`)).size === record.bytes && sha(`${pack}/${record.filename}`) === record.sha256, `pack manifest mismatch: ${record.filename}`);
  assert(summary.manifestSha256 === crypto.createHash('sha256').update(JSON.stringify(summary.exactUploadFiles)).digest('hex'), 'pack manifest SHA mismatch');
  assert(fs.statSync(abs(`${pack}/compact-evidence-summary.json`)).size < 250000, 'compact v0.337 summary exceeds 250KB');
  for (const name of expectedPack.filter((item) => item.endsWith('.png'))) { const info = pngInfo(`${pack}/${name}`); assert(info && info.width >= 256 && info.height >= 144 && info.bytes > 1000 && info.variance > 2, `pack image invalid/low variance: ${name}`); }
  assert(fs.statSync(abs(`${pack}/08_CONTINUOUS_V0337_HOUSE02_SELECTED_GRANITE.mp4`)).size > 10000, 'pack video too small');
}

const packageText = read('package.json');
assert(packageText.includes('godot:pack:salto-v0337-house-02-selected-granite'), 'dedicated v0.337 pack command missing');
assert(packageText.includes('godot:validate:salto-v0337-house-02-selected-granite'), 'dedicated v0.337 validator command missing');

if (errors.length) {
  console.error(JSON.stringify({ status: 'FAIL_V0337_HOUSE02_SELECTED_GRANITE', base, errors }, null, 2));
  process.exit(1);
}
console.log(JSON.stringify({ status: 'PASS_V0337_HOUSE02_SELECTED_GRANITE', base, checks: 57, outcome: 'READY FOR HUMAN HOUSE 02 SELECTED-GRANITE APPLICATION REVIEW', humanReviewRequired: true, automatedVisualApproval: false }, null, 2));
