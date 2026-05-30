import type { LumeNetworkDefinition } from "../core/GameTypes";

export const LUME_NETWORKS: LumeNetworkDefinition[] = [
  {
    id: "aether_well_ruins_lume_ward",
    campaignNodeId: "aether_well_ruins",
    mapId: "broken_ford",
    mode: "campaign_node",
    rewardsDisabledExcluded: true,
    tutorialExcluded: true,
    activationMode: "capture_only",
    eligibleSiteIds: ["west_stone_cut", "ford_toll", "north_aether_spring"],
    links: [
      {
        id: "west_stone_cut_to_ford_toll",
        fromSiteId: "west_stone_cut",
        toSiteId: "ford_toll",
        displayName: "West Stone Cut to Ford Toll"
      },
      {
        id: "ford_toll_to_north_aether_spring",
        fromSiteId: "ford_toll",
        toSiteId: "north_aether_spring",
        displayName: "Ford Toll to North Aether Spring"
      }
    ],
    maxEligibleSites: 3,
    maxActiveLinks: 2,
    benefit: {
      id: "linked_ward",
      name: "Linked Ward",
      summary: "Friendly units and buildings near active linked sites take 8% less incoming damage.",
      damageTakenMultiplier: 0.92,
      endpointRadiusBonus: 120,
      nonStacking: true
    },
    briefingCopy: "Hold two linked sites to wake a Lume Ward. Enemy recapture severs the link.",
    hudObjective: "Hold linked sites to wake a Lume Ward.",
    counterplay: "Enemy recapture severs the link; retake both endpoints to restore it.",
    battleLocalCopy: "Linked Ward is battle-local and does not change campaign saves."
  }
];

export const LUME_NETWORK_BY_ID: Record<string, LumeNetworkDefinition> = Object.fromEntries(
  LUME_NETWORKS.map((network) => [network.id, network])
);

export function selectLumeNetworkForLaunch(options: {
  mode: string;
  campaignNodeId?: string;
  mapId: string;
  rewardsDisabled?: boolean;
  privatePlaytestDemoId?: string;
}): LumeNetworkDefinition | undefined {
  const privateLumeDemo = options.privatePlaytestDemoId === "aether_well_lume_private_demo";
  if (options.mode !== "campaign_node" || (options.rewardsDisabled && !privateLumeDemo)) {
    return undefined;
  }
  return LUME_NETWORKS.find(
    (network) => network.campaignNodeId === options.campaignNodeId && network.mapId === options.mapId
  );
}

export function lumeNetworkForCampaignNode(nodeId: string): LumeNetworkDefinition | undefined {
  return LUME_NETWORKS.find((network) => network.campaignNodeId === nodeId);
}
