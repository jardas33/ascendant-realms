# Development Checkpoint

Updated: 2026-05-10 v0.8.2 visual source/license screenshot coverage report gate

## v0.8.2 Visual Source/License And Screenshot Coverage Report Gate - 2026-05-10

Scope: review visual asset source/license risk, refine conservative manifest metadata, harden visual asset validation, expand optional screenshot QA coverage, document a broader visual risk register, and prepare a v0.9 controlled visual sprint brief. This pass preserved gameplay, save compatibility, campaign progression, Tutorial / Proving Grounds behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, large binary assets, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, or broad systems.

Included work:

- Added `docs/V082_ASSET_SOURCE_LICENSE_REVIEW_PLAN.md`, `docs/V082_ASSET_SOURCE_LICENSE_AUDIT.md`, `docs/V082_MANIFEST_METADATA_REFINEMENT.md`, `docs/V082_MANIFEST_VALIDATION_HARDENING.md`, `docs/V082_SCREENSHOT_COVERAGE_EXPANSION_PLAN.md`, `docs/V082_EXTENDED_SCREENSHOT_QA_REVIEW.md`, `docs/VISUAL_RISK_REGISTER.md`, `docs/V09_CONTROLLED_VISUAL_SPRINT_BRIEF.md`, and `docs/V082_SOURCE_LICENSE_SCREENSHOT_COVERAGE_REPORT.md`.
- Added `reviewStatus` and `sourceReviewNotes` visual asset metadata.
- Kept current file-backed image assets conservative: no production-approved visual art, unknown-source runtime art remains review-needed and not allowed in production.
- Hardened validation around runtime/reference conflicts, final/candidate production safety, production-approved metadata, deprecated runtime assets, critical replacement notes, and source-review notes.
- Expanded optional `npm run visual:qa` from 10 to 18 indexed screenshots.
- Added screenshot coverage for Asset Gallery, Hero Inventory, tutorial mobile, route-complete campaign map, Cinderfen Crossing tablet, Crossing pressure warning, victory Results, and defeat Results.
- Added a living visual risk register and a v0.9 brief recommending a docs/specs/prompts-only Cinderfen style-frame sprint before runtime visual replacement.

Latest report-gate verification results:

```text
npm test
PASS: 45 test files, 340 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-CC1M6Mg7.js, 476.83 kB minified / 127.77 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 5.0m during screenshot/report gates.

npm run visual:qa
PASS: 1 Playwright capture test, 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes during the report gate.

git diff --check
PASS: no whitespace errors during phase gates.
```

Recommended next milestone: v0.9 Controlled Cinderfen Style-Frame Sprint. Keep the first step docs/specs/prompts-only: Cinderfen terrain material sheet, Cinder Shrine/capture-site landmark sheet, and Ashen outpost architecture sheet. Do not generate, import, download, commit, or wire runtime art assets until a future goal explicitly scopes source/license metadata, manifest updates, validation, and before/after screenshot QA. If player-facing work is preferred, Tutorial v2 onboarding refinement remains the safer alternative.

## v0.8.1 Visual Asset Manifest And Screenshot QA Report Gate - 2026-05-10

Scope: create a visual asset inventory, metadata manifest, validation gate, runtime asset usage cross-check, optional screenshot QA harness, screenshot review baseline, Cinderfen visual replacement backlog, and safe future asset prompt/spec templates. This pass preserved gameplay, save compatibility, campaign progression, Tutorial / Proving Grounds behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, large binary assets, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, or broad systems.

Included work:

- Added `docs/V081_EXISTING_ASSET_INVENTORY_AUDIT.md`, `docs/V081_VISUAL_ASSET_MANIFEST_SCHEMA.md`, `docs/V081_INITIAL_VISUAL_ASSET_MANIFEST.md`, `docs/V081_RUNTIME_ASSET_USAGE_CROSSCHECK.md`, `docs/V081_SCREENSHOT_QA_PLAN.md`, `docs/V081_SCREENSHOT_QA_REVIEW.md`, `docs/CINDERFEN_VISUAL_ASSET_REPLACEMENT_BACKLOG.md`, `docs/ASSET_PROMPT_TEMPLATES.md`, and `docs/V081_VISUAL_ASSET_SCREENSHOT_QA_REPORT.md`.
- Added typed visual asset metadata in `src/game/assets/VisualAssetManifestTypes.ts`.
- Added an initial 89-entry manifest in `src/game/assets/visualAssetManifest.ts`.
- Integrated visual asset metadata validation into `npm run validate:content`.
- Added runtime visual asset coverage checks for battle textures, ability icons, UI-kit CSS assets, faction emblem, and main/results backgrounds.
- Added optional `npm run visual:qa` screenshot capture via `playwright.visual-qa.config.ts` and `tests/visual-qa/visual-qa.spec.ts`.
- Added `/visual-qa/` to `.gitignore` for generated screenshot artifacts.
- Captured and reviewed 10 screenshots with zero recorded browser console errors.
- Applied no visual code/CSS/renderer/scale/asset change because the screenshot review confirmed structural asset/art-direction debt rather than a single safe readability bug.

Latest final-gate verification results:

```text
npm test
PASS: 45 test files, 339 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-CC1M6Mg7.js, 476.83 kB minified / 127.77 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 4.9m.

npm run test:e2e:release
PASS: 67 Playwright tests in about 30.1m.

npm run test:e2e:release:shard1
PASS: 55 Playwright tests in about 25.1m.

npm run test:e2e:release:shard2
PASS: 12 Playwright tests in about 4.7m.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in about 11.8m.

npm run test:e2e:release:shard2of3
PASS: 27 Playwright tests in about 13.4m.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in about 4.7m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes during the report gate.

npm run visual:qa
PASS: 1 Playwright capture test, 10 screenshots, 0 recorded browser console errors.

production preview smoke
PASS: http://127.0.0.1:57934/ verified title, Prototype v0.3 / Cinderfen Route Baseline menu copy, Tutorial launch/exit, New Campaign to Campaign Map, Continue Campaign, Skirmish Setup, and zero browser console errors.

git diff --check
PASS: no whitespace errors during the final gate.
```

Recommended next milestone: v0.8.2 Visual Source/License Review and Screenshot Coverage Expansion. Focus on source/license proof for high-priority manifest entries and expand non-brittle screenshots to Results, Inventory, Asset Gallery, defeat tips, and one mobile/tablet battle view. Do not add new art assets, graphics overhaul, desktop packaging, engine switching, workers, enemy construction, new maps, new units, new factions, rewards, save changes, pressure action promotion, or broad systems unless explicitly scoped. If player-facing work is preferred, Tutorial v2 onboarding refinement remains the safer alternative.

## v0.8 Technical Performance And Visual Foundation Report Gate - 2026-05-10

Scope: refresh bundle/performance and e2e runtime facts while creating the visual debt, scale, art direction, asset pipeline, and Cinderfen visual foundation. This pass preserved gameplay, save compatibility, campaign progression, Tutorial / Proving Grounds behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, large binary assets, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, or broad systems.

Included work:

- Added `docs/V08_PERFORMANCE_AUDIT.md`, `docs/V08_E2E_RUNTIME_SHARD_AUDIT.md`, `docs/V08_E2E_RUNTIME_IMPROVEMENT_PLAN.md`, `docs/V08_VISUAL_DEBT_AUDIT.md`, `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md`, `docs/V08_PROTOTYPE_VISUAL_READABILITY_DECISION.md`, `docs/ART_DIRECTION_2026_BIBLE.md`, `docs/ASSET_PIPELINE_PLAN.md`, `docs/CINDERFEN_VISUAL_REWORK_SPEC.md`, and `docs/V08_TECH_VISUAL_FOUNDATION_REPORT.md`.
- Refreshed current build output: app JS remains 476.83 kB / 127.77 kB gzip, Phaser vendor remains 1,481.79 kB / 339.86 kB gzip, CSS remains 44.23 kB / 9.11 kB gzip, and the known warning remains isolated to the Phaser vendor chunk.
- Audited the 67-test Playwright release suite and confirmed the old 2-shard split is structurally imbalanced at 55 tests vs 12 tests.
- Added additive optional 3-shard release scripts while preserving the full release lane and existing 2-shard scripts.
- Verified the new 3-shard scripts locally: 28 tests in 12.3m, 27 tests in 14.9m, and 12 tests in 5.3m.
- Audited visual debt across terrain, roads, water/swamp, capture sites, units, buildings, minimap, HUD, and style mismatch.
- Audited current scale/readability rules for hero/unit/building/capture-site/minimap/camera/fog/pathfinding systems.
- Applied no visual code or CSS tweak because current readability is functional and the major problems are structural art-direction and asset-pipeline issues.
- Created the future 2026 art bible, asset pipeline plan, and Cinderfen visual rework spec without generating or committing art.

Latest report-gate verification results:

```text
npm test
PASS: 45 test files, 334 tests during the report gate.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-CC1M6Mg7.js, 476.83 kB minified / 127.77 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 6.3m during the report gate.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes during the report gate.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

npm run test:e2e:layout
First attempt hit command timeout with no failing-test output.
After cleaning repo-local leftover Playwright/Vite Node processes and rerunning with a longer timeout:
PASS: 25 Playwright tests in 14.9m.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in 12.3m.

npm run test:e2e:release:shard2of3
PASS: 27 Playwright tests in 14.9m.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in 5.3m.

git diff --check
PASS: no whitespace errors during phase gates.
```

Recommended next milestone: v0.8.1 Visual Asset Manifest and Screenshot QA Gate. Start with source/license/status/scale metadata for existing assets and a small screenshot review set. Do not add new art assets, graphics overhaul, desktop packaging, engine switching, workers, enemy construction, new maps, new units, new factions, rewards, save changes, pressure action promotion, or broad systems. If player-facing work is preferred, Tutorial v2 onboarding refinement is the safer alternative.

## v0.7.3 Real-Input Cinderfen Pressure Playtest Report Gate - 2026-05-09

Scope: review Cinderfen Crossing and Cinderfen Watch pressure with controlled browser input and simulator evidence without expanding into workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, live reinforcements, capture-site contest AI, defensive-hold behavior, or broad systems.

Included work:

- Added `docs/V073_REAL_INPUT_PRESSURE_PLAYTEST_PROTOCOL.md`, `docs/V073_PRESSURE_REVIEW_SETUP.md`, `docs/V073_CINDERFEN_CROSSING_REAL_INPUT_REVIEW.md`, `docs/V073_CINDERFEN_WATCH_REAL_INPUT_REVIEW.md`, `docs/V073_STRATEGY_PROFILE_PRESSURE_REVIEW.md`, `docs/V073_MANUAL_PRESSURE_PLAYTEST_CHECKLIST.md`, `docs/V073_EVIDENCE_BACKED_PRESSURE_POLISH_DECISION.md`, `docs/V08_DIRECTION_DECISION_BRIEF.md`, and `docs/V073_REAL_INPUT_PRESSURE_PLAYTEST_REPORT.md`.
- Used controlled browser-input review to launch Cinderfen Crossing and naturally capture the Cinder Shrine in one pass; Crossing delayed-warning visibility still used seeded surrogate evidence because repeated automated movement was not stable enough to call full human play.
- Used controlled browser-input review to launch Cinderfen Watch, naturally capture Watch Road, observe immediate and delayed pressure warnings, and confirm pressure priority protects the delayed warning from generic status replacement.
- Documented strategy-profile findings: Safe Beginner remains stable, Greedy Economy remains a timeout/closure read, Fast Army remains acceptable strategy expression, and Retinue + Training Yard II remains a saved-progress power watchpoint.
- Created Emmanuel's manual checklist for direct human pressure feedback.
- Applied no pressure copy, timing, status-duration, telemetry, defeat-tip, e2e, scope, wave-nudge, balance, reward, save, map, unit, faction, worker, construction, economy AI, or campaign progression change.
- Recommended v0.8 technical performance/e2e runtime work before any pressure-specific simulator-only reinforcement experiment.

Latest report-gate verification results:

```text
npm test
PASS: 45 test files, 334 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-CC1M6Mg7.js, 476.83 kB minified / 127.77 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors.
```

## v0.7.2 Human-Paced Cinderfen Pressure Review Report Gate - 2026-05-09

Scope: review Cinderfen Crossing and Cinderfen Watch pressure feel/readability without expanding into workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, live reinforcements, capture-site contest AI, defensive-hold behavior, or broad systems.

Included work:

- Added `docs/V072_PRESSURE_PLAY_REVIEW_PLAN.md`, `docs/V072_PRESSURE_BROWSER_REVIEW_NOTES.md`, `docs/V072_CINDERFEN_CROSSING_PRESSURE_REVIEW.md`, `docs/V072_CINDERFEN_WATCH_PRESSURE_REVIEW.md`, `docs/V072_PRESSURE_READABILITY_POLISH_DECISION.md`, `docs/V072_RETINUE_TRAINING_YARD_PRESSURE_REVIEW.md`, `docs/V072_GREEDY_FAST_PRESSURE_REVIEW.md`, `docs/V072_PRESSURE_NEXT_ACTION_DECISION.md`, and `docs/V072_PRESSURE_PLAY_REVIEW_REPORT.md`.
- Used seeded browser/Playwright review and screenshot inspection to confirm Crossing and Watch warnings remain readable.
- Applied no pressure copy, timing, status-duration, telemetry, defeat-tip, e2e, scope, wave-nudge, balance, reward, save, map, unit, faction, worker, construction, economy AI, or campaign progression change.
- Documented Retinue + Training Yard II as a saved-progress power watchpoint rather than a pressure bug.
- Documented Greedy Economy as a timeout/closure read and Fast Army as acceptable quick-clear expression.
- Kept `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only. Future stronger pressure should start with simulator-only `reinforce_next_wave` only after real-input human evidence.

Latest report-gate verification results:

```text
npm test
PASS: 45 test files, 334 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-CC1M6Mg7.js, 476.83 kB minified / 127.77 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 5.2m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors.
```

## v0.7.1 Enemy Pressure Feel Final Gate - 2026-05-09

Scope: review, polish, and harden Enemy Strategic Pressure V1 without expanding into workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, live reinforcements, capture-site contest AI, defensive-hold behavior, or broad systems.

Included work:

- Added `docs/V071_ENEMY_PRESSURE_FEEL_AUDIT.md`, `docs/V071_PRESSURE_WARNING_VISIBILITY_AUDIT.md`, `docs/V071_PRESSURE_ACTION_PROMOTION_GATE.md`, and `docs/V071_ENEMY_PRESSURE_FEEL_REPORT.md`.
- Polished Cinderfen Crossing and Cinderfen Watch pressure warning copy and pressure-specific defeat tips.
- Added pressure battle-status priority with a longer read window while keeping objective/capture feedback above pressure.
- Hardened `tests/e2e/enemy-pressure.spec.ts` so pressure warnings stay visible against normal status replacement attempts.
- Improved playtest report readability for pressure plan/stage labels, triggered/quiet run counts, warnings, losses, and strategy reads.
- Applied no balance tuning and kept `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only.

