# v0.11.4 Fast Confidence Seed/Reload Fix

Date: 2026-05-12

## Purpose

v0.11.4 stabilizes the GitHub Actions `Fast confidence` smoke lane after the v0.11.3 settings timeout fix. This pass stays strictly inside Playwright test-helper reliability and documentation. It does not change gameplay, content, save format, tutorial behavior, campaign progression, balance, visual assets, runtime art, CI coverage strength, maps, units, factions, rewards, or app runtime behavior.

## GitHub Failure Evidence

Emmanuel reported the `CI Release Matrix Dry Run` workflow failed in the automatic `Fast confidence` job:

- Run: `Checkpoint v0.11.3 fast confidence smoke fix #3`
- Failed step: `Run npm run test:e2e:smoke`
- Command: `playwright test tests/e2e/smoke.spec.ts --reporter=line`

The previous settings accessibility timeout appears addressed, but later seeded campaign/skirmish smoke paths failed.

Primary error:

- File: `tests/e2e/shared-helpers.ts:114`
- Helper: `seedCampaignSave(page, ...)`
- Region: `page.evaluate(({ key, value }) => { localStorage.clear(); ... })`
- Stack included `seedCampaignSave`, `launchSkirmishBattle`, and `tests/e2e/smoke.spec.ts:1195`

Retry error:

- `Test timeout of 35000ms exceeded.`
- `expect(page.getByTestId("main-menu")).toBeVisible() failed`
- Occurred after `await page.reload()` in `shared-helpers.ts:123`

Failed tests reported:

- `post-Ashen campaign resolves Cinderfen Overlook, wins Cinderfen Crossing, and persists rewards`
- `post-Crossing campaign launches Cinderfen Watch and persists completion`
- `skirmish difficulty selection changes fog and starting pressure`

Flaky tests reported:

- `campaign Border Village launches a battle scene`
- `skirmish setup lists maps and launches Broken Ford`

## Local Diagnosis

Before the fix, local full smoke still passed:

```text
npm run test:e2e:smoke
PASS: 12 tests in about 5.0m
```

Focused local reproduction before the helper change:

```text
npx playwright test tests/e2e/smoke.spec.ts --grep "post-Ashen campaign resolves Cinderfen Overlook" --retries=1 --trace=on
PASS: 1 test in 55.1s.

npx playwright test tests/e2e/smoke.spec.ts --grep "post-Crossing campaign launches Cinderfen Watch" --retries=1 --trace=on
PASS: 1 test in about 1.0m.

npx playwright test tests/e2e/smoke.spec.ts --grep "skirmish difficulty selection changes fog and starting pressure" --retries=1 --trace=on
PASS: 1 test in 26.7s.

npx playwright test tests/e2e/smoke.spec.ts --grep "campaign Border Village launches a battle scene" --retries=1 --trace=on
PASS: 1 test in 14.6s.

npx playwright test tests/e2e/smoke.spec.ts --grep "skirmish setup lists maps and launches Broken Ford" --retries=1 --trace=on
PASS: 1 test in 14.3s.
```

The local runs did not reproduce a deterministic gameplay failure. The remote error and stack point to seeded-save setup around app boot, localStorage mutation, `page.reload()`, and waiting for `main-menu`.

## Suspected Root Cause

The old helper shape was:

1. `page.goto("/")`
2. mutate localStorage immediately
3. `page.reload()`
4. wait for `main-menu`

That works locally, but on hosted runners it can race with first app boot and Phaser scene startup. If the page reload starts while the app is still settling, the later `main-menu` wait can consume the entire 35s test budget and leave the browser/context unstable for subsequent smoke tests.

The Chapter 2 seed helpers had the same seed-then-`reload()` pattern, which explains why post-Ashen and post-Crossing smoke paths were reported alongside the shared `seedCampaignSave` failure.

## What Changed

`tests/e2e/shared-helpers.ts` now provides a stable seeded-storage flow:

- navigate to `/` with `waitUntil: "domcontentloaded"`
- wait for `main-menu`
- wait for a main-menu action button so the app is not only painted but interactive
- mutate localStorage only after that stable app/origin state exists
- use `page.goto("/")` again instead of `page.reload()` after writing storage
- wait for `main-menu` again
- assert `menu-continue-campaign` is enabled for seeded campaign saves

