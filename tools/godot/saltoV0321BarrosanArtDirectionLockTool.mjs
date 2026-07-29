import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const scene = path.join(root, 'desktop-spikes/godot-salto/visual_vertical_slice/V0321BarrosanArtDirectionLock.tscn');
const script = path.join(root, 'desktop-spikes/godot-salto/scripts/v0321_barrosan_art_direction_lock.gd');
const capture = path.join(root, 'artifacts/desktop-spikes/godot-salto/v0321/true-3d-barrosan-art-direction-lock');
const pack = path.join(root, 'artifacts/manual-review/v0321-true-3d-barrosan-art-direction-lock/UPLOAD_TO_CHAT');
const manifestPath = path.join(capture, 'v0321-barrosan-art-direction-lock-runtime.json');

function fail(message) { throw new Error(message); }
function required(file, label) { if (!fs.existsSync(file)) fail(`missing ${label}: ${file}`); }
function text(file) { return fs.readFileSync(file, 'utf8'); }
function validate() {
  required(scene, 'opt-in scene'); required(script, 'v0.321 script'); required(manifestPath, 'runtime manifest'); required(pack, 'compact review pack');
  const source = text(script);
  const sceneText = text(scene);
  for (const token of ['V0321', 'prototypeOptIn', 'V0321ActualCompactMinimap', 'HALL_MANOR', 'BARRACKS', 'STOREHOUSE_WORKSHOP', 'WORKER_DWELLING', 'V0321Granite', 'V0321PackedEarthRoad', 'V0321AnimatedRiverBelowLand', 'V0321FunctionalStoneTimberBridge', 'V0321_True3D_Worker', 'V0321_True3D_Militia', 'workerStates', 'militiaStates', 'cameraBoundaryAudit', 'continuousEvidence', 'defaultRuntimeChanged']) if (!source.includes(token)) fail(`v0.321 source missing contract token ${token}`);
  if (source.includes('Sprite3D') || source.includes('AnimatedSprite3D') || source.includes('AtlasTexture')) fail('v0.321 PLAYER source contains a 2D/sprite/atlas unit route');
  if (!sceneText.includes('V0321BarrosanArtDirectionLock')) fail('scene does not point at v0.321 benchmark');
  const manifest = JSON.parse(text(manifestPath));
  if (manifest.prototypeOptIn !== true || manifest.prototypeOnly !== true) fail('prototype is not isolated opt-in');
  if (manifest.defaultRuntimeChanged || manifest.gameplayChanged || manifest.movementChanged || manifest.pathfindingChanged || manifest.combatChanged || manifest.economyChanged || manifest.resourceChanged || manifest.stableIdsChanged || manifest.saveChanged) fail('preservation flags report mutation');
  if (manifest.billboardsUsedInPlayer !== false) fail('billboards are reported in PLAYER');
  if (manifest.camera?.projection !== 'orthographic' || manifest.camera?.ordinaryEdgeVisible !== false) fail('camera/projection boundary contract failed');
  if (manifest.architecture?.archetypes?.length !== 4) fail('four architecture identities missing');
  if (manifest.river?.belowLand !== true || manifest.bridge?.spansRiver !== true) fail('river/bridge geometry contract failed');
  if (manifest.hud?.actualMinimap !== true || manifest.hud?.selectedCardOverlap !== false || manifest.hud?.rawValidatorProse !== false) fail('PLAYER UI contract failed');
  if (manifest.variation?.stableIdDeterministic !== true) fail('deterministic variation missing');
  if (manifest.continuousEvidence?.sourceFrames !== 48) fail('continuous source frame contract failed');
  required(path.join(pack, '00_READ_ME_FIRST.md'), 'compact readme');
  const compactNames = ['01_V0141_V0319_V0320_V0321_COMPARISON.png','02_OVERVIEW_BEAUTY.png','03_ORDINARY_GAMEPLAY.png','04_TERRAIN_ROADS_RIVERBANKS.png','05_BARROSAN_ARCHITECTURE.png','06_WORKER_ART_AND_STATES.png','07_MILITIA_ART_AND_STATES.png','08_UNIT_VARIATION_AND_FORMATION.png','09_LIGHTING_MATERIALS_ATMOSPHERE.png','10_CLEAN_PLAYER_UI_AND_MINIMAP.png','11_CONTINUOUS_PLAYER_RUNTIME.gif','12_FINAL_DECISION_AND_VISUAL_SCORECARD.md','compact-evidence-summary.json'];
  for (const name of compactNames) required(path.join(pack, name), `compact evidence ${name}`);
  const files = fs.readdirSync(pack); if (files.length !== 14) fail(`compact upload must contain 14 files, got ${files.length}`);
  const gif = fs.readFileSync(path.join(pack, '11_CONTINUOUS_PLAYER_RUNTIME.gif'));
  const magic = gif.subarray(0, 6).toString('ascii'); if (magic !== 'GIF89a' && magic !== 'GIF87a') fail(`continuous media is not a GIF: ${magic}`);
  const compact = JSON.parse(text(path.join(pack, 'compact-evidence-summary.json')));
  if (compact.video?.mime !== 'image/gif' || compact.video?.frames < 40 || compact.video?.uniqueFrameHashes < 2 || compact.defaultRuntimeChanged !== false || compact.gameplayChanged !== false) fail('compact media/preservation audit failed');
  const imageNames = compactNames.filter((name) => name.endsWith('.png'));
  for (const name of imageNames) { const bytes = fs.readFileSync(path.join(pack, name)); if (bytes.length < 10000 || bytes.subarray(0, 8).toString('hex') !== '89504e470d0a1a0a') fail(`invalid rendered PNG evidence: ${name}`); }
  console.log('PASS_V0321_TRUE_3D_BARROSAN_ART_DIRECTION_LOCK_VALIDATE');
}

if (process.argv[2] === 'validate') validate(); else fail('usage: node saltoV0321BarrosanArtDirectionLockTool.mjs validate');