Latest verification results:

```text
npm test
PASS: 45 test files, 334 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-CC1M6Mg7.js, 476.83 kB minified / 127.77 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 5.3m.

npm run test:e2e:release
PASS: 67 Playwright tests in 32.9m.

npm run test:e2e:release:shard1
PASS: 55 Playwright tests in 28.2m.

npm run test:e2e:release:shard2
PASS: 12 Playwright tests in 5.0m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
Pressure read: 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 12 quiet/untriggered pressure runs, 149 warnings, 147 losses after pressure, 0 simulated reinforcement applications, no enemy-pressure analyzer warnings.

git diff --check
PASS: no whitespace errors.

Production preview smoke
PASS: Browser smoke at http://127.0.0.1:57931/
PASS: title was Ascendant Realms.
PASS: main menu copy showed Prototype v0.3 and Cinderfen Route Baseline.
PASS: Tutorial / Proving Grounds launched and exited without crashing.
PASS: New Campaign reached Campaign Map.
PASS: Continue Campaign reached Campaign Map after the preview save existed.
PASS: Skirmish Setup opened.
PASS: browser console errors stayed at 0.
NOTE: pressure-enabled battle launch was covered by targeted release e2e; the preview smoke did not force a deep Cinderfen save state.
```

Recommended next milestone: human-paced Cinderfen pressure play review. Focus on whether warnings are noticed and understood during real play, whether Cinder Shrine and Watch Road pressure feel fair, whether Fast Army and Greedy Economy outcomes read clearly, and whether Retinue + Training Yard II strength needs a separate human balance pass before any stronger enemy pressure action is promoted.

## v0.7 Enemy Strategic Pressure V1 Report Gate - 2026-05-09

Scope: implement and document the first controlled enemy commander pressure prototype. This pass preserved existing maps, units, factions, buildings, campaign progression, save compatibility, Tutorial / Proving Grounds no-reward behavior, and the browser-prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

Included work:

- Added `docs/V07_ENEMY_PRESSURE_RESEARCH_AUDIT.md`, `docs/V07_ENEMY_STRATEGIC_PRESSURE_SPEC.md`, and `docs/V07_ENEMY_STRATEGIC_PRESSURE_REPORT.md`.
- Added data-driven pressure plan types, metadata, content validation, campaign-only runtime resolution, battle warning copy, telemetry fields, simulator reporting, targeted e2e coverage, and release docs.
- Scoped active plans to `cinderfen_crossing` / `cinderfen_causeway` and `cinderfen_watch` / `cinderfen_watchpost`.
- Kept Ashen Outpost excluded from V1 pressure.
- Kept `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only; the only live/sim effect is an existing next-wave timing nudge.
- Applied no balance tuning after telemetry showed no enemy-pressure analyzer warnings and no structural `too_easy` or `too_hard` nodes.

Latest verification results:

```text
npm test
PASS: 44 test files, 328 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-B8rnpsai.js, 476.13 kB minified / 127.51 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 5.4m.

npm run test:e2e:release
PASS: 67 Playwright tests in 29.4m during the Phase 8 e2e coverage gate.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
Pressure read: 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 149 warnings, 0 simulated reinforcement applications, no enemy-pressure analyzer warnings.

git diff --check
PASS: no whitespace errors.
```

Recommended next milestone: human-paced Cinderfen pressure feel review. Focus on warning salience, Cinder Shrine contest readability, Watch Road timing, Fast Army quick-clear feel, Greedy Economy timeout clarity, and Retinue + Training Yard II strength before adding real reinforcement, route contesting, defensive-hold combat behavior, workers, construction, economy, new content, or broad AI systems.

## v0.6.1 Tutorial Feel Polish Gate - 2026-05-09

Scope: finish a small Browser-evidenced Tutorial / Proving Grounds feel polish pass on top of the final v0.6 onboarding foundation. This pass preserved the existing no-reward, non-persistent tutorial shell and did not add maps, units, factions, rewards, save-version changes, tutorial persistence, campaign progression, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

Included work:

- Added `docs/V061_TUTORIAL_FEEL_REVIEW.md`.
- Used Browser to review the main-menu Tutorial entry, desktop first objective overlay, 360 x 640 mobile-short first objective overlay, Exit Tutorial return, and console output.
- Found that the mobile-short battle status banner could paint over the tutorial overlay and interrupt the first objective text.
- Added explicit overlay z-index priority in `src/game/styles/battle-feedback.css` so `.tutorial-panel` renders above transient battle feedback.
- Added responsive Playwright coverage in `tests/e2e/layout.spec.ts` asserting the tutorial overlay renders above battle status feedback.
- Updated v0.6.1 planning/readability/audit docs and changelog.

Verification results:

```text
npm run test:e2e:layout -- --grep "tutorial entry"
PASS: 4 Playwright tests in 43.2s.

npm test
PASS: 42 test files, 315 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-BCE05t_6.js, 459.85 kB minified / 123.62 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 4.9m.

npm run test:e2e:layout
PASS: 25 Playwright tests in 12.4m.

Production preview Browser smoke
PASS: http://127.0.0.1:57919/
PASS: page title was Ascendant Realms.
PASS: Tutorial / Proving Grounds launched, showed the first overlay, and exited to the main menu.
PASS: browser console warnings/errors stayed at 0.
```

Recommended next milestone: human-play the twelve-step Tutorial / Proving Grounds at normal speed. Keep any follow-up limited to readability, overlay hierarchy, and no-reward completion clarity unless a narrow verified bug appears.

## Final v0.6 Tutorial Onboarding Foundation Gate - 2026-05-08

Scope: final verification and handoff for the v0.6 tutorial onboarding/testing foundation. This pass preserved the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, v0.4 technical groundwork, v0.5 save/content-validation gate, and no-reward playable Tutorial / Proving Grounds shell. It did not add maps, units, factions, rewards, save-version changes, tutorial persistence, campaign progression, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

Completed phases:

- Phase 0 repository integrity through Phase 12 final full verification completed.
- No phases were skipped.

Final verification results:

```text
npm test
PASS: 42 test files, 315 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-DN-Hs_qy.js, 459.85 kB minified / 123.62 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-BzEbtAWy.css, 44.19 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 4.8m.

