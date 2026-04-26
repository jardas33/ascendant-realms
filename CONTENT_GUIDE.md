# Content Guide

Most prototype content lives in `src/game/data`. Change one small thing at a time, run the game, and keep a backup before large balance edits.

## Add A New Unit

1. Open `src/game/data/units.ts`.
2. Copy an existing unit entry.
3. Give it a unique `id`.
4. Edit name, cost, HP, damage, range, speed, armor, train time, color, and XP value.
5. To train it from a building, add the unit `id` to that building's `trainOptions` in `src/game/data/buildings.ts`.
6. Add `prerequisites` if it should require a completed building or researched upgrade.
7. Run `npm run test` to make sure the new ID is valid everywhere.

## Add A New Building

1. Open `src/game/data/buildings.ts`.
2. Copy an existing building entry.
3. Give it a unique `id`.
4. Edit cost, HP, size, build options, train options, or attack values.
5. Set `constructionTimeSeconds`. Use `0` only for prebuilt scenario structures.
6. Add `upgradeOptions` if the building should research upgrades.
7. Add `prerequisites` if it should require another completed building or researched upgrade.
8. To build it from the Command Hall, add its `id` to the Command Hall's `buildOptions`.
9. To place it at battle start, add it to a map `scenario.buildingSpawns` entry in `src/game/data/maps.ts`.

## Add A New Upgrade

1. Open `src/game/data/upgrades.ts`.
2. Copy an existing upgrade entry.
3. Give it a unique `id`.
4. Set name, description, cost, `researchTimeSeconds`, prerequisites, and effects.
5. Add the upgrade `id` to a building's `upgradeOptions` in `src/game/data/buildings.ts`.
6. Supported effect types currently modify unit stats or hero mana regeneration. New effect types need code in the battle systems.
7. Run `npm run test`.

## Add A New Hero Class

1. Open `src/game/data/heroClasses.ts`.
2. Copy an existing class.
3. Give it a unique `id`.
4. Edit starting stats and the `primaryAbilityId`.
5. Add all class ability IDs to `abilityIds`.
6. Add matching abilities in `src/game/data/abilities.ts`.
7. Add class-specific skill nodes in `src/game/data/skillTrees.ts` if the class should unlock abilities through progression.

## Add A New Ability

1. Open `src/game/data/abilities.ts`.
2. Copy an existing ability.
3. Give it a unique `id`.
4. Edit mana cost, cooldown, range, radius, duration, and amount.
5. Engine behavior for brand-new effect types must be added in `AbilitySystem.ts`.
6. Add the ability ID to the correct hero class `abilityIds`.
7. If it should be unlocked later, add a skill node with `unlockAbilityId`.
8. Add `prerequisites` only if the ability should later require tech or hero level gates.
9. Run `npm run test` to confirm the hero class and ability links are valid.

## Add A New Skill Node

1. Open `src/game/data/skillTrees.ts`.
2. Copy an existing skill node.
3. Give it a unique `id`.
4. Choose `treeId`: `combat`, `magic`, or `leadership`.
5. Use `statModsPerRank` for passive bonuses.
6. Use `unlockAbilityId` to unlock an ability.
7. Use `classId` only if the skill belongs to one class.
8. Use `requires` if another skill must be learned first.
9. Run `npm run test`.

## Add A New Item

1. Open `src/game/data/items.ts`.
2. Copy an existing item.
3. Give it a unique `id`.
4. Choose a slot: `weapon`, `armor`, `trinket`, or future `relic`.
5. Choose a rarity: `common`, `uncommon`, `rare`, `epic`, or `legendary`.
6. Write `description`, `flavorText`, and `tags`.
7. Add passive bonuses in `statMods`. Supported hero stats are HP, mana, damage, range, attack cooldown, speed, armor, Might, Command, Arcana, and Faith.
8. Optional fields:
   - `classAffinity`: hero class IDs that thematically fit the item.
   - `factionOrigin`: faction ID for where the item came from.
   - `iconAssetKey`: future item icon asset key.
   - `unique`: set to `true` when the hero should only keep one owned copy.
9. Add the item ID to a reward table in `src/game/data/rewards.ts`.
10. Run `npm run test`.

Inventory stores item instances, not raw catalog IDs. Rewards and town purchases create an instance with `instanceId`, `itemId`, `acquiredAt`, `source`, and an empty `affixes` placeholder. Equipment references the instance ID. Unique duplicate rewards convert into campaign resources instead of adding a second copy; non-unique duplicates remain separate instances.

## Add A New Reward Table

