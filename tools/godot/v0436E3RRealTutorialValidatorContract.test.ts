import { describe, expect, it } from 'vitest';
import { E3R_REQUIRED_FRAMES, evaluateE3RValidatorContract } from './v0436E3RRealTutorialValidatorContract.mjs';

const base = { branch: 'codex/local-core-playability-e', validatedHead: 'head', sourceSha: 'head', manifest: { schema: 'v0436-e3r-real-tutorial-v1', menu_entry: 'How to Play button pressed through the normal main menu' }, sourceWritesRejected: true, blackFrameRejected: true };
const blocker = { status: 'BLOCKED_E3R_LUME_OWNERSHIP_NOT_RECOGNIZED', reason: 'natural ownership did not transition', last_valid_frame: '14_STEP8_CAPTURE_PROGRESS.png', later_phases_not_run: 'completion was not observed' };

describe('v0.436 E3R real tutorial evidence contract', () => {
  it('accepts a truthful partial blocker without success-only frames', () => {
    expect(evaluateE3RValidatorContract({ ...base, files: E3R_REQUIRED_FRAMES.slice(0, 14), blocker })).toMatchObject({ passed: true, status: blocker.status });
  });
  it('accepts the complete real tutorial frame set', () => {
    expect(evaluateE3RValidatorContract({ ...base, files: [...E3R_REQUIRED_FRAMES] })).toMatchObject({ passed: true, status: 'PASSED_V0436_E3R_REAL_TUTORIAL' });
  });
  it('rejects success-only evidence on a blocker', () => {
    expect(evaluateE3RValidatorContract({ ...base, files: ['16_TUTORIAL_COMPLETE.png'], blocker }).passed).toBe(false);
  });
  it('rejects mixed provenance', () => {
    expect(evaluateE3RValidatorContract({ ...base, sourceSha: 'other' }).passed).toBe(false);
  });
});
