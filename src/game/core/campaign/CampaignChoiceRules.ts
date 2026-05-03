import type {
  BattleRewardResult,
  CampaignModifierId,
  CampaignNodeChoiceDefinition,
  CampaignNodeDefinition,
  ResourceBag,
  RewardLevelUpSummary
} from "../GameTypes";
import { grantBattleRewards, heroOwnsCatalogItem } from "../HeroProgressionRules";
import { CAMPAIGN_NODES } from "../../data/campaignNodes";
import { ITEM_BY_ID } from "../../data/contentIndex";
import { applyCampaignResourceRewardModifiers, grantCampaignModifiers, removeCampaignModifiers } from "../../data/campaignModifiers";
import { getAdjustedCampaignChoiceCost, getAdjustedCampaignChoiceRewards } from "../../data/reputation";
import { RIVAL_REWARDS } from "../../data/rivalRewards";
import type { CampaignSaveData, HeroSaveData } from "../../save/SaveTypes";
import { hasRivalTrophy } from "../RivalRules";
import { completeCampaignNode, getCampaignNodeStatus, refreshCampaignUnlocks } from "./CampaignNodeRules";
import {
  addCampaignResources,
  additionalRewardResources,
  recordCampaignResourceSpending,
  subtractCampaignResources
} from "./CampaignRewardRules";
import { applyReputationChanges } from "./CampaignReputationRules";
import { isCampaignChoiceClaimed, recordTownServiceUse } from "./CampaignTownRules";

export interface CampaignChoiceAvailability {
  ok: boolean;
  reasons: string[];
}

export interface CampaignChoiceResult {
  ok: boolean;
  reason?: string;
  campaign: CampaignSaveData;
  hero: HeroSaveData;
  reward: BattleRewardResult;
  levelUp: RewardLevelUpSummary;
  unlockedNodeIds: string[];
  lockedNodeIds: string[];
  grantedModifierIds: CampaignModifierId[];
  removedModifierIds: string[];
  completedNode: boolean;
}

export function getCampaignChoiceAvailability(options: {
  campaign: CampaignSaveData;
  hero: HeroSaveData;
  node: CampaignNodeDefinition;
  choice: CampaignNodeChoiceDefinition;
  nodes?: CampaignNodeDefinition[];
}): CampaignChoiceAvailability {
  const nodes = options.nodes ?? CAMPAIGN_NODES;
  const reasons: string[] = [];
  const status = getCampaignNodeStatus(options.node, options.campaign);
  if (status === "locked") {
    reasons.push("Node is locked");
  }
  if (status === "completed") {
    reasons.push("Node completed");
  }
  if (options.choice.onceOnly && isCampaignChoiceClaimed(options.campaign, options.node, options.choice)) {
    reasons.push(options.node.nodeType === "town" ? "Already purchased" : "Already chosen");
  }
  if (options.choice.stockItemId && heroOwnsCatalogItem(options.hero, options.choice.stockItemId)) {
    reasons.push("Already owned");
  }

  const adjustedChoiceCost = getAdjustedCampaignChoiceCost({
    hero: options.hero,
    node: options.node,
    choice: options.choice
  });
  Object.entries(adjustedChoiceCost).forEach(([resource, amount]) => {
    const current = options.campaign.resources[resource as keyof ResourceBag] ?? 0;
    if ((amount ?? 0) > current) {
      reasons.push(`Need ${amount} ${titleCase(resource)}`);
    }
  });

  Object.entries(options.choice.requirements?.resources ?? {}).forEach(([resource, amount]) => {
    const current = options.campaign.resources[resource as keyof ResourceBag] ?? 0;
    if ((amount ?? 0) > current) {
      reasons.push(`Need ${amount} ${titleCase(resource)}`);
    }
  });
  if (options.choice.requirements?.heroLevel && options.hero.level < options.choice.requirements.heroLevel) {
    reasons.push(`Requires hero level ${options.choice.requirements.heroLevel}`);
  }
  options.choice.requirements?.completedNodeIds?.forEach((nodeId) => {
    if (!options.campaign.completedNodeIds.includes(nodeId)) {
      reasons.push(`Requires ${nodeName(nodeId, nodes)}`);
    }
  });
  options.choice.requirements?.itemIds?.forEach((itemId) => {
    if (!heroOwnsCatalogItem(options.hero, itemId)) {
      reasons.push(`Requires item ${itemId}`);
    }
  });
  options.choice.requirements?.rivalTrophyIds?.forEach((trophyId) => {
    if (!hasRivalTrophy(options.campaign, trophyId)) {
      reasons.push(`Requires trophy ${rivalTrophyName(trophyId)}`);
    }
  });
  Object.entries(options.choice.requirements?.factionReputation ?? {}).forEach(([factionId, amount]) => {
    const current = options.hero.factionReputation[factionId] ?? 0;
    if (current < amount) {
      reasons.push(`Requires ${amount} ${titleCase(factionId)} reputation`);
    }
  });

  return {
    ok: reasons.length === 0,
    reasons
  };
}

