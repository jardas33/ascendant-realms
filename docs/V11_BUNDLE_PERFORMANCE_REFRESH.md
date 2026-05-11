# v0.11 Bundle And Performance Refresh

Date: 2026-05-11

Scope: refresh production build, analyzer, and production-leak facts after v0.10 Tutorial v2 and early v0.11 reliability tooling. This phase is measurement and documentation only. It does not change gameplay, content, save format, campaign progression, tutorial behavior, runtime assets, chunking, lazy loading, or warning policy.

## Commands Run

```text
npm run build
npm run build:analyze
```

Both commands passed. `build:analyze` regenerated ignored local analyzer artifacts:

```text
bundle-analysis/stats.html
bundle-analysis/stats.json
```

## Current Production Build Output

```text
vite v6.4.2 building for production...
204 modules transformed.
dist/index.html                        0.54 kB | gzip:   0.32 kB
dist/assets/index-BiGdwuWI.css         44.51 kB | gzip:   9.16 kB
dist/assets/index-DY-3qp2P.js          477.04 kB | gzip: 127.86 kB
dist/assets/vendor-phaser-B61OQUcB.js 1,481.79 kB | gzip: 339.86 kB
```

Exact warning remains:

```text
(!) Some chunks are larger than 500 kB after minification. Consider:
- Using dynamic import() to code-split the application
- Use build.rollupOptions.output.manualChunks to improve chunking: https://rollupjs.org/configuration-options/#output-manualchunks
- Adjust chunk size limit for this warning via build.chunkSizeWarningLimit.
```

Raw output sizes:

| Output | Bytes | Gzip bytes | Vite size |
| --- | ---: | ---: | --- |
| `index-DY-3qp2P.js` | 477,038 | 127,859 | 477.04 kB / gzip 127.86 kB |
| `vendor-phaser-B61OQUcB.js` | 1,481,792 | 339,855 | 1,481.79 kB / gzip 339.86 kB |
| `index-BiGdwuWI.css` | 44,509 | 9,161 | 44.51 kB / gzip 9.16 kB |

## Comparison

| Checkpoint | App JS | Phaser vendor JS | CSS | Read |
| --- | ---: | ---: | ---: | --- |
| v0.8 / v0.9.1 baseline | 476.83 kB / gzip 127.77 kB | 1,481.79 kB / gzip 339.86 kB | 44.23 kB / gzip 9.11 kB | Post-v0.8 systems and v0.9 docs/intake baseline. |
| v0.10 final | 477.04 kB / gzip 127.86 kB | 1,481.79 kB / gzip 339.86 kB | 44.51 kB / gzip 9.16 kB | Tutorial v2 copy/layout docs and small UI refinement. |
| v0.11 refresh | 477.04 kB / gzip 127.86 kB | 1,481.79 kB / gzip 339.86 kB | 44.51 kB / gzip 9.16 kB | Unchanged from v0.10 after early v0.11 docs/tooling. |

Read:

- The app chunk did not grow from v0.10.
- CSS did not grow from v0.10.
- The Phaser vendor chunk is unchanged.
- The known Vite warning remains isolated to `vendor-phaser`.
- The app chunk remains below Vite's default 500 kB warning threshold.

## Analyzer Highlights

Largest app modules by rendered bytes:

| Rank | Module | Rendered bytes | Gzip bytes |
| ---: | --- | ---: | ---: |
| 1 | `src/game/scenes/BattleScene.ts` | 44,168 | 9,815 |
| 2 | `src/game/data/validation/validateCampaign.ts` | 19,430 | 3,727 |
| 3 | `src/game/save/SaveNormalization.ts` | 12,935 | 2,961 |
| 4 | `src/game/core/RivalRules.ts` | 12,617 | 3,246 |
| 5 | `src/game/core/FirstExperienceGuidance.ts` | 12,239 | 3,612 |
| 6 | `src/game/battle/BattleSceneSystems.ts` | 11,390 | 2,899 |
| 7 | `src/game/data/strongholdUpgrades.ts` | 11,201 | 2,792 |
| 8 | `src/game/data/borderMarchesNodes.ts` | 10,864 | 2,883 |
| 9 | `src/game/scenes/CampaignMapScene.ts` | 10,680 | 2,775 |
| 10 | `src/game/data/aiPersonalities.ts` | 10,579 | 2,047 |
| 11 | `src/game/scenes/HeroProgressionScene.ts` | 10,417 | 2,966 |
| 12 | `src/game/systems/PathfindingGrid.ts` | 9,953 | 2,771 |
| 13 | `src/game/battle/BattleRuntime.ts` | 9,699 | 2,318 |
| 14 | `src/game/ai/EnemyAIController.ts` | 9,526 | 2,446 |
| 15 | `src/game/data/validation/validateEnemyPressurePlans.ts` | 9,430 | 2,185 |

