import type { Position, Team } from "../core/GameTypes";

export interface RallyCapableBuilding {
  alive: boolean;
  team: Team;
  definition: {
    trainOptions: string[];
  };
  isCompleted(): boolean;
  rallyPoint?: Position;
  rallyTargetId?: string;
}

export interface RallyCommandableUnit {
  commandMove(target: Position, attackMove?: boolean): void;
}

export interface RallyPointAssignment {
  updatedCount: number;
  rallyPoint: Position;
}

export function canUseRallyPoint(building: RallyCapableBuilding): boolean {
  return building.alive && building.team === "player" && building.isCompleted() && building.definition.trainOptions.length > 0;
}

export function setBuildingRallyPoint(
  building: RallyCapableBuilding,
  point: Position,
  options: { rallyTargetId?: string } = {}
): boolean {
  if (!canUseRallyPoint(building)) {
    return false;
  }
  building.rallyPoint = { x: point.x, y: point.y };
  building.rallyTargetId = options.rallyTargetId;
  return true;
}

export function setRallyPointForBuildings(
  buildings: RallyCapableBuilding[],
  point: Position,
  options: { rallyTargetId?: string } = {}
): RallyPointAssignment {
  const rallyPoint = { x: point.x, y: point.y };
  const updatedCount = buildings.reduce((count, building) => {
    return setBuildingRallyPoint(building, rallyPoint, options) ? count + 1 : count;
  }, 0);

  return {
    updatedCount,
    rallyPoint
  };
}

export function applyRallyPointToTrainedUnit(building: RallyCapableBuilding, unit: RallyCommandableUnit): boolean {
  if (!building.rallyPoint) {
    return false;
  }
  unit.commandMove(building.rallyPoint, false);
  return true;
}
