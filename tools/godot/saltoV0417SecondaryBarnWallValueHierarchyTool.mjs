import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '../..');
const file = (p) => path.join(root, p);
const read = (p) => fs.readFileSync(file(p), 'utf8');
const must = (ok, message) => { if (!ok) throw new Error(`FAIL_V0417: ${message}`); };
const png = (p) => {
  const b = fs.readFileSync(file(p));
  must(b.length > 10000, `capture too small: ${p}`);
  must(b.readUInt32BE(0) === 0x89504e47, `not PNG: ${p}`);
  return { bytes: b.length, width: b.readUInt32BE(16), height: b.readUInt32BE(20) };
};
must(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0417SecondaryBarnWallValueHierarchyTool.mjs validate');
const script = read('desktop-spikes/godot-salto/scripts/v0417_secondary_barn_wall_value_hierarchy.gd');
const router = read('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = read('package.json');
const report = 'docs/V0417_SECONDARY_BARN_WALL_VALUE_HIERARCHY_REPORT.md';
const scene = 'desktop-spikes/godot-salto/scenes/v0417_secondary_barn_wall_value_hierarchy.tscn';
must(fs.existsSync(file(report)), 'report missing');
must(fs.existsSync(file(scene)), 'scene missing');
for (const token of ['v0416_main_house_chimney_material_hierarchy.gd','V0417_CHECKPOINT','V0417_LIMITATION','BARN_WALL_BODY','V0417_Secondary_Barn_Wall_Body','materialOnly','newMeshInstances','roofGableDoorFoundation']) must(script.includes(token), `script contract missing: ${token}`);
for (const token of ['--v0417-secondary-barn-walls-capture','--v0417-secondary-barn-walls-smoke','v0417_secondary_barn_wall_value_hierarchy.gd']) must(router.includes(token), `router contract missing: ${token}`);
for (const token of ['godot:play:v0417-secondary-barn-walls','godot:smoke:v0417-secondary-barn-walls','godot:capture:v0417-secondary-barn-walls','godot:validate:v0417-secondary-barn-walls']) must(pkg.includes(token), `package command missing: ${token}`);
const names = ['01_PRIMARY_RTS_COLOUR.png','02_SECONDARY_BARN_WALLS_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_SECONDARY_BARN_WALLS_CLOSE_GRAYSCALE.png','05_TEMPORARY_BARN_WALL_NODE_ID.png','06_V0416_V0417_WIDE_COMPARISON.png','07_V0416_V0417_BARN_CLOSE_COMPARISON.png','v0417-preservation-audit.json'];
for (const n of names) { must(fs.existsSync(file(`desktop-spikes/godot-salto/artifacts/runtime/v0417/${n}`)), `runtime evidence missing: ${n}`); must(fs.existsSync(file(`artifacts/manual-review/v0417-secondary-barn-wall-value-hierarchy/${n}`)), `review evidence missing: ${n}`); }
const dimensions = Object.fromEntries(names.filter(n => n.endsWith('.png')).map(n => [n, png(`desktop-spikes/godot-salto/artifacts/runtime/v0417/${n}`)]));
must(dimensions['01_PRIMARY_RTS_COLOUR.png'].width === 1920 && dimensions['01_PRIMARY_RTS_COLOUR.png'].height === 1080, 'wide dimensions invalid');
must(dimensions['06_V0416_V0417_WIDE_COMPARISON.png'].width === 3840 && dimensions['06_V0416_V0417_WIDE_COMPARISON.png'].height === 1080, 'comparison dimensions invalid');
const audit = JSON.parse(read('desktop-spikes/godot-salto/artifacts/runtime/v0417/v0417-preservation-audit.json'));
must(audit.baselineCommit === 'ca50f2a4ab547d0f9210cd59e378cbf0670a991d', `baseline mismatch: ${audit.baselineCommit}`);
for (const key of ['materialOnly','geometryChanged','topologyChanged','indicesChanged','verticesChanged','surfacesChanged','transformsChanged','aabbChanged','uvArraysChanged','overlays','decals','duplicateMeshes','gameplay']) must(audit[key] === (key === 'materialOnly'), `preservation flag failed: ${key}`);
must(audit.newMeshInstances === 0 && audit.stateBehavior === 'unchanged' && audit.defaultRuntime === 'unchanged' && audit.fallbackRenderer === 'unchanged' && audit.debugRenderer === 'unchanged', 'runtime preservation failed');
must(audit.v0416Audit?.checkpoint === 'v0.416', 'v0.416 preservation chain missing');
if (audit.candidateRetained) {
  must(audit.status === 'RENDERED_CANDIDATE', 'candidate status invalid');
  must(Object.values(audit.functionalClassification || {}).includes('BARN_WALL_BODY'), 'barn wall body role missing');
  must(Number(audit.affectedNodeCount) >= 1, 'barn wall inventory too small');
  console.log(`PASS_V0417_SECONDARY_BARN_WALL_VALUE_HIERARCHY_VALIDATOR (material-only candidate; ${audit.affectedNodeCount} dynamic wall nodes; 7 real captures)`);
} else {
  must(audit.status === 'ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_WALLS', `unexpected fail-closed status: ${audit.status}`);
  must(Array.isArray(audit.affectedNodeNames) && Array.isArray(audit.candidateDebugNames), 'fail-closed inventory missing');
  console.log('PASS_V0417_SECONDARY_BARN_WALL_VALUE_HIERARCHY_VALIDATOR (fail-closed limitation; no candidate retained)');
}
