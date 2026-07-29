import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const repo = process.cwd();
const file = p => path.join(repo, p);
const sourceGlb = file('external-art-intake/original-barrosan/v0380-authored-highland-infrastructure/exports/barrosan_highland_infrastructure_v0380.glb');
const importedGlb = file('desktop-spikes/godot-salto/assets/v0380/corrected-highland-infrastructure/barrosan_highland_infrastructure_v0380.glb');
const sourceGenerator = file('external-art-intake/original-barrosan/v0380-authored-highland-infrastructure/source/generate_v0380_highland_infrastructure.py');
const v0383Scene = file('desktop-spikes/godot-salto/scenes/v0383_highland_style_coherence.tscn');
const v0383Script = file('desktop-spikes/godot-salto/scripts/v0383_highland_style_coherence.gd');
const scene = file('desktop-spikes/godot-salto/scenes/v0384_first_inhabited_crossing.tscn');
const script = file('desktop-spikes/godot-salto/scripts/v0384_first_inhabited_crossing.gd');
const router = file('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const project = file('package.json');
const runtime = file('desktop-spikes/godot-salto/artifacts/runtime/v0384');
const workRoot = file('artifacts/work');
const pack = file('artifacts/manual-review/v0384-first-inhabited-crossing');
const audit = file('artifacts/work/v0384-asset-selection-audit.md');
const iterationLog = file('artifacts/work/v0384-iteration-log.md');
const report = file('docs/V0384_FIRST_INHABITED_CROSSING_VISUAL_TARGET_REPORT.md');
const expectedGlb = '746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb';
const expectedSource = '4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19';
const images = ['01_PRIMARY_RTS_VIEW.png','02_SETTLEMENT_AND_CROSSING_CONTEXT.png','03_PRIMARY_BUILDING_AND_YARD_DETAIL.png','04_BRIDGE_AND_ROAD_CONNECTION.png','05_CHARACTER_SCALE_AND_PLACEMENT.png','06_DRESSING_AND_PROP_DISTRIBUTION.png','07_GRAYSCALE_PRIMARY.png'];
const packFiles = ['00_READ_ME_FIRST.md', ...images, '08_ASSET_SELECTION_SUMMARY.md', '09_ITERATION_SUMMARY.md', '10_VALIDATION.json'];
const must = (value, label) => { if (!value) throw new Error(`missing ${label}`); };
const read = p => fs.readFileSync(p, 'utf8');
const sha256 = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const includes = (value, token, label) => { if (!value.includes(token)) throw new Error(`${label} missing ${token}`); };
const png = p => {
  const b = fs.readFileSync(p);
  if (b.readUInt32BE(0) !== 0x89504e47 || b.readUInt32BE(4) !== 0x0d0a1a0a) throw new Error(`${p} is not PNG`);
  return { width: b.readUInt32BE(16), height: b.readUInt32BE(20), bytes: b.length };
};

function validate() {
  for (const [p, label] of [[sourceGlb,'accepted source GLB'],[importedGlb,'accepted imported GLB'],[sourceGenerator,'accepted generator'],[v0383Scene,'preserved v0.383 scene'],[v0383Script,'preserved v0.383 script'],[scene,'v0.384 scene'],[script,'v0.384 script'],[router,'opt-in router'],[project,'package.json'],[audit,'asset audit'],[iterationLog,'iteration log'],[report,'v0.384 report']]) must(fs.existsSync(p), label);
  if (sha256(sourceGlb) !== expectedGlb || sha256(importedGlb) !== expectedGlb) throw new Error('accepted v0.380 GLB hash changed');
  if (sha256(sourceGenerator) !== expectedSource) throw new Error('accepted v0.380 generator hash changed');
  const g = read(script);
  const r = read(router);
  const p = JSON.parse(read(project));
  for (const token of ['V0384_First_Inhabited_Crossing','V0384_Primary_Barrosan_Roadside_Homestead','V0384_Subordinate_Timber_Shed','V0384_Functional_Yard_One_Cluster','V0384_Curated_Yard_Props_Seven','V0384_Exactly_Three_Temporary_Humans','Worn_Tapered_Footpath_No_Rectangle','V0384_Soft_Yard_Fill_No_Shadow','ArrayMesh']) includes(g, token, 'v0.384 scene-local implementation');
  includes(read(v0383Script), 'PROJECTION_ORTHOGONAL', 'preserved oblique camera');
  for (const token of ['--v0384-inhabited-crossing','--v0384-inhabited-crossing-smoke','--v0384-inhabited-crossing-capture','v0384_first_inhabited_crossing.tscn']) includes(r, token, 'v0.384 opt-in router');
  for (const key of ['godot:play:v0384-inhabited-crossing','godot:smoke:v0384-inhabited-crossing','godot:capture:v0384-inhabited-crossing','godot:validate:v0384-inhabited-crossing']) must(p.scripts?.[key], `package command ${key}`);
  for (const forbidden of ['move_and_slide','NavigationAgent','route_follow','attack','damage','hit_points','economy','production_queue','spawn_unit','add_building','queue_free']) if (g.toLowerCase().includes(forbidden.toLowerCase())) throw new Error(`v0.384 visual script contains forbidden gameplay token: ${forbidden}`);
  for (const image of images) {
    const d = png(path.join(runtime, image));
    if (d.width !== 1920 || d.height !== 1080 || d.bytes < 10000) throw new Error(`${image} is not a real 1920x1080 capture`);
  }
  const manifest = JSON.parse(read(file('desktop-spikes/godot-salto/artifacts/runtime/v0384/v0384-first-inhabited-crossing.json')));
  for (const [key, expected] of Object.entries({acceptedBaseUnchanged:true,v0383DressingPreserved:true,primaryBuildings:1,subordinateBuildings:1,functionalYardProps:9,temporaryHumans:3,sceneLocalOnly:true,gameplay:false,movement:false,defaultRuntime:'unchanged',route:'opt-in-only',glbSha256:expectedGlb,sourceSha256:expectedSource})) if (manifest[key] !== expected) throw new Error(`v0.384 manifest boundary failed: ${key}`);
  for (const iteration of [1,2,3]) {
    const dir = file(`artifacts/work/v0384-iteration-0${iteration}`);
    must(fs.existsSync(dir), `v0.384 iteration ${iteration} directory`);
    const d = png(path.join(dir, '01_PRIMARY_RTS_VIEW.png'));
    if (d.width !== 1920 || d.height !== 1080 || d.bytes < 10000) throw new Error(`iteration ${iteration} primary is not a real capture`);
  }
  must(fs.existsSync(pack), 'v0.384 review pack');
  const actualPack = fs.readdirSync(pack).filter(name => fs.statSync(path.join(pack,name)).isFile()).sort();
  if (JSON.stringify(actualPack) !== JSON.stringify([...packFiles].sort())) throw new Error('v0.384 review pack file contract failed');
  const validation = JSON.parse(read(path.join(pack,'10_VALIDATION.json')));
  if (validation.status !== 'READY FOR HUMAN V0384 FIRST INHABITED CROSSING REVIEW') throw new Error('v0.384 pack is not human-review ready');
  if (validation.visualScore < 75 || validation.temporaryHumans !== 3 || validation.primaryBuildings !== 1 || validation.subordinateBuildings !== 1) throw new Error('v0.384 visual gate counts/score failed');
  includes(read(path.join(pack,'00_READ_ME_FIRST.md')), 'READY FOR HUMAN V0384 FIRST INHABITED CROSSING REVIEW', 'review status');
  includes(read(audit), 'Corner_ExteriorWide_Wood.gltf', 'primary candidate audit');
  includes(read(audit), 'Adventurer.gltf', 'human candidate audit');
  includes(read(iterationLog), 'Iteration 3', 'iteration log');
  console.log(`PASS_V0384_FIRST_INHABITED_CROSSING_VALIDATOR (7 real captures; exactly 1 primary; 1 subordinate; 9 props; 3 humans; 3 inspected iterations; accepted GLB unchanged; opt-in visual only)`);
}

if (process.argv[2] === 'validate') validate();
else throw new Error('usage: node tools/godot/saltoV0384FirstInhabitedCrossingTool.mjs validate');
