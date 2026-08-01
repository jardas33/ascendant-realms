# v0.436-R1F Boundary Recovery Physics Truth Report

## Status

`PASSED_V0436_R1F_BOUNDARY_MEASUREMENT_CONTRACT_REPAIRED`

R1F proves that the fresh R1E/R1B boundary failures came from the timer-based measurement contract, not from duplicate recovery movement or a proven production overspeed. The accepted safety allowance remains unchanged at `move_speed * 1.5`.

## Scope and provenance

- Branch: `codex/v0436-first-complete-conquest-victory`
- Base HEAD: `6b14ba305afc4b3090d57f400da885550d512183`
- Current source SHA used by the fresh fixture runs: `6b14ba305afc4b3090d57f400da885550d512183`
- Godot: `4.3.stable.official.77dcf97d8`
- Prototype scope: fixture-only boundary recovery observation, wrapper launch correction, evidence and validator wiring
- No R1C, conquest-predicate, result/replay, balance, economy, AI, combat, visual, HUD, portrait, minimap, wording, command-panel, or v0.437 work was performed

## Root-cause decision

The former R1E/R1B harness sampled after `create_timer(0.1)`, divided interval distance by wall-clock time, and labelled that interval `maximum_single_frame_displacement`. Timer jitter and delayed callbacks produced intervals covering multiple physics frames. The new audit records actual physics frames, `_physics_process(delta)`, positions before/after the recovery move, simulation speed, and movement ownership.

Across three fresh headed runs:

| Run | Max timer speed (diagnostic) | Max timer interval displacement (diagnostic) | Max physics-step displacement | Max simulation speed | Max moves/frame | Duplicate frames |
|---|---:|---:|---:|---:|---:|---|
| 01 | 2.542943 | 1.919922 | 0.119995 | 3.599854 | 1 | none |
| 02 | 7.346640 | 1.199951 | 0.119995 | 3.599854 | 1 | none |
| 03 | 6.922796 | 1.439941 | 0.119995 | 3.599854 | 1 | none |

The expected recovery speed is `3.6`; the existing allowed speed is `5.4`. Each run completed recovery in `34` audited recovery steps, finished inside strict bounds, recorded `34` avoidance callbacks, and recorded zero callbacks that moved after recovery movement. The old timer values are retained as diagnostic comparison only and are no longer treated as single-frame evidence in the active R1B gate.

## Corrected launch contract

The R1B wrapper now launches through npm without Godot `--log-file`, uses the real headed window, uses the quoted project path supplied as an argument, leaves the project-default Forward Plus renderer selected, and lets the runner own stdout/stderr. The exact executable provenance is recorded in `artifacts/manual-review/v0436-r1f-boundary-recovery-physics-truth/preflight.json` and `wrapper-launch-contract.json`.

## Instrumentation and production source impact

Fixture-only, bounded, read-only audit fields were added to `production/ascendant-realms-godot/scripts/units/unit.gd`. They activate only for the boundary fixture or the R1F audit environment and observe recovery movement plus avoidance callbacks. They do not change position, velocity, state, target, avoidance configuration, speed, physics rate, or time scale. No production movement repair was made because the audit disproved duplicate movement and true overspeed.

The isolated R1F runner inherits the real production scene and existing match setup. It writes per-run physics evidence, timer-versus-physics comparison, duplicate-movement audit, final validation, and real headed frames. The true default runtime remains unchanged because R1F is selected only by opt-in environment/autoload wiring.

## Acceptance and retained history

- recovery start/completion: passed in all three runs
- final strict in-bounds position: passed in all three runs
- post-start position writes: `0`
- direct state writes: `0`
- non-finite positions: none
- outward drift: none
- contamination and cleanup: passed
- actual physics speed: within existing allowance
- actual physics displacement: within physics-delta contract
- body movement applications per physics frame: maximum `1`
- R1E blocker history: preserved; the old timer-derived proof is not rewritten as a success
- P0-RESULT-001 and P1-P4: unchanged
- R1C and natural conquest capture: not resumed

## Review pack

`artifacts/manual-review/v0436-r1f-boundary-recovery-physics-truth/`

It contains `preflight.json`, `wrapper-launch-contract.json`, the three per-run physics JSON files, timer comparison, duplicate-movement audit, final validation, accepted/rejected evidence, root copies of the three run records, and six fresh headed PNGs including the contact sheet. The frames are actual rendered runtime captures, not title cards.

## Dedicated command and validation

- `npm run godot:test:v0436-r1f-boundary-physics`
- `npm run godot:smoke:v0436-r1f-boundary-physics`
- `npm run godot:capture:v0436-r1f-boundary-physics`
- `npm run godot:validate:v0436-r1f-boundary-physics`

The active retained command `npm run godot:test:v0436-r1-boundary-recovery` now invokes the fresh three-run R1F capture, and `npm run godot:validate:v0436-r1-navigation-behavioral-proof` now validates that fresh physics evidence. Both pass. The old timer validator/source remains available through `npm run godot:diagnose:v0436-r1b-legacy-timer-contract`, which reports `HISTORICAL_R1E_TIMER_CONTRACT_FALSE_POSITIVE` and is not an active gate. R1F intentionally stops before R1C/conquest/result/replay work.

## CI and final state

The current active R1B/R1F acceptance is green locally and published in commit `1111f306929665b40dab998de7e2aaad7f4f43ae`. GitHub Actions run `30607800767` completed successfully for that exact SHA. PR #10 remains open, draft, and unmerged.

## Full local validation evidence

The closeout validation set completed successfully before publication:

- R1F focused physics tests, smoke, headed three-run capture, and dedicated validator
- active retained R1B boundary-recovery capture and retained behavioral-proof validator
- R1D headed-startup validator after its narrow R1F allowlist extension
- R1B legacy timer diagnostic, explicitly historical and inactive
- R1 navigation-repair smoke
- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npm run validate:artifact-retention`
- `npm run godot:all`
- `git diff --check`

The remaining dirty paths are pre-existing/generated work outside the R1F scope and were preserved. Only the R1F source, reports, validator wiring, and dedicated review pack are intended for the publication commit.

## 2026-07-31 — R1F-V1 retained-validator descendant compatibility

The retained navigation-behavior validator was found to require the obsolete exact base `6b14ba305afc4b3090d57f400da885550d512183` after the accepted documentation descendant `dbdac3a179c54b4b7a3227475b3b99c7b810f26f`. R1F-V1 repairs that tooling contract only: it validates real Git ancestry, exact branch/run/source provenance, and an explicit documentation/review-pack descendant allowlist while preserving all original physics and integrity checks. A pure ten-case matrix and three fresh headed R1F runs at the current descendant HEAD pass. No R1G or R1C work was resumed. See `docs/V0436_R1F_V1_RETAINED_VALIDATOR_DESCENDANT_COMPATIBILITY_REPORT.md` and `artifacts/manual-review/v0436-r1f-v1-retained-validator-descendant-compatibility/`.
