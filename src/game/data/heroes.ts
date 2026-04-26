import type { HeroSaveData } from "../save/SaveTypes";
import { ABILITIES } from "./abilities";
import { HERO_CLASSES } from "./heroClasses";
import { ORIGINS } from "./origins";
import { applyOriginMods } from "../core/Progression";

export function createNewHeroSave(heroName: string, classId: string, originId: string): HeroSaveData {
  const heroClass = HERO_CLASSES.find((entry) => entry.id === classId) ?? HERO_CLASSES[0];
  const origin = ORIGINS.find((entry) => entry.id === originId) ?? ORIGINS[0];
  const ability = ABILITIES.find((entry) => entry.id === heroClass.primaryAbilityId);
  const stats = applyOriginMods(heroClass.baseStats, origin.statMods);

  return {
    heroName: heroName.trim() || "Aster",
    classId: heroClass.id,
    originId: origin.id,
    level: 1,
    xp: 0,
    skillPoints: 0,
    unlockedAbilities: ability ? [ability.id] : [],
    completedBattles: 0,
    clearedMapIds: [],
    inventory: [],
    equipment: {},
    allocatedSkills: {},
    factionReputation: {
      free_marches: 10,
      ashen_covenant: -10,
      sylvan_concord: 0,
      common_folk: 0,
      old_faith: 0
    },
    stats: {
      might: stats.might,
      command: stats.command,
      arcana: stats.arcana,
      faith: stats.faith
    }
  };
}
