import fs from 'node:fs/promises';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync, spawnSync } from 'node:child_process';
import crypto from 'node:crypto';
import { R1K_CELLS, R1K_CELL_CONTRACT, R1K_IMPLEMENTATION_STATUS, R1K_PACK, REQUIRED_R1K_BRANCH, evaluateR1KValidatorContract, evaluateR1KStageA2Diagnostic, spacingPairPasses } from './v0436R1KControlledCombatMatrixValidator.mjs';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, R1K_PACK);
const stageA2Pack = path.join(pack, 'diagnostics', 'stage-a2-compact-spacing-settlement');
const stageA2ReplacementPack = path.join(pack, 'diagnostics', 'stage-a2-compact-spacing-settlement-replacement-1');
const stageA2BPack = path.join(pack, 'diagnostics', 'stage-a2-compact-spacing-settlement-replacement-2');
const stageA2OutputProbePack = path.join(pack, 'diagnostics', 'stage-a2-output-routing-probe');
const captureScript = path.join(repo, 'production', 'ascendant-realms-godot', 'tests', 'v0436_r1k_capture.gd');
const godot = () => process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe');
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const sourceSha = () => git(['rev-parse', 'HEAD']);
const branch = () => git(['branch', '--show-current']);
const exists = async file => { try { await fs.access(file); return true; } catch { return false; } };
const readJson = async file => JSON.parse(await fs.readFile(file, 'utf8'));
const writeJson = async (file, value) => { await fs.mkdir(path.dirname(file), { recursive: true }); await fs.writeFile(file, `${JSON.stringify(value, null, 2)}\n`, 'utf8'); };
const sha256 = file => crypto.createHash('sha256').update(readFileSync(file)).digest('hex');
const diffBinaryHash = () => crypto.createHash('sha256').update(execFileSync('git', ['diff', '--binary', '--', ...r1kHarnessFiles], { cwd: repo, maxBuffer: 64 * 1024 * 1024 })).digest('hex');
const r1kHarnessFiles = [
  'package.json',
  'production/ascendant-realms-godot/tests/v0436_r1k_capture.gd',
  'tools/godot/v0436R1KControlledCombatMatrixTool.mjs',
  'tools/godot/v0436R1KControlledCombatMatrixValidator.mjs',
  'tools/godot/v0436R1KControlledCombatMatrixValidator.test.ts',
  'tools/godot/v0436R1KStageA2Validator.test.ts',
];
const requiredStageA2BPNGs = ['01_STAGE_A2B_START.png', '02_STAGE_A2B_DESTINATIONS_ASSIGNED.png', '03_STAGE_A2B_ARRIVAL_HOLD_PROVEN.png', '04_STAGE_A2B_PUBLIC_STOP_ISSUED.png', '05_STAGE_A2B_POST_STOP_MEASUREMENT.png'];
const pathInside = (root, file) => {
  const relative = path.relative(root, file);
  return relative !== '' && !relative.startsWith(`..${path.sep}`) && !path.isAbsolute(relative);
};

const CELL_DEFINITIONS = Object.freeze([
  { cell_id: R1K_CELLS[0], selected_force: 'hero-plus-spear-guard', spacing: 'wide', spacing_comparable: true, command_path: 'direct-target', target_order: 'thorn-ranger-first', target: 'thorn-ranger' },
  { cell_id: R1K_CELLS[1], selected_force: 'hero-plus-spear-guard', spacing: 'compact', spacing_comparable: true, command_path: 'direct-target', target_order: 'thorn-ranger-first', target: 'thorn-ranger' },
  { cell_id: R1K_CELLS[2], selected_force: 'hero-plus-spear-guard', spacing: 'wide', spacing_comparable: true, command_path: 'direct-target', target_order: 'hero-warden-first', target: 'hero-warden' },
  { cell_id: R1K_CELLS[3], selected_force: 'hero-plus-spear-guard', spacing: 'compact', spacing_comparable: true, command_path: 'direct-target', target_order: 'hero-warden-first', target: 'hero-warden' },
  { cell_id: R1K_CELLS[4], selected_force: 'full-prepared-force', spacing: 'wide', spacing_comparable: true, command_path: 'direct-target', target_order: 'hero-warden-first', target: 'hero-warden' },
  { cell_id: R1K_CELLS[5], selected_force: 'full-prepared-force', spacing: 'wide', spacing_comparable: true, command_path: 'direct-target', target_order: 'thorn-ranger-first', target: 'thorn-ranger' },
  { cell_id: R1K_CELLS[6], selected_force: 'hero-only', spacing: 'not_applicable', spacing_comparable: false, command_path: 'direct-target', target_order: 'thorn-ranger-control', target: 'thorn-ranger' },
  { cell_id: R1K_CELLS[7], selected_force: 'hero-only', spacing: 'not_applicable', spacing_comparable: false, command_path: 'attack-move-then-target', target_order: 'thorn-ranger-control', target: 'thorn-ranger' },
].map(cell => ({ ...cell, repetitions_required: 2, diagnosis_only: true, direct_state_writes: false })));

