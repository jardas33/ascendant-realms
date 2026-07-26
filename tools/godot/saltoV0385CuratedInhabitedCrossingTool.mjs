import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const repo = process.cwd();
const file = p => path.join(repo, p);
const read = p => fs.readFileSync(p, 'utf8');
const must = (v, label) => { if (!v) throw new Error(`missing ${label}`); };
const sha256 = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const png = p => { const b = fs.readFileSync(p); if (b.readUInt32BE(0) !== 0x89504e47) throw new Error(`${p} is not PNG`); return {w:b.readUInt32BE(16),h:b.readUInt32BE(20),bytes:b.length,hash:crypto.createHash('sha256').update(b).digest('hex')}; };
const sourceGlb = file('external-art-intake/original-barrosan/v0380-authored-highland-infrastructure/exports/barrosan_highland_infrastructure_v0380.glb');
const importedGlb = file('desktop-spikes/godot-salto/assets/v0380/corrected-highland-infrastructure/barrosan_highland_infrastructure_v0380.glb');
const script = file('desktop-spikes/godot-salto/scripts/v0385_curated_inhabited_crossing.gd');
const scene = file('desktop-spikes/godot-salto/scenes/v0385_curated_inhabited_crossing.tscn');
const router = file('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const audit = file('artifacts/work/v0385-asset-selection-audit.md');
const iterationLog = file('artifacts/work/v0385-iteration-log.md');
const report = file('docs/V0385_CURATED_INHABITED_CROSSING_ASSET_REPLACEMENT_AND_HIERARCHY_REPAIR_REPORT.md');
const rejectedV0384 = file('docs/V0384_FIRST_INHABITED_CROSSING_VISUAL_TARGET_REPORT.md');
const runtime = file('desktop-spikes/godot-salto/artifacts/runtime/v0385');
const pack = file('artifacts/manual-review/v0385-curated-inhabited-crossing-repair');
const images = ['01_PRIMARY_RTS_VIEW.png','02_SETTLEMENT_AND_CROSSING_CONTEXT.png','03_YARD_AND_CHARACTER_ROLE_DETAIL.png','04_BUILDING_SILHOUETTE_AND_ENTRANCE_DETAIL.png','05_CHARACTER_SCALE_AND_SEPARATION_AUDIT.png','06_ROAD_YARD_ENTRANCE_CONNECTION.png','07_GRAYSCALE_PRIMARY.png'];
const packFiles = [...images,'08_ASSET_SELECTION_SUMMARY.md','09_ITERATION_SUMMARY.md','10_VALIDATION.json'];
const expectedGlb = '746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb';
const V0385_PRIMARY_ASSET = 'res://assets/v0338/barrosan_house_02_material_gold_candidate.glb';
const V0385_SUBORDINATE_ASSET = 'res://scenes/gold/barrosan/BarrosanBarnGold.tscn';

function validate() {
  for (const [p,l] of [[sourceGlb,'accepted source GLB'],[importedGlb,'accepted imported GLB'],[script,'v0.385 script'],[scene,'v0.385 scene'],[router,'opt-in router'],[audit,'asset audit'],[iterationLog,'iteration log'],[report,'v0.385 report'],[rejectedV0384,'preserved v0.384 rejected evidence']]) must(fs.existsSync(p),l);
  if (sha256(sourceGlb) !== expectedGlb || sha256(importedGlb) !== expectedGlb) throw new Error('accepted v0.380 GLB hash changed');
  const g = read(script); const r = read(router); const reportText = read(report);
  for (const token of ['V0385_Curated_Inhabited_Crossing','V0385_One_Primary_Barrosan_Homestead','V0385_One_Subordinate_Agricultural_Barn','V0385_Five_Functional_Yard_Groups','V0385_Yard_Group_01_Cart','V0385_Yard_Group_02_Stacked_Firewood','V0385_Yard_Group_03_Barrel_Crate_Storage','V0385_Yard_Group_04_Trough_Workbench','V0385_Yard_Group_05_Fence_Gate','V0385_Exactly_Three_Distinct_Character_Roles','V0385_Road_To_Yard_To_Entrance_Threshold',V0385_PRIMARY_ASSET,V0385_SUBORDINATE_ASSET]) must(g.includes(token),`script contract ${token}`);
  for (const token of ['--v0385-inhabited-crossing','--v0385-inhabited-crossing-smoke','--v0385-inhabited-crossing-capture','v0385_curated_inhabited_crossing.tscn']) must(r.includes(token),`router contract ${token}`);
  for (const forbidden of ['move_and_slide','NavigationAgent','pathfinding','route_follow','attack','damage','hit_points','economy','production_queue','spawn_unit','add_building','queue_free']) if (g.toLowerCase().includes(forbidden.toLowerCase())) throw new Error(`visual script contains forbidden gameplay token: ${forbidden}`);
  if (!reportText.includes('v0.384 remains rejected evidence')) throw new Error('report does not preserve v0.384 rejection');
  for (const i of [1,2,3,4]) { const d=file(`desktop-spikes/godot-salto/artifacts/work/v0385-iteration-0${i}`); must(fs.existsSync(d),`iteration ${i}`); const p=png(path.join(d,'01_PRIMARY_RTS_VIEW.png')); if(p.w!==1920||p.h!==1080||p.bytes<10000) throw new Error(`iteration ${i} primary invalid`); }
  for (const i of images) { const p=png(path.join(runtime,i)); if(p.w!==1920||p.h!==1080||p.bytes<10000) throw new Error(`${i} invalid`); }
  must(fs.existsSync(pack),'v0.385 review pack');
  const actual=fs.readdirSync(pack).filter(n=>fs.statSync(path.join(pack,n)).isFile()).sort(); if(JSON.stringify(actual)!==JSON.stringify(packFiles.slice().sort())) throw new Error('review pack file contract failed');
  const validation=JSON.parse(read(path.join(pack,'10_VALIDATION.json'))); if(validation.status!=='READY FOR HUMAN V0385 CURATED INHABITED CROSSING REVIEW') throw new Error('review pack status mismatch');
  const hashes=new Set(images.map(i=>png(path.join(pack,i)).hash)); if(hashes.size!==images.length) throw new Error('duplicate final captures');
  console.log(`PASS_V0385_CURATED_INHABITED_CROSSING_VALIDATOR (7 real captures; 1 primary; 1 subordinate; 5 yard groups; 3 character roles; accepted infrastructure unchanged; opt-in visual only)`);
}
if (process.argv[2] === 'validate') validate(); else throw new Error('usage: node tools/godot/saltoV0385CuratedInhabitedCrossingTool.mjs validate');
