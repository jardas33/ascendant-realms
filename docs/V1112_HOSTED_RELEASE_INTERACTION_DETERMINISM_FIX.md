# v0.11.12 Hosted Release Interaction Determinism Fix

Date: 2026-05-15

Scope: hosted GitHub Actions release-matrix interaction determinism only. No gameplay, content, save, tutorial behavior, campaign progression, visual asset, runtime art, balance, or release coverage changes are included.

## Summary

v0.11.12 keeps the v0.11.11 production-preview hosted release environment and hardens the test-only interaction/readiness layer exposed by GitHub Actions run #19.

The fix is aimed at real hosted failures:

- DOM buttons that are visible/enabled but whose Playwright click can hang while Phaser/HUD markup refreshes.
- Tutorial `Next Objective` advancing through a frequently re-rendered HUD panel.
- Battle-loaded waits that were weaker in some specs than the shared release helper.
- Layout checks that measured overlay or side-panel boxes during active HUD refreshes.
- Canvas right-click movement commands that need selected-unit and safe-point verification before keeping the `Moving` assertion.

## GitHub Run #19 Evidence

Remote evidence from Emmanuel:

- `Fast confidence`: PASS.
- `Release simulator`: PASS.
- `Release matrix (deep-meta)`: PASS.
- `Release matrix (deep-battle)`: FAIL.
- `Release matrix (deep-campaign-pressure)`: FAIL.
- `Release matrix (layout-core)`: FAIL.
- `Release matrix (layout-cinderfen)`: FAIL.
- `Release matrix (smoke)`: FAIL.

Representative failures:

- Build Barracks button click timed out on `button[data-action='build'][data-id='barracks']`.
- Battle movement assertion still sometimes saw `Guarding` instead of `Moving`.
- Enemy-pressure battle launch waited forever for `minimap`.
- Tutorial layout measured a null `tutorial-next` layout box.
- Side-panel command reachability timed out inside `page.evaluate`.
- Smoke tutorial `tutorial-next` click hung even after Playwright reported the button visible/enabled/stable.

## Click Helper Changes

`tests/e2e/shared-helpers.ts` now treats `clickReady` as the central test-only DOM button interaction helper:

- waits for attached, visible, and enabled state
- optionally waits for a layout box
- scrolls the target into view
- attempts a normal Playwright click first
- retries transient actionability failures
- after a transient click/actionability failure, uses a verified DOM fallback only for real DOM controls

The DOM fallback is intentionally narrow. It:

- uses the locator's current live DOM matches
- chooses a real control (`button`, `a`, form controls, or `[role=button]`)
- verifies computed visibility and non-zero layout
- verifies not disabled and not `aria-disabled`
- verifies the center point is not covered by another control
- clicks the same verified control in the same page evaluation
- logs `normal click failed; using verified DOM click fallback`

The fallback is not used for canvas/world clicks. Behavior is still proven by the post-click assertions in each test.

## Targeted Raw Click Replacements

Only hosted-problem or related DOM UI action points were routed through `clickReady`, including:

- smoke tutorial semantic command-log `tutorial-next` executor
- smoke tutorial completion and tutorial exit
- smoke settings/skirmish setup and Cinderfen campaign buttons that are part of hosted smoke release coverage
- enemy-pressure tutorial/skirmish launch controls
- deep-flow campaign/skirmish setup controls
- deep-flow Build Barracks and Train Militia HUD command buttons at hosted failure points
- layout tutorial launch/menu/campaign/setup navigation buttons
- Chapter 2 helper campaign choice/start controls used by Cinderfen hosted groups

The change does not blanket-rewrite every e2e click and does not add force-clicks.

## Battle-Loaded Waits

The strongest battle-loaded readiness check now lives in `shared-helpers.ts` and is reused by deep-flow, smoke, layout, enemy-pressure, and Chapter 2 helper paths.

It waits for:

- `battle-hud`
- `battle-resources` with `Crowns`
- `battle-hero-panel`
- `battle-minimap`
- `minimap`
- Phaser `canvas`
- active `BattleScene` with hero, active map, runtime, and game canvas

The minimap assertion remains required.

## Tutorial Layout Readiness

Layout tutorial launch now waits for:

- battle-loaded readiness
- tutorial overlay visible
- `tutorial-next` visible and enabled
- a non-null layout box before viewport checks

The tutorial smoke semantic command path uses a shorter normal-click probe for `tutorial-next`, then the verified DOM fallback, because hosted Chromium repeatedly sees this button detach during HUD refreshes. The test still checks every expected tutorial title/progress/text transition and the final no-save/no-reward state.

