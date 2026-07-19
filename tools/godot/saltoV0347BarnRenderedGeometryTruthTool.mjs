import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const root = process.cwd();
const errors = [];
const abs = (relative) => path.join(root, relative);
const exists = (relative) => fs.existsSync(abs(relative));
const read = (relative) => fs.readFileSync(abs(relative), 'utf8');
const readJson = (relative) => JSON.parse(read(relative).replace(/^\uFEFF/, ''));
const sha256 = (relative) => crypto.createHash('sha256').update(fs.readFileSync(abs(relative))).digest('hex');
const assert = (condition, message) => { if (!condition) errors.push(message); };
const pngInfo = (relative) => {
  if (!exists(relative)) return null;
  const b = fs.readFileSync(abs(relative));
  if (b.length < 24 || b.readUInt32BE(0) !== 0x89504e47) return null;
  let sum = 0; let sum2 = 0; let n = 0;
  for (let i = 100; i < b.length; i += Math.max(1, Math.floor(b.length / 5000))) { sum += b[i]; sum2 += b[i] * b[i]; n += 1; }
  return { width: b.readUInt32BE(16), height: b.readUInt32BE(20), bytes: b.length, variance: sum2 / Math.max(1, n) - (sum / Math.max(1, n)) ** 2 };
};

const V0346_BLEND = 'fbc5e6de4155d0cf1dcd8902751fc26405090c2de714296cddf68306c02ca3df';
const V0346_GLB = '11c974596413b1548c471d3ae5786ccd81cdcb613a79c47a94cd8280a3927da3';
const HOUSE02_BLEND = '3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6';
const HOUSE02_GLB = 'ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89';
const packRoot = 'artifacts/manual-review/v0347-barn-rendered-geometry-truth/UPLOAD_TO_CHAT';
const runtime = 'artifacts/runtime/v0347';
const sourceNames = ['01_front_three_quarter.png', '02_direct_front_orthographic.png', '03_direct_side_gable.png', '04_roof_close_up.png', '05_true_matched_front_512x256.png'];
const packNames = ['00_READ_ME_FIRST.md', '01_FINAL_FRONT_AND_HORIZONTAL_MASS.png', '02_COMPLETE_GRANITE_GABLES.png', '03_HOUSE02_SLATE_AND_ROOF_PITCH.png', '04_TRUE_MATCHED_FRONT_512X256.png', 'compact-evidence-summary.json'];

for (const file of [
  'art-source/blender/v0347/barn_rendered_geometry_truth.blend',
  'art-source/blender/v0347/v0346_source_duplicate_for_v0347.blend',
  'art-source/blender/v0347/v0347-barn-rendered-geometry-metrics.json',
  'art-source/blender/v0347/v0347-transform-and-geometry-diagnosis.json',
  'art-source/blender/v0347/v0347-source-lineage.json',
  'desktop-spikes/godot-salto/assets/v0347/barn_rendered_geometry_truth.glb',
  'desktop-spikes/godot-salto/scenes/review/V0347BarnRenderedGeometryTruth.tscn',
  'desktop-spikes/godot-salto/scripts/v0347_barn_rendered_geometry_truth.gd',
  'tools/blender/generateV0347BarnRenderedGeometryTruth.py',
  'tools/blender/generateV0347BarnRenderedGeometryTruthWindows.ps1',
  'tools/godot/captureGodotV0347BarnRenderedGeometryTruthWindows.ps1',
  'tools/godot/buildV0347BarnRenderedGeometryTruthPack.ps1',
]) assert(exists(file), `required v0.347 file missing: ${file}`);

assert(sha256('art-source/blender/v0346/barn_house02_silhouette_roof_pitch.blend') === V0346_BLEND, 'frozen v0.346 Blend changed');
assert(sha256('desktop-spikes/godot-salto/assets/v0346/barn_house02_silhouette_roof_pitch.glb') === V0346_GLB, 'frozen v0.346 GLB changed');
assert(sha256('art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend') === HOUSE02_BLEND, 'frozen House02 Blend changed');
assert(sha256('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb') === HOUSE02_GLB, 'frozen House02 GLB changed');

if (exists('art-source/blender/v0347/v0347-source-lineage.json')) {
  const lineage = readJson('art-source/blender/v0347/v0347-source-lineage.json');
  assert(lineage.checkpoint === 'v0.347' && lineage.v0346Untouched === true && lineage.v0345Untouched === true && lineage.v0344Untouched === true && lineage.v0343Untouched === true && lineage.house02Untouched === true, 'v0.347 lineage/frozen-source preservation failed');
  assert(lineage.noRuntimeIntegration === true, 'v0.347 lineage is not runtime isolated');
}

