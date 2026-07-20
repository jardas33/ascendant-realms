import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const failures = [];
const check = (condition, message) => { if (!condition) failures.push(message); };
const rel = (p) => path.join(root, p);
const exists = (p) => fs.existsSync(rel(p));
const read = (p) => fs.readFileSync(rel(p), 'utf8');
const json = (p) => JSON.parse(read(p));
const sha = (p) => crypto.createHash('sha256').update(fs.readFileSync(rel(p))).digest('hex');
const pngSize = (p) => {
  const data = fs.readFileSync(rel(p));
  if (data.length < 24 || data.readUInt32BE(0) !== 0x89504e47) return null;
  return { width: data.readUInt32BE(16), height: data.readUInt32BE(20) };
};
if (process.argv[2] !== 'validate') throw new Error('usage: node tools/godot/saltoV0353BarnGoldCloseoutTool.mjs validate');

const expectedHead = '30810baa9c3dce41b115eb97c4546438a7fe30de';
const currentHead = execFileSync('git', ['rev-parse', 'HEAD'], { cwd: root, encoding: 'utf8' }).trim();
check(currentHead.length === 40, 'current HEAD is missing');
check(exists('art-source/blender/v0353/v0353-barn-gold-closeout-metrics.json'), 'v0.353 metrics missing');
const metrics = exists('art-source/blender/v0353/v0353-barn-gold-closeout-metrics.json') ? json('art-source/blender/v0353/v0353-barn-gold-closeout-metrics.json') : {};
const scriptPath = 'desktop-spikes/godot-salto/scripts/v0353_barn_gold_closeout.gd';
const scenePath = 'desktop-spikes/godot-salto/scenes/review/V0353BarnGoldCloseout.tscn';
const workerScenePath = 'desktop-spikes/godot-salto/scenes/review/V0353CompleteBarrosanWorker.tscn';
const script = exists(scriptPath) ? read(scriptPath) : '';
const workerScene = exists(workerScenePath) ? read(workerScenePath) : '';
const manifestPath = 'artifacts/runtime/v0353/v0353-barn-gold-closeout-runtime.json';
check(exists(manifestPath), 'v0.353 runtime manifest missing; run capture first');
const manifest = exists(manifestPath) ? json(manifestPath) : {};

check(metrics.baseHead === expectedHead, 'v0.353 base HEAD is not v0.352 final');
check(metrics.outcome === 'READY FOR HUMAN V0353 BARN GOLD-CLOSEOUT REVIEW', 'required human-review outcome missing');
check(metrics.frozenV0352Content === true && metrics.frozenRoofRepairHash === '0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9', 'frozen v0.352 roof contract missing');
check(sha('art-source/blender/v0350/barn_final_material_harmony.blend') === '1d0645cc258e76fea3f3af744b04314e1e692f0db81d3710123857a594199d6b', 'frozen v0.350 blend changed');
check(sha('desktop-spikes/godot-salto/assets/v0350/barn_final_material_harmony.glb') === '0b4944d8a15006664dad84cec5e8b41546497588d14194d5b2e49621071e209c', 'frozen v0.350 GLB changed');
check(sha('desktop-spikes/godot-salto/assets/v0350/v0350_traditional_slate_courses_albedo.png') === 'cb14b8726702843f8b8811068d9f9d0c17abf3cc278c82070916813bb4ec4f34', 'frozen slate albedo changed');
check(sha('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate_gold_candidate_rubble_albedo.png') === '2b363f0b7cf1d023712d3a12041045f18890e0f4d4f5ed6f4ca3f48ef8d6d083', 'frozen granite changed');
const retainedDiff = execFileSync('git', ['diff', 'HEAD', '--name-only', '--', 'desktop-spikes/godot-salto/scripts/v0352_barn_final_gold_repair.gd', 'desktop-spikes/godot-salto/scenes/review/V0352BarnFinalGoldRepair.tscn', 'art-source/blender/v0352'], { cwd: root, encoding: 'utf8' }).trim();
check(!retainedDiff, `accepted v0.352 files modified: ${retainedDiff}`);

