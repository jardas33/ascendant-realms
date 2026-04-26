import type {
  BattleRewardResult,
  CampaignModifierId,
  CampaignNodeChoiceDefinition,
  CampaignNodeDefinition,
  CampaignNodeStatus,
  ResourceBag,
  RewardLevelUpSummary
} from "./GameTypes";
import { grantBattleRewards } from "./HeroProgressionRules";
import { createFallbackCampaignSave } from "./SaveSystem";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import {
  applyCampaignResourceRewardModifiers,
  grantCampaignModifiers,
  removeCampaignModifiers
} from "../data/campaignModifiers";
import type { CampaignSaveData, HeroSaveData } from "../save/SaveTypes";

export interface CampaignNodeCompletionResult {
  campaign: CampaignSaveData;
  hero: HeroSaveData;
  nodeReward: BattleRewardResult;
  nodeLevelUp: RewardLevelUpSummary;
}

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

export function createStartedCampaignSave(
  base: CampaignSaveData = createFallbackCampaignSave(),
  nodes: CampaignNodeDefinition[] = CAMPAIGN_NODES
): CampaignSaveData {
  return refreshCampaignUnlocks(
    {
      ...base,
      started: true
    },
    nodes
  );
}

export function getCampaignNodeStatus(node: CampaignNodeDefinition, save: CampaignSaveData): CampaignNodeStatus {
  if (save.completedNodeIds.includes(node.id)) {
    return "completed";
  }
  if (save.lockedNodeIds.includes(node.id)) {
    return "locked";
  }
  if (save.unlockedNodeIds.includes(node.id) && arePrerequisitesMet(node, save)) {
    return "available";
  }
  return "locked";
}

export function arePrerequisitesMet(node: CampaignNodeDefinition, save: CampaignSaveData): boolean {
  return node.prerequisites.every((nodeId) => save.completedNodeIds.includes(nodeId));
}

export function refreshCampaignUnlocks(
  save: CampaignSaveData,
  nodes: CampaignNodeDefinition[] = CAMPAIGN_NODES
): CampaignSaveData {
  const unlocked = new Set(save.unlockedNodeIds);
  nodes.forEach((node) => {
    if (node.prerequisites.length === 0 || arePrerequisitesMet(node, save)) {
      unlocked.add(node.id);
    }
  });
  return {
    ...save,
    unlockedNodeIds: [...unlocked].filter((nodeId) => !save.lockedNodeIds.includes(nodeId))
  };
}

export function completeCampaignNode(
  save: CampaignSaveData,
  node: CampaignNodeDefinition,
  nodes: CampaignNodeDefinition[] = CAMPAIGN_NODES
): CampaignSaveData {
  const completed = new Set(save.completedNodeIds);
  completed.add(node.id);
  const unlocked = new Set(save.unlockedNodeIds);
  node.unlocks.forEach((nodeId) => unlocked.add(nodeId));
  return refreshCampaignUnlocks(
    {
      ...save,
      completedNodeIds: [...completed],
      unlockedNodeIds: [...unlocked],
      selectedNodeId: node.id
    },
    nodes
  );
}

export function completeCampaignNodeWithRewards(options: {
  campaign: CampaignSaveData;
  hero: HeroSaveData;
  node: CampaignNodeDefinition;
  nodes?: CampaignNodeDefinition[];
}): CampaignNodeCompletionResult {
  const rewardAlreadyClaimed = options.campaign.nodeRewardsClaimedIds.includes(options.node.id);
  const adjustedReward = rewardAlreadyClaimed
    ? { resources: {}, campaign: options.campaign }
    : applyCampaignResourceRewardModifiers({
        campaign: options.campaign,
        resources: options.node.rewards.resources ?? {}
      });
  const nodeReward: BattleRewardResult = rewardAlreadyClaimed
    ? { itemIds: [], resources: {}, xp: 0 }
    : {
        itemIds: options.node.rewards.itemIds ?? [],
        resources: adjustedReward.resources,
        xp: options.node.rewards.xp ?? 0
      };
  const granted = grantBattleRewards(options.hero, nodeReward);
  const campaign = rewardAlreadyClaimed
    ? completeCampaignNode(options.campaign, options.node, options.nodes)
    : addCampaignResources(completeCampaignNode(adjustedReward.campaign, options.node, options.nodes), nodeReward.resources);
  const claimed = new Set(campaign.nodeRewardsClaimedIds);
  if (!rewardAlreadyClaimed) {
    claimed.add(options.node.id);
  }

  return {
    campaign: {
      ...campaign,
      nodeRewardsClaimedIds: [...claimed]
    },
    hero: granted.hero,
    nodeReward,
    nodeLevelUp: granted.levelUp
  };
}

export function getCampaignProgressSummary(save: CampaignSaveData, nodes: CampaignNodeDefinition[] = CAMPAIGN_NODES): string {
  const completed = nodes.filter((node) => save.completedNodeIds.includes(node.id)).length;
  return `${completed}/${nodes.length} nodes completed`;
}

export function addCampaignResources(campaign: CampaignSaveData, resources: Partial<ResourceBag>): CampaignSaveData {
  return {
    ...campaign,
    resources: {
      crowns: campaign.resources.crowns + (resources.crowns ?? 0),
      stone: campaign.resources.stone + (resources.stone ?? 0),
      iron: campaign.resources.iron + (resources.iron ?? 0),
      aether: campaign.resources.aether + (resources.aether ?? 0)
    }
  };
}

