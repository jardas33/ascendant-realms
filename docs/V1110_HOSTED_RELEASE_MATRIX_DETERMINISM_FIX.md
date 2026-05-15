# v0.11.10 Hosted Release Matrix Determinism Fix

Date: 2026-05-14

Scope: hosted GitHub Actions release-matrix determinism and actionability only. No gameplay, content, saves, save format, tutorial behavior, campaign progression, balance, visual assets, runtime art, or coverage strength changed.

## Summary

v0.11.10 replaces the v0.11.9 hosted test-level shard matrix with explicit hosted release groups, removes `--fully-parallel` from hosted release scripts, and makes seeded-save setup deterministic before app boot. It also applies narrow hosted-safe actionability improvements where GitHub evidence showed a real UI element resolving but not becoming clickable/stable in time.

## GitHub Run #15 Evidence

Remote evidence from Emmanuel showed:

- Automatic Fast confidence: PASS.
- Manual Optional visual QA: already green after v0.11.7.
- Manual Release simulator: PASS.
- Manual hosted release matrix: all six v0.11.9 shards failed on GitHub-hosted runners.

The failures were not confined to one gameplay system. They included seed setup navigation aborts, a hosted right-click movement action that left a unit guarding, layout actionability stalls, Battle HUD readiness timeouts, and seeded campaign/skirmish boot failures.

## Why The 6-Way Native Split Was Not Enough

The v0.11.9 hosted scripts used Playwright native sharding with `--fully-parallel --workers=1 --shard=N/6`.

That split reduced the old 3-way wall-clock pressure, but it also made Playwright distribute individual tests across shards. The long release files are safer when grouped by suite intent because several tests share helper assumptions, viewport setup patterns, and seed styles. The new hosted matrix groups by behavior area while preserving every release test.

## Hosted Matrix Change

Removed from hosted scripts:

```bash
--fully-parallel --shard=N/6
```

Added explicit hosted release group scripts:

```bash
npm run test:e2e:release:hosted:deep-meta
npm run test:e2e:release:hosted:deep-battle
npm run test:e2e:release:hosted:deep-campaign-pressure
npm run test:e2e:release:hosted:layout-core
npm run test:e2e:release:hosted:layout-cinderfen
npm run test:e2e:release:hosted:smoke
```

The groups cover the same 67 release tests:

| Hosted group | Coverage | Local list count |
| --- | --- | ---: |
| `deep-meta` | Deep-flow campaign/meta/inventory/reward persistence checks | 12 |
| `deep-battle` | Deep-flow battle HUD, minimap, command, fog, hotkey, and first-battle checks | 11 |
| `deep-campaign-pressure` | Deep-flow campaign battle routes plus enemy pressure release checks | 7 |
| `layout-core` | Cross-viewport core menu, campaign, setup, inventory, tutorial, battle HUD, and results layout checks | 16 |
| `layout-cinderfen` | Cinderfen and Ashen Outpost readability/layout checks | 9 |
| `smoke` | Full smoke suite, including extended smoke tests | 12 |

Total: 67 tests.

The GitHub Actions `run_release_matrix` input now runs these six named hosted groups with the existing 45 minute per-job timeout. Heavy release jobs remain manual-only.

## Seed Helper Changes

The shared seeded-save helper now supports pre-boot storage seeding through `seedSaveBeforeAppBoot`.

The helper installs an init script, stores a one-shot payload in `window.name` on the current page, then boots the app root. When the app root loads, the init script writes the save payload to `localStorage` before the application reads save state.

This reduces hosted fragility by avoiding the old pattern:

```text
boot app -> mutate localStorage -> reload/goto app again
```

The updated deterministic path is:

```text
install seed init script -> prepare one-shot payload -> boot app once -> assert main menu/Continue Campaign readiness
```

Applied to:

- Shared `seedCampaignSave`.
- Chapter 2 seeded campaign helpers.
- Deep-flow local `seedSave`.

The save payloads, key, version, and assertions remain equivalent.

## Actionability Changes

The existing non-forced `clickReady` helper is now used for additional hosted-problem interactions:

- Continue Campaign after a seeded save.
- Tutorial launch buttons that timed out while resolved.
- Enemy-pressure tutorial and skirmish launch/setup buttons.
- Border Village campaign start in the layout Battle HUD test.

The helper still uses real Playwright actionability. It waits for visible/enabled state, scrolls if needed, retries once only on transient actionability errors, and does not force-click by default.

## Movement Command Reliability

The hosted shard-2 failure showed a right-click movement command leaving the selected unit in `Guarding` instead of `Moving`.

The deep-flow movement test now retries the same right-click command once before failing. The `Moving` assertion remains intact, so coverage is not weakened.

## Layout Strategy

Layout tests now have explicit hosted tags:

- `@hosted-layout-core`
- `@hosted-layout-cinderfen`

The Battle HUD layout path now uses `clickReady` for the Border Village campaign start button and a narrow 30 second Battle HUD readiness window, replacing the previous 15 second expectation for that hosted-problem launch path.

Viewport coverage is unchanged.

## Coverage Preservation

No tests were deleted, skipped, or weakened.

Local release confidence remains:

- `npm run test:e2e:release`.
- Existing 2-way release shards.
- Existing 3-way release shards.

Hosted GitHub release confidence now uses explicit grouped scripts instead of native hosted shards. The groups collectively list the same 67 release tests as the full release lane.

## What Emmanuel Should Rerun

In GitHub Actions, rerun the manual workflow input:

```text
run_release_matrix
```

Expected manual release jobs:

- `Release matrix (deep-meta)`.
- `Release matrix (deep-battle)`.
- `Release matrix (deep-campaign-pressure)`.
- `Release matrix (layout-core)`.
- `Release matrix (layout-cinderfen)`.
- `Release matrix (smoke)`.
- `Release simulator`.

If a group still fails, capture:

- The group name.
- The first failing test.
- The first retry/navigation/actionability log above the failure.
- Whether the failure is setup navigation, actionability, browser context setup, assertion, timeout, or console error.
