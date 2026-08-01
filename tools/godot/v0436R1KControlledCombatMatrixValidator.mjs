import fs from 'node:fs/promises';

export const REQUIRED_R1K_BRANCH = 'codex/v0436-first-complete-conquest-victory';
export const R1K_PACK = 'artifacts/manual-review/v0436-r1k-controlled-combat-variable-isolation/';
export const R1K_STATUS = 'BLOCKED_R1K_CONTROLLED_MATRIX_INCONCLUSIVE';
export const R1K_IMPLEMENTATION_STATUS = 'R1K_IMPLEMENTATION_READY';
export const R1K_STAGE_A2_STATUS = 'NON_EVIDENCE_STAGE_A2_COMPACT_SPACING_SETTLEMENT_VALIDATED';
export const R1K_STAGE_A2_PHYSICAL_BLOCKER = 'BLOCKED_R1K_COMPACT_SPACING_PHYSICALLY_UNACHIEVABLE';
export const R1K_STAGE_A2_UNSTABLE_BLOCKER = 'BLOCKED_R1K_COMPACT_SPACING_UNSTABLE';
export const R1K_STAGE_A2_POST_STOP_WINDOW_BLOCKER = 'BLOCKED_R1K_POST_STOP_WINDOW_INCOMPLETE';
const R1K_DESTINATION_TOLERANCE = 1.5;
const R1K_MIN_ARRIVAL_TAIL_SAMPLES = 10;
const R1K_MIN_ARRIVAL_TAIL_SPAN_MS = 1000;
const R1K_MIN_POST_STOP_SAMPLES = 5;
const R1K_MIN_POST_STOP_SPAN_MS = 500;
export const R1K_CELLS = Object.freeze([
  'hero-spear-wide-thorn-ranger-first',
  'hero-spear-compact-thorn-ranger-first',
  'hero-spear-wide-hero-warden-first',
  'hero-spear-compact-hero-warden-first',
  'full-prepared-force-wide-hero-warden-first',
  'full-prepared-force-wide-thorn-ranger-first',
  'hero-only-direct-thorn-ranger-control',
  'hero-only-attack-move-then-thorn-ranger-control',
]);
export const R1K_CELL_CONTRACT = Object.freeze({
  'hero-spear-wide-thorn-ranger-first': { selected_force: 'hero-plus-spear-guard', spacing: 'wide', spacing_comparable: true, target: 'thorn-ranger' },
  'hero-spear-compact-thorn-ranger-first': { selected_force: 'hero-plus-spear-guard', spacing: 'compact', spacing_comparable: true, target: 'thorn-ranger' },
  'hero-spear-wide-hero-warden-first': { selected_force: 'hero-plus-spear-guard', spacing: 'wide', spacing_comparable: true, target: 'hero-warden' },
  'hero-spear-compact-hero-warden-first': { selected_force: 'hero-plus-spear-guard', spacing: 'compact', spacing_comparable: true, target: 'hero-warden' },
  'full-prepared-force-wide-hero-warden-first': { selected_force: 'full-prepared-force', spacing: 'wide', spacing_comparable: true, target: 'hero-warden' },
  'full-prepared-force-wide-thorn-ranger-first': { selected_force: 'full-prepared-force', spacing: 'wide', spacing_comparable: true, target: 'thorn-ranger' },
  'hero-only-direct-thorn-ranger-control': { selected_force: 'hero-only', spacing: 'not_applicable', spacing_comparable: false, target: 'thorn-ranger' },
  'hero-only-attack-move-then-thorn-ranger-control': { selected_force: 'hero-only', spacing: 'not_applicable', spacing_comparable: false, target: 'thorn-ranger' },
});
export const R1K_CLASSIFICATIONS = Object.freeze([
  'BLOCKED_R1K_HERO_OVERMATCH_OR_FORCE_INSUFFICIENCY_ISOLATED',
  'BLOCKED_R1K_FORMATION_COLLISION_FACTOR_ISOLATED',
  'BLOCKED_R1K_DEFENDER_COMPOSITION_FACTOR_ISOLATED',
  'BLOCKED_R1K_TARGET_ORDER_FACTOR_ISOLATED',
  'BLOCKED_R1K_COMMAND_PATH_FACTOR_ISOLATED',
  'BLOCKED_R1K_COMBAT_OUTCOME_NONDETERMINISTIC',
  'BLOCKED_R1K_CONTROLLED_MATRIX_INCONCLUSIVE',
]);

