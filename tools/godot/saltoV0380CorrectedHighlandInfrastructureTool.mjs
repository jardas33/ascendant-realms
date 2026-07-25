import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const repo = process.cwd();
const intakeRoot = path.join(repo, 'external-art-intake/original-barrosan/v0380-authored-highland-infrastructure');
const sourceGlb = path.join(intakeRoot, 'exports/barrosan_highland_infrastructure_v0380.glb');
const sourceScript = path.join(intakeRoot, 'source/generate_v0380_highland_infrastructure.py');
const importedGlb = path.join(repo, 'desktop-spikes/godot-salto/assets/v0380/corrected-highland-infrastructure/barrosan_highland_infrastructure_v0380.glb');
const scene = path.join(repo, 'desktop-spikes/godot-salto/scenes/v0380_corrected_highland_infrastructure.tscn');
const script = path.join(repo, 'desktop-spikes/godot-salto/scripts/v0380_corrected_highland_infrastructure.gd');
const rootScript = path.join(repo, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const project = path.join(repo, 'package.json');
const runtime = path.join(repo, 'desktop-spikes/godot-salto/artifacts/runtime/v0380');
const pack = path.join(repo, 'artifacts/manual-review/v0380-corrected-highland-infrastructure');
const report = path.join(repo, 'docs/V0380_CORRECTED_HIGHLAND_INFRASTRUCTURE_REVIEW_REPORT.md');
const expectedGlb = '746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb';
const expectedSource = '4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19';
const images = ['01_PRIMARY_RTS_VIEW.png', '02_ROAD_AND_TERRAIN_DETAIL.png', '03_CONTINUOUS_RIVER_CROSSING.png', '04_BRIDGE_AND_LANDINGS.png', '05_ELEVATED_TOPOLOGY_AUDIT.png', '06_GRAYSCALE_PRIMARY.png'];
const packNames = ['00_READ_ME_FIRST.md', ...images, '07_SOURCE_HASH_AND_IMPORT_REPORT.md', '08_PRESENTATION_REVIEW.md', '09_VALIDATION.json'];

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
  for (const [file, label] of [[sourceGlb, 'supplied v0.380 GLB'], [sourceScript, 'supplied generator'], [importedGlb, 'imported v0.380 GLB'], [scene, 'v0.380 scene'], [script, 'v0.380 script'], [rootScript, 'Salto opt-in router'], [report, 'v0.380 report']]) must(fs.existsSync(file), label);
  if (sha256(sourceGlb) !== expectedGlb || sha256(importedGlb) !== expectedGlb) throw new Error('supplied and imported v0.380 GLB hashes do not match the corrected intake hash');
  if (sha256(sourceScript) !== expectedSource) throw new Error('supplied v0.380 generator hash changed');
  const g = read(script);
  const r = read(rootScript);
  const p = JSON.parse(read(project));
  includes(g, 'vertexColours', 'capture manifest contract');
  includes(g, 'PROJECTION_ORTHOGONAL', 'controlled orthographic camera');
  includes(g, 'res://assets/v0380/corrected-highland-infrastructure/barrosan_highland_infrastructure_v0380.glb', 'exact imported GLB path');
  for (const forbidden of ['material_override', 'mesh =', 'SurfaceTool', 'PlaneMesh', 'BoxMesh', 'ArrayMesh']) {
    if (g.includes(forbidden)) throw new Error(`v0.380 presentation script contains forbidden geometry/material replacement: ${forbidden}`);
  }
  for (const token of ['--v0380-highland-infrastructure', '--v0380-highland-infrastructure-smoke', '--v0380-highland-infrastructure-capture', 'v0380_corrected_highland_infrastructure.tscn']) includes(r, token, 'v0.380 opt-in router');
  for (const key of ['godot:play:v0380-highland-infrastructure', 'godot:smoke:v0380-highland-infrastructure', 'godot:capture:v0380-highland-infrastructure', 'godot:validate:v0380-highland-infrastructure']) must(p.scripts?.[key], `package command ${key}`);
  for (const file of images) {
    const d = png(path.join(runtime, file));
    if (d.width !== 1920 || d.height !== 1080 || d.bytes < 10000) throw new Error(`${file} is not a real 1920x1080 capture`);
  }
  const manifest = JSON.parse(read(path.join(runtime, 'v0380-corrected-highland-infrastructure.json')));
  for (const [key, expected] of Object.entries({ buildings: false, units: false, gameplay: false, hud: false, debugOverlays: false, defaultRuntime: 'unchanged', route: 'opt-in-only', vertexColours: 'preserved', glbSha256: expectedGlb, sourceSha256: expectedSource })) {
    if (manifest[key] !== expected) throw new Error(`runtime manifest ${key} boundary failed`);
  }
  if (!fs.existsSync(pack)) throw new Error('v0.380 review pack missing');
  const actualPack = fs.readdirSync(pack).filter(name => fs.statSync(path.join(pack, name)).isFile()).sort();
  if (JSON.stringify(actualPack) !== JSON.stringify([...packNames].sort())) throw new Error(`review pack must contain exactly ${packNames.length} files`);
  const validation = JSON.parse(read(path.join(pack, '09_VALIDATION.json')));
  if (validation.status !== 'READY FOR HUMAN V0380 CORRECTED HIGHLAND INFRASTRUCTURE REVIEW') throw new Error('review pack status is not human-review ready');
  if (validation.glbSha256 !== expectedGlb || validation.importedGlbSha256 !== expectedGlb || validation.sourceSha256 !== expectedSource) throw new Error('review pack hash record failed');
  includes(read(path.join(pack, '00_READ_ME_FIRST.md')), 'READY FOR HUMAN V0380 CORRECTED HIGHLAND INFRASTRUCTURE REVIEW', 'review README status');
  console.log(`PASS_V0380_CORRECTED_HIGHLAND_INFRASTRUCTURE_VALIDATOR (${images.length} runtime captures; exact GLB/source hashes; exact 10-file pack; opt-in; no gameplay)`);
}

if (process.argv[2] === 'validate') validate();
else throw new Error('usage: node tools/godot/saltoV0380CorrectedHighlandInfrastructureTool.mjs validate');
