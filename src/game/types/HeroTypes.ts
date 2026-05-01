import type { CombatStats, TechPrerequisites } from "./CombatTypes";

export type AbilityEffectType =
  | "rally-banner"
  | "cleave"
  | "war-cry"
  | "firebolt"
  | "arcane-burst"
  | "blink"
  | "heal"
  | "blessing"
  | "sanctify-ground";

export type SkillTreeId = "combat" | "magic" | "leadership";

export interface HeroPrimaryStats {
  might: number;
  command: number;
  arcana: number;
  faith: number;
}

export interface HeroBaseStats extends CombatStats, HeroPrimaryStats {
  maxMana: number;
}

export type HeroStatMods = Partial<HeroBaseStats>;

export interface AbilityDefinition {
  id: string;
  name: string;
  heroClassId: string;
  hotkey: string;
  description: string;
  manaCost: number;
  cooldown: number;
  effectType: AbilityEffectType;
  amount: number;
  range: number;
  radius: number;
  duration: number;
  prerequisites?: TechPrerequisites;
}

export interface HeroClassDefinition {
  id: string;
  name: string;
  description: string;
  baseStats: HeroBaseStats;
  visionRadius: number;
  primaryAbilityId: string;
  abilityIds: string[];
  color: number;
}

export interface SkillRequirement {
  skillId: string;
  rank: number;
}

export interface SkillTreeDefinition {
  id: SkillTreeId;
  name: string;
  description: string;
}

export interface SkillNodeDefinition {
  id: string;
  treeId: SkillTreeId;
  name: string;
  description: string;
  maxRank: number;
  costPerRank: number;
  classId?: string;
  unlockAbilityId?: string;
  statModsPerRank?: HeroStatMods;
  requires?: SkillRequirement[];
}

export interface OriginDefinition {
  id: string;
  name: string;
  description: string;
  statMods: Partial<HeroBaseStats>;
}