export function applyCampaignChoice(options: {
  campaign: CampaignSaveData;
  hero: HeroSaveData;
  node: CampaignNodeDefinition;
  choice: CampaignNodeChoiceDefinition;
  nodes?: CampaignNodeDefinition[];
}): CampaignChoiceResult {
  const nodes = options.nodes ?? CAMPAIGN_NODES;
  const availability = getCampaignChoiceAvailability({ ...options, nodes });
  const emptyLevelUp: RewardLevelUpSummary = {
    previousLevel: options.hero.level,
    newLevel: options.hero.level,
    levelsGained: 0,
    skillPointsGained: 0
  };
  const emptyReward: BattleRewardResult = { itemIds: [], resources: {}, xp: 0 };
  if (!availability.ok) {
    return {
      ok: false,
      reason: availability.reasons.join(", "),
      campaign: options.campaign,
      hero: options.hero,
      reward: emptyReward,
      levelUp: emptyLevelUp,
      unlockedNodeIds: [],
      lockedNodeIds: [],
      grantedModifierIds: [],
      removedModifierIds: [],
      completedNode: false
    };
  }

  const adjustedChoiceCost = getAdjustedCampaignChoiceCost({
    hero: options.hero,
    node: options.node,
    choice: options.choice
  });
  const adjustedChoiceRewards = getAdjustedCampaignChoiceRewards({
    hero: options.hero,
    node: options.node,
    choice: options.choice
  });
  const reward: BattleRewardResult = {
    itemIds: adjustedChoiceRewards?.itemIds ?? [],
    resources: adjustedChoiceRewards?.resources ?? {},
    xp: adjustedChoiceRewards?.xp ?? 0
  };
  const beforeUnlocked = new Set(options.campaign.unlockedNodeIds);
  const beforeLocked = new Set(options.campaign.lockedNodeIds);
  const paidCampaign = recordCampaignResourceSpending(
    subtractCampaignResources(options.campaign, adjustedChoiceCost),
    adjustedChoiceCost
  );
  const adjustedReward = options.node.nodeType === "town"
    ? { campaign: paidCampaign, resources: reward.resources, consumedModifierIds: [] }
    : applyCampaignResourceRewardModifiers({
        campaign: paidCampaign,
        resources: reward.resources
      });
  const adjustedRewardResult: BattleRewardResult = {
    ...reward,
    resources: adjustedReward.resources
  };
  const rewardCampaign = addCampaignResources(adjustedReward.campaign, adjustedRewardResult.resources);
  const unlocked = new Set(rewardCampaign.unlockedNodeIds);
  options.choice.unlockNodeIds?.forEach((nodeId) => unlocked.add(nodeId));
  adjustedChoiceRewards?.unlockNodeIds?.forEach((nodeId) => unlocked.add(nodeId));
  const locked = new Set(rewardCampaign.lockedNodeIds);
  options.choice.lockNodeIds?.forEach((nodeId) => locked.add(nodeId));
  adjustedChoiceRewards?.lockNodeIds?.forEach((nodeId) => locked.add(nodeId));
  unlocked.forEach((nodeId) => {
    if (locked.has(nodeId)) {
      unlocked.delete(nodeId);
    }
  });

  const completedNode = options.node.nodeType === "town" ? options.choice.completesNode === true : options.choice.completesNode !== false;
  const completedCampaign = completedNode
    ? completeCampaignNode({ ...rewardCampaign, unlockedNodeIds: [...unlocked], lockedNodeIds: [...locked] }, options.node, nodes)
    : refreshCampaignUnlocks({ ...rewardCampaign, unlockedNodeIds: [...unlocked], lockedNodeIds: [...locked], selectedNodeId: options.node.id }, nodes);
  const townTracking = recordTownServiceUse(completedCampaign, options.node, options.choice);
  const reputationChanges = {
    ...(options.choice.reputationChanges ?? {}),
    ...(adjustedChoiceRewards?.reputationChanges ?? {})
  };
  const heroWithReputation = applyReputationChanges(options.hero, reputationChanges);
  const granted = grantBattleRewards(heroWithReputation, adjustedRewardResult, undefined, {
    itemById: ITEM_BY_ID,
    source: `campaign_choice:${options.node.id}:${options.choice.id}`
  });
  const campaignWithConvertedResources = addCampaignResources(
    completedCampaign,
    additionalRewardResources(granted.reward.resources, adjustedRewardResult.resources)
  );
  const grantedModifierIds = [
    ...(options.choice.modifierIds ?? []),
    ...(adjustedChoiceRewards?.modifierIds ?? [])
  ].filter((modifierId, index, ids): modifierId is CampaignModifierId => ids.indexOf(modifierId) === index);
  const removedModifierIds = [
    ...(options.choice.removeModifierIds ?? []),
    ...(adjustedChoiceRewards?.removeModifierIds ?? [])
  ];
  const modifierCampaign = removeCampaignModifiers(
    grantCampaignModifiers(
      {
        ...campaignWithConvertedResources,
        choiceIdsClaimed: townTracking.choiceIdsClaimed,
        townServiceClaimedIds: townTracking.townServiceClaimedIds,
        townServiceUseCounts: townTracking.townServiceUseCounts
      },
      grantedModifierIds
    ),
    removedModifierIds
  );

  return {
    ok: true,
    campaign: modifierCampaign,
    hero: granted.hero,
    reward: granted.reward,
    levelUp: granted.levelUp,
    unlockedNodeIds: [...modifierCampaign.unlockedNodeIds].filter((nodeId) => !beforeUnlocked.has(nodeId)),
    lockedNodeIds: [...modifierCampaign.lockedNodeIds].filter((nodeId) => !beforeLocked.has(nodeId)),
    grantedModifierIds,
    removedModifierIds,
    completedNode
  };
}

function nodeName(nodeId: string, nodes: CampaignNodeDefinition[]): string {
  return nodes.find((node) => node.id === nodeId)?.name ?? nodeId;
}

function rivalTrophyName(trophyId: string): string {
  return RIVAL_REWARDS.find((reward) => reward.firstDefeat.trophy.trophyId === trophyId)?.firstDefeat.trophy.label ?? trophyId;
}

function titleCase(value: string): string {
  return value.charAt(0).toUpperCase() + value.slice(1).replaceAll("_", " ");
}
