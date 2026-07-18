import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const rel = (p) => path.join(root, p);
const exists = (p) => fs.existsSync(rel(p));
const read = (p) => fs.readFileSync(rel(p), 'utf8');
const json = (p) => JSON.parse(read(p));
const hash = (p) => crypto.createHash('sha256').update(fs.readFileSync(rel(p))).digest('hex');
const errors = [];
const assert = (condition, message) => { if (!condition) errors.push(message); };

const base = '42b643f56b9fe94f7b82634ad841f6b59a93a70c';
const metricsPath = 'artifacts/runtime/v0333/barrosan-house-02-blender-metrics.json';
const materialPath = 'artifacts/runtime/v0333/barrosan-house-02-material-record.json';
const dimensionPath = 'artifacts/runtime/v0333/barrosan-house-02-dimensions.json';
const glbPath = 'desktop-spikes/godot-salto/assets/v0333/barrosan_house_gold_02.glb';
const uploadDir = rel('artifacts/manual-review/v0333-house02-granite-roof/UPLOAD_TO_CHAT');
const fullDir = rel('artifacts/manual-review/v0333-house02-granite-roof/full-evidence');
const uploadFiles = [
  '00_READ_ME_FIRST.md', '01_DOCUMENTARY_SOURCES_AND_COMPLETE_METADATA.png',
  '02_PRIMARY_REFERENCE_TRACE_AND_MODEL_OVERLAY.png', '03_V0332_REJECTED_TO_V0333_GRANITE_TRUTH.png',
  '04_TRUE_ORTHOGRAPHICS_AND_COMPLETE_DIMENSIONS.png', '05_SIMPLE_ROOF_GRANITE_STAIR_AND_OPENINGS.png',
  '06_ACTUAL_PBR_MAPS_MATERIAL_DIAGNOSIS_AND_CHECKER.png', '07_TRUE_WIREFRAME_UV_COLLISION_LODS_AND_BENCHMARK.png',
  '08_CONTINUOUS_BARROSAN_HOUSE02_V0333_TURNTABLE.mp4', 'compact-evidence-summary.json',
];
const screenshots = [
  'diagnostic_granite_full_lighting.png', 'diagnostic_granite_albedo_only.png',
  'diagnostic_granite_normal_neutral_grey.png', 'diagnostic_granite_normal_disabled.png',
  'unlabelled_close_facade.png', 'unlabelled_normal_rts.png', 'unlabelled_far_rts.png',
  'unlabelled_greyscale.png', 'unlabelled_thumbnail.png', 'ordinary_rts.png', 'front_orthographic.png',
  'rear_orthographic.png', 'left_orthographic.png', 'right_orthographic.png', 'top_orthographic.png',
  'roof_front_three_quarter.png', 'roof_rear_three_quarter.png', 'roof_direct_top.png', 'roof_left_verge.png',
  'roof_right_verge.png', 'roof_ridge_chimney.png', 'house02_stair_landing.png', 'materials_and_openings.png',
  'granite_closeup.png', 'roof_material_closeup.png', 'human_scale_and_units.png', 'checker_front.png',
  'checker_roof.png', 'checker_rotation_a.png', 'checker_rotation_b.png', 'lod0_overview.png',
  'lod1_overview.png', 'lod2_overview.png', 'collision_overview.png', 'wireframe_lod0.png',
];

