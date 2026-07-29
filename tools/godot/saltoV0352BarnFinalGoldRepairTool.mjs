import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const failures = [];
const check = (condition, message) => { if (!condition) failures.push(message); };
const exists = (p) => fs.existsSync(path.join(root, p));
const json = (p) => JSON.parse(fs.readFileSync(path.join(root, p), 'utf8'));
const sha = (p) => crypto.createHash('sha256').update(fs.readFileSync(path.join(root, p))).digest('hex');
if (process.argv[2] !== 'validate') throw new Error('usage: node tools/godot/saltoV0352BarnFinalGoldRepairTool.mjs validate');

const baseHead = 'c029305be963353e122da669e67d7d33b8d06c0a';
const currentHead = execFileSync('git', ['rev-parse', 'HEAD'], { cwd: root, encoding: 'utf8' }).trim();
check(currentHead.length === 40, 'current HEAD is missing');
check(exists('art-source/blender/v0352/v0352-barn-final-gold-repair-metrics.json'), 'v0.352 metrics missing');
const metrics = exists('art-source/blender/v0352/v0352-barn-final-gold-repair-metrics.json') ? json('art-source/blender/v0352/v0352-barn-final-gold-repair-metrics.json') : {};
const scriptPath = 'desktop-spikes/godot-salto/scripts/v0352_barn_final_gold_repair.gd';
const scenePath = 'desktop-spikes/godot-salto/scenes/review/V0352BarnFinalGoldRepair.tscn';
const script = exists(scriptPath) ? fs.readFileSync(path.join(root, scriptPath), 'utf8') : '';
const manifestPath = 'artifacts/runtime/v0352/v0352-barn-final-gold-repair-runtime.json';
check(exists(manifestPath), 'v0.352 runtime manifest missing; run capture first');
const manifest = exists(manifestPath) ? json(manifestPath) : {};

check(exists('art-source/blender/v0350/v0350-final-house02-barn-material-unity-metrics.json'), 'frozen v0.350 metrics missing');
const frozen = exists('art-source/blender/v0350/v0350-final-house02-barn-material-unity-metrics.json') ? json('art-source/blender/v0350/v0350-final-house02-barn-material-unity-metrics.json') : {};
check(sha('art-source/blender/v0350/barn_final_material_harmony.blend') === frozen.finalHashes?.blend, 'v0.350 blend changed');
check(sha('desktop-spikes/godot-salto/assets/v0350/barn_final_material_harmony.glb') === frozen.finalHashes?.glb, 'v0.350 GLB changed');
check(sha('desktop-spikes/godot-salto/assets/v0350/v0350_traditional_slate_courses_albedo.png') === 'cb14b8726702843f8b8811068d9f9d0c17abf3cc278c82070916813bb4ec4f34', 'v0.350 slate albedo changed');
check(sha('desktop-spikes/godot-salto/assets/v0350/v0350_traditional_slate_courses_normal.png') === '97909dac106323b1cb8de95b98c8a95afd67a3ea4bfae86eb1385fa541d4f8ca', 'v0.350 slate normal changed');
check(sha('desktop-spikes/godot-salto/assets/v0350/v0350_traditional_slate_courses_roughness.png') === 'fc7f2113d44ab1ef6e1a9968c7c0b4c971c8611a5a98684e8880b7a0499916cf', 'v0.350 slate roughness changed');
check(sha('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate_gold_candidate_rubble_albedo.png') === '2b363f0b7cf1d023712d3a12041045f18890e0f4d4f5ed6f4ca3f48ef8d6d083', 'frozen granite changed');
check(sha('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate_timber_albedo_1024.png') === 'a28bd7ccc7357c22f72bd28b3d5721e73b71e03355e72c622de345f9dc7c48cd', 'frozen timber changed');
const retainedDiff = execFileSync('git', ['diff', 'HEAD', '--name-only', '--', 'art-source/blender/v0347', 'art-source/blender/v0348', 'art-source/blender/v0349', 'art-source/blender/v0350', 'desktop-spikes/godot-salto/assets/v0347', 'desktop-spikes/godot-salto/assets/v0348', 'desktop-spikes/godot-salto/assets/v0350'], { cwd: root, encoding: 'utf8' }).trim();
check(!retainedDiff, `accepted v0.347-v0.350 assets modified: ${retainedDiff}`);

