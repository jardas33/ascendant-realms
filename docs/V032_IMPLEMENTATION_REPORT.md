# v0.32 Persistent Relic Inventory Implementation Report

Date: 2026-05-27

## Scope

v0.32 promotes the three v0.31 relic reward candidates from preview-only copy into persistent hero inventory items. The implementation stays inside the existing `HeroSaveData.inventory` and `HeroSaveData.equipment` structures, so there is no new save field and no save-version bump.

This pass does not add maps, factions, runtime art/assets, a broad inventory UI, shop, crafting, a large loot table, Patrol, formations, global rebalance, broad AI/pathing rewrites, or force-click/DOM fallback behavior for canvas/world interactions.

## Runtime Changes

- Added `emberbrand_shard`, `cinderseer_focus`, and `outpost_command_signet` as unique `slot: "relic"` item definitions.
- Converted `src/game/data/relicRewards.ts` to persistent relic reward metadata with item id, rarity, tier/category, source champion, acquisition source, effect summary, tags, and duplicate policy.
- Added `src/game/core/progression/RelicInventoryRules.ts` to derive acquired/equipped relic ids from normalized hero inventory and equipment.
- Updated relic reward rules to auto-grant the matching source relic after an eligible rival champion victory.
- Kept Tutorial and rewards-disabled launches protected from relic selection/grants.
- Converted unique duplicate relics into the existing unique-item duplicate conversion result instead of adding another relic instance.

## Save Format

Save version stays at the existing version. Persistence uses the current item-instance inventory and `equipment.relic` slot:

- old saves with missing inventory/equipment load safely with an empty relic inventory;
- old/legacy equipment ids normalize to item instance ids through the existing loader;
- unknown item ids remain loadable but do not count as known relics or apply known relic effects;
- no account-wide relic collection was added.

## Reward Acquisition

Eligible relic grants require:

- victory;
- campaign-node launch;
- rewards enabled;
- known rival champion;
- champion defeated.

The first implementation auto-grants one source relic rather than opening a reward-choice modal. The v0.33 spec documents a future choice model, but the runtime avoids a new modal until the save and duplicate gates have more field evidence.

## Duplicate Handling

Relics are unique. If a matching relic is already owned during an otherwise eligible grant, the duplicate converts through the existing unique duplicate conversion path. Repeat clears after the relic is owned do not repeatedly farm duplicate conversion resources.

## Tests

Added or extended coverage for:

- old saves loading with empty relic state;
- unknown relic ids ignored by relic inventory helpers;
- persistent relic definitions and content validation;
- eligible rival champion defeat selecting/granting a relic;
- Tutorial/rewards-disabled protection;
- duplicate conversion without adding a second relic;
- results copy showing persistent relic reward state;
- hosted Ashen Outpost reward persistence/equip proxy.

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
