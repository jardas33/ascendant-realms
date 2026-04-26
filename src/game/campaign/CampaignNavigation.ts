import type { BattleStats, CampaignNodeDefinition } from "../core/GameTypes";
import { getCampaignNodeStatus } from "../core/CampaignRules";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import type { CampaignSaveData } from "../save/SaveTypes";

export interface CampaignMessageData {
  completedNodeId?: string;
  stats?: BattleStats;
}

export function firstAvailableNodeId(save: CampaignSaveData): string {
  return CAMPAIGN_NODES.find((node) => getCampaignNodeStatus(node, save) === "available")?.id ?? CAMPAIGN_NODES[0]?.id ?? "";
}

export function selectedCampaignNode(selectedNodeId: string): CampaignNodeDefinition | undefined {
  return CAMPAIGN_NODES.find((node) => node.id === selectedNodeId) ?? CAMPAIGN_NODES[0];
}

export function canStartCampaignNode(node: CampaignNodeDefinition | undefined, campaignSave: CampaignSaveData): boolean {
  return Boolean(node && !node.choices?.length && getCampaignNodeStatus(node, campaignSave) === "available");
}

export function formatCampaignNodeList(nodeIds: string[]): string {
  return nodeIds
    .map((nodeId) => CAMPAIGN_NODES.find((node) => node.id === nodeId)?.name ?? nodeId)
    .join(", ");
}

export function messageForCampaignMapData(data: CampaignMessageData): string {
  if (data.completedNodeId) {
    const node = CAMPAIGN_NODES.find((entry) => entry.id === data.completedNodeId);
    return node ? `${node.name} completed. New paths may be available.` : "Campaign progress saved.";
  }
  if (data.stats?.outcome === "defeat") {
    return "Defeat recorded. Choose the same node to retry when ready.";
  }
  return "Choose an available campaign node.";
}
