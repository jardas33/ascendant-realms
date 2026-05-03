import type { CampaignNodeDefinition, CampaignNodeStatus } from "../GameTypes";
import { createFallbackCampaignSave } from "../SaveSystem";
import { CAMPAIGN_NODES } from "../../data/campaignNodes";
import type { CampaignSaveData } from "../../save/SaveTypes";

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

export function getCampaignProgressSummary(save: CampaignSaveData, nodes: CampaignNodeDefinition[] = CAMPAIGN_NODES): string {
  const completed = nodes.filter((node) => save.completedNodeIds.includes(node.id)).length;
  return `${completed}/${nodes.length} nodes completed`;
}
