import { HERO_HP_PER_LEVEL, HERO_MANA_PER_LEVEL, LEVEL_XP_THRESHOLDS } from "./Constants";
import type {
  BattleRewardResult,
  EquipmentSlot,
  HeroBaseStats,
  HeroClassDefinition,
  HeroStatMods,
  ItemDuplicateConversion,
  ItemDefinition,
  ItemInstance,
  OriginDefinition,
  ResourceKey,
  RewardTableDefinition,
  RewardLevelUpSummary,
  SkillNodeDefinition
} from "./GameTypes";
import { applyOriginMods, calculateLevelFromXp } from "./Progression";
import type { EquipmentSlots, HeroSaveData } from "../save/SaveTypes";

export const EQUIPMENT_SLOTS: EquipmentSlot[] = ["weapon", "armor", "trinket"];

const HERO_STAT_KEYS: Array<keyof HeroBaseStats> = [
  "maxHp",
  "maxMana",
  "damage",
  "range",
  "attackCooldown",
  "speed",
  "armor",
  "might",
  "command",
  "arcana",
  "faith"
];

export interface ProgressionActionResult {
  ok: boolean;
  hero: HeroSaveData;
  message: string;
  unlockedAbilityId?: string;
}

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
  levelUp: RewardLevelUpSummary;
  reward: BattleRewardResult;
  grantedItemInstances: ItemInstance[];
  duplicateConversions: ItemDuplicateConversion[];
}

export function calculateLiveHeroStats(
  save: HeroSaveData,
  heroClass: HeroClassDefinition,
  origin: OriginDefinition,
  skillById: Record<string, SkillNodeDefinition>,
  itemById: Record<string, ItemDefinition>
): HeroBaseStats {
  const base = applyOriginMods(heroClass.baseStats, origin.statMods);
  const levelBonus = Math.max(0, save.level - 1);
  const levelStats: HeroStatMods = {
    maxHp: levelBonus * HERO_HP_PER_LEVEL,
    maxMana: levelBonus * HERO_MANA_PER_LEVEL,
    damage: levelBonus * 2,
    armor: Math.floor(levelBonus / 2)
  };

  return applyHeroStatMods(
    base,
    mergeHeroStatMods(levelStats, calculateSkillStatMods(save.allocatedSkills, skillById), calculateEquipmentStatMods(save.inventory, save.equipment, itemById))
  );
}

export function saveWithRecalculatedStats(
  save: HeroSaveData,
  heroClass: HeroClassDefinition,
  origin: OriginDefinition,
  skillById: Record<string, SkillNodeDefinition>,
  itemById: Record<string, ItemDefinition>
): HeroSaveData {
  const stats = calculateLiveHeroStats(save, heroClass, origin, skillById, itemById);
  return {
    ...save,
    unlockedAbilities: getUnlockedAbilityIds(save, heroClass, skillById),
    stats: {
      might: stats.might,
      command: stats.command,
      arcana: stats.arcana,
      faith: stats.faith
    }
  };
}

export function calculateSkillStatMods(
  allocatedSkills: Record<string, number>,
  skillById: Record<string, SkillNodeDefinition>
): HeroStatMods {
  return Object.entries(allocatedSkills).reduce<HeroStatMods>((mods, [skillId, rawRank]) => {
    const node = skillById[skillId];
    if (!node?.statModsPerRank) {
      return mods;
    }
    const rank = Math.max(0, Math.min(rawRank, node.maxRank));
    return mergeHeroStatMods(mods, multiplyHeroStatMods(node.statModsPerRank, rank));
  }, {});
}

export function calculateEquipmentStatMods(
  inventory: ItemInstance[],
  equipment: EquipmentSlots,
  itemById: Record<string, ItemDefinition>
): HeroStatMods {
  return EQUIPMENT_SLOTS.reduce<HeroStatMods>((mods, slot) => {
    const instance = equipment[slot] ? findItemInstance(inventory, equipment[slot]!) : undefined;
    const item = instance ? itemById[instance.itemId] : undefined;
    return item ? mergeHeroStatMods(mods, item.statMods) : mods;
  }, {});
}

