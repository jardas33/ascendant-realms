# v0.11.9 Hosted Release Matrix Split And Timeout Fix

Date: 2026-05-14

## Purpose

v0.11.9 makes the manual GitHub Actions release matrix smaller and more CI-realistic after the hosted 3-way release matrix still timed out or failed on GitHub-hosted runners. This is a CI/release stability change only. It does not change gameplay, content, saves, save format, tutorial behavior, campaign progression, visual assets, runtime art, balance, maps, units, factions, rewards, or coverage strength.

## GitHub Run #13 Evidence

Remote evidence from Emmanuel:

- Workflow: `CI Release Matrix Dry Run`.
- Manual run: `CI Release Matrix Dry Run #13`.
- Commit: `bddb95b` or latest v0.11.8 pushed release-matrix stability commit.
- Manual selection: `Run manual 3-way release shard matrix and simulator`.

Results:

- Fast confidence: PASS.
- Optional visual QA: skipped/absent as expected.
- Release simulator: PASS.
- Release matrix shard 1 of 3: cancelled after exceeding 35 minutes.
- Release matrix shard 2 of 3: cancelled after exceeding 35 minutes.
- Release matrix shard 3 of 3: failed with hosted browser/context instability.

## What Changed

### Hosted 6-Way Release Scripts

Added package scripts:

```bash
npm run test:e2e:release:hosted:shard1of6
npm run test:e2e:release:hosted:shard2of6
npm run test:e2e:release:hosted:shard3of6
npm run test:e2e:release:hosted:shard4of6
npm run test:e2e:release:hosted:shard5of6
npm run test:e2e:release:hosted:shard6of6
```

Each script runs the same Playwright release suite through native sharding:

```bash
playwright test --reporter=line --fully-parallel --workers=1 --shard=N/6
```

`--fully-parallel` is included only on the hosted scripts so Playwright distributes individual tests instead of whole files. `--workers=1` keeps each hosted shard single-worker, preserving the current Phaser/Vite stability policy inside a shard.

### GitHub Actions Manual Matrix

`.github/workflows/ci.yml` now uses six hosted shard jobs for the manual release matrix:

- `shard-1-of-6`
- `shard-2-of-6`
- `shard-3-of-6`
- `shard-4-of-6`
- `shard-5-of-6`
- `shard-6-of-6`

Each manual hosted release shard has `timeout-minutes: 45`.

The release matrix remains `workflow_dispatch` only. It does not run automatically on every push or pull request.

### Local Scripts Preserved

These commands remain unchanged:

```bash
npm run test:e2e:release
npm run test:e2e:release:shard1of3
npm run test:e2e:release:shard2of3
npm run test:e2e:release:shard3of3
```

The hosted 6-way scripts are additive. They do not replace local full release confidence.

### Narrow Actionability Fix

Shard 1 evidence showed `menu-reset-save` resolved but waited for visibility/enabled/stable. The two `menu-reset-save` clicks in `tests/e2e/deep-flow.spec.ts` now use the existing `clickReady` helper.

This helper waits for visible/enabled state, scrolls if needed, clicks without `force`, retries once only on transient actionability errors, and still fails real disabled/hidden/missing UI states.

### Narrow Navigation Recovery

Local validation of the corrected 6-way hosted scripts reproduced the seeded Cinderfen layout setup pattern from the hosted release evidence: app-root navigation could finish replacing frames just after the last retry failed. `gotoAppRootWithRetry` now performs a final real-main-menu readiness check after the last transient setup-navigation error. It returns only if the real `main-menu` and `menu-new-campaign` controls are visible; otherwise the helper still throws the navigation failure.

## Coverage Preservation

- No tests were deleted.
- No tests were skipped.
- No assertions were weakened.
- No force-clicks were added.
- Full `npm run test:e2e:release` remains available.
- Existing local 3-way shard scripts remain available.
- The manual hosted 6-way matrix covers the same Playwright release suite as the 3-way matrix, split into smaller test-level jobs.
- Navigation recovery still requires the real main menu; blank pages and missing UI remain failures.
- Fast confidence, Optional visual QA, Release simulator, and Full release e2e workflow jobs remain otherwise unchanged.

## Local Verification

Final v0.11.9 gate:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS: 6 Playwright tests in about 2.2m.

npm run visual:qa
PASS: 5 Playwright visual QA tests in about 4.5m, 18 indexed screenshots, 0 recorded browser console errors, 0 screenshot retries.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 6.7m.

npm run test:e2e:release:hosted:shard1of6
PASS: 12 Playwright tests in about 6.9m.

npm run test:e2e:release:hosted:shard2of6
PASS: 11 Playwright tests in about 5.1m.

npm run test:e2e:release:hosted:shard3of6
PASS: 11 Playwright tests in about 5.2m.

npm run test:e2e:release:hosted:shard4of6
PASS: 11 Playwright tests in about 4.9m.

npm run test:e2e:release:hosted:shard5of6
PASS: 11 Playwright tests in about 11.3m with setup-navigation retry diagnostics and recovery.

npm run test:e2e:release:hosted:shard6of6
PASS: 11 Playwright tests in about 6.3m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS.
```

The existing local 3-way shards were not rerun in this pass because those scripts are unchanged and the corrected hosted 6-way scripts exercised the same 67-test release suite with final code.

## Next GitHub Check

Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input and expect:

- `Release matrix (shard-1-of-6)`
- `Release matrix (shard-2-of-6)`
- `Release matrix (shard-3-of-6)`
- `Release matrix (shard-4-of-6)`
- `Release matrix (shard-5-of-6)`
- `Release matrix (shard-6-of-6)`
- `Release simulator`

The old `shard-1-of-3`, `shard-2-of-3`, and `shard-3-of-3` hosted jobs should no longer appear in the manual release matrix. Local 3-way scripts still exist for developer use.

If a hosted shard still fails, capture the shard name, first failing test, first retry/context log, and whether the failure is job timeout, navigation, actionability, browser context setup, assertion, or browser console error.
