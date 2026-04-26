import { describe, expect, it } from "vitest";
import { createStartedCampaignSave } from "../core/CampaignRules";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import { createNewHeroSave } from "../data/heroes";
import { formatChoiceRewardSummary } from "./CampaignChoicePanel";
import { createCampaignMapViewModel } from "./CampaignMapViewModel";
import { renderNodeDetails } from "./CampaignNodePanel";
import { formatResourceRewards } from "./CampaignResourcePanel";

describe("campaign map presentation helpers", () => {
  it("creates a stable view model with selected node and node statuses", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave();

    const viewModel = createCampaignMapViewModel({
      heroSave: hero,
      campaignSave: campaign,
      selectedNodeId: "border_village"
    });

    expect(viewModel.campaignStateLabel).toBe("Live");
    expect(viewModel.selectedNode?.id).toBe("border_village");
    expect(viewModel.nodes.find((entry) => entry.node.id === "border_village")).toMatchObject({
      status: "available",
      selected: true
    });
    expect(viewModel.nodes.find((entry) => entry.node.id === "old_stone_road")?.status).toBe("locked");
  });

  it("formats resource and choice reward summaries without scene state", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "refugee_caravan")!;
    const choice = node.choices!.find((entry) => entry.id === "demand_tribute")!;

    expect(formatResourceRewards({ crowns: 90, stone: 0 })).toEqual(["90 Crowns"]);
    expect(formatChoiceRewardSummary(choice, hero)).toContain("Modifier: Angered Raiders");
    expect(formatChoiceRewardSummary(choice, hero)).toContain("-8 Common Folk reputation");
  });

  it("renders town service details with stable choice actions", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["border_village", "old_stone_road"],
      unlockedNodeIds: ["border_village", "old_stone_road", "marcher_camp"],
      resources: { crowns: 120, stone: 0, iron: 20, aether: 20 },
      nodeRewardsClaimedIds: []
    });
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "marcher_camp")!;

    const html = renderNodeDetails({ node, campaignSave: campaign, heroSave: hero });

    expect(html).toContain("Town Services");
    expect(html).toContain("data-campaign-choice=\"rest_and_recovery\"");
    expect(html).toContain("Purchase Emberglass Wand");
    expect(html).toContain("Repeatable service.");
  });
});
