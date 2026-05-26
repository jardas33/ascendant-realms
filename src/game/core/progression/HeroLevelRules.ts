import { HERO_ARMOR_LEVEL_INTERVAL, HERO_DAMAGE_PER_LEVEL } from "../Constants";

export interface HeroLevelStatGain {
  damage: number;
  armor: number;
}

export function heroLevelDamageBonus(level: number): number {
  return Math.max(0, Math.floor(level) - 1) * HERO_DAMAGE_PER_LEVEL;
}

export function heroLevelArmorBonus(level: number): number {
  return Math.floor(Math.max(0, Math.floor(level) - 1) / HERO_ARMOR_LEVEL_INTERVAL);
}

export function heroLiveLevelStatGain(previousLevel: number, nextLevel: number): HeroLevelStatGain {
  return {
    damage: heroLevelDamageBonus(nextLevel) - heroLevelDamageBonus(previousLevel),
    armor: heroLevelArmorBonus(nextLevel) - heroLevelArmorBonus(previousLevel)
  };
}
