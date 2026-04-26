import { describe, expect, it, vi } from "vitest";
import type { Team } from "../core/GameTypes";
import {
  applyRallyPointToTrainedUnit,
  canUseRallyPoint,
  setBuildingRallyPoint,
  setRallyPointForBuildings,
  type RallyCapableBuilding
} from "./RallyPointSystem";

function createBuilding(options: Partial<RallyCapableBuilding> = {}): RallyCapableBuilding {
  return {
    alive: true,
    team: "player" as Team,
    definition: { trainOptions: ["militia"] },
    isCompleted: () => true,
    ...options
  };
}

describe("RallyPointSystem", () => {
  it("sets a ground rally point on completed player production buildings", () => {
    const building = createBuilding();

    expect(setBuildingRallyPoint(building, { x: 420, y: 260 })).toBe(true);
    expect(building.rallyPoint).toEqual({ x: 420, y: 260 });
    expect(building.rallyTargetId).toBeUndefined();
  });

  it("sets the same rally point for multiple selected production buildings", () => {
    const barracks = createBuilding();
    const lodge = createBuilding();

    const result = setRallyPointForBuildings([barracks, lodge], { x: 800, y: 540 });

    expect(result.updatedCount).toBe(2);
    expect(barracks.rallyPoint).toEqual({ x: 800, y: 540 });
    expect(lodge.rallyPoint).toEqual({ x: 800, y: 540 });
  });

  it("does not set rally points on destroyed, enemy, incomplete, or non-production buildings", () => {
    const buildings = [
      createBuilding({ alive: false }),
      createBuilding({ team: "enemy" }),
      createBuilding({ isCompleted: () => false }),
      createBuilding({ definition: { trainOptions: [] } })
    ];

    const result = setRallyPointForBuildings(buildings, { x: 100, y: 100 });

    expect(result.updatedCount).toBe(0);
    buildings.forEach((building) => {
      expect(canUseRallyPoint(building)).toBe(false);
      expect(building.rallyPoint).toBeUndefined();
    });
  });

  it("commands a newly trained unit to move to the building rally point", () => {
    const building = createBuilding({ rallyPoint: { x: 640, y: 320 } });
    const unit = {
      commandMove: vi.fn()
    };

    expect(applyRallyPointToTrainedUnit(building, unit)).toBe(true);
    expect(unit.commandMove).toHaveBeenCalledWith({ x: 640, y: 320 }, false);
  });
});
