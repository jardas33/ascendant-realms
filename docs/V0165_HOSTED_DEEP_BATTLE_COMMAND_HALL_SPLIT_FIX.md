# v0.16.5 Hosted Deep-Battle Command Hall Split Fix

Date: 2026-05-20

## Summary

v0.16.5 is a test-only stabilization checkpoint for GitHub Actions CI Release Matrix Dry Run #72. Fast confidence, hosted smoke, release simulator, deep-meta, deep-campaign-pressure, layout-core, and layout-cinderfen were already green. Only hosted deep-battle remained red.

The remaining failure was the old broad deep-battle HUD test timing out at the late Command Hall Barracks build command. The fix splits the late Command Hall building placement/cancel assertions into a focused hosted deep-battle test with a fresh browser context.

## Exact Fix

Changed `tests/e2e/deep-flow.spec.ts`:

- Renamed the older broad test to `battle HUD supports minimap movement, fog toggle, and move commands @hosted-deep-battle`.
- Kept its existing battle boot, initial selection, attack cursor, click-safety, marquee, minimap, fog, and right-click movement assertions.
- Added `battle HUD supports command hall building placement and cancel @hosted-deep-battle`.
- Moved the Command Hall side-panel, Build section, Barracks placement mode, placement ghost offset, Escape cancel, and placement banner removal assertions into the new focused test.

This keeps coverage intact while avoiding one hosted test spending nearly all of its 120s budget before reaching the build/cancel section.

## Why Assertions Were Not Weakened

No assertions were removed. The assertions are now distributed across two hosted deep-battle tests:

- The original scenario still proves minimap movement, fog toggle, and real world move commands.
- The new scenario still proves Command Hall building placement and cancel behavior.
- The dedicated behaviour mode control gauntlet remains the owner of behaviour-mode switching coverage.

## Verification

```text
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, and move commands" --retries=1 --trace=on --reporter=line
PASS, 1 test in 1.0m.

npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports command hall building placement and cancel" --retries=1 --trace=on --reporter=line
PASS, 1 test in 39.7s.

npm run test:e2e:release:hosted:deep-battle
PASS, 13 tests in 4.4m.

npm run test:e2e:release:hosted:smoke
PASS, 14 tests in 3.1m.

npm run test:e2e:smoke:fast
PASS, 8 tests in 2.5m.

npm run test:e2e:smoke
PASS, 14 tests in 6.9m.

npm test
PASS, 56 files / 406 tests.

npm run build
PASS with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS, 1 candidate metadata JSON and 0 review manifests checked.

npm run playtest:controls
PASS, 10 rows / 10 pass.

npm run playtest:controls:verify
PASS, 930 checks.

npm run test:e2e:release
PASS, 78 tests in 37.3m.

npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, and move commands" --retries=1 --trace=on --repeat-each=3 --reporter=line
PASS, 3 tests in 2.7m.

npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports command hall building placement and cancel" --retries=1 --trace=on --repeat-each=3 --reporter=line
PASS, 3 tests in 1.8m.
```

`npm run test:e2e:release` was first attempted with a 30-minute local wrapper timeout and was inconclusive; no Playwright failure context was produced. It was rerun with a longer wrapper timeout and passed.

## GitHub Actions

Rerun required: yes.

Reason: the fix is local and pushed for v0.16.5; GitHub Actions CI Release Matrix Dry Run must confirm hosted deep-battle is green on the runner before v0.17 starts.

## Not Changed

- Runtime gameplay: no
- Gameplay numbers: no
- Save format: no
- Runtime art/assets: no
- Behaviour modes: no
- Package materials: no
- CI workflow/release matrix: no
- Force clicks: no
- Canvas/world DOM fallback: no
