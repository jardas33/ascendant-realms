# Tutorial E2E Runtime Review

Date: 2026-05-08

Status: v0.6 lane-placement review after tutorial copy, layout, and no-reward completion polish.

## Scope

This review checks whether Tutorial / Proving Grounds browser coverage is still placed in the right Playwright lanes. It does not remove coverage, change gameplay, change tutorial behavior, alter save data, add rewards, add maps, add units, add factions, or change campaign progression.

## Current Tutorial E2E Coverage

| Lane | Tutorial coverage | Current role |
| --- | --- | --- |
| `npm run test:e2e:smoke` | Tutorial button visible through main-menu boot; full no-reward twelve-step tutorial completion; session-only completion notice; no localStorage save; no hero/runtime XP from pressure; separate Exit Tutorial path with no save. | Frequent browser gate for onboarding safety and save-pollution protection. |
| `npm run test:e2e:layout` | Tutorial entry and first objective overlay across desktop, tablet-short, mobile-tall, and mobile-short; overlay width guard; overlay/buttons within viewport; command panel width-safe. | Responsive/readability guard for HUD and overlay polish. |
| `npm run test:e2e:release` | Includes smoke, layout, and deep-flow specs. | Full release/checkpoint gate. |
| `npm run test:e2e:release:shard1` | Includes the layout/deep-heavy side of the full release gate. | CI matrix shard, currently the slow shard. |
| `npm run test:e2e:release:shard2` | Includes the smoke-heavy side of the full release gate. | CI matrix shard, currently the fast shard. |

## Latest Runtime Evidence

Recent runs from this v0.6 pass:

```text
Phase 2 smoke after copy polish
PASS: 12 tests in 5.2m.

Phase 3 focused tutorial layout
PASS: 4 tests in 44.4s.

Phase 3 full smoke
PASS: 12 tests in 5.0m.

Phase 3 full layout
PASS: 25 tests in 13.0m.

Phase 4 focused tutorial smoke
PASS: 2 tests in 37.8s.

Phase 4 full smoke
PASS: 12 tests in 5.1m.
```

Baseline final tutorial-shell release evidence from the prior gate:

```text
npm run test:e2e:release
PASS: 65 tests in 28.5m.

npm run test:e2e:release:shard1
PASS: 53 tests in 24.4m.

npm run test:e2e:release:shard2
PASS: 12 tests in 4.9m.
```

The smoke lane remains near the existing 5-minute target. The layout lane remains the larger responsive gate, and shard 1 remains uneven because it carries the deep-flow and layout-heavy tests.

## Placement Decision

Decision: keep the full Tutorial / Proving Grounds completion path in smoke for now.

Reasons:

- The tutorial is the current onboarding vertical slice, so completion should fail fast during ordinary browser checks.
- The full completion test is also the strongest no-save/no-XP/no-reward browser assertion.
- The smoke lane remains acceptable at roughly 5.0-5.2 minutes after the v0.6 polish work.
- Moving completion out of smoke now would reduce confidence just as copy/layout/completion behavior is being hardened.
- The release lane is already slower because of layout and deep-flow tests, not because tutorial smoke alone dominates the suite.

No lane adjustment is recommended in this phase.

## When To Move Completion Out Of Smoke

Move the full tutorial completion path to deep/release only if one of these becomes true:

- Smoke grows materially beyond 6-7 minutes on repeated local runs.
- The tutorial completion path gains more steps or heavier real-time waits.
- A command-log helper makes a deeper release-only tutorial replay more readable while preserving a lightweight smoke launch/exit test.
- Flakiness appears in full tutorial completion but launch/exit remains stable.

If that happens, keep at least one smoke test that:

- Verifies the Tutorial button is visible.
- Launches Tutorial / Proving Grounds.
- Shows the tutorial overlay.
- Exits to the main menu.
- Confirms no save/localStorage pollution.

Then keep full completion in either `test:e2e:deep` or `test:e2e:release` so coverage is preserved.

## Command-Log V1 Implication

The upcoming test-only semantic command-log V1 can improve readability of the current completion test. It should not be used as a reason to delete assertions.

Recommended first use:

- Keep the tutorial completion test in smoke.
- Use command-log records to make the high-level sequence explicit.
- Preserve visible assertions for no save, no XP, no campaign progress, completion notice, and return-to-menu behavior.

## Risks

- Smoke remains dependent on a broad test that uses safe scene hooks for time-heavy tutorial steps.
- Shard 1 remains the slow shard because of layout/deep-flow concentration.
- If future tutorial polish adds more browser assertions, smoke could cross the 6-7 minute watch band.
- Moving coverage too early would hide regressions in the current highest-priority onboarding path.

## Recommendation

Keep the current lane placement through v0.6:

- `smoke`: full tutorial completion plus exit path.
- `layout`: responsive first-overlay checks.
- `release`: full browser suite.
- `shards`: unchanged CI split.

Revisit after command-log V1 and after one human-paced tutorial playtest.
