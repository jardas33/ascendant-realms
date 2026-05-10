# v0.8 E2E Runtime And Shard Audit

Date: 2026-05-10

Scope: audit the current Playwright runtime shape and shard imbalance before changing scripts. This phase is documentation-only. It does not change tests, helpers, selectors, gameplay, campaign flow, saves, maps, units, factions, workers, construction, economy AI, pressure behavior, visuals, Playwright config, package scripts, or coverage.

## Current Playwright Configuration

`playwright.config.ts` remains deliberately conservative for a Phaser/WebGL browser game:

```ts
timeout: 35_000
workers: 1
fullyParallel: false
retries: process.env.CI ? 1 : 0
baseURL: "http://127.0.0.1:5173"
webServer: "npm run dev"
```

The single-worker shape is slow but stable. It avoids parallel browser/game state interactions while the suite relies on localStorage saves, Phaser scene boot, WebGL/SwiftShader launch flags, and direct battle test hooks.

## Current Scripts

| Script | Command | Role |
| --- | --- | --- |
| `test:e2e` | `playwright test` | Full Playwright suite. |
| `test:e2e:smoke` | `playwright test tests/e2e/smoke.spec.ts --reporter=line` | Frequent browser smoke lane. |
| `test:e2e:layout` | `playwright test tests/e2e/layout.spec.ts --reporter=line` | Responsive/layout/readability lane. |
| `test:e2e:deep` | `playwright test tests/e2e/deep-flow.spec.ts --reporter=line` | Deep gameplay/save/results lane. |
| `test:e2e:release` | `playwright test --reporter=line` | Full release gate. |
| `test:e2e:release:shard1` | `playwright test --reporter=line --shard=1/2` | Current 2-shard release shard 1. |
| `test:e2e:release:shard2` | `playwright test --reporter=line --shard=2/2` | Current 2-shard release shard 2. |

## Current Test Inventory

`npx playwright test --list` reports 67 tests in 4 spec files:

| File | Tests | Role |
| --- | ---: | --- |
| `deep-flow.spec.ts` | 28 | Release-critical gameplay, save, campaign, Results, HUD, minimap, retinue, rival, battle command, victory/defeat wiring, and full-flow coverage. |
| `enemy-pressure.spec.ts` | 2 | Cinderfen Watch pressure warning plus Tutorial/Skirmish no-pressure guards. |
| `layout.spec.ts` | 25 | Desktop/tablet/mobile menu, campaign, tutorial overlay, battle HUD, Cinderfen, Watch Results, Ashen Outpost, and fog/HUD layout checks. |
| `smoke.spec.ts` | 12 | Main menu, tutorial completion/exit, settings, New Campaign, Border Village launch, Cinderfen route smoke, skirmish, difficulty, and inventory. |

Support files:

| File | Role |
| --- | --- |
| `chapter2-helpers.ts` | Chapter 2 save seeding, route launch helpers, victory fast-forward helpers, and pressure/Cinderfen utility paths. |
| `shared-helpers.ts` | General fresh-menu, hero creation, seeded campaign, and continue-campaign helpers. |
| `semantic-command-log.ts` | Command-log helper utilities. |

## Current Known Runtimes

Latest v0.7.3 final gate:

| Lane | Tests | Runtime |
| --- | ---: | ---: |
| Smoke | 12 | 5.1m |
| Release | 67 | 30.1m |
| Release shard 1 of 2 | 55 | 24.6m |
| Release shard 2 of 2 | 12 | 5.1m |

Recent known layout lane:

| Lane | Tests | Runtime |
| --- | ---: | ---: |
| Layout | 25 | about 13.0-13.1m in the latest layout-readability gates |

The release lane is green but expensive. The 2-shard scripts are valid coverage-preserving CI commands, but they are not balanced enough to be a satisfying feedback loop.

## Why Shard 1 Is Imbalanced

Current 2-shard listing:

| Shard command | Listed tests | Files included |
| --- | ---: | --- |
| `npx playwright test --list --shard=1/2` | 55 | `deep-flow.spec.ts`, `enemy-pressure.spec.ts`, `layout.spec.ts` |
| `npx playwright test --list --shard=2/2` | 12 | `smoke.spec.ts` |

This explains the v0.7.3 runtime split: shard 1 carries both known slow spec families, while shard 2 carries only smoke. Playwright's built-in sharding is preserving ordering and test distribution, but the small number of large spec families makes the 2-way split uneven.

## 3-Shard Listing Check

Without changing scripts, `npx playwright test --list --shard=x/3` shows a cleaner conceptual split:

| Shard | Listed tests | Files included | Expected runtime read |
| --- | ---: | --- | --- |
| `1/3` | 28 | `deep-flow.spec.ts` | likely about 11-14m based on recent deep-flow/release slices |
| `2/3` | 27 | `enemy-pressure.spec.ts`, `layout.spec.ts` | likely about 13-15m because layout is the dominant file |
| `3/3` | 12 | `smoke.spec.ts` | about 5m |

