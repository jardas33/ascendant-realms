import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '../..');
const file = (p) => path.join(root, p);
const read = (p) => fs.readFileSync(file(p), 'utf8');
const must = (ok, message) => { if (!ok) throw new Error(`FAIL_V0416: ${message}`); };
const png = (p) => { const b = fs.readFileSync(file(p)); must(b.length > 10000, `capture too small: ${p}`); must(b.readUInt32BE(0) === 0x89504e47, `not PNG: ${p}`); return {bytes:b.length,width:b.readUInt32BE(16),height:b.readUInt32BE(20)}; };
must(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0416MainHouseChimneyMaterialHierarchyTool.mjs validate');
const script = read('desktop-spikes/godot-salto/scripts/v0416_main_house_chimney_material_hierarchy.gd');
const router = read('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = read('package.json');
must(fs.existsSync(file('docs/V0416_MAIN_HOUSE_CHIMNEY_MATERIAL_HIERARCHY_REPORT.md')), 'report missing');
must(fs.existsSync(file('desktop-spikes/godot-salto/scenes/v0416_main_house_chimney_material_hierarchy.tscn')), 'scene missing');
for (const token of ['v0415_main_house_foundation_step_grounding.gd','V0416_CHECKPOINT','V0416_LIMITATION','CHIMNEY_BODY','CHIMNEY_CAP_OR_CROWN','V0416_Main_House_Chimney_Body','V0416_Main_House_Chimney_Cap','materialOnly','newMeshInstances']) must(script.includes(token), `script contract missing: ${token}`);
for (const token of ['--v0416-main-house-chimney-capture','--v0416-main-house-chimney-smoke','v0416_main_house_chimney_material_hierarchy.gd']) must(router.includes(token), `router contract missing: ${token}`);
for (const token of ['godot:play:v0416-main-house-chimney','godot:smoke:v0416-main-house-chimney','godot:capture:v0416-main-house-chimney','godot:validate:v0416-main-house-chimney']) must(pkg.includes(token), `package command missing: ${token}`);
const names = ['01_PRIMARY_RTS_COLOUR.png','02_MAIN_HOUSE_CHIMNEY_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_MAIN_HOUSE_CHIMNEY_CLOSE_GRAYSCALE.png','05_TEMPORARY_CHIMNEY_NODE_ID.png','06_V0415_V0416_WIDE_COMPARISON.png','07_V0415_V0416_CHIMNEY_CLOSE_COMPARISON.png','v0416-preservation-audit.json'];
for (const n of names) { must(fs.existsSync(file(`desktop-spikes/godot-salto/artifacts/runtime/v0416/${n}`)), `runtime evidence missing: ${n}`); must(fs.existsSync(file(`artifacts/manual-review/v0416-main-house-chimney-material-hierarchy/${n}`)), `review evidence missing: ${n}`); }
const dimensions = Object.fromEntries(names.filter(n=>n.endsWith('.png')).map(n=>[n,png(`desktop-spikes/godot-salto/artifacts/runtime/v0416/${n}`)]));
must(dimensions['01_PRIMARY_RTS_COLOUR.png'].width===1920 && dimensions['01_PRIMARY_RTS_COLOUR.png'].height===1080, 'wide dimensions invalid');
must(dimensions['06_V0415_V0416_WIDE_COMPARISON.png'].width===3840 && dimensions['06_V0415_V0416_WIDE_COMPARISON.png'].height===1080, 'comparison dimensions invalid');
const audit = JSON.parse(read('desktop-spikes/godot-salto/artifacts/runtime/v0416/v0416-preservation-audit.json'));
must(audit.baselineCommit === '73bbc22d0137a11b4a2cd0f377dbe9157e6f2c7c', `baseline mismatch: ${audit.baselineCommit}`);
for (const key of ['materialOnly','geometryChanged','topologyChanged','indicesChanged','verticesChanged','surfacesChanged','transformsChanged','aabbChanged','uvArraysChanged','overlays','decals','duplicateMeshes','gameplay']) must(audit[key] === (key === 'materialOnly'), `preservation flag failed: ${key}`);
must(audit.newMeshInstances===0 && audit.stateBehavior==='unchanged' && audit.defaultRuntime==='unchanged' && audit.fallbackRenderer==='unchanged' && audit.debugRenderer==='unchanged', 'runtime preservation failed');
must(audit.v0415Audit?.baselineCommit === '25990fcc63513cacb08dc7b1310b418f58d92bf2' && audit.v0415Audit?.checkpoint === 'v0.415', 'v0.415 preservation chain missing');
if (audit.candidateRetained) {
  must(audit.status==='RENDERED_CANDIDATE','candidate status invalid');
  const values = Object.values(audit.functionalClassification || {});
  must(values.includes('CHIMNEY_BODY'),'chimney body role missing');
  must(Number(audit.affectedNodeCount)>=1,'chimney inventory too small');
  console.log(`PASS_V0416_MAIN_HOUSE_CHIMNEY_MATERIAL_HIERARCHY_VALIDATOR (material-only candidate; ${audit.affectedNodeCount} dynamic chimney nodes; 7 real captures)`);
} else {
  must(audit.status==='ASSET_MATERIAL_LIMITATION_MAIN_HOUSE_CHIMNEY', `unexpected fail-closed status: ${audit.status}`);
  must(Array.isArray(audit.affectedNodeNames) && Array.isArray(audit.candidateDebugNames), 'fail-closed inventory missing');
  must(audit.materialOnly===true && audit.newMeshInstances===0, 'fail-closed audit is not material-only');
  console.log('PASS_V0416_MAIN_HOUSE_CHIMNEY_MATERIAL_HIERARCHY_VALIDATOR (fail-closed limitation; no candidate retained)');
}
