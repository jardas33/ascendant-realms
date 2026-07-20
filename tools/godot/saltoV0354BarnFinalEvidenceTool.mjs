import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const failures = [];
const check = (condition, message) => { if (!condition) failures.push(message); };
const rel = (p) => path.join(root, p);
const exists = (p) => fs.existsSync(rel(p));
const read = (p) => fs.readFileSync(rel(p), 'utf8').replace(/^\uFEFF/, '');
const json = (p) => JSON.parse(read(p));
const sha = (p) => crypto.createHash('sha256').update(fs.readFileSync(rel(p))).digest('hex');
const pngSize = (p) => {
  const data = fs.readFileSync(rel(p));
  if (data.length < 24 || data.readUInt32BE(0) !== 0x89504e47) return null;
  return { width: data.readUInt32BE(16), height: data.readUInt32BE(20) };
};
const gitShowSha = (commit, p) => crypto.createHash('sha256').update(execFileSync('git', ['show', `${commit}:${p}`], { cwd: root })).digest('hex');
if (process.argv[2] !== 'validate') throw new Error('usage: node tools/godot/saltoV0354BarnFinalEvidenceTool.mjs validate');

const base = 'd945785be95d07a1de5709f0c9efdede3747e2f2';
const scriptPath = 'desktop-spikes/godot-salto/scripts/v0354_barn_final_evidence.gd';
const scenePath = 'desktop-spikes/godot-salto/scenes/review/V0354BarnFinalEvidence.tscn';
const capturePath = 'tools/godot/captureGodotV0354BarnFinalEvidenceWindows.ps1';
const packBuilderPath = 'tools/godot/buildV0354BarnFinalEvidencePack.ps1';
const validatorPath = 'tools/godot/saltoV0354BarnFinalEvidenceTool.mjs';
const reportPath = 'docs/V0354_BARN_FINAL_EVIDENCE_REPORT.md';
const script = exists(scriptPath) ? read(scriptPath) : '';
const scene = exists(scenePath) ? read(scenePath) : '';
check(exists(scriptPath) && exists(scenePath), 'v0.354 scene or script missing');
check(exists(capturePath) && exists(packBuilderPath) && exists(validatorPath), 'v0.354 tooling missing');
check(exists(reportPath), 'v0.354 report missing');

for (const frozen of [
  'desktop-spikes/godot-salto/scripts/v0353_barn_gold_closeout.gd',
  'desktop-spikes/godot-salto/scenes/review/V0353BarnGoldCloseout.tscn',
  'desktop-spikes/godot-salto/scenes/review/V0353CompleteBarrosanWorker.tscn',
  'desktop-spikes/godot-salto/assets/v0314/h3/worker_directional_animation_atlas.png'
]) {
  check(exists(frozen) && sha(frozen) === gitShowSha(base, frozen), `frozen v0.353 file changed: ${frozen}`);
}
check(sha('art-source/blender/v0350/barn_final_material_harmony.blend') === '1d0645cc258e76fea3f3af744b04314e1e692f0db81d3710123857a594199d6b', 'frozen v0.350 blend changed');
check(sha('desktop-spikes/godot-salto/assets/v0350/barn_final_material_harmony.glb') === '0b4944d8a15006664dad84cec5e8b41546497588d14194d5b2e49621071e209c', 'frozen v0.350 GLB changed');
check(sha('desktop-spikes/godot-salto/assets/v0350/v0350_traditional_slate_courses_albedo.png') === 'cb14b8726702843f8b8811068d9f9d0c17abf3cc278c82070916813bb4ec4f34', 'frozen slate albedo changed');
check(sha('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate_gold_candidate_rubble_albedo.png') === '2b363f0b7cf1d023712d3a12041045f18890e0f4d4f5ed6f4ca3f48ef8d6d083', 'frozen granite changed');

