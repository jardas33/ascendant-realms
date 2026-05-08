# v0.4 Performance Implementation Plan

Date: 2026-05-06

Scope: original measured implementation plan only. The later implementation update records the single approved first optimization and does not change gameplay, change balance, refactor broad systems, alter scene loading, change data loading, remove test hooks, or adjust chunk warning limits.

Continuation update: on 2026-05-08, the overnight pass revalidated the analyzer-backed second optimization decision with refreshed bundle and hook-audit evidence. The selected option remains Option D - no code optimization. The current app chunk is `assets/index-Bi19pD8P.js` at 436.32 kB / gzip 117.33 kB, Phaser remains isolated in `assets/vendor-phaser-B61OQUcB.js` at 1,481.79 kB / gzip 339.86 kB, CSS is `assets/index-CeqfGaMI.css` at 42.04 kB / gzip 8.74 kB, and the known Vite warning remains the accepted Phaser vendor warning.

## Current Bundle State

Current production build output from `docs/PERFORMANCE_BUNDLE_AUDIT.md`:

```text
dist/index.html                 0.45 kB | gzip:   0.29 kB
dist/assets/index-CIXXIuKP.css  41.86 kB | gzip:   8.71 kB
dist/assets/index-BlnznQM_.js   1,918.65 kB | gzip: 457.79 kB
```

Known Vite warning:

```text
(!) Some chunks are larger than 500 kB after minification. Consider:
- Using dynamic import() to code-split the application
- Use build.rollupOptions.output.manualChunks to improve chunking: https://rollupjs.org/configuration-options/#output-manualchunks
- Adjust chunk size limit for this warning via build.chunkSizeWarningLimit.
```

Before implementation, `vite.config.ts` had no `build.rollupOptions.output.manualChunks`, no lazy-loading configuration, and no `chunkSizeWarningLimit` override. The application built as one main runtime JS chunk.

The warning is caused primarily by:

- Phaser being imported directly by `src/main.ts` and included in the main chunk.
- `src/game/config.ts` statically registering every scene, including `AssetGalleryScene`, `BattleScene`, `CampaignMapScene`, `ResultsScene`, `HeroProgressionScene`, and setup/menu scenes.
- Eager content/data imports through `contentIndex.ts` and runtime content validation in `BootScene`.

Production bundle scan from the audit found no large test/dev suite accidentally bundled:

| Pattern | Matches | Read |
| --- | ---: | --- |
| `playwright` | 0 | Playwright e2e code is not bundled. |
| `vitest` | 0 | Vitest code is not bundled. |
| `describe(` | 0 | Unit test bodies are not bundled. |
| `chapter2-helpers` | 0 | E2E helper modules are not bundled. |
| `ScriptedBattlePlaytest` | 0 | Simulator test entry is not bundled. |
| `PlaytestRunner` | 0 | Simulator runner is not bundled. |
| `__ASCENDANT_TEST_HOOKS__` | 8 | Intentional small runtime e2e hooks in `BattleScene`, not a major size source. |

Original status: the warning was accepted for the prototype, but v0.4 could investigate safe optimization with the new e2e lane split available.

## Implementation Update - Phaser Vendor Chunk Split

Date: 2026-05-06

Implemented optimization: vendor chunk split for Phaser.

Files changed for the optimization:

- `vite.config.ts`

What changed:

- Added a Vite/Rollup `manualChunks` rule for `node_modules/phaser`.
- Emitted Phaser as `vendor-phaser`.
- Left all scenes, data, content validation, assets, test hooks, gameplay rules, balance, save format, and e2e semantics unchanged.
- Left `chunkSizeWarningLimit` unchanged.

Before/after build numbers:

| Metric | Before split | After split |
| --- | ---: | ---: |
| JS chunks | 1 | 2 |
| CSS chunks | 1 | 1 |
| JS/CSS emitted chunks | 2 | 3 |
| Main/app JS | `assets/index-BlnznQM_.js` 1,918.65 kB / gzip 457.79 kB | `assets/index-TotuX8zG.js` 435.50 kB / gzip 116.99 kB |
| Phaser vendor JS | Included in main JS | `assets/vendor-phaser-B61OQUcB.js` 1,481.79 kB / gzip 339.86 kB |
| Total JS | 1,918.65 kB / gzip 457.79 kB | 1,917.29 kB / gzip 456.85 kB |
| CSS | `assets/index-CIXXIuKP.css` 41.86 kB / gzip 8.71 kB | `assets/index-CIXXIuKP.css` 41.86 kB / gzip 8.71 kB |
| Vite warning | Present | Present |

Warning result: the Vite large-chunk warning remains because the Phaser vendor chunk is still above 500 kB after minification. The app chunk is now below the threshold. This is a successful first pass because it creates a stable app/vendor boundary and clearer future measurements without touching gameplay.

## Candidate Optimizations

### 1. Vendor Chunk Split For Phaser

Expected benefit:

- Separates Phaser from app code, making the app chunk easier to inspect.
- Improves browser cache behavior if app code changes more often than Phaser.
- Helps future measurement by making Phaser cost explicit.
- Low behavioral risk because it changes bundling output, not runtime game logic.

Implementation risk: Low-medium.

Likely files touched:

- `vite.config.ts`
- `docs/PERFORMANCE_BUNDLE_AUDIT.md`
- `LLM_GAME_HANDOFF.md`

Test impact:

- `npm run build` must confirm new chunk names, gzip sizes, and warning state.
- `npm test` should still pass because config import shape must not affect TS/Vitest.
- `npm run test:e2e:smoke` should verify boot, campaign launch, Cinderfen smoke, skirmish, and inventory still work through dev server.
- `npm run test:e2e:release` should run before checkpoint/freeze because production chunking can surface transition assumptions only under broader coverage.
- Production preview smoke is required because Vite production output changes.

Rollback plan:

- Revert the `vite.config.ts` `manualChunks` change.
- Rebuild and confirm output returns to one main JS chunk.
- Keep any measurement notes in docs if useful, clearly marking the split as reverted.

Notes:

- This may not remove Vite's warning. Phaser's vendor chunk may still exceed 500 kB after minification. That is acceptable if the implementation goal is safer cache shape and clearer measurement, not warning suppression.
- Implemented on 2026-05-06 as the only optimization in the first pass.

### 2. Lazy Loading Non-Initial Scenes

Expected benefit:

- Reduces the initial app chunk by deferring scenes not needed for first boot.
- Larger payoff if `BattleScene`, `ResultsScene`, `HeroProgressionScene`, or `CampaignMapScene` can be deferred safely.

Implementation risk: Medium-high.

Likely files touched:

- `src/game/config.ts`
- `src/game/scenes/BootScene.ts`
- Scene-transition callers in `MainMenuScene`, `CampaignMapScene`, `SkirmishSetupScene`, `BattleScene`, and `ResultsScene`
- `src/game/core/SceneKeys.ts`
- `tests/e2e/smoke.spec.ts`
- `tests/e2e/deep-flow.spec.ts`
- `docs/PERFORMANCE_BUNDLE_AUDIT.md`

Test impact:

- Full release-gate e2e is required because every scene transition is potentially affected.
- Production preview smoke is required because dynamic imports can behave differently under production asset paths.
- If a scene loader abstraction is introduced, add focused unit tests only if the abstraction has pure logic; otherwise rely on Playwright.

Rollback plan:

- Revert scene dynamic imports and restore the static `scene` array in `gameConfig`.
- Rebuild and run smoke to confirm boot returns to the previous eager path.

Notes:

- This should not be the first implementation. It is likely useful later, but it touches the Phaser lifecycle and many navigation paths.

### 3. Lazy Loading Asset Gallery

Expected benefit:

- Defers a non-core scene that is not required for the primary campaign/skirmish loop.
- Smaller and safer than lazy-loading BattleScene or CampaignMapScene.
- Good pilot for a future scene-loader pattern if the vendor split succeeds and a second optimization is needed.

Implementation risk: Medium.

Likely files touched:

- `src/game/config.ts`
- `src/game/scenes/MainMenuScene.ts`
- `src/game/core/SceneKeys.ts`
- `src/game/scenes/AssetGalleryScene.ts`
- `tests/e2e/smoke.spec.ts`
- `tests/e2e/deep-flow.spec.ts`

Test impact:

- Smoke or deep-flow coverage must still open Asset Gallery at least once.
- Production preview smoke should include Asset Gallery if this is implemented.
- Full release-gate e2e is recommended because Main Menu navigation changes.

Rollback plan:

- Put `AssetGalleryScene` back into the static `gameConfig.scene` array.
- Revert any main-menu async loader code.

Notes:

- Asset Gallery is isolated from gameplay, but it still participates in main-menu navigation and asset manifest rendering. This is safer than battle/campaign lazy loading, but not safer than a Phaser vendor chunk split.

### 4. Lazy Loading Campaign Data Or Map Data

Expected benefit:

- Could defer campaign/map/reward data that is not needed at first paint.
- Might become valuable as content grows.

Implementation risk: Medium-high.

Likely files touched:

- `src/game/data/contentIndex.ts`
- `src/game/data/campaignNodes.ts`
- `src/game/data/campaignRewards.ts`
- `src/game/data/maps.ts`
- `src/game/data/validation/*`
- `src/game/core/campaign/*`
- `src/game/save/SaveNormalization.ts`
- `src/game/scenes/CampaignMapScene.ts`
- `src/game/scenes/ResultsScene.ts`
- `src/game/battle/BattleLaunchRequest.ts`
- Unit/content validation tests
- E2E smoke and deep-flow specs

Test impact:

- Requires broad unit coverage for data lookups, validation, save normalization, campaign unlocks, launch requests, Results rewards, and duplicate prevention.
- Requires full e2e release gate and playtest simulator.
- Requires production preview smoke.

Rollback plan:

- Restore eager `contentIndex.ts` exports and static lookup tables.
- Revert async data-loading call sites.
- Re-run content validation and campaign launch tests.

Notes:

- Not first. The current data index is central to rules, validation, saves, campaign, battle launch, and Results. Split only after bundle analyzer data proves it is worth the risk.

### 5. Remove Accidental Test/Dev Hooks From Production Bundle

Expected benefit:

- If accidental test-only code existed, this could reduce bundle size and production surface.
- It could clean up release posture if hooks are made explicitly test-build-only.

Implementation risk: Low-medium.

Likely files touched:

- `src/game/scenes/BattleScene.ts`
- E2E specs using `__ASCENDANT_TEST_HOOKS__`
- Possibly `vite.config.ts` or an environment flag helper
- `docs/PERFORMANCE_BUNDLE_AUDIT.md`

Test impact:

- Any removal or gating must run the full e2e release gate because Playwright depends on the hooks for safe fast-forward and state setup.
- Production preview smoke is required if production-only gating is introduced.

Rollback plan:

- Restore the hook registration in `BattleScene`.
- Re-run the smoke and release e2e lanes.

Notes:

- The audit did not find accidental test/dev suite code in production. `__ASCENDANT_TEST_HOOKS__` is intentional and small. Do not strip it as the first optimization unless a replacement test-build strategy is designed.

### 6. Adjust `chunkSizeWarningLimit`

Expected benefit:

- Removes warning noise if the team explicitly accepts a larger Phaser vendor chunk.

Implementation risk: Low technical risk, low product value.

Likely files touched:

- `vite.config.ts`
- `docs/PERFORMANCE_BUNDLE_AUDIT.md`

Test impact:

- `npm run build` confirms warning behavior.
- No gameplay/e2e impact expected.

Rollback plan:

- Remove the `chunkSizeWarningLimit` override.

Notes:

- This is documentation/noise management, not optimization. Do not use it as the first performance implementation. It may be acceptable only after a measured vendor split defines an intentional warning threshold.

## Risk Ranking

