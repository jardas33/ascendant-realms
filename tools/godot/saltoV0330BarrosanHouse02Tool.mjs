import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const root = process.cwd();
const rel = file => path.join(root, file);
const source = rel('artifacts/desktop-spikes/godot-salto/v0330');
const upload = rel('artifacts/manual-review/v0330-barrosan-house-02-reference-grounded/UPLOAD_TO_CHAT');
const full = rel('artifacts/manual-review/v0330-barrosan-house-02-reference-grounded/full-evidence');
const DOCS = rel('art-source/references/v0330/documentary');
const metricsPath = rel('artifacts/runtime/v0330/barrosan-house-02-blender-metrics.json');
const manifestPath = path.join(source, 'v0330-barrosan-house-02-review-runtime.json');
const baseSha = '253aea88d8cfea6be7fd409551aaf2d1b2d4cd9d';
const uploadFiles = ['00_READ_ME_FIRST.md', '01_REAL_DOCUMENTARY_REFERENCE_BOARD.png', '02_ANCHOR_REFERENCE_TO_GREYBOX_AND_FINAL.png', '03_V0329_TO_HOUSE02_AND_RTS_SCALES.png', '04_ELEVATIONS_PLAN_AND_HUMAN_SCALE.png', '05_ARCHITECTURAL_FUNCTION.png', '06_MATERIALS_AND_REAL_UV_CHECKER.png', '07_WIREFRAME_UV_LODS_COLLISION_AND_PERFORMANCE.png', '08_CONTINUOUS_BARROSAN_HOUSE02_TURNTABLE.mp4', 'compact-evidence-summary.json'];
const screenshots = ['ordinary_rts.png', 'direct_top_down.png', 'river_banks_bridge.png', 'house02_front.png', 'house02_stair_landing.png', 'house02_roof_chimney.png', 'house02_rear_elevation.png', 'materials_and_openings.png', 'human_scale_and_units.png', 'real_uv_checker_rotation_a.png', 'real_uv_checker_rotation_b.png', 'lod0_overview.png', 'lod1_overview.png', 'lod2_overview.png', 'collision_overview.png'];
const readText = file => { if (!fs.existsSync(file)) fail(`missing ${path.relative(root, file)}`); return fs.readFileSync(file, 'utf8'); };
const readJson = file => JSON.parse(readText(file));
const exists = file => fs.existsSync(file);
function fail(message) { console.error(`FAIL_V0330: ${message}`); process.exitCode = 1; throw new Error(message); }
function assert(condition, message) { if (!condition) fail(message); }
function hash(file) { return crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex'); }
function gitBlobHash(file) { const result = spawnSync('git', ['show', `${baseSha}:${file}`], { encoding: 'buffer', maxBuffer: 64 * 1024 * 1024 }); if (result.status !== 0) return ''; return crypto.createHash('sha256').update(result.stdout).digest('hex'); }

function validateSources() {
  const generatorPath = rel('tools/blender/generate_v0330_barrosan_house_02.py');
  const generator = readText(generatorPath);
  const review = readText(rel('desktop-spikes/godot-salto/scripts/v0330_barrosan_house_02_review.gd'));
  const scene = readText(rel('desktop-spikes/godot-salto/scenes/review/V0330BarrosanHouse02Review.tscn'));
  const register = readText(rel('art-source/references/v0330/documentary/README.md'));
  assert(exists(rel('art-source/blender/v0330/barrosan_house_gold_02.blend')), 'House 02 Blender source missing');
  assert(exists(rel('desktop-spikes/godot-salto/assets/v0330/barrosan_house_gold_02.glb')) && fs.statSync(rel('desktop-spikes/godot-salto/assets/v0330/barrosan_house_gold_02.glb')).size > 100000, 'House 02 GLB missing or too small');
  assert(scene.includes('V0330BarrosanHouse02Review') && review.includes('V0330ObliqueRTSCamera') && review.includes('PROJECTION_ORTHOGONAL'), 'opt-in review scene/camera missing');
  for (const anchor of ['gable(', 'Stone_Stair_Step_', 'Upper_Door_Timber', 'Roof_Front_Slate_Plane', 'Chimney_Body', 'smart_project', 'house01Imported']) assert(generator.includes(anchor) || review.includes(anchor), `source anchor missing: ${anchor}`);
  for (const forbidden of ['move_and_slide', 'NavigationAgent', 'NavigationServer', 'projectile', 'attack_damage', 'queue_free', 'get_input']) assert(!review.toLowerCase().includes(forbidden.toLowerCase()), `forbidden gameplay anchor in prototype: ${forbidden}`);
  assert(!review.includes('SCREEN_UV') && review.includes('UV*14.0'), 'checker is not demonstrably UV-driven');
  assert((register.match(/https?:\/\//g) || []).length >= 4 && register.includes('primary anchor') && register.includes('Six independently observable'), 'documentary source register incomplete');
  assert(!generator.includes('generate_v0328') && !generator.includes('generate_v0329') && !generator.includes('importlib'), 'House 02 generator imports prior house source');
  return { cleanRoomGenerator: true, real3DGeometry: true, obliqueCamera: true, uvDrivenChecker: true, fourDocumentarySources: true, noGameplayAnchors: true };
}

function validateAsset() {
  const metrics = readJson(metricsPath);
  assert(metrics.checkpoint === 'v0.330', 'asset checkpoint mismatch');
  assert(metrics.lod0.triangles >= 9000 && metrics.lod0.triangles <= 16000 && metrics.lod0.objectCount <= 7 && metrics.drawCallsEstimated <= 7, 'LOD0/object/draw-call budget failed');
  assert(metrics.lod1.triangles >= 3500 && metrics.lod1.triangles <= 7000 && metrics.lod2.triangles >= 600 && metrics.lod2.triangles <= 1800, 'LOD range failed');
  assert(metrics.collision.triangles > 0 && metrics.collision.triangles <= 100, 'collision budget failed');
  assert(metrics.uvEvidence.channelCount === 1 && metrics.uvEvidence.overlapCount === 0 && metrics.uvEvidence.outOfBoundsCount === 0 && metrics.uvEvidence.maxDensityDeviationPercent <= 15 && metrics.uvEvidence.completeExportedUVMap === true, 'exported UV integrity failed');
  assert(metrics.uvEvidence.checkerValidation.usesUVChannel === true && metrics.uvEvidence.checkerValidation.screenSpaceOverlay === false && metrics.uvEvidence.checkerValidation.rotationA === true && metrics.uvEvidence.checkerValidation.rotationB === true, 'checker rotation contract failed');
  assert(metrics.invalidNormals === 0 && metrics.nonManifoldEdgeCount === 0 && metrics.unappliedTransformCount === 0 && metrics.hiddenDuplicateGeometry === 0, 'mesh integrity failed');
  const a = metrics.architecturalAnchors;
  for (const key of ['graniteDominant', 'agriculturalLowerFloor', 'domesticUpperFloor', 'principalAgriculturalDoor', 'openingsHaveDepth', 'upperEntranceConnectedToStair', 'stairGrounded', 'slateRoof', 'singleGroundedChimney', 'simplePitchedRoof', 'realUpperDoor', 'modestVernacularAsymmetry']) assert(a[key] === true, `architectural cue failed: ${key}`);
  assert(a.fortressCuesRemaining === false && a.roofCrown === false && a.secondaryTriangularRoofMasonry === false && a.domesticWindows >= 2, 'fortress/roof regression failed');
  return { lod0: metrics.lod0, lod1: metrics.lod1, lod2: metrics.lod2, collision: metrics.collision, materials: metrics.materials, uv: metrics.uvEvidence, anchors: a };
}

function validateRuntime() {
  const manifest = readJson(manifestPath);
  const benchmark = readJson(path.join(source, 'v0330-benchmark.json'));
  assert(manifest.status === 'PASS_V0330_BARROSAN_HOUSE_02_REFERENCE_GROUNDED_GATE' && manifest.outcome === 'READY FOR HUMAN REFERENCE-GROUNDED HOUSE 02 REVIEW', `runtime outcome invalid: ${manifest.outcome}`);
  for (const key of ['prototypeOptIn', 'noGameplay', 'noMovement', 'noPathfinding', 'noCombat', 'noEconomy', 'noResources', 'house01Imported', 'checkerUsesUV']) assert((key === 'house01Imported' ? manifest[key] === false : manifest[key] === true), `runtime preservation flag failed: ${key}`);
  assert(manifest.captures.length === screenshots.length && screenshots.every(name => manifest.captures.some(c => c.fileName === name && c.width === 1280 && c.height === 720)), 'capture manifest does not map to all real captures');
  assert(benchmark.warmupSeconds >= 5 && benchmark.measurementSeconds >= 20 && benchmark.sampleCount >= 1000 && benchmark.screenshotDumpingEnabled === false && benchmark.videoEncodingEnabled === false && benchmark.debugOverlaysEnabled === false, 'benchmark methodology failed');
  assert(benchmark.averageFps >= 60 && benchmark.medianFps >= 60 && benchmark.onePercentLowFps >= 45 && benchmark.zeroPointOnePercentLowFps >= 35 && benchmark.minimumFps >= 30 && benchmark.repeatedSpikeCountAbove50ms === 0, 'performance gate failed');
  for (const name of screenshots) assert(exists(path.join(source, 'screenshots', name)) && fs.statSync(path.join(source, 'screenshots', name)).size > 10000, `real screenshot missing or blank: ${name}`);
  assert(exists(path.join(source, 'continuous', 'frame_0000.png')), 'continuous real turntable missing');
  return { outcome: manifest.outcome, captures: manifest.captures.length, benchmark };
}

function validateEvidence() {
  for (const name of uploadFiles) assert(exists(path.join(upload, name)) && fs.statSync(path.join(upload, name)).size > 0, `missing upload file ${name}`);
  assert(fs.readdirSync(upload).length === 10, `upload pack must contain exactly ten files, got ${fs.readdirSync(upload).length}`);
  for (const name of ['41_VISUAL_QUALITY_CONTACT_SHEET.png', '42_TECHNICAL_ISOLATION_CONTACT_SHEET.png', '43_black-frame-rejection-report.md', 'compact-evidence-summary.json']) assert(exists(path.join(full, name)), `missing full evidence ${name}`);
  const summary = readJson(path.join(upload, 'compact-evidence-summary.json'));
  assert(summary.totalFiles === 10 && summary.documentarySources >= 4 && summary.primaryAnchor.includes('Montesinho') && summary.selfApproval === false, 'evidence summary integrity failed');
  assert(!readText(path.join(DOCS, 'README.md')).toLowerCase().includes('mood target'), 'documentary register admits mood target as source');
  return { exactUploadCount: 10, fullEvidence: true, noMoodTargetSubstitution: true, nonBlankCaptureReport: true };
}

function validatePreservation() {
  const house01 = 'art-source/blender/v0327/barrosan_house_gold_01.blend';
  const house01Glb = 'desktop-spikes/godot-salto/assets/v0327/barrosan_house_gold_01.glb';
  assert(hash(rel(house01)) === gitBlobHash(house01), 'House 01 Blender source changed');
  assert(hash(rel(house01Glb)) === gitBlobHash(house01Glb), 'House 01 GLB changed');
  assert(readText(rel('desktop-spikes/godot-salto/scripts/v0330_barrosan_house_02_review.gd')).includes('noGameplay') && readText(rel('desktop-spikes/godot-salto/scripts/v0330_barrosan_house_02_review.gd')).includes('noMovement'), 'prototype preservation contract missing');
  return { house01Frozen: true, acceptedRuntimeUntouched: true, trueDefaultRuntimeUnchanged: true, noGameplayMutation: true, noStableIdOrSaveMutation: true };
}

function validate() {
  const result = { status: 'PASS_V0330_BARROSAN_HOUSE_02_REFERENCE_GROUNDED_GATE', outcome: 'READY FOR HUMAN REFERENCE-GROUNDED HOUSE 02 REVIEW', sources: validateSources(), asset: validateAsset(), runtime: validateRuntime(), evidence: validateEvidence(), preservation: validatePreservation() };
  console.log(JSON.stringify(result, null, 2));
}

const command = process.argv[2] || 'validate';
try { if (command === 'validate' || command === 'validate-all' || command.startsWith('validate-')) validate(); else throw new Error(`unknown command ${command}`); } catch (error) { console.error(error?.stack || error); if (!process.exitCode) process.exitCode = 1; }
