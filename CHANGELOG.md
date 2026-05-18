# Changelog

## v0.13 Automated Playtest Scenario Lab And Balance Telemetry V1 - 2026-05-18

This checkpoint adds an automated scenario-lab and watchpoint-classifier layer on top of the existing deterministic playtest simulator. It preserves the v0.11.12/v0.12/v0.12.1/v0.12.2/v0.12.3/v0.12.4/v0.12.5/v0.12.6 green release foundation, hosted release group structure, save compatibility, tutorial no-save/no-reward behavior, existing art, maps, factions, units, rewards, enemy pressure scope, combat systems, campaign progression, and gameplay numbers.

### Included

- Scenario-lab profiles, metrics, classifier, report writer, and runner under `src/game/playtest/`.
- New commands: `npm run playtest:lab`, `npm run playtest:watchpoints`, and `npm run playtest:profiles`.
- Generated automated evidence outputs: `PLAYTEST_SCENARIO_LAB.md`, `PLAYTEST_SCENARIO_LAB.json`, `PLAYTEST_WATCHPOINT_SUMMARY.md`, `PLAYTEST_SCENARIO_PROFILES.md`, and `PLAYTEST_SCENARIO_PROFILES.json`.
- v0.13 docs for architecture audit, scenario profile spec, telemetry metrics, classifier rules, automated evidence decision, and final scenario-lab report.
- Focused tests for profile metadata, classifier conservatism, report sections, JSON shape, and no human-feedback claims.

### Verdict

- Runtime code changed only in simulator/reporting tooling.
- Gameplay numbers changed: no.
- Human feedback used: no.
- Automated decision: no runtime tuning. Retinue + Training Yard II needs human testing, Greedy Economy remains a monitor item for conversion/time risk, Fast Army remains a monitor item for Cinderfen speed, early defeats are no-change structurally, and pressure fairness still needs human noticeability testing.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.

### Next

- GitHub Actions rerun is optional because no runtime gameplay/HUD/campaign/pressure/result/tuning behavior changed.
- Next recommended long goal: real human playtest execution using v0.12.6 tester packet, followed by feedback intake only after completed forms exist.

## v0.12.6 Playtest Distribution Readiness And Tester Onboarding - 2026-05-18

This checkpoint adds the distribution and onboarding layer needed to hand the current v0.12.x browser prototype to real human testers. It preserves the v0.11.12/v0.12/v0.12.1/v0.12.2/v0.12.3/v0.12.4/v0.12.5 green release foundation, hosted release group structure, save compatibility, tutorial no-save/no-reward behavior, existing art, maps, factions, units, rewards, enemy pressure scope, combat systems, campaign progression, and gameplay numbers.

### Included

- Tester quick-start: `docs/V0126_TESTER_QUICK_START.md`.
- Emmanuel/coordinator guide: `docs/V0126_PLAYTEST_COORDINATOR_GUIDE.md`.
- Route assignment plan: `docs/V0126_ROUTE_ASSIGNMENT_PLAN.md`.
- Copy-paste feedback submission packet: `docs/V0126_FEEDBACK_SUBMISSION_PACKET.md`.
- Feedback storage plan: `docs/V0126_FEEDBACK_STORAGE_PLAN.md`.
- Ready-to-send tester message: `docs/V0126_READY_TO_SEND_TESTER_MESSAGE.md`.
- Updated the v0.12.4 packet index and v0.12.5 intake hub so testers, coordinator workflow, and later triage are connected.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.

### Next

- GitHub Actions rerun is optional because v0.12.6 is docs-only.
- Next recommended long goal: v0.12.7 Real Human Playtest Feedback Review And Small-Polish Decision, only after real completed tester forms exist.

## v0.12.5 Manual Human Playtest Feedback Intake And Evidence Triage - 2026-05-18

This checkpoint adds the evidence-intake layer for completed v0.12.4 manual playtest packets. It preserves the v0.11.12/v0.12/v0.12.1/v0.12.2/v0.12.3/v0.12.4 green release foundation, hosted release group structure, save compatibility, tutorial no-save/no-reward behavior, existing art, maps, factions, units, rewards, enemy pressure scope, combat systems, campaign progression, and gameplay numbers.

### Included

- Feedback intake hub: `docs/V0125_PLAYTEST_FEEDBACK_INTAKE_HUB.md`.
- Evidence classification guide: `docs/V0125_EVIDENCE_CLASSIFICATION_GUIDE.md`.
- Watchpoint aggregation sheet: `docs/V0125_WATCHPOINT_AGGREGATION_SHEET.md`.
- Triage decision tree: `docs/V0125_TRIAGE_DECISION_TREE.md`.
- Severity/priority rubric: `docs/V0125_SEVERITY_PRIORITY_RUBRIC.md`.
- Feedback-to-action matrix: `docs/V0125_FEEDBACK_TO_ACTION_MATRIX.md`.
- Issue-ready templates: `docs/V0125_ISSUE_READY_TEMPLATES.md`.
- Fictional sample feedback triage: `docs/V0125_SAMPLE_FEEDBACK_TRIAGE.md`.
- Updated the v0.12.4 packet index to point from filled tester forms into the v0.12.5 intake workflow.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.

### Next

- GitHub Actions rerun is optional because v0.12.5 is docs-only.
- Next recommended long goal: v0.12.6 Manual Playtest Feedback Review And Small-Polish Decision.

## v0.12.4 Manual Human Playtest Packet And Tester Checklist - 2026-05-18

This checkpoint packages the v0.12.x human balance watchpoints into practical tester-facing documentation. It preserves the v0.11.12/v0.12/v0.12.1/v0.12.2/v0.12.3 green release foundation, hosted release group structure, save compatibility, tutorial no-save/no-reward behavior, existing art, maps, factions, units, rewards, enemy pressure scope, and gameplay mechanics.

### Included

- Main manual playtest packet: `docs/V0124_MANUAL_HUMAN_PLAYTEST_PACKET.md`.
- Route cards: `docs/V0124_PLAYTEST_ROUTE_CARDS.md`.
- Mission checklists: `docs/V0124_MISSION_CHECKLISTS.md`.
- Watchpoint rating sheet: `docs/V0124_WATCHPOINT_RATING_SHEET.md`.
- Bug/friction report template: `docs/V0124_BUG_AND_FRICTION_REPORT_TEMPLATE.md`.
- Playtest summary form: `docs/V0124_PLAYTEST_SUMMARY_FORM.md`.
- Designer interpretation guide: `docs/V0124_DESIGNER_INTERPRETATION_GUIDE.md`.
- Playtest packet index: `docs/V0124_PLAYTEST_PACKET_INDEX.md`.
- Tester-facing guidance for what to judge now versus what belongs to the future visual overhaul.
- Interpretation rules to prevent one-off complaints from becoming premature tuning.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.

### Next

- GitHub Actions rerun is optional because v0.12.4 is docs-only.
- Next recommended long goal: v0.12.5 Manual Human Playtest Feedback Intake And Evidence Triage.

## v0.12.3 Human Campaign Balance Play Session - 2026-05-17

This checkpoint gathers direct human-style campaign balance evidence after v0.12.2 without changing runtime behavior. It preserves the v0.11.12/v0.12/v0.12.1/v0.12.2 green release foundation, hosted release group structure, save compatibility, tutorial no-save/no-reward behavior, existing art, maps, factions, units, rewards, enemy pressure scope, and gameplay mechanics.

### Included

- Human campaign play-session protocol: `docs/V0123_HUMAN_CAMPAIGN_PLAY_SESSION_PROTOCOL.md`.
- Human-style campaign notes: `docs/V0123_HUMAN_CAMPAIGN_PLAY_SESSION_NOTES.md`.
- Compact evidence table: `docs/V0123_CAMPAIGN_BALANCE_EVIDENCE_TABLE.md`.
- No-change decision: `docs/V0123_BALANCE_PLAY_SESSION_DECISION.md`.
- Final report: `docs/V0123_HUMAN_CAMPAIGN_BALANCE_PLAY_SESSION_REPORT.md`.
- Direct visible browser evidence from main menu through New Campaign, Campaign Map, Border Village guidance, and battle HUD launch.
- Route evidence for baseline, no-retinue, one-veteran, mixed-veterans, Retinue + Training Yard II, Greedy Economy, and Fast Army.

### Verification

- Final verification is recorded in `docs/V0123_HUMAN_CAMPAIGN_BALANCE_PLAY_SESSION_REPORT.md`.

### Next

- GitHub Actions rerun is optional because v0.12.3 is docs-only, but a manual release-matrix rerun after push is a clean remote parity check.
- Next recommended long goal: v0.12.4 Manual Human Playtest Packet And Tester Checklist.

## v0.12.2 Human Balance Watchpoint Review - 2026-05-17

This checkpoint reviews the v0.12/v0.12.1 balance watchpoints without changing runtime behavior. It preserves the v0.11.12/v0.12/v0.12.1 green release foundation, hosted release group structure, save compatibility, tutorial no-save/no-reward behavior, existing art, maps, factions, units, rewards, enemy pressure scope, and gameplay mechanics.

### Included

- Balance watchpoint protocol: `docs/V0122_BALANCE_WATCHPOINT_PROTOCOL.md`.
- Simulator balance review: `docs/V0122_SIMULATOR_BALANCE_REVIEW.md`.
- Human-style balance notes: `docs/V0122_HUMAN_BALANCE_NOTES.md`.
- No-tuning decision: `docs/V0122_TUNING_DECISION.md`.
- Final watchpoint report: `docs/V0122_HUMAN_BALANCE_WATCHPOINT_REPORT.md`.
- Retinue + Training Yard II was confirmed as the strongest watchpoint, especially in Ashen/Cinderfen, but not a current numeric nerf target.
- Greedy Economy failures were classified as risky conversion/timeouts rather than unfair early pressure or raw economy shortage.
- Fast Army was classified as a legitimate speed profile, not a free dominant route.
- Early campaign defeat evidence did not show a structural balance problem.
- Cinderfen pressure warnings remain fair and actionable in current structural evidence.

### Verification

- Final verification is recorded in `docs/V0122_HUMAN_BALANCE_WATCHPOINT_REPORT.md`.

### Next

- GitHub Actions rerun is optional because v0.12.2 is docs-only, but a manual release-matrix rerun after push is a clean remote parity check.
- Next recommended long goal: v0.12.3 Human Campaign Balance Play Session, focused on direct human runs through Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch across retinue/Training Yard profiles.

## v0.12.1 Human-Paced Core Feel Playtest Review - 2026-05-17

This checkpoint validates the v0.12 readability pass through slow, human-paced play review and applies only tiny evidence-backed polish. It preserves the v0.11.12/v0.12 green release foundation, hosted release group structure, save compatibility, tutorial no-save/no-reward behavior, existing art, maps, factions, units, rewards, and gameplay mechanics.

### Included

- Human-paced playtest protocol: `docs/V0121_HUMAN_PACED_PLAYTEST_PROTOCOL.md`.
- Human-paced playtest notes: `docs/V0121_HUMAN_PACED_PLAYTEST_NOTES.md`.
- Tiny polish plan: `docs/V0121_PLAYTEST_POLISH_PLAN.md`.
- No-tuning decision: `docs/V0121_TUNING_DECISION.md`.
- Visual QA review: `docs/V0121_VISUAL_QA_REVIEW.md`.
- Final report: `docs/V0121_HUMAN_PACED_PLAYTEST_REPORT.md`.
- Aligned player-facing Cinderfen battle names to `Cinderfen Crossing` and `Cinderfen Watch` while keeping ids, files, routes, saves, and mechanics unchanged.
- Reworded the Cinder Shrine objective so the small tracker calls out the one-time +20 Aether surge and hold instruction more plainly.
- Made defeat guidance context-aware so skirmish defeats no longer suggest campaign-only camp/Chapel support.
- Updated focused tests for the changed copy and preserved release assertions after scene-transition/HUD-refresh timing was exposed by full release verification.

### Verification

- Final verification is recorded in `docs/V0121_HUMAN_PACED_PLAYTEST_REPORT.md`.

### Next

