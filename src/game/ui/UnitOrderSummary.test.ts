import { describe, expect, it } from "vitest";
import { describeUnitOrder, summarizeUnitOrders } from "./UnitOrderSummary";

describe("UnitOrderSummary", () => {
  it("describes explicit attack orders", () => {
    expect(describeUnitOrder({ attackTargetId: "enemy-raider" })).toMatchObject({
      label: "Attacking",
      tone: "active"
    });
  });

  it("distinguishes attack-move from normal movement", () => {
    expect(describeUnitOrder({ moveTarget: { x: 100, y: 200 }, attackMove: true }).label).toBe("Attack-moving");
    expect(describeUnitOrder({ moveTarget: { x: 100, y: 200 }, attackMove: false }).label).toBe("Moving");
  });

  it("describes idle units as guarding nearby space", () => {
    expect(describeUnitOrder({})).toMatchObject({
      label: "Guarding",
      detail: expect.stringContaining("nearby threats")
    });
  });

  it("summarizes mixed selected unit orders", () => {
    expect(
      summarizeUnitOrders([
        { moveTarget: { x: 10, y: 0 } },
        { moveTarget: { x: 12, y: 0 } },
        { attackTargetId: "enemy" },
        {}
      ])
    ).toBe("2 Moving, 1 Attacking, 1 Guarding");
  });
});
