import type { BattleRewardResult, CampaignNodeDefinition, ResourceBag, RewardLevelUpSummary } from "../GameTypes";
import { grantBattleRewards } from "../HeroProgressionRules";
import { ITEM_BY_ID } from "../../data/contentIndex";
import { applyCampaignResourceRewardModifiers } from "../../data/campaignModifiers";
import type { CampaignSaveData, HeroSaveData } from "../../save/SaveTypes";
import { completeCampaignNode } from "./CampaignNodeRules";

export interface CampaignNodeCompletionResult {
  campaign: CampaignSaveData;
  hero: HeroSaveData;
  nodeReward: BattleRewardResult;
  nodeLevelUp: RewardLevelUpSummary;
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
  const granted = grantBattleRewards(options.hero, nodeReward, undefined, {
    itemById: ITEM_BY_ID,
    source: `campaign_node:${options.node.id}`
  });
  const campaign = rewardAlreadyClaimed
    ? completeCampaignNode(options.campaign, options.node, options.nodes)
    : addCampaignResources(completeCampaignNode(adjustedReward.campaign, options.node, options.nodes), granted.reward.resources);
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
    nodeReward: granted.reward,
    nodeLevelUp: granted.levelUp
  };
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

export function subtractCampaignResources(campaign: CampaignSaveData, resources: Partial<ResourceBag>): CampaignSaveData {
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

export function recordCampaignResourceSpending(campaign: CampaignSaveData, resources: Partial<ResourceBag>): CampaignSaveData {
  return {
    ...campaign,
    resourcesSpent: {
      crowns: campaign.resourcesSpent.crowns + Math.max(0, Math.floor(resources.crowns ?? 0)),
      stone: campaign.resourcesSpent.stone + Math.max(0, Math.floor(resources.stone ?? 0)),
      iron: campaign.resourcesSpent.iron + Math.max(0, Math.floor(resources.iron ?? 0)),
      aether: campaign.resourcesSpent.aether + Math.max(0, Math.floor(resources.aether ?? 0))
    }
  };
}

export function additionalRewardResources(
  total: Partial<ResourceBag>,
  alreadyApplied: Partial<ResourceBag>
): Partial<ResourceBag> {
  return {
    crowns: Math.max(0, (total.crowns ?? 0) - (alreadyApplied.crowns ?? 0)),
    stone: Math.max(0, (total.stone ?? 0) - (alreadyApplied.stone ?? 0)),
    iron: Math.max(0, (total.iron ?? 0) - (alreadyApplied.iron ?? 0)),
    aether: Math.max(0, (total.aether ?? 0) - (alreadyApplied.aether ?? 0))
  };
}
