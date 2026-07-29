import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const exists = (p) => fs.existsSync(path.join(root, p));
const readJson = (p) => JSON.parse(fs.readFileSync(path.join(root, p), 'utf8'));
const sha = (p) => crypto.createHash('sha256').update(fs.readFileSync(path.join(root, p))).digest('hex');
const failures = [];
const check = (condition, message) => { if (!condition) failures.push(message); };
const requiredRaw = [
  '01_matched_house02_barn_neutral_full.png', '02_matched_roof_normal_enabled.png', '03_matched_roof_normal_disabled.png',
  '04_barn_albedo_only_roof.png', '05_neutral_barn_front_three_quarter.png', '06_direct_front.png',
  '07_complete_direct_exterior_gable.png', '08_granite_foundation_closeup.png', '09_doors_openings_closeup.png',
  '10_roof_edge_slate_irregularity.png', '11_far_rts.png', '12_true_256_pixel_source.png', '13_greyscale.png',
  '14_restrained_warm_directional.png', '15_contextual_house02_barn_hamlet.png',
];
const expectedPack = [
  '00_READ_ME_FIRST.md', '01_V0349_HUMAN_DECISION_AND_PRESERVED_BASELINE.png', '02_MATCHED_HOUSE02_BARN_NEUTRAL_VALUES.png',
  '03_SLATE_NORMAL_ENABLED_DISABLED_AND_ALBEDO.png', '04_TRADITIONAL_SLATE_VARIATION_AND_ROOF_EDGE.png',
  '05_GRANITE_GABLE_AND_FOUNDATION_CONTACT.png', '06_TIMBER_IRON_AND_REDUCED_UPPER_OPENING.png',
  '07_DIRECT_FRONT_GABLE_RTS_AND_256.png', '08_CONTEXTUAL_HAMLET_MATERIAL_UNITY.png', 'compact-evidence-summary.json',
];
if (process.argv[2] !== 'validate') throw new Error('usage: node tools/godot/saltoV0350FinalHouse02BarnMaterialUnityTool.mjs validate');

const currentHead = execFileSync('git', ['rev-parse', 'HEAD'], { cwd: root, encoding: 'utf8' }).trim();
const baseHead = '35f650d0d4dc30494bcf4111fc15906d0b0adb2c';
check(exists('art-source/blender/v0347/barn_rendered_geometry_truth.blend'), `v0.347 geometry source missing for base ${baseHead} at ${currentHead}`);
check(sha('art-source/blender/v0347/barn_rendered_geometry_truth.blend') === 'e5c8c9d561fc921f97a971110b34b706ed8dbd1824e4e451addab2ac1573a69a', 'v0.347 geometry source changed');
check(sha('desktop-spikes/godot-salto/assets/v0347/barn_rendered_geometry_truth.glb') === '0b4944d8a15006664dad84cec5e8b41546497588d14194d5b2e49621071e209c', 'v0.347 GLB carrier changed');
check(exists('art-source/blender/v0348/barn_barrosan_material_harmony.blend'), 'v0.348 UV/material source missing');
check(exists('art-source/blender/v0349/barn_final_material_harmony.blend'), 'v0.349 accepted material baseline missing');
check(!execFileSync('git', ['diff', '--name-only', '--', 'art-source/blender/v0347', 'art-source/blender/v0348', 'art-source/blender/v0349'], { cwd: root, encoding: 'utf8' }).trim(), 'retained v0.347-v0.349 source was modified');

