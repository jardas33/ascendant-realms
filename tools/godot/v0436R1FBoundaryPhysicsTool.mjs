import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import {
  ACCEPTED_R1F_IMPLEMENTATION_SHA,
  REQUIRED_R1F_BRANCH,
  evaluateR1FValidatorContract,
} from './v0436R1FValidatorContract.mjs';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, 'artifacts', 'manual-review', 'v0436-r1f-boundary-recovery-physics-truth');
const v1Pack = path.join(repo, 'artifacts', 'manual-review', 'v0436-r1f-v1-retained-validator-descendant-compatibility');
const branchName = REQUIRED_R1F_BRANCH;
const exists = async file => { try { await fs.access(file); return true; } catch { return false; } };
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const isAncestor = (ancestor, descendant) => {
  try {
    execFileSync('git', ['merge-base', '--is-ancestor', ancestor, descendant], { cwd: repo, stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
};
const changedPaths = (from, to) => from && to && from !== to
  ? git(['diff', '--name-only', `${from}..${to}`]).split(/\r?\n/).filter(Boolean)
  : [];
const godot = () => process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe');
function run(args, env = {}) { execFileSync(godot(), args, { cwd: repo, stdio: 'inherit', env: { ...process.env, ...env } }); }
function envFor(index) {
  return {
    ASCENDANT_V0436_R1F_CAPTURE: '1',
    ASCENDANT_V0436_R1F_BOUNDARY_AUDIT: '1',
    ASCENDANT_V0436_R1F_RUN_INDEX: String(index).padStart(2, '0'),
    ASCENDANT_V0436_R1F_SOURCE_SHA: git(['rev-parse', 'HEAD']),
    ASCENDANT_V0436_R1F_BRANCH: git(['branch', '--show-current']),
  };
}
function focused() { run(['--headless', '--path', project, '--quit-after', '40'], envFor(1)); }
function smoke() { run(['--headless', '--path', project, '--quit-after', '30']); }
async function capture() {
  for (let index = 1; index <= 3; index += 1) {
    run(['--path', project, '--resolution', '1920x1080', '--verbose'], envFor(index));
  }
  await fs.mkdir(pack, { recursive: true });
  const runOne = path.join(pack, 'run-01');
  for (const name of ['01_R1F_FIXTURE_INITIAL_POSITION.png', '02_R1F_RECOVERY_STARTED.png', '03_R1F_RECOVERY_IN_PROGRESS.png', '04_R1F_RECOVERY_COMPLETED.png', '05_R1F_FINAL_INSIDE_BOUNDS.png', '06_R1F_CONTACT_SHEET.png']) {
    await fs.copyFile(path.join(runOne, name), path.join(pack, name));
  }
  for (const name of ['run-01-physics-steps.json', 'run-02-physics-steps.json', 'run-03-physics-steps.json']) {
    const index = name.slice(4, 6);
    await fs.copyFile(path.join(pack, `run-${index}`, name), path.join(pack, name));
  }
  await fs.writeFile(path.join(pack, 'preflight.json'), JSON.stringify({ schema: 'v0436-r1f-preflight-v2', branch: git(['branch', '--show-current']), validatedHead: git(['rev-parse', 'HEAD']), acceptedImplementationSha: ACCEPTED_R1F_IMPLEMENTATION_SHA, godot: godot(), project, no_r1c_or_conquest_capture: true }, null, 2) + '\n');
  await fs.writeFile(path.join(pack, 'wrapper-launch-contract.json'), JSON.stringify({ schema: 'v0436-r1f-wrapper-launch-contract-v1', command: 'npm run godot:capture:v0436-r1f-boundary-physics', executable: godot(), headed: true, project_default_renderer: true, godot_log_file_argument: false, runner_owned_stdout_stderr: true, three_runs: true }, null, 2) + '\n');
  await fs.writeFile(path.join(pack, 'accepted-and-rejected-evidence.json'), JSON.stringify({ schema: 'v0436-r1f-evidence-disposition-v1', accepted: ['fresh three-run physics-step audit', 'corrected no-log-file headed wrapper', 'real headed frames'], rejected: ['R1E wall-clock interval as single-frame proof', 'stale R1B runtime log dependency'], no_r1c_or_conquest_work: true }, null, 2) + '\n');
}
async function readJson(file) { return JSON.parse(await fs.readFile(file, 'utf8')); }
async function validate() {
  const failures = [];
  const branch = git(['branch', '--show-current']);
  const validatedHead = git(['rev-parse', 'HEAD']);
  const wrapper = await fs.readFile(path.join(repo, 'tools/godot/v0436R1FBoundaryPhysicsTool.mjs'), 'utf8');
  const oldWrapper = await fs.readFile(path.join(repo, 'tools/godot/v0436R1NavigationBehavioralProofTool.mjs'), 'utf8');
  const root = await fs.readFile(path.join(project, 'scripts/world/game_root.gd'), 'utf8');
  const menu = await fs.readFile(path.join(project, 'scripts/main_menu.gd'), 'utf8');
  const unit = await fs.readFile(path.join(project, 'scripts/units/unit.gd'), 'utf8');
  for (const [label, ok] of [
    ['R1F capture wiring', root.includes('ASCENDANT_V0436_R1F_CAPTURE') && root.includes('_start_v0436_r1f_capture') && menu.includes('ASCENDANT_V0436_R1F_CAPTURE')],
    ['explicit capture mapping', (await fs.readFile(path.join(project, 'tests', 'capture_bootstrap.gd'), 'utf8')).includes('"env": "ASCENDANT_V0436_R1F_CAPTURE"') && (await fs.readFile(path.join(project, 'tests', 'capture_bootstrap.gd'), 'utf8')).includes('"name": "V0436R1FCapture"')],
    ['fixture audit instrumentation', unit.includes('v0436_r1f_physics_audit_snapshot') && unit.includes('recovery_step') && unit.includes('avoidance_callback')],
    ['corrected wrapper owns output', !oldWrapper.includes('--log-file') && wrapper.includes("stdio: 'inherit'")],
    ['project default renderer', wrapper.includes("run(['--path', project, '--resolution'")],
  ]) if (!ok) failures.push(`${label} missing or invalid`);
  const runs = [];
  for (let index = 1; index <= 3; index += 1) {
    const file = path.join(pack, `run-${String(index).padStart(2, '0')}`, `run-${String(index).padStart(2, '0')}-physics-steps.json`);
    if (!(await exists(file))) { failures.push(`missing ${file}`); continue; }
    const result = await readJson(file);
    runs.push(result);
    if (result.status !== 'PASSED_V0436_R1F_BOUNDARY_PHYSICS' || result.passed !== true) failures.push(`run ${index} did not pass physics contract`);
    if (result.final_inside_bounds !== true || result.no_duplicate_movement !== true || result.contamination_free !== true || result.cleanup_result !== true || result.ai_processing_restored !== true) failures.push(`run ${index} integrity failed`);
    if (Number(result.maximum_simulation_speed) > Number(result.maximum_allowed_speed) + 0.01) failures.push(`run ${index} speed exceeded`);
    if (!Number.isFinite(Number(result.maximum_per_physics_step_displacement)) || Number(result.maximum_per_physics_step_displacement) <= 0) failures.push(`run ${index} per-physics-step displacement missing`);
    if (Number(result.maximum_movement_applications_same_frame) > 1 || (result.duplicate_movement_frames || []).length > 0) failures.push(`run ${index} duplicate movement detected`);
    if (Number(result.callbacks_that_moved_after_recovery) !== 0) failures.push(`run ${index} avoidance callback moved after recovery`);
    if (result.no_non_finite_position !== true || result.no_material_outward_drift !== true || Number(result.post_start_position_write_count) !== 0 || result.no_direct_state_writes !== true) failures.push(`run ${index} position/state integrity failed`);
  }
  const evidenceSources = [...new Set(runs.map(run => String(run.source_sha || '')).filter(Boolean))];
  const evidenceSourceSha = evidenceSources.length === 1 ? evidenceSources[0] : null;
  const contract = evaluateR1FValidatorContract({
    branch,
    validatedHead,
    acceptedImplementationIsAncestor: isAncestor(ACCEPTED_R1F_IMPLEMENTATION_SHA, validatedHead),
    runs,
    evidenceSourceIsAncestor: Boolean(evidenceSourceSha && isAncestor(evidenceSourceSha, validatedHead)),
    acceptedImplementationIsAncestorOfEvidence: Boolean(evidenceSourceSha && isAncestor(ACCEPTED_R1F_IMPLEMENTATION_SHA, evidenceSourceSha)),
    descendantChangedPaths: changedPaths(evidenceSourceSha, validatedHead),
  });
  failures.push(...contract.failures);
  const duplicate = { schema: 'v0436-r1f-duplicate-movement-audit-v1', runs: runs.map(run => ({ run_index: run.run_index, maximum_movement_applications_same_frame: run.maximum_movement_applications_same_frame, duplicate_movement_frames: run.duplicate_movement_frames, callbacks_that_moved_after_recovery: run.callbacks_that_moved_after_recovery })), passed: runs.length === 3 && runs.every(run => run.no_duplicate_movement === true) };
  await fs.mkdir(pack, { recursive: true });
  await fs.writeFile(path.join(pack, 'duplicate-movement-audit.json'), JSON.stringify(duplicate, null, 2) + '\n');
  await fs.writeFile(path.join(pack, 'timer-versus-physics-comparison.json'), JSON.stringify({ schema: 'v0436-r1f-timer-versus-physics-v1', runs: runs.map(run => ({ run_index: run.run_index, maximum_wall_clock_derived_speed: run.maximum_wall_clock_derived_speed, maximum_sampled_interval_displacement: run.maximum_sampled_interval_displacement, maximum_simulation_speed: run.maximum_simulation_speed, maximum_per_physics_step_displacement: run.maximum_per_physics_step_displacement, timer_metrics_are_diagnostic_only: run.timer_metrics_are_diagnostic_only })) }, null, 2) + '\n');
  const out = {
    schema: 'v0436-r1f-boundary-physics-validator-v2',
    branch,
    validatedHead,
    acceptedImplementationSha: ACCEPTED_R1F_IMPLEMENTATION_SHA,
    evidenceSourceSha: contract.evidenceSourceSha,
    acceptedImplementationIsAncestor: contract.acceptedImplementationIsAncestor,
    evidenceSourceIsCurrentHead: contract.evidenceSourceIsCurrentHead,
    evidenceSourceIsAncestor: contract.evidenceSourceIsAncestor,
    descendantChangedPaths: contract.descendantChangedPaths,
    descendantPathsAllowed: contract.descendantPathsAllowed,
    failures,
    passed: failures.length === 0,
    runs: runs.map(run => run.run_index),
    pack: 'artifacts/manual-review/v0436-r1f-boundary-recovery-physics-truth/',
  };
  await fs.mkdir(v1Pack, { recursive: true });
  await fs.writeFile(path.join(v1Pack, 'fresh-three-run-provenance.json'), JSON.stringify({
    schema: 'v0436-r1f-v1-fresh-three-run-provenance-v1',
    validatedHead,
    runs: runs.map(run => ({
      run_index: run.run_index,
      branch: run.branch,
      source_sha: run.source_sha,
      status: run.status,
      maximum_simulation_speed: run.maximum_simulation_speed,
      maximum_allowed_speed: run.maximum_allowed_speed,
      maximum_per_physics_step_displacement: run.maximum_per_physics_step_displacement,
      maximum_movement_applications_same_frame: run.maximum_movement_applications_same_frame,
      duplicate_movement_frames: run.duplicate_movement_frames,
      callbacks_that_moved_after_recovery: run.callbacks_that_moved_after_recovery,
      final_inside_bounds: run.final_inside_bounds,
      contamination_free: run.contamination_free,
      cleanup_result: run.cleanup_result,
    })),
  }, null, 2) + '\n');
  await fs.writeFile(path.join(v1Pack, 'fresh-validator-result.json'), JSON.stringify(out, null, 2) + '\n');
  await fs.writeFile(path.join(pack, 'final-boundary-validation.json'), JSON.stringify(out, null, 2) + '\n');
  if (failures.length) { console.error(JSON.stringify(out, null, 2)); process.exitCode = 1; } else console.log(JSON.stringify(out, null, 2));
}
const command = process.argv[2] || 'validate';
if (command === 'focused-tests') focused(); else if (command === 'smoke') smoke(); else if (command === 'capture') await capture(); else await validate();