function launchEnv(cell, repetition) {
  const sha = sourceSha();
  return {
    ...process.env,
    ASCENDANT_V0436_R1K_CAPTURE: '1',
    ASCENDANT_V0436_R1J_CAPTURE: '1',
    ASCENDANT_V0436_R1K_SOURCE_SHA: sha,
    ASCENDANT_V0436_R1K_BRANCH: branch(),
    ASCENDANT_V0436_R1J_SOURCE_SHA: sha,
    ASCENDANT_V0436_R1J_BRANCH: branch(),
    ASCENDANT_V0436_R1K_CELL: cell.cell_id,
    ASCENDANT_V0436_R1K_REPETITION: String(repetition),
    ASCENDANT_V0436_R1K_OUT: path.join(pack, cell.cell_id, `rep-${repetition}`),
  };
}

function launch(cell, repetition) {
  const sessionDir = path.join(pack, cell.cell_id, `rep-${repetition}`);
  return execFileSync(godot(), ['--path', project, '--resolution', '1920x1080', '--verbose'], { cwd: sessionDir, stdio: 'inherit', env: launchEnv(cell, repetition) });
}

function metricTemplate() {
  return { survival: null, time_to_terminal: null, damage_dealt: null, damage_received: null, successful_attacks: null, cancelled_attacks: null, projectiles_launched: null, projectiles_impacted: null, misses_or_invalidations: null, attack_uptime: null, movement_time: null, legal_in_range_time: null, in_range_not_attacking: null, collision_blocked: null, no_valid_path: null, transitions: null, effective_dps: null, expected_vs_observed: null, final_hp: null, death_attribution: null };
}

function plannedMatrix() {
  return { schema: 'v0436-r1k-controlled-combat-variable-isolation-matrix-v2', mode: 'diagnosis-only', direct_state_writes: false, cells: CELL_DEFINITIONS.map(cell => ({ ...cell, repetitions: [1, 2].map(repetition => ({ repetition, status: 'planned', metrics: metricTemplate() })) })), natural_confirmation: { sessions: 0, status: 'not-run' }, comparability_audit: { passed: false, status: 'not-run', spacing_pairs_checked: 0, spacing_pairs_passed: 0 } };
}

function sourceAudit() {
  return { schema: 'v0436-r1k-source-audit-v1', true_default_runtime_unchanged: true, no_direct_state_writes: true, no_resource_injection: true, no_free_units: true, accepted_chain_untouched: true, production_repair_made: false, stable_ids_and_saves_untouched: true, historical_reference_non_runtime: true, protected_assets_imported: false, forbidden_gameplay_mutation: false, instrumentation: 'opt-in capture branch only; reuses existing read-only R1J event hooks' };
}

async function capture() {
  await fs.mkdir(pack, { recursive: true });
  await writeJson(path.join(pack, 'preflight.json'), { schema: 'v0436-r1k-preflight-v1', status: 'CAPTURE_STARTED', source_sha: sourceSha(), branch: branch(), headed: true, hidden_window: false, godot_log_file_argument: false, production_scene: 'scenes/main.tscn -> scenes/game_world.tscn', true_default_runtime_unchanged: true, no_direct_state_writes: true, no_resource_injection: true, no_free_units: true });
  await writeJson(path.join(pack, 'matrix-definition.json'), plannedMatrix());
  await writeJson(path.join(pack, 'implementation-contract.json'), { schema: 'v0436-r1k-implementation-contract-v1', source_sha: sourceSha(), branch: branch(), source_audit: sourceAudit(), status: R1K_IMPLEMENTATION_STATUS });
  for (const cell of CELL_DEFINITIONS) {
    for (const repetition of [1, 2]) {
      await fs.mkdir(path.join(pack, cell.cell_id, `rep-${repetition}`), { recursive: true });
      launch(cell, repetition);
    }
  }
  await writeJson(path.join(pack, 'capture-manifest.json'), { schema: 'v0436-r1k-capture-manifest-v1', status: 'CAPTURE_COMPLETED', source_sha: sourceSha(), branch: branch(), cells: R1K_CELLS, repetitions_per_cell: 2, historical_evidence_reused: false });
}

async function captureOne(cellId, repetition) {
  const cell = CELL_DEFINITIONS.find(candidate => candidate.cell_id === cellId);
  if (!cell) throw new Error(`unknown R1K cell: ${cellId}`);
  await fs.mkdir(path.join(pack, cellId, `rep-${repetition}`), { recursive: true });
  launch(cell, repetition);
}

function pngDimensions(file) {
  const bytes = readFileSync(file);
  if (bytes.length < 24 || bytes.toString('ascii', 1, 4) !== 'PNG') return null;
  return { width: bytes.readUInt32BE(16), height: bytes.readUInt32BE(20) };
}

