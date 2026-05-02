import type { Cost, ResourceBag } from "./EconomyTypes";
import type { Size, Team } from "./UITypes";

export type BattleDifficulty = "story" | "easy" | "normal" | "hard";

export type BattlePhaseId = "opening" | "expansion" | "pressure" | "assault";

export type EnemyAIPersonalityId = "balanced_warlord" | "raider_rush" | "fortress_keeper" | "hexfire_cult";

export type BuildingConstructionState = "planned" | "underConstruction" | "completed";

export type StatusEffectType = "burn";

export type FactionModifierType = "burn-on-hit" | "low-health-damage" | "wave-speed";

export interface CombatStats {
  maxHp: number;
  damage: number;
  range: number;
  attackCooldown: number;
  speed: number;
  armor: number;
}

export type UnitVeterancyRankId = "recruit" | "seasoned" | "veteran" | "elite";

export interface UnitVeterancyRankDefinition {
  id: UnitVeterancyRankId;
  name: string;
  minXp: number;
  maxHpMultiplier: number;
  damageMultiplier: number;
  armorBonus: number;
  flavorText?: string;
}

export interface UnitVeterancyState {
  unitInstanceId: string;
  unitTypeId: string;
  xp: number;
  rank: UnitVeterancyRankId;
  kills: number;
  damageDealt: number;
  survivedBattle: boolean;
  rankedUpThisBattle: boolean;
}

export interface UnitVeterancyRankUpEvent {
  unitInstanceId: string;
  unitTypeId: string;
  unitName: string;
  fromRank: UnitVeterancyRankId;
  toRank: UnitVeterancyRankId;
  xp: number;
  kills: number;
  damageDealt: number;
  survivedBattle: boolean;
}

export interface UnitVeterancySummaryEntry {
  unitInstanceId: string;
  unitTypeId: string;
  unitName: string;
  xp: number;
  rank: UnitVeterancyRankId;
  rankName: string;
  kills: number;
  damageDealt: number;
  survivedBattle: boolean;
  rankedUp: boolean;
  previousRank?: UnitVeterancyRankId;
}

export interface UnitVeterancyBattleSummary {
  rankedUpUnits: UnitVeterancySummaryEntry[];
  notableVeterans: UnitVeterancySummaryEntry[];
  topSurvivor?: UnitVeterancySummaryEntry;
}

export interface UnitDefinition {
  id: string;
  name: string;
  factionId: string;
  role: string;
  description: string;
  cost: Cost;
  trainTime: number;
  radius: number;
  color: number;
  visionRadius: number;
  projectileColor?: number;
  stats: CombatStats;
  xpValue: number;
  prerequisites?: TechPrerequisites;
}

export interface BuildingDefinition {
  id: string;
  name: string;
  factionId: string;
  description: string;
  cost: Cost;
  maxHp: number;
  armor: number;
  size: Size;
  color: number;
  visionRadius: number;
  constructionTimeSeconds: number;
  buildOptions: string[];
  trainOptions: string[];
  upgradeOptions: string[];
  xpValue: number;
  prerequisites?: TechPrerequisites;
  attack?: {
    damage: number;
    range: number;
    cooldown: number;
    projectileColor: number;
  };
}

export interface FactionDefinition {
  id: string;
  name: string;
  fantasy: string;
  color: number;
  mechanics: FactionMechanicsDefinition;
}

export interface FactionModifierDefinition {
  id: string;
  name: string;
  description: string;
  type: FactionModifierType;
  unitIds?: string[];
  hpThreshold?: number;
  damageMultiplier?: number;
  burn?: {
    damagePerSecond: number;
    durationSeconds: number;
    tickInterval: number;
  };
  speedMultiplier?: number;
}

export interface FactionMechanicsDefinition {
  economyStyle: string;
  militaryStyle: string;
  magicStyle: string;
  availableUnitIds: string[];
  availableBuildingIds: string[];
  availableUpgradeIds: string[];
  aiPersonalityPreferences: EnemyAIPersonalityId[];
  campaignReputationHooks: string[];
  factionModifiers: FactionModifierDefinition[];
}

export interface ActiveStatusEffect {
  id: string;
  name: string;
  type: StatusEffectType;
  remainingSeconds: number;
  durationSeconds: number;
  tickInterval: number;
  tickTimer: number;
  damagePerSecond: number;
  sourceId?: string;
  sourceTeam?: Team;
}

export interface TechPrerequisites {
  buildingIds?: string[];
  upgradeIds?: string[];
  heroLevel?: number;
}

export type UpgradeEffectDefinition =
  | {
      type: "unit-stat-mod";
      unitIds: string[];
      damageMultiplier?: number;
      rangeMultiplier?: number;
      attackCooldownMultiplier?: number;
      armorBonus?: number;
    }
  | {
      type: "hero-mana-regen";
      multiplier: number;
    };

export interface UpgradeDefinition {
  id: string;
  name: string;
  description: string;
  cost: Cost;
  researchTimeSeconds: number;
  prerequisites: TechPrerequisites;
  effects: UpgradeEffectDefinition[];
}

export interface BattlePhaseDefinition {
  id: BattlePhaseId;
  name: string;
  startSeconds: number;
  endSeconds?: number;
  enemy: {
    baseAttackAllowed: boolean;
    maxAttackWaveSize: number;
    commanderAllowed: boolean;
    allowedAttackUnitIds: string[];
    preferredAttackUnitIds: string[];
    trainUnitIds: string[];
    maxAttackByUnitId?: Record<string, number>;
  };
}

export type EnemyAIPhaseOverride = Partial<BattlePhaseDefinition["enemy"]>;

export interface EnemyAIPersonalityDefinition {
  id: EnemyAIPersonalityId;
  name: string;
  shortDescription: string;
  description: string;
  aggressionLevel: number;
  preferredUnitIds: string[];
  unitPlan: string[];
  timing: {
    firstAttackDelayMultiplier: number;
    attackIntervalMultiplier: number;
    expandIntervalMultiplier: number;
    trainIntervalMultiplier: number;
    commanderJoinDelayMultiplier: number;
  };
  economy: {
    incomeMultiplier: number;
  };
  waves: {
    attackWaveSizeMultiplier: number;
    minAttackArmySizeDelta: number;
    phaseOverrides: Partial<Record<BattlePhaseId, EnemyAIPhaseOverride>>;
  };
  defense: {
    defendRadiusMultiplier: number;
    defenseSquadSizeDelta: number;
    reserveDefenseUnits: number;
    protectCaptureSites: boolean;
  };
  commander: {
    joinsFirstAttack: boolean;
  };
  behaviorNotes: string[];
}

export interface BattleDifficultyDefinition {
  id: BattleDifficulty;
  name: string;
  description: string;
  enemyStartingUnitSpawnIds: string[];
  enemyIncomeMultiplier: number;
  firstAttackDelay: number;
  attackInterval: number;
  attackWaveSize: number;
  expandInterval: number;
  trainInterval: number;
  minAttackArmySize: number;
  expandSquadSize: number;
  commanderJoinDelay: number;
  fogOfWarEnabled: boolean;
}

export interface FirstMatchTutorialProtectionDefinition {
  firstAttackAllowedAfterSeconds: number;
  firstAttackForceAfterSeconds: number;
  largeAttackAllowedAfterSeconds: number;
  earlyAttackMaxWaveSize: number;
}
