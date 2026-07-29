import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const fail = [];
const exists = (p) => fs.existsSync(path.join(root, p));
const readJson = (p) => JSON.parse(fs.readFileSync(path.join(root, p), 'utf8'));
const sha = (p) => crypto.createHash('sha256').update(fs.readFileSync(path.join(root, p))).digest('hex');
const check = (condition, message) => { if (!condition) fail.push(message); };

const v0347Blend = 'art-source/blender/v0347/barn_rendered_geometry_truth.blend';
const v0347Glb = 'desktop-spikes/godot-salto/assets/v0347/barn_rendered_geometry_truth.glb';
const v0348Source = 'art-source/blender/v0348/barn_barrosan_material_harmony.blend';
const metricsPath = 'art-source/blender/v0349/v0349-final-barn-material-harmony-metrics.json';
const manifestPath = 'artifacts/runtime/v0349/v0349-final-barn-material-harmony-runtime.json';
const screenshots = 'artifacts/runtime/v0349/screenshots';
const pack = 'artifacts/manual-review/v0349-final-barn-material-harmony/UPLOAD_TO_CHAT';
const requiredRaw = [
  '01_house02_barn_roof_normal_enabled.png', '02_house02_barn_roof_normal_disabled.png',
  '03_barn_roof_albedo_only.png', '04_neutral_front_three_quarter.png', '05_direct_front.png',
  '06_direct_granite_gable.png', '07_openings_foundation_closeup.png', '08_far_rts.png',
  '09_256_pixel_source.png', '10_greyscale.png', '11_warm_directional.png', '12_roof_edge_closeup.png',
];
const expectedPack = [
  '00_READ_ME_FIRST.md', '01_V0348_HUMAN_REJECTION_AND_PRESERVED_FOUNDATION.png',
  '02_FINAL_NEUTRAL_FRONT_AND_GABLE.png', '03_HOUSE02_BARN_SLATE_NORMAL_ENABLED.png',
  '04_HOUSE02_BARN_SLATE_NORMAL_DISABLED_AND_ALBEDO.png', '05_ROOF_EDGE_AND_SLATE_DETAIL.png',
  '06_GRANITE_FOUNDATION_TIMBER_AND_OPENINGS.png', '07_RTS_256_GREYSCALE_AND_WARM.png',
  '08_TRUE_MATCHED_HOUSE02_BARN.png', 'compact-evidence-summary.json',
];

if (process.argv[2] !== 'validate') throw new Error('usage: node tools/godot/saltoV0349FinalBarnMaterialHarmonyTool.mjs validate');
const currentHead = execFileSync('git', ['rev-parse', 'HEAD'], { cwd: root, encoding: 'utf8' }).trim();
const baseHead = '38a1007110c8bb04e48e97134e66732c5bcdf5f0';
check(exists(v0347Blend), `preserved v0.347 geometry source missing for base ${baseHead} (current ${currentHead})`);
check(sha(v0347Blend) === 'e5c8c9d561fc921f97a971110b34b706ed8dbd1824e4e451addab2ac1573a69a', 'v0.347 Blend geometry carrier changed');
check(sha(v0347Glb) === '0b4944d8a15006664dad84cec5e8b41546497588d14194d5b2e49621071e209c', 'v0.347 GLB geometry carrier changed');
check(exists(v0348Source), 'v0.348 material/UV source was not retained');
check(!execFileSync('git', ['diff', '--name-only', '--', 'art-source/blender/v0347', 'art-source/blender/v0348'], { cwd: root, encoding: 'utf8' }).trim(), 'v0.347/v0.348 tracked source was modified');

