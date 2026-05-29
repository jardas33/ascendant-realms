import { BATTLE_DIFFICULTIES } from "../battlePacing";
import { CAMPAIGN_CHAPTERS } from "../campaignChapters";
import { CAMPAIGN_NODES } from "../campaignNodes";
import { CAMPAIGN_MODIFIERS } from "../campaignModifiers";
import { CAMPAIGN_MISSION_TYPES } from "../missionTypes";
import { ENEMY_PRESSURE_PLANS } from "../enemyPressurePlans";
import { MAPS } from "../maps";
import { REPUTATION_EFFECTS, TRACKED_REPUTATION_FACTION_IDS } from "../reputation";
import type { CampaignNodeChoiceDefinition, CampaignNodeDefinition } from "../../core/GameTypes";
import { assertUniqueIds, type ValidationContext } from "./ValidationTypes";

export function validateCampaignNodes(errors: string[], context: ValidationContext): void {
  CAMPAIGN_NODES.forEach((node) => {
    if (!["battle", "shrine", "town", "ruin", "fortress", "event"].includes(node.nodeType)) {
      errors.push(`Campaign node ${node.id} has invalid node type ${node.nodeType}.`);
    }
    if (!node.name.trim() || !node.description.trim()) {
      errors.push(`Campaign node ${node.id} needs name and description.`);
    }
    validateCampaignNodeMissionMetadata(node, errors, context);
    if (!node.chapterId) {
      errors.push(`Campaign node ${node.id} needs a campaign chapter.`);
    } else if (!context.campaignChapterIds.has(node.chapterId)) {
      errors.push(`Campaign node ${node.id} references missing chapter ${node.chapterId}.`);
    }
    const referencedMap = MAPS.find((map) => map.id === node.mapId);
    if (!referencedMap && !node.isPlaceholder) {
      errors.push(`Campaign node ${node.id} references missing map ${node.mapId}.`);
    }
    if (node.nodeType === "battle" && referencedMap && !context.rewardTableIds.has(referencedMap.scenario.rewardTableId)) {
      errors.push(
        `Campaign battle node ${node.id} uses map ${referencedMap.id} with missing reward table ${referencedMap.scenario.rewardTableId}.`
      );
    }
    if (node.isPlaceholder && (!node.placeholderLabel?.trim() || !node.placeholderDescription?.trim())) {
      errors.push(`Campaign node ${node.id} is a placeholder without placeholder copy.`);
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
    if (node.enemyPressurePlanId) {
      if (node.nodeType !== "battle") {
        errors.push(`Campaign node ${node.id} uses enemy pressure plan ${node.enemyPressurePlanId} outside a battle node.`);
      }
      if (!context.enemyPressurePlanIds.has(node.enemyPressurePlanId)) {
        errors.push(`Campaign node ${node.id} references missing enemy pressure plan ${node.enemyPressurePlanId}.`);
      } else {
        const plan = ENEMY_PRESSURE_PLANS.find((entry) => entry.id === node.enemyPressurePlanId);
        if (plan && (!plan.allowedNodeIds.includes(node.id) || !plan.allowedMapIds.includes(node.mapId))) {
          errors.push(`Campaign node ${node.id} uses enemy pressure plan ${node.enemyPressurePlanId} outside its allowed nodes or maps.`);
        }
      }
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
    node.choices?.forEach((choice) => validateCampaignChoice(node, choice, errors, context));
  });
  if (!CAMPAIGN_NODES.some((node) => node.prerequisites.length === 0)) {
    errors.push("Campaign needs at least one starting node.");
  }
  validateCampaignGraph(errors);
}

function validateCampaignNodeMissionMetadata(
  node: CampaignNodeDefinition,
  errors: string[],
  context: ValidationContext
): void {
  if (node.nodeType !== "battle" && node.scenarioModifierIds?.length) {
    errors.push(`Campaign node ${node.id} declares scenario modifiers outside a battle node.`);
  }
  if (node.missionTypeId && !context.campaignMissionTypeIds.has(node.missionTypeId)) {
    errors.push(`Campaign node ${node.id} references missing mission type ${node.missionTypeId}.`);
  }
  if (node.nodeType === "battle" && !node.isPlaceholder && !node.missionTypeId) {
    errors.push(`Campaign battle node ${node.id} needs a mission type.`);
  }
  if (node.nodeType === "battle" && !node.isPlaceholder && !node.missionBriefing) {
    errors.push(`Campaign battle node ${node.id} needs mission briefing copy.`);
  }
  const briefing = node.missionBriefing;
  if (briefing) {
    if (
      !briefing.summary.trim() ||
      !briefing.primaryObjective.trim() ||
      !briefing.rewardPreview.trim() ||
      !briefing.afterActionSummary.trim()
    ) {
      errors.push(`Campaign node ${node.id} has incomplete mission briefing copy.`);
    }
  }
  const seenScenarioModifiers = new Set<string>();
  (node.scenarioModifierIds ?? []).forEach((modifierId) => {
    if (seenScenarioModifiers.has(modifierId)) {
      errors.push(`Campaign node ${node.id} lists scenario modifier ${modifierId} more than once.`);
    }
    seenScenarioModifiers.add(modifierId);
    if (!context.campaignModifierIds.has(modifierId)) {
      errors.push(`Campaign node ${node.id} references missing scenario modifier ${modifierId}.`);
      return;
    }
    const modifier = CAMPAIGN_MODIFIERS.find((entry) => entry.id === modifierId);
    if (modifier?.trigger !== "mission_battle") {
      errors.push(`Campaign node ${node.id} uses non-mission modifier ${modifierId} as a scenario modifier.`);
    }
  });
}

export function validateCampaignChapters(errors: string[], context: ValidationContext): void {
  CAMPAIGN_CHAPTERS.forEach((chapter) => {
    if (!chapter.title.trim() || !chapter.shortDescription.trim()) {
      errors.push(`Campaign chapter ${chapter.id} needs title and short description.`);
    }
    validateUniqueChapterNodeList(chapter.id, "node", chapter.nodeIds, errors);
    validateUniqueChapterNodeList(chapter.id, "unlock prerequisite", chapter.unlockPrerequisiteNodeIds, errors);
    chapter.nodeIds.forEach((nodeId) => {
      if (!context.campaignNodeIds.has(nodeId)) {
        errors.push(`Campaign chapter ${chapter.id} references missing node ${nodeId}.`);
      } else {
        const node = CAMPAIGN_NODES.find((entry) => entry.id === nodeId);
        if (node?.chapterId !== chapter.id) {
          errors.push(`Campaign chapter ${chapter.id} lists node ${nodeId} from chapter ${node?.chapterId ?? "unknown"}.`);
        }
      }
    });
    chapter.unlockPrerequisiteNodeIds.forEach((nodeId) => {
      if (!context.campaignNodeIds.has(nodeId)) {
        errors.push(`Campaign chapter ${chapter.id} requires missing node ${nodeId}.`);
      }
    });
    const chapterNodes = CAMPAIGN_NODES.filter((node) => node.chapterId === chapter.id).map((node) => node.id);
    chapterNodes.forEach((nodeId) => {
      if (!chapter.nodeIds.includes(nodeId)) {
        errors.push(`Campaign chapter ${chapter.id} omits node ${nodeId}.`);
      }
    });
  });
  if (!CAMPAIGN_CHAPTERS.some((chapter) => chapter.unlockPrerequisiteNodeIds.length === 0 && !chapter.isUpcoming)) {
    errors.push("Campaign needs at least one unlocked current chapter.");
  }
}

export function validateCampaignMissionTypes(errors: string[], context: ValidationContext): void {
  CAMPAIGN_MISSION_TYPES.forEach((missionType) => {
    if (!missionType.name.trim() || !missionType.shortDescription.trim() || !missionType.objectiveHint.trim()) {
      errors.push(`Campaign mission type ${missionType.id} needs name, description, and objective hint.`);
    }
    if (missionType.recommendedBuildTags.length === 0) {
      errors.push(`Campaign mission type ${missionType.id} needs at least one recommended build tag.`);
    }
    if (!context.campaignMissionTypeIds.has(missionType.id)) {
      errors.push(`Campaign mission type ${missionType.id} is missing from validation context.`);
    }
  });
}

export function validateCampaignModifiers(errors: string[], context: ValidationContext): void {
  CAMPAIGN_MODIFIERS.forEach((modifier) => {
    if (!modifier.name.trim() || !modifier.description.trim() || !modifier.durationLabel.trim()) {
      errors.push(`Campaign modifier ${modifier.id} needs name, description, and durationLabel.`);
    }
    if (
      !["next_battle", "next_ashen_battle", "next_cinderfen_battle", "next_node_resource_reward", "mission_battle"].includes(
        modifier.trigger
      )
    ) {
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
    if (
      modifier.effects.captureSiteIncomeMultiplier !== undefined &&
      (modifier.effects.captureSiteIncomeMultiplier < 0.8 || modifier.effects.captureSiteIncomeMultiplier > 1.25)
    ) {
      errors.push(`Campaign modifier ${modifier.id} has invalid capture site income multiplier.`);
    }
    if (
      modifier.effects.enemyAttackIntervalMultiplier !== undefined &&
      (modifier.effects.enemyAttackIntervalMultiplier < 0.85 || modifier.effects.enemyAttackIntervalMultiplier > 1.15)
    ) {
      errors.push(`Campaign modifier ${modifier.id} has invalid enemy attack interval multiplier.`);
    }
    if (
      modifier.effects.enemyInitialAttackDelayMultiplier !== undefined &&
      (modifier.effects.enemyInitialAttackDelayMultiplier < 0.85 || modifier.effects.enemyInitialAttackDelayMultiplier > 1.2)
    ) {
      errors.push(`Campaign modifier ${modifier.id} has invalid enemy initial attack delay multiplier.`);
    }
    if (
      modifier.effects.enemyDefenseSquadSizeBonus !== undefined &&
      (!Number.isInteger(modifier.effects.enemyDefenseSquadSizeBonus) ||
        modifier.effects.enemyDefenseSquadSizeBonus < 0 ||
        modifier.effects.enemyDefenseSquadSizeBonus > 2)
    ) {
      errors.push(`Campaign modifier ${modifier.id} has invalid enemy defense squad size bonus.`);
    }
    validateCampaignModifierCaptureBonuses(modifier, errors, context);
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
  node: CampaignNodeDefinition,
  choice: CampaignNodeChoiceDefinition,
  errors: string[],
  context: ValidationContext
): void {
  const nodeId = node.id;
  if (!choice.id.trim() || !choice.label.trim() || !choice.description.trim()) {
    errors.push(`Campaign node ${nodeId} has a choice missing id, label, or description.`);
  }
  validateCampaignResourceBag(`Campaign choice ${nodeId}:${choice.id} cost`, choice.costs, errors, context);
  validateCampaignResourceBag(`Campaign choice ${nodeId}:${choice.id} resource requirement`, choice.requirements?.resources, errors, context);
  validateCampaignResourceBag(`Campaign choice ${nodeId}:${choice.id} reward`, choice.rewards?.resources, errors, context);
  if (Object.keys(choice.costs ?? {}).length > 0 && !campaignChoiceHasVisibleEffect(choice)) {
    errors.push(`Campaign choice ${nodeId}:${choice.id} has a cost but no visible saved effect.`);
  }
  if (node.nodeType !== "town" && choice.completesNode === false && !campaignChoiceHasNodeFlowEffect(choice)) {
    errors.push(`Campaign choice ${nodeId}:${choice.id} does not complete the node and has no unlock or lock effect.`);
  }
  validateOneTimeTownItemService(node, choice, errors);
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
  choice.requirements?.rivalTrophyIds?.forEach((trophyId) => {
    if (!context.rivalTrophyIds.has(trophyId)) {
      errors.push(`Campaign choice ${nodeId}:${choice.id} requires missing rival trophy ${trophyId}.`);
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

function validateUniqueChapterNodeList(chapterId: string, label: string, nodeIds: string[], errors: string[]): void {
  const seen = new Set<string>();
  nodeIds.forEach((nodeId) => {
    if (seen.has(nodeId)) {
      errors.push(`Campaign chapter ${chapterId} lists ${label} ${nodeId} more than once.`);
    }
    seen.add(nodeId);
  });
}

function validateCampaignGraph(errors: string[]): void {
  const nodeById = new Map(CAMPAIGN_NODES.map((node) => [node.id, node]));
  const nodeIdsRequiredByOtherNodes = new Set<string>();
  const chapterUnlockPrerequisiteNodeIds = new Set<string>();

  CAMPAIGN_NODES.forEach((node) => {
    node.prerequisites.forEach((nodeId) => nodeIdsRequiredByOtherNodes.add(nodeId));
  });
  CAMPAIGN_CHAPTERS.forEach((chapter) => {
    chapter.unlockPrerequisiteNodeIds.forEach((nodeId) => chapterUnlockPrerequisiteNodeIds.add(nodeId));
  });

  CAMPAIGN_CHAPTERS.filter((chapter) => !chapter.isUpcoming).forEach((chapter) => {
    const chapterNodeIds = new Set(chapter.nodeIds);
    const reachable = new Set<string>();
    let changed = true;

    while (changed) {
      changed = false;
      chapter.nodeIds.forEach((nodeId) => {
        const node = nodeById.get(nodeId);
        if (!node || reachable.has(nodeId)) {
          return;
        }
        const prerequisitesReachable = node.prerequisites.every((prerequisiteId) =>
          chapterNodeIds.has(prerequisiteId) ? reachable.has(prerequisiteId) : chapter.unlockPrerequisiteNodeIds.includes(prerequisiteId)
        );
        if (prerequisitesReachable) {
          reachable.add(nodeId);
          changed = true;
        }
      });
    }

    if (chapter.nodeIds.length > 0 && reachable.size === 0) {
      errors.push(`Campaign chapter ${chapter.id} has no reachable entry node.`);
    }
    chapter.nodeIds.forEach((nodeId) => {
      if (nodeById.has(nodeId) && !reachable.has(nodeId)) {
        errors.push(`Campaign chapter ${chapter.id} cannot reach node ${nodeId} from its chapter entry/prerequisite graph.`);
      }
    });
  });

  CAMPAIGN_NODES.forEach((node) => {
    const hasContinuation =
      node.unlocks.length > 0 || nodeIdsRequiredByOtherNodes.has(node.id) || chapterUnlockPrerequisiteNodeIds.has(node.id);
    if (node.nodeType === "battle" && !node.isPlaceholder && !hasContinuation) {
      errors.push(`Campaign battle node ${node.id} has no unlock, prerequisite dependent, or chapter continuation.`);
    }
  });
}

function validateCampaignModifierCaptureBonuses(
  modifier: (typeof CAMPAIGN_MODIFIERS)[number],
  errors: string[],
  context: ValidationContext
): void {
  const additions = modifier.effects.firstCaptureBonusResourceAdditions ?? {};
  if (Object.keys(additions).length === 0) {
    return;
  }
  const cinderfenBattleMapIds = new Set(
    CAMPAIGN_NODES.filter((node) => node.nodeType === "battle" && node.chapterId === "cinderfen_road").map((node) => node.mapId)
  );

  Object.entries(additions).forEach(([captureSiteId, resources]) => {
    const mapsWithSite = MAPS.filter((map) => map.captureSites.some((site) => site.id === captureSiteId));
    if (mapsWithSite.length === 0) {
      errors.push(`Campaign modifier ${modifier.id} targets missing capture site ${captureSiteId}.`);
    }
    if (modifier.trigger === "next_cinderfen_battle") {
      const nonCinderfenMaps = mapsWithSite.filter((map) => !cinderfenBattleMapIds.has(map.id));
      if (nonCinderfenMaps.length > 0) {
        errors.push(
          `Campaign modifier ${modifier.id} targets non-Cinderfen capture site ${captureSiteId} on ${nonCinderfenMaps
            .map((map) => map.id)
            .join(", ")}.`
        );
      }
    }
    Object.entries(resources).forEach(([resource, amount]) => {
      if (!context.resourceIds.has(resource)) {
        errors.push(`Campaign modifier ${modifier.id} capture bonus ${captureSiteId} references missing resource ${resource}.`);
      }
      if ((amount ?? 0) <= 0) {
        errors.push(`Campaign modifier ${modifier.id} capture bonus ${captureSiteId} must grant positive ${resource}.`);
      }
    });
  });
}

function campaignChoiceHasVisibleEffect(choice: Parameters<typeof validateCampaignChoice>[1]): boolean {
  const rewards = choice.rewards;
  return Boolean(
    choice.completesNode ||
      choice.stockItemId ||
      (rewards?.xp ?? 0) > 0 ||
      hasNonZeroRecord(rewards?.resources) ||
      (rewards?.itemIds?.length ?? 0) > 0 ||
      (rewards?.unlockNodeIds?.length ?? 0) > 0 ||
      (rewards?.lockNodeIds?.length ?? 0) > 0 ||
      (rewards?.modifierIds?.length ?? 0) > 0 ||
      (rewards?.removeModifierIds?.length ?? 0) > 0 ||
      hasNonZeroRecord(rewards?.reputationChanges) ||
      rewards?.recoverHero === true ||
      (choice.unlockNodeIds?.length ?? 0) > 0 ||
      (choice.lockNodeIds?.length ?? 0) > 0 ||
      (choice.modifierIds?.length ?? 0) > 0 ||
      (choice.removeModifierIds?.length ?? 0) > 0 ||
      hasNonZeroRecord(choice.reputationChanges)
  );
}

function campaignChoiceHasNodeFlowEffect(choice: CampaignNodeChoiceDefinition): boolean {
  return Boolean(
    (choice.unlockNodeIds?.length ?? 0) > 0 ||
      (choice.lockNodeIds?.length ?? 0) > 0 ||
      (choice.rewards?.unlockNodeIds?.length ?? 0) > 0 ||
      (choice.rewards?.lockNodeIds?.length ?? 0) > 0
  );
}

function validateOneTimeTownItemService(
  node: CampaignNodeDefinition,
  choice: CampaignNodeChoiceDefinition,
  errors: string[]
): void {
  const itemIds = choice.rewards?.itemIds ?? [];
  if (node.nodeType !== "town" || !choice.onceOnly || itemIds.length === 0) {
    return;
  }
  if (!choice.stockItemId) {
    errors.push(`Campaign town choice ${node.id}:${choice.id} grants one-time items without a stockItemId duplicate guard.`);
    return;
  }
  if (!itemIds.includes(choice.stockItemId)) {
    errors.push(`Campaign town choice ${node.id}:${choice.id} stock item ${choice.stockItemId} is not in its item rewards.`);
  }
}

function hasNonZeroRecord(record: Partial<Record<string, number>> | undefined): boolean {
  return Object.values(record ?? {}).some((amount) => (amount ?? 0) !== 0);
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
