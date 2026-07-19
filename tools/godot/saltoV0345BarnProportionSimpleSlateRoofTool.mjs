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

const OUTCOME = 'READY FOR HUMAN V0345 BARN PROPORTION-AND-ROOF VISUAL REVIEW';
const FROZEN_HOUSE02_BLEND = '3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6';
const FROZEN_HOUSE02_GLB = 'ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89';
const V0343_BLEND = 'ecb268c7a4f69c914951a0dbd9494fb332003566073b2311b47a348ba9f831e9';
const V0343_GLB = 'd4d780510b1812e7e4f082f24dfee049ab21f905acbaaeaa4f54d6f67b4118b9';
const V0344_BLEND = 'd63a8364f3edb10d20926a45dd52a41c8d0b8042fe707cf2aae267fbc63ac198';
const V0344_GLB = '76cd62330d4cb4073469fe51e510557d93dcc0d9a07e9f234a539561abda7015';
const runtime = 'artifacts/runtime/v0345';
const manifestPath = `${runtime}/v0345-barn-proportion-simple-slate-roof-runtime.json`;
const reportPath = 'docs/V0345_BARN_PROPORTION_AND_SIMPLE_SLATE_ROOF_REPORT.md';
const packRoot = 'artifacts/manual-review/v0345-barn-proportion-and-simple-slate-roof/UPLOAD_TO_CHAT';
const packNames = ['00_READ_ME_FIRST.md', '01_PROPORTION_RESET_AND_HOUSE02_SCALE.png', '02_UNLABELLED_FRONT_REAR_AND_GABLE.png', '03_SIMPLE_TWO_SLOPE_SLATE_ROOF.png', '04_TRUE_MATCHED_512X256_COMPARISON.png', 'compact-evidence-summary.json'];
const sourceNames = ['01_front_three_quarter.png', '02_rear_three_quarter.png', '03_direct_side_gable.png', '04_close_roof_front_material.png', '05_true_matched_512x256_house02_barn.png'];

function pngInfo(relative) {
  if (!exists(relative)) return null;
  const bytes = fs.readFileSync(abs(relative));
  if (bytes.length < 24 || bytes.readUInt32BE(0) !== 0x89504e47) return null;
  let sum = 0; let sum2 = 0; const step = Math.max(1, Math.floor(bytes.length / 5000));
  for (let i = 100; i < bytes.length; i += step) { sum += bytes[i]; sum2 += bytes[i] * bytes[i]; }
  const n = Math.max(1, Math.ceil((bytes.length - 100) / step));
  return { width: bytes.readUInt32BE(16), height: bytes.readUInt32BE(20), bytes: bytes.length, variance: sum2 / n - (sum / n) ** 2 };
}

for (const file of [
  'art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend',
  'desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb',
  'art-source/blender/v0343/house02_derived_barrosan_barn_visual_preflight.blend',
  'desktop-spikes/godot-salto/assets/v0343/house02_derived_barrosan_barn_visual_preflight.glb',
  'art-source/blender/v0344/barn_front_granite_roof_edge_visual_preflight.blend',
  'desktop-spikes/godot-salto/assets/v0344/barn_front_granite_roof_edge_visual_preflight.glb',
  'art-source/blender/v0345/v0344_source_duplicate_for_v0345.blend',
  'art-source/blender/v0345/barn_proportion_simple_slate_roof_reset.blend',
  'desktop-spikes/godot-salto/assets/v0345/barn_proportion_simple_slate_roof_reset.glb',
  'art-source/blender/v0345/v0345-roof-object-diagnosis.json',
  'art-source/blender/v0345/v0345-barn-metrics.json',
  'art-source/blender/v0345/v0345-source-lineage.json',
  'desktop-spikes/godot-salto/scenes/review/V0345BarnProportionSimpleSlateRoofReset.tscn',
  'desktop-spikes/godot-salto/scripts/v0345_barn_proportion_simple_slate_roof_reset.gd',
  'tools/blender/generateV0345BarnProportionSimpleSlateRoof.py',
  'tools/blender/generateV0345BarnProportionSimpleSlateRoofWindows.ps1',
  'tools/godot/captureGodotV0345BarnProportionSimpleSlateRoofWindows.ps1',
  'tools/godot/buildV0345BarnProportionSimpleSlateRoofPack.ps1',
  reportPath,
]) assert(exists(file), `required v0.345 file missing: ${file}`);

