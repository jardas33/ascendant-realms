# Ascendant Realms

Ascendant Realms is a frozen v0.3 Cinderfen route baseline for a long-term fantasy RTS/RPG hybrid, with v0.3.1 frozen as its polish/readability layer, v0.4 serving as technical/UX/planning groundwork, v0.5 adding a save, content-validation, determinism, and expansion-readiness gate, v0.6 strengthening Tutorial / Proving Grounds onboarding and test-only command-log foundations, v0.7 adding the first controlled Enemy Strategic Pressure V1 prototype, v0.7.1 polishing pressure warning feel and visibility, v0.7.2 reviewing Cinderfen pressure feel without expanding mechanics, v0.7.3 adding closer-to-real browser-input pressure review plus a manual playtest checklist, v0.8 refreshing technical/e2e runtime facts while creating a visual debt, scale, 2026 art direction, asset pipeline, and Cinderfen visual foundation gate, v0.8.1 adding the visual asset manifest and screenshot QA foundation, v0.8.2 hardening source/license review plus expanded screenshot coverage, v0.9 defining a controlled docs/specs/prompts-only Cinderfen style-frame package before any art generation or runtime replacement, v0.9.1 adding the safe non-runtime intake pipeline for future Cinderfen style-frame candidates, v0.10 refining Tutorial / Proving Grounds onboarding clarity without adding rewards, persistence, maps, units, factions, or art replacement, v0.11 improving technical reliability, e2e lane clarity, preview smoke automation, visual QA reporting, bundle/performance documentation, command ergonomics, and release-checklist maintainability without changing gameplay or content, v0.11.1 adding a conservative GitHub Actions CI dry-run workflow, CI matrix documentation, preview helper portability notes, artifact strategy, and CI/local parity checks without changing gameplay or content, v0.11.2 documenting remote CI observation limits, static workflow review, timeout/artifact/preview-helper review, and an Emmanuel-facing GitHub Actions checklist without changing gameplay, content, CI coverage, or workflow behavior, v0.11.5 splitting automatic GitHub fast confidence from full smoke/release browser lanes without deleting or weakening tests, v0.11.9 adding a hosted-only 6-way manual release matrix for GitHub runners while preserving local full release and 3-way shards, v0.11.10 replacing that hosted matrix with deterministic explicit release groups plus pre-boot seeded-save fixtures, v0.11.11 moving those hosted release groups onto production preview, and v0.11.12 hardening hosted release interaction determinism for DOM buttons, battle-loaded waits, layout boxes, side-panel measurement, and canvas movement commands. The visible main menu labels the playable build as `Prototype v0.3` with the subtitle `Cinderfen Route Baseline`; v0.2 remains the previous systems baseline, while v0.3 promotes the compact Chapter 2 Cinderfen route on top of that technical foundation. You create a persistent hero, enter campaign nodes or skirmishes, capture magical resource sites, build a small army, fight enemies and named rival commanders, level up, earn loot with item affixes, claim small rival victory rewards and trophies, spend campaign resources on Stronghold upgrades and Cinderfen preparation services, make compact reputation-shifting choices, face scoped enemy commander pressure in selected Cinderfen battles, and save progress locally.

The latest runtime checkpoint is v0.75-v0.77: Ashen Outpost now serves as the Act 1 finale around Captain Malrec using existing maps, doctrines, elites, tactical plans, battlefield events, Retinue/reinforcement, hero progression, relic rewards, HUD, and Results surfaces.

Current v0.78 work is a docs-only Creative Identity Lock and Original-IP Separation Pass after the clean v0.75-v0.77 Act 1 finale checkpoint. It keeps `Ascendant Realms` as the internal repository codename while proposing `JARDAS: Oath of the Barrosan Marches` as a human-review public-title direction. It defines Jardas, Salto, the Barrosan Marches, Lume, an eight-race master roster draft, future Race + Class + Origin + Oath hero architecture, signature gameplay pillars, a five-act campaign outline, visual governance, browser-to-desktop transition gates, display-name migration safety, original-IP separation, and an Emmanuel review packet. It does not change runtime behavior, save format, internal IDs, gameplay balance, art/assets, maps, races, units, buildings, desktop packaging, engine choice, multiplayer, PvP, or co-op.

The package flow still packages the browser prototype for private human playtesting: playtest-safe production build output, ignored package folders under `artifacts/playtest/`, tester-facing README and feedback files, current retest materials, build metadata, local server launchers, and package verification. v0.78 package metadata includes the creative identity review docs for Emmanuel without changing the playable build.

This is the engine-first foundation, not the full game. Everything is intentionally simple and expandable.

Manual tester quick-start: `docs/V0126_TESTER_QUICK_START.md`.
Automated scenario lab report: `docs/V013_AUTOMATED_PLAYTEST_SCENARIO_LAB_REPORT.md`.
Extended automated lab report: `docs/V0131_EXTENDED_SCENARIO_LAB_REPORT.md`.
Private playtest package guide: `docs/V014_PLAYTEST_PACKAGE_COORDINATOR_GUIDE.md`.
Emmanuel quick playtest fix report: `docs/V0141_QUICK_PLAYTEST_FIX_REPORT.md`.
Emmanuel retest combat/selection fix report: `docs/V0143_COMBAT_SELECTION_RETEST_FIX_REPORT.md`.
v0.14.4 combat control retest fix report: `docs/V0144_COMBAT_CONTROL_RETEST_FIX_REPORT.md`.
v0.15 behaviour mode spec: `docs/V015_BEHAVIOUR_MODES_SPEC.md`.
v0.15 control/combat behaviour fix report: `docs/V015_CONTROL_COMBAT_BEHAVIOUR_FIX_REPORT.md`.
v0.16 control behaviour gauntlet report: `docs/V016_CONTROL_BEHAVIOUR_GAUNTLET_REPORT.md`.
v0.16 Emmanuel control retest script: `docs/V016_EMMANUEL_CONTROL_RETEST_SCRIPT.md`.
v0.18 worker construction foundation spec: `docs/V018_WORKER_CONSTRUCTION_FOUNDATION_SPEC.md`.
v0.18 implementation report: `docs/V018_IMPLEMENTATION_REPORT.md`.
v0.78 Emmanuel creative identity review packet: `docs/V078_EMMANUEL_REVIEW_PACKET.md`.
v0.78 implementation report: `docs/V078_IMPLEMENTATION_REPORT.md`.

Current v0.3 feature snapshot:

