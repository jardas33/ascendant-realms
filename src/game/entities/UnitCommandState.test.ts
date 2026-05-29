import { describe, expect, it } from "vitest";
import type { Position } from "../core/GameTypes";
import { Unit } from "./Unit";

describe("Unit command state", () => {
  it("starts a patrol route and cancels it on explicit move or attack", () => {
    const unit = fakeUnit({ x: 100, y: 120 });

    unit.commandPatrol({ x: 220, y: 180 });

    expect(unit.patrolRoute).toMatchObject({
      origin: { x: 100, y: 120 },
      destination: { x: 220, y: 180 },
      headingTo: "destination"
    });
    expect(unit.moveTarget).toEqual({ x: 220, y: 180 });
    expect(unit.attackMove).toBe(true);

    unit.commandMove({ x: 80, y: 80 });
    expect(unit.patrolRoute).toBeUndefined();

    unit.commandPatrol({ x: 260, y: 220 });
    unit.commandAttack("enemy-raider", "Raider");
    expect(unit.patrolRoute).toBeUndefined();
    expect(unit.attackTargetId).toBe("enemy-raider");
  });

  it("stops movement, attack, and patrol state", () => {
    const unit = fakeUnit({ x: 100, y: 120 });
    unit.commandPatrol({ x: 220, y: 180 });
    unit.attackTargetId = "enemy-raider";
    unit.attackTargetLabel = "Raider";

    unit.commandStop();

    expect(unit.patrolRoute).toBeUndefined();
    expect(unit.moveTarget).toBeUndefined();
    expect(unit.attackTargetId).toBeUndefined();
    expect(unit.attackTargetLabel).toBeUndefined();
    expect(unit.attackMove).toBe(false);
  });

  it("advances patrol legs between destination and origin", () => {
    const unit = fakeUnit({ x: 100, y: 120 });
    unit.commandPatrol({ x: 220, y: 180 });
    unit.moveTarget = undefined;

    expect(unit.advancePatrolRoute()).toBe(true);
    expect(unit.patrolRoute?.headingTo).toBe("origin");
    expect(unit.moveTarget).toEqual({ x: 100, y: 120 });
    expect(unit.attackMove).toBe(true);
  });
});

function fakeUnit(position: Position): Unit {
  return Object.assign(Object.create(Unit.prototype), {
    id: "player-militia",
    kind: "unit",
    team: "player",
    alive: true,
    position,
    definition: { id: "militia", name: "Militia" },
    attackMove: false,
    moveOrderCombatSuppressionSeconds: 0
  }) as Unit;
}
