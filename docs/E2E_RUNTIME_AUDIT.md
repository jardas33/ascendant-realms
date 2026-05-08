# v0.3.1 E2E Runtime Audit

Scope: investigate why the Playwright suite is slow and document safe runtime improvements. This audit does not remove coverage, change gameplay, change UI behavior, or modify the test suite.

## Current Suite Shape

Source files in `tests/e2e`:

| File | Role | Lines | Generated Playwright tests |
| --- | --- | ---: | ---: |
| `tests/e2e/chapter2-helpers.ts` | Shared Chapter 2 seeding, save reading, route launching, and test-only victory fast-forward helpers | 571 | 0 |
| `tests/e2e/deep-flow.spec.ts` | Release-style gameplay, save, battle, results, HUD, minimap, retinue, rival, and campaign progression flows | 2,211 | 28 |
| `tests/e2e/layout.spec.ts` | Responsive reachability/readability, battle HUD layout, Cinderfen layout, Ashen Outpost HUD/fog checks | 711 | 21 |
| `tests/e2e/shared-helpers.ts` | General e2e setup helpers for fresh menu boot, hero creation, seeded default campaign saves, and continuing seeded campaigns | 117 | 0 |
| `tests/e2e/smoke.spec.ts` | Default browser smoke, settings, campaign launch, Chapter 2 smoke, skirmish, inventory | 683 | 10 |

`npx playwright test --list` currently reports 59 tests in 3 spec files. `chapter2-helpers.ts` is not a spec file.

## Explicit Test Lanes

The v0.4 test-lane pass keeps the existing file-level coverage intact and adds npm scripts for explicit lanes. No tests were deleted, no assertions were moved into helpers, and `npm run test:e2e` remains the full Playwright suite.

| Lane | Command | Files | Current tests | Intended use |
| --- | --- | --- | ---: | --- |
| Smoke/default | `npm run test:e2e:smoke` | `tests/e2e/smoke.spec.ts` | 10 | Frequent browser iteration. Covers boot, Settings, New Campaign, campaign launch, Cinderfen reward/save/duplicate-prevention flow, skirmish, difficulty, and inventory smoke. |
| Layout/responsive | `npm run test:e2e:layout` | `tests/e2e/layout.spec.ts` | 21 | Targeted responsive and mobile/readability checks. Keep available for UI/layout work and release review. |
| Deep-flow | `npm run test:e2e:deep` | `tests/e2e/deep-flow.spec.ts` | 28 | Release-critical full-flow gameplay, save, Results, HUD, minimap, retinue, rival, first-battle, and BattleScene result wiring checks. |
| Release gate | `npm run test:e2e:release` or `npm run test:e2e` | all e2e specs | 59 | Full checkpoint/freeze gate. This preserves the previous complete suite. |

This split uses simple file-level scripts rather than tags, grep, projects, sharding, or extra workers. That keeps the classification easy to inspect and avoids changing Playwright's current single-worker stability posture.

## Runtime Baseline

Recent recorded runtimes in `LLM_GAME_HANDOFF.md`:

| Date / pass | Count | Runtime | Notes |
| --- | ---: | ---: | --- |
| 2026-05-05 product-copy pass | 52 | 21.0m | Main-menu copy added to smoke coverage. |
| 2026-05-05 clean checkpoint | 52 | 21.4m | Slow files: `deep-flow.spec.ts`, `layout.spec.ts`. |
| 2026-05-05 release-candidate gate | 52 | 21.9m | Slow files: `deep-flow.spec.ts`, `layout.spec.ts`. |
| 2026-05-05 v0.3.1 UX polish pass | 59 | 31.4m | Slow files: `layout.spec.ts`, `deep-flow.spec.ts`; extra responsive/Cinderfen tests account for the larger current count. |
| 2026-05-05 safe helper pass | 59 | 28.6m | Same test count and coverage shape; slow files: `layout.spec.ts` 12.4m, `deep-flow.spec.ts` 11.5m. |
| 2026-05-06 explicit lane split | 10 smoke / 59 release | 5.4m smoke / 29.0m release | New `test:e2e:smoke` fast lane and `test:e2e:release` full gate; slow files still `layout.spec.ts` and `deep-flow.spec.ts`. |
| 2026-05-08 overnight continuation | 10 smoke / 59 release / 49 shard1 / 10 shard2 | 4.2m smoke / 27.4m release / 23.0m shard1 / 4.2m shard2 | Existing 2-shard scripts reverified. Shard 1 remains uneven because it carries `deep-flow.spec.ts` and `layout.spec.ts`. |

