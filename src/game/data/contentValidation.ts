import type { BattleMapDefinition } from "../core/GameTypes";
import { ABILITIES } from "./abilities";
import { AI_PERSONALITIES } from "./aiPersonalities";
import { BATTLE_DIFFICULTIES } from "./battlePacing";
import { BUILDINGS } from "./buildings";
import { CAMPAIGN_NODES } from "./campaignNodes";
import { CAMPAIGN_MODIFIERS } from "./campaignModifiers";
import { FACTIONS } from "./factions";
import { HERO_CLASSES } from "./heroClasses";
import { ITEMS } from "./items";
import { MAPS } from "./maps";
import { ORIGINS } from "./origins";
import { REWARD_TABLES } from "./rewards";
import { RESOURCE_DEFINITIONS } from "./resources";
import { SKILL_NODES, SKILL_TREES } from "./skillTrees";
import { UNITS } from "./units";
import { UPGRADES } from "./upgrades";

interface ValidationContext {
  unitIds: Set<string>;
  buildingIds: Set<string>;
  abilityIds: Set<string>;
  factionIds: Set<string>;
  heroClassIds: Set<string>;
  originIds: Set<string>;
  itemIds: Set<string>;
  resourceIds: Set<string>;
  skillTreeIds: Set<string>;
  skillNodeIds: Set<string>;
  rewardTableIds: Set<string>;
  upgradeIds: Set<string>;
  campaignNodeIds: Set<string>;
  aiPersonalityIds: Set<string>;
  campaignModifierIds: Set<string>;
}

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
    resourceIds: idsFor(RESOURCE_DEFINITIONS, "resource", errors),
    skillTreeIds: idsFor(SKILL_TREES, "skill tree", errors),
    skillNodeIds: idsFor(SKILL_NODES, "skill node", errors),
    rewardTableIds: idsFor(REWARD_TABLES, "reward table", errors),
    upgradeIds: idsFor(UPGRADES, "upgrade", errors),
    campaignNodeIds: idsFor(CAMPAIGN_NODES, "campaign node", errors),
    aiPersonalityIds: idsFor(AI_PERSONALITIES, "AI personality", errors),
    campaignModifierIds: idsFor(CAMPAIGN_MODIFIERS, "campaign modifier", errors)
  };

  validateUnits(errors, context);
  validateBuildings(errors, context);
  validateAbilities(errors, context);
  validateHeroClasses(errors, context);
  validateItems(errors, context);
  validateOrigins(errors);
  validateResources(errors);
  validateFactions(errors, context);
  validateSkillNodes(errors, context);
  validateRewardTables(errors, context);
  validateCampaignNodes(errors, context);
  validateUpgrades(errors, context);
  validateDifficulties(errors);
  validateAIPersonalities(errors, context);
  validateCampaignModifiers(errors, context);
  MAPS.forEach((map) => validateMap(map, errors, context));
  return errors;
}

function validateCampaignNodes(errors: string[], context: ValidationContext): void {
  CAMPAIGN_NODES.forEach((node) => {
    if (!["battle", "shrine", "town", "ruin", "fortress", "event"].includes(node.nodeType)) {
      errors.push(`Campaign node ${node.id} has invalid node type ${node.nodeType}.`);
    }
    if (!node.name.trim() || !node.description.trim()) {
      errors.push(`Campaign node ${node.id} needs name and description.`);
    }
    if (!MAPS.some((map) => map.id === node.mapId)) {
      errors.push(`Campaign node ${node.id} references missing map ${node.mapId}.`);
    }
    if (!context.factionIds.has(node.enemyFactionId)) {
      errors.push(`Campaign node ${node.id} references missing enemy faction ${node.enemyFactionId}.`);
    }
    if (!BATTLE_DIFFICULTIES.some((difficulty) => difficulty.id === node.difficulty)) {
      errors.push(`Campaign node ${node.id} references missing difficulty ${node.difficulty}.`);
    }
    if (node.aiPersonalityId && !context.aiPersonalityIds.has(node.aiPersonalityId)) {
      errors.push(`Campaign node ${node.id} references missing AI personality ${node.aiPersonalityId}.`);
    }
    node.prerequisites.forEach((nodeId) => {
      if (!context.campaignNodeIds.has(nodeId)) {
        errors.push(`Campaign node ${node.id} requires missing node ${nodeId}.`);
      }
    });
    node.unlocks.forEach((nodeId) => {
      if (!context.campaignNodeIds.has(nodeId)) {
        errors.push(`Campaign node ${node.id} unlocks missing node ${nodeId}.`);
      }
    });
    node.rewards.itemIds?.forEach((itemId) => {
      if (!context.itemIds.has(itemId)) {
        errors.push(`Campaign node ${node.id} rewards missing item ${itemId}.`);
      }
    });
    Object.entries(node.rewards.resources ?? {}).forEach(([resource, amount]) => {
      if (!context.resourceIds.has(resource)) {
        errors.push(`Campaign node ${node.id} rewards missing resource ${resource}.`);
      }
      if ((amount ?? 0) < 0) {
        errors.push(`Campaign node ${node.id} has negative ${resource} reward.`);
      }
    });
    if ((node.rewards.xp ?? 0) < 0) {
      errors.push(`Campaign node ${node.id} has negative XP reward.`);
    }
    assertUniqueIds(node.choices ?? [], `Campaign node ${node.id} choice`, errors);
    node.choices?.forEach((choice) => validateCampaignChoice(node.id, choice, errors, context));
  });
  if (!CAMPAIGN_NODES.some((node) => node.prerequisites.length === 0)) {
    errors.push("Campaign needs at least one starting node.");
  }
}