check(scene.includes('v0354_barn_final_evidence.gd'), 'v0.354 scene does not use dedicated script');
check(script.includes('extends "res://scripts/v0353_barn_gold_closeout.gd"'), 'v0.354 does not extend accepted v0.353 layer');
check(script.includes('SubViewport.new()') && script.includes('square_viewport.size = V0354_VIEWPORT_SIZE'), 'direct 256 square SubViewport missing');
check(script.includes('square_camera.global_transform = camera.global_transform'), 'accepted camera global transform is not copied');
check(script.includes('Camera3D.KEEP_HEIGHT') && script.includes('projection=orthographic'), 'orthographic KEEP_HEIGHT square framing missing');
check(script.includes('actual256SubjectBoundingBox') && script.includes('actual256MinimumEdgeMargin'), 'projected bounds contract missing');
check(!script.includes('square_panel') && !script.includes('resize(256'), 'square source is not a crop or stretch');
check(script.includes('no crop; no stretch') && script.includes('noDefaultRuntimeMutation') && script.includes('noGameplay'), 'isolation metadata missing');

const manifestPath = 'artifacts/runtime/v0354/v0354-barn-final-evidence-runtime.json';
check(exists(manifestPath), 'v0.354 runtime manifest missing; run capture first');
const manifest = exists(manifestPath) ? json(manifestPath) : {};
check(manifest.status === 'PASS_V0354_BARN_FINAL_EVIDENCE_RUNTIME', 'runtime capture did not pass');
check(manifest.checkpoint === 'v0.354' && manifest.outcome === 'READY FOR HUMAN V0354 BARN FINAL EVIDENCE REVIEW', 'human-review outcome missing');
check(manifest.automatedVisualApproval === false && manifest.humanReviewRequired === true, 'human-review gate flags invalid');
check(manifest.frozenV0352RoofRepair && manifest.frozenV0351Shutters && manifest.frozenV0350MaterialBaseline && manifest.frozenV0353Workers && manifest.frozenV0353TerrainContact, 'frozen asset flags incomplete');
check(manifest.completeWorkerCount === 2 && manifest.uprightWorkerCount === 2 && manifest.disassembledWorkerCount === 0 && manifest.detachedWorkerPartCount === 0 && manifest.horizontalWorkerCount === 0, 'worker integrity contract failed');
for (const key of ['visibleContactBlobCount','visibleOvalStainCount','visibleElongatedStainCount','visibleRectangularContactArtifactCount','visibleDecalBoundaryCount','floatingFoundationGeometryCount']) check(manifest[key] === 0, `${key} is not zero`);
const bounds = manifest.actual256SubjectBoundingBox ?? {};
check(manifest.actual256SourceDimensions === '256x256' && manifest.actual256PixelAspectRatio === 1, 'actual square source dimensions invalid');
check(bounds.minEdgeMargin >= 16 && bounds.horizontalCentreError <= 6 && bounds.verticalCentreError <= 10 && bounds.widthPercentage >= 45 && bounds.widthPercentage <= 82 && bounds.heightPercentage >= 35 && bounds.heightPercentage <= 82, `square bounds outside contract: ${JSON.stringify(bounds)}`);
check(manifest.reviewBoard256DisplayDimensions === '512x512' && manifest.reviewBoard256DisplayAspectRatio === 1, 'review board square display contract invalid');
check(manifest.stretched256EvidenceCount === 0 && manifest.cropped256EvidenceCount === 0 && manifest.clipped256EvidenceCount === 0 && manifest.offCentre256EvidenceCount === 0, 'square evidence rejection counters are nonzero');
check(manifest.squareNeutralCameraHash === manifest.squareGreyscaleCameraHash && manifest.squareNeutralCameraHash === manifest.squareWarmCameraHash, 'square camera hashes differ');
check(manifest.raw256SourceHash === manifest.reviewBoardDisplayed256SourceHash, 'raw source and displayed source hashes differ');
check(manifest.rawCaptureCount === 12, `raw capture count is not exactly 12: ${manifest.rawCaptureCount}`);

const rawDir = 'artifacts/runtime/v0354/screenshots';
const rawNames = manifest.requiredRawNames ?? [];
check(rawNames.length === 12, 'required raw name list is not exactly twelve');
for (const required of rawNames) {
  const p = `${rawDir}/${required}`;
  check(exists(p) && fs.statSync(rel(p)).size > 256, `required raw capture missing or empty: ${required}`);
}
for (const [name, size] of [['06_square_neutral_256.png',{width:256,height:256}],['07_square_greyscale_256.png',{width:256,height:256}],['08_square_warm_256.png',{width:256,height:256}],['09_square_512_integer_neutral.png',{width:512,height:512}]]) check(JSON.stringify(pngSize(`${rawDir}/${name}`)) === JSON.stringify(size), `${name} has wrong dimensions`);
const debugCount = (manifest.captures ?? []).filter((capture) => capture.technicalOverlay === true).length;
check(debugCount === 3, `expected three DEBUG_REVIEW captures, found ${debugCount}`);

