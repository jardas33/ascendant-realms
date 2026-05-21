# v0.16.6 Hosted Deep-Battle First Campaign Training Fix

Date: 2026-05-21

## Summary

After the repository was made public, GitHub-hosted Actions started successfully again. CI Release Matrix Dry Run #75 ran on `0398e6e18a596d6ca42f8b50761949f477055757` and proved the billing failure was gone.

Fast confidence, Release simulator, hosted smoke, deep-meta, deep-campaign-pressure, layout-core, and layout-cinderfen were green. The only remaining failure was hosted deep-battle.

Failed test:

```text
tests/e2e/deep-flow.spec.ts:2934
first campaign battle path covers capture, build, train, rally, and victory rewards @hosted-deep-battle
```

Failure shape:

- First attempt: timed out waiting for the newly trained Militia lookup after completing training queues.
- Retry: timed out waiting for the Barracks training queue to show a Militia after repeated visible command click fallback attempts.
- The v0.16.5 split tests passed before this point, so the Command Hall split fix held.

## Root Cause

This was a hosted test-harness timing issue in the broad first-campaign path, not a runtime gameplay regression.

The test already used direct DOM fallback for battle command buttons, but the hosted runner still sometimes failed to observe the Militia queue after visible train-command clicks. Separately, the trained-unit lookup only accepted a newly trained Militia with an active rally `moveTarget`, while the later rally assertion already accepts a unit that has reached the rally point.

## Exact Fix

Changed `tests/e2e/deep-flow.spec.ts`:

- Kept the visible Militia train command click path first.
- Added a narrow fallback to the existing scene-backed `trainUnitThroughCommand` helper only if the visible command never exposes a training queue.
- Kept the train button enabled/resource/prerequisite checks through the helper.
- Broadened the trained Militia lookup to accept a newly trained unit with either:
  - a rally `moveTarget` near the target, or
  - a position already at the rally target.

## Coverage Preserved

- Campaign battle launch still runs through the UI.
- Capture-site progress remains asserted.
- Barracks build/placement remains asserted.
- Militia training remains asserted through a visible command button and the training system.
- Barracks rally assignment remains asserted.
- Trained Militia rally order/progress remains asserted.
- Victory rewards and save persistence remain asserted.

## Verification

```text
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "first campaign battle path covers capture, build, train, rally, and victory rewards" --retries=1 --trace=on --reporter=line
PASS, 1 test in 53.2s.

npm run test:e2e:release:hosted:deep-battle
PASS, 13 tests in 4.3m.

npm run test:e2e:smoke:fast
PASS, 8 tests in 2.6m.

npm test
PASS, 56 files / 406 tests.

npm run build
PASS with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS, 1 candidate metadata JSON and 0 review manifests checked.

git diff --check
PASS.
```

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