- Rerun the manual GitHub Actions release matrix on the v0.12.1 checkpoint commit.
- Next recommended long goal: v0.12.2 Human Balance Watchpoint Review, focused on repeated evidence for retinue plus Training Yard II, Greedy Economy timeouts, Fast Army clear speed, early campaign defeat causes, and pressure-warning fairness.

## v0.12 Core Game Feel and Battle Readability Pass - 2026-05-16

This checkpoint improves the existing playable slice after the v0.11.12 hosted release matrix green closeout. It focuses on command acknowledgement, selected-order clarity, objective wording, scoped pressure readability, battle-status priority, side-panel hierarchy, results guidance, and evidence-backed no-change tuning decisions without adding new art, maps, factions, units, save migrations, broad AI/economy behavior, or CI plumbing.

### Included

- Core feel audit: `docs/V012_CORE_GAME_FEEL_AUDIT.md`.
- Battle readability audit: `docs/V012_BATTLE_READABILITY_AUDIT.md`.
- Balance/readability tuning note: `docs/V012_BALANCE_AND_FEEL_TUNING_NOTES.md`.
- Visual readability note: `docs/V012_VISUAL_READABILITY_NOTES.md`.
- Final pass report: `docs/V012_CORE_GAME_FEEL_PASS_REPORT.md`.
- Added a `command` battle-status priority so accepted commands can outlive routine income ticks while still yielding to pressure and objective messages.
- Added clearer move, attack, attack-move, rally, build, train, research, ability, and blocked-command feedback.
- Improved selected-group and current-order side-panel hierarchy using existing HUD styling.
- Marked the first unfinished objective as `Next` and tightened Ashen/Cinderfen objective copy.
- Clarified Cinderfen pressure warning counterplay without promoting pressure into workers, construction, economy AI, or a broad strategic planner.
- Improved defeat/results guidance while preserving reward/save behavior.
- Added/updated tests for objective state, status priority, pressure warning copy, and command acknowledgement.

### Verification

- Final verification is recorded in `docs/V012_CORE_GAME_FEEL_PASS_REPORT.md`.

### Next

- Rerun the manual GitHub Actions release matrix on the v0.12 checkpoint commit.
- Next recommended long goal: v0.12.1 Human-Paced Core Feel Playtest Review, with any follow-up changes kept small and evidence-driven.

## v0.11.12 Hosted Release Interaction Determinism Fix - 2026-05-15

This checkpoint keeps the hosted release groups on production preview and hardens the test-only interaction/readiness layer after GitHub run #19 passed `deep-meta` but still failed hosted `deep-battle`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke`, without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, release coverage strength, maps, units, factions, rewards, or UI design.

### Included

- Hosted interaction failure audit: `docs/V1112_HOSTED_RELEASE_INTERACTION_FAILURE_AUDIT.md`.
- Hosted interaction determinism fix report: `docs/V1112_HOSTED_RELEASE_INTERACTION_DETERMINISM_FIX.md`.
- `clickReady` now supports a verified DOM click fallback for real enabled controls after normal Playwright click actionability fails; it does not apply to canvas/world clicks.
- Targeted hosted-problem raw DOM clicks now use `clickReady`, including tutorial command-log advancement, smoke setup/campaign controls, enemy-pressure launch controls, deep-flow Barracks/Train command points, layout navigation, and Chapter 2 helper campaign controls.
- Shared `expectBattleLoaded` now covers HUD, resources, hero panel, minimap shell, minimap test id, canvas, and active BattleScene readiness, and is reused across hosted pressure/smoke/layout/deep paths.
- Tutorial layout and smoke paths now wait for real overlay/button readiness and non-null layout boxes before measuring or advancing.
- Side-panel command reachability now waits for side-panel readiness, uses smaller per-button live-DOM geometry checks, and records diagnostics instead of one broad page evaluation.
- Deep-battle right-click movement now revalidates selected unit state and canvas-safe movement points before preserving the unchanged `Moving` assertion.

### Verification

- Final verification for this checkpoint is recorded in `docs/V1112_HOSTED_RELEASE_INTERACTION_DETERMINISM_FIX.md` and `DEVELOPMENT_CHECKPOINT.md`.

### Next

- Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input and expect the same production-preview hosted release jobs plus the unchanged `Release simulator`.

## v0.11.11 Hosted Release Preview Environment Fix - 2026-05-15

This checkpoint moves the manual hosted GitHub Actions release matrix from the Vite dev server to production preview after GitHub run #17 still failed all explicit hosted groups, without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, release coverage strength, maps, units, factions, rewards, or UI design.

### Included

- Hosted release environment audit: `docs/V1111_HOSTED_RELEASE_ENVIRONMENT_AUDIT.md`.
- Hosted preview environment fix report: `docs/V1111_HOSTED_RELEASE_PREVIEW_ENVIRONMENT_FIX.md`.
- New `playwright.hosted-release.config.ts` for hosted release groups, serving `vite preview` on `127.0.0.1:5173` instead of the Vite dev server.
- New `npm run preview:hosted` script for strict-port production preview on the Playwright release URL.
- Hosted release group scripts now run with `--config=playwright.hosted-release.config.ts`.
- Hosted release Chromium launch args now include `--no-sandbox`, `--disable-dev-shm-usage`, `--disable-gpu`, and the existing SwiftShader/WebGL args.
- GitHub Actions already used `npx playwright install --with-deps chromium`; no dependency-install change was required.
- Small test-only actionability hardening on reported skirmish/tutorial launch paths, with no force-clicks and no weakened assertions.
- Deep-flow right-click movement command now tries nearby alternate world points before failing the unchanged `Moving` assertion.

### Verification

- Passed: `npm test` with 46 files / 351 tests.
- Passed: `npm run build` with the known Phaser vendor chunk warning.
- Passed: `npm run validate:content` and `npm run validate:art-intake`.
- Passed: `npm run test:e2e:smoke:fast`, `npm run visual:qa`, `npm run smoke:preview`, and `npm run playtest:sim`.
- Passed: all six hosted release preview groups locally, totaling 67 tests: `deep-meta` 12, `deep-battle` 11, `deep-campaign-pressure` 7, `layout-core` 16, `layout-cinderfen` 9, and `smoke` 12.
- Passed: targeted hosted-preview repros for the run #17 deep-meta, deep-battle movement, pressure, layout, and smoke failures.
- Passed: local `npm run test:e2e:smoke` on rerun after one dev-server app-root navigation timeout in the long Cinderfen Crossing smoke test.
- Passed: local `npm run test:e2e:release` with 67 tests in 35.2m after the first invocation exceeded the local tool timeout.
- Passed: `git diff --check`, with only the existing Windows CRLF warning on `.github/workflows/ci.yml`.

### Next

- Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input and expect the same six hosted group jobs plus the unchanged `Release simulator`, now running release groups against production preview.

## v0.11.10 Hosted Release Matrix Determinism Fix - 2026-05-14

This checkpoint replaces the v0.11.9 hosted native 6-way release shards with explicit hosted release groups after GitHub Actions run #15 still failed across all hosted shards, without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, release coverage strength, maps, units, factions, rewards, or UI design.

### Included

- Hosted failure audit: `docs/V1110_HOSTED_RELEASE_MATRIX_FAILURE_AUDIT.md`.
- Hosted determinism fix report: `docs/V1110_HOSTED_RELEASE_MATRIX_DETERMINISM_FIX.md`.
- Replaced hosted `test:e2e:release:hosted:shard1of6` through `shard6of6` scripts with explicit hosted group scripts for deep meta, deep battle, deep campaign plus pressure, layout core, layout Cinderfen, and smoke.
- Removed hosted `--fully-parallel` test-level sharding from the GitHub manual release matrix.
- Updated `.github/workflows/ci.yml` so manual `run_release_matrix` runs six named hosted groups with the existing 45-minute timeout plus the unchanged release simulator.
- Added `seedSaveBeforeAppBoot` for deterministic test-only localStorage seeding before app boot, and applied it to shared seeded campaign saves, Chapter 2 seed helpers, and deep-flow local seed setup.
- Applied the existing non-forced `clickReady` helper to additional hosted-problem launch/setup interactions and kept real actionability checks intact.
- Added one retry around the hosted-problem right-click movement command while preserving the `Moving` assertion.
- Tagged release tests into hosted groups totaling the same 67 tests as the full release lane.
- README, release checklist, developer command guide, release lane reliability plan, development checkpoint, and handoff updates.

### Verification

- Required gate passed: `npm test` with 46 files / 351 tests, `npm run build` with the known Phaser vendor warning, `validate:content`, `validate:art-intake`, `npm run test:e2e:smoke:fast`, `npm run visual:qa`, `npm run smoke:preview`, targeted remote-failure reproductions, all six hosted release groups, full `npm run test:e2e:smoke`, full `npm run test:e2e:release`, `npm run playtest:sim`, and `git diff --check`.
- Hosted release groups passed with 67 total Playwright tests split 12/11/7/16/9/12.
- Full release passed 67 tests in about 36.5m after the deterministic seed/actionability changes.

### Next

- Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input and expect jobs named `deep-meta`, `deep-battle`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke`, plus the unchanged `Release simulator` job.

## v0.11.9 Hosted Release Matrix Split and Timeout Fix - 2026-05-14

This checkpoint makes the manually triggered GitHub Actions release matrix smaller and more CI-realistic after hosted 3-way release shards timed out or hit Chromium context instability, without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, release coverage strength, maps, units, factions, rewards, or UI design.

### Included

- Hosted release matrix split audit: `docs/V119_HOSTED_RELEASE_MATRIX_SPLIT_AUDIT.md`.
- Hosted release matrix fix report: `docs/V119_HOSTED_RELEASE_MATRIX_SPLIT_FIX.md`.
- New additive package scripts: `npm run test:e2e:release:hosted:shard1of6` through `npm run test:e2e:release:hosted:shard6of6`, using Playwright test-level sharding with `--fully-parallel --workers=1`.
- GitHub Actions manual `run_release_matrix` now runs six hosted release shard jobs with a 45-minute per-shard timeout plus the unchanged release simulator.
- Existing local full release, 2-way shard, and 3-way shard scripts remain available and unchanged.
- Applied the existing non-forced `clickReady` helper to the two `menu-reset-save` clicks called out by hosted shard-1 evidence.
- Added a final real-main-menu readiness check after transient app-root navigation retries in the shared helper, accepting recovery only when the actual main menu controls are visible.
- README, release checklist, developer command guide, release lane reliability plan, development checkpoint, and handoff updates.

### Verification

- Required gate passed: `npm test` with 46 files / 351 tests, `npm run build` with the known Phaser vendor warning, `validate:content`, `validate:art-intake`, `npm run test:e2e:smoke:fast`, `npm run visual:qa`, `npm run smoke:preview`, full `npm run test:e2e:smoke`, all six hosted release shards, `npm run playtest:sim`, and `git diff --check`.
- Hosted 6-way release shards passed with 67 total Playwright tests split 12/11/11/11/11/11.
- The existing local 3-way shard scripts were not rerun in this pass because they are unchanged and the corrected hosted 6-way scripts exercised the same 67-test release suite.

### Next

- Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input and expect six jobs named `shard-1-of-6` through `shard-6-of-6`, plus the unchanged `Release simulator` job.

## v0.11.8 Hosted Release Matrix Stability Fix - 2026-05-13

This checkpoint stabilizes the manually triggered GitHub Actions 3-way release matrix after Fast confidence, Optional visual QA, and the release simulator were green, without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, release coverage strength, maps, units, factions, rewards, or UI design.

### Included

- Release matrix stability report: `docs/V118_HOSTED_RELEASE_MATRIX_STABILITY_FIX.md`.
- Reload/navigation audit: `docs/V118_RELEASE_MATRIX_RELOAD_NAVIGATION_AUDIT.md`.
- Removed remaining Playwright `page.reload()` usage from e2e/visual QA by routing deep-flow and smoke persistence checks through the shared hosted-safe app-root navigation helper.
- Unified `deep-flow.spec.ts` synthetic save setup with the shared `gotoReadyMainMenu` path and Continue Campaign readiness checks.
- Hardened `gotoReadyMainMenu` with commit-stage navigation, three setup-navigation attempts, same-URL interruption handling, longer menu-readiness probes, and clearer retry diagnostics.
- Added a narrow `clickReady` helper for hosted actionability stalls without using force-clicks or weakening assertions.
- Applied `clickReady` to reported release-path interactions: Broken Ford selection/start, seeded skirmish starts, Cinderfen campaign node/start helpers, and Border Village campaign start paths.
- Added a scoped 120s budget to the seeded Cinderfen layout readability test after remote shard-2 evidence and a local full-release reproduction showed the 90s budget could expire during setup-navigation recovery.

### Verification

- Required gate passed: `npm test` with 46 files / 351 tests, `npm run build` with the known Phaser warning, `validate:content`, `validate:art-intake`, `npm run test:e2e:smoke:fast`, full `npm run test:e2e:smoke`, `npm run visual:qa`, `npm run smoke:preview`, targeted hosted-failure reproductions, full release, all 3 release shards, `npm run playtest:sim`, and `git diff --check`.
- Full release passed with 67 tests in about 36.5m after the final helper/timeout refinement.
- 3-way release shards passed: shard1 28 tests, shard2 27 tests, shard3 12 tests.

### Next

- Emmanuel should rerun the manual GitHub Actions `Run manual 3-way release shard matrix and simulator` workflow input and confirm shards 1, 2, and 3 are green with any setup-navigation/actionability retries logged and recovered.

## v0.11.7 Optional Visual QA Screenshot Stability Fix - 2026-05-13

This checkpoint stabilizes the manually triggered GitHub Actions `Optional visual QA` job after v0.11.6 fixed hosted navigation but exposed a hosted screenshot-capture hang, without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, screenshot coverage strength, maps, units, factions, rewards, or UI design.

### Included

- Visual QA screenshot stability report: `docs/V117_VISUAL_QA_SCREENSHOT_STABILITY_FIX.md`.
- Split `npm run visual:qa` from one monolithic 18-screenshot test into 5 smaller visual QA tests with fresh Playwright pages.
- Added per-screenshot `START`, `DONE`, `FAIL`, and `RETRY` logging with capture group, file name, viewport, URL, elapsed time, duration, and retry status.
- Added a 45s per-screenshot timeout, one retry for transient screenshot timeout/capture failures, and disabled animations/caret during screenshots.
- Expanded the generated visual QA index with capture groups and screenshot retry count/status.
- Preserved all 18 visual QA screenshot targets and unchanged browser console error failure behavior.

### Verification

- Full checkpoint gate passed: `npm test` with 46 files / 351 tests, `npm run build` with the known Phaser warning, `validate:content`, `validate:art-intake`, `npm run test:e2e:smoke:fast`, split `npm run visual:qa`, `npm run smoke:preview`, full `npm run test:e2e:smoke`, `npm run playtest:sim`, all 3 release shards, and `git diff --check`.
- Split `npm run visual:qa` passed with 5 tests, 18 screenshots, 0 browser console errors, and 0 screenshot retries.

### Next

- Emmanuel should rerun the manual GitHub Actions `Optional visual QA` job and confirm the log reaches `DONE screenshot ... cinderfen-crossing-tablet.png`, the job shows 5 visual QA tests, and `visual-qa-latest/index.md` reports 18 screenshots and 0 browser console errors.

## v0.11.6 Optional Visual QA Hosted Navigation Fix - 2026-05-12

This checkpoint stabilizes the manually triggered GitHub Actions `Optional visual QA` job after v0.11.5 made automatic `Fast confidence` green, without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, screenshot coverage strength, maps, units, factions, rewards, or UI design.

### Included

- Visual QA hosted navigation report: `docs/V116_VISUAL_QA_HOSTED_NAVIGATION_FIX.md`.
- Narrow setup-navigation retry in `tests/e2e/shared-helpers.ts` for transient hosted-runner `net::ERR_ABORTED`, frame-detached, and setup-navigation timeout errors during `gotoReadyMainMenu`; timed-out navigation is accepted only if the real main menu is already visible.
- Scoped optional visual QA test budget increase from 240s to 420s for the single 18-screenshot capture pass.
- All 18 visual QA screenshot targets, browser console error collection, and human-reviewed non-pixel-perfect policy remain unchanged.
- Release checklist, development checkpoint, and handoff updates.

### Verification

- Required local gate: `npm test`, `npm run build`, `validate:content`, `validate:art-intake`, `npm run test:e2e:smoke:fast`, `npm run visual:qa`, `npm run smoke:preview`, full `npm run test:e2e:smoke`, `npm run playtest:sim`, 3-way release shards, and `git diff --check` passed.

### Next

- Emmanuel should rerun the manual GitHub Actions `Optional visual QA` job and confirm it uploads `visual-qa-latest` with `index.md`, 18 screenshots, and 0 browser console errors.

## v0.11.5 GitHub Actions Fast Confidence Lane Split - 2026-05-12

This checkpoint splits automatic GitHub browser confidence from the full smoke/release lanes without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, workflow coverage strength, maps, units, factions, rewards, or UI design.

### Included

- Fast-confidence lane split report: `docs/V115_FAST_CONFIDENCE_LANE_SPLIT.md`.
- New package script: `npm run test:e2e:smoke:fast`.
- Smoke test title tags:
  - `@ci-fast` for the six automatic fast-confidence checks.
  - `@extended-smoke` for the six longer campaign/skirmish smoke checks.
- GitHub Actions automatic `Fast confidence` now runs `npm run test:e2e:smoke:fast` instead of the full smoke suite.
- Full `npm run test:e2e:smoke`, full release, release shards, manual workflow lanes, and local final gates remain coverage-preserving.
- README, release checklist, developer command guide, release lane reliability plan, development checkpoint, and handoff updates.

### Verification

- Script inventory: `npm run test:e2e:smoke:fast -- --list` lists 6 tests; `npm run test:e2e:smoke -- --list` lists all 12 tests.
- Required local gate: `npm test` passed with 46 files / 351 tests; build passed with the known Phaser warning; `validate:content`, `validate:art-intake`, `npm run test:e2e:smoke:fast`, full `npm run test:e2e:smoke`, `npm run smoke:preview`, full release, 3-way release shards, `visual:qa`, `playtest:sim`, and `git diff --check` passed.

### Next

- Emmanuel should re-check the automatic GitHub Actions `Fast confidence` job after this commit is pushed and confirm the e2e step runs `npm run test:e2e:smoke:fast`.
- Use full local smoke, manual release shards, or full release for the extended campaign/skirmish smoke coverage.

## v0.11.4 GitHub Actions Smoke Seed/Reload Stability Fix - 2026-05-12

This checkpoint stabilizes seeded campaign/skirmish smoke setup after the first v0.11.3 GitHub Actions `Fast confidence` rerun, without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, workflow coverage, maps, units, factions, rewards, or UI design.

### Included

- Seed/reload smoke fix report: `docs/V114_FAST_CONFIDENCE_SEED_RELOAD_FIX.md`.
- Stable seeded-save setup in `tests/e2e/shared-helpers.ts`: boot to a ready main menu before localStorage mutation, navigate with `page.goto("/")` after writing storage instead of `page.reload()`, and verify seeded saves enable Continue Campaign.
- Chapter 2 seed helpers now use the same stable storage setup path for post-Ashen, post-Crossing, and completed-route saves.
- A narrowly scoped 60s timeout for only `skirmish difficulty selection changes fog and starting pressure`, justified by hosted CI evidence and a local traced run that took 44.9s after the safer seeded setup.
- Handoff, development checkpoint, and release-checklist updates.

### Verification

- Pre-fix local smoke passed: `npm run test:e2e:smoke`, 12 tests in about 5.0m.
- Pre-fix targeted runs passed locally for the reported post-Ashen, post-Crossing, skirmish difficulty, Border Village, and Broken Ford smoke paths, supporting a seed/reload CI stability diagnosis rather than a deterministic gameplay failure.
- Post-fix focused gate: `npx playwright test tests/e2e/smoke.spec.ts --grep "skirmish difficulty selection changes fog and starting pressure" --retries=1 --trace=on` passed in 44.9s during the first post-helper run and 32.7s during the final focused gate.
- Required local gate: `npm test` passed with 46 files / 351 tests; build passed with the known Phaser warning; `validate:content`, `validate:art-intake`, all five reported focused smoke paths, `npm run test:e2e:smoke`, `npm run smoke:preview`, full release, 3-way release shards, `visual:qa`, `playtest:sim`, and `git diff --check` passed.
- One first-pass local `release:shard2of3` run hit a timeout in the enemy-pressure tutorial/skirmish guard test after 26/27 tests passed; the exact test passed on targeted rerun and the full shard passed on rerun, so no coverage was changed for that release-lane transient.

### Next

- Emmanuel should re-check the automatic GitHub Actions `Fast confidence` job after this commit is pushed and confirm the seeded campaign/skirmish smoke paths no longer fail around localStorage seed/reload.
- Treat the reported Border Village and Broken Ford failures as likely cascade/flaky context fallout unless the next hosted run shows fresh independent failures after seeded setup succeeds.

## v0.11.3 GitHub Actions Fast Confidence Smoke Fix - 2026-05-12

This checkpoint fixes the first reported remote GitHub Actions `Fast confidence` smoke timeout without changing gameplay, content, tutorial behavior, save format, campaign progression, visual assets, runtime art, workflow coverage, maps, units, factions, rewards, or UI design.

### Included

- Fast-confidence smoke fix report: `docs/V113_FAST_CONFIDENCE_SMOKE_FIX.md`.
- Settings accessibility smoke robustness in `tests/e2e/smoke.spec.ts`.
- A settings range-control helper that waits for the Settings scene's DOM re-rendered control state before continuing.
- Explicit state assertions after settings accessibility/fog controls change.
- A narrowly scoped 60s timeout for only `settings screen persists accessibility options`, justified by GitHub Actions evidence that the combined settings-persistence plus in-battle runtime-application smoke path exceeded the global 35s budget on the hosted runner.
- Handoff, development checkpoint, and release-checklist updates.

### Verification

- Focused reproduction before the fix: local full smoke passed, focused settings passed but consumed 23.6s of the 35s budget, and a serial 3x settings repeat passed at 22.4s, 23.8s, and 24.1s.
- Post-fix focused gate: `npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on` passed in 26.8s.
- Post-fix focused gate: `npx playwright test tests/e2e/smoke.spec.ts --grep "campaign Border Village launches a battle scene" --retries=1 --trace=on` passed in 16.7s.
- Required local gate: `npm test` passed with 46 files / 351 tests; build passed with the known Phaser warning; `validate:content`, `validate:art-intake`, `npm run test:e2e:smoke`, `npm run smoke:preview`, full release, 3-way release shards, `visual:qa`, `playtest:sim`, and `git diff --check` passed.

### Next

- Emmanuel should re-check the automatic GitHub Actions `Fast confidence` job after this commit is pushed and confirm the settings accessibility smoke test no longer times out.
- Treat the previous Border Village `browser.newContext` failure as a likely cascade unless the next hosted run shows a fresh independent failure.

## v0.11.2 GitHub Actions Remote CI Observation and Timeout Tuning - 2026-05-11

This checkpoint documents remote GitHub Actions observation limits and CI no-change decisions without changing gameplay, content, tutorial behavior, save format, campaign progression, visual assets, runtime art, workflow YAML, helper code, Playwright coverage, maps, units, factions, rewards, or UI design.

### Included

- Remote CI observation capability report: `docs/V112_REMOTE_CI_OBSERVATION_CAPABILITY.md`.
- GitHub Actions evidence limitation report: `docs/V112_GITHUB_ACTIONS_EVIDENCE_REPORT.md`.
- Static workflow review: `docs/V112_WORKFLOW_STATIC_REVIEW.md`.
- CI timeout tuning review: `docs/V112_CI_TIMEOUT_TUNING_REVIEW.md`.
- Preview helper remote portability review: `docs/V112_PREVIEW_HELPER_REMOTE_PORTABILITY_REVIEW.md`.
- CI artifact remote review: `docs/V112_CI_ARTIFACT_REMOTE_REVIEW.md`.
- Manual GitHub Actions checklist for Emmanuel: `docs/V112_MANUAL_GITHUB_ACTIONS_CHECKLIST.md`.
- CI no-fix decision: `docs/V112_CI_NO_FIX_DECISION.md`.
- v0.11.2 report: `docs/V112_REMOTE_CI_OBSERVATION_REPORT.md`.
- README, release checklist, roadmap, development checkpoint, and handoff updates.

### Verification

- Phase gates: `npm test` passed with 46 test files and 351 tests.
- Phase gates: `npm run build` passed with the known Phaser vendor large-chunk warning.
- Phase gates: `npm run validate:content` passed.
- Phase gates: `npm run validate:art-intake` passed.
- Tooling gates: `npm run test:e2e:smoke` passed.
- Preview helper gates: `npm run smoke:preview` passed with title/menu/tutorial/campaign/skirmish checks and 0 browser console errors.
- Artifact review/report gates: `npm run visual:qa` passed with 18 indexed screenshots and 0 recorded browser console errors.
- Report gate: `npm run playtest:sim` passed with 255 simulated runs across 85 campaign battle nodes.
- Phase/report gates: `git diff --check` passed.

### Next

- Emmanuel should use `docs/V112_MANUAL_GITHUB_ACTIONS_CHECKLIST.md` to capture authenticated GitHub Actions evidence.
- If GitHub UI evidence shows a real CI-only issue, run v0.11.3 GitHub Actions Evidence Follow-Up and Minimal Tuning.
- If Emmanuel provides tutorial feedback, run v0.10.1 Tutorial v2 Human-Feedback Polish.
- If source/license-documented candidate art exists, run v0.9.2 Controlled Cinderfen Style-Frame Candidate Review.

## v0.11.1 CI Release Matrix Dry-Run and Preview Helper Portability - 2026-05-11

This checkpoint adds a conservative GitHub Actions CI dry-run and CI/release documentation without changing gameplay, content, tutorial behavior, save format, campaign progression, visual assets, runtime art, maps, units, factions, rewards, Playwright coverage, or UI design.

### Included

- CI matrix audit: `docs/V111_CI_MATRIX_AUDIT.md`.
- Preview helper portability audit: `docs/V111_PREVIEW_HELPER_PORTABILITY_AUDIT.md`.
- Small `npm run smoke:preview` portability improvements in `tools/smokePreview.ts`.
- CI release matrix plan: `docs/V111_CI_RELEASE_MATRIX_PLAN.md`.
- Conservative GitHub Actions workflow: `.github/workflows/ci.yml`.
- CI artifact strategy: `docs/V111_CI_ARTIFACT_STRATEGY.md`.
- CI/local parity check: `docs/V111_CI_LOCAL_PARITY_CHECK.md`.
- v0.11.1 report: `docs/V111_CI_RELEASE_MATRIX_REPORT.md`.
- README, release checklist, developer command guide, roadmap, development checkpoint, and handoff updates.

### Verification

- Phase gates: `npm test` passed with 46 test files and 351 tests.
- Phase gates: `npm run build` passed with the known Phaser vendor large-chunk warning.
- Phase gates: `npm run validate:content` passed.
- Phase gates: `npm run validate:art-intake` passed.
- Tooling gates: `npm run test:e2e:smoke` passed.
- Preview helper gates: `npm run smoke:preview` passed with title/menu/tutorial/campaign/skirmish checks and 0 browser console errors.
- Report gate: `npm run visual:qa` passed with 18 indexed screenshots and 0 recorded browser console errors.
- Report gate: `npm run playtest:sim` passed with 255 simulated runs across 85 campaign battle nodes.
- Phase/report gates: `git diff --check` passed.

### Next

- Validate the pushed GitHub Actions workflow on GitHub before treating remote CI as proven.
- If Emmanuel provides tutorial feedback, run v0.10.1 Tutorial v2 Human-Feedback Polish.
- If source/license-documented candidate art exists, run v0.9.2 Controlled Cinderfen Style-Frame Candidate Review.
- If neither is available, the next safe autonomous goal is v0.11.2 GitHub Actions Remote CI Observation and Timeout Tuning.

## v0.11 Technical Reliability, E2E Runtime, and Performance Gate - 2026-05-11

This checkpoint improves release reliability documentation, e2e runtime clarity, preview smoke repeatability, optional visual QA reporting, bundle/performance measurement, developer command ergonomics, and release-checklist maintainability without changing gameplay, content, tutorial behavior, save format, campaign progression, visual assets, runtime art, maps, units, factions, rewards, or UI design.

### Included

- E2E runtime audit refresh: `docs/V11_E2E_RUNTIME_AUDIT_REFRESH.md`.
- Release lane reliability plan: `docs/V11_RELEASE_LANE_RELIABILITY_PLAN.md`.
- Automated production preview smoke helper: `npm run smoke:preview`, backed by `tools/smokePreview.ts`.
- Preview smoke reliability notes: `docs/V11_PREVIEW_SMOKE_RELIABILITY_NOTES.md`.
- Visual QA index/summary improvement plus `docs/V11_VISUAL_QA_RELIABILITY_NOTES.md`.
- Bundle/performance refresh: `docs/V11_BUNDLE_PERFORMANCE_REFRESH.md`.
- Developer command guide: `docs/DEVELOPER_COMMAND_GUIDE.md`.
- Tightened release checklist and v0.11 report: `docs/V11_TECHNICAL_RELIABILITY_REPORT.md`.

### Verification

- Phase gates: `npm test` passed with 46 test files and 351 tests.
- Phase gates: `npm run build` passed with the known Phaser vendor large-chunk warning.
- Phase gates: `npm run validate:content` passed.
- Phase gates: `npm run validate:art-intake` passed with the template-only empty intake.
- Preview helper gate: `npm run smoke:preview` passed with title/menu/tutorial/campaign/skirmish checks and 0 browser console errors.
- Visual QA gate: `npm run visual:qa` passed with 18 indexed screenshots and 0 recorded browser console errors.
- E2E smoke gate: `npm run test:e2e:smoke` passed.
- Phase/report gates: `git diff --check` passed.

### Next

- If Emmanuel provides tutorial feedback, run v0.10.1 Tutorial v2 Human-Feedback Polish.
- If source/license-documented candidate art exists, run v0.9.2 Controlled Cinderfen Style-Frame Candidate Review.
- If neither is available, the next safe autonomous goal is v0.11.1 CI Release Matrix Dry-Run and Preview Helper Portability.

## v0.10 Tutorial v2 Onboarding Refinement - 2026-05-11

This checkpoint refines Tutorial / Proving Grounds onboarding clarity, pacing documentation, overlay hierarchy, no-reward completion messaging, e2e lane documentation, visual QA review, and Emmanuel's manual playtest checklist without adding maps, units, factions, workers, enemy construction, economy AI, rewards, save persistence, campaign progression, generated art, imported art, runtime art replacement, desktop packaging, engine switching, a graphics overhaul, or broad systems.

### Included

- Tutorial v2 audit: `docs/V10_TUTORIAL_V2_AUDIT.md`.
- Tutorial pacing and scope plan: `docs/V10_TUTORIAL_V2_PACING_PLAN.md`.
- Tutorial copy refinement in `src/game/data/tutorials.ts` plus `docs/V10_TUTORIAL_COPY_REFINEMENT_NOTES.md`.
- Small tutorial overlay hierarchy refinement in `src/game/ui/hudPanels/TutorialPanel.ts` and `src/game/styles/battle-feedback.css` plus `docs/V10_TUTORIAL_OVERLAY_REFINEMENT_NOTES.md`.
- Completion/no-reward clarity in the battle and main-menu handoff plus `docs/V10_TUTORIAL_COMPLETION_CLARITY_NOTES.md`.
- Tutorial e2e lane review: `docs/V10_TUTORIAL_E2E_LANE_REVIEW.md`.
- Tutorial visual QA review: `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`.
- Manual Tutorial v2 playtest checklist for Emmanuel: `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`.
- v0.10 report: `docs/V10_TUTORIAL_V2_ONBOARDING_REPORT.md`.

### Verification

- Phase gates: `npm test` passed with 46 test files and 351 tests.
- Phase gates: `npm run build` passed with the known Phaser vendor large-chunk warning.
- Phase gates: `npm run validate:content` passed.
- Phase gates: `npm run validate:art-intake` passed with the template-only empty intake.
- Tutorial source/UI gates: `npm run test:e2e:smoke` passed.
- Layout gate: `npm run test:e2e:layout` passed.
- E2E lane review: `npm run test:e2e:release` passed with 67 Playwright tests.
- Visual review: `npm run visual:qa` passed with 18 indexed review screenshots and zero recorded browser console errors.
- Report gate: `npm run playtest:sim` passed with 255 simulated runs across 85 campaign battle nodes.
- Final gate: full smoke/release, 2-way shards, 3-way shards, visual QA, simulator, diff check, and production preview smoke passed.
- Phase gates: `git diff --check` passed.

### Next

- Recommended immediate human step: Emmanuel should run `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md` and report confusing steps, screenshots, 1-5 ratings, and whether no-reward completion feels acceptable.
- Recommended next player-facing goal after feedback: v0.10.1 Tutorial v2 human-feedback polish, still no rewards, persistence, maps, units, factions, art replacement, or broad UI redesign.
- Recommended visual goal remains v0.9.2 Controlled Cinderfen Style-Frame Candidate Review only after source/license-documented candidate images exist.

## v0.9.1 Controlled Cinderfen Style-Frame Intake And Source Review - 2026-05-10

This checkpoint creates the safe non-runtime intake pipeline for future Cinderfen style-frame candidates. It adds review folders, source/license metadata templates, review manifest schema/types, metadata-only validation, a candidate scan, screenshot comparison planning, Emmanuel's manual preparation guide, and a future v0.9.2 review brief without adding generated art, imported assets, candidate binaries, runtime art, gameplay content, new maps, new units, new factions, rewards, save changes, campaign progression, desktop packaging, engine switching, a graphics overhaul, or broad systems.

### Included

- Intake protocol: `docs/V091_STYLE_FRAME_INTAKE_PROTOCOL.md`.
- Non-runtime review folder structure under `art-review/`.
- Source/license metadata guide and templates: `docs/V091_SOURCE_LICENSE_METADATA_GUIDE.md`, `art-review/cinderfen-style-frames/metadata/CANDIDATE_METADATA_TEMPLATE.md`, and `art-review/cinderfen-style-frames/metadata/CANDIDATE_METADATA_TEMPLATE.json`.
- Review manifest schema and tooling-only types: `docs/V091_STYLE_FRAME_REVIEW_MANIFEST_SCHEMA.md` and `tools/art-intake/StyleFrameReviewManifestTypes.ts`.
- Metadata-only validation: `npm run validate:art-intake`, `tools/art-intake/validateArtIntake.ts`, and `tools/art-intake/validateArtIntake.test.ts`.
- Current candidate scan: `docs/V091_CURRENT_STYLE_FRAME_CANDIDATE_SCAN.md`.
- Screenshot comparison plan: `docs/V091_STYLE_FRAME_SCREENSHOT_COMPARISON_PLAN.md`.
- Manual preparation guide for Emmanuel: `docs/V091_MANUAL_STYLE_FRAME_PREPARATION_GUIDE.md`.
- Future review brief: `docs/V092_STYLE_FRAME_REVIEW_GOAL_BRIEF.md`.
- v0.9.1 report: `docs/V091_CONTROLLED_STYLE_FRAME_INTAKE_REPORT.md`.

### Verification

- Phase gates: `npm test` passed with 46 test files and 351 tests.
- Phase gates: `npm run build` passed with the known Phaser vendor large-chunk warning.
- Phase gates: `npm run validate:content` passed.
- Phase gates: `npm run validate:art-intake` passed with a template-only intake.
- Report gate: `npm run visual:qa` passed with 18 indexed review screenshots and zero recorded browser console errors.
- Report gate: `npm run playtest:sim` passed with 255 simulated runs across 85 campaign battle nodes.
- Phase/report gates: `git diff --check` passed.

### Next

- Recommended next goal: v0.9.2 Controlled Cinderfen Style-Frame Candidate Review, only after Emmanuel provides source/license-documented candidates.
- Keep the next step non-runtime: validate metadata, reject unsafe candidates, catalogue safe candidates as reference/candidate only, run visual QA, and create a side-by-side human review.
- Do not wire assets into runtime until a later goal scopes one tiny replacement with source/license proof, manifest validation, before/after screenshot QA, and rollback.

## v0.9 Controlled Cinderfen Style-Frame Sprint - 2026-05-10

This checkpoint creates a docs/specs/prompts-only Cinderfen visual style-frame package before any art generation or runtime replacement. It defines the future ash-glass wetland identity, material language, shrine landmark direction, Ashen outpost architecture, unit/building scale standards, prompt pack, manifest templates, screenshot acceptance criteria, and future replacement sequence without adding generated art, imported assets, runtime art, gameplay content, new maps, new units, new factions, rewards, save changes, campaign progression, desktop packaging, engine switching, a graphics overhaul, or broad systems.

### Included

- Cinderfen style-frame research packet: `docs/V09_CINDERFEN_STYLE_FRAME_RESEARCH_PACKET.md`.
- Cinderfen visual pillars: `docs/V09_CINDERFEN_VISUAL_PILLARS.md`.
- Terrain material sheet spec: `docs/V09_CINDERFEN_TERRAIN_MATERIAL_SHEET_SPEC.md`.
- Cinder Shrine/capture-site landmark spec: `docs/V09_CINDER_SHRINE_LANDMARK_SPEC.md`.
- Ashen outpost architecture spec: `docs/V09_ASHEN_OUTPOST_ARCHITECTURE_SPEC.md`.
- Unit/building scale reference: `docs/V09_UNIT_BUILDING_SCALE_REFERENCE.md`.
- Cinderfen style-frame prompt pack: `docs/V09_CINDERFEN_STYLE_FRAME_PROMPT_PACK.md`.
- Future Cinderfen manifest templates: `docs/V09_FUTURE_CINDERFEN_MANIFEST_TEMPLATES.md`.
- Screenshot acceptance criteria: `docs/V09_CINDERFEN_SCREENSHOT_ACCEPTANCE_CRITERIA.md`.
- Future visual replacement implementation plan: `docs/V09_CINDERFEN_VISUAL_REPLACEMENT_IMPLEMENTATION_PLAN.md`.
- v0.9 report: `docs/V09_CONTROLLED_CINDERFEN_STYLE_FRAME_REPORT.md`.

### Verification

- Phase gates: `npm test` passed with 45 test files and 340 tests.
- Phase gates: `npm run build` passed with the known Phaser vendor large-chunk warning.
- Phase gates: `npm run validate:content` passed.
- Phase gates: `git diff --check` passed.
- Report gate: `npm run visual:qa` passed with 18 indexed review screenshots and zero recorded browser console errors.
- Report gate: `npm run playtest:sim` passed with 255 simulated runs across 85 campaign battle nodes.

### Next

- Recommended next goal: v0.9.1 Controlled Cinderfen Style-Frame Intake And Source Review.
- Keep the next step non-runtime first: obtain 1 to 3 style-frame candidates, record source/license metadata, track as reference/candidate only, validate, run visual QA, and write a human source/screenshot review.
- Do not wire assets into runtime until a later goal scopes one tiny replacement with source/license proof, manifest validation, before/after screenshot QA, and rollback.

## v0.8.2 Visual Source/License Review and Screenshot Coverage Expansion - 2026-05-10

This checkpoint hardens the visual asset pipeline by reviewing source/license risk, adding conservative source-review metadata, strengthening manifest validation, expanding optional screenshot QA coverage, and preparing a safe v0.9 visual direction without adding art, generated images, external assets, large binaries, gameplay content, new maps, new units, new factions, rewards, save changes, campaign progression, desktop packaging, engine switching, a graphics overhaul, or broad systems.

### Included

- Source/license review plan: `docs/V082_ASSET_SOURCE_LICENSE_REVIEW_PLAN.md`.
- Asset source/license audit: `docs/V082_ASSET_SOURCE_LICENSE_AUDIT.md`.
- Manifest metadata refinement with `reviewStatus` and `sourceReviewNotes`.
- Manifest validation hardening for production approval, runtime/reference conflicts, deprecated runtime assets, critical replacement notes, and production-safe source/license requirements.
- Screenshot coverage expansion plan: `docs/V082_SCREENSHOT_COVERAGE_EXPANSION_PLAN.md`.
- Expanded optional `npm run visual:qa` harness from 10 to 18 indexed screenshots, including Asset Gallery, Hero Inventory, tutorial mobile, route-complete campaign map, Cinderfen Crossing tablet, Crossing pressure warning, victory Results, and defeat Results.
- Extended screenshot review: `docs/V082_EXTENDED_SCREENSHOT_QA_REVIEW.md`.
- Visual risk register: `docs/VISUAL_RISK_REGISTER.md`.
- v0.9 controlled visual sprint brief: `docs/V09_CONTROLLED_VISUAL_SPRINT_BRIEF.md`.
- v0.8.2 report: `docs/V082_SOURCE_LICENSE_SCREENSHOT_COVERAGE_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 340 tests during phase/report gates.
- `npm run build`: passed with the known Phaser vendor large-chunk warning during phase/report gates.
- `npm run validate:content`: passed with gameplay content and hardened visual asset metadata validation.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests during screenshot/report gates.
- `npm run visual:qa`: passed with 18 indexed review screenshots and zero recorded browser console errors.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes during the report gate.
- `git diff --check`: passed during phase/report gates.

