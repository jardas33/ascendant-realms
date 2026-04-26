import type {
  BattleRewardResult,
  CampaignNodeDefinition,
  CampaignNodeStatus,
  RewardLevelUpSummary
} from "./GameTypes";
import { grantBattleRewards } from "./HeroProgressionRules";
import { createFallbackCampaignSave } from "./SaveSystem";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import type { CampaignSaveData, HeroSaveData } from "../save/SaveTypes";

export interface CampaignNodeCompletionResult {
  campaign: CampaignSaveData;
  hero: HeroSaveData;
  nodeReward: BattleRewardResult;
  nodeLevelUp: RewardLevelUpSummary;
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
    unlockedNodeIds: [...unlocked]
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
  const nodeReward: BattleRewardResult = rewardAlreadyClaimed
    ? { itemIds: [], resources: {}, xp: 0 }
    : {
        itemIds: options.node.rewards.itemIds ?? [],
        resources: options.node.rewards.resources ?? {},
        xp: options.node.rewards.xp ?? 0
      };
  const granted = grantBattleRewards(options.hero, nodeReward);
  const campaign = completeCampaignNode(options.campaign, options.node, options.nodes);
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
