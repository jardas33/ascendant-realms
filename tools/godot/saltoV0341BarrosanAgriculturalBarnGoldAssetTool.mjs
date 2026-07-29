import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const base = '6d147d7efb602e87d406d2cdd48915cdda0e6101';
const errors = [];
const abs = (p) => path.join(root, p);
const exists = (p) => fs.existsSync(abs(p));
const read = (p) => fs.readFileSync(abs(p), 'utf8');
const json = (p) => JSON.parse(read(p));
const sha = (p) => crypto.createHash('sha256').update(fs.readFileSync(abs(p))).digest('hex');
const assert = (condition, message) => { if (!condition) errors.push(message); };
const pack = 'artifacts/manual-review/v0341-barrosan-agricultural-barn-gold-asset/UPLOAD_TO_CHAT';
const runtime = 'artifacts/runtime/v0341';
const expectedPack = [
  '00_READ_ME_FIRST.md', '01_HUMAN_V0340_DECISION_AND_DOCUMENTARY_TARGET.png', '02_PRIMARY_PLAYER_AND_HOUSE02_COMPARISON.png',
  '03_ORTHOGRAPHICS_DIMENSIONS_AND_FUNCTION.png', '04_GRANITE_MASONRY_AND_FOUNDATION.png', '05_SLATE_ROOF_TIMBER_AND_OPENINGS.png',
  '06_LIGHTING_RTS_AND_256_READABILITY.png', '07_PBR_UV_WIREFRAME_LOD_COLLISION.png', '08_CONTINUOUS_V0341_BARROSAN_BARN_GOLD_ASSET.mp4', 'compact-evidence-summary.json',
];
const captureNames = [
  '01_human_v0340_rejection_board.png', '02_primary_player_barn.png', '03_house02_barn_matched.png', '04_neutral_overcast.png', '05_cool_daylight.png', '06_warm_directional.png', '07_far_rts.png', '08_256_readability_source.png', '09_greyscale.png', '10_front_orthographic.png', '11_rear_orthographic.png', '12_left_orthographic.png', '13_right_orthographic.png', '14_direct_top_down.png', '15_front_three_quarter_close.png', '16_rear_three_quarter_close.png', '17_lower_entrance.png', '18_upper_loading_opening.png', '19_corner_masonry.png', '20_foundation_contact.png', '21_roof_ridge_eaves.png', '22_roof_verge_underside.png', '23_timber_doors_iron.png', '24_worker_scale.png', '25_normal_enabled.png', '26_normal_disabled.png', '27_albedo_only.png', '28_roughness_isolation.png', '29_height_relief.png', '30_uv_checker.png', '31_blender_wireframe_reference.png', '32_exported_uv_layout_reference.png', '33_lod_comparison.png', '34_isolated_collision.png', '35_exact_dimensions.png', '36_actual_performance_ledger.png', '37_rejected_v0340_vs_v0341_matched.png', '38_documentary_target_comparison.png',
];
const pngInfo = (p) => {
  if (!exists(p)) return null;
  const b = fs.readFileSync(abs(p));
  if (b.length < 24 || b.readUInt32BE(0) !== 0x89504e47) return null;
  const width = b.readUInt32BE(16); const height = b.readUInt32BE(20);
  let sum = 0; let sum2 = 0; const step = Math.max(1, Math.floor(b.length / 6000));
  for (let i = 100; i < b.length; i += step) { sum += b[i]; sum2 += b[i] * b[i]; }
  const n = Math.max(1, Math.ceil((b.length - 100) / step));
  return { width, height, bytes: b.length, variance: sum2 / n - (sum / n) ** 2 };
};
const ffprobe = (p) => {
  const exe = 'C:/Users/barro/.cache/codex-runtimes/ffmpeg-v0322/bin/ffprobe.exe';
  return JSON.parse(execFileSync(exe, ['-v', 'error', '-count_frames', '-show_entries', 'stream=codec_name,width,height,r_frame_rate,duration,nb_read_frames', '-of', 'json', abs(p)], { encoding: 'utf8' })).streams?.[0] || {};
};

