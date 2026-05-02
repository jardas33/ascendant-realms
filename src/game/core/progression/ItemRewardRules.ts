import type {
  BattleRewardResult,
  ItemDefinition,
  ItemDuplicateConversion,
  ItemInstance,
  ResourceKey,
  RewardTableDefinition
} from "../GameTypes";
import type { HeroSaveData } from "../../save/SaveTypes";
import { createItemInstance } from "./AffixRules";
import { createUniqueDuplicateConversion } from "./DuplicateRewardRules";
import { calculateRewardLevelProgress } from "./LevelingRules";

export interface RollBattleRewardOptions {
  table: RewardTableDefinition;
  completedBattlesBeforeVictory: number;
  inventory: ItemInstance[];
  count?: number;
  deterministic?: boolean;
  isFirstClear?: boolean;
  mapId?: string;
  rng?: () => number;
}

export interface GrantBattleRewardsResult {
  hero: HeroSaveData;
  levelUp: ReturnType<typeof calculateRewardLevelProgress>["levelUp"];
  reward: BattleRewardResult;
  grantedItemInstances: ItemInstance[];
  duplicateConversions: ItemDuplicateConversion[];
}

export function pickBattleRewardItemIds(
  table: RewardTableDefinition,
  completedBattlesBeforeVictory: number,
  inventory: ItemInstance[],
  count = 1
): string[] {
  return rollBattleRewards({
    table,
    completedBattlesBeforeVictory,
    inventory,
    count,
    deterministic: true
  }).itemIds;
}

export function rollBattleRewards(options: RollBattleRewardOptions): BattleRewardResult {
  const isFirstClear = options.isFirstClear ?? options.completedBattlesBeforeVictory === 0;
  const count = Math.max(0, Math.floor(options.count ?? options.table.rolls));
  const reward: BattleRewardResult = {
    itemIds: [],
    resources: {},
    xp: 0
  };
  const owned = new Set(options.inventory.map((instance) => instance.itemId));
  const picked = new Set<string>();
  const addItem = (itemId: string): boolean => {
    if (!owned.has(itemId) && !picked.has(itemId)) {
      picked.add(itemId);
      reward.itemIds.push(itemId);
      return true;
    }
    return false;
  };

  options.table.guaranteedItemIds.forEach(addItem);
  applyRewardBonus(reward, isFirstClear ? options.table.firstClearBonus : options.table.repeatClearReward, addItem);

  options.table.resourceRewards
    .filter((entry) => rewardEntryApplies(entry, isFirstClear))
    .forEach((entry) => addRewardResource(reward.resources, entry.resource, entry.amount));
  options.table.xpRewards
    .filter((entry) => rewardEntryApplies(entry, isFirstClear))
    .forEach((entry) => {
      reward.xp += Math.max(0, entry.amount);
    });

  if (options.deterministic) {
    pickDeterministicRewards(options, count, addItem);
    return reward;
  }

  for (let roll = 0; roll < count; roll += 1) {
    const candidates = options.table.weightedItemPool.filter(
      (entry) =>
        rewardPoolEntryApplies(entry, isFirstClear, options.mapId) &&
        !owned.has(entry.itemId) &&
        !picked.has(entry.itemId) &&
        entry.weight > 0
    );
    const pickedEntry = pickWeightedReward(candidates, options.rng ?? Math.random);
    if (!pickedEntry) {
      break;
    }
    addItem(pickedEntry.itemId);
  }

  return reward;
}

export function grantItemRewards(save: HeroSaveData, rewardItemIds: string[]): HeroSaveData {
  const inventory = [...save.inventory, ...rewardItemIds.map((itemId) => createItemInstance(itemId, "manual_grant"))];
  return {
    ...save,
    inventory
  };
}

