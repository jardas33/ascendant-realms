import type { RelicRewardDefinition } from "../core/GameTypes";

export const RELIC_REWARD_DEFINITIONS: RelicRewardDefinition[] = [
  {
    id: "emberbrand_shard",
    itemId: "emberbrand_shard",
    name: "Emberbrand Shard",
    sourceEnemyHeroId: "gorak_emberhand",
    sourceLabel: "Gorak Emberhand champion relic",
    description: "A scorched command shard that marks the raider captain's broken charge.",
    effectSummary: "Equipped effect: +2 hero damage and +1 might.",
    persistenceStatus: "persistent_inventory",
    rarity: "rare",
    tier: "rival",
    category: "hero_loadout",
    acquisitionSource: "Defeat Gorak Emberhand in an eligible rewarded battle.",
    duplicateCopiesAllowed: false,
    duplicatePolicy: "unique_duplicate_conversion",
    tags: ["rival", "damage", "might", "relic"]
  },
  {
    id: "cinderseer_focus",
    itemId: "cinderseer_focus",
    name: "Cinder-Seer Focus",
    sourceEnemyHeroId: "veyra_cinders",
    sourceLabel: "Veyra of the Cinders champion relic",
    description: "A cracked emberglass focus that still holds a disciplined hexfire pattern.",
    effectSummary: "Equipped effect: +18 max Mana and +2 arcana.",
    persistenceStatus: "persistent_inventory",
    rarity: "rare",
    tier: "rival",
    category: "hero_loadout",
    acquisitionSource: "Defeat Veyra of the Cinders in an eligible rewarded battle.",
    duplicateCopiesAllowed: false,
    duplicatePolicy: "unique_duplicate_conversion",
    tags: ["rival", "mana", "arcana", "relic"]
  },
  {
    id: "outpost_command_signet",
    itemId: "outpost_command_signet",
    name: "Outpost Command Signet",
    sourceEnemyHeroId: "captain_malrec",
    sourceLabel: "Captain Malrec champion relic",
    description: "A compact field signet used to hold an Ashen outpost line together.",
    effectSummary: "Equipped effect: +24 max HP, +1 armor, and +1 command.",
    persistenceStatus: "persistent_inventory",
    rarity: "epic",
    tier: "rival",
    category: "hero_loadout",
    acquisitionSource: "Defeat Captain Malrec in an eligible rewarded battle.",
    duplicateCopiesAllowed: false,
    duplicatePolicy: "unique_duplicate_conversion",
    tags: ["rival", "hp", "armor", "command", "relic"]
  }
];

export const RELIC_REWARD_BY_ENEMY_HERO_ID: Record<string, RelicRewardDefinition> = Object.fromEntries(
  RELIC_REWARD_DEFINITIONS.map((reward) => [reward.sourceEnemyHeroId, reward])
);
