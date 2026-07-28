import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '../..');
const file = (p) => path.join(root, p);
const read = (p) => fs.readFileSync(file(p), 'utf8');
const must = (ok, message) => { if (!ok) throw new Error(`FAIL_V0420: ${message}`); };
const png = (p) => {
  const b = fs.readFileSync(file(p));
  must(b.length > 10000, `capture too small: ${p}`);
  must(b.readUInt32BE(0) === 0x89504e47, `not PNG: ${p}`);
  return { bytes: b.length, width: b.readUInt32BE(16), height: b.readUInt32BE(20) };
};
must(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0420SecondaryBarnStoneBaseValueHierarchyTool.mjs validate');
const script = read('desktop-spikes/godot-salto/scripts/v0420_secondary_barn_stone_base_value_hierarchy.gd');
const router = read('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = read('package.json');
const report = 'docs/V0420_SECONDARY_BARN_STONE_BASE_VALUE_HIERARCHY_REPORT.md';
const scene = 'desktop-spikes/godot-salto/scenes/v0420_secondary_barn_stone_base_value_hierarchy.tscn';
must(fs.existsSync(file(report)), 'report missing');
must(fs.existsSync(file(scene)), 'scene missing');
for (const token of ['v0419_secondary_barn_front_gable_value_integration.gd','V0420_CHECKPOINT','V0420_LIMITATION','BARN_STONE_BASE','V0420_Secondary_Barn_Stone_Base','V0399_Barn_Contact_Shadow','materialOnly','newMeshInstances']) must(script.includes(token), `script contract missing: ${token}`);
for (const token of ['--v0420-secondary-barn-stone-base-capture','--v0420-secondary-barn-stone-base-smoke','v0420_secondary_barn_stone_base_value_hierarchy.gd']) must(router.includes(token), `router contract missing: ${token}`);
for (const token of ['godot:play:v0420-secondary-barn-stone-base','godot:smoke:v0420-secondary-barn-stone-base','godot:capture:v0420-secondary-barn-stone-base','godot:validate:v0420-secondary-barn-stone-base']) must(pkg.includes(token), `package command missing: ${token}`);
const names = ['01_PRIMARY_RTS_COLOUR.png','02_SECONDARY_BARN_STONE_BASE_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_SECONDARY_BARN_STONE_BASE_CLOSE_GRAYSCALE.png','05_TEMPORARY_BARN_STONE_BASE_NODE_ID.png','06_V0419_V0420_WIDE_COMPARISON.png','07_V0419_V0420_BARN_BASE_CLOSE_COMPARISON.png','v0420-preservation-audit.json'];
for (const n of names) { must(fs.existsSync(file(`desktop-spikes/godot-salto/artifacts/runtime/v0420/${n}`)), `runtime evidence missing: ${n}`); must(fs.existsSync(file(`artifacts/manual-review/v0420-secondary-barn-stone-base-value-hierarchy/${n}`)), `review evidence missing: ${n}`); }
const dimensions = Object.fromEntries(names.filter(n => n.endsWith('.png')).map(n => [n, png(`desktop-spikes/godot-salto/artifacts/runtime/v0420/${n}`)]));
must(dimensions['01_PRIMARY_RTS_COLOUR.png'].width === 1920 && dimensions['01_PRIMARY_RTS_COLOUR.png'].height === 1080, 'wide dimensions invalid');
must(dimensions['06_V0419_V0420_WIDE_COMPARISON.png'].width === 3840 && dimensions['06_V0419_V0420_WIDE_COMPARISON.png'].height === 1080, 'comparison dimensions invalid');
const audit = JSON.parse(read('desktop-spikes/godot-salto/artifacts/runtime/v0420/v0420-preservation-audit.json'));
must(audit.baselineCommit === '50d8879dd12e1800bbd0835421483194f6103f1c', `baseline mismatch: ${audit.baselineCommit}`);
for (const key of ['materialOnly','geometryChanged','topologyChanged','indicesChanged','verticesChanged','surfacesChanged','transformsChanged','aabbChanged','uvArraysChanged','overlays','decals','duplicateMeshes','gameplay']) must(audit[key] === (key === 'materialOnly'), `preservation flag failed: ${key}`);
must(audit.newMeshInstances === 0 && audit.stateBehavior === 'unchanged' && audit.defaultRuntime === 'unchanged' && audit.fallbackRenderer === 'unchanged' && audit.debugRenderer === 'unchanged', 'runtime preservation failed');
must(audit.v0419Audit?.checkpoint === 'v0.419', 'v0.419 preservation chain missing');
if (audit.candidateRetained) {
  must(audit.status === 'RENDERED_CANDIDATE', 'candidate status invalid');
  must(Number(audit.affectedNodeCount) === 1, 'stone-base inventory must contain exactly one node');
  must((audit.functionalClassification?.V0399_Barn_Stone_Base || '') === 'BARN_STONE_BASE', 'stone-base role missing');
  must(audit.excludedContactShadow === 'V0399_Barn_Contact_Shadow', 'contact shadow exclusion missing');
  must(Array.isArray(audit.unexpectedVisibleBaseNames) && audit.unexpectedVisibleBaseNames.length === 0, 'unexpected base inventory');
  must(JSON.stringify(audit.finalMaterials).includes('V0420_Secondary_Barn_Stone_Base'), 'base candidate missing');
  console.log('PASS_V0420_SECONDARY_BARN_STONE_BASE_VALUE_HIERARCHY_VALIDATOR (material-only candidate; 1 exact base node; excluded contact shadow; 7 real captures)');
} else {
  must(audit.status === 'ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_STONE_BASE', `unexpected fail-closed status: ${audit.status}`);
  must(Array.isArray(audit.expectedInventory), 'fail-closed expected inventory missing');
  console.log('PASS_V0420_SECONDARY_BARN_STONE_BASE_VALUE_HIERARCHY_VALIDATOR (fail-closed limitation; no candidate retained)');
}
