import { describe, expect, it } from 'vitest';
import { evaluateR1KValidatorContract, REQUIRED_R1K_BRANCH, R1K_CELLS, R1K_IMPLEMENTATION_STATUS } from './v0436R1KControlledCombatMatrixValidator.mjs';

const head = 'r1k-test-head';
const implementationFiles = [
  'production/ascendant-realms-godot/tests/v0436_r1k_capture.gd',
  'tools/godot/v0436R1KControlledCombatMatrixTool.mjs',
  'tools/godot/v0436R1KControlledCombatMatrixValidator.mjs',
  'tools/godot/v0436R1KControlledCombatMatrixValidator.test.ts',
];
const metrics = {
  survival: true, time_to_terminal: 1, damage_dealt: 1, damage_received: 1,
  successful_attacks: 1, cancelled_attacks: 0, projectiles_launched: 1,
  projectiles_impacted: 1, misses_or_invalidations: 0, attack_uptime: 1,
  movement_time: 1, legal_in_range_time: 1, in_range_not_attacking: 0,
  collision_blocked: 0, no_valid_path: 0, transitions: 1, effective_dps: 1,
  expected_vs_observed: { expected: 1, observed: 1 }, final_hp: 1,
  death_attribution: null,
};
const repetition = n => ({ repetition: n, source_sha: head, branch: REQUIRED_R1K_BRANCH, headed: true, hidden_window: false, metrics });
const matrix = { mode: 'diagnosis-only', direct_state_writes: false, cells: R1K_CELLS.map(cell_id => ({ cell_id, repetitions: [repetition(1), repetition(2)] })), natural_confirmation: { sessions: 0 }, comparability_audit: { passed: false } };
const common = { repo: '.', branch: REQUIRED_R1K_BRANCH, validatedHead: head, expectedHead: head, implementationFiles, packFiles: ['00_READ_ME_FIRST.md', 'matrix-definition.json', 'implementation-contract.json'], matrix, sourceAudit: { true_default_runtime_unchanged: true, no_direct_state_writes: true, no_resource_injection: true, no_free_units: true, accepted_chain_untouched: true, production_repair_made: false, stable_ids_and_saves_untouched: true, historical_reference_non_runtime: true, protected_assets_imported: false, forbidden_gameplay_mutation: false } };

describe('v0.436-R1K controlled combat matrix contract', () => {
  it('accepts the complete implementation contract before final evidence publication', async () => {
    const result = await evaluateR1KValidatorContract({ ...common, evidenceStatus: R1K_IMPLEMENTATION_STATUS, finalEvidence: false });
    expect(result).toMatchObject({ passed: true, status: R1K_IMPLEMENTATION_STATUS });
  });
  it('rejects a missing repetition and forbidden mutation', async () => {
    const bad = structuredClone(common);
    bad.matrix.cells[0].repetitions.pop();
    bad.sourceAudit.forbidden_gameplay_mutation = true;
    expect((await evaluateR1KValidatorContract(bad)).passed).toBe(false);
  });
  it('rejects final publication without one classification and two natural sessions', async () => {
    const result = await evaluateR1KValidatorContract({ ...common, finalEvidence: true, evidenceStatus: R1K_IMPLEMENTATION_STATUS });
    expect(result.passed).toBe(false);
  });
  it('rejects wrong branch and direct state writes', async () => {
    const bad = structuredClone(common);
    bad.branch = 'main';
    bad.sourceAudit.no_direct_state_writes = false;
    expect((await evaluateR1KValidatorContract(bad)).passed).toBe(false);
  });
});
