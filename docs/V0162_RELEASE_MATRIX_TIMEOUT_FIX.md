# v0.16.2 Release Matrix Timeout Fix

Date: 2026-05-20

Scope: stabilize the red release-matrix `deep-battle` and `smoke` jobs from GitHub Actions CI Release Matrix Dry Run #66 without changing gameplay, balance, save format, content, runtime art, package materials, or release-matrix shape.

## Root Cause

Run #66 showed a common timeout symptom in two hosted release jobs:

- `Release matrix (deep-battle)` timed out inside the older HUD/minimap/building test while it was doing duplicated v0.16 behaviour-mode transitions.
- `Release matrix (smoke)` timed out inside the settings runtime accessibility smoke while resuming from the battle pause menu under hosted production-preview timing.

In both cases, `Target page, context or browser has been closed` appeared after the Playwright test timeout. That message was a consequence of Playwright closing a timed-out test, not the primary cause.

## Exact Fix

### Deep-Battle

Changed `tests/e2e/deep-flow.spec.ts`:

- Kept the test `battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions @hosted-deep-battle`.
- Kept the default behaviour-mode affordance checks in that test:
  - selected unit order summary shows `Guarding`
  - current behaviour mode shows `Guard Area`
- Removed only the duplicated Hold Ground, Press Attack, and Guard Area switching sequence from that older HUD test.
- Left the dedicated `behaviour mode control gauntlet preserves attack, retreat, marquee, and minimap intent @hosted-deep-battle` intact in the same hosted deep-battle lane.

This reduced the focused hosted HUD test from about 1.8 minutes before the fix to about 1.0 minute after the fix on this machine.

### Smoke

Changed `tests/e2e/smoke.spec.ts`:

- Increased only `SETTINGS_ACCESSIBILITY_RUNTIME_SMOKE_TIMEOUT_MS` from 60 seconds to 90 seconds.
- Added `waitForBattlePauseState` as a semantic pause/resume success probe for the settings runtime smoke.
- Passed `successCheckAfterClick` to the battle menu and battle resume `clickReady` calls so a successful normal click can stop before fallback work if the real scene/DOM state already changed.
- Added an explicit post-resume assertion that the battle scene is still active and `menuPaused` is false.

All existing settings runtime assertions remain active.

## Why This Preserves Coverage

- The deep-battle HUD test still verifies the original HUD/minimap/building/fog/command-hall surface.
- Behaviour-mode switching was not removed from release coverage. It remains in the dedicated hosted behaviour mode control gauntlet, which covers Hold Ground, Guard Area, Press Attack, attack hover/click intent, retreat, marquee cleanup, minimap movement, and hero-select refresh.
- Behaviour modes also remain covered by unit tests and `npm run playtest:controls` / `npm run playtest:controls:verify`.
- The settings runtime smoke still verifies reduced motion, colorblind minimap application, minimap marker colors, floating text disabled, fog disabled, battle pause, and battle resume.
- No assertion was weakened, skipped, or hidden behind retries.

## Verification

```text
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --retries=1 --trace=on --reporter=line
PASS, 1 test in 1.0m.

npx playwright test tests/e2e/smoke.spec.ts --config=playwright.hosted-release.config.ts --grep "settings accessibility options apply in battle" --retries=1 --trace=on --reporter=line
PASS, 1 test in 36.5s.

npm run test:e2e:release:hosted:deep-battle
PASS, 12 tests in 3.7m.

npm run test:e2e:release:hosted:smoke
PASS, 14 tests in 2.8m.

npm run test:e2e:smoke:fast
PASS, 8 tests in 2.3m.

npm run test:e2e:smoke
PASS, 14 tests in 6.5m.

npm test
PASS, 56 files / 406 tests.

npm run build
PASS, with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.

npm run playtest:controls
PASS, 10 rows / 10 pass.

npm run playtest:controls:verify
PASS, 930 checks.

npm run test:e2e:release
PASS, 77 tests in 36.3m.

npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --retries=1 --trace=on --repeat-each=3 --reporter=line
PASS, 3 tests in 3.4m.

npx playwright test tests/e2e/smoke.spec.ts --config=playwright.hosted-release.config.ts --grep "settings accessibility options apply in battle" --retries=1 --trace=on --repeat-each=3 --reporter=line
PASS, 3 tests in 1.6m.

git diff --check
PASS.
```

The `playtest:controls` command regenerated tracked control-lab output files as expected; those generated report changes were restored because this v0.16.2 checkpoint does not change control-lab/package materials.

## GitHub Actions

Rerun required: yes.

Reason: the fix targets the two red hosted release-matrix jobs from CI Release Matrix Dry Run #66. Local hosted deep-battle, hosted smoke, focused soaks, and full release are green, but GitHub-hosted CI must confirm the production-preview runner timing is now within budget.