async function collectStageA2Artifacts(root) {
  const entries = [];
  async function visit(dir) {
    for (const entry of await fs.readdir(dir, { withFileTypes: true })) {
      const absolute = path.join(dir, entry.name);
      if (entry.isDirectory()) await visit(absolute);
      else if (/\.(png|json)$/i.test(entry.name)) {
        const stat = await fs.stat(absolute);
        entries.push({ relative_path: path.relative(root, absolute).replaceAll(path.sep, '/'), absolute_path: absolute, kind: entry.name.toLowerCase().endsWith('.png') ? 'png' : 'json', bytes: stat.size, sha256: sha256(absolute), dimensions: entry.name.toLowerCase().endsWith('.png') ? pngDimensions(absolute) : null, nonblank_candidate: stat.size > 1024 });
      }
    }
  }
  await visit(root);
  return entries.sort((a, b) => a.relative_path.localeCompare(b.relative_path));
}

async function collectManifestFiles(root, writerRecords = []) {
  const artifacts = await collectStageA2Artifacts(root);
  const recordByAbsolutePath = new Map(writerRecords.map(record => [path.resolve(record.absolute_path), record]));
  return artifacts.map(file => {
    const writer = recordByAbsolutePath.get(path.resolve(file.absolute_path));
    const relative = file.relative_path;
    return {
      ...file,
      absolute_path: path.resolve(file.absolute_path),
      inside_authorized_output_root: pathInside(root, path.resolve(file.absolute_path)),
      writer_return_code: writer?.writer_return_code ?? 'NODE_OK',
      exists: writer?.exists ?? true,
      readable: writer?.readable ?? (file.kind === 'png' ? Boolean(file.dimensions) : file.bytes > 0),
      generated_before_replacement_2: relative === 'stage-a2b-preflight.json',
      generated_during_replacement_2: relative !== 'stage-a2b-preflight.json',
    };
  });
}

function runChild(args, cwd, env) {
  const result = spawnSync(godot(), args, { cwd, env, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });
  return { status: result.status, signal: result.signal, stdout: result.stdout || '', stderr: result.stderr || '', error: result.error ? String(result.error) : null };
}

async function runStageA2OutputProbe(sha, branchName, localDiffHash) {
  if (await exists(stageA2OutputProbePack) && (await fs.readdir(stageA2OutputProbePack)).length > 0) throw new Error(`output-routing probe directory is not empty: ${stageA2OutputProbePack}`);
  await fs.mkdir(stageA2OutputProbePack, { recursive: true });
  const absoluteRoot = path.resolve(stageA2OutputProbePack);
  const child = runChild(['--headless', '--path', project, '--verbose'], repo, {
    ...process.env,
    ASCENDANT_V0436_R1K_CAPTURE: '1',
    ASCENDANT_V0436_R1J_CAPTURE: '1',
    ASCENDANT_V0436_R1K_STAGE_A2B: '1',
    ASCENDANT_V0436_R1K_OUTPUT_PROBE: '1',
    ASCENDANT_V0436_R1K_OUTPUT_ROOT_ABS: absoluteRoot,
    ASCENDANT_V0436_R1K_REPO_ROOT_ABS: repo,
    ASCENDANT_V0436_R1K_SOURCE_SHA: sha,
    ASCENDANT_V0436_R1K_BRANCH: branchName,
    ASCENDANT_V0436_R1J_SOURCE_SHA: sha,
    ASCENDANT_V0436_R1J_BRANCH: branchName,
    ASCENDANT_V0436_R1K_LOCAL_DIFF_SHA256: localDiffHash,
  });
  const files = await collectManifestFiles(stageA2OutputProbePack);
  const passed = child.status === 0 && !/Can't save PNG|SCRIPT ERROR|ERROR: Can't save PNG/i.test(`${child.stdout}\n${child.stderr}`) && files.some(file => file.relative_path === 'probe.png' && file.kind === 'png' && file.bytes > 0 && file.dimensions && file.readable && file.inside_authorized_output_root) && files.some(file => file.relative_path === 'probe.json' && file.bytes > 0 && file.readable && file.inside_authorized_output_root);
  const result = { schema: 'v0436-r1k-stage-a2-output-routing-probe-v1', status: passed ? 'PROBE_PASSED' : 'BLOCKED_R1K_STAGE_A2_OUTPUT_ROUTING_PROBE', source_sha: sha, branch: branchName, absolute_root: absoluteRoot, child_exit_code: child.status, signal: child.signal, files, stdout_tail: child.stdout.slice(-4000), stderr_tail: child.stderr.slice(-4000), local_git_diff_binary_sha256: localDiffHash, passed };
  await writeJson(path.join(stageA2OutputProbePack, 'stage-a2-output-routing-probe-result.json'), result);
  if (!passed) throw new Error(`Stage-A.2b output-routing probe failed: ${JSON.stringify(result)}`);
  return result;
}

