# v0.3.1 Performance Bundle Audit

Date: 2026-05-05 21:20 -04:00

Scope: investigate the known Vite large-chunk warning for the frozen v0.3 Cinderfen Route Baseline. The original audit did not change gameplay, balance, runtime source, Vite config, chunking, asset loading, or broad architecture.

Update: on 2026-05-06, the first v0.4 performance pass implemented only the approved Phaser vendor chunk split in `vite.config.ts`. It did not change gameplay, balance, scene loading, data loading, save format, campaign rules, e2e semantics, test hooks, asset loading, or chunk warning limits.

## Current Build Output

Command:

```bash
npm run build
```

Result: PASS.

Vite output:

```text
vite v6.4.2 building for production...
transforming...
196 modules transformed.
rendering chunks...
computing gzip size...
dist/index.html                 0.45 kB | gzip:   0.29 kB
dist/assets/index-CIXXIuKP.css  41.86 kB | gzip:   8.71 kB
dist/assets/index-BlnznQM_.js   1,918.65 kB | gzip: 457.79 kB
built in 11.27s
```

Exact Vite warning:

```text
(!) Some chunks are larger than 500 kB after minification. Consider:
- Using dynamic import() to code-split the application
- Use build.rollupOptions.output.manualChunks to improve chunking: https://rollupjs.org/configuration-options/#output-manualchunks
- Adjust chunk size limit for this warning via build.chunkSizeWarningLimit.
```

Raw output files after build:

| Output | Bytes | Vite size | Vite gzip |
| --- | ---: | ---: | ---: |
| `dist/index.html` | 454 | 0.45 kB | 0.29 kB |
| `dist/assets/index-BlnznQM_.js` | 1,918,650 | 1,918.65 kB | 457.79 kB |
| `dist/assets/index-CIXXIuKP.css` | 41,862 | 41.86 kB | 8.71 kB |

Static asset output is separate from the JS chunk:

| Asset group | Files | Size |
| --- | ---: | ---: |
| `dist/assets/manual` | 64 | 83.77 MB |
| `dist/assets/final` | 25 | 11.31 MB |
| `dist/assets/manifests` | 1 | 0.03 MB |

The runtime asset manifest is `dist/assets/manifests/assetManifest.json`, 35,273 bytes, 62 asset entries. The manifest and copied PNG assets are not the Vite large-chunk warning, but they matter for production footprint and future loading policy.

## v0.4 Vendor Chunk Split Result

Chosen optimization: Phaser vendor chunk split through Vite/Rollup `manualChunks`.

Implementation scope:

- Touched only `vite.config.ts` for runtime code/config.
- Split `node_modules/phaser` into `vendor-phaser`.
- Did not change `chunkSizeWarningLimit`.
- Did not lazy-load scenes, data, Asset Gallery, or content validation.
- Did not remove or gate `__ASCENDANT_TEST_HOOKS__`.

Before/after production build output:

| Metric | Before split | After split |
| --- | ---: | ---: |
| JS chunks | 1 | 2 |
| CSS chunks | 1 | 1 |
| JS/CSS emitted chunks | 2 | 3 |
| Main/app JS | `assets/index-BlnznQM_.js` 1,918.65 kB / gzip 457.79 kB | `assets/index-TotuX8zG.js` 435.50 kB / gzip 116.99 kB |
| Phaser vendor JS | Included in main JS | `assets/vendor-phaser-B61OQUcB.js` 1,481.79 kB / gzip 339.86 kB |
| Total JS | 1,918.65 kB / gzip 457.79 kB | 1,917.29 kB / gzip 456.85 kB |
| CSS | `assets/index-CIXXIuKP.css` 41.86 kB / gzip 8.71 kB | `assets/index-CIXXIuKP.css` 41.86 kB / gzip 8.71 kB |
| `index.html` | 0.45 kB / gzip 0.29 kB | 0.54 kB / gzip 0.32 kB |
| Vite warning | Present | Present |

After-split Vite output:

```text
dist/index.html                        0.54 kB | gzip:   0.32 kB
dist/assets/index-CIXXIuKP.css         41.86 kB | gzip:   8.71 kB
dist/assets/index-TotuX8zG.js         435.50 kB | gzip: 116.99 kB
dist/assets/vendor-phaser-B61OQUcB.js 1,481.79 kB | gzip: 339.86 kB
```

