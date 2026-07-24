import fs from 'node:fs';
import path from 'node:path';

const repo = process.cwd();
const must = (file, label) => { if (!fs.existsSync(file)) throw new Error(`missing ${label}: ${path.relative(repo, file)}`); };
const text = file => fs.readFileSync(file, 'utf8');
const includes = (value, needle, label) => { if (!value.includes(needle)) throw new Error(`${label} missing: ${needle}`); };
const forbidden = (value, needle, label) => { if (value.includes(needle)) throw new Error(`${label} contains forbidden token: ${needle}`); };
const png = file => {
  const bytes = fs.readFileSync(file);
  if (bytes.length < 100000 || bytes.toString('ascii', 1, 4) !== 'PNG') throw new Error(`invalid PNG: ${path.basename(file)}`);
  return { width: bytes.readUInt32BE(16), height: bytes.readUInt32BE(20), bytes: bytes.length };
};

const scene = path.join(repo, 'desktop-spikes/godot-salto/scenes/v0377_reference_driven_terrain_infrastructure.tscn');
const script = path.join(repo, 'desktop-spikes/godot-salto/scripts/v0377_reference_driven_terrain_infrastructure.gd');
const rootScript = path.join(repo, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const generator = path.join(repo, 'tools/blender/generate_v0377_terrain_infrastructure.py');
const blend = path.join(repo, 'art-source/blender/v0377/terrain-infrastructure/barrosan_terrain_infrastructure_v0377.blend');
const glb = path.join(repo, 'desktop-spikes/godot-salto/assets/v0377/terrain-infrastructure/barrosan_terrain_infrastructure_v0377.glb');
const packageJson = path.join(repo, 'package.json');
const reference = path.join(repo, 'docs/art-direction/v0377-visual-reference-pack/03_TERRAIN_ROAD_RIVER_BRIDGE.png');
const work = path.join(repo, 'artifacts/work');
const raw = path.join(repo, 'artifacts/runtime/v0377');

function validate() {
  for (const [file, label] of [[scene, 'v0.377 scene'], [script, 'v0.377 Godot script'], [rootScript, 'opt-in root route'], [generator, 'v0.377 Blender generator'], [blend, 'v0.377 Blender source'], [glb, 'v0.377 GLB'], [reference, 'binding terrain reference'], [packageJson, 'package']]) must(file, label);
  const s = text(scene), g = text(script), r = text(rootScript), gen = text(generator), pkg = JSON.parse(text(packageJson));
  for (const key of ['blender:generate:v0377-terrain-infrastructure', 'godot:play:v0377-terrain-infrastructure', 'godot:smoke:v0377-terrain-infrastructure', 'godot:capture:v0377-terrain-infrastructure', 'godot:validate:v0377-terrain-infrastructure']) if (!pkg.scripts?.[key]) throw new Error(`missing package command: ${key}`);
  includes(s, 'V0377ReferenceDrivenTerrainInfrastructure', 'scene');
  includes(g, 'Camera3D.PROJECTION_ORTHOGONAL', 'orthographic camera');
  includes(g, '06_REFERENCE_COMPARISON.png', 'comparison capture');
  includes(g, '05_GRAYSCALE_PRIMARY.png', 'grayscale capture');
  includes(r, '--v0377-terrain-infrastructure', 'opt-in root arg');
  includes(r, 'v0377_reference_driven_terrain_infrastructure.tscn', 'opt-in root scene');
  for (const token of ['Continuous_Highland_Land_West', 'Recessed_Riverbed_Continuous', 'Irregular_Wet_Bank_Slope_', 'Embedded_Road_West_Approach', 'Bridge_Granite_Abutment_Block', 'Bridge_Timber_Deck_Plank', 'Highland_Stone_Formation', 'River_Reed_Cluster', 'use_smooth', 'terrain_z(x, y) + 0.18']) includes(gen, token, 'Stage 1 authored kit');
  for (const token of ['Main_Hall', 'Field_Barracks', 'Gold_Mine', 'Hostile_Camp', 'Worker.gltf', 'Farmer.gltf', 'Adventurer.gltf', 'Quaternius', 'NavigationAgent3D', 'CharacterBody3D', 'Combat', 'damage', 'economy']) { forbidden(gen, token, 'Stage 1 generator boundary'); forbidden(g, token, 'Stage 1 runtime boundary'); }
  if (fs.existsSync(raw)) {
    const smoke = path.join(raw, 'v0377-terrain-infrastructure-smoke.json');
    if (fs.existsSync(smoke)) { const manifest = JSON.parse(text(smoke)); if (manifest.status !== 'PASS' || manifest.buildings !== false || manifest.units !== false || manifest.gameplay !== false || manifest.defaultRuntime !== 'unchanged') throw new Error('v0.377 smoke boundary is not clean'); }
  }
  const names = ['01_CLEAN_PRIMARY_RTS_VIEW.png', '02_ROAD_AND_TERRAIN_DETAIL.png', '03_RIVERBANK_DETAIL.png', '04_BRIDGE_AND_LANDINGS.png', '05_GRAYSCALE_PRIMARY.png', '06_REFERENCE_COMPARISON.png'];
  let count = 0;
  for (let i = 1; i <= 6; i += 1) {
    const dir = path.join(work, `v0377-iteration-0${i}`);
    must(dir, `iteration ${i} evidence folder`);
    for (const name of names) { const file = path.join(dir, name); must(file, `iteration ${i} ${name}`); const dimensions = png(file); if (dimensions.width !== 1920 || dimensions.height !== 1080) throw new Error(`${name} is not 1920x1080`); count += 1; }
    const manifest = path.join(dir, 'v0377-terrain-infrastructure.json');
    must(manifest, `iteration ${i} manifest`);
    const data = JSON.parse(text(manifest));
    if (data.stage !== 'stage-1-terrain-road-riverbanks-bridge' || data.gameplay !== false || data.defaultRuntime !== 'unchanged') throw new Error(`iteration ${i} manifest boundary failed`);
  }
  console.log(`PASS_V0377_REFERENCE_DRIVEN_TERRAIN_INFRASTRUCTURE (${count} rendered PNGs; Stage 1 only; opt-in; no gameplay)`);
}

const command = process.argv[2] ?? 'validate';
if (command === 'validate') validate();
else throw new Error(`unsupported command: ${command}`);