### Next

- Recommended next goal: v0.9 Controlled Cinderfen Style-Frame Sprint.
- Keep the first v0.9 visual step docs/specs/prompts-only: terrain material sheet, Cinder Shrine/capture-site landmark sheet, and Ashen outpost architecture sheet.
- Do not generate, import, download, commit, or wire runtime art assets until a future goal explicitly scopes source/license metadata, manifest updates, validation, and before/after screenshot QA.

## v0.8.1 Visual Asset Manifest and Screenshot QA Gate - 2026-05-10

This checkpoint creates the visual asset manifest, metadata validation, runtime asset cross-check, and non-brittle screenshot QA foundation without adding final art, generated art, external assets, large binaries, gameplay content, new maps, new units, new factions, workers, enemy construction, economy AI, rewards, save changes, campaign progression, desktop packaging, engine switching, a graphics overhaul, or broad systems.

### Included

- Existing asset inventory audit across `public/assets/`, manual/final/runtime assets, loader references, and source usage.
- Typed visual asset manifest schema and 89-entry initial manifest covering runtime assets, manual source originals, procedural terrain debt, and future prompt/spec references.
- Visual asset metadata validation integrated into `npm run validate:content`, including runtime file existence checks in the CLI path.
- Runtime asset usage cross-check for battle textures, ability icons, UI-kit CSS assets, faction emblem, and screen backgrounds.
- Optional screenshot QA harness: `npm run visual:qa`, backed by `playwright.visual-qa.config.ts` and `tests/visual-qa/visual-qa.spec.ts`.
- Ignored screenshot output under `/visual-qa/`, with generated review index and zero pixel-perfect assertions.
- Screenshot QA review for main menu, tutorial, campaign map, skirmish setup, Cinderfen Crossing, Cinder Shrine capture, Cinderfen Watch, and Watch pressure warning.
- Cinderfen visual asset replacement backlog.
- Safe future asset prompt/spec templates.
- v0.8.1 report: `docs/V081_VISUAL_ASSET_SCREENSHOT_QA_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 339 tests during the final gate.
- `npm run build`: passed with the known Phaser vendor large-chunk warning during the final gate.
- `npm run validate:content`: passed with gameplay content and visual asset metadata validation.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests during the final gate.
- `npm run test:e2e:release`: passed with 67 Playwright tests during the final gate.
- `npm run test:e2e:release:shard1`: passed with 55 Playwright tests during the final gate.
- `npm run test:e2e:release:shard2`: passed with 12 Playwright tests during the final gate.
- `npm run test:e2e:release:shard1of3`: passed with 28 Playwright tests during the final gate.
- `npm run test:e2e:release:shard2of3`: passed with 27 Playwright tests during the final gate.
- `npm run test:e2e:release:shard3of3`: passed with 12 Playwright tests during the final gate.
- `npm run visual:qa`: passed with 10 generated review screenshots and zero recorded browser console errors.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes during the final gate.
- Production preview smoke: passed at `http://127.0.0.1:57934/` with title, main menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and zero browser console errors verified.
- `git diff --check`: passed during the final gate.

