import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const script = path.join(root, 'desktop-spikes/godot-salto/scripts/v0411_bridge_rail_post_value_hierarchy.gd');
const scene = path.join(root, 'desktop-spikes/godot-salto/scenes/v0411_bridge_rail_post_value_hierarchy.tscn');
const router = path.join(root, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = path.join(root, 'package.json');
const report = path.join(root, 'docs/V0411_BRIDGE_RAIL_POST_VALUE_HIERARCHY_REPORT.md');
const runtime = path.join(root, 'desktop-spikes/godot-salto/artifacts/runtime/v0411');
const pack = path.join(root, 'artifacts/manual-review/v0411-bridge-rail-post-value-hierarchy');
const files = ['01_PRIMARY_RTS_COLOUR.png','02_BRIDGE_RAIL_POST_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_BRIDGE_RAIL_POST_CLOSE_GRAYSCALE.png','05_TEMPORARY_RAIL_POST_MATERIAL_ID.png','06_ACCEPTED_BASELINE_V0411_WIDE_COMPARISON.png','07_ACCEPTED_BASELINE_V0411_CLOSE_COMPARISON.png','v0411-preservation-audit.json'];
const affected = ['Bridge_Rail_+1_High','Bridge_Rail_+1_Low','Bridge_Rail_-1_High','Bridge_Rail_-1_Low',...['+1','-1'].flatMap(side => Array.from({length:6},(_,i)=>`Bridge_Post_${side}_${String(i).padStart(2,'0')}`))];
const forbidden = ['move_and_slide','NavigationAgent','pathfinding','route_follow','attack','damage','hit_points','economy','production_queue','spawn_unit','add_building','queue_free','combat','construct_building','BoxMesh.new','new MeshInstance3D'];
const must = (condition, message) => { if (!condition) throw new Error(`FAIL_V0411: ${message}`); };
const read = file => fs.readFileSync(file,'utf8');
const png = file => { const bytes=fs.readFileSync(file); must(bytes.readUInt32BE(0)===0x89504e47,`not PNG: ${file}`); return {width:bytes.readUInt32BE(16),height:bytes.readUInt32BE(20),bytes:bytes.length}; };

function validate() {
  for (const [file,label] of [[script,'script'],[scene,'scene'],[router,'router'],[pkg,'package'],[report,'report']]) must(fs.existsSync(file),`${label} missing`);
  const g=read(script), r=read(router), p=read(pkg), d=read(report);
  for (const token of ['v0410_bridge_deck_timber_surface_readability.gd','V0411_CHECKPOINT','V0411_AFFECTED_NAMES','V0411_Bridge_Rail_High','V0411_Bridge_Rail_Low','V0411_Bridge_Post','materialOnly','geometryChanged','topologyChanged','newMeshInstances','ASSET_MATERIAL_LIMITATION_BRIDGE_RAIL_POSTS']) must(g.includes(token),`script contract missing: ${token}`);
  for (const name of affected) must(g.includes(name),`affected node contract missing: ${name}`);
  for (const token of ['--v0411-bridge-rail-post-capture','--v0411-bridge-rail-post-smoke','v0411_bridge_rail_post_value_hierarchy.gd']) must(r.includes(token),`router contract missing: ${token}`);
  for (const token of ['godot:play:v0411-bridge-rail-post','godot:smoke:v0411-bridge-rail-post','godot:capture:v0411-bridge-rail-post','godot:validate:v0411-bridge-rail-post']) must(p.includes(token),`package command missing: ${token}`);
  for (const token of ['v0.410','material-only','rail','post','deck','landing','grayscale','default runtime']) must(d.toLowerCase().includes(token.toLowerCase()),`report evidence missing: ${token}`);
  for (const file of files) { const rf=path.join(runtime,file), pf=path.join(pack,file); must(fs.existsSync(rf),`runtime evidence missing: ${file}`); must(fs.existsSync(pf),`review pack evidence missing: ${file}`); if(file.endsWith('.png')) { const image=png(rf); must(image.width===(file.startsWith('06_')||file.startsWith('07_')?3840:1920)&&image.height===1080&&image.bytes>10000,`invalid capture: ${file}`); } }
  must(!forbidden.some(token=>g.toLowerCase().includes(token.toLowerCase())),'forbidden gameplay or new-mesh token in script');
  const audit=JSON.parse(read(path.join(runtime,'v0411-preservation-audit.json')));
  must(['RENDERED_CANDIDATE','ASSET_MATERIAL_LIMITATION_BRIDGE_RAIL_POSTS'].includes(audit.status),`audit status ${audit.status}`);
  must(audit.materialOnly===true&&audit.geometryChanged===false&&audit.topologyChanged===false&&audit.indicesChanged===false&&audit.transformsChanged===false,'geometry preservation failed');
  must(audit.overlays===false&&audit.decals===false&&audit.duplicateMeshes===false&&audit.newMeshInstances===0,'duplicate/overlay contract failed');
  must(audit.gameplay===false&&audit.stateBehavior==='unchanged'&&audit.defaultRuntime==='unchanged'&&audit.fallbackRenderer==='unchanged'&&audit.debugRenderer==='unchanged','runtime preservation failed');
  if(audit.status==='RENDERED_CANDIDATE') { must(audit.candidateRetained===true&&audit.affectedNodeCount===16,'all 16 rail/post nodes must be retained'); must(audit.meshInstanceCountBefore===audit.meshInstanceCountAfter,'mesh count changed'); must(JSON.stringify(audit.bridgeHashesBefore)===JSON.stringify(audit.bridgeHashesAfter),'bridge hashes changed'); console.log('PASS_V0411_BRIDGE_RAIL_POST_VALUE_HIERARCHY_VALIDATOR (material-only candidate; 4 rails and 12 posts; 7 real captures)'); }
  else { must(audit.candidateRetained===false,'material limitation must retain no candidate'); must(String(audit.reason).length>0,'material limitation requires reason'); console.log('PASS_V0411_BRIDGE_RAIL_POST_VALUE_HIERARCHY_VALIDATOR (fail-closed ASSET_MATERIAL_LIMITATION_BRIDGE_RAIL_POSTS; no candidate retained; diagnostic evidence preserved)'); }
}
if(process.argv[2]!=='validate') throw new Error('usage: node tools/godot/saltoV0411BridgeRailPostValueHierarchyTool.mjs validate');
validate();
