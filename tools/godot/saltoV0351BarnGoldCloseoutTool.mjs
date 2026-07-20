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
if (process.argv[2] !== 'validate') throw new Error('usage: node tools/godot/saltoV0351BarnGoldCloseoutTool.mjs validate');

const baseHead = '896370138335029647209d2faeab7d8bdaaf894e';
const currentHead = execFileSync('git', ['rev-parse', 'HEAD'], { cwd: root, encoding: 'utf8' }).trim();
check(currentHead === baseHead || currentHead !== '', `current HEAD missing while deriving from v0.350 ${baseHead}`);
check(exists('art-source/blender/v0351/v0351-barn-gold-closeout-metrics.json'), 'v0.351 metrics missing');
const metrics = json('art-source/blender/v0351/v0351-barn-gold-closeout-metrics.json');
const scriptPath = 'desktop-spikes/godot-salto/scripts/v0351_barn_gold_closeout.gd';
const script = fs.readFileSync(path.join(root, scriptPath), 'utf8');
const manifestPath = 'artifacts/runtime/v0351/v0351-barn-gold-closeout-runtime.json';
check(exists(manifestPath), 'v0.351 runtime manifest missing; run capture first');
const manifest = exists(manifestPath) ? json(manifestPath) : {};

const frozen = metrics.frozenV0350;
check(sha('art-source/blender/v0350/barn_final_material_harmony.blend') === frozen.blend, 'v0.350 blend hash changed');
check(sha('desktop-spikes/godot-salto/assets/v0350/barn_final_material_harmony.glb') === frozen.glb, 'v0.350 roof/geometry carrier hash changed');
check(sha('desktop-spikes/godot-salto/assets/v0350/v0350_traditional_slate_courses_albedo.png') === frozen.slateAlbedo, 'v0.350 slate albedo hash changed');
check(sha('desktop-spikes/godot-salto/assets/v0350/v0350_traditional_slate_courses_normal.png') === frozen.slateNormal, 'v0.350 slate normal hash changed');
check(sha('desktop-spikes/godot-salto/assets/v0350/v0350_traditional_slate_courses_roughness.png') === frozen.slateRoughness, 'v0.350 slate roughness hash changed');
check(sha('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate_gold_candidate_rubble_albedo.png') === frozen.granite, 'frozen granite resource changed');
check(sha('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate_timber_albedo_1024.png') === frozen.timber, 'frozen timber resource changed');
check(sha('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate_timber_roughness_1024.png') === frozen.timberRoughness, 'frozen timber roughness resource changed');

const retainedDiff = execFileSync('git', ['diff', '--name-only', '--', 'art-source/blender/v0347', 'art-source/blender/v0348', 'art-source/blender/v0349', 'art-source/blender/v0350', 'desktop-spikes/godot-salto/assets/v0350'], { cwd: root, encoding: 'utf8' }).trim();
check(!retainedDiff, `accepted v0.347-v0.350 assets modified: ${retainedDiff}`);
check(exists('desktop-spikes/godot-salto/scenes/review/V0351BarnGoldCloseout.tscn'), 'v0.351 review scene missing');
check(script.includes('V0351_Upper_Loading_Shutters_Two_Closed_Leaves'), 'two-leaf shutter group missing');
check(script.includes('V0351_Shutter_Left_Closed_Timber_Leaf') && script.includes('V0351_Shutter_Right_Closed_Timber_Leaf'), 'exact shutter leaves missing');
check(script.includes('V0351_Shutter_Central_Meeting_Seam') && script.includes('V0351_Shutter_Vertical_Board_Seam'), 'vertical shutter-board/seam treatment missing');
check(!script.includes('UpperOpening_Center_Iron') && !script.includes('Upper_Loading_Opening_Reduced_13x10_Percent'), 'old grille-style shutter overlay retained');
check(!script.includes('V0351_Foundation_Left_Corner') && !script.includes('V0351_Foundation_Right_Corner'), 'floating foundation contact blocks retained');
check(script.includes('V0351_Coherent_Footprint_Contact_Shadow') && script.includes('V0351_Irregular_Main_Door_Soil_Stain'), 'ground contact finish missing');
check(script.includes('V0351_DEBUG_REVIEW_Technical_Evidence_Only') && script.includes('V0351_DEBUG_REVIEW_Opening_And_Contact_Readout'), 'DEBUG_REVIEW evidence mode missing');
check(script.includes('Head') && script.includes('Body') && script.includes('Leg_Left') && script.includes('Leg_Right') && script.includes('Base_Grounding'), 'context worker is not complete');
check(script.includes('V0350_Shared_Neutral_Overcast_Key') && script.includes('light_energy = 1.08'), 'v0.350 shared light was not retained');
check(metrics.upperOpeningExteriorDimensions.width === 3.32 && metrics.upperOpeningExteriorDimensions.height === 0.92, 'accepted exterior opening bounds changed');
check(metrics.shutterLeafCount === 2 && metrics.shutterPrimaryBoardOrientation === 'vertical', 'shutter contract invalid');
check(metrics.lowerUpperAreaRatio >= 3.64, 'lower/upper visible area ratio below 3.64');
check(metrics.playerEvidenceDebrisCount === 0 && metrics.completeWorkerCount === 2, 'PLAYER evidence cleanliness/worker completeness contract invalid');
check(metrics.defaultRuntimeIntegrated === false && metrics.noGameplay === true, 'default runtime/gameplay isolation missing');

