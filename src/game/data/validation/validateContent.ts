import { ABILITIES } from "../abilities";
import { AI_PERSONALITIES } from "../aiPersonalities";
import { BUILDINGS } from "../buildings";
import { CAMPAIGN_NODES } from "../campaignNodes";
import { CAMPAIGN_CHAPTERS } from "../campaignChapters";
import { CAMPAIGN_MODIFIERS } from "../campaignModifiers";
import { ENEMY_HERO_ABILITIES, ENEMY_HEROES } from "../enemyHeroes";
import { ENEMY_PRESSURE_PLANS } from "../enemyPressurePlans";
import { FACTIONS } from "../factions";
import { HERO_CLASSES } from "../heroClasses";
import { ITEM_AFFIXES } from "../itemAffixes";
import { ITEMS } from "../items";
import { CAMPAIGN_MISSION_TYPES } from "../missionTypes";
import { ORIGINS } from "../origins";
import { REWARD_TABLES } from "../rewards";
import { RESOURCE_DEFINITIONS } from "../resources";
import { RELIC_REWARD_DEFINITIONS } from "../relicRewards";
import { RIVAL_REWARDS } from "../rivalRewards";
import { SKILL_NODES, SKILL_TREES } from "../skillTrees";
import { STRONGHOLD_UPGRADES } from "../strongholdUpgrades";
import { TUTORIALS } from "../tutorials";
import { UNITS } from "../units";
import { UPGRADES } from "../upgrades";
import { idsFor, type ValidationContext } from "./ValidationTypes";
import { validateAbilities, validateHeroClasses, validateSkillNodes } from "./validateAbilities";
import { validateAIPersonalities, validateDifficulties } from "./validateAi";
import { validateBuildings } from "./validateBuildings";
import {
  validateCampaignChapters,
  validateCampaignActSpine,
  validateCampaignMissionTypes,
  validateCampaignModifiers,
  validateCampaignNodes,
  validateReputationEffects
} from "./validateCampaign";
import { validateEnemyHeroes } from "./validateEnemyHeroes";
import { validateEnemyDoctrines, validateEnemyEliteSquads } from "./validateEnemyDoctrines";
import { validateEnemyPressurePlans } from "./validateEnemyPressurePlans";
import { validateFactions } from "./validateFactions";
import { validateItemAffixes, validateItems } from "./validateItems";
import { validateMaps } from "./validateMaps";
import { validateOrigins, validateResources } from "./validateResources";
import { validateRelicRewards, validateRewardTables, validateRivalRewards } from "./validateRewards";
import { validateStrongholdUpgrades } from "./validateStronghold";
import { validateTacticalPlans } from "./validateTacticalPlans";
import { validateTutorials } from "./validateTutorials";
import { validateUnits } from "./validateUnits";
import { validateUpgrades } from "./validateUpgrades";

export function validateContent(): string[] {
  const errors: string[] = [];
  const context: ValidationContext = {
    unitIds: idsFor(UNITS, "unit", errors),
    buildingIds: idsFor(BUILDINGS, "building", errors),
    abilityIds: idsFor(ABILITIES, "ability", errors),
    factionIds: idsFor(FACTIONS, "faction", errors),
    heroClassIds: idsFor(HERO_CLASSES, "hero class", errors),
    originIds: idsFor(ORIGINS, "origin", errors),
    itemIds: idsFor(ITEMS, "item", errors),
    itemAffixIds: idsFor(ITEM_AFFIXES, "item affix", errors),
    resourceIds: idsFor(RESOURCE_DEFINITIONS, "resource", errors),
    skillTreeIds: idsFor(SKILL_TREES, "skill tree", errors),
    skillNodeIds: idsFor(SKILL_NODES, "skill node", errors),
    rewardTableIds: idsFor(REWARD_TABLES, "reward table", errors),
    relicRewardIds: idsFor(RELIC_REWARD_DEFINITIONS, "relic reward", errors),
    upgradeIds: idsFor(UPGRADES, "upgrade", errors),
    strongholdUpgradeIds: idsFor(STRONGHOLD_UPGRADES, "stronghold upgrade", errors),
    campaignChapterIds: idsFor(CAMPAIGN_CHAPTERS, "campaign chapter", errors),
    campaignMissionTypeIds: idsFor(CAMPAIGN_MISSION_TYPES, "campaign mission type", errors),
    campaignNodeIds: idsFor(CAMPAIGN_NODES, "campaign node", errors),
    aiPersonalityIds: idsFor(AI_PERSONALITIES, "AI personality", errors),
    campaignModifierIds: idsFor(CAMPAIGN_MODIFIERS, "campaign modifier", errors),
    enemyHeroIds: idsFor(ENEMY_HEROES, "enemy hero", errors),
    enemyHeroAbilityIds: idsFor(ENEMY_HERO_ABILITIES, "enemy hero ability", errors),
    enemyPressurePlanIds: idsFor(ENEMY_PRESSURE_PLANS, "enemy pressure plan", errors),
    tutorialIds: idsFor(TUTORIALS, "tutorial", errors),
    rivalTrophyIds: new Set(RIVAL_REWARDS.map((reward) => reward.firstDefeat.trophy.trophyId))
  };

  validateUnits(errors, context);
  validateBuildings(errors, context);
  validateAbilities(errors, context);
  validateHeroClasses(errors, context);
  validateItems(errors, context);
  validateItemAffixes(errors);
  validateOrigins(errors);
  validateResources(errors);
  validateFactions(errors, context);
  validateSkillNodes(errors, context);
  validateRewardTables(errors, context);
  validateRivalRewards(errors, context);
  validateRelicRewards(errors, context);
  validateStrongholdUpgrades(errors, context);
  validateCampaignMissionTypes(errors, context);
  validateCampaignChapters(errors, context);
  validateCampaignNodes(errors, context);
  validateCampaignActSpine(errors, context);
  validateReputationEffects(errors, context);
  validateUpgrades(errors, context);
  validateDifficulties(errors);
  validateAIPersonalities(errors, context);
  validateEnemyDoctrines(errors, context);
  validateEnemyEliteSquads(errors, context);
  validateTacticalPlans(errors);
  validateCampaignModifiers(errors, context);
  validateEnemyHeroes(errors, context);
  validateEnemyPressurePlans(errors, context);
  validateMaps(errors, context);
  validateTutorials(errors, context);
  return errors;
}
