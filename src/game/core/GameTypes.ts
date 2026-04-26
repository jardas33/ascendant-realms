export type Team = "player" | "enemy" | "neutral";

export type ResourceKey = "crowns" | "stone" | "iron" | "aether";

export type EntityKind = "unit" | "hero" | "building" | "projectile" | "capture-site";

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

export type TerrainType = "grass" | "buildable" | "blocked" | "water";
export type SkillTreeId = "combat" | "magic" | "leadership";
export type EquipmentSlot = "weapon" | "armor" | "trinket" | "relic";
export type ItemRarity = "common" | "uncommon" | "rare" | "epic" | "legendary";
export type BattleDifficulty = "story" | "easy" | "normal" | "hard";
export type BattlePhaseId = "opening" | "expansion" | "pressure" | "assault";
export type EnemyAIPersonalityId = "balanced_warlord" | "raider_rush" | "fortress_keeper" | "hexfire_cult";
export type CampaignModifierId = "inspired_militia" | "blessed_road" | "angered_raiders" | "local_support";
export type CampaignModifierTrigger = "next_battle" | "next_ashen_battle" | "next_node_resource_reward";
export type BuildingConstructionState = "planned" | "underConstruction" | "completed";
export type CampaignNodeType = "battle" | "shrine" | "town" | "ruin" | "fortress" | "event";
export type VisibilityState = "unseen" | "explored" | "visible";
export type StatusEffectType = "burn";
export type FactionModifierType = "burn-on-hit" | "low-health-damage" | "wave-speed";

export interface Position {
  x: number;
  y: number;
}

export interface Size {
  width: number;
  height: number;
}

export type ResourceBag = Record<ResourceKey, number>;

export interface Cost {
  crowns?: number;
  stone?: number;
  iron?: number;
  aether?: number;
}

export interface CombatStats {
  maxHp: number;
  damage: number;
  range: number;
  attackCooldown: number;
  speed: number;
  armor: number;
}

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

export interface ItemDefinition {
  id: string;
  name: string;
  slot: EquipmentSlot;
  rarity: ItemRarity;
  description: string;
  statMods: HeroStatMods;
  classAffinity?: string[];
  factionOrigin?: string;
  iconAssetKey?: string;
  flavorText: string;
  tags: string[];
}

export interface RewardTableDefinition {
  id: string;
  name: string;
  guaranteedItemIds: string[];
  weightedItemPool: WeightedRewardEntry[];
  resourceRewards: RewardResourceDefinition[];
  xpRewards: RewardXpDefinition[];
  firstClearBonus?: RewardBonusDefinition;
  repeatClearReward?: RewardBonusDefinition;
  rolls: number;
  deterministicItemIds?: string[];
}

export interface WeightedRewardEntry {
  itemId: string;
  weight: number;
  mapIds?: string[];
  firstClearOnly?: boolean;
  repeatClearOnly?: boolean;
}

export interface RewardResourceDefinition {
  resource: ResourceKey;
  amount: number;
  firstClearOnly?: boolean;
  repeatClearOnly?: boolean;
}

export interface RewardXpDefinition {
  amount: number;
  firstClearOnly?: boolean;
  repeatClearOnly?: boolean;
}

export interface RewardBonusDefinition {
  itemIds?: string[];
  resources?: Partial<ResourceBag>;
  xp?: number;
}

export interface BattleRewardResult {
  itemIds: string[];
  resources: Partial<ResourceBag>;
  xp: number;
}

export interface RewardLevelUpSummary {
  previousLevel: number;
  newLevel: number;
  levelsGained: number;
  skillPointsGained: number;
}

