import { describe, expect, it } from "vitest";
import { ACT1_FINALE_PHASES, isAct1FinaleBattle } from "./act1Finale";

describe("act1Finale data", () => {
  it("defines exactly three readable finale phases", () => {
    expect(ACT1_FINALE_PHASES.map((phase) => phase.id)).toEqual([
      "secure_foothold",
      "break_fortified_line",
      "defeat_rival_commander"
    ]);
    expect(ACT1_FINALE_PHASES.every((phase) => phase.objective.length > 20)).toBe(true);
  });

  it("enables only eligible non-Tutorial Ashen Outpost campaign battles", () => {
    expect(
      isAct1FinaleBattle({
        mode: "campaign_node",
        campaignNodeId: "ashen_outpost",
        mapId: "ashen_outpost"
      })
    ).toBe(true);
    expect(
      isAct1FinaleBattle({
        mode: "tutorial",
        campaignNodeId: "ashen_outpost",
        mapId: "ashen_outpost"
      })
    ).toBe(false);
    expect(
      isAct1FinaleBattle({
        mode: "campaign_node",
        campaignNodeId: "ashen_outpost",
        mapId: "ashen_outpost",
        rewardsDisabled: true
      })
    ).toBe(false);
  });
});