const rawDir = path.join(root, 'artifacts/runtime/v0351/screenshots');
const rawFiles = exists('artifacts/runtime/v0351/screenshots') ? fs.readdirSync(rawDir).filter((f) => f.toLowerCase().endsWith('.png')) : [];
check(rawFiles.length >= 15, `expected at least fifteen raw PNG captures, found ${rawFiles.length}`);
for (const file of rawFiles) check(fs.statSync(path.join(rawDir, file)).size > 256, `raw capture empty: ${file}`);
check(manifest.checkpoint === 'v0.351' && manifest.rawCaptureCount >= 15, 'runtime manifest capture count/checkpoint invalid');
check(manifest.outcome === 'READY FOR HUMAN V0351 BARN GOLD-CLOSEOUT REVIEW', 'required v0.351 human-review outcome missing');
check(manifest.playerEvidenceDebrisCount === 0 && manifest.completeWorkerCount === 2, 'manifest PLAYER evidence contract invalid');
check(manifest.defaultRuntimeIntegrated === false && manifest.noGameplay === true && manifest.noMovement === true && manifest.noPathfinding === true && manifest.noCombat === true && manifest.noEconomy === true && manifest.noResources === true, 'forbidden runtime mutation flag present');
check(manifest.captures?.some((capture) => capture.fileName === '15_debug_review_dimensions_contact_mask.png' && capture.technicalOverlay === true), 'DEBUG_REVIEW dimensions/contact-mask capture missing');
check(manifest.captures?.some((capture) => capture.fileName === '14_contextual_house02_barn_player.png' && capture.technicalOverlay === false), 'clean contextual PLAYER capture missing');

const packDir = path.join(root, 'artifacts/manual-review/v0351-barn-gold-closeout/UPLOAD_TO_CHAT');
const packFiles = exists('artifacts/manual-review/v0351-barn-gold-closeout/UPLOAD_TO_CHAT') ? fs.readdirSync(packDir).filter((f) => fs.statSync(path.join(packDir, f)).isFile()).sort() : [];
const expectedPack = ['00_READ_ME_FIRST.md','01_V0350_HUMAN_ACCEPTANCE_AND_FROZEN_MATERIAL_BASELINE.png','02_CLEAN_FINAL_BARN_NEUTRAL_AND_DIRECT_FRONT.png','03_AGRICULTURAL_UPPER_SHUTTERS_AND_OPENING_HIERARCHY.png','04_COMPLETE_GABLE_REAR_AND_ROOF_LOCK.png','05_FOUNDATION_CONTACT_AND_WEATHERING.png','06_HOUSE02_BARN_MATCHED_MATERIAL_UNITY.png','07_RTS_256_GREYSCALE_AND_WARM.png','08_CONTEXTUAL_PLAYER_HAMLET_CLEANLINESS.png','compact-evidence-summary.json'];
check(JSON.stringify(packFiles) === JSON.stringify(expectedPack), 'review pack is not exactly ten required files');
check(packFiles.filter((f) => f.toLowerCase().endsWith('.png')).length === 8, 'review pack does not contain exactly eight PNG boards');
check(!packFiles.some((f) => /\.mp4$|\.webm$|\.mov$/i.test(f)), 'review pack contains video');
check(!script.includes('PRODUCTION_READY') && !script.includes('AUTOMATIC_GOLD_APPROVAL'), 'automatic gold/production claim present in runtime script');

if (failures.length) { console.error('FAIL_V0351_BARN_GOLD_CLOSEOUT_VALIDATION'); for (const failure of failures) console.error(`- ${failure}`); process.exit(1); }
console.log('PASS_V0351_BARN_GOLD_CLOSEOUT_VALIDATION');
