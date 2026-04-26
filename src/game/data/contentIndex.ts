import type {
  AbilityDefinition,
  BattleMapDefinition,
  BuildingDefinition,
  CampaignNodeDefinition,
  FactionDefinition,
  HeroClassDefinition,
  ItemDefinition,
  OriginDefinition,
  RewardTableDefinition,
  SkillNodeDefinition,
  UnitDefinition,
  UpgradeDefinition
} from "../core/GameTypes";
import { ABILITIES } from "./abilities";
import { BUILDINGS } from "./buildings";
import { CAMPAIGN_NODES } from "./campaignNodes";
import { FACTIONS } from "./factions";
import { HERO_CLASSES } from "./heroClasses";
import { ITEMS } from "./items";
import { MAPS } from "./maps";
import { ORIGINS } from "./origins";
import { REWARD_TABLES } from "./rewards";
import { SKILL_NODES } from "./skillTrees";
import { UNITS } from "./units";
import { UPGRADES } from "./upgrades";

function toIndex<T extends { id: string }>(entries: T[]): Record<string, T> {
  return Object.fromEntries(entries.map((entry) => [entry.id, entry]));
}

export const UNIT_BY_ID: Record<string, UnitDefinition> = toIndex(UNITS);
export const BUILDING_BY_ID: Record<string, BuildingDefinition> = toIndex(BUILDINGS);
export const ABILITY_BY_ID: Record<string, AbilityDefinition> = toIndex(ABILITIES);
export const HERO_CLASS_BY_ID: Record<string, HeroClassDefinition> = toIndex(HERO_CLASSES);
export const ORIGIN_BY_ID: Record<string, OriginDefinition> = toIndex(ORIGINS);
export const MAP_BY_ID: Record<string, BattleMapDefinition> = toIndex(MAPS);
export const CAMPAIGN_NODE_BY_ID: Record<string, CampaignNodeDefinition> = toIndex(CAMPAIGN_NODES);
export const FACTION_BY_ID: Record<string, FactionDefinition> = toIndex(FACTIONS);
export const ITEM_BY_ID: Record<string, ItemDefinition> = toIndex(ITEMS);
export const SKILL_NODE_BY_ID: Record<string, SkillNodeDefinition> = toIndex(SKILL_NODES);
export const REWARD_TABLE_BY_ID: Record<string, RewardTableDefinition> = toIndex(REWARD_TABLES);
export const UPGRADE_BY_ID: Record<string, UpgradeDefinition> = toIndex(UPGRADES);

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

export function requireUpgrade(id: string): UpgradeDefinition {
  const definition = UPGRADE_BY_ID[id];
  if (!definition) {
    throw new Error(`Unknown upgrade id: ${id}`);
  }
  return definition;
}
