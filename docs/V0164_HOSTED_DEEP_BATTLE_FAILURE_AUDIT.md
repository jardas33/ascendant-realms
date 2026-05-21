# v0.16.4 Hosted Deep-Battle Failure Audit

Date: 2026-05-20

Scope: audit GitHub Actions CI Release Matrix Dry Run #70 after v0.16.3, where `Release matrix (smoke)` was green and only `Release matrix (deep-battle)` remained red. This audit is limited to the hosted deep-battle timeout and does not start v0.17.

## Remote Evidence

- Run: CI Release Matrix Dry Run #70.
- Actions run id inspected through the GitHub connector: `26194525737`.
- Checked-out commit: `ce2b54a9e23d7dc43e7eb9706ab882dc4e761bfa`, `Checkpoint v0.16.3 hosted smoke pause-resume stabilization`.
- Green jobs: Fast confidence, Release simulator, Release matrix smoke, deep-meta, deep-campaign-pressure, layout-core, and layout-cinderfen.
- Red job: Release matrix deep-battle.
- Failed test: `tests/e2e/deep-flow.spec.ts:1706:3`, `battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions @hosted-deep-battle`.
- Failure: retry #1 hit the 120s test timeout inside `rightClickWorldPointUntilOrder` after repeated logs that the movement command order did not become `Moving`.
- Artifact upload failed because GitHub artifact storage quota was hit, so the connector exposed job logs but not trace/video/error-context downloads.

## Cause Classification

This is not a runtime gameplay regression, browser crash, or release-matrix structure issue.

The `Target page, context or browser has been closed` shape from earlier runs is again a timeout-cleanup consequence when it appears, not the root cause. Run #70's clearer retry failure timed out inside `page.waitForTimeout(250)` after the test had already spent its budget retrying the same movement-order expectation.

The root cause is a test assertion/readiness mismatch in a pressure-heavy hosted battle:

- The helper sent real canvas right-click movement commands.
- The older HUD test required the selected unit order summary to become exactly `Moving`.
- The runtime can validly render the same accepted move command as `Repositioning` when move-order combat suppression is active.
- The same test also had transient status-line assertions for fog and placement cancel. Local trace evidence showed `Enemy scouts are moving.` can occupy the status line while the fog state changes correctly, because pressure messages outrank normal fog debug messages.

## Why Smoke Passed While Deep-Battle Failed

Run #70 showed v0.16.3's smoke fix worked: `Release matrix (smoke)` passed. The remaining failure was in the older hosted deep-battle HUD scenario, which runs a longer battle under enemy pressure and therefore exposes order-summary/status-priority timing that the focused smoke settings test does not cover.

## Why The Behaviour Gauntlet Passed

The dedicated behaviour mode gauntlet already accepted `/Repositioning|Moving/` for the retreat movement order and then asserted `Move order accepted` plus movement state. The older HUD test still required exactly `Moving`, so it was the only lane left with the stale movement-copy assumption.

## Smallest Safe Fix

- Keep the older HUD test and all named coverage.
- Keep real canvas/world clicks.
- Keep the dedicated behaviour mode gauntlet intact.
- Use the same movement-order summary pattern for valid move commands: `Moving` or `Repositioning`.
- Replace transient status-line checks in this hosted deep-battle test with deterministic state checks for the behaviours under test:
  - fog actually active after `F`
  - movement order summary shows movement/repositioning after the real right-click
  - placement state and banner are cleared after Escape

No runtime gameplay, gameplay numbers, save format, runtime art/assets, behaviour modes, package materials, or workflow matrix shape needed to change.

## Assertions Still Protected

- Minimap click still must move the battle camera by more than 10 pixels.
- Fog toggle still must re-enable active battle fog and clear `fogDebugDisabled`.
- Movement still uses a real canvas right-click and must update the selected unit order summary to a movement order.
- Command Hall selection and build button coverage remain unchanged.
- Barracks placement mode still must show the placement banner and hide hint-line noise.
- Escape cancel still must clear pending placement, hide the ghost, and remove the placement banner.
- The dedicated behaviour mode control gauntlet still covers behaviour-mode switching, attack intent, retreat, marquee cleanup, minimap movement, and hero-select refresh.
