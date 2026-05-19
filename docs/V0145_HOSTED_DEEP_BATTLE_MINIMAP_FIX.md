# v0.14.5 Hosted Deep-Battle Minimap Fix

Date: 2026-05-18  
Baseline commit: 9a1dc0a113144c9cb3132b689cec53fd772953f1

## Failure Summary

GitHub Actions CI Release Matrix Dry Run #61 failed only in the hosted deep-battle lane:

- `tests/e2e/deep-flow.spec.ts:1647`
- `battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions @hosted-deep-battle`
- failure around line 1868
- `Timeout 1000ms exceeded while waiting on the predicate`

The failing predicate checked active marquee drag state while a drag crossed into the minimap. The rest of the deep-battle lane and the other reported release lanes were green.

## Root Cause

The v0.14.4 test added real coverage for active marquee dragging across the minimap, but the event ordering was too tight for hosted preview:

- it pressed the mouse down on the battlefield;
- immediately moved into the minimap;
- then gave the active-drag predicate only 1000ms;
- and did not guarantee mouseup cleanup when that midpoint assertion failed.

Local hosted repros passed, including three repeated targeted runs and the full hosted deep-battle group, so this was treated as a hosted timing race in the test path rather than a proven runtime product regression.

## Exact Fix

`tests/e2e/deep-flow.spec.ts` now:

- waits up to 3000ms for the battlefield pointerdown to start the marquee drag before moving into the minimap;
- keeps the active-drag-over-minimap assertion, also with a scoped 3000ms hosted-safe timeout;
- wraps the minimap crossing in `try/finally` so the mouse button is released even if the assertion fails;
- adds an explicit minimap-click camera movement assertion so the test's minimap movement coverage is clearer, not weaker.

No runtime source code changed.

## Coverage Preserved

- Minimap camera movement is now explicitly asserted.
- Marquee drag over the minimap is still asserted.
- Release-over-minimap cleanup is still asserted.
- Fog toggle, building placement cancel, and command hall action checks remain in the same test.
- The v0.14.4 stale-selection and HUD/minimap drag fixes remain covered.
- No assertion was skipped, removed, or replaced with fake state.

## Verification

Final verification:

```text
npm test PASS, 53 files / 383 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast first attempt hit local Windows net::ERR_NO_BUFFER_SPACE on the first navigation; rerun after socket cooldown PASS, 7 tests.
npm run test:e2e:smoke PASS, 13 tests.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --retries=1 --trace=on --reporter=line
PASS, 1 test.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --repeat-each=3 --retries=0 --reporter=line
PASS, 3 repeated targeted tests before the fix, supporting the hosted-timing diagnosis.
npm run test:e2e:release:hosted:deep-battle
PASS, 11 tests.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run test:e2e:release:hosted:smoke PASS, 13 tests.
npm run test:e2e:release PASS, 75 tests.
git diff --check PASS.
```

## Rerun

Emmanuel should rerun GitHub Actions CI Release Matrix Dry Run and specifically confirm the hosted deep-battle group passes.
