# v0.436-R1B Boundary Recovery Proof

## Verdict

`PASSED_NAVIGATION_BEHAVIORAL_PROOF` for the isolated boundary-recovery case. This is a bounded follow-up to v0.436-R1A, not a full conquest capture and not v0.437.

The proof demonstrates that a real production `Unit` placed outside the playable boundary before the fixture begins enters the existing production recovery state, moves back into bounds without post-start position writes or teleport displacement, emits the real recovery events, and is cleaned up without contaminating the normal match.

## Scope and base

- Repository: `D:\Code for projects\WB game like\ascendant-realms-v0223-recovery`
- Branch: `codex/v0436-first-complete-conquest-victory`
- Required base HEAD: `ed7a66a05d8d7750ba5f8e7f0d4124c6eb40c2b2`
- Capture source SHA recorded in the proof: `ed7a66a05d8d7750ba5f8e7f0d4124c6eb40c2b2` (the required checkpoint input)
- Fixture mode: opt-in `ASCENDANT_V0436_R1_CAPTURE=1` plus `ASCENDANT_V0436_R1_BOUNDARY_ONLY=1`
- Full conquest capture: deliberately not run
- Next checkpoint: deliberately not started

The checkout began with the required branch and base HEAD, `0/0` ahead/behind, six pre-existing tracked modifications, and 516 pre-existing untracked paths. Those user-owned paths remain outside this scoped change and were not reset, restored, or staged.

The validator accepts evidence provenance against either the required base input SHA or the eventual publication HEAD. This keeps the evidence tied to the requested checkpoint base while allowing the validator to run after the evidence/report publication commit.

## Isolated fixture architecture

The harness creates a dedicated `V0436R1BoundaryFixtureContainer` under the production navigation region and adds one real `Unit` instance using the production `barrosan_worker` definition. The fixture unit receives exactly one pre-tree `position` assignment at `x=140`, while the active map bound is `x=136` with a two-metre recovery tolerance. It is not added to the commander roster, population, economy, or AI wave roster. Existing AI processing is suspended only for the fixture window and restored afterward.

The only production source repair is removal of the premature `distance <= 0.2` early return in `unit.gd`'s existing `_state_boundary_recovery` state. That return could leave a unit just outside the hard bound without completing recovery. The existing recovery state, safe target, speed limit, telemetry, and completion events remain the semantic path.

## Boundary telemetry

From `artifacts/manual-review/v0436-r1a-navigation-behavioral-proof/v0436-r1a-navigation-behavioral-proof.json`:

- initial position: `(140, 0, 0)`
- hard map bounds: `x/z ±136`
- recovery tolerance: `2`
- initial outside distance: `4`
- recovery target: `(136, 0, 0)`
- final position: `(135.980163574219, 0, 0)`
- travelled distance: `4.01983642578125`
- production move speed: `3.6`
- maximum sampled speed: `4.11747951133578`, allowed `5.4`
- maximum single-frame displacement: `0.65997314453125`, allowed `1.35`
- post-start position writes: `0`
- initial transform assignments: `1`
- recovery started: `boundary_recovery_started`
- recovery completed: `boundary_recovery_completed`
- non-finite position: `false`
- material outward drift: `false`
- terminal failure: `false`
- contamination-free: `true`
- cleanup confirmed: `true`
- normal match units quiesced for the fixture: `14`

The recovery event timestamps are `87472` and `89218`, a measured interval of `1746 ms` in the headed capture. The unit moves through progressive runtime samples; it is not snapped to the final position.

## Evidence pack

Review pack:

`artifacts/manual-review/v0436-r1a-navigation-behavioral-proof/`

The pack contains the existing R1A production behavior frames plus the R1B boundary frames and regenerated contact sheet:

- `19_BOUNDARY_RECOVERY_UNDERWAY.png` is a real rendered frame showing the real worker outside the playable edge, active recovery, the recovery event, zero post-start position writes, and the speed contract.
- `20_BOUNDARY_RECOVERY_COMPLETE.png` is a real rendered frame showing the same worker inside the playable edge, completed recovery, zero post-start position writes, and measured travel/speed telemetry.
- `22_NAVIGATION_BEHAVIORAL_CONTACT_SHEET.png` is the regenerated 4-by-6 sheet containing all 22 real gameplay captures. The two unused final grid cells are intentionally dark empty slots; they are not presented as evidence frames.
- `v0436-r1b-boundary-recovery-proof.json` is the boundary-specific runtime proof.
- `v0436-r1a-navigation-behavioral-validation.json` is the fail-closed dedicated validator output, now schema `v0436-r1b-navigation-behavioral-validator-v1`, with zero failures.

The individual boundary images were visually inspected and are nonblank real runtime captures, not title cards, blank frames, or fabricated overlays without the production unit.

## Preserved behavior and safety

- R1A ordinary move, construction, gathering/deposit, military move, attack-move, pursuit, invalid-target, and navigation-readiness evidence remains in the same pack.
- The fixture does not mutate commander resources, population, roster, match result, pressure, AI wave state, or production state.
- AI processing is restored exactly after the fixture.
- The fixture node is absent after cleanup.
- The normal match is quiesced only during the isolated fixture window so unrelated economy ticks cannot contaminate the boundary ledger.
- No full conquest capture was run, so natural conquest/result/replay remains a separate open backlog item.

## Commands and results

Focused R1B proof:

`npm run godot:test:v0436-r1-boundary-recovery` — passed.

Full headed R1A/R1B capture:

`npm run godot:capture:v0436-r1-navigation-behavior` — passed and wrote the 22-frame pack.

Dedicated validator:

`npm run godot:validate:v0436-r1-navigation-behavior` — passed with `failures: []` and `runtimeStatus: PASSED_NAVIGATION_BEHAVIORAL_PROOF`.

The retained R1 repair focused tests, smoke, validator, and v0.436 conquest focused tests/smoke passed. The historical v0.432-v0.435 validators were executed truthfully; they fail only their older branch or capture-provenance contracts on this later branch, with no validator weakening:

- v0.435: branch and capture match-contract metadata mismatch
- v0.434: branch and capture provenance mismatch
- v0.433: branch mismatch
- v0.432: branch mismatch

The remaining repository validation commands are run as part of this closeout and are recorded in the final publication evidence and exact-SHA CI result.

## Publication and final state

The scoped R1B source, validator, evidence, report, and backlog amendment are committed separately from the preserved user-owned worktree paths. The exact publication SHA and GitHub Actions run are recorded after push; no clean-tree claim is made because the six pre-existing tracked modifications and 516 pre-existing untracked paths are intentionally preserved.

## Remaining boundary

This closes the focused navigation behavioral proof only. `P0-RESULT-001` remains open for a real natural conquest victory/result/replay capture. No v0.437 work is included or implied.