check(exists(scenePath), 'v0.352 review scene missing');
check(script.includes('V0352_Roof_Visibility_Repair_Closed_Underside_Only'), 'minimal closed-roof repair missing');
check(script.includes('V0352_Roof_Left_Closed_Exterior_Slope') && script.includes('V0352_Roof_Right_Closed_Exterior_Slope'), 'both repaired roof slopes missing');
check(script.includes('rotation_degrees.x = 20.0') && script.includes('rotation_degrees.x = -20.0'), 'roof slope pitch repair not explicit');
check(script.includes('BaseMaterial3D.CULL_BACK') && !script.includes('CULL_DISABLED'), 'ordinary backface culling was not retained');
check(!script.includes('roof.visible = false') && !script.includes('Roof.visible = false'), 'camera-specific roof hiding present');
check(script.includes('V0351_Upper_Loading_Shutters_Two_Closed_Leaves'), 'accepted v0.351 shutter group missing');
check(script.includes('V0351_Shutter_Left_Closed_Timber_Leaf') && script.includes('V0351_Shutter_Right_Closed_Timber_Leaf'), 'accepted shutter leaves missing');
check(script.includes('V0351_Shutter_Vertical_Board_Seam') && script.includes('V0351_Shutter_Central_Meeting_Seam'), 'accepted shutter board/seam treatment missing');
check(!script.includes('QuadMesh.new(); footprint.size') && !script.includes('V0351_Coherent_Footprint_Contact_Shadow'), 'rectangular v0.351 contact plane retained');
check(script.includes('SphereMesh.new()') && script.includes('V0352_Organic_Contact_'), 'organic rounded contact treatment missing');
check(!script.includes('V0351_Foundation_Left_Corner') && !script.includes('V0351_Foundation_Right_Corner'), 'floating foundation debris retained');
check(script.includes('V0352_Contextual_Workers_Complete_Review_Only') && script.includes('V0352_Complete_Worker_Near_House02') && script.includes('V0352_Complete_Worker_Near_Barn'), 'context worker fixture missing');
check(script.includes('Vector3(-18,10.5,26)') && script.includes('three-quarter'), 'contextual three-quarter camera missing');
check(script.includes('V0352_DEBUG_REVIEW_Opening_Contact_Roof_Readout') && script.includes('roof slopes 2') && script.includes('cull back'), 'DEBUG_REVIEW roof/contact evidence missing');
check(script.includes('PROJECTION_ORTHOGONAL'), 'normal RTS orthographic camera missing');

check(metrics.checkpoint === 'v0.352', 'metrics checkpoint invalid');
check(metrics.frozenV0351Shutters === true && metrics.shutterLeafCount === 2 && metrics.shutterPrimaryBoardOrientation === 'vertical', 'frozen shutter contract invalid');
check(metrics.lowerUpperAreaRatio >= 3.64, 'lower/upper area ratio below 3.64');
check(metrics.roof?.pitchDegrees?.[0] === 20 && metrics.roof?.pitchDegrees?.[1] === 20, 'roof pitch changed');
check(metrics.roof?.principalSlopes === 2 && metrics.roof?.straightRidge === true, 'roof slope/ridge contract invalid');
check(metrics.defaultRuntimeIntegrated === false && metrics.noGameplay === true, 'default-runtime/gameplay isolation missing');

