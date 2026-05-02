import { ABILITIES } from "../abilities";
import { AI_PERSONALITIES } from "../aiPersonalities";
import { BUILDINGS } from "../buildings";
import { CAMPAIGN_NODES } from "../campaignNodes";
import { CAMPAIGN_MODIFIERS } from "../campaignModifiers";
import { ENEMY_HERO_ABILITIES, ENEMY_HEROES } from "../enemyHeroes";
import { FACTIONS } from "../factions";
import { HERO_CLASSES } from "../heroClasses";
import { ITEM_AFFIXES } from "../itemAffixes";
import { ITEMS } from "../items";
import { ORIGINS } from "../origins";
import { REWARD_TABLES } from "../rewards";
import { RESOURCE_DEFINITIONS } from "../resources";
import { SKILL_NODES, SKILL_TREES } from "../skillTrees";
import { STRONGHOLD_UPGRADES } from "../strongholdUpgrades";
import { UNITS } from "../units";
import { UPGRADES } from "../upgrades";
import { idsFor, type ValidationContext } from "./ValidationTypes";
import { validateAbilities, validateHeroClasses, validateSkillNodes } from "./validateAbilities";
import { validateAIPersonalities, validateDifficulties } from "./validateAi";
import { validateBuildings } from "./validateBuildings";
import { validateCampaignModifiers, validateCampaignNodes, validateReputationEffects } from "./validateCampaign";
import { validateEnemyHeroes } from "./validateEnemyHeroes";
import { validateFactions } from "./validateFactions";
import { validateItemAffixes, validateItems } from "./validateItems";
import { validateMaps } from "./validateMaps";
import { validateOrigins, validateResources } from "./validateResources";
import { validateRewardTables } from "./validateRewards";
import { validateStrongholdUpgrades } from "./validateStronghold";
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
    upgradeIds: idsFor(UPGRADES, "upgrade", errors),
    strongholdUpgradeIds: idsFor(STRONGHOLD_UPGRADES, "stronghold upgrade", errors),
    campaignNodeIds: idsFor(CAMPAIGN_NODES, "campaign node", errors),
    aiPersonalityIds: idsFor(AI_PERSONALITIES, "AI personality", errors),
    campaignModifierIds: idsFor(CAMPAIGN_MODIFIERS, "campaign modifier", errors),
    enemyHeroIds: idsFor(ENEMY_HEROES, "enemy hero", errors),
    enemyHeroAbilityIds: idsFor(ENEMY_HERO_ABILITIES, "enemy hero ability", errors)
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
  validateStrongholdUpgrades(errors, context);
  validateCampaignNodes(errors, context);
  validateReputationEffects(errors, context);
  validateUpgrades(errors, context);
  validateDifficulties(errors);
  validateAIPersonalities(errors, context);
  validateCampaignModifiers(errors, context);
  validateEnemyHeroes(errors, context);
  validateMaps(errors, context);
  return errors;
}
