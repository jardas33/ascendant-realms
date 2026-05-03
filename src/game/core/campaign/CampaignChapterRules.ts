import type { CampaignChapterDefinition, CampaignChapterStatus, CampaignNodeDefinition } from "../GameTypes";
import { CAMPAIGN_CHAPTERS } from "../../data/campaignChapters";
import { CAMPAIGN_NODES } from "../../data/campaignNodes";
import type { CampaignSaveData } from "../../save/SaveTypes";

export interface CampaignChapterViewModel {
  chapter: CampaignChapterDefinition;
  status: CampaignChapterStatus;
  completedNodeCount: number;
  currentNodeCount: number;
}

export function getCampaignChapterStatus(chapter: CampaignChapterDefinition, save: CampaignSaveData): CampaignChapterStatus {
  const prerequisitesMet = chapter.unlockPrerequisiteNodeIds.every((nodeId) => save.completedNodeIds.includes(nodeId));
  if (!prerequisitesMet) {
    return "locked";
  }
  return chapter.isUpcoming ? "upcoming" : "unlocked";
}

export function getCampaignChapterViewModels(
  save: CampaignSaveData,
  chapters: CampaignChapterDefinition[] = CAMPAIGN_CHAPTERS,
  nodes: CampaignNodeDefinition[] = CAMPAIGN_NODES
): CampaignChapterViewModel[] {
  return chapters.map((chapter) => {
    const chapterNodeIds = new Set(chapter.nodeIds);
    const currentNodes = nodes.filter((node) => chapterNodeIds.has(node.id) && !node.isPlaceholder);
    return {
      chapter,
      status: getCampaignChapterStatus(chapter, save),
      completedNodeCount: currentNodes.filter((node) => save.completedNodeIds.includes(node.id)).length,
      currentNodeCount: currentNodes.length
    };
  });
}
