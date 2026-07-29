import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '../..');
const file = (p) => path.join(root, p);
const read = (p) => fs.readFileSync(file(p), 'utf8');
const must = (ok, message) => { if (!ok) throw new Error(`FAIL_V0418: ${message}`); };
const png = (p) => {
  const b = fs.readFileSync(file(p));
  must(b.length > 10000, `capture too small: ${p}`);
  must(b.readUInt32BE(0) === 0x89504e47, `not PNG: ${p}`);
  return { bytes: b.length, width: b.readUInt32BE(16), height: b.readUInt32BE(20) };
};
must(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0418SecondaryBarnOpeningsValueHierarchyTool.mjs validate');
const script = read('desktop-spikes/godot-salto/scripts/v0418_secondary_barn_openings_value_hierarchy.gd');
const router = read('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = read('package.json');
const report = 'docs/V0418_SECONDARY_BARN_OPENINGS_VALUE_HIERARCHY_REPORT.md';
const scene = 'desktop-spikes/godot-salto/scenes/v0418_secondary_barn_openings_value_hierarchy.tscn';
must(fs.existsSync(file(report)), 'report missing');
must(fs.existsSync(file(scene)), 'scene missing');
for (const token of ['v0417_secondary_barn_wall_value_hierarchy.gd','V0418_CHECKPOINT','V0418_LIMITATION','BARN_ENTRANCE','BARN_WINDOW_RECESS','V0418_Secondary_Barn_Entrance_Door','V0418_Secondary_Barn_Window_Recess','materialOnly','newMeshInstances']) must(script.includes(token), `script contract missing: ${token}`);
for (const token of ['--v0418-secondary-barn-openings-capture','--v0418-secondary-barn-openings-smoke','v0418_secondary_barn_openings_value_hierarchy.gd']) must(router.includes(token), `router contract missing: ${token}`);
for (const token of ['godot:play:v0418-secondary-barn-openings','godot:smoke:v0418-secondary-barn-openings','godot:capture:v0418-secondary-barn-openings','godot:validate:v0418-secondary-barn-openings']) must(pkg.includes(token), `package command missing: ${token}`);
const names = ['01_PRIMARY_RTS_COLOUR.png','02_SECONDARY_BARN_OPENINGS_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_SECONDARY_BARN_OPENINGS_CLOSE_GRAYSCALE.png','05_TEMPORARY_BARN_OPENING_NODE_ID.png','06_V0417_V0418_WIDE_COMPARISON.png','07_V0417_V0418_BARN_CLOSE_COMPARISON.png','v0418-preservation-audit.json'];
for (const n of names) { must(fs.existsSync(file(`desktop-spikes/godot-salto/artifacts/runtime/v0418/${n}`)), `runtime evidence missing: ${n}`); must(fs.existsSync(file(`artifacts/manual-review/v0418-secondary-barn-openings-value-hierarchy/${n}`)), `review evidence missing: ${n}`); }
const dimensions = Object.fromEntries(names.filter(n => n.endsWith('.png')).map(n => [n, png(`desktop-spikes/godot-salto/artifacts/runtime/v0418/${n}`)]));
must(dimensions['01_PRIMARY_RTS_COLOUR.png'].width === 1920 && dimensions['01_PRIMARY_RTS_COLOUR.png'].height === 1080, 'wide dimensions invalid');
must(dimensions['06_V0417_V0418_WIDE_COMPARISON.png'].width === 3840 && dimensions['06_V0417_V0418_WIDE_COMPARISON.png'].height === 1080, 'comparison dimensions invalid');
const audit = JSON.parse(read('desktop-spikes/godot-salto/artifacts/runtime/v0418/v0418-preservation-audit.json'));
must(audit.baselineCommit === '02edf9d0e469bf11ea9d3597a5768f62c422e757', `baseline mismatch: ${audit.baselineCommit}`);
for (const key of ['materialOnly','geometryChanged','topologyChanged','indicesChanged','verticesChanged','surfacesChanged','transformsChanged','aabbChanged','uvArraysChanged','overlays','decals','duplicateMeshes','gameplay']) must(audit[key] === (key === 'materialOnly'), `preservation flag failed: ${key}`);
must(audit.newMeshInstances === 0 && audit.stateBehavior === 'unchanged' && audit.defaultRuntime === 'unchanged' && audit.fallbackRenderer === 'unchanged' && audit.debugRenderer === 'unchanged', 'runtime preservation failed');
must(audit.v0417Audit?.checkpoint === 'v0.417', 'v0.417 preservation chain missing');
if (audit.candidateRetained) {
  must(audit.status === 'RENDERED_CANDIDATE', 'candidate status invalid');
  must(Number(audit.affectedNodeCount) === 3, 'opening inventory must contain exactly three nodes');
  must((audit.functionalClassification?.V0399_Barn_Entrance_Door || '') === 'BARN_ENTRANCE', 'entrance role missing');
  must((audit.functionalClassification?.['V0399_Barn_Front_Window_-2_25'] || '') === 'BARN_WINDOW_RECESS', 'left window role missing');
  must((audit.functionalClassification?.V0399_Barn_Front_Window_2_25 || '') === 'BARN_WINDOW_RECESS', 'right window role missing');
  must(Array.isArray(audit.unexpectedVisibleOpeningNames) && audit.unexpectedVisibleOpeningNames.length === 0, 'unexpected opening inventory');
  must(JSON.stringify(audit.finalMaterials).includes('V0418_Secondary_Barn_Entrance_Door'), 'door candidate missing');
  must(JSON.stringify(audit.finalMaterials).includes('V0418_Secondary_Barn_Window_Recess'), 'window candidate missing');
  console.log('PASS_V0418_SECONDARY_BARN_OPENINGS_VALUE_HIERARCHY_VALIDATOR (material-only candidate; 3 exact opening nodes; 7 real captures)');
} else {
  must(audit.status === 'ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_OPENINGS', `unexpected fail-closed status: ${audit.status}`);
  must(Array.isArray(audit.expectedInventory), 'fail-closed expected inventory missing');
  console.log('PASS_V0418_SECONDARY_BARN_OPENINGS_VALUE_HIERARCHY_VALIDATOR (fail-closed limitation; no candidate retained)');
}
