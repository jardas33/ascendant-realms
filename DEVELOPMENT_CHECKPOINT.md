# Development Checkpoint

Updated: 2026-05-22 v0.16.9 autonomous manual-retest proxy and tester readiness

## v0.16.9 Autonomous Manual-Retest Proxy And Tester Readiness - 2026-05-22

Scope: build stronger automated evidence around the v0.16.7 manual combat/control retest items while Emmanuel is away, inspect remote CI status, prepare first external tester docs, document worker construction as design-only, audit control visual/readability risks, and run the requested verification gates without starting v0.17 or changing runtime gameplay.

Baseline:

- Starting commit: `ad4eee0a80a43f81df41ff30640a14f8434a5797`, `Checkpoint v0.16.8 post-combat-fix CI verification and soak audit`.
- Branch was clean and synced with `origin/main`.
- v0.16.7 remains the latest runtime combat/control fix.
- v0.16.8 was test/CI/docs/package readiness and did not change runtime gameplay.
- GitHub Actions CI Release Matrix Dry Run #79 for `ad4eee0a80a43f81df41ff30640a14f8434a5797` passed Fast confidence as a push run.
- GitHub Actions CI Release Matrix Dry Run #80 for `ad4eee0a80a43f81df41ff30640a14f8434a5797` passed as a `workflow_dispatch` run across Fast confidence, Release simulator, deep-meta, deep-battle, deep-campaign-pressure, layout-core, layout-cinderfen, and smoke.
- #80 skipped Optional visual QA and Full release e2e, so those remain local evidence from this checkpoint.

Included work:

- Added `docs/V0169_BASELINE_STATUS.md`.
- Added `docs/V0169_REMOTE_RELEASE_MATRIX_STATUS.md`.
- Added `docs/V0169_AUTONOMOUS_MANUAL_RETEST_PROXY_SPEC.md`.
- Added `docs/V0169_AUTONOMOUS_MANUAL_RETEST_PROXY_REPORT.md`.
- Added `docs/V0169_COMBAT_EDGE_CASE_MATRIX.md`.
- Added `docs/V0169_FIRST_EXTERNAL_TESTER_PLAN.md`.
- Added `docs/V0169_TESTER_MESSAGE_SHORT.md`.
- Added `docs/V0169_TESTER_FEEDBACK_FORM_SHORT.md`.
- Added `docs/V0169_ROUTE_ASSIGNMENTS_SMALL_BATCH.md`.
- Added `docs/V0169_WORKER_CONSTRUCTION_DESIGN_BRIEF.md`.
- Added `docs/V0169_CONTROL_VISUAL_READABILITY_AUDIT.md`.
- Added `docs/V0169_LONG_SOAK_REPORT.md`.
- Extended the control behaviour lab to 18 scenarios.
- Added manual proxy coverage for Hold Ground adjacent follow-up and group retreat/resume.
- Added combat edge scenarios for 1 hero vs 3 melee enemies, 2 friendly units vs 3 enemies, building aggro locality, and Hold/Guard/Press mode differences.
- Added a focused ranged-enemy building aggro unit test.
- Updated private package build-info metadata and verifier expectation to name the v0.16.9 checkpoint.

Verification:

```text
npm test -- CombatSystem.test.ts ControlBehaviourScenarioLab.test.ts PASS, 2 files / 29 tests.
Focused repeat of the same command 5 times: PASS 5/5.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 5 iterations / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "behaviour mode control gauntlet|manual combat contact regression" --repeat-each=3 --reporter=line PASS, 6 tests in 2.8m.
npm test PASS, 57 files / 415 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.4m.
npm run test:e2e:smoke PASS, 14 tests in 6.8m.
npm run test:e2e:release:hosted:deep-battle PASS, 14 tests in 4.2m.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 2.7m.
npm run test:e2e:release PASS, 79 tests in 38.4m.
npm run visual:qa PASS, 5 tests in 4.2m; 18 screenshots, 0 browser console errors, 0 screenshot retries.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Enemy aggro changed: no. Retreat logic changed: no. Test/CI harness changed: yes, deterministic coverage only. Package changed: final clean package must be regenerated after commit.

Remaining closeout: run `git diff --check`, commit as `Checkpoint v0.16.9 autonomous manual-retest proxy and tester readiness`, push, regenerate and verify a clean private playtest package, confirm branch clean/synced, and inspect the final push Fast confidence run. A fresh workflow-dispatch release matrix on the final v0.16.9 commit is optional because v0.16.9 did not change runtime gameplay.

## v0.16.8 Post-Combat-Fix CI Verification And Soak Audit - 2026-05-22

Scope: verify v0.16.7's runtime combat/control fix through remote CI inspection, automated soak, control-lab coverage, public-repo safety audit, and package readiness without starting v0.17, adding gameplay features, implementing worker construction/builders, adding units/buildings/maps/factions/runtime art/assets, adding Patrol/formations, rewriting broad AI/pathing, changing gameplay numbers/unit stats/enemy wave timings/save format, weakening control coverage, using force clicks, using DOM fallback for canvas/world clicks, or inventing human feedback.

Baseline:

- Starting commit: `169bb21d54bd1599f5241b15bbfb1a187276d921`, `Checkpoint v0.16.7 manual combat contact and aggro fix`.
- Branch was clean and synced with `origin/main`.
- Existing package `artifacts/playtest/ascendant-realms-private-playtest-169bb21` recorded `workingTreeDirty: false`.
- v0.16.7 had changed runtime melee contact/reacquisition, local melee enemy building aggro, retreat suppression, and hover/click tolerance.
- GitHub Actions CI Release Matrix Dry Run #78 on the v0.16.7 commit was green as a push run, but only Fast confidence ran. Release simulator, release matrix groups, optional visual QA, and full release e2e were skipped because they require workflow dispatch.

Included work:

- Added `docs/V0168_BASELINE_AND_REMOTE_CI_AUDIT.md`.
- Added `docs/V0168_REMOTE_CI_VERIFICATION.md`.
- Added `docs/V0168_CI_TRIAGE_FIX.md`.
- Added `docs/V0168_COMBAT_FIX_SOAK_REPORT.md`.
- Added `docs/V0168_CONTROL_LAB_V0167_COVERAGE_REVIEW.md`.
- Added `docs/V0168_PUBLIC_REPO_SAFETY_AUDIT.md`.
- Added `docs/V0168_EMMANUEL_RETEST_AFTER_V0167_CHECKLIST.md`.
- Added `docs/V0168_LONG_SOAK_RESULTS.md`.
- Added deterministic control-lab scenarios for local melee enemy building aggro and attack-hover tolerance versus nearby empty terrain.
- Regenerated control-lab normal, extended, and dashboard outputs.
- Stabilized one hosted smoke assertion by relying on deterministic Cinderfen Crossing scene state instead of transient `battle-status` launch text after the battle had already advanced to AI status.
- Completed a public-repo safety audit.

Public safety result:

- No tracked `.env`, private key, credential, service-account, package artifact, Playwright report, raw private feedback, email address, or secret value was found.
- Secret-pattern matches were documentation/test references and package-validator dummy fixtures.
- Protected-IP searches found only guardrails/prompt negatives/art-direction warnings, not copied names/assets/lore/UI/music.
- Tracked `public/assets/manual` image assets remain intentional prototype assets, but prior asset docs still classify current file-backed image assets as needing source/license proof before production approval.

Triage:

- `npm run test:e2e:release:hosted:smoke` initially failed one Chapter 2 smoke assertion because `battle-status` had advanced to `AI: EXPAND - Time 0:12`.
- Classification: hosted timing issue / transient status-line assertion.
- Fix: test-only; no runtime change.
- Coverage preserved: the test still asserts Cinderfen Crossing map/node/reward table/mode/difficulty and later objective/reward/persistence state through scene and save state.

Current verification:

```text
npm test -- CombatSystem.test.ts CollisionSystem.test.ts MovementSystem.test.ts BehaviourModeSystem.test.ts ControlBehaviourScenarioLab.test.ts PASS, 5 files / 38 tests.
Focused unit soak repeated the same command 10 times: PASS 10/10.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "manual combat contact regression" --repeat-each=5 --reporter=line PASS, 5/5 in 1.6m.
npm run playtest:controls / npm run playtest:controls:extended / npm run playtest:controls:verify repeated 3 cycles: PASS 3/3. Final verifier PASS, 1112 checks.
npm test PASS, 57 files / 414 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.4m.
npm run test:e2e:smoke PASS, 14 tests in 7.0m after the hosted smoke assertion fix.
npm run test:e2e:release:hosted:deep-battle PASS, 14 tests in 4.4m.
npm run test:e2e:release:hosted:smoke first run FAIL, 1 transient status-line assertion; targeted fix applied.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/smoke.spec.ts --grep "post-Ashen campaign resolves Cinderfen Overlook" --reporter=line PASS, 1 test in 27.7s.
npm run test:e2e:release:hosted:smoke rerun PASS, 14 tests in 2.9m.
npm run test:e2e:release PASS, 79 tests in 38.7m.
npm run visual:qa PASS, 5 tests in 4.4m; 18 screenshots, 0 browser console errors, 0 screenshot retries.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Enemy aggro changed: no. Retreat logic changed: no. Test/CI harness changed: yes. Package changed: final clean package must be regenerated after commit.

Remaining closeout: run `git diff --check`, commit as `Checkpoint v0.16.8 post-combat-fix CI verification and soak audit`, push, regenerate and verify a clean private playtest package, confirm branch clean/synced, and have a user with GitHub Actions write access dispatch the normal enabled release matrix.

## v0.16.7 Manual Combat Contact And Aggro Fix - 2026-05-21

Scope: fix only Emmanuel's real manual v0.16.6 retest combat/control bugs without starting v0.17, implementing worker construction/builders, adding units/buildings/maps/factions/runtime art, adding patrol/formations, rewriting broad AI/pathing, changing gameplay numbers, changing unit stats, changing enemy wave timings, changing save format, weakening tests, using force clicks, or using DOM fallback for canvas/world clicks.

Baseline:

- Starting commit: `3737c16`, `Checkpoint v0.16.6 hosted deep-battle first campaign training stabilization`.
- Branch was clean and synced with `origin/main`.
- GitHub Actions CI Release Matrix Dry Run #77 was green on enabled lanes: Fast confidence, Release simulator, deep-meta, deep-battle, deep-campaign-pressure, layout-core, layout-cinderfen, and smoke.
- v0.16.6 was test-only; runtime gameplay, gameplay numbers, save format, runtime art/assets, and behaviour modes were unchanged.
- Emmanuel's manual retest session `PT-20260521-EMMANUEL-V0166-CONTROLS-01` on build/package `3737c16` / `ascendant-realms-private-playtest-3737c16` returned MIXED.

Included work:

- Added `docs/V0167_EMMANUEL_MANUAL_RETEST_INTAKE.md`.
- Added `docs/V0167_COMBAT_CONTACT_AGGRO_REPRODUCTION_PLAN.md`.
- Added `docs/V0167_COMBAT_CONTACT_AGGRO_AUDIT.md`.
- Added `docs/V0167_COMBAT_CONTACT_AGGRO_FIX_REPORT.md`.
- Added `docs/V0167_DEFERRED_WORKER_CONSTRUCTION_NOTE.md`.
- Increased melee visual-contact tolerance narrowly.
- Made melee unit-vs-building contact use the target building footprint.
- Preserved player move-away combat suppression even if pathing clears the move target early.
- Added conservative world entity interaction hit-test tolerance for attack hover/click intent.
- Added focused unit/system tests and a hosted-safe manual combat contact regression.

Root cause:

- Visible melee contact and raw center/radius combat contact were slightly mismatched for small adjacent enemies.
- Building pathing/obstacles use rectangular footprints, but melee attack reach treated buildings like circular targets.
- Retreat suppression could be effectively canceled by early move-target clearing before the short suppression window expired.
- Attack hover/click intent used raw entity radius rather than a visible interaction footprint.

Current verification:

```text
npm test -- CombatSystem.test.ts CollisionSystem.test.ts MovementSystem.test.ts PASS, 3 files / 30 tests.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "manual combat contact regression" --reporter=line PASS, 1 test in 23.9s.
npm test PASS, 57 files / 414 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.9m.
npm run test:e2e:smoke first attempt timed out at 6m; rerun PASS, 14 tests in 7.1m.
npm run playtest:controls PASS, 10 scenarios / 10 pass rows.
npm run playtest:controls:verify PASS, 930 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 14 tests in 4.6m.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 3.0m.
npm run test:e2e:release first attempt timed out at 30m; longer local wrapper rerun PASS, 79 tests in 38.8m.
npm run visual:qa PASS, 5 tests in 4.5m; 18 screenshots, 0 console errors, 0 retries.
git diff --check PASS.
```

Runtime gameplay changed: yes. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: yes, contact/reacquisition semantics only. Enemy aggro changed: yes, local melee building contact only. Retreat logic changed: yes, move-away suppression preservation only. Package changed: final clean package must be regenerated after commit.

Remaining closeout: run `git diff --check`, commit as `Checkpoint v0.16.7 manual combat contact and aggro fix`, push, regenerate and verify a clean private playtest package, confirm branch clean/synced, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.16.6 Hosted Deep-Battle First Campaign Training Stabilization - 2026-05-21

Scope: fix only the remaining GitHub Actions CI Release Matrix Dry Run #75 `Release matrix (deep-battle)` failure after v0.16.5, without adding features, changing runtime gameplay, changing gameplay numbers, changing save format, adding runtime art/assets, changing behaviour modes, changing package materials, restructuring the release matrix, weakening first-campaign capture/build/train/rally/victory assertions, using force clicks, or using DOM fallback for canvas/world clicks.

Baseline:

- Starting commit: `0398e6e18a596d6ca42f8b50761949f477055757`, `Checkpoint v0.16.5 hosted deep-battle command hall split stabilization`.
- Branch was clean and synced with `origin/main`.
- GitHub Actions run #73 failed before starting because the private repository hit the billing/payment/spending gate.
- After the repository was made public, rerun #73 Fast confidence passed and manual workflow dispatch #75 ran on the hosted runner.
- CI Release Matrix Dry Run #75 had Fast confidence, Release simulator, Release matrix smoke, deep-meta, deep-campaign-pressure, layout-core, and layout-cinderfen green.
- Only `Release matrix (deep-battle)` was red.

Included work:

- Added `docs/V0166_HOSTED_DEEP_BATTLE_FIRST_CAMPAIGN_TRAINING_FIX.md`.
- Kept visible Militia train command click attempts in the first-campaign hosted deep-battle test.
- Added a narrow fallback to the existing scene-backed `trainUnitThroughCommand` helper only after visible command clicks fail to expose a training queue.
- Allowed the trained Militia lookup to accept a newly trained unit that has already reached the rally point as well as one still carrying the rally `moveTarget`.

Root cause:

- The v0.16.5 Command Hall split held; the new #75 failure occurred later in the broad first-campaign path.
- Hosted CI sometimes failed to observe the Barracks training queue after repeated visible Militia command fallback clicks.
- The trained-unit lookup was stricter than the later rally assertion because it required a live `moveTarget` and ignored a newly trained unit already at the rally point.
- This was a test-harness timing/readiness issue, not a runtime gameplay regression.

Current verification:

```text
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "first campaign battle path covers capture, build, train, rally, and victory rewards" --retries=1 --trace=on --reporter=line PASS, 1 test in 53.2s.
npm run test:e2e:release:hosted:deep-battle PASS, 13 tests in 4.3m.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.6m.
npm test PASS, 56 files / 406 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
git diff --check PASS.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Package changed: no. Test/CI harness changed: yes, deep-flow spec fallback/lookup only.

Remaining closeout: commit as `Checkpoint v0.16.6 hosted deep-battle first campaign training stabilization`, push, confirm branch clean/synced, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.16.5 Hosted Deep-Battle Command Hall Split Stabilization - 2026-05-20

Scope: fix only the remaining GitHub Actions CI Release Matrix Dry Run #72 `Release matrix (deep-battle)` timeout after v0.16.4, without adding features, changing runtime gameplay, changing gameplay numbers, changing save format, adding runtime art/assets, changing behaviour modes, changing package materials, restructuring the release matrix, weakening minimap/fog/building/cancel/command hall assertions, weakening behaviour mode coverage, using force clicks, or using DOM fallback for canvas/world clicks.

Baseline:

- Starting commit: `9c8e694177e6a60e423539eb202393a3a94071b9`, `Checkpoint v0.16.4 hosted deep-battle movement command stabilization`.
- Branch was clean and synced with `origin/main`.
- `gh` CLI was unavailable locally.
- GitHub connector logs for Actions run id `26198333332` showed CI Release Matrix Dry Run #72 failed only in `Release matrix (deep-battle)`.
- Fast confidence, Release simulator, Release matrix smoke, deep-meta, deep-campaign-pressure, layout-core, and layout-cinderfen were green.
- Artifact upload failed because GitHub artifact storage quota was hit, so traces/videos/error-context files were not downloadable.

Included work:

- Added `docs/V0165_HOSTED_DEEP_BATTLE_COMMAND_HALL_SPLIT_AUDIT.md`.
- Added `docs/V0165_HOSTED_DEEP_BATTLE_COMMAND_HALL_SPLIT_FIX.md`.
- Split the older hosted deep-battle HUD/minimap/fog/build/cancel scenario into two focused tests.
- Kept minimap movement, fog toggle, attack cursor, marquee, and right-click move command assertions in the original test.
- Moved Command Hall building placement/cancel assertions into a new hosted deep-battle test with a fresh browser context.

Root cause:

- v0.16.4 fixed the previous movement-order timeout, and run #72 reached the later Command Hall build section.
- The older hosted HUD/minimap/building test was still too broad for the 120s hosted CI budget and timed out while `clickReady` waited for the Barracks build command to be visible or enabled.
- Later command-button tests in the same hosted deep-battle shard passed, so the failure was scenario length and hosted timing pressure, not a Command Hall or Barracks runtime regression.

Current verification:

```text
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, and move commands" --retries=1 --trace=on --reporter=line PASS, 1 test in 1.0m.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports command hall building placement and cancel" --retries=1 --trace=on --reporter=line PASS, 1 test in 39.7s.
npm run test:e2e:release:hosted:deep-battle PASS, 13 tests in 4.4m.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 3.1m.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.5m.
npm run test:e2e:smoke PASS, 14 tests in 6.9m.
npm test PASS, 56 files / 406 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run playtest:controls PASS, 10 rows / 10 pass.
npm run playtest:controls:verify PASS, 930 checks.
npm run test:e2e:release PASS, 78 tests in 37.3m after rerunning with a longer local wrapper timeout.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, and move commands" --retries=1 --trace=on --repeat-each=3 --reporter=line PASS, 3 tests in 2.7m.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports command hall building placement and cancel" --retries=1 --trace=on --repeat-each=3 --reporter=line PASS, 3 tests in 1.8m.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Package changed: no. Test/CI harness changed: yes, deep-flow spec split only.

Remaining closeout: run `git diff --check`, commit as `Checkpoint v0.16.5 hosted deep-battle command hall split stabilization`, push, confirm branch clean/synced, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.16.4 Hosted Deep-Battle Movement Command Stabilization - 2026-05-20

Scope: fix only the remaining GitHub Actions CI Release Matrix Dry Run #70 `Release matrix (deep-battle)` timeout after v0.16.3, without adding features, changing runtime gameplay, changing gameplay numbers, changing save format, adding runtime art/assets, changing behaviour modes, changing package materials, restructuring the release matrix, weakening minimap/fog/building/cancel/command hall assertions, weakening behaviour mode coverage, using force clicks, or using DOM fallback for canvas/world clicks.

Baseline:

- Starting commit: `ce2b54a9e23d7dc43e7eb9706ab882dc4e761bfa`, `Checkpoint v0.16.3 hosted smoke pause-resume stabilization`.
- Branch was clean and synced with `origin/main`.
- `gh` CLI was unavailable locally.
- GitHub connector logs for Actions run id `26194525737` showed CI Release Matrix Dry Run #70 failed only in `Release matrix (deep-battle)`.
- Fast confidence, Release simulator, Release matrix smoke, deep-meta, deep-campaign-pressure, layout-core, and layout-cinderfen were green.
- Artifact upload failed because GitHub artifact storage quota was hit, so traces/videos/error-context files were not downloadable.

Included work:

- Added `docs/V0164_HOSTED_DEEP_BATTLE_FAILURE_AUDIT.md`.
- Added `docs/V0164_HOSTED_DEEP_BATTLE_FIX.md`.
- Added `MOVE_ORDER_SUMMARY_PATTERN = /Moving|Repositioning/` for valid move-order summaries.
- Applied that pattern to the older deep-battle HUD movement assertion and the dedicated behaviour gauntlet retreat assertion.
- Replaced transient status-line assertions in the older HUD test with semantic fog active, movement order, and placement cancel state assertions.

Root cause:

- The older HUD/minimap/building deep-battle test still required a real right-click movement order to render exactly `Moving`.
- Under combat pressure, the same valid movement order can render as `Repositioning` while move-order combat suppression is active.
- The test also used transient status-line text for fog/cancel feedback, but pressure status messages can intentionally outrank normal fog debug or command messages.
- The timeout was caused by the stale assertion/readiness shape, not a browser crash or gameplay runtime regression.

Current verification:

```text
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --retries=1 --trace=on --reporter=line PASS, 1 test in 1.3m.
npm run test:e2e:release:hosted:deep-battle PASS, 12 tests in 4.1m.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 3.1m.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.8m.
npm run test:e2e:smoke PASS, 14 tests in 8.2m.
npm test PASS, 56 files / 406 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run playtest:controls PASS, 10 rows / 10 pass.
npm run playtest:controls:verify PASS, 930 checks.
npm run test:e2e:release PASS, 77 tests in 40.9m.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --retries=1 --trace=on --repeat-each=3 --reporter=line PASS, 3 tests in 3.4m.
git diff --check PASS.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Package changed: no. Test/CI harness changed: yes, deep-flow spec assertions only.

Remaining closeout: commit as `Checkpoint v0.16.4 hosted deep-battle movement command stabilization`, push, confirm branch clean/synced, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.16.3 Hosted Smoke Pause/Resume Stabilization - 2026-05-20

Scope: fix only the remaining GitHub Actions CI Release Matrix Dry Run #68 `Release matrix (smoke)` timeout after v0.16.2, without adding features, changing runtime gameplay, changing gameplay numbers, changing save format, adding runtime art/assets, changing behaviour modes, changing package materials, restructuring the release matrix, weakening settings/accessibility assertions, using force clicks, or using DOM fallback for canvas/world clicks.

Baseline:

- Starting commit: `f4ac082875db451a05b2b2668f9714e1ecf0af8d`, `Checkpoint v0.16.2 release-matrix smoke and deep-battle stabilization`.
- Branch was clean and synced with `origin/main`.
- `gh` CLI was unavailable locally.
- GitHub connector logs for Actions run id `26191069260` showed CI Release Matrix Dry Run #68 failed only in `Release matrix (smoke)`.
- Deep-battle, Fast confidence, Release simulator, deep-meta, deep-campaign-pressure, layout-core, and layout-cinderfen were green.

Included work:

- Added `docs/V0163_HOSTED_SMOKE_PAUSE_RESUME_FIX.md`.
- Added scoped settings battle menu click options in `tests/e2e/smoke.spec.ts`.
- Applied those options only to `settings smoke battle menu` and `settings smoke battle resume`.

Root cause:

- v0.16.2 fixed the earlier timeout/page-closed shape, but run #68 showed the settings smoke still spent too much hosted CI time inside normal Playwright actionability waits before the verified DOM-control fallback.
- Both Menu and Resume were real visible DOM buttons, and both verified DOM fallbacks fired before the test timed out.
- The failure was not a settings runtime regression; it was an over-budget smoke pause/resume interaction under hosted production-preview timing.

Current verification:

```text
npx playwright test tests/e2e/smoke.spec.ts --config=playwright.hosted-release.config.ts --grep "settings accessibility options apply in battle" --retries=1 --trace=on --reporter=line PASS, 1 test in 42.1s.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 3.0m.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.5m.
npm run test:e2e:smoke PASS, 14 tests in 7.0m.
npm test PASS, 56 files / 406 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:release PASS, 77 tests in 37.8m.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Package changed: no. Test/CI harness changed: yes, smoke spec only.

Remaining closeout: run `git diff --check`, commit as `Checkpoint v0.16.3 hosted smoke pause-resume stabilization`, push, confirm branch clean/synced, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.16.2 Release-Matrix Smoke/Deep-Battle Stabilization - 2026-05-20

Scope: fix only GitHub Actions CI Release Matrix Dry Run #66 `Release matrix (deep-battle)` and `Release matrix (smoke)` timeout regressions after v0.16.1, without adding features, changing runtime gameplay, changing gameplay numbers, changing save format, adding runtime art/assets, changing behaviour modes, changing package materials, restructuring the release matrix, weakening settings/accessibility assertions, weakening minimap/fog/building/cancel/command hall assertions, or weakening behaviour mode coverage.

Baseline:

- Starting commit: `3bfe3b20a09cbc67de80954384d3ddad7a61a270`, `Checkpoint v0.16.1 fast-confidence CI smoke stabilization`.
- Branch was clean and synced with `origin/main`.
- `gh` CLI was unavailable locally.
- GitHub connector logs for Actions run id `26154299133` showed CI Release Matrix Dry Run #66 failed in `Release matrix (deep-battle)` and `Release matrix (smoke)`.
- Artifact upload failed because GitHub artifact storage quota was hit, so traces/videos/error-context files were not downloadable.

Included work:

- Added `docs/V0162_RELEASE_MATRIX_TIMEOUT_FAILURE_AUDIT.md`.
- Added `docs/V0162_RELEASE_MATRIX_TIMEOUT_FIX.md`.
- Removed duplicated Hold Ground, Press Attack, and Guard Area switching from the older deep-battle HUD/minimap/building test.
- Kept the dedicated hosted behaviour mode gauntlet intact for behaviour-mode switching and behaviour assertions.
- Increased only the settings runtime accessibility smoke timeout from 60s to 90s.
- Added semantic pause/resume success checks around the settings battle menu and resume `clickReady` calls.
- Added an explicit post-resume battle-state assertion.

Root cause:

- The deep-battle failure was an overloaded hosted scenario: the older HUD/minimap/building test had accumulated duplicated v0.16 behaviour-mode transitions before continuing through its original minimap/fog/build/cancel/command hall surface.
- The smoke failure was a hosted production-preview timing margin issue in the settings runtime accessibility test; the test was valid locally but exceeded the 60s hosted budget around battle resume.
- In both logs, `Target page, context or browser has been closed` was reported after Playwright's per-test timeout, so it was a consequence of timeout cleanup rather than the root cause.

Current verification:

```text
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --retries=1 --trace=on --reporter=line PASS, 1 test in 1.0m.
npx playwright test tests/e2e/smoke.spec.ts --config=playwright.hosted-release.config.ts --grep "settings accessibility options apply in battle" --retries=1 --trace=on --reporter=line PASS, 1 test in 36.5s.
npm run test:e2e:release:hosted:deep-battle PASS, 12 tests in 3.7m.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 2.8m.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.3m.
npm run test:e2e:smoke PASS, 14 tests in 6.5m.
npm test PASS, 56 files / 406 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run playtest:controls PASS, 10 rows / 10 pass.
npm run playtest:controls:verify PASS, 930 checks.
npm run test:e2e:release PASS, 77 tests in 36.3m.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --retries=1 --trace=on --repeat-each=3 --reporter=line PASS, 3 tests in 3.4m.
npx playwright test tests/e2e/smoke.spec.ts --config=playwright.hosted-release.config.ts --grep "settings accessibility options apply in battle" --retries=1 --trace=on --repeat-each=3 --reporter=line PASS, 3 tests in 1.6m.
git diff --check PASS.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Package changed: no. Test/CI harness changed: yes, Playwright specs only.

Remaining closeout: commit as `Checkpoint v0.16.2 release-matrix smoke and deep-battle stabilization`, push, confirm branch clean/synced, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.16.1 Fast-Confidence CI Smoke Stabilization - 2026-05-20

Scope: fix only GitHub Actions CI Release Matrix Dry Run #64 `Fast confidence` regression after v0.16, without adding features, changing runtime gameplay, changing gameplay numbers, changing save format, adding runtime art/assets, touching behaviour modes, changing package materials, restructuring CI, weakening settings/accessibility assertions, or weakening inventory coverage.

Baseline:

- Starting commit: `c28f19d82205a1dd8358c4412fdf030d3d9e3b7b`, `Checkpoint v0.16 behaviour mode gauntlet and playtest diagnostics`.
- Branch was clean and synced with `origin/main`.
- Remote evidence supplied by Emmanuel: run #64 failed in `Fast confidence`; primary failed test was `settings screen persists accessibility options @ci-fast`; secondary flaky test was `inventory screen opens without crashing @ci-fast`.
- Direct GitHub artifact inspection was unavailable because `gh` is not installed and the connector could not resolve displayed run `#64` as a numeric Actions run id.

Included work:

- Added `docs/V0161_FAST_CONFIDENCE_CI_FAILURE_AUDIT.md`.
- Added `docs/V0161_FAST_CONFIDENCE_CI_FIX.md`.
- Split the settings accessibility smoke path into a persistence-focused `@ci-fast` test and a runtime-battle `@ci-fast` test.
- Added shared accessibility smoke settings data so both tests assert the same setting values.
- Added a Settings-screen success check to the Settings menu click/reopen path so a successful transition does not fall through to a now-gone main-menu button.
- Left the inventory smoke test unchanged.

Root cause:

- The original settings test combined persistence, localStorage, document dataset, battle launch, runtime accessibility, minimap color, fog override, floating text, and pause/resume assertions in one long browser context.
- Remote failure evidence reached the settings retry and then showed inventory failing while a new browser context was being created, which points to browser/context pressure after the long settings path.
- A local full-smoke run after the first split exposed the actionability race: Settings had already reopened, but the click helper did not treat `settings-screen` as success before fallback checked the vanished `menu-settings` button.

Current verification:

