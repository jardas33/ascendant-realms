import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const script = path.join(root, 'desktop-spikes/godot-salto/scripts/v0412_bridge_understructure_value_hierarchy.gd');
const scene = path.join(root, 'desktop-spikes/godot-salto/scenes/v0412_bridge_understructure_value_hierarchy.tscn');
const router = path.join(root, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = path.join(root, 'package.json');
const report = path.join(root, 'docs/V0412_BRIDGE_UNDERSTRUCTURE_VALUE_HIERARCHY_REPORT.md');
const runtime = path.join(root, 'desktop-spikes/godot-salto/artifacts/runtime/v0412');
const pack = path.join(root, 'artifacts/manual-review/v0412-bridge-understructure-value-hierarchy');
const files = ['01_PRIMARY_RTS_COLOUR.png','02_BRIDGE_UNDERSTRUCTURE_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_BRIDGE_UNDERSTRUCTURE_CLOSE_GRAYSCALE.png','05_TEMPORARY_UNDERBEAM_EDGECOURSE_ID.png','06_V0411_V0412_WIDE_COMPARISON.png','07_V0411_V0412_CLOSE_COMPARISON.png','v0412-preservation-audit.json'];
const forbidden = ['move_and_slide','NavigationAgent','pathfinding','route_follow','attack','damage','hit_points','economy','production_queue','spawn_unit','add_building','queue_free','combat','construct_building','BoxMesh.new','new MeshInstance3D'];
const must = (condition, message) => { if (!condition) throw new Error(`FAIL_V0412: ${message}`); };
const read = file => fs.readFileSync(file, 'utf8');
const png = file => { const bytes = fs.readFileSync(file); must(bytes.readUInt32BE(0) === 0x89504e47, `not PNG: ${file}`); return { width: bytes.readUInt32BE(16), height: bytes.readUInt32BE(20), bytes: bytes.length }; };

function validate() {
  for (const [file, label] of [[script,'script'],[scene,'scene'],[router,'router'],[pkg,'package'],[report,'report']]) must(fs.existsSync(file), `${label} missing`);
  const g = read(script), r = read(router), p = read(pkg), d = read(report);
  for (const token of ['v0411_bridge_rail_post_value_hierarchy.gd','V0412_CHECKPOINT','V0412_LIMITATION','V0412_Bridge_Underbeam','V0412_Bridge_EdgeCourse','UNDERBEAM','EDGE_COURSE','materialOnly','geometryChanged','newMeshInstances','ASSET_MATERIAL_LIMITATION_BRIDGE_UNDERSTRUCTURE']) must(g.includes(token), `script contract missing: ${token}`);
  for (const token of ['--v0412-bridge-understructure-capture','--v0412-bridge-understructure-smoke','v0412_bridge_understructure_value_hierarchy.gd']) must(r.includes(token), `router contract missing: ${token}`);
  for (const token of ['godot:play:v0412-bridge-understructure','godot:smoke:v0412-bridge-understructure','godot:capture:v0412-bridge-understructure','godot:validate:v0412-bridge-understructure']) must(p.includes(token), `package command missing: ${token}`);
  for (const token of ['v0.411','material-only','underbeam','edge course','deck','rail','post','landing','grayscale','default runtime']) must(d.toLowerCase().includes(token.toLowerCase()), `report evidence missing: ${token}`);
  for (const file of files) { const rf = path.join(runtime, file), pf = path.join(pack, file); must(fs.existsSync(rf), `runtime evidence missing: ${file}`); must(fs.existsSync(pf), `review pack evidence missing: ${file}`); if (file.endsWith('.png')) { const image = png(rf); const expectedWidth = file.startsWith('06_') || file.startsWith('07_') ? 3840 : 1920; must(image.width === expectedWidth && image.height === 1080 && image.bytes > 10000, `invalid capture: ${file}`); } }
  must(!forbidden.some(token => g.toLowerCase().includes(token.toLowerCase())), 'forbidden gameplay or new-mesh token in script');
  const audit = JSON.parse(read(path.join(runtime, 'v0412-preservation-audit.json')));
  must(['RENDERED_CANDIDATE','ASSET_MATERIAL_LIMITATION_BRIDGE_UNDERSTRUCTURE'].includes(audit.status), `audit status ${audit.status}`);
  must(audit.baselineCommit === '7f73ded8743f415392f2eea2d08cfa4578432728', 'wrong v0.411 baseline');
  must(audit.materialOnly === true && audit.geometryChanged === false && audit.topologyChanged === false && audit.indicesChanged === false && audit.verticesChanged === false && audit.transformsChanged === false && audit.aabbChanged === false, 'geometry preservation failed');
  must(audit.overlays === false && audit.decals === false && audit.duplicateMeshes === false && audit.newMeshInstances === 0, 'duplicate/overlay contract failed');
  must(audit.gameplay === false && audit.stateBehavior === 'unchanged' && audit.defaultRuntime === 'unchanged' && audit.fallbackRenderer === 'unchanged' && audit.debugRenderer === 'unchanged', 'runtime preservation failed');
  if (audit.status === 'RENDERED_CANDIDATE') {
    must(audit.candidateRetained === true && audit.affectedNodeCount >= 2, 'complete underbeam/edge-course inventory must be retained');
    const classes = Object.values(audit.functionalClassification || {}); must(classes.includes('UNDERBEAM') && classes.includes('EDGE_COURSE'), 'both live component classes must be present');
    must(audit.meshInstanceCountBefore === audit.meshInstanceCountAfter, 'mesh count changed');
    must(JSON.stringify(audit.bridgeHashesBefore) === JSON.stringify(audit.bridgeHashesAfter), 'bridge hashes changed');
    console.log(`PASS_V0412_BRIDGE_UNDERSTRUCTURE_VALUE_HIERARCHY_VALIDATOR (material-only candidate; ${audit.affectedNodeCount} dynamically inventoried components; 7 real captures)`);
  } else {
    must(audit.candidateRetained === false, 'material limitation must retain no candidate'); must(String(audit.reason).length > 0, 'material limitation requires reason');
    console.log('PASS_V0412_BRIDGE_UNDERSTRUCTURE_VALUE_HIERARCHY_VALIDATOR (fail-closed ASSET_MATERIAL_LIMITATION_BRIDGE_UNDERSTRUCTURE; no candidate retained; diagnostic contract preserved)');
  }
}
if (process.argv[2] !== 'validate') throw new Error('usage: node tools/godot/saltoV0412BridgeUnderstructureValueHierarchyTool.mjs validate');
validate();
