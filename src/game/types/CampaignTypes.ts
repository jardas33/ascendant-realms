import type { BattleDifficulty, EnemyAIPersonalityId } from "./CombatTypes";
import type { Cost, ResourceBag } from "./EconomyTypes";
import type { EnemyStrategicPressurePlanId } from "./EnemyPressureTypes";

export type CampaignModifierId =
  | "inspired_militia"
  | "blessed_road"
  | "well_rested"
  | "angered_raiders"
  | "local_support"
  | "ashen_hostile_pressure"
  | "marsh_guides"
  | "ash_filters"
  | "shrine_attunement"
  | "mission_rich_veins"
  | "mission_enemy_patrols"
  | "mission_fortified_enemy"
  | "mission_aether_surge";

export type CampaignModifierTrigger =
  | "next_battle"
  | "next_ashen_battle"
  | "next_cinderfen_battle"
  | "next_node_resource_reward"
  | "mission_battle";

export type CampaignNodeType = "battle" | "shrine" | "town" | "ruin" | "fortress" | "event";

export type CampaignChapterId = "border_marches" | "cinderfen_road";

export type CampaignChapterStatus = "unlocked" | "locked" | "upcoming";

export type CampaignMissionTypeId = "assault" | "control" | "defense" | "skirmish_training";

export type CampaignActId = "act1";

export type CampaignActStepKind = "training" | "campaign_battle" | "campaign_support" | "replay_loop";

export type CampaignActPacingTier = "training" | "low" | "standard" | "milestone" | "replay";

export interface CampaignActStepDefinition {
  id: string;
  actId: CampaignActId;
  order: number;
  title: string;
  kind: CampaignActStepKind;
  pacingTier: CampaignActPacingTier;
  nodeId?: string;
  supportNodeIds?: string[];
  mechanicFocus: string[];
  recommendedBuildTags: string[];
  unlockSummary: string;
  playerGoal: string;
  difficultyPacing: string;
  onboardingHint: string;
  resultsHint: string;
  nextAction: string;
  replayHint?: string;
}

export interface CampaignMissionTypeDefinition {
  id: CampaignMissionTypeId;
  name: string;
  shortDescription: string;
  objectiveHint: string;
  recommendedBuildTags: string[];
}

export interface CampaignChapterDefinition {
  id: CampaignChapterId;
  title: string;
  shortDescription: string;
  nodeIds: string[];
  unlockPrerequisiteNodeIds: string[];
  isUpcoming?: boolean;
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
    heroMaxHpMultiplier?: number;
    buildingVisionBonus?: number;
    enemyWarningLeadSeconds?: number;
    campaignResourceRewardMultiplier?: number;
    firstCaptureBonusResourceAdditions?: Record<string, Partial<ResourceBag>>;
    captureSiteIncomeMultiplier?: number;
    enemyAttackIntervalMultiplier?: number;
    enemyInitialAttackDelayMultiplier?: number;
    enemyDefenseSquadSizeBonus?: number;
  };
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
  rivalTrophyIds?: string[];
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
  stockItemId?: string;
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
  chapterId?: CampaignChapterId;
  nodeType: CampaignNodeType;
  missionTypeId?: CampaignMissionTypeId;
  missionBriefing?: {
    summary: string;
    primaryObjective: string;
    rewardPreview: string;
    afterActionSummary: string;
    recommendedBuildHint?: string;
  };
  scenarioModifierIds?: CampaignModifierId[];
  difficulty: BattleDifficulty;
  mapId: string;
  enemyFactionId: string;
  aiPersonalityId?: EnemyAIPersonalityId;
  enemyHeroId?: string;
  enemyPressurePlanId?: EnemyStrategicPressurePlanId;
  isPlaceholder?: boolean;
  placeholderLabel?: string;
  placeholderDescription?: string;
  futureMapName?: string;
  prerequisites: string[];
  rewards: CampaignNodeRewardDefinition;
  eventText?: string;
  choices?: CampaignNodeChoiceDefinition[];
  unlocks: string[];
  x: number;
  y: number;
}

export type CampaignNodeStatus = "locked" | "available" | "completed";

export type StrongholdUpgradeId =
  | "training_yard_i"
  | "training_yard_ii"
  | "watch_post_i"
  | "watch_post_ii"
  | "quartermaster_stores_i"
  | "quartermaster_stores_ii"
  | "chapel_corner_i"
  | "chapel_corner_ii"
  | "ranger_paths_i"
  | "ranger_paths_ii";

export interface StrongholdUpgradePrerequisites {
  upgradeRanks?: Partial<Record<StrongholdUpgradeId, number>>;
  completedNodeIds?: string[];
}

export type StrongholdUpgradeEffectDefinition =
  | {
      type: "extra-starting-unit";
      unitId: string;
      count: number;
    }
  | {
      type: "starting-resources";
      resources: Partial<ResourceBag>;
    }
  | {
      type: "hero-max-hp-multiplier";
      multiplier: number;
    }
  | {
      type: "hero-max-mana-multiplier";
      multiplier: number;
    }
  | {
      type: "building-vision-bonus";
      amount: number;
    }
  | {
      type: "enemy-wave-warning-lead";
      seconds: number;
    }
  | {
      type: "watchtower-range-multiplier";
      multiplier: number;
    }
  | {
      type: "first-building-construction-time-multiplier";
      multiplier: number;
    }
  | {
      type: "unit-training-time-multiplier";
      unitId: string;
      multiplier: number;
    };

export interface StrongholdUpgradeDefinition {
  id: StrongholdUpgradeId;
  name: string;
  description: string;
  tier: number;
  cost: Cost;
  prerequisites: StrongholdUpgradePrerequisites;
  effects: StrongholdUpgradeEffectDefinition[];
  maxRank: number;
  iconKey?: string;
  flavorText: string;
}
