import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const errors = [];
const abs = (file) => path.join(root, file);
const exists = (file) => fs.existsSync(abs(file));
const read = (file) => fs.readFileSync(abs(file), 'utf8').replace(/^\uFEFF/, '');
const json = (file) => JSON.parse(read(file));
const sha256 = (file) => crypto.createHash('sha256').update(fs.readFileSync(abs(file))).digest('hex');
const assert = (condition, message) => { if (!condition) errors.push(message); };
const pngInfo = (file) => {
  if (!exists(file)) return null;
  const bytes = fs.readFileSync(abs(file));
  if (bytes.length < 24 || bytes.readUInt32BE(0) !== 0x89504e47) return null;
  let total = 0; let totalSq = 0; let count = 0;
  const stride = Math.max(1, Math.floor(bytes.length / 6000));
  for (let i = 100; i < bytes.length; i += stride) { total += bytes[i]; totalSq += bytes[i] * bytes[i]; count += 1; }
  const mean = total / Math.max(1, count);
  return { width: bytes.readUInt32BE(16), height: bytes.readUInt32BE(20), bytes: bytes.length, variance: totalSq / Math.max(1, count) - mean * mean };
};
const cleanGitDiff = (file) => {
  try { execFileSync('git', ['diff', '--quiet', '--', file], { cwd: root, stdio: 'ignore' }); return true; }
  catch { return false; }
};

const V0347_BLEND_SHA = 'e5c8c9d561fc921f97a971110b34b706ed8dbd1824e4e451addab2ac1573a69a';
const V0347_GLB_SHA = '0b4944d8a15006664dad84cec5e8b41546497588d14194d5b2e49621071e209c';
const HOUSE02_BLEND_SHA = '3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6';
const HOUSE02_GLB_SHA = 'ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89';
const outcome = 'READY FOR HUMAN V0348 BARN MATERIAL-HARMONY GOLD-CANDIDATE REVIEW';
const rawNames = [
  '01_front_three_quarter.png', '02_direct_front.png', '03_direct_side_gable.png',
  '04_house02_barn_slate_match.png', '05_front_openings_closeup.png', '06_far_rts.png',
  '07_256_pixel_source.png', '08_true_matched_house02_barn.png',
  '09_neutral_overcast_full_asset.png', '10_warm_directional_full_asset.png',
];
const packRoot = 'artifacts/manual-review/v0348-barn-material-harmony-gold-candidate/UPLOAD_TO_CHAT';
const packNames = [
  '00_READ_ME_FIRST.md', '01_HUMAN_V0347_ACCEPTANCE_AND_FROZEN_GEOMETRY.png',
  '02_FINAL_BARN_NEUTRAL_AND_FRONT.png', '03_HOUSE02_AND_BARN_SLATE_MATCH.png',
  '04_GRANITE_GABLE_UV_CONTINUITY.png', '05_OPENINGS_TIMBER_AND_FOUNDATION.png',
  '06_RTS_256_AND_GREYSCALE.png', '07_PBR_NORMAL_ROUGHNESS_AND_UV.png',
  '08_TRUE_MATCHED_HOUSE02_BARN.png', 'compact-evidence-summary.json',
];
const sourceFiles = [
  'art-source/blender/v0348/barn_barrosan_material_harmony.blend',
  'art-source/blender/v0348/v0347_source_duplicate_for_v0348.blend',
  'art-source/blender/v0348/v0348-barn-material-harmony-metrics.json',
  'art-source/blender/v0348/v0348-material-response-matrix.json',
  'art-source/blender/v0348/v0348-source-lineage.json',
  'art-source/blender/v0348/v0348_roof_uv_checker.png',
  'art-source/blender/v0348/v0348_roof_uv_layout.png',
  'art-source/blender/v0348/v0348_weathered_slate_courses_albedo.png',
  'art-source/blender/v0348/v0348_weathered_slate_courses_normal.png',
  'art-source/blender/v0348/v0348_weathered_slate_courses_roughness.png',
  'desktop-spikes/godot-salto/assets/v0348/barn_barrosan_material_harmony.glb',
  'desktop-spikes/godot-salto/assets/v0348/barn_barrosan_material_harmony.glb.import',
  'desktop-spikes/godot-salto/assets/v0348/v0348_weathered_slate_courses_albedo.png',
  'desktop-spikes/godot-salto/assets/v0348/v0348_weathered_slate_courses_normal.png',
  'desktop-spikes/godot-salto/assets/v0348/v0348_weathered_slate_courses_roughness.png',
  'desktop-spikes/godot-salto/scenes/review/V0348BarnBarrosanMaterialHarmony.tscn',
  'desktop-spikes/godot-salto/scripts/v0348_barn_barrosan_material_harmony.gd',
  'tools/blender/generateV0348BarnBarrosanMaterialHarmony.py',
  'tools/blender/generateV0348BarnBarrosanMaterialHarmonyWindows.ps1',
  'tools/godot/captureGodotV0348BarnBarrosanMaterialHarmonyWindows.ps1',
  'tools/godot/buildV0348BarnMaterialHarmonyPack.ps1',
  'docs/V0348_BARN_BARROSAN_MATERIAL_HARMONY_GOLD_CANDIDATE_REPORT.md',
];
for (const file of sourceFiles) assert(exists(file), `required v0.348 file missing: ${file}`);