1. Open `src/game/data/rewards.ts`.
2. Copy the existing reward table.
3. Give it a unique `id`.
4. Add fixed items to `guaranteedItemIds` if every victory should grant them.
5. Add weighted drops to `weightedItemPool`. Each entry needs an `itemId` and positive `weight`.
6. Use `mapIds` when a drop should only appear on specific maps.
7. Use `firstClearOnly` or `repeatClearOnly` for table entries that should only appear before or after the first win on that map.
8. Set `rolls` to the number of weighted item attempts per victory.
9. Add `resourceRewards` and `xpRewards` for normal victory payouts.
10. Add `firstClearBonus` and `repeatClearReward` for map-clear pacing.
11. Keep `deterministicItemIds` when tests or scripted flows need predictable item selection.
12. Open `src/game/data/maps.ts` and set the map scenario's `rewardTableId`.
13. Run `npm run test`.

Weighted reward rolls prefer unowned catalog items when possible. If a guaranteed, deterministic, or scripted reward grants a unique item the hero already owns, the reward flow converts it into Crowns or Aether and reports the conversion on the Results screen.

## Add A New Skirmish Map

1. Open `src/game/data/maps.ts`.
2. Copy an existing `BattleMapDefinition`.
3. Give the map a unique `id`, display `name`, `role`, `description`, and `strategicNotes`.
4. Set `width`, `height`, `playerStart`, `enemyStart`, and `visualPaths`. Visual paths draw roads and lanes; keep every path point inside the map.
5. Add terrain zones. Include one full-map grass zone, buildable zones for each base, and blocked or water zones that shape building placement.
6. Add 4 capture sites for the current skirmish setup. Each site must use a resource ID from `resources.ts`.
7. Add neutral camps with valid unit IDs. Use stronger central camps when the center should feel risky.
8. Fill the `scenario` block with starting resources, hero spawn, player/enemy buildings, player/enemy unit spawns, objectives, enemy AI config, and reward table.
   - Primary objectives use `playerBaseBuildingId` and `enemyBaseBuildingId`.
   - Optional `secondaryObjectives` can track `capture_site`, `destroy_building`, or `defeat_unit` targets for milestone maps and ResultsScene display.
9. Add a reward table in `rewards.ts` and point the map's `scenario.rewardTableId` at it.
10. Run `npm run test` and `npm run build`. The setup screen automatically lists maps from `MAPS`.

Current map examples:

- `first_claim`: tutorial skirmish with the safest opening economy.
- `broken_ford`: contested two-lane river map with a risky center.
- `ashen_outpost`: campaign milestone fortress assault with a central Burned Shrine, enemy defensive towers, side resource paths, and secondary objectives for shrine capture, enemy Barracks destruction, and commander defeat.

## Add A New Campaign Node

1. Open `src/game/data/campaignNodes.ts`.
2. Copy an existing node entry.
3. Give it a unique `id`, display `name`, and `description`.
4. Choose `nodeType`: `battle`, `shrine`, `town`, `ruin`, `fortress`, or `event`.
5. Set `difficulty`, `mapId`, `enemyFactionId`, and optional `aiPersonalityId`.
6. Add prerequisite node IDs to `prerequisites`.
7. Add future node IDs to `unlocks`.
8. Add node rewards with optional `xp`, `itemIds`, and `resources`. Node resource rewards are added to the persistent campaign bank, not to the temporary battle economy.
9. For `event`, `town`, `shrine`, or other non-battle nodes, add optional `eventText` and `choices` when the node should ask the player to choose an outcome or use a service.
10. Set `x` and `y` as percentages for the campaign map UI position.
11. Battle nodes launch combat through `BattleLaunchRequest`. Non-battle nodes either resolve direct rewards or show data-driven choices from the campaign map.
12. Run `npm run test`. Content validation checks node links, map IDs, faction IDs, AI personality IDs, reward item IDs, resource IDs, and choice references.

Campaign choices support:

- `id`, `label`, and `description` for display.
- `requirements` for campaign resources, hero level, completed nodes, owned items, or faction reputation.
- `costs` paid from the persistent campaign resource bank.
- `rewards` for XP, item IDs, campaign resources, campaign modifiers, node unlocks, reputation changes, and a `recoverHero` placeholder.
- `stockItemId` for town item purchases. It should point at the same item granted in `rewards.itemIds` so the UI can show stock rarity and slot.
- `reputationChanges` and `unlockNodeIds` as direct choice effects when that reads cleaner than nesting under `rewards`.
- `onceOnly` to save a claim ID in `choiceIdsClaimed`.
- `completesNode: false` when the choice should leave the node open for a later choice.

Town service guidance:

- Use `nodeType: "town"` for repeatable service hubs such as Marcher Camp.
- Give repeatable services `onceOnly: false` and `completesNode: false`.
- Give fixed stock purchases `onceOnly: true`, `completesNode: false`, `stockItemId`, and a matching `rewards.itemIds` entry.
- Costs are paid from the persistent campaign bank and are tracked in `campaign.resourcesSpent`.
- Town service usage is tracked in `campaign.townServiceUseCounts`; once-only service purchases are also tracked in `campaign.townServiceClaimedIds`.
- Next-battle effects should usually grant a campaign modifier such as `well_rested` or `inspired_militia`.

