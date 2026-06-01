# v0.95 Visual QA Report

## Scope

v0.95 extends visual QA around battle readability:

- ordinary battle start;
- fog, roads, and water;
- selected hero, Worker, melee, ranged, enemy, and building;
- neutral, player, enemy, contested, selected, and objective capture-site states;
- Lume Auto, Hidden, and Always modes;
- minimap readability;
- 1920x1080, 1600x900, and 1366x768 desktop viewports.

## Acceptance

- No new imported art or generated images.
- No hidden primary battle controls.
- No HUD/minimap/objective collision.
- No screenshot retries.
- No browser console errors.
- Labels remain readable where important and quieter where routine.
- Fog and terrain appear as intentional placeholder presentation, not debug blocks.

## Latest Run

`npm run visual:qa` passed after the v0.95 coverage expansion.

- Tests: 11 passed.
- Screenshots: 102.
- Browser console errors: 0.
- Screenshot retries: 0.
- New v0.95 screenshots: 18.
- Target desktop viewports covered: 1920x1080, 1600x900, 1366x768.

Sampled manually during implementation:

- `artifacts/visual-qa/latest/v095-ordinary-battle-start-1920.png`.
- `artifacts/visual-qa/latest/v095-selected-worker-1600.png`.
- `artifacts/visual-qa/latest/v095-site-contested-1366.png`.
- `artifacts/visual-qa/latest/v095-lume-always-1366.png`.

Non-pass evidence: an intentional targeted grep run captured only the v0.95 group and failed the global afterAll screenshot-count check because the rest of the suite was filtered. The final unfiltered visual-QA run captured the full 102-screenshot set successfully.

## Visual Review Pack

`npm run visual:review-pack` passed after visual QA.

- Output: `artifacts/visual-review/latest/`.
- Screenshots: 102.
- Contact sheets: 7.
- Target viewports: 1920x1080, 1600x900, 1366x768.
