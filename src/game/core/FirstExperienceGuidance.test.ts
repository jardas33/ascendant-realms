import { describe, expect, it } from "vitest";
import {
  getCampaignNextAction,
  getCampaignNodeGuidance,
  getHeroProgressionGuidance,
  getResultsGuidance,
  heroHasUnequippedItems
} from "./FirstExperienceGuidance";
import { createStartedCampaignSave } from "./CampaignRules";
import { createFallbackCampaignSave } from "./SaveSystem";
import { createItemInstance } from "./HeroProgressionRules";
import { createNewHeroSave } from "../data/heroes";

describe("first experience guidance", () => {
  it("points a new campaign player to Border Village", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave(createFallbackCampaignSave());

    const guidance = getCampaignNextAction(campaign, hero);

    expect(guidance.title).toBe("Start Here");
    expect(guidance.body).toContain("Border Village");
    expect(guidance.actions).toContain("Win the battle");
  });

  it("points post-Border Village players to inventory before Old Stone Road when progression is waiting", () => {
    const hero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      inventory: [createItemInstance("weathered_command_sword", "test")],
      skillPoints: 1
    };
    const campaign = {
      ...createStartedCampaignSave(createFallbackCampaignSave()),
      completedNodeIds: ["border_village"],
      unlockedNodeIds: ["border_village", "old_stone_road"]
    };

    const guidance = getCampaignNextAction(campaign, hero);

    expect(heroHasUnequippedItems(hero)).toBe(true);
    expect(guidance.title).toBe("Strengthen Your Hero");
    expect(guidance.actions).toContain("Open Hero Inventory");
    expect(guidance.actions).toContain("Launch Old Stone Road");
  });

  it("uses Refugee Caravan as the first campaign choice moment after Old Stone Road", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = {
      ...createStartedCampaignSave(createFallbackCampaignSave()),
      completedNodeIds: ["border_village", "old_stone_road"],
      unlockedNodeIds: ["border_village", "old_stone_road", "refugee_caravan", "aether_well_ruins"]
    };

    const guidance = getCampaignNextAction(campaign, hero);

    expect(guidance.title).toBe("Campaign Choice Moment");
    expect(guidance.body).toContain("Refugee Caravan");
  });

  it("explains the role of the first battle and post-victory loop", () => {
    const nodeGuidance = getCampaignNodeGuidance("border_village");
    const resultGuidance = getResultsGuidance({
      outcome: "victory",
      completedNodeId: "border_village",
      completedNodeName: "Border Village",
      unlockedNodeNames: ["Old Stone Road"],
      rewardItemCount: 1,
      skillPointsGained: 1
    });

    expect(nodeGuidance.title).toBe("First Campaign Battle");
    expect(nodeGuidance.body).toContain("persistent campaign loop");
    expect(resultGuidance.title).toBe("Border Village Secured");
    expect(resultGuidance.actions.join(" ")).toContain("Old Stone Road");
  });

  it("marks the Cinderfen route complete after Aftermath", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = {
      ...createStartedCampaignSave(createFallbackCampaignSave()),
      completedNodeIds: [
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost",
        "cinderfen_overlook",
        "cinderfen_crossing",
        "cinderfen_watch",
        "cinderfen_aftermath"
      ],
      unlockedNodeIds: [
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost",
        "cinderfen_overlook",
        "cinderfen_waystation",
        "cinderfen_crossing",
        "cinderfen_watch",
        "cinderfen_aftermath"
      ]
    };

    const guidance = getCampaignNextAction(campaign, hero);

    expect(guidance.title).toBe("Cinderfen route secured");
    expect(guidance.body).toContain("Chapter 2 route complete");
    expect(guidance.body).toContain("future Cinderfen roads");
  });

  it("points Watch victory toward the final Cinderfen aftermath event", () => {
    const guidance = getResultsGuidance({
      outcome: "victory",
      completedNodeId: "cinderfen_watch",
      completedNodeName: "Cinderfen Watch",
      unlockedNodeNames: ["Cinderfen Aftermath"],
      rewardItemCount: 0,
      skillPointsGained: 0
    });

    expect(guidance.title).toBe("Cinderfen Watch Secured");
    expect(guidance.body).toContain("Cinderfen Aftermath");
    expect(guidance.body).toContain("current v0.3 route");
    expect(guidance.actions).toContain("Route ends after Aftermath");
  });

  it("prompts inventory and skill spending when both are available", () => {
    const hero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      inventory: [createItemInstance("weathered_command_sword", "test")],
      skillPoints: 1
    };

    const guidance = getHeroProgressionGuidance({
      hero,
      recentRewardItemCount: 1,
      skillPointsGained: 1,
      inCampaign: true
    });

    expect(guidance.title).toBe("Power Up Before The Next Node");
    expect(guidance.actions).toContain("Equip a reward item");
    expect(guidance.actions).toContain("Spend skill points");
  });
});