function validate() {
  assert(exists(metricsPath), 'v0.333 metrics missing');
  assert(exists(materialPath), 'v0.333 material record missing');
  assert(exists(dimensionPath), 'v0.333 dimensions missing');
  assert(exists(glbPath), 'v0.333 GLB missing');
  assert(exists('desktop-spikes/godot-salto/scenes/review/V0333BarrosanHouse02GraniteRoof.tscn'), 'v0.333 opt-in scene missing');
  assert(exists('tools/godot/captureGodotV0333House02GraniteRoofWindows.ps1'), 'v0.333 capture command missing');
  assert(exists('tools/blender/generateV0333BarrosanHouse02Windows.ps1'), 'v0.333 generator command missing');
  if (!exists(metricsPath) || !exists(materialPath) || !exists(glbPath)) return finish();
  const metrics = json(metricsPath); const materials = json(materialPath); const dimensions = json(dimensionPath);
  assert(metrics.checkpoint === 'v0.333', 'metrics checkpoint mismatch');
  assert(metrics.glbSha256 === hash(glbPath), 'metrics GLB SHA does not match current GLB');
  assert(metrics.lod0.triangles >= 9000 && metrics.lod0.triangles <= 16000, 'LOD0 budget failed');
  assert(metrics.lod0.objectCount <= 7 && metrics.drawCallsEstimated <= 7, 'render object/draw-call budget failed');
  assert(metrics.lod1.triangles >= 3500 && metrics.lod1.triangles <= 7000, 'LOD1 budget failed');
  assert(metrics.lod2.triangles >= 600 && metrics.lod2.triangles <= 1800, 'LOD2 budget failed');
  assert(metrics.collision.triangles <= 100, 'collision budget failed');
  const anchors = metrics.architecturalAnchors;
  assert(anchors.falseCrossGablesRemoved === true && anchors.frontRearFacadeContinuous === true, 'false cross-gable removal anchor missing');
  assert(anchors.shortEndGableWallsOnly === true && anchors.principalRoofSlopeCount === 2, 'two-slope roof anchor failed');
  assert(anchors.continuousRidge && anchors.continuousEaves && anchors.continuousVerges && anchors.singleGroundedChimney, 'roof continuity anchor failed');
  assert(anchors.darkFacadeBandAudit === 'no undocumented horizontal facade bands', 'dark facade-band audit missing');
  assert(metrics.visualGate?.humanReviewRequired === true && metrics.visualGate?.automatedVisualApproval === false, 'human visual gate was weakened');
  assert(metrics.materialDiagnosis?.cause?.includes('Smart Project') && metrics.materialDiagnosis?.cause?.includes('coherent house-scale'), 'exact granite diagnosis missing');
  assert(metrics.uvEvidence.channelCount === 1 && metrics.uvEvidence.overlapCount === 0 && metrics.uvEvidence.outOfBoundsCount === 0, 'UV overlap/bounds failed');
  assert(Object.keys(metrics.uvEvidence.surfaceGroupDensityTexelsPerMeter || {}).length === 10, 'per-surface density groups missing');
  const density = Object.values(metrics.uvEvidence.surfaceGroupDensityTexelsPerMeter || {});
  assert(Math.max(...density) / Math.min(...density) < 1.15, 'surface-group density target failed');
  assert(dimensions.humanFigureHeight === 1.75 && dimensions.units === 'metres', 'authored dimensions missing human scale');
  assert(materials.checkpoint === 'v0.333' && materials.materials.length === 7, 'material record incomplete');
  for (const material of materials.materials) for (const map of material.maps || []) {
    assert(exists(map.path), `bound material map missing: ${map.path}`);
    assert(map.colorSpace && map.compression && map.mipmap !== undefined && map.filtering !== undefined && map.repeat !== undefined, `complete import metadata missing: ${map.path}`);
  }
  const runtime = rel('artifacts/desktop-spikes/godot-salto/v0333');
  assert(fs.existsSync(runtime), 'v0.333 capture root missing');
  for (const name of screenshots) {
    const file = path.join(runtime, 'screenshots', name);
    assert(fs.existsSync(file) && fs.statSync(file).size > 1000, `capture missing or blank: ${name}`);
  }
  const benchmark = runtime && fs.existsSync(path.join(runtime, 'v0333-benchmark.json')) ? JSON.parse(fs.readFileSync(path.join(runtime, 'v0333-benchmark.json'), 'utf8')) : null;
  assert(benchmark && benchmark.sampleCount === 1500 && benchmark.frameTimesMs?.length === 1500, 'benchmark does not store exactly 1,500 frame-time samples');
  if (benchmark) {
    assert(benchmark.measurementSeconds >= 20 && benchmark.visibleTriangles === metrics.lod0.triangles, 'benchmark duration/current-GLB consistency failed');
    assert(benchmark.screenshotDumpingEnabled === false && benchmark.videoEncodingEnabled === false, 'benchmark isolation flags failed');
  }
  assert(fs.existsSync(fullDir) && fs.existsSync(path.join(fullDir, '44_black-frame-rejection-report.md')), 'full evidence/rejection report missing');
  assert(fs.existsSync(uploadDir), 'upload pack missing');
  if (fs.existsSync(uploadDir)) {
    const actual = fs.readdirSync(uploadDir).filter((name) => fs.statSync(path.join(uploadDir, name)).isFile()).sort();
    assert(JSON.stringify(actual) === JSON.stringify([...uploadFiles].sort()), 'upload pack is not exactly the required ten files');
    const summary = path.join(uploadDir, 'compact-evidence-summary.json');
    assert(fs.existsSync(summary), 'compact evidence summary missing');
    if (fs.existsSync(summary)) {
      const compact = JSON.parse(fs.readFileSync(summary, 'utf8'));
      assert(compact.totalFiles === 10 && compact.humanReviewRequired === true && compact.selfApproval === false, 'compact summary contract failed');
      assert(compact.architecture.falseCrossGablesRemoved === true && compact.architecture.principalRoofSlopeCount === 2, 'compact roof summary failed');
      assert(compact.documentary.completeMetadata === true && compact.documentary.traceAndOverlay === true, 'compact documentary summary failed');
    }
  }
  const README = read('art-source/references/v0331/documentary/README.md');
  assert(README.includes('30987') && README.includes('30985') && README.includes('30986') && (README.includes('UNKNOWN') || README.includes('incomplete') || README.includes('not stated')), 'complete documentary uncertainty metadata missing');
  const changed = execFileSync('git', ['diff', '--name-only', base], { cwd: root, encoding: 'utf8' }).trim().split(/\r?\n/).filter(Boolean);
  const allowed = ['.gitignore', 'art-source/blender/v0333/', 'art-source/materials/v0333/', 'artifacts/runtime/v0333/', 'desktop-spikes/godot-salto/assets/v0333/', 'desktop-spikes/godot-salto/scenes/review/V0333', 'desktop-spikes/godot-salto/scripts/v0333_', 'docs/V0333_', 'tools/blender/generate_v0333', 'tools/blender/generateV0333', 'tools/godot/buildV0333', 'tools/godot/captureGodotV0333', 'tools/godot/saltoV0333', 'package.json'];
  assert(changed.every((file) => allowed.some((prefix) => file === prefix || file.startsWith(prefix))), `unexpected out-of-scope changed file: ${changed.find((file) => !allowed.some((prefix) => file === prefix || file.startsWith(prefix))) || ''}`);
  const source = read('tools/blender/generate_v0333_barrosan_house_02.py');
  assert(!source.includes('House 01') && !source.includes('Warlords') && !source.includes('settlement integration'), 'protected or unrelated asset/runtime cue imported');
  return finish({lod0: metrics.lod0, lod1: metrics.lod1, lod2: metrics.lod2, collision: metrics.collision, glbSha256: metrics.glbSha256, sampleCount: benchmark?.sampleCount ?? 0, uploadCount: fs.existsSync(uploadDir) ? fs.readdirSync(uploadDir).length : 0, humanReviewRequired: true, outcome: 'REJECTED INTERNALLY — HOUSE STILL DOES NOT READ AS GRANITE OR FALSE ROOF FORMS REMAIN'});
}

function finish(extra = {}) {
  if (errors.length) { console.error(JSON.stringify({ status: 'FAIL_V0333_HOUSE02_GRANITE_ROOF_TRUTH', errors }, null, 2)); process.exitCode = 1; return; }
  console.log(JSON.stringify({ status: 'PASS_V0333_HOUSE02_GRANITE_ROOF_TRUTH', ...extra }, null, 2));
}

validate();
