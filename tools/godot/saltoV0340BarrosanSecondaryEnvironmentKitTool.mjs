import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const base = '471d17cd3ca9a5f124bc18128f0175b3d4616da7';
const abs = (value) => path.join(root, value);
const exists = (value) => fs.existsSync(abs(value));
const read = (value) => fs.readFileSync(abs(value), 'utf8');
const json = (value) => JSON.parse(read(value));
const sha = (value) => crypto.createHash('sha256').update(fs.readFileSync(abs(value))).digest('hex');
const errors = [];
const assert = (condition, message) => { if (!condition) errors.push(message); };
const runtime = 'artifacts/runtime/v0340';
const pack = 'artifacts/manual-review/v0340-barrosan-secondary-environment-kit/UPLOAD_TO_CHAT';
const full = 'artifacts/manual-review/v0340-barrosan-secondary-environment-kit/full-evidence';
const expectedPack = [
  '00_READ_ME_FIRST.md', '01_HUMAN_V0339_DECISION_AND_FROZEN_HOUSE02.png', '02_PRIMARY_PLAYER_ENVIRONMENT_KIT.png',
  '03_BARN_AND_SHED_ARCHITECTURE.png', '04_DRY_STONE_WALL_KIT.png', '05_TERRAIN_ROADS_AND_PATHS.png',
  '06_WATER_CROSSING_TROUGH_AND_BANKS.png', '07_VEGETATION_SCALE_AND_MATERIAL_HARMONY.png',
  '08_CONTINUOUS_V0340_BARROSAN_ENVIRONMENT_KIT.mp4', '09_PBR_UV_LOD_COLLISION_AND_PERFORMANCE.png', 'compact-evidence-summary.json',
];
const frozenBlend = '3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6';
const frozenGlb = 'ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89';
const unchangedFromBase = (relative) => {
  try { execFileSync('git', ['diff', '--quiet', base, '--', relative], { cwd: root, stdio: 'ignore' }); return true; }
  catch { return false; }
};
const pngInfo = (relative) => {
  if (!exists(relative)) return null;
  const b = fs.readFileSync(abs(relative));
  if (b.length < 24 || b.readUInt32BE(0) !== 0x89504e47) return null;
  const w = b.readUInt32BE(16), h = b.readUInt32BE(20);
  let sum = 0, sum2 = 0, n = 0;
  for (let i = 100; i < b.length; i += Math.max(1, Math.floor(b.length / 4000))) { const v = b[i]; sum += v; sum2 += v * v; n++; }
  return { width: w, height: h, bytes: b.length, variance: sum2 / n - (sum / n) ** 2 };
};
const ffprobe = (relative) => JSON.parse(execFileSync('C:/Users/barro/.cache/codex-runtimes/ffmpeg-v0322/bin/ffprobe.exe', ['-v', 'error', '-count_frames', '-show_entries', 'stream=codec_name,width,height,r_frame_rate,duration,nb_read_frames', '-of', 'json', abs(relative)], { encoding: 'utf8' })).streams?.[0] || {};

assert(unchangedFromBase('art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend'), 'frozen v0.338 Blend changed');
assert(unchangedFromBase('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb'), 'frozen v0.338 GLB changed');
assert(sha('art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend') === frozenBlend, 'frozen v0.338 Blend hash mismatch');
assert(sha('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb') === frozenGlb, 'frozen v0.338 GLB hash mismatch');
for (const file of [
  'art-source/blender/v0340/barrosan_secondary_environment_kit.blend',
  'desktop-spikes/godot-salto/assets/v0340/barrosan_secondary_environment_kit.glb',
  'desktop-spikes/godot-salto/scenes/review/V0340BarrosanSecondaryEnvironmentKitReview.tscn',
  'desktop-spikes/godot-salto/scripts/v0340_barrosan_secondary_environment_kit_review.gd',
  'tools/blender/generateV0340BarrosanSecondaryEnvironmentKit.py',
  'tools/godot/captureGodotV0340BarrosanSecondaryEnvironmentKitWindows.ps1',
  'tools/godot/buildV0340BarrosanSecondaryEnvironmentKitPack.py',
]) assert(exists(file), `required v0.340 file missing: ${file}`);

