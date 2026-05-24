# v0.21 Worker Repair Foundation Implementation Report

Date: 2026-05-24
Status: implemented and locally verified; final clean package generation pending the checkpoint commit

## Baseline

- Starting commit: `1ae687e`, `Checkpoint v0.20.1 tech tree closeout and polish`.
- Starting package: `ascendant-realms-private-playtest-1ae687e`.
- Branch baseline before edits: clean `main`, synced with `origin/main`.

## Runtime Changed

Yes. v0.21 adds the first Worker repair action.

- Added Worker repair intent state separate from construction, move, and attack intent.
- Added `RepairSystem` for repair validation, approach movement, pause/resume, and HP restoration.
- Repair is allowed only for damaged friendly completed buildings.
- Repair does not work on enemy buildings.
- Repair does not work on incomplete buildings; construction remains the incomplete-building action.
- Full-health buildings report already repaired/full health and do not start repair.
- Explicit move and attack orders pause repair so Workers are not pulled back like the old v0.18.2 construction magnet.
- Moving back into range or reissuing Repair resumes repair.
- Repair has no resource cost in v0.21 and is intentionally slow; resource-cost repair is future economy work.

## UI Changed

- Selected Workers show Repair commands for completed friendly buildings.
- Damaged repair commands show target HP, no-cost status, and the near-target requirement.
- Full-health repair commands are disabled and marked already repaired.
- Selected Worker order summary shows `Repairing` or `Repair Paused`.
- Selected completed buildings show `Repair Full health` or `Repair Damaged - select a Worker or right-click with a Worker`.

## Tests Added Or Extended

- Repair system coverage for Command Hall, Barracks, Mystic Lodge, and Watchtower repair.
- Repair system negative coverage for enemy buildings, full-health buildings, and incomplete construction sites.
- Repair pause/resume coverage for explicit move and attack orders.
- Repair approach coverage around building footprints.
- Command-panel coverage for Worker repair buttons and full-health disabled status.
- Selected-building coverage for damaged/full-health repair readability.
- Unit-order summary coverage for active and paused repair.
- Hosted deep-battle proxy for damaging a completed Barracks, issuing Worker repair, confirming HP increases, move-away pauses repair, and moving back resumes repair.

## Verification

Focused checks run during implementation:

```text
npm exec tsc -- --noEmit PASS.
npm exec vitest run src/game/systems/RepairSystem.test.ts src/game/systems/BuildingSystem.test.ts src/game/ui/UnitOrderSummary.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts -- --reporter=dot PASS, 5 files / 38 tests.
npm exec vitest run src/game/playtest/PlaytestPackageValidation.test.ts -- --reporter=dot PASS, 1 file / 3 tests.
npm run build PASS with the known Vite chunk-size warning.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Worker repairs a damaged friendly completed building" --reporter=line PASS, 1 hosted repair proxy test.
```

Full requested verification:

```text
npm test PASS, 64 files / 478 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 20 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-1ae687e-dirty generated.
npm run verify:playtest-package PASS, 56 checks.
git diff --check PASS.
```

Closeout note: commit as `Checkpoint v0.21 worker repair foundation`, then regenerate and verify the clean package from the final commit.

## Emmanuel Retest Focus

1. Train a Worker from the Command Hall.
2. Damage a friendly completed Command Hall, Barracks, Mystic Lodge, or Watchtower.
3. Select the Worker and use Repair on the damaged building.
4. Confirm repair progresses only while the Worker is alive and near the footprint.
5. Move the Worker away and confirm repair pauses without pulling the Worker back.
6. Move the Worker back or issue Repair again and confirm repair resumes.
7. Confirm enemy buildings cannot be repaired.
8. Confirm full-health buildings show already repaired/full health feedback.
9. Confirm incomplete buildings remain construction sites and do not become repair targets.
10. Confirm v0.18.3 construction pause/resume and pathing still feel stable.
