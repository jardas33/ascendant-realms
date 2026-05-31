# v0.90 Layout Assertion Coverage

Checkpoint: v0.90 UX Visual-Regression Harness and Desktop-Viewport Acceptance Hardening

## Automated Coverage

`tests/e2e/layout.spec.ts` now includes desktop acceptance checks for `1920x1080`, `1600x900`, and `1366x768`.

Assertions cover:

- no campaign node-card overlap;
- no horizontal overflow in campaign, Results, and HUD surfaces;
- primary campaign action visible without default page scrolling;
- Results primary actions visible without default page scrolling;
- selected mission More Details disclosure collapsed by default and expandable;
- locked Aether Well preview and disabled launch action;
- all campaign tab panels reachable;
- private-demo controls absent in ordinary battle;
- Lume controls absent outside eligible Lume mission;
- private-demo Results compact/expanded disclosure preserved;
- command panel, objective tracker, and minimap visibility through existing hosted layout lanes.

## Visual QA Harness Coverage

`tests/visual-qa/visual-qa.spec.ts` now captures the 64-shot review set and records:

- screenshot count;
- viewport set;
- capture groups;
- browser console errors;
- screenshot retry count;
- total harness duration;
- average screenshot duration.

The v0.90 acceptance matrix contributes 28 deterministic captures listed in `docs/V090_VISUAL_REGRESSION_MATRIX.json`.

## Deliberate Limits

- Visual QA remains screenshot evidence, not pixel-diff auto-approval.
- Text overflow checks are scoped to key cards and HUD panels to avoid false positives from intentional scroll containers.
- Battlefield states are staged through existing test hooks and DOM controls only; no force clicks or DOM fallbacks are used for canvas/world clicks.