assert(exists('art-source/blender/v0341/barrosan_agricultural_barn_gold_asset.blend'), 'v0.341 source Blend missing');
assert(exists('desktop-spikes/godot-salto/assets/v0341/barrosan_agricultural_barn_gold_asset.glb'), 'v0.341 exported GLB missing');
assert(exists('desktop-spikes/godot-salto/scenes/review/V0341BarrosanAgriculturalBarnGoldAssetReview.tscn'), 'v0.341 opt-in scene missing');
assert(exists('desktop-spikes/godot-salto/scripts/v0341_barrosan_agricultural_barn_gold_asset_review.gd'), 'v0.341 review script missing');
assert(exists('tools/blender/generateV0341BarrosanAgriculturalBarnGoldAsset.py'), 'v0.341 Blender generator missing');
assert(exists('tools/godot/captureGodotV0341BarrosanAgriculturalBarnGoldAssetWindows.ps1'), 'v0.341 capture wrapper missing');
assert(exists('tools/godot/buildV0341BarrosanAgriculturalBarnGoldAssetPack.py'), 'v0.341 pack builder missing');
assert(read('desktop-spikes/godot-salto/scenes/review/V0341BarrosanAgriculturalBarnGoldAssetReview.tscn').includes('V0341BarrosanAgriculturalBarnGoldAssetReview'), 'scene identity mismatch');
const script = read('desktop-spikes/godot-salto/scripts/v0341_barrosan_agricultural_barn_gold_asset_review.gd');
assert(script.includes('V0341_BARN_GLB') && script.includes('V0341_CAPTURE_COUNT := 38') && script.includes('V0341_CONTINUOUS_FRAMES := 360'), 'capture/runtime contract missing');
assert(!script.includes('V0340_KIT_GLB') && !script.includes('barrosan_secondary_environment_kit.glb'), 'visible v0.340 environment kit dependency found');
for (const forbidden of ['move_and_slide', 'NavigationAgent3D', 'damage_taken', 'projectile', 'save_game', 'resource_mutation']) assert(!script.toLowerCase().includes(forbidden), `forbidden gameplay coupling: ${forbidden}`);

assert(sha('art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend') === '3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6', 'frozen House 02 Blend hash mismatch');
assert(sha('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb') === 'ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89', 'frozen House 02 GLB hash mismatch');
const source = read('tools/blender/generateV0341BarrosanAgriculturalBarnGoldAsset.py');
for (const token of ['candidate_a', 'irregular', 'Recessed', 'two principal slopes', 'Upper_Hay_Loading', 'Lower_Livestock', 'Weathered_Agricultural_Timber', 'worker_clearance']) assert(source.toLowerCase().includes(token.toLowerCase()), `barn source identity/function token missing: ${token}`);
assert(source.includes('export_scene.gltf') && source.includes('export_format="GLB"'), 'real Blender GLB export contract missing');
for (const texture of ['candidate_a_granite_albedo.png', 'weathered_agricultural_timber_albedo.png', 'charcoal_slate_albedo.png']) assert(exists(`art-source/blender/v0341/textures/${texture}`) && exists(`desktop-spikes/godot-salto/assets/v0341/textures/${texture}`), `texture ledger missing: ${texture}`);

const runtimePath = `${runtime}/v0341-barrosan-agricultural-barn-gold-asset-runtime.json`;
assert(exists(runtimePath) || exists(`${pack}/compact-evidence-summary.json`), 'v0.341 runtime manifest or canonical evidence summary missing');
if (exists(runtimePath)) {
  const m = json(runtimePath);
  assert(m.checkpoint === 'v0.341' && m.prototypeOptIn === true && m.defaultRuntimeIntegrated === false, 'prototype/default-runtime isolation mismatch');
  assert(m.house02Modified === false && m.frozenHouse02BlendSha256 === '3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6' && m.frozenHouse02GLBSha256 === 'ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89', 'frozen House 02 evidence mismatch');
  assert(m.barn?.roofPrincipalSlopes === 2 && m.barn?.lowerFunction && m.barn?.upperFunction, 'barn functional/roof hierarchy incomplete');
  assert(m.barn?.candidateLineage?.includes('candidate_a') && m.barn?.masonry?.includes('recessed'), 'granite candidate lineage/relief incomplete');
  assert(m.terrainContact?.darkDampContact === true && m.terrainContact?.pedestal === false && m.terrainContact?.embeddedGraniteRocks >= 3, 'terrain contact contract incomplete');
  assert(m.workerScale?.referenceHeightMeters === 1.75 && m.workerScale?.clearanceMeters >= 1.75, 'Worker scale/clearance contract incomplete');
  assert(m.metrics?.lod0Triangles > m.metrics?.lod1Triangles && m.metrics?.lod1Triangles > m.metrics?.lod2Triangles && m.metrics?.collisionTriangles > 0, 'LOD/collision metrics invalid');
  assert(m.metrics?.uvOverlap === false && m.metrics?.mirroredNormals === false && m.metrics?.textureCount >= 3 && m.metrics?.drawCalls > 0 && (m.metrics?.visibleTriangles ?? m.performance?.visibleTriangles) > 0, 'UV/texture/performance ledger invalid');
  assert(m.performance?.warmupSeconds >= 5 && m.performance?.measurementSeconds > 0 && m.performance?.sampleCount >= 1000 && m.performance?.visibleTriangles > 0 && m.performance?.drawCalls > 0, 'performance warmup/sample/numeric ledger invalid');
  assert(m.captureCount === 38 && m.continuousFrames === 360 && m.videoSeconds === 15.0 && Array.isArray(m.captures) && m.captures.length === 38 && m.errors?.length === 0, 'capture manifest count/error mismatch');
  const firstCapture = pngInfo(`${runtime}/screenshots/${captureNames[0]}`);
  assert(firstCapture && firstCapture.width >= 1280 && firstCapture.height >= 720, 'real Godot capture resolution below review minimum');
  for (const name of captureNames) { const info = pngInfo(`${runtime}/screenshots/${name}`); assert(info && info.width === firstCapture?.width && info.height === firstCapture?.height && info.bytes > 10000 && info.variance > 2, `invalid real Godot capture: ${name}`); }
}