The long tutorial smoke has a scoped 95s test budget because the full semantic command replay now preserves real state assertions while defending every `tutorial-next` transition against hosted actionability stalls. The final `Complete Tutorial` button also has an explicit post-click main-menu wait/retry so a transient hidden/stale button cannot count as success unless the menu actually appears.

## Side-Panel Readiness

`expectBattleCommandButtonsReachable` now:

- waits for `.side-panel` visibility
- waits until requested action buttons exist
- logs diagnostics if readiness fails
- measures command buttons in small per-button checks instead of one large page evaluation
- scrolls the side panel to the current live command button by action/index
- verifies each command button remains inside the panel, inside the viewport, and large enough

The Cinderfen battle readability test family uses a scoped 120s budget because it verifies two seeded Cinderfen battles and, on mobile portrait, results readability.

## Right-Click Movement

The deep-battle movement helper now:

- ensures a selected non-building player unit immediately before right-clicking
- centers the camera on that unit
- tries safe candidate world points away from UI and obstacles
- verifies the screen point is inside the Phaser canvas and not under HUD before right-clicking
- waits for a movement target near the selected point
- preserves the visible `unit-order-summary` `Moving` assertion

No gameplay movement logic changed.

## Additional Interaction Determinism Fixes

- Battle command buttons use a shorter normal-click probe before verified DOM fallback, then keep post-click state assertions such as placement mode, research state, queue state, or trained unit state.
- Barracks build command clicks in the hosted movement and first-campaign tests retry only when the expected placement-mode state does not appear.
- HUD `Menu` and results `Campaign Map` buttons allow target-disappeared-after-click handling only with follow-up assertions that prove the destination screen appeared.
- The hotkey test keeps Cleave targets alive for the subsequent War Cry hotkey coverage, preserving mana, cooldown, ally buff, and enemy damage assertions.
- The first-campaign rally test uses a safer main-road rally coordinate so pathfinding keeps the rally movement deterministic.
- Layout button reachability restores explicit DOM `scrollIntoView` before bounded layout measurement so long campaign panels work in both hosted preview and the local default release config.

## Coverage Preservation

Release coverage remains equivalent:

- No release tests were deleted.
- No hosted group was excluded.
- No assertion was weakened.
- Local `npm run test:e2e:release` remains intact.
- Hosted release still uses the same explicit groups introduced in v0.11.10 and the production preview config introduced in v0.11.11.

## Verification

Final local verification passed:

```text
npm test: PASS, 46 files / 351 tests
npm run build: PASS, known Phaser vendor chunk-size warning only
npm run validate:content: PASS
npm run validate:art-intake: PASS, 1 candidate metadata JSON / 0 review manifests
npm run test:e2e:smoke:fast: PASS, 6 tests
npm run visual:qa: PASS, 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries
npm run smoke:preview: PASS, 0 browser console errors
npm run playtest:sim: PASS, 255 runs across 85 campaign battle nodes
npm run test:e2e:smoke: PASS, 12 tests
npm run test:e2e:release: PASS, 67 tests
git diff --check: PASS
```

Hosted release groups passed locally under `playwright.hosted-release.config.ts`:

```text
npm run test:e2e:release:hosted:deep-meta: PASS, 12 tests
npm run test:e2e:release:hosted:deep-battle: PASS, 11 tests
npm run test:e2e:release:hosted:deep-campaign-pressure: PASS, 7 tests
npm run test:e2e:release:hosted:layout-core: PASS, 16 tests
npm run test:e2e:release:hosted:layout-cinderfen: PASS, 9 tests
npm run test:e2e:release:hosted:smoke: PASS, 12 tests
```

Targeted hosted repros passed locally:

```text
battle HUD supports minimap movement: PASS, 1 test
battle HUD keeps hovered command buttons stable: PASS, 1 test
tutorial and skirmish launches do not activate pressure plans: PASS, 1 test
tutorial entry and first objective overlay stay readable: PASS, 4 viewport tests
Cinderfen battle HUD and Watch results readability fit desktop: PASS, 1 test
tutorial entry launches a no-reward shell and returns to menu: PASS, 1 test without retry
```

## What Emmanuel Should Rerun

In GitHub Actions, rerun:

```text
CI Release Matrix Dry Run
```

with the manual `run_release_matrix` input.

Check these jobs:

- `Release matrix (deep-meta)`
- `Release matrix (deep-battle)`
- `Release matrix (deep-campaign-pressure)`
- `Release matrix (layout-core)`
- `Release matrix (layout-cinderfen)`
- `Release matrix (smoke)`
- `Release simulator`

If any group fails, capture the first failure, whether a verified DOM fallback log appeared before it, and whether the failure is now app boot, battle-loaded readiness, DOM actionability, canvas movement, layout measurement, or browser/page/context closure.
