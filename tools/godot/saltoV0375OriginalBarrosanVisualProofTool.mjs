import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const repo = process.cwd();
const scene = path.join(repo, 'desktop-spikes/godot-salto/scenes/v0375_original_barrosan_visual_proof.tscn');
const script = path.join(repo, 'desktop-spikes/godot-salto/scripts/v0375_original_barrosan_visual_proof.gd');
const rootScript = path.join(repo, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const generator = path.join(repo, 'tools/blender/generate_v0375_original_barrosan.py');
const glb = path.join(repo, 'desktop-spikes/godot-salto/assets/v0375/original_barrosan/barrosan_original_kit.glb');
const blend = path.join(repo, 'art-source/blender/v0375/original_barrosan/barrosan_original_kit.blend');
const packageJson = path.join(repo, 'package.json');
const raw = path.join(repo, 'artifacts/runtime/v0375');
const iterations = path.join(repo, 'artifacts/work');
const text = file => fs.readFileSync(file, 'utf8');
const must = (file, label) => { if (!fs.existsSync(file)) throw new Error(`missing ${label}: ${path.relative(repo,file)}`); };
const includes = (value, needle, label) => { if (!value.includes(needle)) throw new Error(`${label} missing: ${needle}`); };
const no = (value, needle, label) => { if (value.includes(needle)) throw new Error(`${label} contains forbidden token: ${needle}`); };
const png = file => { const b=fs.readFileSync(file); if(b.length<100000 || b.toString('ascii',1,4)!=='PNG') throw new Error(`invalid rendered PNG: ${path.basename(file)}`); return {width:b.readUInt32BE(16),height:b.readUInt32BE(20),bytes:b.length}; };

function validate() {
  for (const [file,label] of [[scene,'isolated scene'],[script,'Godot proof script'],[rootScript,'root route'],[generator,'Blender generator'],[glb,'exported GLB'],[blend,'Blender source'],[packageJson,'package']]) must(file,label);
  const s=text(scene), g=text(script), r=text(rootScript), gen=text(generator), pkg=JSON.parse(text(packageJson));
  for(const key of ['blender:generate:original-barrosan-proof','godot:play:original-barrosan-proof','godot:smoke:original-barrosan-proof','godot:capture:original-barrosan-proof','godot:validate:original-barrosan-proof']) if(!pkg.scripts?.[key]) throw new Error(`missing package command: ${key}`);
  includes(s,'V0375OriginalBarrosanVisualProof','scene'); includes(g,'Camera3D.PROJECTION_ORTHOGONAL','camera'); includes(g,'barrosan_original_kit.glb','kit'); includes(g,'v0375-original-barrosan-visual-proof.json','capture'); includes(r,'--v0375-original-barrosan-proof','route'); includes(r,'v0375_original_barrosan_visual_proof.tscn','route scene');
  for(const token of ['Recessed_Curved_Stream_Water','Bridge_Timber_Deck','Field_Barracks','Main_Hall','Worked_Ore_Yard','Hostile_Camp','Embedded_Worn_Road','Original_Pine']) includes(gen,token,'original kit generator');
  for(const forbidden of ['NavigationAgent3D','CharacterBody3D','AnimationPlayer','Area3D','Combat','damage','HP','economy','resource mutation']) { no(g,forbidden,'prototype gameplay boundary'); no(gen,forbidden,'generator gameplay boundary'); }
  if(fs.existsSync(raw)) { const smoke=path.join(raw,'v0375-original-barrosan-visual-proof-smoke.json'); if(fs.existsSync(smoke)){const m=JSON.parse(text(smoke)); if(m.status!=='PASS'||m.hud!==false||m.gameplay!==false||m.defaultRuntime!=='unchanged') throw new Error('v0.375 smoke is not clean');} }
  const files=[]; for(const n of fs.readdirSync(iterations)){ if(!n.startsWith('v0375-iteration-')) continue; const dir=path.join(iterations,n); if(fs.statSync(dir).isDirectory()) for(const f of fs.readdirSync(dir)) if(f.endsWith('.png')) files.push(path.join(dir,f)); }
  if(files.length<12) throw new Error(`need at least three rendered four-view iterations; found ${files.length} PNGs`);
  for(const file of files) { const d=png(file); if(d.width!==1920||d.height!==1080) throw new Error(`${path.basename(file)} is not 1920x1080`); }
  console.log(`PASS_V0375_ORIGINAL_BARROSAN_VISUAL_PROOF (${files.length} rendered iteration PNGs)`);
}
function audit() { validate(); }
const command=process.argv[2]??'validate'; if(command==='validate'||command==='audit') audit(); else throw new Error(`unsupported command: ${command}`);