async function captureStageA2() {
  if (branch() !== REQUIRED_R1K_BRANCH) throw new Error(`Stage-A.2b requires branch ${REQUIRED_R1K_BRANCH}`);
  if (await exists(stageA2BPack) && (await fs.readdir(stageA2BPack)).length > 0) throw new Error(`Stage-A.2b replacement output already exists: ${stageA2BPack}; refusing to overwrite evidence`);
  await fs.mkdir(stageA2BPack, { recursive: true });
  const sha = sourceSha();
  const branchName = branch();
  const localDiffHash = diffBinaryHash();
  const absoluteRoot = path.resolve(stageA2BPack);
  const cell = { cell_id: 'hero-spear-compact-thorn-ranger-first', selected_force: 'hero-plus-spear-guard', spacing: 'compact', spacing_comparable: true, command_path: 'diagnostic-spacing-only', target: 'thorn-ranger', diagnostic_only: true };
  await writeJson(path.join(stageA2BPack, 'stage-a2b-preflight.json'), { schema: 'v0436-r1k-stage-a2b-preflight-v1', status: 'STAGE_A2B_PREPARED', non_evidence: true, committed_baseline_sha: sha, source_sha: sha, branch: branchName, headed: true, hidden_window: false, renderer: 'Forward Plus', production_scene: 'scenes/main.tscn -> scenes/game_world.tscn', output_root_abs: absoluteRoot, local_modified_r1k_harness_files: r1kHarnessFiles, local_git_diff_binary_sha256: localDiffHash, headed_launch_count: 0, no_direct_state_writes: true, no_resource_injection: true, no_free_units: true, cell });
  let probe;
  let child = { status: null, signal: null, stdout: '', stderr: '', error: null };
  let validator = { passed: false, failures: ['headed diagnostic not executed'] };
  let manifest;
  try {
    probe = await runStageA2OutputProbe(sha, branchName, localDiffHash);
    child = runChild(['--path', project, '--resolution', '1920x1080', '--verbose'], stageA2BPack, {
      ...process.env,
      ASCENDANT_V0436_R1K_CAPTURE: '1',
      ASCENDANT_V0436_R1J_CAPTURE: '1',
      ASCENDANT_V0436_R1K_STAGE_A2: '1',
      ASCENDANT_V0436_R1K_STAGE_A2B: '1',
      ASCENDANT_V0436_R1K_OUTPUT_ROOT_ABS: absoluteRoot,
      ASCENDANT_V0436_R1K_REPO_ROOT_ABS: repo,
      ASCENDANT_V0436_R1K_SOURCE_SHA: sha,
      ASCENDANT_V0436_R1K_BRANCH: branchName,
      ASCENDANT_V0436_R1J_SOURCE_SHA: sha,
      ASCENDANT_V0436_R1J_BRANCH: branchName,
      ASCENDANT_V0436_R1K_CELL: cell.cell_id,
      ASCENDANT_V0436_R1K_REPETITION: '1',
      ASCENDANT_V0436_R1K_OUT: stageA2BPack,
      ASCENDANT_V0436_R1K_LOCAL_DIFF_SHA256: localDiffHash,
    });
    const outputLog = `${child.stdout}\n${child.stderr}`;
    const summaryFile = path.join(stageA2BPack, 'stage-a2-diagnostic-summary.json');
    const diagnosticFile = path.join(stageA2BPack, 'stage-a2-spacing-diagnostic.json');
    const summary = await exists(summaryFile) ? await readJson(summaryFile) : null;
    const writerRecords = Array.isArray(summary?.stage_a2b_writer_records) ? summary.stage_a2b_writer_records : [];
    let files = (await collectManifestFiles(stageA2BPack, writerRecords)).filter(file => file.relative_path !== 'stage-a2b-artifact-manifest.json');
    const requiredChecks = Object.fromEntries(requiredStageA2BPNGs.map(required => {
      const file = files.find(candidate => candidate.relative_path === required);
      return [required, Boolean(file && file.kind === 'png' && file.bytes > 1024 && file.dimensions?.width >= 2 && file.dimensions?.height >= 2 && file.readable && file.inside_authorized_output_root)];
    }));
    const diagnostic = summary && await exists(diagnosticFile) ? { summary, public_commands: (await readJson(diagnosticFile)).public_commands || [], contract: await exists(path.join(stageA2BPack, 'stage-a2-diagnostic-contract.json')) ? await readJson(path.join(stageA2BPack, 'stage-a2-diagnostic-contract.json')) : null, manifest: null } : null;
    manifest = { schema: 'v0436-r1k-stage-a2b-artifact-manifest-v1', non_evidence: true, source_sha: sha, branch: branchName, output_root_abs: absoluteRoot, local_modified_r1k_harness_files: r1kHarnessFiles, local_git_diff_binary_sha256: localDiffHash, headed_launch_count: 1, no_direct_state_writes: true, no_resource_injection: true, no_free_units: true, renderer: 'Forward Plus', production_scene: 'scenes/main.tscn -> scenes/game_world.tscn', required_pngs: requiredStageA2BPNGs, required_artifact_checks: requiredChecks, files, manifest_path: path.join(stageA2BPack, 'stage-a2b-artifact-manifest.json') };
    await writeJson(path.join(stageA2BPack, 'stage-a2b-artifact-manifest.json'), manifest);
    const logFailure = /Can't save PNG|SCRIPT ERROR|Failed to load image/i.test(outputLog);
    if (diagnostic) {
      diagnostic.manifest = manifest;
      validator = evaluateR1KStageA2Diagnostic({ diagnostic, branch: branchName, expectedSourceSha: sha, outputScope: 'diagnostics/stage-a2-compact-spacing-settlement-replacement-2' });
    } else validator = { passed: false, failures: ['missing Stage-A.2b diagnostic summary or spacing diagnostic'] };
    validator.failures = [...(validator.failures || []), ...(summary?.stage_a2b_output_failed ? ['GDScript reported Stage-A.2b output failure'] : []), ...(logFailure ? ['Godot log reported required output failure'] : [])];
    validator.passed = validator.failures.length === 0 && child.status === 0 && requiredStageA2BPNGs.every(required => requiredChecks[required]);
    files = await collectManifestFiles(stageA2BPack, writerRecords);
    manifest.files = files;
    await writeJson(path.join(stageA2BPack, 'stage-a2b-artifact-manifest.json'), manifest);
    const wrapper = { schema: 'v0436-r1k-stage-a2b-wrapper-result-v1', child_exit_code: child.status, signal: child.signal, child_error: child.error, required_artifact_checks: requiredChecks, validator_result: validator, probe_result: probe, overall_pass: validator.passed, stdout_tail: child.stdout.slice(-6000), stderr_tail: child.stderr.slice(-6000), source_sha: sha, branch: branchName, headed_launch_count: 1, local_git_diff_binary_sha256: localDiffHash };
    await writeJson(path.join(stageA2BPack, 'stage-a2b-wrapper-result.json'), wrapper);
    const finalFiles = (await collectManifestFiles(stageA2BPack, writerRecords)).filter(file => file.relative_path !== 'stage-a2b-artifact-manifest.json');
    manifest.files = finalFiles;
    await writeJson(path.join(stageA2BPack, 'stage-a2b-artifact-manifest.json'), manifest);
    if (!wrapper.overall_pass) { console.error(JSON.stringify(wrapper, null, 2)); process.exitCode = 1; } else console.log(JSON.stringify(wrapper, null, 2));
  } catch (error) {
    const files = (await collectManifestFiles(stageA2BPack)).filter(file => file.relative_path !== 'stage-a2b-artifact-manifest.json');
    const wrapper = { schema: 'v0436-r1k-stage-a2b-wrapper-result-v1', child_exit_code: child.status, signal: child.signal, child_error: child.error, required_artifact_checks: Object.fromEntries(requiredStageA2BPNGs.map(name => [name, false])), validator_result: validator, probe_result: probe || null, overall_pass: false, error: String(error), source_sha: sha, branch: branchName, headed_launch_count: child.status === null ? 0 : 1, local_git_diff_binary_sha256: localDiffHash };
    await writeJson(path.join(stageA2BPack, 'stage-a2b-wrapper-result.json'), wrapper);
    await writeJson(path.join(stageA2BPack, 'stage-a2b-artifact-manifest.json'), { schema: 'v0436-r1k-stage-a2b-artifact-manifest-v1', non_evidence: true, source_sha: sha, branch: branchName, output_root_abs: absoluteRoot, local_git_diff_binary_sha256: localDiffHash, headed_launch_count: wrapper.headed_launch_count, required_pngs: requiredStageA2BPNGs, files, manifest_path: path.join(stageA2BPack, 'stage-a2b-artifact-manifest.json') });
    console.error(JSON.stringify(wrapper, null, 2));
    process.exitCode = 1;
  }
}

