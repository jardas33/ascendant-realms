import { describe, expect, it } from 'vitest';
import { E1R2_REQUIRED_FRAMES, evaluateE1R2ValidatorContract } from './v0436E1R2SustainableEconomyValidatorContract.mjs';

const base = { branch: 'codex/local-core-playability-e', head: 'head', config: { observed: { start_resources: 'rich', game_speed: 2, map: 'hollowspan', mode: 'skirmish', victory: 'conquest', player_race: 'barrosan', opponents: [{ race: 'lioraen', difficulty: 'easy' }] } }, blocker: { status: 'INCONCLUSIVE_E1R_TIME_LIMIT', reason: 'reinforcement production did not recover in the bounded window' }, files: [...E1R2_REQUIRED_FRAMES], sourceWritesRejected: true, resourceTransactions: 10, queueResults: [{ ok: true }] };

describe('v0.436 E1R2 sustainable economy contract', () => {
  it('accepts a truthful bounded natural-play result', () => expect(evaluateE1R2ValidatorContract(base).passed).toBe(true));
  it('rejects standard resources', () => expect(evaluateE1R2ValidatorContract({ ...base, config: { observed: { ...base.config.observed, start_resources: 'standard' } } }).passed).toBe(false));
  it('rejects missing real economy evidence', () => expect(evaluateE1R2ValidatorContract({ ...base, resourceTransactions: 0 }).passed).toBe(false));
  it('rejects success-only frames on a blocker', () => expect(evaluateE1R2ValidatorContract({ ...base, files: [...base.files, '18_E1R_GENUINE_VICTORY.png'] }).passed).toBe(false));
});