Warning status: still present. The app chunk is now below Vite's 500 kB warning threshold, but the `vendor-phaser` chunk remains above it. This is expected and acceptable for this pass because the goal was a safer app/vendor boundary and clearer measurement, not hiding the warning.

## Why The Warning Happens

The original warning was expected because the app emitted one main runtime JS chunk. The entrypoint imports Phaser, the game config, and the global CSS:

```ts
import Phaser from "phaser";
import { gameConfig } from "./game/config";
import "./game/styles/ui.css";
```

`gameConfig` statically imports and registers every scene:

```ts
scene: [
  BootScene,
  MainMenuScene,
  AssetGalleryScene,
  HeroCreationScene,
  CampaignMapScene,
  SkirmishSetupScene,
  BattleScene,
  ResultsScene,
  HeroProgressionScene,
  SettingsScene
]
```

That means the first production chunk includes:

- Phaser 3.90.0. The installed package exposes `node_modules/phaser/dist/phaser.esm.js`, which is about 7.86 MB unminified; Phaser's own minified browser bundles are about 1.17 MB before app code.
- All scene classes, including `BattleScene.ts` and all menu/progression/results scenes.
- Most shared battle/campaign/data modules reachable from those scenes.
- Runtime content validation, because `BootScene` imports `validateContent()` and runs it before starting the main menu.
- Data indexes from `contentIndex.ts`, which eagerly import units, buildings, maps, rewards, chapters, campaign nodes, items, affixes, AI personalities, rivals, reputation, stronghold upgrades, and modifiers.

After the v0.4 vendor split, Phaser is no longer hidden inside the app chunk. The warning remains because Phaser itself is still a large vendor chunk. The app source itself is not unusually large for the prototype, but its import graph remains intentionally simple and eager.

## Test And Dev Code Check

No large test suite or Playwright helper code appears to be accidentally shipped in the main JS bundle.

Bundle string scan:

| Pattern | Matches | Interpretation |
| --- | ---: | --- |
| `Phaser` | 3,102 | Phaser is present and is the largest likely contributor. |
| `playwright` | 0 | Playwright e2e code is not bundled. |
| `vitest` | 0 | Vitest test code is not bundled. |
| `describe(` | 0 | Unit test bodies are not bundled. |
| `chapter2-helpers` | 0 | E2E helper module is not bundled. |
| `ScriptedBattlePlaytest` | 0 | Playtest test entry is not bundled. |
| `PlaytestRunner` | 0 | Simulator runner is not bundled. |
| `__ASCENDANT_TEST_HOOKS__` | 8 | Intentional runtime hooks used by e2e; not a large size source. |
| `data-testid` | 74 | Expected DOM test IDs in runtime UI. |

The notable non-gameplay contributor is runtime validation. Strings like `Content Data Error`, `Campaign choice`, and `Stronghold upgrade` are present in the bundle because production boot currently validates content data. That is useful safety during prototype development, but it can be revisited later as a build-time or dev-only validation path.

## Asset Manifest And Loading

`AssetLoader` reads `/assets/manifests/assetManifest.json` at boot. `BootScene` then queues only `BATTLE_TEXTURE_ASSET_IDS` before starting the main menu, so the entire copied asset folder is not loaded into memory at boot.

The copied `manual` asset folder is large, around 83.77 MB. This does not trigger Vite's JS chunk warning, but it is relevant to future production hosting and deploy size. A separate asset audit could later decide whether manual prompt/reference assets should ship in production builds.

## Release Assessment

Status: safe for prototype; first v0.4 optimization implemented.

The warning is acceptable for the current frozen v0.3 route baseline and v0.3.1 polish layer because:

- The build passes.
- The app JS chunk is now 435.50 kB minified / 116.99 kB gzip.
- The remaining warning is isolated to the Phaser vendor chunk at 1,481.79 kB minified / 339.86 kB gzip.
- Production preview smoke has already passed without a production-only crash.
- Phaser-heavy prototypes commonly exceed Vite's default 500 kB chunk warning.
- The first optimization did not touch boot, scene lifecycle, content access, gameplay rules, or e2e assumptions.

The warning should stay documented as non-blocking unless a later optimization explicitly targets lazy scene/data loading or an intentional warning-limit policy.

## Safe Future Options