const metricsPath = 'art-source/blender/v0350/v0350-final-house02-barn-material-unity-metrics.json';
const manifestPath = 'artifacts/runtime/v0350/v0350-final-house02-barn-material-unity-runtime.json';
const scriptPath = 'desktop-spikes/godot-salto/scripts/v0350_final_house02_barn_material_unity.gd';
const script = fs.readFileSync(path.join(root, scriptPath), 'utf8');
const metrics = readJson(metricsPath);
const manifest = readJson(manifestPath);
check(metrics.checkpoint === 'v0.350', 'v0.350 metrics checkpoint missing');
check(metrics.geometryUnchanged === true && metrics.v0348Preserved === true, 'v0.347 geometry/v0.348 UV preservation missing');
check(metrics.v0349MaterialBaselinePreserved === true, 'v0.349 material baseline preservation missing');
check(JSON.stringify(metrics.roof?.pitchDegrees) === JSON.stringify([20, 20]) && metrics.roof?.straightRidge === true, 'roof geometry contract changed');
check(metrics.roof?.principalSlopes === 2 && metrics.roof?.completeGraniteGables === 2, 'roof/gable contract incomplete');
check(metrics.albedoFirst === true && metrics.normalIntensity <= 0.1, 'albedo-first slate or restrained normal evidence missing');
check(metrics.slatePalette?.metallic === 0 && metrics.slatePalette?.roughness >= 0.94, 'slate roughness/metallic response invalid');
check(metrics.externalTextureResources?.length === 3 && metrics.embeddedImageDependency === false && metrics.fallbackMaterial === false, 'external resource truth failed');
check(metrics.openings?.reductionPercent?.width >= 12 && metrics.openings?.reductionPercent?.width <= 15, 'upper opening width reduction outside 12-15%');
check(metrics.openings?.reductionPercent?.height >= 8 && metrics.openings?.reductionPercent?.height <= 12, 'upper opening height reduction outside 8-12%');
check(metrics.openings?.lowerDoorDominant === true && metrics.openings?.lowerUpperAreaRatioRecorded === true, 'opening hierarchy evidence missing');
check(manifest.checkpoint === 'v0.350' && manifest.rawCaptureCount === 15, 'runtime manifest does not contain exactly fifteen raw captures');
check(manifest.outcome === 'READY FOR HUMAN V0350 FINAL HOUSE02/BARN MATERIAL-UNITY REVIEW', 'automatic outcome is not the required human-review handoff');
check(manifest.defaultRuntimeIntegrated === false && manifest.prototypeOnly === true, 'prototype is not isolated from default runtime');
check(manifest.noGameplay && manifest.noMovement && manifest.noPathfinding && manifest.noCombat && manifest.noEconomy && manifest.noResources, 'forbidden gameplay mutation flag present');
check(script.includes('V0350_Shared_Neutral_Overcast_Key') && script.includes('light_energy = 1.08'), 'shared neutral lighting fixture missing');
check(script.includes('V0350_Upper_Loading_Opening_Reduced_13x10_Percent'), 'permitted upper-opening reduction is not explicit');
check(script.includes('V0350_Context_Workers_Review_Only'), 'contextual hamlet dressing is missing');
check(script.includes('normal_enabled') || script.includes('_set_slate_normal'), 'normal enabled/disabled capture control missing');
check(script.includes('V0350_Barrosan_Albedo_First_Weathered_Slate'), 'deterministic v0.350 slate material missing');
check(!script.includes('GOLD') && !script.includes('PRODUCTION_READY'), 'automatic gold/production claim present');

for (const name of requiredRaw) {
  const file = path.join(root, 'artifacts/runtime/v0350/screenshots', name);
  check(fs.existsSync(file) && fs.statSync(file).size > 256, `missing or empty raw capture: ${name}`);
  if (fs.existsSync(file)) check(fs.readFileSync(file).subarray(0, 8).equals(Buffer.from([137,80,78,71,13,10,26,10])), `raw capture is not PNG: ${name}`);
}
const packPath = path.join(root, 'artifacts/manual-review/v0350-final-house02-barn-material-unity/UPLOAD_TO_CHAT');
if (fs.existsSync(packPath)) {
  const files = fs.readdirSync(packPath).filter((f) => fs.statSync(path.join(packPath, f)).isFile()).sort();
  check(JSON.stringify(files) === JSON.stringify([...expectedPack].sort()), 'review pack is not exactly ten files');
  check(files.filter((f) => f.toLowerCase().endsWith('.png')).length === 8, 'review pack does not contain exactly eight PNG boards');
  check(!files.some((f) => /\.mp4$|\.webm$|\.mov$/i.test(f)), 'review pack contains video');
} else check(false, 'v0.350 review pack missing; build it only after visual inspection');

if (failures.length) { console.error('FAIL_V0350_FINAL_HOUSE02_BARN_MATERIAL_UNITY_VALIDATION'); for (const failure of failures) console.error(`- ${failure}`); process.exit(1); }
console.log(fs.existsSync(packPath) ? 'PASS_V0350_FINAL_HOUSE02_BARN_MATERIAL_UNITY_VALIDATION' : 'PASS_V0350_FINAL_HOUSE02_BARN_MATERIAL_UNITY_CAPTURE_GATE (review pack pending visual approval)');
