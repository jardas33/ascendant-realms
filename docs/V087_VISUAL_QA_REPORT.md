# v0.87 Visual QA Report

Status: passed.

## Scope

v0.87 visual QA covers the second campaign-shell polish and ordinary Results information architecture. It is a presentation-only review and does not approve new gameplay, reward, save, map, faction, art, or progression behavior.

## Captures

- `v087-campaign-shell-1920.png`: fresh campaign Map tab at 1920x1080 with Border Village selected, visible routes, selected mission action, chapter lanes, and no node overlap.
- `v087-campaign-shell-1366.png`: fresh campaign Map tab at 1366x768 with the same immediate map/action visibility.
- `v087-aether-well-preview-1920.png`: locked Aether Well Ruins preview with lock reason and compact mission panel.
- `v087-results-replay-desktop.png`: ordinary replay Results with compact above-the-fold summary and replay-safe copy.
- `v087-results-defeat-1366.png`: ordinary defeat Results at 1366x768 with primary actions above extended telemetry.

## Automated Evidence

- `npm run visual:qa` - PASS, 6 tests / 36 screenshots / 0 browser console errors / 0 screenshot retries.

- `npm test` - PASS, 91 files / 675 tests.
- `npm run build` - PASS with the known Phaser vendor chunk-size warning.
- `npm run validate:content` - PASS.
- `npm run validate:art-intake` - PASS.
- `npm run test:e2e:smoke:fast` - PASS, 9 tests.
- `npm run test:e2e:smoke` - PASS, 16 tests.
- `npm run test:e2e:layout` - PASS, 32 tests.

## Manual Review Notes

Reviewers should inspect:

- map-first composition at 1920x1080 and 1366x768,
- chapter-lane route clarity,
- selected mission compactness,
- locked Aether Well preview readability,
- Results overview priority,
- `Show Full Battle Details` disclosure behavior,
- private-demo Results preservation.

No new art or imported asset review was required for v0.87.
