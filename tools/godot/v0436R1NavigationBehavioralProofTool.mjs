import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, 'artifacts', 'manual-review', 'v0436-r1a-navigation-behavioral-proof');
const baseSha = '9e9312560bccd1c04aee8ff39f8677074c30b10f';
const branchName = 'codex/v0436-first-complete-conquest-victory';
const frames = [
  '01_PRODUCTION_MATCH_INITIAL_STATE.png', '02_NAVIGATION_MAP_READY.png',
  '03_WORKER_CONSTRUCTION_COMMAND_ISSUED.png', '04_WORKER_CONSTRUCTION_TRAVELLING.png',
  '05_WORKER_INSIDE_BUILD_RANGE.png', '06_REAL_CONSTRUCTION_PROGRESS.png',
  '07_COMPLETED_WAR_HALL.png', '08_WORKER_GATHERING.png',
  '09_WORKER_CARRYING_RESOURCES.png', '10_WORKER_RETURNING.png',
  '11_REAL_DEPOSIT_COMPLETED.png', '12_MILITARY_MOVE_UNDERWAY.png',
  '13_MILITARY_MOVE_ARRIVED.png', '14_GROUP_ATTACK_MOVE_BEGINNING.png',
  '15_GROUP_CROSSING_BATTLEFIELD.png', '16_ENEMY_CONTACT.png',
  '17_MOVING_TARGET_PURSUIT.png', '18_INVALID_TARGET_TERMINAL_FAILURE.png',
  '19_BOUNDARY_RECOVERY_UNDERWAY.png', '20_BOUNDARY_RECOVERY_COMPLETE.png',
  '21_FINAL_BOUNDED_UNIT_OVERVIEW.png', '22_NAVIGATION_BEHAVIORAL_CONTACT_SHEET.png',
];
const exists = async p => { try { await fs.access(p); return true; } catch { return false; } };
const read = p => fs.readFile(p, 'utf8');
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const godot = () => process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe');
function run(args, env = {}) { execFileSync(godot(), args, { cwd: repo, stdio: 'inherit', env: { ...process.env, ...env } }); }
function focused() { run(['--headless', '--path', project, '--script', 'res://tests/v0436_navigation_repair.gd', '--quit-after', '20']); }
function smoke() { run(['--headless', '--path', project, '--quit-after', '30', '--log-file', path.join(pack, 'v0436-r1a-navigation-smoke.log')]); }
function capture() { run(['--path', project, '--resolution', '1920x1080', '--rendering-method', 'gl_compatibility', '--verbose', '--log-file', path.join(pack, 'v0436-r1a-navigation-runtime.log')], { ASCENDANT_V0436_R1_CAPTURE: '1' }); }
async function validate() {
  const failures = [];
  const branch = git(['branch', '--show-current']);
  const head = git(['rev-parse', 'HEAD']);
  if (branch !== branchName) failures.push(`branch ${branch}`);
  try { execFileSync('git', ['merge-base', '--is-ancestor', baseSha, 'HEAD'], { cwd: repo, stdio: 'ignore' }); } catch { failures.push(`base ${baseSha} is not an ancestor`); }
  const root = await read(path.join(project, 'scripts/world/game_root.gd'));
  const menu = await read(path.join(project, 'scripts/main_menu.gd'));
  const projectFile = await read(path.join(project, 'project.godot'));
  const proof = await read(path.join(project, 'tests/v0436_r1_navigation_behavioral_proof.gd'));
  for (const [label, ok] of [
    ['opt-in main-menu wiring', menu.includes('ASCENDANT_V0436_R1_CAPTURE')],
    ['opt-in runtime wiring', root.includes('ASCENDANT_V0436_R1_CAPTURE') && root.includes('_start_v0436_r1_capture')],
    ['autoload wiring', projectFile.includes('V0436R1Capture=')],
    ['real command API proof', proof.includes('command_move') && proof.includes('command_build') && proof.includes('command_gather') && proof.includes('issue_attack_move_destination') && proof.includes('issue_attack_target')],
    ['no direct state writes', proof.includes('no_direct_state_writes')],
    ['bounded no-conquest scope', proof.includes('no_full_conquest_capture')],
    ['durable backlog', await exists(path.join(repo, 'docs', 'ASCENDANT_REALMS_MASTER_PLAYER_EXPERIENCE_BACKLOG.md'))],
  ]) if (!ok) failures.push(`${label} missing`);
  const proofPath = path.join(pack, 'v0436-r1a-navigation-behavioral-proof.json');
  let result = null;
  if (!(await exists(proofPath))) failures.push('missing behavioral proof JSON');
  else {
    result = JSON.parse(await read(proofPath));
    if (result.status !== 'PASSED_NAVIGATION_BEHAVIORAL_PROOF') failures.push(`runtime status ${result.status}`);
    for (const kind of ['navigation_ready_before_commands', 'ordinary_move_arrival', 'worker_inside_build_range', 'worker_construction_completion', 'worker_gather_and_return', 'attack_move_progress', 'bounded_pursuit_progress', 'invalid_target_terminal_failure', 'boundary_recovery']) {
      const event = (result.events || []).find(e => e.kind === kind);
      if (!event) failures.push(`missing behavioral event: ${kind}`);
      else if (kind !== 'boundary_recovery' && event.passed !== true) failures.push(`behavior not proven: ${kind}`);
    }
    if (result.no_full_conquest_capture !== true || result.no_direct_state_writes !== true) failures.push('scope flags invalid');
  }
  for (const frame of frames) if (!(await exists(path.join(pack, frame)))) failures.push(`missing evidence ${frame}`);
  const out = {
    schema: 'v0436-r1a-navigation-behavioral-validator-v2', baseSha, validationInputSha: head, branch,
    runtimeStatus: result?.status || null, failures, passed: failures.length === 0,
    evidence: frames, pack: 'artifacts/manual-review/v0436-r1a-navigation-behavioral-proof/',
    report: 'docs/V0436_R1A_NAVIGATION_BEHAVIORAL_PROOF_REPORT.md',
  };
  await fs.mkdir(pack, { recursive: true });
  await fs.writeFile(path.join(pack, 'v0436-r1a-navigation-behavioral-validation.json'), JSON.stringify(out, null, 2) + '\n');
  if (failures.length) { console.error(JSON.stringify(out, null, 2)); process.exitCode = 1; } else console.log(JSON.stringify(out, null, 2));
}
const command = process.argv[2] || 'validate';
if (command === 'focused-tests') focused(); else if (command === 'smoke') smoke(); else if (command === 'capture') capture(); else await validate();
