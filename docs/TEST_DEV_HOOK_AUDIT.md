# Test And Dev Hook Audit

Date: 2026-05-07

Continuation refresh: 2026-05-08. Re-ran source and production-bundle hook scans after the v0.4 accessibility/readability polish and bundle-analysis refresh. This refresh updates emitted asset names, sizes, and explicit hook string counts only; no gameplay, balance, save format, e2e semantics, or runtime behavior changed.

## Scope

This audit checks whether the current v0.4 technical baseline accidentally ships test-only or dev-only surfaces in the production browser bundle. It is documentation-only: no gameplay, balance, save format, e2e semantics, or runtime behavior changed.

Inputs reviewed:

- `LLM_GAME_HANDOFF.md`
- `docs/BUNDLE_ANALYSIS_REPORT.md`
- `docs/PERFORMANCE_BUNDLE_AUDIT.md`
- `src/main.ts`
- `src/game/config.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/scenes/AssetGalleryScene.ts`
- `src/game/scenes/MainMenuScene.ts`
- `src/game/scenes/SettingsScene.ts`
- `src/game/systems/InputSystem.ts`
- `src/game/playtest/*`
- `tests/e2e/*`
- `tools/runPlaytestSim.ts`
- `vite.config.ts`
- `package.json`
- current `dist/assets/*.js`

## Bundle Scan

Current production app chunk from the latest bundle analysis:

- App chunk: `dist/assets/index-Bi19pD8P.js`, 436.32 kB, gzip 117.33 kB
- Phaser vendor chunk: `dist/assets/vendor-phaser-B61OQUcB.js`, 1,481.79 kB, gzip 339.86 kB
- CSS: `dist/assets/index-CeqfGaMI.css`, 42.04 kB, gzip 8.74 kB

Targeted production bundle string scan:

| Pattern | App chunk matches | Phaser chunk matches | Read |
| --- | ---: | ---: | --- |
| `__ASCENDANT_TEST_HOOKS__` | 8 | 0 | Intentional BattleScene e2e hook surface is included in production app code. |
| `ascendantRealmsGame` | 1 | 0 | Intentional global Phaser game handle is included in production app code. |
| `data-testid` | 74 | 0 | Stable DOM selectors are included in production markup. |
| `PlaytestRunner` / `ScriptedBattlePlaytest` / `playtest` | 0 | 0 | Deterministic simulator code is not in the production app chunk. |
| `chapter2-helpers` / `deep_e2e` / `e2e_seed` | 0 | 0 | E2E helper and seed literals are not in the production app chunk. |
| `vitest` / `describe(` | 0 | 0 | Unit-test framework code is not in the production app chunk. |
| `waitForTimeout` | 0 | 0 | Arbitrary Playwright timeout helper does not appear in production. |

Explicit hook-name scan of `dist/assets/index-Bi19pD8P.js`:

| Pattern | Matches | Read |
| --- | ---: | --- |
| `forceBattleVictory` | 2 | Present only through the intentional BattleScene hook type/registry. |
| `captureSite` | 36 | Mostly normal gameplay capture-site strings plus the intentional hook; not an e2e helper import. |
| `scoutEnemyHero` | 2 | Present only through the intentional BattleScene hook type/registry. |
| `defeatEnemyHero` | 2 | Present only through the intentional BattleScene hook type/registry. |
| `grantSelectedUnitVeterancyXp` | 2 | Present only through the intentional BattleScene hook type/registry. |

## Classification