assert(sha256('art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend') === FROZEN_HOUSE02_BLEND, 'frozen House02 Blend changed');
assert(sha256('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb') === FROZEN_HOUSE02_GLB, 'frozen House02 GLB changed');
assert(sha256('art-source/blender/v0343/house02_derived_barrosan_barn_visual_preflight.blend') === V0343_BLEND, 'v0.343 Blend changed');
assert(sha256('desktop-spikes/godot-salto/assets/v0343/house02_derived_barrosan_barn_visual_preflight.glb') === V0343_GLB, 'v0.343 GLB changed');
assert(sha256('art-source/blender/v0344/barn_front_granite_roof_edge_visual_preflight.blend') === V0344_BLEND, 'v0.344 Blend changed');
assert(sha256('desktop-spikes/godot-salto/assets/v0344/barn_front_granite_roof_edge_visual_preflight.glb') === V0344_GLB, 'v0.344 GLB changed');
assert(sha256('art-source/blender/v0345/v0344_source_duplicate_for_v0345.blend') === V0344_BLEND, 'v0.345 v0.344 source duplicate is not byte-identical');

const lineage = readJson('art-source/blender/v0345/v0345-source-lineage.json');
assert(lineage.checkpoint === 'v0.345' && lineage.v0344Untouched === true && lineage.v0343Untouched === true && lineage.house02Untouched === true, 'v0.345 lineage preservation contract failed');
assert(lineage.copiedV0344SourceSha256 === V0344_BLEND && lineage.noV0341VisibleDependency === true && lineage.noV0342VisibleDependency === true, 'v0.345 source lineage/hash contract failed');

const metrics = readJson('art-source/blender/v0345/v0345-barn-metrics.json');
const ratios = metrics.ratiosAfter || {};
for (const [key, min, max] of [['ridgeHeight', 1.0, 1.2], ['eaveHeight', 0.95, 1.15], ['frontWidth', 1.1, 1.4], ['depth', 0.95, 1.3]]) assert(ratios[key] >= min && ratios[key] <= max, `House02-relative ${key} ratio is outside v0.345 bounds`);
assert(metrics.prototypeOnly === true && metrics.defaultRuntimeIntegrated === false, 'prototype-only/default-runtime isolation failed');
assert(metrics.roof?.principalSlopes === 2 && metrics.roof?.frontSlope === true && metrics.roof?.rearSlope === true && metrics.roof?.straightRidge === true, 'simple two-slope roof contract failed');
for (const key of ['secondaryRoofNodes', 'pedimentNodes', 'paleRoofFaces', 'graniteRoofFaces', 'placeholderRoofFaces', 'floatingRoofPieces', 'intersectingSecondaryRoofPieces']) assert(metrics.roof?.[key] === 0, `roof defect count is nonzero: ${key}`);
assert(metrics.roof?.restoredLeftGraniteGable === true, 'restored side-gable closure is missing');
assert(metrics.openings?.lowerDoubleLivestockDoor === true && metrics.openings?.upperHayLoadingOpening === true && metrics.openings?.rearServiceOpening === true, 'agricultural opening contract failed');
for (const material of ['V0344_House02Derived_Granite_Continuous', 'V0345_Simple_Weathered_Slate', 'V0345_Simple_Weathered_Slate_Underside', 'V0345_Subordinate_Dark_Timber_Roof_Edge']) assert(metrics.usedMaterials?.includes(material), `required retained/new material missing: ${material}`);
assert(fs.statSync(abs('desktop-spikes/godot-salto/assets/v0345/barn_proportion_simple_slate_roof_reset.glb')).size < 20_000_000, 'unapproved large v0.345 asset import');

