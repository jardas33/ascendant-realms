# v0.37 Ability Upgrade Foundation Implementation Report

Date: 2026-05-28

## Scope

v0.37 adds a small data-driven ability upgrade layer on top of existing hero abilities. It upgrades current ability definitions at runtime from allocated skill nodes instead of adding a large ability roster. It does not add new maps, factions, runtime art/assets, new targeting widgets, enemy hero ability upgrades, a save-version bump, broad AI/pathing rewrites, global rebalance, Patrol, formations, or canvas/world force-click behavior.

## Ability Upgrade Rules

- Skill nodes can now carry an `abilityUpgrade` definition with target ability ids, effect summary, and modest numeric deltas.
- Runtime ability handling derives an effective ability from base ability data plus allocated skills.
- Upgrade deltas support damage amount, Mana cost, cooldown, radius, and duration.
- Unknown skill ids and unknown ability ids are ignored safely by upgrade helpers and validated in content checks.

## Initial Upgrades

- Warrior: Cleave gains a modest damage increase and small cooldown reduction.
- Seer: Aether Flow reduces Mana costs for learned abilities.
- Seer: Arcane Burst can receive a modest damage and cooldown support upgrade when unlocked.
- Commander: Rally Banner gains a modest radius and duration increase.
- Commander: War Cry receives a modest duration support upgrade when unlocked.

## UI

- Skill cards show ability-upgrade summaries before spending.
- Battle HUD ability buttons show effective Mana cost, cooldown, and upgrade/synergy summary in their tooltips.
- Ability execution uses the same effective ability values shown in the HUD, so copy and runtime behavior stay aligned.

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