- Compact Chapter 2 Cinderfen route after Ashen Outpost: Overlook, optional Waystation, Crossing, Watch, and Aftermath. The current playable v0.3 slice ends at Cinderfen Aftermath; more Cinderfen content is upcoming.
- Named enemy heroes/rival commanders on important Ashen campaign battles, with compact persistent rival state.
- Rival Rewards and Trophies V1 with once-only first-defeat rewards, cosmetic trophy records, and the first tiny persistent relic reward loop.
- Retinue Camp V1 for a small save-backed roster of surviving veteran units.
- Unit Veterancy V1 with Recruit, Seasoned, Veteran, and Elite ranks.
- Stronghold Development Tier II with compact persistent upgrade effects.
- Randomized item affixes V1 on reward-generated item instances.
- Reputation hooks for modest campaign choice consequences and preparation effects.
- CampaignRules split into focused pure-rule modules behind a compatibility facade.
- HUD/fog polish for stable command hover, side-panel scroll preservation, and captured-site local reveal behavior.
- Cinderfen reward-economy audit and Chapter 2 Playwright helper cleanup, with first-clear rewards useful and repeat rewards kept tiny.
- v0.5 save fixture tests, standalone content validation, campaign graph/reward validation, simulator determinism checks, and a first playable no-reward Tutorial / Proving Grounds shell for onboarding work.
- v0.6 tutorial polish, e2e runtime review, test-only semantic command-log V1, tutorial accessibility checks, and desktop/2026 visual-direction planning.
- v0.7 Enemy Strategic Pressure V1: campaign-scoped pressure plans on Cinderfen Crossing and Cinderfen Watch, content validation, warning/telemetry runtime, simulator reporting, and targeted release e2e coverage without workers, enemy construction, new maps, new units, new factions, rewards, save changes, or broad AI economy.
- v0.7.1 Enemy Pressure Feel Review: clearer pressure warnings and defeat tips, longer prioritized pressure status messages, objective feedback priority above pressure, hardened pressure visibility e2e coverage, clearer simulator reporting, no balance tuning, and no promotion of live reinforcements, route contesting, or defensive hold behavior.
- v0.7.2 Human-Paced Cinderfen Pressure Review: seeded browser evidence for Crossing and Watch warning readability, no-change pressure readability decision, Retinue + Training Yard II watchpoint, Greedy/Fast strategy review, and a fresh decision to keep stronger actions warning/telemetry-only.
- v0.7.3 Real-Input Cinderfen Pressure Playtest: controlled browser-input review for Crossing and Watch, manual playtest checklist for Emmanuel, strategy-profile no-change gate, and v0.8 direction brief recommending technical/e2e runtime work before any simulator-only reinforcement experiment.
- v0.8 Technical Performance and Visual Foundation Gate: refreshed bundle/performance facts, e2e runtime/shard audit, additive optional 3-shard release scripts, visual debt audit, visual scale/readability audit, no-code visual readability decision, 2026 art direction bible, asset pipeline plan, Cinderfen visual rework spec, and no gameplay or asset expansion.
- v0.8.1 Visual Asset Manifest and Screenshot QA Gate: initial visual asset inventory, typed visual metadata schema, populated 89-entry manifest covering runtime and manual-source assets, visual metadata validation through `npm run validate:content`, runtime asset usage cross-check, optional non-brittle `npm run visual:qa` screenshot harness, screenshot QA review, Cinderfen visual replacement backlog, and safe future asset prompt/spec templates.
- v0.8.2 Visual Source/License and Screenshot Coverage Gate: source/license review plan and audit, conservative manifest `reviewStatus`/`sourceReviewNotes` metadata, hardened production-safety validation, expanded optional `npm run visual:qa` coverage to 18 indexed screenshots, extended screenshot review, visual risk register, and v0.9 controlled Cinderfen style-frame recommendation.
- v0.9 Controlled Cinderfen Style-Frame Sprint: docs/specs/prompts-only Cinderfen visual definition covering research, visual pillars, terrain materials, Cinder Shrine landmark direction, Ashen outpost architecture, unit/building scale, prompt pack, future manifest templates, screenshot acceptance criteria, and future replacement sequencing. No generated art, imported assets, runtime replacement, gameplay expansion, map changes, or production approval were added.
- v0.9.1 Controlled Cinderfen Style-Frame Intake and Source Review: non-runtime `art-review/` intake folders, source/license metadata templates, review manifest schema, metadata-only `npm run validate:art-intake`, candidate scan, screenshot comparison plan, manual preparation guide for Emmanuel, future v0.9.2 review brief, and controlled intake report. No candidate art, imported assets, runtime replacement, gameplay expansion, map changes, or production approval were added.
- v0.10 Tutorial v2 Onboarding Refinement: clearer Tutorial / Proving Grounds step copy, tighter hints, stronger no-reward/no-save completion messaging, a small overlay hierarchy pass, e2e lane review, visual QA review, and Emmanuel's manual playtest checklist. No rewards, persistence, campaign progression, maps, units, factions, generated art, imported art, runtime art replacement, or full UI redesign were added.
- v0.11 Technical Reliability Gate: refreshed e2e runtime audit, release-lane reliability plan, automated `npm run smoke:preview`, visual QA index summary improvements, bundle/performance refresh, developer command guide, and tightened release checklist. No gameplay, content, save, campaign, tutorial behavior, visual asset, or runtime art changes were added.
- v0.11.1 CI Release Matrix Dry-Run: conservative `.github/workflows/ci.yml` with fast PR/push confidence, manual optional visual QA, manual 3-way release shards, manual simulator/full-release options, preview helper portability improvements, artifact strategy, and CI/local parity documentation. No gameplay, content, save, campaign, tutorial behavior, visual asset, runtime art, or coverage reduction was added.
- v0.11.2 GitHub Actions Remote CI Observation: remote Actions inspection capability and limitation reports, GitHub Actions expected-evidence report, static workflow review, timeout review, preview-helper remote review, artifact review, manual GitHub Actions checklist, no-fix decision, and observation report. No workflow, helper, gameplay, content, save, campaign, tutorial behavior, visual asset, runtime art, or coverage change was added.
- v0.11.5 GitHub Actions Fast Confidence Lane Split: automatic push/PR CI runs `npm run test:e2e:smoke:fast`, now a seven-test `@ci-fast` subset after v0.14.1's hero-name input coverage, while full `npm run test:e2e:smoke` and the release/manual lanes keep all campaign/skirmish smoke coverage. No smoke tests were deleted, skipped, or weakened.
- v0.11.11 Hosted Release Preview Environment: manual GitHub release groups now use `playwright.hosted-release.config.ts` against production preview instead of Vite dev server, with hosted-only Chromium stability args. No release tests were deleted, skipped, or weakened.
- v0.11.12 Hosted Release Interaction Determinism: hosted release tests now use a verified DOM click fallback for real enabled controls, stronger shared battle-loaded waits, retrying tutorial/layout box measurement, scroll-aware side-panel command geometry checks, and safer canvas movement targets. No gameplay or release coverage changed.
- v0.12 Core Game Feel and Battle Readability: accepted commands have a protected read window, selected groups show clearer current orders, objective rows mark the next unfinished action, Cinderfen pressure warnings name counterplay, and results guidance gives clearer retry/next-step advice. No new art, content, save format, broad AI, or release-lane plumbing was added.
- v0.12.1 Human-Paced Core Feel Playtest Review: slow review confirmed the v0.12 readability gains, aligned Cinderfen Crossing / Cinderfen Watch display names, clarified the Cinder Shrine one-time +20 Aether objective, and made skirmish defeat guidance context-safe. No numeric tuning, content expansion, art replacement, save migration, or release coverage reduction was added.

