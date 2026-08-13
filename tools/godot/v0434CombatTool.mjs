import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, 'artifacts', 'manual-review', 'v0434-first-combat-casualty-loop');
const baseSha = '3b09035fc1001acd423801d46c557852daec8f70';
const branchName = 'codex/v0434-first-combat-casualty-loop';
const allowedBranches = new Set([branchName, 'codex/golden-s1-core-godot']);
const frames = [
  '01_V0434_INITIAL_REAL_SKIRMISH.png','02_V0434_WAR_HALL_CRAG_ARCHER_QUEUE.png','03_V0434_CRAG_ARCHER_SPAWNED.png',
  '04_V0434_PLAYER_SQUAD_SELECTED.png','05_V0434_ENCOUNTER_APPROACH.png','06_V0434_DIRECT_ATTACK_ORDER.png',
  '07_V0434_SPEARS_MELEE_CONTACT.png','08_V0434_CRAG_ARCHER_ARROW_IN_FLIGHT.png','09_V0434_LIORAEN_THORN_RETURN_FIRE.png',
  '10_V0434_DAMAGED_UNIT_HEALTH_BARS.png','11_V0434_FIRST_ENEMY_CASUALTY.png','12_V0434_ARCHER_PROJECTILE_KILL.png',
  '13_V0434_RANGED_KILL_ATTRIBUTION.png','14_V0434_MELEE_KILL_ATTRIBUTION.png','15_V0434_ATTACK_MOVE_ORDER.png',
  '16_V0434_ATTACK_MOVE_ENGAGEMENT.png','17_V0434_ATTACK_MOVE_RESUMED_DESTINATION.png','18_V0434_STOP_ORDER_CLEARED.png',
  '19_V0434_FRESH_SCENE_COMBAT_REPLAY.png','20_V0434_COMBAT_LOOP_CONTACT_SHEET.png'
];
const evidence = [
  'v0434-combat-root-cause-audit.json','v0434-direct-attack-input-audit.json','v0434-target-validation-audit.json',
  'v0434-melee-range-audit.json','v0434-projectile-source-audit.json','v0434-damage-formula-audit.json',
  'v0434-health-presentation-audit.json','v0434-ranged-kill-audit.json','v0434-melee-kill-audit.json',
  'v0434-death-cleanup-audit.json','v0434-selection-cleanup-audit.json','v0434-population-roster-audit.json',
  'v0434-attack-move-resume-audit.json','v0434-stop-order-audit.json','v0434-fresh-scene-replay-audit.json',
  'v0434-v0433-regression-audit.json','v0434-preservation-audit.json','v0434-network-audit.json',
  'v0434-performance-observation.json','v0434-headed-capture-audit.json','v0434-runtime-combat-audit.json','v0434-black-frame-rejection.json','v0434-validation.json'
];
const exists = async file => { try { await fs.access(file); return true; } catch { return false; } };
const read = async file => JSON.parse((await fs.readFile(path.join(pack, file), 'utf8')).replace(/^\uFEFF/, ''));
const write = async (file, value) => { await fs.mkdir(pack, { recursive: true }); await fs.writeFile(path.join(pack, file), JSON.stringify(value, null, 2) + '\n', 'utf8'); };
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const ancestor = (older, newer) => { try { execFileSync('git', ['merge-base', '--is-ancestor', older, newer], { cwd: repo, stdio: 'ignore' }); return true; } catch { return false; } };
const godot = () => process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe');

function runGodot(args, env = {}) {
  execFileSync(godot(), args, { cwd: repo, stdio: 'inherit', env: { ...process.env, ...env } });
}

async function capture() {
  await fs.mkdir(pack, { recursive: true });
  const log = path.join(pack, 'v0434-headed-runtime.log');
  runGodot(['--path', project, '--resolution', '1920x1080', '--verbose', '--log-file', log], { ASCENDANT_V0434_CAPTURE: '1' });
  await write('v0434-capture-command.json', { schema: 'v0434-capture-command-v1', baseSha, captureSourceSha: git(['rev-parse', 'HEAD']), productionScene: 'scenes/main.tscn', method: 'headed official Godot Forward Plus runtime using real RTSController commands, real War Hall production and real unit combat', executable: godot(), captureGeneratedAfterCombatRepair: true, status: 'completed' });
  console.log(`v0.434 headed combat capture complete: ${pack}`);
}

function smoke() {
  const log = path.join(pack, 'v0434-smoke.log');
  runGodot(['--headless', '--path', project, '--quit-after', '30', '--log-file', log]);
  console.log('v0.434 production scene smoke completed');
}

function focusedTests() {
  runGodot(['--headless', '--path', project, '--script', 'res://tests/v0434_combat_unit_test.gd', '--quit-after', '20']);
  console.log('v0.434 focused combat tests completed');
}

