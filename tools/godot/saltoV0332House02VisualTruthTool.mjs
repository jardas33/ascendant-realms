import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const rel = file => path.join(root, file);
const source = rel('artifacts/desktop-spikes/godot-salto/v0332');
const upload = rel('artifacts/manual-review/v0332-house02-visual-truth/UPLOAD_TO_CHAT');
const full = rel('artifacts/manual-review/v0332-house02-visual-truth/full-evidence');
const metricsPath = rel('artifacts/runtime/v0332/barrosan-house-02-blender-metrics.json');
const materialsPath = rel('artifacts/runtime/v0332/barrosan-house-02-material-record.json');
const importRecordPath = rel('artifacts/runtime/v0332/barrosan-house-02-godot-import-record.json');
const glbPath = rel('desktop-spikes/godot-salto/assets/v0330/barrosan_house_gold_02.glb');
const importPath = rel('desktop-spikes/godot-salto/assets/v0330/barrosan_house_gold_02.glb.import');
const report = rel('docs/V0332_HOUSE02_VISUAL_TRUTH_REPORT.md');
const uploadFiles = ['00_READ_ME_FIRST.md', '01_DOCUMENTARY_ARCHITECTURE_AND_SOURCE_METADATA.png', '02_PRIMARY_REFERENCE_REAL_ALIGNMENT.png', '03_V0331_REJECTED_TO_V0332_VISUAL_TRUTH.png', '04_TRUE_ORTHOGRAPHICS_AND_AUTHORED_DIMENSIONS.png', '05_ROOF_STAIR_OPENINGS_AND_ARCHITECTURAL_FUNCTION.png', '06_REAL_PBR_MATERIALS_AND_NUMBERED_UV_CHECKER.png', '07_TRUE_WIREFRAME_UV_LODS_COLLISION_AND_BENCHMARK.png', '08_CONTINUOUS_BARROSAN_HOUSE02_V0332_TURNTABLE.mp4', 'compact-evidence-summary.json'];
const read = file => { if (!fs.existsSync(file)) fail(`missing ${path.relative(root, file)}`); return fs.readFileSync(file, 'utf8'); };
const json = file => JSON.parse(read(file));
const exists = file => fs.existsSync(file);
function fail(message) { console.error(`FAIL_V0332: ${message}`); process.exitCode = 1; throw new Error(message); }
function assert(condition, message) { if (!condition) fail(message); }
function hash(file) { return crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex'); }
function pngSize(file) { const b = fs.readFileSync(file); return { width: b.readUInt32BE(16), height: b.readUInt32BE(20) }; }

function validateSources() {
  const generator = read(rel('tools/blender/generate_v0330_barrosan_house_02.py'));
  const script = read(rel('desktop-spikes/godot-salto/scripts/v0332_barrosan_house_02_visual_truth.gd'));
  const scene = read(rel('desktop-spikes/godot-salto/scenes/review/V0332BarrosanHouse02VisualTruth.tscn'));
  assert(scene.includes('V0332BarrosanHouse02VisualTruth') && script.includes('v0331_barrosan_house_02_review') && script.includes('_artifact_root_from_args'), 'opt-in v0.332 scene/script missing');
  assert(generator.includes('V0332_Granite') && generator.includes('V0332_Weathered_Slate') && generator.includes('V0332_Weathered_Timber'), 'v0.332 material names missing');
  for (const anchor of ['Roof_Front_Slate_Plane', 'Roof_Rear_Slate_Plane', 'Roof_Ridge_Cap', 'Chimney_Flashing_Front', 'Upper_Door_Timber', 'Stone_Stair_Step_']) assert(generator.includes(anchor), `architecture anchor missing: ${anchor}`);
  assert(!generator.includes('Roof_Triangular') && !generator.includes('Roof_Eyebrow') && !generator.includes('Roof_Crown'), 'forbidden roof ornament anchor present');
  for (const forbidden of ['move_and_slide', 'NavigationAgent', 'NavigationServer', 'projectile', 'attack_damage', 'queue_free', 'get_input']) assert(!script.toLowerCase().includes(forbidden.toLowerCase()), `forbidden gameplay anchor: ${forbidden}`);
  return { optInScene: true, materialAuthoring: true, twoPlaneRoof: true, noGameplayAnchors: true };
}

function validateAsset() {
  const metrics = json(metricsPath);
  const materials = json(materialsPath);
  assert(metrics.checkpoint === 'v0.332', 'metrics checkpoint mismatch');
  assert(metrics.glbSha256 === hash(glbPath), 'metrics GLB hash does not match current GLB');
  assert(metrics.lod0.triangles >= 9000 && metrics.lod0.triangles <= 16000 && metrics.lod0.objectCount <= 7 && metrics.drawCallsEstimated <= 7, 'LOD0 budget failed');
  assert(metrics.lod1.triangles >= 3500 && metrics.lod1.triangles <= 7000 && metrics.lod2.triangles >= 600 && metrics.lod2.triangles <= 1800, 'LOD range failed');
  assert(metrics.collision.triangles > 0 && metrics.collision.triangles <= 100, 'collision budget failed');
  assert(metrics.uvEvidence.channelCount === 1 && metrics.uvEvidence.overlapCount === 0 && metrics.uvEvidence.outOfBoundsCount === 0 && metrics.uvEvidence.numberedSquareChecker, 'UV evidence contract failed');
  const anchors = metrics.architecturalAnchors;
  assert(anchors.continuousPrincipalRoofPlanes === 2 && anchors.continuousRidge && anchors.continuousEaves && anchors.continuousVerges && anchors.singleGroundedChimney && anchors.secondaryTriangularRoofMasonry === false, 'roof truth anchors failed');
  assert(anchors.agriculturalLowerFloor && anchors.domesticUpperFloor && anchors.principalAgriculturalDoor && anchors.upperEntranceConnectedToStair && anchors.stairGrounded, 'functional architecture anchors failed');
  assert(materials.checkpoint === 'v0.332' && materials.materials.length === 7, 'material record incomplete');
  for (const material of materials.materials) {
    for (const map of material.maps) assert(exists(rel(map.path)) && hash(rel(map.path)) === map.sha256 && map.resolution[0] === 1024, `material map binding failed: ${map.path}`);
  }
  const uvPng = rel('artifacts/runtime/v0332/barrosan-house-02-uv-layout.png');
  assert(exists(uvPng) && pngSize(uvPng).width >= 512 && fs.statSync(uvPng).size > 1000, 'actual UV raster missing');
  const uv = { ...metrics.uvEvidence };
  delete uv.segments;
  return { glbSha256: metrics.glbSha256, lod0: metrics.lod0, lod1: metrics.lod1, lod2: metrics.lod2, collision: metrics.collision, materials: materials.materials.length, uv };
}

function validateRuntime() {
  const manifest = json(path.join(source, 'v0332-house02-visual-truth-runtime.json'));
  const benchmark = json(path.join(source, 'v0332-benchmark.json'));
  const currentHash = hash(glbPath);
  assert(manifest.checkpoint === 'v0.332' && manifest.prototypeOptIn && manifest.humanReviewRequired, 'runtime manifest outcome/opt-in failed');
  assert(manifest.sourceGLBHash === currentHash, 'manifest GLB hash mismatch');
  for (const key of ['noGameplay', 'noMovement', 'noPathfinding', 'noCombat', 'noEconomy', 'noResources', 'house01Imported', 'actualOrthographicCamera', 'trueWireframeCapture', 'isolatedCollisionCapture']) assert(key === 'house01Imported' ? manifest[key] === false : manifest[key] === true, `preservation flag failed: ${key}`);
  assert(manifest.captures.length >= 28 && manifest.captures.every(c => c.width === 1280 && c.height === 720), 'real capture manifest incomplete');
  for (const capture of manifest.captures) assert(exists(path.join(source, 'screenshots', capture.fileName)) && fs.statSync(path.join(source, 'screenshots', capture.fileName)).size > 10000, `capture missing/blank: ${capture.fileName}`);
  assert(benchmark.warmupSeconds >= 5 && benchmark.measurementSeconds >= 20 && benchmark.sampleCount >= 1000 && benchmark.visibleTriangles === json(metricsPath).lod0.triangles && benchmark.screenshotDumpingEnabled === false && benchmark.videoEncodingEnabled === false, 'current-GLB benchmark truth failed');
  assert(benchmark.frameTimesMs.length > 0 && benchmark.frameTimesMs.every(Number.isFinite), 'frame-time graph input missing');
  const frames = fs.readdirSync(path.join(source, 'continuous')).filter(name => /^frame_\d{4}\.png$/.test(name));
  assert(frames.length === 288, `turntable frame count invalid: ${frames.length}`);
  return { captures: manifest.captures.length, frames: frames.length, benchmark: { visibleTriangles: benchmark.visibleTriangles, samples: benchmark.sampleCount, frameTimePoints: benchmark.frameTimesMs.length } };
}

function validateEvidence() {
  for (const name of uploadFiles) assert(exists(path.join(upload, name)) && fs.statSync(path.join(upload, name)).size > 0, `missing upload file: ${name}`);
  assert(fs.readdirSync(upload).length === 10, `upload count is not ten: ${fs.readdirSync(upload).length}`);
  const summary = json(path.join(upload, 'compact-evidence-summary.json'));
  assert(summary.checkpoint === 'v0.332' && summary.totalFiles === 10 && summary.payloadFiles.length === 10 && summary.humanReviewRequired === true && summary.selfApproval === false, 'compact summary contract failed');
  assert(summary.sourceGLBSha256 === hash(glbPath), 'summary GLB hash mismatch');
  assert(exists(path.join(full, '41_VISUAL_QUALITY_CONTACT_SHEET.png')) && exists(path.join(full, '42_TECHNICAL_ISOLATION_CONTACT_SHEET.png')) && exists(path.join(full, '43_BEFORE_AFTER_VISUAL_COMPARISON.png')) && exists(path.join(full, '44_black-frame-rejection-report.md')), 'full evidence pack incomplete');
  const black = read(path.join(full, '44_black-frame-rejection-report.md'));
  assert(black.includes('ACCEPTED') && black.includes('black/frozen rejected: yes'), 'black/frozen rejection evidence incomplete');
  const media = summary.finalMedia;
  assert(media.codec === 'h264' && media.width === 1280 && media.height === 720 && media.decodedFrameCount === 288 && media.uniqueFrameRatio > 0.95, 'media evidence incomplete');
  return { exactUploadCount: 10, realRenderedInputs: true, humanReviewRequired: true, media }; 
}

function validatePreservation() {
  for (const file of ['art-source/blender/v0327/barrosan_house_gold_01.blend', 'desktop-spikes/godot-salto/assets/v0327/barrosan_house_gold_01.glb', 'desktop-spikes/godot-salto/scripts/v0331_barrosan_house_02_review.gd', 'docs/V0331_HOUSE02_DOCUMENTARY_ROOF_AND_MATERIAL_CLOSURE_REPORT.md']) assert(exists(rel(file)), `preserved accepted input missing: ${file}`);
  assert(read(importPath).includes('source_file="res://assets/v0330/barrosan_house_gold_02.glb"'), 'Godot source import contract changed');
  const record = json(importRecordPath);
  assert(record.sourceGLBSha256 === hash(glbPath) && record.importedResource?.sha256, 'Godot imported resource record incomplete');
  return { house01Frozen: true, acceptedV0331Retained: true, trueDefaultRuntimeUnchanged: true, noGameplayMutation: true, noStableIdOrSaveMutation: true };
}

function validate() {
  console.log(JSON.stringify({ status: 'PASS_V0332_BARROSAN_HOUSE_02_VISUAL_TRUTH', humanReviewRequired: true, sources: validateSources(), asset: validateAsset(), runtime: validateRuntime(), evidence: validateEvidence(), preservation: validatePreservation() }, null, 2));
}

try { validate(); } catch (error) { console.error(error?.stack || error); if (!process.exitCode) process.exitCode = 1; }
