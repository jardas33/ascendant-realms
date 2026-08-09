import { describe, expect, it } from 'vitest';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { validateG0Manifest, G0_FINAL_FILES } from './v0436G0StartupValidator.mjs';

const base = {
  schema: 'v0436-g0-startup-final-v1',
  base_sha: '07e55140acd737433dce9f14565310320aa0355a',
  branch: 'codex/local-runtime-startup-g0',
  godot: { version: '4.6.3.stable.official.7d41c59c4', sha256: 'EF90E929BA1A6A4322860285D97F40F4AA349C90329A91B0E8B55B8DF0F4CB00' },
  cold_cache_classification: 'PASSED_G0_COLD_IMPORT_ENVIRONMENT_ONLY',
  production_code_repaired: false,
  sequence_reentry_observed: false,
  runs: Object.fromEntries(['ordinary_run_1', 'ordinary_run_2', 'automated_run', 'f2_harness'].map((name) => [name, { status: 'PASSED_G0_STARTUP_REACHED_GAMEWORLD', game_root_seen: true, game_world_seen: true, hud_seen: true, first_playable_frame_seen: true, settled: true, sequence_invocation_count: 1 }])),
};

describe('v0.436 G0 runtime startup validator', () => {
  const evidenceDir = fs.mkdtempSync(path.join(os.tmpdir(), 'g0-validator-'));
  for (const file of G0_FINAL_FILES) fs.writeFileSync(path.join(evidenceDir, file), Buffer.alloc(10000, 1));

  it('accepts the complete startup contract', () => {
    const result = validateG0Manifest(base, evidenceDir);
    expect(result.passed).toBe(true);
  });

  it('rejects missing settled evidence', () => {
    const manifest = { ...base, runs: { ...base.runs, f2_harness: { ...base.runs.f2_harness, settled: false } } };
    const result = validateG0Manifest(manifest, evidenceDir);
    expect(result.passed).toBe(false);
    expect(result.failures).toContain('f2_harness lacks loader-settled evidence');
  });

  it('keeps the required evidence list explicit', () => expect(G0_FINAL_FILES).toHaveLength(7));
});
