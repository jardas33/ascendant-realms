# v0.11.3 Fast Confidence Smoke Fix

Date: 2026-05-12

## Purpose

v0.11.3 fixes the first remote GitHub Actions `Fast confidence` failure reported after the v0.11.1/v0.11.2 CI workflow work. This pass stays strictly inside Playwright smoke reliability and documentation. It does not change gameplay, content, saves, tutorial behavior, campaign progression, visual assets, runtime art, CI coverage strength, maps, units, factions, rewards, or app runtime behavior.

## GitHub Failure Evidence

Emmanuel reported the pushed `CI Release Matrix Dry Run` workflow failed in the automatic `Fast confidence` job:

- Run: `Checkpoint v0.11.2 GitHub Actions remote CI observation #2`
- Commit: `aee73ee`
- Total duration: 15m 15s
- Failed step: `Run npm run test:e2e:smoke`
- Command: `playwright test tests/e2e/smoke.spec.ts --reporter=line`

Primary failure:

- File: `tests/e2e/smoke.spec.ts:541`
- Test: `Ascendant Realms browser smoke flows > settings screen persists accessibility options`
- Error: `Test timeout of 35000ms exceeded.`
- Artifacts mentioned by GitHub: `video.webm`, `error-context.md`, `trace.zip`

Likely cascade:

- File: `tests/e2e/smoke.spec.ts:671`
- Test: `Ascendant Realms browser smoke flows > campaign Border Village launches a battle scene`
- Error: `Test timeout of 35000ms exceeded while setting up "context".`
- Browser error: `browser.newContext: Protocol error (Browser.setDownloadBehavior): Failed to find browser context for id ...`

## Local Reproduction Notes

The full local smoke lane passed before the fix:

```text
npm run test:e2e:smoke
PASS: 12 tests in about 4.9m
```

Focused sequential runs also passed before the fix, but showed the settings test has a narrow CI margin under the global 35s Playwright test timeout:

```text
npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on
PASS: 1 test in 23.6s, total command 33.8s

npx playwright test tests/e2e/smoke.spec.ts --grep "campaign Border Village launches a battle scene" --retries=1 --trace=on
PASS: 1 test in 17.3s, total command 25.9s
```

The settings test was repeated serially with one worker and trace enabled:

```text
npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --workers=1 --repeat-each=3 --retries=1 --trace=on
PASS: 3 tests in 22.4s, 23.8s, and 24.1s
```

A concurrent local targeted run of the settings and Border Village tests exceeded the 35s per-test budget during trace capture/teardown. That was not treated as the main reproduction because the repository smoke lane is configured for one worker, but it reinforced that the settings smoke path is vulnerable when the runner is slower or under pressure.

## Root Cause Hypothesis

The settings accessibility smoke test is valid but long for the default 35s per-test budget. It intentionally verifies several behaviors in one smoke path:

- settings screen opens from a fresh main menu
- volume and UI scale controls update through the Settings scene's DOM re-render flow
- accessibility toggles and fog override are saved
- settings persist after returning to the main menu and reopening Settings
- settings are written to localStorage
- document-level accessibility datasets are applied
- a skirmish battle launches
- in-battle runtime settings are applied to floating text, fog, UI scale, reduced motion, and minimap palette

On the local machine the focused test usually finishes in roughly 22-24s, leaving about 11-13s of headroom. The GitHub-hosted runner exceeded the global 35s budget, likely because startup, rendering, tracing, browser teardown, or CPU scheduling was slower.

## What Changed

`tests/e2e/smoke.spec.ts` now:

- adds `setSettingsRangeValue()` so the settings range controls wait for the Settings scene's re-rendered DOM state before the next action
- explicitly asserts checkbox and select state after each accessibility/fog control change
- gives only the `settings screen persists accessibility options` smoke test a 60s timeout
- documents in-code that the timeout is scoped to the GitHub Actions evidence and the test's combined settings-persistence plus in-battle runtime-application coverage

No app code, gameplay code, content data, save code, visual assets, runtime art, campaign progression, or CI workflow YAML changed.

## Coverage Preservation

The smoke test was not removed, skipped, split into fake assertions, or weakened. The same user-facing and runtime checks remain covered:

- Settings screen accessibility controls
- Settings save/persistence
- localStorage settings payload
- document dataset application
- skirmish launch after changing settings
- in-battle application of reduced motion, UI scale, floating text, fog override, and colorblind minimap behavior

The timeout change is scoped to one smoke test rather than the whole suite.

## Campaign Failure Assessment

The Border Village smoke test passed independently both before and after the settings fix. v0.11.3 treats the GitHub `browser.newContext` failure as a likely cascade from the earlier settings timeout and browser/context instability unless the next remote run shows a fresh, independent Border Village failure.

## Post-Fix Focused Verification

```text
npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on
PASS: 1 test in 26.8s, total command 35.7s

npx playwright test tests/e2e/smoke.spec.ts --grep "campaign Border Village launches a battle scene" --retries=1 --trace=on
PASS: 1 test in 16.7s, total command 26.6s
```

## Full Local Verification

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build. The known Phaser vendor chunk-size warning remains.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke
PASS: 12 tests in about 4.7m.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

npm run test:e2e:release
PASS: 67 tests in about 28.7m.

npm run test:e2e:release:shard1of3
PASS: 28 tests in about 11.3m.

npm run test:e2e:release:shard2of3
PASS: 27 tests in about 13.4m.

npm run test:e2e:release:shard3of3
PASS: 12 tests in about 4.9m.

npm run visual:qa
PASS: 18 screenshots, 0 browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS.
```

## Next GitHub Actions Check

After this commit is pushed, Emmanuel should re-open the automatic `CI Release Matrix Dry Run` workflow for `main` and check:

1. `Fast confidence` reaches the `npm run test:e2e:smoke` step.
2. `settings screen persists accessibility options` passes instead of timing out.
3. `campaign Border Village launches a battle scene` either passes or, if it fails, reports a new independent failure rather than context fallout.
4. `npm run smoke:preview` still passes after the smoke lane.
5. Any uploaded Playwright artifacts are retained only for real failures.

The known Phaser vendor chunk warning remains non-blocking.