### Next

- Recommended next goal: v0.8.2 Visual Source/License Review and Screenshot Coverage Expansion.
- Keep future visual work manifest-backed, source/license-reviewed, and screenshot-QA reviewed before committing binary replacements.
- Tutorial v2 onboarding refinement remains the safest player-facing alternative.

## v0.8 Technical Performance, E2E Runtime, and Visual Foundation Gate - 2026-05-10

This checkpoint refreshes technical performance/e2e runtime facts and creates a disciplined visual foundation without adding workers, enemy construction, economy AI, new maps, new units, new factions, rewards, save changes, live reinforcements, capture-site contest AI, defensive-hold behavior, desktop packaging, engine switching, external generated assets, large binary assets, a full UI redesign, a graphics overhaul, or broad systems.

### Included

- Refreshed performance and bundle audit with current app JS, Phaser vendor, CSS, gzip sizes, analyzer findings, and production-leak scan.
- E2E runtime and shard imbalance audit for the 67-test release suite.
- Additive optional 3-shard release scripts: `test:e2e:release:shard1of3`, `test:e2e:release:shard2of3`, and `test:e2e:release:shard3of3`.
- Visual debt audit covering terrain, roads, water/swamp, capture sites, units, buildings, minimap, HUD, and style mismatch.
- Visual scale/readability audit covering hero/unit/building/capture-site/minimap/camera/fog/pathfinding scale rules.
- Explicit no-code visual readability decision for v0.8.
- 2026 art direction bible for future original dark heroic fantasy RTS/RPG visuals.
- Asset pipeline plan for future source/license/status/scale metadata.
- Cinderfen visual rework spec with future identity, readability requirements, art prompt templates, and implementation phases.
- v0.8 report: `docs/V08_TECH_VISUAL_FOUNDATION_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 334 tests during phase gates.
- `npm run build`: passed with the known Phaser vendor large-chunk warning during phase gates.
- `npm run validate:content`: passed during phase gates.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 6.1m during the visual readability gate.
- `npm run test:e2e:layout`: first attempt hit the command timeout with no failing-test output; after cleaning repo-local leftover Playwright/Vite Node processes and rerunning with a longer timeout, passed with 25 Playwright tests in 14.9m.
- `npm run test:e2e:release:shard1of3`: passed with 28 Playwright tests in 12.3m.
- `npm run test:e2e:release:shard2of3`: passed with 27 Playwright tests in 14.9m.
- `npm run test:e2e:release:shard3of3`: passed with 12 Playwright tests in 5.3m.
- Report-gate `npm run test:e2e:smoke`: passed with 12 Playwright tests in 6.3m.
- Report-gate `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes.
- `git diff --check`: passed during phase gates.

### Next

- Recommended next goal: v0.8.1 Visual Asset Manifest and Screenshot QA Gate, with no new assets or graphics overhaul.
- Alternative player-facing goal: Tutorial v2 onboarding refinement.
- Keep pressure-specific work blocked on manual feedback and simulator-only first experiments; do not promote live reinforcement, route contesting, or defensive hold behavior yet.

## v0.7.3 Real-Input Cinderfen Pressure Playtest - 2026-05-09

This checkpoint reviews Cinderfen pressure with controlled browser input and simulator evidence without expanding Enemy Strategic Pressure into workers, enemy construction, economy AI, new maps, new units, new factions, rewards, save changes, live reinforcements, capture-site contest AI, defensive-hold behavior, or broad systems.