npm run test:e2e:release
PASS: 65 Playwright tests in 28.9m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.4m and tests/e2e/deep-flow.spec.ts 11.4m.

npm run test:e2e:release:shard1
PASS: 53 Playwright tests in 24.0m.

npm run test:e2e:release:shard2
PASS: 12 Playwright tests in 4.9m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 57918 --strictPort
PASS: Browser smoke at http://127.0.0.1:57918/
PASS: page title was Ascendant Realms.
PASS: main menu was visible with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: Tutorial / Proving Grounds launched and exited without crashing.
PASS: New Campaign reached Campaign Map.
PASS: Continue Campaign reached Campaign Map after the preview save existed.
PASS: Skirmish Setup opened.
PASS: browser console errors stayed at 0.
```

Preview server was stopped after the smoke pass. No e2e transients or reruns were needed.

Recommended next milestone: human-play Tutorial / Proving Grounds, then do only small v0.6.1 tutorial feel polish around real input feel, copy clarity, overlay hierarchy, completion clarity, and command-log stability review.

## v0.6 Tutorial Onboarding Foundation Report Checkpoint - 2026-05-08

Scope: checkpoint the v0.6 tutorial onboarding/testing foundation before the final full release-style verification. This pass preserved the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, v0.4 technical groundwork, v0.5 save/content-validation gate, and no-reward playable Tutorial / Proving Grounds shell. It did not add maps, units, factions, rewards, save-version changes, tutorial persistence, campaign progression, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

Included work:

- Added the v0.6 tutorial feel audit.
- Polished tutorial copy, overlay layout, no-reward completion clarity, and accessibility semantics.
- Reviewed tutorial e2e lane placement and kept full completion in smoke while it remains near 5 minutes.
- Added test-only semantic command-log V1 for exactly one tutorial completion smoke path.
- Added command-log V1 plan and report.
- Added desktop/2026 visual-direction planning without implementation.
- Added `docs/V06_TUTORIAL_ONBOARDING_REPORT.md`.

Phase 11 report verification:

```text
npm test
PASS: 42 test files, 315 tests, 11.35s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-DN-Hs_qy.js, 459.85 kB minified / 123.62 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-BzEbtAWy.css, 44.19 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 5.0m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Recommended next milestone after the final full gate: human-play Tutorial / Proving Grounds, then do only small v0.6.1 tutorial feel polish around real input feel, copy clarity, overlay hierarchy, completion clarity, and command-log stability review.

## Final Tutorial / Proving Grounds Playable Shell Gate - 2026-05-08 19:21:40 -04:00

Scope: final verification and handoff for the first playable Tutorial / Proving Grounds shell. This pass preserved the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, v0.4 technical groundwork, and v0.5 save/content-validation gate. It did not add maps, units, factions, rewards, save-version changes, campaign progression, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

Completed phases:

- Phase 0 repository integrity through Phase 12 release report completed and committed.
- Phase 13 optional polish skipped intentionally; the next changes should come from human tutorial feel review.
- Phase 14 final full verification completed.

Final verification results:

```text
npm test
PASS: 42 test files, 315 tests, 11.45s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-BArZgVc-.js, 459.27 kB minified / 123.49 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-EaFx5BCM.css, 43.77 kB minified / 9.02 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 5.2m.

npm run test:e2e:release
PASS: 65 Playwright tests in 28.5m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.3m and tests/e2e/deep-flow.spec.ts 11.2m.

npm run test:e2e:release:shard1
PASS: 53 Playwright tests in 24.4m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.7m and tests/e2e/deep-flow.spec.ts 11.4m.

npm run test:e2e:release:shard2
PASS: 12 Playwright tests in 4.9m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 57916 --strictPort
PASS: Browser smoke at http://127.0.0.1:57916/
PASS: page title was Ascendant Realms.
PASS: main menu was visible with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: Tutorial / Proving Grounds launched and exited without crashing.
PASS: New Campaign reached Campaign Map.
PASS: Continue Campaign returned to Campaign Map after the preview save existed.
PASS: Skirmish Setup opened.
PASS: browser console errors stayed at 0.
```

Preview note: an initial ad hoc headless launch without the project's Chromium SwiftShader args reported `Framebuffer Unsupported`. The preview smoke was rerun with the same Chromium args used by Playwright, passed with zero console errors, and the preview server was stopped afterward.

Recommended next milestone: human-play Tutorial / Proving Grounds, then do only small tutorial polish around copy, overlay hierarchy, completion clarity, and layout spacing unless a verified bug requires a narrow fix.

## Tutorial / Proving Grounds Playable Shell Report Checkpoint - 2026-05-08 18:11:29 -04:00

Scope: checkpoint the first playable Tutorial / Proving Grounds shell documentation before the final full release-style verification. This pass preserved the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, v0.4 technical groundwork, and v0.5 save/content-validation gate. It did not add maps, units, factions, rewards, save-version changes, campaign progression, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

Included work:

- Added `docs/TUTORIAL_PLAYABLE_SHELL_REPORT.md`.
- Updated README, roadmap, release checklist, changelog, and handoff status for the no-reward playable tutorial shell.
- Documented launch path, reused content, twelve tutorial steps, no-reward policy, save/persistence policy, tests added, e2e lane impact, known risks, and next recommended improvement.
- Confirmed the next recommended work is human-paced tutorial review and small polish, not content expansion.

Phase 12 report verification:

```text
npm test
PASS: 42 test files, 315 tests, 10.70s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-BArZgVc-.js, 459.27 kB minified / 123.49 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-EaFx5BCM.css, 43.77 kB minified / 9.02 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 4.8m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.
```

Recommended next milestone after the final full gate: human-play Tutorial / Proving Grounds, then do only small tutorial polish around copy, overlay hierarchy, completion clarity, and layout spacing unless a verified bug requires a narrow fix.

## Final v0.5 Save Content Validation Gate - 2026-05-08 14:54:30 -04:00

Scope: final verification and handoff for the v0.5 save, content-validation, determinism, and expansion-readiness gate. This pass did not add gameplay content, change balance, bump the save version, add maps, add units, add factions, add workers, add enemy construction, add diplomacy, add procedural generation, add crafting, add multiplayer, or add broad systems.

Final verification results:

```text
npm test
PASS: 40 test files, 298 tests, 9.84s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-Caz7zKca.js, 445.42 kB minified / 119.69 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-CeqfGaMI.css, 42.04 kB minified / 8.74 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.5m.

npm run test:e2e:release
PASS: 59 Playwright tests in 28.4m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.6m and tests/e2e/deep-flow.spec.ts 11.0m.

npm run test:e2e:release:shard1
PASS: 49 Playwright tests in 23.9m.

npm run test:e2e:release:shard2
PASS: 10 Playwright tests in 4.4m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 57915 --strictPort
PASS: Browser smoke at http://127.0.0.1:57915/
PASS: page title was Ascendant Realms.
PASS: main menu was visible with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: New Campaign reached Campaign Map.
PASS: Continue Campaign returned to Campaign Map after the preview save existed.
PASS: Skirmish Setup opened and listed current maps.
PASS: browser console errors stayed at 0.
```

