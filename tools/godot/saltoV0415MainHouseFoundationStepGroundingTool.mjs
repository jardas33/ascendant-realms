import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '../..');
const file = (p) => path.join(root, p);
const read = (p) => fs.readFileSync(file(p), 'utf8');
const must = (ok, message) => { if (!ok) throw new Error(`FAIL_V0415: ${message}`); };
const png = (p) => {
  const b = fs.readFileSync(file(p));
  must(b.length > 10000, `capture too small: ${p}`);
  must(b.readUInt32BE(0) === 0x89504e47, `not PNG: ${p}`);
  return { bytes: b.length, width: b.readUInt32BE(16), height: b.readUInt32BE(20) };
};

must(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0415MainHouseFoundationStepGroundingTool.mjs validate');
const script = read('desktop-spikes/godot-salto/scripts/v0415_main_house_foundation_step_grounding.gd');
const router = read('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = read('package.json');
must(fs.existsSync(file('docs/V0415_MAIN_HOUSE_FOUNDATION_STEP_GROUNDING_REPORT.md')), 'report missing');
must(fs.existsSync(file('desktop-spikes/godot-salto/scenes/v0415_main_house_foundation_step_grounding.tscn')), 'scene missing');
for (const token of ['v0414_main_house_openings_trim_value_hierarchy.gd','V0415_CHECKPOINT','V0415_LIMITATION','FOUNDATION_OR_PLINTH','ENTRY_STEP_OR_THRESHOLD','V0415_Main_House_Foundation','V0415_Main_House_Entry_Steps','materialOnly','newMeshInstances']) must(script.includes(token), `script contract missing: ${token}`);
for (const token of ['--v0415-main-house-foundation-step-capture','--v0415-main-house-foundation-step-smoke','v0415_main_house_foundation_step_grounding.gd']) must(router.includes(token), `router contract missing: ${token}`);
for (const token of ['godot:play:v0415-main-house-foundation-step','godot:smoke:v0415-main-house-foundation-step','godot:capture:v0415-main-house-foundation-step','godot:validate:v0415-main-house-foundation-step']) must(pkg.includes(token), `package command missing: ${token}`);
const names = ['01_PRIMARY_RTS_COLOUR.png','02_MAIN_HOUSE_FOUNDATION_STEPS_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_MAIN_HOUSE_FOUNDATION_STEPS_CLOSE_GRAYSCALE.png','05_TEMPORARY_FOUNDATION_STEP_NODE_ID.png','06_V0414_V0415_WIDE_COMPARISON.png','07_V0414_V0415_FOUNDATION_CLOSE_COMPARISON.png','v0415-preservation-audit.json'];
for (const n of names) { must(fs.existsSync(file(`desktop-spikes/godot-salto/artifacts/runtime/v0415/${n}`)), `runtime evidence missing: ${n}`); must(fs.existsSync(file(`artifacts/manual-review/v0415-main-house-foundation-step-grounding/${n}`)), `review evidence missing: ${n}`); }
const dimensions = Object.fromEntries(names.filter(n => n.endsWith('.png')).map(n => [n, png(`desktop-spikes/godot-salto/artifacts/runtime/v0415/${n}`)]));
must(dimensions['01_PRIMARY_RTS_COLOUR.png'].width === 1920 && dimensions['01_PRIMARY_RTS_COLOUR.png'].height === 1080, 'wide dimensions invalid');
must(dimensions['06_V0414_V0415_WIDE_COMPARISON.png'].width === 3840 && dimensions['06_V0414_V0415_WIDE_COMPARISON.png'].height === 1080, 'comparison dimensions invalid');
const audit = JSON.parse(read('desktop-spikes/godot-salto/artifacts/runtime/v0415/v0415-preservation-audit.json'));
must(audit.baselineCommit === '25990fcc63513cacb08dc7b1310b418f58d92bf2', `baseline mismatch: ${audit.baselineCommit}`);
for (const key of ['materialOnly','geometryChanged','topologyChanged','indicesChanged','verticesChanged','surfacesChanged','transformsChanged','aabbChanged','uvArraysChanged','overlays','decals','duplicateMeshes','gameplay']) must(audit[key] === (key === 'materialOnly'), `preservation flag failed: ${key}`);
must(audit.newMeshInstances === 0 && audit.stateBehavior === 'unchanged' && audit.defaultRuntime === 'unchanged' && audit.fallbackRenderer === 'unchanged' && audit.debugRenderer === 'unchanged', 'runtime preservation failed');
if (audit.candidateRetained) {
  must(audit.status === 'RENDERED_CANDIDATE', 'candidate status invalid');
  must(Number(audit.affectedNodeCount) >= 2, 'foundation/step inventory too small');
  const values = Object.values(audit.functionalClassification || {});
  for (const role of ['FOUNDATION_OR_PLINTH','ENTRY_STEP_OR_THRESHOLD']) must(values.includes(role), `missing live role: ${role}`);
  must(audit.v0414Audit?.baselineCommit === '25990fcc63513cacb08dc7b1310b418f58d92bf2', 'v0.414 preservation chain missing');
  console.log(`PASS_V0415_MAIN_HOUSE_FOUNDATION_STEP_GROUNDING_VALIDATOR (material-only candidate; ${audit.affectedNodeCount} dynamic foundation/step nodes; 7 real captures)`);
} else {
  must(audit.status === 'ASSET_MATERIAL_LIMITATION_MAIN_HOUSE_FOUNDATION_STEPS', `unexpected fail-closed status: ${audit.status}`);
  must(Number(audit.affectedNodeCount) >= 1, 'fail-closed audit missing affected foundation inventory');
  must(Array.isArray(audit.affectedNodeNames), 'fail-closed audit missing affected node names');
  const values = Object.values(audit.functionalClassification || {});
  must(values.includes('FOUNDATION_OR_PLINTH'), 'fail-closed audit missing foundation/plinth classification');
  must(!values.includes('ENTRY_STEP_OR_THRESHOLD'), 'fail-closed audit falsely classified an entry step');
  must(audit.materialOnly === true && audit.newMeshInstances === 0, 'fail-closed audit is not material-only');
  console.log('PASS_V0415_MAIN_HOUSE_FOUNDATION_STEP_GROUNDING_VALIDATOR (fail-closed limitation; no candidate retained)');
}