### Included

- Real-input pressure playtest protocol and seeded browser setup notes.
- Controlled browser-input review for Cinderfen Crossing, including natural Cinder Shrine capture and seeded delayed-warning visibility evidence.
- Controlled browser-input review for Cinderfen Watch, including natural Watch Road capture, immediate warning visibility, delayed warning visibility, and pressure-priority protection against generic status churn.
- Strategy-profile pressure review for Safe Beginner, Greedy Economy, Fast Army, and Retinue + Training Yard II.
- Manual Cinderfen pressure checklist for Emmanuel with 1 to 5 ratings for warning clarity, timing, fairness, usefulness, fun, and frustration.
- Explicit evidence-backed no-change decision: no pressure copy, timing, status-duration, defeat-tip, telemetry, e2e, scope, wave-nudge, or balance change.
- v0.8 direction brief recommending technical performance/e2e runtime work before any pressure-specific simulator-only reinforcement experiment.
- v0.7.3 report: `docs/V073_REAL_INPUT_PRESSURE_PLAYTEST_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 334 tests during phase gates.
- `npm run build`: passed with the known Phaser vendor large-chunk warning during phase gates.
- `npm run validate:content`: passed during phase gates.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests during pressure review/polish/report gates.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes during pressure review/polish/report gates.
- Pressure telemetry remains 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 12 quiet/untriggered pressure runs, 149 warnings, 147 losses after pressure, 0 simulated reinforcement applications, and no enemy-pressure analyzer warnings.
- `git diff --check`: passed during phase gates.

### Next

- Recommended next goal: v0.8 technical performance/e2e runtime pass, with Tutorial v2 onboarding refinement as the safer player-facing alternative.
- Emmanuel should still run the manual pressure checklist before any pressure-specific v0.8 work.
- If pressure work resumes, start with simulator-only `reinforce_next_wave`; do not promote live reinforcement, route contesting, defensive hold behavior, workers, real enemy construction, dynamic enemy economy, new maps, new units, new factions, rewards, save changes, or broad systems.

## v0.7.2 Human-Paced Cinderfen Pressure Review - 2026-05-09

This checkpoint reviews Cinderfen pressure feel and warning readability without expanding Enemy Strategic Pressure into workers, enemy construction, economy AI, new maps, new units, new factions, rewards, save changes, live reinforcements, capture-site contest AI, defensive-hold behavior, or broad systems.

### Included

- Human-paced pressure review protocol and browser review notes.
- Seeded browser evidence and screenshot inspection for Cinderfen Crossing pressure warnings.
- Seeded browser evidence and screenshot inspection for Cinderfen Watch pressure warnings.
- Explicit no-change pressure readability decision: no warning copy, timing, status-duration, defeat-tip, telemetry, e2e, scope, or wave-nudge change.
- Retinue + Training Yard II pressure review documented as a saved-progress power watchpoint, not a pressure bug.
- Greedy Economy and Fast Army pressure review with no tuning applied.
- Fresh next-action decision keeping `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only.
- v0.7.2 report: `docs/V072_PRESSURE_PLAY_REVIEW_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 334 tests during the report gate.
- `npm run build`: passed with the known Phaser vendor large-chunk warning during the report gate.
- `npm run validate:content`: passed during the report gate.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 5.2m during the report gate.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes during the report gate.
- Pressure telemetry remains 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 12 quiet/untriggered pressure runs, 149 warnings, 147 losses after pressure, 0 simulated reinforcement applications, and no enemy-pressure analyzer warnings.
- `git diff --check`: passed during the report gate.

### Next

- Recommended next goal: v0.7.3 real-input Cinderfen pressure playtest.
- Focus on warning noticeability during actual unit commands, Cinder Shrine salience, Watch Road fairness, Greedy Economy timeout clarity, Fast Army quick-clear feel, and Retinue + Training Yard II power.
- Only after stronger human evidence should v0.8 consider a simulator-only `reinforce_next_wave` experiment.
- Continue postponing workers, real enemy construction, dynamic enemy economy, new maps, new units, new factions, rewards, save changes, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, broad systems, live reinforcements, capture-site contest AI, and defensive-hold behavior.

## v0.7.1 Enemy Pressure Feel Review and Warning Polish - 2026-05-09

This checkpoint reviews, polishes, and hardens Enemy Strategic Pressure V1 without expanding it into real enemy construction, workers, economy AI, new maps, new units, new factions, rewards, save changes, live reinforcements, capture-site contest AI, defensive-hold behavior, or broad systems.

### Included

- Pressure feel audit for Cinderfen Crossing and Cinderfen Watch.
- Clearer pressure warning copy and pressure-specific defeat tips.
- Pressure battle-status priority with a longer read window.
- Objective battle-status priority above pressure so `Cinder Shrine Surge` and capture feedback stay readable.
- Focused pressure e2e hardening for visible warning priority, Tutorial no-pressure protection, and skirmish no-pressure protection.
- Clearer simulator report wording with readable pressure plan/stage labels, triggered/quiet run counts, and per-strategy pressure reads.
- Pressure balance review with no tuning applied.
- Action promotion gate keeping `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only.
- v0.7.1 report: `docs/V071_ENEMY_PRESSURE_FEEL_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 334 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 5.3m during the final gate.
- Focused pressure e2e: passed with 2 Playwright tests in 43.1s during visibility hardening.
- `npm run test:e2e:release`: passed with 67 Playwright tests in 32.9m during the final gate.
- `npm run test:e2e:release:shard1`: passed with 55 Playwright tests in 28.2m during the final gate.
- `npm run test:e2e:release:shard2`: passed with 12 Playwright tests in 5.0m during the final gate.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes.
- Pressure telemetry: 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 12 quiet/untriggered pressure runs, 149 warnings, 147 losses after pressure, 0 simulated reinforcement applications, and no enemy-pressure analyzer warnings.
- Production preview smoke: passed at `http://127.0.0.1:57931/`; title, main menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and zero browser console errors were verified.
- `git diff --check`: passed.

### Next

- Human-play Cinderfen Crossing and Cinderfen Watch to judge warning salience and fairness.
- Keep follow-up limited to copy, timing, scope, telemetry, or a simulator-first tiny combat experiment only if human evidence justifies it.
- Continue postponing workers, real enemy construction, dynamic enemy economy, new maps, new units, new factions, rewards, save changes, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, broad systems, live reinforcements, capture-site contest AI, and defensive-hold behavior.

## v0.7 Enemy Strategic Pressure V1 - 2026-05-09

This checkpoint adds the first controlled enemy commander pressure prototype. It preserves the frozen v0.3 Cinderfen Route Baseline, v0.3.1 polish layer, v0.4 technical groundwork, v0.5 safety gate, v0.6 tutorial foundation, and v0.6.1 tutorial feel polish. It does not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

### Included

- Enemy Strategic Pressure research audit, design spec, and final report.
- Data model and metadata for `causeway_contest_pressure` and `ashen_watch_captain_pressure`.
- Content validation for pressure plan ids, stage ids, map/node references, trigger/action types, unit references, capture-site references, and forbidden worker/construction/economy fields.
- Campaign-only runtime pressure tracker for Cinderfen Crossing and Cinderfen Watch.
- Existing battle status warning copy and pressure-specific battle stats/telemetry.
- One safe existing-wave timing nudge; reinforcement, contest, and defensive-hold actions remain warning/telemetry-only.
- Pressure-aware defeat tip copy only when pressure actually triggered.
- Simulator telemetry and generated pressure balance-gate reporting.
- Targeted Playwright release coverage for Cinderfen Watch pressure and Tutorial/skirmish no-pressure guards.

### Verification

- `npm test`: passed with 44 test files and 328 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 5.4m during the balance gate.
- Focused pressure e2e: passed with 2 Playwright tests in 49.4s.
- `npm run test:e2e:release`: passed with 67 Playwright tests in 29.4m during the e2e coverage gate.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes.
- Pressure telemetry: 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 149 warnings, 0 simulated reinforcement applications, and no enemy-pressure analyzer warnings.
- `git diff --check`: passed.

### Next

- Human-play Cinderfen Crossing and Cinderfen Watch for pressure warning salience and fairness.
- Keep follow-up limited to copy, timing, scope, telemetry, or a tiny combat effect only if human evidence justifies it.
- Continue postponing workers, real enemy construction, dynamic enemy economy, new maps, new units, new factions, rewards, save changes, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, and broad systems.

## v0.6.1 Tutorial Feel Polish - 2026-05-09

This checkpoint finishes a small Browser-evidenced Tutorial / Proving Grounds feel pass. It preserves the existing no-reward, non-persistent tutorial shell and does not add maps, units, factions, rewards, save-version changes, tutorial persistence, campaign progression, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

### Included

- Visible Browser review of main-menu Tutorial entry, desktop first objective, mobile-short first objective, Exit Tutorial, and console output.
- New review doc: `docs/V061_TUTORIAL_FEEL_REVIEW.md`.
- Mobile-short overlay priority polish so the tutorial panel renders above transient battle feedback instead of being interrupted by the battle status banner.
- Responsive layout assertion that protects tutorial overlay z-index priority over battle status feedback.
- v0.6.1 updates to the tutorial polish plan, readability surrogate review, and tutorial feel audit.

### Verification

- `npm test`: passed with 42 test files and 315 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:layout -- --grep "tutorial entry"`: passed with 4 Playwright tests in 43.2s.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 4.9m.
- `npm run test:e2e:layout`: passed with 25 Playwright tests in 12.4m.
- Production preview Browser smoke: passed at `http://127.0.0.1:57919/`; title, Tutorial launch/exit, first overlay, and zero browser warnings/errors were verified.

### Next

- Human-play the full twelve-step tutorial at normal speed before adding any tutorial content.
- Keep future follow-up limited to readability, overlay hierarchy, and no-reward completion clarity unless a narrow verified bug appears.
- Continue postponing rewards, campaign integration, save persistence, new maps, new units, new factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, and broad systems.

## v0.6 Tutorial Onboarding And Testing Foundation - 2026-05-08

This checkpoint polishes and hardens the playable Tutorial / Proving Grounds shell while preserving the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, v0.4 technical groundwork, v0.5 save/content-validation gate, and no-reward tutorial policy. It does not add rewards, save-version changes, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, campaign progression, or broad systems.

### Included

- Tutorial human-feel surrogate audit.
- Tutorial copy tightening and hierarchy polish.
- Mobile-short overlay width and footer layout polish.
- Session-only no-reward completion notice on the main menu.
- Tutorial e2e runtime placement review keeping full completion in smoke for now.
- Test-only semantic command-log V1 helper used by exactly one tutorial completion smoke path.
- Command-log V1 plan and report.
- Tutorial accessibility checks for polite live-region semantics, described instruction/condition text, and explicit button labels.
- Desktop/2026 visual-direction plan, planning only.
- v0.6 onboarding/testing foundation report.

### Verification

- Phase 11 report gate and final full verification passed.
- `npm test`: passed with 42 test files and 315 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 4.8m during the final gate.
- `npm run test:e2e:layout`: passed with 25 Playwright tests in 12.5m after accessibility polish.
- `npm run test:e2e:release`: passed with 65 Playwright tests in 28.9m during the final gate.
- `npm run test:e2e:release:shard1`: passed with 53 Playwright tests in 24.0m.
- `npm run test:e2e:release:shard2`: passed with 12 Playwright tests in 4.9m.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes and no telemetry diff.
- `git diff --check`: passed.
- Production preview smoke: passed at `http://127.0.0.1:57918/`; title, main menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and zero browser console errors were verified.

### Next

- Recommended next long-running goal: human-paced Tutorial / Proving Grounds review and small v0.6.1 tutorial feel polish.
- Keep command-log V1 test-only and at one consumer unless a concrete second test path needs it.
- Continue postponing rewards, campaign integration, save persistence, new maps, new units, new factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, and broad systems until their gates are explicit and green.

## Tutorial / Proving Grounds Playable Shell - 2026-05-08

