import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const pack = path.join(root, 'artifacts/manual-review/v0323-structural-geometry-repair');
const upload = path.join(pack, 'UPLOAD_TO_CHAT');
const source = path.join(root, 'artifacts/desktop-spikes/godot-salto/v0323/structural-geometry-repair');
const scene = path.join(root, 'desktop-spikes/godot-salto/visual_vertical_slice/V0323StructuralGeometryRepair.tscn');
const script = path.join(root, 'desktop-spikes/godot-salto/scripts/v0323_structural_geometry_repair.gd');
const v0322Media = path.join(root, 'artifacts/manual-review/v0322-barrosan-bridge-hamlet-hero-slice/UPLOAD_TO_CHAT/08_CONTINUOUS_HERO_SLICE.mp4');
const expectedMediaSha = '8901bb6a074e5c3cc01bf5e16572f21dac06a527a4ea15273d649c71c73faa84';
const requiredUpload = ['00_READ_ME_FIRST.md','01_V0322_TO_V0323_COMPARISON.png','02_CLEAN_PLAYER_OVERVIEW.png','03_PRINCIPAL_ROOF_FRONT_AND_SIDE.png','04_SECONDARY_ROOF_FRONT_AND_SIDE.png','05_ROOF_GEOMETRY_DEBUG_AUDIT.png','06_WORLD_COVERAGE_CORNER_AUDIT.png','07_RIVERBANK_CONTINUITY.png','08_ORDINARY_GAMEPLAY.png','compact-evidence-summary.json'];
const fail = (message) => { throw new Error(`FAIL_V0323: ${message}`); };
const exists = (file) => fs.existsSync(file);
const readText = (file) => fs.readFileSync(file, 'utf8');
const readJson = (file) => JSON.parse(readText(file));
function sha(file) { return crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex'); }
function pngSize(file) { const bytes = fs.readFileSync(file); if (bytes.subarray(0, 8).toString('hex') !== '89504e470d0a1a0a') fail(`${path.basename(file)} is not PNG`); return { width: bytes.readUInt32BE(16), height: bytes.readUInt32BE(20) }; }
function audit() { if (!exists(path.join(source, 'v0323-geometry-audit.json'))) fail('runtime geometry audit missing; capture v0.323 first'); return readJson(path.join(source, 'v0323-geometry-audit.json')); }
function manifest() { if (!exists(path.join(source, 'v0323-structural-geometry-repair-runtime.json'))) fail('runtime manifest missing; capture v0.323 first'); return readJson(path.join(source, 'v0323-structural-geometry-repair-runtime.json')); }
function validateFiles() {
  if (!exists(scene) || !exists(script)) fail('v0.323 scene/script missing');
  if (!exists(upload)) fail('UPLOAD_TO_CHAT missing');
  const names = fs.readdirSync(upload).filter(name => fs.statSync(path.join(upload, name)).isFile()).sort();
  if (names.length !== 10 || names.join('|') !== requiredUpload.slice().sort().join('|')) fail(`UPLOAD_TO_CHAT must contain exactly 10 required files; got ${names.join(',')}`);
  for (const name of requiredUpload.filter(name => name.endsWith('.png'))) { const size = pngSize(path.join(upload, name)); if (size.width < 640 || size.height < 360) fail(`${name} is too small`); }
  const sourceText = readText(script);
  if (!sourceText.includes('MeshDataTool') || !sourceText.includes('global_transform')) fail('roof validator is not based on actual runtime mesh vertices/transforms');
  if (!sourceText.includes('_add_gable_roof') || !sourceText.includes('V0323ContinuousTerrainCoverage') || !sourceText.includes('V0323ConnectedRiverbanks')) fail('structural repair anchors missing');
  const hudStart = sourceText.indexOf('func _build_player_hud()');
  const captureStart = sourceText.indexOf('func _capture_all()');
  const playerHud = sourceText.slice(hudStart, captureStart);
  for (const forbidden of ['BRIDGE HAMLET', 'PRESSURE STABILIZED', 'PLAYER prototype', 'VALIDATOR', 'PROTOTYPE']) if (playerHud.includes(forbidden)) fail(`PLAYER HUD still contains ${forbidden}`);
  return { names, sourceText };
}
function validateRoof() {
  const rows = audit().roofs || [];
  if (rows.length !== 2) fail(`expected two audited roofs, got ${rows.length}`);
  for (const roof of rows) {
    if (!(roof.ridgeHeight > roof.leftEaveHeight && roof.ridgeHeight > roof.rightEaveHeight)) fail(`${roof.name} ridge is not above both eaves`);
    if (roof.minimumRoofRise < 0.65) fail(`${roof.name} roof rise ${roof.minimumRoofRise} < 0.65`);
    if (roof.upwardNormalCount < 4 || roof.invalidNormalCount !== 0) fail(`${roof.name} normals invalid: upward=${roof.upwardNormalCount}, invalid=${roof.invalidNormalCount}`);
    if (roof.selfIntersectionCount !== 0 || !roof.chimneyContact || !roof.ridgeCapContact || !roof.roofBoundsAboveWall) fail(`${roof.name} contact/topology contract failed`);
    if (roof.sampleCount < 5 || !roof.worldTransformAudited || roof.actualVertexCount < 6) fail(`${roof.name} actual mesh audit incomplete`);
  }
  return rows;
}
function validateCoverage() {
  const c = audit().terrainCoverage;
  if (c.failedViewportRays !== 0 || c.backgroundCornerMatches !== 0) fail(`coverage failures: rays=${c.failedViewportRays}, corners=${c.backgroundCornerMatches}`);
  if (c.measuredMarginPercent < 20 || c.rayGrid !== '11x7' || !c.cameraPanZoomSurvives) fail('coverage margin/grid/pan-zoom contract failed');
  if (c.terrainWidth <= c.projectedFootprintWidth || c.terrainDepth <= c.projectedFootprintDepth) fail('terrain does not exceed projected footprint');
  return c;
}
function validateRiverbank() {
  const r = audit().river;
  if (r.leftBankConnectedComponents !== 1 || r.rightBankConnectedComponents !== 1 || r.waterConnectedComponents !== 1) fail('river components are disconnected');
  if (r.maximumGapMetres >= 0.03 || r.degenerateTriangleCount !== 0 || r.invalidNormalCount !== 0 || r.terrainHoles !== 0) fail('riverbank continuity thresholds failed');
  return r;
}
function validatePlayer() {
  const m = manifest();
  if (!m.prototypeOptIn || m.defaultRuntimeChanged || m.gameplayChanged || m.playerDebugStringsFound.length !== 0) fail('PLAYER hygiene or preservation flags failed');
  const summary = readJson(path.join(upload, 'compact-evidence-summary.json'));
  if (summary.playerDebugStringsFound.length !== 0 || summary.noUnverifiedClaims === true) fail('compact evidence contains PLAYER debug strings or forbidden self-certification claim');
  return { playerDebugStringsFound: m.playerDebugStringsFound, selectedCardOverlap: m.hud.selectedCardOverlap };
}
function validateMedia() {
  if (!exists(v0322Media)) fail('accepted v0.322 MP4 missing');
  const before = sha(v0322Media); const after = sha(v0322Media);
  if (before !== expectedMediaSha || after !== expectedMediaSha || before !== after) fail(`v0.322 MP4 SHA changed: ${before}`);
  return { sha256: after, mediaUnchanged: true };
}
function validate() {
  validateFiles();
  const roofs = validateRoof();
  const coverage = validateCoverage();
  const river = validateRiverbank();
  const player = validatePlayer();
  const media = validateMedia();
  console.log(JSON.stringify({ status: 'PASS_V0323_STRUCTURAL_GEOMETRY_REPAIR', outcome: 'READY FOR HUMAN GEOMETRY REVIEW', roofs, coverage, river, player, media, compactFileCount: 10, v0322MediaUnchanged: true, defaultRuntimeUnchanged: true, gameplayUnchanged: true }, null, 2));
}
const command = process.argv[2] || 'validate';
if (command === 'validate') validate();
else if (command === 'validate-roof') { validateFiles(); console.log(JSON.stringify({ status: 'PASS_V0323_ROOF_TOPOLOGY', roofs: validateRoof() }, null, 2)); }
else if (command === 'validate-coverage') { validateFiles(); console.log(JSON.stringify({ status: 'PASS_V0323_WORLD_COVERAGE', terrainCoverage: validateCoverage() }, null, 2)); }
else if (command === 'validate-riverbank') { validateFiles(); console.log(JSON.stringify({ status: 'PASS_V0323_RIVERBANK_CONTINUITY', river: validateRiverbank() }, null, 2)); }
else if (command === 'validate-player') { validateFiles(); console.log(JSON.stringify({ status: 'PASS_V0323_PLAYER_HYGIENE', player: validatePlayer() }, null, 2)); }
else if (command === 'validate-media') console.log(JSON.stringify(validateMedia(), null, 2));
else fail(`unknown command ${command}`);
