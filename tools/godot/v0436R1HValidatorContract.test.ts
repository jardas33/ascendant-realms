import { describe, expect, it } from 'vitest';
import {
  REQUIRED_R1H_BRANCH,
  REQUIRED_R1H_FRAMES,
  SUCCESS_R1H_FRAMES,
  evaluateR1HValidatorContract,
} from './v0436R1HValidatorContract.mjs';

const rootFiles = REQUIRED_R1H_FRAMES.slice(0, 0).map(name => ({ name, present: true }));
const base = {
  branch: REQUIRED_R1H_BRANCH,
  validatedHead: 'stage-a-sha',
  sourceShas: ['stage-a-sha', 'stage-a-sha'],
  sessions: ['A', 'B'],
  requiredRootFiles: rootFiles,
  requiredFramesBySession: { A: [...REQUIRED_R1H_FRAMES], B: [...REQUIRED_R1H_FRAMES] },
  successFramesBySession: { A: [], B: [] },
  blockers: [
    { session: 'A', status: 'BLOCKED_R1H_PREPARED_ASSAULT_FORCE_ELIMINATED', reason: 'force eliminated', force_plan: [], economy_timeline: [], completed_production: [], player_inventory: {}, enemy_inventory: {}, target_lifecycles: [], surviving_entities: [], resource_transactions: [], navigation_state: {}, match_state: {}, last_valid_frame: '09_R1H_WAVE_ONE_TERMINAL_STATE.png', later_phases_not_run: 'truthful blocker' },
    { session: 'B', status: 'BLOCKED_R1H_PREPARED_ASSAULT_FORCE_ELIMINATED', reason: 'force eliminated', force_plan: [], economy_timeline: [], completed_production: [], player_inventory: {}, enemy_inventory: {}, target_lifecycles: [], surviving_entities: [], resource_transactions: [], navigation_state: {}, match_state: {}, last_valid_frame: '09_R1H_WAVE_ONE_TERMINAL_STATE.png', later_phases_not_run: 'truthful blocker' },
  ],
};

describe('v0.436-R1H natural assault viability contract', () => {
  it('accepts two truthful blocker sessions without success-only evidence', () => {
    expect(evaluateR1HValidatorContract(base)).toMatchObject({ passed: true, sessions: ['A', 'B'] });
  });

  it('accepts a success session when all replay frames exist', () => {
    const result = evaluateR1HValidatorContract({ ...base, blockers: [], successFramesBySession: { A: [...SUCCESS_R1H_FRAMES], B: [...SUCCESS_R1H_FRAMES] } });
    expect(result.passed).toBe(true);
  });

  it('rejects wrong branch', () => {
    expect(evaluateR1HValidatorContract({ ...base, branch: 'main' }).passed).toBe(false);
  });

  it('rejects mixed source provenance', () => {
    expect(evaluateR1HValidatorContract({ ...base, sourceShas: ['stage-a-sha', 'other-sha'] }).passed).toBe(false);
  });

  it('rejects a blocker that includes success-only evidence', () => {
    expect(evaluateR1HValidatorContract({ ...base, successFramesBySession: { A: [SUCCESS_R1H_FRAMES[0]], B: [] } }).passed).toBe(false);
  });

  it('rejects missing direct-write protection', () => {
    expect(evaluateR1HValidatorContract({ ...base, directGameplayWritesRejected: false }).passed).toBe(false);
  });
});