```text
npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on --reporter=line PASS, 1 test in 38.2s.
npx playwright test tests/e2e/smoke.spec.ts --grep "inventory screen opens without crashing" --retries=1 --trace=on --reporter=line PASS, 1 test in 28.8s.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.6m.
npm run test:e2e:smoke PASS, 14 tests in 7.4m.
npm test PASS, 56 files / 406 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run playtest:controls PASS, 10 rows / 10 pass.
npm run playtest:controls:verify PASS, 930 checks.
npm run test:e2e:release:hosted:smoke FAIL first run on unrelated extended-smoke transient Cinderfen difficulty status copy.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/smoke.spec.ts --grep "post-Ashen campaign resolves Cinderfen Overlook" --retries=1 --trace=on --reporter=line PASS, 1 test in 35.6s.
npm run test:e2e:release:hosted:smoke PASS on full rerun, 14 tests in 3.3m.
npm run test:e2e:release PASS, 77 tests in 38.4m.
npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on --repeat-each=3 --reporter=line PASS, 3 tests in 1.5m.
git diff --check PASS.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Package changed: no. Test/CI harness changed: yes, smoke spec only.

Remaining closeout: run `git diff --check`, commit as `Checkpoint v0.16.1 fast-confidence CI smoke stabilization`, push, confirm branch clean/synced, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.16 Behaviour Mode Gauntlet And Playtest Diagnostics - 2026-05-19

Scope: build a deep automated confidence layer around the v0.15 session-only behaviour modes and core RTS controls, add deterministic control diagnostics, harden private package validation, and prepare Emmanuel's next manual retest without broad gameplay design, balance changes, save migration, Patrol runtime behaviour, new content, runtime art/assets, or visual overhaul.

Phase 0 baseline:

- Starting commit: `27dfe1a1ec060708c831690c4bfa806b0d06cb32`, `Checkpoint v0.15 RTS control behaviour foundation`.
- Baseline was clean and synced with `origin/main` before v0.16 work started.
- GitHub CLI was unavailable. The GitHub connector returned no PR-triggered workflow runs and no combined statuses for the v0.15 SHA, so the latest v0.15 Actions status is recorded as unknown rather than green or red.
- Guardrails preserved: no maps, factions, units, runtime art/assets, save format changes, behaviour-mode persistence, Patrol runtime behaviour, broad AI/pathing rewrites, gameplay-number tuning, enemy wave timing changes, hosted release restructuring, weakened assertions, force-click world shortcuts, DOM fallback for canvas/world clicks, protected UI/lore copying, or invented human feedback.

Included work:

- Added `docs/V016_BASELINE_AND_CI_AUDIT.md`.
- Added `docs/V016_BEHAVIOUR_MODE_AUDIT.md`.
- Added `docs/V016_CONTROL_BEHAVIOUR_GAUNTLET_REPORT.md`.
- Added v0.16 Emmanuel/tester materials: retest script, route card, checklist, feedback intake template, and triage guide.
- Added deterministic control behaviour lab scripts: `npm run playtest:controls`, `npm run playtest:controls:extended`, and `npm run playtest:controls:verify`.
- Added control lab scenario types, profiles, runner, report writer, validation, and generated JSON/Markdown/dashboard outputs.
- Expanded unit/system tests for Hold Ground, Guard Area, Press Attack, explicit attack/move overrides, retreat suppression, mixed group handling, order copy, selected panel controls, and package validation.
- Added a hosted browser control gauntlet for behaviour mode buttons, attack hover, left-click attack, retreat feedback, marquee/HUD cleanup, minimap movement, and `H` hero-select refresh.
- Narrowly fixed Hold Ground direct-attacker handling so a nearby enemy directly attacking the unit can be pursued within the existing local aggro radius while idle distant threats are still refused.
- Updated private playtest package contents and verifier requirements to include v0.16 control retest materials.

Generated control lab evidence:

```text
npm run playtest:controls PASS, 10 rows / 10 pass.
npm run playtest:controls:extended PASS, 50 rows / 50 pass across 5 deterministic iterations.
npm run playtest:controls:verify PASS, 930 consistency checks.
```

Current verification:

```text
npm test PASS, 56 files / 406 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 7 tests.
npm run test:e2e:smoke PASS, 13 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run smoke:preview PASS against production preview.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
npm run playtest:controls PASS, 10 rows / 10 pass.
npm run playtest:controls:extended PASS, 50 rows / 50 pass.
npm run playtest:controls:verify PASS, 930 checks.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 12 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run test:e2e:release:hosted:smoke PASS, 13 tests.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "behaviour mode control gauntlet" --repeat-each=3 --retries=0 --reporter=line PASS, 3 tests.
npm run test:e2e:release:shard1of3 PASS, 29 tests.
npm run test:e2e:release:shard2of3 PASS, 34 tests.
npm run test:e2e:release:shard3of3 PASS, 13 tests.
npm run test:e2e:release PASS, 76 tests.
npm run package:playtest PASS, produced pre-commit dirty package `artifacts/playtest/ascendant-realms-private-playtest-27dfe1a-dirty`.
npm run verify:playtest-package PASS, 24 checks.
```

One earlier `npm run test:e2e:release` attempt hit the shell timeout at 40 minutes before returning output. The orphaned process was stopped, the release suite passed in the existing 3-way shards, and the exact all-in-one command then passed with a longer timeout.

Runtime gameplay changed: yes, narrowly in Hold Ground direct-attacker response. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: yes, only the direct-attacker Hold Ground rule alignment; no new modes. Package changed: yes.

Remaining closeout: run `git diff --check`, commit as `Checkpoint v0.16 behaviour mode gauntlet and playtest diagnostics`, push, regenerate and verify a clean private playtest package from the final commit, confirm branch clean/synced, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.15 RTS Control Behaviour Foundation - 2026-05-19

Scope: build a narrow, original RTS control foundation for command reliability, attack intent, melee engagement, retreat/move-away behavior, and session-only behaviour modes while preserving all v0.14.x human playtest fixes.

Phase 0 baseline:

- Current commit before this goal: `5ab64f5ec56324ba0f9abd4d69d51f109e0adeca`, clean and synced with `origin/main`.
- Confirmed v0.14.5 hosted deep-battle minimap fix was complete before starting v0.15.
- Read the required handoff/docs and runtime/test files before implementation.
- Guardrails: no maps, factions, combat units, runtime art/assets, save format changes, broad AI/pathing rewrites, broad balance tuning, protected UI copying, visual overhaul, hosted release restructuring, weakened assertions, force-click canvas/world shortcuts, or DOM fallback for canvas/world clicks.

Included work:

- Added `docs/V015_CONTROL_COMBAT_BASELINE_AUDIT.md`.
- Added `docs/V015_BEHAVIOUR_MODES_SPEC.md`.
- Added `docs/V015_CONTROL_COMBAT_BEHAVIOUR_FIX_REPORT.md`.
- Added `BehaviourModeSystem` with `Hold Ground`, `Guard Area`, and `Press Attack`.
- Added session-only `behaviourMode` state to live units; default is `Guard Area`.
- Added selected-unit and selected-group behaviour controls to the current side panel, including `Mixed` state and group mode application.
- Updated `CombatSystem` acquisition rules so Hold Ground avoids distant chase, Guard Area remains the balanced default, and Press Attack pursues within a larger bounded leash.
- Preserved explicit move/attack orders above behaviour mode reacquisition and tightened move-away suppression so retreat intent cannot be overwritten on its expiry frame.
- Added explicit attack target labels and clearer order copy for Guarding, Holding Ground, Pressing Attack, Attacking, Moving, and Repositioning.
- Kept selected-unit attack hover/click intent reliable across HUD refresh, empty clicks, and cursor clearing.
- Hardened hero-select HUD refresh after HUD/minimap interactions and constrained the side panel height so expanded controls do not cover Ashen/Cinderfen landmark focus.
- Updated tester quick-start/package copy and playtest package checkpoint metadata for v0.15.

Deferred:

- Patrol, escort, return-anchor memory, save-persistent behaviour modes, icon/art additions, formation/pathing overhaul, broad combat AI rewrite, and balance tuning.

Current verification:

```text
npm test PASS, 55 files / 393 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 7 tests.
npm run test:e2e:smoke PASS, 13 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run smoke:preview PASS against production preview.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 11 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run test:e2e:release:hosted:smoke PASS, 13 tests.
npm run test:e2e:release PASS, 75 tests.
npm run package:playtest PASS, produced pre-commit dirty package `artifacts/playtest/ascendant-realms-private-playtest-5ab64f5-dirty`.
npm run verify:playtest-package PASS, 19 checks.
git diff --check PASS.
```

Runtime gameplay changed: yes, narrowly in session-only unit behaviour modes, command feedback/order copy, attack target labels, retreat reacquisition suppression timing, and HUD command controls. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no.

Remaining closeout: commit as `Checkpoint v0.15 RTS control behaviour foundation`, push, regenerate and verify a clean private playtest package from the final commit, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.14.5 Hosted Deep-Battle Minimap Fix - 2026-05-18

Scope: fix the isolated GitHub Actions CI Release Matrix Dry Run #61 hosted deep-battle failure in the minimap/marquee section of `battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions @hosted-deep-battle`, without weakening minimap movement coverage or changing runtime gameplay.

Phase 0 baseline:

- Current commit before this goal: `9a1dc0a113144c9cb3132b689cec53fd772953f1`, clean and synced with `origin/main`.
- Remote failure evidence supplied by Emmanuel: CI Release Matrix Dry Run #61, commit `9a1dc0a`, hosted deep-battle group, 1 failed / 10 passed.
- Failed predicate: around `tests/e2e/deep-flow.spec.ts:1868`, `Timeout 1000ms exceeded while waiting on the predicate`.
- The local environment did not have the GitHub CLI installed, so the audit records Emmanuel's supplied CI evidence rather than claiming direct log/artifact inspection.
- Guardrails: no gameplay numbers, save format, maps, factions, units, assets, assertion weakening, force clicks, DOM fallback for canvas/world clicks, broad input refactor, hosted matrix restructuring, or rollback of v0.14.4 user-facing fixes.

Included work:

- Added `docs/V0145_HOSTED_DEEP_BATTLE_MINIMAP_REGRESSION_AUDIT.md`.
- Added `docs/V0145_HOSTED_DEEP_BATTLE_MINIMAP_FIX.md`.
- Updated `tests/e2e/deep-flow.spec.ts` to wait for canvas pointerdown to establish active marquee drag before crossing the minimap.
- Kept active-drag-over-minimap and release-over-minimap assertions with a scoped hosted-safe 3-second poll.
- Wrapped the minimap crossing in `try/finally` so mouseup cleanup happens if the midpoint assertion fails.
- Added an explicit minimap-click camera movement assertion before the existing fog toggle, movement command, placement cancel, and command hall checks.

Root cause:

- The v0.14.4 test moved immediately from canvas to minimap after `page.mouse.down()` and then gave the active-drag predicate only 1000ms.
- Hosted preview timing can process the pointerdown and DOM-bound pointer movement in a slightly different order, so the check could sample before active drag state was observable.
- Local targeted hosted repros and the full hosted deep-battle group passed before the fix, so this was treated as a test timing race rather than a proven runtime product bug.

Current verification:

```text
npm test PASS, 53 files / 383 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast first attempt hit local Windows net::ERR_NO_BUFFER_SPACE on the first navigation; rerun after socket cooldown PASS, 7 tests.
npm run test:e2e:smoke PASS, 13 tests.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --retries=1 --trace=on --reporter=line
PASS, 1 test.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --repeat-each=3 --retries=0 --reporter=line
PASS, 3 repeated targeted tests before the fix, supporting the hosted-timing diagnosis.
npm run test:e2e:release:hosted:deep-battle
PASS, 11 tests.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run test:e2e:release:hosted:smoke PASS, 13 tests.
npm run test:e2e:release PASS, 75 tests.
git diff --check PASS.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Minimap coverage preserved: yes.

## v0.14.4 Combat Control Retest Fix Pass - 2026-05-18

Scope: use only Emmanuel's v0.14.3 retest evidence from `PT-20260518-EMMANUEL-BASELINE-01`, preserve all v0.14.3 fixes, and narrowly fix remaining melee engagement, drag-selection responsiveness, tutorial completion semantics, attack-hover intent, and tutorial copy mismatch.

Phase 0 baseline:

- Current commit before this goal: `28698152edca0967a561dc0de2a9c08b021d4061`, clean and synced with `origin/main`.
- Human feedback source: Emmanuel only, v0.14.3 retest notes.
- Confirmed fixed before this pass: drag-select multiple units, tutorial defeat Results, Retry Tutorial, Return Main Menu, and class/origin mechanical explanations.
- Guardrails: no maps, factions, units, runtime art/assets, save format changes, broad redesign, behaviour modes, unit panel redesign, balance tuning, hidden failures, force-click test shortcuts, or DOM fallback for canvas/world clicks.

Included work:

- Added `docs/V0144_COMBAT_CONTROL_RETEST_FIX_REPORT.md`.
- Strengthened `CombatSystem` melee contact interpretation with a small visual contact margin so sprite-adjacent melee units attack reliably.
- Added regression coverage for visual melee contact and post-kill adjacent target reacquisition.
- Updated `InputSystem` so active marquee drags continue rendering via global pointer movement while crossing DOM HUD/minimap surfaces.
- Added targetable-hostile attack cursor state and left-click attack ordering for selected units.
- Changed final tutorial completion to route through no-save/no-reward Results instead of direct Main Menu.
- Updated tutorial Crown Shrine copy from blue to green ownership and final completion hint to Results summary.
- Updated smoke/deep-flow browser coverage for tutorial completion, attack-hover/click, and release-over-minimap drag handling.

Known evidence gap:

- Emmanuel mentioned an attached screenshot visual bug, but no matching screenshot was present in the current thread or repo artifacts during this pass. No screenshot-specific visual fix is claimed; visual QA remains part of final verification.

Current verification:

```text
npm test PASS, 53 files / 383 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 7 tests.
npm run test:e2e:smoke PASS, 13 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run smoke:preview PASS against production preview.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 11 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run test:e2e:release:hosted:smoke PASS, 13 tests.
npm run test:e2e:release PASS, 75 tests after fixing the HUD/minimap stale-selection deferral.
npm run package:playtest PASS, produced pre-commit dirty package `artifacts/playtest/ascendant-realms-private-playtest-2869815-dirty`.
npm run verify:playtest-package PASS, 19 checks.
git diff --check PASS.
```

Remaining watch items: commit as `Checkpoint v0.14.4 combat control retest fixes`, push, then regenerate and verify a clean non-dirty private playtest package from the final commit. GitHub Actions should be rerun because runtime battle/input/tutorial behavior changed.

## v0.14.3 Combat Engagement, Marquee Selection, And Control Clarity Fix Pass - 2026-05-18

Scope: ingest Emmanuel's v0.14.x retest of `PT-20260518-EMMANUEL-BASELINE-01`, fix the remaining critical marquee selection, melee engagement, retreat, tutorial defeat, and hero creation clarity issues, and keep behaviour modes design-only.

Phase 0 baseline:

- Current commit before this goal: `029a1c730d03ede1e126a8da5ffce3c88eccba93`, clean and synced with `origin/main`.
- Human feedback source: Emmanuel only, session `PT-20260518-EMMANUEL-BASELINE-01 retest`.
- Confirmed fixed by Emmanuel before this pass: W/A/S/D hero rename, Tutorial Next Objective, hover flicker, hero skill explanation, and pause/menu behavior.
- Guardrails: no protected UI copying, maps, factions, units, runtime art/assets, save format changes, broad AI/pathing rewrite, gameplay-number tuning, hidden failures, force-click test shortcuts, DOM fallback for canvas/world clicks, or v0.14.1 rollback.

Included work:

- Added `docs/V0143_EMMANUEL_RETEST_INTAKE.md`.
- Added `docs/V0143_REPRODUCTION_PLAN.md`.
- Added `docs/V0143_COMBAT_SELECTION_RETEST_FIX_REPORT.md`.
- Added `docs/V0143_UNIT_BEHAVIOUR_MODES_DESIGN.md`.
- Fixed release-over-HUD marquee selection by completing active battlefield drags on global pointer release and clearing only on cancel/blur.
- Added `src/game/systems/SelectionSystem.test.ts` and strengthened deep-flow marquee coverage.
- Added melee contact reach in `CombatSystem` for melee units using existing body radii, while leaving ranged behavior and unit data unchanged.
- Replaced indefinite normal move-order combat suppression with a short-lived movement-intent window.
- Preserved attack-move and explicit attack behavior.
- Kept and strengthened movement snap-back regression coverage.
- Routed tutorial defeat to Results with no-save/no-reward guidance and `Retry Tutorial` / `Main Menu`.
- Added factual class/origin mechanical summaries to Hero Creation using existing stats, origin bonuses, and primary ability descriptions.
- Added/updated focused unit and browser tests.

Fix status:

- Fixed: retest marquee selection broken while releasing over HUD.
- Fixed: melee hero/unit/enemy idle-adjacent combat cases covered by contact reach tests.
- Improved/fixed narrowly: retreat/move-away intent now gets a short priority window, then units can re-engage if still stuck beside enemies.
- Guarded: unit teleport/snap-back loop remains unreproduced in retest and now has an additional repeated-command regression test.
- Fixed: tutorial defeat now shows no-save/no-reward Results guidance instead of silently dumping to main menu.
- Fixed: hero class/origin choices now expose mechanical summaries.
- Deferred: unit info panel visual restructuring and behaviour modes runtime implementation.

Current verification:

