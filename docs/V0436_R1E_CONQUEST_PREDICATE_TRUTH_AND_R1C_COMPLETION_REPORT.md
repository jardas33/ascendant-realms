# v0.436-R1E Conquest Predicate Truth and R1C Completion Report

## Final status

`BLOCKED_R1B_BOUNDARY_RECOVERY_REGRESSION`

R1E is fail-closed at its required fresh R1B boundary gate. The natural-conquest predicate audit and R1C result/replay capture were not run after that gate failed. No gameplay source was changed, no movement or threshold was weakened, and no success frame was manufactured.

## Provenance and publication

- Branch: `codex/v0436-first-complete-conquest-victory`
- Publication SHA: `2350c8a36e1d8b16acd70a1689296ac68df94c4b`
- Exact GitHub Actions run: `30603755080` — success
- PR #10: open, draft, unmerged
- PR title: `v0.436-R1E blocked by fresh R1B boundary recovery regression`
- Local checkout: `0 ahead / 0 behind origin`
- Local preserved dirty state after the run: 12 tracked paths and 516 untracked paths

## Fresh R1B result

The required isolated boundary fixture was executed at the publication SHA with its existing thresholds and movement values unchanged. The stale wrapper launch still fails before the fixture starts because it passes a Godot `--log-file` path and Godot exits with status 34. The same fixture was then run directly with that launch-only defect removed; the runtime proof completed and was preserved at:

`artifacts/manual-review/v0436-r1a-navigation-behavioral-proof/v0436-r1b-boundary-recovery-proof.json`

Observed contract values:

- `maximum_sampled_speed`: `9.41138174019608`
- allowed speed: `5.4`
- `maximum_single_frame_displacement`: `1.919921875`
- allowed single-frame displacement: `1.35`
- fixture present: `true`
- post-start position writes: `0`
- recovery started: `true`
- recovery completed: `true`
- final position in bounds: `true`
- direct state writes: `false`
- full-conquest capture: `false`
- contamination-free: `true`
- cleanup: `true`

The exact required classification is therefore `BLOCKED_R1B_BOUNDARY_RECOVERY_REGRESSION`.

## Exact samples behind the failure

The proof's initial fixture position was `(140, 0, 0)` at timestamp `23548 ms`. Recovery began at timestamp `23569 ms`. The two samples responsible for the maxima were:

| Timestamp | Previous position | Position | Wall-clock interval | Distance | Calculated speed | Contract consequence |
| ---: | --- | --- | ---: | ---: | ---: | --- |
| `24682 ms` | `(139.52001953125, 0, 0)` | `(137.60009765625, 0, 0)` | `1.105 s` | `1.919921875` | `1.73748585972851` | single-frame displacement exceeds `1.35` |
| `24733 ms` | `(137.60009765625, 0, 0)` | `(137.1201171875, 0, 0)` | `0.051 s` | `0.47998046875` | `9.41138174019608` | sampled speed exceeds `5.4` |

The next samples continued inward at timestamps `24786`, `24839`, `24893`, and `24946 ms`; recovery completed in bounds at `(135.920166015625, 0, 0)`. The proof records the first sample's timing as valid for the displacement contract and the second sample's timing as valid because the harness defines valid speed timing as `delta_seconds >= 0.05`.

## What is and is not proven

The evidence proves that the current accepted R1B fixture/validator contract observes values above its limits on fresh current-SHA runtime data. It does not, by itself, prove whether the cause is production recovery motion, wall-clock sampling jitter, game-speed scaling, or a mismatch between physics-frame movement and the harness's timer-based measurement. The harness computes `frame_distance / wall_clock_delta` from timer samples; it does not record the corresponding physics-frame count or the production `_physics_process(delta)` value for each sample. No causal conclusion is claimed.

The runtime did prove progressive inward recovery, no material outward drift, no post-start position writes, no direct state manipulation, no fixture contamination, and cleanup. Recovery completion does not satisfy the gate while either safety metric fails.

## R1C and R1E conquest status

Because the fresh R1B gate failed, R1E did not proceed to read-only conquest-predicate instrumentation or a new natural R1C capture. Consequently there are no R1E initial/final enemy predicate snapshots, no surviving-entity inventory from an R1E run, and no new headed conquest sessions.

The earlier R1C headed run remains truthful and blocked: it reached the real production scene and real frames but ended with `match_ended=false` before Victory, result HUD, Continue, Play Again, or fresh replay proof. Old success-sounding R1C frames remain invalidated and are not reused.

## Scope preservation

No production gameplay source changed in R1E. No conquest semantics, commander defeat behavior, `_end_game` behavior, unit movement values, navigation thresholds, AI, combat, damage, HP, economy, resources, balance, visual presentation, HUD, portraits, minimap, wording, command panel, or unrelated work changed. No direct result/replay signals or state writes were used.

P0-NAV-001 remains not promotable because the fresh boundary gate failed. P0-RESULT-001 remains open. P1/P2/P3/P4 remain unfixed.

## Evidence paths

- Fresh R1B proof: `artifacts/manual-review/v0436-r1a-navigation-behavioral-proof/v0436-r1b-boundary-recovery-proof.json`
- R1D report: `docs/V0436_R1D_HEADED_GODOT_STARTUP_RECOVERY_REPORT.md`
- R1C report: `docs/V0436_R1C_NATURAL_CONQUEST_RESULT_REPLAY_PROOF_REPORT.md`
- R1E blocked review directory: `artifacts/manual-review/v0436-r1e-conquest-predicate-truth-and-r1c-completion/`

No R1E success frames are present or claimed. The checkpoint stops at the required fail-closed boundary result; it does not start v0.437 and does not merge PR #10.

## Dated R1F follow-up — 2026-07-30

The R1E boundary failure was investigated by the isolated v0.436-R1F physics-frame audit. Three fresh headed runs through the corrected npm wrapper all completed recovery in bounds with zero post-start position writes, zero direct state writes, no contamination, no outward drift, a maximum per-physics-step displacement of `0.1199951171875`, a maximum simulation speed of `3.599853515625` against the existing `5.4` allowance, and exactly one body movement application per physics frame. The audit recorded `34` avoidance callbacks per run and zero callbacks that moved after recovery movement. No duplicate movement was proven and no production overspeed was proven.

The prior `9.41138174019608` sampled speed and `1.919921875` sampled interval displacement remain valid historical observations of the old timer harness, not physics-frame truth. R1F classifies the issue as `PASSED_V0436_R1F_BOUNDARY_MEASUREMENT_CONTRACT_REPAIRED`: timer interval displacement is now labelled diagnostic, while active R1B acceptance is based on physics-step displacement and simulation speed. `npm run godot:test:v0436-r1-boundary-recovery` and `npm run godot:validate:v0436-r1-navigation-behavioral-proof` now pass fresh physics evidence. The old timer source/output remains available as `npm run godot:diagnose:v0436-r1b-legacy-timer-contract` with status `HISTORICAL_R1E_TIMER_CONTRACT_FALSE_POSITIVE`. The only production-script change is bounded fixture-only read-only instrumentation; no movement repair or gameplay semantic change was made. R1C and conquest-predicate capture were not resumed. R1E's original blocked history remains intact and is not being rewritten as a success.

R1F evidence: `artifacts/manual-review/v0436-r1f-boundary-recovery-physics-truth/`. R1F report: `docs/V0436_R1F_BOUNDARY_RECOVERY_PHYSICS_TRUTH_REPORT.md`.
