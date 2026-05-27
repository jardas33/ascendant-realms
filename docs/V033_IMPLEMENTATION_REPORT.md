# v0.33 Hero Relic Loadout Implementation Report

Date: 2026-05-27

## Scope

v0.33 adds the first tiny hero relic loadout foundation on top of the v0.32 persistent relic inventory. The hero can equip one relic through the existing equipment pipeline, and equipped relics apply modest stat effects through the existing live-stat calculation.

No equipment paper-doll, broad inventory redesign, shop, crafting, random relic roll, large loot table, new art/assets, new maps/factions, save-version bump, global rebalance, Patrol, formations, or broad AI/pathing rewrite was added.

## Loadout

- `equipment.relic` is now included in the shared equipment slot list.
- Existing Results and Hero Inventory equip actions can equip relic item instances.
- Existing Hero Inventory unequip handling now accepts `relic`.
- Opening Hero Inventory shows the Relic equipment row and relic inventory rows through the same item presentation used for weapons/armor/trinkets.

## Effects

Relic effects are existing item stat modifiers and apply only while the relic is equipped:

- `Emberbrand Shard`: +2 damage, +1 might.
- `Cinder-Seer Focus`: +18 max Mana, +2 arcana.
- `Outpost Command Signet`: +24 max HP, +1 armor, +1 command.

Unequipping removes the effect on the next stat recalculation. Duplicate relic stacking is blocked by the unique duplicate policy.

## UI

Results now show:

- Relic Reward block;
- relic name and source champion;
- inventory/duplicate status;
- effect summary and stat summary;
- "Relic effects are active when equipped.";
- an `Equip Relic` button when a newly granted relic instance is present.

Hero Inventory now shows:

- Relic equipment slot;
- relic item rows in the existing inventory list;
- equip/unequip through existing actions;
- the same stat-preview and total-stat copy used by other equipment.

Battle HUD now shows:

- `Relic: Empty` when no relic is equipped;
- `Relic: <name> active` when a known relic is equipped.

## Tutorial Impact

Tutorial / Proving Grounds still launches with a transient no-save hero and `rewardsDisabled: true`. It does not grant relics, does not show the Relic Reward block, and does not persist relic state.

## Tests

Added or extended coverage for:

- equipped relic stat effects applying and disappearing when unequipped;
- Results rendering the persistent relic reward and Equip Relic action;
- Hero HUD rendering the equipped relic summary;
- Hero Inventory opening from Results after equipping the relic;
- Tutorial results remaining free of relic rewards.

## Verification

Closeout verification passed:

```text
npx vitest run src/game/core/RelicRewardRules.test.ts src/game/core/RivalRules.test.ts src/game/core/SaveSystem.test.ts src/game/core/HeroProgressionRules.test.ts src/game/results/ResultsViewModel.test.ts src/game/ui/hudPanels/HeroHudPanel.test.ts src/game/data/contentValidation.test.ts PASS, 7 files / 107 tests.
npm test PASS, 73 files / 546 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Ashen Outpost special objectives" --reporter=line PASS, 1 hosted test.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
git diff --check PASS.
```

Package verification and the optional local full-release rerun note are recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md` for the checkpoint closeout.