check(manifest.checkpoint === 'v0.352' && manifest.rawCaptureCount >= 20, 'v0.352 manifest capture count/checkpoint invalid');
check(manifest.outcome === 'READY FOR HUMAN V0352 BARN FINAL-GOLD REVIEW', 'required v0.352 human-review outcome missing');
check(manifest.oldRoofGeometryHash === '0b4944d8a15006664dad84cec5e8b41546497588d14194d5b2e49621071e209c', 'old roof geometry hash missing');
check(manifest.newRoofGeometryHash === '0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9', 'new roof repair hash missing');
check(manifest.roofExteriorOrbitViewCount >= 8 && manifest.missingRoofSlopeCount === 0 && manifest.exteriorCutawayCount === 0 && manifest.roofInteriorExposureCount === 0 && manifest.hiddenRoofNodeCount === 0, 'exterior roof orbit gate failed');
check(manifest.visibleRectangularContactArtifactCount === 0 && manifest.visibleDecalBoundaryCount === 0 && manifest.floatingFoundationGeometryCount === 0, 'organic foundation gate failed');
check(manifest.contextualCameraMode === 'three-quarter RTS' && manifest.completeWorkerCount === 2 && manifest.minimumContextWorkerPixelHeight >= 20, 'context PLAYER worker proof contract failed');
check(manifest.actual256SourceDimensions === '256x256', 'actual 256x256 capture contract missing');
check(manifest.defaultRuntimeIntegrated === false && manifest.noGameplay === true && manifest.noMovement === true && manifest.noPathfinding === true && manifest.noCombat === true && manifest.noEconomy === true && manifest.noResources === true, 'forbidden runtime mutation flag present');
check(manifest.captures?.filter((capture) => capture.technicalOverlay === true).length === 1, 'DEBUG_REVIEW capture count is not exactly one');
check(manifest.captures?.some((capture) => capture.fileName === '18_contextual_three_quarter_player.png' && capture.technicalOverlay === false), 'clean contextual PLAYER capture missing');

const rawDir = path.join(root, 'artifacts/runtime/v0352/screenshots');
const rawFiles = exists('artifacts/runtime/v0352/screenshots') ? fs.readdirSync(rawDir).filter((f) => f.toLowerCase().endsWith('.png')) : [];
check(rawFiles.length >= 20, `expected at least twenty raw PNG captures, found ${rawFiles.length}`);
for (const file of rawFiles) check(fs.statSync(path.join(rawDir, file)).size > 256, `raw capture empty: ${file}`);
for (const required of manifest.requiredRawNames ?? []) check(rawFiles.includes(required), `required raw capture missing: ${required}`);
const packDir = path.join(root, 'artifacts/manual-review/v0352-barn-final-gold-repair/UPLOAD_TO_CHAT');
const packFiles = exists('artifacts/manual-review/v0352-barn-final-gold-repair/UPLOAD_TO_CHAT') ? fs.readdirSync(packDir).filter((f) => fs.statSync(path.join(packDir, f)).isFile()).sort() : [];
const expectedPack = ['00_READ_ME_FIRST.md','01_V0351_HUMAN_DECISION_AND_FROZEN_SHUTTERS.png','02_FINAL_BARN_FRONT_AND_DIRECT_FRONT.png','03_COMPLETE_EXTERIOR_ROOF_ORBIT_PROOF.png','04_REAR_GABLE_AND_ROOF_VISIBILITY.png','05_ORGANIC_FOUNDATION_CONTACT.png','06_HOUSE02_BARN_MATCHED_MATERIAL_UNITY.png','07_RTS_256_GREYSCALE_AND_WARM.png','08_CONTEXTUAL_THREE_QUARTER_PLAYER_PROOF.png','compact-evidence-summary.json'];
check(JSON.stringify(packFiles) === JSON.stringify(expectedPack), 'review pack is not exactly ten required files');
check(packFiles.filter((f) => f.toLowerCase().endsWith('.png')).length === 8, 'review pack does not contain exactly eight PNG boards');
check(!packFiles.some((f) => /\.mp4$|\.webm$|\.mov$/i.test(f)), 'review pack contains video');
check(!script.includes('PRODUCTION_READY') && !script.includes('AUTOMATIC_GOLD_APPROVAL'), 'automatic gold/production claim present');

if (failures.length) { console.error('FAIL_V0352_BARN_FINAL_GOLD_REPAIR_VALIDATION'); for (const failure of failures) console.error(`- ${failure}`); process.exit(1); }
console.log('PASS_V0352_BARN_FINAL_GOLD_REPAIR_VALIDATION');