## Add A New Faction

1. Open `src/game/data/factions.ts`.
2. Copy an existing faction.
3. Give it a unique `id`.
4. Write `name`, `fantasy`, and a readable `color`.
5. Fill the `mechanics` block:
   - `economyStyle`, `militaryStyle`, and `magicStyle` are shown in setup/campaign UI.
   - `availableUnitIds`, `availableBuildingIds`, and `availableUpgradeIds` must reference valid data IDs.
   - `aiPersonalityPreferences` must reference valid AI personality IDs.
   - `campaignReputationHooks` should list factions whose reputation can be affected by this faction.
   - `factionModifiers` can currently use `burn-on-hit`, `low-health-damage`, or `wave-speed`.
6. Add faction units in `units.ts`.
7. Add faction buildings in `buildings.ts`.
8. Add faction upgrades or trait placeholders in `upgrades.ts` when needed.
9. Assign the faction to campaign nodes with `enemyFactionId` and pair it with a fitting `aiPersonalityId`.
10. Run `npm run test` so validation checks faction unit, building, upgrade, AI, and reputation references.

Current faction modifier support:

- `burn-on-hit`: applies a damage-over-time status when matching units or buildings hit.
- `low-health-damage`: multiplies damage when matching units are below an HP threshold.
- `wave-speed`: increases movement speed for matching units when an AI attack wave launches.

New modifier types require code in combat or battle systems plus validation in `contentValidation.ts`.

## Add A New Manual Art Asset

1. Open `tools/manual-asset-pipeline/assetRegistry.ts`.
2. Copy an existing asset entry from the same category.
3. Give it a unique `id`, clear `displayName`, target folder, filename, size, usage, and notes.
4. Run `npm run assets:prompts`.
5. Open `public/assets/manual/ASSET_PROMPT_BOOK.md`.
6. Generate the image manually in ChatGPT.
7. Put the image in the listed `public/assets/manual/...` folder.
8. Exact snake_case filenames are best, but friendly display names also work.
9. Run `npm run assets:refresh`.

## Add Or Replace UI Art Kit Images

UI-kit images are reusable frames and slots, not full menu screenshots.

1. Run `npm run assets:prompts`.
2. Open `public/assets/manual/ASSET_PROMPT_BOOK.md`.
3. Search for `Reusable Panel Frame` or any asset ID starting with `ui_`.
4. Generate one image at a time in ChatGPT.
5. Save the image in `public/assets/manual/ui`.
6. Use the exact filename from the prompt book, such as `ui_panel_frame.png`.
7. Run `npm run assets:refresh`.
8. Refresh the browser and check the main menu, battle HUD, results screen, and Asset Gallery.

Important UI-kit rules:

- Frames should have transparent centers.
- Button states should not contain words.
- Slots should not contain ability or item icons.
- Dividers should be thin and quiet.
- Do not use one big screenshot as UI art.
- If a UI asset looks stretched, ask Codex to tune the CSS `border-image-slice` value for that asset.

## Edit A Skirmish Map

1. Open `src/game/data/maps.ts`.
2. Setup metadata, terrain, visual paths, capture sites, and neutral camps are near the top of each map entry.
3. Starting buildings, starting units, hero spawn, objectives, starting resources, and enemy AI settings live in the map's `scenario` block.
4. To change enemy pressure, edit `scenario.enemyAI.attackInterval`, `minAttackArmySize`, `attackWaveSize`, and `unitPlan`.
5. To change victory rewards, edit `scenario.rewardTableId`.
6. Run `npm run test` after edits. The content validation test catches missing IDs before the game opens.

## Add Or Tune An AI Personality

1. Open `src/game/data/aiPersonalities.ts`.
2. Copy one of the four existing personalities: Balanced Warlord, Raider Rush, Fortress Keeper, or Hexfire Cult.
3. Give it a unique `id`, `name`, `shortDescription`, and `description`.
4. Set `preferredUnitIds` and `unitPlan` using valid unit IDs.
5. Tune timing multipliers for first attack delay, attack interval, expansion interval, training interval, and commander join delay.
6. Tune wave behavior through `attackWaveSizeMultiplier`, `minAttackArmySizeDelta`, and per-phase overrides for allowed, preferred, and capped units.
7. Tune defense through `defendRadiusMultiplier`, `defenseSquadSizeDelta`, `reserveDefenseUnits`, and `protectCaptureSites`.
8. Assign the personality to a campaign battle node with `aiPersonalityId`, or select it in Skirmish Setup.
9. Run `npm run test` so validation catches missing units or invalid campaign references.

## Safe Editing Tips

- Keep IDs lowercase and use hyphens or underscores consistently.
- Do not reuse IDs.
- Change numbers gradually.
- Completed-building prerequisites only count finished construction, not structures still under construction.
- If the game stops building, undo the last data edit and run `npm run build` again.
- If tests fail with "references missing", check for a typo in an ID.
