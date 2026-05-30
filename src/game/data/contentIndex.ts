import type {
  AbilityDefinition,
  BattleMapDefinition,
  BuildingDefinition,
  CampaignNodeDefinition,
  CampaignChapterDefinition,
  FactionDefinition,
  EnemyHeroAbilityDefinition,
  EnemyHeroDefinition,
  EnemyStrategicPressurePlanDefinition,
  ItemAffixDefinition,
  HeroClassDefinition,
  ItemDefinition,
  CampaignMissionTypeDefinition,
  OriginDefinition,
  RelicRewardDefinition,
  RewardTableDefinition,
  SkillNodeDefinition,
  UnitDefinition,
  EnemyAIPersonalityDefinition,
  CampaignModifierDefinition,
  EnemyDoctrineDefinition,
  EnemyEliteSquadDefinition,
  BattlefieldEventDefinition,
  LumeNetworkDefinition,
  TacticalPlanDefinition,
  UpgradeDefinition
} from "../core/GameTypes";
import { ABILITIES } from "./abilities";
import { AI_PERSONALITIES } from "./aiPersonalities";
import { BUILDINGS } from "./buildings";
import { CAMPAIGN_NODES } from "./campaignNodes";
import { CAMPAIGN_CHAPTERS } from "./campaignChapters";
import { CAMPAIGN_MODIFIERS } from "./campaignModifiers";
import { ENEMY_HERO_ABILITIES, ENEMY_HEROES } from "./enemyHeroes";
import { ENEMY_DOCTRINES, ENEMY_ELITE_SQUADS } from "./enemyDoctrines";
import { BATTLEFIELD_EVENTS } from "./battlefieldEvents";
import { LUME_NETWORKS } from "./lumeNetworks";
import { ENEMY_PRESSURE_PLANS } from "./enemyPressurePlans";
import { FACTIONS } from "./factions";
import { HERO_CLASSES } from "./heroClasses";
import { ITEM_AFFIXES } from "./itemAffixes";
import { ITEMS } from "./items";
import { MAPS } from "./maps";
import { CAMPAIGN_MISSION_TYPES } from "./missionTypes";
import { ORIGINS } from "./origins";
import { REWARD_TABLES } from "./rewards";
import { RELIC_REWARD_DEFINITIONS } from "./relicRewards";
import { SKILL_NODES } from "./skillTrees";
import { TACTICAL_PLANS } from "./tacticalPlans";
import { UNITS } from "./units";
import { UNIT_ROLE_IDENTITIES, type UnitRoleIdentity } from "./unitRoles";
import { UPGRADES } from "./upgrades";

function toIndex<T extends { id: string }>(entries: T[]): Record<string, T> {
  return Object.fromEntries(entries.map((entry) => [entry.id, entry]));
}

export const UNIT_BY_ID: Record<string, UnitDefinition> = toIndex(UNITS);
export const UNIT_ROLE_BY_ID: Record<string, UnitRoleIdentity> = Object.fromEntries(
  UNIT_ROLE_IDENTITIES.map((entry) => [entry.unitId, entry])
);
export const BUILDING_BY_ID: Record<string, BuildingDefinition> = toIndex(BUILDINGS);
export const ABILITY_BY_ID: Record<string, AbilityDefinition> = toIndex(ABILITIES);
export const HERO_CLASS_BY_ID: Record<string, HeroClassDefinition> = toIndex(HERO_CLASSES);
export const ORIGIN_BY_ID: Record<string, OriginDefinition> = toIndex(ORIGINS);
export const MAP_BY_ID: Record<string, BattleMapDefinition> = toIndex(MAPS);
export const CAMPAIGN_NODE_BY_ID: Record<string, CampaignNodeDefinition> = toIndex(CAMPAIGN_NODES);
export const CAMPAIGN_CHAPTER_BY_ID: Record<string, CampaignChapterDefinition> = toIndex(CAMPAIGN_CHAPTERS);
export const FACTION_BY_ID: Record<string, FactionDefinition> = toIndex(FACTIONS);
export const ENEMY_HERO_BY_ID: Record<string, EnemyHeroDefinition> = toIndex(ENEMY_HEROES);
export const ENEMY_HERO_ABILITY_BY_ID: Record<string, EnemyHeroAbilityDefinition> = toIndex(ENEMY_HERO_ABILITIES);
export const ENEMY_DOCTRINE_BY_ID: Record<string, EnemyDoctrineDefinition> = toIndex(ENEMY_DOCTRINES);
export const ENEMY_ELITE_SQUAD_BY_ID: Record<string, EnemyEliteSquadDefinition> = toIndex(ENEMY_ELITE_SQUADS);
export const BATTLEFIELD_EVENT_BY_ID: Record<string, BattlefieldEventDefinition> = toIndex(BATTLEFIELD_EVENTS);
export const LUME_NETWORK_BY_ID: Record<string, LumeNetworkDefinition> = toIndex(LUME_NETWORKS);
export const ENEMY_PRESSURE_PLAN_BY_ID: Record<string, EnemyStrategicPressurePlanDefinition> = toIndex(ENEMY_PRESSURE_PLANS);
export const TACTICAL_PLAN_BY_ID: Record<string, TacticalPlanDefinition> = toIndex(TACTICAL_PLANS);
export const ITEM_AFFIX_BY_ID: Record<string, ItemAffixDefinition> = toIndex(ITEM_AFFIXES);
export const ITEM_BY_ID: Record<string, ItemDefinition> = toIndex(ITEMS);
export const RELIC_REWARD_BY_ID: Record<string, RelicRewardDefinition> = toIndex(RELIC_REWARD_DEFINITIONS);
export const SKILL_NODE_BY_ID: Record<string, SkillNodeDefinition> = toIndex(SKILL_NODES);
export const REWARD_TABLE_BY_ID: Record<string, RewardTableDefinition> = toIndex(REWARD_TABLES);
export const UPGRADE_BY_ID: Record<string, UpgradeDefinition> = toIndex(UPGRADES);
export const AI_PERSONALITY_BY_ID: Record<string, EnemyAIPersonalityDefinition> = toIndex(AI_PERSONALITIES);
export const CAMPAIGN_MODIFIER_BY_ID: Record<string, CampaignModifierDefinition> = toIndex(CAMPAIGN_MODIFIERS);
export const CAMPAIGN_MISSION_TYPE_BY_ID: Record<string, CampaignMissionTypeDefinition> = toIndex(CAMPAIGN_MISSION_TYPES);

