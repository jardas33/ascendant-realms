import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const repo = process.cwd();
const must = (file, label) => { if (!fs.existsSync(file)) throw new Error(`missing ${label}: ${path.relative(repo, file)}`); };
const read = file => fs.readFileSync(file, 'utf8');
const sha256 = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const includes = (value, needle, label) => { if (!value.includes(needle)) throw new Error(`${label} missing: ${needle}`); };
const forbidden = (value, needle, label) => { if (value.toLowerCase().includes(needle.toLowerCase())) throw new Error(`${label} contains forbidden token: ${needle}`); };
const forbiddenWord = (value, needle, label) => { if (new RegExp(`\\b${needle}\\b`, 'i').test(value)) throw new Error(`${label} contains forbidden token: ${needle}`); };
const png = file => {
  const bytes = fs.readFileSync(file);
  if (bytes.length < 100000 || bytes.subarray(1, 4).toString('ascii') !== 'PNG') throw new Error(`invalid PNG: ${path.basename(file)}`);
  return { width: bytes.readUInt32BE(16), height: bytes.readUInt32BE(20), bytes: bytes.length };
};

const intakeRoot = path.join(repo, 'external-art-intake/original-barrosan/v0378-authored-infrastructure');
const intakeReadme = path.join(intakeRoot, 'docs/README.md');
const intakeShaFile = path.join(intakeRoot, 'docs/SHA256.json');
const intakeGlb = path.join(intakeRoot, 'exports/barrosan_infrastructure_v0378.glb');
const originalIntakeGlb = path.join(intakeRoot, 'exports/barrosan_infrastructure_v0378_original_supplied.glb');
const intakeSource = path.join(intakeRoot, 'source/generate_v0378_infrastructure.py');
const importedGlb = path.join(repo, 'desktop-spikes/godot-salto/assets/v0378/provided-infrastructure/barrosan_infrastructure_v0378.glb');
const scene = path.join(repo, 'desktop-spikes/godot-salto/scenes/v0378_provided_infrastructure.tscn');
const script = path.join(repo, 'desktop-spikes/godot-salto/scripts/v0378_provided_infrastructure.gd');
const rootScript = path.join(repo, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const packageJson = path.join(repo, 'package.json');
const work = path.join(repo, 'artifacts/work');
const report = path.join(repo, 'docs/V0378_PROVIDED_INFRASTRUCTURE_KIT_VISUAL_GATE_REPORT.md');
const blockerReport = path.join(repo, 'docs/V0378_PROVIDED_INFRASTRUCTURE_KIT_VISUAL_GATE_BLOCKER_REPORT.md');
const successPack = path.join(repo, 'artifacts/manual-review/v0378-provided-infrastructure-kit/');

function validate() {
  for (const [file, label] of [[intakeReadme, 'intake README'], [intakeShaFile, 'intake SHA manifest'], [intakeGlb, 'repaired intake GLB'], [originalIntakeGlb, 'original supplied GLB'], [intakeSource, 'intake source'], [importedGlb, 'imported GLB'], [scene, 'v0.378 scene'], [script, 'v0.378 Godot script'], [rootScript, 'opt-in root route'], [packageJson, 'package']]) must(file, label);
  const s = read(scene), g = read(script), r = read(rootScript), pkg = JSON.parse(read(packageJson));
  const intakeSums = JSON.parse(read(intakeShaFile));
  const expectedGlb = intakeSums['external-art-intake/original-barrosan/v0378-authored-infrastructure/exports/barrosan_infrastructure_v0378.glb'];
  if (expectedGlb !== sha256(intakeGlb) || expectedGlb !== sha256(importedGlb)) throw new Error('supplied GLB hash does not match intake manifest or imported copy');
  const expectedOriginal = intakeSums['external-art-intake/original-barrosan/v0378-authored-infrastructure/exports/barrosan_infrastructure_v0378_original_supplied.glb'];
  if (expectedOriginal !== '557653dbda28a350046ef9ac08ec41d0a5b1eaf496238fde3c2a5784a321b078' || expectedOriginal !== sha256(originalIntakeGlb)) throw new Error('original supplied GLB provenance hash is not preserved');
  includes(read(intakeReadme), 'bounded source repair record', 'intake README');
  includes(s, 'V0378ProvidedInfrastructure', 'scene');
  includes(g, 'res://assets/v0378/provided-infrastructure/barrosan_infrastructure_v0378.glb', 'supplied kit path');
  includes(g, 'Camera3D.PROJECTION_ORTHOGONAL', 'orthographic camera');
  includes(g, 'stage-1-provided-terrain-road-riverbanks-bridge', 'stage boundary');
  includes(r, '--v0378-provided-infrastructure', 'opt-in root arg');
  includes(r, 'v0378_provided_infrastructure.tscn', 'opt-in root scene');
  for (const key of ['godot:play:v0378-provided-infrastructure', 'godot:smoke:v0378-provided-infrastructure', 'godot:capture:v0378-provided-infrastructure', 'godot:validate:v0378-provided-infrastructure']) if (!pkg.scripts?.[key]) throw new Error(`missing package command: ${key}`);
  for (const token of ['v0377_reference', 'Continuous_Highland_Land_West', 'checkerboard', 'torn triangular', 'Main_Hall', 'Field_Barracks', 'Gold_Mine', 'Hostile_Camp', 'NavigationAgent3D', 'CharacterBody3D', 'Combat', 'damage', 'economy']) {
    forbidden(g, token, 'v0.378 runtime boundary');
  }
  for (const token of ['unit', 'movement', 'pathfinding']) {
    forbiddenWord(g, token, 'v0.378 runtime boundary');
  }
  const names = ['01_PRIMARY_RTS_VIEW.png', '02_ROAD_AND_TERRAIN_DETAIL.png', '03_RIVERBANK_DETAIL.png', '04_BRIDGE_AND_LANDINGS.png', '05_GRAYSCALE_PRIMARY.png'];
  let count = 0;
  const evidenceSets = [
    { prefix: 'v0378-iteration-0', hash: expectedOriginal, label: 'original' },
    { prefix: 'v0378-repaired-iteration-0', hash: expectedGlb, label: 'repaired' },
  ];
  for (const evidenceSet of evidenceSets) for (let i = 1; i <= 4; i += 1) {
    const dir = path.join(work, `${evidenceSet.prefix}${i}`);
    must(dir, `iteration ${i} evidence folder`);
    for (const name of names) {
      const file = path.join(dir, name); must(file, `iteration ${i} ${name}`);
      const dimensions = png(file); if (dimensions.width !== 1920 || dimensions.height !== 1080) throw new Error(`${name} is not 1920x1080`); count += 1;
    }
    const manifestFile = path.join(dir, 'v0378-provided-infrastructure.json'); must(manifestFile, `iteration ${i} manifest`);
    const manifest = JSON.parse(read(manifestFile));
    if (manifest.suppliedGeometry !== true || manifest.buildings !== false || manifest.units !== false || manifest.gameplay !== false || manifest.defaultRuntime !== 'unchanged' || manifest.glbSha256 !== evidenceSet.hash) throw new Error(`${evidenceSet.label} iteration ${i} manifest boundary failed`);
  }
  if (fs.existsSync(successPack)) {
    const successNames = ['00_READ_ME_FIRST.md', '01_PRIMARY_RTS_VIEW.png', '02_ROAD_AND_TERRAIN_DETAIL.png', '03_RIVERBANK_DETAIL.png', '04_BRIDGE_AND_LANDINGS.png', '05_GRAYSCALE_PRIMARY.png', '06_SOURCE_HASH_AND_IMPORT_REPORT.md', '07_SCORECARD.md', '08_VALIDATION.json'];
    for (const name of successNames) must(path.join(successPack, name), `success pack ${name}`);
    const validation = JSON.parse(read(path.join(successPack, '08_VALIDATION.json')));
    if (validation.delivery !== 'READY FOR HUMAN V0378 PROVIDED INFRASTRUCTURE KIT REVIEW') throw new Error('success pack delivery marker is incorrect');
  } else if (fs.existsSync(blockerReport)) {
    includes(read(blockerReport), 'BLOCKED', 'blocker report');
    includes(read(blockerReport), 'V0378 PROVIDED INFRASTRUCTURE KIT VISUAL GATE NOT MET', 'blocker report');
  }
  if (fs.existsSync(report)) includes(read(report), 'v0.378', 'v0.378 report');
  console.log(`PASS_V0378_PROVIDED_INFRASTRUCTURE_VALIDATOR (${count} rendered PNGs; supplied GLB hash verified; opt-in; no gameplay)`);
}

if ((process.argv[2] ?? 'validate') === 'validate') validate();
else throw new Error(`unsupported command: ${process.argv[2]}`);
