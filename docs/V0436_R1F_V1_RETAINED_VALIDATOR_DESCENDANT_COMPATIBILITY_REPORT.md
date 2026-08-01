# v0.436-R1F-V1 Retained Validator Descendant Compatibility Report

## Status

`IN_PROGRESS_LOCAL_VALIDATION` — the tooling repair and fresh evidence are complete; publication and exact-SHA CI remain pending.

## Scope

This is a tooling-only descendant-compatibility checkpoint for the accepted R1F boundary-physics proof. It repairs the retained validator's obsolete exact-HEAD assumption so a valid documentation descendant can be validated by real Git ancestry and evidence provenance. It does not resume R1G, R1C, natural conquest, result/replay, balance, AI, combat, economy, v0.437, or P1-P4 work.

## Provenance

- Branch: `codex/v0436-first-complete-conquest-victory`
- Accepted implementation: `1111f306929665b40dab998de7e2aaad7f4f43ae`
- Validated local HEAD before publication: `dbdac3a179c54b4b7a3227475b3b99c7b810f26f`
- Accepted implementation is an ancestor of the validated HEAD: `true`
- Pull request: `#10`, open, draft, unmerged

## Defect and repair

The retained command `npm run godot:validate:v0436-r1-navigation-behavioral-proof` failed because `v0436R1FBoundaryPhysicsTool.mjs` demanded the obsolete exact base `6b14ba305afc4b3090d57f400da885550d512183`. The repaired contract uses `git merge-base --is-ancestor`, requires the accepted implementation ancestry, requires one branch and one source SHA across exactly three runs (`01`, `02`, `03`), and classifies stale evidence by an explicit documentation/review-pack allowlist. A stale run source followed by any production or validator-tool change is rejected and requires fresh capture.

## Implementation

- `tools/godot/v0436R1FValidatorContract.mjs` centralizes the pure contract.
- `tools/godot/v0436R1FValidatorContract.test.ts` covers the required ten-case matrix.
- `tools/godot/v0436R1FBoundaryPhysicsTool.mjs` preserves the original physics/integrity assertions and emits truthful ancestry/provenance fields.
- `tools/godot/v0436R1DHeadedStartupRecoveryTool.mjs` receives the minimal retained allowlist extension required to recognize the accepted R1F/R1F-V1 evidence descendants.
- No production source, gameplay semantics, capture fixture, package command, or runtime behavior was changed.

## Fresh evidence

The repaired tool produced three fresh headed runs at `dbdac3a179c54b4b7a3227475b3b99c7b810f26f`. All three runs report `PASSED_V0436_R1F_BOUNDARY_PHYSICS`, maximum simulation speed `3.599853515625` against allowed `5.4`, maximum per-physics-step displacement `0.1199951171875`, one movement application per frame, zero duplicate frames, zero post-recovery callback movement, final in-bounds state, contamination-free state, and cleanup success. The dedicated validator reports `failures: []` and `passed: true`.

## Review pack

`artifacts/manual-review/v0436-r1f-v1-retained-validator-descendant-compatibility/`

The pack contains preflight, failure reproduction, before/after contract records, the ten-case ancestry matrix, fresh run provenance, fresh validator output, scope audit, accepted/rejected evidence, and publication state. The original R1F pack retains the three actual headed run captures; no new R1G/R1C capture was performed.

## Validation state

Completed at this point:

- pure ten-case contract test
- fresh `npm run godot:test:v0436-r1-boundary-recovery`
- `npm run godot:validate:v0436-r1-navigation-behavioral-proof`
- `git diff --check`

The first R1D run exposed the stale allowlist defect and failed closed. After the minimal R1D compatibility extension, `npm run godot:validate:v0436-r1d-headed-startup` passed with no failures. Because that extension is tooling, the final publication SHA must receive a fresh three-run R1F capture before closeout.

Still required before publication: the explicit R1F focused test/smoke/capture/validator set, retained R1D/nav/conquest checks, full npm/content/art/runtime/artifact-retention/Godot validation, commit, push, exact-SHA Actions success, and clean/synced publication state.

## Closeout rule

R1G remains paused. A fresh explicit authorization rebased onto the final published R1F-V1 SHA is required before any R1G work resumes.