async function validate() {
  const failures = [];
  const branch = git(['branch', '--show-current']);
  const head = git(['rev-parse', 'HEAD']);
  const v0435Continuation = branch === 'codex/v0435-first-autonomous-easy-opponent-wave';
  if (!allowedBranches.has(branch) && !v0435Continuation) failures.push(`branch ${branch}`);
  try { execFileSync('git', ['merge-base', '--is-ancestor', baseSha, 'HEAD'], { cwd: repo, stdio: 'ignore' }); } catch { failures.push(`base ${baseSha} is not an ancestor`); }
  for (const file of frames) {
    const target = path.join(pack, file);
    if (!(await exists(target))) failures.push(`missing frame ${file}`);
    else if ((await fs.stat(target)).size < 1024) failures.push(`small frame ${file}`);
  }
  for (const file of evidence.filter(file => file !== 'v0434-validation.json')) if (!(await exists(path.join(pack, file)))) failures.push(`missing evidence ${file}`);
  const unit = await fs.readFile(path.join(project, 'scripts/units/unit.gd'), 'utf8');
  const projectile = await fs.readFile(path.join(project, 'scripts/units/projectile.gd'), 'utf8');
  const world = await fs.readFile(path.join(project, 'scripts/world/game_world.gd'), 'utf8');
  const rts = await fs.readFile(path.join(project, 'scripts/world/rts_controller.gd'), 'utf8');
  const root = await fs.readFile(path.join(project, 'scripts/world/game_root.gd'), 'utf8');
  const projectFile = await fs.readFile(path.join(project, 'project.godot'), 'utf8');
  if (!unit.includes('_can_attack_target') || !unit.includes('_attack_move_ordered') || !unit.includes('distance_to(tgt.global_position) <= _engage_range() + 0.15')) failures.push('target validation/attack-move/melee range repair missing');
  if (!unit.includes('_last_damage_source_team') || !unit.includes('_build_health_bar')) failures.push('damage attribution/health presentation missing');
  if (!projectile.includes('source_unit_id') || !projectile.includes('source_team') || !projectile.includes('projectile_kind')) failures.push('projectile source provenance missing');
  if (!world.includes('source_payload') || !world.includes('combat_kill_events') || !world.includes('source_team == player_team')) failures.push('combat attribution/kill credit missing');
  if (!rts.includes('issue_attack_target') || !rts.includes('issue_attack_move_destination') || !rts.includes('issue_stop')) failures.push('public RTS combat command path missing');
  if (!root.includes('ASCENDANT_V0434_CAPTURE') || !projectFile.includes('V0434Capture')) failures.push('v0434 capture wiring missing');
  if (await exists(path.join(pack, 'v0434-capture-command.json'))) {
    const captureMeta = await read('v0434-capture-command.json');
    if ((!v0435Continuation && captureMeta.captureSourceSha !== head) || (v0435Continuation && !ancestor(captureMeta.captureSourceSha, head)) || captureMeta.captureGeneratedAfterCombatRepair !== true) failures.push('capture provenance mismatch');
  }
  if (await exists(path.join(pack, 'v0434-black-frame-rejection.json'))) {
    const black = await read('v0434-black-frame-rejection.json');
    if ((black.rejected_black || []).length || (black.rejected_blank || []).length || black.all_real_gameplay !== true) failures.push('black/blank frame rejection audit is non-empty or capture is not real gameplay');
  }
  if (await exists(path.join(pack, 'v0434-runtime-combat-audit.json'))) {
    const runtime = await read('v0434-runtime-combat-audit.json');
    if (runtime.passed !== true || Number(runtime.damage_event_count) < 3 || Number(runtime.death_event_count) < 3 || Number(runtime.player_kill_count) < 3) failures.push('runtime combat audit does not prove real damage, casualties, and player kill credit');
  } else failures.push('missing runtime combat audit');
  if (await exists(path.join(pack, 'v0434-damage-formula-audit.json'))) {
    const damage = await read('v0434-damage-formula-audit.json');
    if (damage.passed !== true || !Array.isArray(damage.events) || damage.events.length < 3) failures.push('damage formula audit has no real event list');
  }
  if (await exists(path.join(pack, 'v0434-death-cleanup-audit.json'))) {
    const death = await read('v0434-death-cleanup-audit.json');
    if (death.exactly_once !== true || Number(death.death_count) < 3 || !Array.isArray(death.death_events) || death.death_events.length < 3) failures.push('death cleanup audit does not prove exact casualty records');
  }
  if (await exists(path.join(pack, 'v0434-ranged-kill-audit.json'))) {
    const ranged = await read('v0434-ranged-kill-audit.json');
    if (ranged.credited !== true || Number(ranged.kill_count) < 1) failures.push('ranged kill audit has no credited kill');
  }
  if (await exists(path.join(pack, 'v0434-melee-kill-audit.json'))) {
    const melee = await read('v0434-melee-kill-audit.json');
    if (melee.credited !== true || Number(melee.kill_count) < 1) failures.push('melee kill audit has no credited kill');
  }
  const result = { schema: 'v0434-first-real-combat-validator-v1', baseSha, combatRepairSha: git(['log', '-1', '--format=%H', '--', 'production/ascendant-realms-godot/scripts/units/unit.gd']), captureSourceSha: head, validationInputSha: head, branch, prNumber: 8, frames, evidence, failures, passed: failures.length === 0 };
  await write('v0434-validation.json', result);
  if (failures.length) { console.error(JSON.stringify(result, null, 2)); process.exitCode = 1; } else console.log(JSON.stringify(result, null, 2));
}

const command = process.argv[2] || 'validate';
if (command === 'capture') await capture();
else if (command === 'smoke') smoke();
else if (command === 'focused-tests') focusedTests();
else await validate();