export function campaignChoiceClaimId(nodeId: string, choiceId: string): string {
  return `${nodeId}:${choiceId}`;
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
  if (options.choice.onceOnly && (options.campaign.choiceIdsClaimed ?? []).includes(campaignChoiceClaimId(options.node.id, options.choice.id))) {
    reasons.push("Already chosen");
  }

  Object.entries(options.choice.costs ?? {}).forEach(([resource, amount]) => {
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
    if (!options.hero.inventory.includes(itemId)) {
      reasons.push(`Requires item ${itemId}`);
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

  const reward: BattleRewardResult = {
    itemIds: options.choice.rewards?.itemIds ?? [],
    resources: options.choice.rewards?.resources ?? {},
    xp: options.choice.rewards?.xp ?? 0
  };
  const beforeUnlocked = new Set(options.campaign.unlockedNodeIds);
  const beforeLocked = new Set(options.campaign.lockedNodeIds);
  const paidCampaign = subtractCampaignResources(options.campaign, options.choice.costs ?? {});
  const adjustedReward = applyCampaignResourceRewardModifiers({
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
  options.choice.rewards?.unlockNodeIds?.forEach((nodeId) => unlocked.add(nodeId));
  const locked = new Set(rewardCampaign.lockedNodeIds);
  options.choice.lockNodeIds?.forEach((nodeId) => locked.add(nodeId));
  options.choice.rewards?.lockNodeIds?.forEach((nodeId) => locked.add(nodeId));
  unlocked.forEach((nodeId) => {
    if (locked.has(nodeId)) {
      unlocked.delete(nodeId);
    }
  });

  const completedNode = options.choice.completesNode !== false;
  const completedCampaign = completedNode
    ? completeCampaignNode({ ...rewardCampaign, unlockedNodeIds: [...unlocked], lockedNodeIds: [...locked] }, options.node, nodes)
    : refreshCampaignUnlocks({ ...rewardCampaign, unlockedNodeIds: [...unlocked], lockedNodeIds: [...locked], selectedNodeId: options.node.id }, nodes);
  const claimed = new Set(completedCampaign.choiceIdsClaimed ?? []);
  if (options.choice.onceOnly) {
    claimed.add(campaignChoiceClaimId(options.node.id, options.choice.id));
  }
  const reputationChanges = {
    ...(options.choice.reputationChanges ?? {}),
    ...(options.choice.rewards?.reputationChanges ?? {})
  };
  const heroWithReputation = applyReputationChanges(options.hero, reputationChanges);
  const granted = grantBattleRewards(heroWithReputation, adjustedRewardResult);
  const grantedModifierIds = [
    ...(options.choice.modifierIds ?? []),
    ...(options.choice.rewards?.modifierIds ?? [])
  ].filter((modifierId, index, ids): modifierId is CampaignModifierId => ids.indexOf(modifierId) === index);
  const removedModifierIds = [
    ...(options.choice.removeModifierIds ?? []),
    ...(options.choice.rewards?.removeModifierIds ?? [])
  ];
  const modifierCampaign = removeCampaignModifiers(
    grantCampaignModifiers(
      {
        ...completedCampaign,
        choiceIdsClaimed: [...claimed]
      },
      grantedModifierIds
    ),
    removedModifierIds
  );

  return {
    ok: true,
    campaign: modifierCampaign,
    hero: granted.hero,
    reward: adjustedRewardResult,
    levelUp: granted.levelUp,
    unlockedNodeIds: [...modifierCampaign.unlockedNodeIds].filter((nodeId) => !beforeUnlocked.has(nodeId)),
    lockedNodeIds: [...modifierCampaign.lockedNodeIds].filter((nodeId) => !beforeLocked.has(nodeId)),
    grantedModifierIds,
    removedModifierIds,
    completedNode
  };
}

function subtractCampaignResources(campaign: CampaignSaveData, resources: Partial<ResourceBag>): CampaignSaveData {
  return {
    ...campaign,
    resources: {
      crowns: campaign.resources.crowns - (resources.crowns ?? 0),
      stone: campaign.resources.stone - (resources.stone ?? 0),
      iron: campaign.resources.iron - (resources.iron ?? 0),
      aether: campaign.resources.aether - (resources.aether ?? 0)
    }
  };
}

function applyReputationChanges(hero: HeroSaveData, changes: Record<string, number>): HeroSaveData {
  const factionReputation = { ...hero.factionReputation };
  Object.entries(changes).forEach(([factionId, amount]) => {
    factionReputation[factionId] = clampReputation((factionReputation[factionId] ?? 0) + amount);
  });
  return {
    ...hero,
    factionReputation
  };
}

function clampReputation(value: number): number {
  return Math.max(-100, Math.min(100, Math.round(value)));
}

function nodeName(nodeId: string, nodes: CampaignNodeDefinition[]): string {
  return nodes.find((node) => node.id === nodeId)?.name ?? nodeId;
}

function titleCase(value: string): string {
  return value.charAt(0).toUpperCase() + value.slice(1).replaceAll("_", " ");
}