| Rank | Candidate | Expected benefit | Implementation risk | Test impact | Rollback confidence |
| ---: | --- | --- | --- | --- | --- |
| 1 | Vendor chunk split for Phaser | Better cache shape and clearer measurement | Low-medium | Build, unit, smoke, release, preview | High |
| 2 | Remove accidental test/dev code if found | Small bundle cleanup and cleaner production surface | Low-medium | Full e2e if hooks are touched | Medium |
| 3 | Lazy load Asset Gallery | Defers a non-core scene | Medium | Smoke, release, preview with gallery path | Medium |
| 4 | Lazy load other non-initial scenes | Smaller initial app chunk | Medium-high | Full release gate and preview | Medium |
| 5 | Lazy load campaign/map data | Potential future content-scale benefit | Medium-high | Broad unit, e2e, sim, preview | Low-medium |
| 6 | Adjust `chunkSizeWarningLimit` | Warning noise reduction only | Low | Build only | High |

## Recommended First Optimization

Recommended first implementation: vendor chunk split for Phaser.

Status: implemented on 2026-05-06 as the only optimization in this pass.

Why this one:

- It is the safest real optimization candidate.
- It touches `vite.config.ts` instead of gameplay, scene lifecycle, save rules, campaign data, or UI behavior.
- It creates a clearer vendor/app boundary for future measurement.
- It has an easy rollback.
- It does not depend on stripping intentional e2e hooks or changing the Asset Gallery route.

Implemented shape:

1. Added a Rollup `manualChunks` rule in `vite.config.ts` that places `node_modules/phaser` in `vendor-phaser`.
2. Did not change `chunkSizeWarningLimit`.
3. Ran `npm run build` and recorded exact emitted asset names, minified sizes, gzip sizes, and warning state.
4. Kept lazy scene loading, data chunking, Asset Gallery loading, and test-hook changes out of scope.
5. Updated `docs/PERFORMANCE_BUNDLE_AUDIT.md` with the measured result.

Not included in the first implementation:

- No lazy scene loading.
- No data chunk splitting.
- No Asset Gallery route change.
- No removal of `__ASCENDANT_TEST_HOOKS__`.
- No warning-limit increase.

## Verification Plan

For the first optimization implementation, run:

```bash
npm test
npm run build
npm run test:e2e:smoke
npm run test:e2e:release
npm run playtest:sim
```

If `test:e2e:release` is unavailable in a future branch, use:

```bash
npm run test:e2e
```

Production preview smoke:

```bash
npm run preview -- --host 127.0.0.1 --port 4188
```

Preview smoke checklist:

- Main menu loads.
- `Prototype v0.3` and `Cinderfen Route Baseline` copy is visible.
- New Campaign does not crash.
- Continue Campaign does not crash when a save exists.
- Skirmish Setup opens.
- Campaign Map opens.
- Asset Gallery opens if Asset Gallery loading is touched.
- Browser console errors stay at zero.

For a vendor split specifically, the verification report should include:

- JS output chunk names.
- Phaser/vendor chunk minified and gzip size.
- App chunk minified and gzip size.
- CSS output name and gzip size.
- Exact Vite warning text, or confirmation that it disappeared.
- A short comparison with the previous `assets/index-BlnznQM_.js` 1,918.65 kB / 457.79 kB gzip baseline.

Current verification status: complete for the first optimization.

```text
npm test
PASS: 38 test files, 270 tests, 10.91s.

npm run build
PASS: TypeScript compile and Vite production build.
App JS: assets/index-TotuX8zG.js, 435.50 kB / gzip 116.99 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.
CSS: assets/index-CIXXIuKP.css, 41.86 kB / gzip 8.71 kB.
Vite warning remains because vendor-phaser is over 500 kB.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.6m.

npm run test:e2e:release
PASS: 59 Playwright tests in 29.1m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.

Production preview smoke
PASS: http://127.0.0.1:4189/ loaded the built app, showed Prototype v0.3 / Cinderfen Route Baseline, opened New Campaign, reached Campaign Map, continued the campaign, opened Skirmish Setup, and logged 0 browser console errors.
```

## Decision Gate

Proceed to implementation only if the task explicitly asks for it. The safe first prompt should be:

