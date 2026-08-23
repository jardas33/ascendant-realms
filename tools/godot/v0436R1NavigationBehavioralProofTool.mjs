import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, 'artifacts', 'manual-review', 'v0436-r1a-navigation-behavioral-proof');
const baseSha = 'ed7a66a05d8d7750ba5f8e7f0d4124c6eb40c2b2';
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
function smoke() { run(['--headless', '--path', project, '--quit-after', '30']); }
function capture() {
  run(['--path', project, '--resolution', '1920x1080', '--verbose'], {
    ASCENDANT_V0436_R1_CAPTURE: '1',
    ASCENDANT_V0436_R1_SOURCE_SHA: git(['rev-parse', 'HEAD']),
    ASCENDANT_V0436_R1_BRANCH: git(['branch', '--show-current']),
  });
}
function boundaryTests() {
  run(['--path', project, '--resolution', '1920x1080', '--verbose'], {
    ASCENDANT_V0436_R1_CAPTURE: '1',
    ASCENDANT_V0436_R1_BOUNDARY_ONLY: '1',
    ASCENDANT_V0436_R1F_BOUNDARY_AUDIT: '1',
    ASCENDANT_V0436_R1_SOURCE_SHA: git(['rev-parse', 'HEAD']),
    ASCENDANT_V0436_R1_BRANCH: git(['branch', '--show-current']),
  });
}
async function validate() {
  const failures = [];
  const branch = git(['branch', '--show-current']);
  const head = git(['rev-parse', 'HEAD']);
  const acceptedSourceShas = new Set([head, baseSha]);
  if (branch !== branchName) failures.push(`branch ${branch}`);
  try { execFileSync('git', ['merge-base', '--is-ancestor', baseSha, 'HEAD'], { cwd: repo, stdio: 'ignore' }); } catch { failures.push(`base ${baseSha} is not an ancestor`); }
  const root = await read(path.join(project, 'scripts/world/game_root.gd'));
  const menu = await read(path.join(project, 'scripts/main_menu.gd'));
  const projectFile = await read(path.join(project, 'project.godot'));
  const captureBootstrap = await read(path.join(project, 'tests/capture_bootstrap.gd'));
  const proof = await read(path.join(project, 'tests/v0436_r1_navigation_behavioral_proof.gd'));
  const unit = await read(path.join(project, 'scripts/units/unit.gd'));
  for (const [label, ok] of [
    ['opt-in main-menu wiring', menu.includes('ASCENDANT_V0436_R1_CAPTURE')],
    ['opt-in runtime wiring', root.includes('ASCENDANT_V0436_R1_CAPTURE') && root.includes('_start_v0436_r1_capture')],
    ['explicit capture mapping', captureBootstrap.includes('"env": "ASCENDANT_V0436_R1_CAPTURE"') && captureBootstrap.includes('"name": "V0436R1Capture"')],
    ['real command API proof', proof.includes('command_move') && proof.includes('command_build') && proof.includes('command_gather') && proof.includes('issue_attack_move_destination') && proof.includes('issue_attack_target')],
    ['no direct state writes', proof.includes('no_direct_state_writes')],
    ['bounded no-conquest scope', proof.includes('no_full_conquest_capture')],
    ['isolated real-unit fixture', proof.includes('pre_tree_real_unit_under_dedicated_navigation_region_container') && proof.includes('ASCENDANT_V0436_R1_BOUNDARY_ONLY')],
    ['production recovery path retained', unit.includes('_begin_boundary_recovery') && unit.includes('_state_boundary_recovery') && unit.includes('boundary_recovery_started') && unit.includes('boundary_recovery_completed')],
    ['durable backlog', await exists(path.join(repo, 'docs', 'ASCENDANT_REALMS_MASTER_PLAYER_EXPERIENCE_BACKLOG.md'))],
  ]) if (!ok) failures.push(`${label} missing`);
  const proofPath = path.join(pack, 'v0436-r1a-navigation-behavioral-proof.json');
  const boundaryPath = path.join(pack, 'v0436-r1b-boundary-recovery-proof.json');
  let result = null;
  if (!(await exists(proofPath))) failures.push('missing behavioral proof JSON');
  else {
    result = JSON.parse(await read(proofPath));
    if (result.status !== 'PASSED_NAVIGATION_BEHAVIORAL_PROOF') failures.push(`runtime status ${result.status}`);
    if (!acceptedSourceShas.has(result.source_sha)) failures.push(`source SHA ${result.source_sha} is neither validation HEAD ${head} nor required base ${baseSha}`);
    for (const kind of ['navigation_ready_before_commands', 'ordinary_move_arrival', 'worker_inside_build_range', 'worker_construction_completion', 'worker_gather_and_return', 'attack_move_progress', 'bounded_pursuit_progress', 'invalid_target_terminal_failure', 'boundary_recovery']) {
      const event = (result.events || []).find(e => e.kind === kind);
      if (!event) failures.push(`missing behavioral event: ${kind}`);
      else if (kind !== 'boundary_recovery' && event.passed !== true) failures.push(`behavior not proven: ${kind}`);
    }
    if (result.no_full_conquest_capture !== true || result.no_direct_state_writes !== true) failures.push('scope flags invalid');
  }
  if (!(await exists(boundaryPath))) failures.push('missing R1B boundary proof JSON');
  else {
    const boundaryResult = JSON.parse(await read(boundaryPath));
    const boundary = boundaryResult.boundary || boundaryResult;
    if (boundaryResult.status !== 'PASSED_NAVIGATION_BEHAVIORAL_PROOF') failures.push(`boundary runtime status ${boundaryResult.status}`);
    if (!acceptedSourceShas.has(boundaryResult.source_sha)) failures.push(`boundary source SHA ${boundaryResult.source_sha} is neither validation HEAD ${head} nor required base ${baseSha}`);
    for (const [label, ok] of [
      ['fixture present', boundary.fixture_present === true],
      ['one initial transform assignment', boundary.initial_transform_assignment_count === 1],
      ['zero post-start position writes', boundary.post_start_position_write_count === 0],
      ['initial position outside trigger threshold', Number(boundary.initial_outside_distance) > Number(boundary.recovery_tolerance)],
      ['recovery started event', boundary.recovery_started === true && boundary.recovery_started_event?.kind === 'boundary_recovery_started'],
      ['progressive movement samples', Array.isArray(boundary.samples) && boundary.samples.length >= 3 && Number(boundary.travelled_distance) > 0],
      ['speed within contract', Number(boundary.maximum_sampled_speed) <= Number(boundary.maximum_allowed_speed)],
      ['no teleport displacement', Number(boundary.maximum_single_frame_displacement) <= Number(boundary.maximum_allowed_single_frame_displacement)],
      ['no non-finite position', boundary.no_non_finite_position === true],
      ['no material outward drift', boundary.no_material_outward_drift === true],
      ['recovery completed event', boundary.recovery_completed === true && boundary.recovery_completed_event?.kind === 'boundary_recovery_completed'],
      ['final position in bounds', boundary.final_inside_bounds === true],
      ['no terminal failure', boundary.terminal_failure === false],
      ['no fixture contamination', boundary.contamination_free === true],
      ['fixture cleanup', boundary.cleanup_result === true],
    ]) if (!ok) failures.push(`boundary ${label} failed`);
  }
  for (const frame of frames) if (!(await exists(path.join(pack, frame)))) failures.push(`missing evidence ${frame}`);
  for (const frame of ['19_BOUNDARY_RECOVERY_UNDERWAY.png', '20_BOUNDARY_RECOVERY_COMPLETE.png']) {
    const stat = await fs.stat(path.join(pack, frame)).catch(() => null);
    if (!stat || stat.size < 4096) failures.push(`boundary evidence ${frame} is blank or too small`);
  }
  const out = {
    schema: 'v0436-r1b-navigation-behavioral-validator-v1', baseSha, validationInputSha: head, acceptedSourceShas: [...acceptedSourceShas], branch,
    runtimeStatus: result?.status || null, failures, passed: failures.length === 0,
    evidence: frames, pack: 'artifacts/manual-review/v0436-r1a-navigation-behavioral-proof/',
    report: 'docs/V0436_R1B_BOUNDARY_RECOVERY_PROOF_REPORT.md',
  };
  await fs.mkdir(pack, { recursive: true });
  await fs.writeFile(path.join(pack, 'v0436-r1a-navigation-behavioral-validation.json'), JSON.stringify(out, null, 2) + '\n');
  if (failures.length) { console.error(JSON.stringify(out, null, 2)); process.exitCode = 1; } else console.log(JSON.stringify(out, null, 2));
}
async function legacyDiagnose() {
  const boundaryPath = path.join(pack, 'v0436-r1b-boundary-recovery-proof.json');
  const boundary = JSON.parse(await read(boundaryPath));
  const result = {
    schema: 'v0436-r1b-legacy-timer-diagnostic-v1',
    status: 'HISTORICAL_R1E_TIMER_CONTRACT_FALSE_POSITIVE',
    source_sha: boundary.source_sha,
    branch: boundary.branch,
    diagnostic_only: true,
    active_gate: false,
    reason: 'Legacy timer intervals are retained as historical evidence and are not physics-frame acceptance.',
    legacy_metrics: {
      maximum_sampled_speed: boundary.boundary?.maximum_sampled_speed ?? boundary.maximum_sampled_speed,
      maximum_single_frame_displacement: boundary.boundary?.maximum_single_frame_displacement ?? boundary.maximum_single_frame_displacement,
      maximum_allowed_speed: boundary.boundary?.maximum_allowed_speed ?? boundary.maximum_allowed_speed,
      maximum_allowed_single_frame_displacement: boundary.boundary?.maximum_allowed_single_frame_displacement ?? boundary.maximum_allowed_single_frame_displacement,
    },
  };
  await fs.writeFile(path.join(pack, 'v0436-r1b-legacy-timer-diagnostic.json'), JSON.stringify(result, null, 2) + '\n');
  console.log(JSON.stringify(result, null, 2));
}
const command = process.argv[2] || 'validate';
if (command === 'focused-tests') focused(); else if (command === 'boundary-tests') boundaryTests(); else if (command === 'smoke') smoke(); else if (command === 'capture') capture(); else if (command === 'legacy-diagnose') await legacyDiagnose(); else await validate();