const generator = read('tools/blender/generateV0345BarnProportionSimpleSlateRoof.py').toLowerCase();
const scene = read('desktop-spikes/godot-salto/scenes/review/V0345BarnProportionSimpleSlateRoofReset.tscn');
const script = read('desktop-spikes/godot-salto/scripts/v0345_barn_proportion_simple_slate_roof_reset.gd');
assert(scene.includes('[node name="V0345BarnProportionSimpleSlateRoofReset" type="Node3D"]'), 'scene is not isolated Node3D');
for (const token of ['generatev0341', 'generatev0342', 'warcraft', 'blizzard', 'age of empires']) assert(!generator.includes(token), `forbidden dependency/provenance token: ${token}`);
for (const token of ['move_and_slide', 'NavigationAgent', 'projectile', 'save_game', 'instantiate_enemy', 'resource_mutation']) assert(!script.toLowerCase().includes(token.toLowerCase()), `forbidden gameplay coupling: ${token}`);
for (const token of ['V0345_Stable_Oblique_Barn_Camera', 'PROJECTION_ORTHOGONAL', 'V0345_Frozen_House02_Unmodified_Anchor', 'V0345_Barn_Proportion_Reset_Candidate', '05_true_matched_512x256_house02_barn.png', 'prototypeOnly', 'defaultRuntimeIntegrated']) assert(script.includes(token), `capture/isolation contract missing: ${token}`);

const report = read(reportPath);
assert((report.match(new RegExp(OUTCOME, 'g')) || []).length === 1, 'v0.345 human-review outcome must appear exactly once in report');
for (const token of ['v0.344 human rejection', 'automated visual approval remains false', '05_true_matched_512x256_house02_barn.png', 'no gameplay', 'no default runtime integration', packRoot]) assert(report.toLowerCase().includes(token.toLowerCase()), `report evidence missing: ${token}`);
const packageText = read('package.json');
for (const command of ['blender:generate:salto-v0345-barn-proportion-and-simple-slate-roof', 'godot:capture:salto-v0345-barn-proportion-and-simple-slate-roof', 'godot:pack:salto-v0345-barn-proportion-and-simple-slate-roof', 'godot:validate:salto-v0345-barn-proportion-and-simple-slate-roof']) assert(packageText.includes(command), `package command missing: ${command}`);

const packFiles = exists(packRoot) ? fs.readdirSync(abs(packRoot)).filter((name) => fs.statSync(abs(`${packRoot}/${name}`)).isFile()).sort() : [];
assert(JSON.stringify(packFiles) === JSON.stringify([...packNames].sort()), 'v0.345 upload pack must contain exactly six files');
if (exists(`${packRoot}/compact-evidence-summary.json`)) { const summary = readJson(`${packRoot}/compact-evidence-summary.json`); assert(summary.exactlySixReviewFiles === true || summary.exactUploadFileCount === 6 || packFiles.length === 6, 'v0.345 upload pack summary count mismatch'); }
for (const name of packNames.filter((name) => name.endsWith('.png'))) { const info = pngInfo(`${packRoot}/${name}`); assert(info && info.bytes > 10000 && info.variance > 2, `invalid v0.345 upload board: ${name}`); }

if (exists(manifestPath)) {
  const manifest = readJson(manifestPath);
  assert(manifest.checkpoint === 'v0.345' && manifest.status === 'PASS_V0345_BARN_PROPORTION_SIMPLE_SLATE_ROOF' && manifest.outcome === OUTCOME, 'runtime manifest gate metadata mismatch');
  assert(manifest.captureCount === 5 && manifest.errors?.length === 0 && manifest.house02RenderedDirectlyInCapture5 === true && manifest.defaultRuntimeIntegrated === false, 'runtime capture manifest incomplete');
  for (const name of sourceNames) { const info = pngInfo(`${runtime}/screenshots/${name}`); assert(info && info.bytes > 10000 && info.variance > 2, `invalid v0.345 source capture: ${name}`); }
  const matched = pngInfo(`${runtime}/screenshots/05_true_matched_512x256_house02_barn.png`); assert(matched?.width === 512 && matched?.height === 256, 'true matched source capture is not 512x256');
} else {
  assert(exists(`${packRoot}/04_TRUE_MATCHED_512X256_COMPARISON.png`), 'runtime absent and matched comparison board is missing');
}

if (errors.length) {
  console.error(JSON.stringify({ status: 'FAIL_V0345_BARN_PROPORTION_SIMPLE_SLATE_ROOF', errors }, null, 2));
  process.exit(1);
}
console.log(JSON.stringify({ status: 'PASS_V0345_BARN_PROPORTION_SIMPLE_SLATE_ROOF', outcome: OUTCOME, automatedVisualApproval: false, humanReviewRequired: true, sourceCaptures: 5, uploadPackFiles: 6, prototypeOnly: true, defaultRuntimeUnchanged: true, gameplayUnchanged: true }, null, 2));
