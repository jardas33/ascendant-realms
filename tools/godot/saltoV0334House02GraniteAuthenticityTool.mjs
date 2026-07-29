import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const root = process.cwd();
const rel = (value) => path.join(root, value);
const exists = (value) => fs.existsSync(rel(value));
const read = (value) => fs.readFileSync(rel(value), 'utf8');
const json = (value) => JSON.parse(read(value));
const sha = (value) => crypto.createHash('sha256').update(fs.readFileSync(rel(value))).digest('hex');
const errors = [];
const assert = (condition, message) => { if (!condition) errors.push(message); };

const base = 'b9fec221c4020f015c6dcf486415adbeabb5e5c4';
const metricsPath = 'artifacts/runtime/v0334/barrosan-house-02-blender-metrics.json';
const materialPath = 'artifacts/runtime/v0334/barrosan-house-02-material-record.json';
const dimensionPath = 'artifacts/runtime/v0334/barrosan-house-02-dimensions.json';
const glbPath = 'desktop-spikes/godot-salto/assets/v0334/barrosan_house_gold_02.glb';
const packPath = 'artifacts/manual-review/v0334-house02-granite-authenticity/UPLOAD_TO_CHAT';
const expectedPack = ['00_READ_ME_FIRST.md', '01_DOCUMENTARY_GRANITE_MASONRY_ANALYSIS.png', '02_THREE_GRANITE_CANDIDATES_AND_SELECTION.png', '03_V0333_REJECTED_TO_V0334_GRANITE_AUTHENTICITY.png', '04_ACCEPTED_ROOF_AND_ARCHITECTURE_PRESERVATION.png', '05_ACTUAL_GRANITE_PBR_MAPS_AND_MATERIAL_RESPONSE.png', '06_CHECKER_UV_DENSITY_AND_DIMENSIONS.png', '07_WIREFRAME_COLLISION_LODS_AND_BENCHMARK.png', '08_CONTINUOUS_BARROSAN_HOUSE02_V0334_TURNTABLE.mp4', 'compact-evidence-summary.json'];

function pngSize(file) {
  const buffer = fs.readFileSync(rel(file));
  if (buffer.readUInt32BE(0) !== 0x89504e47) return null;
  return { width: buffer.readUInt32BE(16), height: buffer.readUInt32BE(20), bytes: buffer.length };
}

function finish() {
  if (errors.length) {
    console.error(JSON.stringify({ status: 'FAIL_V0334_HOUSE02_GRANITE_AUTHENTICITY', base, errors }, null, 2));
    process.exit(1);
  }
  console.log(JSON.stringify({ status: 'PASS_V0334_HOUSE02_GRANITE_AUTHENTICITY', base, checks: 30 }, null, 2));
}

