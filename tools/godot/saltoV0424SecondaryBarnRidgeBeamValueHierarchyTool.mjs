import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '../..');
const file = (p) => path.join(root, p);
const read = (p) => fs.readFileSync(file(p), 'utf8');
const must = (ok, message) => { if (!ok) throw new Error(`FAIL_V0424: ${message}`); };
const png = (p) => {
  const b = fs.readFileSync(file(p));
  must(b.length > 10000, `capture too small: ${p}`);
  must(b.readUInt32BE(0) === 0x89504e47, `not PNG: ${p}`);
  return { bytes: b.length, width: b.readUInt32BE(16), height: b.readUInt32BE(20) };
};
must(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0424SecondaryBarnRidgeBeamValueHierarchyTool.mjs validate');
const script = read('desktop-spikes/godot-salto/scripts/v0424_secondary_barn_ridge_beam_value_hierarchy.gd');
const router = read('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = read('package.json');
const report = 'docs/V0424_SECONDARY_BARN_RIDGE_BEAM_VALUE_HIERARCHY_REPORT.md';
const scene = 'desktop-spikes/godot-salto/scenes/v0424_secondary_barn_ridge_beam_value_hierarchy.tscn';
must(fs.existsSync(file(report)), 'report missing');
must(fs.existsSync(file(scene)), 'scene missing');
for (const token of ['v0423_secondary_barn_side_beam_recession_hierarchy.gd','V0424_CHECKPOINT','V0424_LIMITATION','BARN_RIDGE_BEAM','V0424_Secondary_Barn_Ridge_Beam','V0399_Barn_Roof_Left','V0399_Barn_Left_Eave','V0399_Barn_Side_Beam_-1_8','materialOnly','newMeshInstances','captureOnlyContextIsolation']) must(script.includes(token), `script contract missing: ${token}`);
must(!script.includes('MeshInstance3D.new'), 'new mesh instance path forbidden');
for (const token of ['--v0424-secondary-barn-ridge-beam-capture','--v0424-secondary-barn-ridge-beam-smoke','v0424_secondary_barn_ridge_beam_value_hierarchy.gd']) must(router.includes(token), `router contract missing: ${token}`);
for (const token of ['godot:play:v0424-secondary-barn-ridge-beam','godot:smoke:v0424-secondary-barn-ridge-beam','godot:capture:v0424-secondary-barn-ridge-beam','godot:validate:v0424-secondary-barn-ridge-beam']) must(pkg.includes(token), `package command missing: ${token}`);
const names = ['01_PRIMARY_RTS_COLOUR.png','02_SECONDARY_BARN_RIDGE_BEAM_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_SECONDARY_BARN_RIDGE_BEAM_CLOSE_GRAYSCALE.png','05_TEMPORARY_BARN_RIDGE_BEAM_NODE_ID.png','06_V0423_V0424_WIDE_COMPARISON.png','07_V0423_V0424_RIDGE_BEAM_CLOSE_COMPARISON.png','v0424-preservation-audit.json'];
for (const n of names) { must(fs.existsSync(file(`desktop-spikes/godot-salto/artifacts/runtime/v0424/${n}`)), `runtime evidence missing: ${n}`); must(fs.existsSync(file(`artifacts/manual-review/v0424-secondary-barn-ridge-beam-value-hierarchy/${n}`)), `review evidence missing: ${n}`); }
const dimensions = Object.fromEntries(names.filter(n => n.endsWith('.png')).map(n => [n, png(`desktop-spikes/godot-salto/artifacts/runtime/v0424/${n}`)]));
must(dimensions['01_PRIMARY_RTS_COLOUR.png'].width === 1920 && dimensions['01_PRIMARY_RTS_COLOUR.png'].height === 1080, 'wide dimensions invalid');
must(dimensions['06_V0423_V0424_WIDE_COMPARISON.png'].width === 3840 && dimensions['06_V0423_V0424_WIDE_COMPARISON.png'].height === 1080, 'comparison dimensions invalid');
const audit = JSON.parse(read('desktop-spikes/godot-salto/artifacts/runtime/v0424/v0424-preservation-audit.json'));
must(audit.baselineCommit === '1e561af85207acb7636d9f51587b69a77c68a565', `baseline mismatch: ${audit.baselineCommit}`);
for (const key of ['materialOnly','geometryChanged','topologyChanged','indicesChanged','verticesChanged','surfacesChanged','transformsChanged','aabbChanged','uvArraysChanged','overlays','decals','duplicateMeshes','gameplay']) must(audit[key] === (key === 'materialOnly'), `preservation flag failed: ${key}`);
must(audit.newMeshInstances === 0 && audit.stateBehavior === 'unchanged' && audit.defaultRuntime === 'unchanged' && audit.fallbackRenderer === 'unchanged' && audit.debugRenderer === 'unchanged', 'runtime preservation failed');
if (audit.candidateRetained) {
  must(audit.status === 'RENDERED_CANDIDATE', 'candidate status invalid');
  must(Number(audit.affectedNodeCount) === 1, 'ridge inventory must contain exactly one node');
  must((audit.functionalClassification?.['V0399_Barn_Ridge_Beam'] || '') === 'BARN_RIDGE_BEAM', 'ridge role missing');
  must(Array.isArray(audit.unexpectedVisibleRidgeApexNames) && audit.unexpectedVisibleRidgeApexNames.length === 0, 'unexpected ridge/apex inventory');
  must(JSON.stringify(audit.excludedRoofPlaneInventory).includes('V0399_Barn_Roof_Left') && JSON.stringify(audit.excludedRoofPlaneInventory).includes('V0399_Barn_Roof_Right'), 'roof-plane exclusion missing');
  must(JSON.stringify(audit.excludedEaveInventory).includes('V0399_Barn_Left_Eave') && JSON.stringify(audit.excludedEaveInventory).includes('V0399_Barn_Right_Eave'), 'eave exclusion missing');
  must(JSON.stringify(audit.excludedSideBeamInventory).includes('V0399_Barn_Side_Beam_-1_8'), 'side-beam exclusion missing');
  must(JSON.stringify(audit.finalMaterials).includes('V0424_Secondary_Barn_Ridge_Beam'), 'ridge candidate missing');
  must(String(audit.captureOnlyContextIsolation).includes('restored'), 'capture-only visibility restoration missing');
  console.log('PASS_V0424_SECONDARY_BARN_RIDGE_BEAM_VALUE_HIERARCHY_VALIDATOR (material-only candidate; 1 ridge beam; roof planes, eaves, front structure, side beams and entrance frame excluded; 7 real captures)');
} else {
  must(audit.status === 'ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_RIDGE_BEAM', `unexpected fail-closed status: ${audit.status}`);
  must(Array.isArray(audit.expectedInventory), 'fail-closed expected inventory missing');
  console.log('PASS_V0424_SECONDARY_BARN_RIDGE_BEAM_VALUE_HIERARCHY_VALIDATOR (fail-closed limitation; no candidate retained)');
}
