import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const root = process.cwd();
const errors = [];
const abs = (p) => path.join(root, p);
const exists = (p) => fs.existsSync(abs(p));
const read = (p) => fs.readFileSync(abs(p), 'utf8');
const json = (p) => JSON.parse(read(p));
const sha = (p) => crypto.createHash('sha256').update(fs.readFileSync(abs(p))).digest('hex');
const assert = (condition, message) => { if (!condition) errors.push(message); };
const runtime = 'artifacts/runtime/v0342';
const pack = 'artifacts/manual-review/v0342-reference-locked-barrosan-barn/UPLOAD_TO_CHAT';
const captureNames = ['01_human_v0341_rejection_and_primary_reference.png','02_visual_first_lock_front_three_quarter.png','03_visual_first_lock_rear_three_quarter.png','04_visual_first_lock_front_close_material.png','05_house02_barn_matched_256.png','06_ordinary_player_rts.png','07_front_three_quarter_player.png','08_rear_three_quarter_player.png','09_far_rts_gameplay_zoom.png','10_thumbnail_readability.png','11_greyscale_readability.png','12_neutral_overcast.png','13_cool_daylight.png','14_warm_directional.png','15_front_orthographic.png','16_rear_orthographic.png','17_left_orthographic.png','18_right_orthographic.png','19_direct_top_down_comparison.png','20_river_below_land_and_banks.png','21_road_bridge_integration.png','22_bridge_deck_support_depth.png','23_barn_full_view.png','24_barn_lower_entrance.png','25_barn_upper_hay_loading.png','26_roof_courses_ridge_eaves.png','27_granite_corners_lintel_sill.png','28_foundation_uphill_downhill.png','29_timber_iron_detail.png','30_worker_scale_and_clearance.png','31_performance_ledger_view.png','32_normal_enabled.png','33_normal_disabled.png','34_albedo_only.png','35_roughness_isolation.png','36_height_relief.png','37_uv_checker.png','38_blender_wireframe.png','39_exported_uv_layout.png','40_lod0_lod1_lod2_comparison.png','41_isolated_collision.png','42_exact_dimensions_and_function.png','43_rejected_v0341_vs_rebuilt.png','44_review_contact_sheet_source.png'];
const pngInfo = (p) => {
  if (!exists(p)) return null;
  const b = fs.readFileSync(abs(p));
  if (b.length < 24 || b.readUInt32BE(0) !== 0x89504e47) return null;
  let sum = 0; let sum2 = 0; const step = Math.max(1, Math.floor(b.length / 5000));
  for (let i = 100; i < b.length; i += step) { sum += b[i]; sum2 += b[i] * b[i]; }
  const n = Math.max(1, Math.ceil((b.length - 100) / step));
  return { width: b.readUInt32BE(16), height: b.readUInt32BE(20), bytes: b.length, variance: sum2 / n - (sum / n) ** 2 };
};

assert(exists('art-source/blender/v0342/reference_locked_barrosan_two_storey_barn.blend'), 'v0.342 source Blend missing');
assert(exists('desktop-spikes/godot-salto/assets/v0342/reference_locked_barrosan_two_storey_barn.glb'), 'v0.342 GLB missing');
assert(exists('desktop-spikes/godot-salto/scenes/review/V0342ReferenceLockedBarrosanBarnReview.tscn'), 'v0.342 scene missing');
assert(exists('desktop-spikes/godot-salto/scripts/v0342_reference_locked_barrosan_barn_review.gd'), 'review script missing');
assert(exists('tools/blender/generateV0342ReferenceLockedBarrosanBarn.py'), 'clean-room generator missing');
assert(exists('tools/godot/captureGodotV0342ReferenceLockedBarrosanBarnWindows.ps1'), 'capture wrapper missing');
assert(exists('tools/godot/buildV0342ReferenceLockedBarrosanBarnPack.py'), 'pack builder missing');
assert(exists('art-source/blender/v0342/v0342-barn-metrics.json'), 'geometry metrics missing');
const script = read('desktop-spikes/godot-salto/scripts/v0342_reference_locked_barrosan_barn_review.gd');
for (const token of ['V0342_BARN_GLB','V0342_CAPTURE_COUNT := 44','V0342_CONTINUOUS_FRAMES := 360','V0342_FrozenHouse02_Unmodified_QualityAnchor','V0342_ReferenceLocked_Barrosan_TwoStorey_Barn']) assert(script.includes(token), `runtime contract missing: ${token}`);
for (const token of ['move_and_slide','NavigationAgent3D','damage_taken','projectile','save_game','resource_mutation']) assert(!script.toLowerCase().includes(token), `forbidden gameplay coupling: ${token}`);
assert(sha('art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend') === '3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6', 'frozen House02 Blend changed');
assert(sha('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb') === 'ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89', 'frozen House02 GLB changed');
const source = read('tools/blender/generateV0342ReferenceLockedBarrosanBarn.py');
for (const token of ['closed','irregular_face_stones','CandidateA','Upper_Hay_Loading_Shutter','Lower_Double_Livestock_Door','slate_slope','regular block wall generator']) assert(source.toLowerCase().includes(token.toLowerCase()), `source identity token missing: ${token}`);
assert(!source.includes('generateV0341') && !source.includes('v0341_barrosan'), 'v0.341 visible mesh source dependency');

