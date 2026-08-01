import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import {
  evaluateR1KStageA2Diagnostic,
  REQUIRED_R1K_BRANCH,
  R1K_STAGE_A2_POST_STOP_WINDOW_BLOCKER,
  R1K_STAGE_A2_STATUS,
} from './v0436R1KControlledCombatMatrixValidator.mjs';

const sha = 'stage-a2-test-sha';
const assignment = { runtime_id: 'hero-1', definition_id: 'barrosan_hero_thane', destination: { x: 0, y: 0, z: 0 }, command_accepted: true };
const companionAssignment = { runtime_id: 'spear-1', definition_id: 'barrosan_spear_guard', destination: { x: 1.2, y: 0, z: 0 }, command_accepted: true };
const sample = (timestamp_ms: number, destinationError = 0.5, distance = 2) => ({
  timestamp_ms,
  units: [
    { runtime_id: 'hero-1', valid: true, alive: true, destination_error: destinationError },
    { runtime_id: 'spear-1', valid: true, alive: true, destination_error: Math.min(destinationError, 0.8) },
  ],
  pairwise_distances: [distance],
  hero_to_companion_distance: distance,
  combat_event_counts: { attacks: 0, projectiles: 0, damage: 0, deaths: 0 },
});

const validProvisional = () => [
  sample(0, 2),
  sample(120, 2),
  ...Array.from({ length: 10 }, (_, index) => sample(240 + index * 120)),
];
const validPostStop = () => Array.from({ length: 5 }, (_, index) => sample(1500 + index * 125));
const diagnostic = (overrides: Record<string, unknown> = {}) => ({
  summary: {
    schema: 'v0436-r1k-stage-a2-diagnostic-summary-v1',
    non_evidence: true,
    branch: REQUIRED_R1K_BRANCH,
    source_sha: sha,
    headed: true,
    hidden_window: false,
    no_direct_state_writes: true,
    no_resource_injection: true,
    no_free_units: true,
    status: R1K_STAGE_A2_STATUS,
    cell: { spacing: 'compact', spacing_comparable: true, command_path: 'diagnostic-spacing-only' },
    spacing_measurement: {
      assigned_destinations: [assignment, companionAssignment],
      provisional_settlement_samples: validProvisional(),
      post_stop_samples: validPostStop(),
      frozen_unit_ids: ['hero-1', 'spear-1'],
      arrival_hold_start_index: 2,
      arrival_hold_end_index: 11,
      arrival_hold_sample_count: 10,
      arrival_hold_start_timestamp_ms: 240,
      arrival_hold_end_timestamp_ms: 1320,
      arrival_hold_span_ms: 1080,
      settled_consecutive_samples: 10,
      settled_hold_seconds: 1.08,
      public_stop_command_count: 1,
      combat_interference: false,
    },
  },
  public_commands: [
    { kind: 'attack_move_destination', accepted: true, timestamp_ms: 0 },
    { kind: 'attack_move_destination', accepted: true, timestamp_ms: 10 },
    { kind: 'stop', accepted: true, timestamp_ms: 1400 },
  ],
  ...overrides,
});

const evaluate = (value = diagnostic()) => evaluateR1KStageA2Diagnostic({ diagnostic: value, branch: REQUIRED_R1K_BRANCH, expectedSourceSha: sha });

