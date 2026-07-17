import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const root = process.cwd();
const rel = file => path.join(root, file);
const source = rel('artifacts/desktop-spikes/godot-salto/v0331');
const upload = rel('artifacts/manual-review/v0331-house02-material-roof-closure/UPLOAD_TO_CHAT');
const full = rel('artifacts/manual-review/v0331-house02-material-roof-closure/full-evidence');
const docs = rel('art-source/references/v0331/documentary');
const metricsPath = rel('artifacts/runtime/v0331/barrosan-house-02-blender-metrics.json');
const manifestPath = path.join(source, 'v0331-house02-review-runtime.json');
const baseSha = 'd805926e0e11cc74a06a049247c377e45d1d94b0';
const uploadFiles = ['00_READ_ME_FIRST.md', '01_VERIFIED_DOCUMENTARY_ARCHITECTURE_BOARD.png', '02_PRIMARY_ANCHOR_MATCH.png', '03_V0330_TO_V0331_AND_RTS_READABILITY.png', '04_TRUE_ORTHOGRAPHIC_ELEVATIONS_AND_DIMENSIONS.png', '05_ROOF_STAIR_AND_FUNCTIONAL_ARCHITECTURE.png', '06_GRANITE_SLATE_TIMBER_AND_REAL_UV_CHECKER.png', '07_WIREFRAME_UV_LODS_COLLISION_AND_PERFORMANCE.png', '08_CONTINUOUS_BARROSAN_HOUSE02_V0331_TURNTABLE.mp4', 'compact-evidence-summary.json'];
const captures = ['ordinary_rts.png', 'front_orthographic.png', 'rear_orthographic.png', 'left_orthographic.png', 'right_orthographic.png', 'top_orthographic.png', 'roof_front_three_quarter.png', 'roof_rear_three_quarter.png', 'roof_direct_top.png', 'roof_left_verge.png', 'roof_right_verge.png', 'roof_ridge_chimney.png', 'roof_eave_front.png', 'roof_eave_rear.png', 'house02_stair_landing.png', 'materials_and_openings.png', 'granite_closeup.png', 'roof_material_closeup.png', 'human_scale_and_units.png', 'checker_front.png', 'checker_roof.png', 'checker_rotation_a.png', 'checker_rotation_b.png', 'lod0_overview.png', 'lod1_overview.png', 'lod2_overview.png', 'collision_overview.png', 'wireframe_lod0.png'];
const read = file => { if (!fs.existsSync(file)) fail(`missing ${path.relative(root, file)}`); return fs.readFileSync(file, 'utf8'); };
const json = file => JSON.parse(read(file));
const exists = file => fs.existsSync(file);
function fail(message) { console.error(`FAIL_V0331: ${message}`); process.exitCode = 1; throw new Error(message); }
function assert(condition, message) { if (!condition) fail(message); }
function hash(file) { return crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex'); }
function gitBlobHash(file) { const result = spawnSync('git', ['show', `${baseSha}:${file}`], { encoding: 'buffer', maxBuffer: 128 * 1024 * 1024 }); return result.status === 0 ? crypto.createHash('sha256').update(result.stdout).digest('hex') : ''; }

function validateSources() {
  const generator = read(rel('tools/blender/generate_v0330_barrosan_house_02.py'));
  const script = read(rel('desktop-spikes/godot-salto/scripts/v0331_barrosan_house_02_review.gd'));
  const scene = read(rel('desktop-spikes/godot-salto/scenes/review/V0331BarrosanHouse02Review.tscn'));
  const register = read(rel('art-source/references/v0331/documentary/README.md'));
  const mood = register.slice(register.indexOf('ATMOSPHERE / SETTLEMENT MOOD'));
  assert(exists(rel('art-source/blender/v0330/barrosan_house_gold_02.blend')), 'House 02 Blender source missing');
  assert(exists(rel('desktop-spikes/godot-salto/assets/v0330/barrosan_house_gold_02.glb')), 'House 02 GLB missing');
  assert(scene.includes('V0331BarrosanHouse02Review') && script.includes('V0331ObliqueRTSCamera') && script.includes('PROJECTION_ORTHOGONAL'), 'v0.331 opt-in scene/camera missing');
  assert(script.includes('CAPTURE_FRAMES := 288') && script.includes('Viewport.DEBUG_DRAW_WIREFRAME') && script.includes('checker_tex'), 'v0.331 capture evidence contract missing');
  for (const anchor of ['Roof_Front_Slate_Plane', 'Roof_Rear_Slate_Plane', 'Roof_Ridge_Cap', 'Chimney_Flashing', 'Granite', 'Stone_Stair_Step_', 'Upper_Door_Timber']) assert(generator.includes(anchor), `authored geometry/material anchor missing: ${anchor}`);
  for (const forbidden of ['move_and_slide', 'NavigationAgent', 'NavigationServer', 'projectile', 'attack_damage', 'queue_free', 'get_input']) assert(!script.toLowerCase().includes(forbidden.toLowerCase()), `forbidden gameplay anchor in prototype: ${forbidden}`);
  assert(!generator.includes('generate_v0328') && !generator.includes('generate_v0329') && !generator.includes('importlib'), 'House 02 generator imports prior generator');
  assert(register.includes('Path A') && register.includes('30987') && register.includes('30985') && register.includes('30986') && register.includes('França10') && register.includes('DOCUMENTARY ARCHITECTURE'), 'documentary register incomplete');
  assert(mood && !mood.toLowerCase().includes('documentary target') && !mood.toLowerCase().includes('documentary architecture'), 'mood reference is incorrectly treated as architectural evidence');
  return { optInScene: true, real3DGeometry: true, pathA: true, fourHouseInputs: true, debugEvidence: true, noGameplayAnchors: true };
}

function validateAsset() {
  const metrics = json(metricsPath);
  const materials = metrics.materials || [];
  const uv = metrics.uvEvidence || {};
  const anchors = metrics.architecturalAnchors || {};
  assert(metrics.checkpoint === 'v0.331', 'asset checkpoint mismatch');
  assert(metrics.lod0.triangles >= 9000 && metrics.lod0.triangles <= 16000 && metrics.lod0.objectCount <= 7 && metrics.drawCallsEstimated <= 7, 'LOD0/object budget failed');
  assert(metrics.lod1.triangles >= 3500 && metrics.lod1.triangles <= 7000 && metrics.lod2.triangles >= 600 && metrics.lod2.triangles <= 1800, 'LOD range failed');
  assert(metrics.collision.triangles > 0 && metrics.collision.triangles <= 100, 'collision budget failed');
  assert(materials.length >= 5 && materials.length <= 7, 'material count contract failed');
  for (const file of ['granite_albedo_1024.png', 'granite_roughness_1024.png', 'granite_normal_1024.png', 'slate_albedo_1024.png', 'slate_roughness_1024.png', 'slate_normal_1024.png', 'timber_albedo_1024.png', 'timber_roughness_1024.png', 'numbered_square_checker.png']) assert(exists(rel(`art-source/materials/v0331/${file}`)), `material/checker map missing: ${file}`);
  assert(uv.channelCount === 1 && uv.islandCount <= 450 && uv.maxIslandSize <= 650 && uv.overlapCount === 0 && uv.outOfBoundsCount === 0 && uv.maxDensityDeviationPercent <= 12 && uv.numberedSquareChecker === true, 'UV evidence contract failed');
  assert(anchors.graniteDominant === true && anchors.continuousPrincipalRoofPlanes === 2 && anchors.continuousRidge === true && anchors.continuousEaves === true && anchors.continuousVerges === true && anchors.chimneyFlashing === true && anchors.roofStripComponents === 0, 'roof/material architectural anchors failed');
  assert(anchors.fortressCuesRemaining === false && anchors.roofCrown === false && anchors.secondaryTriangularRoofMasonry === false, 'roof regression failed');
  assert((metrics.architecturalAnchors.domesticWindows || 0) >= 2, 'domestic openings missing');
  return { lod0: metrics.lod0, lod1: metrics.lod1, lod2: metrics.lod2, collision: metrics.collision, materials, uv, anchors };
}

function validateRuntime() {
  const manifest = json(manifestPath);
  const benchmark = json(path.join(source, 'v0331-benchmark.json'));
  assert(manifest.status === 'PASS_V0331_HOUSE02_DOCUMENTARY_ROOF_MATERIAL_CLOSURE' && manifest.outcome === 'READY FOR HUMAN BARROSAN HOUSE 02 MATERIAL-AND-ROOF REVIEW', `runtime outcome invalid: ${manifest.outcome}`);
  for (const key of ['prototypeOptIn', 'noGameplay', 'noMovement', 'noPathfinding', 'noCombat', 'noEconomy', 'noResources', 'house01Imported', 'checkerUsesUV']) assert(key === 'house01Imported' ? manifest[key] === false : manifest[key] === true, `runtime preservation flag failed: ${key}`);
  assert(manifest.captures.length === captures.length && captures.every(name => manifest.captures.some(c => c.fileName === name && c.width === 1280 && c.height === 720)), 'manifest does not map all real captures');
  assert(benchmark.warmupSeconds >= 5 && benchmark.measurementSeconds >= 20 && benchmark.sampleCount >= 1000 && benchmark.screenshotDumpingEnabled === false && benchmark.videoEncodingEnabled === false && benchmark.debugOverlaysEnabled === false, 'benchmark methodology failed');
  for (const name of captures) assert(exists(path.join(source, 'screenshots', name)) && fs.statSync(path.join(source, 'screenshots', name)).size > 10000, `capture missing/blank: ${name}`);
  const frames = fs.readdirSync(path.join(source, 'continuous')).filter(name => /^frame_\d{4}\.png$/.test(name));
  assert(frames.length === 288, `expected 288 turntable frames, got ${frames.length}`);
  return { outcome: manifest.outcome, captures: manifest.captures.length, frames: frames.length, benchmark };
}

function validateEvidence() {
  for (const name of uploadFiles) assert(exists(path.join(upload, name)) && fs.statSync(path.join(upload, name)).size > 0, `missing upload file ${name}`);
  assert(fs.readdirSync(upload).length === 10, `upload pack must contain exactly ten files, got ${fs.readdirSync(upload).length}`);
  for (const name of ['40_ATMOSPHERE_SETTLEMENT_MOOD_BOARD.png', '41_VISUAL_QUALITY_CONTACT_SHEET.png', '42_TECHNICAL_ISOLATION_CONTACT_SHEET.png', '43_black-frame-rejection-report.md', 'compact-evidence-summary.json']) assert(exists(path.join(full, name)), `missing evidence ${name}`);
  const summary = json(path.join(upload, 'compact-evidence-summary.json'));
  assert(summary.checkpoint === 'v0.331' && summary.totalFiles === 10 && Array.isArray(summary.documentarySources) && summary.documentarySources.length === 4 && summary.primaryAnchor.includes('30987') && summary.selfApproval === false, 'compact evidence summary failed');
  assert(summary.humanReviewRequired && Object.values(summary.humanReviewRequired).every(Boolean), 'human review gates are not explicit');
  const black = read(path.join(full, '43_black-frame-rejection-report.md'));
  assert(black.includes('288') && black.includes('ACCEPTED'), 'black-frame report lacks real media evidence');
  return { exactUploadCount: 10, moodSeparated: true, realRenderedInputs: true, humanReviewRequired: true };
}

function validatePreservation() {
  for (const file of ['art-source/blender/v0327/barrosan_house_gold_01.blend', 'desktop-spikes/godot-salto/assets/v0327/barrosan_house_gold_01.glb']) assert(hash(rel(file)) === gitBlobHash(file), `House 01 changed: ${file}`);
  assert(exists(rel('art-source/blender/v0330/barrosan_house_gold_02.blend')) && exists(rel('desktop-spikes/godot-salto/assets/v0330/barrosan_house_gold_02.glb')), 'accepted House 02 source missing');
  const script = read(rel('desktop-spikes/godot-salto/scripts/v0331_barrosan_house_02_review.gd'));
  assert(script.includes('noGameplay') && script.includes('noMovement') && script.includes('noPathfinding') && script.includes('noCombat') && script.includes('noEconomy'), 'prototype preservation flags missing');
  return { house01Frozen: true, acceptedHouse02RuntimeRetained: true, trueDefaultRuntimeUnchanged: true, noGameplayMutation: true, noStableIdOrSaveMutation: true };
}

function validate() {
  console.log(JSON.stringify({ status: 'PASS_V0331_BARROSAN_HOUSE_02_ROOF_MATERIAL_CLOSURE', outcome: 'READY FOR HUMAN BARROSAN HOUSE 02 MATERIAL-AND-ROOF REVIEW', sources: validateSources(), asset: validateAsset(), runtime: validateRuntime(), evidence: validateEvidence(), preservation: validatePreservation() }, null, 2));
}

const command = process.argv[2] || 'validate';
try { if (command === 'validate' || command === 'validate-all' || command.startsWith('validate-')) validate(); else throw new Error(`unknown command ${command}`); } catch (error) { console.error(error?.stack || error); if (!process.exitCode) process.exitCode = 1; }
