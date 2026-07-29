import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '../..');
const file = (p) => path.join(root, p);
const read = (p) => fs.readFileSync(file(p), 'utf8');
const must = (ok, message) => { if (!ok) throw new Error(`FAIL_V0426: ${message}`); };
const png = (p) => {
  const b = fs.readFileSync(file(p));
  must(b.length > 10000, `capture too small: ${p}`);
  must(b.readUInt32BE(0) === 0x89504e47, `not PNG: ${p}`);
  return { bytes: b.length, width: b.readUInt32BE(16), height: b.readUInt32BE(20) };
};
must(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0426SecondaryBarnContactShadowRestraintHierarchyTool.mjs validate');
const script = read('desktop-spikes/godot-salto/scripts/v0426_secondary_barn_contact_shadow_restraint_hierarchy.gd');
const router = read('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = read('package.json');
const report = 'docs/V0426_SECONDARY_BARN_CONTACT_SHADOW_RESTRAINT_HIERARCHY_REPORT.md';
const scene = 'desktop-spikes/godot-salto/scenes/v0426_secondary_barn_contact_shadow_restraint_hierarchy.tscn';
must(fs.existsSync(file(report)), 'report missing');
must(fs.existsSync(file(scene)), 'scene missing');
for (const token of ['v0425_secondary_barn_eave_edge_value_hierarchy.gd','V0426_CHECKPOINT','V0426_LIMITATION','BARN_CONTACT_SHADOW','V0426_Secondary_Barn_Contact_Shadow','V0399_Barn_Contact_Shadow','V0399_Barn_Stone_Base','originalMaterialState','shadowSettingsChanged','footprintChanged','lightingChanged','captureOnlyContextIsolation','materialOnly']) must(script.includes(token), `script contract missing: ${token}`);
must(!script.includes('MeshInstance3D.new'), 'new mesh instance path forbidden');
for (const token of ['--v0426-secondary-barn-contact-shadow-capture','--v0426-secondary-barn-contact-shadow-smoke','v0426_secondary_barn_contact_shadow_restraint_hierarchy.gd']) must(router.includes(token), `router contract missing: ${token}`);
for (const token of ['godot:play:v0426-secondary-barn-contact-shadow','godot:smoke:v0426-secondary-barn-contact-shadow','godot:capture:v0426-secondary-barn-contact-shadow','godot:validate:v0426-secondary-barn-contact-shadow']) must(pkg.includes(token), `package command missing: ${token}`);
const names = ['01_PRIMARY_RTS_COLOUR.png','02_SECONDARY_BARN_CONTACT_SHADOW_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_SECONDARY_BARN_CONTACT_SHADOW_CLOSE_GRAYSCALE.png','05_TEMPORARY_BARN_CONTACT_SHADOW_NODE_ID.png','06_V0425_V0426_WIDE_COMPARISON.png','07_V0425_V0426_CONTACT_SHADOW_CLOSE_COMPARISON.png','v0426-preservation-audit.json'];
for (const n of names) { must(fs.existsSync(file(`desktop-spikes/godot-salto/artifacts/runtime/v0426/${n}`)), `runtime evidence missing: ${n}`); must(fs.existsSync(file(`artifacts/manual-review/v0426-secondary-barn-contact-shadow-restraint-hierarchy/${n}`)), `review evidence missing: ${n}`); }
const dimensions = Object.fromEntries(names.filter(n => n.endsWith('.png')).map(n => [n, png(`desktop-spikes/godot-salto/artifacts/runtime/v0426/${n}`)]));
must(dimensions['01_PRIMARY_RTS_COLOUR.png'].width === 1920 && dimensions['01_PRIMARY_RTS_COLOUR.png'].height === 1080, 'wide dimensions invalid');
must(dimensions['06_V0425_V0426_WIDE_COMPARISON.png'].width === 3840 && dimensions['06_V0425_V0426_WIDE_COMPARISON.png'].height === 1080, 'comparison dimensions invalid');
const audit = JSON.parse(read('desktop-spikes/godot-salto/artifacts/runtime/v0426/v0426-preservation-audit.json'));
must(audit.baselineCommit === 'a98e9abe41de5d8e52097343ab49bf5542133909', `baseline mismatch: ${audit.baselineCommit}`);
for (const key of ['materialOnly','geometryChanged','topologyChanged','indicesChanged','verticesChanged','surfacesChanged','transformsChanged','aabbChanged','footprintChanged','terrainChanged','lightingChanged','shadowSettingsChanged','overlays','decals','duplicateMeshes','gameplay']) must(audit[key] === (key === 'materialOnly'), `preservation flag failed: ${key}`);
must(audit.newMeshInstances === 0 && audit.stateBehavior === 'unchanged' && audit.defaultRuntime === 'unchanged' && audit.fallbackRenderer === 'unchanged' && audit.debugRenderer === 'unchanged', 'runtime preservation failed');
if (audit.candidateRetained) {
  must(audit.status === 'RENDERED_CANDIDATE', 'candidate status invalid');
  must(Number(audit.affectedNodeCount) === 1, 'contact-shadow inventory must contain exactly one node');
  must((audit.functionalClassification?.['V0399_Barn_Contact_Shadow'] || '') === 'BARN_CONTACT_SHADOW', 'contact-shadow role missing');
  must(Array.isArray(audit.unexpectedVisibleContactShadowNames) && audit.unexpectedVisibleContactShadowNames.length === 0, 'unexpected contact-shadow inventory');
  must(JSON.stringify(audit.excludedStoneBaseInventory).includes('V0399_Barn_Stone_Base'), 'stone-base exclusion missing');
  must(JSON.stringify(audit.finalMaterials).includes('V0426_Secondary_Barn_Contact_Shadow'), 'contact-shadow candidate missing');
  must(audit.originalMaterialState && audit.finalMaterialState, 'original/final material state audit missing');
  must(String(audit.captureOnlyContextIsolation).includes('restored'), 'capture-only visibility restoration missing');
  console.log('PASS_V0426_SECONDARY_BARN_CONTACT_SHADOW_RESTRAINT_HIERARCHY_VALIDATOR (material-only transparent-state candidate; 1 contact shadow; footprint, terrain, lighting and shadow settings preserved; 7 real captures)');
} else {
  must(audit.status === 'ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_CONTACT_SHADOW', `unexpected fail-closed status: ${audit.status}`);
  must(Array.isArray(audit.expectedInventory), 'fail-closed expected inventory missing');
  console.log('PASS_V0426_SECONDARY_BARN_CONTACT_SHADOW_RESTRAINT_HIERARCHY_VALIDATOR (fail-closed limitation; no candidate retained)');
}
