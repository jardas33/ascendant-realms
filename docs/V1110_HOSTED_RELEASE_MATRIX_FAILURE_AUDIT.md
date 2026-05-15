# v0.11.10 Hosted Release Matrix Failure Audit

Date: 2026-05-14

Scope: GitHub Actions release-matrix stability only. This audit does not change gameplay, content, saves, save format, campaign progression, tutorial behavior, balance, visual assets, runtime art, or release coverage strength.

## Purpose

v0.11.9 made the manual hosted release matrix smaller by adding six GitHub-hosted shards with a 45 minute timeout. Local verification passed, including all six hosted shard scripts. GitHub Actions run #15 still failed across all six hosted release shards, which means the remaining issue is not simply shard size.

This audit records the hosted evidence and the safest next fix direction: deterministic test fixtures, hosted-safe actionability, and a hosted matrix shape that avoids test-level sharding side effects.

## Remote Evidence

Workflow: `CI Release Matrix Dry Run`

Manual run: `CI Release Matrix Dry Run #15`

Commit: `973e28f`

Manual selection: `Run manual release shard matrix and simulator`

Results:

- Fast confidence: PASS.
- Release simulator: PASS.
- Release matrix shard-1-of-6: FAIL.
- Release matrix shard-2-of-6: FAIL.
- Release matrix shard-3-of-6: FAIL.
- Release matrix shard-4-of-6: FAIL.
- Release matrix shard-5-of-6: FAIL.
- Release matrix shard-6-of-6: FAIL.

## Shard 1 Seed/Navigation Failure

Important failure:

- File: `tests/e2e/deep-flow.spec.ts`.
- Test: `alternate Refugee Caravan and Chapel choices apply rewards and completion`.
- Error: test timeout of 100000ms exceeded.
- Root setup error: `deep-flow seedSave storage seed setup: app root navigation failed after 3 attempt(s): page.goto: net::ERR_ABORTED at http://127.0.0.1:5173/`.
- Stack: `gotoAppRootWithRetry` to `gotoReadyMainMenu` to `seedSave`.

Interpretation: the deep-flow local seed path still depended on booting the app before mutating storage. On hosted runners, that boot-then-seed-then-boot shape can lose the page/frame during navigation. This is fixture instability, not evidence of a save-format or gameplay bug.

## Shard 2 Command Actionability Failure

Important failure:

- File: `tests/e2e/deep-flow.spec.ts`.
- Test: `battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions`.
- Expected `unit-order-summary` to contain `Moving`.
- Received `Guarding` and `Holding position and engaging nearby threats`.

Interpretation: the right-click movement command did not deterministically land on the hosted Chromium runner. The assertion is still meaningful and should remain, but the test should retry the same right-click command once before concluding the command was not accepted.

## Shard 3 Actionability/Layout/Pressure Failures

Failures included:

- Mystic Lodge, Acolyte, Watchtower combat, and research UI.
- Live campaign victory/defeat flow.
- Enemy pressure tutorial/skirmish guard.
- Tutorial entry and first objective layout.

Explicit actionability failure:

- File: `tests/e2e/layout.spec.ts`.
- Line evidence: clicking `menu-tutorial` timed out while the button was resolved but waiting for visible/enabled/stable.

Interpretation: several launch/setup clicks are real UI interactions but too sensitive to hosted runner actionability timing. They should use the existing non-forced `clickReady` helper where the remote evidence points to actionability stalls.

## Shard 4 Battle HUD/Layout Failures

Failures included:

- Campaign/setup/inventory/gallery reachable.
- Battle HUD and results layout inside viewport.

Important failure:

- File: `tests/e2e/layout.spec.ts`.
- Expected `battle-hud` visible after starting Border Village.
- `battle-hud` was not found within 15 seconds.

Interpretation: hosted layout tests launch real battle scenes across multiple viewport shapes. The test should use hosted-safe actionability for the campaign start click and a slightly larger narrow Battle HUD readiness window, without changing the app or viewport coverage.

## Shard 5 Layout Concentration Failures

Failures were concentrated in layout coverage:

- Battle HUD and results layout on mobile-short.
- v0.3 Cinderfen menu/campaign readability across desktop/tablet/mobile.
- Cinderfen battle HUD and Watch results readability across viewports.
- Ashen Outpost landmarks scoutable under fog, flaky.

Interpretation: layout coverage remains valuable but should run as explicit hosted layout groups instead of being fragmented by native test-level sharding. Each layout test already uses fresh pages through Playwright fixtures; the remaining improvement is deterministic seed setup and clearer hosted group boundaries.

## Shard 6 Seeded Campaign/Skirmish Boot Failures

Failures included extended smoke paths:

- Post-Ashen campaign resolves Cinderfen Overlook, wins Cinderfen Crossing, and persists rewards.
- Post-Crossing campaign launches Cinderfen Watch and persists completion.
- Skirmish difficulty selection changes fog and starting pressure.

Important setup failure:

- `seedCampaignSave storage seed setup expected main-menu after app boot, but main-menu was not found within 20000ms`.

Interpretation: shared seeded-save helpers still depended on app boot before localStorage mutation. Hosted runners can fail that boot stage even before the actual test scenario begins.

## Why v0.11.9 Was Not Enough

v0.11.9 reduced job size, but the scripts used:

```bash
playwright test --reporter=line --fully-parallel --workers=1 --shard=N/6
```

`--workers=1` kept each job single-worker, but `--fully-parallel` changed Playwright sharding to test-level distribution. That helped balance runtime, but it also fragmented files and made suite grouping less predictable for long e2e specs that contain related setup helpers and similar browser states.

The hosted failures are now spread across deterministic fixtures, actionability, layout setup, and long-flow grouping. More shards or larger global timeouts alone would not address those root causes.

## Recommended Fix Direction

Change first:

- Remove `--fully-parallel` from hosted release scripts.
- Replace the hosted native 6-way shards with explicit hosted release groups that still cover all 67 release tests.
- Seed localStorage before app boot for hosted-failing seeded-save paths.
- Apply non-forced `clickReady` only to interactions with hosted actionability evidence.
- Retry the right-click movement command once while keeping the `Moving` assertion.
- Keep Fast confidence, Optional visual QA, Release simulator, local full release, local 2-way shards, and local 3-way shards unchanged.

Do not change:

- Gameplay behavior.
- Save format or campaign progression.
- Release test assertions.
- Runtime art or visual assets.
- Full release coverage.
