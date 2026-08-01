# v0.436-R1K Controlled Matrix Compact-Spacing Blocker Report

## Disposition

`BLOCKED_R1K_MATRIX_CONTRACT_COMPACT_SPACING_PHYSICALLY_UNACHIEVABLE` — `final_evidence=false` — `P0-RESULT-001 OPEN`.

This is a truthful blocker publication, not a production gameplay pass or a completed conquest/result checkpoint.

## Accepted baseline and provenance

- Branch: `codex/v0436-first-complete-conquest-victory`
- Source and exact origin SHA: `bf9a9f0f935cd6103fd12ab7275ff266843ce884`
- Exact GitHub Actions: run `30720639071` / run `682`, completed `success`
- PR #10 remains open, draft, and unmerged.
- Stage-A.2c implementation was accepted and published before this diagnostic.
- Replacement-3 was run exactly once from the published SHA with one headed Godot 4.3 Forward Plus process.

## Why R1K was introduced

R1K isolates the first complete-combat/conquest blocker from unrelated production behavior. The controlled matrix requires public-command movement, arrival settlement, explicit public stop, and a stable compact-spacing measurement before any combat or conquest evidence can be trusted. It exists to distinguish a real executable gameplay path from a visually plausible or internally injected result.

## Progression through Stage-A

- Stage-A established the controlled-combat matrix route and its evidence contract.
- A.1 restored the bounded runtime/capture preconditions needed for controlled observation.
- A.2 introduced the compact-spacing settlement gate used by the hero-plus-spear cells.
- A.2a and A.2b exposed incomplete harness/evidence timing and were not accepted as final evidence.
- A.2c established the routed replacement-2 implementation and exact-SHA publication path while preserving fail-closed behavior.
- A.2d added an isolated replacement-3 route with a fresh attempt ID, exact output root, and explicit A2D artifact names. The implementation was committed and pushed at the exact SHA above; CI passed before the headed run.

## Replacement-1 and replacement-2 rejection

Replacement-1 was rejected as `BLOCKED_R1K_STAGE_A2_VISUAL_EVIDENCE_INVALID` because its visual/evidence contract was not valid. Replacement-2 was rejected as `BLOCKED_R1K_STAGE_A2B_VALIDATION`; its 390 ms post-stop window did not satisfy the required timing contract. Neither is final matrix evidence.

## Why replacement-3 is valid diagnostic evidence

Replacement-3 used the exact authorized public-command protocol and produced a complete, immutable, provenance-bound diagnostic:

- Attempt: `stage-a2-compact-spacing-settlement-replacement-3`
- Cell: `hero-spear-compact-thorn-ranger-first`
- Command path: `diagnostic-spacing-only`
- Selected force: `hero-plus-spear-guard`
- Spacing: `compact`
- Target: `thorn-ranger`
- Headed: yes; hidden window: no; launch count: 1
- Combat interference: false
- Dedicated validator: `STAGE_A2D_DIAGNOSTIC_VALIDATED`, `passed=true`, `failures=[]`
- `non_evidence=true`; `final_evidence=false`

All five required A2D PNGs are present, readable, nonblank, and 1920x1061. The output manifest confirms they were generated during this attempt and remain inside the authorized replacement-3 directory. The three contextual R1J-named PNGs emitted in that directory are preserved as raw attempt context only and are explicitly excluded from the A2D evidence claim. No generated JSON contains replacement-2 provenance.

## Decisive measurements

### Arrival tail

- 20 consecutive samples
- 1013 ms span
- Both frozen units remained within the unchanged 1.5 destination-error tolerance
- Destination errors: `1.12735748291016` and `1.16319167613983`

### Public stop

- Two accepted attack-move destination commands
- Exactly one accepted public stop command
- No direct writes, resource injection, free units, or production mutation

### Post-stop window

- Five strictly increasing timestamps: `72969`, `73103`, `73236`, `73369`, `73503` ms
- Real span: 534 ms
- All velocities zero
- Stable hero-to-companion distance: `3.48830461502075` at every sample
- Unchanged compact threshold: `3.2`
- Therefore the compact threshold was not met

### Interference

Across the post-stop evidence, attacks, projectiles, damage, deaths, and target transitions were all zero. Units remained alive and valid. The diagnostic does not show combat or result mutation; it only shows that the declared compact-spacing contract cannot be achieved in this exact setup through the authorized public commands while normal collision/avoidance behavior remains active.

