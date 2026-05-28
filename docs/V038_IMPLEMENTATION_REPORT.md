# v0.38 Relic Build Synergy Implementation Report

Date: 2026-05-28

## Scope

v0.38 lightly connects the v0.34-v0.35 relic build identities to the new skill branches. Synergy is derived from the existing one-slot relic loadout and existing allocated skill map. It does not add relic slots, relic leveling, a large relic pool, skill-gated relic requirements, shop, crafting, runtime art/assets, a save-version bump, global rebalance, broad AI/pathing rewrites, Patrol, formations, or canvas/world force-click behavior.

## Synergy Rules

- Emberbrand Shard supports Warrior.
- Cinder-Seer Focus supports Seer.
- Outpost Command Signet supports Commander.
- Synergy is active only when the matching relic is equipped and at least one skill in the matching branch is allocated.
- Unequipped relics give no synergy.
- Unknown relic ids and unknown skill ids are ignored safely.
- The current one-slot loadout prevents accidental multi-relic stacking.

## Initial Bonuses

- Warrior synergy gives Cleave a small extra damage bonus.
- Seer synergy gives learned abilities a small Mana and cooldown support bonus.
- Commander synergy gives Rally Banner a small extra radius and duration bonus.

## UI

- Battle HUD shows active relic synergy in the hero summary and ability tooltips.
- Hero Inventory and Equipment rows show the equipped relic's active synergy when the matching branch is unlocked.
- Results show the current equipped relic/build identity and a skill-point reminder when hero progression creates spending decisions.

## Tutorial Impact

Tutorial / Proving Grounds remains no-save/no-reward. It does not require skill spending, relic rewards, or relic synergy to complete.

## Verification

Required verification passed:

```text
npx vitest run src/game/core/HeroProgressionRules.test.ts src/game/core/SaveSystem.test.ts src/game/systems/AbilitySystem.test.ts src/game/ui/AbilityBar.test.ts src/game/ui/hudPanels/HeroHudPanel.test.ts src/game/results/ResultsViewModel.test.ts src/game/data/contentValidation.test.ts src/game/playtest/PlaytestPackageValidation.test.ts PASS, 8 files / 109 tests.
npm test PASS, 73 files / 554 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "inventory equipment, unequip, and skill spending|unlocked hero ability hotkeys" --reporter=line PASS after exact skill/relic locator follow-up, 2 hosted tests.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-b09ef96-dirty` generated.
npm run verify:playtest-package PASS, 112 checks against the dirty pre-commit package.
git diff --check PASS.
```

Optional `npm run test:e2e:release` was not run for this closeout. The required hosted release groups and visual QA are the final release evidence.
