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
      inventory: ["weathered_command_sword"],
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

    expect(nodeGuidance.title).toBe("Tutorial Battle");
    expect(resultGuidance.title).toBe("Border Village Secured");
    expect(resultGuidance.actions.join(" ")).toContain("Old Stone Road");
  });

  it("prompts inventory and skill spending when both are available", () => {
    const hero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      inventory: ["weathered_command_sword"],
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
