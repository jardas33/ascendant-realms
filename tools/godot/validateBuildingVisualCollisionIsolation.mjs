import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const buildingPath = path.join(root, 'production', 'ascendant-realms-godot', 'scripts', 'buildings', 'building.gd');
const utilsPath = path.join(root, 'production', 'ascendant-realms-godot', 'scripts', 'utils', 'model_utils.gd');
const defsPath = path.join(root, 'production', 'ascendant-realms-godot', 'scripts', 'game', 'building_defs.gd');
const worldPath = path.join(root, 'production', 'ascendant-realms-godot', 'scripts', 'world', 'game_world.gd');
const controllerPath = path.join(root, 'production', 'ascendant-realms-godot', 'scripts', 'world', 'rts_controller.gd');
const testPath = path.join(root, 'production', 'ascendant-realms-godot', 'tests', 'building_visual_collision_isolation_test.gd');

const building = fs.readFileSync(buildingPath, 'utf8');
const utils = fs.readFileSync(utilsPath, 'utf8');
const defs = fs.readFileSync(defsPath, 'utf8');
const world = fs.readFileSync(worldPath, 'utf8');
const controller = fs.readFileSync(controllerPath, 'utf8');
const test = fs.readFileSync(testPath, 'utf8');

function fail(message) {
  console.error(`G1C-A2-A2 FAIL ${message}`);
  process.exit(1);
}

for (const id of ['barrosan_clanhold', 'barrosan_war_hall', 'barrosan_clan_croft']) {
  if (!defs.includes(`"${id}": {`)) fail(`missing canonical definition ${id}`);
}
for (const token of ['var visual_root: Node3D', 'var collision_root: Node3D', 'visual_root.name = "VisualRoot"', 'collision_root.name = "CollisionRoot"', 'model_root.add_child(visual_root)', 'model_root.add_child(collision_root', 'visual_root.add_child(m)', 'ModelUtils.add_per_part_convex_collision_to(m, collision_root, 4)', 'model_root.position.y = lerp']) {
  if (!building.includes(token)) fail(`missing structural contract ${token}`);
}
if (!utils.includes('static func add_per_part_convex_collision_to(node: Node3D, destination_root: Node3D, collision_layer: int = 1) -> int')) fail('destination-root utility missing');
if (!utils.includes('destination_root.add_child(body)') || !utils.includes('body.transform = mesh_transform')) fail('generated collision destination transform contract missing');
for (const token of ['parts.sort_custom', 'min(parts.size(), 25)', 'mi.mesh.create_convex_shape(true, true)', 'body.collision_layer = collision_layer', 'body.collision_mask = 0']) {
  if (!utils.includes(token)) fail(`collision policy changed or missing ${token}`);
}
if (utils.includes('visual_scale') || utils.includes('presentation_scale')) fail('visual hierarchy scale value introduced in shared utility');
if (building.includes('visual_root.scale =') || building.includes('presentation_scale') || building.includes('visual_scale')) fail('production building scale introduced');
if (!building.includes('selection_ring.position.y = 0.1') || !building.includes('add_child(selection_ring)')) fail('selection ring moved into presentation subtree');
if (!building.includes('rally_point = global_position + Vector3(0, 0, footprint + 3.0)')) fail('rally formula changed');
if (!building.includes('model_root.position.y = lerp(-footprint * 0.9, 0.0, clamp(p, 0.0, 1.0))')) fail('construction movement no longer uses common root');
if (world.includes('NavigationObstacle3D') || building.includes('NavigationObstacle3D')) fail('navigation obstacle introduced');
if (!test.includes('visual_root') || !test.includes('collision_root') || !test.includes('VisualRoot test scale changed collision AABB')) fail('focused test does not prove ownership and test-only decoupling');
if (!controller.includes('2 | 4 | 8')) fail('selection raycast mask contract unavailable');
const changed = [];
const status = execFileSync('git', ['status', '--short'], {cwd: root, encoding: 'utf8'}).split(/\r?\n/).filter(Boolean);
for (const line of status) {
  const file = line.slice(3);
  if (file) changed.push(file);
}
const allowed = new Set([
  'production/ascendant-realms-godot/scripts/buildings/building.gd',
  'production/ascendant-realms-godot/scripts/utils/model_utils.gd',
  'production/ascendant-realms-godot/tests/building_visual_collision_isolation_test.gd',
  'tools/godot/validateBuildingVisualCollisionIsolation.mjs',
]);
if (changed.some((file) => !allowed.has(file)) || changed.length > 4) fail(`scope violation: ${changed.join(', ')}`);
console.log('G1C-A2-A2 PASS building visual/collision ownership isolation contract');
