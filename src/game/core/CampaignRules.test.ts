import { describe, expect, it } from "vitest";
import {
  completeCampaignNode,
  completeCampaignNodeWithRewards,
  createStartedCampaignSave,
  getCampaignNodeStatus
} from "./CampaignRules";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import { createNewHeroSave } from "../data/heroes";

describe("campaign rules", () => {
  it("unlocks the first node and gates later nodes by prerequisites", () => {
    const campaign = createStartedCampaignSave();
    const borderVillage = CAMPAIGN_NODES.find((node) => node.id === "border_village");
    const oldRoad = CAMPAIGN_NODES.find((node) => node.id === "old_stone_road");

    expect(borderVillage && getCampaignNodeStatus(borderVillage, campaign)).toBe("available");
    expect(oldRoad && getCampaignNodeStatus(oldRoad, campaign)).toBe("locked");
  });

  it("completes nodes and unlocks their next choices", () => {
    const campaign = createStartedCampaignSave();
    const borderVillage = CAMPAIGN_NODES.find((node) => node.id === "border_village");
    expect(borderVillage).toBeDefined();

    const next = completeCampaignNode(campaign, borderVillage!);
    const oldRoad = CAMPAIGN_NODES.find((node) => node.id === "old_stone_road");

    expect(next.completedNodeIds).toContain("border_village");
    expect(oldRoad && getCampaignNodeStatus(oldRoad, next)).toBe("available");
  });

  it("claims node rewards once while preserving completion progress", () => {
    const campaign = createStartedCampaignSave();
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "border_village")!;

    const completed = completeCampaignNodeWithRewards({ campaign, hero, node });
    const repeated = completeCampaignNodeWithRewards({
      campaign: completed.campaign,
      hero: completed.hero,
      node
    });

    expect(completed.campaign.completedNodeIds).toContain(node.id);
    expect(completed.campaign.nodeRewardsClaimedIds).toContain(node.id);
    expect(completed.hero.inventory).toContain("weathered_command_sword");
    expect(repeated.nodeReward.itemIds).toEqual([]);
  });
});
