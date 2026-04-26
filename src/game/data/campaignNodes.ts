export interface CampaignNodeDefinition {
  id: string;
  name: string;
  description: string;
  connectedNodeIds: string[];
  battleMapId?: string;
}

export const CAMPAIGN_NODES: CampaignNodeDefinition[] = [
  {
    id: "marchgate",
    name: "Marchgate",
    description: "Placeholder starting node for the future campaign map.",
    connectedNodeIds: ["old-quarry"],
    battleMapId: "first_claim"
  },
  {
    id: "old-quarry",
    name: "Old Quarry",
    description: "Placeholder resource node for future quests and faction events.",
    connectedNodeIds: ["marchgate"]
  }
];
