import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const script = path.join(root, 'desktop-spikes/godot-salto/scripts/v0409_secondary_barn_roof_surface_readability.gd');
const scene = path.join(root, 'desktop-spikes/godot-salto/scenes/v0409_secondary_barn_roof_surface_readability.tscn');
const router = path.join(root, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = path.join(root, 'package.json');
const report = path.join(root, 'docs/V0409_SECONDARY_BARN_ROOF_SURFACE_READABILITY_REPORT.md');
const runtime = path.join(root, 'desktop-spikes/godot-salto/artifacts/runtime/v0409');
const pack = path.join(root, 'artifacts/manual-review/v0409-secondary-barn-roof-surface-readability');
const files = [
  '01_PRIMARY_RTS_COLOUR.png',
  '02_SECONDARY_BARN_ROOF_CLOSE_COLOUR.png',
  '03_PRIMARY_RTS_GRAYSCALE.png',
  '04_SECONDARY_BARN_ROOF_GRAYSCALE.png',
  '05_SECONDARY_BARN_ROOF_MATERIAL_DIAGNOSTIC.png',
  '06_V0408_V0409_WIDE_COMPARISON.png',
  '07_V0408_V0409_BARN_ROOF_CLOSE_COMPARISON.png',
  'v0409-preservation-audit.json'
];
const forbidden = ['move_and_slide', 'NavigationAgent', 'pathfinding', 'route_follow', 'attack', 'damage', 'hit_points', 'economy', 'production_queue', 'spawn_unit', 'add_building', 'queue_free', 'combat', 'construct_building', 'new_geometry', 'BoxMesh.new'];
const must = (condition, message) => { if (!condition) throw new Error(`FAIL_V0409: ${message}`); };
const read = file => fs.readFileSync(file, 'utf8');
const png = file => { const bytes = fs.readFileSync(file); must(bytes.readUInt32BE(0) === 0x89504e47, `not PNG: ${file}`); return { width: bytes.readUInt32BE(16), height: bytes.readUInt32BE(20), bytes: bytes.length }; };

function validate() {
  for (const [file, label] of [[script, 'script'], [scene, 'scene'], [router, 'router'], [pkg, 'package'], [report, 'report']]) must(fs.existsSync(file), `${label} missing`);
  const g = read(script), r = read(router), p = read(pkg), d = read(report);
  for (const token of ['v0408_main_house_roof_surface_readability.gd', 'V0399_Barn_Front_Gable', 'V0399_Barn_Roof_Left', 'V0399_Barn_Roof_Right', 'V0399_Barn_Ridge_Beam', 'V0399_Barn_Left_Eave', 'V0399_Barn_Right_Eave', 'v0338/barrosan_house_02_material_gold_candidate_slate_albedo_1024.png', 'materialOnly', 'uvArraysChanged', 'geometryChanged', 'ASSET_UV_LIMITATION_SECONDARY_BARN_ROOF']) must(g.includes(token), `script contract missing: ${token}`);
  for (const token of ['--v0409-secondary-barn-roof-capture', '--v0409-secondary-barn-roof-smoke', 'v0409_secondary_barn_roof_surface_readability.gd']) must(r.includes(token), `router contract missing: ${token}`);
  for (const token of ['godot:play:v0409-secondary-barn-roof', 'godot:smoke:v0409-secondary-barn-roof', 'godot:capture:v0409-secondary-barn-roof', 'godot:validate:v0409-secondary-barn-roof']) must(p.includes(token), `package command missing: ${token}`);
  for (const token of ['v0.408', 'material-only', 'barn', 'UV', 'walls', 'entrance', 'eaves', 'grayscale', 'default runtime']) must(d.toLowerCase().includes(token.toLowerCase()), `report evidence missing: ${token}`);
  for (const file of files) {
    const runtimeFile = path.join(runtime, file), packFile = path.join(pack, file);
    must(fs.existsSync(runtimeFile), `runtime evidence missing: ${file}`);
    must(fs.existsSync(packFile), `review pack evidence missing: ${file}`);
    if (file.endsWith('.png')) { const image = png(runtimeFile); must(image.width === (file.startsWith('06_') || file.startsWith('07_') ? 3840 : 1920) && image.height === 1080 && image.bytes > 10000, `invalid capture: ${file}`); }
  }
  must(!forbidden.some(token => g.toLowerCase().includes(token.toLowerCase())), 'forbidden gameplay or replacement-geometry token in script');
  const audit = JSON.parse(read(path.join(runtime, 'v0409-preservation-audit.json')));
  must(['RENDERED_CANDIDATE', 'ASSET_UV_LIMITATION_SECONDARY_BARN_ROOF'].includes(audit.status), `audit status ${audit.status}`);
  must(audit.materialOnly === true && audit.geometryChanged === false && audit.uvArraysChanged === false, 'material-only preservation failed');
  must(audit.topologyChanged === false && audit.indicesChanged === false && audit.verticesChanged === false && audit.transformsChanged === false && audit.aabbChanged === false, 'mesh preservation failed');
  must(audit.newGeometry === false && audit.duplicateMeshes === false && audit.duplicateSurfaces === false && audit.overlays === false && audit.decals === false, 'duplicate/overlay contract failed');
  must(audit.gameplay === false && audit.defaultRuntime === 'unchanged' && audit.fallbackRenderer === 'unchanged' && audit.debugRenderer === 'unchanged', 'runtime preservation failed');
  if (audit.status === 'RENDERED_CANDIDATE') {
    must(audit.candidateRetained === true, 'rendered candidate must be explicitly retained');
    must(audit.requiredBarnRoofNodes === 6, 'expected six existing visible barn roof/trim material nodes');
    console.log('PASS_V0409_SECONDARY_BARN_ROOF_SURFACE_READABILITY_VALIDATOR (material-only candidate; existing barn roof nodes; UV-preserving; 7 real captures)');
  } else {
    must(audit.candidateRetained === false, 'UV limitation must retain no candidate');
    must(String(audit.reason).includes('no UV arrays'), 'UV limitation reason must identify missing UV arrays');
    console.log('PASS_V0409_SECONDARY_BARN_ROOF_SURFACE_READABILITY_VALIDATOR (fail-closed ASSET_UV_LIMITATION_SECONDARY_BARN_ROOF; no candidate retained; diagnostic evidence preserved)');
  }
}

if (process.argv[2] !== 'validate') throw new Error('usage: node tools/godot/saltoV0409SecondaryBarnRoofSurfaceReadabilityTool.mjs validate');
validate();
