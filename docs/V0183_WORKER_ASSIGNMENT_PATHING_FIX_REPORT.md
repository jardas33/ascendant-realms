# v0.18.3 Worker Assignment And Pathing Fix Report

Date: 2026-05-24
Status: implementation, requested verification, dirty package validation, and diff check complete before commit

## Baseline

- Starting commit: `039fe64`, `Document v0.18.2 worker construction closeout`.
- Latest tested package: `artifacts/playtest/ascendant-realms-private-playtest-039fe64`.
- Manual retest intake: `docs/V0183_EMMANUEL_039FE64_WORKER_RETEST_INTAKE.md`.

## Scope

Bugfix pass only for v0.18.2 Worker construction assignment, construction pause/resume, and building-cluster pathing.

Not included:

- v0.19 feature work.
- Harvesting.
- Repair.
- Multiple-worker acceleration.
- Enemy construction AI.
- New units, buildings, maps, or factions.
- Save migration.
- Runtime art/assets.
- Broad global rebalance.
- Patrol or formations.

## Fix Summary

- Added explicit Worker construction intent tracking.
- Construction auto-move now uses a construction-specific Worker command instead of an ordinary move order.
- Ordinary player move and attack commands pause the current construction intent instead of being overwritten by construction auto-return.
- A paused assigned site no longer pulls the Worker back while the Worker has an explicit move-away target.
- Moving the Worker back into valid work range resumes construction.
- Construction site status uses existing UI copy: `Building`, `Paused - Worker away`, assigned Worker, and progress.
- Movement pathfinding now uses a finer production-preview path grid and exact terrain/static-obstacle edge checks so partial terrain/building cells do not act like invisible blockers.
- Exact blocker interiors remain solid; open points in the same coarse cell can still be walked to when the precise point is outside the blocker.
- Hosted browser click retries were kept on real canvas/world clicks only, with no forced clicks and no DOM fallback for canvas movement or placement commands.

## Runtime Changed

Yes.

Worker construction assignment and pathfinding behavior changed. Costs, stats, build times, production options, maps, art, save format, and global balance did not change.

## Tests Added Or Extended

- Building system coverage for explicit Worker move-away pause, immediate pause before the Worker leaves range, and resume after moving back.
- Building system coverage for approach points around Barracks, Mystic Lodge, and Watchtower.
- Movement system coverage for Worker/Militia/Ranger movement out of a Command Hall + Barracks + Mystic Lodge + Watchtower cluster.
- Movement system coverage for exact open ground beside blocked terrain.
- Hosted deep-battle regression for Worker move-away pause/resume and base-cluster attack movement.

## Verification

Requested verification:

```text
npm test PASS, 61 files / 450 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 3.8m after rerunning the same command; the first attempt hit a cold Vite dev-server boot timeout before Phaser reached the main menu.
npm run test:e2e:smoke PASS, 14 tests in 9.3m after prewarming the dev server; the cold dev-server first test timed out before app boot, then the warmed rerun passed.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 18 tests in 8.9m.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 4.3m.
npm run package:playtest PASS, dirty package `artifacts/playtest/ascendant-realms-private-playtest-039fe64-dirty` generated.
npm run verify:playtest-package -- --package=artifacts/playtest/ascendant-realms-private-playtest-039fe64-dirty PASS, 46 checks.
git diff --check PASS.
```

Focused verification already run during implementation:

```text
npx tsc -p tsconfig.json --noEmit PASS.
npx vitest run src/game/systems/BuildingSystem.test.ts src/game/systems/MovementSystem.test.ts src/game/systems/CombatSystem.test.ts --reporter=dot PASS, 3 files / 47 tests.
npx vitest run src/game/systems/PathfindingGrid.test.ts src/game/systems/TrainingSystem.test.ts src/game/systems/MovementSystem.test.ts --reporter=dot PASS, 3 files / 17 tests.
npx vitest run src/game/systems/BuildingSystem.test.ts src/game/systems/MovementSystem.test.ts src/game/systems/PathfindingGrid.test.ts src/game/systems/TrainingSystem.test.ts --reporter=dot PASS, 4 files / 25 tests.
npm run build PASS with the known Vite chunk-size warning.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Worker move-away pauses construction" --reporter=line PASS, 1 hosted test in 27.7s after rebuilding production dist.
```

## Emmanuel Retest Focus

1. Launch the v0.18.3 package.
2. Train a Worker from the Command Hall.
3. Start a Barracks, Mystic Lodge, or Watchtower construction site.
4. Move the assigned Worker away while the site is under construction.
5. Confirm construction pauses and the Worker does not get pulled back.
6. Move the Worker back beside the site and confirm progress resumes.
7. Build a compact base cluster and confirm Worker, Militia, and Ranger can move out toward enemies.
8. Confirm incomplete Watchtower still cannot attack and completed Watchtower still attacks.
