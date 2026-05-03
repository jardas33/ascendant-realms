import type { CampaignNodeChoiceDefinition, CampaignNodeDefinition } from "../GameTypes";
import type { CampaignSaveData } from "../../save/SaveTypes";

export function campaignChoiceClaimId(nodeId: string, choiceId: string): string {
  return `${nodeId}:${choiceId}`;
}

export function isCampaignChoiceClaimed(
  campaign: CampaignSaveData,
  node: CampaignNodeDefinition,
  choice: CampaignNodeChoiceDefinition
): boolean {
  const claimId = campaignChoiceClaimId(node.id, choice.id);
  return (campaign.choiceIdsClaimed ?? []).includes(claimId) || (node.nodeType === "town" && (campaign.townServiceClaimedIds ?? []).includes(claimId));
}

export function recordTownServiceUse(
  campaign: CampaignSaveData,
  node: CampaignNodeDefinition,
  choice: CampaignNodeChoiceDefinition
): {
  choiceIdsClaimed: string[];
  townServiceClaimedIds: string[];
  townServiceUseCounts: Record<string, number>;
} {
  const claimed = new Set(campaign.choiceIdsClaimed ?? []);
  const serviceId = campaignChoiceClaimId(node.id, choice.id);
  if (choice.onceOnly) {
    claimed.add(serviceId);
  }
  const townServiceClaimed = new Set(campaign.townServiceClaimedIds ?? []);
  if (node.nodeType === "town" && choice.onceOnly) {
    townServiceClaimed.add(serviceId);
  }
  const townServiceUseCounts = { ...(campaign.townServiceUseCounts ?? {}) };
  if (node.nodeType === "town") {
    townServiceUseCounts[serviceId] = (townServiceUseCounts[serviceId] ?? 0) + 1;
  }
  return {
    choiceIdsClaimed: [...claimed],
    townServiceClaimedIds: [...townServiceClaimed],
    townServiceUseCounts
  };
}
