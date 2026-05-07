# v0.4 Direction Decision Brief

Date: 2026-05-06

Scope: planning only. This brief compares possible v0.4 directions after the frozen v0.3 Cinderfen Route Baseline and frozen v0.3.1 polish release. It does not implement v0.4, add gameplay, add maps, add systems, change balance, or change UI behavior.

Current baseline:

- v0.3 remains the frozen Cinderfen content baseline.
- v0.3.1 is polish/readability/performance-audit/test-maintenance only.
- Final verification is green: `npm test` passed with 270 tests, `npm run build` passed with the known Vite warning, `npm run test:e2e -- --reporter=line` passed with 59 Playwright tests in about 28.6m, `npm run playtest:sim` passed with 255 deterministic runs, `git diff --check` passed, and production preview smoke passed.
- Known watch items are the 59-test / about 28.6m Playwright runtime, the Vite large-chunk warning, human readability and mobile density, Cinder Shrine salience, retinue/rival/trophy hierarchy, and the temptation to add content before technical lanes are clean.

## Decision Summary

| Option | Direction | Overall stance |
| --- | --- | --- |
| A | Performance and build-size optimization | Safest technical optimization path after e2e lanes are clearer. |
| B | E2E default/release-gate split | Best first v0.4 direction; reduces daily friction while preserving coverage. |
| C | Human-readability and accessibility polish | Safest UX path after the test lanes are easier to run. |
| D | Small content continuation | Highest content temptation; postpone until technical lanes are clean. |

## Option A - Performance And Build-Size Optimization

Value:

- Addresses the known Vite large-chunk warning documented in `docs/PERFORMANCE_BUNDLE_AUDIT.md`.
- Starts from measured current output: `assets/index-BlnznQM_.js` at 1,918.65 kB minified / 457.79 kB gzip and `assets/index-CIXXIuKP.css` at 41.86 kB / 8.71 kB gzip.
- Can separate evidence gathering from implementation by first adding bundle analysis.
- Potential later wins include Phaser/vendor chunk split, lazy scene loading, data chunk splitting, dev/test hook separation, and production asset-shipping review.
- Keeps the path technical rather than content-facing.

Risk:

- Low if limited to analyzer/reporting and documentation.
- Low-medium for Phaser/vendor chunking: it can improve cache shape and diagnostics, but total JS may not shrink and the warning may remain on a vendor chunk.
- Medium for lazy scene loading: scene registration, scene keys, save/continue paths, Results navigation, and e2e hooks can regress.
- Medium-high for data chunk splitting: `contentIndex.ts`, validation, save normalization, Campaign Map, Results, and launch rules depend on eager data access.
- High if optimization mixes multiple changes before the baseline is measured.

Files likely touched:

- `package.json`
- `vite.config.ts`
- `src/main.ts`
- `src/game/config.ts`
- `src/game/scenes/BootScene.ts`
- `src/game/scenes/*`
- `src/game/data/contentIndex.ts`
- `src/game/data/validation/*`
- `tests/e2e/*`
- `docs/PERFORMANCE_BUNDLE_AUDIT.md`
- `LLM_GAME_HANDOFF.md`

Test impact:

- Always run `npm test` and `npm run build`.
- Keep the exact Vite warning and chunk output recorded after each optimization pass.
- Any real chunking or lazy-load change should also run the full Playwright release gate and production preview smoke because runtime scene transitions are the risk.
- If data splitting changes validation or content loading, add or update focused unit tests before relying on browser coverage.

Why now:

- The warning is known, measured, and non-blocking, so it can be handled calmly.
- Performance work can improve confidence before future content increases bundle size.
- Analyzer-only work is a safe technical step with little gameplay risk.

Why not now:

- The build already passes and the main gzip size is acceptable for a prototype.
- Optimizing scene/data loading before e2e lanes are split makes every regression check expensive.
- Lazy loading and data splitting can touch fragile boot and scene-transition surfaces.

First implementation prompt if chosen:

```text
Read LLM_GAME_HANDOFF.md and docs/PERFORMANCE_BUNDLE_AUDIT.md. Implement a measurement-only bundle analysis pass for the current Vite build. Do not change runtime chunking, gameplay, balance, scenes, data loading, or UI behavior. Record Phaser/vendor/app/data contributions, run npm test and npm run build, and update the performance audit with findings and safe next steps.
```

## Option B - E2E Default/Release-Gate Split

Value:

- Directly addresses the 59-test / about 28.6m Playwright runtime documented in `docs/E2E_RUNTIME_AUDIT.md`.
- Creates a fast default suite for routine local verification without deleting meaningful coverage.
- Keeps the full release-gate suite available for freeze/checkpoint work.
- Makes future technical work safer because developers can run a small reliable browser lane frequently and the full lane when risk warrants it.
- Can use Playwright projects, tags, grep, sharding, or npm scripts while preserving the existing assertions.

Risk:

- Low if this starts as scripts/config plus documentation and does not move assertions.
- Medium if tests are retagged or split carelessly; release-critical flows could silently stop running by default.
- Medium-high if sharding or parallel workers are introduced before localStorage, Phaser boot, and browser-state isolation are proven stable.
- Coverage risk is classification drift: "default" must still prove that the frozen game boots and the current Cinderfen route has core coverage.

Files likely touched:

- `package.json`
- `playwright.config.ts`
- `tests/e2e/smoke.spec.ts`
- `tests/e2e/layout.spec.ts`
- `tests/e2e/deep-flow.spec.ts`
- `tests/e2e/shared-helpers.ts`
- `tests/e2e/chapter2-helpers.ts`
- `docs/E2E_RUNTIME_AUDIT.md`
- `LLM_GAME_HANDOFF.md`
- `RELEASE_CHECKLIST.md`

Test impact:

- Add or define a fast default e2e command that keeps smoke coverage visible.
- Keep the full release-gate command equivalent to the current 59-test suite unless intentionally expanded.
- Use `npx playwright test --list` or equivalent listing to prove which tests belong to each lane.
- Preserve full-flow protection for main menu, hero creation, campaign launch, at least one BattleScene path, Results, Cinderfen route smoke, save persistence, and duplicate-prevention checks.
- Run `npm test`, `npm run build`, the new fast lane, and the full release-gate lane before accepting the split.

Why now:

- It is the best leverage point after v0.3.1: the suite is trusted but slow.
- It helps every later direction, including bundle work, UX polish, and eventual content work.
- It preserves coverage while reducing the cost of frequent verification.
- The e2e audit already identifies slow files, default smoke candidates, release-gate candidates, and tests that should remain full-flow.

Why not now:

- A rushed split can create false confidence if important flows become release-only without a clear default replacement.
- Tags/projects can become confusing if naming and documentation are not crisp.
- Sharding or more workers may introduce flakes before isolation is proven.

First implementation prompt if chosen:

```text
Read LLM_GAME_HANDOFF.md, RELEASE_CHECKLIST.md, and docs/E2E_RUNTIME_AUDIT.md. Implement only a safe Playwright default/release-gate split using npm scripts, Playwright projects or tags, and documentation. Do not remove tests, do not weaken assertions, do not change gameplay, and keep the current full 59-test suite available as the release gate. Prove the listed tests for each lane, then run npm test, npm run build, the fast default e2e lane, and the full release-gate e2e lane.
```

## Option C - Human-Readability And Accessibility Polish

Value:

- Addresses the largest remaining human-facing risks: mobile density, route readability, input clarity, accessibility settings, Cinder Shrine salience, and dense retinue/rival/trophy hierarchy.
- Builds on the v0.3.1 polish release without adding content.
- Improves the frozen route players already have before expanding it.
- Gives better manual-review confidence for Cinderfen Overlook, Waystation, Crossing, Watch, Aftermath, Results, Settings, and campaign-map panels.

Risk:

- Low for copy, hierarchy, focus-state, contrast, tooltip, and settings-label improvements that preserve behavior.
- Medium for layout changes on dense Campaign Map, Battle HUD, Results, and Settings surfaces.
- Medium-high if accessibility settings become new systems instead of narrow presentation preferences.
- Selector risk exists if Playwright-visible labels or test IDs are disturbed.

Files likely touched:

- `src/game/styles/*`
- `src/game/ui/*`
- `src/game/campaign/*`
- `src/game/scenes/MainMenuScene.ts`
- `src/game/scenes/CampaignMapScene.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/scenes/ResultsScene.ts`
- `src/game/scenes/SettingsScene.ts`
- `tests/e2e/layout.spec.ts`
- `tests/e2e/smoke.spec.ts`
- `docs/V031_MOBILE_READABILITY_AUDIT.md`
- `docs/V031_POLISH_RELEASE_REPORT.md`
- `LLM_GAME_HANDOFF.md`

Test impact:

- `npm test` and `npm run build` stay mandatory.
- Targeted Playwright checks should cover changed layout/settings surfaces.
- Full release-gate e2e should run before a freeze or broad UI checkpoint.
- Human browser review remains important because automated checks cannot judge scan quality, stress, audio, or visual salience.