## Design Pillars

The long-term goal is to grow around four pillars:

- Persistent hero fantasy.
- Faction asymmetry.
- Living campaign map.
- Data-driven and mod-friendly content.

Early versions may look rough. The important thing is that the project stays playable, expandable, and easy to change.

## Install

1. Install Node.js if you do not already have it.
2. Open a terminal in this project folder.
3. Run:

```bash
npm install
```

## Run

```bash
npm run dev
```

Then open the local URL shown in the terminal, usually:

```text
http://localhost:5173
```

## Build

```bash
npm run build
```

Latest v0.10 tutorial onboarding checkpoint status, 2026-05-11: build passes. App JS is about 477.04 kB / 127.86 kB gzip, `vendor-phaser` is about 1,481.79 kB / 339.86 kB gzip, and CSS is about 44.51 kB / 9.16 kB gzip. Vite may warn that the Phaser vendor chunk is larger than 500 kB; that warning is known and is not a build failure.

## Test Content And Pure Rules

```bash
npm run validate:content
npm run validate:art-intake
npm run test
```

Run `npm run validate:content` after changing data files or adding future campaign content. It runs the data validator without opening the game UI and fails with a plain list of broken references or duplicate IDs. Then run `npm run test` for the broader pure-rule suite. Together they check the level curve, hero progression rules, building placement rules, save migration fixtures, and whether units, buildings, abilities, skill trees, reward tables, maps, objectives, resources, capture sites, terrain zones, campaign graphs, AI plans, rivals, Stronghold upgrades, and Cinderfen-specific modifiers reference valid IDs.

Run `npm run validate:art-intake` after adding or editing non-runtime Cinderfen style-frame metadata under `art-review/cinderfen-style-frames/metadata/`. It validates source/license and review-gate fields without requiring candidate image files unless a metadata record says the candidate file has been submitted. This is separate from the runtime visual asset manifest and does not approve or wire any art into the game.

Latest v0.10 tutorial onboarding checkpoint status, 2026-05-11: `npm run validate:content` passes, `npm run validate:art-intake` passes with the template-only empty intake, and `npm test` passes with 46 test files and 351 tests. v0.10 refined Tutorial / Proving Grounds copy, hints, overlay hierarchy, completion clarity, lane review docs, visual QA review, and manual playtest guidance without adding rewards, persistence, campaign progression, new content, or art.

Tutorial / Proving Grounds report: `docs/TUTORIAL_PLAYABLE_SHELL_REPORT.md`. v0.6 onboarding/testing report: `docs/V06_TUTORIAL_ONBOARDING_REPORT.md`. v0.10 Tutorial v2 docs: `docs/V10_TUTORIAL_V2_AUDIT.md`, `docs/V10_TUTORIAL_V2_PACING_PLAN.md`, `docs/V10_TUTORIAL_COPY_REFINEMENT_NOTES.md`, `docs/V10_TUTORIAL_OVERLAY_REFINEMENT_NOTES.md`, `docs/V10_TUTORIAL_COMPLETION_CLARITY_NOTES.md`, `docs/V10_TUTORIAL_E2E_LANE_REVIEW.md`, `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`, `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`, and `docs/V10_TUTORIAL_V2_ONBOARDING_REPORT.md`. The current shell launches from the main menu, reuses existing First Claim content, has no rewards, does not persist completion, and returns to the main menu on completion or exit.

