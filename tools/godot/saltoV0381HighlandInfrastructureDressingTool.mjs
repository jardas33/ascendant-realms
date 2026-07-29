import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const repo = process.cwd();
const sourceGlb = path.join(repo, 'external-art-intake/original-barrosan/v0380-authored-highland-infrastructure/exports/barrosan_highland_infrastructure_v0380.glb');
const sourceScript = path.join(repo, 'external-art-intake/original-barrosan/v0380-authored-highland-infrastructure/source/generate_v0380_highland_infrastructure.py');
const importedGlb = path.join(repo, 'desktop-spikes/godot-salto/assets/v0380/corrected-highland-infrastructure/barrosan_highland_infrastructure_v0380.glb');
const scene = path.join(repo, 'desktop-spikes/godot-salto/scenes/v0381_highland_infrastructure_dressing.tscn');
const script = path.join(repo, 'desktop-spikes/godot-salto/scripts/v0381_highland_infrastructure_dressing.gd');
const rootScript = path.join(repo, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const project = path.join(repo, 'package.json');
const runtime = path.join(repo, 'desktop-spikes/godot-salto/artifacts/runtime/v0381');
const pack = path.join(repo, 'artifacts/manual-review/v0381-highland-infrastructure-dressing');
const report = path.join(repo, 'docs/V0381_ACCEPTED_HIGHLAND_INFRASTRUCTURE_ENVIRONMENT_DRESSING_REPORT.md');
const expectedGlb = '746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb';
const expectedSource = '4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19';
const images = ['01_PRIMARY_RTS_VIEW.png', '02_CROSSING_CONTEXT_VIEW.png', '03_RIVERBANK_AND_REEDS_DETAIL.png', '04_BRIDGE_AND_LANDINGS_DETAIL.png', '05_DRESSING_DISTRIBUTION_AUDIT.png', '06_GRAYSCALE_PRIMARY.png'];
const packFiles = ['00_READ_ME_FIRST.md', ...images, '07_VALIDATION.json', '08_PRESENTATION_REVIEW.md'];

const must = (value, label) => { if (!value) throw new Error(`missing ${label}`); };
const read = file => fs.readFileSync(file, 'utf8');
const sha256 = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const includes = (value, token, label) => { if (!value.includes(token)) throw new Error(`${label} missing ${token}`); };
const png = file => {
  const b = fs.readFileSync(file);
  if (b.readUInt32BE(0) !== 0x89504e47 || b.readUInt32BE(4) !== 0x0d0a1a0a) throw new Error(`${file} is not PNG`);
  return { width: b.readUInt32BE(16), height: b.readUInt32BE(20), bytes: b.length };
};

function validate() {
  for (const [file, label] of [[sourceGlb, 'accepted v0.380 source GLB'], [sourceScript, 'accepted v0.380 generator'], [importedGlb, 'accepted imported GLB'], [scene, 'v0.381 scene'], [script, 'v0.381 script'], [rootScript, 'opt-in router'], [report, 'v0.381 report']]) must(fs.existsSync(file), label);
  if (sha256(sourceGlb) !== expectedGlb || sha256(importedGlb) !== expectedGlb) throw new Error('accepted v0.380 GLB hash changed');
  if (sha256(sourceScript) !== expectedSource) throw new Error('accepted v0.380 generator hash changed');
  const g = read(script);
  const r = read(rootScript);
  const p = JSON.parse(read(project));
  includes(g, 'v0380/corrected-highland-infrastructure/barrosan_highland_infrastructure_v0380.glb', 'unchanged accepted base kit');
  includes(g, 'V0381_Sparse_Environment_Dressing_Only', 'dressing root');
  includes(g, 'Dressing_Riverbank_Shrubs_Reeds', 'riverbank dressing group');
  includes(g, 'Dressing_Rock_Distribution', 'rock dressing group');
  includes(g, 'third_party/quaternius/v0370', 'existing in-repo asset root');
  includes(g, 'PROJECTION_ORTHOGONAL', 'controlled orthographic camera');
  includes(g, 'baseKitUnchanged', 'base preservation manifest');
  for (const forbidden of ['move_and_slide', 'NavigationAgent', 'attack', 'damage', 'hit_points', 'economy', 'production_queue', 'route_follow']) {
    if (g.toLowerCase().includes(forbidden.toLowerCase())) throw new Error(`v0.381 dressing script contains forbidden gameplay token: ${forbidden}`);
  }
  for (const token of ['--v0381-highland-dressing', '--v0381-highland-dressing-smoke', '--v0381-highland-dressing-capture', 'v0381_highland_infrastructure_dressing.tscn']) includes(r, token, 'v0.381 opt-in router');
  for (const key of ['godot:play:v0381-highland-dressing', 'godot:smoke:v0381-highland-dressing', 'godot:capture:v0381-highland-dressing', 'godot:validate:v0381-highland-dressing']) must(p.scripts?.[key], `package command ${key}`);
  for (const file of images) {
    const d = png(path.join(runtime, file));
    if (d.width !== 1920 || d.height !== 1080 || d.bytes < 10000) throw new Error(`${file} is not a real 1920x1080 capture`);
  }
  const manifest = JSON.parse(read(path.join(runtime, 'v0381-highland-infrastructure-dressing.json')));
  for (const [key, expected] of Object.entries({ baseKitUnchanged: true, dressingOnly: true, buildings: false, units: false, gameplay: false, hud: false, defaultRuntime: 'unchanged', route: 'opt-in-only', glbSha256: expectedGlb, sourceSha256: expectedSource })) {
    if (manifest[key] !== expected) throw new Error(`runtime manifest ${key} boundary failed`);
  }
  must(fs.existsSync(pack), 'v0.381 review pack');
  const actualPack = fs.readdirSync(pack).filter(name => fs.statSync(path.join(pack, name)).isFile()).sort();
  if (JSON.stringify(actualPack) !== JSON.stringify([...packFiles].sort())) throw new Error(`review pack file contract failed; expected ${packFiles.length} files`);
  const validation = JSON.parse(read(path.join(pack, '07_VALIDATION.json')));
  if (validation.status !== 'READY FOR HUMAN V0381 ENVIRONMENT DRESSING REVIEW') throw new Error('v0.381 review status is not human-review ready');
  if (validation.baseGlbSha256 !== expectedGlb || validation.sourceGeneratorSha256 !== expectedSource) throw new Error('v0.381 hash record failed');
  includes(read(path.join(pack, '00_READ_ME_FIRST.md')), 'READY FOR HUMAN V0381 ENVIRONMENT DRESSING REVIEW', 'review README status');
  includes(read(path.join(pack, '08_PRESENTATION_REVIEW.md')), 'real rendered', 'rendered-evidence review record');
  console.log(`PASS_V0381_HIGHLAND_INFRASTRUCTURE_DRESSING_VALIDATOR (${images.length} real captures; accepted v0.380 kit unchanged; opt-in dressing only; no gameplay)`);
}

if (process.argv[2] === 'validate') validate();
else throw new Error('usage: node tools/godot/saltoV0381HighlandInfrastructureDressingTool.mjs validate');