check(exists(scenePath) && exists(workerScenePath), 'v0.353 scenes missing');
check(workerScene.includes('WorkerBillboard') && workerScene.includes('WorkerContactShadow'), 'complete worker scene hierarchy missing');
check(workerScene.includes('worker_directional_animation_atlas.png'), 'accepted complete worker atlas missing');
check((script.match(/v0353_worker_scene\.instantiate\(\)/g) ?? []).length === 2, 'v0.353 does not instantiate exactly two complete worker scenes');
check(script.includes('V0353_Terrain_Integrated_Contact_Engine_Shadow_Only'), 'engine-shadow-only contact contract missing');
check(script.includes('visibleContactBlobCount", 0') && script.includes('visibleDecalBoundaryCount", 0'), 'natural contact zero-count contract missing');
check(!script.includes('V0352_Organic_Contact_') && !script.includes('SphereMesh.new()') && !script.includes('_make_context_worker'), 'broken v0.352 manual worker/contact implementation leaked into v0.353');
check(script.includes('SubViewport.new()') && script.includes('square_viewport.size = Vector2i(256, 256)') && script.includes('dedicated 256x256 SubViewport direct read'), 'true square viewport capture missing');
check(script.includes('pixelAspectRatio":1.0') && script.includes('without crop or stretch'), 'square evidence metadata missing');
check(script.includes('_apply_roof_visibility_repair()') && script.includes('_apply_upper_loading_shutters()'), 'accepted roof/shutter application not retained');
check(script.includes('V0353_DEBUG_REVIEW_Worker_Hierarchy_Readout'), 'DEBUG_REVIEW evidence readout missing');

check(metrics.worker?.completeWorkerCount === 2 && metrics.worker?.disassembledWorkerCount === 0 && metrics.worker?.detachedWorkerPartCount === 0 && metrics.worker?.horizontalWorkerCount === 0 && metrics.worker?.uprightWorkerCount === 2, 'complete upright worker metrics invalid');
check(metrics.foundation?.visibleContactBlobCount === 0 && metrics.foundation?.visibleRectangularContactArtifactCount === 0 && metrics.foundation?.visibleDecalBoundaryCount === 0 && metrics.foundation?.floatingFoundationGeometryCount === 0, 'natural foundation metrics invalid');
check(metrics.squareEvidence?.actualSourceDimensions === '256x256' && metrics.squareEvidence?.pixelAspectRatio === 1, 'square evidence metrics invalid');
check(metrics.defaultRuntimeIntegrated === false && metrics.noGameplay === true && metrics.noMovement === true && metrics.noPathfinding === true && metrics.noCombat === true && metrics.noEconomy === true && metrics.noResources === true, 'runtime isolation metrics invalid');

check(manifest.checkpoint === 'v0.353', 'manifest checkpoint invalid');
check(manifest.outcome === 'READY FOR HUMAN V0353 BARN GOLD-CLOSEOUT REVIEW', 'manifest outcome invalid');
check(manifest.rawCaptureCount >= 20, `v0.353 raw capture count below 20: ${manifest.rawCaptureCount}`);
check(manifest.completeWorkerCount === 2 && manifest.disassembledWorkerCount === 0 && manifest.detachedWorkerPartCount === 0 && manifest.horizontalWorkerCount === 0 && manifest.uprightWorkerCount === 2, 'manifest worker integrity contract failed');
check(manifest.minimumContextWorkerPixelHeight >= 24, 'minimum worker pixel height contract failed');
check(manifest.visibleContactBlobCount === 0 && manifest.visibleRectangularContactArtifactCount === 0 && manifest.visibleDecalBoundaryCount === 0 && manifest.floatingFoundationGeometryCount === 0, 'manifest natural contact contract failed');
check(manifest.actual256SourceDimensions === '256x256' && manifest.pixelAspectRatio === 1 && manifest.squareCaptureMethod.includes('without crop or stretch'), 'manifest true-aspect 256 contract failed');
check(manifest.defaultRuntimeIntegrated === false && manifest.noGameplay === true && manifest.noMovement === true && manifest.noPathfinding === true && manifest.noCombat === true && manifest.noEconomy === true && manifest.noResources === true && manifest.noDefaultRuntimeMutation === true, 'forbidden mutation flag present');
check((manifest.captures ?? []).filter((capture) => capture.technicalOverlay === true).length === 2, 'DEBUG_REVIEW capture count is not exactly two');
check((manifest.captures ?? []).some((capture) => capture.fileName === '11_contextual_three_quarter_player.png' && capture.technicalOverlay === false), 'clean contextual PLAYER capture missing');