function validateAIPersonalities(errors: string[], context: ValidationContext): void {
  AI_PERSONALITIES.forEach((personality) => {
    if (!personality.name.trim() || !personality.shortDescription.trim() || !personality.description.trim()) {
      errors.push(`AI personality ${personality.id} needs name, shortDescription, and description.`);
    }
    if (personality.aggressionLevel < 0 || personality.aggressionLevel > 1) {
      errors.push(`AI personality ${personality.id} aggressionLevel must be between 0 and 1.`);
    }
    personality.preferredUnitIds.forEach((unitId) => {
      if (!context.unitIds.has(unitId)) {
        errors.push(`AI personality ${personality.id} prefers missing unit ${unitId}.`);
      }
    });
    personality.unitPlan.forEach((unitId) => {
      if (!context.unitIds.has(unitId)) {
        errors.push(`AI personality ${personality.id} trains missing unit ${unitId}.`);
      }
    });
    if (personality.unitPlan.length === 0) {
      errors.push(`AI personality ${personality.id} must include a unit plan.`);
    }
    Object.entries(personality.timing).forEach(([field, multiplier]) => {
      if (multiplier <= 0) {
        errors.push(`AI personality ${personality.id} has invalid timing multiplier ${field}.`);
      }
    });
    if (personality.economy.incomeMultiplier < 0) {
      errors.push(`AI personality ${personality.id} cannot have negative income multiplier.`);
    }
    if (personality.waves.attackWaveSizeMultiplier <= 0) {
      errors.push(`AI personality ${personality.id} has invalid attack wave multiplier.`);
    }
    Object.entries(personality.waves.phaseOverrides).forEach(([phaseId, override]) => {
      if (!["opening", "expansion", "pressure", "assault"].includes(phaseId)) {
        errors.push(`AI personality ${personality.id} has invalid phase override ${phaseId}.`);
      }
      override.allowedAttackUnitIds?.forEach((unitId) => {
        if (!context.unitIds.has(unitId)) {
          errors.push(`AI personality ${personality.id} phase ${phaseId} allows missing unit ${unitId}.`);
        }
      });
      override.preferredAttackUnitIds?.forEach((unitId) => {
        if (!context.unitIds.has(unitId)) {
          errors.push(`AI personality ${personality.id} phase ${phaseId} prefers missing unit ${unitId}.`);
        }
      });
      override.trainUnitIds?.forEach((unitId) => {
        if (!context.unitIds.has(unitId)) {
          errors.push(`AI personality ${personality.id} phase ${phaseId} trains missing unit ${unitId}.`);
        }
      });
      Object.keys(override.maxAttackByUnitId ?? {}).forEach((unitId) => {
        if (!context.unitIds.has(unitId)) {
          errors.push(`AI personality ${personality.id} phase ${phaseId} caps missing unit ${unitId}.`);
        }
      });
    });
    if (personality.defense.defendRadiusMultiplier <= 0 || personality.defense.reserveDefenseUnits < 0) {
      errors.push(`AI personality ${personality.id} has invalid defense tuning.`);
    }
  });
}

function validateCampaignModifiers(errors: string[], context: ValidationContext): void {
  CAMPAIGN_MODIFIERS.forEach((modifier) => {
    if (!modifier.name.trim() || !modifier.description.trim() || !modifier.durationLabel.trim()) {
      errors.push(`Campaign modifier ${modifier.id} needs name, description, and durationLabel.`);
    }
    if (!["next_battle", "next_ashen_battle", "next_node_resource_reward"].includes(modifier.trigger)) {
      errors.push(`Campaign modifier ${modifier.id} has invalid trigger ${modifier.trigger}.`);
    }
    [...(modifier.effects.extraPlayerUnitIds ?? []), ...(modifier.effects.extraEnemyUnitIds ?? [])].forEach((unitId) => {
      if (!context.unitIds.has(unitId)) {
        errors.push(`Campaign modifier ${modifier.id} references missing unit ${unitId}.`);
      }
    });
    if (modifier.effects.heroManaMultiplier !== undefined && modifier.effects.heroManaMultiplier <= 0) {
      errors.push(`Campaign modifier ${modifier.id} has invalid hero mana multiplier.`);
    }
    if (modifier.effects.heroMaxHpMultiplier !== undefined && modifier.effects.heroMaxHpMultiplier <= 0) {
      errors.push(`Campaign modifier ${modifier.id} has invalid hero HP multiplier.`);
    }
    if (modifier.effects.campaignResourceRewardMultiplier !== undefined && modifier.effects.campaignResourceRewardMultiplier <= 0) {
      errors.push(`Campaign modifier ${modifier.id} has invalid resource reward multiplier.`);
    }
  });
}