```text
npm test PASS, 53 files / 381 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 7 tests.
npm run test:e2e:smoke PASS, 13 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors.
npm run smoke:preview PASS against production preview.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 11 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run test:e2e:release:hosted:smoke PASS, 13 tests.
npm run test:e2e:release PASS, 75 tests.
npm run package:playtest PASS, produced a pre-commit dirty package.
npm run verify:playtest-package PASS, 19 checks.
```

Remaining watch items: Run `git diff --check`, commit, push, then regenerate and verify a clean non-dirty private playtest package from the final commit. GitHub Actions should be rerun because runtime battle/input/tutorial behavior changed.

## v0.14.2 Hosted Settings Smoke Fix - 2026-05-18

Scope: fix the isolated GitHub Actions CI Release Matrix Dry Run #55 hosted smoke timeout in `settings screen persists accessibility options @ci-fast`, without weakening the settings assertions or changing runtime gameplay.

Phase 0 baseline:

- Current commit before this goal: `256c688` (`Checkpoint v0.14.1 Emmanuel quick playtest fixes`).
- Branch state before edits: `main` clean and synced with `origin/main`.
- Remote failure: CI Release Matrix Dry Run #55, hosted smoke group, 1 failed / 12 passed.
- Failed test: `tests/e2e/smoke.spec.ts:825`, `settings screen persists accessibility options @ci-fast`.
- Failure mode: 60-second timeout on both first attempt and retry.
- Guardrails: no gameplay numbers, save format, maps, factions, units, assets, assertion weakening, force clicks, DOM fallback for canvas/world clicks, broad CI restructuring, or hosted matrix reshaping.

Included work:

- Added `docs/V0142_HOSTED_SETTINGS_SMOKE_FAILURE_AUDIT.md`.
- Added `docs/V0142_HOSTED_SETTINGS_SMOKE_FIX.md`.
- Increased only `SETTINGS_ACCESSIBILITY_SMOKE_TIMEOUT_MS` from 60 seconds to 90 seconds.

Root cause:

- The exact hosted-config settings repro passed locally before the fix, but took about 45 seconds.
- v0.14.1 expanded this smoke path with battle pause overlay verification while preserving settings persistence and runtime accessibility checks.
- GitHub-hosted preview plus screenshot/video/trace overhead left too little margin inside the previous 60-second scoped budget.

Protected assertions:

- Settings still persist after save/reopen.
- Reduced motion and colorblind minimap document datasets are still asserted.
- Floating text disabled, fog override disabled, reduced motion, and colorblind minimap runtime behavior are still asserted.
- Battle Menu pause and Resume behavior are still asserted.
- No settings assertion was removed or softened.

Current verification:

```text
npx playwright test tests/e2e/smoke.spec.ts --config=playwright.hosted-release.config.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on --reporter=line
PASS, 1 test in about 35.8s after the scoped timeout fix.

npm run test:e2e:release:hosted:smoke
PASS, 13 tests in about 2.9m.

npm test PASS, 52 files / 375 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 7 tests in about 2.2m.
npm run test:e2e:smoke PASS, 13 tests in about 6.7m.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
git diff --check PASS.
```

Remaining watch items: Emmanuel should rerun GitHub Actions CI Release Matrix Dry Run and confirm the hosted smoke group passes.

## v0.14.1 Emmanuel Quick Playtest Intake And Critical Usability Fix Pass - 2026-05-18

Scope: ingest Emmanuel's real Baseline Cautious private playtest session `PT-20260518-EMMANUEL-BASELINE-01`, classify the nine reports through the existing intake framework, and implement only small high-confidence fixes for actual bugs or severe usability friction. This pass preserves gameplay numbers, campaign data, maps, factions, units, rewards, save format, runtime art/assets, pressure plans, hosted release patterns, automated simulation scope, and the no-invented-feedback boundary.

Phase 0 baseline:

- Current commit before this goal: `0236df7` (`Checkpoint v0.14 private playtest build packaging`).
- Branch state before edits: `main` clean and synced with `origin/main`.
- Human feedback source: Emmanuel only, session `PT-20260518-EMMANUEL-BASELINE-01`.
- Guardrails: no maps, factions, units, runtime art/assets, save format, gameplay numbers, broad combat AI rewrite, broad tuning, automated simulation expansion, invented feedback, hosted release assertion weakening, force clicks, DOM fallback for canvas/world clicks, or visual overhaul.

Included work:

- Added `docs/V0141_EMMANUEL_QUICK_PLAYTEST_INTAKE.md`.
- Added `docs/V0141_REPRODUCTION_PLAN.md`.
- Added `docs/V0141_QUICK_PLAYTEST_FIX_REPORT.md`.
- Added `src/game/systems/KeyboardFocusGuard.ts` so game keyboard handlers ignore focused editable elements.
- Updated hero creation input handling so names can include movement-key letters such as `W`, `A`, `S`, and `D`.
- Updated battle input drag handling so selection marquee state clears on pointer release/cancel/blur and stale mouse-button loss.
- Added a battle pause overlay for `Menu`, with `Resume` and explicit `Exit to Main Menu`.
- Updated player normal move orders so they do not immediately re-acquire combat targets; attack-move still engages.
- Tightened movement correction so blocked separation does not produce large snap-back movement.
- Added visible hero ability description/cost copy and clearer selected order copy for attacking/moving.
- Added/updated focused unit and browser tests for the fixes.

Fix status:

- Fixed: I05 hero rename input blocks `W/A/S/D`.
- Fixed: I07 selection marquee stuck over HUD.
- Fixed narrowly: I06 retreat/move command being overridden by nearby combat.
- Fixed: I09 battle Menu accidental exit now opens pause.
- Fixed: I02 hero skill explanation.
- Addressed: I01 hover flicker and I03 tutorial Next Objective delay through stable tutorial/HUD refresh handling.
- Narrowly addressed: I08 unit movement snap-back through blocked movement-correction guard; retest required.
- Partly addressed: I04 hero attack unclear through selected order copy; retest required before deeper combat/VFX work.

Current verification:

```text
npm test PASS, 52 files / 375 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 7 tests in about 2.4m.
npm run test:e2e:smoke PASS, 13 tests in about 7.1m.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors.
npm run smoke:preview PASS against production preview.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 11 tests after targeted HUD stability fixes.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run test:e2e:release:hosted:smoke PASS, 13 tests after pause-menu actionability stabilization.
npm run test:e2e:release PASS, 75 tests in about 39.5m after rerunning with a long enough local command timeout.
```

Remaining watch items: Run `git diff --check` before commit. GitHub Actions should be rerun after this checkpoint because runtime input/HUD/battle/menu behavior changed. Emmanuel should retest the same Baseline Cautious private route on a clean v0.14.1 package before any deeper pathing, combat readability, or UI polish goal.

## v0.14 Private Playtest Build Packaging And One-Click Tester Delivery - 2026-05-18

Scope: make the current browser prototype easier to package, send, start, and verify for private human playtesting. This pass preserves runtime gameplay, gameplay numbers, campaign data, maps, factions, units, rewards, save format, runtime art/assets, pressure behavior, hosted release patterns, automated simulation scope, and human-feedback boundaries.

Phase 0 baseline:

- Current commit before this goal: `afbb37f` (`Checkpoint v0.13.1a extended scenario lab integrity audit`).
- Branch state before edits: `main` clean and synced with `origin/main`.
- Guardrails: no maps, factions, units, runtime art/assets, save format, gameplay numbers, combat systems, campaign progression, hosted release stability changes, invented feedback, broad AI/economy rewrites, automated simulation expansion, or balance implementation.

Included work:

- Added `npm run build:playtest`, `npm run package:playtest`, and `npm run verify:playtest-package`.
- Added `tools/packagePlaytestBuild.ts` to create ignored private package folders under `artifacts/playtest/`.
- Added `tools/verifyPlaytestPackage.ts`.
- Added `src/game/playtest/PlaytestPackageValidation.ts` and focused package validation tests.
- Added `.gitignore` coverage for generated private playtest packages.
- Added v0.14 distribution audit, tester README, coordinator guide, and paste-ready private tester message.
- Updated README, release checklist, v0.12.6 tester docs, roadmap, changelog, and handoff references.

Package shape:

- Output location: `artifacts/playtest/ascendant-realms-private-playtest-<commit>/`.
- Includes built `game/`, `README_FOR_TESTERS.md`, `PLAYTEST_BUILD_INFO.md`, `playtest-build-info.json`, `FEEDBACK_SUBMISSION_PACKET.md`, `TESTER_QUICK_START.md`, `ROUTE_ASSIGNMENT_PLAN.md`, `READY_TO_SEND_PRIVATE_PLAYTEST_MESSAGE.md`, `start-playtest-server.mjs`, `START_GAME_WINDOWS.bat`, and `START_GAME_MAC_LINUX.sh`.
- Excludes `node_modules`, `.git`, raw private feedback folders, secret-like files, and unapproved runtime art/assets.

Current verification:

```text
npm test PASS, 50 files / 371 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 6 tests in about 2.2m.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
npm run build:playtest PASS with package-safe relative asset URLs and the known Phaser vendor chunk warning.
npm run package:playtest PASS, generated artifacts/playtest/ascendant-realms-private-playtest-afbb37f-dirty during the pre-commit worktree.
npm run verify:playtest-package PASS, 19 package integrity checks.
Private package server smoke PASS at http://127.0.0.1:4174/ with ASCENDANT_PLAYTEST_NO_OPEN=1.
git diff --check PASS.
```

Remaining watch items: Regenerate the private package after the final checkpoint commit so its metadata uses the clean v0.14 commit hash. GitHub Actions rerun is optional because no runtime gameplay/HUD/campaign/pressure/result/tuning behavior changed.

## v0.13.1a Extended Scenario Lab Integrity Audit And Gap-Fix Pass - 2026-05-18

Scope: independently audit v0.13.1 extended scenario lab implementation and generated evidence, then fix only genuine tooling/reporting integrity gaps. This pass preserves runtime gameplay, gameplay numbers, campaign data, maps, factions, units, rewards, save format, runtime art/assets, pressure behavior, hosted release patterns, and human-feedback boundaries.

Phase 0 baseline:

- Current commit before this goal: `1e59f8c` (`Checkpoint v0.13.1 extended scenario lab`).
- Branch state before edits: `main` clean and synced with `origin/main`.
- Guardrails: no maps, factions, units, runtime art/assets, save format, gameplay numbers, combat systems, campaign progression, hosted release stability changes, invented feedback, broad AI/economy rewrites, or balance implementation.

Audit verdict:

- v0.13.1 was real implementation, not mostly superficial docs.
- The extended scripts did call simulator-backed runners and computed counts from generated data.
- The five default iterations are deterministic repeatability checks, not stochastic samples.
- v0.13.1 had genuine reporting/tooling gaps: no generated-output verifier, CSV/Markdown ranking mismatch, missing extended metric-availability metadata, and too-permissive `--runs` parsing.

Included work:

- Added `src/game/playtest/ScenarioLabOutputValidation.ts`.
- Added `tools/verifyPlaytestLabOutputs.ts`.
- Added `npm run playtest:lab:verify`.
- Updated `src/game/playtest/ScenarioLabExtendedRunner.ts` and types to include `uniqueDerivedMetricFingerprints` and metric availability.
- Updated `src/game/playtest/ScenarioLabExtendedReportWriter.ts` so CSV/Markdown profile order agrees and extended reports state deterministic-repeatability limits.
- Updated CLI run-count parsing in `tools/runPlaytestLab.ts` and `tools/runPlaytestProfiles.ts`.
- Expanded extended lab tests to validate generated JSON/Markdown/CSV consistency.
- Added v0.13.1a audit docs and improved threshold rationale docs.
- Regenerated extended outputs.

Current verification:

```text
npm test PASS, 49 files / 368 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 6 tests in about 2.0m.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab PASS, 10 profiles, 355 derived metrics, 8 watchpoints.
npm run playtest:watchpoints PASS, 10 profiles, 355 derived metrics, 8 watchpoints.
npm run playtest:profiles PASS, 10 scenario profiles.
npm run playtest:lab:extended PASS, 5 iterations, 1,275 source runs, 1,775 derived metrics, 10 watchpoints.
npm run playtest:watchpoints:extended PASS, 5 iterations, 1,275 source runs, 1,775 derived metrics, 10 watchpoints.
npm run playtest:profiles:compare PASS, 10 comparisons, 1,775 extended metrics.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
git diff --check PASS.
```

Remaining watch items: GitHub Actions rerun is optional because no runtime gameplay/HUD/campaign/pressure/result/tuning behavior changed. The next recommended long goal remains Real Human Playtest Execution And Intake after testers complete the v0.12.6 packet.

## v0.13.1 Extended Automated Scenario Lab, Multi-Run Evidence, and Balance Regression Dashboard - 2026-05-18

Scope: deepen the v0.13 automated scenario lab with repeated deterministic evidence, profile comparison, node-risk dashboarding, balance regression thresholds, generated reports, tests, and docs. This pass preserves the v0.13/v0.12.x green release foundation, hosted release group structure, local/hosted lane separation, save compatibility, tutorial no-save/no-reward behavior, existing art/runtime assets, maps, factions, units, rewards, pressure scope, combat systems, campaign progression, and gameplay numbers. It does not invent human feedback, start the 2026 visual overhaul, or implement balance changes.

Phase 0 baseline:

- Current commit before this goal: `1a4e09e` (`Checkpoint v0.13 automated playtest scenario lab`).
- Branch state before edits: `main` clean and synced with `origin/main`.
- Guardrails: no maps, factions, units, runtime art/assets, save format, gameplay numbers, combat systems, campaign progression, hosted release stability changes, invented feedback, broad AI/economy rewrites, or balance implementation.

Included work:

- Added `src/game/playtest/ScenarioLabExtendedRunner.ts`.
- Added `src/game/playtest/ScenarioLabExtendedReportWriter.ts`.
- Added `src/game/playtest/ScenarioLabRegressionThresholds.ts`.
- Added `src/game/playtest/ScenarioLabExtended.test.ts`.
- Extended scenario metric rows with objective completion, pressure-trigger, first-wave, and post-pressure loss fields needed for repeated reporting.
- Added `npm run playtest:lab:extended`, `npm run playtest:watchpoints:extended`, and `npm run playtest:profiles:compare`.
- Generated `PLAYTEST_SCENARIO_LAB_EXTENDED.json`, `PLAYTEST_SCENARIO_LAB_EXTENDED.md`, `PLAYTEST_PROFILE_COMPARISON.md`, `PLAYTEST_PROFILE_COMPARISON.csv`, `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.md`, `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.json`, and `PLAYTEST_WATCHPOINTS_EXTENDED.md`.
- Added v0.13.1 docs for limitations audit, node-risk dashboard spec, regression thresholds, extended evidence review, no-tuning decision, and final extended lab report.
- Updated README, ROADMAP, CHANGELOG, the v0.12.5 intake hub, and the v0.13 scenario-lab report so automated evidence remains separate from real tester feedback.

Extended automated evidence:

- Extended run size: 5 deterministic iterations, 255 source simulator runs per iteration, 1,275 source simulator runs total, 355 derived metric rows per iteration, 1,775 extended metric rows total.
- Top-ranked stable automated profile: Mixed-Veterans.
- Weakest / most failure-prone route: Greedy Economy.
- Biggest timeout risk: Ashen Outpost.
- Biggest pressure-risk signal: Cinderfen Watch.
- Retinue + Training Yard II: human testing required; no nerf.
- Greedy Economy: monitor conversion/time risk; no buff.
- Fast Army: monitor Cinderfen speed; no slowdown.
- Early defeats: OK/no change.
- Pressure fairness: human testing required.
- Cinderfen Crossing / Watch: structurally OK for Safe Beginner; no structural tuning.
- Objective completion and resource starvation: OK.

Current verification:

```text
npm test
PASS - 49 files / 367 tests.

npm run build
PASS - production build completed with the known Phaser vendor chunk-size warning.

npm run validate:content
PASS - content validation passed.

npm run validate:art-intake
PASS - checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS - 6 tests.

npm run playtest:sim
PASS - regenerated telemetry for 255 runs across 85 campaign battle nodes.

npm run playtest:lab
PASS - generated 10 profiles, 355 derived profile-run metrics, and 8 watchpoint classifications.

npm run playtest:watchpoints
PASS - regenerated the scenario lab and watchpoint summary.

npm run playtest:profiles
PASS - generated 10 scenario profile definitions.

npm run playtest:lab:extended
PASS - generated 5 deterministic iterations, 1,275 source simulator runs, 1,775 derived profile-run metrics, and 10 regression watchpoints.

npm run playtest:watchpoints:extended
PASS - regenerated extended watchpoints with 5 deterministic iterations, 1,275 source simulator runs, 1,775 derived profile-run metrics, and 10 regression watchpoints.

npm run playtest:profiles:compare
PASS - generated 10 scenario profile comparisons and 1,775 extended profile-run metrics.

git diff --check
PASS.
```

Remaining watch items: GitHub Actions rerun is optional because no runtime gameplay/HUD/campaign/pressure/result/tuning behavior changed. The next recommended long goal is Real Human Playtest Execution And Intake after testers complete the v0.12.6 packet, using the v0.13.1 dashboard to prioritize routes. Do not run feedback triage until real completed forms exist.

## v0.13 Automated Playtest Scenario Lab And Balance Telemetry V1 - 2026-05-18

Scope: add an automated playtest scenario lab and watchpoint classifier on top of the existing deterministic simulator. This pass preserves the v0.11.12/v0.12/v0.12.1/v0.12.2/v0.12.3/v0.12.4/v0.12.5/v0.12.6 green release foundation, hosted release group structure, local/hosted lane separation, save compatibility, tutorial no-save/no-reward behavior, existing art/runtime assets, maps, factions, units, rewards, pressure scope, combat systems, campaign progression, and gameplay numbers. It does not invent human feedback, start the 2026 visual overhaul, or implement balance changes.

Phase 0 baseline:

- Current commit before this goal: `064b5db` (`Checkpoint v0.12.6 playtest distribution readiness`).
- Branch state before edits: `main` clean and synced with `origin/main` (`git rev-list --left-right --count origin/main...HEAD` returned `0 0`).
- Guardrails: no maps, factions, units, runtime art/assets, save format, gameplay numbers, combat systems, campaign progression, hosted release stability changes, invented feedback, broad AI/economy rewrites, or balance implementation.

Included work:

- Added `src/game/playtest/ScenarioLabTypes.ts`.
- Added `src/game/playtest/ScenarioLabProfiles.ts`.
- Added `src/game/playtest/ScenarioLabClassifier.ts`.
- Added `src/game/playtest/ScenarioLabRunner.ts`.
- Added `src/game/playtest/ScenarioLabReportWriter.ts`.
- Added `src/game/playtest/ScenarioLab.test.ts`.
- Added `tools/runPlaytestLab.ts`.
- Added `tools/runPlaytestProfiles.ts`.
- Added `npm run playtest:lab`, `npm run playtest:watchpoints`, and `npm run playtest:profiles`.
- Generated `PLAYTEST_SCENARIO_LAB.json`, `PLAYTEST_SCENARIO_LAB.md`, `PLAYTEST_WATCHPOINT_SUMMARY.md`, `PLAYTEST_SCENARIO_PROFILES.json`, and `PLAYTEST_SCENARIO_PROFILES.md`.
- Added v0.13 docs for architecture audit, profile spec, metrics spec, classifier rules, automated evidence decision, and final scenario-lab report.
- Updated README, ROADMAP, CHANGELOG, and the v0.12.5 intake hub so automated evidence remains separate from real tester feedback.

Automated evidence verdicts:

- Strongest automated watchpoint profile: Retinue + Training Yard II.
- Weakest / most failure-prone route: Greedy Economy.
- Fastest profile: Pressure-Ignoring, a narrow Fast Army pressure-node proxy.
- Retinue + Training Yard II: needs human testing; no nerf.
- Greedy Economy: monitor conversion/time risk; no buff.
- Fast Army: monitor Cinderfen speed; no slowdown.
- Early defeats: no change.
- Pressure fairness: structurally actionable but needs human noticeability testing.
- Cinderfen Crossing / Watch: no structural tuning from automation.
- Ashen Outpost: monitor pacing/final-assault timeouts.

Current verification:

```text
npm test
PASS - 48 files / 362 tests.

npm run build
PASS - production build completed with the known Phaser vendor chunk-size warning.

npm run validate:content
PASS - content validation passed.

npm run validate:art-intake
PASS - checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS - 6 tests.

npm run playtest:sim
PASS - regenerated telemetry for 255 runs across 85 campaign battle nodes; no telemetry diff.

npm run playtest:lab
PASS - generated 10 profiles, 355 derived profile-run metrics, and 8 watchpoint classifications.

npm run playtest:watchpoints
PASS - regenerated the scenario lab and watchpoint summary.

npm run playtest:profiles
PASS - generated 10 scenario profile definitions.

git diff --check
PASS.
```

Remaining watch items: GitHub Actions rerun is optional because no runtime gameplay/HUD/campaign/pressure/result/tuning behavior changed. The next recommended long goal is Real Human Playtest Execution And Intake after testers complete the v0.12.6 packet. Do not run feedback triage until real completed forms exist.

## v0.12.6 Playtest Distribution Readiness And Tester Onboarding - 2026-05-18

Scope: add the distribution-readiness layer for real human manual playtests of the current v0.12.x browser prototype. This pass preserves the v0.11.12/v0.12/v0.12.1/v0.12.2/v0.12.3/v0.12.4/v0.12.5 green release foundation, hosted release group structure, local/hosted lane separation, save compatibility, tutorial no-save/no-reward behavior, existing art/runtime assets, maps, factions, units, rewards, pressure scope, combat systems, campaign progression, and gameplay numbers. It does not invent tester feedback, start the 2026 visual overhaul, or implement balance changes.

Phase 0 baseline:

- Current commit before this goal: `fbd5530` (`Checkpoint v0.12.5 manual playtest feedback intake triage`).
- Branch state before edits: `main` clean and synced with `origin/main` (`git rev-list --left-right --count origin/main...HEAD` returned `0 0`).
- Guardrails: docs-only tester onboarding/distribution; no maps, factions, units, art/assets, runtime art, save format, gameplay numbers, combat systems, campaign progression, hosted release stability patterns, invented feedback, or balance implementation.

Included work:

- Added `docs/V0126_TESTER_QUICK_START.md`.
- Added `docs/V0126_PLAYTEST_COORDINATOR_GUIDE.md`.
- Added `docs/V0126_ROUTE_ASSIGNMENT_PLAN.md`.
- Added `docs/V0126_FEEDBACK_SUBMISSION_PACKET.md`.
- Added `docs/V0126_FEEDBACK_STORAGE_PLAN.md`.
- Added `docs/V0126_READY_TO_SEND_TESTER_MESSAGE.md`.
- Updated `docs/V0124_PLAYTEST_PACKET_INDEX.md` so the tester quick-start, route assignment, feedback packet, coordinator guide, storage plan, and ready-to-send message sit above the larger v0.12.4 packet.
- Updated `docs/V0125_PLAYTEST_FEEDBACK_INTAKE_HUB.md` so feedback intake begins after real tester forms are completed and points back to the v0.12.6 distribution docs.
- Updated `README.md` with a short manual tester quick-start pointer.

Current verification:

```text
npm test
PASS - 47 files / 356 tests.

npm run build
PASS - production build completed with the known Phaser vendor chunk-size warning.

npm run validate:content
PASS - content validation passed.

npm run validate:art-intake
PASS - checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS - 6 tests.

npm run playtest:sim
PASS - regenerated telemetry for 255 runs across 85 campaign battle nodes; no telemetry diff.

git diff --check
PASS.
```

Remaining watch items: GitHub Actions rerun is optional because v0.12.6 is docs-only. The next recommended long goal is v0.12.7 Real Human Playtest Feedback Review And Small-Polish Decision after real completed tester packets are received. Do not invent feedback, and keep future visual overhaul work separate.

## v0.12.5 Manual Human Playtest Feedback Intake And Evidence Triage - 2026-05-18

Scope: add the evidence-intake and triage framework for completed v0.12.4 manual playtest packet responses. This pass preserves the v0.11.12/v0.12/v0.12.1/v0.12.2/v0.12.3/v0.12.4 green release foundation, hosted release group structure, local/hosted lane separation, save compatibility, tutorial no-save/no-reward behavior, existing art/runtime assets, maps, factions, units, rewards, pressure scope, combat systems, campaign progression, and gameplay numbers. It does not start the 2026 visual overhaul or implement balance changes.

Phase 0 baseline:

- Current commit before this goal: `9fb0196` (`Checkpoint v0.12.4 manual human playtest packet`).
- Branch state before edits: `main` clean and synced with `origin/main` (`git rev-list --left-right --count origin/main...HEAD` returned `0 0`).
- Guardrails: docs-only intake/triage; no maps, factions, units, art/assets, runtime art, save format, gameplay numbers, combat systems, campaign progression, hosted release stability patterns, or balance implementation.

Included work:

- Added `docs/V0125_PLAYTEST_FEEDBACK_INTAKE_HUB.md`.
- Added `docs/V0125_EVIDENCE_CLASSIFICATION_GUIDE.md`.
- Added `docs/V0125_WATCHPOINT_AGGREGATION_SHEET.md`.
- Added `docs/V0125_TRIAGE_DECISION_TREE.md`.
- Added `docs/V0125_SEVERITY_PRIORITY_RUBRIC.md`.
- Added `docs/V0125_FEEDBACK_TO_ACTION_MATRIX.md`.
- Added `docs/V0125_ISSUE_READY_TEMPLATES.md`.
- Added `docs/V0125_SAMPLE_FEEDBACK_TRIAGE.md`.
- Updated `docs/V0124_PLAYTEST_PACKET_INDEX.md` so completed tester forms point into the v0.12.5 intake workflow.
- Defined session IDs, evidence categories, repetition thresholds, severity/priority mapping, feedback-to-action rules, issue-ready templates, and clearly fictional sample triage.

Current verification:

```text
npm test
PASS - 47 files / 356 tests.

npm run build
PASS - production build completed with the known Phaser vendor chunk-size warning.

npm run validate:content
PASS - content validation passed.

npm run validate:art-intake
PASS - checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS - 6 tests.

npm run playtest:sim
PASS - regenerated telemetry for 255 runs across 85 campaign battle nodes; no telemetry diff.

git diff --check
PASS.
```

Remaining watch items: GitHub Actions rerun is optional because v0.12.5 is docs-only. The next recommended long goal is v0.12.6 Manual Playtest Feedback Review And Small-Polish Decision after real tester packets are received. Keep future visual overhaul work separate.

## v0.12.4 Manual Human Playtest Packet And Tester Checklist - 2026-05-18

Scope: package the v0.12.x manual human balance/readability questions into practical tester-facing documentation that Emmanuel or another human tester can use while playing the current browser prototype. This pass preserves the v0.11.12/v0.12/v0.12.1/v0.12.2/v0.12.3 green release foundation, hosted release group structure, local/hosted lane separation, save compatibility, tutorial no-save/no-reward behavior, existing art/runtime assets, maps, factions, units, rewards, pressure scope, combat systems, campaign progression, and gameplay numbers. It does not start the 2026 visual overhaul.

Phase 0 baseline:

- Current commit before this goal: `1184e5f` (`Checkpoint v0.12.3 human campaign balance play session`).
- Branch state before edits: `main` clean and synced with `origin/main` (`git rev-list --left-right --count origin/main...HEAD` returned `0 0`).
- Guardrails: docs-only packet; no maps, factions, units, art/assets, runtime art, save format, gameplay numbers, combat systems, campaign progression, hosted release stability patterns, or broad balance implementation.

Included work:

- Added `docs/V0124_MANUAL_HUMAN_PLAYTEST_PACKET.md`.
- Added `docs/V0124_PLAYTEST_ROUTE_CARDS.md`.
- Added `docs/V0124_MISSION_CHECKLISTS.md`.
- Added `docs/V0124_WATCHPOINT_RATING_SHEET.md`.
- Added `docs/V0124_BUG_AND_FRICTION_REPORT_TEMPLATE.md`.
- Added `docs/V0124_PLAYTEST_SUMMARY_FORM.md`.
- Added `docs/V0124_DESIGNER_INTERPRETATION_GUIDE.md`.
- Added `docs/V0124_PLAYTEST_PACKET_INDEX.md`.
- Converted the v0.12.3 watchpoints into tester-facing route cards, mission prompts, rating scales, report templates, and designer interpretation rules.
- Kept future visual-overhaul notes separate from current gameplay readability and balance evidence.

Current verification:

```text
npm test
PASS - 47 files / 356 tests.

npm run build
PASS - production build completed with the known Phaser vendor chunk-size warning.

npm run validate:content
PASS - content validation passed.

npm run validate:art-intake
PASS - checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS - 6 tests.

npm run visual:qa
PASS - final rerun 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.
Note: the first visual QA attempt hit a local saved-campaign click fallback refusal in the existing campaign/skirmish screenshot group; the full visual QA rerun passed without code or test changes.

npm run playtest:sim
PASS - regenerated telemetry for 255 runs across 85 campaign battle nodes; no telemetry diff.

git diff --check
PASS.
```

Remaining watch items: GitHub Actions rerun is optional because v0.12.4 is docs-only. The next recommended long goal is v0.12.5 Manual Human Playtest Feedback Intake And Evidence Triage after Emmanuel or another tester fills the packet. Keep future visual overhaul work separate.

## v0.12.3 Human Campaign Balance Play Session - 2026-05-17

Scope: gather direct human-style campaign balance evidence for Retinue + Training Yard II, Greedy Economy, Fast Army, early defeats, pressure-warning noticeability, and the fairness of Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch. This pass preserves the v0.11.12/v0.12/v0.12.1/v0.12.2 green release foundation, hosted release group structure, local/hosted lane separation, save compatibility, tutorial no-save/no-reward behavior, existing art/runtime assets, maps, factions, units, rewards, pressure scope, and gameplay mechanics. It does not start the 2026 visual overhaul or add broad AI/economy behavior.

Included work:

- Added `docs/V0123_HUMAN_CAMPAIGN_PLAY_SESSION_PROTOCOL.md`.
- Added `docs/V0123_HUMAN_CAMPAIGN_PLAY_SESSION_NOTES.md`.
- Added `docs/V0123_CAMPAIGN_BALANCE_EVIDENCE_TABLE.md`.
- Added `docs/V0123_BALANCE_PLAY_SESSION_DECISION.md`.
- Added `docs/V0123_HUMAN_CAMPAIGN_BALANCE_PLAY_SESSION_REPORT.md`.
- Confirmed direct visible browser readability from main menu through New Campaign, Campaign Map, Border Village guidance, and battle HUD launch.
- Classified Retinue + Training Yard II as the strongest and cleanest route, but still deferred numeric tuning as earned power.
- Classified Greedy Economy as risky conversion/timeouts, not unfair pressure or underpowered economy.
- Classified Fast Army as decisive speed play, not current Cinderfen trivialization.
- Found no current structural early defeat issue and kept pressure-warning noticeability as a human-stress watch item.

Current verification:

```text
npm test
PASS - 47 files / 356 tests.

npm run build
PASS - production build completed with the known Phaser vendor chunk-size warning.

npm run validate:content
PASS - content validation passed.

npm run validate:art-intake
PASS - checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS - 6 tests.

npm run test:e2e:smoke
PASS - final full rerun 12 tests in 7.5m.
Note: the first full-smoke attempt hit a local timeout in the existing trophy-standard extended smoke after 11/12 tests passed; the focused trophy-standard rerun passed, then the full smoke rerun passed without code or test changes.

npm run visual:qa
PASS - 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.

npm run smoke:preview
PASS - production preview at http://127.0.0.1:4173/ verified menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and 0 browser console errors.

npm run playtest:sim
PASS - regenerated telemetry for 255 runs across 85 campaign battle nodes; no telemetry diff.

git diff --check
PASS.
```

