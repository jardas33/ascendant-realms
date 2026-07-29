import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '../..');
const file = (p) => path.join(root, p);
const read = (p) => fs.readFileSync(file(p), 'utf8');
const must = (ok, message) => { if (!ok) throw new Error(`FAIL_V0427: ${message}`); };
const png = (p) => {
  const b = fs.readFileSync(file(p));
  must(b.length > 10000, `capture too small: ${p}`);
  must(b.readUInt32BE(0) === 0x89504e47, `not PNG: ${p}`);
  return { bytes: b.length, width: b.readUInt32BE(16), height: b.readUInt32BE(20) };
};

must(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0427ResidentWorkerPrimaryGarmentValueHierarchyTool.mjs validate');
const script = read('desktop-spikes/godot-salto/scripts/v0427_resident_worker_primary_garment_value_hierarchy.gd');
const router = read('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = read('package.json');
const report = 'docs/V0427_RESIDENT_WORKER_PRIMARY_GARMENT_VALUE_HIERARCHY_REPORT.md';
const scene = 'desktop-spikes/godot-salto/scenes/v0427_resident_worker_primary_garment_value_hierarchy.tscn';
must(fs.existsSync(file(report)), 'report missing');
must(fs.existsSync(file(scene)), 'scene missing');
for (const token of ['v0426_secondary_barn_contact_shadow_restraint_hierarchy.gd','V0427_CHECKPOINT','V0427_LIMITATION','V0389_Resident_Worker','Farmer.gltf','LightBlue','RESIDENT_WORKER_PRIMARY_GARMENT','V0427_Resident_Worker_Primary_Garment','sourceAssetChanged','skeletonChanged','otherCharactersChanged','materialOnly']) must(script.includes(token), `script contract missing: ${token}`);
must(!script.includes('MeshInstance3D.new'), 'new MeshInstance3D path forbidden');
for (const token of ['--v0427-resident-worker-primary-garment-capture','--v0427-resident-worker-primary-garment-smoke','v0427_resident_worker_primary_garment_value_hierarchy.gd']) must(router.includes(token), `router contract missing: ${token}`);
for (const token of ['godot:play:v0427-resident-worker-garment','godot:smoke:v0427-resident-worker-garment','godot:capture:v0427-resident-worker-garment','godot:validate:v0427-resident-worker-garment']) must(pkg.includes(token), `package command missing: ${token}`);
const names = ['01_PRIMARY_RTS_COLOUR.png','02_RESIDENT_WORKER_GARMENT_CLOSE_COLOUR.png','03_THREE_CHARACTER_CONTEXT_COLOUR.png','04_RESIDENT_WORKER_GARMENT_CLOSE_GRAYSCALE.png','05_TEMPORARY_RESIDENT_WORKER_GARMENT_NODE_ID.png','06_V0426_V0427_WIDE_COMPARISON.png','07_V0426_V0427_WORKER_CLOSE_COMPARISON.png','v0427-preservation-audit.json'];
for (const n of names) { must(fs.existsSync(file(`desktop-spikes/godot-salto/artifacts/runtime/v0427/${n}`)), `runtime evidence missing: ${n}`); must(fs.existsSync(file(`artifacts/manual-review/v0427-resident-worker-primary-garment-value-hierarchy/${n}`)), `review evidence missing: ${n}`); }
const dimensions = Object.fromEntries(names.filter(n => n.endsWith('.png')).map(n => [n, png(`desktop-spikes/godot-salto/artifacts/runtime/v0427/${n}`)]));
for (const [name, d] of Object.entries(dimensions)) must(d.width === (name.startsWith('06_') || name.startsWith('07_') ? 3840 : 1920) && d.height === 1080, `dimensions invalid: ${name}`);
const audit = JSON.parse(read('desktop-spikes/godot-salto/artifacts/runtime/v0427/v0427-preservation-audit.json'));
must(audit.baselineCommit === 'a3c89a9677437ca39c613d946fb0bc0610b46b49', `baseline mismatch: ${audit.baselineCommit}`);
for (const key of ['materialOnly','sourceAssetChanged','geometryChanged','topologyChanged','verticesChanged','indicesChanged','normalsChanged','tangentsChanged','surfacesChanged','uvArraysChanged','skeletonChanged','skinBindingChanged','poseChanged','animationChanged','transformChanged','groundingChanged','otherCharactersChanged','lightingChanged','overlays','decals','emission','duplicateMeshes','gameplay']) must(audit[key] === (key === 'materialOnly'), `preservation flag failed: ${key}`);
must(audit.newMeshInstances === 0 && audit.stateBehavior === 'unchanged' && audit.defaultRuntime === 'unchanged' && audit.fallbackRenderer === 'unchanged' && audit.debugRenderer === 'unchanged', 'runtime preservation failed');
if (audit.candidateRetained) {
  must(audit.status === 'RENDERED_CANDIDATE', 'candidate status invalid');
  must(audit.workerRoot === 'V0389_Resident_Worker' && audit.sourceAsset.endsWith('/Farmer.gltf'), 'worker identity/source missing');
  must(audit.functionalClassification === 'RESIDENT_WORKER_PRIMARY_GARMENT', 'garment classification missing');
  must(Number(audit.admittedSurfaceCount) >= 1, 'no admitted LightBlue surfaces');
  must(JSON.stringify(audit.admittedSurfaces).includes('LightBlue'), 'admitted LightBlue inventory missing');
  for (const material of ['Skin','Brown','Beige','Brown2','Eyebrows','Red','Eye']) must(JSON.stringify(audit.excludedAuthoredMaterials).includes(material), `excluded material missing: ${material}`);
  must(audit.guardExcluded === true && audit.travellerExcluded === true, 'other character exclusion missing');
  must(JSON.stringify(audit.finalMaterial).includes('V0427_Resident_Worker_Primary_Garment'), 'candidate material missing');
  must(audit.candidateParameters?.metallic === 0 && audit.candidateParameters?.alphaPreserved === true, 'candidate parameters invalid');
  must(String(audit.captureOnlyRestoration).includes('restored'), 'surface override restoration missing');
  console.log('PASS_V0427_RESIDENT_WORKER_PRIMARY_GARMENT_VALUE_HIERARCHY_VALIDATOR (instance-local LightBlue surface candidate; source, pose, grounding, geometry and other characters preserved; 7 real captures)');
} else {
  must(audit.status === 'ASSET_MATERIAL_LIMITATION_RESIDENT_WORKER_PRIMARY_GARMENT', `unexpected fail-closed status: ${audit.status}`);
  console.log('PASS_V0427_RESIDENT_WORKER_PRIMARY_GARMENT_VALUE_HIERARCHY_VALIDATOR (fail-closed limitation; no candidate retained)');
}