Command-log V1 docs: `docs/COMMAND_LOG_V1_TEST_ONLY_PLAN.md` and `docs/COMMAND_LOG_V1_REPORT.md`. The helper is test-only and currently used by one Tutorial / Proving Grounds smoke path. v0.12 game-feel docs: `docs/V012_CORE_GAME_FEEL_AUDIT.md`, `docs/V012_BATTLE_READABILITY_AUDIT.md`, `docs/V012_BALANCE_AND_FEEL_TUNING_NOTES.md`, `docs/V012_VISUAL_READABILITY_NOTES.md`, and `docs/V012_CORE_GAME_FEEL_PASS_REPORT.md`. Enemy Strategic Pressure V1 docs: `docs/V07_ENEMY_STRATEGIC_PRESSURE_SPEC.md`, `docs/V07_ENEMY_STRATEGIC_PRESSURE_REPORT.md`, `docs/V071_ENEMY_PRESSURE_FEEL_REPORT.md`, `docs/V072_PRESSURE_PLAY_REVIEW_REPORT.md`, and `docs/V073_REAL_INPUT_PRESSURE_PLAYTEST_REPORT.md`. Manual Cinderfen pressure playtest checklist: `docs/V073_MANUAL_PRESSURE_PLAYTEST_CHECKLIST.md`. v0.8 technical and visual foundation docs: `docs/V08_PERFORMANCE_AUDIT.md`, `docs/V08_E2E_RUNTIME_SHARD_AUDIT.md`, `docs/V08_E2E_RUNTIME_IMPROVEMENT_PLAN.md`, `docs/V08_VISUAL_DEBT_AUDIT.md`, `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md`, `docs/V08_PROTOTYPE_VISUAL_READABILITY_DECISION.md`, `docs/ART_DIRECTION_2026_BIBLE.md`, `docs/ASSET_PIPELINE_PLAN.md`, `docs/CINDERFEN_VISUAL_REWORK_SPEC.md`, and `docs/V08_TECH_VISUAL_FOUNDATION_REPORT.md`. v0.8.1 visual asset and screenshot QA docs: `docs/V081_EXISTING_ASSET_INVENTORY_AUDIT.md`, `docs/V081_VISUAL_ASSET_MANIFEST_SCHEMA.md`, `docs/V081_INITIAL_VISUAL_ASSET_MANIFEST.md`, `docs/V081_RUNTIME_ASSET_USAGE_CROSSCHECK.md`, `docs/V081_SCREENSHOT_QA_PLAN.md`, `docs/V081_SCREENSHOT_QA_REVIEW.md`, `docs/CINDERFEN_VISUAL_ASSET_REPLACEMENT_BACKLOG.md`, `docs/ASSET_PROMPT_TEMPLATES.md`, and `docs/V081_VISUAL_ASSET_SCREENSHOT_QA_REPORT.md`. v0.8.2 visual source/license and screenshot coverage docs: `docs/V082_ASSET_SOURCE_LICENSE_REVIEW_PLAN.md`, `docs/V082_ASSET_SOURCE_LICENSE_AUDIT.md`, `docs/V082_MANIFEST_METADATA_REFINEMENT.md`, `docs/V082_MANIFEST_VALIDATION_HARDENING.md`, `docs/V082_SCREENSHOT_COVERAGE_EXPANSION_PLAN.md`, `docs/V082_EXTENDED_SCREENSHOT_QA_REVIEW.md`, `docs/VISUAL_RISK_REGISTER.md`, `docs/V09_CONTROLLED_VISUAL_SPRINT_BRIEF.md`, and `docs/V082_SOURCE_LICENSE_SCREENSHOT_COVERAGE_REPORT.md`. v0.9 controlled Cinderfen style-frame docs: `docs/V09_CINDERFEN_STYLE_FRAME_RESEARCH_PACKET.md`, `docs/V09_CINDERFEN_VISUAL_PILLARS.md`, `docs/V09_CINDERFEN_TERRAIN_MATERIAL_SHEET_SPEC.md`, `docs/V09_CINDER_SHRINE_LANDMARK_SPEC.md`, `docs/V09_ASHEN_OUTPOST_ARCHITECTURE_SPEC.md`, `docs/V09_UNIT_BUILDING_SCALE_REFERENCE.md`, `docs/V09_CINDERFEN_STYLE_FRAME_PROMPT_PACK.md`, `docs/V09_FUTURE_CINDERFEN_MANIFEST_TEMPLATES.md`, `docs/V09_CINDERFEN_SCREENSHOT_ACCEPTANCE_CRITERIA.md`, `docs/V09_CINDERFEN_VISUAL_REPLACEMENT_IMPLEMENTATION_PLAN.md`, and `docs/V09_CONTROLLED_CINDERFEN_STYLE_FRAME_REPORT.md`. v0.9.1 intake docs: `docs/V091_STYLE_FRAME_INTAKE_PROTOCOL.md`, `docs/V091_SOURCE_LICENSE_METADATA_GUIDE.md`, `docs/V091_STYLE_FRAME_REVIEW_MANIFEST_SCHEMA.md`, `docs/V091_CURRENT_STYLE_FRAME_CANDIDATE_SCAN.md`, `docs/V091_STYLE_FRAME_SCREENSHOT_COMPARISON_PLAN.md`, `docs/V091_MANUAL_STYLE_FRAME_PREPARATION_GUIDE.md`, `docs/V092_STYLE_FRAME_REVIEW_GOAL_BRIEF.md`, and `docs/V091_CONTROLLED_STYLE_FRAME_INTAKE_REPORT.md`. v0.10 tutorial docs: `docs/V10_TUTORIAL_V2_AUDIT.md`, `docs/V10_TUTORIAL_V2_PACING_PLAN.md`, `docs/V10_TUTORIAL_COPY_REFINEMENT_NOTES.md`, `docs/V10_TUTORIAL_OVERLAY_REFINEMENT_NOTES.md`, `docs/V10_TUTORIAL_COMPLETION_CLARITY_NOTES.md`, `docs/V10_TUTORIAL_E2E_LANE_REVIEW.md`, `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`, `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`, and `docs/V10_TUTORIAL_V2_ONBOARDING_REPORT.md`. v0.11.1 CI docs: `docs/V111_CI_MATRIX_AUDIT.md`, `docs/V111_PREVIEW_HELPER_PORTABILITY_AUDIT.md`, `docs/V111_CI_RELEASE_MATRIX_PLAN.md`, `docs/V111_CI_ARTIFACT_STRATEGY.md`, and `docs/V111_CI_LOCAL_PARITY_CHECK.md`; v0.11.5 CI lane split lives in `docs/V115_FAST_CONFIDENCE_LANE_SPLIT.md`. Desktop future-direction planning lives in `docs/DESKTOP_2026_VISUAL_DIRECTION.md`; no desktop packaging or engine-port code has been added.

v0.12.1 human-paced playtest docs: `docs/V0121_HUMAN_PACED_PLAYTEST_PROTOCOL.md`, `docs/V0121_HUMAN_PACED_PLAYTEST_NOTES.md`, `docs/V0121_PLAYTEST_POLISH_PLAN.md`, `docs/V0121_TUNING_DECISION.md`, `docs/V0121_VISUAL_QA_REVIEW.md`, and `docs/V0121_HUMAN_PACED_PLAYTEST_REPORT.md`.

## Browser E2E Test Lanes

```bash
npm run test:e2e:smoke:fast
npm run test:e2e:smoke
```

The browser suite uses Playwright and starts the Vite dev server automatically. The automatic GitHub fast-confidence lane runs `npm run test:e2e:smoke:fast`, which selects the seven `@ci-fast` smoke checks: main menu boot, hero name input accepting movement-key letters, Tutorial / Proving Grounds no-reward entry, Tutorial exit without saving, Settings persistence and battle pause behavior, New Campaign into Campaign Map with locked-node blocking, and inventory reachability.

The full smoke lane remains `npm run test:e2e:smoke`. It runs all 13 tests in `tests/e2e/smoke.spec.ts`, including the `@ci-fast` checks plus the six `@extended-smoke` campaign/skirmish checks for Border Village, Cinderfen reward persistence, Cinderfen Watch and Aftermath, Malrec trophy event behavior, skirmish launch, and difficulty/fog setup.

