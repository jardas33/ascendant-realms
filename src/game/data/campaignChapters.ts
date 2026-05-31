import type { CampaignChapterDefinition, CampaignChapterId } from "../core/GameTypes";

export const DEFAULT_CAMPAIGN_CHAPTER_ID: CampaignChapterId = "border_marches";

export const CAMPAIGN_CHAPTERS: CampaignChapterDefinition[] = [
  {
    id: "border_marches",
    title: "Chapter 1: The Barrosan Marches",
    shortDescription:
      "The current playable mini-campaign: secure Salto's road, nearby ruins, the Marcher Camp, rival commanders, and Ashen Outpost.",
    nodeIds: [
      "border_village",
      "old_stone_road",
      "marcher_camp",
      "aether_well_ruins",
      "bandit_hillfort",
      "chapel_of_the_marches",
      "refugee_caravan",
      "ashen_outpost"
    ],
    unlockPrerequisiteNodeIds: []
  },
  {
    id: "cinderfen_road",
    title: "Chapter 2: Cinderfen Road",
    shortDescription:
      "The first playable v0.3 road beyond Ashen Outpost: one compact event gate, one waystation support node, two Cinderfen battles, and one aftermath event.",
    nodeIds: [
      "cinderfen_overlook",
      "cinderfen_waystation",
      "cinderfen_crossing",
      "cinderfen_watch",
      "cinderfen_aftermath"
    ],
    unlockPrerequisiteNodeIds: ["ashen_outpost"]
  }
];

export const CAMPAIGN_CHAPTER_BY_ID: Record<CampaignChapterId, CampaignChapterDefinition> = Object.fromEntries(
  CAMPAIGN_CHAPTERS.map((chapter) => [chapter.id, chapter])
) as Record<CampaignChapterId, CampaignChapterDefinition>;

export function isCampaignChapterId(value: unknown): value is CampaignChapterId {
  return typeof value === "string" && value in CAMPAIGN_CHAPTER_BY_ID;
}