function validateCampaignChoice(
  nodeId: string,
  choice: {
    id: string;
    label: string;
    description: string;
    requirements?: {
      resources?: Partial<Record<string, number>>;
      heroLevel?: number;
      completedNodeIds?: string[];
      itemIds?: string[];
      factionReputation?: Record<string, number>;
    };
    costs?: Partial<Record<string, number>>;
    rewards?: {
      itemIds?: string[];
      resources?: Partial<Record<string, number>>;
      xp?: number;
      unlockNodeIds?: string[];
      lockNodeIds?: string[];
      modifierIds?: string[];
      removeModifierIds?: string[];
      reputationChanges?: Record<string, number>;
    };
    stockItemId?: string;
    reputationChanges?: Record<string, number>;
    unlockNodeIds?: string[];
    lockNodeIds?: string[];
    modifierIds?: string[];
    removeModifierIds?: string[];
  },
  errors: string[],
  context: ValidationContext
): void {
  if (!choice.id.trim() || !choice.label.trim() || !choice.description.trim()) {
    errors.push(`Campaign node ${nodeId} has a choice missing id, label, or description.`);
  }
  validateCampaignResourceBag(`Campaign choice ${nodeId}:${choice.id} cost`, choice.costs, errors, context);
  validateCampaignResourceBag(`Campaign choice ${nodeId}:${choice.id} resource requirement`, choice.requirements?.resources, errors, context);
  validateCampaignResourceBag(`Campaign choice ${nodeId}:${choice.id} reward`, choice.rewards?.resources, errors, context);
  if (choice.requirements?.heroLevel !== undefined && choice.requirements.heroLevel <= 0) {
    errors.push(`Campaign choice ${nodeId}:${choice.id} has invalid hero level requirement.`);
  }
  choice.requirements?.completedNodeIds?.forEach((requiredNodeId) => {
    if (!context.campaignNodeIds.has(requiredNodeId)) {
      errors.push(`Campaign choice ${nodeId}:${choice.id} requires missing node ${requiredNodeId}.`);
    }
  });
  choice.requirements?.itemIds?.forEach((itemId) => {
    if (!context.itemIds.has(itemId)) {
      errors.push(`Campaign choice ${nodeId}:${choice.id} requires missing item ${itemId}.`);
    }
  });
  Object.keys(choice.requirements?.factionReputation ?? {}).forEach((factionId) => {
    if (!context.factionIds.has(factionId)) {
      errors.push(`Campaign choice ${nodeId}:${choice.id} requires missing faction reputation ${factionId}.`);
    }
  });
  choice.rewards?.itemIds?.forEach((itemId) => {
    if (!context.itemIds.has(itemId)) {
      errors.push(`Campaign choice ${nodeId}:${choice.id} rewards missing item ${itemId}.`);
    }
  });
  if (choice.stockItemId && !context.itemIds.has(choice.stockItemId)) {
    errors.push(`Campaign choice ${nodeId}:${choice.id} stocks missing item ${choice.stockItemId}.`);
  }
  if ((choice.rewards?.xp ?? 0) < 0) {
    errors.push(`Campaign choice ${nodeId}:${choice.id} has negative XP reward.`);
  }
  [...(choice.unlockNodeIds ?? []), ...(choice.rewards?.unlockNodeIds ?? [])].forEach((unlockNodeId) => {
    if (!context.campaignNodeIds.has(unlockNodeId)) {
      errors.push(`Campaign choice ${nodeId}:${choice.id} unlocks missing node ${unlockNodeId}.`);
    }
  });
  [...(choice.lockNodeIds ?? []), ...(choice.rewards?.lockNodeIds ?? [])].forEach((lockNodeId) => {
    if (!context.campaignNodeIds.has(lockNodeId)) {
      errors.push(`Campaign choice ${nodeId}:${choice.id} locks missing node ${lockNodeId}.`);
    }
  });
  [...(choice.modifierIds ?? []), ...(choice.rewards?.modifierIds ?? [])].forEach((modifierId) => {
    if (!context.campaignModifierIds.has(modifierId)) {
      errors.push(`Campaign choice ${nodeId}:${choice.id} grants missing modifier ${modifierId}.`);
    }
  });
  [...(choice.removeModifierIds ?? []), ...(choice.rewards?.removeModifierIds ?? [])].forEach((modifierId) => {
    if (!context.campaignModifierIds.has(modifierId)) {
      errors.push(`Campaign choice ${nodeId}:${choice.id} removes missing modifier ${modifierId}.`);
    }
  });
  Object.keys({ ...(choice.reputationChanges ?? {}), ...(choice.rewards?.reputationChanges ?? {}) }).forEach((factionId) => {
    if (!context.factionIds.has(factionId)) {
      errors.push(`Campaign choice ${nodeId}:${choice.id} changes missing faction reputation ${factionId}.`);
    }
  });
}

function validateCampaignResourceBag(
  label: string,
  resources: Partial<Record<string, number>> | undefined,
  errors: string[],
  context: ValidationContext
): void {
  Object.entries(resources ?? {}).forEach(([resource, amount]) => {
    if (!context.resourceIds.has(resource)) {
      errors.push(`${label} references missing resource ${resource}.`);
    }
    if ((amount ?? 0) < 0) {
      errors.push(`${label} has negative ${resource}.`);
    }
  });
}

function validateItems(errors: string[], context: ValidationContext): void {
  ITEMS.forEach((item) => {
    if (!["weapon", "armor", "trinket", "relic"].includes(item.slot)) {
      errors.push(`Item ${item.id} has invalid equipment slot ${item.slot}.`);
    }
    if (!["common", "uncommon", "rare", "epic", "legendary"].includes(item.rarity)) {
      errors.push(`Item ${item.id} has invalid rarity ${item.rarity}.`);
    }
    if (item.unique !== undefined && typeof item.unique !== "boolean") {
      errors.push(`Item ${item.id} has invalid unique flag.`);
    }
    if (!item.name.trim() || !item.description.trim() || !item.flavorText.trim()) {
      errors.push(`Item ${item.id} needs name, description, and flavor text.`);
    }
    if (!Array.isArray(item.tags) || item.tags.length === 0) {
      errors.push(`Item ${item.id} should include at least one tag.`);
    }
    item.classAffinity?.forEach((classId) => {
      if (!context.heroClassIds.has(classId)) {
        errors.push(`Item ${item.id} references missing hero class affinity ${classId}.`);
      }
    });
    if (item.factionOrigin && !context.factionIds.has(item.factionOrigin)) {
      errors.push(`Item ${item.id} references missing faction origin ${item.factionOrigin}.`);
    }
    Object.entries(item.statMods).forEach(([stat, value]) => {
      if (value !== undefined && !Number.isFinite(value)) {
        errors.push(`Item ${item.id} has a non-finite ${stat} modifier.`);
      }
    });
  });
}

