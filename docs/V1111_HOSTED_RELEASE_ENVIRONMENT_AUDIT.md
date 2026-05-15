# v0.11.11 Hosted Release Environment Audit

Date: 2026-05-15

Scope: hosted GitHub Actions release-matrix browser environment only. This audit does not change gameplay, content, saves, save format, campaign progression, tutorial behavior, balance, visual assets, runtime art, or release coverage strength.

## Purpose

v0.11.10 removed hosted `--fully-parallel` sharding and replaced the manual release matrix with explicit hosted groups. Local verification passed, including all hosted groups and the full release lane, but GitHub Actions run #17 still failed across every hosted release group.

That means the remaining issue is not just shard shape. The hosted release browser environment itself is unstable for the long Phaser/browser release suite.

## Remote Evidence

Workflow: `CI Release Matrix Dry Run`

Manual run: `CI Release Matrix Dry Run #17`

Commit: `8779110`

Results:

- Fast confidence: PASS.
- Optional visual QA: skipped or absent as expected.
- Release simulator: PASS.
- Release matrix `deep-meta`: FAIL.
- Release matrix `deep-battle`: FAIL.
- Release matrix `deep-campaign-pressure`: FAIL.
- Release matrix `layout-core`: FAIL.
- Release matrix `layout-cinderfen`: FAIL.
- Release matrix `smoke`: FAIL.

## Current Hosted Server Mode

Before v0.11.11, the hosted release group scripts used the default `playwright.config.ts`.

That config starts:

```bash
npm run dev
```

through Playwright `webServer`, which means hosted release groups used the Vite dev server on `http://127.0.0.1:5173`.

This is different from `npm run smoke:preview`, which starts `vite preview` against the production build.

## Production Build Availability

The GitHub Actions release matrix job already runs:

```bash
npm run build
```

before the hosted release group command.

That means a production `dist/` build is available for each hosted group before Playwright starts. The hosted release groups can safely run against `vite preview` without changing app code or runtime behavior.

## Browser Install State

The workflow already installs Playwright Chromium with Linux dependencies:

```bash
npx playwright install --with-deps chromium
```

No install-step upgrade is required for v0.11.11.

## Current Chromium Launch Args

The default e2e config uses Chromium with:

```text
--use-gl=angle
--use-angle=swiftshader
--enable-unsafe-swiftshader
```

The preview smoke helper uses the same SwiftShader/WebGL args and has been green locally and in the fast confidence path.

For the hosted release matrix, the recommended environment is production preview plus additional Linux-hosted stability args:

```text
--no-sandbox
--disable-dev-shm-usage
--disable-gpu
--use-gl=angle
--use-angle=swiftshader
--enable-unsafe-swiftshader
```

These args are scoped to hosted release config only.

## Why Fast Confidence And Visual QA Can Pass

Fast confidence is intentionally small and runs only the stable `@ci-fast` subset. It does not put the hosted browser through the long seeded campaign, layout, and extended smoke loops.

Optional visual QA runs a separate screenshot harness that was already split and hardened in v0.11.7. It is long, but it is not the same 67-test release suite and does not exercise every campaign/skirmish release path.

The release matrix is uniquely stressful:

- repeated app boots
- repeated seeded saves
- repeated Phaser scene launches
- multiple viewport changes
- long campaign and battle loops
- more browser contexts over a longer wall-clock period

The dev server adds HMR/WebSocket and transform behavior that is useful during development but unnecessary for release verification.

## Recommended Fix

Create a hosted-only Playwright config that:

- runs the same hosted release groups against production preview instead of Vite dev server
- uses the existing `127.0.0.1:5173` base URL so test code remains unchanged
- keeps `workers: 1`, `fullyParallel: false`, and CI retry policy
- keeps traces, screenshots, and videos on failure
- adds hosted-only Chromium stability args
- preserves the same 67 release tests

Keep unchanged:

- automatic Fast confidence
- optional visual QA
- release simulator
- local full release
- local 2-way and 3-way release scripts
- manual full-release CI lane
