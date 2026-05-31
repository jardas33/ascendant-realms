# v0.86 Visual QA Report

## Scope

v0.86 adds screenshot coverage for the battlefield shell rescue without adding pixel-perfect assertions.

## New Captures

- `v086-battlefield-shell-1920.png`: 1920x1080 Command Hall selection with compact command panel, capture-site chip, softened fog, objective tracker, and minimap markers visible.
- `v086-battlefield-shell-1366.png`: 1366x768 version of the same battlefield-shell review state.

## Automated Evidence

- Focused unit presentation tests passed before full verification.
- `npm run build` passed with the known Phaser vendor chunk warning.
- `npm run visual:qa` passed with 6 tests, 31 screenshots, 0 browser console errors, and 0 screenshot retries.

## Manual Review Notes

Reviewers should inspect:

- command panel action density,
- capture-site label contrast,
- selected entity ring readability,
- fog distinction between unexplored and explored-muted cells,
- minimap objective-site marker contrast,
- status-line priority styling.

No final art quality approval is claimed by this report.
