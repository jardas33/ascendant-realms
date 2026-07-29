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
const V0343_BLEND_SHA = 'ecb268c7a4f69c914951a0dbd9494fb332003566073b2311b47a348ba9f831e9';
const V0343_GLB_SHA = 'd4d780510b1812e7e4f082f24dfee049ab21f905acbaaeaa4f54d6f67b4118b9';
const OUTCOME = 'READY FOR HUMAN V0344 BARN MATERIAL-AND-ROOF VISUAL PREFLIGHT REVIEW';
const runtime = 'artifacts/runtime/v0344';
const manifestPath = `${runtime}/v0344-barn-front-granite-roof-edge-visual-preflight-runtime.json`;
const reportPath = 'docs/V0344_BARN_FRONT_GRANITE_AND_ROOF_EDGE_SURGICAL_REPAIR_REPORT.md';
const packRoot = 'artifacts/manual-review/v0344-barn-front-granite-roof-edge-visual-preflight/UPLOAD_TO_CHAT';
const packNames = ['00_READ_ME_FIRST.md', '01_HOUSE02_LINEAGE_AND_REPAIR_DIAGNOSIS.png', '02_UNLABELLED_FRONT_AND_REAR_VISUAL_LOCK.png', '03_GRANITE_CONTINUITY_AND_ROOF_EDGE.png', '04_MATCHED_HOUSE02_AND_TRUE_256PX.png', 'compact-evidence-summary.json'];
const captureNames = ['01_front_three_quarter_granite_roof.png', '02_rear_three_quarter_granite_roof.png', '03_front_close_granite_continuity.png', '04_direct_side_gable_roof.png', '05_house02_barn_matched_true_256.png'];

function pngInfo(relative) {
  if (!exists(relative)) return null;
  const bytes = fs.readFileSync(abs(relative));
  if (bytes.length < 24 || bytes.readUInt32BE(0) !== 0x89504e47) return null;
  let sum = 0; let sum2 = 0; const step = Math.max(1, Math.floor(bytes.length / 5000));
  for (let i = 100; i < bytes.length; i += step) { sum += bytes[i]; sum2 += bytes[i] * bytes[i]; }
  const n = Math.max(1, Math.ceil((bytes.length - 100) / step));
  return { width: bytes.readUInt32BE(16), height: bytes.readUInt32BE(20), bytes: bytes.length, variance: sum2 / n - (sum / n) ** 2 };
}

function reportLedger() {
  const report = read(reportPath);
  const match = report.match(/V0344_CAPTURE_LEDGER_JSON\s*([\s\S]*?)\s*V0344_CAPTURE_LEDGER_JSON/);
  if (!match) return null;
  try { return JSON.parse(match[1]); } catch { return null; }
}

for (const file of [
  'art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend',
  'desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb',
  'art-source/blender/v0343/house02_derived_barrosan_barn_visual_preflight.blend',
  'desktop-spikes/godot-salto/assets/v0343/house02_derived_barrosan_barn_visual_preflight.glb',
  'art-source/blender/v0344/v0343_source_duplicate_for_v0344.blend',
  'art-source/blender/v0344/barn_front_granite_roof_edge_visual_preflight.blend',
  'desktop-spikes/godot-salto/assets/v0344/barn_front_granite_roof_edge_visual_preflight.glb',
  'desktop-spikes/godot-salto/scenes/review/V0344BarnFrontGraniteRoofEdgeVisualPreflight.tscn',
  'desktop-spikes/godot-salto/scripts/v0344_barn_front_granite_roof_edge_visual_preflight.gd',
  'tools/blender/generateV0344BarnFrontGraniteRoofEdgeVisualPreflight.py',
  'tools/blender/generateV0344BarnFrontGraniteRoofEdgeVisualPreflightWindows.ps1',
  'tools/godot/captureGodotV0344BarnFrontGraniteRoofEdgeVisualPreflightWindows.ps1',
  'art-source/blender/v0344/v0344-front-material-binding-ledger.json',
  'art-source/blender/v0344/v0344-barn-metrics.json',
  'art-source/blender/v0344/v0344-source-lineage.json',
  reportPath,
]) assert(exists(file), `required v0.344 file missing: ${file}`);

