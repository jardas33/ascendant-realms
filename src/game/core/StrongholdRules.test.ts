import { describe, expect, it } from "vitest";
import { createStartedCampaignSave } from "./CampaignRules";
import {
  getStrongholdLaunchModifiers,
  getStrongholdUpgradeAvailability,
  purchaseStrongholdUpgrade
} from "./StrongholdRules";
import { STRONGHOLD_UPGRADE_BY_ID, applyStrongholdBuildingEffects, getStrongholdBattleEffects } from "../data/strongholdUpgrades";
import { requireBuilding } from "../data/contentIndex";
import { createNewHeroSave } from "../data/heroes";

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

  it("does not allow Tier II upgrades before their Tier I prerequisite", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      resources: { crowns: 300, stone: 200, iron: 100, aether: 100 }
    });

    const locked = purchaseStrongholdUpgrade(campaign, "quartermaster_stores_ii");

    expect(locked.ok).toBe(false);
    expect(locked.reason).toContain("Requires Quartermaster Stores I rank 1");
    expect(locked.campaign.resources).toMatchObject({ crowns: 300, stone: 200, iron: 100, aether: 100 });
  });

  it("allows Tier II upgrades after Tier I and spends campaign resources", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      resources: { crowns: 300, stone: 200, iron: 100, aether: 100 }
    });

    const tierOne = purchaseStrongholdUpgrade(campaign, "quartermaster_stores_i");
    const tierTwo = purchaseStrongholdUpgrade(tierOne.campaign, "quartermaster_stores_ii");

    expect(tierOne.ok).toBe(true);
    expect(tierTwo.ok).toBe(true);
    expect(tierTwo.campaign.resources).toMatchObject({ crowns: 110, stone: 95, iron: 65, aether: 100 });
    expect(tierTwo.campaign.resourcesSpent).toMatchObject({ crowns: 190, stone: 105, iron: 35, aether: 0 });
    expect(tierTwo.campaign.strongholdUpgradeRanks.quartermaster_stores_i).toBe(1);
    expect(tierTwo.campaign.strongholdUpgradeRanks.quartermaster_stores_ii).toBe(1);
  });

  it("discounts Stronghold Crown costs when Free Marches reputation is friendly", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      resources: { crowns: 100, stone: 0, iron: 40, aether: 0 }
    });
    const hero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      factionReputation: {
        free_marches: 25,
        ashen_covenant: -10,
        sylvan_concord: 0,
        common_folk: 0,
        old_faith: 0
      }
    };

    const purchased = purchaseStrongholdUpgrade(campaign, "training_yard_i", hero);

    expect(purchased.ok).toBe(true);
    expect(purchased.campaign.resources).toMatchObject({ crowns: 28, iron: 5 });
    expect(purchased.campaign.resourcesSpent).toMatchObject({ crowns: 72, iron: 35 });
  });

  it("creates persistent battle launch modifiers for purchased upgrades", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      strongholdUpgradeRanks: {
        training_yard_i: 1,
        quartermaster_stores_i: 1,
        quartermaster_stores_ii: 1
      }
    });

    expect(getStrongholdLaunchModifiers(campaign).map((modifier) => modifier.id)).toEqual([
      "stronghold:training_yard_i",
      "stronghold:quartermaster_stores_i",
      "stronghold:quartermaster_stores_ii"
    ]);
  });

  it("aggregates stronghold launch effects without consuming the purchase", () => {
    const effects = getStrongholdBattleEffects([
      { id: "stronghold:training_yard_i" },
      { id: "stronghold:training_yard_ii" },
      { id: "stronghold:quartermaster_stores_i" },
      { id: "stronghold:quartermaster_stores_ii" },
      { id: "stronghold:chapel_corner_i" },
      { id: "stronghold:chapel_corner_ii" },
      { id: "stronghold:watch_post_i" },
      { id: "stronghold:watch_post_ii" },
      { id: "stronghold:ranger_paths_i" },
      { id: "stronghold:ranger_paths_ii" }
    ]);

    expect(effects.extraPlayerUnitIds).toEqual(["militia", "ranger"]);
    expect(effects.startingResources).toMatchObject({ crowns: 140, stone: 90, iron: 55, aether: 30 });
    expect(effects.heroMaxHpMultiplier).toBe(1.08);
    expect(effects.heroMaxManaMultiplier).toBe(1.08);
    expect(effects.buildingVisionBonus).toBe(80);
    expect(effects.enemyWarningLeadSeconds).toBe(40);
    expect(effects.watchtowerRangeMultiplier).toBe(1.2);
    expect(effects.firstBuildingConstructionTimeMultiplier).toBe(0.9);
    expect(effects.unitTrainingTimeMultipliers.militia).toBe(0.9);
    expect(effects.unitTrainingTimeMultipliers.ranger).toBe(0.9);
  });

  it("applies Watch Post range only to player Watchtowers", () => {
    const watchtower = requireBuilding("watchtower");
    const effects = getStrongholdBattleEffects([{ id: "stronghold:watch_post_i" }]);

    const playerWatchtower = applyStrongholdBuildingEffects(watchtower, "player", effects);
    const enemyWatchtower = applyStrongholdBuildingEffects(watchtower, "enemy", effects);

    expect(playerWatchtower).not.toBe(watchtower);
    expect(playerWatchtower.attack?.range).toBe(242);
    expect(enemyWatchtower).toBe(watchtower);
    expect(watchtower.attack?.range).toBe(220);
  });
});
