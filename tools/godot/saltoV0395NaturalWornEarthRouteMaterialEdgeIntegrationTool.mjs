import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const repo = process.cwd();
const file = p => path.join(repo, p);
const read = p => fs.readFileSync(p, 'utf8');
const must = (v, label) => { if (!v) throw new Error(`missing ${label}`); };
const sha256 = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const png = p => {
  const b = fs.readFileSync(p);
  if (b.readUInt32BE(0) !== 0x89504e47) throw new Error(`${p} is not PNG`);
  return { w: b.readUInt32BE(16), h: b.readUInt32BE(20), bytes: b.length, hash: sha256(p) };
};

const sourceGlb = file('external-art-intake/original-barrosan/v0380-authored-highland-infrastructure/exports/barrosan_highland_infrastructure_v0380.glb');
const importedGlb = file('desktop-spikes/godot-salto/assets/v0380/corrected-highland-infrastructure/barrosan_highland_infrastructure_v0380.glb');
const priorScript = file('desktop-spikes/godot-salto/scripts/v0394_route_only_visibility_repair_fence_regression_rollback.gd');
const script = file('desktop-spikes/godot-salto/scripts/v0395_natural_worn_earth_route_material_edge_integration.gd');
const scene = file('desktop-spikes/godot-salto/scenes/v0395_natural_worn_earth_route_material_edge_integration.tscn');
const router = file('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const packageJson = file('package.json');
const report = file('docs/V0395_NATURAL_WORN_EARTH_ROUTE_MATERIAL_EDGE_INTEGRATION_REPORT.md');
const runtime = file('desktop-spikes/godot-salto/artifacts/runtime/v0395');
const pack = file('artifacts/manual-review/v0395-natural-worn-earth-route-material-edge-integration');
const images = [
  '01_PRIMARY_RTS_VIEW.png', '02_SETTLEMENT_AND_CROSSING_CONTEXT.png',
  '03_CLOSE_ROUTE_YARD_DOORWAY.png', '04_BARN_BRANCH_CONNECTION.png',
  '05_GRAYSCALE_PRIMARY.png', '06_GRAYSCALE_CLOSE_ROUTE.png',
  '07_V0394_V0395_PRIMARY_COMPARISON.png'
];
const packFiles = [...images, '08_ITERATION_SUMMARY.md', '09_VALIDATION.json'];
const expectedGlb = '746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb';

function validate() {
  for (const [p, label] of [
    [sourceGlb, 'accepted source GLB'], [importedGlb, 'accepted imported GLB'],
    [priorScript, 'v0.394 baseline script'], [script, 'v0.395 script'], [scene, 'v0.395 scene'],
    [router, 'opt-in router'], [packageJson, 'package commands'], [report, 'v0.395 report']
  ]) must(fs.existsSync(p), label);
  if (sha256(sourceGlb) !== expectedGlb || sha256(importedGlb) !== expectedGlb) throw new Error('accepted v0.380 GLB hash changed');

  const g = read(script); const prior = read(priorScript); const visual = `${prior}\n${g}`; const r = read(router); const pkg = read(packageJson); const reportText = read(report);
  for (const token of [
    'v0394_route_only_visibility_repair_fence_regression_rollback.gd',
    'V0395_Natural_Worn_Earth_Route_Material_Edge_Integration',
    'V0395_One_Compacted_Warm_Earth_Bridge_Yard_Door_Route',
    'V0395_Short_Compacted_Warm_Earth_Barn_Entrance_Branch',
    'v0394_route_topology_preserved', 'v0395_material', 'compacted_warm_worn_earth',
    'narrow_landings_wide_working_yard', 'vertex_color_use_as_albedo',
    'BaseMaterial3D.CULL_DISABLED', 'V0395_Door_Threshold_Stone',
    'v0395-natural-worn-earth-route-material-edge-integration.json',
    'gameplay": false', 'defaultRuntime": "unchanged"'
  ]) must(visual.includes(token), `script contract ${token}`);
  for (const token of [
    '--v0395-route-material', '--v0395-route-material-smoke', '--v0395-route-material-capture',
    'v0395_natural_worn_earth_route_material_edge_integration.gd'
  ]) must(r.includes(token), `router contract ${token}`);
  for (const token of [
    'godot:play:v0395-route-material', 'godot:smoke:v0395-route-material',
    'godot:capture:v0395-route-material', 'godot:validate:v0395-route-material'
  ]) must(pkg.includes(token), `package contract ${token}`);
  for (const token of ['V0394_One_Flush_Continuous_Worn_Earth_Route_Only', 'V0394_Short_Flush_Contrasting_Barn_Entrance_Branch', 'v0393_fence_geometry_removed']) must(prior.includes(token), `v0.394 preservation ${token}`);
  for (const forbidden of ['move_and_slide', 'NavigationAgent', 'pathfinding', 'route_follow', 'attack', 'damage', 'hit_points', 'economy', 'production_queue', 'spawn_unit', 'add_building', 'queue_free', 'combat', 'construct_building']) if (g.toLowerCase().includes(forbidden.toLowerCase())) throw new Error(`visual script contains forbidden gameplay token: ${forbidden}`);
  for (const token of ['v0.394', 'route topology', 'compacted warm worn earth', 'default runtime', 'independent visual review']) must(reportText.toLowerCase().includes(token.toLowerCase()), `report evidence ${token}`);

  for (const name of images) {
    must(fs.existsSync(path.join(runtime, name)), `runtime ${name}`);
    const p = png(path.join(runtime, name));
    if (p.w !== (name.startsWith('07_') ? 3840 : 1920) || p.h !== 1080 || p.bytes < 10000) throw new Error(`${name} invalid dimensions or size`);
  }
  must(fs.existsSync(path.join(runtime, 'v0395-natural-worn-earth-route-material-edge-integration.json')), 'runtime manifest');
  must(fs.existsSync(pack), 'v0.395 review pack');
  const actual = fs.readdirSync(pack).filter(n => fs.statSync(path.join(pack, n)).isFile()).sort();
  if (JSON.stringify(actual) !== JSON.stringify(packFiles.slice().sort())) throw new Error('review pack file contract failed');
  const validation = JSON.parse(read(path.join(pack, '09_VALIDATION.json')));
  if (!["READY FOR INDEPENDENT V0395 VISUAL REVIEW", "ACCEPTED BY INDEPENDENT V0395 VISUAL REVIEW"].includes(validation.status)) throw new Error('review pack status mismatch');
  const hashes = new Set(images.map(i => png(path.join(pack, i)).hash));
  if (hashes.size !== images.length) throw new Error('duplicate v0.395 captures');
  console.log('PASS_V0395_NATURAL_WORN_EARTH_ROUTE_MATERIAL_EDGE_INTEGRATION_VALIDATOR (7 real captures; v0.394 topology preserved; opt-in visual only)');
}

if (process.argv[2] === 'validate') validate();
else throw new Error('usage: node tools/godot/saltoV0395NaturalWornEarthRouteMaterialEdgeIntegrationTool.mjs validate');