export interface OriginDefinition {
  id: string;
  name: string;
  description: string;
  statMods: Partial<HeroBaseStats>;
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

export interface ResourceDefinition {
  id: ResourceKey;
  name: string;
  color: number;
  description: string;
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

export interface CampaignModifierDefinition {
  id: CampaignModifierId;
  name: string;
  description: string;
  trigger: CampaignModifierTrigger;
  durationLabel: string;
  effects: {
    extraPlayerUnitIds?: string[];
    extraEnemyUnitIds?: string[];
    heroManaMultiplier?: number;
    campaignResourceRewardMultiplier?: number;
  };
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

export interface TerrainZoneDefinition {
  id: string;
  type: TerrainType;
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface CaptureSiteDefinition {
  id: string;
  name: string;
  resource: ResourceKey;
  x: number;
  y: number;
  radius: number;
  incomeAmount: number;
  incomeInterval: number;
}

export interface NeutralCampDefinition {
  id: string;
  name: string;
  x: number;
  y: number;
  unitIds: string[];
}

export interface UnitSpawnDefinition {
  id: string;
  unitId: string;
  team: Team;
  x: number;
  y: number;
}

export interface BuildingSpawnDefinition {
  id: string;
  buildingId: string;
  team: Exclude<Team, "neutral">;
  x: number;
  y: number;
}

export type BattleSecondaryObjectiveType = "capture_site" | "destroy_building" | "defeat_unit";

export interface BattleSecondaryObjectiveDefinition {
  id: string;
  name: string;
  description: string;
  type: BattleSecondaryObjectiveType;
  targetId: string;
}

export interface BattleObjectiveDefinition {
  playerBaseBuildingId: string;
  enemyBaseBuildingId: string;
  secondaryObjectives?: BattleSecondaryObjectiveDefinition[];
}

export interface BattleMapPathDefinition {
  id: string;
  width: number;
  points: Position[];
}

export interface EnemyAIConfig {
  incomeInterval: number;
  incomePerTick: Partial<ResourceBag>;
  trainInterval: number;
  expandInterval: number;
  initialExpandDelay: number;
  attackInterval: number;
  initialAttackDelay: number;
  minAttackArmySize: number;
  attackWaveSize: number;
  expandSquadSize: number;
  defenseSquadSize: number;
  defendRadius: number;
  baseBuildingId: string;
  productionBuildingId: string;
  attackTargetBuildingId: string;
  unitPlan: string[];
}

export interface BattleScenarioDefinition {
  startingResources: Record<"player" | "enemy", ResourceBag>;
  heroSpawn: Position;
  buildingSpawns: BuildingSpawnDefinition[];
  unitSpawns: UnitSpawnDefinition[];
  objectives: BattleObjectiveDefinition;
  enemyAI: EnemyAIConfig;
  rewardTableId: string;
}

export interface BattleMapDefinition {
  id: string;
  name: string;
  role: string;
  description: string;
  strategicNotes: string[];
  width: number;
  height: number;
  playerStart: Position;
  enemyStart: Position;
  visualPaths: BattleMapPathDefinition[];
  terrainZones: TerrainZoneDefinition[];
  captureSites: CaptureSiteDefinition[];
  neutralCamps: NeutralCampDefinition[];
  scenario: BattleScenarioDefinition;
}

export interface BattleStats {
  unitsKilled: number;
  buildingsDestroyed: number;
  resourcesCaptured: number;
  firstSiteCaptured?: string;
  buildingsBuilt: number;
  builtBuildingIds: string[];
  unitsTrained: number;
  trainedUnitIds: string[];
  enemyWavesSurvived: number;
  xpGained: number;
  timeSeconds: number;
  completedObjectiveIds: string[];
  outcome: "victory" | "defeat";
}

export interface CampaignNodeRewardDefinition {
  itemIds?: string[];
  resources?: Partial<ResourceBag>;
  xp?: number;
}

export interface CampaignChoiceRequirements {
  resources?: Partial<ResourceBag>;
  heroLevel?: number;
  completedNodeIds?: string[];
  itemIds?: string[];
  factionReputation?: Record<string, number>;
}

export interface CampaignChoiceRewardDefinition extends CampaignNodeRewardDefinition {
  unlockNodeIds?: string[];
  lockNodeIds?: string[];
  modifierIds?: CampaignModifierId[];
  removeModifierIds?: CampaignModifierId[];
  reputationChanges?: Record<string, number>;
  recoverHero?: boolean;
}

export interface CampaignNodeChoiceDefinition {
  id: string;
  label: string;
  description: string;
  requirements?: CampaignChoiceRequirements;
  costs?: Partial<ResourceBag>;
  rewards?: CampaignChoiceRewardDefinition;
  reputationChanges?: Record<string, number>;
  unlockNodeIds?: string[];
  lockNodeIds?: string[];
  modifierIds?: CampaignModifierId[];
  removeModifierIds?: CampaignModifierId[];
  onceOnly: boolean;
  completesNode?: boolean;
}

export interface CampaignNodeDefinition {
  id: string;
  name: string;
  description: string;
  nodeType: CampaignNodeType;
  difficulty: BattleDifficulty;
  mapId: string;
  enemyFactionId: string;
  aiPersonalityId?: EnemyAIPersonalityId;
  prerequisites: string[];
  rewards: CampaignNodeRewardDefinition;
  eventText?: string;
  choices?: CampaignNodeChoiceDefinition[];
  unlocks: string[];
  x: number;
  y: number;
}

export type CampaignNodeStatus = "locked" | "available" | "completed";
