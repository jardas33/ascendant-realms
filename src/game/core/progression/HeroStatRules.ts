import { HERO_HP_PER_LEVEL, HERO_MANA_PER_LEVEL } from "../Constants";
import type {
  HeroBaseStats,
  HeroClassDefinition,
  HeroStatMods,
  ItemDefinition,
  OriginDefinition,
  SkillNodeDefinition
} from "../GameTypes";
import { applyOriginMods } from "../Progression";
import type { HeroSaveData } from "../../save/SaveTypes";
import { calculateEquipmentStatMods } from "./EquipmentStatRules";
import { calculateSkillStatMods, getUnlockedAbilityIds } from "./SkillRules";

export const HERO_STAT_KEYS: Array<keyof HeroBaseStats> = [
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
    mergeHeroStatMods(
      levelStats,
      calculateSkillStatMods(save.allocatedSkills, skillById),
      calculateEquipmentStatMods(save.inventory, save.equipment, itemById)
    )
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