`tests/e2e/chapter2-helpers.ts` now uses the same stable storage setup before and after writing post-Ashen, post-Crossing, and completed-route seeded saves.

`tests/e2e/smoke.spec.ts` now gives only `skirmish difficulty selection changes fog and starting pressure` a 60s timeout. This is justified by the remote failure evidence plus the fact that this smoke path performs two seeded skirmish launches back-to-back. After the more stable helper change, the local traced run took 44.9s, which confirms that the previous 35s budget was too tight for robust hosted-runner execution.

## Coverage Preservation

No smoke test was removed or skipped. Assertions were not weakened. The affected smoke paths still cover:

- seeded campaign save loading
- Continue Campaign availability
- Cinderfen Overlook choices and rewards
- Cinderfen Crossing launch, objectives, rewards, and persistence
- Cinderfen Watch launch, objectives, rewards, and aftermath persistence
- skirmish setup and map launch
- story and normal skirmish difficulty behavior, fog, and enemy pressure shape

## Timeout Changes

- `settings screen persists accessibility options`: still has the v0.11.3 60s timeout.
- `skirmish difficulty selection changes fog and starting pressure`: now has a 60s timeout.
- Post-Ashen and post-Crossing already had larger test-specific budgets and were not changed.
- No global Playwright timeout changed.

## Campaign/Skirmish Failure Assessment

The failed and flaky tests all touch app boot, seeded localStorage, or battle launch after a seeded setup. Local targeted runs passed before the fix, and the reported stack centered on `seedCampaignSave`/reload. v0.11.4 treats these failures as a shared seed/reload stability issue rather than five independent gameplay regressions unless the next hosted run produces a fresh isolated failure after seeded setup succeeds.

## Next GitHub Actions Check

After this commit is pushed, Emmanuel should re-check the automatic `Fast confidence` job and confirm:

1. The settings accessibility smoke still passes.
2. `post-Ashen campaign resolves Cinderfen Overlook...` passes.
3. `post-Crossing campaign launches Cinderfen Watch...` passes.
4. `skirmish difficulty selection changes fog and starting pressure` passes with the new scoped timeout.
5. Border Village and Broken Ford no longer show cascade/flaky context failures.
6. `npm run smoke:preview` still passes after smoke.

The known Phaser vendor chunk warning remains non-blocking.

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

npx playwright test tests/e2e/smoke.spec.ts --grep "post-Ashen campaign resolves Cinderfen Overlook" --retries=1 --trace=on
PASS: 1 test in about 1.1m.

npx playwright test tests/e2e/smoke.spec.ts --grep "post-Crossing campaign launches Cinderfen Watch" --retries=1 --trace=on
PASS: 1 test in 39.3s.

npx playwright test tests/e2e/smoke.spec.ts --grep "skirmish difficulty selection changes fog and starting pressure" --retries=1 --trace=on
PASS: 1 test in 32.7s.

npx playwright test tests/e2e/smoke.spec.ts --grep "campaign Border Village launches a battle scene" --retries=1 --trace=on
PASS: 1 test in 19.2s.

npx playwright test tests/e2e/smoke.spec.ts --grep "skirmish setup lists maps and launches Broken Ford" --retries=1 --trace=on
PASS: 1 test in 16.8s.

npm run test:e2e:smoke
PASS: 12 tests in about 5.2m.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

git diff --check
PASS.

npm run test:e2e:release
PASS: 67 tests in about 30.3m.

npm run test:e2e:release:shard1of3
PASS: 28 tests in about 12.4m.

npm run test:e2e:release:shard2of3
First pass: one local timeout in `enemy-pressure.spec.ts` tutorial/skirmish pressure guard after 26/27 tests passed.
Targeted rerun: PASS, 1 test in 29.1s.
Full shard rerun: PASS, 27 tests in about 14.7m.

npm run test:e2e:release:shard3of3
PASS: 12 tests in about 5.7m.

npm run visual:qa
PASS: 18 screenshots, 0 browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
```