const scene = exists('desktop-spikes/godot-salto/scenes/review/V0340BarrosanSecondaryEnvironmentKitReview.tscn') ? read('desktop-spikes/godot-salto/scenes/review/V0340BarrosanSecondaryEnvironmentKitReview.tscn') : '';
const script = exists('desktop-spikes/godot-salto/scripts/v0340_barrosan_secondary_environment_kit_review.gd') ? read('desktop-spikes/godot-salto/scripts/v0340_barrosan_secondary_environment_kit_review.gd') : '';
const generator = exists('tools/blender/generateV0340BarrosanSecondaryEnvironmentKit.py') ? read('tools/blender/generateV0340BarrosanSecondaryEnvironmentKit.py') : '';
for (const token of ['V0340BarrosanSecondaryEnvironmentKitReview', 'V0340_MODE', 'PLAYER', 'DEBUG_REVIEW', 'orthographic', 'V0340_CONTINUOUS_FRAMES := 504', 'V0340DebugReviewTechnicalEvidenceOnly', 'V0340_FrozenHouse02_QualityAnchor_Unmodified']) assert(scene.includes(token) || script.includes(token), `v0.340 contract token missing: ${token}`);
for (const token of ['V0340_Granite_Agricultural_Barn', 'V0340_Timber_Stone_Shed_LeanTo', 'V0340_Wall_', 'V0340_Granite_Trough_Communal_Washing', 'V0340_Rural_Timber_Stone_Crossing', 'V0340_Highland_Vegetation_Kit', 'V0340_Terrain_Truth_Landscape', 'V0340_authored']) assert(generator.toLowerCase().includes(token.toLowerCase()), `authored family token missing: ${token}`);
for (const forbidden of ['move_and_slide', 'NavigationAgent3D', 'damage', 'projectile', 'change_pressure', 'save_game', 'queue_free', 'NavigationServer']) assert(!script.toLowerCase().includes(forbidden.toLowerCase()), `forbidden gameplay coupling in v0.340 script: ${forbidden}`);

const manifestPath = `${runtime}/v0340-barrosan-secondary-environment-kit-runtime.json`;
assert(exists(manifestPath), 'v0.340 runtime manifest missing');
let manifest = {};
if (exists(manifestPath)) {
  manifest = json(manifestPath);
  assert(manifest.checkpoint === 'v0.340' && manifest.prototypeOptIn === true && manifest.prototypeOnly === true && manifest.defaultRuntimeIntegrated === false, 'v0.340 opt-in/default-runtime contract failed');
  assert(manifest.house02Modified === false && manifest.frozenV0338BlendSha256 === frozenBlend && manifest.frozenV0338GLBSha256 === frozenGlb, 'frozen House 02 ledger failed');
  assert(manifest.captureCount === 42 && manifest.continuousFrames === 504 && manifest.videoSeconds === 21, 'capture/video count contract failed');
  assert(manifest.errors?.length === 0, 'v0.340 runtime manifest has errors');
  assert(manifest.camera?.projection === 'orthographic' && manifest.camera?.oblique === true && manifest.camera?.directTopDown === true, 'camera contract failed');
  assert(manifest.terrain?.elevationDifferenceMeters === 1.8 && manifest.terrain?.valley === true && manifest.terrain?.raisedAgriculturalEdge === true && manifest.terrain?.hardBoundaryHidden === true, 'terrain truth contract failed');
  assert(manifest.water?.belowBanks === true && manifest.water?.nonRectangular === true && manifest.water?.crossingSeated === true, 'water/bank contract failed');
  assert(manifest.road?.connected === true && manifest.road?.crowned === true, 'road integration contract failed');
  assert(manifest.LOD?.lod0 && manifest.LOD?.lod1 && manifest.LOD?.lod2 && manifest.LOD?.collisionSimpler, 'LOD contract failed');
  assert(manifest.UV?.overlap === false && manifest.UV?.mirroredNormals === false, 'UV/normals contract failed');
  assert(manifest.noGameplay && manifest.noMovement && manifest.noPathfinding && manifest.noCombat && manifest.noAI && manifest.noEconomy && manifest.noResources && manifest.noPressureMutation && manifest.noSaves && manifest.noStableIDChanges, 'preservation ledger incomplete');
}

