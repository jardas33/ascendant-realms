import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
const repo = process.cwd();
const file = p => path.join(repo, p);
const read = p => fs.readFileSync(p, 'utf8');
const must = (v, label) => { if (!v) throw new Error(`missing ${label}`); };
const sha256 = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const png = p => { const b = fs.readFileSync(p); if (b.readUInt32BE(0) !== 0x89504e47) throw new Error(`${p} is not PNG`); return {w:b.readUInt32BE(16),h:b.readUInt32BE(20),bytes:b.length,hash:sha256(p)}; };
const script = file('desktop-spikes/godot-salto/scripts/v0397_terrain_route_integration.gd');
const scene = file('desktop-spikes/godot-salto/scenes/v0397_terrain_route_integration.tscn');
const router = file('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = file('package.json');
const report = file('docs/V0397_TERRAIN_ROUTE_INTEGRATION_REPORT.md');
const runtime = file('desktop-spikes/godot-salto/artifacts/runtime/v0397');
const pack = file('artifacts/manual-review/v0397-terrain-route-integration');
const images = ['01_PRIMARY_RTS_VIEW.png','02_CLOSE_ROUTE_YARD_DOORWAY.png','03_GRAYSCALE_PRIMARY.png','04_DIAGNOSTIC_ROUTE_BEDDING_AND_GROUNDING.png','05_V0396_V0397_PRIMARY_COMPARISON.png'];
const packFiles = [...images,'v0397-terrain-route-integration.json','06_ITERATION_SUMMARY.md','07_VALIDATION.json'];
function validate() {
  for (const [p,l] of [[script,'v0.397 script'],[scene,'v0.397 scene'],[router,'opt-in router'],[pkg,'package commands'],[report,'v0.397 report']]) must(fs.existsSync(p),l);
  const g=read(script), r=read(router), p=read(pkg), d=read(report);
  for (const t of ['v0396_inherited_route_mesh_deduplication_material_unification.gd','V0397_Route_Grass_Bedding','V0397_Contact_Grounding','v0397_route_edge_bedding','v0397_contact_grounding','routeGeometry','v0396-preserved','gameplay": false','defaultRuntime','unchanged']) must(g.includes(t),`script contract ${t}`);
  for (const t of ['--v0397-terrain-route-capture','--v0397-terrain-route-smoke','v0397_terrain_route_integration.gd']) must(r.includes(t),`router contract ${t}`);
  for (const t of ['godot:play:v0397-terrain-route','godot:smoke:v0397-terrain-route','godot:capture:v0397-terrain-route','godot:validate:v0397-terrain-route']) must(p.includes(t),`package contract ${t}`);
  for (const forbidden of ['move_and_slide','NavigationAgent','pathfinding','route_follow','attack','damage','hit_points','economy','production_queue','spawn_unit','add_building','queue_free','combat','construct_building']) if (g.toLowerCase().includes(forbidden.toLowerCase())) throw new Error(`visual script contains forbidden gameplay token: ${forbidden}`);
  for (const t of ['v0.396','route','contact','default runtime','independent visual review']) must(d.toLowerCase().includes(t),`report evidence ${t}`);
  for (const n of images) { must(fs.existsSync(path.join(runtime,n)),`runtime ${n}`); const i=png(path.join(runtime,n)); if(i.w !== (n.startsWith('05_')?3840:1920)||i.h!==1080||i.bytes<10000) throw new Error(`${n} invalid dimensions or size`); }
  must(fs.existsSync(path.join(runtime,'v0397-terrain-route-integration.json')),'runtime manifest');
  must(fs.existsSync(pack),'review pack');
  const actual=fs.readdirSync(pack).filter(n=>fs.statSync(path.join(pack,n)).isFile()).sort(); if(JSON.stringify(actual)!==JSON.stringify(packFiles.slice().sort())) throw new Error('review pack file contract failed');
  const validation=JSON.parse(read(path.join(pack,'07_VALIDATION.json'))); if(!['READY FOR INDEPENDENT V0397 VISUAL REVIEW','ACCEPTED BY INDEPENDENT V0397 VISUAL REVIEW'].includes(validation.status)) throw new Error('review status mismatch');
  console.log('PASS_V0397_TERRAIN_ROUTE_INTEGRATION_VALIDATOR (5 real captures; visual-only edge bedding and grounding; opt-in)');
}
if(process.argv[2]==='validate') validate(); else throw new Error('usage: node tools/godot/saltoV0397TerrainRouteIntegrationTool.mjs validate');
