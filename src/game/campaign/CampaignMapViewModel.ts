import { getCampaignChapterViewModels, getCampaignNodeStatus, getCampaignProgressSummary } from "../core/CampaignRules";
import { getKnownRivalIntel, getRivalTrophyIntel } from "../core/RivalRules";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import { FACTION_BY_ID } from "../data/contentIndex";
import {
  TRACKED_REPUTATION_FACTION_IDS,
  getActiveReputationEffects,
  getReputationRank
} from "../data/reputation";
import type { CampaignSaveData, HeroSaveData } from "../save/SaveTypes";
import type { CampaignMapViewModel, CampaignReputationViewModel } from "./CampaignPresentationTypes";

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
    chapters: getCampaignChapterViewModels(input.campaignSave),
    progressSummary: getCampaignProgressSummary(input.campaignSave),
    campaignStateLabel: input.campaignSave.started ? "Live" : "New",
    reputation: createCampaignReputationViewModel(input.heroSave),
    rivalIntel: getKnownRivalIntel(input.campaignSave),
    rivalTrophies: getRivalTrophyIntel(input.campaignSave)
  };
}

function createCampaignReputationViewModel(heroSave: HeroSaveData): CampaignReputationViewModel {
  return {
    rows: TRACKED_REPUTATION_FACTION_IDS.map((factionId) => {
      const value = heroSave.factionReputation[factionId] ?? 0;
      const faction = FACTION_BY_ID[factionId];
      return {
        factionId,
        factionName: faction?.name ?? factionId,
        value,
        rankLabel: getReputationRank(value).label
      };
    }),
    activeEffects: getActiveReputationEffects(heroSave).map((effect) => ({
      id: effect.id,
      factionId: effect.factionId,
      factionName: FACTION_BY_ID[effect.factionId]?.name ?? effect.factionId,
      name: effect.name,
      description: effect.description
    }))
  };
}