assert(exists('art-source/blender/v0347/barn_rendered_geometry_truth.blend') && sha256('art-source/blender/v0347/barn_rendered_geometry_truth.blend') === V0347_BLEND_SHA, 'frozen v0.347 Blend changed');
assert(exists('desktop-spikes/godot-salto/assets/v0347/barn_rendered_geometry_truth.glb') && sha256('desktop-spikes/godot-salto/assets/v0347/barn_rendered_geometry_truth.glb') === V0347_GLB_SHA, 'frozen v0.347 GLB changed');
assert(exists('art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend') && sha256('art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend') === HOUSE02_BLEND_SHA, 'frozen House02 Blend changed');
assert(exists('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb') && sha256('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb') === HOUSE02_GLB_SHA, 'frozen House02 GLB changed');
assert(cleanGitDiff('art-source/blender/v0347/barn_rendered_geometry_truth.blend'), 'v0.347 source Blend has an unexpected working-tree diff');
assert(cleanGitDiff('desktop-spikes/godot-salto/assets/v0347/barn_rendered_geometry_truth.glb'), 'v0.347 source GLB has an unexpected working-tree diff');
assert(cleanGitDiff('desktop-spikes/godot-salto/scenes/salto_spike_root.tscn'), 'true default scene has an unexpected working-tree diff');

const metrics = exists('art-source/blender/v0348/v0348-barn-material-harmony-metrics.json') ? json('art-source/blender/v0348/v0348-barn-material-harmony-metrics.json') : {};
const lineage = exists('art-source/blender/v0348/v0348-source-lineage.json') ? json('art-source/blender/v0348/v0348-source-lineage.json') : {};
assert(metrics.checkpoint === 'v0.348' && metrics.derivedFromV0347 === true && metrics.prototypeOnly === true && metrics.defaultRuntimeIntegrated === false && metrics.geometryUnchanged === true, 'v0.348 derivative/isolation contract failed');
assert(lineage.checkpoint === 'v0.348' && lineage.derivedFrom === 'v0.347' && lineage.geometryUnchanged === true && lineage.defaultRuntimeIntegrated === false && lineage.humanApprovalRequired === true, 'v0.348 source lineage contract failed');
assert(metrics.sourceHashes?.v0347Blend === V0347_BLEND_SHA && metrics.sourceHashes?.v0347GLB === V0347_GLB_SHA && metrics.sourceHashes?.house02Blend === HOUSE02_BLEND_SHA, 'v0.348 source hash ledger is not frozen');
assert(metrics.finalHashes?.glb === V0347_GLB_SHA, 'v0.348 Godot geometry carrier must remain the frozen v0.347 GLB');
assert(metrics.roof?.pitchDegrees?.length === 2 && metrics.roof.pitchDegrees.every((pitch) => pitch === 20), 'v0.348 roof pitch changed from frozen 20 degrees');
assert(metrics.roof?.principalSlopes === 2 && metrics.roof.straightRidge === true && metrics.roof.secondaryRoofNodes === 0, 'v0.348 two-slope/straight-ridge contract failed');
assert(metrics.roof?.completeGraniteGables === 2 && metrics.roof.roofMaterialOnGables === false, 'v0.348 complete-gable/roof-material contract failed');
assert(metrics.roof?.activeUv === 'V0348_Explicit_Roof_And_Gable_UV' && metrics.roof.roofFacesExplicitlyUvMapped >= 2 && metrics.roof.gableFacesExplicitlyUvMapped >= 2, 'v0.348 explicit roof/gable UV contract missing');
assert(metrics.slateScale?.apparentScaleDeltaPercent <= 10 && metrics.slateScale?.visibleCoursesEaveToRidge >= 8 && metrics.slateScale?.uvRotationFrontDegrees === 0 && metrics.slateScale?.uvRotationRearDegrees === 0, 'v0.348 House02 slate scale/course/rotation evidence failed');
assert(metrics.slateScale?.uvProgression?.toLowerCase().includes('independent') && metrics.slateScale?.uvProgression?.toLowerCase().includes('eave-to-ridge'), 'v0.348 independent eave-to-ridge UV progression missing');
assert(metrics.granite?.lineage?.includes('House02') && metrics.granite.gableWorldProjected === true && metrics.granite.lowerWallAndGableScaleMatched === true, 'v0.348 House02 granite continuity contract failed');
assert(metrics.openings?.lowerDoubleAgriculturalDoor === true && metrics.openings?.upperHayLoadingOpening === true && metrics.openings?.upperOpeningSubordinate === true && metrics.openings?.rearServiceOpening === true && metrics.openings?.upperOpeningGeometryUnchanged === true, 'v0.348 agricultural-opening hierarchy or geometry preservation failed');
assert(Object.keys(metrics.materials || {}).length >= 6, 'v0.348 material-role ledger is incomplete');

