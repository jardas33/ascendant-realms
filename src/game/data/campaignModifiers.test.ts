import { describe, expect, it } from "vitest";
import { createStartedCampaignSave } from "../core/CampaignRules";
import { CAMPAIGN_NODES } from "./campaignNodes";
import {
  CAMPAIGN_MODIFIERS,
  applyCampaignResourceRewardModifiers,
  consumeBattleCampaignModifiers,
  grantCampaignModifiers
} from "./campaignModifiers";

describe("campaign modifiers", () => {
  it("defines the initial visible consequence modifiers", () => {
    expect(CAMPAIGN_MODIFIERS.map((modifier) => modifier.id)).toEqual([
      "inspired_militia",
      "blessed_road",
      "angered_raiders",
      "local_support"
    ]);
    expect(CAMPAIGN_MODIFIERS.filter((modifier) => modifier.trigger.includes("battle")).length).toBeGreaterThanOrEqual(3);
  });

  it("grants one-use battle modifiers and consumes them on matching launches", () => {
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "old_stone_road")!;
    const campaign = grantCampaignModifiers(createStartedCampaignSave(), ["inspired_militia", "blessed_road", "local_support"]);

    const consumed = consumeBattleCampaignModifiers({ campaign, node });

    expect(consumed.launchModifiers.map((modifier) => modifier.id)).toEqual(["inspired_militia", "blessed_road"]);
    expect(consumed.campaign.activeModifierIds).toEqual(["local_support"]);
    expect(consumed.consumedModifierIds).toEqual(["inspired_militia", "blessed_road"]);
  });

  it("only consumes Angered Raiders for Ashen Covenant battles", () => {
    const campaign = grantCampaignModifiers(createStartedCampaignSave(), ["angered_raiders"]);
    const node = { ...CAMPAIGN_NODES.find((entry) => entry.id === "old_stone_road")!, enemyFactionId: "sylvan_concord" };

    const skipped = consumeBattleCampaignModifiers({ campaign, node });
    const consumed = consumeBattleCampaignModifiers({
      campaign,
      node: { ...node, enemyFactionId: "ashen_covenant" }
    });

    expect(skipped.launchModifiers).toEqual([]);
    expect(skipped.campaign.activeModifierIds).toEqual(["angered_raiders"]);
    expect(consumed.launchModifiers.map((modifier) => modifier.id)).toEqual(["angered_raiders"]);
    expect(consumed.campaign.activeModifierIds).toEqual([]);
  });

  it("applies Local Support to one campaign resource reward", () => {
    const campaign = grantCampaignModifiers(createStartedCampaignSave(), ["local_support"]);

    const applied = applyCampaignResourceRewardModifiers({
      campaign,
      resources: { crowns: 50, stone: 35 }
    });

    expect(applied.resources).toEqual({ crowns: 55, stone: 39 });
    expect(applied.consumedModifierIds).toEqual(["local_support"]);
    expect(applied.campaign.activeModifierIds).toEqual([]);
  });
});
