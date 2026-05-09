import { describe, expect, it } from "vitest";
import { CAMPAIGN_NODE_BY_ID, MAP_BY_ID, UNIT_BY_ID, requireEnemyPressurePlan } from "./contentIndex";
import { ENEMY_PRESSURE_PLANS } from "./enemyPressurePlans";

describe("enemy pressure plan metadata", () => {
  it("defines the two scoped V1 pressure plans without attaching runtime behavior", () => {
    expect(ENEMY_PRESSURE_PLANS.map((plan) => plan.id)).toEqual([
      "ashen_watch_captain_pressure",
      "causeway_contest_pressure"
    ]);
    expect(ENEMY_PRESSURE_PLANS.every((plan) => plan.scope === "campaign_node")).toBe(true);
    expect(ENEMY_PRESSURE_PLANS.every((plan) => plan.enabledByDefault)).toBe(true);
  });

  it("references only existing V1 nodes, maps, and unit ids", () => {
    ENEMY_PRESSURE_PLANS.forEach((plan) => {
      expect(plan.allowedNodeIds.every((nodeId) => CAMPAIGN_NODE_BY_ID[nodeId])).toBe(true);
      expect(plan.allowedMapIds.every((mapId) => MAP_BY_ID[mapId])).toBe(true);
      plan.stages.forEach((stage) => {
        stage.action.unitIds?.forEach((unitId) => expect(UNIT_BY_ID[unitId]).toBeDefined());
      });
    });
  });

  it("keeps the V1 notes explicit that pressure is not construction or workers", () => {
    ENEMY_PRESSURE_PLANS.forEach((plan) => {
      expect(plan.notes).toContain("Pressure events only");
      expect(plan.notes).toContain("must not place buildings");
      expect(plan.notes).toContain("create workers");
      expect(plan.notes).toContain("simulate enemy construction");
    });
  });

  it("indexes pressure plans for future validation and launch resolution", () => {
    expect(requireEnemyPressurePlan("ashen_watch_captain_pressure").allowedNodeIds).toEqual(["cinderfen_watch"]);
    expect(requireEnemyPressurePlan("causeway_contest_pressure").allowedMapIds).toEqual(["cinderfen_causeway"]);
  });
});
