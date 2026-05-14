# v0.11.8 Hosted Release Matrix Stability Fix

Date: 2026-05-13

## Purpose

v0.11.8 stabilizes the manually triggered GitHub Actions 3-way release matrix after Fast confidence, Optional visual QA, and the release simulator were already green. This is a Playwright release-harness fix only. It does not change gameplay, content, saves, save format, tutorial behavior, campaign progression, visual assets, runtime art, balance, maps, units, factions, rewards, or coverage strength.

## GitHub Evidence

Emmanuel reported manual run `CI Release Matrix Dry Run #11` on commit `8b805b9`.

Reported results:

- Fast confidence: pass.
- Release simulator: pass.
- Release matrix shard 1: fail, with 2 failed, 9 flaky, 17 passed, about 32.7m.
- Release matrix shard 2: cancelled/failed after hosted-runner navigation setup failure.
- Release matrix shard 3: fail, with 1 failed, 3 flaky, 8 passed, about 11.4m.

### Shard 1

Failure:

- File: `tests/e2e/deep-flow.spec.ts`
- Test: `live campaign battles resolve victory and defeat through BattleScene results`
- Error: `page.reload: net::ERR_ABORTED; maybe frame was detached?`
- Stack: local `seedSave`

Finding: `deep-flow.spec.ts` still had its own storage-seed helper that wrote `localStorage` and then used raw `page.reload()`, unlike the newer hosted-safe shared seed helpers.

### Shard 2

Failure:

- Helper path: `gotoAppRootWithRetry` -> `gotoReadyMainMenu` -> `openMainMenuForStorageSeed` -> `seedCompletedCinderfenRouteCampaign`
- Error: app root navigation failed after two attempts because `page.goto` timed out.

Finding: the shared hosted-safe navigation helper was conceptually right but too strict for some hosted Linux release/layout paths.

### Shard 3

Failure:

- File: `tests/e2e/smoke.spec.ts`
- Test: `skirmish setup lists maps and launches Broken Ford @extended-smoke`
- Error: `locator.click: Test timeout of 35000ms exceeded`
- Target: `setup-map-broken_ford`
- Detail: Playwright resolved the element but waited for it to become visible, enabled, and stable.

Finding: this is an actionability stall in a long hosted release path, not a missing map, missing button, or gameplay failure.

## Changes

### Unified Deep-Flow Seeding

`tests/e2e/deep-flow.spec.ts` now imports the shared `SAVE_KEY` and `gotoReadyMainMenu` helper.

Replaced local raw-reload paths:

- `openFreshMainMenu`: now boots through `gotoReadyMainMenu`, removes the save key, then navigates through `gotoReadyMainMenu` again.
- `seedSave`: now boots through `gotoReadyMainMenu`, writes the synthetic save, navigates through `gotoReadyMainMenu`, and verifies Continue Campaign is enabled.

This preserves the same synthetic save content and assertions while removing the hosted-fragile reload after storage mutation.

### Hardened App-Root Navigation

`tests/e2e/shared-helpers.ts` now gives hosted CI one additional app-root navigation attempt and a longer readiness probe when checking whether the real main menu already rendered after a transient navigation timeout.

It also treats same-URL navigation interruption as transient setup-navigation churn and uses `waitUntil: "commit"` for the root navigation; the real app readiness check still happens afterward through visible main-menu controls.

The helper still fails if the app does not render real menu controls. It does not accept a blank page, hidden controls, or missing main menu.

### Narrow Hosted-Safe Click Helper

`tests/e2e/shared-helpers.ts` now exports `clickReady(locator, context)`.

It:

- waits for the target to be visible
- waits for the target to be enabled
- scrolls into view if needed
- clicks without `force`
- retries once on transient actionability/timeouts
- logs context on retry
- fails real disabled, locked, or missing UI states

Applied to release-path interactions reported by GitHub evidence or their shared helpers:

- `setup-map-broken_ford`
- skirmish `setup-start-battle` launches in the affected smoke/deep/layout helper paths
- Cinderfen campaign node/start helper paths
- Border Village campaign node/start paths that appeared in hosted release flakes

### Reload Removal

All Playwright `page.reload()` usage was removed from `tests/e2e` and `tests/visual-qa`.

The post-Crossing smoke persistence check still verifies persistence after a fresh app-root navigation, then continues the campaign and rechecks resources, XP, inventory count, and node locks.

### Narrow Layout Timeout

The Cinderfen menu/campaign readability layout test now has a 120s budget instead of 90s. This is scoped to the seeded Cinderfen layout pass that failed shard 2 on GitHub and locally reproduced a 90s timeout after multiple setup-navigation retries. No assertions were removed or weakened.

### Release Scripts

No release scripts changed.

The 3-way matrix remains:

- `npm run test:e2e:release:shard1of3`
- `npm run test:e2e:release:shard2of3`
- `npm run test:e2e:release:shard3of3`

## Coverage Preservation

- No tests were deleted.
- No tests were skipped.
- No assertions were weakened.
- No force-clicks were added.
- No console errors were hidden.
- Full smoke, full release, and all release shards remain available.
- Gameplay, content, saves, tutorial behavior, campaign progression, visuals, and runtime art were untouched.

## Local Verification

Final v0.11.8 local gate:

```text
npm test
PASS: 46 files / 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk-size warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS: 6 tests in about 2.3m.

npm run test:e2e:smoke
PASS: 12 tests in about 6.5m.

npm run visual:qa
PASS: 5 tests in about 4.4m, 18 screenshots, 0 browser console errors, 0 screenshot retries.

npm run smoke:preview
PASS: production preview checks with 0 browser console errors.

Targeted repro: live campaign battles resolve victory and defeat through BattleScene results
PASS: 1 test in about 1.1m.

Targeted repro: layout mobile portrait
PASS: 2 tests in about 2.7m.

Targeted repro: layout tablet Cinderfen readability after helper refinement
PASS: 1 test in about 1.7m, with setup-navigation retry diagnostics and recovery.

Targeted repro: skirmish setup lists maps and launches Broken Ford
PASS: 1 test in about 30.5s.

Targeted repro: post-Ashen campaign resolves Cinderfen Overlook
PASS: 1 test in about 1.4m.

Targeted repro: post-Crossing campaign launches Cinderfen Watch
PASS: 1 test in about 1.3m.

npm run test:e2e:release
PASS: 67 tests in about 36.5m after the final helper/timeout refinement.

npm run test:e2e:release:shard1of3
PASS: 28 tests in about 13.7m.

npm run test:e2e:release:shard2of3
PASS: 27 tests in about 16.5m, with setup-navigation retry diagnostics and recovery.

npm run test:e2e:release:shard3of3
PASS: 12 tests in about 6.0m.

npm run playtest:sim
PASS: simulated 255 runs across 85 campaign battle nodes.
```

During local verification, an earlier full-release attempt with the first helper refinement failed the same tablet Cinderfen layout path after 66/67 tests passed. The focused tablet repro passed, then the final patch added the scoped 120s layout budget and the final full release plus all 3-way shards passed.

## Next GitHub Check

Emmanuel should rerun the manual GitHub Actions `Run manual 3-way release shard matrix and simulator` workflow input and check:

- Shard 1 no longer fails in `deep-flow` `seedSave` with `page.reload`.
- Shard 2 no longer fails after only two app-root navigation attempts in `seedCompletedCinderfenRouteCampaign`.
- Shard 3 no longer stalls at `setup-map-broken_ford`.
- Any helper retry logs include context and still end in real assertions passing.
- No release tests are missing from the matrix.

If a hosted shard still fails, capture the first failing test name, helper context line, and whether the failure is navigation, actionability, assertion, console error, or total job timeout.