function idsFor(entries: Array<{ id: string }>, label: string, errors: string[]): Set<string> {
  const ids = new Set<string>();
  entries.forEach((entry) => {
    if (!entry.id.trim()) {
      errors.push(`A ${label} has an empty id.`);
      return;
    }
    if (ids.has(entry.id)) {
      errors.push(`Duplicate ${label} id: ${entry.id}`);
    }
    ids.add(entry.id);
  });
  return ids;
}

function validateUnits(errors: string[], context: ValidationContext): void {
  UNITS.forEach((unit) => {
    if (!context.factionIds.has(unit.factionId)) {
      errors.push(`Unit ${unit.id} references missing faction ${unit.factionId}.`);
    }
    if (unit.stats.maxHp <= 0) {
      errors.push(`Unit ${unit.id} must have positive max HP.`);
    }
    if (unit.stats.attackCooldown <= 0) {
      errors.push(`Unit ${unit.id} must have positive attack cooldown.`);
    }
    if (unit.trainTime < 0) {
      errors.push(`Unit ${unit.id} cannot have negative train time.`);
    }
    if (unit.radius <= 0) {
      errors.push(`Unit ${unit.id} must have a positive radius.`);
    }
    if (unit.visionRadius <= 0) {
      errors.push(`Unit ${unit.id} must have a positive vision radius.`);
    }
    validatePrerequisites(`Unit ${unit.id}`, unit.prerequisites, errors, context);
    validateCombatStats(`Unit ${unit.id}`, unit.stats, errors);
  });
}

function validateBuildings(errors: string[], context: ValidationContext): void {
  BUILDINGS.forEach((building) => {
    if (!context.factionIds.has(building.factionId)) {
      errors.push(`Building ${building.id} references missing faction ${building.factionId}.`);
    }
    if (building.maxHp <= 0) {
      errors.push(`Building ${building.id} must have positive max HP.`);
    }
    if (building.size.width <= 0 || building.size.height <= 0) {
      errors.push(`Building ${building.id} must have a positive footprint size.`);
    }
    if (building.visionRadius <= 0) {
      errors.push(`Building ${building.id} must have a positive vision radius.`);
    }
    if (building.constructionTimeSeconds < 0) {
      errors.push(`Building ${building.id} cannot have negative construction time.`);
    }
    building.buildOptions.forEach((id) => {
      if (!context.buildingIds.has(id)) {
        errors.push(`Building ${building.id} can build missing building ${id}.`);
      }
    });
    building.trainOptions.forEach((id) => {
      if (!context.unitIds.has(id)) {
        errors.push(`Building ${building.id} can train missing unit ${id}.`);
      }
    });
    building.upgradeOptions.forEach((id) => {
      if (!context.upgradeIds.has(id)) {
        errors.push(`Building ${building.id} can research missing upgrade ${id}.`);
      }
    });
    validatePrerequisites(`Building ${building.id}`, building.prerequisites, errors, context);
    if (building.attack) {
      if (building.attack.damage <= 0) {
        errors.push(`Building ${building.id} attack damage must be positive.`);
      }
      if (building.attack.range <= 0) {
        errors.push(`Building ${building.id} attack range must be positive.`);
      }
      if (building.attack.cooldown <= 0) {
        errors.push(`Building ${building.id} attack cooldown must be positive.`);
      }
    }
  });
}

function validateAbilities(errors: string[], context: ValidationContext): void {
  ABILITIES.forEach((ability) => {
    if (!context.heroClassIds.has(ability.heroClassId)) {
      errors.push(`Ability ${ability.id} references missing hero class ${ability.heroClassId}.`);
    }
    if (!ability.hotkey.trim()) {
      errors.push(`Ability ${ability.id} needs a hotkey.`);
    }
    if (ability.manaCost < 0) {
      errors.push(`Ability ${ability.id} cannot have a negative mana cost.`);
    }
    if (ability.cooldown < 0) {
      errors.push(`Ability ${ability.id} cannot have a negative cooldown.`);
    }
    if (ability.range < 0 || ability.radius < 0 || ability.duration < 0) {
      errors.push(`Ability ${ability.id} has a negative range, radius, or duration.`);
    }
    validatePrerequisites(`Ability ${ability.id}`, ability.prerequisites, errors, context);
  });
}

function validateHeroClasses(errors: string[], context: ValidationContext): void {
  HERO_CLASSES.forEach((heroClass) => {
    if (!context.abilityIds.has(heroClass.primaryAbilityId)) {
      errors.push(`Hero class ${heroClass.id} references missing primary ability ${heroClass.primaryAbilityId}.`);
    }
    heroClass.abilityIds.forEach((abilityId) => {
      if (!context.abilityIds.has(abilityId)) {
        errors.push(`Hero class ${heroClass.id} references missing ability ${abilityId}.`);
      }
    });
    if (!heroClass.abilityIds.includes(heroClass.primaryAbilityId)) {
      errors.push(`Hero class ${heroClass.id} must include its primary ability in abilityIds.`);
    }
    if (heroClass.visionRadius <= 0) {
      errors.push(`Hero class ${heroClass.id} must have a positive vision radius.`);
    }
    validateCombatStats(`Hero class ${heroClass.id}`, heroClass.baseStats, errors);
    if (heroClass.baseStats.maxMana < 0) {
      errors.push(`Hero class ${heroClass.id} cannot have negative max mana.`);
    }
  });
}

