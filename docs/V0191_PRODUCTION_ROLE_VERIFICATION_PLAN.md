# v0.19.1 Production Role Verification Plan

Date: 2026-05-24
Status: completed locally; clean package generation follows the final commit

## Baseline

- Starting commit: `ec73568`, `Checkpoint v0.19 production architecture and building roles`.
- Starting package: `ascendant-realms-private-playtest-ec73568`.
- Branch state before edits: clean `main`, synced with `origin/main`.
- Emmanuel v0.18.3 retest result: Worker construction assignment, pause/resume, and base-cluster pathing now seem resolved.
- v0.19 local result: production architecture role migration was locally green and packaged.

## Scope

This is an automated verification and role-readability polish checkpoint before v0.20.

Included:

- Reconfirm Command Hall Worker-only production ownership.
- Reconfirm Worker-built Barracks, Mystic Lodge, and Watchtower remain the existing construction set.
- Reconfirm incomplete buildings expose role/status/unlock copy but no completed-building train or research actions.
- Reconfirm completed Barracks owns Militia/Ranger and Infantry Weapons I, Reinforced Armor I, Ranger Training I.
- Reconfirm completed Mystic Lodge owns Acolyte and Aether Study I.
- Reconfirm incomplete Watchtower cannot attack and completed Watchtower attacks.
- Reconfirm v0.18.3 Worker construction pause/resume and building-cluster pathing coverage still run.
- Add a focused hosted tutorial/manual-proxy route for Command Hall -> Worker -> Barracks -> army plus Watchtower role copy.

Not included:

- Harvesting.
- Repair.
- Multiple-worker acceleration.
- Enemy construction AI.
- New maps or factions.
- Runtime art/assets.
- Save migration.
- Broad AI/pathing rewrite.
- Global rebalance.
- Patrol or formations.

## Automated Audit Targets

1. Data ownership:
   - Command Hall trains only Worker.
   - Command Hall has no army train options, build options, or basic troop research.
   - Worker builds Barracks, Mystic Lodge, and Watchtower.
   - Barracks owns basic army training and basic troop research.
   - Mystic Lodge owns Acolyte and Aether Study I.
   - Watchtower owns defensive attack only.

2. HUD ownership:
   - Completed Command Hall reads as a Worker-only base hub.
   - Incomplete Barracks/Mystic Lodge/Watchtower show role and unlock copy but no completed train/research actions.
   - Completed Barracks and Mystic Lodge expose their proper train/research actions.
   - Completed Watchtower reads as defense-ready instead of production idle.

3. Runtime behavior:
   - Incomplete Watchtower remains inert.
   - Completed Watchtower attacks enemies in range.
   - Worker move-away pauses construction and moving back resumes progress.
   - Worker, Militia, and Ranger still move out of a compact Command Hall + Barracks + Mystic Lodge + Watchtower cluster.

4. Hosted tutorial proxy:
   - Launch Tutorial.
   - Select Command Hall and train Worker.
   - Build Barracks from Worker.
   - Confirm incomplete role/status copy.
   - Complete Barracks and train Militia/Ranger from Barracks.
   - Build Watchtower if the route can do so without lengthening the test.
   - Confirm incomplete and completed role copy.

## Verification Completed

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

Notes:

- The hosted Tutorial proxy is intentionally focused. It uses normal UI commands for production actions and a scene-backed placement helper only after the UI has entered pending building placement, so it does not add force clicks or DOM fallback for canvas/world clicks.
- The hosted behaviour gauntlet still uses real canvas/world click delivery; the v0.19.1 stability tweak only changed the retreat target to a known open point and increased existing click-retry attempts for the intermittent hosted attack-command delivery case.
- Clean package generation and package verification run again after the final v0.19.1 commit.

## Package Retest Focus

Emmanuel's next package retest should focus on:

- Command Hall Worker-only.
- Worker-built buildings.
- inactive incomplete structures.
- Barracks army and basic troop research.
- Mystic Lodge Acolyte and Aether Study I.
- Watchtower defense.
- Worker pause/resume and compact base-cluster pathing stability.
