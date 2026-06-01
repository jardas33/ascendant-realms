# v0.94 Visual QA Report

## Scope

v0.94 extends visual QA coverage for the presentation rescue surfaces:

- main menu at 1920x1080, 1600x900, and 1366x768;
- Ascendant creation class, origin, selected class, selected origin, and review states;
- fresh campaign map;
- Salto selected;
- Salto after another mission preview;
- expanded mission details;
- every campaign tab;
- compact ordinary Results;
- expanded ordinary Results details.

## Acceptance Targets

- no tiny prose wall;
- no hidden primary action;
- no preserved mission scroll bug;
- no overflowing cards;
- no giant unused desktop regions where useful content should be;
- no progression or save changes.

## Latest Run

`npm run visual:qa` passed.

- Test files: 10 visual-QA tests.
- Screenshot count: 84.
- Browser console errors: 0.
- Screenshot retries: 0.
- Output folder: `visual-qa/latest/`.
- Added v0.94 group: `v094-presentation-rescue`.

Non-pass evidence resolved before final run: an earlier visual-QA attempt caught the locked Aether Well preview primary action below the 1366x768 fold. The selected mission panel now uses a concise pacing chip and tighter default spacing, and the final run passed with the full 84-screenshot set.

## Visual Review Pack

`npm run visual:review-pack` passed after the final visual-QA run.

- Output folder: `artifacts/visual-review/latest/`.
- Screenshots: 84.
- Contact sheets: 7.
- Target viewports: 1920x1080, 1600x900, 1366x768.
