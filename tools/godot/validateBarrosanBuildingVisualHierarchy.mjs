import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const base = '1d4b9b096e058586e19b0d84a753f0e244a975a8';
const defsRel = 'production/ascendant-realms-godot/scripts/game/building_defs.gd';
const buildingRel = 'production/ascendant-realms-godot/scripts/buildings/building.gd';
const utilsRel = 'production/ascendant-realms-godot/scripts/utils/model_utils.gd';
const projectRel = 'production/ascendant-realms-godot/project.godot';
const retainedTestRel = 'production/ascendant-realms-godot/tests/building_visual_collision_isolation_test.gd';
const retainedValidatorRel = 'tools/godot/validateBuildingVisualCollisionIsolation.mjs';
const testRel = 'production/ascendant-realms-godot/tests/barrosan_building_visual_hierarchy_test.gd';
const validatorRel = 'tools/godot/validateBarrosanBuildingVisualHierarchy.mjs';
const allowed = new Set([defsRel, buildingRel, testRel, validatorRel]);
const read = (rel) => fs.readFileSync(path.join(root, rel), 'utf8').replaceAll('\r\n', '\n');
const baseRead = (rel) => execFileSync('git', ['show', `${base}:${rel}`], { cwd: root, encoding: 'utf8' }).replaceAll('\r\n', '\n');

function fail(message) {
  console.error(`G1C-A2-A3 FAIL ${message}`);
  process.exit(1);
}

const status = execFileSync('git', ['status', '--short'], { cwd: root, encoding: 'utf8' })
  .split(/\r?\n/).filter(Boolean).map((line) => line.slice(3));
if (status.length !== 4 || status.some((file) => !allowed.has(file)) || new Set(status).size !== 4) {
  fail(`scope must contain exactly four paths: ${status.join(', ')}`);
}

const defs = read(defsRel);
const building = read(buildingRel);
const test = read(testRel);
const utils = read(utilsRel);
const baseDefs = baseRead(defsRel);
const baseBuilding = baseRead(buildingRel);

const expected = new Map([
  ['barrosan_clanhold', 1.18],
  ['barrosan_war_hall', 1.00],
  ['barrosan_clan_croft', 0.90],
]);
const visualScaleMatches = [...defs.matchAll(/"visual_scale"\s*:\s*([0-9]+(?:\.[0-9]+)?)/g)];
if (visualScaleMatches.length !== expected.size) fail(`expected exactly ${expected.size} visual_scale properties, found ${visualScaleMatches.length}`);
for (const [id, value] of expected) {
  const block = defs.match(new RegExp(`"${id}"\\s*:\\s*\\{([\\s\\S]*?)\\n\\s*\\},`));
  if (!block) fail(`missing canonical definition ${id}`);
  const match = block[1].match(/"visual_scale"\s*:\s*([0-9]+(?:\.[0-9]+)?)/);
  if (!match || Number(match[1]) !== value) fail(`${id} visual_scale must be exactly ${value}`);
}
const defsWithoutScale = defs.split('\n').filter((line) => !line.includes('"visual_scale"')).join('\n');
if (defsWithoutScale !== baseDefs) fail('building definitions changed outside the three frozen visual_scale lines');

const buildingWithoutScale = building.split('\n').filter((line) => {
  const trimmed = line.trim();
  return !trimmed.startsWith('var visual_scale :=') &&
    !trimmed.startsWith('visual_root.scale = Vector3.ONE * visual_scale') &&
    !trimmed.startsWith('ModelUtils.ground_model(visual_root)');
}).join('\n');
if (buildingWithoutScale !== baseBuilding) fail('building runtime changed outside the frozen VisualRoot scale path');

const collisionAt = building.indexOf('ModelUtils.add_per_part_convex_collision_to(m, collision_root, 4)');
const meshCollectAt = building.indexOf('_mesh_instances.append_array(ModelUtils.get_mesh_instances(m))');
const scaleAt = building.indexOf('visual_root.scale = Vector3.ONE * visual_scale');
const regroundAt = building.indexOf('ModelUtils.ground_model(visual_root)');
if (collisionAt < 0 || meshCollectAt < 0 || scaleAt < 0 || regroundAt < 0 || !(collisionAt < meshCollectAt && meshCollectAt < scaleAt && scaleAt < regroundAt)) {
  fail('production order must be collision, mesh collection, VisualRoot scale, then VisualRoot grounding');
}
if ((building.match(/visual_root\.scale\s*=/g) ?? []).length !== 1) fail('VisualRoot must receive exactly one production scale assignment');
if (building.includes('model_root.scale =') || building.includes('collision_root.scale =') || building.includes('self.scale =')) fail('shared hierarchy scale was changed');
for (const token of ['model_root.position.y = lerp(-footprint * 0.9, 0.0, clamp(p, 0.0, 1.0))', 'selection_ring.position.y = 0.1', 'rally_point = global_position + Vector3(0, 0, footprint + 3.0)']) {
  if (!building.includes(token)) fail(`preserved runtime contract missing: ${token}`);
}
if (!building.includes('float(def.get("visual_scale", 1.0))')) fail('default visual scale fallback is missing');
if (!utils.includes('add_per_part_convex_collision_to')) fail('A2-A2 collision utility is unavailable');

for (const rel of [projectRel, utilsRel, retainedTestRel, retainedValidatorRel]) {
  try { execFileSync('git', ['diff', '--quiet', base, '--', rel], { cwd: root, stdio: 'ignore' }); }
  catch { fail(`${rel} changed after A2-A2`); }
}
for (const token of ['Building.configure', 'VisualRoot', 'CollisionRoot', 'visual_scale', 'collision AABB', 'construction', 'physics ray', 'selection ring']) {
  if (!test.toLowerCase().includes(token.toLowerCase())) fail(`focused test missing contract evidence: ${token}`);
}
try { execFileSync('git', ['diff', '--check'], { cwd: root, stdio: 'ignore' }); }
catch { fail('git diff --check failed'); }

console.log('G1C-A2-A3 PASS Barrosan building visual hierarchy contract');