Largest app groups:

| Group | Rendered bytes | Gzip bytes | Modules |
| --- | ---: | ---: | ---: |
| `src/game/data/` | 244,417 | 63,606 | 52 |
| `src/game/scenes/` | 105,952 | 28,478 | 10 |
| `src/game/core/` | 76,809 | 23,297 | 23 |
| `src/game/systems/` | 76,344 | 21,727 | 23 |
| `src/game/battle/` | 60,800 | 16,519 | 12 |
| `src/game/ui/` | 33,986 | 11,086 | 19 |
| `src/game/campaign/` | 31,302 | 10,801 | 16 |
| `src/game/results/` | 29,033 | 9,368 | 8 |
| `src/game/entities/` | 24,598 | 7,636 | 6 |
| `src/game/save/` | 19,811 | 5,186 | 5 |

The analyzer profile is consistent with the existing architecture: data, scenes, core rules, systems, and battle modules dominate app code. No new v0.11 helper appears as a production-size contributor.

## Production Test/Dev Code Scan

String scan of `dist/assets/index-DY-3qp2P.js`:

| Pattern | Matches | Interpretation |
| --- | ---: | --- |
| `playwright` | 0 | Playwright code is not bundled. |
| `vitest` | 0 | Vitest code is not bundled. |
| `describe(` | 0 | Unit test bodies are not bundled. |
| `chapter2-helpers` | 0 | E2E helper modules are not bundled. |
| `ScriptedBattlePlaytest` | 0 | Simulator test entry is not bundled. |
| `PlaytestRunner` | 0 | Simulator runner is not bundled. |
| `smokePreview` | 0 | v0.11 preview helper is not bundled. |
| `visual-qa` | 0 | Visual QA harness paths are not bundled. |
| `__ASCENDANT_TEST_HOOKS__` | 8 | Intentional runtime e2e hooks; unchanged in kind and still small. |
| `data-testid` | 86 | Expected runtime DOM selectors. |

No obvious test/dev-only production leak was found.

## Warning Status

The known Vite large-chunk warning remains non-blocking for v0.11:

- The app chunk is below 500 kB.
- The warning is caused by the isolated Phaser vendor chunk.
- The Phaser chunk is unchanged from the earlier vendor split.
- The v0.11 preview helper and visual QA improvements do not ship in production JS.
- Raising `chunkSizeWarningLimit` would reduce warning noise but would not improve player load behavior.

## Recommendation

No bundle optimization should be implemented in v0.11.

Recommended near-term policy:

- Keep documenting the known Phaser vendor warning.
- Keep `vendor-phaser` isolated through the existing `manualChunks` rule.
- Do not lazy-load scenes, data, or runtime validation in this reliability pass.
- Keep using `npm run build:analyze` for measured future decisions.
- Revisit scene/data lazy loading only as a dedicated optimization goal with full release and preview smoke verification.

## Future Optimization Candidates

| Candidate | Potential value | Risk | v0.11 decision |
| --- | --- | --- | --- |
| Keep measuring only | Preserves green baseline and gives trend data | Low | Recommended |
| Raise chunk warning limit | Removes known warning noise | Low technical value | Do not do now |
| Move runtime validation toward build/test-only | Could reduce app code and boot work | Medium | Separate goal only |
| Lazy-load Asset Gallery | Small app chunk reduction | Medium | Not worth lifecycle change now |
| Lazy-load BattleScene or campaign/data | Meaningful possible reduction | High | Too broad for v0.11 |
| Gate/remove test hooks | Small production surface cleanup | Medium | Not justified by size |

## Phase 5 Verification

Required after this documentation phase:

```text
npm test
npm run build
npm run validate:content
npm run validate:art-intake
git diff --check
```