| Hook or surface | Files | Production inclusion status | Category | Risk if removed | Test impact | Recommendation |
| --- | --- | --- | --- | --- | --- | --- |
| Battle test hook registry, `globalThis.__ASCENDANT_TEST_HOOKS__` | `src/game/scenes/BattleScene.ts` | Included in the app chunk. Installed during `BattleScene.create()` and partially cleaned up on scene shutdown. | Test-only and intentionally compiled. | High. Removing now would break release-critical deep-flow assertions that need controlled battle completion, veterancy, capture-site, and enemy-hero outcomes. | High. `tests/e2e/deep-flow.spec.ts` and `tests/e2e/chapter2-helpers.ts` use these hooks. | Keep for now. Treat as known intentional production-included test surface. Future safe fix: introduce a dedicated e2e/test build flag or injected test harness before gating this out of normal production builds. |
| `grantSelectedUnitVeterancyXp` hook | `src/game/scenes/BattleScene.ts`, `tests/e2e/deep-flow.spec.ts` | Included through `__ASCENDANT_TEST_HOOKS__`. | Test-only and intentionally compiled. | Medium-high. It can alter unit veterancy when called from console, but it is not exposed in UI. | High for veterancy/retinue e2e coverage. | Keep until the hook registry can be test-build gated. |
| `forceBattleVictory` hook | `src/game/scenes/BattleScene.ts`, `tests/e2e/deep-flow.spec.ts` | Included through `__ASCENDANT_TEST_HOOKS__`. | Test-only and intentionally compiled. | Medium-high. It can end a battle if manually called from console. | High for long-route e2e runtime control. | Keep until a test-build gate exists. Do not remove without replacing release-gate coverage. |
| `captureSite` hook | `src/game/scenes/BattleScene.ts`, `tests/e2e/chapter2-helpers.ts` | Included through `__ASCENDANT_TEST_HOOKS__`. | Test-only and intentionally compiled. | Medium. It mutates battle state and campaign-resource assertions depend on it. | High for Chapter 2 reward/persistence coverage. | Keep. Prefer future gating over deletion. |
| `scoutEnemyHero` and `defeatEnemyHero` hooks | `src/game/scenes/BattleScene.ts`, `tests/e2e/deep-flow.spec.ts` | Included through `__ASCENDANT_TEST_HOOKS__`. | Test-only and intentionally compiled. | Medium-high. They can reveal or defeat commander units from console. | High for rival intel, reward, trophy, and duplicate-prevention e2e coverage. | Keep. Future gate only after e2e can run against a test harness build. |
| Global Phaser handle, `window.ascendantRealmsGame` | `src/main.ts`, `tests/e2e/deep-flow.spec.ts`, `tests/e2e/layout.spec.ts`, `tests/e2e/smoke.spec.ts`, `tests/e2e/chapter2-helpers.ts` | Included in production app chunk. | Dev/test inspection surface intentionally compiled. | High. Removing it immediately would break many smoke, layout, and release-gate assertions that inspect active scenes and battle state. | High across all e2e lanes. | Keep for now. If production hardening becomes a release goal, replace direct e2e scene inspection with a gated diagnostics bridge first. |
| DOM `data-testid` selectors | Campaign panels, menu scenes, settings, battle HUD panels, results panels, minimap | Included in production app chunk and DOM markup. | Test-only selectors intentionally compiled into runtime UI. | Medium. They do not mutate state, but stripping them would break most e2e locators. | Very high across smoke, layout, deep, and release lanes. | Keep. They are low-risk and size-light. Consider stripping only for a separate hardened distribution, not this prototype release lane. |
| Fog debug hotkey and status copy | `src/game/scenes/BattleScene.ts`, `src/game/systems/InputSystem.ts`, `src/game/scenes/SettingsScene.ts` | Included in production app chunk and visible in Settings keyboard reference. | Runtime player-facing debug/QA control. | Medium. Removing it changes UI behavior and would reduce manual QA leverage around fog readability. | Medium. Smoke and deep-flow tests assert fog behavior and the HUD status can include fog debug copy. | Keep. It is player-facing prototype tooling, not accidental leakage. Rename or hide only as an intentional UX decision later. |
| Fog of War override setting | `src/game/core/Settings.ts`, `src/game/save/SaveTypes.ts`, `src/game/scenes/SettingsScene.ts`, `src/game/scenes/BattleScene.ts` | Included in production app chunk and saved settings. | Runtime player-facing accessibility/control setting. | High. Removing changes save/settings behavior and gameplay visibility options. | High. Smoke tests verify settings persistence and battle fog state. | Keep. This is not a test hook. |
| Manual Asset Gallery screen | `src/game/config.ts`, `src/game/scenes/AssetGalleryScene.ts`, `src/game/scenes/MainMenuScene.ts` | Included in production app chunk and reachable from the main menu. | Runtime player-facing prototype asset QA screen. | Low-medium. It is not gameplay, but removing it changes UI behavior and asset QA workflow. | Medium. Smoke can navigate main menu actions, and future preview checks may rely on the gallery. | Keep for now. It remains a meaningful isolated lazy-load candidate, but that should be a separate measured optimization pass. |
| Deterministic playtest simulator | `src/game/playtest/*`, `tools/runPlaytestSim.ts`, `package.json` script `playtest:sim` | Not found in the production app chunk. It lives under `src/game/playtest` but has no runtime import from `src/main.ts` or scene config. | Test/telemetry code excluded from runtime bundle by import graph. | Low if left alone. High if deleted because balance telemetry and release checks depend on it. | High for `npm run playtest:sim`; none for browser runtime. | No fix needed. Keep as Node-side verification code. |
| E2E seed helpers and fast-forward helpers | `tests/e2e/chapter2-helpers.ts`, `tests/e2e/shared-helpers.ts`, e2e specs | Not found in the production app chunk. | Test-only and outside runtime build. | High if removed because they preserve coverage while controlling runtime. | High for Chapter 2 and release-gate Playwright coverage. | No fix needed. Keep visible assertions in specs and helper names/comments clear. |
| Playwright/Vitest test files | `tests/e2e/*`, `src/**/*.test.ts` | Not found in the production app chunk. `vite.config.ts` excludes `tests/e2e/**` from Vitest, and app bundling does not import tests. | Test-only and excluded from runtime. | High if removed; no runtime benefit. | High for automated verification. | No fix needed. |
| Bundle analyzer tooling | `vite.config.ts`, `package.json`, `.gitignore`, `bundle-analysis/*` | Not included in app runtime. Visualizer only runs for `vite build --mode analyze`; output is ignored by git. | Dev-only build measurement. | Low if left alone. Removing would reduce bundle inspection tooling. | None for gameplay/e2e runtime. | Keep. This is measurement infrastructure, not player-facing code. |
| Save-system console warnings | `src/game/save/SaveSystem.ts`, `src/game/scenes/BattleScene.ts` fallback warning | Included in production app chunk. | Runtime diagnostics for failure cases. | Medium. Removing would make save/debug failure diagnosis harder. | Low direct test impact. | Keep. These are defensive runtime warnings, not test leakage. |
| Pathfinding internals | `src/game/systems/PathfindingGrid.ts`, `src/game/systems/MovementSystem.ts`, tests | Production pathfinding code is included because it is gameplay. Pathfinding tests are not included. No debug panel or pathfinding UI surface was found. | Runtime gameplay system, with tests excluded. | High if removed because unit movement depends on it. | High for gameplay and tests. | No hook fix needed. |