For a work-type-to-command matrix, use `docs/DEVELOPER_COMMAND_GUIDE.md`. It explains the fast local gate, tutorial/UI checks, visual-intake validation, visual QA, release shards, preview smoke, bundle analysis, and simulator use.

Additional lanes keep the slower coverage available without making it the default frequent-iteration command:

```bash
npm run test:e2e:layout
npm run test:e2e:deep
npm run test:e2e:release
```

`test:e2e:layout` runs responsive layout and mobile/readability checks from `tests/e2e/layout.spec.ts`, including Tutorial / Proving Grounds overlay reachability across desktop, tablet, and mobile viewports. `test:e2e:deep` runs the release-critical full-flow gameplay checks from `tests/e2e/deep-flow.spec.ts`, including at least one full first-battle campaign path. Enemy Strategic Pressure V1 has targeted release coverage in `tests/e2e/enemy-pressure.spec.ts`, keeping pressure warnings and tutorial/skirmish no-pressure guards out of the smoke lane. `test:e2e:release` runs the full Playwright suite with line reporter; `npm run test:e2e` remains the full suite as well.

The e2e suite runs with one worker for stability because live Phaser scenes, video capture, and the Vite dev server can time out when several full game flows run at once on a local machine. The full release gate is intentionally slower than the smoke lane; after the v0.16 control gauntlet, `npm run test:e2e:release` covers 76 tests while the smoke lane covers 13 tests.

Tutorial e2e placement reviews: `docs/TUTORIAL_E2E_RUNTIME_REVIEW.md` and `docs/V10_TUTORIAL_E2E_LANE_REVIEW.md`. The v0.10 review keeps full Tutorial / Proving Grounds completion in smoke because the lane remains inside the 6-7 minute watch band and the test protects no-save/no-XP/no-reward behavior. Move completion deeper only if smoke repeatedly grows beyond the watch band.

For CI, the full release gate can also be split into two Playwright shards:

```bash
npm run test:e2e:release:shard1
npm run test:e2e:release:shard2
```

Both shards together equal the full `test:e2e:release` suite; neither removes coverage. These scripts are mainly for CI matrix jobs. Running both sequentially on a local machine usually has similar total runtime to the full release gate and produces split logs, so local developers can keep using `test:e2e:smoke` for frequent checks and `test:e2e:release` for one-piece release verification.

v0.8 also adds additive 3-shard release scripts for CI runs where the old 2-shard split is too lopsided:

```bash
npm run test:e2e:release:shard1of3
npm run test:e2e:release:shard2of3
npm run test:e2e:release:shard3of3
```

All three 3-shard scripts together equal the same full release suite. They preserve the existing full release and 2-shard scripts; they do not change Playwright workers, parallelism, serving mode, or test coverage.

v0.11.12 keeps the explicit hosted release groups on the v0.11.11 production-preview config and adds interaction-determinism hardening for hosted DOM buttons, battle-loaded waits, tutorial/layout box readiness, side-panel measurement, and right-click movement:

```bash
npm run test:e2e:release:hosted:deep-meta
npm run test:e2e:release:hosted:deep-battle
npm run test:e2e:release:hosted:deep-campaign-pressure
npm run test:e2e:release:hosted:layout-core
npm run test:e2e:release:hosted:layout-cinderfen
npm run test:e2e:release:hosted:smoke
```

All six hosted group scripts together cover the same full release suite, currently 76 tests. They avoid `--fully-parallel` test-level sharding, keep the hosted matrix manual-only, and group related deep-flow, layout, pressure, and smoke coverage for GitHub-hosted runners. Local full release, local 2-way shards, and local 3-way shards remain unchanged. The hosted helpers preserve behavior assertions and still forbid DOM fallback for canvas/world clicks.

Run `npm run build` before running the hosted group scripts locally. In GitHub Actions, the hosted release jobs already build before starting the production preview server.

Latest v0.10 final verification: smoke passed 12 tests in about 4.9 minutes; full release passed 67 tests in about 29.0 minutes; the existing 2-shard scripts passed 55 tests in about 24.3 minutes and 12 tests in about 4.8 minutes; `shard1of3` passed 28 tests in about 11.5 minutes; `shard2of3` passed 27 tests in about 12.9 minutes; `shard3of3` passed 12 tests in about 4.9 minutes. The split is intentionally optional; CI parallelism is the main benefit.

v0.11.1 adds `.github/workflows/ci.yml` as a conservative GitHub Actions dry run. v0.11.5 keeps that workflow but changes automatic fast confidence on pull requests and pushes to `main` to run `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run test:e2e:smoke:fast`, and `npm run smoke:preview` after `npm ci` and Playwright Chromium installation. v0.11.12 keeps heavy lanes manual and runs the release-matrix workflow input as explicit hosted release groups against production preview plus simulator; optional visual QA and the full one-command release lane remain manual inputs. Heavy lanes remain manual so the local final gate stays authoritative and CI does not duplicate every expensive run on every push. v0.11.2 could not fetch remote Actions evidence from this environment because authenticated access was unavailable; use `docs/V112_MANUAL_GITHUB_ACTIONS_CHECKLIST.md` to inspect the workflow in GitHub UI and report hosted-run timing/artifacts before making CI-only tuning changes.

For a visible browser run:

```bash
npm run test:e2e:headed
```

## Visual Screenshot QA

```bash
npm run visual:qa
```

This optional v0.8.2 lane captures review screenshots into `visual-qa/latest/`, including main menu, Asset Gallery, Hero Inventory, Tutorial / Proving Grounds desktop/mobile, campaign map, route-complete campaign map, Skirmish Setup, Cinderfen Crossing desktop/tablet, Cinder Shrine capture, Crossing pressure warning, Cinderfen Watch, Watch pressure warning, and victory/defeat Results views. The folder is ignored by git on purpose. The screenshots are human review artifacts, not pixel-perfect visual regression baselines.

The visual QA policy and first review live in `docs/V081_SCREENSHOT_QA_PLAN.md` and `docs/V081_SCREENSHOT_QA_REVIEW.md`; the expanded coverage plan and review live in `docs/V082_SCREENSHOT_COVERAGE_EXPANSION_PLAN.md` and `docs/V082_EXTENDED_SCREENSHOT_QA_REVIEW.md`; future Cinderfen visual acceptance criteria live in `docs/V09_CINDERFEN_SCREENSHOT_ACCEPTANCE_CRITERIA.md`; the v0.10 tutorial visual QA review lives in `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`. Future asset replacements should update `src/game/assets/visualAssetManifest.ts`, pass `npm run validate:content`, run `npm run visual:qa`, and compare before/after screenshots before committing binaries. Do not use pixel-perfect screenshot diffing as the approval mechanism yet.