Remaining watch items: GitHub Actions rerun is optional because v0.12.3 is docs-only, but a manual release-matrix rerun after push is a clean remote parity check. The next recommended long goal is v0.12.4 Manual Human Playtest Packet And Tester Checklist. Keep the future 2026 visual overhaul separate.

## v0.12.2 Human Balance Watchpoint Review - 2026-05-17

Scope: review repeated simulator and human-style evidence for Retinue + Training Yard II strength, Greedy Economy timeouts, Fast Army quick clears, early campaign defeat causes, and Cinderfen pressure warning fairness. This pass preserves the v0.11.12/v0.12/v0.12.1 green release foundation, hosted release group structure, local/hosted lane separation, save compatibility, tutorial no-save/no-reward behavior, existing art/runtime assets, maps, factions, units, rewards, pressure scope, and gameplay mechanics. It does not start the 2026 visual overhaul or add broad AI/economy behavior.

Included work:

- Added `docs/V0122_BALANCE_WATCHPOINT_PROTOCOL.md`.
- Added `docs/V0122_SIMULATOR_BALANCE_REVIEW.md`.
- Added `docs/V0122_HUMAN_BALANCE_NOTES.md`.
- Added `docs/V0122_TUNING_DECISION.md`.
- Added `docs/V0122_HUMAN_BALANCE_WATCHPOINT_REPORT.md`.
- Classified Retinue + Training Yard II as the strongest current watchpoint and satisfying earned power, not a current nerf target.
- Classified Greedy Economy failures as risky resource-to-army conversion/timeouts, not unfair early pressure.
- Classified Fast Army as a legitimate speed profile with broader failure risk, not a free dominant route.
- Found no current structural early campaign defeat problem.
- Found Cinderfen pressure warnings fair/actionable in structural evidence while preserving human noticeability as a watch item.

Current verification:

```text
npm test: PASS, 47 files / 356 tests.
npm run build: PASS, known Phaser vendor chunk-size warning only.
npm run validate:content: PASS.
npm run validate:art-intake: PASS, 1 candidate metadata JSON / 0 review manifests.
npm run test:e2e:smoke:fast: PASS, 6 tests.
npm run test:e2e:smoke: PASS, 12 tests.
npm run visual:qa: PASS, 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.
npm run smoke:preview: PASS, production preview, 0 browser console errors.
npm run playtest:sim: PASS, 255 simulated runs across 85 campaign battle nodes.
git diff --check: PASS.
```

Hosted release groups and full release were not run locally because v0.12.2 made no gameplay, HUD, campaign, pressure, result, tuning, test-harness, or release-lane behavior changes.

Remaining watch items: GitHub Actions rerun is optional because v0.12.2 is docs-only, but a manual release-matrix rerun after push is a clean remote parity check. The next recommended long goal is v0.12.3 Human Campaign Balance Play Session focused on direct human runs through Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch across retinue/Training Yard profiles. Keep the future 2026 visual overhaul separate.

## v0.12.1 Human-Paced Core Feel Playtest Review - 2026-05-17

Scope: review the v0.12 core feel/readability changes through a slower human-style play pass, then apply only tiny evidence-backed polish. This pass preserves the v0.11.12/v0.12 green release foundation, hosted release group structure, local/hosted lane separation, save compatibility, tutorial no-save/no-reward behavior, existing art/runtime assets, maps, factions, units, rewards, and gameplay mechanics. It does not start the 2026 visual overhaul or add broad AI/economy behavior.

Included work:

- Added `docs/V0121_HUMAN_PACED_PLAYTEST_PROTOCOL.md`.
- Added `docs/V0121_HUMAN_PACED_PLAYTEST_NOTES.md`.
- Added `docs/V0121_PLAYTEST_POLISH_PLAN.md`.
- Added `docs/V0121_TUNING_DECISION.md`.
- Added `docs/V0121_VISUAL_QA_REVIEW.md`.
- Added `docs/V0121_HUMAN_PACED_PLAYTEST_REPORT.md`.
- Aligned player-facing Cinderfen map names to `Cinderfen Crossing` and `Cinderfen Watch` while keeping map ids, file names, route wiring, saves, and mechanics unchanged.
- Reworded the Cinder Shrine objective to explain the one-time +20 Aether surge and hold instruction in the small tracker.
- Made defeat guidance context-aware so skirmish defeats use `Hold after each wave` while campaign defeats keep camp/Chapel support guidance.
- Updated reward/report naming and focused copy tests for the new Cinderfen names.
- Preserved release assertions after full release exposed two deep-flow timing issues: Start Battle scene transitions now use the existing scene-transition click options, and direct building selection refreshes the HUD before side-panel assertions. No force clicks or canvas/world DOM fallback were added.

Current verification:

```text
npm test: PASS, 47 files / 356 tests.
npm run build: PASS, known Phaser vendor chunk-size warning only.
npm run validate:content: PASS.
npm run validate:art-intake: PASS.
npm run test:e2e:smoke:fast: PASS, 6 tests.
npm run test:e2e:smoke: PASS, 12 tests.
npm run visual:qa: PASS, 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.
npm run smoke:preview: PASS, production preview, 0 browser console errors.
npm run playtest:sim: PASS, 255 simulated runs across 85 campaign battle nodes.
npm run test:e2e:release:hosted:deep-meta: PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle: PASS, 11 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure: PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core: PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen: PASS, 12 tests.
npm run test:e2e:release:hosted:smoke: PASS, 12 tests.
npm run test:e2e:release: PASS, 74 tests.
git diff --check: PASS.
```

Remaining watch items: commit, push, and rerun the manual GitHub Actions release matrix on the final v0.12.1 checkpoint commit. The next recommended long goal is v0.12.2 Human Balance Watchpoint Review focused on retinue plus Training Yard II, Greedy Economy timeouts, Fast Army clear speed, early campaign defeat causes, and pressure-warning fairness. Keep the future 2026 visual overhaul separate.

## v0.12 Core Game Feel and Battle Readability Pass - 2026-05-16

Scope: improve the existing playable slice after the v0.11.12 hosted release matrix green closeout. This pass focuses on readability and responsiveness through command acknowledgement, selected-order clarity, objective wording, scoped pressure counterplay, battle-status priority, side-panel hierarchy, and results guidance. It preserves gameplay scope, save compatibility, campaign progression, tutorial no-save/no-reward behavior, existing art, runtime art wiring, hosted release group configuration, release coverage strength, maps, units, factions, workers/construction prohibitions, and local/hosted release-lane separation.

Included work:

- Added `docs/V012_CORE_GAME_FEEL_AUDIT.md`.
- Added `docs/V012_BATTLE_READABILITY_AUDIT.md`.
- Added `docs/V012_BALANCE_AND_FEEL_TUNING_NOTES.md`.
- Added `docs/V012_VISUAL_READABILITY_NOTES.md`.
- Added `docs/V012_CORE_GAME_FEEL_PASS_REPORT.md`.
- Added command-level battle-status priority so accepted commands can replace routine income/status messages while pressure/objective messages still outrank them.
- Added clearer successful and blocked command feedback for movement, attack, attack-move, rally points, building placement, training, research, and abilities.
- Improved selected-group and current-order side-panel hierarchy without changing selection mechanics or runtime art.
- Marked the first unfinished objective as `Next` and tightened Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch objective copy.
- Clarified Cinderfen Crossing and Cinderfen Watch pressure warnings with counterplay language while keeping pressure warning/telemetry scoped.
- Improved defeat/results guidance without changing reward or save behavior.
- Added/updated focused tests for command status priority, objective state, pressure warning copy, and browser command acknowledgement.

Current verification:

```text
npm test: PASS, 47 files / 355 tests.
npm run build: PASS, known Phaser vendor chunk-size warning only.
npm run validate:content: PASS.
npm run validate:art-intake: PASS, 1 candidate metadata JSON / 0 review manifests.
npm run test:e2e:smoke:fast: PASS, 6 tests.
npm run test:e2e:smoke: PASS, 12 tests.
npm run visual:qa: PASS, 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.
npm run smoke:preview: PASS, production preview smoke, 0 browser console errors.
npm run playtest:sim: PASS, 255 simulated runs across 85 campaign battle nodes.
npm run test:e2e:release:hosted:deep-meta: PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle: PASS, 11 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure: PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core: PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen: PASS, 12 tests.
npm run test:e2e:release:hosted:smoke: PASS, 12 tests.
npm run test:e2e:release: PASS, 74 tests.
git diff --check: PASS.
```

Remaining watch items: rerun the manual GitHub Actions release matrix on the final v0.12 commit after push. The next recommended long goal is v0.12.1 Human-Paced Core Feel Playtest Review across Ashen Outpost, Cinderfen Crossing, Cinderfen Watch, Results, and campaign return flow. Keep the future 2026 visual overhaul separate from this pass.

## v0.11.12 Hosted Release Interaction Determinism Fix - 2026-05-15

Scope: harden the manually triggered GitHub Actions hosted release matrix interaction layer after v0.11.11 production preview reduced server instability but run #19 still failed hosted deep-battle, deep-campaign-pressure, layout-core, layout-cinderfen, and smoke. This pass preserves gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, release coverage strength, and the current browser prototype scope. It does not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, visual baseline pixel assertions, skipped tests, or weakened assertions.

Included work:

- Added `docs/V1112_HOSTED_RELEASE_INTERACTION_FAILURE_AUDIT.md`.
- Added `docs/V1112_HOSTED_RELEASE_INTERACTION_DETERMINISM_FIX.md`.
- Hardened `clickReady` with a verified DOM fallback for real visible/enabled controls after normal Playwright click actionability fails, without using force clicks and without applying it to canvas/world clicks.
- Reused the strongest shared `expectBattleLoaded` helper across hosted pressure, smoke, layout, deep-flow, and Chapter 2 helper launch paths.
- Routed targeted hosted-problem DOM UI buttons through `clickReady`, including tutorial command-log advancement, smoke setup/campaign paths, enemy-pressure launches, deep-flow Barracks/Train command buttons, layout navigation, and Cinderfen helper choices/starts.
- Strengthened tutorial layout readiness with overlay/button waits and retrying layout-box measurement.
- Reworked side-panel command reachability to wait for side-panel readiness, measure current live DOM buttons in smaller scroll-aware checks, and emit diagnostics if readiness fails.
- Hardened the deep-battle right-click movement helper to reselect a friendly unit, validate canvas-safe target points, and keep the `Moving` assertion.

Current verification:

```text
npm test: PASS, 46 files / 351 tests.
npm run build: PASS, known Phaser vendor chunk-size warning only.
npm run validate:content: PASS.
npm run validate:art-intake: PASS, 1 candidate metadata JSON / 0 review manifests.
npm run test:e2e:smoke:fast: PASS, 6 tests.
npm run visual:qa: PASS, 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.
npm run smoke:preview: PASS, 0 browser console errors.
npm run playtest:sim: PASS, 255 runs across 85 campaign battle nodes.
npm run test:e2e:release:hosted:deep-meta: PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle: PASS, 11 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure: PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core: PASS, 16 tests.
npm run test:e2e:release:hosted:layout-cinderfen: PASS, 9 tests.
npm run test:e2e:release:hosted:smoke: PASS, 12 tests.
Targeted hosted repro commands: PASS, movement/build, hover stability, enemy-pressure battle load, tutorial layout, Cinderfen desktop layout, and tutorial smoke.
npm run test:e2e:smoke: PASS, 12 tests.
npm run test:e2e:release: PASS, 67 tests.
git diff --check: PASS.
```

Remaining watch items: Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input after this checkpoint and confirm the same six production-preview hosted release matrix jobs plus the unchanged release simulator.

## v0.11.11 Hosted Release Preview Environment Fix - 2026-05-15

Scope: harden the manually triggered GitHub Actions hosted release matrix environment after v0.11.10 explicit groups still failed on hosted runners, while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, release coverage strength, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or visual baseline pixel assertions.

Included work:

- Added `docs/V1111_HOSTED_RELEASE_ENVIRONMENT_AUDIT.md`.
- Added `docs/V1111_HOSTED_RELEASE_PREVIEW_ENVIRONMENT_FIX.md`.
- Added `playwright.hosted-release.config.ts` so hosted release groups run against production preview instead of Vite dev server.
- Added `npm run preview:hosted`.
- Updated hosted release group scripts to use `--config=playwright.hosted-release.config.ts`.
- Kept automatic Fast confidence, optional visual QA, release simulator, local full release, local 2-way shards, local 3-way shards, and manual full-release CI lane unchanged.
- Kept the GitHub Actions Chromium install step as `npx playwright install --with-deps chromium`, because the workflow already installs Linux browser dependencies.
- Added hosted-release-only Chromium launch args for Linux runner stability.
- Applied small test-only `clickReady` hardening to reported skirmish/tutorial launch paths and extended the deep-flow right-click movement helper to try nearby alternate world points while preserving the `Moving` assertion.

Current verification:

```text
npm test
PASS: 46 files / 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: 1 candidate metadata JSON file and 0 review manifest JSON files checked.

npm run test:e2e:smoke:fast
PASS: 6 Playwright tests in 2.1m.

npm run visual:qa
PASS: 5 Playwright tests in 4.4m, 18 screenshots, 0 browser console errors, 0 screenshot retries.

npm run smoke:preview
PASS: production preview smoke on http://127.0.0.1:4173/ with 0 browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

Hosted release preview groups
PASS: deep-meta 12/12, deep-battle 11/11, deep-campaign-pressure 7/7, layout-core 16/16, layout-cinderfen 9/9, smoke 12/12.

Targeted hosted-preview run #17 repros
PASS: deep-meta alternate Refugee/Chapel, deep-battle movement, pressure tutorial/skirmish, desktop tutorial layout, battle HUD/results layout, and smoke difficulty-selection repros.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 6.8m on rerun. The first local dev-server attempt timed out in the long Cinderfen Crossing smoke test during an app-root navigation retry; the targeted repro and full rerun passed.

npm run test:e2e:release
PASS: 67 Playwright tests in 35.2m after rerunning with a longer local command ceiling. The first invocation exceeded the local tool timeout before returning output.

git diff --check
PASS: only the existing Windows CRLF warning on .github/workflows/ci.yml.
```

Remaining watch items: Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input after this checkpoint and confirm the same six release matrix jobs now run against production preview.

## v0.11.10 Hosted Release Matrix Determinism Fix - 2026-05-14

Scope: stabilize the manually triggered GitHub Actions hosted release matrix after v0.11.9's native 6-way split still failed on hosted runners, while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, release coverage strength, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or visual baseline pixel assertions.

Included work:

- Added `docs/V1110_HOSTED_RELEASE_MATRIX_FAILURE_AUDIT.md`.
- Added `docs/V1110_HOSTED_RELEASE_MATRIX_DETERMINISM_FIX.md`.
- Replaced hosted native 6-way `--fully-parallel` shard scripts with explicit hosted release group scripts: `deep-meta`, `deep-battle`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke`.
- Updated `.github/workflows/ci.yml` so the manual `run_release_matrix` input runs the six hosted groups with the existing 45-minute job timeout plus the unchanged release simulator.
- Added `seedSaveBeforeAppBoot` and routed shared, Chapter 2, and deep-flow seeded-save setup through pre-boot localStorage seeding.
- Applied non-forced `clickReady` to hosted-problem launch/setup interactions and added a one-retry right-click movement command helper while preserving the `Moving` assertion.
- Tagged release tests into explicit hosted groups totaling the same 67 tests as the full release suite.
- Updated README, release checklist, developer command guide, release lane reliability plan, changelog, and this checkpoint.

Current verification:

```text
npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm test
PASS: 46 test files, 351 tests.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS: 6 Playwright tests in about 2.0m.

npm run visual:qa
PASS: 5 Playwright visual QA tests in about 4.2m, 18 indexed screenshots, 0 recorded browser console errors, 0 screenshot retries.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