async function finalizeStageA2B() {
  const preflightFile = path.join(stageA2BPack, 'stage-a2b-preflight.json');
  const summaryFile = path.join(stageA2BPack, 'stage-a2-diagnostic-summary.json');
  const diagnosticFile = path.join(stageA2BPack, 'stage-a2-spacing-diagnostic.json');
  if (!await exists(preflightFile) || !await exists(summaryFile) || !await exists(diagnosticFile)) throw new Error('Stage-A.2b cannot be finalized without its existing preflight, summary, and spacing diagnostic');
  const preflight = await readJson(preflightFile);
  const summary = await readJson(summaryFile);
  const diagnosticFileValue = await readJson(diagnosticFile);
  const writerRecords = Array.isArray(summary.stage_a2b_writer_records) ? summary.stage_a2b_writer_records : [];
  let files = (await collectManifestFiles(stageA2BPack, writerRecords)).filter(file => file.relative_path !== 'stage-a2b-artifact-manifest.json');
  const requiredChecks = Object.fromEntries(requiredStageA2BPNGs.map(required => {
    const file = files.find(candidate => candidate.relative_path === required);
    return [required, Boolean(file && file.kind === 'png' && file.bytes > 1024 && file.dimensions?.width >= 2 && file.dimensions?.height >= 2 && file.readable && file.inside_authorized_output_root && file.writer_return_code === 0)];
  }));
  const manifest = { schema: 'v0436-r1k-stage-a2b-artifact-manifest-v1', non_evidence: true, source_sha: preflight.source_sha, branch: preflight.branch, output_root_abs: path.resolve(stageA2BPack), local_modified_r1k_harness_files: r1kHarnessFiles, local_git_diff_binary_sha256: preflight.local_git_diff_binary_sha256, headed_launch_count: 1, no_direct_state_writes: true, no_resource_injection: true, no_free_units: true, renderer: 'Forward Plus', production_scene: 'scenes/main.tscn -> scenes/game_world.tscn', required_pngs: requiredStageA2BPNGs, required_artifact_checks: requiredChecks, files, manifest_path: path.join(stageA2BPack, 'stage-a2b-artifact-manifest.json'), finalized_without_new_headed_launch: true };
  const diagnostic = { summary, public_commands: diagnosticFileValue.public_commands || [], contract: await exists(path.join(stageA2BPack, 'stage-a2-diagnostic-contract.json')) ? await readJson(path.join(stageA2BPack, 'stage-a2-diagnostic-contract.json')) : null, manifest };
  const validator = evaluateR1KStageA2Diagnostic({ diagnostic, branch: preflight.branch, expectedSourceSha: preflight.source_sha, outputScope: 'diagnostics/stage-a2-compact-spacing-settlement-replacement-2' });
  if (summary.stage_a2b_output_failed === true) validator.failures.push('GDScript reported Stage-A.2b output failure');
  validator.passed = validator.failures.length === 0 && requiredStageA2BPNGs.every(required => requiredChecks[required]);
  await writeJson(path.join(stageA2BPack, 'stage-a2b-artifact-manifest.json'), manifest);
  const oldWrapper = await exists(path.join(stageA2BPack, 'stage-a2b-wrapper-result.json')) ? await readJson(path.join(stageA2BPack, 'stage-a2b-wrapper-result.json')) : {};
  const wrapper = { schema: 'v0436-r1k-stage-a2b-wrapper-result-v1', child_exit_code: oldWrapper.child_exit_code ?? 0, signal: oldWrapper.signal ?? null, child_error: oldWrapper.child_error ?? null, required_artifact_checks: requiredChecks, validator_result: validator, probe_result: oldWrapper.probe_result || null, overall_pass: validator.passed, source_sha: preflight.source_sha, branch: preflight.branch, headed_launch_count: 1, local_git_diff_binary_sha256: preflight.local_git_diff_binary_sha256, finalized_without_new_headed_launch: true, prior_wrapper_error: oldWrapper.error || null };
  await writeJson(path.join(stageA2BPack, 'stage-a2b-wrapper-result.json'), wrapper);
  files = (await collectManifestFiles(stageA2BPack, writerRecords)).filter(file => file.relative_path !== 'stage-a2b-artifact-manifest.json');
  manifest.files = files;
  await writeJson(path.join(stageA2BPack, 'stage-a2b-artifact-manifest.json'), manifest);
  if (!wrapper.overall_pass) { console.error(JSON.stringify(wrapper, null, 2)); process.exitCode = 1; } else console.log(JSON.stringify(wrapper, null, 2));
}