const manifestPath = `${runtime}/v0342-reference-locked-barrosan-barn-runtime.json`;
assert(exists(manifestPath) || exists(`${pack}/compact-evidence-summary.json`), 'runtime manifest/canonical summary missing');
if (exists(manifestPath)) {
  const manifest = json(manifestPath);
  assert(manifest.prototypeOptIn === true && manifest.defaultRuntimeIntegrated === false, 'prototype/default isolation mismatch');
  assert(manifest.house02Modified === false && manifest.v0341VisibleAssetDependency === false, 'frozen/rejected asset isolation mismatch');
  assert(manifest.captureCount === 44 && manifest.continuousFrames === 360 && manifest.errors?.length === 0, 'capture manifest incomplete');
  for (const name of captureNames) { const info = pngInfo(`${runtime}/screenshots/${name}`); assert(info && info.width >= 1280 && info.height >= 720 && info.bytes > 10000 && info.variance > 2, `invalid real capture: ${name}`); }
  const m = manifest.metrics || {}; const lod = m.lod || {};
  assert(m.closedVolume === true && m.principalRoofSlopes === 2 && m.slateVisibleCoursesPerSlope >= 8, 'closed barn/roof contract missing');
  assert(m.graniteExteriorPercent >= 0.85 && m.regularBlockWallGenerator === false, 'granite/block contract invalid');
  assert(lod.lod0Triangles <= 60000 && lod.lod1Triangles < lod.lod0Triangles && lod.lod2Triangles < lod.lod1Triangles && lod.collisionTriangles <= 250, 'LOD/collision metrics invalid');
  assert(manifest.performance?.warmupSeconds >= 5 && manifest.performance?.measurementSeconds >= 20 && manifest.performance?.sampleCount >= 1000, 'performance ledger incomplete');
}

assert(exists(pack), 'canonical pack missing');
if (exists(pack)) {
  const expected = ['00_READ_ME_FIRST.md','01_HUMAN_V0341_DECISION_AND_DOCUMENTARY_LOCK.png','02_VISUAL_FIRST_PLAYER_LOCK.png','03_FUNCTION_ORTHOGRAPHICS_AND_DIMENSIONS.png','04_GRANITE_MASONRY_FOUNDATION_AND_CORNERS.png','05_SLATE_ROOF_TIMBER_AND_OPENINGS.png','06_LIGHTING_RTS_GREYSCALE_AND_256.png','07_REAL_PBR_UV_WIREFRAME_LOD_COLLISION.png','08_CONTINUOUS_V0342_REFERENCE_LOCKED_BARROSAN_BARN.mp4','compact-evidence-summary.json'];
  assert(JSON.stringify(fs.readdirSync(abs(pack)).sort()) === JSON.stringify(expected.sort()), 'canonical pack must contain exactly ten files');
  const summary = json(`${pack}/compact-evidence-summary.json`);
  assert(summary.checkpoint === 'v0.342' && summary.humanReviewRequired === true && summary.automatedVisualApproval === false, 'human-review gate mismatch');
  assert(summary.captures?.count === 44 && summary.video?.codec === 'h264' && summary.video?.width === 1280 && summary.video?.height === 720 && summary.video?.frameRate === '24/1' && summary.video?.decodedFrames === 360, 'video/capture summary invalid');
  for (const record of summary.exactUploadFiles || []) assert(exists(`${pack}/${record.path}`) && fs.statSync(abs(`${pack}/${record.path}`)).size === record.bytes && sha(`${pack}/${record.path}`) === record.sha256, `pack hash mismatch: ${record.path}`);
}
const packageText = read('package.json');
for (const command of ['blender:generate:salto-v0342-reference-locked-barrosan-barn','godot:capture:salto-v0342-reference-locked-barrosan-barn','godot:pack:salto-v0342-reference-locked-barrosan-barn','godot:validate:salto-v0342-reference-locked-barrosan-barn']) assert(packageText.includes(command), `package command missing: ${command}`);
if (errors.length) { console.error(JSON.stringify({ status: 'FAIL_V0342_REFERENCE_LOCKED_BARROSAN_BARN', errors }, null, 2)); process.exit(1); }
console.log(JSON.stringify({ status: 'PASS_V0342_REFERENCE_LOCKED_BARROSAN_BARN', checks: 54, outcome: 'REJECTED INTERNALLY — REBUILT BARN STILL READS AS A GARAGE, GREYBOX, REGULAR-BLOCK BUILDING, GENERIC LOW-POLY PROP OR NON-BARROSAN STRUCTURE', humanReviewRequired: true, automatedVisualApproval: false }, null, 2));