This is not perfect, but it is much more honest than the current 55/12 split. It would reduce CI wall-clock if shards run in parallel, while preserving the full release gate when all three pass.

## Likely Slow Specs

### `deep-flow.spec.ts`

Keep these full-flow or release-gate covered:

- full main-menu/hero/gallery/reset navigation
- campaign event/town/reputation/resource choices
- Stronghold purchase and battle application
- unit veterancy, retinue, rival persistence, inventory, reward, and skill persistence
- live BattleScene command flows
- first campaign battle capture/build/train/rally/victory/reward path
- first enemy wave survival
- Ashen Outpost objective/result wiring
- live victory and defeat result transitions

These are expensive because they intentionally exercise real browser/game state rather than pure rule shortcuts.

### `layout.spec.ts`

Keep as release/layout coverage:

- menu/hero creation reachability across desktop/tablet/mobile
- campaign/setup/inventory/gallery reachability
- Tutorial / Proving Grounds overlay readability
- battle HUD and synthetic Results layout
- Cinderfen menu/campaign readability
- Cinderfen battle HUD and Watch Results readability
- Ashen Outpost objective/fog/HUD overlap checks

This file is slow because it multiplies scene setup across viewport matrices. It is valuable, but it is a better release/layout lane than a frequent local default.

### `smoke.spec.ts`

Smoke stays at 12 tests and about 5 minutes. It is not tiny, but it is the current best frequent lane because it covers the first playable tutorial shell and the frozen Cinderfen route.

## What Must Remain Full-Flow

- At least one Main Menu -> Hero Creation -> New Campaign -> Campaign Map flow.
- At least one Campaign Map -> Border Village -> BattleScene flow.
- The first campaign battle path through capture, build, train, rally, victory, rewards, and save persistence.
- Live victory and defeat result wiring through BattleScene.
- Cinderfen route smoke through Overlook, Crossing, Watch, Aftermath, persistence, and duplicate prevention.
- Tutorial completion and exit no-reward/no-save pollution checks.
- Retinue, rival, Stronghold, inventory/equipment, battle command, minimap, fog, and Ashen objective coverage.
- Desktop and mobile HUD/layout checks for the current Cinderfen and tutorial surfaces.

## What Could Move Or Be Tagged Later

Do not delete these, but consider clearer lanes:

- Keep `smoke.spec.ts` as frequent local smoke.
- Keep `layout.spec.ts` as explicit layout/release coverage.
- Keep `deep-flow.spec.ts` as deep/release coverage.
- Add 3-shard release scripts so CI can run deep, layout+pressure, and smoke in parallel.
- Later, split `deep-flow.spec.ts` into topical spec files if diagnosis gets difficult, but only as a structural move with no assertion deletion.
- Later, tag viewport matrices if the project needs a smaller "layout smoke" plus full "layout release" distinction.

## Would A 3-Shard Release Gate Help?

Yes, as a CI wall-clock improvement and local exact-reproduction convenience:

- It preserves all 67 tests.
- It does not require changing Playwright workers or parallel mode.
- It does not remove or weaken coverage.
- It makes the current slow families visible as separate shard jobs.
- It gives a cleaner manual reproduction command for deep-flow-only, layout+pressure, and smoke shards.

The expected weak point is that shard 3 would still be only about 5 minutes while shard 1/2 would likely be about 11-15 minutes. That is still far better than a 24.6-minute first shard.

## Would Project/File-Based Sharding Help?

File-based scripts already exist for smoke, layout, and deep. A stricter file-based release matrix could be:

```text
npm run test:e2e:deep
npm run test:e2e:layout
npx playwright test tests/e2e/enemy-pressure.spec.ts tests/e2e/smoke.spec.ts --reporter=line
```

That is easier to reason about than generic Playwright sharding, but it requires a custom mixed script for pressure+smoke and does not exercise Playwright's built-in shard semantics. Built-in 3-shard scripts are the safer first implementation because they are simple, reversible, and match the existing 2-shard precedent.

Project-based sharding is not recommended yet. It would increase Playwright config complexity and may invite unintended browser/project duplication.

## Recommendation

For v0.8, the first safe runtime improvement should be adding 3-shard release scripts while preserving:

- existing full `test:e2e:release`
- existing 2-shard scripts
- existing smoke/layout/deep scripts
- `workers: 1`
- `fullyParallel: false`
- all current tests and assertions

Do not rebalance by deleting tests or changing gameplay. Do not move tests into fake helpers. Do not change Playwright config or serving mode in the same pass.

## Phase Verification

```text
npm test: PASS, 45 files / 334 tests.
npm run build: PASS with known Phaser vendor warning.
npm run validate:content: PASS.
git diff --check: PASS.
```
