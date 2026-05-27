# v0.29.2 Hosted Deep-Battle Fix Report

Date: 2026-05-27
Scope: narrow recovery for the hosted `deep-battle` release-matrix lane. No runtime gameplay files changed.

## Runtime Changed

No.

The fix is limited to hosted Playwright coverage in `tests/e2e/deep-flow.spec.ts`.

## Root Cause

The red hosted lane combined four test-harness problems:

- Absolute-page `page.mouse.click` right-clicks could occasionally deliver no native events even after the target world point mapped to uncovered canvas.
- One retreat assertion depended on the transient `battle-status` message, which the AI status line can legitimately overwrite.
- One hover-stability assertion required identical DOM node identity across HUD refresh, while the player-visible button state remained stable.
- One Worker/resource-site regression let unrelated enemy site pressure contest the player-owned site during the setup window.
- The first post-fix remote matrix still had one stale duplicate movement-summary assertion: after the helper observed `/Moving|Repositioning/`, the final test line waited on the same short-lived `unit-order-summary` text again and saw the normal `Guarding` state.

## Fix

- Right-click world commands now use a Playwright canvas-position click with normal actionability checks and no `force`, after the helper has already verified that the world point is inside the canvas and not covered by HUD.
- World-to-screen conversion now respects camera zoom.
- Movement command retries reselect the original player unit ids and prefer visible, far-enough, ground-safe candidate points.
- Movement verification now requires durable scene state: a matching move target, or measured progress toward the target under explicit move-order combat suppression.
- The behaviour gauntlet no longer asserts the transient `battle-status` text after the retreat order; it asserts the hero's durable move/attack state instead.
- The minimap/fog/move hosted test no longer repeats a second assertion against the transient movement summary after the shared helper has already checked it.
- Marquee cleanup now releases the real mouse again only if the scene still reports an active drag after releasing over the HUD.
- Hosted Worker/site setup parks hostile units away and clears player-site contest progress before testing Worker assignment/upgrades.
- Hover stability now asserts the user-facing state: exactly one Barracks build button, pointer still over it, enabled state, and correct accessible label.

## Guardrail Check

- No new gameplay features.
- No runtime AI/pathing/economy/balance changes.
- No maps, factions, runtime art/assets, or save migration.
- No broad retries.
- No test weakening.
- No force click.
- No DOM fallback for canvas/world clicks.
- DOM-control fallbacks remain limited to existing enabled command buttons.

## Local Evidence

- Targeted behaviour gauntlet before fix: failed without retries in local hosted config.
- Cleaned behaviour gauntlet after fix: `5 passed (6.0m)` with `--repeat-each=5 --retries=0`.
- Audited four-test set after fix: `4 passed (3.3m)` with `--retries=0`.
- Full hosted deep-battle after fix: `27 passed (12.7m)`.
- Full local verification after docs/package metadata updates passed through unit tests, production build, validators, fast/full smoke, controls labs, hosted deep-battle, hosted smoke, hosted deep-campaign-pressure, visual QA, and `git diff --check`.
- Follow-up exact remote-failed test after stale-summary fix: `5 passed (4.4m)` with `--repeat-each=5 --retries=0`.
- Follow-up full hosted deep-battle after stale-summary fix: `27 passed (11.9m)`.

## Remote Evidence

- Push run `26490257582` on first v0.29.2 fix commit `45c7eb1`: Fast confidence passed.
- Manual release-matrix run `26490433401` on `45c7eb1`: checkout, Fast confidence, Release simulator, and hosted groups other than `deep-battle` passed.
- Hosted `deep-battle` in run `26490433401` failed one stale duplicate movement-summary assertion. Follow-up fix is local-only until the next push/manual matrix run.
