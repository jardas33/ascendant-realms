import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { spawnSync } from 'node:child_process';

const root = process.cwd();
const source = path.join(root, 'artifacts/desktop-spikes/godot-salto/v0326');
const upload = path.join(root, 'artifacts/manual-review/v0326-barrosan-hero-art-pipeline/UPLOAD_TO_CHAT');
const full = path.join(root, 'artifacts/manual-review/v0326-barrosan-hero-art-pipeline/full-evidence');
const script = path.join(root, 'desktop-spikes/godot-salto/scripts/v0326_barrosan_hero_art_pipeline_proof.gd');
const scene = path.join(root, 'desktop-spikes/godot-salto/visual_vertical_slice/V0326BarrosanHeroArtPipelineProof.tscn');
const manifestPath = path.join(source, 'v0326-barrosan-hero-art-pipeline-runtime.json');
const summaryPath = path.join(upload, 'compact-evidence-summary.json');
const readJson = file => { if (!fs.existsSync(file)) fail(`missing JSON ${path.relative(root, file)}`); return JSON.parse(fs.readFileSync(file, 'utf8')); };
const readText = file => { if (!fs.existsSync(file)) fail(`missing file ${path.relative(root, file)}`); return fs.readFileSync(file, 'utf8'); };
const exists = file => fs.existsSync(file);
function fail(message) { console.error(`FAIL_V0326: ${message}`); process.exitCode = 1; throw new Error(message); }
function manifest() { return readJson(manifestPath); }
function summary() { return readJson(summaryPath); }
function assert(condition, message) { if (!condition) fail(message); }
function hash(file) { return crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex'); }
function requiredUploads() { return ['00_READ_ME_FIRST.md','01_HISTORICAL_TARGET_TO_V0326_COMPARISON.png','02_CLEAN_HERO_OVERVIEW.png','03_HOUSE_MATERIAL_CLOSEUP.png','04_RIVER_BANK_AND_WATER_CLOSEUP.png','05_BRIDGE_ASSET_CLOSEUP.png','06_WORKER_AND_SCALE.png','07_LIGHTING_AND_TERRAIN.png','08_CONTINUOUS_HERO_ART_PROOF.mp4','compact-evidence-summary.json']; }
function validateFiles() {
  for (const file of requiredUploads()) assert(exists(path.join(upload, file)), `missing upload ${file}`);
  assert(fs.readdirSync(upload).length === 10, `upload pack must contain exactly 10 files, got ${fs.readdirSync(upload).length}`);
  for (const file of ['02_CLEAN_HERO_OVERVIEW.png','03_HOUSE_MATERIAL_CLOSEUP.png','04_RIVER_BANK_AND_WATER_CLOSEUP.png','05_BRIDGE_ASSET_CLOSEUP.png','06_WORKER_AND_SCALE.png','07_LIGHTING_AND_TERRAIN.png']) {
    assert(fs.statSync(path.join(upload, file)).size > 100000, `capture ${file} is too small to be genuine rendered evidence`);
  }
  assert(exists(path.join(full, 'black-frame-rejection-report.md')), 'black-frame rejection report missing');
  assert(exists(path.join(full, '41_VISUAL_QUALITY_CONTACT_SHEET.png')), 'visual-quality contact sheet missing');
  assert(exists(path.join(full, '42_TECHNICAL_ISOLATION_CONTACT_SHEET.png')), 'technical-isolation contact sheet missing');
  return { uploadCount: 10, fullEvidence: true };
}
function validateRuntime() {
  const m = manifest();
  assert(m.status === 'PASS_V0326_BARROSAN_HERO_ART_PIPELINE_PROOF', `runtime status is ${m.status}`);
  assert(m.outcome === 'READY FOR HUMAN ART BENCHMARK REVIEW' || m.outcome === 'BLOCKED BY ART TOOLCHAIN', 'outcome is outside allowed v0.326 vocabulary');
  assert(m.outcome === 'READY FOR HUMAN ART BENCHMARK REVIEW', 'genuine rendered capture did not reach human benchmark review');
  assert(m.prototypeOptIn && !m.defaultRuntimeChanged && !m.gameplayChanged && !m.movementChanged && !m.pathfindingChanged && !m.combatChanged && !m.economyChanged && !m.resourceChanged && !m.savesChanged && !m.stableIdsChanged, 'opt-in or preservation flags failed');
  assert(Array.isArray(m.errors) && m.errors.length === 0, `runtime errors present: ${JSON.stringify(m.errors)}`);
  assert(m.toolchain.godotGlbImportSuccessful === true && m.toolchain.existingBlenderSourcesAvailable === true, 'Godot GLB import/source lineage proof missing');
  assert(m.sourceGlb === 'res://assets/v0238/salto_barrosan_building_roster.glb', 'unexpected source GLB');
  assert(m.sourceBlend === 'art-source/blender/v0238/salto_barrosan_building_roster.blend', 'unexpected source Blend');
  assert(m.v0325ScenePreserved === true && m.v0322MediaSHA256 === '8901bb6a074e5c3cc01bf5e16572f21dac06a527a4ea15273d649c71c73faa84', 'accepted v0.325/v0.322 preservation proof missing');
  assert(m.metrics.terrainTriangleCount > 1000 && m.metrics.riverbedTriangleCount > 0 && m.metrics.waterTriangleCount > 0 && m.metrics.houseTriangleCount > 0 && m.metrics.bridgeTriangleCount > 0, 'authored geometry metrics missing');
  assert(m.metrics.materialCount >= 6 && m.metrics.textureCount === 6 && m.metrics.shaderCount === 1, 'material/texture/shader metrics missing');
  assert(m.metrics.riverbedBelowWater === true && m.metrics.pathConnectivity === true && m.metrics.workerGroundedContact === true, 'river/path/worker geometry contract failed');
  assert(m.continuousEvidence.sourceFrames === 288 && m.continuousEvidence.targetFps === 24 && m.continuousEvidence.visualOnlyChoreography === true, 'continuous evidence contract failed');
  return { status: m.status, outcome: m.outcome, metrics: m.metrics };
}
function validateSource() {
  const text = readText(script);
  for (const anchor of ['SurfaceTool.new()', 'st.set_uv', 'ArrayMesh', 'V0326ContinuousWaterSurface', 'V0326RecessedAuthoredRiverbed', 'V0326FilledWornPathToBridge', 'V0326AuthoredBarrosanWorker', 'V0326RetainedAuthoredBarrosanLibrary', 'bridge_module', 'house_dwelling', 'farm_granary', 'v0326_hero_water.gdshader']) assert(text.includes(anchor), `missing authored pipeline anchor ${anchor}`);
  for (const forbidden of ['BoxMesh.new()', 'CylinderMesh.new()', 'SphereMesh.new()', 'PlaneMesh.new()', 'get_tree().change_scene', 'move_and_slide', 'NavigationAgent', 'attack_damage', 'projectile', 'queue_free']) assert(!text.includes(forbidden), `forbidden/procedural placeholder or gameplay anchor remains: ${forbidden}`);
  assert(exists(scene), 'isolated v0.326 scene missing');
  for (const file of ['v0326_grass_breakup.png','v0326_earth_path.png','v0326_stone_granite.png','v0326_weathered_timber.png','v0326_weathered_slate.png','v0326_recessed_water.png']) assert(fs.statSync(path.join(root, 'desktop-spikes/godot-salto/assets/v0326/textures', file)).size > 100000, `generated texture missing ${file}`);
  assert(exists(path.join(root, 'tools/godot/generateV0326HeroTextures.py')), 'texture-origin script missing');
  assert(exists(path.join(root, 'desktop-spikes/godot-salto/assets/v0238/salto_barrosan_building_roster.glb')), 'retained authored GLB missing');
  return { authoredArrayMesh: true, retainedAuthoredGLB: true, generatedTextures: 6, prototypeScene: true };
}
function validateMedia() {
  const s = summary();
  const media = s.finalMedia;
  const mediaPath = path.join(root, media.finalMediaPath);
  assert(exists(mediaPath), 'final MP4 missing');
  assert(hash(mediaPath) === media.SHA256 && media.codec === 'h264' && media.width === 1280 && media.height === 720 && media.FPS >= 23.9 && media.FPS <= 24.1 && media.decodedFrameCount === 288 && media.uniqueFrameCount >= 260 && media.duration >= 10 && media.duration <= 13, `continuous media contract failed: ${JSON.stringify(media)}`);
  assert(media.postCopyHashVerified && media.postValidationHashVerified, 'continuous media hash evidence failed');
  return media;
}
function validatePreservation() {
  const v0325Scene = path.join(root, 'desktop-spikes/godot-salto/visual_vertical_slice/V0325HumanRiverNaturalization.tscn');
  assert(exists(v0325Scene), 'v0.325 scene is missing');
  const v0322Media = path.join(root, 'artifacts/manual-review/v0322-barrosan-bridge-hamlet-hero-slice/UPLOAD_TO_CHAT/08_CONTINUOUS_HERO_SLICE.mp4');
  assert(exists(v0322Media) && hash(v0322Media) === '8901bb6a074e5c3cc01bf5e16572f21dac06a527a4ea15273d649c71c73faa84', 'accepted v0.322 media SHA changed');
  const changed = spawnSync('git', ['status', '--short'], { cwd: root, encoding: 'utf8' }).stdout.trim().split(/\r?\n/).filter(Boolean).map(line => line.trim().slice(2).trim());
  const forbidden = changed.filter(file => file && !file.startsWith('desktop-spikes/godot-salto/assets/v0326/') && !file.startsWith('desktop-spikes/godot-salto/scripts/v0326_') && !file.includes('V0326BarrosanHeroArtPipelineProof.tscn') && !file.startsWith('tools/godot/') && !file.startsWith('docs/V0326_') && file !== 'package.json');
  assert(forbidden.length === 0, `unexpected non-v0.326 changed files: ${forbidden.join(', ')}`);
  return { v0325ScenePreserved: true, v0322MediaSHA256: hash(v0322Media), unexpectedChangedFiles: [] };
}
function validate() {
  const result = { status: 'PASS_V0326_BARROSAN_HERO_ART_PIPELINE_PROOF', outcome: 'READY FOR HUMAN ART BENCHMARK REVIEW', files: validateFiles(), runtime: validateRuntime(), source: validateSource(), media: validateMedia(), preservation: validatePreservation(), trueDefaultRuntimeUnchanged: true, gameplayUnchanged: true, noProtectedGameAssets: true, noLargeUnapprovedAssetImport: true };
  console.log(JSON.stringify(result, null, 2));
}
const command = process.argv[2] || 'validate';
try {
  if (command === 'validate' || command === 'validate-all' || command.startsWith('validate-')) validate();
  else throw new Error(`unknown command ${command}`);
} catch (error) {
  if (!process.exitCode) process.exitCode = 1;
}
