import type { ResourceBag, ResourceKey } from "./EconomyTypes";
import type { HeroStatMods } from "./HeroTypes";

export type EquipmentSlot = "weapon" | "armor" | "trinket" | "relic";

export type ItemRarity = "common" | "uncommon" | "rare" | "epic" | "legendary";
export type ItemAffixTier = "minor" | "major";

export interface ItemDefinition {
  id: string;
  name: string;
  slot: EquipmentSlot;
  rarity: ItemRarity;
  unique?: boolean;
  description: string;
  statMods: HeroStatMods;
  classAffinity?: string[];
  factionOrigin?: string;
  iconAssetKey?: string;
  flavorText: string;
  tags: string[];
}

export interface ItemInstance {
  instanceId: string;
  itemId: string;
  acquiredAt: string;
  source: string;
  affixes: string[];
  locked?: boolean;
  favorite?: boolean;
}

export interface ItemAffixDefinition {
  id: string;
  name: string;
  tier: ItemAffixTier;
  allowedSlots: EquipmentSlot[];
  statMods: HeroStatMods;
  tags: string[];
  weight: number;
}

export interface RewardTableDefinition {
  id: string;
  name: string;
  guaranteedItemIds: string[];
  weightedItemPool: WeightedRewardEntry[];
  resourceRewards: RewardResourceDefinition[];
  xpRewards: RewardXpDefinition[];
  firstClearBonus?: RewardBonusDefinition;
  repeatClearReward?: RewardBonusDefinition;
  rolls: number;
  deterministicItemIds?: string[];
}

export interface WeightedRewardEntry {
  itemId: string;
  weight: number;
  mapIds?: string[];
  firstClearOnly?: boolean;
  repeatClearOnly?: boolean;
}

export interface RewardResourceDefinition {
  resource: ResourceKey;
  amount: number;
  firstClearOnly?: boolean;
  repeatClearOnly?: boolean;
}

export interface RewardXpDefinition {
  amount: number;
  firstClearOnly?: boolean;
  repeatClearOnly?: boolean;
}

export interface RewardBonusDefinition {
  itemIds?: string[];
  resources?: Partial<ResourceBag>;
  xp?: number;
}

export interface BattleRewardResult {
  itemIds: string[];
  resources: Partial<ResourceBag>;
  xp: number;
  itemInstances?: ItemInstance[];
  duplicateConversions?: ItemDuplicateConversion[];
}

export interface ItemDuplicateConversion {
  itemId: string;
  reason: "unique_duplicate";
  resources: Partial<ResourceBag>;
}

export interface RewardLevelUpSummary {
  previousLevel: number;
  newLevel: number;
  levelsGained: number;
  skillPointsGained: number;
}

export type RelicRewardPersistenceStatus = "persistent_inventory";
export type RelicBuildArchetype = "warrior" | "seer" | "commander";

export interface RelicRewardDefinition {
  id: string;
  itemId: string;
  name: string;
  sourceEnemyHeroId: string;
  sourceLabel: string;
  description: string;
  effectSummary: string;
  persistenceStatus: RelicRewardPersistenceStatus;
  rarity: ItemRarity;
  tier: "rival";
  category: "hero_loadout";
  buildArchetype: RelicBuildArchetype;
  buildSummary: string;
  choiceCopy: string;
  acquisitionSource: string;
  duplicateCopiesAllowed: boolean;
  duplicatePolicy: "unique_duplicate_conversion";
  tags: string[];
}
