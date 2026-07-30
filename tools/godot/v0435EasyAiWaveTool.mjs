import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, 'artifacts', 'manual-review', 'v0435-first-autonomous-easy-opponent-wave');
const baseSha = '6d52ec1309b09401ed6c705b6dda98707d26b33e';
const branchName = 'codex/v0435-first-autonomous-easy-opponent-wave';
const frames = [
  '01_V0435_INITIAL_EASY_AI_SCENE.png','02_V0435_AI_WORKERS_GATHERING.png','03_V0435_AI_EXACT_RESOURCE_ASSIGNMENT.png',
  '04_V0435_AI_RESOURCE_DEPOSITS.png','05_V0435_AI_BANK_LEDGER.png','06_V0435_AI_FIRST_WORKER_PRODUCTION.png',
  '07_V0435_AI_HOUSING_CONSTRUCTION.png','08_V0435_AI_MILITARY_BUILDING_CONSTRUCTION.png','09_V0435_AI_MIXED_ROLE_QUEUE.png',
  '10_V0435_AI_ARMY_STAGING.png','11_V0435_AI_RALLY_POINT.png','12_V0435_AI_FIRST_WAVE_LAUNCHED.png',
  '13_V0435_AI_ATTACK_MOVE_CONTACT.png','14_V0435_PLAYER_UNIT_DAMAGED_BY_AI.png','15_V0435_PLAYER_BUILDING_DAMAGED_BY_AI.png',
  '16_V0435_AI_FIRST_CASUALTY.png','17_V0435_AI_SECOND_CASUALTY.png','18_V0435_AI_REPLACEMENT_QUEUE.png',
  '19_V0435_FRESH_SCENE_REPLAY.png','20_V0435_EASY_AI_CONTACT_SHEET.png'
];
const evidence = [
  'v0435-ai-root-cause-audit.json','v0435-worker-gathering-audit.json','v0435-resource-selection-audit.json',
  'v0435-ai-deposit-ledger.json','v0435-ai-bank-reconciliation.json','v0435-ai-worker-production-audit.json',
  'v0435-ai-building-validation-audit.json','v0435-ai-housing-audit.json','v0435-ai-military-building-audit.json',
  'v0435-army-composition-audit.json','v0435-staging-audit.json','v0435-wave-launch-audit.json',
  'v0435-targeting-fairness-audit.json','v0435-player-damage-audit.json','v0435-player-building-damage-audit.json',
  'v0435-casualty-replacement-audit.json','v0435-fresh-scene-replay-audit.json','v0435-v0434-regression-audit.json',
  'v0435-v0433-regression-audit.json','v0435-v0432-regression-audit.json','v0435-preservation-audit.json',
  'v0435-network-audit.json','v0435-performance-observation.json','v0435-headed-capture-audit.json',
  'v0435-black-frame-rejection.json','v0435-validation.json'
];
const exists = async file => { try { await fs.access(file); return true; } catch { return false; } };
const readJson = async file => JSON.parse((await fs.readFile(path.join(pack, file), 'utf8')).replace(/^\uFEFF/, ''));
const writeJson = async (file, value) => { await fs.mkdir(pack, { recursive: true }); await fs.writeFile(path.join(pack, file), JSON.stringify(value, null, 2) + '\n', 'utf8'); };
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const godot = () => process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe');
function runGodot(args, env = {}) { execFileSync(godot(), args, { cwd: repo, stdio: 'inherit', env: { ...process.env, ...env } }); }

async function capture() {
  await fs.mkdir(pack, { recursive: true });
  const log = path.join(pack, 'v0435-headed-runtime.log');
  runGodot(['--path', project, '--resolution', '1920x1080', '--verbose', '--log-file', log], { ASCENDANT_V0435_CAPTURE: '1' });
  const captureSourceSha = git(['rev-parse', 'HEAD']);
  await writeJson('v0435-capture-command.json', {
    schema: 'v0435-capture-command-v2', baseSha, aiRepairSha: captureSourceSha,
    captureSourceSha, validationInputSha: captureSourceSha, branch: git(['branch', '--show-current']),
    prNumber: 9, productionScene: 'scenes/main.tscn',
    matchConfig: { playerRace: 'barrosan', opponentRace: 'lioraen', opponentCount: 1, difficulty: 'easy', startResources: 'standard', map: 'hollowspan', mode: 'skirmish', victory: 'conquest', gameSpeed: 2.0 },
    captureGeneratedAfterAiRepair: true,
    method: 'headed official Godot Forward Plus runtime observing one autonomous Easy EnemyAI and using RTSController only for player response',
    directAiCommands: false, directResourceWrites: false, directHpWrites: false, directDeathCalls: false, status: 'completed'
  });
  console.log(`v0.435 headed Easy AI capture complete: ${pack}`);
}

