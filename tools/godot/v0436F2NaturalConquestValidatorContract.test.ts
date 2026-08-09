import { describe, expect, it } from 'vitest';
import { F2_REQUIRED_FRAMES, evaluateF2NaturalConquestContract } from './v0436F2NaturalConquestValidatorContract.mjs';

const base = {
  branch: 'codex/local-core-playability-e', head: 'head',
  config: { observed: { start_resources: 'rich', game_speed: 2, map: 'hollowspan', mode: 'skirmish', victory: 'conquest', player_race: 'barrosan', opponents: [{ race: 'lioraen', difficulty: 'easy' }] } },
  status: 'INCONCLUSIVE_F2_TIME_LIMIT', reason: 'bounded natural attempt ended without victory', files: [...F2_REQUIRED_FRAMES, '26_F2_BLOCKER_CONTACT_SHEET.png'], samples: [{ simulation_time_seconds: 0 }, { simulation_time_seconds: 10 }], workerExpansion: [{ completed: true }], queueResults: [{ ok: true }], sourceWritesRejected: true, resourceTransactions: 12,
};

describe('v0.436 F2 natural conquest contract', () => {
  it('accepts a truthful bounded result', () => expect(evaluateF2NaturalConquestContract(base).passed).toBe(true));
  it('rejects standard resources', () => expect(evaluateF2NaturalConquestContract({ ...base, config: { observed: { ...base.config.observed, start_resources: 'standard' } } }).passed).toBe(false));
  it('rejects missing normal-play telemetry', () => expect(evaluateF2NaturalConquestContract({ ...base, samples: [] }).passed).toBe(false));
  it('rejects victory-only evidence on a non-winning result', () => expect(evaluateF2NaturalConquestContract({ ...base, files: [...base.files, '15_F2_NATURAL_CONQUEST.png'] }).passed).toBe(false));
  it('accepts a truthful pre-match runtime-startup blocker without gameplay evidence', () => expect(evaluateF2NaturalConquestContract({ branch: base.branch, head: base.head, status: 'BLOCKED_F2_SYSTEM_DEFECT_RUNTIME_STARTUP_LOADING_LOOP', reason: 'Godot remained in loading_screen.gd:_run_preload_sequence', blockerPhase: 'runtime_startup', files: ['f2-blocker.json'], sourceWritesRejected: true }).passed).toBe(true));
});