function validateOrigins(errors: string[]): void {
  ORIGINS.forEach((origin) => {
    Object.entries(origin.statMods).forEach(([stat, value]) => {
      if (value !== undefined && !Number.isFinite(value)) {
        errors.push(`Origin ${origin.id} has a non-finite ${stat} modifier.`);
      }
    });
  });
}

function validateResources(errors: string[]): void {
  RESOURCE_DEFINITIONS.forEach((resource) => {
    if (!resource.name.trim()) {
      errors.push(`Resource ${resource.id} needs a display name.`);
    }
  });
}

function validateFactions(errors: string[], context: ValidationContext): void {
  FACTIONS.forEach((faction) => {
    if (!faction.name.trim() || !faction.fantasy.trim()) {
      errors.push(`Faction ${faction.id} needs name and fantasy text.`);
    }
    if (!faction.mechanics) {
      errors.push(`Faction ${faction.id} needs mechanics.`);
      return;
    }
    if (!faction.mechanics.economyStyle.trim() || !faction.mechanics.militaryStyle.trim() || !faction.mechanics.magicStyle.trim()) {
      errors.push(`Faction ${faction.id} needs economy, military, and magic style text.`);
    }
    faction.mechanics.availableUnitIds.forEach((unitId) => {
      if (!context.unitIds.has(unitId)) {
        errors.push(`Faction ${faction.id} references missing available unit ${unitId}.`);
      }
    });
    faction.mechanics.availableBuildingIds.forEach((buildingId) => {
      if (!context.buildingIds.has(buildingId)) {
        errors.push(`Faction ${faction.id} references missing available building ${buildingId}.`);
      }
    });
    faction.mechanics.availableUpgradeIds.forEach((upgradeId) => {
      if (!context.upgradeIds.has(upgradeId)) {
        errors.push(`Faction ${faction.id} references missing available upgrade ${upgradeId}.`);
      }
    });
    faction.mechanics.aiPersonalityPreferences.forEach((personalityId) => {
      if (!context.aiPersonalityIds.has(personalityId)) {
        errors.push(`Faction ${faction.id} prefers missing AI personality ${personalityId}.`);
      }
    });
    faction.mechanics.campaignReputationHooks.forEach((factionId) => {
      if (!context.factionIds.has(factionId)) {
        errors.push(`Faction ${faction.id} references missing reputation hook ${factionId}.`);
      }
    });
    assertUniqueIds(faction.mechanics.factionModifiers, `Faction ${faction.id} modifier`, errors);
    faction.mechanics.factionModifiers.forEach((modifier) => {
      if (!modifier.name.trim() || !modifier.description.trim()) {
        errors.push(`Faction ${faction.id} modifier ${modifier.id} needs name and description.`);
      }
      if (!["burn-on-hit", "low-health-damage", "wave-speed"].includes(modifier.type)) {
        errors.push(`Faction ${faction.id} modifier ${modifier.id} has invalid type ${modifier.type}.`);
      }
      modifier.unitIds?.forEach((unitId) => {
        if (!context.unitIds.has(unitId)) {
          errors.push(`Faction ${faction.id} modifier ${modifier.id} references missing unit ${unitId}.`);
        }
      });
      if (modifier.type === "burn-on-hit") {
        if (!modifier.burn) {
          errors.push(`Faction ${faction.id} modifier ${modifier.id} needs burn tuning.`);
        } else {
          if (modifier.burn.damagePerSecond <= 0 || modifier.burn.durationSeconds <= 0 || modifier.burn.tickInterval <= 0) {
            errors.push(`Faction ${faction.id} modifier ${modifier.id} has invalid burn tuning.`);
          }
        }
      }
      if (modifier.type === "low-health-damage") {
        if ((modifier.hpThreshold ?? 0) <= 0 || (modifier.hpThreshold ?? 0) >= 1) {
          errors.push(`Faction ${faction.id} modifier ${modifier.id} has invalid HP threshold.`);
        }
        if ((modifier.damageMultiplier ?? 0) <= 0) {
          errors.push(`Faction ${faction.id} modifier ${modifier.id} has invalid damage multiplier.`);
        }
      }
      if (modifier.type === "wave-speed" && (modifier.speedMultiplier ?? 0) <= 0) {
        errors.push(`Faction ${faction.id} modifier ${modifier.id} has invalid speed multiplier.`);
      }
    });
  });
}

function validateSkillNodes(errors: string[], context: ValidationContext): void {
  SKILL_NODES.forEach((node) => {
    if (!context.skillTreeIds.has(node.treeId)) {
      errors.push(`Skill node ${node.id} references missing tree ${node.treeId}.`);
    }
    if (node.classId && !context.heroClassIds.has(node.classId)) {
      errors.push(`Skill node ${node.id} references missing hero class ${node.classId}.`);
    }
    if (node.unlockAbilityId && !context.abilityIds.has(node.unlockAbilityId)) {
      errors.push(`Skill node ${node.id} unlocks missing ability ${node.unlockAbilityId}.`);
    }
    if (node.maxRank <= 0) {
      errors.push(`Skill node ${node.id} must have a positive max rank.`);
    }
    if (node.costPerRank <= 0) {
      errors.push(`Skill node ${node.id} must have a positive cost per rank.`);
    }
    node.requires?.forEach((requirement) => {
      if (!context.skillNodeIds.has(requirement.skillId)) {
        errors.push(`Skill node ${node.id} requires missing skill ${requirement.skillId}.`);
      }
      if (requirement.rank <= 0) {
        errors.push(`Skill node ${node.id} has a requirement with non-positive rank.`);
      }
    });
  });
}