The preview server was stopped after the smoke pass. No Phase 15 transient reruns were needed.

Recommended next milestone: implement the first Tutorial / Proving Grounds playable shell using existing content only, with no rewards, no save-version bump, no new map, no new units, no new faction, and no broad systems.

## v0.5 Save Content Validation Gate Documentation Checkpoint - 2026-05-08 13:50:00 -04:00

Scope: checkpoint the v0.5 save, content-validation, determinism, and expansion-readiness gate documentation before the final full release-style verification. This pass preserved the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, and v0.4 technical groundwork. It did not add playable tutorial content, change gameplay balance, bump the save version, add maps, add units, add factions, add workers, add enemy construction, add diplomacy, add procedural generation, add crafting, add multiplayer, or add broad systems.

Included work:

- Added fixture-based save migration and normalization coverage for legacy V1, V2 campaign progress, settings-only saves, invalid JSON, affixed inventory, legacy equipment, retinue, rivals, trophies, Chapter 2 selection, Cinderfen route progress, missing optional fields, and future-ish unknown fields.
- Added stronger content validation and `npm run validate:content`.
- Added campaign graph/reward validation and documentation.
- Added command-log replay feasibility documentation recommending a future test-only semantic replay slice.
- Added simulator determinism documentation and tests.
- Selected Candidate A, Tutorial / Proving Grounds, for future planning.
- Added the Tutorial / Proving Grounds design brief and a non-playable metadata-only scaffold.
- Added `docs/V05_SAVE_CONTENT_VALIDATION_GATE_REPORT.md`.

Phase 14 documentation verification:

```text
npm test
PASS: 40 test files, 298 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-Caz7zKca.js, 445.42 kB minified / 119.69 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-CeqfGaMI.css, 42.04 kB minified / 8.74 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.7m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors.
```

Recommended next milestone after the full v0.5 final gate: implement the first Tutorial / Proving Grounds playable shell using existing content only, with no rewards, no save-version bump, no new map, no new units, no new faction, and no broad systems.

## v0.4 Overnight Autonomous Progress Checkpoint - 2026-05-08 03:58:50 -04:00

Scope: checkpoint the extended v0.4 overnight autonomous goal. This pass preserved the frozen v0.3 Cinderfen Route Baseline and frozen v0.3.1 polish release. It did not add gameplay content, change balance, add maps, add units, add factions, add workers, add enemy construction, add diplomacy, add procedural generation, add crafting, alter save format, or change campaign rules.

Included work:

- Reconfirmed repository integrity and kept every phase checkpoint committed only after green verification.
- Refreshed bundle analysis, production test/dev hook audit, analyzer-backed no-op optimization decision, and e2e sharding documentation.
- Hardened one test-only rally movement wait in `tests/e2e/deep-flow.spec.ts`; no gameplay code changed.
- Applied copy-only Settings readability polish for colorblind minimap and small-screen command-panel guidance.
- Added `docs/SAVE_COMPATIBILITY_AUDIT.md` and one save test preserving valid Chapter 2 selected chapter/node state.
- Added `docs/V04_ROUTE_FEEL_SURROGATE_REVIEW.md`.
- Expanded `docs/FULL_GAME_ROADMAP.md`, `docs/SYSTEMS_EXPANSION_RISK_REGISTER.md`, and `docs/V05_SYSTEMS_DESIGN_BRIEF.md` to cover all fifteen future-system planning tracks.
- Added `docs/V04_POLISH_BACKLOG.md`.

Checkpoint commits created in this overnight continuation:

```text
5459857 Checkpoint v0.4 bundle analysis
e393dd5 Checkpoint v0.4 test hook audit
5748857 Checkpoint v0.4 measured performance optimization
614a9ba Checkpoint v0.4 e2e sharding groundwork
ce1bc23 Checkpoint v0.4 e2e flake hardening
c302c34 Checkpoint v0.4 accessibility readability polish
7d156c6 Checkpoint v0.4 save compatibility audit
718820e Checkpoint v0.4 route feel surrogate review
cb333c5 Checkpoint full-game roadmap architecture
4b21824 Checkpoint v0.4 polish backlog
```

Final verification results:

```text
npm test
PASS: 38 test files, 271 tests, 7.35s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-90WGArXv.js, 436.35 kB minified / 117.34 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-CeqfGaMI.css, 42.04 kB minified / 8.74 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.6m.

npm run test:e2e:release
PASS: 59 Playwright tests in 27.8m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.1m and tests/e2e/deep-flow.spec.ts 11.1m.

npm run test:e2e:release:shard1
PASS: 49 Playwright tests in 23.0m.

npm run test:e2e:release:shard2
PASS: 10 Playwright tests in 4.2m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 57911 --strictPort
PASS: Browser Use smoke at http://127.0.0.1:57911/
PASS: page title was Ascendant Realms.
PASS: main menu was visible with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: New Campaign reached Campaign Map.
PASS: Continue Campaign returned to Campaign Map after the preview save existed.
PASS: Skirmish Setup opened and listed current maps.
PASS: browser console errors stayed at 0.
```

The preview server was stopped after the smoke pass. The next recommended long-running goal is the v0.5 save/content-validation gate: fixture-based save migration tests, stricter future content validation rules, deterministic command-log feasibility notes, and one explicitly approved vertical-slice candidate. Continue postponing workers, enemy construction, full new factions, new maps, diplomacy, procedural generation, crafting, multiplayer, monetization code, and broad army-management systems until their gates are explicit and green.

## v0.4 Autonomous Goal Progress Checkpoint - 2026-05-07 23:40:55 -04:00

Scope: checkpoint the autonomous v0.4 goal pass. This pass preserved the frozen v0.3 Cinderfen Route Baseline and frozen v0.3.1 polish release. It did not add gameplay content, change balance, add maps, add units, add factions, add workers, add enemy construction, add diplomacy, add procedural generation, add crafting, alter save format, or change campaign rules.

Included work:

- Confirmed the repo started clean and synced with `origin/main`.
- Re-ran and validated the existing bundle analyzer, bundle report, test/dev hook audit, analyzer-backed no-op optimization decision, and e2e release shard scripts.
- Added low-risk Settings readability/accessibility polish: clearer accessibility toggle labels, concise setting hints, UI Scale explanation, clearer Fog of War Override labels, and a broader keyboard/control reference.
- Added `docs/V04_ACCESSIBILITY_READABILITY_PLAN.md`.
- Added planning-only full-game architecture docs:
  - `docs/FULL_GAME_ROADMAP.md`
  - `docs/SYSTEMS_EXPANSION_RISK_REGISTER.md`
  - `docs/V05_SYSTEMS_DESIGN_BRIEF.md`

Commits created before this final docs checkpoint:

```text
9934fb6 Checkpoint v0.4 accessibility readability polish
29ec5b6 Checkpoint full-game roadmap architecture
```

Phase 4 shard note:

```text
npm run test:e2e:release:shard1
First run: one transient timeout in tests/e2e/deep-flow.spec.ts around the first campaign rally movement assertion.
Follow-up: the exact failed test passed without code changes, then the full shard1 rerun passed with 49 tests.

npm run test:e2e:release:shard2
PASS: 10 Playwright tests.
```

Final verification results:

```text
npm test
PASS: 38 test files, 270 tests, 7.15s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-Bi19pD8P.js, 436.32 kB minified / 117.33 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-CeqfGaMI.css, 42.04 kB minified / 8.74 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.2m.

npm run test:e2e:release
PASS: 59 Playwright tests in 26.1m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 11.3m and tests/e2e/deep-flow.spec.ts 10.7m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 57705
PASS: Browser Use smoke at http://127.0.0.1:57705/
PASS: page title was Ascendant Realms.
PASS: main menu was visible with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: browser console errors stayed at 0.
```

The preview server was stopped after the smoke pass. The next recommended milestone is a v0.5 save/content-validation gate before any broad mechanics implementation: save migration tests, future content validation rules, a deterministic command-log feasibility note, and one explicitly approved vertical-slice candidate.

## v0.4 Performance And E2E Sharding Groundwork Checkpoint - 2026-05-07 21:23:29 -04:00

Scope: checkpoint the v0.4 measurement, performance, and e2e sharding groundwork. This checkpoint does not add gameplay content, change balance, add maps, add units, add factions, add workers, add enemy construction, add diplomacy, add procedural generation, add crafting, alter save format, or change campaign content.

Included technical groundwork:

- Bundle analyzer script and report added for the current v0.4 technical baseline.
- Test/dev hook audit completed; no accidental large Playwright, Vitest, e2e-helper, or simulator leak was found in the production bundle.
- Phaser remains split into the `vendor-phaser` Vite/Rollup chunk.
- Analyzer-backed second optimization decision chose no additional code optimization; Asset Gallery was too small, no safe accidental production leakage was found, and no second stable vendor chunk exists.
- Explicit Playwright lanes remain available: `test:e2e:smoke`, `test:e2e:layout`, `test:e2e:deep`, and `test:e2e:release`.
- Minimal 2-shard release-gate scripts were added for CI: `test:e2e:release:shard1` and `test:e2e:release:shard2`.
- Full `npm run test:e2e` and `npm run test:e2e:release` remain the canonical complete release-gate commands.

Verification results:

```text
npm test
PASS: 38 test files, 270 tests, 10.38s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-TotuX8zG.js, 435.50 kB minified / 116.99 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-CIXXIuKP.css, 41.86 kB minified / 8.71 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.2m.

npm run test:e2e:release
PASS: 59 Playwright tests in 28.8m.
Slow files noted by Playwright: tests/e2e/deep-flow.spec.ts 12.1m and tests/e2e/layout.spec.ts 12.0m.

npm run test:e2e:release:shard1
PASS: 49 Playwright tests in 24.0m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.5m and tests/e2e/deep-flow.spec.ts 11.2m.

npm run test:e2e:release:shard2
PASS: 10 Playwright tests in 4.3m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated.

git diff --check
PASS: no whitespace errors. Git emitted the existing .gitignore LF-to-CRLF working-copy warning.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 4191 --strictPort
PASS: Browser Use smoke at http://127.0.0.1:4191/
PASS: page title was Ascendant Realms.
PASS: main menu loaded with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: New Campaign created a preview-smoke hero and reached Campaign Map.
PASS: Continue Campaign returned to Campaign Map after the smoke save existed.
PASS: Skirmish Setup opened and listed current maps.
PASS: browser console errors stayed at 0.
```

The preview server was stopped after the smoke pass. The shard scripts were run even though the full release gate also passed; the current split is coverage-preserving but locally uneven, with shard 1 carrying deep-flow and layout-heavy coverage. The shard scripts are primarily for CI matrix wall-clock reduction, not mandatory local iteration.

Checkpoint commit message:

```text
Checkpoint v0.4 performance and e2e sharding groundwork
```

Remaining known risks:

- Full Playwright release gate is still slow at roughly 29 minutes.
- The 2-shard split is currently uneven; shard 1 remains the long shard.
- Vite still reports a large-chunk warning because Phaser remains a large vendor chunk.
- Browser readability, mobile density, retinue/rival/trophy hierarchy, and Cinder Shrine salience still deserve human review before new content.
- Further performance work should remain analyzer-guided and limited to one explicit optimization at a time.

Recommended next milestone:

Use this checkpoint as the v0.4 technical baseline, then choose one focused follow-up: CI workflow wiring for the shard scripts, human readability/accessibility review of the frozen Cinderfen route, or a separate test-harness/content-validation hardening plan. Continue postponing workers, enemy construction, new factions, new maps, crafting, diplomacy, procedural systems, and broad gameplay systems.

## v0.4 Technical Groundwork Verification Refresh - 2026-05-07 17:58:57 -04:00

Scope: clean post-checkpoint verification before further work. No reset, checkout, delete, revert, gameplay addition, content addition, balance change, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, or broad systems were added. The repository was clean and synced before this metadata refresh.

Verification results:

```text
npm test
PASS: 38 test files, 270 tests, 11.23s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-TotuX8zG.js, 435.50 kB minified / 116.99 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-CIXXIuKP.css, 41.86 kB minified / 8.71 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.7m.

npm run test:e2e:release
PASS: 59 Playwright tests in 28.1m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.0m and tests/e2e/deep-flow.spec.ts 11.5m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors before this metadata refresh.
```

Branch status before this metadata refresh:

```text
git status -sb
## main...origin/main

git rev-list --left-right --count origin/main...HEAD
0 0
```

Recommended next milestone remains unchanged: choose one focused v0.4 follow-up, preferably analyzer-guided performance measurement, a second carefully scoped optimization, or human readability/accessibility review of the frozen Cinderfen route. Continue postponing workers, enemy construction, new factions, new maps, crafting, diplomacy, procedural systems, and broad gameplay systems.

## v0.4 Technical Test And Performance Groundwork Checkpoint - 2026-05-06 21:25:41 -04:00

Scope: checkpoint the v0.4 technical groundwork after the explicit e2e lane split and the first measured performance optimization. This checkpoint does not add gameplay content, change balance, add maps, add units, add factions, add workers, add enemy construction, add diplomacy, add procedural generation, add crafting, or alter campaign content.

Included technical groundwork:

- Added explicit Playwright lanes while preserving the full release gate: `test:e2e:smoke`, `test:e2e:layout`, `test:e2e:deep`, and `test:e2e:release`.
- Kept `npm run test:e2e` as the full Playwright suite.
- Added v0.4 planning docs for direction and performance implementation.
- Implemented only the first approved performance optimization: Vite/Rollup splits `node_modules/phaser` into `vendor-phaser`.
- Documented before/after bundle numbers and the remaining Phaser vendor large-chunk warning.

Verification results:

```text
npm test
PASS: 38 test files, 270 tests, 10.18s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-TotuX8zG.js, 435.50 kB minified / 116.99 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-CIXXIuKP.css, 41.86 kB minified / 8.71 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.8m.

npm run test:e2e:release
PASS: 59 Playwright tests in 29.0m on final full-suite rerun.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.4m and tests/e2e/deep-flow.spec.ts 11.8m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors after checkpoint metadata update.
```

E2E note: the first full release-gate run had one transient timeout in the deep-flow rally movement assertion, while 58 tests passed. The targeted failed case then passed in 38.1s without code changes, and the full release gate passed on rerun. No gameplay or test semantics were changed in response.

Checkpoint commit message:

```text
Checkpoint v0.4 technical test and performance groundwork
```

Remaining known risks:

- Full Playwright release gate is still slow at roughly 29 minutes.
- The fast smoke lane is useful for iteration but is not a release-gate replacement.
- Vite still reports a large-chunk warning because Phaser remains a large vendor chunk.
- Further performance work should be analyzer-guided and limited to one explicit optimization at a time.
- Human readability and mobile-density review of the frozen Cinderfen route remains valuable before new content.

Recommended next milestone:

Choose a focused v0.4 follow-up: analyzer-guided performance measurement, a second carefully scoped optimization, or human readability/accessibility review of the frozen Cinderfen route. Continue postponing workers, enemy construction, new factions, new maps, crafting, diplomacy, procedural systems, and broad gameplay systems.

## Final v0.3.1 Polish Release Verification - 2026-05-06 18:30:40 -04:00

Scope: final automated verification for the v0.3.1 polish release. No features, gameplay behavior, balance values, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, durability, or broad systems were added. The only changes after verification are release-documentation updates.

Verification results:

```text
npm test
PASS: 38 test files, 270 tests, 7.56s.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only.
Output: assets/index-BlnznQM_.js, 1,918.65 kB minified / 457.79 kB gzip.
CSS: assets/index-CIXXIuKP.css, 41.86 kB minified / 8.71 kB gzip.

npm run test:e2e -- --reporter=line
PASS: 59 Playwright tests in 28.6m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.3m and tests/e2e/deep-flow.spec.ts 11.4m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle node/profile summaries.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 4188
PASS: Browser Use smoke at http://127.0.0.1:4188/
PASS: page title was Ascendant Realms.
PASS: main menu loaded with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: New Campaign reached Campaign Map.
PASS: Continue Campaign returned to Campaign Map after the smoke save existed.
PASS: Skirmish Setup opened and listed the current maps.
PASS: browser console errors stayed at 0.
```

The preview server was stopped after the smoke pass. Final v0.3.1 decision: frozen as the polish release for the frozen Cinderfen Route Baseline, with remaining known risks limited to human readability/feel, mobile density, Cinder Shrine salience, retinue/rival/trophy hierarchy, the long Playwright release-gate runtime, and the accepted Vite large-chunk warning.

## Clean v0.3.1 Polish Checkpoint - 2026-05-06 17:49:49 -04:00

Scope: create a clean checkpoint for the completed v0.3.1 polish, readability, audit, and safe e2e helper work before any new feature work. No reset, checkout, delete, revert, gameplay addition, balance change, map addition, unit addition, faction addition, worker system, enemy construction, diplomacy, procedural generation, crafting, or broad refactor was performed during this checkpoint pass.

Preserved current dirty work:

- v0.3.1 polish plan and route readability documentation.
- UX copy and hierarchy polish for the existing frozen Cinderfen route.
- Mobile/readability audit coverage and documentation.
- Performance bundle audit documenting the known Vite large-chunk warning.
- E2E runtime audit plus the safest helper cleanup.
- Shared Playwright setup helpers for smoke/layout setup while keeping release-critical full-flow coverage visible in specs.
- All existing gameplay behavior, route content, selectors, and balance.

Verification results:

```text
npm test
PASS: 38 test files, 270 tests, 8.21s.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only.
Output: assets/index-BlnznQM_.js, 1,918.65 kB minified / 457.79 kB gzip.
CSS: assets/index-CIXXIuKP.css, 41.86 kB minified / 8.71 kB gzip.

npm run test:e2e -- --reporter=line
PASS: 59 Playwright tests in 28.7m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.4m and tests/e2e/deep-flow.spec.ts 11.5m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle node/profile summaries.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Git and branch status:

```text
Pre-checkpoint `git status -sb`: ## main...origin/main with the expected dirty v0.3.1 polish/audit/helper stack.
Pre-checkpoint `git rev-list --left-right --count origin/main...HEAD`: 0 0
Checkpoint commit message: Checkpoint v0.3.1 polish readability and e2e cleanup
Checkpoint commit hash: 53fa85671dd5668b6654abfd01aeed857bf49ab2
Post-checkpoint, pre-metadata `git status -sb`: ## main...origin/main [ahead 1]
Post-checkpoint, pre-metadata `git rev-list --left-right --count origin/main...HEAD`: 0 1
Metadata commit hash: eaacdeaf4370005bf791d5bc2023d86b4b31503e
After pushing the checkpoint and metadata commits, `git status -sb`: ## main...origin/main
After pushing the checkpoint and metadata commits, `git rev-list --left-right --count origin/main...HEAD`: 0 0
After this push-status note is pushed, the branch should remain synced with origin/main.
```

Remaining known risks:

- Human readability and feel still need review on the frozen Cinderfen route, especially Cinderfen Overlook, Waystation, Cinder Shrine, Watch, Aftermath, Results, and mobile density.
- Vite still reports the known large Phaser/main-bundle warning; the performance audit recommends documentation and safe future options only, with no risky optimization implemented for v0.3.1.
- Full Playwright e2e remains slow at roughly 29 minutes. The helper cleanup held coverage steady and avoided brittle shortcuts; deeper runtime reductions should use explicit release-gate/default split decisions later.
- Fast Army, retinue, and Training Yard II profiles remain campaign pacing watchpoints during human playtesting.

Recommended next milestone:

Human-verify v0.3.1 polish on the frozen Cinderfen route in a browser, then decide whether to keep the full Playwright suite as a release gate and add a smaller default smoke lane. Do not start new Chapter 2 content or broad systems until the existing route stays green in human readability, UX, and balance review.

## Final v0.3 Release-Candidate Verification - 2026-05-05 18:36 -04:00

Scope: final automated verification for the v0.3 Cinderfen route release-candidate freeze. No features, gameplay behavior, balance values, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, durability, or broad systems were added. The only changes in this pass are release-candidate documentation updates.

Verification results:

```text
npm test
PASS: 38 test files, 268 tests, 7.40s.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only.
Output: assets/index-BRMcmX2c.js, 1,917.92 kB minified / 457.57 kB gzip.