## Playtest Simulation

```bash
npm run playtest:sim
```

This runs the deterministic campaign battle simulator and regenerates `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json`.

For the v0.13 automated scenario lab:

```bash
npm run playtest:lab
npm run playtest:watchpoints
npm run playtest:profiles
npm run playtest:lab:extended
npm run playtest:watchpoints:extended
npm run playtest:profiles:compare
npm run playtest:lab:verify
```

`playtest:lab` regenerates `PLAYTEST_SCENARIO_LAB.md`, `PLAYTEST_SCENARIO_LAB.json`, and `PLAYTEST_WATCHPOINT_SUMMARY.md`. `playtest:profiles` regenerates `PLAYTEST_SCENARIO_PROFILES.md` and `PLAYTEST_SCENARIO_PROFILES.json`. `playtest:lab:extended`, `playtest:watchpoints:extended`, and `playtest:profiles:compare` generate separate v0.13.1 extended outputs including `PLAYTEST_SCENARIO_LAB_EXTENDED.md`, `PLAYTEST_SCENARIO_LAB_EXTENDED.json`, `PLAYTEST_PROFILE_COMPARISON.md`, `PLAYTEST_PROFILE_COMPARISON.csv`, `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.md`, `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.json`, and `PLAYTEST_WATCHPOINTS_EXTENDED.md`. `playtest:lab:verify` checks those generated outputs for JSON/Markdown/CSV consistency without treating them as human feedback. These are automated deterministic evidence only; they do not include or replace human tester feedback.

For the v0.16 control behaviour lab:

```bash
npm run playtest:controls
npm run playtest:controls:extended
npm run playtest:controls:verify
```

`playtest:controls` regenerates `PLAYTEST_CONTROL_BEHAVIOUR_LAB.md`, `PLAYTEST_CONTROL_BEHAVIOUR_LAB.json`, `PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.md`, and `PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.json`. `playtest:controls:extended` repeats the deterministic scenarios and writes `PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.md` plus `.json`. `playtest:controls:verify` checks IDs, allowed verdicts, metrics, iteration counts, dashboard/Markdown consistency, and the absence of invented human-feedback claims. These outputs are deterministic automated evidence, not human fun, balance, or usability proof.

## Preview A Build

```bash
npm run preview
```

For automated production preview smoke after `npm run build`, use:

```bash
npm run smoke:preview
```

Latest v0.11.1 production preview smoke, 2026-05-11: `npm run smoke:preview` passed at `http://127.0.0.1:4173/`; title, `Prototype v0.3` / `Cinderfen Route Baseline` menu copy, Tutorial launch/exit, New Campaign to Campaign Map, Continue Campaign to Campaign Map, Skirmish Setup, zero browser console errors, and helper-owned process-tree shutdown were verified. The helper supports validated host/port/timeout environment overrides for CI but should use defaults for normal release evidence.

## Private Playtest Build

To create a private package for a tester:

```bash
npm run package:playtest
npm run verify:playtest-package
```

This writes an ignored package folder under `artifacts/playtest/ascendant-realms-private-playtest-<commit>/`. The package includes the built game under `game/`, a tester README, build metadata, route assignment notes, the feedback form, v0.16 control retest materials, and small local server launchers. Send the folder or a manual zip of the folder; do not send the full repo, `node_modules`, raw private feedback, or secret files.

Use `docs/V014_PLAYTEST_PACKAGE_COORDINATOR_GUIDE.md` for the coordinator flow and `docs/V014_READY_TO_SEND_PRIVATE_PLAYTEST_MESSAGE.md` for a paste-ready tester message.

## Manual Asset Workflow (No API Costs)

This project does not use paid image APIs. You can generate images manually in ChatGPT, download them, and place them in `public/assets/manual`.

1. Run `npm run assets:prompts`.
2. Open `public/assets/manual/ASSET_PROMPT_BOOK.md`.
3. Copy one prompt into ChatGPT image generation.
4. Download the image.
5. Save it in the folder listed in the prompt book.
6. The exact snake_case filename is best, such as `warlord_hero_portrait.png`.
7. Human-readable names such as `Warlord Hero Portrait.png` also work.
8. Run `npm run assets:manifest` to let the project find the image.
9. Run `npm run assets:validate` to check for missing or broken paths.
10. Update `src/game/assets/visualAssetManifest.ts` with source/license/status/scale metadata before treating the asset as part of the current reviewed set.
11. Run `npm run validate:content`; the CLI now validates visual asset metadata and runtime file paths in addition to gameplay content.
12. Or run `npm run assets:refresh` to process battle sprites, rebuild the runtime manifest, and validate the manual asset pipeline before the content gate.
13. Run or refresh the game.

Asset priority is `final`, then `manual`, then `placeholders`, then built-in runtime fallbacks. Missing art is okay; the game should keep running. The visual metadata manifest is stricter: runtime entries need valid metadata, non-empty `usedBy`, safe status/license flags, and existing file paths when checked by the CLI.

Use the `Asset Gallery` button on the main menu to confirm which images the game can see. Each card says `Image loaded` when the browser has actually loaded that file.

If the terminal is open in the outer `WB game like` folder instead of the `ascendant-realms` folder, the same `npm run ...` commands now work there too.

## Dedicated UI Art Kit

The game now has a dedicated optional UI-kit lane for reusable interface art. These are not backgrounds. They are frames, slots, dividers, and button states that the CSS uses carefully through scalable frame rules.

Generate these from the prompt book when you want the HUD and menus to feel more like a polished game:

- `ui_panel_frame.png`
- `ui_button_idle.png`
- `ui_button_hover.png`
- `ui_button_pressed.png`
- `ui_resource_frame.png`
- `ui_divider_ornament.png`
- `ui_tooltip_frame.png`
- `ui_minimap_frame.png`
- `ui_ability_slot_frame.png`
- `ui_inventory_slot_frame.png`
- `ui_victory_panel_frame.png`
- `ui_defeat_panel_frame.png`

Put them in `public/assets/manual/ui`, then run `npm run assets:refresh` and refresh the browser. Missing UI-kit files are safe; the game uses the current CSS fallback.

See `UI_ART_KIT.md` for the full filename list and rules for good frame art.

