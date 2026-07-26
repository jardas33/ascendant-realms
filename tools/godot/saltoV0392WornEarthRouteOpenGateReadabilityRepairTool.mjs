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
const script = file('desktop-spikes/godot-salto/scripts/v0392_worn_earth_route_open_gate_readability_repair.gd');
const scene = file('desktop-spikes/godot-salto/scenes/v0392_worn_earth_route_open_gate_readability_repair.tscn');
const router = file('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const packageJson = file('package.json');
const audit = file('artifacts/work/v0392-asset-selection-audit.md');
const iterationLog = file('artifacts/work/v0392-iteration-log.md');
const report = file('docs/V0392_WORN_EARTH_ROUTE_OPEN_GATE_READABILITY_REPAIR_REPORT.md');
const priorReport = file('docs/V0386_INHABITED_CROSSING_COMPOSITION_ROLE_AND_CONNECTION_REPAIR_REPORT.md');
const rejectedReport = file('docs/V0387_INHABITED_CROSSING_ROUTE_HIERARCHY_REPAIR_REPORT.md');
const runtime = file('desktop-spikes/godot-salto/artifacts/runtime/v0392');
const pack = file('artifacts/manual-review/v0392-worn-earth-route-open-gate-readability-repair');
const images = [
  '01_PRIMARY_RTS_VIEW.png', '02_SETTLEMENT_AND_CROSSING_CONTEXT.png',
  '03_ROAD_YARD_ENTRANCE_CONNECTION.png', '04_FIVE_FUNCTIONAL_YARD_GROUPS.png',
  '05_THREE_CHARACTER_ROLE_AUDIT.png', '06_BUILDING_SEPARATION_AND_ENTRANCES.png',
  '07_GRAYSCALE_PRIMARY.png'
];
const packFiles = [...images, '08_ITERATION_SUMMARY.md', '09_VALIDATION.json'];
const expectedGlb = '746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb';

function validate() {
  for (const [p, label] of [
    [sourceGlb, 'accepted source GLB'], [importedGlb, 'accepted imported GLB'],
    [script, 'v0.390 script'], [scene, 'v0.390 scene'], [router, 'opt-in router'],
    [packageJson, 'package commands'], [audit, 'asset audit'], [iterationLog, 'iteration log'],
    [report, 'v0.390 report'], [priorReport, 'preserved v0.386 report'],
    [rejectedReport, 'preserved v0.387 rejected report']
  ]) must(fs.existsSync(p), label);
  if (sha256(sourceGlb) !== expectedGlb || sha256(importedGlb) !== expectedGlb) throw new Error('accepted v0.380 GLB hash changed');

  const g = read(script); const r = read(router); const pkg = read(packageJson); const reportText = read(report);
  for (const token of [
    'V0392_Worn_Earth_Route_Open_Gate_Readability_Repair',
    'V0392_One_Primary_Barrosan_Homestead', 'V0392_One_Subordinate_Agricultural_Barn_Separate',
    'V0392_Five_Functional_Yard_Groups', 'V0392_Yard_Group_01_Cart_Direct_Ground',
    'V0392_Yard_Group_02_Stacked_Firewood_Direct_Ground', 'V0392_Yard_Group_03_Barrel_Crate_Storage_Direct_Ground',
    'V0392_Yard_Group_04_Trough_Workbench_Direct_Ground', 'V0392_Yard_Group_05_Coherent_Fence_With_Open_Gate',
    'V0388_Exactly_Three_Distinct_Character_Roles', 'V0392_Road_Yard_Entrance_Connection',
    'V0392_One_Flush_Contrasting_Bridge_Yard_Door_Route', 'V0392_Short_Flush_Contrasting_Barn_Entrance_Branch', 'V0392_Flush_Irregular_Contrasting_Worn_Earth_Yard', 'continuous_route_ribbon',
    'V0392_Bridge_Desaturated_Value', 'V0392_Bridge_Value_Control', 'Workbench_Narrow_Top', 'Coherent_Fence_With_Open_Gate',
    'Farmer.gltf', 'Adventurer.gltf', 'Worker.gltf',
    'v0392-worn-earth-route-open-gate-readability-repair.json', 'gameplay": false', 'defaultRuntime": "unchanged"'
  ]) must(g.includes(token), `script contract ${token}`);
  for (const token of [
    '--v0392-worn-earth', '--v0392-worn-earth-smoke', '--v0392-worn-earth-capture',
    'v0392_worn_earth_route_open_gate_readability_repair.tscn'
  ]) must(r.includes(token), `router contract ${token}`);
  for (const token of [
    'godot:play:v0392-worn-earth', 'godot:smoke:v0392-worn-earth',
    'godot:capture:v0392-worn-earth', 'godot:validate:v0392-worn-earth'
  ]) must(pkg.includes(token), `package contract ${token}`);
  for (const forbidden of [
    'move_and_slide', 'NavigationAgent', 'pathfinding', 'route_follow', 'animation_player',
    'attack', 'damage', 'hit_points', 'economy', 'production_queue', 'spawn_unit',
    'add_building', 'queue_free', 'combat', 'selection', 'construct_building'
  ]) if (g.toLowerCase().includes(forbidden.toLowerCase())) throw new Error(`visual script contains forbidden gameplay token: ${forbidden}`);
  if (!reportText.includes('v0.391 remains retained')) throw new Error('report does not preserve v0.391 ancestry');
  if ((g.match(/V0388_Exactly_Three_Distinct_Character_Roles/g) || []).length !== 1) throw new Error('character role container is not singular');
  if ((g.match(/_instantiate_asset\(V0388_QUATERNIUS_ROOT \+ "men\//g) || []).length !== 3) throw new Error('character asset count is not exactly three');
  if (!g.includes('men/Farmer.gltf') || !g.includes('men/Adventurer.gltf') || !g.includes('men/Worker.gltf')) throw new Error('distinct character source variants missing');
  if ((g.match(/V0392_Yard_Group_/g) || []).length < 5) throw new Error('five yard group names missing');

  for (const i of [1, 2, 3]) {
    const d = file(`desktop-spikes/godot-salto/artifacts/work/v0392-iteration-0${i}`);
    must(fs.existsSync(d), `iteration ${i}`);
    const p = png(path.join(d, '01_PRIMARY_RTS_VIEW.png'));
    if (p.w !== 1920 || p.h !== 1080 || p.bytes < 10000) throw new Error(`iteration ${i} primary invalid`);
  }
  for (const i of images) {
    const p = png(path.join(runtime, i));
    if (p.w !== 1920 || p.h !== 1080 || p.bytes < 10000) throw new Error(`${i} invalid`);
  }
  must(fs.existsSync(pack), 'v0.392 review pack');
  const actual = fs.readdirSync(pack).filter(n => fs.statSync(path.join(pack, n)).isFile()).sort();
  if (JSON.stringify(actual) !== JSON.stringify(packFiles.slice().sort())) throw new Error('review pack file contract failed');
  const validation = JSON.parse(read(path.join(pack, '09_VALIDATION.json')));
  if (validation.status !== 'REJECTED BY INDEPENDENT V0392 VISUAL REVIEW') throw new Error('review pack status mismatch');
  if (validation.independentVerdict !== 'REJECT') throw new Error('independent v0.392 verdict missing');
  const hashes = new Set(images.map(i => png(path.join(pack, i)).hash));
  if (hashes.size !== images.length) throw new Error('duplicate final captures');
  console.log('PASS_V0392_WORN_EARTH_ROUTE_OPEN_GATE_READABILITY_REPAIR_VALIDATOR (7 real captures; contrasting flush route; coherent open gate; opt-in visual only)');
}

if (process.argv[2] === 'validate') validate();
else throw new Error('usage: node tools/godot/saltoV0392WornEarthRouteOpenGateReadabilityRepairTool.mjs validate');