```text
Read docs/V04_PERFORMANCE_IMPLEMENTATION_PLAN.md and docs/PERFORMANCE_BUNDLE_AUDIT.md. Implement only the Phaser vendor chunk split in Vite config. Do not change gameplay, balance, scene loading, data loading, test hooks, or chunk warning limits. Record exact before/after build output and run npm test, npm run build, npm run test:e2e:smoke, npm run test:e2e:release, npm run playtest:sim, and production preview smoke.
```

Current plan status: first optimization implemented. A later analyzer-backed second-decision pass chose Option D, no code optimization, because the available options were not safe enough or meaningful enough for a second runtime change.

## Second Optimization Decision - 2026-05-07

Chosen option: Option D - no code optimization.

Decision matrix:

| Option | Decision | Reason |
| --- | --- | --- |
| Option A - Lazy-load Asset Gallery | Skip | Analyzer shows `AssetGalleryScene.ts` is only about 4,125 rendered bytes / 1,502 gzip bytes. It is isolated, but the payoff does not justify changing Phaser scene registration now. |
| Option B - Production-gate accidental test/dev code | Skip | The hook audit found no accidental large test/dev bundle leak. Existing hooks/selectors are intentional and e2e-critical. |
| Option C - Split another stable vendor/tool chunk | Skip | Phaser is already isolated. No other large stable runtime dependency exists. |
| Option D - No code optimization | Chosen | Safest outcome. Preserve the current green baseline and plan any broader content-validation, data-splitting, or scene-loading work as a dedicated pass. |

Before/after bundle numbers:

| Metric | Before decision | After decision |
| --- | ---: | ---: |
| JS chunks | 2 | 2 |
| CSS chunks | 1 | 1 |
| App JS | `assets/index-Bi19pD8P.js` 436.32 kB / gzip 117.33 kB | unchanged |
| Phaser vendor JS | `assets/vendor-phaser-B61OQUcB.js` 1,481.79 kB / gzip 339.86 kB | unchanged |
| CSS | `assets/index-CeqfGaMI.css` 42.04 kB / gzip 8.74 kB | unchanged |
| Vite warning | Present for `vendor-phaser` | unchanged |

No implementation was made in this pass. The next optimization should be a separately scoped task, most likely either a test-harness build mode for intentional hooks or a build/test content-validation path. Do not combine those with scene lazy loading or data chunk splitting.

Verification for the no-code decision:

```text
npm test
PASS: 38 test files, 270 tests, 8.76s.

npm run build
PASS: TypeScript compile and Vite production build.
App JS: assets/index-TotuX8zG.js, 435.50 kB / gzip 116.99 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.
CSS: assets/index-CIXXIuKP.css, 41.86 kB / gzip 8.71 kB.
Vite warning remains because vendor-phaser is over 500 kB.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.4m.

npm run test:e2e:release
PASS: 59 Playwright tests in 29.1m.
Slow files: tests/e2e/layout.spec.ts 12.8m and tests/e2e/deep-flow.spec.ts 11.4m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.

Production preview smoke
PASS: npm run preview -- --host 127.0.0.1 --port 4190 --strictPort.
PASS: main menu loaded, Prototype v0.3 / Cinderfen Route Baseline copy visible, New Campaign reached Campaign Map, Continue Campaign reached Campaign Map, Skirmish Setup opened, and browser console errors stayed at 0.
Note: Browser Use reached the local URL and saw 0 console errors, but its DOM/screenshot surface was blank for this app tab; a Playwright fallback completed the production preview smoke.
```

Continuation verification on 2026-05-08:

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
Initial background release attempt was stopped after two early test-level timeouts. Targeted foreground reruns passed for both timed-out tests, then the full foreground release rerun passed: 59 Playwright tests in 27.4m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.

git diff --check
PASS.

Production preview smoke
PASS: Browser in-app preview smoke at http://127.0.0.1:57901/ loaded the built app, saw PROTOTYPE V0.3 / Cinderfen Route Baseline main-menu copy, reached Campaign Map through New Campaign and Continue Campaign, opened Skirmish Setup, and saw 0 browser console errors.
```