export function getUnlockedAbilityIds(
  save: HeroSaveData,
  heroClass: HeroClassDefinition,
  skillById: Record<string, SkillNodeDefinition>
): string[] {
  const unlocked = new Set<string>([heroClass.primaryAbilityId, ...save.unlockedAbilities]);
  Object.entries(save.allocatedSkills).forEach(([skillId, rank]) => {
    const node = skillById[skillId];
    if (node?.unlockAbilityId && rank > 0) {
      unlocked.add(node.unlockAbilityId);
    }
  });

  return heroClass.abilityIds.filter((abilityId) => unlocked.has(abilityId));
}

export function canAllocateSkill(
  save: HeroSaveData,
  node: SkillNodeDefinition | undefined,
  skillById: Record<string, SkillNodeDefinition>
): { ok: boolean; message: string } {
  if (!node) {
    return { ok: false, message: "Unknown skill." };
  }
  if (node.classId && node.classId !== save.classId) {
    return { ok: false, message: "This skill belongs to another hero class." };
  }
  const currentRank = save.allocatedSkills[node.id] ?? 0;
  if (currentRank >= node.maxRank) {
    return { ok: false, message: "This skill is already maxed." };
  }
  if (save.skillPoints < node.costPerRank) {
    return { ok: false, message: "Not enough skill points." };
  }
  const missingRequirement = node.requires?.find((requirement) => {
    const requiredNode = skillById[requirement.skillId];
    return !requiredNode || (save.allocatedSkills[requirement.skillId] ?? 0) < requirement.rank;
  });
  if (missingRequirement) {
    const requiredNode = skillById[missingRequirement.skillId];
    return { ok: false, message: `Requires ${requiredNode?.name ?? missingRequirement.skillId} rank ${missingRequirement.rank}.` };
  }
  return { ok: true, message: "Skill can be learned." };
}

export function allocateSkillPoint(
  save: HeroSaveData,
  nodeId: string,
  skillById: Record<string, SkillNodeDefinition>
): ProgressionActionResult {
  const node = skillById[nodeId];
  const check = canAllocateSkill(save, node, skillById);
  if (!check.ok || !node) {
    return { ok: false, hero: save, message: check.message };
  }

  const currentRank = save.allocatedSkills[node.id] ?? 0;
  const unlocked = new Set(save.unlockedAbilities);
  if (node.unlockAbilityId) {
    unlocked.add(node.unlockAbilityId);
  }

  return {
    ok: true,
    hero: {
      ...save,
      skillPoints: save.skillPoints - node.costPerRank,
      allocatedSkills: {
        ...save.allocatedSkills,
        [node.id]: currentRank + 1
      },
      unlockedAbilities: [...unlocked]
    },
    message: node.unlockAbilityId ? `${node.name} learned. Ability unlocked.` : `${node.name} improved.`,
    unlockedAbilityId: node.unlockAbilityId
  };
}

export function equipItem(
  save: HeroSaveData,
  itemInstanceId: string,
  itemById: Record<string, ItemDefinition>
): ProgressionActionResult {
  const instance = findItemInstance(save.inventory, itemInstanceId);
  if (!instance) {
    return { ok: false, hero: save, message: "Item is not in this hero's inventory." };
  }
  const item = itemById[instance.itemId];
  if (!item) {
    return { ok: false, hero: save, message: "Unknown item." };
  }

  return {
    ok: true,
    hero: {
      ...save,
      equipment: {
        ...save.equipment,
        [item.slot]: instance.instanceId
      }
    },
    message: `${item.name} equipped.`
  };
}