`playwright.config.ts` intentionally runs with `workers: 1`, `fullyParallel: false`, one Chromium project, and SwiftShader launch args. That is stable for a Phaser canvas/WebGL game, but it means every slow scene boot and every multi-step campaign flow is paid serially.

## Why It Takes So Long

The suite is slow for expected reasons:

- Phaser scene boot is repeated many times, and each test starts from a browser page rather than a cheaper pure-rule boundary.
- The suite is single-worker by design, so deep battle tests and generated viewport layout tests cannot overlap.
- `deep-flow.spec.ts` contains many release-gate checks with high per-test timeouts: 15 calls to `test.setTimeout`, several at 60-90 seconds.
- `layout.spec.ts` generates 21 tests from viewport loops. The Cinderfen readability section alone runs 4 campaign-map route checks plus 3 battle-HUD checks across desktop/mobile sizes.
- Chapter 2 smoke flows are intentionally broad: one post-Ashen test walks Overlook -> Waystation -> Crossing -> Results -> reload persistence, and one post-Crossing test walks Watch -> Results -> Aftermath -> duplicate prevention.
- Some tests still replay hero creation or campaign entry where a seeded save would prove the same layout or reachability contract.
- Several tests wait on live Phaser state via `waitForFunction`; that is correct for gameplay assertions, but slower than direct save/data assertions.

No `waitForTimeout` calls were found in the e2e files, which is good. The slowness is not caused by arbitrary sleeps.

## Slowest Areas

### `deep-flow.spec.ts`

This file is the main release-style coverage bucket. Slow or high-value areas include:

- `all skirmish maps and AI personalities launch without browser errors`: loops through First Claim, Broken Ford, and Ashen Outpost scene launches in one test.
- `first campaign battle path covers capture, build, train, rally, and victory rewards`: full new-campaign path, campaign launch, movement, capture progress, building placement, queue completion, rally behavior, forced victory, and save assertions.
- `first enemy wave pressure can damage the base and be survived`: validates live wave/base pressure instead of only synthetic results.
- `Mystic Lodge, Acolyte, Watchtower combat, and research UI work through battle commands`: broad battle command-system UI pass.
- `Ashen Outpost special objectives display completed states on Results`: campaign map, Ashen launch, objective completion hooks, enemy hero defeat, Results objective summary.
- `live campaign battles resolve victory and defeat through BattleScene results`: validates real BattleScene result wiring for both outcomes.

These protect important gameplay contracts and should not be casually converted to save-only tests.

### `layout.spec.ts`

This file is slow because it multiplies expensive flows across viewport matrices:

- 4 viewport checks for menu/hero creation.
- 4 viewport checks for campaign/setup/inventory/asset-gallery reachability.
- 4 viewport checks for battle HUD plus synthetic Results layout.
- 4 viewport checks for v0.3 Cinderfen campaign readability, including post-Ashen seed, Overlook choice, Waystation, Crossing details, route-complete seed, and Aftermath details.
- 3 viewport checks for Cinderfen Crossing and Watch battle-HUD readability; mobile portrait also completes Watch and checks Results.
- 2 Ashen Outpost desktop battle-layout/fog checks.

This is useful coverage, but it is the most obvious area to separate default smoke from release-gate depth.

### Chapter 2 Smoke Flows

`smoke.spec.ts` uses shared Chapter 2 helpers and already avoids replaying Chapter 1. The two longest current smoke flows are still broad:

- `post-Ashen campaign resolves Cinderfen Overlook, wins Cinderfen Crossing, and persists rewards`
- `post-Crossing campaign launches Cinderfen Watch and persists completion`

They are valuable default smoke coverage because the current release baseline is the frozen Cinderfen route. They should stay in the default suite until a smaller default/release split exists.

## Remaining Duplicated Setup

- `openFreshMainMenu`, `createHero`, `startNewCampaign`, `seedCampaignSave`, and `continueSavedCampaign` now live in `shared-helpers.ts` for smoke/layout usage.
- `deep-flow.spec.ts` still keeps its own setup helpers because they attach console/page-error failure handling and support many specialized deep-flow seeds.
- `seedSave` still exists only inside `deep-flow.spec.ts`; Chapter 2 specs use `chapter2-helpers.ts`. Older Chapter 1/deep-flow seed setup is not shared.
- `readSave` in `deep-flow.spec.ts` overlaps with `readStoredSave` in `chapter2-helpers.ts`.
- Synthetic Results setup exists in `deep-flow.spec.ts` as `startSyntheticResults`; layout has its own `showVictoryResults`.
- Battle setup helpers overlap across files: skirmish launch, battle loaded assertions, scene selection/building helpers, and direct scene mutation helpers are not centralized.

