# v0.19 Production Architecture Implementation Report

Date: 2026-05-24
Status: complete; local verification green

## Baseline

- Starting point: `5762120`, a docs-only descendant of the accepted v0.18.3 runtime baseline.
- v0.18.3 accepted runtime/package baseline: commit `ce43d0e`, package `ascendant-realms-private-playtest-ce43d0e`.
- Emmanuel retest: Worker construction assignment, pause/resume, and base-cluster pathing now seem resolved.
- GitHub Actions CI Release Matrix Dry Run #26365296115 passed on `main` / `ce43d0e`; rerun the matrix after the v0.19 commit if remote release evidence is needed for this new runtime role migration.

## Runtime Changed

Yes. Existing production ownership changed, but no new content was added.

- Command Hall now exposes Worker training only and no research actions.
- Barracks now owns existing basic troop research in addition to Militia/Ranger training.
- Infantry Weapons I and Reinforced Armor I now require a completed Barracks instead of the Command Hall.
- Mystic Lodge keeps existing Acolyte and Aether Study I actions.
- Watchtower keeps existing completed-only defensive attack behavior.

## UI Changed

- Building descriptions now state role clearly.
- Command buttons include existing role/effect summaries for production buildings and defensive structures.
- Incomplete buildings now show role, completion unlocks, and inactive status instead of generic production-lock copy.
- Selected buildings show role text.
- Selected construction sites show role, status, progress, assigned Worker, and unlock summary.
- Completed Watchtower now reads as defense-ready rather than a queue-style production building.

## Tutorial Changed

- Tutorial / Proving Grounds keeps the same 12 steps.
- Copy now explains:
  - Command Hall -> Worker.
  - Worker -> building.
  - Barracks -> army.
  - Watchtower -> defense.
- No new Tutorial objective, reward, save behavior, unit, building, or map was added.

## Tests Added Or Extended

- Command panel coverage for Command Hall Worker-only UI and Barracks-owned army train/research actions.
- Incomplete building command-panel coverage for role/unlock copy and inactive train/research actions.
- Selected-building coverage for completed role labels, construction role/unlock status, and completed Watchtower defense-ready status.
- HUD formatting coverage for building roles and completion unlocks.
- Training/upgrade system coverage for Command Hall Worker-only role and Barracks-owned basic research.
- Tutorial step-model coverage that v0.19 role copy was added without increasing Tutorial length.
- Hosted deep-battle coverage was extended to check Command Hall has no army train/research actions and incomplete buildings use the new role/status copy.

## Verification

Focused checks already run during implementation:

```text
npm exec vitest run src/game/ui/hudPanels/HudFormatting.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts src/game/tutorial/TutorialStepModel.test.ts src/game/systems/TrainingSystem.test.ts src/game/systems/UpgradeSystem.test.ts PASS, 6 files / 27 tests.
npm exec tsc -- --noEmit PASS.
```

Full requested verification:

```text
npm test PASS, 61 files / 454 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 3.7m.
npm run test:e2e:smoke PASS, 14 tests in 7.7m after exact rerun; the first attempt hit the known cold dev-server main-menu boot timeout on test 1 while the remaining 13 tests passed.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 18 tests in 8.9m after fixing the existing behaviour-gauntlet left-click to use the real-canvas retry helper; two earlier full-lane attempts failed that single existing gauntlet assertion while the Worker/building-role tests passed.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests in 2.5m. Extra coverage because the research UI test was updated for Barracks-owned basic research.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 4.4m.
npm run package:playtest PASS, dirty package `artifacts/playtest/ascendant-realms-private-playtest-5762120-dirty` generated.
npm run verify:playtest-package -- --package=artifacts/playtest/ascendant-realms-private-playtest-5762120-dirty PASS, 48 checks.
git diff --check PASS.
```

## Emmanuel Retest Focus

1. Command Hall trains Worker only in normal UI.
2. Worker can build Barracks, Mystic Lodge, and Watchtower.
3. Incomplete Barracks, Mystic Lodge, and Watchtower stay inactive.
4. Completed Barracks trains Militia/Ranger and exposes existing basic troop upgrades.
5. Completed Mystic Lodge trains Acolyte and exposes Aether Study I.
6. Completed Watchtower attacks defensively.
7. Worker construction pause/resume and compact base-cluster movement remain stable from v0.18.3.
