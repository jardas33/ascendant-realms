import { getCampaignNodeStatus, getCampaignProgressSummary } from "../core/CampaignRules";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import type { CampaignSaveData, HeroSaveData } from "../save/SaveTypes";
import type { CampaignMapViewModel } from "./CampaignPresentationTypes";

interface CampaignMapViewModelInput {
  heroSave: HeroSaveData;
  campaignSave: CampaignSaveData;
  selectedNodeId: string;
}

export function createCampaignMapViewModel(input: CampaignMapViewModelInput): CampaignMapViewModel {
  const selectedNode = CAMPAIGN_NODES.find((node) => node.id === input.selectedNodeId) ?? CAMPAIGN_NODES[0];
  return {
    heroSave: input.heroSave,
    campaignSave: input.campaignSave,
    selectedNode,
    nodes: CAMPAIGN_NODES.map((node) => ({
      node,
      status: getCampaignNodeStatus(node, input.campaignSave),
      selected: node.id === input.selectedNodeId
    })),
    progressSummary: getCampaignProgressSummary(input.campaignSave),
    campaignStateLabel: input.campaignSave.started ? "Live" : "New"
  };
}
