import { describe, expect, it } from "vitest";
import { createStartedCampaignSave } from "../core/CampaignRules";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import { createNewHeroSave } from "../data/heroes";
import { formatChoiceModifierSummary, formatChoiceReputationSummary, formatChoiceRewardSummary } from "./CampaignChoicePanel";
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

  it("shows reputation ranks and active reputation effects in the view model", () => {
    const hero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      factionReputation: {
        free_marches: 25,
        ashen_covenant: -50,
        sylvan_concord: 0,
        common_folk: 50,
        old_faith: 25
      }
    };
    const campaign = createStartedCampaignSave();

    const viewModel = createCampaignMapViewModel({
      heroSave: hero,
      campaignSave: campaign,
      selectedNodeId: "border_village"
    });

    expect(viewModel.reputation.rows.find((row) => row.factionId === "common_folk")).toMatchObject({
      value: 50,
      rankLabel: "Honored"
    });
    expect(viewModel.reputation.rows.find((row) => row.factionId === "ashen_covenant")?.rankLabel).toBe("Hostile");
    expect(viewModel.reputation.activeEffects.map((effect) => effect.id)).toEqual([
      "common_folk_friendly_services",
      "free_marches_friendly_stronghold",
      "old_faith_friendly_chapel",
      "ashen_covenant_hostile_pressure"
    ]);
  });

  it("formats resource and choice reward summaries without scene state", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "refugee_caravan")!;
    const choice = node.choices!.find((entry) => entry.id === "demand_tribute")!;

    expect(formatResourceRewards({ crowns: 90, stone: 0 })).toEqual(["90 Crowns"]);
    expect(formatChoiceRewardSummary(choice, hero, node)).toContain("65 Crowns");
    expect(formatChoiceModifierSummary(choice, hero, node)).toContain("Gain Angered Raiders");
    expect(formatChoiceReputationSummary(choice, hero, node)).toContain("-8 Common Folk (to -8 Neutral)");
  });

  it("previews the resulting reputation rank on choice cards", () => {
    const hero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      factionReputation: {
        free_marches: 10,
        ashen_covenant: -10,
        sylvan_concord: 0,
        common_folk: 20,
        old_faith: 0
      }
    };
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "refugee_caravan")!;
    const choice = node.choices!.find((entry) => entry.id === "protect_them")!;

    expect(formatChoiceReputationSummary(choice, hero, node)).toContain("+8 Common Folk (to +28 Friendly)");
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