function validateRewardTables(errors: string[], context: ValidationContext): void {
  REWARD_TABLES.forEach((table) => {
    const guaranteedItemIds = table.guaranteedItemIds ?? [];
    const weightedItemPool = table.weightedItemPool ?? [];
    const resourceRewards = table.resourceRewards ?? [];
    const xpRewards = table.xpRewards ?? [];
    if (table.rolls < 0) {
      errors.push(`Reward table ${table.id} cannot have negative rolls.`);
    }
    if (guaranteedItemIds.length === 0 && weightedItemPool.length === 0) {
      errors.push(`Reward table ${table.id} must include guaranteed items or a weighted item pool.`);
    }
    guaranteedItemIds.forEach((itemId) => validateRewardItemReference(table.id, itemId, errors, context));
    table.deterministicItemIds?.forEach((itemId) => validateRewardItemReference(table.id, itemId, errors, context));
    weightedItemPool.forEach((entry) => {
      validateRewardItemReference(table.id, entry.itemId, errors, context);
      if (entry.weight <= 0) {
        errors.push(`Reward table ${table.id} has non-positive weight for ${entry.itemId}.`);
      }
      entry.mapIds?.forEach((mapId) => {
        if (!MAPS.some((map) => map.id === mapId)) {
          errors.push(`Reward table ${table.id} references missing map ${mapId}.`);
        }
      });
    });
    resourceRewards.forEach((entry) => {
      if (!context.resourceIds.has(entry.resource)) {
        errors.push(`Reward table ${table.id} gives missing resource ${entry.resource}.`);
      }
      if (entry.amount < 0) {
        errors.push(`Reward table ${table.id} has negative resource reward ${entry.resource}.`);
      }
    });
    xpRewards.forEach((entry) => {
      if (entry.amount < 0) {
        errors.push(`Reward table ${table.id} has negative XP reward.`);
      }
    });
    validateRewardBonus(table.id, "first-clear bonus", table.firstClearBonus, errors, context);
    validateRewardBonus(table.id, "repeat-clear reward", table.repeatClearReward, errors, context);
  });
}

function validateRewardItemReference(
  tableId: string,
  itemId: string,
  errors: string[],
  context: ValidationContext
): void {
  if (!context.itemIds.has(itemId)) {
    errors.push(`Reward table ${tableId} references missing item ${itemId}.`);
  }
}

function validateRewardBonus(
  tableId: string,
  label: string,
  bonus: { itemIds?: string[]; resources?: Partial<Record<string, number>>; xp?: number } | undefined,
  errors: string[],
  context: ValidationContext
): void {
  bonus?.itemIds?.forEach((itemId) => validateRewardItemReference(tableId, itemId, errors, context));
  Object.entries(bonus?.resources ?? {}).forEach(([resource, amount]) => {
    if (!context.resourceIds.has(resource)) {
      errors.push(`Reward table ${tableId} ${label} gives missing resource ${resource}.`);
    }
    if ((amount ?? 0) < 0) {
      errors.push(`Reward table ${tableId} ${label} has negative resource reward ${resource}.`);
    }
  });
  if ((bonus?.xp ?? 0) < 0) {
    errors.push(`Reward table ${tableId} ${label} has negative XP reward.`);
  }
}

function validateUpgrades(errors: string[], context: ValidationContext): void {
  UPGRADES.forEach((upgrade) => {
    if (!upgrade.name.trim()) {
      errors.push(`Upgrade ${upgrade.id} needs a display name.`);
    }
    if (upgrade.researchTimeSeconds < 0) {
      errors.push(`Upgrade ${upgrade.id} cannot have negative research time.`);
    }
    validatePrerequisites(`Upgrade ${upgrade.id}`, upgrade.prerequisites, errors, context);
    if (upgrade.effects.length === 0) {
      errors.push(`Upgrade ${upgrade.id} must include at least one effect.`);
    }
    upgrade.effects.forEach((effect) => {
      if (effect.type === "unit-stat-mod") {
        if (effect.unitIds.length === 0) {
          errors.push(`Upgrade ${upgrade.id} unit-stat-mod must target at least one unit.`);
        }
        effect.unitIds.forEach((unitId) => {
          if (!context.unitIds.has(unitId)) {
            errors.push(`Upgrade ${upgrade.id} targets missing unit ${unitId}.`);
          }
        });
        if (effect.damageMultiplier !== undefined && effect.damageMultiplier <= 0) {
          errors.push(`Upgrade ${upgrade.id} has invalid damage multiplier.`);
        }
        if (effect.rangeMultiplier !== undefined && effect.rangeMultiplier <= 0) {
          errors.push(`Upgrade ${upgrade.id} has invalid range multiplier.`);
        }
        if (effect.attackCooldownMultiplier !== undefined && effect.attackCooldownMultiplier <= 0) {
          errors.push(`Upgrade ${upgrade.id} has invalid attack cooldown multiplier.`);
        }
      }
      if (effect.type === "hero-mana-regen" && effect.multiplier <= 0) {
        errors.push(`Upgrade ${upgrade.id} has invalid hero mana regen multiplier.`);
      }
    });
  });
}

