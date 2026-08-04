import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const defsPath = path.join(root, 'production', 'ascendant-realms-godot', 'scripts', 'game', 'unit_defs.gd');
const unitPath = path.join(root, 'production', 'ascendant-realms-godot', 'scripts', 'units', 'unit.gd');
const defs = fs.readFileSync(defsPath, 'utf8');
const unit = fs.readFileSync(unitPath, 'utf8');
const targets = {
  barrosan_worker: { scale: '0.90', model: 'barrosan_highlander_worker' },
  barrosan_spear_guard: { scale: '1.0', model: 'barrosan_spear_guard' },
  barrosan_hero_thane: { scale: '1.13', model: 'barrosan_hero_thane' },
};

function fail(message) {
  console.error(`G1C-A1 FAIL ${message}`);
  process.exit(1);
}

for (const [id, expected] of Object.entries(targets)) {
  const start = defs.indexOf(`"${id}": {`);
  if (start < 0) fail(`missing canonical definition ${id}`);
  const end = defs.indexOf('\n\t},', start);
  const block = defs.slice(start, end < 0 ? defs.length : end);
  if (!block.includes(`"visual_scale": ${expected.scale}`)) fail(`wrong visual_scale for ${id}`);
  if (!block.includes(`"${expected.model}"`)) fail(`canonical model changed for ${id}`);
}
const scaleUses = [...defs.matchAll(/"visual_scale"\s*:/g)].length;
if (scaleUses !== 3) fail(`expected exactly three visual_scale definitions, found ${scaleUses}`);
if (!unit.includes('model_root.scale = Vector3.ONE * visual_scale')) fail('visual scale is not isolated to model_root');
if (!unit.includes('ModelUtils.ground_model(model_root)')) fail('scaled visual subtree is not regrounded');
const visualStart = unit.indexOf('var visual_scale');
const visualEnd = unit.indexOf('\t\t# animation', visualStart);
const context = unit.slice(visualStart, visualEnd < 0 ? visualStart : visualEnd);
for (const forbidden of ['global_position', 'position =', 'NavigationAgent3D', 'CollisionShape3D', 'collision_layer', 'agent.radius =']) {
  if (context.includes(forbidden)) fail(`visual patch touches forbidden gameplay node/property ${forbidden}`);
}
console.log('G1C-A1 PASS isolated three-role visual hierarchy contract');
