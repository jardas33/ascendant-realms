import fs from 'node:fs';
import path from 'node:path';
const root = path.resolve(import.meta.dirname, '../..');
const file = (p) => path.join(root, p);
const read = (p) => fs.readFileSync(file(p), 'utf8');
const must = (ok, message) => { if (!ok) throw new Error(`FAIL_V0414: ${message}`); };
const png = (p) => { const b = fs.readFileSync(file(p)); must(b.length > 10000, `capture too small: ${p}`); must(b.readUInt32BE(0) === 0x89504e47, `not PNG: ${p}`); return {bytes:b.length,width:b.readUInt32BE(16),height:b.readUInt32BE(20)}; };
must(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0414MainHouseOpeningsTrimValueHierarchyTool.mjs validate');
const script = read('desktop-spikes/godot-salto/scripts/v0414_main_house_openings_trim_value_hierarchy.gd');
const router = read('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = read('package.json');
must(fs.existsSync(file('docs/V0414_MAIN_HOUSE_OPENINGS_TRIM_VALUE_HIERARCHY_REPORT.md')), 'report missing');
must(fs.existsSync(file('desktop-spikes/godot-salto/scenes/v0414_main_house_openings_trim_value_hierarchy.tscn')), 'scene missing');
for (const token of ['v0413_main_house_masonry_value_hierarchy.gd','V0414_CHECKPOINT','V0414_LIMITATION','DOOR','WINDOW','TIMBER_TRIM','V0414_Main_House_Door','V0414_Main_House_Window_Frame','V0414_Main_House_Timber_Trim','materialOnly','surfacesChanged','newMeshInstances']) must(script.includes(token), `script contract missing: ${token}`);
for (const token of ['--v0414-main-house-openings-trim-capture','--v0414-main-house-openings-trim-smoke','v0414_main_house_openings_trim_value_hierarchy.gd']) must(router.includes(token), `router contract missing: ${token}`);
for (const token of ['godot:play:v0414-main-house-openings-trim','godot:smoke:v0414-main-house-openings-trim','godot:capture:v0414-main-house-openings-trim','godot:validate:v0414-main-house-openings-trim']) must(pkg.includes(token), `package command missing: ${token}`);
const names = ['01_PRIMARY_RTS_COLOUR.png','02_MAIN_HOUSE_OPENINGS_TRIM_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_MAIN_HOUSE_OPENINGS_TRIM_CLOSE_GRAYSCALE.png','05_TEMPORARY_OPENING_TRIM_NODE_ID.png','06_V0413_V0414_WIDE_COMPARISON.png','07_V0413_V0414_HOUSE_CLOSE_COMPARISON.png','v0414-preservation-audit.json'];
for (const n of names) { must(fs.existsSync(file(`desktop-spikes/godot-salto/artifacts/runtime/v0414/${n}`)), `runtime evidence missing: ${n}`); must(fs.existsSync(file(`artifacts/manual-review/v0414-main-house-openings-trim-value-hierarchy/${n}`)), `review evidence missing: ${n}`); }
const dimensions = Object.fromEntries(names.filter(n=>n.endsWith('.png')).map(n=>[n,png(`desktop-spikes/godot-salto/artifacts/runtime/v0414/${n}`)]));
must(dimensions['01_PRIMARY_RTS_COLOUR.png'].width === 1920 && dimensions['01_PRIMARY_RTS_COLOUR.png'].height === 1080, 'wide dimensions invalid');
must(dimensions['06_V0413_V0414_WIDE_COMPARISON.png'].width === 3840 && dimensions['06_V0413_V0414_WIDE_COMPARISON.png'].height === 1080, 'comparison dimensions invalid');
const audit = JSON.parse(fs.readFileSync(file('desktop-spikes/godot-salto/artifacts/runtime/v0414/v0414-preservation-audit.json'), 'utf8'));
must(audit.baselineCommit === '77b2b2289f76754cbc0644727f6c2e05ba216b69', `baseline mismatch: ${audit.baselineCommit}`);
for (const key of ['materialOnly','geometryChanged','topologyChanged','indicesChanged','verticesChanged','surfacesChanged','transformsChanged','aabbChanged','uvArraysChanged','overlays','decals','duplicateMeshes','gameplay']) must(audit[key] === (['materialOnly'].includes(key)), `preservation flag failed: ${key}`);
must(audit.newMeshInstances === 0 && audit.stateBehavior === 'unchanged' && audit.defaultRuntime === 'unchanged' && audit.fallbackRenderer === 'unchanged' && audit.debugRenderer === 'unchanged', 'runtime preservation failed');
if (audit.candidateRetained) { must(audit.status === 'RENDERED_CANDIDATE', 'candidate status invalid'); must(Number(audit.affectedNodeCount) >= 3, 'opening/trim inventory too small'); const values = Object.values(audit.functionalClassification || {}); for (const role of ['DOOR','WINDOW','TIMBER_TRIM']) must(values.includes(role), `missing live role: ${role}`); console.log(`PASS_V0414_MAIN_HOUSE_OPENINGS_TRIM_VALUE_HIERARCHY_VALIDATOR (material-only candidate; ${audit.affectedNodeCount} dynamic opening/trim nodes; 7 real captures)`); }
else { must(audit.status === 'ASSET_MATERIAL_LIMITATION_MAIN_HOUSE_OPENINGS_TRIM', `unexpected fail-closed status: ${audit.status}`); console.log('PASS_V0414_MAIN_HOUSE_OPENINGS_TRIM_VALUE_HIERARCHY_VALIDATOR (fail-closed limitation; no candidate retained)'); }
