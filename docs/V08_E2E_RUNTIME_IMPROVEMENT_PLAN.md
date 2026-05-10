# v0.8 E2E Runtime Improvement Plan

Date: 2026-05-10

Scope: choose one safe e2e runtime/lane improvement after the v0.8 shard audit. This phase is planning-only. It does not change tests, scripts, Playwright config, helpers, assertions, gameplay, visuals, maps, units, factions, saves, rewards, pressure behavior, or serving mode.

## Goals

- Reduce CI and release-gate pain without weakening coverage.
- Keep smoke fast enough for frequent local iteration.
- Preserve the full release gate as the authoritative checkpoint lane.
- Make slow areas easier to diagnose.
- Avoid hiding real player flows behind fake assertions or opaque helpers.
- Avoid changing gameplay for test speed.

## Non-Goals

- Do not delete e2e tests.
- Do not make smoke the only release gate.
- Do not replace full-flow tests with save-only assertions.
- Do not enable more Playwright workers in this pass.
- Do not change `fullyParallel`.
- Do not switch e2e serving from dev server to preview server in the same pass.
- Do not restructure deep-flow or layout specs yet.
- Do not change game code, UI code, battle runtime, save format, or content.

## Options

### Option A - Rebalance Existing 2 Shards

Shape: change the current `release:shard1` / `release:shard2` scripts or test ordering so shard 1 does not receive deep-flow, layout, and enemy-pressure together.

Value:

- Could keep the public script count unchanged.
- Might reduce the slowest shard if ordering can be nudged cleanly.

Risks:

- Built-in Playwright sharding is simple; custom balancing would likely require file-specific scripts or ordering hacks.
- It may make the current shard names misleading.
- It may accidentally stop being equivalent to a built-in `1/2` + `2/2` full-suite split.

Decision: do not choose this as the first v0.8 implementation.

### Option B - Add 3-Shard Release Scripts

Shape: preserve every existing script and add:

```json
"test:e2e:release:shard1of3": "playwright test --reporter=line --shard=1/3",
"test:e2e:release:shard2of3": "playwright test --reporter=line --shard=2/3",
"test:e2e:release:shard3of3": "playwright test --reporter=line --shard=3/3"
```

Value:

- Preserves coverage.
- Preserves full release and existing 2-shard scripts.
- Does not change Playwright config.
- Keeps `workers: 1`.
- Gives a cleaner split by current slow-file families:
  - shard 1 of 3: 28 deep-flow tests
  - shard 2 of 3: 27 layout+pressure tests
  - shard 3 of 3: 12 smoke tests
- Easy to verify with `--list` and targeted shard runs.
- Easy to roll back.

Risks:

- Adds three more npm scripts.
- CI report/artifact count increases if adopted.
- Shard 3 remains shorter than shards 1 and 2.
- It improves CI wall-clock only when shards run in parallel; local sequential use is not faster than the full release gate.

Decision: recommended first implementation.

### Option C - Keep Full Release Lane But Document Longer Timeout

Shape: make no script change and document that `npm run test:e2e:release` needs a longer local/agent timeout.

Value:

- Zero technical risk.
- Accurately reflects the current 30-minute lane.

Risks:

- Does not reduce CI pain.
- Does not address shard1 imbalance.
- Leaves users with the same slow feedback loop.

Decision: useful documentation, but not enough as the only v0.8 technical runtime change.

### Option D - Split Deep-Flow And Layout Release Groups

Shape: create file-based release scripts such as `release:deep`, `release:layout`, and `release:smoke-pressure`.

Value:

- Very readable.
- Maps directly to spec ownership.
- Good local diagnosis.

Risks:

- More custom than built-in Playwright sharding.
- Needs a mixed pressure+smoke script to preserve full coverage in three jobs.
- Could drift from `test:e2e:release` if future spec files are added and not assigned.

Decision: reasonable future option, but not the first v0.8 implementation.

### Option E - Change Workers Or Parallelism

Shape: increase `workers`, enable `fullyParallel`, or create Playwright projects for parallelism.

Value:

- Could reduce local and CI wall-clock materially.

Risks:

- High for this prototype: Phaser/WebGL startup, localStorage saves, direct scene hooks, single dev server, and visual/layout checks may expose timing and isolation flakes.
- Requires deeper test isolation review.

Decision: do not implement in v0.8.

## Recommended First Implementation

Implement Option B: add 3-shard release scripts only.

Why this one:

- It is additive.
- It preserves all existing lanes.
- It does not change coverage.
- It does not change game/runtime code.
- It does not change Playwright config.
- It directly addresses the observed 55/12 two-shard imbalance.
- It creates a future CI path where the slowest release shard is likely closer to 13-15 minutes than 24-25 minutes.

## Verification Plan

After adding scripts:

```text
npm test
npm run build
npm run validate:content
npm run test:e2e:smoke
npm run test:e2e:release:shard1of3
npm run test:e2e:release:shard2of3
npm run test:e2e:release:shard3of3
git diff --check
```

Also run list checks if needed:

```text
npx playwright test --list --shard=1/3
npx playwright test --list --shard=2/3
npx playwright test --list --shard=3/3
```

The existing full release and 2-shard scripts must remain untouched:

```text
npm run test:e2e:release
npm run test:e2e:release:shard1
npm run test:e2e:release:shard2
```

Full release can be deferred to the final v0.8 release gate because this implementation does not alter test bodies or Playwright config, and because all three new shards together are the full release set.

## Rollback Plan

If the new scripts fail due to script shape rather than real test failures:

1. Remove only the three `shard1of3` / `shard2of3` / `shard3of3` package scripts.
2. Leave existing release, 2-shard, smoke, layout, and deep scripts untouched.
3. Re-run `npm run test:e2e:smoke` and `git diff --check`.

If an actual test fails in a new shard:

1. Rerun the exact failing test once.
2. If the targeted rerun passes, rerun the failed shard once.
3. Document the transient in `LLM_GAME_HANDOFF.md`.
4. Do not change gameplay or weaken assertions to hide the failure.

## Phase Verification

```text
npm test: PASS, 45 files / 334 tests.
npm run build: PASS with known Phaser vendor warning.
npm run validate:content: PASS.
git diff --check: PASS.
```
