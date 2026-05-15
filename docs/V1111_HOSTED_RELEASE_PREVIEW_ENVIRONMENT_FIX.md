# v0.11.11 Hosted Release Preview Environment Fix

Date: 2026-05-15

Scope: hosted GitHub Actions release-matrix environment hardening only. This fix does not change gameplay, content, saves, save format, campaign progression, tutorial behavior, balance, visual assets, runtime art, or release coverage strength.

## Summary

v0.11.11 moves the manual hosted release matrix from Vite dev server to production preview and gives those hosted release groups a dedicated Playwright config. The goal is to remove dev-server/HMR/WebSocket instability from the long GitHub-hosted Phaser release suite while preserving every release test.

## GitHub Run #17 Evidence

Remote evidence from Emmanuel showed:

- Fast confidence: PASS.
- Optional visual QA: skipped or absent as expected.
- Release simulator: PASS.
- All six explicit hosted release groups failed.

Observed failure families:

- `deep-meta`: seeded-save boot reached `gotoReadyMainMenu`, but `menu-new-campaign` was not reliably visible.
- `deep-battle`: right-click movement command still left the unit in `Guarding` instead of `Moving`.
- `deep-campaign-pressure`: `clickReady` failed because the target page/context/browser had closed.
- `layout-core`: repeated fresh app boot failures, `page.goto` timeouts, `net::ERR_ABORTED`, closed browser/page errors, and missing main menu.
- `layout-cinderfen`: seeded Cinderfen layout setup failed during app-root navigation.
- `smoke`: extended smoke still failed around seeded campaign/skirmish setup and setup difficulty actionability.

v0.11.10 fixed grouping and deterministic fixture shape, but the hosted browser environment remained too unstable.

## Hosted Release Server Change

Before v0.11.11, hosted release scripts used `playwright.config.ts`, whose `webServer` command is:

```bash
npm run dev
```

v0.11.11 adds:

```text
playwright.hosted-release.config.ts
```

The hosted release config starts:

```bash
npm run preview:hosted
```

which serves the existing production build with:

```bash
vite preview --host 127.0.0.1 --port 5173 --strictPort
```

The GitHub workflow already runs `npm run build` before each hosted release group, so the preview server has a fresh production build to serve.

## Hosted Release Scripts

The hosted group scripts still cover the same release groups, but now use the hosted release config:

```bash
npm run test:e2e:release:hosted:deep-meta
npm run test:e2e:release:hosted:deep-battle
npm run test:e2e:release:hosted:deep-campaign-pressure
npm run test:e2e:release:hosted:layout-core
npm run test:e2e:release:hosted:layout-cinderfen
npm run test:e2e:release:hosted:smoke
```

Each command runs with:

```bash
--config=playwright.hosted-release.config.ts
```

Local full release and local shard scripts remain unchanged.

## Chromium Environment

The GitHub workflow already uses:

```bash
npx playwright install --with-deps chromium
```

No workflow dependency-install change was required.

The hosted release config adds Chromium launch args scoped only to hosted release groups:

```text
--no-sandbox
--disable-dev-shm-usage
--disable-gpu
--use-gl=angle
--use-angle=swiftshader
--enable-unsafe-swiftshader
```

This keeps the existing SwiftShader/WebGL path while adding Linux hosted-runner stability flags.

## Small Helper Changes

No gameplay or app runtime code changed.

Small test-only actionability updates were applied to reported hosted-problem launch paths:

- Smoke skirmish menu/difficulty/start paths use `clickReady`.
- Settings smoke battle launch uses `clickReady` for skirmish/difficulty/start.
- Deep-flow skirmish setup paths use `clickReady` for menu, map, difficulty, personality, and start interactions.
- Deep-flow skirmish map-loop return-to-menu uses `clickReady` for the battle HUD `Menu` button after hosted-preview evidence showed the HUD button can detach/re-render during click.
- Deep-flow Barracks build-command coverage now uses `clickReady` and asserts the deterministic placement banner/internal pending-building state instead of relying on the transient battle status line, which can be overwritten by resource or AI status messages.
- Layout Ashen Outpost and skirmish navigation paths use `clickReady`.

The deep battle right-click movement helper now tries two nearby alternate world points if the initial command does not produce `Moving`. The `Moving` assertion remains unchanged.

No force-clicks were added.

## Coverage Preservation

No tests were deleted, skipped, or weakened.

The hosted release groups still list the same 67 release tests:

- `deep-meta`: 12 tests.
- `deep-battle`: 11 tests.
- `deep-campaign-pressure`: 7 tests.
- `layout-core`: 16 tests.
- `layout-cinderfen`: 9 tests.
- `smoke`: 12 tests.

Total: 67 tests.

## Local Verification

Passed locally on 2026-05-15:

- `npm test`: 46 files / 351 tests.
- `npm run build`: TypeScript compile and Vite production build, with the known Phaser vendor chunk warning.
- `npm run validate:content`.
- `npm run validate:art-intake`: 1 candidate metadata JSON file and 0 review manifest JSON files checked.
- `npm run test:e2e:smoke:fast`: 6 tests.
- `npm run visual:qa`: 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.
- `npm run smoke:preview`: production preview smoke on `http://127.0.0.1:4173/`, 0 browser console errors.
- `npm run playtest:sim`: 255 simulated runs across 85 campaign battle nodes.
- Hosted release preview groups:
  - `deep-meta`: 12/12.
  - `deep-battle`: 11/11.
  - `deep-campaign-pressure`: 7/7.
  - `layout-core`: 16/16.
  - `layout-cinderfen`: 9/9.
  - `smoke`: 12/12.
- Targeted hosted-preview run #17 repros:
  - alternate Refugee Caravan and Chapel choices.
  - battle HUD minimap movement.
  - tutorial and skirmish pressure launch guard.
  - desktop tutorial layout.
  - battle HUD/results layout.
  - skirmish difficulty fog/pressure smoke.
- `npm run test:e2e:smoke`: 12/12 on rerun. The first local dev-server attempt timed out in the long Cinderfen Crossing smoke test during an app-root navigation retry; the targeted repro and full rerun passed.
- `npm run test:e2e:release`: 67/67 in 35.2m after rerunning with a longer local command ceiling. The first invocation exceeded the local tool timeout before returning output.
- `git diff --check`: passed with only the existing Windows CRLF warning on `.github/workflows/ci.yml`.

## What Emmanuel Should Rerun

In GitHub Actions, rerun the manual workflow input:

```text
run_release_matrix
```

Expected jobs:

- `Release matrix (deep-meta)`.
- `Release matrix (deep-battle)`.
- `Release matrix (deep-campaign-pressure)`.
- `Release matrix (layout-core)`.
- `Release matrix (layout-cinderfen)`.
- `Release matrix (smoke)`.
- `Release simulator`.

If a hosted group still fails, capture:

- group name
- first failing test
- first setup/navigation/actionability retry above the failure
- whether the failure was app boot, page/context/browser closure, actionability, movement assertion, timeout, or browser console error