assert(exists('desktop-spikes/godot-salto/scenes/review/V0334BarrosanHouse02GraniteAuthenticity.tscn'), 'v0.334 opt-in scene missing');
assert(exists('desktop-spikes/godot-salto/scripts/v0334_barrosan_house_02_granite_authenticity.gd'), 'v0.334 Godot evidence script missing');
assert(exists('tools/blender/generate_v0334_barrosan_house_02.py'), 'v0.334 Blender source missing');
assert(exists('tools/godot/captureGodotV0334House02GraniteAuthenticityWindows.ps1'), 'v0.334 capture command missing');
assert(exists('tools/godot/buildV0334House02GraniteAuthenticityPack.py'), 'v0.334 pack command missing');
assert(exists('tools/godot/saltoV0334House02GraniteAuthenticityTool.mjs'), 'v0.334 validator missing');
assert(exists(metricsPath) && exists(materialPath) && exists(dimensionPath) && exists(glbPath), 'v0.334 runtime records or GLB missing');
if (exists(metricsPath) && exists(materialPath) && exists(dimensionPath) && exists(glbPath)) {
  const metrics = json(metricsPath); const materials = json(materialPath); const dimensions = json(dimensionPath);
  assert(metrics.checkpoint === 'v0.334', 'metrics checkpoint mismatch');
  assert(metrics.glbSha256 === sha(glbPath), 'metrics GLB SHA does not match current GLB');
  assert(metrics.architecturalAnchors?.roofFormPreserved === true && metrics.architecturalAnchors?.principalRoofSlopeCount === 2, 'accepted v0.333 roof form was not preserved');
  assert(metrics.architecturalAnchors?.falseCrossGablesRemoved === true, 'false cross-gable preservation anchor missing');
  assert(metrics.materialDiagnosis?.humanReviewRequired === true && metrics.materialDiagnosis?.automatedVisualApproval === false, 'human gate was weakened');
  assert(metrics.materialDiagnosis?.sourceHeightMap === 'art-source/materials/v0334/granite_height_2048.png', 'common height source missing');
  assert(metrics.uvEvidence?.formula?.includes('UV island pixel area'), 'exact texel-density formula missing');
  const density = metrics.uvEvidence?.surfaceGroupDensityTexelsPerMeter ?? {};
  assert(Object.keys(density).length === 10, 'ten surface-group density records required');
  assert(Object.values(density).every((value) => value >= 128 && value <= 384), 'texel-density target out of range');
  assert(dimensions.principalHouseBodyBounds && dimensions.housePlusStairLandingBounds && dimensions.completeArchitecturalAssetBounds && dimensions.collisionBounds && dimensions.reviewSceneBounds, 'dimension reconciliation categories incomplete');
  assert(metrics.stoneHierarchy?.sharedSource?.includes('granite_height_2048.png'), 'stone hierarchy is not tied to common source');
  for (const candidate of ['granite_candidate_a_1024.png', 'granite_candidate_b_1024.png', 'granite_candidate_c_1024.png']) {
    assert(exists(`art-source/materials/v0334/${candidate}`) && exists(`desktop-spikes/godot-salto/assets/v0334/${candidate}`), `candidate map missing: ${candidate}`);
  }
  for (const map of ['granite_height_2048.png', 'granite_albedo_2048.png', 'granite_roughness_2048.png', 'granite_normal_2048.png']) {
    const image = pngSize(`art-source/materials/v0334/${map}`);
    assert(image && image.width === 2048 && image.height === 2048 && image.bytes > 10000, `2048 granite map invalid: ${map}`);
  }
  assert(materials.commonSource === 'art-source/materials/v0334/granite_height_2048.png', 'material record common source mismatch');
  assert(materials.candidates?.length === 3, 'material record must expose A/B/C candidates');
}

assert(exists(packPath), 'v0.334 upload pack missing');
if (exists(packPath)) {
  const names = fs.readdirSync(rel(packPath)).sort();
  assert(JSON.stringify(names) === JSON.stringify([...expectedPack].sort()), `exact ten-file pack mismatch: ${names.join(', ')}`);
  for (const file of expectedPack.filter((name) => name.endsWith('.png'))) {
    const image = pngSize(`${packPath}/${file}`);
    assert(image && image.width >= 256 && image.height >= 144 && image.bytes > 1000, `review evidence image invalid: ${file}`);
  }
  assert(fs.statSync(rel(`${packPath}/08_CONTINUOUS_BARROSAN_HOUSE02_V0334_TURNTABLE.mp4`)).size > 10000, 'turntable media missing or too small');
  const summary = json(`${packPath}/compact-evidence-summary.json`);
  assert(summary.checkpoint === 'v0.334' && summary.humanReviewRequired === true && summary.automatedVisualApproval === false, 'pack summary gate mismatch');
  assert(summary.roofOutcome === 'ROOF FORM PRESERVED — PASS', 'roof outcome not carried into pack');
  assert(summary.texelDensityFormula === 'sqrt(UV island pixel area / world surface area)', 'pack density formula mismatch');
}

const script = read('desktop-spikes/godot-salto/scripts/v0334_barrosan_house_02_granite_authenticity.gd');
assert(script.includes('ImmediateMesh') && script.includes('Mesh.PRIMITIVE_LINES'), 'wireframe is not an actual triangle-edge renderer');
assert(script.includes('V0334IsolatedGraniteCandidateStudy'), 'isolated candidate study missing');
assert(script.includes('measurementSeconds') && script.includes('rawSampleCount') && script.includes('storedSampleCount'), '20-second benchmark evidence fields missing');
assert(!script.includes('V0333_CHECKER'), 'v0.333 checker remains bound in v0.334 script');

finish();