const exists = async file => { try { await fs.access(file); return true; } catch { return false; } };

function unique(values) { return new Set(values).size === values.length; }

function strictlyIncreasing(values) {
  return values.length > 1 && values.every((value, index) => index === 0 || value > values[index - 1]);
}

function unitsProveArrival(sample, frozenIds = null) {
  if (!Array.isArray(sample?.units) || !sample.units.length) return false;
  const ids = sample.units.map(unit => String(unit.runtime_id ?? ''));
  if (frozenIds && (ids.length !== frozenIds.size || ids.some(id => !frozenIds.has(id)))) return false;
  return sample.units.every(unit => unit.valid === true && unit.alive === true && Number.isFinite(Number(unit.destination_error)) && Number(unit.destination_error) <= R1K_DESTINATION_TOLERANCE);
}

export function spacingPairPasses(wide, compact) {
  const wideDistances = Array.isArray(wide?.pairwise_distances) ? wide.pairwise_distances.map(Number).filter(Number.isFinite) : [];
  const compactDistances = Array.isArray(compact?.pairwise_distances) ? compact.pairwise_distances.map(Number).filter(Number.isFinite) : [];
  if (!wideDistances.length || !compactDistances.length) return false;
  return Math.min(...wideDistances) > Math.max(...compactDistances) + 1;
}