assert(sha256('art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend') === FROZEN_BLEND_SHA, 'frozen House02 Blend changed');
assert(sha256('desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb') === FROZEN_GLB_SHA, 'frozen House02 GLB changed');
assert(sha256('art-source/blender/v0343/house02_derived_barrosan_barn_visual_preflight.blend') === V0343_BLEND_SHA, 'v0.343 Blend changed');
assert(sha256('desktop-spikes/godot-salto/assets/v0343/house02_derived_barrosan_barn_visual_preflight.glb') === V0343_GLB_SHA, 'v0.343 GLB changed');
assert(sha256('art-source/blender/v0344/v0343_source_duplicate_for_v0344.blend') === V0343_BLEND_SHA, 'v0.344 copied v0.343 source is not byte-identical');

const lineage = readJson('art-source/blender/v0344/v0344-source-lineage.json');
assert(lineage.noV0341VisibleDependency === true && lineage.noV0342VisibleDependency === true, 'prior checkpoint dependency boundary failed');
assert(lineage.copiedV0343Source === 'art-source/blender/v0344/v0343_source_duplicate_for_v0344.blend', 'v0.344 lineage path mismatch');

const ledger = readJson('art-source/blender/v0344/v0344-front-material-binding-ledger.json');
assert(ledger.diagnosedCause?.includes('compressed default cube UV'), 'exact front UV diagnosis missing');
assert(ledger.preRepairBindings?.length > 0, 'pre-repair binding ledger is empty');
assert(ledger.postRepairContract?.principalFrontMaterialKind === 'granite' && ledger.postRepairContract?.frontTimberObjects?.length === 0, 'continuous front granite repair contract failed');
assert(ledger.postRepairContract?.coplanarFrontDuplicate === false && ledger.postRepairContract?.frontUVMap === 'V0344GraniteProjectionUV', 'front UV/no-duplicate repair contract failed');
assert(ledger.postRepairContract?.roofRepair?.includes('exactly two slate slopes'), 'roof repair contract missing');

const metrics = readJson('art-source/blender/v0344/v0344-barn-metrics.json');
assert(metrics.prototypeOnly === true && metrics.defaultRuntimeIntegrated === false, 'prototype isolation contract failed');
assert(metrics.materialSlots <= 6 && metrics.renderObjects <= 60 && metrics.drawCalls <= 35 && metrics.visibleTriangles < 60000, 'v0.344 metrics exceed sanity limits');
assert(metrics.architecture?.principalRoofSlopes === 2 && metrics.architecture?.straightRidge === true && metrics.architecture?.secondaryRoofNodes === 0 && metrics.architecture?.pedimentNodes === 0, 'exact two-slope single-ridge roof contract failed');
assert(metrics.architecture?.lowerDoubleDoor === true && metrics.architecture?.upperHayLoadingOpening === true && metrics.architecture?.rearServiceOpening === true && metrics.architecture?.terrainPedestal === false, 'opening/grounding preservation contract failed');
assert(metrics.reusedHouse02Resources?.granite && metrics.reusedHouse02Resources?.slate, 'House02 granite/slate lineage missing');
assert(metrics.texturePaths?.granite?.some((p) => p.includes('v0338')) && metrics.texturePaths?.slate?.some((p) => p.includes('v0334')), 'source material provenance missing');
assert(fs.statSync(abs('desktop-spikes/godot-salto/assets/v0344/barn_front_granite_roof_edge_visual_preflight.glb')).size < 20_000_000, 'unapproved large asset import');

