import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, 'artifacts', 'manual-review', 'v0433-multi-resource-worker-economy-loop');
const baseSha = 'eb6485805c06ecf7bb92a616ff16de95c0dead5c';
const branchName = 'codex/v0433-multi-resource-worker-economy-loop';
const frames = [
  '01_V0433_INITIAL_BANK_AND_WORKERS.png','02_V0433_TIMBER_WORKER_ASSIGNED.png','03_V0433_STONE_WORKER_ASSIGNED.png',
  '04_V0433_FOOD_WORKER_ASSIGNED.png','05_V0433_WORKERS_GATHERING_CONCURRENTLY.png','06_V0433_WORKER_CARRY_10_OF_10.png',
  '07_V0433_TIMBER_RETURNING.png','08_V0433_TIMBER_DEPOSIT_BANK_UPDATED.png','09_V0433_STONE_DEPOSIT_BANK_UPDATED.png',
  '10_V0433_FOOD_CARRIED_GOLD_SWITCH_REQUESTED.png','11_V0433_FOOD_DEPOSIT_BEFORE_SWITCH.png',
  '12_V0433_WORKER_GATHERING_GOLD_AFTER_SWITCH.png','13_V0433_GOLD_DEPOSIT_BANK_UPDATED.png','14_V0433_PAUSED_GATHERING_STATE.png',
  '15_V0433_UNPAUSED_GATHERING_RESUMED.png','16_V0433_MULTI_WORKER_SAME_NODE_AUDIT.png','17_V0433_SHARED_BANK_SPEND_RESULT.png',
  '18_V0433_FRESH_SCENE_TIMBER_REPLAY.png','19_V0433_V0432_REGRESSION_PRESERVATION.png','20_V0433_ECONOMY_LOOP_CONTACT_SHEET.png'
];
const evidence = [
  'v0433-economy-root-cause-audit.json','v0433-resource-definition-audit.json','v0433-input-command-audit.json',
  'v0433-worker-state-transition-audit.json','v0433-carry-capacity-audit.json','v0433-resource-switch-audit.json',
  'v0433-deposit-transaction-audit.json','v0433-multi-worker-concurrency-audit.json','v0433-depletion-edge-case-audit.json',
  'v0433-dropoff-failure-audit.json','v0433-pause-audit.json','v0433-shared-bank-spend-audit.json',
  'v0433-fresh-scene-replay-audit.json','v0433-v0432-regression-audit.json','v0433-preservation-audit.json',
  'v0433-network-audit.json','v0433-performance-observation.json','v0433-headed-capture-audit.json',
  'v0433-black-frame-rejection.json','v0433-luminance-comparison.json','v0433-capture-command.json'
];
const exists = async file => { try { await fs.access(file); return true; } catch { return false; } };
const readJson = async name => JSON.parse((await fs.readFile(path.join(pack, name), 'utf8')).replace(/^\uFEFF/, ''));
const writeJson = async (name, value) => { await fs.mkdir(pack, { recursive: true }); await fs.writeFile(path.join(pack, name), JSON.stringify(value, null, 2) + '\n', 'utf8'); };
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const ancestor = (older, newer) => { try { execFileSync('git', ['merge-base', '--is-ancestor', older, newer], { cwd: repo, stdio: 'ignore' }); return true; } catch { return false; } };

const failures = [];
const branch = git(['branch', '--show-current']);
const head = git(['rev-parse', 'HEAD']);
if (branch !== branchName) failures.push(`branch ${branch}`);
if (!ancestor(baseSha, head)) failures.push(`base ${baseSha} is not an ancestor`);

for (const frame of frames) {
  const file = path.join(pack, frame);
  if (!(await exists(file))) failures.push(`missing frame ${frame}`);
  else if ((await fs.stat(file)).size < 1024) failures.push(`small frame ${frame}`);
}
for (const file of evidence) if (!(await exists(path.join(pack, file)))) failures.push(`missing evidence ${file}`);

