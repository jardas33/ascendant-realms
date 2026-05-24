# v0.20 Tech Tree Foundation Implementation Report

Date: 2026-05-24
Status: implemented and locally verified; final clean package generation pending the checkpoint commit

## Baseline

- Starting commit: `a59248c`, `Checkpoint v0.19.1 production architecture verification and role polish`.
- Starting package: `ascendant-realms-private-playtest-a59248c`.
- Branch state before edits: clean `main`, synced with `origin/main`.
- Remote baseline: GitHub Actions CI Release Matrix Dry Run #115 passed on `main` / `a59248c`.

## Runtime Changes

- Added explicit owner/category/tier/effect-summary metadata to battle upgrades.
- Added Command Hall core upgrade `Camp Foundations I`.
- Added Watchtower defensive upgrade `Sentry Bracing I`.
- Added a small building-upgrade effect path for building armor bonuses.
- Kept existing Barracks and Mystic Lodge upgrade effects unchanged.
- Kept incomplete-building research locked.
- Kept Tutorial step count stable with only light upgrade-readability copy.

## Tests

- Added upgrade data audit coverage for owner/category/effect summaries and the small player upgrade layer.
- Added command-panel tests for owner, requirement, effect, locked, researching, and researched text.
- Added upgrade-system tests for incomplete-building lock and Watchtower prerequisite lock.
- Added upgrade-effects tests for building armor upgrade application.
- Extended the hosted Tutorial production proxy for Worker-built Barracks completion and Barracks upgrade research UI.

## Verification

```text
npm exec vitest run src/game/data/techTree.test.ts src/game/data/productionRoles.test.ts src/game/systems/UpgradeSystem.test.ts src/game/systems/UpgradeEffects.test.ts src/game/ui/hudPanels/HudFormatting.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts src/game/tutorial/TutorialStepModel.test.ts src/game/systems/TrainingSystem.test.ts src/game/playtest/PlaytestPackageValidation.test.ts -- --reporter=dot PASS, 10 files / 43 tests.
npm test PASS, 63 files / 465 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Tutorial production route keeps Command Hall, Barracks, and Watchtower roles readable" --reporter=line PASS, 1 hosted Tutorial proxy test.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 19 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-a59248c-dirty generated.
npm run verify:playtest-package PASS, 53 checks.
```

## Package

- Dirty package verified before commit: `artifacts/playtest/ascendant-realms-private-playtest-a59248c-dirty`.
- Final clean package should be regenerated and verified after the checkpoint commit.

## Emmanuel Retest Focus

1. Command Hall still trains Workers only and now exposes only the small core upgrade.
2. Worker-built Barracks still completes and exposes existing basic troop upgrades.
3. Mystic Lodge still owns Aether Study I.
4. Watchtower remains defensive and exposes only its simple defensive upgrade after completion.
5. Incomplete buildings still cannot research.
6. Upgrade buttons clearly show owner, requirements, cost, effect, and researched state.
7. v0.18.3 Worker construction pause/resume and v0.19 production roles remain stable.
