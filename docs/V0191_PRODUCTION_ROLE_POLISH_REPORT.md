# v0.19.1 Production Role Polish Report

Date: 2026-05-24
Status: implemented and locally verified; clean package generation follows the final commit

## Baseline

- Starting commit: `ec73568`, `Checkpoint v0.19 production architecture and building roles`.
- Starting package: `ascendant-realms-private-playtest-ec73568`.
- Branch state before edits: clean `main`, synced with `origin/main`.
- v0.18.3 worker construction/pathing retest: passed by Emmanuel, and the green v0.18.3 release matrix remains the Worker construction foundation baseline.

## Runtime Changed

Small copy/readability changes only:

- Command Hall role copy now explicitly says it trains Workers only.
- Mystic Lodge role copy now names Aether Study I consistently.
- Watchtower role copy now states that it is inactive while incomplete and attacks when complete.
- Incomplete-building command-panel status now reads `Incomplete - actions locked until construction finishes.`
- Defeat-tip copy now points players to train a Worker from the Command Hall and then build a Barracks, instead of implying Command Hall direct construction.

No systems, stats, costs, build times, maps, factions, save format, art, AI/pathing rewrite, harvesting, repair, multi-worker acceleration, enemy construction AI, Patrol, or formations were added.

## Automated Coverage Added Or Extended

- Added a production-role data audit proving Command Hall, Worker, Barracks, Mystic Lodge, Watchtower, and upgrade prerequisites match the v0.19 architecture.
- Extended command-panel coverage for:
  - Command Hall Worker-only UI.
  - no Command Hall army/research/build actions.
  - incomplete Barracks/Mystic Lodge/Watchtower role/status/unlock copy with no train/research actions.
  - completed Mystic Lodge Acolyte and Aether Study I ownership.
- Updated selected-building and HUD-formatting coverage for polished role copy.
- Updated hosted deep-battle expectations for new incomplete-building and Watchtower role copy.
- Added hosted tutorial/manual-proxy coverage for Command Hall -> Worker -> Barracks -> army and Watchtower role readability.
- Updated hosted layout coverage so Command Hall reachability expects the v0.19 Worker-training role instead of stale build/upgrade actions.

## Verification

```text
npm exec vitest run src/game/data/productionRoles.test.ts src/game/ui/hudPanels/HudFormatting.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts src/game/core/ResultsFlow.test.ts src/game/playtest/PlaytestPackageValidation.test.ts -- --reporter=dot PASS, 6 files / 33 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Tutorial production route" --reporter=line PASS, 1 test.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Tutorial production route|behaviour mode control gauntlet" --reporter=line PASS, 2 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm test PASS, 62 files / 458 tests.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 19 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-ec73568-dirty generated.
npm run verify:playtest-package PASS, 51 checks.
git diff --check PASS.
```

Remote CI:

- v0.19 push run #112 on `ec73568` passed Fast confidence and skipped release-matrix lanes by push rules.
- Manual workflow-dispatch run #113 on `ec73568` passed Fast confidence, Release simulator, and hosted release groups deep-meta, deep-battle, deep-campaign-pressure, and smoke.
- Run #113 failed only hosted layout-core/layout-cinderfen because those tests still expected removed Command Hall build/upgrade actions. v0.19.1 updates the stale layout expectation, and both local hosted layout lanes pass after the fix.

## Package

Dirty package generation and package verification passed with 51 checks. Final clean package generation and verification run again after the v0.19.1 commit.

## Emmanuel Retest Focus

1. Command Hall trains Worker only.
2. Worker builds Barracks, Mystic Lodge, and Watchtower.
3. Incomplete structures show role/unlock/status copy and stay inactive.
4. Completed Barracks trains Militia/Ranger and researches Infantry Weapons I, Reinforced Armor I, and Ranger Training I.
5. Completed Mystic Lodge trains Acolyte and researches Aether Study I.
6. Incomplete Watchtower stays inert; completed Watchtower defends.
7. Worker move-away pause/resume and compact base-cluster movement remain stable.