const script = exists('desktop-spikes/godot-salto/scripts/v0348_barn_barrosan_material_harmony.gd') ? read('desktop-spikes/godot-salto/scripts/v0348_barn_barrosan_material_harmony.gd') : '';
const generator = exists('tools/blender/generateV0348BarnBarrosanMaterialHarmony.py') ? read('tools/blender/generateV0348BarnBarrosanMaterialHarmony.py') : '';
const scene = exists('desktop-spikes/godot-salto/scenes/review/V0348BarnBarrosanMaterialHarmony.tscn') ? read('desktop-spikes/godot-salto/scenes/review/V0348BarnBarrosanMaterialHarmony.tscn') : '';
for (const token of ['Warcraft', 'Blizzard', 'Age of Empires', 'copyrighted third-party']) assert(!generator.toLowerCase().includes(token.toLowerCase()), `protected-game/provenance token present: ${token}`);
for (const token of ['move_and_slide', 'NavigationAgent', 'projectile', 'save_game', 'instantiate_enemy', 'resource_mutation']) assert(!script.toLowerCase().includes(token.toLowerCase()), `forbidden runtime coupling present: ${token}`);
for (const token of ['CHECKPOINT := "v0.348"', 'PROJECTION_ORTHOGONAL', 'V0348_OptIn_Barrosan_Material_Harmony_World', 'V0348_Frozen_House02_Unmodified_Anchor', 'prototypeOptIn', 'defaultRuntimeIntegrated', 'noGameplay', 'noMovement', 'noPathfinding', 'noCombat', 'noEconomy', 'noResources']) assert(script.includes(token), `v0.348 opt-in/isolation token missing: ${token}`);
assert(scene.includes('[node name="V0348BarnBarrosanMaterialHarmony" type="Node3D"]') && scene.includes('v0348_barn_barrosan_material_harmony.gd'), 'v0.348 review scene is not an isolated Node3D scene');
for (const token of ['V0348_Barrosan_House02_Harmony_Granite', 'V0348_Barrosan_House02_Harmony_Weathered_Slate', 'V0348_Aged_Agricultural_Timber', 'V0348_Subordinate_Charcoal_Brown_Roof_Edge', 'V0348_Stable_Orthographic_Material_Harmony_Camera']) assert(script.includes(token), `v0.348 material/camera token missing: ${token}`);

const packageText = read('package.json');
for (const command of ['blender:generate:salto-v0348-barn-material-harmony-gold-candidate', 'godot:capture:salto-v0348-barn-material-harmony-gold-candidate', 'godot:pack:salto-v0348-barn-material-harmony-gold-candidate', 'godot:validate:salto-v0348-barn-material-harmony-gold-candidate', 'validate:artifact-retention', 'godot:all']) assert(packageText.includes(command), `package command missing: ${command}`);