async function validateStageA2() {
  const summaryFile = path.join(stageA2BPack, 'stage-a2-diagnostic-summary.json');
  const diagnosticFile = path.join(stageA2BPack, 'stage-a2-spacing-diagnostic.json');
  const manifestFile = path.join(stageA2BPack, 'stage-a2b-artifact-manifest.json');
  const summary = await exists(summaryFile) ? await readJson(summaryFile) : null;
  const manifest = await exists(manifestFile) ? await readJson(manifestFile) : null;
  const diagnostic = summary && await exists(diagnosticFile) ? { summary, public_commands: (await readJson(diagnosticFile)).public_commands || [], contract: await exists(path.join(stageA2BPack, 'stage-a2-diagnostic-contract.json')) ? await readJson(path.join(stageA2BPack, 'stage-a2-diagnostic-contract.json')) : null, manifest } : { summary: summary || {}, public_commands: [], manifest };
  const result = evaluateR1KStageA2Diagnostic({ diagnostic, branch: branch(), expectedSourceSha: sourceSha(), outputScope: 'diagnostics/stage-a2-compact-spacing-settlement-replacement-2' });
  if (!summary) result.failures.push(`missing Stage-A.2b diagnostic summary: ${summaryFile}`);
  if (!await exists(diagnosticFile)) result.failures.push(`missing Stage-A.2b spacing diagnostic: ${diagnosticFile}`);
  if (!manifest) result.failures.push(`missing Stage-A.2b artifact manifest: ${manifestFile}`);
  for (const required of requiredStageA2BPNGs) {
    const entry = manifest?.files?.find(file => file.relative_path === required);
    if (!entry || entry.kind !== 'png' || entry.bytes <= 1024 || !entry.dimensions || entry.readable !== true || entry.inside_authorized_output_root !== true) result.failures.push(`invalid or missing required Stage-A.2b PNG ${required}`);
  }
  result.passed = result.failures.length === 0;
  result.status = result.passed ? 'STAGE_A2B_DIAGNOSTIC_VALIDATED' : 'BLOCKED_R1K_STAGE_A2B_VALIDATION';
  await writeJson(path.join(stageA2BPack, 'stage-a2b-validation.json'), result);
  if (!result.passed) { console.error(JSON.stringify(result, null, 2)); process.exitCode = 1; } else console.log(JSON.stringify(result, null, 2));
}