export function grantBattleRewards(
  save: HeroSaveData,
  reward: BattleRewardResult,
  mapId?: string,
  options: {
    itemById?: Record<string, ItemDefinition>;
    source?: string;
    acquiredAt?: string;
    deterministicAffixes?: boolean;
    rng?: () => number;
    affixesByItemId?: Record<string, string[]>;
  } = {}
): GrantBattleRewardsResult {
  const inventory = [...save.inventory];
  const grantedItemInstances: ItemInstance[] = [];
  const duplicateConversions: ItemDuplicateConversion[] = [];
  const convertedResources: Partial<Record<ResourceKey, number>> = { ...reward.resources };
  reward.itemIds.forEach((itemId) => {
    const item = options.itemById?.[itemId];
    if (item?.unique && inventory.some((instance) => instance.itemId === itemId)) {
      const conversion = createUniqueDuplicateConversion(item);
      duplicateConversions.push(conversion);
      Object.entries(conversion.resources).forEach(([resource, amount]) => {
        convertedResources[resource as ResourceKey] = (convertedResources[resource as ResourceKey] ?? 0) + (amount ?? 0);
      });
      return;
    }
    const instance = createItemInstance(itemId, options.source ?? "battle_reward", options.acquiredAt, {
      itemById: options.itemById,
      affixes: options.affixesByItemId?.[itemId],
      deterministicAffixes: options.deterministicAffixes,
      rng: options.rng
    });
    inventory.push(instance);
    grantedItemInstances.push(instance);
  });

  const levelProgress = calculateRewardLevelProgress(save, reward.xp);
  const clearedMapIds = mapId ? [...new Set([...(save.clearedMapIds ?? []), mapId])] : save.clearedMapIds;

  return {
    hero: {
      ...save,
      xp: levelProgress.nextXp,
      level: levelProgress.newLevel,
      skillPoints: save.skillPoints + levelProgress.levelsGained,
      inventory,
      clearedMapIds
    },
    levelUp: levelProgress.levelUp,
    reward: {
      ...reward,
      resources: convertedResources,
      itemInstances: grantedItemInstances,
      duplicateConversions
    },
    grantedItemInstances,
    duplicateConversions
  };
}

function pickDeterministicRewards(options: RollBattleRewardOptions, count: number, addItem: (itemId: string) => boolean): void {
  const orderedIds = options.table.deterministicItemIds ?? options.table.weightedItemPool.map((entry) => entry.itemId);
  if (orderedIds.length === 0 || count <= 0) {
    return;
  }
  let added = 0;
  for (let offset = 0; offset < orderedIds.length && added < count; offset += 1) {
    const itemId = orderedIds[(options.completedBattlesBeforeVictory + offset) % orderedIds.length];
    if (addItem(itemId)) {
      added += 1;
    }
  }
}

function rewardEntryApplies(entry: { firstClearOnly?: boolean; repeatClearOnly?: boolean }, isFirstClear: boolean): boolean {
  if (entry.firstClearOnly && !isFirstClear) {
    return false;
  }
  if (entry.repeatClearOnly && isFirstClear) {
    return false;
  }
  return true;
}

function rewardPoolEntryApplies(
  entry: { firstClearOnly?: boolean; repeatClearOnly?: boolean; mapIds?: string[] },
  isFirstClear: boolean,
  mapId?: string
): boolean {
  if (!rewardEntryApplies(entry, isFirstClear)) {
    return false;
  }
  return !entry.mapIds || !mapId || entry.mapIds.includes(mapId);
}

function pickWeightedReward<T extends { weight: number }>(entries: T[], rng: () => number): T | undefined {
  const totalWeight = entries.reduce((total, entry) => total + Math.max(0, entry.weight), 0);
  if (totalWeight <= 0) {
    return undefined;
  }
  let roll = Math.max(0, Math.min(0.999999, rng())) * totalWeight;
  for (const entry of entries) {
    roll -= Math.max(0, entry.weight);
    if (roll <= 0) {
      return entry;
    }
  }
  return entries.at(-1);
}

function applyRewardBonus(reward: BattleRewardResult, bonus: RewardTableDefinition["firstClearBonus"], addItem: (itemId: string) => void): void {
  bonus?.itemIds?.forEach(addItem);
  Object.entries(bonus?.resources ?? {}).forEach(([resource, amount]) => {
    addRewardResource(reward.resources, resource as ResourceKey, amount ?? 0);
  });
  reward.xp += Math.max(0, bonus?.xp ?? 0);
}

function addRewardResource(resources: BattleRewardResult["resources"], resource: ResourceKey, amount: number): void {
  resources[resource] = (resources[resource] ?? 0) + Math.max(0, amount);
}
