import fs from 'node:fs';
import path from 'node:path';
const repo = process.cwd();
const file = p => path.join(repo, p);
const read = p => fs.readFileSync(p, 'utf8');
const must = (v, l) => { if (!v) throw new Error(`missing ${l}`); };
const png = p => { const b = fs.readFileSync(p); if (b.readUInt32BE(0) !== 0x89504e47) throw new Error(`${p} is not PNG`); return { w: b.readUInt32BE(16), h: b.readUInt32BE(20), bytes: b.length }; };
const script = file('desktop-spikes/godot-salto/scripts/v0401_character_scale_grounding_calibration.gd');
const scene = file('desktop-spikes/godot-salto/scenes/v0401_character_scale_grounding_calibration.tscn');
const router = file('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = file('package.json');
const report = file('docs/V0401_CHARACTER_SCALE_GROUNDING_CALIBRATION_REPORT.md');
const runtime = file('desktop-spikes/godot-salto/artifacts/runtime/v0401');
const pack = file('artifacts/manual-review/v0401-character-scale-grounding-calibration');
const images = ['01_PRIMARY_RTS_VIEW.png','02_CHARACTER_SCALE_GROUNDING_CLOSE.png','03_GRAYSCALE_PRIMARY.png','04_CHARACTER_GROUNDING_GRAYSCALE.png','05_V0400_V0401_PRIMARY_COMPARISON.png'];
const packFiles = [...images, 'v0401-character-scale-grounding-calibration.json', '06_ITERATION_SUMMARY.md', '07_VALIDATION.json'];
function validate() {
  for (const [p, l] of [[script,'v0.401 script'],[scene,'v0.401 scene'],[router,'opt-in router'],[pkg,'package commands'],[report,'v0.401 report']]) must(fs.existsSync(p), l);
  const g = read(script), r = read(router), p = read(pkg), d = read(report);
  for (const t of ['v0400_main_house_roof_silhouette_cleanup.gd','V0389_Resident_Worker','V0389_Crossing_Guard','V0389_Traveller_Porter','v0401_calibrated_scale','v0401_vertical_contact_correction','v0401_xz_preserved','posePreserved','verticalContactOnly','gameplay": false','defaultRuntime']) must(g.includes(t), `script contract ${t}`);
  for (const t of ['--v0401-character-grounding-capture','--v0401-character-grounding-smoke','v0401_character_scale_grounding_calibration.gd']) must(r.includes(t), `router contract ${t}`);
  for (const t of ['godot:play:v0401-character-grounding','godot:smoke:v0401-character-grounding','godot:capture:v0401-character-grounding','godot:validate:v0401-character-grounding']) must(p.includes(t), `package contract ${t}`);
  for (const forbidden of ['move_and_slide','NavigationAgent','pathfinding','route_follow','attack','damage','hit_points','economy','production_queue','spawn_unit','add_building','queue_free','combat','construct_building']) if (g.toLowerCase().includes(forbidden.toLowerCase())) throw new Error(`visual script contains forbidden gameplay token: ${forbidden}`);
  for (const t of ['v0.400','uniform scale','ground contact','X/Z','pose','default runtime']) must(d.toLowerCase().includes(t.toLowerCase()), `report evidence ${t}`);
  for (const n of images) { must(fs.existsSync(path.join(runtime, n)), `runtime ${n}`); const i = png(path.join(runtime, n)); if (i.w !== (n.startsWith('05_') ? 3840 : 1920) || i.h !== 1080 || i.bytes < 10000) throw new Error(`${n} invalid dimensions or size`); }
  must(fs.existsSync(path.join(runtime, 'v0401-character-scale-grounding-calibration.json')), 'runtime audit');
  const audit = JSON.parse(read(path.join(runtime, 'v0401-character-scale-grounding-calibration.json')));
  must(audit.figures.length === 3, 'three calibrated figures');
  must(audit.verticalContactOnly === true && audit.xzPositions === 'unchanged' && audit.pose === 'unchanged', 'calibration scope');
  must(fs.existsSync(pack), 'review pack');
  const actual = fs.readdirSync(pack).filter(n => fs.statSync(path.join(pack, n)).isFile()).sort();
  if (JSON.stringify(actual) !== JSON.stringify(packFiles.slice().sort())) throw new Error('review pack file contract failed');
  const validation = JSON.parse(read(path.join(pack, '07_VALIDATION.json')));
  if (validation.status !== 'READY FOR INDEPENDENT V0401 VISUAL REVIEW' && validation.status !== 'ACCEPTED BY INDEPENDENT V0401 VISUAL REVIEW') throw new Error('review status mismatch');
  console.log('PASS_V0401_CHARACTER_SCALE_GROUNDING_CALIBRATION_VALIDATOR (5 real captures; three existing characters; opt-in)');
}
if (process.argv[2] === 'validate') validate(); else throw new Error('usage: node tools/godot/saltoV0401CharacterScaleGroundingCalibrationTool.mjs validate');