export function evaluateR1KStageA2Diagnostic({ diagnostic, branch, expectedBranch = REQUIRED_R1K_BRANCH, expectedSourceSha, outputScope = 'diagnostics/stage-a2-compact-spacing-settlement', expectedAttemptId = null }) {
  const failures = [];
  const summary = diagnostic?.summary || diagnostic;
  const measurement = summary?.spacing_measurement || {};
  const postStop = Array.isArray(measurement.post_stop_samples) ? measurement.post_stop_samples : [];
  const provisional = Array.isArray(measurement.provisional_settlement_samples) ? measurement.provisional_settlement_samples : [];
  const assignments = Array.isArray(measurement.assigned_destinations) ? measurement.assigned_destinations : [];
  const commands = Array.isArray(diagnostic?.public_commands) ? diagnostic.public_commands : (Array.isArray(summary?.metrics?.public_commands) ? summary.metrics.public_commands : []);
  if (!summary || summary.schema !== 'v0436-r1k-stage-a2-diagnostic-summary-v1') failures.push('missing Stage-A.2 diagnostic summary schema');
  if (summary?.non_evidence !== true) failures.push('Stage-A.2 diagnostic is not explicitly marked non-evidence');
  if (branch !== expectedBranch || summary?.branch !== expectedBranch) failures.push('Stage-A.2 branch provenance mismatch');
  if (expectedSourceSha && summary?.source_sha !== expectedSourceSha) failures.push('Stage-A.2 source SHA mismatch');
  if (summary?.headed !== true || summary?.hidden_window !== false) failures.push('Stage-A.2 is not proven headed and visible');
  if (expectedAttemptId && summary?.attempt_id !== expectedAttemptId) failures.push(`Stage-A.2 summary attempt identity mismatch: expected ${expectedAttemptId}`);
  if (expectedAttemptId && diagnostic?.attempt_id !== expectedAttemptId) failures.push(`Stage-A.2 spacing diagnostic attempt identity mismatch: expected ${expectedAttemptId}`);
  if (expectedAttemptId && JSON.stringify(diagnostic || {}).includes('replacement-2')) failures.push('Stage-A.2 replacement-2 provenance appears in the requested attempt output');
  if (summary?.no_direct_state_writes !== true || summary?.no_resource_injection !== true || summary?.no_free_units !== true) failures.push('Stage-A.2 mutation guard is not proven');
  if (summary?.cell?.spacing !== 'compact' || summary?.cell?.spacing_comparable !== true) failures.push('Stage-A.2 compact spacing contract is missing');
  if (summary?.cell?.command_path !== 'diagnostic-spacing-only') failures.push('Stage-A.2 command path is not diagnostic-only');
  if ([R1K_STAGE_A2_STATUS, R1K_STAGE_A2_PHYSICAL_BLOCKER, R1K_STAGE_A2_UNSTABLE_BLOCKER, R1K_STAGE_A2_POST_STOP_WINDOW_BLOCKER].includes(summary?.status)) {
    if (postStop.length < 5) failures.push('successful Stage-A.2 diagnostic lacks five post-stop samples');
    const frozenIds = Array.isArray(measurement.frozen_unit_ids) ? new Set(measurement.frozen_unit_ids.map(String)) : null;
    const arrivalStart = Number(measurement.arrival_hold_start_index);
    const arrivalEnd = Number(measurement.arrival_hold_end_index);
    const declaredArrivalCount = Number(measurement.arrival_hold_sample_count);
    const arrivalTailValid = Number.isInteger(arrivalStart) && Number.isInteger(arrivalEnd) && arrivalStart >= 0 && arrivalEnd >= arrivalStart && arrivalEnd < provisional.length && declaredArrivalCount === arrivalEnd - arrivalStart + 1;
    if (!arrivalTailValid) failures.push('Stage-A.2 lacks a contiguous declared arrival-hold tail');
    const arrivalTail = arrivalTailValid ? provisional.slice(arrivalStart, arrivalEnd + 1) : [];
    const arrivalTimes = arrivalTail.map(sample => Number(sample.timestamp_ms));
    const arrivalTailSpan = arrivalTimes.length ? Math.max(...arrivalTimes) - Math.min(...arrivalTimes) : 0;
    if (arrivalTail.length < R1K_MIN_ARRIVAL_TAIL_SAMPLES) failures.push('successful Stage-A.2 diagnostic lacks ten consecutive arrival-tail samples');
    if (!strictlyIncreasing(arrivalTimes) || arrivalTailSpan < R1K_MIN_ARRIVAL_TAIL_SPAN_MS) failures.push('successful Stage-A.2 arrival-hold tail does not span one real second');
    if (Number(measurement.arrival_hold_start_timestamp_ms) !== arrivalTimes[0] || Number(measurement.arrival_hold_end_timestamp_ms) !== arrivalTimes[arrivalTimes.length - 1] || Number(measurement.arrival_hold_span_ms) !== arrivalTailSpan) failures.push('Stage-A.2 arrival-hold timestamps do not match the declared tail');
    if (frozenIds === null || frozenIds.size !== assignments.length || !frozenIds.size) failures.push('Stage-A.2 lacks the frozen controlled unit IDs');
    if (!arrivalTail.every(sample => unitsProveArrival(sample, frozenIds))) failures.push('successful Stage-A.2 arrival-hold tail does not prove destination tolerance');
    if (Number(measurement.settled_hold_seconds) < 1) failures.push('successful Stage-A.2 diagnostic lacks one-second arrival hold');
    if (Number(measurement.public_stop_command_count) !== 1) failures.push('successful Stage-A.2 diagnostic does not prove exactly one public stop command');
    const stopCommands = commands.filter(command => command.kind === 'stop');
    const stopTimestamp = Number(stopCommands[0]?.timestamp_ms);
    const arrivalEndTimestamp = Number(measurement.arrival_hold_end_timestamp_ms);
    if (!Number.isFinite(stopTimestamp) || !Number.isFinite(arrivalEndTimestamp) || stopTimestamp <= arrivalEndTimestamp) failures.push('public stop timestamp is not after the valid arrival-hold tail');
    const postStopTimes = postStop.map(sample => Number(sample.timestamp_ms));
    const postStopTimingValid = postStopTimes.length >= R1K_MIN_POST_STOP_SAMPLES && strictlyIncreasing(postStopTimes) && Number.isFinite(stopTimestamp) && postStopTimes[0] >= stopTimestamp && postStopTimes[postStopTimes.length - 1] - postStopTimes[0] >= R1K_MIN_POST_STOP_SPAN_MS;
    if (!postStopTimingValid) failures.push('successful Stage-A.2 post-stop window does not satisfy the five-sample, strictly increasing, post-stop 500 ms contract');
    if (!postStop.every(sample => unitsProveArrival(sample, frozenIds))) failures.push('successful Stage-A.2 post-stop samples do not prove destination arrival');
    if (summary.status === R1K_STAGE_A2_POST_STOP_WINDOW_BLOCKER) failures.push('Stage-A.2 runtime reported an incomplete post-stop timing window');
    const postStopDistances = postStop.map(sample => Number(sample.hero_to_companion_distance)).filter(Number.isFinite);
    if (!postStopDistances.length) failures.push('successful Stage-A.2 diagnostic lacks post-stop distance distribution');
    else if (postStopTimingValid && summary.status === R1K_STAGE_A2_STATUS && Math.max(...postStopDistances) > 3.2) failures.push('settlement classification contradicts post-stop compact threshold');
    else if (postStopTimingValid && summary.status === R1K_STAGE_A2_PHYSICAL_BLOCKER && Math.min(...postStopDistances) <= 3.2) failures.push('physical-infeasibility classification contradicts post-stop compact threshold');
    else if (postStopTimingValid && summary.status === R1K_STAGE_A2_UNSTABLE_BLOCKER && (Math.min(...postStopDistances) > 3.2 || Math.max(...postStopDistances) <= 3.2)) failures.push('unstable classification does not cross the compact threshold');
  }
  if (!assignments.length || assignments.some(item => !item.runtime_id || !item.destination || item.command_accepted !== true)) failures.push('Stage-A.2 lacks per-unit accepted public destination assignments');
  if (!commands.some(command => command.kind === 'attack_move_destination') || commands.filter(command => command.kind === 'stop').length !== 1) failures.push('Stage-A.2 lacks exactly one public movement-stop command history');
  const allSamples = [...provisional, ...postStop];
  if (!allSamples.every(sample => Number.isFinite(Number(sample.timestamp_ms)))) failures.push('Stage-A.2 samples are not timestamped');
  if (allSamples.some(sample => Object.values(sample.combat_event_counts || {}).some(value => Number(value) !== 0))) failures.push('combat interference occurred during Stage-A.2 spacing staging');
  if (summary?.metrics?.combat_interference === true || measurement.combat_interference === true) failures.push('Stage-A.2 diagnostic reports combat interference');
  if (summary?.metrics?.direct_state_writes === true || summary?.metrics?.resource_injection === true) failures.push('Stage-A.2 diagnostic reports forbidden mutation');
  if (outputScope.includes('artifacts/manual-review/v0436-r1k-controlled-combat-variable-isolation/hero-spear-')) failures.push('Stage-A.2 diagnostic output is inside a final matrix cell');
  return { schema: 'v0436-r1k-stage-a2-diagnostic-validator-v1', passed: failures.length === 0, status: failures.length ? 'BLOCKED_R1K_STAGE_A2_VALIDATION' : 'STAGE_A2_DIAGNOSTIC_VALIDATED', failures, diagnostic_status: summary?.status || null, source_sha: summary?.source_sha || null, branch: summary?.branch || null, output_scope: outputScope, non_evidence: true };
}