async function naturalPlan() {
  await fs.mkdir(pack, { recursive: true });
  await writeJson(path.join(pack, 'natural-confirmation-plan.json'), {
    schema: 'v0436-r1k-natural-confirmation-plan-v1',
    status: 'PLANNED_NOT_CAPTURED',
    sessions: [
      { session_id: 'natural-confirmation-a', status: 'planned', source_sha: sourceSha(), branch: branch(), headed: true, hidden_window: false, production_path: 'normal prepared-force production and public command' },
      { session_id: 'natural-confirmation-b', status: 'planned', source_sha: sourceSha(), branch: branch(), headed: true, hidden_window: false, production_path: 'normal prepared-force production and public command' },
    ],
    no_direct_state_writes: true,
    no_resource_injection: true,
    no_free_units: true,
  });
}

async function captureNatural() {
  if (process.env.ASCENDANT_V0436_R1K_STAGE_B_AUTHORIZED !== '1') throw new Error('Stage-B natural confirmation capture is not authorized during Stage-A.1');
  for (const sessionId of ['natural-confirmation-a', 'natural-confirmation-b']) {
    const sessionDir = path.join(pack, sessionId);
    await fs.mkdir(sessionDir, { recursive: true });
    execFileSync(godot(), ['--path', project, '--resolution', '1920x1080', '--verbose'], {
      cwd: sessionDir,
      stdio: 'inherit',
      env: { ...process.env, ASCENDANT_V0436_R1K_CAPTURE: '1', ASCENDANT_V0436_R1J_CAPTURE: '1', ASCENDANT_V0436_R1K_NATURAL_CAPTURE: '1', ASCENDANT_V0436_R1K_NATURAL_SESSION: sessionId, ASCENDANT_V0436_R1K_SOURCE_SHA: sourceSha(), ASCENDANT_V0436_R1K_BRANCH: branch(), ASCENDANT_V0436_R1J_SOURCE_SHA: sourceSha(), ASCENDANT_V0436_R1J_BRANCH: branch(), ASCENDANT_V0436_R1K_OUT: sessionDir },
    });
  }
}

async function assemble() {
  const matrix = plannedMatrix();
  const failures = [];
  const summaries = [];
  for (const cell of matrix.cells) {
    for (const repetition of cell.repetitions) {
      const file = path.join(pack, cell.cell_id, `rep-${repetition.repetition}`, 'r1k-session-summary.json');
      if (!await exists(file)) { failures.push(`missing captured summary ${cell.cell_id}/rep-${repetition.repetition}`); continue; }
      const summary = await readJson(file);
      if (summary.source_sha !== sourceSha()) failures.push(`stale source SHA in ${cell.cell_id}/rep-${repetition.repetition}`);
      if (summary.branch !== branch() || summary.headed !== true || summary.hidden_window !== false) failures.push(`invalid provenance in ${cell.cell_id}/rep-${repetition.repetition}`);
      if (summary.status !== 'CAPTURE_COMPLETED') failures.push(`non-completed capture in ${cell.cell_id}/rep-${repetition.repetition}`);
      if (!summary.metrics || Object.keys(metricTemplate()).some(key => !(key in summary.metrics))) failures.push(`missing metrics in ${cell.cell_id}/rep-${repetition.repetition}`);
      repetition.status = summary.status;
      repetition.source_sha = summary.source_sha;
      repetition.branch = summary.branch;
      repetition.headed = summary.headed;
      repetition.hidden_window = summary.hidden_window;
      repetition.metrics = summary.metrics || {};
      repetition.spacing_measurement = summary.spacing_measurement;
      summaries.push(summary);
    }
  }
  const natural = [];
  for (const id of ['natural-confirmation-a', 'natural-confirmation-b']) {
    const file = path.join(pack, id, 'r1k-natural-confirmation-summary.json');
    if (!await exists(file)) failures.push(`missing natural confirmation ${id}`);
    else natural.push(await readJson(file));
  }
  const wideCompactPairs = [
    [matrix.cells[0], matrix.cells[1]],
    [matrix.cells[2], matrix.cells[3]],
  ];
  let spacingPairsPassed = 0;
  for (const [wide, compact] of wideCompactPairs) {
    const wideMeasurements = wide.repetitions.map(rep => rep.spacing_measurement).filter(Boolean);
    const compactMeasurements = compact.repetitions.map(rep => rep.spacing_measurement).filter(Boolean);
    if (wideMeasurements.length === 2 && compactMeasurements.length === 2 && wideMeasurements.every(measurement => spacingPairPasses(measurement, compactMeasurements[0])) && compactMeasurements.every(measurement => spacingPairPasses(wideMeasurements[0], measurement))) spacingPairsPassed += 1;
    else failures.push(`wide/compact spacing pair failed for ${wide.cell_id} vs ${compact.cell_id}`);
  }
  matrix.natural_confirmation = { sessions: natural.length, status: natural.length === 2 ? 'captured' : 'missing', records: natural };
  matrix.comparability_audit = { passed: failures.length === 0, status: failures.length === 0 ? 'passed' : 'failed', spacing_pairs_checked: 2, spacing_pairs_passed: spacingPairsPassed, captured_sessions: summaries.length };
  const evidenceStatus = failures.length ? 'BLOCKED_R1K_CONTROLLED_MATRIX_INCONCLUSIVE' : 'BLOCKED_R1K_CONTROLLED_MATRIX_INCONCLUSIVE';
  const result = await evaluateR1KValidatorContract({ repo, branch: branch(), validatedHead: sourceSha(), expectedHead: sourceSha(), expectedSourceSha: sourceSha(), implementationFiles: ['production/ascendant-realms-godot/tests/v0436_r1k_capture.gd', 'tools/godot/v0436R1KControlledCombatMatrixTool.mjs', 'tools/godot/v0436R1KControlledCombatMatrixValidator.mjs', 'tools/godot/v0436R1KControlledCombatMatrixValidator.test.ts'], packFiles: ['00_READ_ME_FIRST.md', 'matrix-definition.json', 'implementation-contract.json'], matrix, sourceAudit: sourceAudit(), evidenceStatus, finalEvidence: true });
  await writeJson(path.join(pack, 'assembled-final-validation.json'), { ...result, assembly_failures: failures, matrix });
  if (failures.length || !result.passed) { console.error(JSON.stringify({ ...result, assembly_failures: failures }, null, 2)); process.exitCode = 1; } else console.log(JSON.stringify(result, null, 2));
}

