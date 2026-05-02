import { BATTLE_DIFFICULTIES } from "../battlePacing";
import { CAMPAIGN_NODES } from "../campaignNodes";
import { CAMPAIGN_MODIFIERS } from "../campaignModifiers";
import { MAPS } from "../maps";
import { REPUTATION_EFFECTS, TRACKED_REPUTATION_FACTION_IDS } from "../reputation";
import { assertUniqueIds, type ValidationContext } from "./ValidationTypes";

export function validateCampaignNodes(errors: string[], context: ValidationContext): void {
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
    if (node.enemyHeroId && !context.enemyHeroIds.has(node.enemyHeroId)) {
      errors.push(`Campaign node ${node.id} references missing enemy hero ${node.enemyHeroId}.`);
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

export function validateCampaignModifiers(errors: string[], context: ValidationContext): void {
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

export function validateReputationEffects(errors: string[], context: ValidationContext): void {
  TRACKED_REPUTATION_FACTION_IDS.forEach((factionId) => {
    if (!context.factionIds.has(factionId)) {
      errors.push(`Tracked reputation faction ${factionId} is missing from factions.`);
    }
  });
  REPUTATION_EFFECTS.forEach((reputationEffect) => {
    if (!context.factionIds.has(reputationEffect.factionId)) {
      errors.push(`Reputation effect ${reputationEffect.id} references missing faction ${reputationEffect.factionId}.`);
    }
    if (!["friendly", "hostile"].includes(reputationEffect.requiredRank)) {
      errors.push(`Reputation effect ${reputationEffect.id} has invalid required rank ${reputationEffect.requiredRank}.`);
    }
    reputationEffect.effects.forEach((effect) => {
      if (effect.type === "town-choice-cost-multiplier" && (effect.multiplier <= 0 || effect.multiplier >= 1)) {
        errors.push(`Reputation effect ${reputationEffect.id} has invalid town choice discount.`);
      }
      if (effect.type === "stronghold-crown-cost-multiplier" && (effect.multiplier <= 0 || effect.multiplier >= 1)) {
        errors.push(`Reputation effect ${reputationEffect.id} has invalid Stronghold Crown discount.`);
      }
      if (effect.type === "chapel-aether-bonus" && effect.amount <= 0) {
        errors.push(`Reputation effect ${reputationEffect.id} has invalid Chapel Aether bonus.`);
      }
      if (effect.type === "ashen-hostile-pressure" && !context.campaignModifierIds.has(effect.modifierId)) {
        errors.push(`Reputation effect ${reputationEffect.id} references missing campaign modifier ${effect.modifierId}.`);
      }
      if ("nodeIds" in effect) {
        effect.nodeIds.forEach((nodeId) => {
          if (!context.campaignNodeIds.has(nodeId)) {
            errors.push(`Reputation effect ${reputationEffect.id} references missing campaign node ${nodeId}.`);
          }
        });
      }
    });
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
