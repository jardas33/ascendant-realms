# v0.8 Performance Audit

Date: 2026-05-10

Scope: refresh the current production build and bundle-analysis facts before deciding whether v0.8 should make any performance change. This phase is measurement-only: no gameplay, balance, save, campaign, scene-loading, chunking, test-hook, asset-loading, warning-policy, map, unit, faction, worker, construction, economy AI, pressure, tutorial reward, or desktop/graphics implementation change was made.

## Commands Run

```text
npm run build
npm run build:analyze
```

Both commands passed. `build:analyze` regenerated the ignored local analyzer artifacts:

```text
bundle-analysis/stats.html
bundle-analysis/stats.json
```

## Current Production Build Output

```text
vite v6.4.2 building for production...
204 modules transformed.
dist/index.html                        0.54 kB | gzip:   0.32 kB
dist/assets/index-v9ZLtiOK.css         44.23 kB | gzip:   9.11 kB
dist/assets/index-CC1M6Mg7.js          476.83 kB | gzip: 127.77 kB
dist/assets/vendor-phaser-B61OQUcB.js 1,481.79 kB | gzip: 339.86 kB
built in 11.60s
```

Exact warning:

```text
(!) Some chunks are larger than 500 kB after minification. Consider:
- Using dynamic import() to code-split the application
- Use build.rollupOptions.output.manualChunks to improve chunking: https://rollupjs.org/configuration-options/#output-manualchunks
- Adjust chunk size limit for this warning via build.chunkSizeWarningLimit.
```

Raw output sizes from `dist/assets`:

| Output | Bytes | Gzip bytes | Vite size |
| --- | ---: | ---: | --- |
| `index-CC1M6Mg7.js` | 476,830 | 127,766 | 476.83 kB / gzip 127.77 kB |
| `vendor-phaser-B61OQUcB.js` | 1,481,792 | 339,855 | 1,481.79 kB / gzip 339.86 kB |
| `index-v9ZLtiOK.css` | 44,229 | 9,113 | 44.23 kB / gzip 9.11 kB |

## Comparison Against Previous Bundle Audit

The 2026-05-08 bundle-analysis refresh recorded:

| Output | 2026-05-08 | v0.8 refresh | Delta |
| --- | ---: | ---: | ---: |
| App JS | 436.32 kB / gzip 117.33 kB | 476.83 kB / gzip 127.77 kB | +40.51 kB / +10.44 kB gzip |
| Phaser vendor JS | 1,481.79 kB / gzip 339.86 kB | 1,481.79 kB / gzip 339.86 kB | unchanged |
| CSS | 42.04 kB / gzip 8.74 kB | 44.23 kB / gzip 9.11 kB | +2.19 kB / +0.37 kB gzip |

The app chunk grew through v0.5-v0.7.3 systems, including save/content validation, tutorial onboarding, retinue/veterancy/rival work, and enemy pressure. It remains below Vite's default 500 kB warning threshold. The current warning is still the accepted Phaser vendor warning.

## Analyzer Highlights

Largest app modules by rendered bytes:

| Rank | Module | Rendered bytes | Gzip bytes |
| ---: | --- | ---: | ---: |
| 1 | `src/game/scenes/BattleScene.ts` | 44,173 | 9,814 |
| 2 | `src/game/data/validation/validateCampaign.ts` | 19,430 | 3,727 |
| 3 | `src/game/save/SaveNormalization.ts` | 12,935 | 2,961 |
| 4 | `src/game/core/RivalRules.ts` | 12,617 | 3,246 |
| 5 | `src/game/core/FirstExperienceGuidance.ts` | 12,239 | 3,612 |
| 6 | `src/game/battle/BattleSceneSystems.ts` | 11,390 | 2,899 |
| 7 | `src/game/data/strongholdUpgrades.ts` | 11,201 | 2,792 |
| 8 | `src/game/data/borderMarchesNodes.ts` | 10,864 | 2,883 |
| 9 | `src/game/scenes/CampaignMapScene.ts` | 10,680 | 2,775 |
| 10 | `src/game/data/aiPersonalities.ts` | 10,579 | 2,047 |

Largest app groups by rendered bytes:

| Group | Rendered bytes | Gzip bytes | Modules |
| --- | ---: | ---: | ---: |
| `src/game/data/` | 244,281 | 63,543 | 52 |
| `src/game/scenes/` | 105,916 | 28,458 | 10 |
| `src/game/core/` | 76,809 | 23,297 | 23 |
| `src/game/systems/` | 76,344 | 21,727 | 23 |
| `src/game/battle/` | 60,800 | 16,519 | 12 |
| `src/game/ui/` | 33,950 | 11,073 | 19 |
| `src/game/campaign/` | 31,302 | 10,801 | 16 |
| `src/game/results/` | 29,033 | 9,368 | 8 |

Pressure/tutorial-related modules visible in the app chunk:

| Module | Rendered bytes | Gzip bytes |
| --- | ---: | ---: |
| `src/game/data/validation/validateEnemyPressurePlans.ts` | 9,430 | 2,185 |
| `src/game/data/tutorials.ts` | 6,664 | 1,789 |
| `src/game/tutorial/TutorialStepModel.ts` | 5,151 | 1,346 |
| `src/game/battle/EnemyPressureRuntime.ts` | 5,042 | 1,313 |
| `src/game/data/validation/validateTutorials.ts` | 4,956 | 1,173 |
| `src/game/data/enemyPressurePlans.ts` | 3,888 | 1,086 |
| `src/game/ui/hudPanels/TutorialPanel.ts` | 1,391 | 489 |

Read: pressure and tutorial systems contribute real app-code size, especially validation/runtime/data. They do not currently justify risky lazy loading or production validation removal because the app chunk is still under threshold and the release gates depend on the current eager, validation-safe boot path.

## Test And Dev Code Scan

String scan of `dist/assets/index-CC1M6Mg7.js`:

| Pattern | Matches | Interpretation |
| --- | ---: | --- |
| `playwright` | 0 | Playwright e2e code is not bundled. |
| `vitest` | 0 | Vitest code is not bundled. |
| `describe(` | 0 | Unit test bodies are not bundled. |
| `chapter2-helpers` | 0 | E2E helper modules are not bundled. |
| `ScriptedBattlePlaytest` | 0 | Simulator test entry is not bundled. |
| `PlaytestRunner` | 0 | Simulator runner is not bundled. |
| `__ASCENDANT_TEST_HOOKS__` | 8 | Intentional runtime e2e hooks; not a major size source. |
| `data-testid` | 86 | Expected runtime DOM selectors. Count increased with additional UI/e2e surfaces. |

No obvious test/dev-only code leak was found.

## Current Warning Status

The Phaser vendor warning remains non-blocking for the browser prototype:

- The app chunk is below 500 kB.
- The vendor chunk is stable and isolated.
- The warning is not caused by current pressure/tutorial source growth.
- Raising `chunkSizeWarningLimit` would reduce noise but would not improve player load behavior.
- Lazy scene/data loading or production validation removal would be broader and riskier than the current v0.8 foundation pass.

## Likely Optimization Candidates

| Candidate | Value | Risk | v0.8 read |
| --- | --- | --- | --- |
| Keep measuring only | Preserves green baseline and documents growth | Low | Recommended for this phase. |
| Add more e2e lane scripts/documentation | Reduces CI/developer pain without runtime risk | Low | Better v0.8 target than bundle changes. |
| Move content validation toward build/test-only path later | Could reduce app data/validation cost | Medium | Plan separately; production currently benefits from friendly content failure. |
| Lazy-load Asset Gallery | Tiny app reduction | Medium | Not worth Phaser scene lifecycle churn. |
| Lazy-load BattleScene or campaign/data | Meaningful possible reduction | High | Too broad for v0.8; touches scene transitions, saves, validation, e2e hooks, and simulator assumptions. |
| Remove or gate test hooks | Small production-surface cleanup | Medium | Not justified by size; would require a test-build strategy. |
| Raise chunk warning limit | Removes warning noise | Low technical value | Avoid unless doing warning-policy cleanup only. |

## Recommendation

Do not implement a bundle optimization in v0.8. The current app chunk growth is visible but acceptable, the remaining warning is still isolated to Phaser, and the risky candidates would touch boot validation, data loading, or Phaser scene lifecycle. Focus v0.8 technical implementation on e2e runtime ergonomics and documentation while using the visual foundation docs to prepare future graphics work.

## Phase Verification

```text
npm test: PASS, 45 files / 334 tests.
npm run build: PASS with known Phaser vendor warning.
npm run build:analyze: PASS, analyzer artifacts regenerated.
npm run validate:content: PASS.
git diff --check: PASS.
```
