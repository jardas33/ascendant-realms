import { HERO_HP_PER_LEVEL, HERO_MANA_PER_LEVEL } from "./Constants";
import type {
  EquipmentSlot,
  HeroBaseStats,
  HeroClassDefinition,
  HeroStatMods,
  ItemDefinition,
  OriginDefinition,
  RewardTableDefinition,
  SkillNodeDefinition
} from "./GameTypes";
import { applyOriginMods } from "./Progression";
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
    mergeHeroStatMods(levelStats, calculateSkillStatMods(save.allocatedSkills, skillById), calculateEquipmentStatMods(save.equipment, itemById))
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
  equipment: EquipmentSlots,
  itemById: Record<string, ItemDefinition>
): HeroStatMods {
  return EQUIPMENT_SLOTS.reduce<HeroStatMods>((mods, slot) => {
    const itemId = equipment[slot];
    const item = itemId ? itemById[itemId] : undefined;
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
  itemId: string,
  itemById: Record<string, ItemDefinition>
): ProgressionActionResult {
  const item = itemById[itemId];
  if (!item) {
    return { ok: false, hero: save, message: "Unknown item." };
  }
  if (!save.inventory.includes(item.id)) {
    return { ok: false, hero: save, message: "Item is not in this hero's inventory." };
  }

  return {
    ok: true,
    hero: {
      ...save,
      equipment: {
        ...save.equipment,
        [item.slot]: item.id
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
  inventory: string[],
  count = 1
): string[] {
  const owned = new Set(inventory);
  const picked: string[] = [];
  for (let offset = 0; offset < table.itemIds.length && picked.length < count; offset += 1) {
    const itemId = table.itemIds[(completedBattlesBeforeVictory + offset) % table.itemIds.length];
    if (!owned.has(itemId) && !picked.includes(itemId)) {
      picked.push(itemId);
    }
  }
  return picked;
}

export function grantItemRewards(save: HeroSaveData, rewardItemIds: string[]): HeroSaveData {
  const inventory = [...save.inventory];
  rewardItemIds.forEach((itemId) => {
    if (!inventory.includes(itemId)) {
      inventory.push(itemId);
    }
  });
  return {
    ...save,
    inventory
  };
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