function validateDifficulties(errors: string[]): void {
  const knownSpawnIds = new Set(MAPS.flatMap((map) => map.scenario.unitSpawns.map((spawn) => spawn.id)));
  BATTLE_DIFFICULTIES.forEach((difficulty) => {
    if (difficulty.enemyIncomeMultiplier < 0) {
      errors.push(`Difficulty ${difficulty.id} cannot have a negative enemy income multiplier.`);
    }
    if (difficulty.firstAttackDelay < 0 || difficulty.attackInterval <= 0) {
      errors.push(`Difficulty ${difficulty.id} has invalid attack timing.`);
    }
    if (difficulty.attackWaveSize <= 0 || difficulty.minAttackArmySize <= 0) {
      errors.push(`Difficulty ${difficulty.id} has invalid wave sizing.`);
    }
    if (difficulty.expandInterval <= 0 || difficulty.trainInterval <= 0) {
      errors.push(`Difficulty ${difficulty.id} has invalid expansion or training timing.`);
    }
    difficulty.enemyStartingUnitSpawnIds.forEach((spawnId) => {
      if (!knownSpawnIds.has(spawnId)) {
        errors.push(`Difficulty ${difficulty.id} references missing enemy starting spawn ${spawnId}.`);
      }
    });
  });
}

function validateMap(map: BattleMapDefinition, errors: string[], context: ValidationContext): void {
  if (map.width <= 0 || map.height <= 0) {
    errors.push(`Map ${map.id} must have positive dimensions.`);
  }
  if (!map.name.trim() || !map.role.trim() || !map.description.trim()) {
    errors.push(`Map ${map.id} must include name, role, and description for setup UI.`);
  }
  if (map.strategicNotes.length === 0) {
    errors.push(`Map ${map.id} should include at least one strategic note.`);
  }
  if (map.visualPaths.length === 0) {
    errors.push(`Map ${map.id} should include at least one visual path.`);
  }
  assertUniqueIds(map.terrainZones, `Map ${map.id} terrain zone`, errors);
  assertUniqueIds(map.visualPaths, `Map ${map.id} visual path`, errors);
  assertUniqueIds(map.captureSites, `Map ${map.id} capture site`, errors);
  assertUniqueIds(map.neutralCamps, `Map ${map.id} neutral camp`, errors);
  assertUniqueIds(map.scenario.buildingSpawns, `Map ${map.id} building spawn`, errors);
  assertUniqueIds(map.scenario.unitSpawns, `Map ${map.id} unit spawn`, errors);

  validatePointInMap(map, map.playerStart, "player start", errors);
  validatePointInMap(map, map.enemyStart, "enemy start", errors);
  validatePointInMap(map, map.scenario.heroSpawn, "hero spawn", errors);

  map.terrainZones.forEach((zone) => {
    if (zone.width <= 0 || zone.height <= 0) {
      errors.push(`Map ${map.id} terrain zone ${zone.id} must have positive size.`);
    }
    if (zone.x < 0 || zone.y < 0 || zone.x + zone.width > map.width || zone.y + zone.height > map.height) {
      errors.push(`Map ${map.id} terrain zone ${zone.id} is outside map bounds.`);
    }
  });

  map.visualPaths.forEach((path) => {
    if (path.width <= 0) {
      errors.push(`Map ${map.id} visual path ${path.id} must have positive width.`);
    }
    if (path.points.length < 2) {
      errors.push(`Map ${map.id} visual path ${path.id} needs at least two points.`);
    }
    path.points.forEach((point, index) => validatePointInMap(map, point, `visual path ${path.id} point ${index}`, errors));
  });

  map.captureSites.forEach((site) => {
    if (!context.resourceIds.has(site.resource)) {
      errors.push(`Map ${map.id} capture site ${site.id} references missing resource ${site.resource}.`);
    }
    if (site.radius <= 0) {
      errors.push(`Map ${map.id} capture site ${site.id} must have a positive radius.`);
    }
    if (site.incomeAmount < 0 || site.incomeInterval <= 0) {
      errors.push(`Map ${map.id} capture site ${site.id} has invalid income settings.`);
    }
    validatePointInMap(map, site, `capture site ${site.id}`, errors);
  });

  map.scenario.buildingSpawns.forEach((spawn) => {
    if (!context.buildingIds.has(spawn.buildingId)) {
      errors.push(`Map ${map.id} spawns missing building ${spawn.buildingId}.`);
    }
    validatePointInMap(map, spawn, `building spawn ${spawn.id}`, errors);
  });
  map.scenario.unitSpawns.forEach((spawn) => {
    if (!context.unitIds.has(spawn.unitId)) {
      errors.push(`Map ${map.id} spawns missing unit ${spawn.unitId}.`);
    }
    validatePointInMap(map, spawn, `unit spawn ${spawn.id}`, errors);
  });
  map.neutralCamps.forEach((camp) => {
    validatePointInMap(map, camp, `neutral camp ${camp.id}`, errors);
    if (camp.unitIds.length === 0) {
      errors.push(`Map ${map.id} camp ${camp.id} must include at least one unit.`);
    }
    camp.unitIds.forEach((unitId) => {
      if (!context.unitIds.has(unitId)) {
        errors.push(`Map ${map.id} camp ${camp.id} references missing unit ${unitId}.`);
      }
    });
  });

  const scenario = map.scenario;
  (["player", "enemy"] as const).forEach((team) => {
    Object.entries(scenario.startingResources[team]).forEach(([resource, amount]) => {
      if (!context.resourceIds.has(resource)) {
        errors.push(`Map ${map.id} gives ${team} an unknown starting resource ${resource}.`);
      }
      if (amount < 0) {
        errors.push(`Map ${map.id} gives ${team} negative starting ${resource}.`);
      }
    });
  });
  [scenario.objectives.playerBaseBuildingId, scenario.objectives.enemyBaseBuildingId].forEach((buildingId) => {
    if (!context.buildingIds.has(buildingId)) {
      errors.push(`Map ${map.id} objective references missing building ${buildingId}.`);
    }
  });
  assertUniqueIds(scenario.objectives.secondaryObjectives ?? [], `Map ${map.id} secondary objective`, errors);
  scenario.objectives.secondaryObjectives?.forEach((objective) => {
    if (!objective.name.trim() || !objective.description.trim()) {
      errors.push(`Map ${map.id} secondary objective ${objective.id} needs name and description.`);
    }
    if (!["capture_site", "destroy_building", "defeat_unit"].includes(objective.type)) {
      errors.push(`Map ${map.id} secondary objective ${objective.id} has invalid type ${objective.type}.`);
    }
    if (objective.type === "capture_site" && !map.captureSites.some((site) => site.id === objective.targetId)) {
      errors.push(`Map ${map.id} secondary objective ${objective.id} references missing capture site ${objective.targetId}.`);
    }
    if (objective.type === "destroy_building" && !context.buildingIds.has(objective.targetId)) {
      errors.push(`Map ${map.id} secondary objective ${objective.id} references missing building ${objective.targetId}.`);
    }
    if (
      objective.type === "destroy_building" &&
      context.buildingIds.has(objective.targetId) &&
      !map.scenario.buildingSpawns.some((spawn) => spawn.buildingId === objective.targetId)
    ) {
      errors.push(`Map ${map.id} secondary objective ${objective.id} targets a building not spawned on this map.`);
    }
    if (objective.type === "defeat_unit" && !context.unitIds.has(objective.targetId)) {
      errors.push(`Map ${map.id} secondary objective ${objective.id} references missing unit ${objective.targetId}.`);
    }
    if (
      objective.type === "defeat_unit" &&
      context.unitIds.has(objective.targetId) &&
      !map.scenario.unitSpawns.some((spawn) => spawn.unitId === objective.targetId)
    ) {
      errors.push(`Map ${map.id} secondary objective ${objective.id} targets a unit not spawned on this map.`);
    }
  });
  scenario.enemyAI.unitPlan.forEach((unitId) => {
    if (!context.unitIds.has(unitId)) {
      errors.push(`Map ${map.id} AI plan references missing unit ${unitId}.`);
    }
  });
  if (scenario.enemyAI.unitPlan.length === 0) {
    errors.push(`Map ${map.id} AI unit plan must include at least one unit.`);
  }
  [scenario.enemyAI.baseBuildingId, scenario.enemyAI.productionBuildingId, scenario.enemyAI.attackTargetBuildingId].forEach(
    (buildingId) => {
      if (!context.buildingIds.has(buildingId)) {
        errors.push(`Map ${map.id} AI references missing building ${buildingId}.`);
      }
    }
  );
  if (!context.rewardTableIds.has(scenario.rewardTableId)) {
    errors.push(`Map ${map.id} references missing reward table ${scenario.rewardTableId}.`);
  }
}