const packDir = 'artifacts/manual-review/v0354-barn-final-evidence/UPLOAD_TO_CHAT';
const expectedPack = ['00_READ_ME_FIRST.md','01_V0353_HUMAN_DECISION_AND_FROZEN_ASSET.png','02_ACCEPTED_BARN_CONTACT_AND_WORKERS.png','03_ACCEPTED_EXTERIOR_ROOF_AND_SHUTTERS.png','04_CONTEXTUAL_PLAYER_PROOF.png','05_HOUSE02_BARN_MATERIAL_UNITY.png','06_TRUE_256_NEUTRAL_SOURCE.png','07_TRUE_ASPECT_256_NEUTRAL_GREYSCALE_WARM.png','08_FINAL_EVIDENCE_CLOSEOUT_SUMMARY.png','compact-evidence-summary.json'];
const packFiles = exists(packDir) ? fs.readdirSync(rel(packDir)).filter((file) => fs.statSync(rel(`${packDir}/${file}`)).isFile()).sort() : [];
check(JSON.stringify(packFiles) === JSON.stringify(expectedPack), 'upload pack is not exactly the ten required files');
check(packFiles.filter((file) => file.toLowerCase().endsWith('.png')).length === 8, 'upload pack does not contain exactly eight PNG boards');
check(!packFiles.some((file) => /\.mp4$|\.webm$|\.mov$/i.test(file)), 'upload pack contains video');
for (const file of packFiles.filter((file) => file.endsWith('.png'))) check(fs.statSync(rel(`${packDir}/${file}`)).size > 1024, `review board is empty: ${file}`);
const summaryPath = `${packDir}/compact-evidence-summary.json`;
check(exists(summaryPath), 'compact summary missing');
const summary = exists(summaryPath) ? json(summaryPath) : {};
const requiredSummaryKeys = ['checkpoint','outcome','automatedVisualApproval','humanReviewRequired','frozenV0352RoofRepair','frozenRoofRepairHash','completeWorkerCount','uprightWorkerCount','disassembledWorkerCount','detachedWorkerPartCount','horizontalWorkerCount','minimumContextWorkerPixelHeight','visibleContactBlobCount','visibleOvalStainCount','visibleElongatedStainCount','visibleRectangularContactArtifactCount','visibleDecalBoundaryCount','floatingFoundationGeometryCount','actual256SourceDimensions','actual256PixelAspectRatio','actual256SubjectBoundingBox','actual256SubjectWidthPercentage','actual256SubjectHeightPercentage','actual256MinimumEdgeMargin','actual256HorizontalCentreError','actual256VerticalCentreError','reviewBoard256DisplayDimensions','reviewBoard256DisplayAspectRatio','stretched256EvidenceCount','cropped256EvidenceCount','clipped256EvidenceCount','offCentre256EvidenceCount','squareNeutralCameraHash','squareGreyscaleCameraHash','squareWarmCameraHash','raw256SourceHash','reviewBoardDisplayed256SourceHash','contextualCameraMode','rawCaptureCount','exactTenFiles','exactlyEightPng','noVideo','noDefaultRuntimeMutation','noGameplay'];
for (const key of requiredSummaryKeys) check(Object.prototype.hasOwnProperty.call(summary, key), `compact summary key missing: ${key}`);
check(summary.checkpoint === manifest.checkpoint && summary.raw256SourceHash === manifest.raw256SourceHash && summary.reviewBoardDisplayed256SourceHash === manifest.reviewBoardDisplayed256SourceHash, 'compact summary does not match runtime manifest');
check(!script.includes('PRODUCTION_READY') && !script.includes('AUTOMATIC_GOLD_APPROVAL'), 'automatic production approval claim present');

if (failures.length) { console.error('FAIL_V0354_BARN_FINAL_EVIDENCE_VALIDATION'); for (const failure of failures) console.error(`- ${failure}`); process.exit(1); }
console.log('PASS_V0354_BARN_FINAL_EVIDENCE_VALIDATION');