export function unequipItem(save: HeroSaveData, slot: EquipmentSlot): ProgressionActionResult {
  if (!save.equipment[slot]) {
    return { ok: false, hero: save, message: "Nothing is equipped there." };
  }
  const equipment = { ...save.equipment };
  delete equipment[slot];
  return {
    ok: true,
    hero: {
      ...save,
      equipment
    },
    message: "Item unequipped."
  };
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
  options: { itemById?: Record<string, ItemDefinition>; source?: string; acquiredAt?: string } = {}
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
    const instance = createItemInstance(itemId, options.source ?? "battle_reward", options.acquiredAt);
    inventory.push(instance);
    grantedItemInstances.push(instance);
  });

  const previousLevel = save.level;
  const nextXp = Math.max(0, save.xp + Math.max(0, reward.xp));
  const newLevel = Math.max(previousLevel, calculateLevelFromXp(nextXp, LEVEL_XP_THRESHOLDS));
  const levelsGained = Math.max(0, newLevel - previousLevel);
  const clearedMapIds = mapId ? [...new Set([...(save.clearedMapIds ?? []), mapId])] : save.clearedMapIds;

  return {
    hero: {
      ...save,
      xp: nextXp,
      level: newLevel,
      skillPoints: save.skillPoints + levelsGained,
      inventory,
      clearedMapIds
    },
    levelUp: {
      previousLevel,
      newLevel,
      levelsGained,
      skillPointsGained: levelsGained
    },
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

export function createItemInstance(itemId: string, source: string, acquiredAt = new Date().toISOString()): ItemInstance {
  return {
    instanceId: `${sanitizeItemInstancePart(source)}:${sanitizeItemInstancePart(itemId)}:${Date.now().toString(36)}:${Math.random().toString(36).slice(2, 8)}`,
    itemId,
    acquiredAt,
    source,
    affixes: [],
    locked: false,
    favorite: false
  };
}

export function findItemInstance(inventory: ItemInstance[], instanceOrCatalogId: string): ItemInstance | undefined {
  return inventory.find((instance) => instance.instanceId === instanceOrCatalogId) ?? inventory.find((instance) => instance.itemId === instanceOrCatalogId);
}

export function heroOwnsCatalogItem(save: HeroSaveData, itemId: string): boolean {
  return save.inventory.some((instance) => instance.itemId === itemId);
}

export function applyHeroStatMods(base: HeroBaseStats, mods: HeroStatMods): HeroBaseStats {
  return {
    maxHp: Math.max(1, base.maxHp + (mods.maxHp ?? 0)),
    maxMana: Math.max(0, base.maxMana + (mods.maxMana ?? 0)),
    damage: Math.max(1, base.damage + (mods.damage ?? 0)),
    range: Math.max(20, base.range + (mods.range ?? 0)),
    attackCooldown: Math.max(0.25, base.attackCooldown + (mods.attackCooldown ?? 0)),
    speed: Math.max(40, base.speed + (mods.speed ?? 0)),
    armor: Math.max(0, base.armor + (mods.armor ?? 0)),
    might: Math.max(0, base.might + (mods.might ?? 0)),
    command: Math.max(0, base.command + (mods.command ?? 0)),
    arcana: Math.max(0, base.arcana + (mods.arcana ?? 0)),
    faith: Math.max(0, base.faith + (mods.faith ?? 0))
  };
}

export function mergeHeroStatMods(...modsList: HeroStatMods[]): HeroStatMods {
  return modsList.reduce<HeroStatMods>((merged, mods) => {
    HERO_STAT_KEYS.forEach((key) => {
      const value = mods[key];
      if (typeof value === "number") {
        const target = merged as Partial<Record<keyof HeroBaseStats, number>>;
        target[key] = (target[key] ?? 0) + value;
      }
    });
    return merged;
  }, {});
}

export function multiplyHeroStatMods(mods: HeroStatMods, multiplier: number): HeroStatMods {
  const multiplied: HeroStatMods = {};
  HERO_STAT_KEYS.forEach((key) => {
    const value = mods[key];
    if (typeof value === "number") {
      const target = multiplied as Partial<Record<keyof HeroBaseStats, number>>;
      target[key] = value * multiplier;
    }
  });
  return multiplied;
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

function createUniqueDuplicateConversion(item: ItemDefinition): ItemDuplicateConversion {
  const highRarity = item.rarity === "rare" || item.rarity === "epic" || item.rarity === "legendary";
  const amountByRarity: Record<ItemDefinition["rarity"], number> = {
    common: 40,
    uncommon: 70,
    rare: 25,
    epic: 45,
    legendary: 75
  };
  return {
    itemId: item.id,
    reason: "unique_duplicate",
    resources: highRarity
      ? { aether: amountByRarity[item.rarity] }
      : { crowns: amountByRarity[item.rarity] }
  };
}

function sanitizeItemInstancePart(value: string): string {
  return value.replace(/[^a-zA-Z0-9_-]/g, "_");
}