const rawDir = 'artifacts/runtime/v0353/screenshots';
const rawFiles = exists(rawDir) ? fs.readdirSync(rel(rawDir)).filter((f) => f.toLowerCase().endsWith('.png')) : [];
check(rawFiles.length >= 20, `expected at least twenty raw PNG captures, found ${rawFiles.length}`);
for (const required of manifest.requiredRawNames ?? []) {
  check(rawFiles.includes(required), `required raw capture missing: ${required}`);
  if (rawFiles.includes(required)) check(fs.statSync(rel(`${rawDir}/${required}`)).size > 256, `raw capture empty: ${required}`);
}
if (rawFiles.includes('14_true_256_pixel_source.png')) check(JSON.stringify(pngSize(`${rawDir}/14_true_256_pixel_source.png`)) === JSON.stringify({width:256,height:256}), 'raw 256 capture is not an actual 256x256 PNG');
const packDir = 'artifacts/manual-review/v0353-barn-gold-closeout/UPLOAD_TO_CHAT';
const packFiles = exists(packDir) ? fs.readdirSync(rel(packDir)).filter((f) => fs.statSync(rel(`${packDir}/${f}`)).isFile()).sort() : [];
const expectedPack = ['00_READ_ME_FIRST.md','01_V0352_HUMAN_DECISION_AND_FROZEN_ROOF.png','02_FINAL_BARN_AND_NATURAL_CONTACT.png','03_INTACT_WORKER_CLOSE_PROOF.png','04_CONTEXTUAL_THREE_QUARTER_PLAYER_PROOF.png','05_HOUSE02_BARN_MATCHED_MATERIAL_UNITY.png','06_RETAINED_EXTERIOR_ROOF_PROOF.png','07_TRUE_ASPECT_RTS_256_GREYSCALE_WARM.png','08_FINAL_GOLD_CLOSEOUT_SUMMARY.png','compact-evidence-summary.json'];
check(JSON.stringify(packFiles) === JSON.stringify(expectedPack), 'v0.353 upload pack is not exactly ten required files');
check(packFiles.filter((f) => f.toLowerCase().endsWith('.png')).length === 8, 'v0.353 upload pack does not contain exactly eight PNG boards');
check(!packFiles.some((f) => /\.mp4$|\.webm$|\.mov$/i.test(f)), 'v0.353 upload pack contains video');
for (const file of packFiles.filter((f) => f.endsWith('.png'))) check(fs.statSync(rel(`${packDir}/${file}`)).size > 1024, `review board is empty: ${file}`);
check(!script.includes('PRODUCTION_READY') && !script.includes('AUTOMATIC_GOLD_APPROVAL'), 'automatic gold/production claim present');

if (failures.length) { console.error('FAIL_V0353_BARN_GOLD_CLOSEOUT_VALIDATION'); for (const failure of failures) console.error(`- ${failure}`); process.exit(1); }
console.log('PASS_V0353_BARN_GOLD_CLOSEOUT_VALIDATION');