This duplication increases maintenance risk and makes it harder to optimize setup consistently.

## Applied Safe Improvements

Applied in the safe helper pass:

- Added `tests/e2e/shared-helpers.ts` for duplicated fresh-menu, hero creation, new-campaign, default campaign seed, and continue-campaign setup.
- Updated `smoke.spec.ts` to use the shared setup helpers while keeping Chapter 2 route assertions visible in the spec.
- Updated layout reachability tests to seed a normal campaign save where they are checking layout/reachability, not the New Campaign path.
- Updated layout battle-HUD tests to seed a campaign before launching Border Village, while keeping campaign-to-battle launch coverage and battle HUD assertions.
- Updated Ashen Outpost layout checks to seed a hero before opening skirmish setup, because those tests assert Ashen Outpost HUD/fog layout rather than hero creation.
- Updated smoke difficulty and inventory checks to use seeded hero/campaign state where the test is not specifically about hero creation.

Coverage shape after the pass:

- Playwright still reports 59 tests.
- `deep-flow.spec.ts` remains intact, including the full first campaign battle path and live victory/defeat result wiring.
- Full New Campaign and Skirmish hero-creation paths remain covered in smoke/deep-flow tests.
- Chapter 2 route copy, reward, save-state, and duplicate-prevention assertions remain in spec files, not hidden inside helpers.
- No gameplay, UI behavior, test IDs, selectors, balance, maps, units, or runtime source were changed.

## Remaining Safe Faster Seeding Candidates

These are good candidates for faster setup without reducing meaningful coverage:

- More layout matrices could eventually split into default versus release-gate scripts, preserving coverage but avoiding the full matrix on every local smoke run.
- Results layout checks can use one shared synthetic Results helper instead of each file having its own Results boot path.
- Cinderfen campaign readability tests can keep seeded post-Ashen and route-complete states, but avoid doing both partial-route and completed-route checks in every viewport if a release-gate profile keeps the full matrix.
- Chapter 1 event/town choice tests in `deep-flow.spec.ts` can reuse a shared seeded campaign helper instead of local custom save setup.
- Skirmish map/personality launch coverage can become data-driven targeted smoke by default plus a full matrix release-gate test, if the full matrix remains available and documented.

## Tests That Should Remain Full-Flow

Keep these as full-flow or release-gate coverage because they protect real player paths:

- Main menu -> hero creation -> new campaign at least once.
- Campaign Border Village launch into BattleScene at least once.
- First campaign battle path through capture, build, train, rally, victory, reward persistence.
- Live victory and defeat result wiring through BattleScene.
- First enemy wave pressure/base survival.
- Battle command UI for build/train/research/Watchtower/Mystic Lodge coverage.
- Ashen Outpost objectives and Captain Malrec objective/result coverage.
- Current Chapter 2 route smoke through Overlook, Crossing, Watch, Aftermath, reward persistence, and repeat-prevention.
- Desktop/mobile responsive checks for the current Cinderfen campaign and battle HUD, though the full viewport matrix can be release-gated.

## Recommended Improvements

