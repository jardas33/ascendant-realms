# v0.436-R1A Navigation Behavioral Proof

Status at the original R1A publication: `BLOCKED_EXACT_BEHAVIORAL_PROOF`.

R1B amendment: the previously missing isolated boundary fixture is now present and passes the dedicated real-`Unit` proof. The original blocked status remains preserved historically; the current focused R1A/R1B behavioral result is recorded in `docs/V0436_R1B_BOUNDARY_RECOVERY_PROOF_REPORT.md`.

This checkpoint is intentionally fail-closed. The real headed production capture proves the supported navigation behaviors listed below, but the required isolated out-of-bounds boundary-recovery fixture is not present in the accepted production setup. The checkpoint must not be described as passed until that fixture exists and produces truthful evidence.

## Scope and boundary

The checkpoint stays on branch `codex/v0436-first-complete-conquest-victory`, based on `9e9312560bccd1c04aee8ff39f8677074c30b10f`. It does not start v0.437 and does not run the full v0.436 conquest capture. The capture is opt-in through `ASCENDANT_V0436_R1_CAPTURE=1`; the true default runtime and existing conquest path remain unchanged.

No position, HP, resource, timer, AI, wave, victory, or match-result state is written by the evidence harness. All tested actions are issued through the public production command APIs.

## Implementation

- `production/ascendant-realms-godot/tests/v0436_r1_navigation_behavioral_proof.gd` is the headed runtime harness.
- `production/ascendant-realms-godot/scripts/world/game_root.gd` starts that harness only for the opt-in environment flag.
- `production/ascendant-realms-godot/scripts/main_menu.gd` routes the opt-in capture directly into the real game scene while leaving the ordinary main menu path intact.
- `production/ascendant-realms-godot/project.godot` registers the test-only capture autoload.
- `tools/godot/v0436R1NavigationBehavioralProofTool.mjs` performs source, evidence, frame, and fail-closed validation.
- `package.json` exposes both the proof command names and the exact `...:behavior` aliases requested for this checkpoint.
- `docs/ASCENDANT_REALMS_MASTER_PLAYER_EXPERIENCE_BACKLOG.md` records the durable P0-P4 player-experience issues and evidence-audit boundary.

## Real headed evidence

The review pack is:

`artifacts/manual-review/v0436-r1a-navigation-behavioral-proof/`

It contains 22 real gameplay-scale PNG captures, a contact sheet, runtime logs, preflight metadata, capture-command metadata, and the proof JSON. The evidence is not title-card or black-frame evidence. The required boundary frames are present as rendered context captures, but they are explicitly rejected as proof because no supported isolated out-of-bounds fixture was used.

Runtime proof JSON:

`artifacts/manual-review/v0436-r1a-navigation-behavioral-proof/v0436-r1a-navigation-behavioral-proof.json`

Observed status: `BLOCKED_EXACT_BEHAVIORAL_PROOF`.

Passed real behaviors:

- navigation map readiness, RID/region/iteration evidence, and an early command deferred before readiness;
- ordinary move with meaningful travel and progressive position samples;
- worker arrival in construction range and real War Hall completion;
- worker gather, return, and one real player deposit transaction;
- military move with meaningful distance and arrival;
- mixed-group attack-move progress and battlefield crossing;
- moving-target pursuit progress with a stable target contract;
- invalid-target rejection with bounded/safe terminal handling.

Failed behavior:

- `boundary_recovery`: blocked because no supported isolated out-of-bounds fixture exists in the accepted production setup; no position was written by this proof. The harness records this exact reason instead of fabricating a pass.

## Required commands

Exact v0.436-R1A commands:

- `npm run godot:test:v0436-r1-navigation-behavior`
- `npm run godot:smoke:v0436-r1-navigation-behavior`
- `npm run godot:capture:v0436-r1-navigation-behavior`
- `npm run godot:validate:v0436-r1-navigation-behavior`

Retained commands:

- `npm run godot:test:v0436-r1-navigation-repair`
- `npm run godot:smoke:v0436-r1-navigation-repair`
- `npm run godot:validate:v0436-r1-navigation-repair`
- `npm run godot:test:v0436-conquest-victory`
- `npm run godot:smoke:v0436-conquest-victory`
- `npm run godot:validate:v0435-easy-ai-wave`
- `npm run godot:validate:v0434-combat`
- `npm run godot:validate:v0433-worker-economy`
- `npm run godot:validate:v0432-war-hall-production`
- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npm run validate:artifact-retention`
- `npm run godot:all`
- `git diff --check`

The dedicated validator now requires the runtime status to be exactly `PASSED_NAVIGATION_BEHAVIORAL_PROOF`; a blocked runtime result cannot be reported as green merely because the JSON is structurally valid.

## What is deliberately not included

There is no full conquest capture, no balance or economy change, no AI or wave change, no new movement semantics, no combat redesign, no HUD/portrait/minimap/wording redesign, and no unrelated visual work. The missing boundary fixture remains a concrete follow-up blocker for this proof gate.

## Closeout condition

The checkpoint can close only after a supported isolated fixture starts slightly out of bounds before the fixture begins, then demonstrates recovery or a truthful terminal failure without position writes after fixture start, and the validator plus exact-SHA CI pass. Until then, the honest status is `BLOCKED_EXACT_BEHAVIORAL_PROOF`.

## Validation and publication evidence

Local results for this commit:

- focused R1 navigation repair tests, smoke, and validator: passed;
- v0.436 conquest focused tests and smoke: passed; full conquest capture was not run;
- `npm test`: 887 tests passed;
- `npm run build`: passed;
- content, art-intake, runtime-art-slot, artifact-retention, `npm run godot:all`, and `git diff --check`: passed;
- dedicated R1A behavioral validator: failed closed on `runtime status BLOCKED_EXACT_BEHAVIORAL_PROOF`;
- retained v0.432-v0.435 validators were executed and failed only their historical branch/capture-provenance contracts on this later branch. No source repair was made to weaken those validators.

Published commit: `8ae52b125ea1d2492a3e8510c289bc14319311fc`.

Exact GitHub Actions proof: run `30594187115` completed `success` for that exact SHA.

The checkout intentionally retains pre-existing user-owned tracked and untracked work outside this scoped commit. The R1A commit itself contains only the opt-in proof wiring, validator, report/backlog, and dedicated review pack.