const captures = (manifest.captures || []).map((item) => item.file);
assert(captures.length === 42, `manifest capture list expected 42, got ${captures.length}`);
for (const file of captures) {
  const info = pngInfo(`${runtime}/screenshots/${file}`);
  assert(info && info.width >= 1280 && info.height >= 720 && info.bytes > 10000 && info.variance > 2, `invalid v0.340 capture: ${file}`);
  assert(exists(`${full}/${file}`), `full evidence missing: ${file}`);
}
assert(pngInfo(`${runtime}/screenshots/06_256_readability.png`)?.width === 256, '256px readability derivative missing');

const video = `${pack}/08_CONTINUOUS_V0340_BARROSAN_ENVIRONMENT_KIT.mp4`;
if (exists(video)) {
  try {
    const s = ffprobe(video);
    assert(s.codec_name === 'h264' && s.width === 1280 && s.height === 720 && s.r_frame_rate === '24/1' && Number(s.nb_read_frames) === 504, 'v0.340 video codec/dimensions/fps/frame count mismatch');
    assert(Number(s.duration) >= 20.8 && Number(s.duration) <= 21.2, 'v0.340 video duration mismatch');
  } catch (error) { errors.push(`v0.340 ffprobe failed: ${error.message}`); }
} else errors.push('v0.340 exact upload video missing');
const names = exists(pack) ? fs.readdirSync(abs(pack)).filter((name) => fs.statSync(abs(`${pack}/${name}`)).isFile()).sort() : [];
assert(JSON.stringify(names) === JSON.stringify([...expectedPack].sort()), `v0.340 exact upload pack mismatch: ${names.join(',')}`);
if (exists(`${pack}/compact-evidence-summary.json`)) {
  const summary = json(`${pack}/compact-evidence-summary.json`);
  assert(summary.checkpoint === 'v0.340' && summary.defaultRuntimeIntegrated === false && summary.house02Modified === false, 'v0.340 compact summary gate failed');
  assert(summary.captures?.count === 42 && summary.video?.decodedFrames === 504 && summary.video?.allNonBlank === true, 'compact capture/video evidence incomplete');
  assert(Array.isArray(summary.exactUploadFiles) && summary.exactUploadFiles.length === 10, 'compact upload manifest must cover ten non-summary files');
  for (const record of summary.exactUploadFiles || []) assert(exists(`${pack}/${record.path}`) && fs.statSync(abs(`${pack}/${record.path}`)).size === record.bytes && sha(`${pack}/${record.path}`) === record.sha256, `pack manifest mismatch: ${record.path}`);
  assert(fs.statSync(abs(`${pack}/compact-evidence-summary.json`)).size < 250000, 'compact summary exceeds 250KB');
  for (const file of expectedPack.filter((name) => name.endsWith('.png'))) { const info = pngInfo(`${pack}/${file}`); assert(info && info.width >= 900 && info.height >= 500 && info.bytes > 10000 && info.variance > 2, `upload board invalid/low variance: ${file}`); }
}
const packageText = read('package.json');
for (const token of ['blender:generate:salto-v0340-barrosan-secondary-environment-kit', 'godot:capture:salto-v0340-barrosan-secondary-environment-kit', 'godot:pack:salto-v0340-barrosan-secondary-environment-kit', 'godot:validate:salto-v0340-barrosan-secondary-environment-kit']) assert(packageText.includes(token), `package command missing: ${token}`);

if (errors.length) { console.error(JSON.stringify({ status: 'FAIL_V0340_BARROSAN_SECONDARY_ENVIRONMENT_KIT', base, errors }, null, 2)); process.exit(1); }
console.log(JSON.stringify({ status: 'PASS_V0340_BARROSAN_SECONDARY_ENVIRONMENT_KIT', base, checks: 84, outcome: 'READY FOR HUMAN BARROSAN SECONDARY ENVIRONMENT KIT REVIEW', humanReviewRequired: true, automatedVisualApproval: false }, null, 2));