const metrics = readJson(metricsPath);
const manifest = readJson(manifestPath);
check(metrics.checkpoint === 'v0.349', 'v0.349 metrics checkpoint missing');
check(metrics.geometryUnchanged === true && metrics.v0348Preserved === true, 'frozen geometry/UV preservation is not recorded');
check(metrics.roof?.pitchDegrees?.[0] === 20 && metrics.roof?.pitchDegrees?.[1] === 20 && metrics.roof?.straightRidge === true, 'roof geometry contract changed');
check(metrics.roof?.principalSlopes === 2 && metrics.roof?.secondaryRoofNodes === 0 && metrics.roof?.completeGraniteGables === 2, 'roof/gable contract incomplete');
check(metrics.albedoFirst === true && metrics.normalIntensity <= 0.1, 'slate is not albedo-first or normal intensity remains too high');
check(metrics.slatePalette?.metallic === 0 && metrics.slatePalette?.roughness >= 0.94, 'slate response is not rough non-metallic');
check(metrics.externalTextureResources?.length === 3 && metrics.embeddedImageDependency === false && metrics.fallbackMaterial === false, 'explicit material-resource truth failed');
check(metrics.foundationWeathering?.uniformStripe === false && metrics.foundationWeathering?.floatingGeometry === false, 'foundation weathering is not restrained');
check(metrics.openings?.lowerDoorDominant === true && metrics.openings?.upperOpeningSubordinate === true, 'opening hierarchy evidence missing');
check(manifest.checkpoint === 'v0.349' && manifest.rawCaptureCount === 12 && manifest.defaultRuntimeIntegrated === false, 'runtime manifest is not the isolated twelve-capture fixture');
check(manifest.outcome === 'READY FOR HUMAN V0349 FINAL BARN MATERIAL-HARMONY REVIEW', 'automatic outcome is not the required human-review handoff');
check(manifest.noGameplay && manifest.noMovement && manifest.noPathfinding && manifest.noCombat && manifest.noEconomy && manifest.noResources, 'forbidden runtime mutation flag present');
for (const name of requiredRaw) {
  const p = path.join(root, screenshots, name);
  check(fs.existsSync(p) && fs.statSync(p).size > 256, `missing or empty raw capture: ${name}`);
  if (fs.existsSync(p)) check(fs.readFileSync(p).subarray(0, 8).equals(Buffer.from([137,80,78,71,13,10,26,10])), `raw capture is not PNG: ${name}`);
}
const packExists = fs.existsSync(path.join(root, pack));
if (packExists) {
  const files = fs.readdirSync(path.join(root, pack)).filter((f) => fs.statSync(path.join(root, pack, f)).isFile()).sort();
  check(JSON.stringify(files) === JSON.stringify([...expectedPack].sort()), 'review pack is not exactly ten files');
  check(files.filter((f) => f.toLowerCase().endsWith('.png')).length === 8, 'review pack does not contain exactly eight PNG boards');
  check(!files.some((f) => /\.mp4$|\.webm$|\.mov$/i.test(f)), 'review pack contains video');
} else {
  fail.push('review pack is not present yet; create it only after visual gate inspection');
}
const forbidden = ['movement', 'pathfinding', 'combat', 'economy', 'resource mutation', 'default runtime'];
const v0349Script = fs.readFileSync(path.join(root, 'desktop-spikes/godot-salto/scripts/v0349_barn_final_material_harmony.gd'), 'utf8');
check(v0349Script.includes('res://assets/v0349/v0349_weathered_slate_courses_albedo.png'), 'Godot fixture does not expose v0.349 albedo path');
check(v0349Script.includes('normal_scale = 0.08'), 'Godot fixture does not expose reduced normal scale');
check(v0349Script.includes('V0349_Final_Material_Harmony_Review_Only') || v0349Script.includes('V0349_Barn_Final_Material_Harmony_Review_Only'), 'review-only fixture identity missing');
check(forbidden.every((word) => manifest.noGameplay || word !== 'resource mutation'), 'forbidden gameplay flags were not retained');

if (fail.length) {
  console.error('FAIL_V0349_FINAL_BARN_MATERIAL_HARMONY_VALIDATION');
  for (const item of fail) console.error(`- ${item}`);
  process.exit(1);
}
console.log(packExists ? 'PASS_V0349_FINAL_BARN_MATERIAL_HARMONY_VALIDATION' : 'PASS_V0349_FINAL_BARN_MATERIAL_HARMONY_CAPTURE_GATE (review pack pending visual approval)');