function validateCombatStats(label: string, stats: { maxHp: number; damage: number; range: number; attackCooldown: number; speed: number }): void;
function validateCombatStats(
  label: string,
  stats: { maxHp: number; damage: number; range: number; attackCooldown: number; speed: number },
  errors: string[]
): void;
function validateCombatStats(
  label: string,
  stats: { maxHp: number; damage: number; range: number; attackCooldown: number; speed: number },
  errors: string[] = []
): void {
  Object.entries(stats).forEach(([stat, value]) => {
    if (!Number.isFinite(value)) {
      errors.push(`${label} has non-finite ${stat}.`);
    }
  });
  if (stats.damage < 0) {
    errors.push(`${label} cannot have negative damage.`);
  }
  if (stats.range < 0) {
    errors.push(`${label} cannot have negative range.`);
  }
  if (stats.speed < 0) {
    errors.push(`${label} cannot have negative speed.`);
  }
}

function validatePrerequisites(
  label: string,
  prerequisites: { buildingIds?: string[]; upgradeIds?: string[]; heroLevel?: number } | undefined,
  errors: string[],
  context: ValidationContext
): void {
  prerequisites?.buildingIds?.forEach((buildingId) => {
    if (!context.buildingIds.has(buildingId)) {
      errors.push(`${label} requires missing building ${buildingId}.`);
    }
  });
  prerequisites?.upgradeIds?.forEach((upgradeId) => {
    if (!context.upgradeIds.has(upgradeId)) {
      errors.push(`${label} requires missing upgrade ${upgradeId}.`);
    }
  });
  if (prerequisites?.heroLevel !== undefined && prerequisites.heroLevel <= 0) {
    errors.push(`${label} has an invalid hero level prerequisite.`);
  }
}

function assertUniqueIds(entries: Array<{ id: string }>, label: string, errors: string[]): void {
  const ids = new Set<string>();
  entries.forEach((entry) => {
    if (!entry.id.trim()) {
      errors.push(`${label} has an empty id.`);
    }
    if (ids.has(entry.id)) {
      errors.push(`Duplicate ${label} id: ${entry.id}`);
    }
    ids.add(entry.id);
  });
}

function validatePointInMap(
  map: BattleMapDefinition,
  point: { x: number; y: number },
  label: string,
  errors: string[]
): void {
  if (!Number.isFinite(point.x) || !Number.isFinite(point.y)) {
    errors.push(`Map ${map.id} ${label} has a non-finite position.`);
    return;
  }
  if (point.x < 0 || point.y < 0 || point.x > map.width || point.y > map.height) {
    errors.push(`Map ${map.id} ${label} is outside map bounds.`);
  }
}
