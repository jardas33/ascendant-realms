# v0.10 Tutorial Overlay Refinement Notes

Date: 2026-05-11

Scope: small Tutorial / Proving Grounds overlay hierarchy refinement after v0.10 copy changes.

This phase changes only the tutorial overlay's visual hierarchy. It does not relocate the HUD, add panels, add animations, change gameplay, change tutorial steps, change rewards, add persistence, change campaign progression, add art, or redesign the UI.

## Evidence Reviewed

- Existing `visual-qa/latest/tutorial-desktop.png`.
- Existing `visual-qa/latest/tutorial-mobile.png`.
- `docs/V082_EXTENDED_SCREENSHOT_QA_REVIEW.md`.
- `docs/TUTORIAL_READABILITY_SURROGATE_REVIEW.md`.
- Current tutorial overlay renderer and `battle-feedback.css`.
- Existing layout e2e guards for overlay viewport fit, Exit Tutorial reachability, command-panel width, and overlay priority above battle-status feedback.

## Observations

- Desktop launch is readable and leaves the main playfield, resources, minimap, hero panel, selected-unit panel, and command panel visible.
- Mobile launch is width-safe but dense. The overlay fits, while the minimap, objectives, resource row, selected-unit panel, and hero panel all compete for the narrow viewport.
- The overlay should stay a single compact surface. Moving it or redesigning the HUD would create more risk than the copy update needs.
- The footer had equal-weight Next Objective and Exit Tutorial buttons. That made the forward action and escape action harder to scan quickly.

## Changes

- Added `tutorial-primary` to the Next Objective / Complete Tutorial button.
- Added `tutorial-secondary` to the Exit Tutorial button.
- Slightly strengthened tutorial panel opacity and instruction/hint readability.
- Kept all test ids, aria labels, step ids, layout positioning, z-index relationship, and button sizes intact.

## Expected Player Benefit

- The next tutorial action reads as the primary action.
- Exit Tutorial remains reachable without visually competing as strongly with the forward action.
- Mobile overlay text has a little more contrast against dense battlefield HUD elements behind it.

## Verification Plan

Phase 4 must pass:

- `npm test`;
- `npm run build`;
- `npm run validate:content`;
- `npm run validate:art-intake`;
- `npm run test:e2e:smoke`;
- `npm run test:e2e:layout`;
- `npm run visual:qa`;
- `git diff --check`.

## Verification Result

Phase 4 passed:

- `npm test`: PASS, 46 files / 351 tests.
- `npm run build`: PASS with the known Phaser vendor chunk-size warning.
- `npm run validate:content`: PASS.
- `npm run validate:art-intake`: PASS.
- `npm run test:e2e:smoke`: PASS, 12 tests in about 4.6m.
- `npm run test:e2e:layout`: PASS, 25 tests in about 12.5m.
- `npm run visual:qa`: PASS, 1 capture test in about 3.2m.

Refreshed visual QA generated 18 screenshots and recorded no browser console errors. The refreshed tutorial screenshots show the v0.10 `Find Your Army` first step on desktop and mobile. The mobile capture remains dense, but the overlay, Next Objective, Exit Tutorial, selected-unit panel, hero panel, minimap, and resource row remain visible and reviewable.
