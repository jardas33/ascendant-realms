import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '../..');
const file = (p) => path.join(root, p);
const read = (p) => fs.readFileSync(file(p), 'utf8');
const must = (ok, message) => { if (!ok) throw new Error(`FAIL_V0421: ${message}`); };
const png = (p) => {
  const b = fs.readFileSync(file(p));
  must(b.length > 10000, `capture too small: ${p}`);
  must(b.readUInt32BE(0) === 0x89504e47, `not PNG: ${p}`);
  return { bytes: b.length, width: b.readUInt32BE(16), height: b.readUInt32BE(20) };
};
must(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0421SecondaryBarnEntranceFrameValueHierarchyTool.mjs validate');
const script = read('desktop-spikes/godot-salto/scripts/v0421_secondary_barn_entrance_frame_value_hierarchy.gd');
const router = read('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = read('package.json');
const report = 'docs/V0421_SECONDARY_BARN_ENTRANCE_FRAME_VALUE_HIERARCHY_REPORT.md';
const scene = 'desktop-spikes/godot-salto/scenes/v0421_secondary_barn_entrance_frame_value_hierarchy.tscn';
must(fs.existsSync(file(report)), 'report missing');
must(fs.existsSync(file(scene)), 'scene missing');
for (const token of ['v0420_secondary_barn_stone_base_value_hierarchy.gd','V0421_CHECKPOINT','V0421_LIMITATION','BARN_ENTRANCE_FRAME_POST','BARN_ENTRANCE_FRAME_LINTEL','V0421_Secondary_Barn_Entrance_Frame','V0399_Barn_Entrance_Door','materialOnly','newMeshInstances']) must(script.includes(token), `script contract missing: ${token}`);
for (const token of ['--v0421-secondary-barn-entrance-frame-capture','--v0421-secondary-barn-entrance-frame-smoke','v0421_secondary_barn_entrance_frame_value_hierarchy.gd']) must(router.includes(token), `router contract missing: ${token}`);
for (const token of ['godot:play:v0421-secondary-barn-entrance-frame','godot:smoke:v0421-secondary-barn-entrance-frame','godot:capture:v0421-secondary-barn-entrance-frame','godot:validate:v0421-secondary-barn-entrance-frame']) must(pkg.includes(token), `package command missing: ${token}`);
const names = ['01_PRIMARY_RTS_COLOUR.png','02_SECONDARY_BARN_ENTRANCE_FRAME_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_SECONDARY_BARN_ENTRANCE_FRAME_CLOSE_GRAYSCALE.png','05_TEMPORARY_BARN_ENTRANCE_FRAME_NODE_ID.png','06_V0420_V0421_WIDE_COMPARISON.png','07_V0420_V0421_ENTRANCE_FRAME_CLOSE_COMPARISON.png','v0421-preservation-audit.json'];
for (const n of names) { must(fs.existsSync(file(`desktop-spikes/godot-salto/artifacts/runtime/v0421/${n}`)), `runtime evidence missing: ${n}`); must(fs.existsSync(file(`artifacts/manual-review/v0421-secondary-barn-entrance-frame-value-hierarchy/${n}`)), `review evidence missing: ${n}`); }
const dimensions = Object.fromEntries(names.filter(n => n.endsWith('.png')).map(n => [n, png(`desktop-spikes/godot-salto/artifacts/runtime/v0421/${n}`)]));
must(dimensions['01_PRIMARY_RTS_COLOUR.png'].width === 1920 && dimensions['01_PRIMARY_RTS_COLOUR.png'].height === 1080, 'wide dimensions invalid');
must(dimensions['06_V0420_V0421_WIDE_COMPARISON.png'].width === 3840 && dimensions['06_V0420_V0421_WIDE_COMPARISON.png'].height === 1080, 'comparison dimensions invalid');
const audit = JSON.parse(read('desktop-spikes/godot-salto/artifacts/runtime/v0421/v0421-preservation-audit.json'));
must(audit.baselineCommit === 'de4e5c25d9e42d5d4cf2c7358741a961ffd3f468', `baseline mismatch: ${audit.baselineCommit}`);
for (const key of ['materialOnly','geometryChanged','topologyChanged','indicesChanged','verticesChanged','surfacesChanged','transformsChanged','aabbChanged','uvArraysChanged','overlays','decals','duplicateMeshes','gameplay']) must(audit[key] === (key === 'materialOnly'), `preservation flag failed: ${key}`);
must(audit.newMeshInstances === 0 && audit.stateBehavior === 'unchanged' && audit.defaultRuntime === 'unchanged' && audit.fallbackRenderer === 'unchanged' && audit.debugRenderer === 'unchanged', 'runtime preservation failed');
must(audit.v0420Audit?.checkpoint === 'v0.420', 'v0.420 preservation chain missing');
if (audit.candidateRetained) {
  must(audit.status === 'RENDERED_CANDIDATE', 'candidate status invalid');
  must(Number(audit.affectedNodeCount) === 3, 'entrance frame inventory must contain exactly three nodes');
  must((audit.functionalClassification?.V0399_Barn_Door_Left_Post || '') === 'BARN_ENTRANCE_FRAME_POST', 'left post role missing');
  must((audit.functionalClassification?.V0399_Barn_Door_Right_Post || '') === 'BARN_ENTRANCE_FRAME_POST', 'right post role missing');
  must((audit.functionalClassification?.V0399_Barn_Door_Lintel || '') === 'BARN_ENTRANCE_FRAME_LINTEL', 'lintel role missing');
  must(audit.excludedDoor === 'V0399_Barn_Entrance_Door', 'door exclusion missing');
  must(Array.isArray(audit.unexpectedVisibleEntranceFrameNames) && audit.unexpectedVisibleEntranceFrameNames.length === 0, 'unexpected entrance-frame inventory');
  must(JSON.stringify(audit.finalMaterials).includes('V0421_Secondary_Barn_Entrance_Frame'), 'frame candidate missing');
  console.log('PASS_V0421_SECONDARY_BARN_ENTRANCE_FRAME_VALUE_HIERARCHY_VALIDATOR (material-only candidate; 2 posts + 1 lintel; door excluded; 7 real captures)');
} else {
  must(audit.status === 'ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_ENTRANCE_FRAME', `unexpected fail-closed status: ${audit.status}`);
  must(Array.isArray(audit.expectedInventory), 'fail-closed expected inventory missing');
  console.log('PASS_V0421_SECONDARY_BARN_ENTRANCE_FRAME_VALUE_HIERARCHY_VALIDATOR (fail-closed limitation; no candidate retained)');
}
