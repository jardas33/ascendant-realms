# v0.14.2 Hosted Settings Smoke Fix

Date: 2026-05-18

## Failure Summary

GitHub Actions CI Release Matrix Dry Run #55 failed only in the hosted smoke group at:

```text
tests/e2e/smoke.spec.ts:825
settings screen persists accessibility options @ci-fast
```

The test timed out at 60 seconds on both the first attempt and retry. The other 12 hosted smoke tests passed.

## Root Cause

The test was not failing a protected settings assertion locally. The exact hosted-config repro passed locally in about 45 seconds, which left too little margin for the slower GitHub-hosted runner after v0.14.1 expanded the same test to include battle pause overlay verification.

This was a scoped timeout margin problem on a real multi-stage smoke path:

- open settings
- change controls
- save settings
- reopen and confirm persistence
- confirm document accessibility state
- launch a battle directly
- confirm runtime settings effects
- verify colorblind minimap markers
- open and resume the pause overlay

## Exact Fix

`SETTINGS_ACCESSIBILITY_SMOKE_TIMEOUT_MS` was increased from 60 seconds to 90 seconds for this single test.

No settings assertions were removed. No hosted matrix structure changed. No runtime gameplay code changed.

## Assertions Still Protected

- settings persist after save/reopen
- reduced motion and colorblind minimap document datasets apply
- floating text remains disabled during runtime combat
- fog override disables battle fog
- colorblind minimap state applies to runtime and DOM markers
- battle Menu opens the pause overlay instead of exiting
- Resume closes the pause overlay

## Verification

```text
npx playwright test tests/e2e/smoke.spec.ts --config=playwright.hosted-release.config.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on --reporter=line
PASS, 1 test in about 35.8s after the scoped timeout fix.

npm run test:e2e:release:hosted:smoke
PASS, 13 tests in about 2.9m.

npm test
PASS, 52 files / 375 tests.

npm run build
PASS with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS, 1 candidate metadata JSON and 0 review manifests checked.

npm run test:e2e:smoke:fast
PASS, 7 tests in about 2.2m.

npm run test:e2e:smoke
PASS, 13 tests in about 6.7m.

npm run playtest:sim
PASS, 255 runs across 85 campaign battle nodes.

npm run playtest:lab:verify
PASS, 63 generated-output consistency checks.

git diff --check
PASS.
```

## What Emmanuel Should Rerun

Rerun GitHub Actions CI Release Matrix Dry Run, specifically confirming the hosted smoke group passes on commit `256c688` or later.
