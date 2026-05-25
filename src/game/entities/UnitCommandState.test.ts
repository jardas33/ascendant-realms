import { describe, expect, it } from "vitest";
import { Unit } from "./Unit";

function commandStateUnit(): Unit {
  return Object.assign(Object.create(Unit.prototype), {
    activeResourceSiteId: "crown-site",
    activeResourceSiteLabel: "Crown Shrine",
    attackTargetId: undefined,
    attackTargetLabel: undefined,
    attackMove: false,
    moveTarget: undefined
  }) as Unit;
}

describe("Unit command state", () => {
  it("clears resource-site assignment when explicit move, attack, build, or repair orders take over", () => {
    const moveWorker = commandStateUnit();
    moveWorker.commandMove({ x: 320, y: 420 });
    expect(moveWorker.activeResourceSiteId).toBeUndefined();

    const attackWorker = commandStateUnit();
    attackWorker.commandAttack("enemy-building", "Enemy Building");
    expect(attackWorker.activeResourceSiteId).toBeUndefined();

    const constructionWorker = commandStateUnit();
    constructionWorker.commandConstructionMove({ x: 360, y: 460 }, "barracks-site");
    expect(constructionWorker.activeResourceSiteId).toBeUndefined();
    expect(constructionWorker.activeConstructionSiteId).toBe("barracks-site");

    const repairWorker = commandStateUnit();
    repairWorker.commandRepairMove({ x: 410, y: 500 }, "barracks");
    expect(repairWorker.activeResourceSiteId).toBeUndefined();
    expect(repairWorker.activeRepairTargetId).toBe("barracks");
  });
});