npm run test:e2e -- --reporter=line
PASS: 52 Playwright tests in 21.9m.
Slow files noted by Playwright: tests/e2e/deep-flow.spec.ts and tests/e2e/layout.spec.ts.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle node/profile summaries.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json were regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 4187
PASS: Browser Use smoke at http://127.0.0.1:4187/
PASS: main menu loaded with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: New Campaign reached hero creation and Campaign Map.
PASS: Continue Campaign returned to Campaign Map after the smoke save existed.
PASS: Skirmish Setup opened and listed the current maps.
PASS: browser console errors stayed at 0.
```

The preview server was stopped after the smoke pass. Final freeze decision: v0.3 is ready to freeze as the Cinderfen Route Baseline prototype release candidate, with remaining known risks limited to human readability/feel watch items.

## Checkpoint Scope

This checkpoint records the verified v0.3 Cinderfen route polish-freeze baseline. It preserves the v0.3 baseline docs, readiness/preview reports, route-complete polish, reward-audit/test updates, Chapter 2 e2e helper cleanup, and campaign map presentation helper cleanup without adding gameplay during the checkpoint pass.

Included in this checkpoint:

- `cinderfen_overlook` is a playable Chapter 2 event gate after `ashen_outpost`.
- `cinderfen_waystation` is a compact Chapter 2 town/support node after Cinderfen Overlook.
- `cinderfen_crossing` launches the authored `Cinderfen Causeway` map after the event gate is completed.
- Cinderfen Causeway includes the Cinder Shrine first-capture Aether surge and Shrine Attunement support.
- `cinderfen_watch` launches the compact `Cinderfen Watchpost` map after Cinderfen Crossing victory.
- `cinderfen_aftermath` is a compact non-battle consequence event after Cinderfen Watch.
- The compact Malrec trophy consequence is visible through the existing rival/trophy state.
- Chapter/campaign data is split into focused node and reward modules with compatibility barrels preserved.
- Chapter 2 reward-economy audit changes are preserved: Cinderfen repeat clears pay only tiny XP/resources and no repeat battle item roll while first clears remain useful.
- Chapter 2 Playwright setup cleanup is preserved in `tests/e2e/chapter2-helpers.ts`; smoke specs keep the meaningful reward, copy, persistence, and duplicate-prevention assertions.
- v0.3 baseline/readiness documentation is preserved in `docs/V03_CINDERFEN_ROUTE_BASELINE.md`, `docs/CINDERFEN_ROUTE_READINESS_GATE.md`, and `docs/PRODUCTION_PREVIEW_REPORT.md`.
- Route-complete polish is preserved: completing Cinderfen Aftermath makes the campaign map/return flow clearly communicate that the playable Cinderfen route is secured and the Chapter 2 slice is complete.
- Campaign map presentation cleanup is preserved with focused helpers for chapter cards, node cards, route status, event/town choice summaries, and result copy.
- Chapter 2 event, support, battle, aftermath, reward, persistence, simulator, e2e, telemetry, balance, report, production-preview, and documentation changes from the current route are preserved.
- Chapter 1 remains stable in tests, e2e, and simulator telemetry.

No gameplay behavior was changed during this checkpoint request. The only post-verification edits are this checkpoint record and the corresponding handoff update.

## Verification Results

### Unit Tests

Command:

```bash
npm test
```

Result:

```text
PASS
38 test files passed
268 tests passed
Latest duration: 10.77s
```

### Production Build

Command:

```bash
npm run build
```

Result:

```text
PASS
TypeScript compile passed
Vite production build passed
Latest output: assets/index-CIosN5VC.js, 1,917.97 kB minified / 457.58 kB gzip.
```

Known build warning:

```text
Some chunks are larger than 500 kB after minification.
```

### Browser E2E

Command:

```bash
npm run test:e2e -- --reporter=line
```

Result:

```text
PASS
52 Playwright tests passed
Total duration: 21.4m
Slow files noted by Playwright: tests/e2e/deep-flow.spec.ts and tests/e2e/layout.spec.ts
```

Coverage includes Chapter 2 browser flows that resolve Cinderfen Overlook, use Cinderfen Waystation Shrine Attunement, win Cinderfen Crossing, verify Cinder Shrine rewards do not duplicate, win Cinderfen Watch, verify rewards persist once, resolve Cinderfen Aftermath, verify route-complete copy, verify future Chapter 2 nodes remain upcoming/locked, verify Aftermath rewards do not duplicate, and verify the Malrec trophy consequence. The Chapter 2 smoke flows use the extracted helper module.

### Playtest Simulation

Command:

```bash
npm run playtest:sim
```

Result:

```text
PASS
Simulated 255 runs across 85 campaign battle node/profile summaries.
Regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json.
Chapter 1 telemetry remains stable.
Cinderfen Crossing and Cinderfen Watch remain structurally reasonable.
```

### Git Diff Check

Command:

```bash
git diff --check
```

Result:

```text
PASS
No whitespace errors.
```

## Git And Branch Status

Checkpoint commit message:

```text
Checkpoint v0.3 Cinderfen route polish freeze
```

Checkpoint commit hash:

```text
f644bb6dc6b09d529a249321fd70563fa44748e1
```

Branch:

```text
main tracking origin/main
```

Branch sync status:

```text
Before the checkpoint commit, `git status -sb` reported `## main...origin/main` with the expected dirty v0.3 polish-freeze stack.
Before the checkpoint commit, `git rev-list --left-right --count origin/main...HEAD` reported `0 0`.
After checkpoint commit `f644bb6dc6b09d529a249321fd70563fa44748e1` and before this metadata update, `git status -sb` reported `## main...origin/main [ahead 1]`, and `git rev-list --left-right --count origin/main...HEAD` reported `0 1`.
After pushing the checkpoint and metadata update, `git status -sb` reported `## main...origin/main`, and `git rev-list --left-right --count origin/main...HEAD` reported `0 0`.
```

## Remaining Known Risks

- Human playtesting is still needed for the full Cinderfen route with no retinue, light retinue, Training Yard II, Quartermaster II, and mixed Chapter 1 upgrade states.
- Fast Army and retinue plus Training Yard II profiles can still clear Cinderfen quickly, so reward pacing should be watched before adding more Chapter 2 payouts even though repeat farming value is now tiny.
- Cinder Shrine and Shrine Attunement are intentionally modest, but human players may overvalue or miss the first-capture Aether surge without a live readability pass.
- Cinderfen Overlook, Waystation, and Aftermath choice/service copy is covered by tests, but mobile UI density should still be spot-checked in the browser.
- The Chapter 2 Playwright helper file should stay a setup/fast-forward helper only; future specs should keep meaningful gameplay assertions in the spec files.
- Campaign map presentation helpers should stay presentation-only; do not move campaign rules, save mutation, or battle launch logic into the view-model helper layer.
- Rival impact is intentionally compact and Malrec-trophy-gated; broader returning-rival arcs remain future work.
- Chapter/campaign content now depends on focused data modules and compatibility barrels staying aligned.
- Vite still reports the known large Phaser bundle warning.
- Full Playwright e2e remains slow at roughly 22 minutes.

## Recommended Next Milestone

Human-verify the v0.3 Cinderfen route freeze candidate end to end: Overlook, Waystation, Crossing, Cinder Shrine surge/attunement, Watch, Aftermath, Results, route-complete campaign-map copy, and return-to-campaign persistence. Add no further Chapter 2 content until the route stays green in human readability and balance review. Avoid workers, enemy construction, new factions, diplomacy, procedural generation, crafting, and broad army-management systems.