function validateCell(cell, failures, requireCapturedRepetition) {
  if (!R1K_CELLS.includes(cell.cell_id)) failures.push(`unknown R1K cell ${cell.cell_id}`);
  const expected = R1K_CELL_CONTRACT[cell.cell_id];
  if (expected) {
    if (cell.selected_force !== expected.selected_force) failures.push(`cell ${cell.cell_id} has wrong selected force`);
    if (cell.spacing !== expected.spacing) failures.push(`cell ${cell.cell_id} has wrong spacing contract`);
    if (cell.spacing_comparable !== expected.spacing_comparable) failures.push(`cell ${cell.cell_id} has wrong spacing comparability`);
    if (cell.target !== expected.target) failures.push(`cell ${cell.cell_id} has wrong target`);
  }
  const repetitions = Array.isArray(cell.repetitions) ? cell.repetitions : [];
  if (repetitions.length < 2) failures.push(`cell ${cell.cell_id} requires at least two repetitions`);
  if (unique(repetitions.map(rep => rep.repetition)) === false) failures.push(`cell ${cell.cell_id} has duplicate repetitions`);
  if (requireCapturedRepetition && !repetitions.every(rep => rep.source_sha && rep.branch && rep.headed === true && rep.hidden_window === false)) {
    failures.push(`cell ${cell.cell_id} has incomplete headed provenance`);
  }
  for (const repetition of repetitions) {
    if (!requireCapturedRepetition) continue;
    for (const key of ['survival', 'time_to_terminal', 'damage_dealt', 'damage_received', 'successful_attacks', 'cancelled_attacks', 'projectiles_launched', 'projectiles_impacted', 'misses_or_invalidations', 'attack_uptime', 'movement_time', 'legal_in_range_time', 'in_range_not_attacking', 'collision_blocked', 'no_valid_path', 'transitions', 'effective_dps', 'expected_vs_observed', 'final_hp', 'death_attribution']) {
      if (!(key in repetition.metrics)) failures.push(`cell ${cell.cell_id} repetition ${repetition.repetition} lacks metric ${key}`);
    }
    if (expected?.spacing_comparable && !repetition.spacing_measurement) failures.push(`cell ${cell.cell_id} repetition ${repetition.repetition} lacks spacing measurement`);
    if (expected?.spacing_comparable && repetition.spacing_measurement && repetition.spacing_measurement.comparable !== true) failures.push(`cell ${cell.cell_id} repetition ${repetition.repetition} spacing is not comparable`);
    if (expected?.spacing_comparable && repetition.spacing_measurement && !Array.isArray(repetition.spacing_measurement.pairwise_distances)) failures.push(`cell ${cell.cell_id} repetition ${repetition.repetition} lacks pairwise distances`);
    if (!expected?.spacing_comparable && repetition.spacing_measurement?.comparable === true) failures.push(`cell ${cell.cell_id} hero-only control incorrectly claims spacing comparability`);
    if (repetition.metrics && repetition.metrics.controlled_damage_attribution !== true) failures.push(`cell ${cell.cell_id} repetition ${repetition.repetition} lacks controlled damage attribution proof`);
    if (repetition.metrics && repetition.metrics.controlled_terminal_identity !== true) failures.push(`cell ${cell.cell_id} repetition ${repetition.repetition} lacks frozen terminal identity proof`);
    if (repetition.metrics && repetition.metrics.sampling_contract !== 'timestamped') failures.push(`cell ${cell.cell_id} repetition ${repetition.repetition} lacks timestamped sampling contract`);
  }
}

