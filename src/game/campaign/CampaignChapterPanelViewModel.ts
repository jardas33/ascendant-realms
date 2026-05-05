import { getCampaignChapterViewModels } from "../core/CampaignRules";
import type { CampaignChapterDefinition, CampaignNodeDefinition } from "../core/GameTypes";
import { CAMPAIGN_CHAPTERS } from "../data/campaignChapters";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import type { CampaignSaveData } from "../save/SaveTypes";
import type { CampaignChapterViewModel } from "./CampaignPresentationTypes";
import { titleCase } from "./CampaignPresentationTypes";

export function createCampaignChapterPanelViewModels(
  campaignSave: CampaignSaveData,
  chapters: CampaignChapterDefinition[] = CAMPAIGN_CHAPTERS,
  nodes: CampaignNodeDefinition[] = CAMPAIGN_NODES
): CampaignChapterViewModel[] {
  return getCampaignChapterViewModels(campaignSave, chapters, nodes).map((entry) => ({
    ...entry,
    statusLabel: titleCase(entry.status),
    progressText:
      entry.currentNodeCount > 0
        ? `${entry.completedNodeCount}/${entry.currentNodeCount} current nodes complete`
        : "Future content scaffold",
    testId: `campaign-chapter-${entry.chapter.id}`,
    cssClass: `chapter-card ${entry.status}`
  }));
}
