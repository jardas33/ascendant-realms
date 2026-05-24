# v0.18 Worker Construction Foundation Implementation Report

Date: 2026-05-23
Status: implementation and local verification complete; commit, clean package, and GitHub Actions closeout still happen after this report is committed

## Baseline

- Starting commit: `2fa6de3`, `Update v0.17.5 release handoff after green matrix`.
- Branch: `main`.
- Starting branch state: clean and synced with `origin/main`.
- v0.17.5 package: `artifacts/playtest/ascendant-realms-private-playtest-2fa6de3` exists from the clean v0.17.5 closeout.
- GitHub Actions baseline: prior handoff records CI Release Matrix Dry Run #102 green for fast confidence, simulator, and all six hosted release-matrix groups.

## Implemented

- Added `docs/V018_WORKER_CONSTRUCTION_FOUNDATION_SPEC.md`.
- Added a Free Marches `worker` unit using existing runtime asset conventions only.
- Added `buildOptions` validation for units.
- Added Worker training to the Command Hall.
- Added Worker-owned Build Barracks command rendering.
- Added assigned Worker fields and progress/status details to building construction state.
- Added Worker assignment to Worker-started building placement.
- Added Worker construction gating: assigned Worker must be alive and near the site footprint before progress advances.
- Added Worker approach movement using existing pathfinding/building blocker data.
- Preserved legacy Command Hall direct building placement as the safe fallback route.
- Preserved completed Barracks/Mystic Lodge army production ownership; no Command Hall army-production removal was needed because the current data already keeps army units on production buildings.
- Added incomplete-building UI feedback for production lock, assigned worker, status, and progress.
- Kept incomplete buildings blocked from train/upgrade commands.
- Added focused unit/UI tests for Worker training, Worker build commands, assigned construction progress, incomplete-building status, and footprint-adjacent construction range.
- Added hosted deep-battle browser coverage for Worker training, Worker Barracks placement, assigned construction, completion, and unlocked Barracks training.

## Runtime Changed

Yes.

The battle runtime now supports a first Worker construction path:

- Command Hall trains Workers.
- Workers can place assigned Barracks construction sites.
- Assigned construction sites only progress when the Worker is nearby.
- Completed Barracks becomes usable for existing unit production.

## Worker System

Worker is a light Free Marches builder unit:

- cost: 50 Crowns,
- train time: 3 seconds,
- build option: Barracks,
- no harvesting, repair, or multi-worker acceleration yet.

## Construction System

Construction remains the existing building construction system with an assigned-worker layer added.

Worker approach and progress checks are intentionally conservative:

- blockers still use live building footprints,
- incomplete buildings still block pathing,
- one assigned Worker owns progress,
- footprint proximity is used instead of center distance so crowded base layouts do not strand a Worker beside the construction site.

## Production Changes

- Command Hall gains Worker training.
- Worker selection gains Build Barracks.
- Incomplete Barracks hides train/upgrade actions.
- Completed Barracks retains its existing Militia/Ranger production.
- Existing Command Hall direct build placement remains available.

## Save Format

No save format change.

Worker construction state is battle-runtime state only in v0.18.

## Tutorial Impact

Tutorial is intentionally not migrated to require Worker construction.

The fallback Command Hall placement path remains available so Tutorial onboarding remains stable while the Worker path is tested.

## Art And Assets

No new runtime art/assets.

Worker uses the existing unit fallback/asset convention.

## Verification

```text
npx tsc -p tsconfig.json --noEmit PASS.
npm test -- src/game/systems/BuildingSystem.test.ts src/game/systems/TrainingSystem.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts PASS, 4 files / 14 tests.
npm run build PASS with the known Vite chunk-size warning.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Worker can be trained" --reporter=line PASS, 1 test.
npm test PASS, 61 files / 440 tests.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.8m.
npm run test:e2e:smoke PASS, 14 tests in 7.4m.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "behaviour mode control gauntlet" --reporter=line PASS after hosted helper stabilization.
npm run test:e2e:release:hosted:deep-battle PASS after hosted helper stabilization, 16 tests in 5.3m.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 3.3m.
npm run test:e2e:release PASS, 81 tests in 40.8m.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-2fa6de3-dirty generated.
npm run verify:playtest-package -- --package=artifacts/playtest/ascendant-realms-private-playtest-2fa6de3-dirty PASS, 42 checks.
Packaged build browser boot sanity PASS from the bundled local server at http://127.0.0.1:4174/.
```

## Pending Before Closeout

- clean commit,
- clean package generation and verification,
- `git diff --check`,
- GitHub Actions release matrix rerun after push.
