import fs from 'node:fs';
import path from 'node:path';

const repo = process.cwd();
const scene = path.join(repo, 'desktop-spikes/godot-salto/scenes/v0376_original_barrosan_art_quality_pass.tscn');
const script = path.join(repo, 'desktop-spikes/godot-salto/scripts/v0376_original_barrosan_art_quality_pass.gd');
const rootScript = path.join(repo, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const generator = path.join(repo, 'tools/blender/generate_v0376_original_barrosan.py');
const glb = path.join(repo, 'desktop-spikes/godot-salto/assets/v0376/original_barrosan/barrosan_original_kit_v0376.glb');
const blend = path.join(repo, 'art-source/blender/v0376/original_barrosan/barrosan_original_kit_v0376.blend');
const packageJson = path.join(repo, 'package.json');
const raw = path.join(repo, 'artifacts/runtime/v0376');
const iterations = path.join(repo, 'artifacts/work');
const text = file => fs.readFileSync(file, 'utf8');
const must = (file, label) => { if (!fs.existsSync(file)) throw new Error(`missing ${label}: ${path.relative(repo, file)}`); };
const includes = (value, needle, label) => { if (!value.includes(needle)) throw new Error(`${label} missing: ${needle}`); };
const no = (value, needle, label) => { if (value.includes(needle)) throw new Error(`${label} contains forbidden token: ${needle}`); };
const png = file => { const b = fs.readFileSync(file); if (b.length < 100000 || b.toString('ascii', 1, 4) !== 'PNG') throw new Error(`invalid rendered PNG: ${path.basename(file)}`); return {width:b.readUInt32BE(16), height:b.readUInt32BE(20), bytes:b.length}; };

function validate() {
  for (const [file, label] of [[scene, 'isolated v0.376 scene'], [script, 'v0.376 Godot proof script'], [rootScript, 'opt-in root route'], [generator, 'v0.376 Blender generator'], [glb, 'v0.376 exported GLB'], [blend, 'v0.376 Blender source'], [packageJson, 'package']]) must(file, label);
  const s = text(scene), g = text(script), r = text(rootScript), gen = text(generator), pkg = JSON.parse(text(packageJson));
  for (const key of ['blender:generate:original-barrosan-quality-pass', 'godot:play:original-barrosan-quality-pass', 'godot:smoke:original-barrosan-quality-pass', 'godot:capture:original-barrosan-quality-pass', 'godot:validate:original-barrosan-quality-pass']) if (!pkg.scripts?.[key]) throw new Error(`missing package command: ${key}`);
  includes(s, 'V0376OriginalBarrosanArtQualityPass', 'scene');
  includes(g, 'Camera3D.PROJECTION_ORTHOGONAL', 'controlled oblique camera');
  includes(g, 'barrosan_original_kit_v0376.glb', 'isolated kit');
  includes(g, 'v0376-original-barrosan-art-quality.json', 'capture manifest');
  includes(r, '--v0376-original-barrosan-quality-pass', 'opt-in route');
  includes(r, 'v0376_original_barrosan_art_quality_pass.tscn', 'route scene');
  for (const token of ['Recessed_Curved_Stream_Water', 'Wet_Sloped_Bank_West', 'Bridge_Timber_Deck', 'Field_Barracks', 'Main_Hall', 'Gold_Mine_Extraction_Opening', 'Hostile_Camp_Worked_Ground', 'Camp_Command_Canopy', 'Embedded_Worn_Road', 'Original_Broadleaf', 'River_Reed_Cluster', 'Irregular_Terrain_Transition']) includes(gen, token, 'original Barrosan art-quality kit');
  for (const forbidden of ['NavigationAgent3D', 'CharacterBody3D', 'AnimationPlayer', 'Area3D', 'Combat', 'damage', 'HP', 'economy', 'resource mutation', 'production logic']) { no(g, forbidden, 'prototype gameplay boundary'); no(gen, forbidden, 'generator gameplay boundary'); }
  if (fs.existsSync(raw)) {
    const smokePath = path.join(raw, 'v0376-original-barrosan-art-quality-smoke.json');
    if (fs.existsSync(smokePath)) { const m = JSON.parse(text(smokePath)); if (m.status !== 'PASS' || m.hud !== false || m.gameplay !== false || m.defaultRuntime !== 'unchanged') throw new Error('v0.376 smoke is not clean'); }
  }
  const files = [];
  for (const n of fs.readdirSync(iterations)) {
    if (!/^v0376-iteration-0[1-4]$/.test(n)) continue;
    const dir = path.join(iterations, n);
    if (fs.statSync(dir).isDirectory()) for (const f of fs.readdirSync(dir)) if (f.endsWith('.png')) files.push(path.join(dir, f));
  }
  if (files.length < 16) throw new Error(`need four rendered four-view iterations; found ${files.length} PNGs`);
  for (const file of files) { const d = png(file); if (d.width !== 1920 || d.height !== 1080) throw new Error(`${path.basename(file)} is not 1920x1080`); }
  if (gen.includes('third_party') || gen.includes('quaternius')) throw new Error('Blender kit generator imports external character assets');
  console.log(`PASS_V0376_ORIGINAL_BARROSAN_ART_QUALITY (${files.length} rendered iteration PNGs; opt-in isolated; no gameplay)`);
}

const command = process.argv[2] ?? 'validate';
if (command === 'validate' || command === 'audit') validate();
else throw new Error(`unsupported command: ${command}`);
