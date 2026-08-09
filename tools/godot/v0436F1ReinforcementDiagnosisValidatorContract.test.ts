import { describe, expect, it } from 'vitest';
import { evaluateF1ReinforcementContract } from './v0436F1ReinforcementDiagnosisValidatorContract.mjs';

const base = {
  branch: 'codex/local-core-playability-e',
  head: 'head',
  configuration: { observed: { start_resources: 'rich', game_speed: 2, map: 'hollowspan', mode: 'skirmish', victory: 'conquest', player_race: 'barrosan', opponents: [{ race: 'lioraen', difficulty: 'easy' }] } },
  throughput: { schema: 'v0436-f1-reinforcement-throughput-v1', theoretical_cost_time: { totals: { 5: {}, 10: {}, 15: {} } }, samples: [{ bucket: 0, match_time_seconds: 0 }, { bucket: 1, match_time_seconds: 10 }, { bucket: 2, match_time_seconds: 20 }], no_player_offense_before_simulation_seconds: 600, queue_results: [{}] },
  files: ['01_F1_STANDARD_MATCH_START.png'],
  sourceWritesRejected: true,
};

describe('v0.436 F1 reinforcement diagnosis contract', () => {
  it('accepts a bounded fresh normal-play diagnosis', () => expect(evaluateF1ReinforcementContract(base).passed).toBe(true));
  it('rejects standard resources', () => expect(evaluateF1ReinforcementContract({ ...base, configuration: { observed: { ...base.configuration.observed, start_resources: 'standard' } } }).passed).toBe(false));
  it('rejects missing periodic samples', () => expect(evaluateF1ReinforcementContract({ ...base, throughput: { ...base.throughput, samples: [] } }).passed).toBe(false));
});