const metrics = exists('art-source/blender/v0347/v0347-barn-rendered-geometry-metrics.json') ? readJson('art-source/blender/v0347/v0347-barn-rendered-geometry-metrics.json') : {};
const slopes = metrics.v0347WorldSpaceSlopes || [];
assert(metrics.derivedFromV0346 === true && metrics.prototypeOnly === true && metrics.defaultRuntimeIntegrated === false, 'prototype/default-runtime isolation failed');
assert(slopes.length === 2 && slopes.every((s) => s.faceCount === 1 && s.pitchDegrees >= 20 && s.pitchDegrees <= 24 && s.rise > 0 && s.run > 0), 'final world-space roof slope contract failed');
assert(metrics.roof?.principalSlopes === 2 && metrics.roof?.straightRidge === true && metrics.roof?.secondaryRoofNodes === 0, 'two-slope/one-ridge contract failed');
assert(metrics.roof?.completeGraniteGables === 2 && metrics.roof?.greyPlaceholderRoof === false && metrics.roof?.smoothGenericRoof === false && metrics.roof?.roofMaterialOnGables === false, 'granite-gable or roof-material contract failed');
assert(metrics.roofPercentOfTotalHeight <= 34.5, 'roof remains too tall relative to total building height');
assert(metrics.openings?.lowerDoubleAgriculturalDoor === true && metrics.openings?.upperHayLoadingOpening === true && metrics.openings?.rearServiceOpening === true, 'agricultural openings missing');
assert(metrics.v0346ActualSourceGeometry?.slopes?.length === 2 && metrics.v0346ActualSourceGeometry.pitchDegrees.every((p) => Number.isFinite(p)), 'v0.346 actual source pitch was not recomputed from final world geometry');
assert(metrics.transformsApplied === true && JSON.stringify(metrics.objectScaleAfterApply) === JSON.stringify([1, 1, 1]), 'world transform bake contract failed');
assert(metrics.roof?.roofMaterialLineage?.includes('V0334_Weathered_Slate') && metrics.roof?.roofMaterialTileUV === true, 'frozen House02 slate lineage/UV contract missing');
assert(fs.statSync(abs('desktop-spikes/godot-salto/assets/v0347/barn_rendered_geometry_truth.glb')).size < 20_000_000, 'unapproved large v0.347 asset import');

const generator = exists('tools/blender/generateV0347BarnRenderedGeometryTruth.py') ? read('tools/blender/generateV0347BarnRenderedGeometryTruth.py').toLowerCase() : '';
const script = exists('desktop-spikes/godot-salto/scripts/v0347_barn_rendered_geometry_truth.gd') ? read('desktop-spikes/godot-salto/scripts/v0347_barn_rendered_geometry_truth.gd') : '';
const scene = exists('desktop-spikes/godot-salto/scenes/review/V0347BarnRenderedGeometryTruth.tscn') ? read('desktop-spikes/godot-salto/scenes/review/V0347BarnRenderedGeometryTruth.tscn') : '';
for (const token of ['warcraft', 'blizzard', 'age of empires', 'copyrighted third-party']) assert(!generator.includes(token), `forbidden provenance token: ${token}`);
for (const token of ['move_and_slide', 'navigationagent', 'projectile', 'save_game', 'instantiate_enemy', 'resource_mutation']) assert(!script.toLowerCase().includes(token), `forbidden gameplay coupling: ${token}`);
for (const token of ['V0347_Stable_Orthographic_Truth_Camera', 'PROJECTION_ORTHOGONAL', 'V0347_Frozen_House02_Unmodified_Anchor', 'V0347_Barn_Rendered_Geometry_Truth_Candidate', '05_true_matched_front_512x256.png', 'prototypeOnly', 'defaultRuntimeIntegrated']) assert(script.includes(token) || script.toLowerCase().includes(token.toLowerCase()), `capture/isolation token missing: ${token}`);
assert(scene.includes('[node name="V0347BarnRenderedGeometryTruth" type="Node3D"]'), 'v0.347 scene is not isolated Node3D');