For in-battle unit, hero, and building sprites, see `BATTLE_ASSET_PROMPTS.md`. The battle renderer now uses dedicated battle sprite files when they exist, falls back to concept art or portraits where possible, and finally falls back to simple Phaser shapes.

To create a free starter set without any image API, run:

```bash
npm run assets:ui-kit
npm run assets:refresh
```

This writes original procedural PNG frames into `public/assets/manual/ui`. They are meant as prototype UI art and can be replaced later with polished manual or final art.

## Reset Save

Use the `Reset Save` button on the main menu. You can also clear the browser's local storage for this site.

## Save Data

The game stores one local save under the browser localStorage key defined in `src/game/core/Constants.ts`. Current saves write `version: 2` and include `createdAt`, `updatedAt`, `hero`, `campaign`, `settings`, and a placeholder `statistics` object.

Settings currently include master/music/SFX volume, screen shake enabled, floating text enabled, fog override, reduced motion, UI scale, and a colorblind-friendly minimap palette. Saving settings before creating a hero creates a settings-only save marker; starting a campaign or skirmish later keeps those settings and replaces the placeholder hero data.

Older `version: 1` saves are migrated in memory when loaded. Invalid JSON or invalid save shapes are rejected safely and do not clear or overwrite the existing localStorage value. New writes always use the current version 2 shape.

## Campaign

Use `New Campaign` from the main menu to create or reuse a hero and open the Border Marches campaign map. Select an available node, read its details, then start the battle or choose an event outcome. Victories complete battle nodes, claim node rewards once, add node resource rewards to the persistent campaign bank, save progress, and unlock connected nodes. Defeats can be retried or returned to the campaign map.

The first skeleton campaign has eight nodes:

- Border Village.
- Old Stone Road.
- Marcher Camp.
- Aether Well Ruins.
- Bandit Hillfort.
- Chapel of the Marches.
- Refugee Caravan.
- Ashen Outpost.

After Ashen Outpost, the current v0.3 baseline adds the compact Cinderfen route:

- Cinderfen Overlook.
- Cinderfen Waystation.
- Cinderfen Crossing.
- Cinderfen Watch.
- Cinderfen Aftermath.

Cinderfen Aftermath is the end of the current playable v0.3 Chapter 2 slice. Completing it should leave the campaign map in a clear route-secured state; any later Cinderfen nodes should remain upcoming/locked until their maps and content exist.

Chapel of the Marches and Refugee Caravan use simple data-driven choices. Marcher Camp is the first town sink: it stays available after Old Stone Road and lets you spend campaign Crowns on rest, volunteers, supplies, and a small fixed item stock. The Campaign Map also includes the Stronghold panel, where two tiers of persistent upgrades spend Crowns, Stone, Iron, and Aether and apply to later battle launches. Choices can be locked by resource costs, hero level, ownership, previous purchase, or faction reputation; pay from the campaign resource bank; grant XP/items/resources; change faction reputation; unlock nodes; and save once-only claims. Reputation ranks and active effects are visible before the player commits.

Skirmish mode remains separate through the `Skirmish` button.

## Post-Battle Rewards

After victory, the Results screen summarizes the map, difficulty, battle time, XP gained, level progress before and after, level-ups, skill points gained, battle rewards, campaign node rewards when applicable, and eligible rival relic rewards. Earned equipment creates an inventory instance immediately. Equippable rewards show rarity, slot, stat modifiers, source details, the currently equipped item in that slot, and an Equip Now comparison.

Using Equip Now equips the earned item instance, saves the updated hero equipment, and recalculates stats, including valid affix stat modifiers. Leaving the screen without equipping keeps the instance in inventory. Campaign node item rewards are claimed once. If a unique reward is already owned, the reward converts into campaign Crowns or Aether and the Results screen shows the conversion.

Campaign resource awards are added to a persistent campaign bank with Crowns, Stone, Iron, and Aether. That bank is separate from temporary battle resources. Marcher Camp and Stronghold Development spend from it now; later shops, mercenaries, repairs, and broader upgrades should use the same bank.

Rival relic rewards use the existing hero inventory and `equipment.relic` slot. Relic effects are active only when equipped, and Tutorial / Proving Grounds remains no-save and no-reward.

## Controls

- Left click: select a friendly unit or building.
- Drag with left mouse: box-select friendly units.
- Left click a hovered enemy while player units are selected: attack that enemy.
- Right click ground: move selected units.
- Right click ground with a completed Barracks or Mystic Lodge selected: set its rally point.
- Right click enemy: attack selected enemy.
- `Shift+A`, then right click: attack-move selected units.
- Selected unit panel: use `Hold`, `Guard`, and `Press` to change session-only unit behaviour mode.
- `H`: select hero.
- `1`, `2`, `3`: use unlocked hero abilities.
- `Space`: center camera on hero.
- Click minimap: center camera on that map location.
- `F`: debug-toggle fog of war on difficulties where fog is enabled.
- `Esc`: clear selection or cancel building placement.
- `WASD` or arrow keys: pan camera.

## Current Features

