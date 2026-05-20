# v0.16.1 Fast Confidence CI Fix

Date: 2026-05-20

Scope: fix the automatic GitHub Actions Fast confidence regression reported on CI Release Matrix Dry Run #64 for commit `c28f19d`, without starting v0.17 or changing runtime gameplay.

## Remote Failure

- Workflow: CI Release Matrix Dry Run.
- Run: #64.
- Failed job: Fast confidence.
- Primary failed test: `tests/e2e/smoke.spec.ts:834`, `settings screen persists accessibility options @ci-fast`.
- Secondary flaky test: `tests/e2e/smoke.spec.ts:1529`, `inventory screen opens without crashing @ci-fast`.
- Supplied secondary error: Playwright timed out while setting up a new browser context and failed `Browser.setDownloadBehavior`.

Direct GitHub artifact inspection was unavailable from this environment: `gh` is not installed, the connector could not resolve displayed run number `#64` as a numeric Actions run id, and public API access returns 404 for the private repository.

## Root Cause

The failed settings smoke path was oversized for the automatic CI Fast confidence lane. It combined settings save/reopen persistence, document dataset checks, direct battle launch, runtime settings checks, minimap colorblind marker checks, floating-text suppression, fog override, and pause/resume behavior in one long browser context.

Local baseline did not reproduce a deterministic app bug, but the settings test took about 50 seconds with trace before the fix and the remote failure reached retry artifact creation. A local full-smoke run after the first split exposed the concrete actionability race in the same path: reopening Settings could reach the Settings screen while the click helper still treated the original main-menu button as the target, leaving no button for fallback.

The inventory error is classified as secondary context instability because it failed during browser context setup, before inventory assertions ran, and the inventory test passed independently before and after the fix.

## Fix

- Replaced the single 90s `settings screen persists accessibility options @ci-fast` test with two focused 60s `@ci-fast` tests:
  - `settings screen persists accessibility options @ci-fast`
  - `settings accessibility options apply in battle @ci-fast`
- Added shared `ACCESSIBILITY_SMOKE_SETTINGS` test data so persistence and runtime checks assert the same settings values without duplicating literals.
- Added `settingsScreenVisible()` as a success check for opening/reopening Settings so a successful UI transition is accepted before click fallback looks for a now-gone menu button.
- Kept the inventory smoke unchanged.

## Assertion Coverage Preserved

The original settings coverage remains present:

- settings values persist after save/reopen
- `floatingTextEnabled: false`
- `reducedMotionEnabled: true`
- `colorblindMinimapPalette: true`
- `fogEnabledOverride: "disabled"`
- document datasets for reduced motion and colorblind minimap apply
- battle runtime sees floating text disabled
- fog override disables battle fog
- colorblind minimap snapshot and marker colors apply
- battle menu pause/resume behavior still works

The coverage moved into separate browser contexts so Fast confidence does not ask one CI worker context to carry the whole multi-scene settings path.

## Not Changed

- Runtime gameplay: no.
- Gameplay numbers: no.
- Save format: no.
- Runtime art/assets: no.
- Behaviour modes: no.
- Package/playtest materials: no.
- CI workflow or release matrix structure: no.
- Settings/accessibility assertions weakened: no.
- Inventory assertions weakened: no.
- Force clicks or canvas/world DOM fallback added: no.

## Verification

```text
npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on --reporter=line
PASS, 1 test in 38.2s.

npx playwright test tests/e2e/smoke.spec.ts --grep "inventory screen opens without crashing" --retries=1 --trace=on --reporter=line
PASS, 1 test in 28.8s.

npm run test:e2e:smoke:fast
PASS, 8 tests in 2.6m.

npm run test:e2e:smoke
PASS, 14 tests in 7.4m.

npm test
PASS, 56 files / 406 tests.

npm run build
PASS with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS, 1 candidate metadata JSON and 0 review manifests checked.

npm run playtest:controls
PASS, 10 scenario rows / 10 pass.

npm run playtest:controls:verify
PASS, 930 checks.

npm run test:e2e:release:hosted:smoke
FAIL on first run in unrelated extended smoke status copy; targeted hosted rerun and full hosted rerun passed.

npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/smoke.spec.ts --grep "post-Ashen campaign resolves Cinderfen Overlook" --retries=1 --trace=on --reporter=line
PASS, 1 test in 35.6s.

npm run test:e2e:release:hosted:smoke
PASS on full rerun, 14 tests in 3.3m.

npm run test:e2e:release
PASS, 77 tests in 38.4m.

npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on --repeat-each=3 --reporter=line
PASS, 3 tests in 1.5m.

git diff --check
PASS.
```

GitHub Actions should be rerun because the remote Fast confidence job failed on run #64 and local verification can only prove the narrow fix under local/hosted-preview equivalents.