## Accidental Production Leakage

No clearly accidental large test/dev-only inclusion was found in the production bundle.

The notable production-included surfaces are intentional:

- `__ASCENDANT_TEST_HOOKS__` is a real production-bundle test harness surface.
- `window.ascendantRealmsGame` is a production-bundle inspection handle.
- `data-testid` attributes are shipped in runtime markup.
- Fog debug is a visible prototype QA/player control.
- Asset Gallery is a visible prototype asset QA screen.

These are not accidental imports of Playwright, Vitest, e2e helpers, or simulator code. The current risk is product-hardening risk rather than bundle-size risk: a user with console access can call BattleScene test hooks while a battle is active.

## Minimal Fix If Hardening Is Requested Later

Do not remove the hooks directly in this pass. The safest later fix is:

1. Add an explicit e2e/test harness build mode, for example `VITE_ENABLE_TEST_HOOKS=true` or a Vite mode used only by Playwright.
2. Gate `installTestHooks()` and `window.ascendantRealmsGame` diagnostics behind that mode.
3. Update Playwright webServer/scripts to use the test-harness mode.
4. Keep release preview/build smoke on the normal production build to verify hooks are absent.
5. Run the full suite: `npm test`, `npm run build`, `npm run test:e2e:smoke`, `npm run test:e2e:release`, `npm run playtest:sim`, and production preview smoke.

This should be treated as a dedicated technical-hardening task because it touches every e2e lane and the app startup contract.

## Recommendation

For the current v0.4 technical baseline, do not change runtime behavior yet. Document the intentional production-included test surfaces and keep the suite stable.

Recommended next single optimization, if chosen after this audit: create a dedicated test-harness build mode that gates `__ASCENDANT_TEST_HOOKS__` first. That is safer than deleting hooks because it preserves Playwright coverage while allowing the normal production build to become cleaner.

## Continuation Verification

2026-05-08 refresh verification:

```text
npm test
PASS: 38 test files, 270 tests, 6.94s.

npm run build
PASS: TypeScript compile and Vite production build.
Known Vite warning remains for vendor-phaser.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.3m.
```
