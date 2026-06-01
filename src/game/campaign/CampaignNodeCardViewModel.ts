import { getCampaignNodeStatus } from "../core/CampaignRules";
import type { CampaignNodeDefinition } from "../core/GameTypes";
import { getCampaignMissionRewardState } from "../core/campaign/CampaignMissionRules";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import type { CampaignSaveData } from "../save/SaveTypes";
import type { CampaignNodeViewModel } from "./CampaignPresentationTypes";
import { titleCase } from "./CampaignPresentationTypes";

const CHAPTER_TWO_MIN_X = 58;
const CHAPTER_TWO_MAX_X = 92;
const CHAPTER_TWO_MIN_Y = 14;
const CHAPTER_TWO_MAX_Y = 84;
const CAMPAIGN_NODE_PRESENTATION_POSITIONS: Record<string, { x: number; y: number }> = {
  border_village: { x: 14, y: 72 },
  old_stone_road: { x: 31, y: 50 },
  marcher_camp: { x: 34, y: 76 },
  aether_well_ruins: { x: 47, y: 25 },
  bandit_hillfort: { x: 52, y: 68 },
  chapel_of_the_marches: { x: 65, y: 38 },
  refugee_caravan: { x: 55, y: 90 },
  ashen_outpost: { x: 69, y: 58 },
  cinderfen_overlook: { x: 78, y: 88 },
  cinderfen_waystation: { x: 86, y: 53 },
  cinderfen_crossing: { x: 91, y: 72 },
  cinderfen_watch: { x: 92, y: 34 },
  cinderfen_aftermath: { x: 88, y: 14 }
};

export function createCampaignNodeCardViewModels(
  campaignSave: CampaignSaveData,
  selectedNodeId: string,
  nodes: CampaignNodeDefinition[] = CAMPAIGN_NODES
): CampaignNodeViewModel[] {
  return nodes.map((node) =>
    createCampaignNodeCardViewModel({
      node,
      status: getCampaignNodeStatus(node, campaignSave),
      selected: node.id === selectedNodeId,
      campaignSave
    })
  );
}

export function createCampaignNodeCardViewModel(input: {
  node: CampaignNodeDefinition;
  status: ReturnType<typeof getCampaignNodeStatus>;
  selected: boolean;
  campaignSave?: CampaignSaveData;
}): CampaignNodeViewModel {
  const { node, status, selected } = input;
  const mission = input.campaignSave ? getCampaignMissionRewardState(input.campaignSave, node) : undefined;
  const position = campaignNodeMapPosition(node);
  const chapterId = node.chapterId ?? "unchaptered";
  return {
    node,
    status,
    selected,
    mapX: position.x,
    mapY: position.y,
    chapterId,
    nodeTypeLabel: titleCase(node.nodeType),
    statusLabel: node.isPlaceholder ? "Upcoming" : status === "completed" && node.nodeType === "battle" ? "Replayable (Completed)" : titleCase(status),
    rewardStateLabel: mission?.rewardLabel,
    testId: `campaign-node-${node.id}`,
    cssClass: `campaign-node ${status}${selected ? " selected" : ""} chapter-${chapterId}${status === "completed" && node.nodeType === "battle" ? " replayable" : ""}${node.isPlaceholder ? " future" : ""}`,
    style: `--node-x: ${position.x}%; --node-y: ${position.y}%`
  };
}

export function campaignNodeMapPosition(node: CampaignNodeDefinition): { x: number; y: number } {
  const fixedPosition = CAMPAIGN_NODE_PRESENTATION_POSITIONS[node.id];
  if (fixedPosition) {
    return fixedPosition;
  }

  if (node.chapterId === "border_marches") {
    return {
      x: clamp(8 + node.x * 0.68, 8, 70),
      y: clamp(12 + node.y * 0.76, 14, 88)
    };
  }

  if (node.chapterId === "cinderfen_road") {
    const xRatio = (node.x - CHAPTER_TWO_MIN_X) / (CHAPTER_TWO_MAX_X - CHAPTER_TWO_MIN_X);
    const yRatio = (node.y - CHAPTER_TWO_MIN_Y) / (CHAPTER_TWO_MAX_Y - CHAPTER_TWO_MIN_Y);
    return {
      x: clamp(74 + xRatio * 19, 73, 94),
      y: clamp(13 + yRatio * 74, 13, 88)
    };
  }

  return { x: node.x, y: node.y };
}

function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}
