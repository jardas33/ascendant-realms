# v0.11.9 Hosted Release Matrix Split Audit

Date: 2026-05-14

## Purpose

This audit reviews the GitHub-hosted release matrix evidence after v0.11.8 and explains why the manual release matrix should move from 3 hosted shards to 6 hosted shards while preserving the local full release lane and existing local 3-way shard scripts.

This is CI/release tooling work only. It does not change gameplay, content, saves, save format, tutorial behavior, campaign progression, visual assets, runtime art, balance, maps, units, factions, rewards, or coverage strength.

## Remote Evidence

Emmanuel reported GitHub Actions manual run `CI Release Matrix Dry Run #13` on commit `bddb95b` or the latest v0.11.8 release-matrix stability commit.

Manual selection:

```text
Run manual 3-way release shard matrix and simulator
```

Results:

- Fast confidence: PASS.
- Optional visual QA: skipped or absent as expected.
- Release simulator: PASS.
- Release matrix shard 1 of 3: CANCELLED / timeout.
- Release matrix shard 2 of 3: CANCELLED / timeout.
- Release matrix shard 3 of 3: FAILED.

## Shard 1 Finding

Command:

```bash
npm run test:e2e:release:shard1of3
```

Observed:

- 28 tests using 1 worker.
- Job exceeded the 35 minute GitHub job timeout.
- Cancelled around 35m53s.
- First shown issue: `tests/e2e/deep-flow.spec.ts:569`, `main menu, info, hero creation selections, reset state, and gallery navigation work`.
- Timeout clicking `getByTestId("menu-reset-save")`; the locator resolved, but Playwright waited for it to be visible, enabled, and stable.

Interpretation:

Shard 1 is too large for the hosted 35 minute cap. The `menu-reset-save` click is a real hosted actionability signal, but the larger root issue is that the shard was still running at the job timeout. This is not a reason to delete deep-flow coverage.

## Shard 2 Finding

Command:

```bash
npm run test:e2e:release:shard2of3
```

Observed:

- 27 tests using 1 worker.
- Job exceeded the 35 minute GitHub job timeout.
- Cancelled around 36m2s.
- First shown issue: `tests/e2e/enemy-pressure.spec.ts:138`, `tutorial and skirmish launches do not activate pressure plans`.
- Browser context setup failed with `Protocol error (Browser.setDownloadBehavior): Failed to find browser context`.
- Retry also timed out.

Interpretation:

Shard 2 is also too large for the hosted 35 minute cap. The context setup failure appeared after the job had entered long-running timeout territory, so it is likely hosted Chromium instability under an overlong matrix job rather than an independent gameplay assertion failure.

## Shard 3 Finding

Command:

```bash
npm run test:e2e:release:shard3of3
```

Observed:

- 12 tests using 1 worker.
- Failed around 18m13s.
- First major failure: `tests/e2e/smoke.spec.ts:692`, `campaign Border Village launches a battle scene @extended-smoke`.
- Browser context setup failed with `Protocol error (Browser.setDownloadBehavior): Failed to find browser context`.
- Another failure appeared in `post-Ashen campaign resolves Cinderfen Overlook, wins Cinderfen Crossing, and persists rewards @extended-smoke`.

Interpretation:

Shard 3 is shorter than shards 1 and 2, but it still runs the long extended smoke file as one hosted job. Context instability here is best addressed by reducing hosted shard wall-clock and browser-session pressure, not by removing extended smoke coverage.

## Why Native 3-Way Sharding Is Not Enough

The local 3-way split was useful as a first manual CI matrix, but hosted evidence now shows it is too coarse:

- Shard 1 and shard 2 can run past GitHub's 35 minute job cap.
- Timeout cancellation can cascade into browser context failures and poor diagnostics.
- Shard 3 is shorter but still vulnerable to hosted Chromium/context instability.

The problem is hosted lane shape, not test coverage itself.

## 6-Way Hosted Sharding

The 6-way hosted matrix uses Playwright native sharding with test-level distribution enabled:

```bash
playwright test --reporter=line --fully-parallel --workers=1 --shard=N/6
```

Coverage is preserved because all six shards together run the same Playwright release suite as:

```bash
npm run test:e2e:release
```

Expected benefit:

- smaller hosted jobs
- test-level distribution instead of file-shaped shards
- single-worker execution inside each shard for the current Phaser/Vite stability policy
- lower per-job browser/context pressure
- less chance of hitting GitHub job timeout
- clearer failing shard logs if a real regression appears
- no change to local full release or existing local 3-way scripts

Local list verification for the final scripts split the 67-test release suite into 12/11/11/11/11/11 tests.

## Timeout Review

The 35 minute hosted release job timeout is too tight for 3-way shards on GitHub-hosted runners.

v0.11.9 uses 45 minutes for each hosted 6-way shard:

- 6-way shards should be smaller than the previous 3-way shards.
- 45 minutes gives GitHub-hosted runners breathing room for install/build/dev-server variance and Playwright retry overhead.
- This is not an unbounded timeout increase; it is scoped to manual hosted release shards only.

## Fast Confidence And Visual QA

No change is recommended for:

- automatic Fast confidence, which remains green on `npm run test:e2e:smoke:fast`
- optional visual QA, which remains green and manual
- release simulator, which remains green
- manual full release, which remains available for major freezes

## Helper Decision

The main fix is the hosted matrix split.

One narrow helper usage is justified by shard 1 evidence: the two `menu-reset-save` clicks in the first deep-flow test now use the existing non-forced `clickReady` helper. This preserves the same reset assertions and does not skip or weaken the test.

During local validation, the corrected test-level shard 5 reproduced the hosted shard-2 setup-navigation pattern in the seeded Cinderfen layout readability path. `gotoAppRootWithRetry` now performs one final real-main-menu readiness check after the last transient app-root navigation error. This is intentionally narrow: it accepts recovery only when the actual `main-menu` and `menu-new-campaign` controls are visible, so a blank page or missing app still fails.