This checkpoint implements the first playable Tutorial / Proving Grounds shell on top of the v0.5 safety gate. It preserves the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, v0.4 technical groundwork, and v0.5 save/content-validation gate. It does not add rewards, save-version changes, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, campaign progression, or broad systems.

### Included

- Main-menu Tutorial launch surface.
- Validated playable tutorial metadata for `proving_grounds_basics`.
- Dedicated `tutorial` battle launch mode with rewards disabled.
- Existing-content Tutorial / Proving Grounds shell on `first_claim` using transient Warlord Aster data.
- Lightweight tutorial HUD overlay with current objective, instruction, hint, progress, completion condition, Next Objective, Complete Tutorial, and Exit Tutorial.
- Linear twelve-step objective model for camera, selection, movement, capture, resources, Command Hall, Barracks, Militia, rally point, Rally Banner, safe pressure, and completion.
- Non-persistent no-reward completion and exit paths back to the main menu.
- XP/veterancy guard for rewards-disabled tutorial kills.
- Save/persistence audit, tutorial content-validation gate, readability surrogate review, and playable-shell report.
- Unit, content-validation, smoke e2e, and layout e2e coverage for the tutorial shell.

### Verification

- Phase 12 report verification and final full gate passed.
- `npm test`: passed with 42 test files and 315 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 5.2m.
- `npm run test:e2e:release`: passed with 65 Playwright tests in 28.5m.
- `npm run test:e2e:release:shard1`: passed with 53 Playwright tests in 24.4m.
- `npm run test:e2e:release:shard2`: passed with 12 Playwright tests in 4.9m.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes and no telemetry diff.
- `git diff --check`: passed.
- Production preview smoke: passed at `http://127.0.0.1:57916/`; title, main menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and zero browser console errors were verified.

### Next

- Human-play Tutorial / Proving Grounds for length, clarity, mobile readability, building/training/rally timing, and no-reward completion clarity.
- Keep follow-up polish small: copy tightening, overlay hierarchy, completion clarity, and layout spacing only.
- Continue postponing rewards, campaign integration, save persistence, new maps, new units, new factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, and broad systems until their gates are explicit and green.

## v0.5 Save Content Validation Gate - 2026-05-08

This checkpoint builds the v0.5 safety foundation before broad mechanics or new content expansion. It preserves the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, and v0.4 technical groundwork. It does not add playable tutorial content, gameplay balance changes, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, monetization code, or broad army-management systems.

### Included

- File-backed save fixtures and test utilities under `tests/fixtures/saves/`.
- Fixture-based save migration and normalization tests for V1, V2, settings-only, invalid JSON, affixed inventory, legacy equipment, campaign progress, retinue, rivals, trophies, Chapter 2, and Cinderfen route state.
- Expanded save compatibility documentation and current save-version policy; save version remains `2`.
- Stronger content validation for campaign graph references, maps, reward tables, repeat rewards, event/town effects, modifiers, map objectives, enemy AI references, and tutorial metadata.
- Standalone `npm run validate:content` gate.
- Campaign graph and reward economy report.
- Command-log replay feasibility study recommending a future test-only semantic replay slice, not production replay.
- Simulator determinism report and tests locking the simulator matrix/schema and deterministic summary behavior.
- Candidate A, Tutorial / Proving Grounds, selected as the future vertical-slice candidate.
- Tutorial / Proving Grounds design brief plus a non-playable metadata-only scaffold.

### Verification

- Phase 14 documentation-gate verification passed.
- `npm test`: passed with 40 test files and 298 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 10 Playwright tests in 4.5m.
- `npm run test:e2e:release`: passed with 59 Playwright tests in 28.4m.
- `npm run test:e2e:release:shard1`: passed with 49 Playwright tests in 23.9m.
- `npm run test:e2e:release:shard2`: passed with 10 Playwright tests in 4.4m.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes.
- `git diff --check`: passed.
- Production preview smoke: passed at `http://127.0.0.1:57915/`; title, main menu copy, New Campaign, Continue Campaign, Skirmish Setup, and zero browser console errors were verified.

### Next

- Recommended next long-running goal after full v0.5 verification: implement the first Tutorial / Proving Grounds playable shell using existing content only.
- Keep the first tutorial implementation non-rewarding, validation-first, and save-compatible.
- Continue postponing workers, enemy construction, full new factions, new maps, diplomacy, procedural generation, crafting, multiplayer, monetization code, and broad army-management systems until their gates are explicit and green.

## v0.4 Overnight Autonomous Progress Checkpoint - 2026-05-08

This checkpoint completes the extended v0.4 technical, UX, save-safety, route-review, and planning pass while preserving the frozen v0.3 Cinderfen Route Baseline and frozen v0.3.1 polish release. It does not add gameplay, change balance, alter save format, or add maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, monetization code, or broad systems.

### Included

- Bundle analyzer report refreshed and the current production chunks documented.
- Test/dev hook production audit refreshed; no accidental large production leak was found.
- Analyzer-backed optimization decision recorded as no additional code optimization.
- E2E sharding plan and scripts verified while preserving the full 59-test release gate.
- One test-only rally wait in `tests/e2e/deep-flow.spec.ts` hardened against timing flake without changing gameplay.
- Settings readability copy clarified for colorblind minimap team markers and small-screen command-panel guidance.
- Save compatibility audited in `docs/SAVE_COMPATIBILITY_AUDIT.md`, with one new test preserving valid Chapter 2 selected chapter/node state.
- Automated route-feel surrogate review added in `docs/V04_ROUTE_FEEL_SURROGATE_REVIEW.md`.
- Full-game architecture docs expanded for fifteen future-system tracks, including modding/data-driven content, tutorial/onboarding, monetization/packaging, and recommended order.
- Tiny no-gameplay polish backlog added in `docs/V04_POLISH_BACKLOG.md`.

### Verification

- `npm test`: passed with 38 test files and 271 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run test:e2e:smoke`: passed with 10 Playwright tests in 4.6m.
- `npm run test:e2e:release`: passed with 59 Playwright tests in 27.8m.
- `npm run test:e2e:release:shard1`: passed with 49 Playwright tests in 23.0m.
- `npm run test:e2e:release:shard2`: passed with 10 Playwright tests in 4.2m.
- `npm run playtest:sim`: passed with 255 deterministic runs across 85 campaign battle nodes.
- `git diff --check`: passed.
- Production preview smoke: passed at `http://127.0.0.1:57911/`; main menu, New Campaign, Continue Campaign, Skirmish Setup, and browser console error checks passed.

### Next

- Recommended next long-running goal: v0.5 save/content-validation gate.
- Add fixture-based migration tests, future content validation rules, deterministic command-log feasibility notes, and one explicitly approved vertical-slice candidate before broad mechanics.
- Continue postponing workers, enemy construction, full new factions, new maps, diplomacy, procedural generation, crafting, multiplayer, monetization code, and broad army-management systems until their gates are explicit and green.

## v0.4 Autonomous Goal Progress Checkpoint - 2026-05-07

This checkpoint advances v0.4 technical/readability planning while preserving the frozen v0.3 Cinderfen Route Baseline and frozen v0.3.1 polish release. It does not add gameplay, change balance, alter saves, or add maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, or broad systems.

### Included

- Settings readability/accessibility polish: clearer toggle labels and hints, UI Scale explanation, Fog of War Override labels, and a broader keyboard/control reference.
- New accessibility plan: `docs/V04_ACCESSIBILITY_READABILITY_PLAN.md`.
- New planning-only full-game architecture docs:
  - `docs/FULL_GAME_ROADMAP.md`
  - `docs/SYSTEMS_EXPANSION_RISK_REGISTER.md`
  - `docs/V05_SYSTEMS_DESIGN_BRIEF.md`
- Existing bundle analyzer, hook audit, no-op second optimization decision, and e2e shard scripts were validated and left behavior-preserving.

### Verification

- `npm test`: passed with 38 test files and 270 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run test:e2e:smoke`: passed with 10 Playwright tests.
- `npm run test:e2e:release`: passed with 59 Playwright tests in 26.1m.
- `npm run playtest:sim`: passed with 255 deterministic runs across 85 campaign battle nodes.
- `git diff --check`: passed.
- Production preview smoke: passed at `http://127.0.0.1:57705/`; main menu loaded and browser console errors stayed at 0.

### Next

- Recommended next milestone: v0.5 save/content-validation gate before broad mechanics.
- Continue postponing workers, enemy construction, full new factions, new maps, diplomacy, procedural generation, crafting, multiplayer, and broad army-management systems until their gates are explicit and green.

## v0.3.1 Polish Release Frozen - 2026-05-06

The v0.3.1 polish release is now frozen. v0.3 remains the Cinderfen Route Baseline content release; v0.3.1 is a polish/readability/performance-audit/test-maintenance release on top of that baseline. This freeze does not add gameplay, change balance, refactor code, or add maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, durability, or broad systems.

### Freeze Verification

- `npm test`: passed with 38 test files and 270 tests.
- `npm run build`: passed with the known Vite large-chunk warning only.
- `npm run test:e2e -- --reporter=line`: passed with 59 Playwright tests in 28.6m.
- `npm run playtest:sim`: passed with 255 deterministic runs across 85 campaign battle node/profile summaries.
- `git diff --check`: passed with no whitespace errors.
- Production preview smoke: passed at `http://127.0.0.1:4188/`; main menu loaded with `Prototype v0.3` / `Cinderfen Route Baseline`, New Campaign reached Campaign Map, Continue Campaign returned to Campaign Map, Skirmish Setup opened, and browser console errors stayed at 0.

### Frozen Scope

- v0.3.1 preserves the frozen v0.3 Cinderfen content route: Chapter 1 through `ashen_outpost`, then `cinderfen_overlook`, optional `cinderfen_waystation`, `cinderfen_crossing`, `cinderfen_watch`, and `cinderfen_aftermath`.
- v0.3.1 includes mobile/readability audit coverage, Cinderfen copy/hierarchy polish, route-complete clarity, Results copy improvements, performance/bundle audit documentation, e2e runtime audit documentation, and safe shared e2e helper cleanup.
- No risky bundle optimization or test coverage reduction was implemented.
- Release report: `docs/V031_POLISH_RELEASE_REPORT.md`.
- Next phase: **v0.4 planning or technical optimization**.
- Recommended next work: human readability review of the frozen route, measurement-first performance optimization, or explicit e2e default/release-gate script planning.
- Postponed next work: workers, enemy construction, new factions, new maps, new units, diplomacy, procedural systems, crafting, durability, and broad systems.

## v0.3 Cinderfen Route Baseline Frozen - 2026-05-05

The v0.3 Cinderfen Route Baseline is now frozen. This freeze does not add gameplay, change balance, refactor code, or add maps, factions, units, workers, enemy construction, diplomacy, procedural generation, crafting, durability, or broad loot systems.

### Freeze Verification

- `npm test`: passed with 38 test files and 268 tests.
- `npm run build`: passed with the known Vite large-chunk warning only.
- `npm run test:e2e -- --reporter=line`: passed with 52 Playwright tests.
- `npm run playtest:sim`: passed with 255 deterministic runs across 85 campaign battle node/profile summaries.
- `git diff --check`: passed with no whitespace errors.
- Production preview smoke: passed at `http://127.0.0.1:4187/`; main menu loaded with `Prototype v0.3` / `Cinderfen Route Baseline`, New Campaign, Continue Campaign, Skirmish Setup, and Campaign Map did not crash, and browser console errors stayed at 0.

### Frozen Scope

- Frozen route: Chapter 1 through `ashen_outpost`, then `cinderfen_overlook`, optional `cinderfen_waystation`, `cinderfen_crossing`, `cinderfen_watch`, and `cinderfen_aftermath`.
- Cinderfen Aftermath remains the end of the current playable v0.3 slice.
- Next phase: **v0.3.1 polish and human readability review**.
- Allowed next work: copy clarity, UX hierarchy, mobile/readability checks, small bug fixes, and controlled polish on the existing frozen route.
- Postponed next work: workers, enemy construction, new factions, diplomacy, procedural generation, crafting, new maps, and broad systems.

