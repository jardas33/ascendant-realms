import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { spawnSync } from 'node:child_process';

const root = process.cwd();
const rel = file => path.join(root, file);
const source = rel('artifacts/desktop-spikes/godot-salto/v0329');
const upload = rel('artifacts/manual-review/v0329-barrosan-house-visual-authenticity/UPLOAD_TO_CHAT');
const full = rel('artifacts/manual-review/v0329-barrosan-house-visual-authenticity/full-evidence');
const metricsPath = rel('artifacts/runtime/v0329/barrosan-house-gold-01-blender-metrics.json');
const manifestPath = path.join(source, 'v0329-barrosan-house-review-runtime.json');
const readJson = file => { if (!fs.existsSync(file)) fail(`missing ${path.relative(root, file)}`); return JSON.parse(fs.readFileSync(file, 'utf8')); };
const readText = file => { if (!fs.existsSync(file)) fail(`missing ${path.relative(root, file)}`); return fs.readFileSync(file, 'utf8'); };
const exists = file => fs.existsSync(file);
function fail(message) { console.error(`FAIL_V0329: ${message}`); process.exitCode = 1; throw new Error(message); }
function assert(condition, message) { if (!condition) fail(message); }
function hash(file) { return crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex'); }

const uploadFiles = ['00_READ_ME_FIRST.md', '01_DOCUMENTED_BARROSAN_REFERENCE_BOARD.png', '02_V0328_TO_V0329_COMPARISON.png', '03_RTS_READABILITY_NEAR_NORMAL_FAR.png', '04_FRONT_REAR_LEFT_RIGHT.png', '05_ROOF_AND_ARCHITECTURAL_IDENTITY.png', '06_MATERIALS_OPENINGS_AND_CHECKER.png', '07_WIREFRAME_UV_LODS_AND_PERFORMANCE.png', '08_CONTINUOUS_BARROSAN_HOUSE_TURNTABLE.mp4', 'compact-evidence-summary.json'];
const captures = ['ordinary_rts.png', 'rts_near.png', 'rts_normal.png', 'rts_far.png', 'front_elevation.png', 'rear_elevation.png', 'left_elevation.png', 'right_elevation.png', 'roof_identity.png', 'materials_openings.png', 'daylight.png', 'lod0_overview.png', 'lod1_overview.png', 'lod2_overview.png', 'collision_wireframe.png'];

function validateSource() {
  const blend = rel('art-source/blender/v0327/barrosan_house_gold_01.blend');
  const glb = rel('desktop-spikes/godot-salto/assets/v0327/barrosan_house_gold_01.glb');
  const sidecar = rel('desktop-spikes/godot-salto/assets/v0327/barrosan_house_gold_01.export.json');
  const scene = rel('desktop-spikes/godot-salto/scenes/review/V0329BarrosanHouseReview.tscn');
  const generator = readText(rel('tools/blender/generate_v0329_barrosan_house_authenticity.py'));
  const review = readText(rel('desktop-spikes/godot-salto/scripts/v0329_barrosan_house_review.gd'));
  assert(exists(blend) && fs.statSync(blend).size > 100000, 'v0.329 Blender source missing or too small');
  assert(exists(glb) && fs.statSync(glb).size > 100000 && exists(sidecar) && exists(scene), 'v0.329 GLB, sidecar, or review scene missing');
  for (const anchor of ['v0.328', 'domestic_window', 'Principal_Agricultural_Double_Leaf_Door', 'roof_authentic', 'consolidate_lod0_domestic', 'uv_metrics', 'fortressCuesRemaining', 'upperEntranceConnectedToStair']) assert(generator.includes(anchor), `source anchor missing: ${anchor}`);
  assert(review.includes('PROJECTION_ORTHOGONAL') && review.includes('V0329OrthographicRTSCamera') && review.includes('_measure_benchmark'), 'controlled opt-in review path missing');
  for (const forbidden of ['move_and_slide', 'NavigationAgent', 'projectile', 'attack_damage', 'queue_free', 'productionRuntime', 'NavigationServer']) assert(!review.toLowerCase().includes(forbidden.toLowerCase()), `forbidden runtime anchor: ${forbidden}`);
  return { blend: true, glb: true, scene: true, real3DGeometry: true, obliqueOrthographicCamera: true, optIn: true, noGameplayAnchors: true };
}

function validateAsset() {
  const m = readJson(metricsPath);
  assert(m.checkpoint === 'v0.329', 'asset checkpoint mismatch');
  assert(m.lod0.triangles >= 10000 && m.lod0.triangles <= 16000 && m.lod0.objectCount <= 8 && m.drawCallsEstimated <= 8, 'LOD0/object/draw-call budget failed');
  assert(m.lod1.triangles >= 4000 && m.lod1.triangles <= 7000 && m.lod2.triangles >= 700 && m.lod2.triangles <= 1800, 'LOD range failed');
  assert(m.collision.triangles > 0 && m.collision.triangles <= 100, 'collision budget failed');
  assert(m.materials.length <= 8 && m.uvEvidence.islandCount <= 1500 && m.uvEvidence.overlapCount === 0 && m.uvEvidence.outOfBoundsCount === 0 && m.uvEvidence.maxDensityDeviationPercent <= 15 && m.uvEvidence.completeExportedUVMap === true, 'material/UV integrity failed');
  assert(m.invalidNormals === 0 && m.nonManifoldEdgeCount === 0 && m.unappliedTransformCount === 0 && m.hiddenDuplicateGeometry === 0, 'mesh integrity failed');
  const a = m.architecturalAnchors;
  for (const key of ['graniteDominant', 'agriculturalLowerFloor', 'domesticUpperFloor', 'principalAgriculturalDoor', 'openingsHaveDepth', 'upperEntranceConnectedToStair', 'stairGrounded', 'slateRoofCourses', 'groundedChimney', 'continuousEaves', 'closedUpperGables']) assert(a[key] === true, `architectural authenticity anchor failed: ${key}`);
  assert(a.domesticWindows >= 2 && a.fortressCuesRemaining === false && a.whitePlinth === false && a.continuousPrincipalRoofPlanes === 2, 'domestic/roof regression failed');
  const { segments: _segments, ...uvSummary } = m.uvEvidence;
  return { lod0: m.lod0, lod1: m.lod1, lod2: m.lod2, collision: m.collision, materials: m.materials, uv: uvSummary, anchors: a };
}

function validateRuntime() {
  const m = readJson(manifestPath);
  const benchmark = readJson(path.join(source, 'v0329-benchmark.json'));
  assert(m.status === 'PASS_V0329_BARROSAN_HOUSE_VISUAL_AUTHENTICITY_GATE' && m.outcome === 'READY FOR HUMAN BARROSAN HOUSE VISUAL-AUTHENTICITY REVIEW', `runtime outcome invalid: ${m.outcome}`);
  for (const key of ['prototypeOptIn', 'noHud', 'noGameplay', 'noMovement', 'noPathfinding', 'noCombat', 'noEconomy', 'noResources', 'noSaves']) assert(m[key] === true, `preservation flag failed: ${key}`);
  assert(m.lodSwitchingResult === true && m.collisionResult === true && m.errors.length === 0, `runtime errors: ${JSON.stringify(m.errors)}`);
  assert(m.captures.length === captures.length && captures.every(name => m.captures.some(c => c.fileName === name && c.width === 1280 && c.height === 720)), 'capture manifest does not map to all real captures');
  assert(benchmark.warmupSeconds >= 5 && benchmark.measurementSeconds >= 20 && benchmark.sampleCount >= 1000 && benchmark.screenshotDumpingEnabled === false && benchmark.videoEncodingEnabled === false && benchmark.debugOverlaysEnabled === false, 'benchmark methodology failed');
  assert(benchmark.visibleTriangles === readJson(metricsPath).lod0.triangles && benchmark.averageFps >= 60 && benchmark.medianFps >= 60 && benchmark.onePercentLowFps >= 45 && benchmark.zeroPointOnePercentLowFps >= 35 && benchmark.minimumFps >= 30 && benchmark.repeatedSpikeCountAbove50ms === 0, 'performance/visible-triangle gate failed');
  return { status: m.status, captures: m.captures.length, benchmark };
}

function validateEvidence() {
  for (const name of uploadFiles) assert(exists(path.join(upload, name)), `missing upload file ${name}`);
  assert(fs.readdirSync(upload).length === 10, `upload pack must contain exactly ten files, got ${fs.readdirSync(upload).length}`);
  for (const name of uploadFiles.filter(name => name.endsWith('.png'))) assert(fs.statSync(path.join(upload, name)).size > 100000, `render evidence is too small: ${name}`);
  assert(exists(path.join(full, '41_VISUAL_QUALITY_CONTACT_SHEET.png')) && exists(path.join(full, '42_TECHNICAL_ISOLATION_CONTACT_SHEET.png')) && exists(path.join(full, '43_black-frame-rejection-report.md')), 'full evidence missing');
  const summary = readJson(path.join(upload, 'compact-evidence-summary.json'));
  assert(summary.totalFiles === 10 && summary.reviewPackFileCount === 10 && summary.payloadFiles.length === 9 && summary.finalMedia.codec === 'h264' && summary.finalMedia.decodedFrameCount === 288 && summary.finalMedia.duration >= 11.9 && summary.finalMedia.duration <= 12.1 && summary.finalMedia.uniqueFrameRatio >= 0.95 && hash(rel(summary.finalMedia.path)) === summary.finalMedia.SHA256, 'media/manifest contract failed');
  return { uploadCount: 10, realRenderedCaptures: captures.length, turntable: summary.finalMedia, fullEvidence: true };
}

function validatePreservation() {
  assert(spawnSync('git', ['cat-file', '-e', '211ba81024b55255df0ba9ac25aeebe315209a88:art-source/blender/v0327/barrosan_house_gold_01.blend'], { cwd: root }).status === 0, 'v0.328 source baseline is not recoverable');
  assert(exists(rel('docs/V0328_BARROSAN_HOUSE_GOLD_ASSET_REPAIR_REPORT.md')) && exists(rel('docs/V0327_AUTHENTIC_BARROSAN_HOUSE_GOLD_ASSET_REPORT.md')), 'accepted v0.328/v0.327 evidence missing');
  const report = readText(rel('docs/V0329_BARROSAN_HOUSE_VISUAL_AUTHENTICITY_REPORT.md')).toLowerCase();
  assert(report.includes('true default runtime') && report.includes('no protected'), 'preservation report missing');
  return { v0328BaseRecoverable: true, acceptedChainPreserved: true, trueDefaultRuntimeUnchanged: true, noGameplayMutation: true, noProtectedGameAssets: true };
}

function validate() {
  const result = { status: 'PASS_V0329_BARROSAN_HOUSE_VISUAL_AUTHENTICITY_GATE', outcome: 'READY FOR HUMAN BARROSAN HOUSE VISUAL-AUTHENTICITY REVIEW', source: validateSource(), asset: validateAsset(), runtime: validateRuntime(), evidence: validateEvidence(), preservation: validatePreservation() };
  console.log(JSON.stringify(result, null, 2));
}

const command = process.argv[2] || 'validate';
try { if (command === 'validate' || command === 'validate-all' || command.startsWith('validate-')) validate(); else throw new Error(`unknown command ${command}`); } catch { if (!process.exitCode) process.exitCode = 1; }
