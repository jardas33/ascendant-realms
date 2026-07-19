import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const root = process.cwd();
const errors = [];
const abs = (relative) => path.join(root, relative);
const exists = (relative) => fs.existsSync(abs(relative));
const read = (relative) => fs.readFileSync(abs(relative), 'utf8');
const readJson = (relative) => JSON.parse(read(relative));
const sha256 = (relative) => crypto.createHash('sha256').update(fs.readFileSync(abs(relative))).digest('hex');
const assert = (condition, message) => { if (!condition) errors.push(message); };

const FROZEN_BLEND_SHA = '3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6';
const FROZEN_GLB_SHA = 'ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89';
const OUTCOME = 'REJECTED INTERNALLY — HOUSE02-DERIVED BARN STILL FAILS THE VISUAL PREFLIGHT';
const runtime = 'artifacts/runtime/v0343';
const manifestPath = `${runtime}/v0343-house02-derived-barn-visual-preflight-runtime.json`;
const reportPath = 'docs/V0343_HOUSE02_DERIVED_BARROSAN_BARN_VISUAL_PREFLIGHT_REPORT.md';
const captureNames = [
  '01_front_three_quarter_ordinary_rts.png',
  '02_rear_three_quarter_ordinary_rts.png',
  '03_front_close_material.png',
  '04_direct_side_gable.png',
  '05_house02_barn_matched_256.png',
];

function pngInfo(relative) {
  if (!exists(relative)) return null;
  const bytes = fs.readFileSync(abs(relative));
  if (bytes.length < 24 || bytes.readUInt32BE(0) !== 0x89504e47) return null;
  let sum = 0; let sum2 = 0; const step = Math.max(1, Math.floor(bytes.length / 5000));
  for (let i = 100; i < bytes.length; i += step) { sum += bytes[i]; sum2 += bytes[i] * bytes[i]; }
  const n = Math.max(1, Math.ceil((bytes.length - 100) / step));
  return { width: bytes.readUInt32BE(16), height: bytes.readUInt32BE(20), bytes: bytes.length, variance: sum2 / n - (sum / n) ** 2 };
}

function extractCaptureLedger(report) {
  const match = report.match(/V0343_CAPTURE_LEDGER_JSON\s*([\s\S]*?)\s*V0343_CAPTURE_LEDGER_JSON/);
  if (!match) return null;
  try { return JSON.parse(match[1]); } catch { return null; }
}

assert(exists('art-source/blender/v0343/house02_source_duplicate_initial.blend'), 'duplicated House 02 source is missing');
assert(exists('art-source/blender/v0343/house02_derived_barrosan_barn_visual_preflight.blend'), 'derived barn Blend source is missing');
assert(exists('desktop-spikes/godot-salto/assets/v0343/house02_derived_barrosan_barn_visual_preflight.glb'), 'derived barn GLB is missing');
assert(exists('desktop-spikes/godot-salto/scenes/review/V0343House02DerivedBarnVisualPreflight.tscn'), 'isolated preflight scene is missing');
assert(exists('desktop-spikes/godot-salto/scripts/v0343_house02_derived_barrosan_barn_visual_preflight.gd'), 'preflight runtime script is missing');
assert(exists('tools/blender/generateV0343House02DerivedBarrosanBarn.py'), 'v0.343 generator is missing');
assert(exists('tools/blender/generateV0343House02DerivedBarrosanBarnWindows.ps1'), 'v0.343 generator wrapper is missing');
assert(exists('tools/godot/captureGodotV0343House02DerivedBarnVisualPreflightWindows.ps1'), 'v0.343 capture wrapper is missing');
assert(exists('art-source/blender/v0343/v0343-source-lineage.json'), 'source lineage metadata is missing');
assert(exists('art-source/blender/v0343/v0343-barn-metrics.json'), 'barn metrics are missing');
assert(exists(reportPath), 'v0.343 report is missing');
assert(!exists('artifacts/manual-review/v0343-house02-derived-barn-visual-preflight'), 'rejected visual gate must not create a review pack');

assert(sha256('art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend') === FROZEN_BLEND_SHA, 'frozen House 02 Blend changed');
assert(sha256('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb') === FROZEN_GLB_SHA, 'frozen House 02 GLB changed');
assert(sha256('art-source/blender/v0343/house02_source_duplicate_initial.blend') === FROZEN_BLEND_SHA, 'duplicated House 02 source is not byte-identical to frozen source');

const lineage = readJson('art-source/blender/v0343/v0343-source-lineage.json');
assert(lineage.originalFrozenHash === FROZEN_BLEND_SHA && lineage.copiedSourceInitialHash === FROZEN_BLEND_SHA, 'lineage frozen hashes mismatch');
assert(lineage.visibleDependencies?.v0341 === false && lineage.visibleDependencies?.v0342 === false, 'v0.341/v0.342 dependency flags are not closed');
assert(lineage.copiedSource === 'art-source/blender/v0343/house02_source_duplicate_initial.blend', 'lineage copied source path mismatch');
for (const token of ['generateV0341', 'generateV0342', 'v0341_barrosan', 'v0342_reference_locked']) assert(!read('tools/blender/generateV0343House02DerivedBarrosanBarn.py').toLowerCase().includes(token.toLowerCase()), `generator visibly depends on ${token}`);

