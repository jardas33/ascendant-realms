import { describe, expect, it } from 'vitest';
import { evaluateK1BeginnerEconomyContract } from './v0436K1BeginnerEconomyValidatorContract.mjs';

describe('K1 beginner economy validator', () => {
  it('accepts the required public opening predicates', () => {
    const result = evaluateK1BeginnerEconomyContract({
      benchmark: { status: 'PASS_K1_BEGINNER_ECONOMY_DRIVER', samples_every_simulation_seconds: 5, samples: Array(10), action_trace: ['TRAIN_WORKER', 'ASSIGN_WORKER', 'BUILD_HOUSING', 'BUILD_WAR_HALL', 'QUEUE_MILITARY', 'BUILD_MORE_HOUSING', 'QUEUE_NEXT_MILITARY'], final: { workers_total: 6, peak_workers: 6, war_hall_built: true, housing_count: 1, completed_combat_units: 5, player_offense_count: 0 }, public_actions_only: true, state_injection: false },
      configuration: { observed: { player_race: 'barrosan', map: 'hollowspan', start_resources: 'rich', mode: 'skirmish', victory: 'conquest' } },
      files: ['01_K1_OPENING_BASELINE.png', '02_K1_ECONOMY_AND_FORCE_READY.png', 'k1-benchmark.json', 'k1-blocker.json', 'k1-match-configuration.json'],
      source: '',
    });
    expect(result.passed).toBe(true);
  });
});
