import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const repo = process.cwd();
const scene = path.join(repo, 'desktop-spikes/godot-salto/scenes/v0372_quaternius_rts_visual_recovery.tscn');
const script = path.join(repo, 'desktop-spikes/godot-salto/scripts/v0372_quaternius_rts_visual_recovery.gd');
const rootScript = path.join(repo, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const packageJson = path.join(repo, 'package.json');
const report = path.join(repo, 'docs/V0372_SINGLE_FRAME_RTS_VISUAL_RECOVERY_REPORT.md');
const pack = path.join(repo, 'artifacts/manual-review/v0372-quaternius-rts-visual-recovery');
const raw = path.join(repo, 'artifacts/runtime/v0372');
const intake = path.join(repo, 'desktop-spikes/godot-salto/assets/third_party/quaternius/v0370');
const smoke = path.join(raw, 'v0372-visual-recovery-smoke.json');
const packFiles = [
  '00_READ_ME_FIRST.md',
  '01_PRIMARY_RTS_COMPOSITION.png',
  '02_CLOSER_SETTLEMENT_AND_RESOURCE.png',
  '03_BRIDGE_AND_HOSTILE_CAMP.png',
  '04_TOPDOWN_SPACING_AUDIT.png',
  '05_VALIDATION.json',
];

const mustExist = (file, label) => {
  if (!fs.existsSync(file)) throw new Error(`missing ${label}: ${path.relative(repo, file)}`);
};
const text = (file) => fs.readFileSync(file, 'utf8');
const assertIncludes = (value, needle, label) => {
  if (!value.includes(needle)) throw new Error(`${label} missing: ${needle}`);
};
const assertNo = (value, needle, label) => {
  if (value.includes(needle)) throw new Error(`${label} contains forbidden token: ${needle}`);
};

function pngDimensions(file) {
  const buffer = fs.readFileSync(file);
  if (buffer.length < 24 || buffer.toString('ascii', 1, 4) !== 'PNG') throw new Error(`not a PNG: ${path.basename(file)}`);
  return { width: buffer.readUInt32BE(16), height: buffer.readUInt32BE(20), bytes: buffer.length };
}

function assertRetainedUnchanged() {
  for (const file of [
    'desktop-spikes/godot-salto/scenes/v0370_quaternius_visual_proof.tscn',
    'desktop-spikes/godot-salto/scripts/v0370_quaternius_visual_proof.gd',
    'desktop-spikes/godot-salto/scenes/v0371_first_cohesive_quaternius_rts_sector.tscn',
    'desktop-spikes/godot-salto/scripts/v0371_first_cohesive_quaternius_rts_sector.gd',
  ]) {
    try {
      execFileSync('git', ['diff', '--quiet', '--', file], { cwd: repo, stdio: 'ignore' });
    } catch {
      throw new Error(`retained scene/script has a worktree diff: ${file}`);
    }
  }
}

function validatePack() {
  mustExist(pack, 'review pack');
  const names = fs.readdirSync(pack).filter((name) => fs.statSync(path.join(pack, name)).isFile()).sort();
  const expected = [...packFiles].sort();
  if (names.length !== expected.length || names.some((name, index) => name !== expected[index])) {
    throw new Error(`review pack must contain exactly six files; found ${names.join(', ')}`);
  }
  for (const name of packFiles) {
    const file = path.join(pack, name);
    mustExist(file, `review-pack file ${name}`);
    if (name.endsWith('.png')) {
      const dimensions = pngDimensions(file);
      if (dimensions.width !== 1920 || dimensions.height !== 1080) throw new Error(`${name} must be 1920x1080; got ${dimensions.width}x${dimensions.height}`);
      if (dimensions.bytes < 100000) throw new Error(`${name} is too small to be a rendered frame`);
    } else if (fs.statSync(file).size < 100) {
      throw new Error(`review-pack file is too small: ${name}`);
    }
  }
  const readme = text(path.join(pack, '00_READ_ME_FIRST.md'));
  assertIncludes(readme, 'READY FOR HUMAN V0372 RTS VISUAL COMPOSITION REVIEW', 'README');
  assertIncludes(readme, 'does not claim acceptance', 'README');
}

function writePackManifest() {
  fs.mkdirSync(pack, { recursive: true });
  const captures = packFiles.filter((name) => name.endsWith('.png')).map((name) => {
    const dimensions = pngDimensions(path.join(pack, name));
    return { file: name, width: dimensions.width, height: dimensions.height, bytes: dimensions.bytes, rendered: true };
  });
  fs.writeFileSync(path.join(pack, '05_VALIDATION.json'), `${JSON.stringify({ checkpoint: 'v0.372', status: 'READY_FOR_HUMAN_REVIEW', primary: captures[0], hud: false, captures, packFiles: packFiles.length, source: 'v0.370 Quaternius assets, isolated world-only composition', defaultRuntime: 'unchanged', gameplay: 'not connected' }, null, 2)}\n`, 'utf8');
}

function validate() {
  for (const [file, label] of [[scene, 'isolated scene'], [script, 'visual recovery script'], [rootScript, 'root router'], [packageJson, 'package.json'], [report, 'report']]) mustExist(file, label);
  const pkg = JSON.parse(text(packageJson));
  for (const key of ['godot:play:quaternius-visual-recovery', 'godot:smoke:quaternius-visual-recovery', 'godot:capture:quaternius-visual-recovery', 'godot:validate:quaternius-visual-recovery']) {
    if (!pkg.scripts?.[key]) throw new Error(`missing package command: ${key}`);
  }
  const sceneText = text(scene);
  const scriptText = text(script);
  const rootText = text(rootScript);
  assertIncludes(sceneText, 'V0372QuaterniusRtsVisualRecovery', 'scene');
  assertIncludes(scriptText, 'Camera3D.PROJECTION_ORTHOGONAL', 'fixed camera');
  assertIncludes(scriptText, 'One_Continuous_Recessed_River', 'single river');
  assertIncludes(scriptText, 'Single_Readable_Timber_Bridge', 'bridge');
  assertIncludes(scriptText, 'Settlement_To_Bridge_Path', 'settlement path');
  assertIncludes(scriptText, 'Bridge_To_Hostile_Camp_Path', 'camp path');
  assertIncludes(scriptText, 'Gold_Resource_Site', 'resource site');
  assertIncludes(scriptText, 'Hostile_Camp_Opposite_Bank', 'hostile camp');
  assertIncludes(scriptText, 'seed(372)', 'deterministic scene');
  assertIncludes(rootText, '--v0372-quaternius-visual-recovery', 'opt-in route flag');
  assertIncludes(rootText, 'v0372_quaternius_rts_visual_recovery.tscn', 'isolated route scene');
  assertIncludes(rootText, 'v0368_playable_slice_visual_coherence.tscn', 'default route retained');
  for (const forbidden of ['CapsuleMesh', 'SphereMesh', 'CylinderMesh', 'Label3D', 'CanvasLayer', 'Control.new()', 'v0368_playable_slice_visual_coherence.gd']) assertNo(scriptText, forbidden, 'world-only script');
  if (!fs.existsSync(intake)) throw new Error('missing Quaternius asset intake');
  const assetPaths = [...scriptText.matchAll(/"([^"]+\.gltf)"/g)].map((match) => match[1]);
  for (const assetPath of [...new Set(assetPaths)]) mustExist(path.join(intake, assetPath), `Quaternius asset ${assetPath}`);
  assertRetainedUnchanged();
  if (fs.existsSync(smoke)) {
    const smokeData = JSON.parse(text(smoke));
    if (smokeData.status !== 'PASS' || smokeData.hud !== false || smokeData.gameplay !== false) throw new Error('smoke manifest is not a clean world-only pass');
  }
  validatePack();
  const reportText = text(report);
  assertIncludes(reportText, 'true default runtime', 'report');
  assertIncludes(reportText, 'v0.370 proof scene', 'report');
  assertIncludes(reportText, 'v0.371 playable scene', 'report');
  console.log('PASS_V0372_QUATERNIUS_VISUAL_RECOVERY');
}

const command = process.argv[2] ?? 'validate';
if (command === 'pack') writePackManifest();
else if (command === 'validate') validate();
else throw new Error(`unsupported command: ${command}`);