export async function evaluateR1KValidatorContract({ repo = '.', branch, validatedHead, expectedHead, expectedSourceSha = null, implementationFiles = [], packFiles = [], matrix, sourceAudit = {}, evidenceStatus = 'IMPLEMENTATION_READY', finalEvidence = false }) {
  const failures = [];
  if (branch !== REQUIRED_R1K_BRANCH) failures.push(`wrong branch: ${branch}`);
  if (validatedHead !== expectedHead) failures.push(`validated HEAD ${validatedHead} differs from expected ${expectedHead}`);
  const requiredImplementation = [
    'production/ascendant-realms-godot/tests/v0436_r1k_capture.gd',
    'tools/godot/v0436R1KControlledCombatMatrixTool.mjs',
    'tools/godot/v0436R1KControlledCombatMatrixValidator.mjs',
    'tools/godot/v0436R1KControlledCombatMatrixValidator.test.ts',
  ];
  for (const file of requiredImplementation) if (!implementationFiles.includes(file)) failures.push(`missing R1K implementation file ${file}`);
  for (const file of ['00_READ_ME_FIRST.md', 'matrix-definition.json', 'implementation-contract.json']) if (!packFiles.includes(file)) failures.push(`missing R1K pack file ${file}`);
  if (sourceAudit.true_default_runtime_unchanged !== true) failures.push('true default runtime preservation is not proven');
  if (sourceAudit.no_direct_state_writes !== true || sourceAudit.no_resource_injection !== true || sourceAudit.no_free_units !== true) failures.push('capture mutation guard is not proven');
  if (sourceAudit.accepted_chain_untouched !== true) failures.push('accepted R1J chain preservation is not proven');
  if (sourceAudit.production_repair_made !== false) failures.push('production repair was made during diagnosis');
  if (sourceAudit.stable_ids_and_saves_untouched !== true) failures.push('stable IDs or saves are not proven untouched');
  if (sourceAudit.historical_reference_non_runtime !== true) failures.push('historical reference was not kept non-runtime');
  if (sourceAudit.protected_assets_imported !== false) failures.push('protected or unapproved assets were imported');
  if (sourceAudit.forbidden_gameplay_mutation === true) failures.push('forbidden gameplay mutation is present');
  const cells = Array.isArray(matrix?.cells) ? matrix.cells : [];
  if (cells.length !== R1K_CELLS.length) failures.push(`exactly ${R1K_CELLS.length} R1K cells are required`);
  if (!unique(cells.map(cell => cell.cell_id))) failures.push('R1K cell IDs are not unique');
  for (const cell of cells) validateCell(cell, failures, finalEvidence || evidenceStatus !== R1K_IMPLEMENTATION_STATUS);
  if (expectedSourceSha && finalEvidence) {
    for (const cell of cells) for (const repetition of Array.isArray(cell.repetitions) ? cell.repetitions : []) {
      if (repetition.source_sha !== expectedSourceSha) failures.push(`stale repetition source SHA in ${cell.cell_id} repetition ${repetition.repetition}`);
    }
  }
  if (matrix?.mode !== 'diagnosis-only') failures.push('matrix is not diagnosis-only');
  if (matrix?.direct_state_writes !== false) failures.push('matrix permits direct state writes');
  if (finalEvidence) {
    if (evidenceStatus === 'R1K_IMPLEMENTATION_READY') failures.push('final evidence cannot remain implementation-only');
    if (!R1K_CLASSIFICATIONS.includes(evidenceStatus)) failures.push(`invalid primary causal classification ${evidenceStatus}`);
    if (matrix?.natural_confirmation?.sessions !== 2) failures.push('two natural confirmation sessions are required');
    if (matrix?.comparability_audit?.passed !== true) failures.push('comparability audit did not pass');
    if (matrix?.comparability_audit?.spacing_pairs_checked !== 2) failures.push('two wide/compact spacing pairs are required');
    if (matrix?.comparability_audit?.spacing_pairs_passed !== 2) failures.push('wide/compact spacing pairs did not both pass');
  } else if (R1K_CLASSIFICATIONS.includes(evidenceStatus)) {
    failures.push('causal classification requires finalEvidence=true');
  }
  return {
    schema: 'v0436-r1k-controlled-combat-matrix-validator-v1',
    branch,
    validatedHead,
    expectedHead,
    failures,
    passed: failures.length === 0,
    status: failures.length ? 'BLOCKED_R1K_EVIDENCE_VALIDATION' : evidenceStatus,
    final_evidence: finalEvidence,
    cells: cells.map(cell => ({ cell_id: cell.cell_id, repetitions: Array.isArray(cell.repetitions) ? cell.repetitions.length : 0 })),
  };
}

export { exists };
