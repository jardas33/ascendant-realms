import { describe, expect, it } from "vitest";
import type { Unit } from "../entities/Unit";
import { createUnitVeterancyState } from "../data/unitVeterancy";
import { isPatrolEligibleUnit, patrolEligibilityMessage } from "./PatrolRules";

describe("PatrolRules", () => {
  it("allows veteran combat units to Patrol while keeping Workers on utility duties", () => {
    const veteranMilitia = fakeUnit("militia-1", "militia", { xp: 140, damage: 9 });
    const worker = fakeUnit("worker-1", "worker", { damage: 3 });

    expect(isPatrolEligibleUnit(veteranMilitia)).toBe(true);
    expect(veteranMilitia.veterancy.rank).toBe("veteran");
    expect(isPatrolEligibleUnit(worker)).toBe(false);
    expect(patrolEligibilityMessage([worker])).toBe("Patrol needs combat units; Workers keep build, repair, and site duties.");
    expect(patrolEligibilityMessage([worker, veteranMilitia])).toBe("Patrol: click a destination");
  });

  it("rejects dead, enemy, and non-combat units", () => {
    expect(isPatrolEligibleUnit(fakeUnit("dead", "militia", { alive: false, damage: 9 }))).toBe(false);
    expect(isPatrolEligibleUnit(fakeUnit("enemy", "raider", { team: "enemy", damage: 10 }))).toBe(false);
    expect(isPatrolEligibleUnit(fakeUnit("pacifist", "militia", { damage: 0 }))).toBe(false);
  });
});

function fakeUnit(
  id: string,
  unitId: string,
  options: { alive?: boolean; team?: "player" | "enemy"; xp?: number; damage?: number } = {}
): Unit {
  return {
    id,
    alive: options.alive ?? true,
    team: options.team ?? "player",
    kind: "unit",
    veterancy: createUnitVeterancyState(id, unitId, options.xp ?? 0),
    definition: {
      id: unitId,
      stats: {
        damage: options.damage ?? 0
      }
    }
  } as Unit;
}
