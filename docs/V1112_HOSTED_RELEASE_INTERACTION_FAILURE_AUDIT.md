# v0.11.12 Hosted Release Interaction Failure Audit

Date: 2026-05-15

Scope: hosted GitHub Actions release-matrix interaction determinism only. This audit does not change gameplay, content, saves, save format, campaign progression, tutorial behavior, balance, visual assets, runtime art, or release coverage strength.

## Purpose

v0.11.11 moved the manual hosted release groups from Vite dev server to production preview and added hosted Chromium launch args. That removed the largest server-environment risk from the release matrix, but GitHub Actions run #19 still failed several hosted groups.

The new failure shape is different from v0.11.10/v0.11.11. Hosted production preview boots far enough for `deep-meta` to pass, while remaining failures cluster around actionability, DOM button delivery, canvas right-click delivery, battle-loaded readiness, and layout measurement during HUD refreshes.

## Remote Evidence

Workflow: `CI Release Matrix Dry Run`

Manual run: `CI Release Matrix Dry Run #19`

Commit: `8c12738` or latest v0.11.11 commit

Results:

- Fast confidence: PASS.
- Release simulator: PASS.
- Release matrix `deep-meta`: PASS.
- Release matrix `deep-battle`: FAIL.
- Release matrix `deep-campaign-pressure`: FAIL.
- Release matrix `layout-core`: FAIL.
- Release matrix `layout-cinderfen`: FAIL.
- Release matrix `smoke`: FAIL.

## Failure Families

### deep-battle

`battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions`

Failure A: Playwright timed out clicking:

```text
button[data-action='build'][data-id='barracks']
```

The locator resolved to the Build Barracks button, then stayed in Playwright actionability waiting for visible/enabled/stable.

Failure B: the movement command still sometimes asserted:

```text
expected Moving
received Guarding
```

This indicates hosted Chromium did not always deliver the canvas right-click to a safe traversable point, or the selected unit was no longer the intended unit when the command was issued.

### deep-campaign-pressure

`tutorial and skirmish launches do not activate pressure plans`

The test failed in `expectBattleLoaded` waiting for:

```text
getByTestId('minimap')
```

That points to battle readiness alignment, not a weakened minimap requirement. The hosted wait should use the strongest shared battle-loaded contract.

### layout-core

Tutorial layout tests failed when reading a layout box for `tutorial-next`:

```text
mobile-tall tutorial next has a layout box
Received null
```

The tutorial overlay and button are real UI, but hosted production preview can measure during a HUD refresh. Layout tests should wait for overlay/button visibility and a non-null layout box before measuring.

### layout-cinderfen

`expectBattleCommandButtonsReachable` timed out inside `page.evaluate` while checking side-panel command buttons.

The layout check was doing too much in one page evaluation while the battle scene and HUD were still active. It needs side-panel readiness, smaller per-button checks, scroll-aware measurement, and diagnostics.

### smoke

Tutorial entry hung clicking `tutorial-next`. Playwright reported the element visible, enabled, stable, and scrolled into view, but the click still consumed the test timeout.

This is a hosted Chromium DOM click delivery problem on a real button. The test can safely use a test-only DOM click fallback only after verifying that the real enabled control exists, is visible, has a layout box, and is not covered.

## Interpretation

Run #19 is not primarily a sharding or server-boot failure:

- Hosted release now uses production preview.
- `deep-meta` passed.
- Fast confidence and release simulator remain green.
- Failures occur after app boot, around real UI/canvas interactions and active battle HUD refreshes.

The fix should therefore harden the test interaction layer:

- keep hosted release groups on production preview
- keep release coverage equivalent
- keep assertions intact
- make DOM button clicks resilient when Playwright actionability hangs on real visible controls
- strengthen shared battle-loaded waits
- make layout measurements retry around HUD refreshes
- make canvas movement right-clicks verify selection and safe canvas points before preserving the `Moving` assertion

## Must Not Change

- Do not delete or skip release tests.
- Do not weaken behavior assertions.
- Do not force-click canvas/world interactions.
- Do not fake battle state or tutorial state.
- Do not hide browser console errors.
- Do not change gameplay, content, saves, tutorial behavior, campaign progression, balance, visual assets, runtime art, or release coverage strength.
