import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const repo = process.cwd();
const file = p => path.join(repo, p);
const read = p => fs.readFileSync(p, 'utf8');
const must = (v, label) => { if (!v) throw new Error(`missing ${label}`); };
const sha256 = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const png = p => {
  const b = fs.readFileSync(p);
  if (b.readUInt32BE(0) !== 0x89504e47) throw new Error(`${p} is not PNG`);
  return { w: b.readUInt32BE(16), h: b.readUInt32BE(20), bytes: b.length, hash: sha256(p) };
};

const sourceGlb = file('external-art-intake/original-barrosan/v0380-authored-highland-infrastructure/exports/barrosan_highland_infrastructure_v0380.glb');
const importedGlb = file('desktop-spikes/godot-salto/assets/v0380/corrected-highland-infrastructure/barrosan_highland_infrastructure_v0380.glb');
const priorScript = file('desktop-spikes/godot-salto/scripts/v0395_natural_worn_earth_route_material_edge_integration.gd');
const script = file('desktop-spikes/godot-salto/scripts/v0396_inherited_route_mesh_deduplication_material_unification.gd');
const scene = file('desktop-spikes/godot-salto/scenes/v0396_inherited_route_mesh_deduplication_material_unification.tscn');
const router = file('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = file('package.json');
const report = file('docs/V0396_INHERITED_ROUTE_MESH_DEDUPLICATION_MATERIAL_UNIFICATION_REPORT.md');
const runtime = file('desktop-spikes/godot-salto/artifacts/runtime/v0396');
const pack = file('artifacts/manual-review/v0396-inherited-route-mesh-deduplication-material-unification');
const images = ['01_PRIMARY_RTS_VIEW.png','02_CLOSE_ROUTE_YARD_DOORWAY.png','03_GRAYSCALE_PRIMARY.png','04_DIAGNOSTIC_INHERITED_ROUTE_MESH_ISOLATED.png','05_V0395_V0396_PRIMARY_COMPARISON.png'];
const packFiles = [...images, '06_ITERATION_SUMMARY.md', '07_VALIDATION.json'];
const expectedGlb = '746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb';

function validate() {
  for (const [p, label] of [[sourceGlb,'accepted source GLB'],[importedGlb,'accepted imported GLB'],[priorScript,'v0.395 baseline script'],[script,'v0.396 script'],[scene,'v0.396 scene'],[router,'opt-in router'],[pkg,'package commands'],[report,'v0.396 report']]) must(fs.existsSync(p), label);
  if (sha256(sourceGlb) !== expectedGlb || sha256(importedGlb) !== expectedGlb) throw new Error('accepted v0.380 GLB hash changed');
  const g = read(script); const r = read(router); const p = read(pkg); const d = read(report); const visual = `${g}\n${r}`;
  for (const token of ['v0395_natural_worn_earth_route_material_edge_integration.gd','V0396InheritedRouteMeshDeduplicationMaterialUnification','V0395_One_Compacted_Warm_Earth_Bridge_Yard_Door_Route','V0394_Bridge_Desaturated_Value','v0396_inherited_override_repaired','v0396_material_unified','v0396-inherited-route-mesh-inventory.json','gameplay": false','defaultRuntime": "unchanged']) must(visual.includes(token), `script contract ${token}`);
  for (const token of ['--v0396-route-mesh-capture','--v0396-route-mesh-smoke','v0396_inherited_route_mesh_deduplication_material_unification.gd']) must(r.includes(token), `router contract ${token}`);
  for (const token of ['godot:play:v0396-route-mesh','godot:smoke:v0396-route-mesh','godot:capture:v0396-route-mesh','godot:validate:v0396-route-mesh']) must(p.includes(token), `package contract ${token}`);
  for (const forbidden of ['move_and_slide','NavigationAgent','pathfinding','route_follow','attack','damage','hit_points','economy','production_queue','spawn_unit','add_building','queue_free','combat','construct_building']) if (g.toLowerCase().includes(forbidden.toLowerCase())) throw new Error(`visual script contains forbidden gameplay token: ${forbidden}`);
  for (const token of ['v0.395','inherited material override','route topology','default runtime','independent visual review']) must(d.toLowerCase().includes(token.toLowerCase()), `report evidence ${token}`);
  for (const name of images) { must(fs.existsSync(path.join(runtime,name)), `runtime ${name}`); const i = png(path.join(runtime,name)); if (i.w !== (name.startsWith('05_') ? 3840 : 1920) || i.h !== 1080 || i.bytes < 10000) throw new Error(`${name} invalid dimensions or size`); }
  const inventory = JSON.parse(read(path.join(runtime,'v0396-inherited-route-mesh-inventory.json')));
  must(inventory.identifiedLegacyOverride.includes('V0394_Bridge_Desaturated_Value'), 'identified legacy override');
  must(fs.existsSync(pack), 'review pack');
  const actual = fs.readdirSync(pack).filter(n => fs.statSync(path.join(pack,n)).isFile()).sort();
  if (JSON.stringify(actual) !== JSON.stringify(packFiles.slice().sort())) throw new Error('review pack file contract failed');
  const validation = JSON.parse(read(path.join(pack,'07_VALIDATION.json')));
  if (!['READY FOR INDEPENDENT V0396 VISUAL REVIEW','ACCEPTED BY INDEPENDENT V0396 VISUAL REVIEW'].includes(validation.status)) throw new Error('review status mismatch');
  console.log('PASS_V0396_INHERITED_ROUTE_MESH_DEDUPLICATION_MATERIAL_UNIFICATION_VALIDATOR (5 real captures; legacy override identified; opt-in visual only)');
}
if (process.argv[2] === 'validate') validate(); else throw new Error('usage: node tools/godot/saltoV0396InheritedRouteMeshDeduplicationMaterialUnificationTool.mjs validate');
