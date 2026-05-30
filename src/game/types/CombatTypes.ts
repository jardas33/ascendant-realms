import type { Cost, ResourceBag } from "./EconomyTypes";
import type { Size, Team } from "./UITypes";

export type BattleDifficulty = "story" | "easy" | "normal" | "hard";

export type BattlePhaseId = "opening" | "expansion" | "pressure" | "assault";

export type EnemyAIPersonalityId = "balanced_warlord" | "raider_rush" | "fortress_keeper" | "hexfire_cult";

export type EnemyDoctrineId = "raider" | "fortress" | "hunter" | "warband";

export type TacticalPlanId = "guarded_advance" | "resource_push" | "champion_hunt";

export type EnemyHeroAbilityId = "ember_strike" | "rally_raiders" | "hexfire_bolt" | "hold_the_line";

export type EnemyHeroArchetype = "melee_commander" | "hexfire_seer" | "fortress_commander";

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
  buildOptions?: string[];
  projectileColor?: number;
  stats: CombatStats;
  xpValue: number;
  prerequisites?: TechPrerequisites;
}

export interface EnemyDoctrineDefinition {
  id: EnemyDoctrineId;
  name: string;
  shortDescription: string;
  statusLabel: string;
  threatWarning: string;
  counterplay: string;
  preferredMissionTypeIds: string[];
  preferredModifierIds: string[];
  tags: string[];
  activity: {
    resourceRaidInitialDelaySeconds?: number;
    resourceRaidCooldownMultiplier?: number;
    resourceRaidSquadBonus?: number;
    defenseReserveBonus?: number;
    attackWaveSizeBonus?: number;
    hunterInitialDelaySeconds?: number;
    hunterCooldownSeconds?: number;
    hunterEscortCount?: number;
    techCooldownMultiplier?: number;
  };
}

export interface EnemyEliteSquadDefinition {
  id: string;
  name: string;
  shortLabel: string;
  description: string;
  counterplay: string;
  eligibleDoctrineIds: EnemyDoctrineId[];
  eligibleMissionTypeIds: string[];
  eligibleUnitIds: string[];
  maxUnitsPerBattle: number;
  maxHpMultiplier: number;
  damageMultiplier: number;
  armorBonus: number;
}

export interface TacticalPlanDefinition {
  id: TacticalPlanId;
  name: string;
  shortLabel: string;
  description: string;
  effectSummary: string;
  hudSummary: string;
  afterActionSummary: string;
  recommendedDoctrineIds: EnemyDoctrineId[];
  recommendedCounterplay: string;
  tags: string[];
  launchModifierId: string;
}

export type EnemyHeroAbilityEffectDefinition =
  | {
      type: "damage-and-burn";
      damage: number;
      burn: {
        damagePerSecond: number;
        durationSeconds: number;
        tickInterval: number;
      };
    }
  | {
      type: "damage-buff";
      multiplier: number;
      durationSeconds: number;
      radius: number;
      maxTargets?: number;
    }
  | {
      type: "direct-damage";
      damage: number;
      projectileColor?: number;
    }
  | {
      type: "armor-aura";
      armorBonus: number;
      durationSeconds: number;
      radius: number;
      requiresNearEnemyBase?: boolean;
    };

export interface EnemyHeroAbilityDefinition {
  id: EnemyHeroAbilityId;
  name: string;
  description: string;
  cooldownSeconds: number;
  range: number;
  effect: EnemyHeroAbilityEffectDefinition;
}

export interface EnemyHeroDefinition {
  id: string;
  name: string;
  title: string;
  factionId: string;
  personalityId: EnemyAIPersonalityId;
  archetype: EnemyHeroArchetype;
  level: number;
  unitId: string;
  stats: CombatStats;
  xpValue: number;
  abilities: EnemyHeroAbilityId[];
  flavorText: string;
  campaignNodeIds: string[];
  mapIds: string[];
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

export type UpgradeCategory = "core" | "infantry" | "ranger" | "aether" | "defense" | "faction_trait";

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
      type: "building-stat-mod";
      buildingIds: string[];
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
  ownerBuildingId: string;
  category: UpgradeCategory;
  tier: number;
  cost: Cost;
  researchTimeSeconds: number;
  prerequisites: TechPrerequisites;
  effectSummary: string;
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