const unit = await fs.readFile(path.join(project, 'scripts/units/unit.gd'), 'utf8');
const node = await fs.readFile(path.join(project, 'scripts/world/resource_node.gd'), 'utf8');
const world = await fs.readFile(path.join(project, 'scripts/world/game_world.gd'), 'utf8');
const root = await fs.readFile(path.join(project, 'scripts/world/game_root.gd'), 'utf8');
const hud = await fs.readFile(path.join(project, 'scripts/ui/hud.gd'), 'utf8');
const map = await fs.readFile(path.join(project, 'scripts/world/map_defs.gd'), 'utf8');
const mainMenu = await fs.readFile(path.join(project, 'scripts/main_menu.gd'), 'utf8');
const projectFile = await fs.readFile(path.join(project, 'project.godot'), 'utf8');
if (!unit.includes('remaining_capacity') || !unit.includes('_pending_gather_node') || !unit.includes('get_economy_text')) failures.push('worker economy repair missing');
if (!node.includes('depleted_once') || !node.includes('min(max(0, per_tick)')) failures.push('ResourceNode exact depletion guard missing');
if (!world.includes('find_nearest_resource_exact') || !world.includes('record_resource_deposit') || !world.includes('is_resource_command_valid')) failures.push('world economy audit/dropoff helpers missing');
if (!root.includes('ASCENDANT_V0433_CAPTURE') || !projectFile.includes('V0433Capture') || !mainMenu.includes('ASCENDANT_V0433_CAPTURE')) failures.push('v0433 headed capture wiring missing');
if (!map.includes('"kind": "food"') || !map.includes('c + toward * 3.0 - side * 15.0')) failures.push('reachable food node missing from starting clusters');
if (!hud.includes('get_economy_text')) failures.push('selected worker economy panel missing');

const defs = await readJson('v0433-resource-definition-audit.json');
if (JSON.stringify(defs.resource_types) !== JSON.stringify(['food', 'timber', 'stone', 'gold']) || defs.carry_max !== 10) failures.push('resource definition audit failed');
const input = await readJson('v0433-input-command-audit.json');
if (input.right_click_path_used !== true || input.timber !== true || input.stone !== true || input.food !== true || input.workers < 3) failures.push('real initial resource command audit failed');
const cap = await readJson('v0433-carry-capacity-audit.json');
if (cap.all_within_capacity !== true || (cap.extractions || []).some(x => x.granted > x.capacity)) failures.push('carry capacity audit failed');
const sw = await readJson('v0433-resource-switch-audit.json');
if (sw.food_to_gold !== true || sw.food_preserved !== true || sw.gold_gathered_after_food_deposit !== true || sw.gold_deposited_after_food_deposit !== true) failures.push('resource switch audit failed');
const dep = await readJson('v0433-deposit-transaction-audit.json');
if (dep.no_duplicate_deposit !== true || dep.no_negative_bank !== true || !['food', 'timber', 'stone', 'gold'].every(kind => (dep.transactions || []).some(x => x.kind === kind))) failures.push('deposit transaction audit failed');
const pause = await readJson('v0433-pause-audit.json');
if (pause.extraction_stopped !== true || pause.resumed !== true) failures.push('pause audit failed');
const spend = await readJson('v0433-shared-bank-spend-audit.json');
if (spend.same_live_commander_bank !== true || spend.placement_used_real_path !== true) failures.push('shared bank spend audit failed');
const replay = await readJson('v0433-fresh-scene-replay-audit.json');
if (replay.command_ok !== true || replay.deposit_count < 1 || replay.stale_cargo !== false) failures.push('fresh scene replay audit failed');
const luminance = await readJson('v0433-luminance-comparison.json');
if (!Array.isArray(luminance) || luminance.some(x => x.nonBlack !== true || x.meaningfulVariance !== true)) failures.push('black/low-variance frame detected');
const capture = await readJson('v0433-capture-command.json');
if (!ancestor(capture.captureSourceSha, head) || !ancestor(baseSha, capture.captureSourceSha) || !capture.method.includes('real worker right-click')) failures.push('capture provenance/method mismatch');

const result = { schema: 'v0433-multi-resource-worker-economy-validator-v2', baseSha, finalCommitSha: head, captureSourceSha: capture.captureSourceSha, branch, frames, evidence, failures, passed: failures.length === 0 };
await writeJson('v0433-validation.json', result);
if (failures.length) { console.error(JSON.stringify(result, null, 2)); process.exitCode = 1; }
else console.log(JSON.stringify(result, null, 2));
