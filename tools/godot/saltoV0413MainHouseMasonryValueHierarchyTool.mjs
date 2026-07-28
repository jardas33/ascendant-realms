import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '../..');
const file = (p) => path.join(root, p);
const read = (p) => fs.readFileSync(file(p), 'utf8');
const must = (condition, message) => { if (!condition) throw new Error(`FAIL_V0413: ${message}`); };
const png = (p) => {
  const b = fs.readFileSync(file(p));
  must(b.length > 10000, `capture too small or title-card-only: ${p}`);
  must(b.readUInt32BE(0) === 0x89504e47, `not a PNG: ${p}`);
  return { bytes: b.length, width: b.readUInt32BE(16), height: b.readUInt32BE(20) };
};

must(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0413MainHouseMasonryValueHierarchyTool.mjs validate');
const script = read('desktop-spikes/godot-salto/scripts/v0413_main_house_masonry_value_hierarchy.gd');
const router = read('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const packageText = read('package.json');
const report = file('docs/V0413_MAIN_HOUSE_MASONRY_VALUE_HIERARCHY_REPORT.md');
const runtime = file('desktop-spikes/godot-salto/artifacts/runtime/v0413');
const pack = file('artifacts/manual-review/v0413-main-house-masonry-value-hierarchy');
must(fs.existsSync(report), 'report missing');
must(fs.existsSync(file('desktop-spikes/godot-salto/scenes/v0413_main_house_masonry_value_hierarchy.tscn')), 'scene missing');
for (const token of ['v0412_bridge_understructure_value_hierarchy.gd','V0413_CHECKPOINT','V0413_LIMITATION','MAIN_HOUSE_MASONRY_WALL','V0413_Main_House_Restrained_Masonry','materialOnly','surfacesChanged','newMeshInstances','excludedNearbyHouseInventory']) must(script.includes(token), `script contract missing: ${token}`);
for (const token of ['--v0413-main-house-masonry-capture','--v0413-main-house-masonry-smoke','v0413_main_house_masonry_value_hierarchy.gd']) must(router.includes(token), `router contract missing: ${token}`);
for (const token of ['godot:play:v0413-main-house-masonry','godot:smoke:v0413-main-house-masonry','godot:capture:v0413-main-house-masonry','godot:validate:v0413-main-house-masonry']) must(packageText.includes(token), `package command missing: ${token}`);

const names = ['01_PRIMARY_RTS_COLOUR.png','02_MAIN_HOUSE_MASONRY_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_MAIN_HOUSE_MASONRY_CLOSE_GRAYSCALE.png','05_TEMPORARY_MASONRY_NODE_MATERIAL_ID.png','06_V0412_V0413_WIDE_COMPARISON.png','07_V0412_V0413_HOUSE_CLOSE_COMPARISON.png','v0413-preservation-audit.json'];
for (const name of names) must(fs.existsSync(path.join(runtime, name)), `runtime evidence missing: ${name}`);
for (const name of names) must(fs.existsSync(path.join(pack, name)), `review-pack evidence missing: ${name}`);
const dimensions = {};
for (const name of names.filter((n) => n.endsWith('.png'))) dimensions[name] = png(`desktop-spikes/godot-salto/artifacts/runtime/v0413/${name}`);
for (const name of names.filter((n) => n.endsWith('.png'))) must(png(`artifacts/manual-review/v0413-main-house-masonry-value-hierarchy/${name}`).bytes > 10000, `review-pack capture too small: ${name}`);
must(dimensions['01_PRIMARY_RTS_COLOUR.png'].width === 1920 && dimensions['01_PRIMARY_RTS_COLOUR.png'].height === 1080, 'wide capture dimensions invalid');
must(dimensions['06_V0412_V0413_WIDE_COMPARISON.png'].width === 3840 && dimensions['06_V0412_V0413_WIDE_COMPARISON.png'].height === 1080, 'wide comparison dimensions invalid');
const audit = JSON.parse(fs.readFileSync(path.join(runtime, 'v0413-preservation-audit.json'), 'utf8'));
must(audit.baselineCommit === '5a064c8df089336f71324b0c477d5b48578f560b', `baseline mismatch: ${audit.baselineCommit}`);
must(audit.materialOnly === true && audit.geometryChanged === false && audit.topologyChanged === false && audit.indicesChanged === false && audit.verticesChanged === false && audit.surfacesChanged === false && audit.transformsChanged === false && audit.aabbChanged === false && audit.uvArraysChanged === false, 'material-only preservation contract failed');
must(audit.newMeshInstances === 0 && audit.overlays === false && audit.decals === false && audit.duplicateMeshes === false, 'new or duplicate geometry contract failed');
must(audit.gameplay === false && audit.stateBehavior === 'unchanged' && audit.defaultRuntime === 'unchanged' && audit.fallbackRenderer === 'unchanged' && audit.debugRenderer === 'unchanged', 'runtime preservation contract failed');
if (audit.candidateRetained) {
  must(audit.status === 'RENDERED_CANDIDATE', `candidate status invalid: ${audit.status}`);
  must(Number(audit.affectedNodeCount) > 0, 'candidate has no dynamically inventoried wall nodes');
  must(Array.isArray(audit.affectedNodeNames) && audit.affectedNodeNames.every((name) => /granite|masonry|wall/i.test(name)), 'affected inventory is not masonry-specific');
  must(Array.isArray(audit.excludedNearbyHouseInventory) && audit.excludedNearbyHouseInventory.length > 0, 'excluded house inventory missing');
  must(String(audit.finalMaterialParameters).includes('roughness=0.96'), 'masonry value calibration missing');
  console.log(`PASS_V0413_MAIN_HOUSE_MASONRY_VALUE_HIERARCHY_VALIDATOR (material-only candidate; ${audit.affectedNodeCount} dynamic wall nodes; 7 real captures)`);
} else {
  must(audit.status === 'ASSET_MATERIAL_LIMITATION_MAIN_HOUSE_MASONRY', `unexpected fail-closed status: ${audit.status}`);
  console.log('PASS_V0413_MAIN_HOUSE_MASONRY_VALUE_HIERARCHY_VALIDATOR (fail-closed ASSET_MATERIAL_LIMITATION_MAIN_HOUSE_MASONRY; no candidate retained)');
}
