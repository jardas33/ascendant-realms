import fs from 'node:fs';
import path from 'node:path';
const repo = process.cwd();
const file = p => path.join(repo,p);
const read = p => fs.readFileSync(p,'utf8');
const must = (v,l) => { if(!v) throw new Error(`missing ${l}`); };
const png = p => { const b=fs.readFileSync(p); if(b.readUInt32BE(0)!==0x89504e47) throw new Error(`${p} is not PNG`); return {w:b.readUInt32BE(16),h:b.readUInt32BE(20),bytes:b.length}; };
const script=file('desktop-spikes/godot-salto/scripts/v0398_route_edge_bedding_cleanup.gd');
const scene=file('desktop-spikes/godot-salto/scenes/v0398_route_edge_bedding_cleanup.tscn');
const router=file('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg=file('package.json');
const report=file('docs/V0398_ROUTE_EDGE_BEDDING_CLEANUP_REPORT.md');
const runtime=file('desktop-spikes/godot-salto/artifacts/runtime/v0398');
const pack=file('artifacts/manual-review/v0398-route-edge-bedding-cleanup');
const images=['01_PRIMARY_RTS_VIEW.png','02_CLOSE_ROUTE_YARD_DOORWAY.png','03_GRAYSCALE_PRIMARY.png','04_DIAGNOSTIC_NARROW_EDGE_ONLY.png','05_V0397_V0398_PRIMARY_COMPARISON.png'];
const packFiles=[...images,'v0398-route-edge-bedding-cleanup.json','06_ITERATION_SUMMARY.md','07_VALIDATION.json'];
function validate(){
  for(const [p,l] of [[script,'v0.398 script'],[scene,'v0.398 scene'],[router,'opt-in router'],[pkg,'package commands'],[report,'v0.398 report']]) must(fs.existsSync(p),l);
  const g=read(script),r=read(router),p=read(pkg),d=read(report);
  for(const t of ['v0397_terrain_route_integration.gd','V0398_Narrow_Route_Edge_Bedding','V0398_Narrow_Barn_Branch_Edge_Bedding','V0397_Contact_Grounding','contactHalos','removed','v0396_geometry_preserved','gameplay": false','defaultRuntime']) must(g.includes(t),`script contract ${t}`);
  for(const t of ['--v0398-route-edge-capture','--v0398-route-edge-smoke','v0398_route_edge_bedding_cleanup.gd']) must(r.includes(t),`router contract ${t}`);
  for(const t of ['godot:play:v0398-route-edge','godot:smoke:v0398-route-edge','godot:capture:v0398-route-edge','godot:validate:v0398-route-edge']) must(p.includes(t),`package contract ${t}`);
  for(const forbidden of ['move_and_slide','NavigationAgent','pathfinding','route_follow','attack','damage','hit_points','economy','production_queue','spawn_unit','add_building','queue_free','combat','construct_building']) if(g.toLowerCase().includes(forbidden.toLowerCase())) throw new Error(`visual script contains forbidden gameplay token: ${forbidden}`);
  for(const t of ['v0.397','revise once','contact','narrow','default runtime','independent visual verdict']) must(d.toLowerCase().includes(t),`report evidence ${t}`);
  for(const n of images){must(fs.existsSync(path.join(runtime,n)),`runtime ${n}`);const i=png(path.join(runtime,n));if(i.w!==(n.startsWith('05_')?3840:1920)||i.h!==1080||i.bytes<10000)throw new Error(`${n} invalid dimensions or size`);}
  must(fs.existsSync(path.join(runtime,'v0398-route-edge-bedding-cleanup.json')),'runtime manifest');
  must(fs.existsSync(pack),'review pack'); const actual=fs.readdirSync(pack).filter(n=>fs.statSync(path.join(pack,n)).isFile()).sort(); if(JSON.stringify(actual)!==JSON.stringify(packFiles.slice().sort())) throw new Error('review pack file contract failed');
  const validation=JSON.parse(read(path.join(pack,'07_VALIDATION.json'))); if(!['READY FOR INDEPENDENT V0398 VISUAL REVIEW','ACCEPTED BY INDEPENDENT V0398 VISUAL REVIEW'].includes(validation.status)) throw new Error('review status mismatch');
  console.log('PASS_V0398_ROUTE_EDGE_BEDDING_CLEANUP_VALIDATOR (5 real captures; broad halos removed; narrow edge only; opt-in)');
}
if(process.argv[2]==='validate')validate();else throw new Error('usage: node tools/godot/saltoV0398RouteEdgeBeddingCleanupTool.mjs validate');