## Artifact list and visual hashes

The immutable attempt directory is:

`artifacts/manual-review/v0436-r1k-controlled-combat-variable-isolation/diagnostics/stage-a2-compact-spacing-settlement-replacement-3/`

Required A2D visual evidence:

| File | Dimensions | Bytes | SHA-256 |
|---|---:|---:|---|
| `01_STAGE_A2D_START.png` | 1920x1061 | 4,409,027 | `805f2007b3b4a0ac32e7f3650a9e694af655de4ea8ef62b2a2ebcf1a0fc76d47` |
| `02_STAGE_A2D_DESTINATIONS_ASSIGNED.png` | 1920x1061 | 4,243,834 | `29fefb8f9645d069466608591c284cac3225b3eb8019f6c8d131f5360f927f04` |
| `03_STAGE_A2D_ARRIVAL_HOLD_PROVEN.png` | 1920x1061 | 4,243,902 | `797adf614c2b75f606084b105544ba9ab396b627dee066599594e3b43fba0bbd` |
| `04_STAGE_A2D_PUBLIC_STOP_ISSUED.png` | 1920x1061 | 4,228,162 | `d9d975f3e77e98d3b78296867f931d28471ae7f659d7329dc495b9933ddb860b` |
| `05_STAGE_A2D_POST_STOP_MEASUREMENT.png` | 1920x1061 | 4,228,392 | `d1508c3212e18f5c477417b9272d350e3855bbb3073e5ffef719a4d46797a7ab` |

The complete 29-file, 128,327,348-byte attempt directory is immutable. Its manifest records hashes for the 27 generated payload files; `stage-a2d-artifact-manifest.json` and `stage-a2d-validation.json` are the manifest/validator records alongside that payload. The publication evidence disposition is recorded in `accepted-and-rejected-stage-a2-evidence.json`.

## Contract validity versus production correctness

These are separate claims:

1. **Diagnostic contract validity:** proven. The replacement-3 validator passed, the five required images and JSON evidence exist, provenance is exact, the run was headed and single-shot, and the timing/interference guards are satisfied.
2. **Compact-spacing hypothesis:** disproven for this exact two-unit setup under the unchanged `<=3.2` threshold. The stable measured distance is `3.48830461502075`.
3. **Production gameplay correctness:** not established as defective by this diagnostic. No production repair is authorized.
4. **Final R1K completion:** not achieved. `final_evidence=false`, the controlled matrix remains incomplete, and Stage-B is unauthorized.

## Evidence dispositions

Accepted as diagnostic-contract evidence: replacement-3 preflight, summary, spacing diagnostic, wrapper result, validator output, artifact manifest, the five required A2D PNGs, and exact SHA/CI provenance.

Rejected as final matrix evidence: the original Stage-A.2 attempt, replacement-1, replacement-2, stopped `c5bed126` Stage-B1 partial captures, all pre-A.1 material, missing controlled cells, natural confirmations because none were run, and the contextual R1J-named PNGs.

No existing diagnostic directory was modified, overwritten, renamed, deleted, regenerated, or relabeled by this publication.

## Narrow backlog disposition

The master player-experience backlog records:

- R1K controlled matrix: blocked by compact-spacing contract infeasibility;
- production defect: not established;
- Stage-B: not started;
- natural confirmations: not started;
- `P0-RESULT-001`: remains open;
- next decision requires a separately authorized matrix-contract redesign or another strategy for resolving the original conquest blocker.

P0 is not complete and P1–P4 are not advanced.

## Conclusion

**R1K cannot continue under the current eight-cell matrix contract because cells requiring compact hero-plus-spear spacing <= 3.2 are not executable under the authorized public-command protocol.**

**R1K remains blocked rather than passed or failed as a production gameplay checkpoint.**

## Publication validation

The publication run must retain these results:

- replacement-3 validator: passes;
- Stage-A.2 validator: `R1K_IMPLEMENTATION_READY`, `final_evidence=false`;
- test suites: pass;
- natural-plan validation: pass;
- final matrix assembler: remains fail-closed for incomplete controlled matrix and absent natural confirmations;
- no headed Godot launch after the already completed replacement-3 run;
- `git diff --check`: pass.

## Final state for this publication

`BLOCKED_R1K_MATRIX_CONTRACT_COMPACT_SPACING_PHYSICALLY_UNACHIEVABLE — final_evidence=false — P0-RESULT-001 OPEN`.