export function requireUnit(id: string): UnitDefinition {
  const definition = UNIT_BY_ID[id];
  if (!definition) {
    throw new Error(`Unknown unit id: ${id}`);
  }
  return definition;
}

export function requireBuilding(id: string): BuildingDefinition {
  const definition = BUILDING_BY_ID[id];
  if (!definition) {
    throw new Error(`Unknown building id: ${id}`);
  }
  return definition;
}

export function requireAbility(id: string): AbilityDefinition {
  const definition = ABILITY_BY_ID[id];
  if (!definition) {
    throw new Error(`Unknown ability id: ${id}`);
  }
  return definition;
}

export function requireHeroClass(id: string): HeroClassDefinition {
  const definition = HERO_CLASS_BY_ID[id];
  if (!definition) {
    throw new Error(`Unknown hero class id: ${id}`);
  }
  return definition;
}

export function requireOrigin(id: string): OriginDefinition {
  const definition = ORIGIN_BY_ID[id];
  if (!definition) {
    throw new Error(`Unknown origin id: ${id}`);
  }
  return definition;
}

export function requireItem(id: string): ItemDefinition {
  const definition = ITEM_BY_ID[id];
  if (!definition) {
    throw new Error(`Unknown item id: ${id}`);
  }
  return definition;
}

export function requireRewardTable(id: string): RewardTableDefinition {
  const definition = REWARD_TABLE_BY_ID[id];
  if (!definition) {
    throw new Error(`Unknown reward table id: ${id}`);
  }
  return definition;
}

export function requireCampaignNode(id: string): CampaignNodeDefinition {
  const definition = CAMPAIGN_NODE_BY_ID[id];
  if (!definition) {
    throw new Error(`Unknown campaign node id: ${id}`);
  }
  return definition;
}

export function requireCampaignChapter(id: string): CampaignChapterDefinition {
  const definition = CAMPAIGN_CHAPTER_BY_ID[id];
  if (!definition) {
    throw new Error(`Unknown campaign chapter id: ${id}`);
  }
  return definition;
}

export function requireUpgrade(id: string): UpgradeDefinition {
  const definition = UPGRADE_BY_ID[id];
  if (!definition) {
    throw new Error(`Unknown upgrade id: ${id}`);
  }
  return definition;
}

export function requireAIPersonality(id: string): EnemyAIPersonalityDefinition {
  const definition = AI_PERSONALITY_BY_ID[id];
  if (!definition) {
    throw new Error(`Unknown AI personality id: ${id}`);
  }
  return definition;
}

export function requireCampaignModifier(id: string): CampaignModifierDefinition {
  const definition = CAMPAIGN_MODIFIER_BY_ID[id];
  if (!definition) {
    throw new Error(`Unknown campaign modifier id: ${id}`);
  }
  return definition;
}

export function requireEnemyHero(id: string): EnemyHeroDefinition {
  const definition = ENEMY_HERO_BY_ID[id];
  if (!definition) {
    throw new Error(`Unknown enemy hero id: ${id}`);
  }
  return definition;
}

export function requireEnemyPressurePlan(id: string): EnemyStrategicPressurePlanDefinition {
  const definition = ENEMY_PRESSURE_PLAN_BY_ID[id];
  if (!definition) {
    throw new Error(`Unknown enemy pressure plan id: ${id}`);
  }
  return definition;
}