const generator = read('tools/blender/generateV0344BarnFrontGraniteRoofEdgeVisualPreflight.py').toLowerCase();
const scene = read('desktop-spikes/godot-salto/scenes/review/V0344BarnFrontGraniteRoofEdgeVisualPreflight.tscn');
const script = read('desktop-spikes/godot-salto/scripts/v0344_barn_front_granite_roof_edge_visual_preflight.gd');
assert(scene.includes('[node name="V0344BarnFrontGraniteRoofEdgeVisualPreflight" type="Node3D"]'), 'scene is not isolated Node3D');
for (const token of ['generatev0341', 'generatev0342', 'warcraft', 'blizzard', 'age of empires']) assert(!generator.includes(token), `forbidden dependency/provenance token: ${token}`);
for (const token of ['move_and_slide', 'NavigationAgent', 'damage', 'projectile', 'save_game', 'resource_mutation', 'instantiate_enemy']) assert(!script.toLowerCase().includes(token.toLowerCase()), `forbidden gameplay coupling: ${token}`);
for (const token of ['V0344_Stable_Oblique_Preflight_Camera', 'PROJECTION_ORTHOGONAL', 'V0344_Frozen_House02_Unmodified_Anchor', 'V0344_Barn_Front_Granite_Roof_Edge_Candidate', '05_house02_barn_matched_true_256.png', 'Temporary_Neutral_Overcast_Diagnostic_Environment']) assert(script.includes(token), `capture/isolation contract missing: ${token}`);

const report = read(reportPath);
assert(report.includes(OUTCOME) && report.toLowerCase().includes('automated approval remains false'), 'report outcome/human gate missing');
assert(report.includes('V0344_CAPTURE_LEDGER_JSON') && report.includes('05_house02_barn_matched_true_256.png'), 'report source ledger missing');

const packageText = read('package.json');
for (const command of ['blender:generate:salto-v0344-barn-front-granite-roof-edge-visual-preflight', 'godot:capture:salto-v0344-barn-front-granite-roof-edge-visual-preflight', 'godot:validate:salto-v0344-barn-front-granite-roof-edge-visual-preflight']) assert(packageText.includes(command), `package command missing: ${command}`);

const packFiles = exists(packRoot) ? fs.readdirSync(abs(packRoot)).filter((name) => fs.statSync(abs(`${packRoot}/${name}`)).isFile()).sort() : [];
assert(JSON.stringify(packFiles) === JSON.stringify([...packNames].sort()), 'READY outcome requires exactly six upload-pack files');
assert(readJson(`${packRoot}/compact-evidence-summary.json`).exactUploadFileCount === 6, 'upload-pack compact summary count mismatch');
for (const name of packNames.filter((name) => name.endsWith('.png'))) { const info = pngInfo(`${packRoot}/${name}`); assert(info && info.bytes > 10000 && info.variance > 2, `invalid upload board: ${name}`); }

if (exists(manifestPath)) {
  const manifest = readJson(manifestPath);
  assert(manifest.checkpoint === 'v0.344' && manifest.outcome === OUTCOME && manifest.automatedVisualApproval === false, 'runtime manifest gate metadata mismatch');
  assert(manifest.captureCount === 5 && manifest.errors?.length === 0 && manifest.house02Modified === false && manifest.defaultRuntimeIntegrated === false, 'runtime capture manifest incomplete');
  for (const name of captureNames) { const info = pngInfo(`${runtime}/screenshots/${name}`); assert(info && info.bytes > 10000 && info.variance > 2, `invalid source capture: ${name}`); }
  const square = pngInfo(`${runtime}/screenshots/05_house02_barn_matched_true_256.png`); assert(square?.width === 256 && square?.height === 256, 'matched source capture is not true 256x256');
} else {
  const captured = reportLedger(); assert(captured?.captures?.length === 5, 'runtime absent and report capture ledger is incomplete');
  for (const name of captureNames) assert(captured.captures.some((item) => item.fileName === name && /^[a-f0-9]{64}$/.test(item.sha256) && item.bytes > 10000), `report capture ledger missing: ${name}`);
}

if (errors.length) {
  console.error(JSON.stringify({ status: 'FAIL_V0344_BARN_FRONT_GRANITE_ROOF_EDGE_VISUAL_PREFLIGHT', errors }, null, 2));
  process.exit(1);
}
console.log(JSON.stringify({ status: 'PASS_V0344_BARN_FRONT_GRANITE_ROOF_EDGE_VISUAL_PREFLIGHT', outcome: OUTCOME, automatedVisualApproval: false, humanReviewRequired: true, sourceCaptures: 5, uploadPackFiles: 6, prototypeOnly: true, defaultRuntimeUnchanged: true, gameplayUnchanged: true }, null, 2));