const metrics = readJson('art-source/blender/v0343/v0343-barn-metrics.json');
assert(metrics.prototypeOnly === true && metrics.defaultRuntimeIntegrated === false && metrics.assetProvenance?.includes('repository-authored'), 'prototype isolation/provenance contract missing');
assert(metrics.architecture?.closedRectangularVolume === true && metrics.architecture?.principalRoofSlopes === 2, 'closed barn volume/two-slope roof contract missing');
assert(metrics.architecture?.lowerDoubleDoor === true && metrics.architecture?.upperHayLoadingOpening === true && metrics.architecture?.resolvedRear === true && metrics.architecture?.resolvedBothGables === true, 'barn opening/rear/gable contract missing');
assert(metrics.materialSlots === 6 && metrics.visibleTriangles > 0 && metrics.visibleTriangles < 60000, 'compact real-geometry metrics invalid');
assert(metrics.sourceTexturePaths?.some((p) => p.includes('v0338')), 'House 02 material provenance missing');

const scene = read('desktop-spikes/godot-salto/scenes/review/V0343House02DerivedBarnVisualPreflight.tscn');
const script = read('desktop-spikes/godot-salto/scripts/v0343_house02_derived_barrosan_barn_visual_preflight.gd');
assert(scene.includes('[node name="V0343House02DerivedBarnVisualPreflight" type="Node3D"]'), 'scene is not an isolated Node3D fixture');
for (const token of ['move_and_slide', 'NavigationAgent', 'damage', 'projectile', 'save_game', 'resource_mutation', 'instantiate_enemy']) assert(!script.toLowerCase().includes(token.toLowerCase()), `forbidden gameplay coupling: ${token}`);
for (const token of ['V0343_Stable_Oblique_Preflight_Camera', 'PROJECTION_ORTHOGONAL', 'V0343_Frozen_House02_Unmodified_Anchor', 'V0343_House02_Derived_Barrosan_Barn_Candidate', '05_house02_barn_matched_256.png']) assert(script.includes(token), `capture contract missing: ${token}`);

const report = read(reportPath);
assert(report.includes(OUTCOME), 'report does not record the exact rejected visual outcome');
assert(report.includes('No upload review pack was created') && report.includes('No technical diagnostics were created'), 'report does not record rejection evidence boundary');
assert(report.includes('01_front_three_quarter_ordinary_rts.png') && report.includes('05_house02_barn_matched_256.png'), 'report does not identify all five source captures');

if (exists(manifestPath)) {
  const manifest = readJson(manifestPath);
  assert(manifest.checkpoint === 'v0.343' && manifest.outcome === OUTCOME, 'runtime manifest outcome/checkpoint mismatch');
  assert(manifest.status === 'PASS_V0343_HOUSE02_DERIVED_BARN_VISUAL_PREFLIGHT' && manifest.humanReviewRequired === true && manifest.automatedVisualApproval === false, 'human visual gate metadata mismatch');
  assert(manifest.captureCount === 5 && manifest.errors?.length === 0 && manifest.house02Modified === false, 'five-capture runtime manifest incomplete');
  assert(manifest.prototypeOptIn === true && manifest.prototypeOnly === true && manifest.defaultRuntimeIntegrated === false, 'runtime is not isolated opt-in');
  assert(manifest.noTechnicalDiagnostics === true && manifest.noVideo === true && manifest.noLOD === true && manifest.noCollision === true, 'rejection boundary flags failed');
  for (const name of captureNames) {
    const info = pngInfo(`${runtime}/screenshots/${name}`);
    assert(info && info.width >= 256 && info.height >= 144 && info.bytes > 10000 && info.variance > 2, `invalid source capture: ${name}`);
  }
} else {
  const ledger = extractCaptureLedger(report);
  assert(ledger?.captures?.length === 5, 'runtime captures absent and report ledger does not preserve five source captures');
  for (const name of captureNames) assert(ledger.captures.some((capture) => capture.fileName === name && /^[a-f0-9]{64}$/.test(capture.sha256) && capture.bytes > 10000), `report capture ledger missing hash: ${name}`);
}

const packageText = read('package.json');
for (const command of ['blender:generate:salto-v0343-house02-derived-barn-visual-preflight', 'godot:capture:salto-v0343-house02-derived-barn-visual-preflight', 'godot:validate:salto-v0343-house02-derived-barn-visual-preflight']) assert(packageText.includes(command), `package command missing: ${command}`);
for (const forbidden of ['video', 'wireframe', 'collision', 'lod', 'uv-checker']) assert(!exists(`artifacts/manual-review/v0343-house02-derived-barn-visual-preflight/${forbidden}`), `forbidden technical evidence exists: ${forbidden}`);

if (errors.length) {
  console.error(JSON.stringify({ status: 'FAIL_V0343_HOUSE02_DERIVED_BARN_VISUAL_PREFLIGHT', errors }, null, 2));
  process.exit(1);
}
console.log(JSON.stringify({ status: 'PASS_V0343_HOUSE02_DERIVED_BARN_VISUAL_PREFLIGHT', outcome: OUTCOME, automatedVisualApproval: false, humanReviewRequired: true, sourceCaptures: 5, reviewPackCreated: false, defaultRuntimeUnchanged: true, gameplayUnchanged: true }, null, 2));
