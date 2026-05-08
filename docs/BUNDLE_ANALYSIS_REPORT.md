# v0.4 Bundle Analysis Report

Date: 2026-05-07

Scope: measurement only for the current v0.4 technical baseline. This pass added an analyzer script and local report artifact path, but did not change gameplay, balance, chunking behavior, scene loading, data loading, test hooks, save format, campaign rules, or the Vite chunk warning limit.

## Analyzer Setup

Analyzer command:

```bash
npm run build:analyze
```

Implementation:

- Added `rollup-plugin-visualizer` as a dev dependency.
- Added `build:analyze` to run `tsc -p tsconfig.json && vite build --mode analyze`.
- `vite.config.ts` enables analyzer plugins only when `mode === "analyze"`.
- Analyzer output is written to `bundle-analysis/stats.html` and `bundle-analysis/stats.json`.
- `bundle-analysis/` is ignored by git and is not required at runtime.

The normal production build path remains:

```bash
npm run build
```

No `manualChunks` rule was changed in this pass. `chunkSizeWarningLimit` was not changed.

## Current Emitted Chunks

Analyzer run result:

```text
dist/index.html                        0.54 kB | gzip:   0.32 kB
dist/assets/index-CIXXIuKP.css         41.86 kB | gzip:   8.71 kB
dist/assets/index-TotuX8zG.js          435.50 kB | gzip: 116.99 kB
dist/assets/vendor-phaser-B61OQUcB.js  1,481.79 kB | gzip: 339.86 kB
```

Raw file sizes from `dist/`:

| Output | Bytes | Gzip bytes | Vite size |
| --- | ---: | ---: | ---: |
| `dist/index.html` | 538 | 324 | 0.54 kB / gzip 0.32 kB |
| `dist/assets/index-CIXXIuKP.css` | 41,862 | 8,711 | 41.86 kB / gzip 8.71 kB |
| `dist/assets/index-TotuX8zG.js` | 435,496 | 116,991 | 435.50 kB / gzip 116.99 kB |
| `dist/assets/vendor-phaser-B61OQUcB.js` | 1,481,792 | 339,855 | 1,481.79 kB / gzip 339.86 kB |

Current chunk count:

| Type | Count | Notes |
| --- | ---: | --- |
| JS chunks | 2 | App chunk plus `vendor-phaser`. |
| CSS chunks | 1 | Shared UI CSS. |
| Vite warning | Present | The warning remains because `vendor-phaser` is over 500 kB. The app chunk is below 500 kB. |

## Largest App Chunk Modules

These numbers come from `bundle-analysis/stats.json`. They are visualizer module contributions and do not sum exactly to final minified output sizes, but they are useful for ranking where app code lives.

| Rank | Module | Rendered bytes | Gzip bytes |
| ---: | --- | ---: | ---: |
| 1 | `src/game/scenes/BattleScene.ts` | 38,780 | 8,748 |
| 2 | `src/game/save/SaveNormalization.ts` | 12,935 | 2,961 |
| 3 | `src/game/core/RivalRules.ts` | 12,617 | 3,246 |
| 4 | `src/game/core/FirstExperienceGuidance.ts` | 12,239 | 3,612 |
| 5 | `src/game/data/validation/validateCampaign.ts` | 11,617 | 2,158 |
| 6 | `src/game/data/strongholdUpgrades.ts` | 11,201 | 2,792 |
| 7 | `src/game/battle/BattleSceneSystems.ts` | 11,141 | 2,827 |
| 8 | `src/game/data/borderMarchesNodes.ts` | 10,864 | 2,883 |
| 9 | `src/game/scenes/CampaignMapScene.ts` | 10,680 | 2,775 |
| 10 | `src/game/data/aiPersonalities.ts` | 10,579 | 2,047 |
| 11 | `src/game/scenes/HeroProgressionScene.ts` | 10,417 | 2,966 |
| 12 | `src/game/systems/PathfindingGrid.ts` | 9,953 | 2,771 |
| 13 | `src/game/ai/EnemyAIController.ts` | 9,348 | 2,394 |
| 14 | `src/game/data/cinderfenRoadNodes.ts` | 8,885 | 2,314 |
| 15 | `src/game/systems/AbilitySystem.ts` | 8,558 | 1,925 |

Largest app-level groups:

| Group | Rendered bytes | Gzip bytes | Modules |
| --- | ---: | ---: | ---: |
| `src/game/data/` | 208,553 | 55,170 | 48 |
| `src/game/scenes/` | 97,606 | 26,489 | 10 |
| `src/game/systems/` | 76,251 | 21,701 | 23 |
| `src/game/core/` | 76,004 | 23,083 | 23 |
| `src/game/battle/` | 52,068 | 14,330 | 10 |
| `src/game/ui/` | 32,405 | 10,554 | 18 |
| `src/game/campaign/` | 31,302 | 10,803 | 16 |
| `src/game/results/` | 29,049 | 9,375 | 8 |
| `src/game/save/` | 19,811 | 5,186 | 5 |

## Test And Dev Code Check

String scan of `dist/assets/index-TotuX8zG.js`:

| Pattern | Matches | Interpretation |
| --- | ---: | --- |
| `playwright` | 0 | Playwright e2e code is not bundled. |
| `vitest` | 0 | Vitest code is not bundled. |
| `describe(` | 0 | Unit test bodies are not bundled. |
| `chapter2-helpers` | 0 | E2E helper modules are not bundled. |
| `ScriptedBattlePlaytest` | 0 | Simulator test entry is not bundled. |
| `PlaytestRunner` | 0 | Simulator runner is not bundled. |
| `__ASCENDANT_TEST_HOOKS__` | 8 | Intentional runtime e2e hooks in `BattleScene`; not a major size source. |
| `data-testid` | 74 | Expected runtime DOM selectors used by UI/e2e. |

Conclusion: no large test/dev-only suite appears in the production bundle. The intentional e2e hooks remain present and should not be removed without a separate test-build strategy.

## Lazy-Load Candidate Assessment

### Asset Gallery

`AssetGalleryScene.ts` contributes about 4,125 rendered bytes / 1,502 gzip bytes.

Assessment: not a meaningful size optimization by itself. It is non-core and isolated enough to be a possible pilot for scene lazy-loading later, but the analyzer does not justify touching scene registration just to defer this file.

Recommendation: do not lazy-load Asset Gallery as the next optimization unless the goal is to prove a scene-loader pattern, not to materially reduce bundle size.

### Campaign, Map, And Data Modules

The `src/game/data/` group is the largest app-code group at about 208,553 rendered bytes / 55,170 gzip bytes across 48 modules. Notable entries include:

| Module | Rendered bytes | Gzip bytes |
| --- | ---: | ---: |
| `src/game/data/validation/validateCampaign.ts` | 11,617 | 2,158 |
| `src/game/data/strongholdUpgrades.ts` | 11,201 | 2,792 |
| `src/game/data/borderMarchesNodes.ts` | 10,864 | 2,883 |
| `src/game/data/aiPersonalities.ts` | 10,579 | 2,047 |
| `src/game/data/cinderfenRoadNodes.ts` | 8,885 | 2,314 |
| `src/game/data/items.ts` | 8,452 | 2,207 |
| `src/game/data/campaignRewards.ts` | 8,077 | 1,185 |
| `src/game/data/validation/validateMaps.ts` | 7,965 | 1,609 |
| `src/game/data/maps/cinderfenCauseway.ts` | 7,533 | 2,244 |
| `src/game/data/maps/ashenOutpost.ts` | 7,483 | 2,079 |

Assessment: meaningful size target, but risky. Data is eagerly indexed through `contentIndex.ts`, validated in `BootScene`, used by campaign rules, save normalization, Results, battle launch requests, and simulator/e2e assumptions. Splitting data now would affect many contracts.

Recommendation: do not data-split as the next optimization. If pursued later, start with a build/test validation command and one read-only data boundary at a time.

### Scene-Level Lazy Loading

Scene module contributions:

| Scene | Rendered bytes | Gzip bytes |
| --- | ---: | ---: |
| `BattleScene.ts` | 38,780 | 8,748 |
| `CampaignMapScene.ts` | 10,680 | 2,775 |
| `HeroProgressionScene.ts` | 10,417 | 2,966 |
| `SkirmishSetupScene.ts` | 7,843 | 2,254 |
| `SettingsScene.ts` | 7,543 | 2,209 |
| `ResultsScene.ts` | 6,047 | 1,828 |
| `HeroCreationScene.ts` | 5,324 | 1,756 |
| `MainMenuScene.ts` | 5,095 | 1,672 |
| `AssetGalleryScene.ts` | 4,125 | 1,502 |
| `BootScene.ts` | 1,752 | 779 |

Assessment: scene-level lazy loading could eventually reduce initial app code, especially if `BattleScene` and battle-adjacent modules are deferred. It is not worth the risk now because it touches Phaser scene registration, scene keys, navigation, Results transitions, save/load paths, and e2e hooks. The app chunk is already below 500 kB after the Phaser vendor split.