const packageText = read('package.json');
for (const command of ['blender:generate:salto-v0347-barn-rendered-geometry-truth', 'godot:capture:salto-v0347-barn-rendered-geometry-truth', 'godot:pack:salto-v0347-barn-rendered-geometry-truth', 'godot:validate:salto-v0347-barn-rendered-geometry-truth', 'validate:artifact-retention']) assert(packageText.includes(command), `package command missing: ${command}`);

if (exists(`${runtime}/v0347-barn-rendered-geometry-truth-runtime.json`)) {
  const manifest = readJson(`${runtime}/v0347-barn-rendered-geometry-truth-runtime.json`);
  assert(manifest.status === 'PASS_V0347_BARN_RENDERED_GEOMETRY_TRUTH' && manifest.rawCaptureCount === 5 && manifest.errors?.length === 0, 'runtime manifest is not a clean five-capture pass');
  assert(manifest.prototypeOptIn === true && manifest.prototypeOnly === true && manifest.defaultRuntimeIntegrated === false && manifest.noGameplay === true && manifest.noRuntimeIntegration === true, 'runtime isolation contract failed');
  assert(manifest.house02RenderedDirectlyInCapture5 === true && manifest.frontCaptureShowsAgriculturalOpenings === true, 'true comparison/front-opening evidence missing');
  for (const name of sourceNames) { const info = pngInfo(`${runtime}/screenshots/${name}`); assert(info && info.bytes > 10_000 && info.variance > 2, `invalid v0.347 rendered source capture: ${name}`); }
  const matched = pngInfo(`${runtime}/screenshots/05_true_matched_front_512x256.png`); assert(matched?.width === 512 && matched?.height === 256, 'true matched source capture is not 512x256');
} else errors.push('v0.347 runtime manifest missing');

assert(exists(packRoot), 'v0.347 upload pack missing');
const packFiles = exists(packRoot) ? fs.readdirSync(abs(packRoot)).filter((name) => fs.statSync(abs(`${packRoot}/${name}`)).isFile()).sort() : [];
assert(JSON.stringify(packFiles) === JSON.stringify([...packNames].sort()), 'v0.347 upload pack must contain exactly six files');
if (exists(`${packRoot}/compact-evidence-summary.json`)) {
  const summary = readJson(`${packRoot}/compact-evidence-summary.json`);
  assert(summary.exactlySixReviewFiles === true && summary.exactlyFourPng === true && summary.noVideo === true && summary.noTitleCardOnlyEvidence === true, 'v0.347 pack-count/video/evidence contract failed');
  assert(summary.sourceCaptureCount === 5 && summary.trueMatchedComparison?.width === 512 && summary.trueMatchedComparison?.height === 256, 'v0.347 summary source evidence contract failed');
}
for (const name of packNames.filter((name) => name.endsWith('.png'))) { const info = pngInfo(`${packRoot}/${name}`); assert(info && info.bytes > 10_000 && info.variance > 2, `invalid v0.347 review board: ${name}`); }

const reportPath = 'docs/V0347_BARN_RENDERED_GEOMETRY_ROOF_AND_GABLE_TRUTH_REPORT.md';
assert(exists(reportPath), 'v0.347 report missing');
if (exists(reportPath)) {
  const report = read(reportPath); const outcome = 'READY FOR HUMAN V0347 BARN RENDERED-GEOMETRY REVIEW';
  assert((report.match(new RegExp(outcome, 'g')) || []).length === 1, 'v0.347 READY outcome must appear exactly once');
  for (const token of ['v0.346 remains rejected by human review', 'automated visual approval remains false', packRoot, '05_true_matched_front_512x256.png', 'no default runtime integration', '20 degrees']) assert(report.toLowerCase().includes(token.toLowerCase()), `report evidence missing: ${token}`);
  assert(!report.toLowerCase().includes('v0.347 is gold') && !report.toLowerCase().includes('v0.347 approved'), 'report must not claim human approval/gold');
}

if (errors.length) { console.error(JSON.stringify({ status: 'FAIL_V0347_BARN_RENDERED_GEOMETRY_TRUTH', errors }, null, 2)); process.exit(1); }
console.log(JSON.stringify({ status: 'PASS_V0347_BARN_RENDERED_GEOMETRY_TRUTH', outcome: 'READY FOR HUMAN V0347 BARN RENDERED-GEOMETRY REVIEW', automatedVisualApproval: false, humanReviewRequired: true, sourceCaptures: 5, uploadPackFiles: 6, prototypeOnly: true, defaultRuntimeUnchanged: true, gameplayUnchanged: true }, null, 2));
