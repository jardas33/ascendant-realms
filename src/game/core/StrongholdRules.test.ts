import { describe, expect, it } from "vitest";
import { createStartedCampaignSave } from "./CampaignRules";
import {
  getStrongholdLaunchModifiers,
  getStrongholdUpgradeAvailability,
  purchaseStrongholdUpgrade
} from "./StrongholdRules";
import { STRONGHOLD_UPGRADE_BY_ID, getStrongholdBattleEffects } from "../data/strongholdUpgrades";

describe("stronghold development rules", () => {
  it("checks affordability before buying an upgrade", () => {
    const campaign = createStartedCampaignSave();
    const availability = getStrongholdUpgradeAvailability(campaign, STRONGHOLD_UPGRADE_BY_ID.training_yard_i);

    expect(availability.ok).toBe(false);
    expect(availability.reasons).toEqual(expect.arrayContaining(["Need 80 Crowns", "Need 35 Iron"]));
  });

  it("spends resources, records spending, and persists the purchased rank", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      resources: { crowns: 120, stone: 0, iron: 50, aether: 0 }
    });

    const result = purchaseStrongholdUpgrade(campaign, "training_yard_i");

    expect(result.ok).toBe(true);
    expect(result.campaign.resources).toMatchObject({ crowns: 40, iron: 15 });
    expect(result.campaign.resourcesSpent).toMatchObject({ crowns: 80, iron: 35 });
    expect(result.campaign.strongholdUpgradeRanks.training_yard_i).toBe(1);
  });

  it("does not allow a one-rank upgrade to be bought twice", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      resources: { crowns: 200, stone: 0, iron: 100, aether: 0 }
    });
    const purchased = purchaseStrongholdUpgrade(campaign, "training_yard_i");

    const repeated = purchaseStrongholdUpgrade(purchased.campaign, "training_yard_i");

    expect(repeated.ok).toBe(false);
    expect(repeated.reason).toContain("Already purchased");
    expect(repeated.campaign.resources).toMatchObject({ crowns: 120, iron: 65 });
  });

  it("enforces upgrade prerequisites", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      resources: { crowns: 200, stone: 0, iron: 100, aether: 0 }
    });

    const locked = purchaseStrongholdUpgrade(campaign, "ranger_paths_i");
    const trainingYard = purchaseStrongholdUpgrade(campaign, "training_yard_i");
    const unlocked = purchaseStrongholdUpgrade(
      { ...trainingYard.campaign, resources: { crowns: 200, stone: 0, iron: 100, aether: 0 } },
      "ranger_paths_i"
    );

    expect(locked.ok).toBe(false);
    expect(locked.reason).toContain("Requires Training Yard I rank 1");
    expect(unlocked.ok).toBe(true);
    expect(unlocked.campaign.strongholdUpgradeRanks.ranger_paths_i).toBe(1);
  });

  it("creates persistent battle launch modifiers for purchased upgrades", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      strongholdUpgradeRanks: {
        training_yard_i: 1,
        quartermaster_stores_i: 1
      }
    });

    expect(getStrongholdLaunchModifiers(campaign).map((modifier) => modifier.id)).toEqual([
      "stronghold:training_yard_i",
      "stronghold:quartermaster_stores_i"
    ]);
  });

  it("aggregates stronghold launch effects without consuming the purchase", () => {
    const effects = getStrongholdBattleEffects([
      { id: "stronghold:training_yard_i" },
      { id: "stronghold:quartermaster_stores_i" },
      { id: "stronghold:chapel_corner_i" },
      { id: "stronghold:watch_post_i" }
    ]);

    expect(effects.extraPlayerUnitIds).toEqual(["militia"]);
    expect(effects.startingResources).toMatchObject({ crowns: 50, stone: 30 });
    expect(effects.heroMaxHpMultiplier).toBe(1.05);
    expect(effects.buildingVisionBonus).toBe(80);
  });
});
