import { describe, expect, it } from 'vitest';
import { E3R_STEP8_REPAIR_REQUIRED_FRAMES, evaluateE3RStep8RepairContract } from './v0436E3RStep8RepairValidatorContract.mjs';

const manifest = {
  schema: 'v0436-e3r-step8-repair-manifest-v1',
  source_sha: 'head',
  branch: 'codex/local-core-playability-e',
  player_team: 0,
  natural_capture: true,
  state_injection: false,
  tutorial: { completed: true, step_index: 9 },
  return_flow: { main_menu_reached: true, completion_button_exercised: true },
  capture_semantics: { before: { radius: 7.5, rate: 0.35 }, after: { radius: 7.5, rate: 0.35 }, contest_changed: false, benefit_changed: false },
};

describe('v0.436 E3R Step-8 repair contract', () => {
  it('requires the complete golden-path frame set', () => {
    const result = evaluateE3RStep8RepairContract({
      manifest,
      telemetry: { samples: [{ expected_target: { same_instance: true }, progress: 0.1, owner_team: 0, tutorial: { completed: true, step_index: 9 } }].concat(Array(100).fill({})) },
      files: E3R_STEP8_REPAIR_REQUIRED_FRAMES,
    });
    expect(result.passed).toBe(true);
  });

  it('rejects injected or incomplete evidence', () => {
    const result = evaluateE3RStep8RepairContract({
      manifest: { ...manifest, state_injection: true },
      telemetry: { samples: [] },
      files: [],
    });
    expect(result.passed).toBe(false);
    expect(result.failures).toContain('state injection was not explicitly false');
  });
});
