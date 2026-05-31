# v0.90 Lightweight Performance Baseline

Checkpoint: v0.90 UX Visual-Regression Harness and Desktop-Viewport Acceptance Hardening

## Scope

This is a lightweight browser-prototype baseline. It is not a profiling system and does not introduce heavy runtime instrumentation.

## Baseline Fields

- Build chunk warning status.
- Initial load evidence.
- Campaign-map render evidence.
- Battle-launch evidence.
- Visual-QA duration.
- Screenshot count.
- Console-error count.
- Screenshot retry count.
- Representative battle-frame posture where existing visual QA can inspect it safely.

## Captured Baseline

Current v0.90 visual-QA baseline from the expanded matrix:

```text
npm run visual:qa: PASS
visual QA screenshot count: 64
visual QA duration: 946,330 ms total harness time, 16.0m Playwright wall time
visual QA average screenshot duration: 5,310 ms
visual QA console errors: 0
visual QA screenshot retries: 0
battle frame posture: ordinary battle, selected unit group, selected Command Hall, contested capture site, Lume states, Victory, Defeat, Replay, and Tutorial captured
```

Build baseline from `npm run build`:

```text
npm run build: PASS
assets/index-BXgUo5fG.js: 751.51 kB, gzip 200.24 kB
assets/vendor-phaser-B61OQUcB.js: 1,481.79 kB, gzip 339.86 kB
chunk warning: expected Vite warning for chunks larger than 500 kB
```

The existing expected Phaser vendor chunk warning remains acceptable because it did not change shape and no new build failure was introduced.

## Interpretation Rules

- The known Vite warning for the Phaser vendor chunk is acceptable unless the warning changes shape or new chunk warnings appear.
- Any browser console error in visual QA is a release blocker for this checkpoint.
- Any screenshot retry is a release blocker for this checkpoint.
- Baseline timing is comparative evidence only; failures should be tied to functional regressions or significant harness slowdowns, not small machine-to-machine variance.
