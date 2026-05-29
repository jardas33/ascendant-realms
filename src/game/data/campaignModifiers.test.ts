import { describe, expect, it } from "vitest";
import { createStartedCampaignSave } from "../core/CampaignRules";
import { CAMPAIGN_NODES } from "./campaignNodes";
import {
  CAMPAIGN_MODIFIERS,
  applyCampaignCaptureSiteModifierEffects,
  applyCampaignEnemyAIModifierEffects,
  applyCampaignResourceRewardModifiers,
  consumeBattleCampaignModifiers,
  getCampaignBattleModifierEffects,
  grantCampaignModifiers
} from "./campaignModifiers";
import { getStrongholdBattleEffects } from "./strongholdUpgrades";

describe("campaign modifiers", () => {
  it("defines the initial visible consequence modifiers", () => {
    expect(CAMPAIGN_MODIFIERS.map((modifier) => modifier.id)).toEqual([
      "inspired_militia",
      "blessed_road",
      "well_rested",
      "angered_raiders",
      "local_support",
      "ashen_hostile_pressure",
      "marsh_guides",
      "ash_filters",
      "shrine_attunement",
      "mission_rich_veins",
      "mission_enemy_patrols",
      "mission_fortified_enemy",
      "mission_aether_surge"
    ]);
    expect(CAMPAIGN_MODIFIERS.filter((modifier) => modifier.trigger.includes("battle")).length).toBeGreaterThanOrEqual(3);
  });

  it("projects mission scenario modifiers into conservative battle effects", () => {
    const effects = getCampaignBattleModifierEffects([
      { id: "mission_rich_veins" },
      { id: "mission_enemy_patrols" },
      { id: "mission_fortified_enemy" }
    ]);

    expect(effects.captureSiteIncomeMultiplier).toBe(1.1);
    expect(effects.enemyAttackIntervalMultiplier).toBe(0.95);
    expect(effects.enemyInitialAttackDelayMultiplier).toBe(1.06);
    expect(effects.enemyDefenseSquadSizeBonus).toBe(1);
  });

  it("applies mission income and AI hooks only through launch modifiers", () => {
    const site = {
      id: "test_site",
      name: "Test Site",
      resource: "crowns" as const,
      x: 100,
      y: 100,
      radius: 60,
      incomeAmount: 10,
      incomeInterval: 8
    };
    const aiConfig = {
      incomeInterval: 5,
      incomePerTick: { crowns: 12 },
      trainInterval: 20,
      expandInterval: 70,
      initialExpandDelay: 45,
      attackInterval: 80,
      initialAttackDelay: 120,
      minAttackArmySize: 4,
      attackWaveSize: 5,
      expandSquadSize: 3,
      defenseSquadSize: 4,
      defendRadius: 220,
      baseBuildingId: "enemy_stronghold",
      productionBuildingId: "enemy_barracks",
      attackTargetBuildingId: "command_hall",
      unitPlan: ["raider"]
    };

    expect(applyCampaignCaptureSiteModifierEffects(site, [{ id: "mission_rich_veins" }]).incomeAmount).toBe(11);
    expect(applyCampaignCaptureSiteModifierEffects(site, []).incomeAmount).toBe(10);
    expect(
      applyCampaignEnemyAIModifierEffects(aiConfig, [
        { id: "mission_enemy_patrols" },
        { id: "mission_fortified_enemy" }
      ])
    ).toMatchObject({
      attackInterval: 76,
      initialAttackDelay: 127,
      defenseSquadSize: 5
    });
    expect(applyCampaignEnemyAIModifierEffects(aiConfig, [])).toBe(aiConfig);
  });

  it("grants one-use battle modifiers and consumes them on matching launches", () => {
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "old_stone_road")!;
    const campaign = grantCampaignModifiers(createStartedCampaignSave(), ["inspired_militia", "blessed_road", "well_rested", "local_support"]);

    const consumed = consumeBattleCampaignModifiers({ campaign, node });

    expect(consumed.launchModifiers.map((modifier) => modifier.id)).toEqual(["inspired_militia", "blessed_road", "well_rested"]);
    expect(consumed.campaign.activeModifierIds).toEqual(["local_support"]);
    expect(consumed.consumedModifierIds).toEqual(["inspired_militia", "blessed_road", "well_rested"]);
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

  it("only consumes Cinderfen Waystation modifiers for Chapter 2 Cinderfen battles", () => {
    const campaign = grantCampaignModifiers(createStartedCampaignSave(), ["marsh_guides", "ash_filters", "shrine_attunement"]);
    const oldRoad = CAMPAIGN_NODES.find((entry) => entry.id === "old_stone_road")!;
    const cinderfen = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_crossing")!;
    const watch = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_watch")!;

    const skipped = consumeBattleCampaignModifiers({ campaign, node: oldRoad });
    const consumed = consumeBattleCampaignModifiers({ campaign, node: cinderfen });
    const watchConsumed = consumeBattleCampaignModifiers({ campaign, node: watch });

    expect(skipped.launchModifiers).toEqual([]);
    expect(skipped.campaign.activeModifierIds).toEqual(["marsh_guides", "ash_filters", "shrine_attunement"]);
    expect(consumed.launchModifiers.map((modifier) => modifier.id)).toEqual([
      "marsh_guides",
      "ash_filters",
      "shrine_attunement"
    ]);
    expect(consumed.campaign.activeModifierIds).toEqual([]);
    expect(watchConsumed.launchModifiers.map((modifier) => modifier.id)).toEqual(["marsh_guides", "ash_filters"]);
    expect(watchConsumed.campaign.activeModifierIds).toEqual(["shrine_attunement"]);
  });

  it("projects Cinderfen service modifiers into battle launch effects", () => {
    const effects = getStrongholdBattleEffects([{ id: "marsh_guides" }, { id: "ash_filters" }, { id: "shrine_attunement" }]);

    expect(effects.buildingVisionBonus).toBe(60);
    expect(effects.enemyWarningLeadSeconds).toBe(20);
    expect(effects.heroMaxHpMultiplier).toBe(1.08);
    expect(effects.heroMaxManaMultiplier).toBe(1.08);
    expect(effects.firstCaptureBonusResourceAdditions.cinder_crossing).toEqual({ crowns: 0, stone: 0, iron: 0, aether: 5 });
  });

  it("applies Local Support to one campaign resource reward", () => {
    const campaign = grantCampaignModifiers(createStartedCampaignSave(), ["local_support"]);

    const applied = applyCampaignResourceRewardModifiers({
      campaign,
      resources: { crowns: 50, stone: 35 }
    });

    expect(applied.resources).toEqual({ crowns: 57, stone: 40 });
    expect(applied.consumedModifierIds).toEqual(["local_support"]);
    expect(applied.campaign.activeModifierIds).toEqual([]);
  });
});
