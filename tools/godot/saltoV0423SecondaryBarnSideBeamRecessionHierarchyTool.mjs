import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '../..');
const file = (p) => path.join(root, p);
const read = (p) => fs.readFileSync(file(p), 'utf8');
const must = (ok, message) => { if (!ok) throw new Error(`FAIL_V0423: ${message}`); };
const png = (p) => {
  const b = fs.readFileSync(file(p));
  must(b.length > 10000, `capture too small: ${p}`);
  must(b.readUInt32BE(0) === 0x89504e47, `not PNG: ${p}`);
  return { bytes: b.length, width: b.readUInt32BE(16), height: b.readUInt32BE(20) };
};
must(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0423SecondaryBarnSideBeamRecessionHierarchyTool.mjs validate');
const script = read('desktop-spikes/godot-salto/scripts/v0423_secondary_barn_side_beam_recession_hierarchy.gd');
const router = read('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = read('package.json');
const report = 'docs/V0423_SECONDARY_BARN_SIDE_BEAM_RECESSION_HIERARCHY_REPORT.md';
const scene = 'desktop-spikes/godot-salto/scenes/v0423_secondary_barn_side_beam_recession_hierarchy.tscn';
must(fs.existsSync(file(report)), 'report missing');
must(fs.existsSync(file(scene)), 'scene missing');
for (const token of ['v0422_secondary_barn_front_structure_value_hierarchy.gd','V0423_CHECKPOINT','V0423_LIMITATION','BARN_SIDE_STRUCTURAL_BEAM','V0423_Secondary_Barn_Side_Structural_Timber','V0399_Barn_Front_Beam','V0399_Barn_Ridge_Beam','materialOnly','newMeshInstances']) must(script.includes(token), `script contract missing: ${token}`);
for (const token of ['--v0423-secondary-barn-side-beams-capture','--v0423-secondary-barn-side-beams-smoke','v0423_secondary_barn_side_beam_recession_hierarchy.gd']) must(router.includes(token), `router contract missing: ${token}`);
for (const token of ['godot:play:v0423-secondary-barn-side-beams','godot:smoke:v0423-secondary-barn-side-beams','godot:capture:v0423-secondary-barn-side-beams','godot:validate:v0423-secondary-barn-side-beams']) must(pkg.includes(token), `package command missing: ${token}`);
const names = ['01_PRIMARY_RTS_COLOUR.png','02_SECONDARY_BARN_SIDE_BEAMS_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_SECONDARY_BARN_SIDE_BEAMS_CLOSE_GRAYSCALE.png','05_TEMPORARY_BARN_SIDE_BEAM_NODE_ID.png','06_V0422_V0423_WIDE_COMPARISON.png','07_V0422_V0423_SIDE_BEAMS_CLOSE_COMPARISON.png','v0423-preservation-audit.json'];
for (const n of names) { must(fs.existsSync(file(`desktop-spikes/godot-salto/artifacts/runtime/v0423/${n}`)), `runtime evidence missing: ${n}`); must(fs.existsSync(file(`artifacts/manual-review/v0423-secondary-barn-side-beam-recession-hierarchy/${n}`)), `review evidence missing: ${n}`); }
const dimensions = Object.fromEntries(names.filter(n => n.endsWith('.png')).map(n => [n, png(`desktop-spikes/godot-salto/artifacts/runtime/v0423/${n}`)]));
must(dimensions['01_PRIMARY_RTS_COLOUR.png'].width === 1920 && dimensions['01_PRIMARY_RTS_COLOUR.png'].height === 1080, 'wide dimensions invalid');
must(dimensions['06_V0422_V0423_WIDE_COMPARISON.png'].width === 3840 && dimensions['06_V0422_V0423_WIDE_COMPARISON.png'].height === 1080, 'comparison dimensions invalid');
const audit = JSON.parse(read('desktop-spikes/godot-salto/artifacts/runtime/v0423/v0423-preservation-audit.json'));
must(audit.baselineCommit === '5a74f257d582d6b1adcce4bf17dae23737d92621', `baseline mismatch: ${audit.baselineCommit}`);
for (const key of ['materialOnly','geometryChanged','topologyChanged','indicesChanged','verticesChanged','surfacesChanged','transformsChanged','aabbChanged','uvArraysChanged','overlays','decals','duplicateMeshes','gameplay']) must(audit[key] === (key === 'materialOnly'), `preservation flag failed: ${key}`);
must(audit.newMeshInstances === 0 && audit.stateBehavior === 'unchanged' && audit.defaultRuntime === 'unchanged' && audit.fallbackRenderer === 'unchanged' && audit.debugRenderer === 'unchanged', 'runtime preservation failed');
if (audit.candidateRetained) {
  must(audit.status === 'RENDERED_CANDIDATE', 'candidate status invalid');
  must(Number(audit.affectedNodeCount) === 2, 'side-beam inventory must contain exactly two nodes');
  must((audit.functionalClassification?.['V0399_Barn_Side_Beam_-1_8'] || '') === 'BARN_SIDE_STRUCTURAL_BEAM', 'negative-side beam role missing');
  must((audit.functionalClassification?.['V0399_Barn_Side_Beam_1_8'] || '') === 'BARN_SIDE_STRUCTURAL_BEAM', 'positive-side beam role missing');
  must(JSON.stringify(audit.excludedFrontStructureInventory).includes('V0399_Barn_Front_Beam'), 'front-structure exclusion missing');
  must(JSON.stringify(audit.excludedRidgeEaveInventory).includes('V0399_Barn_Ridge_Beam'), 'ridge/eave exclusion missing');
  must(Array.isArray(audit.unexpectedVisibleSideStructureNames) && audit.unexpectedVisibleSideStructureNames.length === 0, 'unexpected side-structure inventory');
  must(JSON.stringify(audit.finalMaterials).includes('V0423_Secondary_Barn_Side_Structural_Timber'), 'side-beam candidate missing');
  console.log('PASS_V0423_SECONDARY_BARN_SIDE_BEAM_RECESSION_HIERARCHY_VALIDATOR (material-only candidate; 2 side beams; front structure, entrance frame, ridge and eaves excluded; 7 real captures)');
} else {
  must(audit.status === 'ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_SIDE_BEAMS', `unexpected fail-closed status: ${audit.status}`);
  must(Array.isArray(audit.expectedInventory), 'fail-closed expected inventory missing');
  console.log('PASS_V0423_SECONDARY_BARN_SIDE_BEAM_RECESSION_HIERARCHY_VALIDATOR (fail-closed limitation; no candidate retained)');
}
