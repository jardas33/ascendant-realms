# v0.10 Tutorial E2E Lane Review

Date: 2026-05-11

Scope: Tutorial / Proving Grounds browser coverage after v0.10 copy, overlay, and completion-clarity changes.

This review changes no tests, scripts, gameplay, tutorial steps, rewards, persistence, maps, units, factions, or campaign progression. It records lane placement and the decision to preserve existing coverage.

## Current E2E Suite Shape

`npx playwright test --list` reports 67 tests across 4 spec files:

- `tests/e2e/smoke.spec.ts`: 12 tests.
- `tests/e2e/layout.spec.ts`: 25 tests.
- `tests/e2e/deep-flow.spec.ts`: 28 tests.
- `tests/e2e/enemy-pressure.spec.ts`: 2 tests.

The repo scripts remain:

- `npm run test:e2e:smoke`
- `npm run test:e2e:layout`
- `npm run test:e2e:deep`
- `npm run test:e2e:release`
- `npm run test:e2e:release:shard1`
- `npm run test:e2e:release:shard2`
- `npm run test:e2e:release:shard1of3`
- `npm run test:e2e:release:shard2of3`
- `npm run test:e2e:release:shard3of3`

## Tutorial Coverage By Lane

### Smoke-Critical

`tests/e2e/smoke.spec.ts` contains three tutorial-relevant checks:

- `main menu boots`: verifies the Tutorial entry exists.
- `tutorial entry launches a no-reward shell and returns to menu`: verifies launch mode, map/source, rewards-disabled launch, Aster transient hero data, full twelve-step completion, no localStorage save, no hero XP/runtime XP from safe pressure, final no-reward copy, completion notice, and New Campaign next-step copy.
- `tutorial exit returns to menu without saving`: verifies Exit Tutorial returns to the main menu, does not show the completion notice, and does not create a save.

These remain smoke-critical because they protect the tutorial's public entry point and its most important safety contract: no rewards, no persistence, no campaign progress.

### Layout-Only

`tests/e2e/layout.spec.ts` contains four tutorial viewport checks:

- desktop;
- tablet-short;
- mobile-tall;
- mobile-short.

Each check launches the tutorial, verifies the first objective overlay, verifies no horizontal overflow, keeps the overlay in viewport, keeps tutorial overlay priority above battle-status feedback, checks readable overlay width, verifies Next Objective and Exit Tutorial are reachable, and verifies the battle command panel remains within viewport width.

These stay in the layout lane because they are responsive/readability checks rather than core smoke flow checks.

### Release-Critical

`npm run test:e2e:release` includes the smoke lane, the layout lane, the deep-flow lane, and enemy-pressure coverage.

Release-critical tutorial-related coverage includes:

- full tutorial completion inherited from smoke;
- tutorial exit inherited from smoke;
- responsive tutorial overlay coverage inherited from layout;
- pressure-plan isolation from `tests/e2e/enemy-pressure.spec.ts`, which verifies tutorial and skirmish launches do not activate campaign pressure plans.

### Deep-Only

There is no dedicated Tutorial / Proving Grounds test in `tests/e2e/deep-flow.spec.ts`.

Deep-flow still supports tutorial confidence indirectly through the first campaign battle path, which exercises capture, building, training, rally, battle victory, rewards, and save behavior in the campaign context. That is intentionally not a replacement for tutorial smoke because campaign rewards and tutorial no-reward policy are different contracts.

## Lane Decision

Keep full Tutorial / Proving Grounds completion in smoke for v0.10.

Reasons:

- v0.10 touched tutorial copy, overlay hierarchy, completion notice copy, and smoke assertions.
- The latest v0.10 smoke pass remains inside the watch band: Phase 5 smoke passed 12 tests in about 4.9m.
- Full completion protects no-save/no-reward behavior better than a launch-only smoke test.
- Release and shard lanes inherit smoke coverage, so removing full completion from smoke now would reduce frequent safety feedback.

## v0.10 Phase 6 Verification

- `npm test`: PASS, 46 files / 351 tests.
- `npm run build`: PASS with the known Phaser vendor chunk-size warning.
- `npm run validate:content`: PASS.
- `npm run validate:art-intake`: PASS.
- `npm run test:e2e:smoke`: PASS, 12 tests in about 4.8m.
- `npm run test:e2e:release`: PASS, 67 tests in about 28.0m.
- `git diff --check`: PASS.

## No Script Changes

No package scripts changed in this phase.

No tests were moved.

No coverage was removed.

## Future Move Criteria

A later goal may move full tutorial completion from smoke to release/deep only if all of the following are true:

- smoke repeatedly grows beyond the 6-7 minute watch band on a stable local machine;
- a separate smoke test still launches Tutorial / Proving Grounds and exits without saving;
- full tutorial completion still runs in release/deep;
- no-save/no-reward assertions remain covered;
- the move is documented in README, release checklist, and handoff.

## Human Review Gap

E2E coverage does not prove the tutorial feels short, fun, or clear to a first-time player. Manual play remains required for pacing, confusion, mobile comfort, and completion satisfaction.
