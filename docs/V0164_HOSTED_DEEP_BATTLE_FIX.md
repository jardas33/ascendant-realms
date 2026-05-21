# v0.16.4 Hosted Deep-Battle Movement Command Fix

Date: 2026-05-20

Scope: stabilize the red `Release matrix (deep-battle)` job from GitHub Actions CI Release Matrix Dry Run #70 after v0.16.3. This is a test-only release-matrix hardening pass, not v0.17.

## Exact Fix

Changed `tests/e2e/deep-flow.spec.ts` only:

- Added `MOVE_ORDER_SUMMARY_PATTERN = /Moving|Repositioning/`.
- Used that pattern in the older HUD/minimap/building test's movement command assertion.
- Reused the same pattern in the dedicated behaviour gauntlet retreat order assertion.
- Replaced the older HUD test's transient fog status-line assertion with a semantic battle-state poll:
  - `BattleScene` active
  - `scene.isFogActive()` true
  - `scene.fogDebugDisabled` false
- Replaced the post-movement status-line dependency with the movement order summary assertion after the real canvas right-click.
- Replaced the placement-cancel status-line dependency with placement-state assertions:
  - no pending building
  - ghost not visible
  - placement banner removed

## Why This Preserves Coverage

- No tests were removed.
- No retries were added.
- No force clicks were added.
- No DOM fallback was added for canvas/world clicks.
- The movement command still uses `clickWorldPoint(..., "right")`.
- The minimap, fog, build, cancel, command hall, and behaviour-mode surfaces remain covered.
- The new assertions are tied to durable scene/HUD state instead of transient status copy that can be intentionally blocked by higher-priority pressure messages.

## What Was Not Changed

- Runtime gameplay: unchanged.
- Gameplay numbers: unchanged.
- Save format: unchanged.
- Runtime art/assets: unchanged.
- Behaviour modes: unchanged.
- Package materials: unchanged.
- GitHub Actions workflow/release matrix shape: unchanged.
- Shared click helper: unchanged.

## Verification

```text
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --retries=1 --trace=on --reporter=line
PASS, 1 test in 1.3m.

npm run test:e2e:release:hosted:deep-battle
PASS, 12 tests in 4.1m.

npm run test:e2e:release:hosted:smoke
PASS, 14 tests in 3.1m.

npm run test:e2e:smoke:fast
PASS, 8 tests in 2.8m.

npm run test:e2e:smoke
PASS, 14 tests in 8.2m.

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
PASS, 77 tests in 40.9m.

npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --retries=1 --trace=on --repeat-each=3 --reporter=line
PASS, 3 tests in 3.4m.

git diff --check
PASS.
```

The `playtest:controls` command regenerated tracked control-lab output files as expected; those generated report changes were restored because this v0.16.4 checkpoint does not change control-lab/package materials.

## GitHub Actions

Rerun required: yes.

Reason: GitHub-hosted run #70 was red in `Release matrix (deep-battle)`. Local hosted deep-battle, hosted smoke, full smoke, full release, and focused soak are green, but the GitHub-hosted production-preview runner must confirm the timeout is resolved.
