import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '../..');
const file = (p) => path.join(root, p);
const read = (p) => fs.readFileSync(file(p), 'utf8');
const must = (ok, message) => { if (!ok) throw new Error(`FAIL_V0419: ${message}`); };
const png = (p) => {
  const b = fs.readFileSync(file(p));
  must(b.length > 10000, `capture too small: ${p}`);
  must(b.readUInt32BE(0) === 0x89504e47, `not PNG: ${p}`);
  return { bytes: b.length, width: b.readUInt32BE(16), height: b.readUInt32BE(20) };
};
must(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0419SecondaryBarnFrontGableValueIntegrationTool.mjs validate');
const script = read('desktop-spikes/godot-salto/scripts/v0419_secondary_barn_front_gable_value_integration.gd');
const router = read('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = read('package.json');
const report = 'docs/V0419_SECONDARY_BARN_FRONT_GABLE_VALUE_INTEGRATION_REPORT.md';
const scene = 'desktop-spikes/godot-salto/scenes/v0419_secondary_barn_front_gable_value_integration.tscn';
must(fs.existsSync(file(report)), 'report missing');
must(fs.existsSync(file(scene)), 'scene missing');
for (const token of ['v0418_secondary_barn_openings_value_hierarchy.gd','V0419_CHECKPOINT','V0419_LIMITATION','BARN_FRONT_GABLE','V0419_Secondary_Barn_Front_Gable','materialOnly','newMeshInstances']) must(script.includes(token), `script contract missing: ${token}`);
for (const token of ['--v0419-secondary-barn-front-gable-capture','--v0419-secondary-barn-front-gable-smoke','v0419_secondary_barn_front_gable_value_integration.gd']) must(router.includes(token), `router contract missing: ${token}`);
for (const token of ['godot:play:v0419-secondary-barn-front-gable','godot:smoke:v0419-secondary-barn-front-gable','godot:capture:v0419-secondary-barn-front-gable','godot:validate:v0419-secondary-barn-front-gable']) must(pkg.includes(token), `package command missing: ${token}`);
const names = ['01_PRIMARY_RTS_COLOUR.png','02_SECONDARY_BARN_FRONT_GABLE_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_SECONDARY_BARN_FRONT_GABLE_CLOSE_GRAYSCALE.png','05_TEMPORARY_BARN_FRONT_GABLE_NODE_ID.png','06_V0418_V0419_WIDE_COMPARISON.png','07_V0418_V0419_BARN_CLOSE_COMPARISON.png','v0419-preservation-audit.json'];
for (const n of names) { must(fs.existsSync(file(`desktop-spikes/godot-salto/artifacts/runtime/v0419/${n}`)), `runtime evidence missing: ${n}`); must(fs.existsSync(file(`artifacts/manual-review/v0419-secondary-barn-front-gable-value-integration/${n}`)), `review evidence missing: ${n}`); }
const dimensions = Object.fromEntries(names.filter(n => n.endsWith('.png')).map(n => [n, png(`desktop-spikes/godot-salto/artifacts/runtime/v0419/${n}`)]));
must(dimensions['01_PRIMARY_RTS_COLOUR.png'].width === 1920 && dimensions['01_PRIMARY_RTS_COLOUR.png'].height === 1080, 'wide dimensions invalid');
must(dimensions['06_V0418_V0419_WIDE_COMPARISON.png'].width === 3840 && dimensions['06_V0418_V0419_WIDE_COMPARISON.png'].height === 1080, 'comparison dimensions invalid');
const audit = JSON.parse(read('desktop-spikes/godot-salto/artifacts/runtime/v0419/v0419-preservation-audit.json'));
must(audit.baselineCommit === '99f8ca689b8eac75e4f80c3c2e3c7b729e78da42', `baseline mismatch: ${audit.baselineCommit}`);
for (const key of ['materialOnly','geometryChanged','topologyChanged','indicesChanged','verticesChanged','surfacesChanged','transformsChanged','aabbChanged','uvArraysChanged','overlays','decals','duplicateMeshes','gameplay']) must(audit[key] === (key === 'materialOnly'), `preservation flag failed: ${key}`);
must(audit.newMeshInstances === 0 && audit.stateBehavior === 'unchanged' && audit.defaultRuntime === 'unchanged' && audit.fallbackRenderer === 'unchanged' && audit.debugRenderer === 'unchanged', 'runtime preservation failed');
must(audit.v0418Audit?.checkpoint === 'v0.418', 'v0.418 preservation chain missing');
if (audit.candidateRetained) {
  must(audit.status === 'RENDERED_CANDIDATE', 'candidate status invalid');
  must(Number(audit.affectedNodeCount) === 1, 'front-gable inventory must contain exactly one node');
  must((audit.functionalClassification?.V0399_Barn_Front_Gable || '') === 'BARN_FRONT_GABLE', 'front-gable role missing');
  must(Array.isArray(audit.unexpectedVisibleGableNames) && audit.unexpectedVisibleGableNames.length === 0, 'unexpected gable inventory');
  must(JSON.stringify(audit.finalMaterials).includes('V0419_Secondary_Barn_Front_Gable'), 'gable candidate missing');
  console.log('PASS_V0419_SECONDARY_BARN_FRONT_GABLE_VALUE_INTEGRATION_VALIDATOR (material-only candidate; 1 exact gable node; 7 real captures)');
} else {
  must(audit.status === 'ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_FRONT_GABLE', `unexpected fail-closed status: ${audit.status}`);
  must(Array.isArray(audit.expectedInventory), 'fail-closed expected inventory missing');
  console.log('PASS_V0419_SECONDARY_BARN_FRONT_GABLE_VALUE_INTEGRATION_VALIDATOR (fail-closed limitation; no candidate retained)');
}
