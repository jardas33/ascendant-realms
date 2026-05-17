# v0.12.1 Visual QA Review

Date: 2026-05-17

Scope: Phase 7 visual QA review after tiny v0.12.1 copy/readability polish. This was not an art overhaul and did not add or replace any image assets.

## Visual QA Result

`npm run visual:qa` passed:

- 5 Playwright visual QA tests passed.
- 18 screenshots were generated under `visual-qa/latest/`.
- Browser console errors: 0.
- Screenshot retries: 0.

## Visible Improvements

- Skirmish setup, battle status, and results now show `Cinderfen Crossing` and `Cinderfen Watch`, matching the campaign route names a player sees elsewhere.
- Cinderfen Crossing objective text is easier to read in the small objective tracker because the shrine payoff is written as a one-time +20 Aether surge instead of relying on the `Cinder Shrine Surge` label.
- Skirmish defeat guidance no longer shows a campaign-only support action.

## Layout Concerns

- No new screenshot failures, console errors, or retry metadata appeared.
- No obvious layout regression was introduced by the shorter Cinderfen names or revised objective line.
- Existing result panels remain dense, especially when rewards, retinue information, and hero stats are all present.

## Deferred Visual Debt

- Selection rings, command destination markers, attack lines, hit flashes, projectile/status VFX, minimap icon language, map thumbnails, Cinderfen terrain landmarks, shrine/tower silhouettes, and results background/panel art remain future visual-overhaul work.
- Runtime art files and generated art were not touched.
