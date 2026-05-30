import { describe, expect, it } from "vitest";
import {
  DEFAULT_TACTICAL_PLAN_ID,
  TACTICAL_PLAN_MODIFIER_IDS,
  TACTICAL_PLANS,
  addTacticalPlanLaunchModifier,
  formatTacticalPlanRecommendation,
  getTacticalPlanBattleEffects,
  getTacticalPlanRecommendations,
  normalizeTacticalPlanId,
  tacticalPlanMatchesDoctrine
} from "./tacticalPlans";

describe("tactical plans", () => {
  it("defines three conservative launch-local plans", () => {
    expect(DEFAULT_TACTICAL_PLAN_ID).toBe("guarded_advance");
    expect(TACTICAL_PLANS.map((plan) => plan.id)).toEqual(["guarded_advance", "resource_push", "champion_hunt"]);
    expect(TACTICAL_PLANS.every((plan) => plan.tags.length > 0)).toBe(true);
    expect(normalizeTacticalPlanId("missing")).toBe("guarded_advance");
  });

  it("maps doctrines to readable counter-plan recommendations", () => {
    expect(getTacticalPlanRecommendations("raider").map((plan) => plan.id)).toEqual(["guarded_advance", "resource_push"]);
    expect(getTacticalPlanRecommendations("fortress").map((plan) => plan.id)).toEqual(["resource_push", "guarded_advance"]);
    expect(getTacticalPlanRecommendations("hunter").map((plan) => plan.id)).toEqual(["guarded_advance", "champion_hunt"]);
    expect(getTacticalPlanRecommendations("warband").map((plan) => plan.id)).toEqual(["guarded_advance", "champion_hunt"]);
    expect(formatTacticalPlanRecommendation("fortress")).toBe("Resource Push or Guarded Advance");
    expect(tacticalPlanMatchesDoctrine("resource_push", "fortress")).toBe(true);
    expect(tacticalPlanMatchesDoctrine("champion_hunt", "fortress")).toBe(false);
  });

  it("derives modest effects from launch modifiers without stacking plans", () => {
    const guarded = getTacticalPlanBattleEffects([{ id: TACTICAL_PLAN_MODIFIER_IDS.guardedAdvance }]);
    const resource = getTacticalPlanBattleEffects([{ id: TACTICAL_PLAN_MODIFIER_IDS.resourcePush }]);
    const champion = getTacticalPlanBattleEffects([{ id: TACTICAL_PLAN_MODIFIER_IDS.championHunt }]);
    const replaced = addTacticalPlanLaunchModifier(
      [{ id: TACTICAL_PLAN_MODIFIER_IDS.resourcePush }, { id: "mission_rich_veins" }],
      "champion_hunt"
    );

    expect(guarded.retinueReinforcementCostMultiplier).toBe(0.8);
    expect(resource.startingResources).toEqual({ crowns: 35, stone: 20 });
    expect(champion.heroMaxManaMultiplier).toBe(1.06);
    expect(replaced.map((modifier) => modifier.id)).toEqual(["mission_rich_veins", TACTICAL_PLAN_MODIFIER_IDS.championHunt]);
  });
});
