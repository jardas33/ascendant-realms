# v0.90 Implementation Report

Checkpoint: v0.90 UX Visual-Regression Harness and Desktop-Viewport Acceptance Hardening

## Summary

v0.90 hardens the browser prototype against UI regressions by expanding the deterministic visual QA matrix, adding desktop viewport layout assertions, validating the visual-regression manifest, and documenting review rules for future screenshot changes.

## Runtime Changed

- No gameplay systems added.
- No balance changes.
- No reward changes.
- No campaign progression changes.
- No save changes.
- No stable IDs renamed.
- No art generated or imported.

## QA Tooling Changed

- Expanded `tests/visual-qa/visual-qa.spec.ts` from 36 to 64 deterministic screenshots.
- Added `1600x900` to the visual QA desktop viewport set.
- Added v0.90 screenshots for campaign, tabs, battle HUD states, Lume states, Results states, replay Results, and Tutorial.
- Visual QA now records screenshot duration data in `visual-qa/latest/index.md`.
- Visual QA now fails if any screenshot retry is used.
- Added layout assertions for campaign node overlap, above-fold campaign actions, above-fold Results actions, key-card overflow, private-demo control posture, and Lume control isolation.
- Added manifest validation in `src/game/playtest/VisualRegressionMatrix.test.ts`.

## Save Format

No save migration. Save schema and `CURRENT_SAVE_VERSION` are unchanged.

## Verification

```text
npm test PASS, 92 files / 678 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast PASS, 9 tests.
npm run test:e2e:smoke PASS, 16 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests after updating stale campaign-tab and Ready-status expectations.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests.
npm run test:e2e:release:hosted:smoke PASS, 16 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 8 tests.
npm run test:e2e:release:hosted:layout-core PASS, 25 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run visual:qa PASS, 9 tests / 64 screenshots / 0 console errors / 0 screenshot retries.
```

Non-pass evidence resolved:

- Initial `npm run test:e2e:release:hosted:deep-meta` found stale expectations that predated the current campaign tab architecture and Retinue Ready/Recovering status copy. The tests now navigate to Stronghold, Hero, Intel, and Reputation before asserting tab-specific panels; exact rerun passed 12/12.
- Initial local `npm run test:e2e:layout` passed 36/37 and exposed a local-dev/private-package posture difference for the private Lume launch button. The exact failed test now detects Vite dev/private package posture versus hosted public posture, and exact rerun plus hosted layout-core rerun passed.

## Package

Package metadata is updated for v0.90. The package should be generated and verified after the final clean commit so build info records the final commit and `dirty: no`.
