import { describe, expect, it } from 'vitest';
import { evaluateK2CombatQualificationContract } from './v0436K2CombatQualificationValidatorContract.mjs';

describe('K2 combat qualification contract', () => {
  it('requires three public-action, headed run records and classifies clean evidence', () => {
    const run = (n: number) => ({
      root: `run-${n}`,
      files: ['01_K2_BASE_OPENING.png', '02_K2_DEFENDERS_READY.png', '03_K2_FIRST_WAVE_APPROACH.png', '04_K2_FIRST_CONTACT.png', '05_K2_ACTIVE_COMBAT.png', '06_K2_FIRST_WAVE_RESULT.png', 'k2-run.json'],
      status: 'QUALIFIED_FIRST_WAVE_OBSERVED',
      configuration: { observed: { player_race: 'barrosan', map: 'hollowspan', start_resources: 'rich', mode: 'skirmish', victory: 'conquest' }, state_injection: false, player_offense_before_first_wave: false },
      telemetry: [{ runtime_id: String(n), target_runtime_id: 'enemy', target_distance: 1, engage_range: 1.5, role: 'spear_guard', attack_state: true }],
      milestones: { first_wave: 10, first_contact: 12, first_damage: 13 },
    });
    const result = evaluateK2CombatQualificationContract({ runs: [run(1), run(2), run(3)], finalFiles: ['k2-run-1.json', 'k2-run-2.json', 'k2-run-3.json', 'k2-combat-telemetry.json', 'k2-first-wave-summary.json', 'k2-validation.json', 'k2-report.md', '07_MELEE_SETTLED.png', '08_GROUP_SETTLED.png', '09_RANGED_SETTLED.png', '10_COMBAT_BESIDE_BUILDING.png', '11_ROUTE_AROUND_BUILDING.png', '12_1366_FIRST_WAVE.png'], source: 'K2_FORCE_PLAN k2_mode _k2_unit_telemetry K2_COMBAT_CAPTURE', fs: { statSync: () => ({ size: 30_000 }) } as never });
    expect(result.passed).toBe(true);
    expect(result.classification).toBe('PASSED_K2_H1_COMBAT_CORRECTNESS_QUALIFIED');
  });
});
