import { describe, expect, it } from "vitest";
import { describeUnitOrder, summarizeUnitOrders } from "./UnitOrderSummary";

describe("UnitOrderSummary", () => {
  it("describes explicit attack orders", () => {
    expect(describeUnitOrder({ attackTargetId: "enemy-raider", attackTargetLabel: "Raider" })).toMatchObject({
      label: "Attacking",
      detail: expect.stringContaining("Target: Raider"),
      tone: "active"
    });
  });

  it("distinguishes attack-move from normal movement", () => {
    expect(describeUnitOrder({ moveTarget: { x: 100, y: 200 }, attackMove: true }).label).toBe("Attack-moving");
    expect(describeUnitOrder({ moveTarget: { x: 100, y: 200 }, attackMove: false })).toMatchObject({
      label: "Moving",
      detail: expect.stringContaining("use attack-move")
    });
    expect(
      describeUnitOrder({
        moveTarget: { x: 100, y: 200 },
        attackMove: false,
        moveOrderCombatSuppressionSeconds: 0.5
      })
    ).toMatchObject({
      label: "Repositioning",
      detail: expect.stringContaining("Retreat or move order")
    });
  });

  it("describes idle units as guarding nearby space", () => {
    expect(describeUnitOrder({ behaviourMode: "guard_area" })).toMatchObject({
      label: "Guarding",
      detail: expect.stringContaining("Defending nearby space")
    });
    expect(describeUnitOrder({ behaviourMode: "hold_ground" })).toMatchObject({
      label: "Holding Ground",
      detail: expect.stringContaining("immediate threats")
    });
    expect(describeUnitOrder({ behaviourMode: "press_attack" })).toMatchObject({
      label: "Pressing Attack",
      detail: expect.stringContaining("more assertively")
    });
  });

  it("describes active and paused Worker repair orders", () => {
    expect(describeUnitOrder({ activeRepairTargetId: "player-barracks", moveTarget: { x: 400, y: 600 } })).toMatchObject({
      label: "Repairing",
      detail: expect.stringContaining("Worker must stay near")
    });
    expect(
      describeUnitOrder({
        pausedRepairTargetId: "player-barracks",
        moveTarget: { x: 120, y: 120 },
        moveOrderCombatSuppressionSeconds: 0.5
      })
    ).toMatchObject({
      label: "Repair Paused",
      detail: expect.stringContaining("Issue Repair again")
    });
  });

  it("keeps explicit move and attack copy ahead of behaviour mode copy", () => {
    expect(
      describeUnitOrder({
        behaviourMode: "hold_ground",
        attackTargetId: "enemy-hexer",
        attackTargetLabel: "Hexer"
      })
    ).toMatchObject({
      label: "Attacking",
      detail: expect.stringContaining("Target: Hexer")
    });
    expect(
      describeUnitOrder({
        behaviourMode: "press_attack",
        moveTarget: { x: 220, y: 140 },
        moveOrderCombatSuppressionSeconds: 0.2
      })
    ).toMatchObject({
      label: "Repositioning",
      detail: expect.stringContaining("target reacquisition waits briefly")
    });
  });

  it("summarizes mixed selected unit orders", () => {
    expect(
      summarizeUnitOrders([
        { moveTarget: { x: 10, y: 0 } },
        { moveTarget: { x: 12, y: 0 }, moveOrderCombatSuppressionSeconds: 0.3 },
        { attackTargetId: "enemy" },
        { behaviourMode: "hold_ground" }
      ])
    ).toBe("1 Moving, 1 Repositioning, 1 Attacking, 1 Holding Ground");
  });
});