describe('v0.436-R1K Stage-A.2c timing and arrival-tail contract', () => {
  it('accepts early provisional samples outside tolerance when the declared contiguous tail is valid', () => {
    expect(evaluate().passed).toBe(true);
  });

  it('rejects a bad sample inside the declared arrival tail', () => {
    const bad = diagnostic();
    bad.summary.spacing_measurement.provisional_settlement_samples[5].units[0].destination_error = 1.6;
    expect(evaluate(bad).passed).toBe(false);
  });

  it('rejects forged or noncontiguous arrival-tail indices', () => {
    const bad = diagnostic();
    bad.summary.spacing_measurement.arrival_hold_end_index = 12;
    bad.summary.spacing_measurement.arrival_hold_sample_count = 10;
    expect(evaluate(bad).passed).toBe(false);
  });

  it('rejects an arrival tail shorter than ten samples or shorter than one real second', () => {
    const shortCount = diagnostic();
    shortCount.summary.spacing_measurement.arrival_hold_end_index = 10;
    shortCount.summary.spacing_measurement.arrival_hold_sample_count = 9;
    expect(evaluate(shortCount).passed).toBe(false);
    const shortSpan = diagnostic();
    shortSpan.summary.spacing_measurement.arrival_hold_end_timestamp_ms = 1100;
    shortSpan.summary.spacing_measurement.arrival_hold_span_ms = 860;
    expect(evaluate(shortSpan).passed).toBe(false);
  });

  it('rejects a public stop issued before the valid arrival-hold tail ends', () => {
    const bad = diagnostic();
    bad.public_commands[2].timestamp_ms = 1000;
    expect(evaluate(bad).passed).toBe(false);
  });

  it('requires five post-stop samples spanning at least 500 ms', () => {
    const shortWindow = diagnostic();
    shortWindow.summary.spacing_measurement.post_stop_samples = Array.from({ length: 5 }, (_, index) => sample(1500 + index * 97));
    expect(evaluate(shortWindow).passed).toBe(false);
    const exactWindow = diagnostic();
    expect(evaluate(exactWindow).passed).toBe(true);
    const longerWindow = diagnostic();
    longerWindow.summary.spacing_measurement.post_stop_samples = Array.from({ length: 6 }, (_, index) => sample(1500 + index * 125));
    expect(evaluate(longerWindow).passed).toBe(true);
  });

  it('rejects duplicated or decreasing post-stop timestamps and missing measurement fields', () => {
    const duplicate = diagnostic();
    duplicate.summary.spacing_measurement.post_stop_samples[2].timestamp_ms = duplicate.summary.spacing_measurement.post_stop_samples[1].timestamp_ms;
    expect(evaluate(duplicate).passed).toBe(false);
    const missing = diagnostic();
    delete missing.summary.spacing_measurement.post_stop_samples[0].hero_to_companion_distance;
    delete missing.summary.spacing_measurement.post_stop_samples[0].units[0].destination_error;
    expect(evaluate(missing).passed).toBe(false);
  });

  it('does not classify physical infeasibility when timing is invalid', () => {
    const blocked = diagnostic();
    blocked.summary.status = 'BLOCKED_R1K_COMPACT_SPACING_PHYSICALLY_UNACHIEVABLE';
    blocked.summary.spacing_measurement.post_stop_samples = Array.from({ length: 5 }, (_, index) => ({ ...sample(1500 + index * 97, 0.5, 3.5), hero_to_companion_distance: 3.5, pairwise_distances: [3.5] }));
    expect(evaluate(blocked).passed).toBe(false);
  });

  it('accepts physical infeasibility only with a complete valid post-stop distribution above threshold', () => {
    const blocked = diagnostic();
    blocked.summary.status = 'BLOCKED_R1K_COMPACT_SPACING_PHYSICALLY_UNACHIEVABLE';
    blocked.summary.spacing_measurement.post_stop_samples = Array.from({ length: 5 }, (_, index) => ({ ...sample(1500 + index * 125), hero_to_companion_distance: 3.5, pairwise_distances: [3.5] }));
    expect(evaluate(blocked).passed).toBe(true);
  });

  it('keeps the incomplete-window runtime blocker fail-closed', () => {
    const blocked = diagnostic();
    blocked.summary.status = R1K_STAGE_A2_POST_STOP_WINDOW_BLOCKER;
    expect(evaluate(blocked).passed).toBe(false);
  });

  it('keeps wrapper required-artifact and finalize-only contracts canonical', () => {
    const source = readFileSync(new URL('./v0436R1KControlledCombatMatrixTool.mjs', import.meta.url), 'utf8');
    expect(source.match(/const requiredStageA2BPNGs\s*=/g)?.length).toBe(1);
    expect(source).not.toMatch(/\brequiredStageA2PNGs\b/);
    const finalizeBody = source.slice(source.indexOf('async function finalizeStageA2B()'), source.indexOf('async function validateStageA2()'));
    expect(finalizeBody).not.toContain('runChild(');
    expect(source).toContain('finalized_without_new_headed_launch: true');
    expect(source).toContain('overall_pass: validator.passed');
    expect(source).toContain('replacement-1');
    expect(source).toContain('replacement-2');
  });
});
