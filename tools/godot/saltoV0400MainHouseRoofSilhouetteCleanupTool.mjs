import fs from 'node:fs';
import path from 'node:path';
const repo = process.cwd();
const file = p => path.join(repo, p);
const read = p => fs.readFileSync(p, 'utf8');
const must = (v, l) => { if (!v) throw new Error(`missing ${l}`); };
const png = p => { const b = fs.readFileSync(p); if (b.readUInt32BE(0) !== 0x89504e47) throw new Error(`${p} is not PNG`); return { w: b.readUInt32BE(16), h: b.readUInt32BE(20), bytes: b.length }; };
const script = file('desktop-spikes/godot-salto/scripts/v0400_main_house_roof_silhouette_cleanup.gd');
const scene = file('desktop-spikes/godot-salto/scenes/v0400_main_house_roof_silhouette_cleanup.tscn');
const router = file('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = file('package.json');
const report = file('docs/V0400_MAIN_HOUSE_ROOF_SILHOUETTE_CLEANUP_REPORT.md');
const runtime = file('desktop-spikes/godot-salto/artifacts/runtime/v0400');
const pack = file('artifacts/manual-review/v0400-main-house-roof-silhouette-cleanup');
const images = ['01_PRIMARY_RTS_VIEW.png','02_MAIN_HOUSE_ROOF_CLOSE.png','03_GRAYSCALE_PRIMARY.png','04_MAIN_HOUSE_ROOF_GRAYSCALE.png','05_V0399_V0400_PRIMARY_COMPARISON.png'];
const packFiles = [...images, 'v0400-main-house-roof-silhouette-cleanup.json', '06_ITERATION_SUMMARY.md', '07_VALIDATION.json'];
function validate() {
  for (const [p, l] of [[script,'v0.400 script'],[scene,'v0.400 scene'],[router,'opt-in router'],[pkg,'package commands'],[report,'v0.400 report']]) must(fs.existsSync(p), l);
  const g = read(script), r = read(router), p = read(pkg), d = read(report);
  for (const t of ['v0399_barn_outbuilding_structural_readability.gd','V0394_One_Primary_Barrosan_Homestead','V0400_Main_House_Roof_Silhouette','V0400_Main_House_Roof_Left_Plane','V0400_Main_House_Roof_Right_Plane','V0400_Main_House_Ridge_Beam','single_ridge','chimneyPreserved','v0399-preserved','gameplay": false','defaultRuntime']) must(g.includes(t), `script contract ${t}`);
  for (const t of ['--v0400-house-roof-capture','--v0400-house-roof-smoke','v0400_main_house_roof_silhouette_cleanup.gd']) must(r.includes(t), `router contract ${t}`);
  for (const t of ['godot:play:v0400-house-roof','godot:smoke:v0400-house-roof','godot:capture:v0400-house-roof','godot:validate:v0400-house-roof']) must(p.includes(t), `package contract ${t}`);
  for (const forbidden of ['move_and_slide','NavigationAgent','pathfinding','route_follow','attack','damage','hit_points','economy','production_queue','spawn_unit','add_building','queue_free','combat','construct_building']) if (g.toLowerCase().includes(forbidden.toLowerCase())) throw new Error(`visual script contains forbidden gameplay token: ${forbidden}`);
  for (const t of ['v0.399','single ridge','eaves','chimney','grayscale','default runtime']) must(d.toLowerCase().includes(t), `report evidence ${t}`);
  for (const n of images) { must(fs.existsSync(path.join(runtime, n)), `runtime ${n}`); const i = png(path.join(runtime, n)); if (i.w !== (n.startsWith('05_') ? 3840 : 1920) || i.h !== 1080 || i.bytes < 10000) throw new Error(`${n} invalid dimensions or size`); }
  must(fs.existsSync(path.join(runtime, 'v0400-main-house-roof-silhouette-cleanup.json')), 'runtime manifest');
  must(fs.existsSync(pack), 'review pack');
  const actual = fs.readdirSync(pack).filter(n => fs.statSync(path.join(pack, n)).isFile()).sort();
  if (JSON.stringify(actual) !== JSON.stringify(packFiles.slice().sort())) throw new Error('review pack file contract failed');
  const validation = JSON.parse(read(path.join(pack, '07_VALIDATION.json')));
  if (validation.status !== 'READY FOR INDEPENDENT V0400 VISUAL REVIEW' && validation.status !== 'ACCEPTED BY INDEPENDENT V0400 VISUAL REVIEW') throw new Error('review status mismatch');
  console.log('PASS_V0400_MAIN_HOUSE_ROOF_SILHOUETTE_CLEANUP_VALIDATOR (5 real captures; primary house only; opt-in)');
}
if (process.argv[2] === 'validate') validate(); else throw new Error('usage: node tools/godot/saltoV0400MainHouseRoofSilhouetteCleanupTool.mjs validate');
