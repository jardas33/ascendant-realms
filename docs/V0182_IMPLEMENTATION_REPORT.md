# v0.18.2 Worker Construction Expansion Implementation Report

Date: 2026-05-23
Status: implementation, local verification, clean package, and GitHub Actions push closeout complete

## Baseline

- Starting commit: `7ec2701`, `Simplify construction site progress display`.
- Branch: `main`.
- Starting branch state: clean and synced with `origin/main`.
- Current local package before this pass: `artifacts/playtest/ascendant-realms-private-playtest-7ec2701`.

## Implemented

- Expanded Worker build options from Barracks only to Barracks, Mystic Lodge, and Watchtower.
- Kept Command Hall player-facing construction disabled; it still trains Workers.
- Preserved the existing generic Worker assignment path for all Worker-built structures.
- Preserved existing Barracks, Mystic Lodge, and Watchtower costs, footprints, art conventions, construction times, and completed behavior.
- Added focused command-panel coverage for all Worker build buttons and affordability copy.
- Added a combat regression proving under-construction Watchtowers do not fire before completion.
- Cleaned selected construction-site UI copy from `Worker Worker` to `Assigned Worker`.
- Added package docs for the v0.18.2 retest focus.

## Runtime Changed

Yes.

Worker construction now covers the existing player build set instead of only Barracks:

- Barracks.
- Mystic Lodge.
- Watchtower.

No harvesting, repair, multiple-worker acceleration, enemy construction AI, save migration, new art/assets, new maps, new factions, Patrol runtime, formations, or global rebalance were added.

## Worker System

Worker remains the same basic Free Marches builder. The only Worker data change is the build-option list.

## Construction System

No new construction state shape was required.

The existing assigned-worker construction system already supports arbitrary building ids through `BuildingSystem.startPlacement`. This pass reuses that path for Mystic Lodge and Watchtower.

## Production Changes

- Command Hall: trains Worker, no build commands.
- Worker: builds Barracks, Mystic Lodge, Watchtower.
- Incomplete production buildings: no train/research commands.
- Incomplete Watchtower: no attack.
- Completed buildings: existing production/attack behavior resumes.

## Save Format

No save format change.

## Tutorial Impact

Tutorial remains on the existing Worker Barracks route. No new Tutorial objectives were added for Mystic Lodge or Watchtower.

## Verification And Closeout

```text
npx vitest run src/game/playtest/PlaytestPackageValidation.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts src/game/systems/TrainingSystem.test.ts src/game/systems/CombatSystem.test.ts src/game/systems/BuildingSystem.test.ts --reporter=dot PASS, 6 files / 49 tests.
npx tsc -p tsconfig.json --noEmit PASS.
npm run build PASS with the known Vite chunk-size warning.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Worker can be trained|Worker exposes existing build set" --reporter=line PASS, 2 hosted tests in 1.8m.
npm test PASS, 61 files / 442 tests.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run playtest:sim PASS, 255 simulated runs across 85 campaign battle nodes.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.8m.
npm run test:e2e:smoke PASS, 14 tests in 7.6m.
npm run test:e2e:release:hosted:deep-battle PASS, 17 tests in 6.2m.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 3.4m.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests in 1.8m.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests in 1.9m.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests in 3.6m.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests in 3.5m.
npm run test:e2e:release PASS, 82 tests in 39.3m.
npm run smoke:preview PASS at http://127.0.0.1:4173/ with 0 browser console errors.
```

Post-commit closeout completed on 2026-05-24:

- `git diff --check` passed before commit.
- Implementation commit `a20da05` (`Checkpoint v0.18.2 worker construction expansion`) was pushed to `origin/main`.
- Clean package `artifacts/playtest/ascendant-realms-private-playtest-a20da05` was generated from a clean tree and passed package verification with 44 checks.
- The package was served locally at `http://127.0.0.1:4174/`; Browser boot sanity reached the main menu, rendered a 1280x720 canvas, and reported no browser console errors.
- GitHub Actions push run #107 / `26351035731` completed successfully for commit `a20da05`. The Fast confidence job passed. Release matrix, simulator, optional visual QA, and full release e2e jobs were skipped on push by workflow rules, so the release-matrix evidence for this checkpoint is the local production-preview matrix above.

## Package

The package identifies this as `v0.18.2 worker construction expansion` and includes both the v0.18 foundation docs and the v0.18.2 expansion docs.

## Emmanuel Retest

Suggested retest route:

1. Launch the package.
2. Start Tutorial or First Claim.
3. Select Command Hall and confirm it trains Worker but has no build buttons.
4. Train Worker.
5. Select Worker and confirm Barracks, Mystic Lodge, and Watchtower are visible.
6. Build one structure and confirm a single world bar plus side-panel progress/status.
7. Confirm incomplete production/attack behavior is disabled.
8. Complete the structure and confirm normal completed behavior resumes.