assert(exists(pack), 'canonical v0.341 upload pack missing');
if (exists(pack)) {
  const names = fs.readdirSync(abs(pack)).sort();
  assert(JSON.stringify(names) === JSON.stringify([...expectedPack].sort()), `canonical pack must contain exactly ten files: ${names.join(', ')}`);
  const summary = exists(`${pack}/compact-evidence-summary.json`) ? json(`${pack}/compact-evidence-summary.json`) : {};
  assert(summary.checkpoint === 'v0.341' && summary.humanReviewRequired === true && summary.automatedVisualApproval === false, 'compact summary gate mismatch');
  assert(summary.defaultRuntimeIntegrated === false && summary.house02Modified === false && summary.prototypeOptIn === true, 'compact isolation summary mismatch');
  assert(summary.captures?.count === 38 && summary.video?.codec === 'h264' && summary.video?.width === 1280 && summary.video?.height === 720 && summary.video?.frameRate === '24/1' && summary.video?.decodedFrames === 360 && summary.video?.allNonBlank === true && summary.video?.frozenAdjacentFrames === 0, 'compact genuine capture/video summary mismatch');
  assert(Array.isArray(summary.exactUploadFiles) && summary.exactUploadFiles.length === 9, 'compact exact-upload ledger must cover nine non-summary files');
  for (const record of summary.exactUploadFiles || []) assert(exists(`${pack}/${record.path}`) && fs.statSync(abs(`${pack}/${record.path}`)).size === record.bytes && sha(`${pack}/${record.path}`) === record.sha256, `pack hash ledger mismatch: ${record.path}`);
  for (const name of expectedPack.filter((n) => n.endsWith('.png'))) { const info = pngInfo(`${pack}/${name}`); assert(info && info.width >= 600 && info.height >= 338 && info.bytes > 10000 && info.variance > 2, `invalid canonical board: ${name}`); }
  try { const stream = ffprobe(`${pack}/08_CONTINUOUS_V0341_BARROSAN_BARN_GOLD_ASSET.mp4`); assert(stream.codec_name === 'h264' && stream.width === 1280 && stream.height === 720 && stream.r_frame_rate === '24/1' && Number(stream.nb_read_frames) === 360, 'canonical MP4 ffprobe mismatch'); } catch (error) { errors.push(`ffprobe failed: ${error.message}`); }
}

const packageText = read('package.json');
for (const command of ['blender:generate:salto-v0341-barrosan-agricultural-barn-gold-asset', 'godot:capture:salto-v0341-barrosan-agricultural-barn-gold-asset', 'godot:pack:salto-v0341-barrosan-agricultural-barn-gold-asset', 'godot:validate:salto-v0341-barrosan-agricultural-barn-gold-asset']) assert(packageText.includes(command), `dedicated package command missing: ${command}`);
assert(!exists('art-source/materials/v0341/protected-game-assets'), 'protected-game asset import path present');

if (errors.length) { console.error(JSON.stringify({ status: 'FAIL_V0341_BARROSAN_AGRICULTURAL_BARN_GOLD_ASSET', base, errors }, null, 2)); process.exit(1); }
console.log(JSON.stringify({ status: 'PASS_V0341_BARROSAN_AGRICULTURAL_BARN_GOLD_ASSET', base, checks: 62, outcome: 'READY FOR HUMAN BARROSAN AGRICULTURAL BARN GOLD-ASSET REVIEW', humanReviewRequired: true, automatedVisualApproval: false }, null, 2));
