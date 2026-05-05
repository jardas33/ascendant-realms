import { getCampaignNodeStatus } from "../core/CampaignRules";
import type { CampaignNodeDefinition } from "../core/GameTypes";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import type { CampaignSaveData } from "../save/SaveTypes";
import type { CampaignNodeViewModel } from "./CampaignPresentationTypes";
import { titleCase } from "./CampaignPresentationTypes";

export function createCampaignNodeCardViewModels(
  campaignSave: CampaignSaveData,
  selectedNodeId: string,
  nodes: CampaignNodeDefinition[] = CAMPAIGN_NODES
): CampaignNodeViewModel[] {
  return nodes.map((node) =>
    createCampaignNodeCardViewModel({
      node,
      status: getCampaignNodeStatus(node, campaignSave),
      selected: node.id === selectedNodeId
    })
  );
}

export function createCampaignNodeCardViewModel(input: {
  node: CampaignNodeDefinition;
  status: ReturnType<typeof getCampaignNodeStatus>;
  selected: boolean;
}): CampaignNodeViewModel {
  const { node, status, selected } = input;
  return {
    node,
    status,
    selected,
    nodeTypeLabel: titleCase(node.nodeType),
    statusLabel: node.isPlaceholder ? "Upcoming" : titleCase(status),
    testId: `campaign-node-${node.id}`,
    cssClass: `campaign-node ${status}${selected ? " selected" : ""}`,
    style: `--node-x: ${node.x}%; --node-y: ${node.y}%`
  };
}
