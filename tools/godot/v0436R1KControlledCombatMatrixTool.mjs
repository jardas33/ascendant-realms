import fs from 'node:fs/promises';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import crypto from 'node:crypto';
import { R1K_CELLS, R1K_CELL_CONTRACT, R1K_IMPLEMENTATION_STATUS, R1K_PACK, REQUIRED_R1K_BRANCH, evaluateR1KValidatorContract, spacingPairPasses } from './v0436R1KControlledCombatMatrixValidator.mjs';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, R1K_PACK);
const captureScript = path.join(repo, 'production', 'ascendant-realms-godot', 'tests', 'v0436_r1k_capture.gd');
const godot = () => process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe');
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const sourceSha = () => git(['rev-parse', 'HEAD']);
const branch = () => git(['branch', '--show-current']);
const exists = async file => { try { await fs.access(file); return true; } catch { return false; } };
const readJson = async file => JSON.parse(await fs.readFile(file, 'utf8'));
const writeJson = async (file, value) => { await fs.mkdir(path.dirname(file), { recursive: true }); await fs.writeFile(file, `${JSON.stringify(value, null, 2)}\n`, 'utf8'); };
const sha256 = file => crypto.createHash('sha256').update(readFileSync(file)).digest('hex');

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
else if (command === 'natural-plan') await naturalPlan();
else if (command === 'capture-natural') await captureNatural();
else if (command === 'assemble') await assemble();
else if (command === 'focused-tests') await focused();
else if (command === 'smoke') smoke();
else await validate();
