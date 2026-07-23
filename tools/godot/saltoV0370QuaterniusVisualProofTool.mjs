import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const repo = process.cwd();
const scene = path.join(repo, 'desktop-spikes/godot-salto/scenes/v0370_quaternius_visual_proof.tscn');
const script = path.join(repo, 'desktop-spikes/godot-salto/scripts/v0370_quaternius_visual_proof.gd');
const rootScript = path.join(repo, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const packageJson = path.join(repo, 'package.json');
const manifest = path.join(repo, 'docs/V0370_QUATERNIUS_SELECTED_ASSET_MANIFEST.md');
const report = path.join(repo, 'docs/V0370_QUATERNIUS_COHESIVE_ART_FAMILY_PROOF_REPORT.md');
const intake = path.join(repo, 'desktop-spikes/godot-salto/assets/third_party/quaternius/v0370');
const pack = path.join(repo, 'artifacts/manual-review/v0370-quaternius-cohesive-art-family-proof');
const raw = path.join(repo, 'artifacts/runtime/v0370');

const requiredPack = [
  '00_READ_ME_FIRST.md',
  '01_QUATERNIUS_WIDE.png',
  '02_QUATERNIUS_RTS_CAMERA.png',
  '03_QUATERNIUS_CLOSE_DETAIL.png',
  '04_QUATERNIUS_BRIDGE_CONTACT.png',
  '05_QUATERNIUS_HOSTILE_CAMP.png',
  '06_ORIGINAL_VS_QUATERNIUS_COMPARISON.png',
  '07_SELECTED_ASSET_MANIFEST.md',
  '08_RUNTIME_VALIDATION.json',
];

const mustExist = (file, label) => {
  if (!fs.existsSync(file)) throw new Error(`missing ${label}: ${path.relative(repo, file)}`);
};
const text = (file) => fs.readFileSync(file, 'utf8');
const assertIncludes = (value, needle, label) => {
  if (!value.includes(needle)) throw new Error(`${label} missing: ${needle}`);
};

function validate() {
  for (const [file, label] of [[scene, 'prototype scene'], [script, 'prototype script'], [rootScript, 'root router'], [manifest, 'asset manifest'], [report, 'report']]) mustExist(file, label);
  const pkg = JSON.parse(text(packageJson));
  for (const key of ['godot:play:quaternius-proof', 'godot:smoke:quaternius-proof', 'godot:capture:quaternius-proof', 'godot:validate:quaternius-proof']) {
    if (!pkg.scripts?.[key]) throw new Error(`missing package command: ${key}`);
  }
  const sceneText = text(scene);
  const scriptText = text(script);
  const rootText = text(rootScript);
  assertIncludes(sceneText, 'AscendantRealmsQuaterniusVisualProof', 'scene');
  assertIncludes(scriptText, 'ASSET_ROOT', 'prototype script');
  assertIncludes(scriptText, 'Composed_Timber_Bridge', 'bridge composition');
  assertIncludes(scriptText, 'Recessed_Stream', 'recessed stream');
  assertIncludes(scriptText, 'Continuous_Terrain_Bed', 'continuous terrain bed');
  assertIncludes(scriptText, 'Camera3D.PROJECTION_PERSPECTIVE', 'oblique camera');
  assertIncludes(scriptText, 'seed(370)', 'deterministic seed');
  assertIncludes(rootText, '--v0370-quaternius-proof', 'opt-in router flag');
  assertIncludes(rootText, 'v0370_quaternius_visual_proof.tscn', 'isolated router scene');
  for (const forbidden of ['CapsuleMesh', 'SphereMesh', 'CylinderMesh', 'Label3D', 'CanvasLayer', 'v0368_playable_slice_visual_coherence.tscn']) {
    if (scriptText.includes(forbidden)) throw new Error(`forbidden prototype substitute or coupling: ${forbidden}`);
  }
  if (!fs.existsSync(intake)) throw new Error('missing selected Quaternius derived intake');
  const gltf = [];
  const walk = (dir) => {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) walk(full);
      else if (entry.name.endsWith('.gltf')) gltf.push(full);
    }
  };
  walk(intake);
  if (gltf.length < 20 || gltf.length > 40) throw new Error(`selected intake glTF count outside bounded range: ${gltf.length}`);
  const manifestText = text(manifest).toLowerCase();
  assertIncludes(manifestText, 'external-art-intake/quaternius/', 'manifest provenance');
  assertIncludes(manifestText, 'accepted', 'manifest acceptance record');
  assertIncludes(manifestText, 'rejected', 'manifest rejection record');
  for (const name of requiredPack) {
    const file = path.join(pack, name);
    mustExist(file, `review-pack file ${name}`);
    const minimumBytes = name.endsWith('.png') ? 100000 : 100;
    if (fs.statSync(file).size < minimumBytes) throw new Error(`review-pack file is empty or too small: ${name}`);
  }
  const packNames = fs.readdirSync(pack).filter((name) => fs.statSync(path.join(pack, name)).isFile()).sort();
  if (packNames.length !== requiredPack.length || packNames.some((name, index) => name !== [...requiredPack].sort()[index])) {
    throw new Error(`review pack must contain exactly ${requiredPack.length} files; found ${packNames.length}: ${packNames.join(', ')}`);
  }
  for (const name of requiredPack.slice(1, 6)) {
    mustExist(path.join(raw, name), `raw capture ${name}`);
    if (fs.statSync(path.join(raw, name)).size < 100000) throw new Error(`raw capture is too small: ${name}`);
  }
  const comparison = path.join(pack, '06_ORIGINAL_VS_QUATERNIUS_COMPARISON.png');
  if (fs.statSync(comparison).size < 100000) throw new Error('comparison sheet is too small');
  const reportText = text(report);
  if (!reportText.includes('production integration') && !reportText.includes('production loop')) throw new Error('report must disclose production isolation');
  try {
    execFileSync('git', ['diff', '--quiet', '--', 'desktop-spikes/godot-salto/scenes/v0368_playable_slice_visual_coherence.tscn', 'desktop-spikes/godot-salto/scripts/v0368_playable_slice_visual_coherence.gd'], { cwd: repo, stdio: 'ignore' });
  } catch {
    throw new Error('accepted v0.368 scene or script has a worktree diff');
  }
  console.log(`v0.370 Quaternius visual proof validation passed: ${gltf.length} selected glTF files, ${packNames.length}-file review pack, 5 raw captures`);
}

if ((process.argv[2] ?? 'validate') !== 'validate') throw new Error(`unsupported command: ${process.argv[2]}`);
validate();
