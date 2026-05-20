# v0.16.3 Hosted Smoke Pause/Resume Fix

Date: 2026-05-20

Scope: fix the remaining GitHub Actions CI Release Matrix Dry Run #68 hosted smoke failure after v0.16.2. This is a test-only follow-up and does not start v0.17.

## Remote Evidence

Run #68 checked out `f4ac082875db451a05b2b2668f9714e1ecf0af8d`, `Checkpoint v0.16.2 release-matrix smoke and deep-battle stabilization`.

Green jobs:

- Fast confidence
- Release simulator
- Release matrix deep-meta
- Release matrix deep-battle
- Release matrix deep-campaign-pressure
- Release matrix layout-core
- Release matrix layout-cinderfen

Red job:

- Release matrix smoke

Failed test:

```text
tests/e2e/smoke.spec.ts:921:3
Ascendant Realms browser smoke flows › settings accessibility options apply in battle @ci-fast
```

The important new clue is that both DOM-control fallbacks fired before the test timed out:

```text
settings smoke battle menu: normal click failed; using verified DOM click fallback on button 70x37 "Menu"
settings smoke battle resume: normal click failed; using verified DOM click fallback on button 161x58 "Resume"
Test timeout of 90000ms exceeded.
```

Artifacts again were not downloadable through the connector. The job attempted to upload 8 files, but GitHub reported that artifact storage quota had been hit.

## Root Cause

v0.16.2 correctly preserved the settings runtime assertions and made the pause/resume clicks success-aware, but the hosted runner still spent too much time in Playwright's normal actionability waits before reaching the already-existing verified DOM-control fallback.

This is not a runtime settings bug. The failure reached real `Menu` and `Resume` DOM buttons, clicked them through the verified DOM fallback, and then hit the 90s test limit. The timeout budget was consumed by repeated normal-click actionability waits on a smoke-only pause/resume check.

## Fix

`tests/e2e/smoke.spec.ts` now gives only the settings battle menu/resume buttons a tight click budget before the verified DOM-control fallback:

- one normal actionability attempt
- 500ms normal click timeout
- 1s verified DOM-control fallback timeout
- 3s visible/enabled target budget
- no duplicate layout-box wait because the test already verifies the menu point / pause menu state before clicking

The fallback still verifies a real visible, enabled, uncovered DOM control and then the test asserts the scene/DOM follow-up state. This is not a force click and does not use DOM fallback for canvas/world clicks.

## Coverage Preserved

- Settings persistence remains covered by the separate `settings screen persists accessibility options @ci-fast` test.
- Runtime settings assertions remain covered: reduced motion, colorblind minimap dataset, colorblind minimap snapshot, minimap marker colors, floating text disabled, fog override disabled, fog inactive, battle pause, and battle resume.
- The post-resume assertion still requires the BattleScene to be active and `menuPaused` to be false.
- `@ci-fast` coverage remains intact.

## Verification

```text
npx playwright test tests/e2e/smoke.spec.ts --config=playwright.hosted-release.config.ts --grep "settings accessibility options apply in battle" --retries=1 --trace=on --reporter=line
PASS, 1 test in 42.1s.

npm run test:e2e:release:hosted:smoke
PASS, 14 tests in 3.0m.

npm run test:e2e:smoke:fast
PASS, 8 tests in 2.5m.

npm run test:e2e:smoke
PASS, 14 tests in 7.0m.

npm test
PASS, 56 files / 406 tests.

npm run build
PASS, with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.

npm run test:e2e:release
PASS, 77 tests in 37.8m.
```

## GitHub Actions

Rerun required: yes.

Reason: run #68 proves the remaining failure is GitHub-hosted smoke timing around the settings pause/resume DOM controls. Local hosted smoke and full release are now green with the tighter, assertion-preserving click budget.
