# v0.11.8 Release Matrix Reload Navigation Audit

Date: 2026-05-13

## Purpose

This audit maps remaining Playwright reload/navigation patterns to the hosted GitHub Actions 3-way release matrix failures reported after v0.11.7. It is test-harness-only work: no gameplay, content, save format, tutorial behavior, campaign progression, visual assets, runtime art, balance, or coverage strength changed.

## Remote Failure Mapping

GitHub Actions manual run `CI Release Matrix Dry Run #11` on commit `8b805b9` showed:

- `shard-1-of-3`: `live campaign battles resolve victory and defeat through BattleScene results` failed at `tests/e2e/deep-flow.spec.ts` inside local `seedSave`, with `page.reload: net::ERR_ABORTED; maybe frame was detached?`.
- `shard-2-of-3`: `seedCompletedCinderfenRouteCampaign` setup failed after two app-root navigation attempts in a layout path, showing the shared app-root helper needed more hosted-runner tolerance and diagnostics.
- `shard-3-of-3`: extended smoke/skirmish paths flaked on actionability, especially `setup-map-broken_ford` and nearby `setup-start-battle` interactions.

The evidence points to hosted-runner navigation/actionability instability in long release paths, not a deterministic gameplay failure.

## Pre-Fix Reload Sites

| File | Site | Followed localStorage mutation? | Decision | GitHub mapping |
| --- | --- | --- | --- | --- |
| `tests/e2e/deep-flow.spec.ts` | local `openFreshMainMenu` used `page.reload()` after `localStorage.removeItem(SAVE_KEY)` | Yes | Replaced with shared hosted-safe `gotoReadyMainMenu` before and after storage reset. | Same helper family as shard 1 reload failure. |
| `tests/e2e/deep-flow.spec.ts` | local `seedSave` used `page.reload()` after `localStorage.setItem(SAVE_KEY, ...)` | Yes | Replaced with shared hosted-safe `gotoReadyMainMenu` setup/reload path and Continue Campaign readiness check. | Directly maps to shard 1 failure. |
| `tests/e2e/smoke.spec.ts` | post-Crossing persistence check used `page.reload()` before continuing the campaign | No direct synthetic mutation at that line; it verified real saved progression survived an app reload | Replaced with shared hosted-safe `gotoReadyMainMenu`, preserving the persistence check through a fresh app-root navigation. | Reduces risk in shard 3 extended smoke paths without removing assertions. |

## Current Reload Status

Current command:

```bash
rg -n "page\\.reload\\(" tests/e2e tests/visual-qa
```

Result:

```text
No remaining Playwright page.reload() usage in tests/e2e or tests/visual-qa.
```

## Shared Navigation Review

`gotoReadyMainMenu` remains the app-ready gate for seeded-save setup. v0.11.8 exports it for deep-flow and smoke paths so those suites no longer maintain their own reload logic.

The helper still requires:

- visible `main-menu`
- visible `menu-new-campaign`
- normal assertions after storage seeding, including enabled `menu-continue-campaign`

It now:

- uses `page.goto("/", { waitUntil: "commit" })` for the setup navigation, then verifies real app readiness separately
- allows three app-root navigation attempts
- treats same-URL navigation interruption as transient setup-navigation churn
- probes for an already-rendered main menu for longer before failing a transient hosted navigation timeout

## Actionability Review

Remote shard 3 showed a resolved `setup-map-broken_ford` locator that never became actionable before the test timeout. v0.11.8 adds a narrow `clickReady` helper for hosted-problem interactions only.

The helper:

- waits for visible and enabled state
- scrolls into view when needed
- clicks without `force`
- retries once only on transient actionability errors
- logs the context and retry attempt
- still fails real locked/disabled states

Applied coverage-preserving call sites:

- Broken Ford map selection and start battle in extended smoke.
- Seeded skirmish start-battle launch helpers that appeared in hosted flake paths.
- Cinderfen and Border Village campaign-node/start interactions that appeared in shard evidence or use the same release helper path.

## No Script Changes

The release matrix scripts were not changed. The existing commands remain:

```bash
npm run test:e2e:release:shard1of3
npm run test:e2e:release:shard2of3
npm run test:e2e:release:shard3of3
```

Coverage remains equivalent: no tests were deleted, skipped, or weakened.

## Local Follow-Up

The final local 3-way release shards passed after the helper changes:

- `npm run test:e2e:release:shard1of3`: PASS, 28 tests.
- `npm run test:e2e:release:shard2of3`: PASS, 27 tests, with setup-navigation retry diagnostics and recovery.
- `npm run test:e2e:release:shard3of3`: PASS, 12 tests.

