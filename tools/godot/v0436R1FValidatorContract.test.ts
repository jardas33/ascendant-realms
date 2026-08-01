import { describe, expect, it } from 'vitest';
import {
  ACCEPTED_R1F_IMPLEMENTATION_SHA,
  REQUIRED_R1F_BRANCH,
  evaluateR1FValidatorContract,
} from './v0436R1FValidatorContract.mjs';

const DOC_DESCENDANT = 'dbdac3a179c54b4b7a3227475b3b99c7b810f26f';

function runs(source = ACCEPTED_R1F_IMPLEMENTATION_SHA, branch = REQUIRED_R1F_BRANCH) {
  return ['01', '02', '03'].map(run_index => ({ run_index, source_sha: source, branch }));
}

function evaluate(overrides: Record<string, unknown> = {}) {
  return evaluateR1FValidatorContract({
    branch: REQUIRED_R1F_BRANCH,
    validatedHead: ACCEPTED_R1F_IMPLEMENTATION_SHA,
    acceptedImplementationIsAncestor: true,
    runs: runs(),
    evidenceSourceIsAncestor: true,
    acceptedImplementationIsAncestorOfEvidence: true,
    descendantChangedPaths: [],
    ...overrides,
  });
}

describe('v0.436-R1F retained validator descendant contract', () => {
  it('accepts the exact implementation commit with fresh evidence', () => {
    expect(evaluate()).toMatchObject({ passed: true, evidenceSourceIsCurrentHead: true });
  });

  it('accepts the known documentation-only descendant', () => {
    expect(evaluate({
      validatedHead: DOC_DESCENDANT,
      descendantChangedPaths: ['docs/V0436_R1F_BOUNDARY_RECOVERY_PHYSICS_TRUTH_REPORT.md'],
    })).toMatchObject({ passed: true, descendantPathsAllowed: true });
  });

  it('accepts fresh evidence captured at the current descendant head', () => {
    expect(evaluate({ validatedHead: DOC_DESCENDANT, runs: runs(DOC_DESCENDANT) }))
      .toMatchObject({ passed: true, evidenceSourceIsCurrentHead: true });
  });

  it('rejects a non-descendant head', () => {
    expect(evaluate({ acceptedImplementationIsAncestor: false })).toMatchObject({ passed: false });
  });

  it('rejects the wrong branch', () => {
    expect(evaluate({ branch: 'main' })).toMatchObject({ passed: false });
  });

  it('rejects mixed evidence SHAs', () => {
    const mixed = runs();
    mixed[2].source_sha = DOC_DESCENDANT;
    expect(evaluate({ runs: mixed })).toMatchObject({ passed: false, evidenceSourceSha: null });
  });

  it('rejects stale evidence followed by a production change', () => {
    const result = evaluate({
      validatedHead: DOC_DESCENDANT,
      descendantChangedPaths: ['production/ascendant-realms-godot/scripts/units/unit.gd'],
    });
    expect(result.passed).toBe(false);
    expect(result.failures).toContain('descendant path not allowed: production/ascendant-realms-godot/scripts/units/unit.gd');
  });

  it('rejects stale evidence followed by a tool change', () => {
    const result = evaluate({
      validatedHead: DOC_DESCENDANT,
      descendantChangedPaths: ['tools/godot/v0436R1FBoundaryPhysicsTool.mjs'],
    });
    expect(result.passed).toBe(false);
  });

  it('rejects missing provenance in one run', () => {
    const incomplete = runs();
    incomplete[1].source_sha = '';
    incomplete[2].branch = '';
    expect(evaluate({ runs: incomplete })).toMatchObject({ passed: false });
  });

  it('rejects broad documentation-like paths outside the allowlist', () => {
    const result = evaluate({
      validatedHead: DOC_DESCENDANT,
      descendantChangedPaths: ['docs/UNRELATED_CHECKPOINT.md'],
    });
    expect(result.passed).toBe(false);
  });
});