| Option | Expected benefit | Risk | Notes |
| --- | --- | --- | --- |
| Add bundle analyzer/reporting only | Better evidence before edits | Low | Safe first step. Add analyzer output or Rollup visualizer in a separate tooling-only pass. |
| Vendor chunking Phaser | Better browser cache behavior; clearer app/vendor split | Implemented | Implemented on 2026-05-06. App chunk is now below 500 kB, but Phaser vendor chunk still triggers the Vite warning. |
| Route/scene code splitting | Smaller initial app chunk | Medium-high | Requires async scene registration or delayed imports. Must protect Phaser scene keys, save/load transitions, Results navigation, and e2e launch hooks. |
| Lazy loading heavy scenes | Defers Asset Gallery, Hero Inventory, Results, or Battle code | Medium | Safer if introduced one scene at a time after a scene-loader pattern exists. BattleScene is the most valuable but also the riskiest target. |
| Separate dev/test hooks | Slightly smaller production bundle; cleaner release surface | Low-medium | `__ASCENDANT_TEST_HOOKS__` is small but e2e depends on it. A test-build flag or explicit safe hook module would be needed. |
| Move runtime content validation to build/test only | Smaller production runtime and less boot work | Medium | Production currently shows a friendly content error instead of starting with bad data. Any change needs replacement coverage in `npm test` and maybe a release validation command. |
| Data chunk splitting | Defers campaign/map/reward data | Medium-high | `contentIndex.ts` eagerly builds global lookup tables. Splitting data would affect many rules, scenes, validation, save normalization, and Results code. |
| Asset shipping/pruning audit | Smaller deploy footprint | Low-medium | Separate from JS chunk warning. Could keep final/runtime assets in production and exclude manual prompt/reference assets if the asset pipeline supports it. |
| Raise `chunkSizeWarningLimit` only | Removes warning noise | Low technical risk, low value | Should only happen after documenting the accepted target. It hides the warning without improving loading. |

## Recommendation For v0.3.1

Do not implement additional code splitting unless the user explicitly asks for it as a focused optimization task.

Recommended path after the v0.4 vendor split:

1. Keep the remaining Vite large-chunk warning documented as accepted Phaser vendor risk.
2. Do not raise `chunkSizeWarningLimit` unless the team explicitly wants warning-policy cleanup rather than optimization.
3. If more optimization is requested, collect analyzer output before choosing a second change.
4. Defer route/scene/data splitting until there is a dedicated verification budget.
5. Treat runtime content validation and production asset pruning as separate investigations before touching scene-loading architecture.

No additional optimization was implemented in this audit update.

## Verification

Final checks after creating this audit:

```text
npm test
PASS: 38 test files, 270 tests

npm run build
PASS: TypeScript compile and Vite production build
Known warning remains: Some chunks are larger than 500 kB after minification.
```

v0.4 vendor split verification:

```text
Pre-change npm run build
PASS: baseline reproduced.
Main JS: assets/index-BlnznQM_.js, 1,918.65 kB / gzip 457.79 kB.
CSS: assets/index-CIXXIuKP.css, 41.86 kB / gzip 8.71 kB.
JS chunks: 1. CSS chunks: 1. Vite warning present.

Post-change npm test
PASS: 38 test files, 270 tests, 10.91s.

Post-change npm run build
PASS: TypeScript compile and Vite production build.
App JS: assets/index-TotuX8zG.js, 435.50 kB / gzip 116.99 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.
CSS: assets/index-CIXXIuKP.css, 41.86 kB / gzip 8.71 kB.
JS chunks: 2. CSS chunks: 1. Vite warning still present for vendor-phaser.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.6m.

npm run test:e2e:release
PASS: 59 Playwright tests in 29.1m.
Slow files: tests/e2e/layout.spec.ts 12.9m, tests/e2e/deep-flow.spec.ts 11.6m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.

Production preview smoke
PASS: npm run preview -- --host 127.0.0.1 --port 4189 --strictPort.
PASS: title Ascendant Realms.
PASS: Prototype v0.3 / Cinderfen Route Baseline copy visible.
PASS: New Campaign opened hero creation and Begin Campaign reached Campaign Map.
PASS: Continue Campaign reached Campaign Map after the smoke save existed.
PASS: Skirmish Setup opened and listed maps.
PASS: browser console errors stayed at 0.
Preview server was stopped after the smoke.
```
