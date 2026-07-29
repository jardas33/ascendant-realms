import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const scene = path.join(root, 'desktop-spikes/godot-salto/scenes/v0368_playable_slice_visual_coherence.tscn');
const script = path.join(root, 'desktop-spikes/godot-salto/scripts/v0368_playable_slice_visual_coherence.gd');
const report = path.join(root, 'docs/V0368_ASCENDANT_REALMS_PLAYABLE_SLICE_VISUAL_COHERENCE_REPORT.md');
const packDir = path.join(root, 'artifacts/manual-review/v0368-playable-slice-visual-coherence');
const smokeFile = path.join(root, 'artifacts/runtime/v0368/v0368-playable-smoke.json');
const requiredPngs = ['01_POLISHED_SLICE_START.png','02_GATHERING_AND_CONSTRUCTION.png','03_COMPLETED_SETTLEMENT_AND_MILITIA.png','04_COMBAT_AND_VICTORY.png'];

function read(file) { return fs.readFileSync(file, 'utf8'); }
function assert(condition, message) { if (!condition) throw new Error(message); }
function exists(file) { assert(fs.existsSync(file), `missing ${path.relative(root, file)}`); }

function validate() {
  exists(scene); exists(script); exists(report);
  const source = read(script);
  const packageJson = read(path.join(root, 'package.json'));
  const rootScript = read(path.join(root, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd'));
  assert(source.includes('extends "res://scripts/v0367_first_playable_vertical_slice.gd"'), 'v0.367 gameplay base was not retained');
  for (const token of ['V0368_Playable_Barrosan_Hamlet','RecessedStream','RiverBankWest','RiverBankEast','BridgeDeck','BridgePlank','GoldVein','WORKER_TEXTURE','MILITIA_TEXTURE','BarracksConstructionScaffold','MOUSE_FILTER_IGNORE','_run_smoke','_run_capture']) assert(source.includes(token), `missing v0.368 contract: ${token}`);
  for (const token of ['godot:play:coherent-slice','godot:smoke:coherent-slice','godot:capture:coherent-slice','godot:validate:coherent-slice']) assert(packageJson.includes(token), `missing package command: ${token}`);
  assert(rootScript.includes('--v0368-playable') && rootScript.includes('v0368_playable_slice_visual_coherence.tscn'), 'launcher route missing');
  assert(!source.includes('NavigationAgent') && !source.includes('move_and_slide') && !source.includes('AStar'), 'generalized pathing was added');
  pack();
  console.log('PASS_V0368_PLAYABLE_SLICE_VISUAL_COHERENCE');
}

function smoke() {
  exists(smokeFile);
  const value = JSON.parse(read(smokeFile));
  assert(value.checkpoint === 'v0.368', 'smoke checkpoint mismatch');
  for (const key of ['goldDeposited','barracksBuilt','militiaRecruited','bridgeRouteIssued','combatResolved','victory','restartRestored','hudPassThrough','diagnosticLabelsHidden']) assert(value[key] === true, `smoke contract failed: ${key}`);
  assert(value.status === 'PASS' && Array.isArray(value.errors) && value.errors.length === 0, 'smoke did not pass cleanly');
  console.log('PASS_V0368_PLAYABLE_SLICE_VISUAL_COHERENCE_SMOKE');
}

function pack() {
  exists(packDir);
  const files = fs.readdirSync(packDir).filter(name => !name.startsWith('.'));
  assert(files.length === 5, `review pack must contain exactly 5 files; found ${files.length}`);
  assert(files.includes('00_READ_ME_FIRST.md'), 'review README missing');
  for (const name of requiredPngs) { const file = path.join(packDir, name); exists(file); assert(fs.statSync(file).size > 10000, `capture is too small or blank: ${name}`); }
  console.log('PASS_V0368_PLAYABLE_SLICE_VISUAL_COHERENCE_PACK');
}

const command = process.argv[2] ?? 'validate';
try { if (command === 'validate') validate(); else if (command === 'smoke') smoke(); else if (command === 'pack') pack(); else throw new Error(`unknown command ${command}`); }
catch (error) { console.error(`FAIL_V0368_PLAYABLE_SLICE_VISUAL_COHERENCE: ${error.message}`); process.exit(1); }