| Improvement | Risk | Expected benefit | Recommendation |
| --- | --- | --- | --- |
| Create shared seeded campaign helpers for Chapter 1/default saves | Low | Less duplication; faster setup in layout/smoke specs | Applied for smoke/layout; leave deep-flow's specialized seeds local until a dedicated cleanup. |
| Share `openFreshMainMenu`, `createHero`, `startNewCampaign`, and seeded Continue Campaign helpers | Low | Cleaner e2e maintenance; less drift | Applied for smoke/layout; keep assertions explicit in spec files. |
| Share synthetic Results boot helper | Low-medium | Removes duplicate Results setup and makes layout/result tests cheaper to maintain | Keep at least one real BattleScene -> Results path. |
| Avoid repeated hero creation in layout tests where the assertion is reachability/layout only | Low-medium | Saves repeated menu/hero/campaign flow time across viewports | Applied to layout reachability, layout battle-HUD, Ashen layout, smoke difficulty, and smoke inventory checks. |
| Split `layout.spec.ts` into default smoke layout and release-gate layout matrices | Medium | Keeps default e2e faster while preserving full coverage on release runs | Use Playwright grep/project tags or npm scripts; do not delete tests. |
| Split `deep-flow.spec.ts` into topical specs | Medium | Easier slow-file diagnosis and targeted runs | Structural only; avoid changing assertions while splitting. |
| Mark ultra-deep tests as release-gate only | Medium-high | Large default runtime reduction | Appropriate only after a default smoke suite still covers menu, campaign launch, one battle, Results, Cinderfen route, and key responsive checks. |
| Keep current smoke tests as default | Low | Protects current frozen route | Applied through `npm run test:e2e:smoke`; the full suite remains available as `test:e2e` and `test:e2e:release`. |
| Try more workers | Medium-high | Potential wall-clock reduction | Not first choice because Phaser/localStorage/browser-state isolation can become flaky. Revisit only after specs are cleanly isolated. |

## Recommendation For v0.3.1

Do not remove or weaken e2e coverage during v0.3.1 polish.

Recommended path:

1. Keep `smoke.spec.ts` in the default e2e run.
2. Keep `deep-flow.spec.ts` and the full `layout.spec.ts` matrix as the release gate until a script/tag split exists.
3. Keep the new shared setup helper narrow and setup-only; do not move route assertions into helpers.
4. After helper cleanup, add explicit scripts such as default smoke and release-gate e2e rather than deleting tests.
5. Move only clearly ultra-deep matrices behind a release-gate command, and document that release runs still execute them before checkpointing.

The safe helper pass has now applied the lowest-risk setup/seeding changes. Further runtime reductions should be script/profile splits or carefully reviewed release-gate separation, not coverage deletion.

## v0.4 Lane Split Result

The first v0.4 e2e runtime action is now complete at the script/documentation level:

- `test:e2e:smoke` is the fast default lane and runs only `smoke.spec.ts`.
- `test:e2e:layout` isolates responsive/mobile/readability checks.
- `test:e2e:deep` isolates the release-critical deep gameplay flows.
- `test:e2e:release` runs the full 59-test suite with line reporter.
- `test:e2e` still works and remains the full suite under the existing Playwright convention.

Coverage preservation notes:

- At least one full New Campaign path remains in the smoke/default lane and deep-flow suite.
- The full first-battle campaign path remains in `deep-flow.spec.ts`.
- Chapter 2 reward, save, and duplicate-prevention assertions remain visible in `smoke.spec.ts`.
- Layout/mobile checks remain available in `layout.spec.ts`.
- No release-critical test was deleted or hidden inside helpers.

## Verification

Final checks after creating this audit:

```text
npm test
PASS: 38 test files, 270 tests

npm run build
PASS: TypeScript compile and Vite production build
Known warning remains: Some chunks are larger than 500 kB after minification.

npm run test:e2e -- --reporter=line
PASS: 59 Playwright tests in 28.6m
Slow files: tests/e2e/layout.spec.ts 12.4m, tests/e2e/deep-flow.spec.ts 11.5m

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes
```

Lane-split verification after adding explicit npm scripts:

```text
npm test
PASS: 38 test files, 270 tests, 11.25s.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 5.4m.
Slow test file: tests/e2e/smoke.spec.ts, 5.2m.

npm run test:e2e:release
PASS: 59 Playwright tests in 29.0m.
Slow files: tests/e2e/layout.spec.ts, 12.3m; tests/e2e/deep-flow.spec.ts, 12.1m.
```

2-shard continuation verification, 2026-05-08:

```text
npm test
PASS: 38 test files, 270 tests, 9.19s.

npm run build
PASS: TypeScript compile and Vite production build.
App JS: assets/index-Bi19pD8P.js, 436.32 kB / gzip 117.33 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.
CSS: assets/index-CeqfGaMI.css, 42.04 kB / gzip 8.74 kB.
Known Vite warning remains for vendor-phaser.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.2m.

npm run test:e2e:release
PASS: 59 Playwright tests in 27.4m on foreground rerun after targeted transient reruns.

npm run test:e2e:release:shard1
PASS: 49 Playwright tests in 23.0m.
Slow files: tests/e2e/layout.spec.ts 12.0m and tests/e2e/deep-flow.spec.ts 10.8m.

npm run test:e2e:release:shard2
PASS: 10 Playwright tests in 4.2m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.
```
