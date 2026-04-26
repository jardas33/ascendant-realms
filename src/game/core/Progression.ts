import type { HeroBaseStats } from "./GameTypes";

export interface LevelUpResult {
  level: number;
  skillPoints: number;
  maxHp: number;
  maxMana: number;
  leveledUp: boolean;
  levelsGained: number;
}

export interface XpProgress {
  currentLevelXp: number;
  nextLevelXp: number;
  percent: number;
}

export function calculateLevelFromXp(xp: number, thresholds: Record<number, number>): number {
  let level = 1;
  Object.entries(thresholds).forEach(([levelText, requiredXp]) => {
    if (xp >= requiredXp) {
      level = Math.max(level, Number(levelText));
    }
  });
  return level;
}

export function applyLevelProgression(options: {
  previousLevel: number;
  xp: number;
  skillPoints: number;
  maxHp: number;
  maxMana: number;
  thresholds: Record<number, number>;
  hpPerLevel: number;
  manaPerLevel: number;
}): LevelUpResult {
  const nextLevel = calculateLevelFromXp(options.xp, options.thresholds);
  const levelsGained = Math.max(0, nextLevel - options.previousLevel);
  return {
    level: Math.max(options.previousLevel, nextLevel),
    skillPoints: options.skillPoints + levelsGained,
    maxHp: options.maxHp + levelsGained * options.hpPerLevel,
    maxMana: options.maxMana + levelsGained * options.manaPerLevel,
    leveledUp: levelsGained > 0,
    levelsGained
  };
}

export function xpProgressForLevel(xp: number, level: number, thresholds: Record<number, number>): XpProgress {
  const currentLevelXp = level <= 1 ? 0 : thresholds[level] ?? 0;
  const nextLevelXp = thresholds[level + 1] ?? currentLevelXp;
  if (nextLevelXp <= currentLevelXp) {
    return {
      currentLevelXp,
      nextLevelXp,
      percent: 100
    };
  }
  return {
    currentLevelXp,
    nextLevelXp,
    percent: Math.max(0, Math.min(100, ((xp - currentLevelXp) / (nextLevelXp - currentLevelXp)) * 100))
  };
}

export function applyOriginMods(base: HeroBaseStats, mods: Partial<HeroBaseStats>): HeroBaseStats {
  return {
    maxHp: base.maxHp + (mods.maxHp ?? 0),
    maxMana: base.maxMana + (mods.maxMana ?? 0),
    damage: base.damage + (mods.damage ?? 0),
    armor: base.armor + (mods.armor ?? 0),
    speed: base.speed + (mods.speed ?? 0),
    range: base.range + (mods.range ?? 0),
    attackCooldown: base.attackCooldown + (mods.attackCooldown ?? 0),
    might: base.might + (mods.might ?? 0),
    command: base.command + (mods.command ?? 0),
    arcana: base.arcana + (mods.arcana ?? 0),
    faith: base.faith + (mods.faith ?? 0)
  };
}