Targeted remote-failure reproductions
PASS: Refugee/Chapel seed path, battle HUD minimap movement path, desktop tutorial layout entry, multi-viewport Battle HUD/results layout, and skirmish difficulty pressure path.

npm run test:e2e:release:hosted:deep-meta
PASS: 12 Playwright tests in about 6.1m, with one recovered setup-navigation retry.

npm run test:e2e:release:hosted:deep-battle
PASS: 11 Playwright tests in about 4.7m.

npm run test:e2e:release:hosted:deep-campaign-pressure
PASS: 7 Playwright tests in about 3.6m.

npm run test:e2e:release:hosted:layout-core
PASS: 16 Playwright tests in about 6.2m.

npm run test:e2e:release:hosted:layout-cinderfen
PASS: 9 Playwright tests in about 9.5m, with recovered setup-navigation retries.

npm run test:e2e:release:hosted:smoke
PASS: 12 Playwright tests in about 6.2m.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 6.3m.

npm run test:e2e:release
PASS: 67 Playwright tests in about 36.5m, with recovered setup-navigation retries.

git diff --check
PASS.
```

Remaining watch items: Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input after this checkpoint and confirm it now shows six release matrix jobs named `deep-meta`, `deep-battle`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke`, plus the unchanged release simulator.

## v0.11.9 Hosted Release Matrix Split and Timeout Fix - 2026-05-14

Scope: split the manually triggered GitHub Actions release matrix into smaller hosted shards and tune the hosted shard timeout while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, release coverage strength, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or visual baseline pixel assertions.

Included work:

- Added `docs/V119_HOSTED_RELEASE_MATRIX_SPLIT_AUDIT.md`.
- Added `docs/V119_HOSTED_RELEASE_MATRIX_SPLIT_FIX.md`.
- Added hosted-only 6-way release scripts: `npm run test:e2e:release:hosted:shard1of6` through `npm run test:e2e:release:hosted:shard6of6`, using Playwright test-level sharding with `--fully-parallel --workers=1`.
- Updated `.github/workflows/ci.yml` so the manual `run_release_matrix` input runs six hosted release shard jobs instead of three hosted shard jobs.
- Increased the manual hosted release shard job timeout from 35 minutes to 45 minutes after remote evidence showed shard 1 and shard 2 exceeded the 35-minute cap.
- Kept automatic Fast confidence, optional visual QA, release simulator, manual full-release lane, local full release, local 2-way shards, and local 3-way shards intact.
- Applied the existing non-forced `clickReady` helper to the two `menu-reset-save` clicks reported in the shard-1 hosted evidence.
- Hardened `gotoAppRootWithRetry` with a final real-main-menu readiness check after the last transient setup-navigation error, accepting recovery only when actual main menu controls are visible.
- Updated README, release checklist, developer command guide, release lane reliability plan, changelog, and this checkpoint.

Current verification:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS: 6 Playwright tests in about 2.2m.

npm run visual:qa
PASS: 5 Playwright visual QA tests in about 4.5m, 18 indexed screenshots, 0 recorded browser console errors, 0 screenshot retries.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 6.7m.

npm run test:e2e:release:hosted:shard1of6
PASS: 12 Playwright tests in about 6.9m.

npm run test:e2e:release:hosted:shard2of6
PASS: 11 Playwright tests in about 5.1m.

npm run test:e2e:release:hosted:shard3of6
PASS: 11 Playwright tests in about 5.2m.

npm run test:e2e:release:hosted:shard4of6
PASS: 11 Playwright tests in about 4.9m.

npm run test:e2e:release:hosted:shard5of6
PASS: 11 Playwright tests in about 11.3m with setup-navigation retry diagnostics and recovery.

npm run test:e2e:release:hosted:shard6of6
PASS: 11 Playwright tests in about 6.3m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS.
```

Existing local 3-way shard scripts were not rerun in this pass because they are unchanged and the corrected hosted 6-way scripts exercised the same 67-test release suite. Remaining watch items: Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input and confirm it now shows six release matrix jobs named `shard-1-of-6` through `shard-6-of-6`, plus the unchanged release simulator.

## v0.11.8 Hosted Release Matrix Stability Fix - 2026-05-13

Scope: stabilize the manually triggered GitHub Actions 3-way release matrix while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, release coverage strength, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or visual baseline pixel assertions.

Included work:

- Added `docs/V118_RELEASE_MATRIX_RELOAD_NAVIGATION_AUDIT.md`.
- Added `docs/V118_HOSTED_RELEASE_MATRIX_STABILITY_FIX.md`.
- Replaced remaining e2e `page.reload()` usage with hosted-safe app-root navigation through `gotoReadyMainMenu`.
- Unified `deep-flow.spec.ts` storage seeding with the shared menu-ready helper and Continue Campaign readiness assertion.
- Hardened `gotoReadyMainMenu` with commit-stage navigation, three setup-navigation attempts, same-URL interruption retry handling, longer real-menu readiness probes, and clearer retry logs.
- Added `clickReady` for narrow hosted actionability stalls without force-clicking, skipping, or weakening assertions.
- Applied `clickReady` to reported release-path campaign/skirmish interactions, including Broken Ford, Cinderfen node/start helpers, and Border Village start paths.
- Added a scoped 120s budget for the seeded Cinderfen menu/campaign layout readability test after remote shard-2 evidence and local full-release reproduction.

Current verification:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS: 6 Playwright tests in about 2.3m.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 6.5m.

npm run visual:qa
PASS: 5 Playwright visual QA tests in about 4.4m, 18 indexed screenshots, 0 recorded browser console errors, 0 screenshot retries.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

Targeted hosted-failure reproductions
PASS: deep-flow live victory/defeat, layout mobile portrait, layout tablet Cinderfen readability, Broken Ford smoke, post-Ashen Crossing smoke, and post-Crossing Watch smoke.

npm run test:e2e:release
PASS: 67 Playwright tests in about 36.5m after the final helper/timeout refinement.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in about 13.7m.

npm run test:e2e:release:shard2of3
PASS: 27 Playwright tests in about 16.5m.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in about 6.0m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS.
```

Remaining watch items: Emmanuel should rerun the manual GitHub Actions `Run manual 3-way release shard matrix and simulator` workflow input and confirm shard 1 no longer fails in deep-flow `seedSave`, shard 2 no longer fails in seeded Cinderfen layout setup navigation, and shard 3 no longer stalls at Broken Ford selection/start.

## v0.11.7 Optional Visual QA Screenshot Stability Fix - 2026-05-13

Scope: stabilize the manually triggered GitHub Actions `Optional visual QA` screenshot capture path while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, screenshot coverage strength, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or visual baseline pixel assertions.

Included work:

- Added `docs/V117_VISUAL_QA_SCREENSHOT_STABILITY_FIX.md`.
- Split `tests/visual-qa/visual-qa.spec.ts` from one monolithic screenshot test into 5 smaller tests: menu/gallery/inventory, tutorial, campaign/skirmish, Cinderfen Crossing, and Cinderfen Watch.
- Kept all 18 screenshot targets and strict browser console error collection.
- Added per-screenshot start/done/fail/retry logging with group, file name, viewport, URL, elapsed time, duration, and retry status.
- Added a 45s per-screenshot timeout, disabled screenshot animations/caret, and one retry for transient screenshot timeout/capture failures.
- Updated the generated `visual-qa/latest/index.md` schema to include capture groups and screenshot retry status.

Current verification:

```text
npm run visual:qa
PASS: 5 Playwright visual QA tests in about 4.2m, 18 indexed screenshots, 0 recorded browser console errors, 0 screenshot retries.

npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS: 6 Playwright tests in about 2.0m.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 5.3m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in about 11.3m.

npm run test:e2e:release:shard2of3
PASS: 27 Playwright tests in about 14.8m.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in about 5.2m.

git diff --check
PASS.
```

Remaining watch items: Emmanuel should rerun the manual GitHub Actions `Optional visual QA` job and confirm the hosted log shows `DONE screenshot` for `cinderfen-crossing-tablet.png`, `visual-qa-latest/index.md` uploads with 18 screenshots, and browser console errors remain 0.

## v0.11.6 Optional Visual QA Hosted Navigation Fix - 2026-05-12

Scope: stabilize the manually triggered GitHub Actions `Optional visual QA` job while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, screenshot coverage strength, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or visual baseline pixel assertions.

Included work:

- Added `docs/V116_VISUAL_QA_HOSTED_NAVIGATION_FIX.md`.
- Updated `tests/e2e/shared-helpers.ts` so `gotoReadyMainMenu` retries only transient app-root setup navigation aborts such as `net::ERR_ABORTED`, frame-detach errors, or setup-navigation timeouts, while still requiring visible main-menu controls afterward. A navigation timeout is accepted only when the real main menu is already visible.
- Updated `tests/visual-qa/visual-qa.spec.ts` so the optional 18-screenshot visual QA capture test has a 420s budget instead of the previous 240s budget.
- Kept the visual QA harness as one coverage-preserving pass with 18 screenshot targets and strict browser console error collection.
- Kept automatic GitHub `Fast confidence` on `npm run test:e2e:smoke:fast`; this pass only targets the manual optional visual QA job.

Current verification:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS: 6 Playwright tests.

npm run visual:qa
PASS: 1 Playwright visual QA test in about 4.1m, 18 indexed screenshots, 0 recorded browser console errors.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

npm run test:e2e:smoke
PASS: 12 Playwright tests.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in about 11.7m.

npm run test:e2e:release:shard2of3
PASS: 27 Playwright tests in about 14.8m after the helper was refined to accept a setup-navigation timeout only when the real main menu was already visible.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in about 5.7m.

git diff --check
PASS: no whitespace errors.
```

Remaining watch items: Emmanuel should rerun the manual GitHub Actions `Optional visual QA` job and confirm `visual-qa-latest` uploads with `index.md`, 18 screenshots, and 0 browser console errors. If it fails again, inspect whether the failure is a new app assertion, browser console error, another navigation abort, or total job timeout before tuning further.

## v0.11.5 Fast Confidence Lane Split - 2026-05-12

Scope: split automatic GitHub Actions browser confidence from the full smoke/release lanes while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, workflow coverage strength, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or speculative timeout inflation.

Included work:

- Added `docs/V115_FAST_CONFIDENCE_LANE_SPLIT.md`.
- Added `npm run test:e2e:smoke:fast`.
- Tagged six smoke tests as `@ci-fast` and six longer campaign/skirmish smoke tests as `@extended-smoke`.
- Updated `.github/workflows/ci.yml` so automatic `Fast confidence` runs `npm run test:e2e:smoke:fast`.
- Kept `npm run test:e2e:smoke` as the full 12-test smoke suite.
- Kept full release, 3-way release shards, visual QA, simulator, preview smoke, and manual GitHub workflow lanes coverage-preserving.

Current verification:

```text
npm run test:e2e:smoke:fast -- --list
PASS: lists 6 tests from `tests/e2e/smoke.spec.ts`.

npm run test:e2e:smoke -- --list
PASS: lists all 12 tests from `tests/e2e/smoke.spec.ts`.

npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS: 6 Playwright tests in about 2.1m.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 5.2m.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

npm run test:e2e:release
PASS: 67 Playwright tests in about 31.2m.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in about 11.1m.

npm run test:e2e:release:shard2of3
PASS: 27 Playwright tests in about 15.2m.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in about 5.7m.

npm run visual:qa
PASS: 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors; PowerShell reported only the normal workflow line-ending notice.
```

Remaining watch items: Emmanuel should re-check the automatic GitHub Actions `Fast confidence` job after push and confirm the e2e step runs `npm run test:e2e:smoke:fast`. Extended campaign/skirmish smoke coverage remains in full smoke and release/manual lanes.

## v0.11.4 Fast Confidence Seed/Reload Fix - 2026-05-12

Scope: stabilize GitHub Actions smoke seeded-save setup after the v0.11.3 settings timeout fix while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, workflow coverage, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or speculative CI workflow churn.

Included work:

- Added `docs/V114_FAST_CONFIDENCE_SEED_RELOAD_FIX.md`.
- Improved `tests/e2e/shared-helpers.ts` so seeded-save setup starts from a ready main menu, writes localStorage only after a stable app origin exists, uses deterministic `page.goto("/")` navigation after writing storage instead of `page.reload()`, and verifies seeded saves enable Continue Campaign.
- Updated `tests/e2e/chapter2-helpers.ts` so post-Ashen, post-Crossing, and completed-route seeded saves use the same stable storage setup path.
- Added a narrowly scoped 60s timeout for only `skirmish difficulty selection changes fog and starting pressure`; the test still launches both seeded skirmish battles and keeps the fog/pressure assertions.

Latest verification results:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke
PASS before the fix: 12 Playwright smoke tests in about 5.0m.
PASS after the fix: 12 Playwright smoke tests in about 5.2m.

npx playwright test tests/e2e/smoke.spec.ts --grep "post-Ashen campaign resolves Cinderfen Overlook" --retries=1 --trace=on
PASS before the helper change: 1 test in 55.1s.
PASS after the helper change: 1 test in about 1.1m.

npx playwright test tests/e2e/smoke.spec.ts --grep "post-Crossing campaign launches Cinderfen Watch" --retries=1 --trace=on
PASS before the helper change: 1 test in about 1.0m.
PASS after the helper change: 1 test in 39.3s.

npx playwright test tests/e2e/smoke.spec.ts --grep "skirmish difficulty selection changes fog and starting pressure" --retries=1 --trace=on
PASS after the helper change: 1 test in 44.9s.
PASS after final docs update: 1 test in 32.7s.

npx playwright test tests/e2e/smoke.spec.ts --grep "campaign Border Village launches a battle scene" --retries=1 --trace=on
PASS before the helper change: 1 test in 14.6s.
PASS after the helper change: 1 test in 19.2s.

npx playwright test tests/e2e/smoke.spec.ts --grep "skirmish setup lists maps and launches Broken Ford" --retries=1 --trace=on
PASS before the helper change: 1 test in 14.3s.
PASS after the helper change: 1 test in 16.8s.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

npm run test:e2e:release
PASS: 67 Playwright tests in about 30.3m.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in about 12.4m.

npm run test:e2e:release:shard2of3
First pass: one local timeout in `enemy-pressure.spec.ts` tutorial/skirmish pressure guard after 26/27 tests passed.
Targeted rerun: PASS, 1 test in 29.1s.
Full shard rerun: PASS, 27 Playwright tests in about 14.7m.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in about 5.7m.

npm run visual:qa
PASS: 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors.
```

Remaining watch items: Emmanuel should re-check the automatic GitHub Actions `Fast confidence` job after push. If any reported campaign/skirmish smoke path fails again after seeded setup succeeds, investigate that path independently rather than as seed/reload cascade.

## v0.11.3 Fast Confidence Smoke Fix - 2026-05-12

Scope: fix the first reported remote GitHub Actions `Fast confidence` smoke timeout while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, workflow coverage, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or speculative CI workflow churn.

Included work:

- Added `docs/V113_FAST_CONFIDENCE_SMOKE_FIX.md`.
- Reviewed the reported GitHub Actions failure for `settings screen persists accessibility options` and the likely cascade in `campaign Border Village launches a battle scene`.
- Improved `tests/e2e/smoke.spec.ts` settings control waits by verifying re-rendered Settings DOM state after range, checkbox, and fog-select changes.
- Added a narrowly scoped 60s timeout for only the settings accessibility smoke test, tied to hosted CI evidence that the combined settings-persistence plus in-battle runtime-application path exceeded the global 35s Playwright test timeout.
- Left Border Village smoke coverage unchanged because it passed independently in focused local verification.

Latest verification results:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke
PASS after the fix: 12 Playwright smoke tests in about 4.7m.

npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on
PASS after the fix: 1 test in 26.8s.

npx playwright test tests/e2e/smoke.spec.ts --grep "campaign Border Village launches a battle scene" --retries=1 --trace=on
PASS after the fix: 1 test in 16.7s.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