Recommendation: do not implement scene-level lazy loading yet.

## Recommended Next Single Optimization

Recommendation: do not perform a second runtime optimization immediately. The current Vite warning is isolated to Phaser, and the app chunk is below 500 kB.

If a next optimization is explicitly requested, the safest single candidate is:

```text
Move runtime content validation toward a build/test validation path, while preserving a release-gate validation command and existing unit coverage.
```

Why this instead of lazy loading:

- Analyzer shows validation/data modules are meaningful, while Asset Gallery alone is too small.
- It avoids Phaser scene lifecycle changes.
- It can be staged with tests before changing production boot behavior.
- It should be handled as one focused pass, not combined with data splitting or scene lazy loading.

Risk: medium. Production currently fails gracefully with a visible content error if bad data ships. Any future optimization must preserve equivalent release confidence before removing production boot validation.

Not recommended as the immediate next optimization:

- Lazy-loading Asset Gallery: low payoff.
- Lazy-loading BattleScene or scene groups: higher lifecycle risk.
- Data chunk splitting: meaningful but broad and contract-heavy.
- Raising `chunkSizeWarningLimit`: warning-policy change only, not optimization.

## Second Optimization Decision

Date: 2026-05-07

Chosen option: Option D - no code optimization.

Reason:

- Option A, lazy-loading Asset Gallery, is isolated but not size-meaningful. Analyzer output shows `AssetGalleryScene.ts` at about 4,125 rendered bytes / 1,502 gzip bytes, so it is not worth changing Phaser scene registration for bundle size alone.
- Option B, production-gating accidental test/dev code, is not justified by the hook audit. `docs/TEST_DEV_HOOK_AUDIT.md` found intentional production-included test surfaces, but no accidental large Playwright, Vitest, e2e-helper, or simulator leak.
- Option C, another stable vendor/tool chunk, has no clear target. Phaser is already isolated in `vendor-phaser`; no second large non-game runtime dependency exists.
- The remaining meaningful app-code targets are content validation, data, and scene-level loading. Those are broader than this pass and should be planned separately because they touch boot safety, data contracts, or scene lifecycle.

Before/after for this decision:

| Metric | Before decision | After decision |
| --- | ---: | ---: |
| JS chunks | 2 | 2 |
| CSS chunks | 1 | 1 |
| App JS | `assets/index-TotuX8zG.js` 435.50 kB / gzip 116.99 kB | unchanged |
| Phaser vendor JS | `assets/vendor-phaser-B61OQUcB.js` 1,481.79 kB / gzip 339.86 kB | unchanged |
| CSS | `assets/index-CIXXIuKP.css` 41.86 kB / gzip 8.71 kB | unchanged |
| Vite warning | Present for `vendor-phaser` | unchanged |

No source optimization was implemented. This is the safest analyzer-backed outcome for the current baseline.

## Verification

Analyzer run:

```text
npm run build:analyze
PASS: generated bundle-analysis/stats.html and bundle-analysis/stats.json.
Known Vite warning remains for vendor-phaser.
```

Required verification for this measurement pass is tracked separately:

```text
npm test
PASS: 38 test files, 270 tests, 10.12s.

npm run build
PASS: TypeScript compile and Vite production build.
App JS: assets/index-TotuX8zG.js, 435.50 kB / gzip 116.99 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.
CSS: assets/index-CIXXIuKP.css, 41.86 kB / gzip 8.71 kB.
Known Vite warning remains for vendor-phaser.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.3m.
```

Second optimization decision verification:

```text
npm test
PASS: 38 test files, 270 tests, 8.76s.

npm run build
PASS: TypeScript compile and Vite production build.
App JS: assets/index-TotuX8zG.js, 435.50 kB / gzip 116.99 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.
CSS: assets/index-CIXXIuKP.css, 41.86 kB / gzip 8.71 kB.
Known Vite warning remains for vendor-phaser.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.4m.

npm run test:e2e:release
PASS: 59 Playwright tests in 29.1m.
Slow files: tests/e2e/layout.spec.ts 12.8m and tests/e2e/deep-flow.spec.ts 11.4m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.

Production preview smoke
PASS: npm run preview -- --host 127.0.0.1 --port 4190 --strictPort.
PASS: main menu loaded, Prototype v0.3 / Cinderfen Route Baseline copy visible, New Campaign reached Campaign Map, Continue Campaign reached Campaign Map, Skirmish Setup opened, and console errors stayed at 0.
Note: Browser Use reached the local URL and saw 0 console errors, but its DOM/screenshot surface was blank for this app tab; a Playwright fallback completed the production preview smoke.
```
