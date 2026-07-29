import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const script = path.join(root, 'desktop-spikes/godot-salto/scripts/v0410_bridge_deck_timber_surface_readability.gd');
const scene = path.join(root, 'desktop-spikes/godot-salto/scenes/v0410_bridge_deck_timber_surface_readability.tscn');
const router = path.join(root, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = path.join(root, 'package.json');
const report = path.join(root, 'docs/V0410_BRIDGE_DECK_TIMBER_SURFACE_READABILITY_REPORT.md');
const runtime = path.join(root, 'desktop-spikes/godot-salto/artifacts/runtime/v0410');
const pack = path.join(root, 'artifacts/manual-review/v0410-bridge-deck-timber-surface-readability');
const files = [
  '01_PRIMARY_RTS_COLOUR.png', '02_BRIDGE_DECK_CLOSE_COLOUR.png',
  '03_PRIMARY_RTS_GRAYSCALE.png', '04_BRIDGE_DECK_CLOSE_GRAYSCALE.png',
  '05_BRIDGE_DECK_MATERIAL_DIAGNOSTIC.png', '06_V0409_V0410_WIDE_COMPARISON.png',
  '07_V0409_V0410_BRIDGE_DECK_CLOSE_COMPARISON.png', 'v0410-preservation-audit.json'
];
const planks = Array.from({ length: 18 }, (_, i) => `Bridge_Deck_Plank_${String(i).padStart(2, '0')}`);
const forbidden = ['move_and_slide', 'NavigationAgent', 'pathfinding', 'route_follow', 'attack', 'damage', 'hit_points', 'economy', 'production_queue', 'spawn_unit', 'add_building', 'queue_free', 'combat', 'construct_building', 'new_geometry', 'BoxMesh.new'];
const must = (condition, message) => { if (!condition) throw new Error(`FAIL_V0410: ${message}`); };
const read = file => fs.readFileSync(file, 'utf8');
const png = file => { const bytes = fs.readFileSync(file); must(bytes.readUInt32BE(0) === 0x89504e47, `not PNG: ${file}`); return { width: bytes.readUInt32BE(16), height: bytes.readUInt32BE(20), bytes: bytes.length }; };

function validate() {
  for (const [file, label] of [[script, 'script'], [scene, 'scene'], [router, 'router'], [pkg, 'package'], [report, 'report']]) must(fs.existsSync(file), `${label} missing`);
  const g = read(script), r = read(router), p = read(pkg), d = read(report);
  for (const token of ['v0409_secondary_barn_roof_surface_readability.gd', 'V0410_CHECKPOINT', 'V0410_TIMBER_TEXTURE', 'V0410_Bridge_Weathered_Timber_Deck', 'materialOnly', 'uvArraysChanged', 'Bridge_Deck_Plank_00', 'Bridge_Deck_Plank_17', 'ASSET_UV_LIMITATION_BRIDGE_DECK', 'rails', 'posts', 'supports', 'abutments', 'footings']) must(g.includes(token), `script contract missing: ${token}`);
  for (const token of ['--v0410-bridge-deck-capture', '--v0410-bridge-deck-smoke', 'v0410_bridge_deck_timber_surface_readability.gd']) must(r.includes(token), `router contract missing: ${token}`);
  for (const token of ['godot:play:v0410-bridge-deck-timber', 'godot:smoke:v0410-bridge-deck-timber', 'godot:capture:v0410-bridge-deck-timber', 'godot:validate:v0410-bridge-deck-timber']) must(p.includes(token), `package command missing: ${token}`);
  for (const token of ['v0.409', 'material-only', 'deck', 'timber', 'UV', 'rails', 'posts', 'supports', 'abutments', 'grayscale', 'default runtime']) must(d.toLowerCase().includes(token.toLowerCase()), `report evidence missing: ${token}`);
  for (const plank of planks) must(g.includes(plank), `deck plank contract missing: ${plank}`);
  for (const file of files) {
    const runtimeFile = path.join(runtime, file), packFile = path.join(pack, file);
    must(fs.existsSync(runtimeFile), `runtime evidence missing: ${file}`);
    must(fs.existsSync(packFile), `review pack evidence missing: ${file}`);
    if (file.endsWith('.png')) { const image = png(runtimeFile); must(image.width === (file.startsWith('06_') || file.startsWith('07_') ? 3840 : 1920) && image.height === 1080 && image.bytes > 10000, `invalid capture: ${file}`); }
  }
  must(!forbidden.some(token => g.toLowerCase().includes(token.toLowerCase())), 'forbidden gameplay or replacement-geometry token in script');
  const audit = JSON.parse(read(path.join(runtime, 'v0410-preservation-audit.json')));
  must(['RENDERED_CANDIDATE', 'ASSET_UV_LIMITATION_BRIDGE_DECK'].includes(audit.status), `audit status ${audit.status}`);
  must(audit.materialOnly === true && audit.geometryChanged === false && audit.uvArraysChanged === false, 'material-only preservation failed');
  must(audit.topologyChanged === false && audit.indicesChanged === false && audit.verticesChanged === false && audit.transformsChanged === false && audit.aabbChanged === false, 'mesh preservation failed');
  must(audit.newGeometry === false && audit.duplicateMeshes === false && audit.duplicateSurfaces === false && audit.overlays === false && audit.decals === false, 'duplicate/overlay contract failed');
  must(audit.gameplay === false && audit.defaultRuntime === 'unchanged' && audit.fallbackRenderer === 'unchanged' && audit.debugRenderer === 'unchanged', 'runtime preservation failed');
  if (audit.status === 'RENDERED_CANDIDATE') {
    must(audit.candidateRetained === true && audit.deckPlankCount === 18, 'rendered deck candidate must retain all 18 existing planks');
    for (const entry of audit.deckMeshInventory) must(entry.uvCount > 0, `retained deck plank has no UV arrays: ${entry.name}`);
    console.log('PASS_V0410_BRIDGE_DECK_TIMBER_SURFACE_READABILITY_VALIDATOR (material-only candidate; 18 existing deck planks; UV-preserving; 7 real captures)');
  } else {
    must(audit.candidateRetained === false, 'UV limitation must retain no candidate');
    must(String(audit.reason).toLowerCase().includes('no usable authored uv') || String(audit.reason).toLowerCase().includes('missing'), 'UV limitation reason must identify missing usable asset support');
    console.log('PASS_V0410_BRIDGE_DECK_TIMBER_SURFACE_READABILITY_VALIDATOR (fail-closed ASSET_UV_LIMITATION_BRIDGE_DECK; no candidate retained; diagnostic evidence preserved)');
  }
}

if (process.argv[2] !== 'validate') throw new Error('usage: node tools/godot/saltoV0410BridgeDeckTimberSurfaceReadabilityTool.mjs validate');
validate();
