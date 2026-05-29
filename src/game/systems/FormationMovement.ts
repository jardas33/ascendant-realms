import { FORMATION_SPACING } from "../core/Constants";
import type { BattleMapDefinition, Position } from "../core/GameTypes";
import { clamp, distance, formationOffset } from "../core/MathUtils";
import type { Building } from "../entities/Building";
import type { Unit } from "../entities/Unit";

const OFFSET_SEARCH_SHRINKS = [1, 0.65, 0.35] as const;
const BUILDING_PADDING = 18;
const MAX_OFFSET_DISTANCE = FORMATION_SPACING * 4;

export interface FormationMoveOptions {
  map: BattleMapDefinition;
  buildings?: Building[];
  spacing?: number;
}

export function createFormationMoveTargets(
  clickedPoint: Position,
  units: readonly Unit[],
  options: FormationMoveOptions
): Position[] {
  const spacing = options.spacing ?? FORMATION_SPACING;
  return units.map((unit, index) => {
    if (index === 0 || units.length === 1) {
      return clampForUnit(clickedPoint, unit, options.map);
    }

    const offset = formationOffset(index, spacing);
    const candidate = firstSafeCandidate(clickedPoint, offset, unit, options);
    return candidate ?? clampForUnit(clickedPoint, unit, options.map);
  });
}

function firstSafeCandidate(
  clickedPoint: Position,
  offset: Position,
  unit: Unit,
  options: FormationMoveOptions
): Position | undefined {
  for (const shrink of OFFSET_SEARCH_SHRINKS) {
    const candidate = clampForUnit(
      {
        x: clickedPoint.x + offset.x * shrink,
        y: clickedPoint.y + offset.y * shrink
      },
      unit,
      options.map
    );
    if (isSafeDestination(candidate, clickedPoint, unit, options)) {
      return candidate;
    }
  }
  return undefined;
}

function isSafeDestination(point: Position, clickedPoint: Position, unit: Unit, options: FormationMoveOptions): boolean {
  if (distance(point, clickedPoint) > MAX_OFFSET_DISTANCE) {
    return false;
  }
  if (options.map.terrainZones.some((zone) => (zone.type === "blocked" || zone.type === "water") && pointInRect(point, zone, unit.radius))) {
    return false;
  }
  return !(options.buildings ?? []).some((building) => {
    if (!building.alive) {
      return false;
    }
    const size = building.definition.size;
    return pointInRect(
      point,
      {
        x: building.position.x - size.width / 2,
        y: building.position.y - size.height / 2,
        width: size.width,
        height: size.height
      },
      BUILDING_PADDING + unit.radius
    );
  });
}

function clampForUnit(point: Position, unit: Unit, map: BattleMapDefinition): Position {
  return {
    x: clamp(point.x, unit.radius, map.width - unit.radius),
    y: clamp(point.y, unit.radius, map.height - unit.radius)
  };
}

function pointInRect(point: Position, rect: { x: number; y: number; width: number; height: number }, padding: number): boolean {
  return (
    point.x >= rect.x - padding &&
    point.x <= rect.x + rect.width + padding &&
    point.y >= rect.y - padding &&
    point.y <= rect.y + rect.height + padding
  );
}