async function focused() {
  execFileSync(process.platform === 'win32' ? 'npm.cmd' : 'npm', ['exec', '--', 'vitest', 'run', 'tools/godot/v0436R1KControlledCombatMatrixValidator.test.ts'], { cwd: repo, stdio: 'inherit', shell: process.platform === 'win32' });
}

function smoke() { execFileSync(godot(), ['--headless', '--editor', '--path', project, '--quit'], { cwd: repo, stdio: 'inherit', env: { ...process.env, ASCENDANT_V0436_R1K_CAPTURE: '0', ASCENDANT_V0436_R1J_CAPTURE: '0' } }); }

async function validate() {
  const implementationFiles = [];
  for (const file of ['production/ascendant-realms-godot/tests/v0436_r1k_capture.gd', 'tools/godot/v0436R1KControlledCombatMatrixTool.mjs', 'tools/godot/v0436R1KControlledCombatMatrixValidator.mjs', 'tools/godot/v0436R1KControlledCombatMatrixValidator.test.ts']) if (await exists(path.join(repo, file))) implementationFiles.push(file);
  const packFiles = [];
  for (const file of ['00_READ_ME_FIRST.md', 'matrix-definition.json', 'implementation-contract.json']) if (await exists(path.join(pack, file))) packFiles.push(file);
  // Stage A validates the executable contract with explicit placeholder metrics;
  // final evidence validation must consume captured repetition summaries instead.
  const matrix = plannedMatrix();
  const contract = await evaluateR1KValidatorContract({ repo, branch: branch(), validatedHead: sourceSha(), expectedHead: sourceSha(), implementationFiles, packFiles, matrix, sourceAudit: sourceAudit(), evidenceStatus: R1K_IMPLEMENTATION_STATUS, finalEvidence: false });
  const result = { ...contract, source_sha: sourceSha(), current_head: sourceSha(), implementation_only: true, note: 'Stage-A validator proves the opt-in diagnostic contract. Final evidence requires captured repetitions and two natural confirmation sessions.' };
  await writeJson(path.join(pack, 'final-validation.json'), result);
  if (!result.passed) { console.error(JSON.stringify(result, null, 2)); process.exitCode = 1; } else console.log(JSON.stringify(result, null, 2));
}

const command = process.argv[2] || 'validate';
if (command === 'capture') await capture();
else if (command === 'capture-one') await captureOne(process.argv[3], Number(process.argv[4] || 1));
else if (command === 'capture-stage-a2') await captureStageA2();
else if (command === 'finalize-stage-a2b') await finalizeStageA2B();
else if (command === 'validate-stage-a2') await validateStageA2();
else if (command === 'natural-plan') await naturalPlan();
else if (command === 'capture-natural') await captureNatural();
else if (command === 'assemble') await assemble();
else if (command === 'focused-tests') await focused();
else if (command === 'smoke') smoke();
else await validate();
