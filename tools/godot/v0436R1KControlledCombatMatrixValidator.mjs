import fs from 'node:fs/promises';

export const REQUIRED_R1K_BRANCH = 'codex/v0436-first-complete-conquest-victory';
export const R1K_PACK = 'artifacts/manual-review/v0436-r1k-controlled-combat-variable-isolation/';
export const R1K_STATUS = 'BLOCKED_R1K_CONTROLLED_MATRIX_INCONCLUSIVE';
export const R1K_IMPLEMENTATION_STATUS = 'R1K_IMPLEMENTATION_READY';
export const R1K_CELLS = Object.freeze([
  'hero-only-wide-direct-target',
  'hero-only-compact-direct-target',
  'hero-thorn-ranger-wide-hero-first',
  'hero-thorn-ranger-wide-ranger-first',
  'full-defender-set-wide-hero-first',
  'full-defender-set-wide-defender-first',
  'hero-only-wide-attack-move-then-target',
  'hero-only-wide-direct-target-repeat-control',
]);
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

function validateCell(cell, failures, requireCapturedRepetition) {
  if (!R1K_CELLS.includes(cell.cell_id)) failures.push(`unknown R1K cell ${cell.cell_id}`);
  const repetitions = Array.isArray(cell.repetitions) ? cell.repetitions : [];
  if (repetitions.length < 2) failures.push(`cell ${cell.cell_id} requires at least two repetitions`);
  if (requireCapturedRepetition && !repetitions.every(rep => rep.source_sha && rep.branch && rep.headed === true && rep.hidden_window === false)) {
    failures.push(`cell ${cell.cell_id} has incomplete headed provenance`);
  }
  for (const repetition of repetitions) {
    if (!requireCapturedRepetition) continue;
    for (const key of ['survival', 'time_to_terminal', 'damage_dealt', 'damage_received', 'successful_attacks', 'cancelled_attacks', 'projectiles_launched', 'projectiles_impacted', 'misses_or_invalidations', 'attack_uptime', 'movement_time', 'legal_in_range_time', 'in_range_not_attacking', 'collision_blocked', 'no_valid_path', 'transitions', 'effective_dps', 'expected_vs_observed', 'final_hp', 'death_attribution']) {
      if (!(key in repetition.metrics)) failures.push(`cell ${cell.cell_id} repetition ${repetition.repetition} lacks metric ${key}`);
    }
  }
}

export async function evaluateR1KValidatorContract({ repo = '.', branch, validatedHead, expectedHead, implementationFiles = [], packFiles = [], matrix, sourceAudit = {}, evidenceStatus = 'IMPLEMENTATION_READY', finalEvidence = false }) {
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
  if (matrix?.mode !== 'diagnosis-only') failures.push('matrix is not diagnosis-only');
  if (matrix?.direct_state_writes !== false) failures.push('matrix permits direct state writes');
  if (finalEvidence) {
    if (evidenceStatus === 'R1K_IMPLEMENTATION_READY') failures.push('final evidence cannot remain implementation-only');
    if (!R1K_CLASSIFICATIONS.includes(evidenceStatus)) failures.push(`invalid primary causal classification ${evidenceStatus}`);
    if (matrix?.natural_confirmation?.sessions !== 2) failures.push('two natural confirmation sessions are required');
    if (matrix?.comparability_audit?.passed !== true) failures.push('comparability audit did not pass');
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