const manifestPath = 'artifacts/runtime/v0348/v0348-barn-material-harmony-runtime.json';
assert(exists(manifestPath), 'v0.348 runtime manifest missing');
const manifest = exists(manifestPath) ? json(manifestPath) : {};
assert(manifest.status === 'PASS_V0348_MATERIAL_HARMONY_RUNTIME' && manifest.rawCaptureCount === 10 && Array.isArray(manifest.errors) && manifest.errors.length === 0, 'v0.348 runtime manifest is not a clean ten-capture pass');
assert(manifest.prototypeOptIn === true && manifest.prototypeOnly === true && manifest.defaultRuntimeIntegrated === false && manifest.noGameplay === true && manifest.noRuntimeIntegration === true, 'v0.348 runtime isolation contract failed');
assert(manifest.outcome === outcome && manifest.scenePath === 'res://scenes/review/V0348BarnBarrosanMaterialHarmony.tscn', 'v0.348 runtime outcome/scene contract failed');
for (const name of rawNames) {
  const info = pngInfo(`artifacts/runtime/v0348/screenshots/${name}`);
  assert(info && info.bytes > 10_000 && info.variance > 2, `invalid v0.348 rendered capture: ${name}`);
}
assert(pngInfo('artifacts/runtime/v0348/screenshots/07_256_pixel_source.png')?.width === 256 && pngInfo('artifacts/runtime/v0348/screenshots/07_256_pixel_source.png')?.height === 256, 'v0.348 256-pixel source evidence is not 256x256');
assert(pngInfo('artifacts/runtime/v0348/screenshots/08_true_matched_house02_barn.png')?.width === 512 && pngInfo('artifacts/runtime/v0348/screenshots/08_true_matched_house02_barn.png')?.height === 256, 'v0.348 true House02/barn comparison is not 512x256');
for (const diagnostic of ['normal_enabled.png', 'normal_disabled.png', 'albedo_only.png', 'roughness_isolation.png', 'uv_checker_source.txt']) assert(exists(`artifacts/runtime/v0348/diagnostics/${diagnostic}`), `v0.348 diagnostic evidence missing: ${diagnostic}`);
assert(manifest.diagnosticEvidence?.includes('normal_enabled.png') && manifest.diagnosticEvidence?.includes('roughness_isolation.png'), 'v0.348 diagnostic manifest ledger incomplete');

assert(exists(packRoot), 'v0.348 upload pack missing');
const packFiles = exists(packRoot) ? fs.readdirSync(abs(packRoot)).filter((name) => fs.statSync(abs(`${packRoot}/${name}`)).isFile()).sort() : [];
assert(JSON.stringify(packFiles) === JSON.stringify([...packNames].sort()), 'v0.348 upload pack must contain exactly ten files');
for (const name of packNames.filter((name) => name.endsWith('.png'))) {
  const info = pngInfo(`${packRoot}/${name}`);
  assert(info && info.bytes > 10_000 && info.variance > 2, `invalid v0.348 review board: ${name}`);
}
if (exists(`${packRoot}/compact-evidence-summary.json`)) {
  const summary = json(`${packRoot}/compact-evidence-summary.json`);
  assert(summary.exactTenFiles === true && summary.exactlyEightPng === true && summary.noVideo === true && summary.noTitleCardOnlyEvidence === true && summary.noDefaultRuntimeIntegration === true, 'v0.348 pack summary contract failed');
  assert(summary.rawCaptureCount === 10 && summary.geometryUnchanged === true && summary.automatedVisualApproval === false && summary.humanReviewRequired === true, 'v0.348 summary evidence contract failed');
}
const reportPath = 'docs/V0348_BARN_BARROSAN_MATERIAL_HARMONY_GOLD_CANDIDATE_REPORT.md';
assert(exists(reportPath), 'v0.348 report missing');
if (exists(reportPath)) {
  const report = read(reportPath);
  assert((report.match(new RegExp(outcome, 'g')) || []).length === 1, 'v0.348 READY outcome must appear exactly once in report');
  for (const token of ['v0.347 geometry is frozen', packRoot, 'House02', 'independent', 'eave-to-ridge', 'no default runtime integration', 'automated visual approval remains false', 'human review remains required']) assert(report.toLowerCase().includes(token.toLowerCase()), `v0.348 report evidence missing: ${token}`);
  for (const phrase of ['v0.348 is gold', 'v0.348 approved', 'production-ready approval']) assert(!report.toLowerCase().includes(phrase), `v0.348 report overclaims approval: ${phrase}`);
}
for (const file of ['desktop-spikes/godot-salto/assets/v0348/barn_barrosan_material_harmony.glb', 'art-source/blender/v0348/barn_barrosan_material_harmony.blend']) assert(fs.statSync(abs(file)).size < 20_000_000, `unapproved large v0.348 asset: ${file}`);

if (errors.length) {
  console.error(JSON.stringify({ status: 'FAIL_V0348_BARN_MATERIAL_HARMONY_GOLD_CANDIDATE', errors }, null, 2));
  process.exit(1);
}
console.log(JSON.stringify({ status: 'PASS_V0348_BARN_MATERIAL_HARMONY_GOLD_CANDIDATE', outcome, automatedVisualApproval: false, humanReviewRequired: true, rawCaptures: 10, uploadPackFiles: 10, geometryFrozen: true, prototypeOnly: true, defaultRuntimeUnchanged: true, gameplayUnchanged: true }, null, 2));