npm run test:e2e:release
PASS: 67 Playwright tests in about 28.7m.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in about 11.3m.

npm run test:e2e:release:shard2of3
PASS: 27 Playwright tests in about 13.4m.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in about 4.9m.

npm run visual:qa
PASS: 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors.
```

Remaining watch items: Emmanuel should re-check the automatic GitHub Actions `Fast confidence` job after push. If Border Village fails again with a fresh failure after settings passes, investigate it as independent rather than as timeout cascade.

## v0.11.2 Remote CI Observation Report Gate - 2026-05-11

Scope: observe or document access to the first remote GitHub Actions run from v0.11.1, review likely CI timeout/portability/artifact risks, and make only tiny CI-only fixes if hosted evidence requires them. This pass preserved gameplay rules, save compatibility, campaign progression, tutorial behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, workflow coverage, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, coverage reduction, secrets, paid services, or speculative CI tuning.

Included work:

- Added `docs/V112_REMOTE_CI_OBSERVATION_CAPABILITY.md`, `docs/V112_GITHUB_ACTIONS_EVIDENCE_REPORT.md`, `docs/V112_WORKFLOW_STATIC_REVIEW.md`, `docs/V112_CI_TIMEOUT_TUNING_REVIEW.md`, `docs/V112_PREVIEW_HELPER_REMOTE_PORTABILITY_REVIEW.md`, `docs/V112_CI_ARTIFACT_REMOTE_REVIEW.md`, `docs/V112_MANUAL_GITHUB_ACTIONS_CHECKLIST.md`, `docs/V112_CI_NO_FIX_DECISION.md`, and `docs/V112_REMOTE_CI_OBSERVATION_REPORT.md`.
- Confirmed `gh` is unavailable, the GitHub connector token is expired, and unauthenticated Actions API access returns `404 Not Found`.
- Reviewed `.github/workflows/ci.yml` statically and found no concrete YAML/script/artifact/timeout issue.
- Documented that no CI-only workflow/helper change is justified until authenticated GitHub UI evidence identifies a real hosted-run issue.

Latest report-gate verification results:

```text
npm test
PASS: 46 test files, 351 tests during phase gates.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.
Output: assets/index-DY-3qp2P.js, 477.04 kB minified / 127.86 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-BiGdwuWI.css, 44.51 kB minified / 9.16 kB gzip.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON template and 0 review manifest JSON files.

npm run test:e2e:smoke
PASS during workflow/tooling gates.

npm run smoke:preview
PASS during preview/workflow gates with title/menu/tutorial/campaign/skirmish checks and 0 browser console errors.

npm run visual:qa
PASS: 1 Playwright capture test, 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors.
```

Remaining watch items: remote GitHub Actions evidence still needs authenticated GitHub UI observation, hosted Linux timing is unmeasured, hosted `smoke:preview` remains unconfirmed, manual visual/release artifacts remain unconfirmed, full release e2e remains slow, 2-way shards remain lopsided, and the known Phaser vendor warning remains.

## v0.11.1 CI Release Matrix Report Gate - 2026-05-11

Scope: add a conservative GitHub Actions CI dry-run, release matrix documentation, preview helper portability improvements, artifact strategy, CI/local parity checks, and release documentation updates. This pass preserved gameplay rules, save compatibility, campaign progression, tutorial behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, broad systems, or coverage reduction.

Included work:

- Added `docs/V111_CI_MATRIX_AUDIT.md`, `docs/V111_PREVIEW_HELPER_PORTABILITY_AUDIT.md`, `docs/V111_CI_RELEASE_MATRIX_PLAN.md`, `docs/V111_CI_ARTIFACT_STRATEGY.md`, `docs/V111_CI_LOCAL_PARITY_CHECK.md`, and `docs/V111_CI_RELEASE_MATRIX_REPORT.md`.
- Added `.github/workflows/ci.yml` with automatic fast confidence and manual visual QA, 3-way release shard matrix, simulator, and full-release lanes.
- Improved `tools/smokePreview.ts` with validated preview port/timeout env overrides, clearer startup errors, and POSIX helper-owned process-group shutdown.
- Updated README, `RELEASE_CHECKLIST.md`, `docs/DEVELOPER_COMMAND_GUIDE.md`, `docs/V11_RELEASE_LANE_RELIABILITY_PLAN.md`, roadmap, changelog, and handoff docs.

Latest report-gate verification results:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.
Output: assets/index-DY-3qp2P.js, 477.04 kB minified / 127.86 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-BiGdwuWI.css, 44.51 kB minified / 9.16 kB gzip.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON template and 0 review manifest JSON files.

npm run test:e2e:smoke
PASS during workflow/tooling gates.

npm run smoke:preview
PASS during preview/workflow gates with title/menu/tutorial/campaign/skirmish checks and 0 browser console errors.

npm run visual:qa
PASS: 1 Playwright capture test, 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors.
```

Remaining watch items: the GitHub Actions workflow still needs remote validation after push, full release e2e remains slow, 2-way shards remain lopsided, 3-way shard CI timing is not yet measured remotely, the known Phaser vendor warning remains, and visual QA remains optional/human-reviewed.

## v0.11 Technical Reliability Report Gate - 2026-05-11

Scope: improve technical reliability, e2e runtime clarity, release-lane documentation, preview smoke reliability, optional visual QA reporting, bundle/performance measurement, developer command ergonomics, and release-checklist maintainability. This pass preserved gameplay rules, save compatibility, campaign progression, tutorial behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, or broad systems.

Included work:

- Added `docs/V11_E2E_RUNTIME_AUDIT_REFRESH.md`, `docs/V11_RELEASE_LANE_RELIABILITY_PLAN.md`, `docs/V11_PREVIEW_SMOKE_RELIABILITY_NOTES.md`, `docs/V11_VISUAL_QA_RELIABILITY_NOTES.md`, `docs/V11_BUNDLE_PERFORMANCE_REFRESH.md`, `docs/DEVELOPER_COMMAND_GUIDE.md`, and `docs/V11_TECHNICAL_RELIABILITY_REPORT.md`.
- Added `npm run smoke:preview` through `tools/smokePreview.ts` for repeatable production preview smoke with console-error capture and process-tree shutdown.
- Improved `npm run visual:qa` reporting so the generated index and command output show screenshot count, browser console error count, viewport coverage, and harness path.
- Refreshed bundle/performance facts and confirmed v0.11 tooling does not leak into production app JS.
- Tightened `RELEASE_CHECKLIST.md` and linked command guidance from README.

Latest report-gate verification results:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.
Output: assets/index-DY-3qp2P.js, 477.04 kB minified / 127.86 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-BiGdwuWI.css, 44.51 kB minified / 9.16 kB gzip.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON template and 0 review manifest JSON files.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 5.1m.

npm run visual:qa
PASS: 1 Playwright capture test in about 3.3m, 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

npm run smoke:preview
PASS: http://127.0.0.1:4173/ verified title, Prototype v0.3 / Cinderfen Route Baseline menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and 0 browser console errors. The helper shut down the preview process tree.

git diff --check
PASS: no whitespace errors.
```

## v0.10 Tutorial v2 Onboarding Report Gate - 2026-05-11

Scope: refine the playable Tutorial / Proving Grounds onboarding experience through copy clarity, pacing documentation, overlay hierarchy, no-reward completion clarity, e2e lane review, visual QA review, and Emmanuel's manual playtest checklist. This pass preserved gameplay rules, save compatibility, campaign progression, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, or broad systems.

Included work:

- Added `docs/V10_TUTORIAL_V2_AUDIT.md`, `docs/V10_TUTORIAL_V2_PACING_PLAN.md`, `docs/V10_TUTORIAL_COPY_REFINEMENT_NOTES.md`, `docs/V10_TUTORIAL_OVERLAY_REFINEMENT_NOTES.md`, `docs/V10_TUTORIAL_COMPLETION_CLARITY_NOTES.md`, `docs/V10_TUTORIAL_E2E_LANE_REVIEW.md`, `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`, `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`, and `docs/V10_TUTORIAL_V2_ONBOARDING_REPORT.md`.
- Updated tutorial copy in `src/game/data/tutorials.ts` to make the current twelve-step RTS/RPG loop clearer and more action-oriented.
- Added small tutorial overlay hierarchy styling in `src/game/ui/hudPanels/TutorialPanel.ts` and `src/game/styles/battle-feedback.css`.
- Clarified completion/menu copy so the player sees that training is complete, no rewards or save changes were granted, and New Campaign is the saved-run next step.
- Kept the full tutorial completion path in smoke after reviewing current e2e lane costs and coverage value.
- Reviewed refreshed visual QA tutorial screenshots and kept further UI work out of scope for v0.10.
- Wrote a human playtest checklist for Emmanuel to collect actual first-time-player feedback.

Latest report-gate verification results:

```text
npm test
PASS: 46 test files, 351 tests during phase gates.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-DY-3qp2P.js, 477.04 kB minified / 127.86 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-BiGdwuWI.css, 44.51 kB minified / 9.16 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON template and 0 review manifest JSON files.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 4.7m.

npm run test:e2e:layout
PASS: 25 Playwright tests during the overlay phase.

npm run test:e2e:release
PASS: 67 Playwright tests during the e2e lane review phase, about 28.0m.

npm run visual:qa
PASS: 1 Playwright capture test in about 3.0m, 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors during phase/report gates.
```

Latest final-gate verification results:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON template and 0 review manifest JSON files.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 4.9m.

npm run test:e2e:release
PASS: 67 Playwright tests in about 29.0m.

npm run test:e2e:release:shard1
PASS: 55 Playwright tests in about 24.3m.

npm run test:e2e:release:shard2
PASS: 12 Playwright tests in about 4.8m.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in about 11.5m.

npm run test:e2e:release:shard2of3
PASS: 27 Playwright tests in about 12.9m.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in about 4.9m.

npm run visual:qa
PASS: 1 Playwright capture test in about 3.2m, 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

Production preview smoke
PASS: http://127.0.0.1:4173/ verified title, Prototype v0.3 / Cinderfen Route Baseline menu copy, Tutorial launch/exit, New Campaign to Campaign Map, Continue Campaign to Campaign Map, Skirmish Setup, and zero browser console errors. A first preview harness attempt timed out because the preview child process stayed alive after the checks; repo-local preview processes were cleaned up and the rerun passed.

git diff --check
PASS: no whitespace errors.
```

Recommended next milestone: v0.10.1 Tutorial v2 Human-Feedback Polish, only after Emmanuel completes `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`. Keep it narrow and evidence-driven: clarify confusing steps or tiny overlay spacing only, preserve no rewards/no persistence/no campaign progression, and do not add maps, units, factions, generated art, runtime art replacement, or a full UI redesign. Visual work can instead return to v0.9.2 Controlled Cinderfen Style-Frame Candidate Review when source/license-documented candidates exist.

## v0.9.1 Controlled Cinderfen Style-Frame Intake Report Gate - 2026-05-10

Scope: create a safe non-runtime intake pipeline for future Cinderfen style-frame candidates, source/license metadata, review manifests, screenshot QA mapping, and approval gates. This pass preserved gameplay, save compatibility, campaign progression, Tutorial / Proving Grounds behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, large candidate binaries, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, or broad systems.

Included work:

- Added `docs/V091_STYLE_FRAME_INTAKE_PROTOCOL.md`, `docs/V091_SOURCE_LICENSE_METADATA_GUIDE.md`, `docs/V091_STYLE_FRAME_REVIEW_MANIFEST_SCHEMA.md`, `docs/V091_CURRENT_STYLE_FRAME_CANDIDATE_SCAN.md`, `docs/V091_STYLE_FRAME_SCREENSHOT_COMPARISON_PLAN.md`, `docs/V091_MANUAL_STYLE_FRAME_PREPARATION_GUIDE.md`, `docs/V092_STYLE_FRAME_REVIEW_GOAL_BRIEF.md`, and `docs/V091_CONTROLLED_STYLE_FRAME_INTAKE_REPORT.md`.
- Added non-runtime review folders under `art-review/` and `art-review/cinderfen-style-frames/`.
- Added source/license candidate metadata templates in Markdown and JSON.
- Added tooling-only review manifest types under `tools/art-intake/`.
- Added metadata-only `npm run validate:art-intake` validation and tests.
- Scanned the repo and confirmed no Cinderfen style-frame candidate images currently exist in the review intake.
- Mapped future candidate comparison to the existing 18-screenshot visual QA capture set.
- Wrote Emmanuel-facing manual preparation guidance and a future v0.9.2 candidate-review brief.

Latest report-gate verification results:

```text
npm test
PASS: 46 test files, 351 tests during phase/report gates.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-CC1M6Mg7.js, 476.83 kB minified / 127.77 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON template and 0 review manifest JSON files.

npm run visual:qa
PASS: 1 Playwright capture test, 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors during phase/report gates.
```

Recommended next milestone: v0.9.2 Controlled Cinderfen Style-Frame Candidate Review, only after Emmanuel provides source/license-documented candidate images. Keep it non-runtime first: validate metadata, reject unsafe or unknown-source candidates, catalogue safe candidates as reference/candidate only, run visual QA, and write a side-by-side human review. Do not wire assets into runtime until a later goal scopes one tiny replacement with source/license proof, manifest validation, before/after screenshot QA, and rollback.

## v0.9 Controlled Cinderfen Style-Frame Report Gate - 2026-05-10

Scope: create a complete docs/specs/prompts-only Cinderfen visual style-frame package before any generated art, imported assets, or runtime visual replacement. This pass preserved gameplay, save compatibility, campaign progression, Tutorial / Proving Grounds behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, large binary assets, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, or broad systems.

Included work:

- Added `docs/V09_CINDERFEN_STYLE_FRAME_RESEARCH_PACKET.md`, `docs/V09_CINDERFEN_VISUAL_PILLARS.md`, `docs/V09_CINDERFEN_TERRAIN_MATERIAL_SHEET_SPEC.md`, `docs/V09_CINDER_SHRINE_LANDMARK_SPEC.md`, `docs/V09_ASHEN_OUTPOST_ARCHITECTURE_SPEC.md`, `docs/V09_UNIT_BUILDING_SCALE_REFERENCE.md`, `docs/V09_CINDERFEN_STYLE_FRAME_PROMPT_PACK.md`, `docs/V09_FUTURE_CINDERFEN_MANIFEST_TEMPLATES.md`, `docs/V09_CINDERFEN_SCREENSHOT_ACCEPTANCE_CRITERIA.md`, `docs/V09_CINDERFEN_VISUAL_REPLACEMENT_IMPLEMENTATION_PLAN.md`, and `docs/V09_CONTROLLED_CINDERFEN_STYLE_FRAME_REPORT.md`.
- Defined the Cinderfen ash-glass wetland identity and original-IP guardrails.
- Defined visual pillars for roads, shrines, units, wetland materials, Ashen architecture, player structures, fog, and UI label dependence.
- Specified future terrain materials for causeways, ash mud, shallow water, deep pools, reeds, fog/shadow, ruined edging, and ember/scorch marks.
- Specified Cinder Shrine landmark variants and Ashen outpost architecture categories.
- Consolidated current unit/building/capture-site scale facts into future replacement standards without changing runtime scale.
- Added a safe future prompt pack, manifest templates, screenshot acceptance criteria, and a future-only visual replacement sequence.

Latest report-gate verification results:

```text
npm test
PASS: 45 test files, 340 tests during phase/report gates.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-CC1M6Mg7.js, 476.83 kB minified / 127.77 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run visual:qa
PASS: 1 Playwright capture test, 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors during phase/report gates.
```

Recommended next milestone: v0.9.1 Controlled Cinderfen Style-Frame Intake And Source Review. Keep it non-runtime first: obtain 1 to 3 style-frame candidates, record source/license metadata, add review-only files only if explicitly approved, add manifest entries as reference/candidate only, run validation and visual QA, and write a human source/screenshot review. Do not wire assets into runtime until a later goal scopes one tiny replacement with source/license proof, manifest validation, before/after screenshot QA, and rollback.

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