## v0.3 Cinderfen Route Baseline Candidate - 2026-05-04

This checkpoint promotes the current Cinderfen route to the v0.3 vertical-slice baseline candidate. It does not add gameplay, change balance, or add maps, factions, units, workers, enemy construction, diplomacy, procedural generation, crafting, durability, or broad loot systems. The visible in-game menu now labels the playable build as `Prototype v0.3` with the subtitle `Cinderfen Route Baseline`; v0.2 remains the previous systems baseline.

### Route Baseline

- Current playable route: Chapter 1 through `ashen_outpost`, then `cinderfen_overlook`, optional `cinderfen_waystation`, `cinderfen_crossing`, `cinderfen_watch`, and `cinderfen_aftermath`.
- Main menu product copy is aligned with the current route baseline: `Prototype v0.3` / `Cinderfen Route Baseline`.
- `docs/V03_CINDERFEN_ROUTE_BASELINE.md` records the current route order, rewards summary, simulator summary, e2e summary, known risks, forbidden next steps, and recommended next steps.
- The Chapter 2 reward-economy audit is complete: first clears remain useful, repeat clears now pay only tiny XP/resources, and repeat battle item rolls are disabled for the Cinderfen battles.
- Chapter 2 Playwright helper cleanup is complete in `tests/e2e/chapter2-helpers.ts`, with behavior-preserving helpers for post-Ashen setup, Waystation service flows, Crossing/Watch launch, shrine capture, and test-only victory fast-forwards.
- Chapter 1 reward values and route stability remain unchanged.

### Current Release Verification Expectations

- `npm test`: latest checkpoint passed with 38 test files and 268 tests.
- `npm run build`: latest checkpoint passed with the known Vite large-chunk warning only.
- `npm run test:e2e -- --reporter=line`: latest full suite passed with 52 Playwright tests.
- `npm run playtest:sim`: latest simulator baseline passed with 255 deterministic runs across 85 campaign battle node/profile summaries, no structural too-hard nodes, no structural too-easy nodes, Ashen Outpost beatable, no Stronghold warnings, and Cinderfen repeat rewards reduced to tiny non-item payouts.
- Optional `npm run preview` plus Browser Use smoke remains useful for a visible production-preview check and browser console-error check.

### Next Phase

- Next phase: **automated route readiness + polish freeze**.
- Best current work is verification, readability, UX, copy clarity, mobile density checks, and controlled polish on the existing route.
- Continue to avoid workers, enemy construction, new factions, new maps, new units, diplomacy, procedural campaign, crafting, durability, broad loot complexity, full trophy rooms, and broad army-management systems unless explicitly requested.

## v0.2.1 Prototype Baseline Candidate - 2026-05-03

This checkpoint packages the v0.2 feature baseline with the follow-up technical and UX stabilization work. It does not add gameplay or change balance. At that historical checkpoint, the visible in-game menu labeled the playable prototype as `Prototype v0.2`; `v0.2.1` was the release-baseline candidate for docs, verification expectations, refactor state, and HUD/fog regression coverage.

### Completed Since v0.2

- CampaignRules module split completed: `CampaignRules.ts` is now a compatibility facade over focused pure campaign modules for nodes, choices, rewards, reputation, modifiers, town services, and rival hooks.
- HUD interaction polish completed: battle command hover no longer flickers under routine HUD refresh, and long side-panel scroll positions are preserved across refreshes.
- Captured-site fog polish completed: player-owned captured resource sites remain locally revealed after the capturing units move away.
- Permanent Playwright regression coverage added for command hover stability, side-panel scroll preservation, captured resource-site fog visibility, and desktop/tablet/mobile battle command reachability.
- Rival/Nemesis Persistence V1 and Rival Rewards and Trophies V1 are part of the completed v0.2.1 baseline rather than the next milestone.

### Historical v0.2.1 Verification Expectations

- `npm test`: expected to pass with 36 test files and 210 tests.
- `npm run build`: expected to pass with the known Vite large-chunk warning only.
- `npm run test:e2e -- --reporter=line`: latest full suite passed with 49 Playwright tests after the HUD/fog regression coverage was added.
- `npm run playtest:sim`: latest simulator baseline passed with 180 deterministic runs, no structural too-hard nodes, no structural too-easy nodes, Ashen Outpost beatable, and no Stronghold warnings.
- Optional Browser Use preview sanity remains recommended for a visible production-preview check and browser console-error check.

### Historical Next Phase

- This milestone is superseded by the v0.3 Cinderfen route baseline candidate above.
- Before adding Chapter 2 content, do a human-paced readability pass on retinue, rival rewards/trophies, HUD hover/scroll feel, captured-site fog readability, and Ashen Outpost pressure.
- Continue to avoid workers, enemy construction, new factions, diplomacy, procedural campaign, crafting, durability, broad loot complexity, full trophy rooms, and broad army-management systems unless explicitly requested.

## v0.2 Prototype Baseline - 2026-05-02

This release baseline captures the current playable Ascendant Realms prototype so it is easier to share, test, and continue from. It does not represent a content-complete game; it is the stable RTS/RPG campaign spine with Unit Veterancy V1, Retinue Camp V1, Enemy Hero / Rival Commander V1, Rival/Nemesis Persistence V1, and Rival Rewards and Trophies V1 included.

### Campaign And Skirmish Structure

- Main menu flow labels the build as `Prototype v0.2` with the subtitle `v0.2 Prototype - Campaign, Stronghold, Affixes, Veterancy and Retinue`, and supports New Campaign, Continue Campaign, Skirmish, Hero Inventory, Settings, Asset Gallery, Info, and Reset Save.
- The Border Marches mini-campaign has eight authored nodes: Border Village, Old Stone Road, Marcher Camp, Aether Well Ruins, Bandit Hillfort, Chapel of the Marches, Refugee Caravan, and Ashen Outpost.
- Campaign battle nodes and standalone skirmishes launch through the shared `BattleLaunchRequest` path.
- Skirmish mode includes First Claim, Broken Ford, and Ashen Outpost with difficulty and AI-personality selection.
- Results return battle rewards, campaign node rewards, victory/defeat actions, and save updates through the shared Results flow.

### Hero Progression

- Heroes have class, origin, stats, XP, levels, skill points, skill trees, and class abilities.
- Current classes are Warlord, Arcanist, and Shepherd.
- Current equipment slots are weapon, armor, and trinket, with item instances stored in inventory and equipment referencing instance IDs.
- Victory rewards can grant XP, resources, and item instances; unique duplicate rewards convert into campaign resources.
- Equip Now and Hero Inventory both persist equipment changes and recalculate hero stats.

### RTS Battle Loop

- Battles include hero and unit selection, movement, attack commands, attack-move, projectiles, capture sites, neutral camps, enemy bases, and victory/defeat resolution.
- Player construction supports Barracks, Mystic Lodge, and Watchtower placement with previews, construction progress, production locks, and rally points.
- Unit training queues support Militia, Rangers, and Acolytes with visible progress and cancel/refund behavior.
- Research upgrades include current data-driven battle upgrades such as infantry, armor, ranger, and Aether study lines.
- Unit Veterancy V1 gives player non-hero units battle-local XP, Recruit/Seasoned/Veteran/Elite ranks, modest stat bonuses, selected-unit rank display, rank-up feedback, and Notable Veterans in victory Results.
- Retinue Camp V1 lets campaign victories save a small number of surviving Seasoned+ veterans, shows them on the Campaign Map, deploys them in future campaign battles, and removes them permanently if they die.
- Enemy Hero / Rival Commander V1 adds three named Ashen commanders: Gorak Emberhand on Bandit Hillfort, Veyra of the Cinders on Aether Well Ruins, and Captain Malrec on Ashen Outpost, with scout feedback, minimap markers, modest abilities, XP/objective/results credit, and simulator telemetry.
- Rival/Nemesis Persistence V1 saves commander encounters, defeats, victories against the player, last outcomes, dispositions, small repeat-encounter modifiers, Campaign Map intel, and Results consequence copy.
- Rival Rewards and Trophies V1 adds data-driven once-only first-defeat rewards, duplicate prevention, persistent trophy records, Results reward copy, and compact Campaign Map trophy display.
- Enemy AI expands, trains, defends, and sends pressure waves through data-driven personalities.

### Fog And Minimap

- Fog of war uses unseen, explored, and visible grid states, with Story difficulty able to disable fog.
- Enemy and neutral units/buildings are hidden outside current vision.
- The minimap renders units, buildings, capture sites, camps, rally points, pings, and the camera viewport.
- Minimap click-to-pan, fog toggles, alert pings, and colorblind minimap palette support are covered by automated browser tests.

### Stronghold Development

- Stronghold Development is a compact two-tier persistent-upgrade system, not a city-builder.
- Tier I upgrades are Training Yard I, Watch Post I, Quartermaster Stores I, Chapel Corner I, and Ranger Paths I.
- Tier II upgrades are Training Yard II, Watch Post II, Quartermaster Stores II, Chapel Corner II, and Ranger Paths II.
- Tier II upgrades require their matching Tier I upgrade.
- Implemented effects stay compact: starting units, starting resources, hero HP/Mana multipliers, warning lead time, Watchtower range, building vision, first-building construction speed, Militia/Ranger training speed, and Training Yard II's +1 Retinue capacity.

### Reputation Effects

- Reputation ranks exist for Free Marches, Common Folk, Old Faith, Ashen Covenant, and the Sylvan Concord placeholder.
- Shared thresholds are Friendly at 25, Honored at 50, Disliked at -25, and Hostile at -50.
- Common Folk Friendly discounts Marcher Camp services.
- Free Marches Friendly discounts Stronghold Crown costs.
- Old Faith Friendly improves Chapel Aether rewards.
- Ashen Covenant Hostile adds minor Ashen-node pressure through the existing launch-modifier path.
- Campaign choice cards show costs, adjusted rewards, reputation deltas, resulting reputation value/rank, modifiers, and completion behavior.

### Randomized Item Affixes V1

- Item instances can roll small, slot-filtered affixes from `src/game/data/itemAffixes.ts`.
- Current affixes are Sturdy, Sharp, Guarding, Aether-Touched, Commanding, Faithful, Swift, Embered, and Ranger's.
- Rarity rules are common 0-1, uncommon 1, rare 1-2, epic 2, and legendary 2-3 affixes.
- Deterministic affix generation exists for tests and scripted e2e rewards.
- Affixes persist on item instances, old empty-affix saves remain valid, and equipped affixes contribute to hero stats.
- Results and Inventory display affix names, base stats, affix stat contribution, total item stats, and equip preview deltas.

### Automated Playtest Simulator

- `npm run playtest:sim` regenerates `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json`.
- The simulator currently runs 180 deterministic campaign battle runs across 60 profile-node summaries.
- Profiles include no Stronghold upgrades, Tier I paths, a Tier II Quartermaster path, and retinue-aware profiles for one Veteran Militia, one Veteran Ranger, and mixed retinue.
- Telemetry includes assigned rival commander id, defeated state, attack-join timing, losses involving the rival, objective completion, rival state before/after, rival outcome, active rival modifiers, first-defeat reward state, duplicate prevention, and trophy-earned state.
- Latest simulator status: no too-easy nodes, no structural too-hard nodes, Ashen Outpost beatable, and no Stronghold warnings.

### Historical Verification Status

Latest full verification recorded at the v0.2 point after Rival Rewards and Trophies V1:

- `npm test`: 36 test files, 210 tests passing.
- `npm run build`: passing with the known Vite large-chunk warning.
- `npm run test:e2e -- --reporter=line`: 45 Playwright tests passing.
- `npm run playtest:sim`: 180 simulated runs passing.

Known release caveat: the Vite production build reports that the main Phaser bundle is larger than the default 500 kB chunk warning threshold. This is tracked as a warning, not a failure.

### Historical Next Milestone

- At the v0.2 baseline point, the next recommended pass was Rival Rewards Balance And Readability Review.
- This is now superseded by the v0.3 Cinderfen route baseline candidate above; the current next phase is `automated route readiness + polish freeze`.
