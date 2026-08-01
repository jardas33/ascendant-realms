import { describe, expect, it } from 'vitest';
import {
  REQUIRED_R1I_BRANCH, REQUIRED_R1I_ROOT_FILES, REQUIRED_R1I_FRAMES, R1I_STATUS,
  evaluateR1IValidatorContract,
} from './v0436R1IValidatorContract.mjs';

const head = '4a495aa768ea92683622060070555c91cb86be99';
const roots = REQUIRED_R1I_ROOT_FILES.map(name => ({ name, present: true }));
const files = { A: REQUIRED_R1I_FRAMES.slice(0, 5), B: REQUIRED_R1I_FRAMES.slice(5, 10) };
const base = {
  branch: REQUIRED_R1I_BRANCH, validatedHead: head, sourceShas: [head], sessions: ['A', 'B'],
  rootFiles: roots, frameFiles: files,
  provenance: { headed: true, hidden_window: false, godot_log_file_argument: false, branch: REQUIRED_R1I_BRANCH, source_sha: head },
  baseline: { production_scene: 'scenes/main.tscn -> scenes/game_world.tscn', resource_injection: false, free_units: false, direct_state_writes: false },
  sessionAudit: { A: { blocker_status: 'BLOCKED_R1H_PREPARED_ASSAULT_FORCE_ELIMINATED', comparable: true }, B: { blocker_status: 'BLOCKED_R1H_PREPARED_ASSAULT_FORCE_ELIMINATED', comparable: true } },
  combatAudits: { A: { attributed_event_count: 2, command_count: 2 }, B: { attributed_event_count: 2, command_count: 2 } },
  casualtyAudits: { A: { present: true }, B: { present: true } },
  causalDecision: { status: R1I_STATUS, supported_by_sessions: ['A', 'B'] },
};

describe('v0.436-R1I combat causality contract', () => {
  it('accepts two comparable headed sessions with fail-closed diagnosis', () => {
    expect(evaluateR1IValidatorContract(base)).toMatchObject({ passed: true, status: R1I_STATUS });
  });
  it('rejects stale evidence and unsupported causal claims', () => {
    expect(evaluateR1IValidatorContract({ ...base, frameFiles: { ...files, A: [...files.A, '01_R1H_STALE.png'] } }).passed).toBe(false);
    expect(evaluateR1IValidatorContract({ ...base, causalDecision: { status: 'BLOCKED_R1I_HERO_OVERMATCH_PROVEN', supported_by_sessions: ['A'] } }).passed).toBe(false);
  });
  it('rejects wrong provenance and direct-write baselines', () => {
    expect(evaluateR1IValidatorContract({ ...base, branch: 'main' }).passed).toBe(false);
    expect(evaluateR1IValidatorContract({ ...base, baseline: { ...base.baseline, direct_state_writes: true } }).passed).toBe(false);
  });
});
