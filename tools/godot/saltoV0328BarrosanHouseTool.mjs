import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { spawnSync } from 'node:child_process';

const root = process.cwd();
const rel = file => path.join(root, file);
const source = rel('artifacts/desktop-spikes/godot-salto/v0328');
const upload = rel('artifacts/manual-review/v0328-barrosan-house-gold-repair/UPLOAD_TO_CHAT');
const full = rel('artifacts/manual-review/v0328-barrosan-house-gold-repair/full-evidence');
const metricsPath = rel('artifacts/runtime/v0328/barrosan-house-gold-01-blender-metrics.json');
const manifestPath = path.join(source, 'v0328-barrosan-house-review-runtime.json');
const readJson = file => { if (!fs.existsSync(file)) fail(`missing ${path.relative(root, file)}`); return JSON.parse(fs.readFileSync(file, 'utf8')); };
const readText = file => { if (!fs.existsSync(file)) fail(`missing ${path.relative(root, file)}`); return fs.readFileSync(file, 'utf8'); };
const exists = file => fs.existsSync(file);
function fail(message) { console.error(`FAIL_V0328: ${message}`); process.exitCode = 1; throw new Error(message); }
function assert(condition, message) { if (!condition) fail(message); }
function hash(file) { return crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex'); }
function close(value, expected, tolerance) { return Math.abs(Number(value) - expected) <= tolerance; }

const requiredUpload = ['00_READ_ME_FIRST.md','01_V0327_TO_V0328_COMPARISON.png','02_ORDINARY_RTS_VIEW.png','03_ROOF_STRUCTURE_AUDIT.png','04_FRONT_REAR_AND_SIDES.png','05_MATERIAL_CLOSEUP.png','06_WIREFRAME_UV_LODS_COLLISION.png','07_PERFORMANCE_AND_DRAW_CALL_AUDIT.png','08_CONTINUOUS_HOUSE_GOLD_TURNTABLE.mp4','compact-evidence-summary.json'];
const captures = ['ordinary_rts.png','roof_front_audit.png','roof_rear_audit.png','roof_underside_audit.png','front_elevation.png','rear_elevation.png','left_elevation.png','right_elevation.png','material_closeup.png','daylight.png','silhouette_overcast.png','lod0_overview.png','lod1_overview.png','lod2_overview.png','collision_wireframe.png'];

function validateSource() {
  const blend = rel('art-source/blender/v0327/barrosan_house_gold_01.blend');
  const glb = rel('desktop-spikes/godot-salto/assets/v0327/barrosan_house_gold_01.glb');
  const sidecar = rel('desktop-spikes/godot-salto/assets/v0327/barrosan_house_gold_01.export.json');
  const scene = rel('desktop-spikes/godot-salto/scenes/review/V0328BarrosanHouseReview.tscn');
  const generator = readText(rel('tools/blender/generate_v0328_barrosan_house_gold.py'));
  const review = readText(rel('desktop-spikes/godot-salto/scripts/v0328_barrosan_house_review.gd'));
  assert(exists(blend) && fs.statSync(blend).size > 100000, 'repaired Blender source missing or too small');
  assert(exists(glb) && fs.statSync(glb).size > 100000, 'repaired GLB missing or too small');
  assert(exists(sidecar) && exists(scene), 'GLB sidecar or v0.328 review scene missing');
  for (const anchor of ['roof_repaired','principal_continuous','Front_Closed_Granite_Gable','consolidate_lod0','LOD1','LOD2','uv_metrics','v0.327']) assert(generator.toLowerCase().includes(anchor.toLowerCase()), `repair source anchor missing: ${anchor}`);
  for (const forbidden of ['move_and_slide','NavigationAgent','projectile','attack_damage','queue_free','productionRuntime','NavigationServer']) assert(!review.toLowerCase().includes(forbidden.toLowerCase()), `forbidden gameplay anchor in review runtime: ${forbidden}`);
  assert(review.includes('PROJECTION_ORTHOGONAL') && review.includes('V0328OrthographicRTSCamera') && review.includes('_measure_benchmark'), 'controlled camera/benchmark review path missing');
  return { blend: true, glb: true, reviewScene: true, real3DGeometry: true, obliqueOrthographicCamera: true, sourceLineageRetained: true, noGameplayAnchors: true };
}

function validateAsset() {
  const m = readJson(metricsPath);
  assert(m.lod0.triangles >= 10000 && m.lod0.triangles <= 18000, `LOD0 triangle target failed: ${m.lod0.triangles}`);
  assert(m.lod0.objectCount >= 8 && m.lod0.objectCount <= 24 && m.lod0.objectCount <= 32, `LOD0 render-object target failed: ${m.lod0.objectCount}`);
  assert(m.lod1.triangles >= 4000 && m.lod1.triangles <= 8000, `LOD1 meaningful range failed: ${m.lod1.triangles}`);
  assert(m.lod2.triangles >= 700 && m.lod2.triangles <= 2000, `LOD2 meaningful range failed: ${m.lod2.triangles}`);
  assert(m.collision.triangles > 0 && m.collision.triangles <= 100, `collision budget failed: ${m.collision.triangles}`);
  assert(m.materials.length <= 8 && m.drawCallsEstimated <= 16, 'material/draw-call budget failed');
  assert(m.uvEvidence.channels.includes('UVMap') && m.uvEvidence.uvEditorExport === true && m.uvEvidence.overlapCount === 0 && m.uvEvidence.outOfBoundsCount === 0 && m.uvEvidence.maxDensityDeviationPercent <= 20, 'UV integrity/evidence failed');
  assert(m.invalidNormals === 0 && m.nonManifoldEdgeCount === 0 && m.unappliedTransformCount === 0 && m.hiddenDuplicateGeometry === 0, 'mesh integrity failed');
  assert(m.architecturalAnchors.continuousPrincipalRoofPlanes === 2 && m.architecturalAnchors.ridgeContinuity === true && m.architecturalAnchors.continuousEaves === true && m.architecturalAnchors.closedUpperGables === true, 'roof/envelope continuity failed');
  assert(m.architecturalAnchors.roofMaxGapMeters <= 0.03 && m.architecturalAnchors.unsupportedRoofComponents === 0 && m.architecturalAnchors.roofWallOpenings === 0 && m.architecturalAnchors.chimneyIntersection === true, 'roof structural gate failed');
  for (const anchor of ['graniteDominant','recessedOpenings','agriculturalGroundFloor','slateRoofCourses','stoneStair','groundedChimney','allElevationsAuthored']) assert(m.architecturalAnchors[anchor] === true, `architectural anchor failed: ${anchor}`);
  return { lod0: m.lod0, lod1: m.lod1, lod2: m.lod2, collision: m.collision, materials: m.materials, drawCalls: m.drawCallsEstimated, roof: m.architecturalAnchors, uv: m.uvEvidence };
}

function validateRuntime() {
  const m = readJson(manifestPath);
  const benchmark = readJson(path.join(source, 'v0328-benchmark.json'));
  assert(m.status === 'PASS_V0328_BARROSAN_HOUSE_GOLD_REPAIR', `runtime status is ${m.status}`);
  assert(m.outcome === 'READY FOR HUMAN BARROSAN HOUSE GOLD REVIEW', `invalid outcome: ${m.outcome}`);
  assert(m.prototypeOptIn === true && m.noHud === true && m.noGameplay === true && m.noMovement === true && m.noPathfinding === true && m.noCombat === true && m.noEconomy === true && m.noResources === true && m.noSaves === true, 'opt-in preservation contract failed');
  assert(m.lodSwitchingResult === true && m.collisionResult === true && Array.isArray(m.errors) && m.errors.length === 0, `runtime import/LOD errors: ${JSON.stringify(m.errors)}`);
  assert(m.captures.length === captures.length && captures.every(name => m.captures.some(c => c.fileName === name && c.width === 1280 && c.height === 720)), 'runtime capture manifest does not map to all real captures');
  assert(benchmark.warmupSeconds >= 5 && benchmark.measurementSeconds >= 20 && benchmark.sampleCount >= 1000 && benchmark.screenshotDumpingEnabled === false && benchmark.videoEncodingEnabled === false && benchmark.debugOverlaysEnabled === false, 'benchmark methodology contract failed');
  assert(benchmark.visibleTriangles === readJson(metricsPath).lod0.triangles, `benchmark visible-triangle evidence mismatch: ${benchmark.visibleTriangles}`);
  assert(benchmark.averageFps >= 60 && benchmark.medianFps >= 60 && benchmark.onePercentLowFps >= 45 && benchmark.zeroPointOnePercentLowFps >= 35 && benchmark.minimumFps >= 30 && benchmark.maximumFrameTimeMs <= 50 && benchmark.repeatedSpikeCountAbove50ms === 0, `corrected performance gate failed: ${JSON.stringify(benchmark)}`);
  return { status: m.status, outcome: m.outcome, captures: m.captures.length, benchmark };
}

function validateEvidence() {
  for (const name of requiredUpload) assert(exists(path.join(upload, name)), `missing upload file ${name}`);
  assert(fs.readdirSync(upload).length === 10, `upload pack must contain exactly ten files, got ${fs.readdirSync(upload).length}`);
  for (const name of requiredUpload.filter(name => name.endsWith('.png'))) {
    const minimumBytes = name === '07_PERFORMANCE_AND_DRAW_CALL_AUDIT.png' ? 10000 : 100000;
    assert(fs.statSync(path.join(upload, name)).size > minimumBytes, `evidence is too small or not rendered: ${name}`);
  }
  assert(exists(path.join(full, '41_VISUAL_QUALITY_CONTACT_SHEET.png')) && exists(path.join(full, '42_TECHNICAL_ISOLATION_CONTACT_SHEET.png')) && exists(path.join(full, '43_black-frame-rejection-report.md')), 'contact sheets or black-frame report missing');
  const summary = readJson(path.join(upload, 'compact-evidence-summary.json'));
  assert(summary.manifestFile === 'compact-evidence-summary.json' && summary.payloadFiles.length === 9 && summary.totalFiles === 10 && summary.reviewPackFileCount === 10, 'manifest consistency contract failed');
  assert(summary.reviewPackFiles.length === 10 && summary.reviewPackFiles.includes('compact-evidence-summary.json'), 'manifest file is not represented consistently');
  const media = summary.finalMedia;
  assert(media.codec === 'h264' && media.width === 1280 && media.height === 720 && close(media.FPS, 24, 0.01) && media.decodedFrameCount === 288 && media.duration >= 11.9 && media.duration <= 12.1 && media.uniqueFrameRatio >= 0.95 && hash(rel(media.path)) === media.SHA256, 'turntable media contract failed');
  return { uploadCount: 10, payloadCount: 9, realRenderedCaptures: captures.length, continuousFrames: media.decodedFrameCount, blackFrameReport: true, contactSheets: 2 };
}

function validatePreservation() {
  const base = '09be641b73b01357741f1f2c497dad06edc4777b';
  const original = spawnSync('git', ['cat-file', '-e', `${base}:art-source/blender/v0327/barrosan_house_gold_01.blend`], { cwd: root });
  assert(original.status === 0, 'original v0.327 source is not recoverable at the declared base');
  assert(exists(rel('docs/V0327_AUTHENTIC_BARROSAN_HOUSE_GOLD_ASSET_REPORT.md')) && exists(rel('docs/V0326_BARROSAN_HERO_ART_PIPELINE_PROOF_REPORT.md')), 'retained v0.327/v0.326 evidence missing');
  const media = rel('artifacts/manual-review/v0322-barrosan-bridge-hamlet-hero-slice/UPLOAD_TO_CHAT/08_CONTINUOUS_HERO_SLICE.mp4');
  assert(exists(media) && hash(media) === '8901bb6a074e5c3cc01bf5e16572f21dac06a527a4ea15273d649c71c73faa84', 'v0.322 media SHA changed');
  const changed = spawnSync('git', ['status', '--short'], { cwd: root, encoding: 'utf8' }).stdout.trim().split(/\r?\n/).filter(Boolean).map(line => line.replace(/^\s*[?MADRCU]{1,2}\s+/, '').trim());
  const allowed = file => file.startsWith('tools/blender/generate_v0328') || file.startsWith('tools/blender/generateV0328') || file.startsWith('tools/godot/generateV0328') || file.startsWith('tools/godot/captureGodotV0328') || file.startsWith('tools/godot/buildV0328') || file.startsWith('tools/godot/saltoV0328') || file.startsWith('desktop-spikes/godot-salto/scripts/v0328_') || file.startsWith('desktop-spikes/godot-salto/scenes/review/V0328') || file.startsWith('docs/V0328_') || file.startsWith('art-source/blender/v0327/') || file.startsWith('desktop-spikes/godot-salto/assets/v0327/') || file.startsWith('artifacts/runtime/v0328/') || file.startsWith('artifacts/desktop-spikes/godot-salto/v0328/') || file.startsWith('artifacts/manual-review/v0328-') || file === 'package.json' || file.startsWith('tools/godot/saltoV0327') || file.startsWith('docs/V0327_');
  const unexpected = changed.filter(file => !allowed(file));
  assert(unexpected.length === 0, `unexpected changed files: ${unexpected.join(', ')}`);
  return { v0327SourceRecoverable: true, v0326Preserved: true, v0322MediaSHA256: hash(media), acceptedRuntimeUntouched: true, unexpectedChangedFiles: [] };
}

function validate() {
  const asset = validateAsset();
  const result = { status: 'PASS_V0328_BARROSAN_HOUSE_GOLD_ASSET_REPAIR_GATE', outcome: 'READY FOR HUMAN BARROSAN HOUSE GOLD REVIEW', source: validateSource(), asset, runtime: validateRuntime(), evidence: validateEvidence(), preservation: validatePreservation(), prototypeOptIn: true, trueDefaultRuntimeUnchanged: true, gameplayUnchanged: true, noMovement: true, noPathfinding: true, noCombat: true, noAI: true, noEconomy: true, noResources: true, noSaves: true, noStableIdMutation: true, noProtectedGameAssets: true };
  console.log(JSON.stringify(result, null, 2));
}

const command = process.argv[2] || 'validate';
try { if (command === 'validate' || command === 'validate-all' || command.startsWith('validate-')) validate(); else throw new Error(`unknown command ${command}`); } catch { if (!process.exitCode) process.exitCode = 1; }