Why now:

- v0.3.1 explicitly says human readability cannot be fully replaced by automation.
- Mobile density and route readability are documented watch items.
- This is the safest user-facing path once the e2e lanes are easier to run.

Why not now:

- The current requested next leverage point is technical lane cleanup.
- Human polish can become open-ended without a clear pass/fail checklist.
- Any layout work is easier to trust after default/release-gate e2e commands are defined.

First implementation prompt if chosen:

```text
Read LLM_GAME_HANDOFF.md, docs/V031_POLISH_RELEASE_REPORT.md, and docs/V031_MOBILE_READABILITY_AUDIT.md. Perform a focused human-readability/accessibility polish pass on the frozen Cinderfen route only. Do not change gameplay, balance, route content, selectors, or save behavior. Keep changes small, document the reviewed surfaces, and run npm test, npm run build, and targeted Playwright checks.
```

## Option D - Small Content Continuation

Value:

- Could provide a tiny Cinderfen epilogue or planning scaffold after the current route ends at Cinderfen Aftermath.
- Keeps content energy pointed at the existing Cinderfen lane rather than a broad new arc.
- If limited to planning, it can define future copy, unlocks, risks, tests, and non-goals without disturbing the frozen baseline.

Risk:

- Highest temptation among the four options because even "tiny" content can expand quickly.
- Low if it is only a planning scaffold.
- Medium for a non-battle epilogue using existing event/reward/reputation rules.
- Medium-high for any battle node because it affects maps, simulator profiles, rewards, e2e runtime, mobile layout, and human balance review.
- Not acceptable if it drifts into workers, enemy construction, a new faction, crafting, procedural generation, diplomacy, or broad systems.

Files likely touched:

- Planning-only: `docs/*`, `ROADMAP.md`, `LLM_GAME_HANDOFF.md`
- If later implemented: `src/game/data/cinderfenRoadNodes.ts`
- If later implemented: `src/game/data/campaignChapters.ts`
- If later implemented: `src/game/data/campaignRewards.ts`
- If later implemented: `src/game/core/campaign/*`
- If later implemented: `tests/e2e/chapter2-helpers.ts`
- If later implemented: `tests/e2e/smoke.spec.ts`
- If later implemented: `PLAYTEST_TELEMETRY.md` and `BALANCE.md`

Test impact:

- Planning-only work needs `npm test` and `npm run build` for documentation hygiene.
- Any later event implementation needs content validation, campaign-rule tests, save persistence checks, and targeted Playwright route assertions.
- Any later battle implementation needs simulator coverage and full release-gate e2e.
- The full 59-test release gate is likely to grow unless the e2e lane split happens first.

Why now:

- The route is frozen, so a tiny epilogue can be described clearly without guessing where the current content ends.
- Planning can box in non-goals before implementation pressure starts.
- It can help decide what "small content" means without adding it.

Why not now:

- The technical lanes are not clean yet: full Playwright still costs about 28.6m and the bundle warning remains accepted but unresolved.
- Human readability still needs review on the frozen route.
- Content work before those checks risks piling new uncertainty on top of known maintenance friction.
- The roadmap and handoff explicitly postpone workers, enemy construction, new factions, new maps, crafting, diplomacy, procedural systems, and broad systems.

First implementation prompt if chosen:

```text
Read LLM_GAME_HANDOFF.md, ROADMAP.md, PLAYTEST_TELEMETRY.md, BALANCE.md, and docs/V031_POLISH_RELEASE_REPORT.md. Create a planning-only scaffold for one tiny Cinderfen epilogue. Do not implement the node yet. Define the player-facing purpose, unlock position, copy outline, non-goals, likely files, tests, and explicit exclusions: no workers, no enemy construction, no new faction, no crafting, no procedural generation, no diplomacy, no new map, and no balance changes.
```

## Recommendation

Recommended order:

1. Option B - E2E default/release-gate split.
2. Option A - measured performance and build-size optimization.
3. Option C - human-readability and accessibility polish.
4. Postpone Option D - small content continuation until after the technical lanes are clean.

The reason is simple: v0.3.1 is already frozen and verified, but the verification loop is expensive. A clear e2e default/release-gate split reduces friction for every future change while preserving the full 59-test release gate. After that, measured bundle work is the safest technical optimization path because it addresses the documented Vite warning without adding content. Human-readability polish should follow with better test-lane support. Content should wait because it is the easiest path to widen scope before the maintenance and performance lanes are ready.