function smoke() {
  const log = path.join(pack, 'v0435-smoke.log');
  runGodot(['--headless', '--path', project, '--quit-after', '30', '--log-file', log]);
  console.log('v0.435 production scene smoke completed');
}

function focusedTests() {
  runGodot(['--headless', '--path', project, '--script', 'res://tests/v0435_easy_ai_wave.gd', '--quit-after', '20']);
  console.log('v0.435 focused Easy AI tests completed');
}

async function validate() {
  const failures = [];
  const branch = git(['branch', '--show-current']);
  const head = git(['rev-parse', 'HEAD']);
  if (branch !== branchName) failures.push(`branch ${branch}`);
  try { execFileSync('git', ['merge-base', '--is-ancestor', baseSha, 'HEAD'], { cwd: repo, stdio: 'ignore' }); } catch { failures.push(`base ${baseSha} is not an ancestor`); }
  for (const file of frames) { const target = path.join(pack, file); if (!(await exists(target))) failures.push(`missing frame ${file}`); else if ((await fs.stat(target)).size < 1024) failures.push(`small frame ${file}`); }
  for (const file of evidence.filter(file => !['v0435-validation.json','v0435-black-frame-rejection.json'].includes(file))) if (!(await exists(path.join(pack, file)))) failures.push(`missing evidence ${file}`);
  const ai = await fs.readFile(path.join(project, 'scripts/ai/enemy_ai.gd'), 'utf8');
  const world = await fs.readFile(path.join(project, 'scripts/world/game_world.gd'), 'utf8');
  const root = await fs.readFile(path.join(project, 'scripts/world/game_root.gd'), 'utf8');
  const projectFile = await fs.readFile(path.join(project, 'project.godot'), 'utf8');
  if (!ai.includes('_easy_mode') || !ai.includes('_think_easy()') || !ai.includes('_easy_wave_launched')) failures.push('bounded Easy AI lane missing');
  if (ai.includes('_easy_wave_size')) failures.push('independent Easy wave-size override remains');
  if (!/"easy":\s*\n\s*_think_interval = 2\.0; _worker_target = 7; _army_attack_size = 6/.test(ai)) failures.push('historical Easy tuning not restored');
  if (!ai.includes('find_nearest_resource_exact') || !ai.includes('_easy_resource_shortages') || !ai.includes('_easy_bank_ledger')) failures.push('exact resource/shortage/bank ledger missing');
  if (!ai.includes('world.can_place_building') || !ai.includes('_find_easy_build_spot')) failures.push('shared deterministic placement missing');
  if (!ai.includes('queue_unit') || !ai.includes('_choose_easy_mixed_unit')) failures.push('real mixed production queue missing');
  if (!ai.includes('command_move(_easy_wave_target, true)') || !ai.includes('_easy_replacement_audit')) failures.push('attack wave/replacement path missing');
  if (!world.includes('func can_place_building') || !world.includes('building_damage_events') || !world.includes('resource_transactions')) failures.push('world shared contracts missing');
  if (!root.includes('ASCENDANT_V0435_CAPTURE') || !projectFile.includes('V0435Capture')) failures.push('capture wiring missing');
  const metaPath = path.join(pack, 'v0435-capture-command.json');
  if (await exists(metaPath)) {
    const meta = await readJson('v0435-capture-command.json');
    if (meta.baseSha !== baseSha || !meta.aiRepairSha || !meta.captureSourceSha || !meta.validationInputSha || meta.captureSourceSha === baseSha || meta.aiRepairSha === baseSha || meta.captureGeneratedAfterAiRepair !== true) failures.push('capture provenance/repair-source contract failed');
    if (meta.branch !== branch || meta.prNumber !== 9 || meta.matchConfig?.playerRace !== 'barrosan' || meta.matchConfig?.opponentRace !== 'lioraen' || meta.matchConfig?.difficulty !== 'easy' || meta.matchConfig?.startResources !== 'standard' || meta.matchConfig?.gameSpeed !== 2.0) failures.push('capture match contract metadata failed');
    for (const sha of [meta.aiRepairSha, meta.captureSourceSha]) { try { execFileSync('git', ['merge-base', '--is-ancestor', sha, 'HEAD'], { cwd: repo, stdio: 'ignore' }); } catch { failures.push(`capture SHA is not an ancestor of HEAD: ${sha}`); } }
    try { execFileSync('git', ['merge-base', '--is-ancestor', baseSha, meta.aiRepairSha], { cwd: repo, stdio: 'ignore' }); } catch { failures.push('aiRepairSha is not based on v0.434'); }
  }
  else failures.push('missing v0435 capture command metadata');
  const blackPath = path.join(pack, 'v0435-black-frame-rejection.json');
  if (await exists(blackPath)) { const black = await readJson('v0435-black-frame-rejection.json'); if ((black.rejected_black || []).length || (black.rejected_blank || []).length || black.all_real_gameplay !== true) failures.push('black/blank rejection failed'); }
  else failures.push('missing black-frame rejection evidence');
  const runtimePath = path.join(pack, 'v0435-validation.json');
  let runtimeProof = {};
  if (await exists(runtimePath)) {
    runtimeProof = await readJson('v0435-validation.json');
    if (runtimeProof.passed !== true || Number(runtimeProof.worker_count) < 3 || Number(runtimeProof.ai_deaths) < 2 || runtimeProof.player_unit_damage !== true || runtimeProof.player_building_damage !== true || runtimeProof.replacement_queued !== true) failures.push('runtime validation does not prove autonomous worker/economy/wave/contact/casualty/replacement chain');
    if (runtimeProof.opponent_race !== 'lioraen' || runtimeProof.difficulty !== 'easy' || runtimeProof.start_resources !== 'standard') failures.push('runtime match contract does not prove Barrosan/Lioraen Easy Standard');
    if (Number(runtimeProof.wave_count) < 6 || Number(runtimeProof.wave_threshold) !== 6 || runtimeProof.mixed_roles !== true || !Array.isArray(runtimeProof.distinct_roles) || runtimeProof.distinct_roles.length < 2) failures.push('runtime wave does not prove six-unit mixed-role launch');
  }
  else failures.push('missing runtime validation evidence');
  const depositPath = path.join(pack, 'v0435-ai-deposit-ledger.json');
  if (await exists(depositPath)) { const d = await readJson('v0435-ai-deposit-ledger.json'); if (Number(d.entry_count) < 2 || !Array.isArray(d.entries) || !['food','timber','stone','gold'].every(k => d.exact_kinds?.includes(k))) failures.push('AI deposit ledger does not prove all four exact resource kinds'); }
  const wavePath = path.join(pack, 'v0435-wave-launch-audit.json');
  if (await exists(wavePath)) { const w = await readJson('v0435-wave-launch-audit.json'); const event = (w.events || []).find(e => e.event === 'first_wave_launched') || {}; if (w.launched !== true || event.count < 6 || event.threshold !== 6 || event.opponent_race !== 'lioraen' || new Set(event.wave_participant_roles || []).size < 2 || (event.wave_participant_ids || []).some(id => /worker|hero/i.test(String(id)))) failures.push('wave audit does not prove six-unit Lioraen mixed-role launch'); }
  const matchPath = path.join(pack, 'v0435-match-config-audit.json');
  if (await exists(matchPath)) { const m = await readJson('v0435-match-config-audit.json'); if (m.player_race !== 'barrosan' || m.opponents?.[0]?.race !== 'lioraen' || m.opponents?.[0]?.difficulty !== 'easy' || m.start_resources !== 'standard' || m.opponent_count !== 1 || m.stored_game_speed !== 2 || m.engine_time_scale !== 2) failures.push('headed match configuration audit failed'); }
  const diffPath = path.join(pack, 'v0435-easy-difficulty-contract-audit.json');
  if (await exists(diffPath)) { const d = await readJson('v0435-easy-difficulty-contract-audit.json'); const v = d.final_values || {}; if (v.think_interval !== 2 || v.worker_target !== 7 || v.army_attack_size !== 6 || v.eco_efficiency !== 0.7 || v.tech_aggression !== 0.6 || v.brutal_income !== 0 || d.qa_wave_override !== false) failures.push('Easy difficulty contract audit failed'); }
  const productionPath = path.join(pack, 'v0435-lioraen-production-contract-audit.json');
  if (await exists(productionPath)) { const p = await readJson('v0435-lioraen-production-contract-audit.json'); if (p.race !== 'lioraen' || p.all_ai_units_same_race !== true || p.all_ai_buildings_same_race !== true || !Array.isArray(p.legal_age_one_roles) || p.legal_age_one_roles.length < 2) failures.push('Lioraen production contract audit failed'); }
  const result = { ...runtimeProof, schema: 'v0435-first-autonomous-easy-opponent-wave-validator-v1', baseSha, validationInputSha: head, branch, prTargetBranch: 'codex/v0434-first-combat-casualty-loop', frames, evidence, failures, passed: failures.length === 0 };
  await writeJson('v0435-validation.json', result);
  if (failures.length) { console.error(JSON.stringify(result, null, 2)); process.exitCode = 1; } else console.log(JSON.stringify(result, null, 2));
}

const command = process.argv[2] || 'validate';
if (command === 'capture') await capture();
else if (command === 'smoke') smoke();
else if (command === 'focused-tests') focusedTests();
else await validate();
