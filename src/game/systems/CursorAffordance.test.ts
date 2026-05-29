import { describe, expect, it } from "vitest";
import { battleCursorView, deriveBattleCursorIntent } from "./CursorAffordance";

const worker = {
  id: "worker-1",
  alive: true,
  team: "player" as const,
  definition: {
    id: "worker",
    buildOptions: ["barracks", "mystic_lodge", "watchtower"]
  }
};

const hero = {
  id: "hero-1",
  alive: true,
  team: "player" as const,
  definition: {
    id: "warlord"
  }
};

describe("CursorAffordance", () => {
  it("shows attack intent over hostile units and buildings when a player unit is selected", () => {
    expect(
      deriveBattleCursorIntent(
        {
          alive: true,
          kind: "unit",
          team: "enemy"
        },
        [hero]
      )
    ).toBe("attack");
    expect(battleCursorView("attack")).toEqual({
      intent: "attack",
      cursor: "crosshair",
      label: "Attack target"
    });
  });

  it("shows Worker build and repair affordances for friendly building targets", () => {
    expect(
      deriveBattleCursorIntent(
        {
          alive: true,
          kind: "building",
          team: "player",
          definition: { id: "barracks" },
          isUnderConstruction: () => true
        },
        [worker]
      )
    ).toBe("build");
    expect(
      deriveBattleCursorIntent(
        {
          alive: true,
          kind: "building",
          team: "player",
          definition: { id: "barracks" },
          hp: 120,
          maxHp: 300,
          isCompleted: () => true
        },
        [worker]
      )
    ).toBe("repair");
    expect(battleCursorView("repair")).toEqual({
      intent: "repair",
      cursor: "copy",
      label: "Repair damaged building"
    });
  });

  it("shows Worker assignment affordance only for assignable friendly resource sites", () => {
    expect(
      deriveBattleCursorIntent(
        {
          alive: true,
          kind: "capture-site",
          team: "player",
          owner: "player",
          siteLevel: 1,
          workerAssignments: []
        },
        [worker]
      )
    ).toBe("assign");
    expect(
      deriveBattleCursorIntent(
        {
          alive: true,
          kind: "capture-site",
          team: "neutral",
          owner: "neutral",
          siteLevel: 1,
          workerAssignments: []
        },
        [worker]
      )
    ).toBe("invalid");
  });

  it("keeps empty terrain neutral and marks rejected Worker targets invalid", () => {
    expect(deriveBattleCursorIntent(undefined, [worker])).toBe("");
    expect(
      deriveBattleCursorIntent(
        {
          alive: true,
          kind: "building",
          team: "player",
          definition: { id: "barracks" },
          hp: 300,
          maxHp: 300,
          isCompleted: () => true
        },
        [worker]
      )
    ).toBe("invalid");
    expect(battleCursorView("invalid")).toEqual({
      intent: "invalid",
      cursor: "not-allowed",
      label: "Invalid target"
    });
  });
});
