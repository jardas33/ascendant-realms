# v0.36 Hero Skill Tree Foundation Implementation Report

Date: 2026-05-28

## Scope

v0.36 turns the existing hero skill-point panel into a compact Warrior / Seer / Commander build foundation. The implementation uses the existing `HeroSaveData.allocatedSkills` map, current hero skill points, and the existing Hero Inventory / progression screen. It does not add maps, factions, runtime art/assets, shop, crafting, broad inventory UI, enemy hero skill trees, a save-version bump, global rebalance, Patrol, formations, broad AI/pathing changes, or canvas/world force-click behavior.

## Skill Tree

- The visible tree now has three player-facing branches: Warrior, Seer, and Commander.
- Each branch stays tiny with 2-3 visible nodes.
- Legacy compatibility nodes that are outside the current foundation remain loadable but hidden from the visible panel.
- Hidden legacy nodes cannot be newly allocated through the skill rules.
- Skill cards show branch identity, cost, locked/unlocked state, stat modifiers, ability upgrade summary, and the existing disabled reason when spending is unavailable.

## Save Compatibility

- No save-version bump.
- Old saves without `allocatedSkills` still normalize safely.
- Unknown skill ids remain loadable in saved data but are ignored by stat, ability, and synergy helpers.
- Existing skill points remain the currency for unlocks.

## UI

- The Hero Inventory progression screen shows the three build branches through existing skill cards.
- The Hero Progression scene adds a compact build identity panel that summarizes unlocked branches and active relic synergy.
- Results can remind the player to spend available skill points in Hero Inventory after progression.

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
