# v0.3.1 Performance Bundle Audit

Date: 2026-05-05 21:20 -04:00

Scope: investigate the known Vite large-chunk warning for the frozen v0.3 Cinderfen Route Baseline. This pass did not change gameplay, balance, runtime source, Vite config, chunking, asset loading, or broad architecture.

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

## Why The Warning Happens

The warning is expected because the app currently emits one main runtime JS chunk. The entrypoint imports Phaser, the game config, and the global CSS:

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

The app source itself is not unusually large for the prototype, but its import graph is intentionally simple and eager. The warning is mostly a packaging shape issue, not evidence of one broken module.

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

Status: safe for prototype, watch for v0.3.1.

The warning is acceptable for the current frozen v0.3 route baseline because:

- The build passes.
- Gzip size is 457.79 kB for the main JS chunk.
- Production preview smoke has already passed without a production-only crash.
- Phaser-heavy prototypes commonly exceed Vite's default 500 kB chunk warning when shipped as one runtime bundle.
- Optimizing chunk boundaries now would touch boot, scene lifecycle, content access, and e2e assumptions. That is higher risk than the warning itself.

The warning should stay documented as non-blocking until bundle optimization becomes an explicit milestone.

## Safe Future Options

| Option | Expected benefit | Risk | Notes |
| --- | --- | --- | --- |
| Add bundle analyzer/reporting only | Better evidence before edits | Low | Safe first step. Add analyzer output or Rollup visualizer in a separate tooling-only pass. |
| Vendor chunking Phaser | Better browser cache behavior; clearer app/vendor split | Low-medium | Does not meaningfully reduce total JS. Phaser vendor chunk may still exceed 500 kB, so the warning may remain unless warning limits are adjusted. |
| Route/scene code splitting | Smaller initial app chunk | Medium-high | Requires async scene registration or delayed imports. Must protect Phaser scene keys, save/load transitions, Results navigation, and e2e launch hooks. |
| Lazy loading heavy scenes | Defers Asset Gallery, Hero Inventory, Results, or Battle code | Medium | Safer if introduced one scene at a time after a scene-loader pattern exists. BattleScene is the most valuable but also the riskiest target. |
| Separate dev/test hooks | Slightly smaller production bundle; cleaner release surface | Low-medium | `__ASCENDANT_TEST_HOOKS__` is small but e2e depends on it. A test-build flag or explicit safe hook module would be needed. |
| Move runtime content validation to build/test only | Smaller production runtime and less boot work | Medium | Production currently shows a friendly content error instead of starting with bad data. Any change needs replacement coverage in `npm test` and maybe a release validation command. |
| Data chunk splitting | Defers campaign/map/reward data | Medium-high | `contentIndex.ts` eagerly builds global lookup tables. Splitting data would affect many rules, scenes, validation, save normalization, and Results code. |
| Asset shipping/pruning audit | Smaller deploy footprint | Low-medium | Separate from JS chunk warning. Could keep final/runtime assets in production and exclude manual prompt/reference assets if the asset pipeline supports it. |
| Raise `chunkSizeWarningLimit` only | Removes warning noise | Low technical risk, low value | Should only happen after documenting the accepted target. It hides the warning without improving loading. |

## Recommendation For v0.3.1

Do not implement code splitting in v0.3.1 unless the user explicitly asks for it as a focused optimization task.

Recommended v0.3.1 path:

1. Keep the Vite large-chunk warning documented as accepted prototype risk.
2. If optimization work is requested, start with a measurement-only bundle analyzer report.
3. Consider Phaser vendor chunking only after analyzer output confirms the split is useful for caching or diagnostics.
4. Defer route/scene/data splitting until after the current Cinderfen readability polish is stable and there is a dedicated verification budget.
5. Treat runtime content validation and production asset pruning as separate, safer follow-up investigations before touching scene-loading architecture.

No optimization was implemented in this audit.

## Verification

Final checks after creating this audit:

```text
npm test
PASS: 38 test files, 270 tests

npm run build
PASS: TypeScript compile and Vite production build
Known warning remains: Some chunks are larger than 500 kB after minification.
```