- Main menu, hero creation, campaign map, skirmish setup, reset save, credits/info.
- Settings screen for audio, reduced motion, floating text, UI scale, fog override, colorblind minimap colors, and keyboard controls.
- Lightweight generated WebAudio cues for UI clicks, selection, build start/complete, unit trained, ability cast, victory, and defeat. Audio fails silently when the browser or test environment blocks it.
- Eight-node Chapter 1 campaign skeleton plus the compact Chapter 2 Cinderfen route with locked, available, completed, town-service, choice-driven node states, and route-complete copy after Cinderfen Aftermath.
- Persistent campaign resource bank for node rewards, event choice costs, Marcher Camp services, and Stronghold upgrades.
- Stronghold Development panel with five Tier I upgrades and five matching Tier II upgrades, prerequisite locks, campaign-resource costs, and battle-launch effects.
- Reputation ranks for Free Marches, Common Folk, Old Faith, Ashen Covenant, and Sylvan Concord placeholder, with small active effects for Marcher Camp discounts, Stronghold Crown discounts, Chapel Aether bonuses, and Ashen hostile pressure.
- Hero inventory screen from the main menu.
- Asset gallery for checking manual/final/placeholder art.
- Three hero classes: Warlord, Arcanist, Shepherd.
- Three origins with small stat modifiers.
- Three skill trees: Combat, Magic, Leadership.
- Three data-defined abilities per class.
- Skill point allocation after level-up.
- Rarity-weighted item rewards after victory.
- Randomized item affixes V1 with slot-filtered stat packages, deterministic test generation, save persistence, equipment stat contribution, and Results/Inventory display.
- Equipment slots: weapon, armor, trinket, and the first one-slot relic loadout.
- Five playable skirmish/campaign battle maps: First Claim, Broken Ford, Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch.
- Player base, enemy base, neutral camps, and capturable resource sites.
- Four resources: Crowns, Stone, Iron, Aether.
- Building placement for Barracks, Mystic Lodge, and Watchtower with valid/invalid previews.
- Automatic construction with under-construction visuals and disabled production until complete.
- Unit training queues from Barracks and Mystic Lodge, with visible progress and cancel/refund.
- Rally points for completed production buildings, with world markers and selected-building minimap markers.
- Data-driven tech prerequisites and basic upgrades.
- Live RTS minimap with units, buildings, capture sites, camera viewport, click-to-pan, and alert pings.
- Lightweight grid fog of war with unseen, explored, and visible states. Enemy and neutral units/buildings are hidden outside current vision.
- Simple RTS selection, movement, combat, projectiles, XP, level-up, and ability use.
- Unit Veterancy V1 with battle-local unit XP, Recruit/Seasoned/Veteran/Elite ranks, selected-unit rank display, rank-up feedback, and Notable Veterans in victory Results.
- Retinue Camp V1 with a small save-backed campaign roster, Results recruitment for eligible veterans, Campaign Map display/dismiss, campaign battle deployment, and permanent removal when a retinue unit dies.
- Enemy Hero / Rival Commander V1 with Gorak Emberhand, Veyra of the Cinders, and Captain Malrec assigned to important campaign battles, plus scout feedback, minimap markers, modest abilities, XP/objective/results credit, and playtest telemetry.
- Rival/Nemesis Persistence V1 with save-backed rival encounters, defeats, victories against the player, last outcomes, dispositions, small repeat-encounter modifiers, Campaign Map intel, Results consequences, and simulator telemetry.
- Rival Rewards and Trophies V1 with data-driven first-defeat rewards, duplicate prevention, persistent trophy records, Campaign Map trophy display, Results reward copy, and simulator telemetry.
- Persistent relic rewards for the three current rival champions, with unique relic inventory entries, equipped-only stat effects, duplicate conversion, Results equip action, Hero Inventory loadout support, and Tutorial no-reward protection.
- Simple enemy AI that expands, trains, defends, sends attack waves, and uses selectable/campaign-assigned personalities.
- Shared victory/defeat Results screen with XP summary, item rewards, Equip Now, campaign node completion details, retry/return flow, and local hero save.
- Pure `BattleRuntime` tests for setup, objectives, battle results, rewards, and save-output decisions.
- `BattleLaunchRequest` contract so skirmish, campaign nodes, and future scenario missions can all start battles through one clean pathway.
- Clean procedural UI skin for menus, result panels, HUD panels, and info boxes.
- Optional dedicated UI-kit assets for panel frames, button states, resource frames, dividers, tooltip frames, minimap frame, ability slot frame, inventory slot frame, victory panel, and defeat panel.
- Automated playtest simulator coverage for no-upgrade, Tier I Stronghold, Tier II Quartermaster, Retinue/Training Yard II, and Chapter 2 Cinderfen campaign paths.

## Known Limitations

- Gameplay units and buildings use dedicated battle sprites when available, then fall back to concept art or simple Phaser shapes if art is missing.
- Movement uses a coarse A* pathfinding grid plus local separation. It is not formation-aware or flow-field based yet.
- Fog of war is grid-based and does not do line-of-sight around blockers yet. Story difficulty disables it; other difficulties can tune it through `fogOfWarEnabled`.
- Workers, broad vendors, full diplomacy, and enemy construction are postponed.
- Retinue Camp V1, Enemy Hero / Rival Commander V1, Rival/Nemesis Persistence V1, and Rival Rewards and Trophies V1 are intentionally small: no replacement UI, wounded timers, deep nemesis branches, unit biographies, scars/titles, full trophy room, crafting, durability, broad loot complexity, broad army management, enemy construction, or raid-boss layer yet.
- Campaign is a skeleton only: Marcher Camp, Stronghold Development, Cinderfen Waystation, Cinderfen Aftermath, and reputation effects prove small resource sinks and consequences, but there is no full diplomacy, procedural random event system, invasion layer, or world simulation yet.
- Skill choices do not support respec yet.
- AI personalities change timing and composition, but AI is still intentionally simple and predictable compared with a full scouting/counter-build system.
- Balance is prototype-only and expected to change often.
- Some engine classes still combine simulation data with Phaser visuals. That is acceptable for this slice, but should be split before multiplayer or replay work.
- `BattleScene` is partly split into helper modules for spawning, map rendering, alerts, snapshots, objectives, and results. It still owns live Phaser orchestration and input, and live entity state is not fully serializable yet.
- The UI-kit assets are optional runtime presentation assets. The game falls back to CSS styling when they are not present, and the v0.8.1 visual manifest tracks their current metadata/status separately from production readiness.

## How To Ask Codex For The Next Feature

Good next prompts are specific and small. Examples:

- "Verify the v0.3 Cinderfen route end to end and polish readability without adding gameplay or changing balance."
- "Human-review Border Village through Ashen Outpost with no retinue, one Veteran Militia, one Veteran Ranger, and mixed retinue."
- "Tune Retinue Camp V1 if saved veterans trivialize early nodes or feel mandatory for Ashen Outpost."
- "Human-review Stronghold Tier II, reputation effects, retinue, rival commanders, and affixed reward readability in the current campaign."
- "Review Rival/Nemesis Persistence V1 balance and readability without adding enemy construction or new factions."
- "Review Rival Rewards and Trophies V1 balance and readability without adding crafting, durability, or a full trophy room."
- "Split ResultsScene into smaller reward, campaign-return, and item-comparison helpers."
- "Split maps.ts into one file per map without changing map behavior."
- "Improve formation movement and dynamic path blockers without changing combat balance."
- "Add a respec button to the hero progression screen."
- "Human-play Tutorial / Proving Grounds and do small copy/layout polish without adding rewards, new content, or save persistence."

## Troubleshooting

- If `npm install` fails, check that Node.js is installed and restart the terminal.
- If the browser page is blank, run `npm run build` and look for TypeScript errors.
- If the game feels stuck after edits, stop the dev server with `Ctrl+C`, run `npm install`, and start it again.
- If `Continue Campaign` is disabled, start a new campaign first.
- If `Hero Inventory` is disabled, create a hero first.
