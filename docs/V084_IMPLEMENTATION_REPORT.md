# v0.84 Implementation Report

Status: implementation and local verification complete. Final clean package generation should be run from the final commit so the package name has no `-dirty` suffix.

## Runtime Changes

- Replaced the Lume HUD paragraph row with a progressive `LUME WARD` tracker.
- Added compact private demo copy with Details disclosure.
- Added private-demo focus buttons for West Stone Cut, Ford Toll, and the optional North Aether Spring reveal.
- Added `Exit Demo` and post-activation `Finish Demo & View Results` actions.
- Added procedural Lume link and endpoint rendering with inactive, active, contested, severed, and restored styles.
- Added high-priority deduped Lume notifications for awaken, sever, restore, and full-network activation.

## Save Format

No save-version bump. No save fields were added, removed, renamed, or migrated. Lume rendering, focus controls, demo exit, and demo finish are battle-session-only.

## Tests Added

- Lume director HUD progression and notification tests.
- Objective panel private demo control rendering tests.
- Smoke coverage for private demo Finish Demo and save isolation.
- Hosted deep campaign coverage for Lume render snapshot and severed HUD copy.
- Visual QA coverage updates for guided private Lume demo screenshots.

## Verification

```text
npx vitest run src/game/battle/LumeNetworkDirector.test.ts src/game/ui/hudPanels/ObjectivePanel.test.ts --reporter=dot PASS, 2 files / 10 tests.
npx vitest run src/game/playtest/PlaytestPackageValidation.test.ts --reporter=dot PASS, 1 file / 3 tests.
npx playwright test tests/e2e/smoke.spec.ts --grep "private playtest Aether Well Lume" --reporter=line PASS, 1 test.
npx playwright test tests/e2e/deep-flow.spec.ts --grep "Aether Well Lume Network" --reporter=line PASS, 1 test.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Aether Well Lume Network" --reporter=line PASS, 1 test.
npm test PASS, 87 files / 659 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast PASS, 9 tests.
npm run test:e2e:smoke PASS, 15 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:smoke PASS, 15 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 8 tests after a focused Lume test-race fix.
npm run visual:qa PASS, 6 tests / 26 screenshots / 0 console errors / 0 screenshot retries after a test-only Cinderfen helper fallback.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-a368b55-dirty` generated.
npm run verify:playtest-package PASS, 265 checks against the dirty pre-commit package.
```

Non-pass evidence:

- One `npm run test:e2e:smoke` wrapper attempt timed out and killed the local dev server; an immediate second attempt failed with `ERR_CONNECTION_REFUSED`; a clean rerun passed.
- One hosted deep-campaign-pressure run exposed a Lume proxy race where a player unit standing on Ford Toll immediately recaptured the site after the test forced enemy ownership. The test now moves player units away before forcing the severed state; exact and full hosted reruns passed.
- One visual QA run failed in an existing Cinderfen helper when the neutral brute had already been cleared. The helper now records or fast-forwards the objective through a safe fallback; the full visual QA rerun passed.
