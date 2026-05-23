import type { BattleMapDefinition, Position } from "../core/GameTypes";
import { clamp, distance, normalizeVector } from "../core/MathUtils";
import type { Building } from "../entities/Building";
import type { Unit } from "../entities/Unit";
import { DEFAULT_PATHFINDING_CELL_SIZE, PathfindingGrid, type PathfindingStaticObstacle } from "./PathfindingGrid";

interface MovementSystemOptions {
  onPathFailed?: (unit: Unit, target: Position) => void;
}

interface UnitPathState {
  destination?: Position;
  waypoints: Position[];
  waypointIndex: number;
  lastPosition: Position;
  stuckSeconds: number;
  repathCooldown: number;
  lastFailureTarget?: Position;
}

const WAYPOINT_REACHED_DISTANCE = 18;
const DESTINATION_REACHED_DISTANCE = 5;
const TARGET_REPATH_DISTANCE = 36;
const STUCK_DISTANCE_EPSILON = 4;
const STUCK_SECONDS_BEFORE_REPATH = 0.75;
const REPATH_COOLDOWN_SECONDS = 0.55;
const MAX_GRID_CORRECTION_DISTANCE = 20;
const BLOCKED_START_CORRECTION_SEARCH_CELLS = 4;
const BLOCKED_START_MAX_CORRECTION_DISTANCE = DEFAULT_PATHFINDING_CELL_SIZE * 1.75;

export class MovementSystem {
  private readonly unitPathStates = new Map<string, UnitPathState>();

  constructor(private readonly options: MovementSystemOptions = {}) {}

  update(deltaSeconds: number, units: Unit[], map: BattleMapDefinition, buildings: Building[] = []): void {
    const grid = PathfindingGrid.fromMap(map, {
      cellSize: DEFAULT_PATHFINDING_CELL_SIZE,
      staticObstacles: this.staticObstaclesForBuildings(buildings)
    });
    this.pruneUnitStates(units);

    units.forEach((unit) => {
      if (!unit.alive) {
        return;
      }
      unit.updateBuffs(deltaSeconds);
      if (!unit.moveTarget) {
        this.unitPathStates.delete(unit.id);
        return;
      }

      if (distance(unit.position, unit.moveTarget) <= DESTINATION_REACHED_DISTANCE) {
        unit.moveTarget = undefined;
        unit.moveOrderCombatSuppressionSeconds = 0;
        this.unitPathStates.delete(unit.id);
        return;
      }
      this.correctBlockedMoveStart(unit, map, grid);

      const state = this.pathStateFor(unit);
      state.repathCooldown = Math.max(0, state.repathCooldown - deltaSeconds);
      this.updateStuckState(unit, state, deltaSeconds);
      this.ensurePath(unit, state, grid);
      this.followPath(unit, state, deltaSeconds, map, grid);
    });

    this.applySeparation(units, map, grid);
  }

  private ensurePath(unit: Unit, state: UnitPathState, grid: PathfindingGrid): void {
    if (!unit.moveTarget) {
      return;
    }
    const targetChanged = !state.destination || distance(state.destination, unit.moveTarget) > TARGET_REPATH_DISTANCE;
    const needsInitialPath = state.waypoints.length === 0 && state.repathCooldown === 0;
    const needsStuckRepath = state.stuckSeconds >= STUCK_SECONDS_BEFORE_REPATH && state.repathCooldown === 0;
    if (!targetChanged && !needsInitialPath && !needsStuckRepath) {
      return;
    }

    const result = grid.findPath(unit.position, unit.moveTarget, { allowPartial: true });
    state.destination = { ...unit.moveTarget };
    state.repathCooldown = REPATH_COOLDOWN_SECONDS;
    state.stuckSeconds = 0;
    if (!result || result.waypoints.length === 0) {
      state.waypoints = [];
      state.waypointIndex = 0;
      this.reportPathFailure(unit, state, unit.moveTarget);
      return;
    }
    state.waypoints = result.waypoints;
    state.waypointIndex = 0;
    if (!result.complete) {
      this.reportPathFailure(unit, state, unit.moveTarget);
    }
  }

  private followPath(unit: Unit, state: UnitPathState, deltaSeconds: number, map: BattleMapDefinition, grid: PathfindingGrid): void {
    if (!unit.moveTarget) {
      return;
    }
    while (state.waypointIndex < state.waypoints.length && distance(unit.position, state.waypoints[state.waypointIndex]) <= WAYPOINT_REACHED_DISTANCE) {
      state.waypointIndex += 1;
    }

    const waypoint = state.waypoints[state.waypointIndex];
    if (!waypoint) {
      unit.moveTarget = undefined;
      this.unitPathStates.delete(unit.id);
      return;
    }
    const dx = waypoint.x - unit.position.x;
    const dy = waypoint.y - unit.position.y;
    const remaining = Math.hypot(dx, dy);
    if (remaining <= DESTINATION_REACHED_DISTANCE) {
      unit.moveTarget = undefined;
      unit.moveOrderCombatSuppressionSeconds = 0;
      this.unitPathStates.delete(unit.id);
      return;
    }

    const step = Math.min(remaining, unit.speed * deltaSeconds);
    const next = {
      x: clamp(unit.position.x + (dx / remaining) * step, unit.radius, map.width - unit.radius),
      y: clamp(unit.position.y + (dy / remaining) * step, unit.radius, map.height - unit.radius)
    };
    if (grid.isWorldWalkable(next)) {
      unit.setPosition(next.x, next.y);
      return;
    }

    const nearest = grid.findNearestWalkablePoint(next, 2);
    if (nearest && distance(nearest, unit.position) <= Math.max(MAX_GRID_CORRECTION_DISTANCE, step + unit.radius)) {
      unit.setPosition(
        clamp(nearest.x, unit.radius, map.width - unit.radius),
        clamp(nearest.y, unit.radius, map.height - unit.radius)
      );
    }
  }

  private correctBlockedMoveStart(unit: Unit, map: BattleMapDefinition, grid: PathfindingGrid): void {
    if (grid.isWorldWalkable(unit.position)) {
      return;
    }
    const nearest = grid.findNearestWalkablePoint(unit.position, BLOCKED_START_CORRECTION_SEARCH_CELLS);
    if (!nearest || distance(nearest, unit.position) > BLOCKED_START_MAX_CORRECTION_DISTANCE) {
      return;
    }
    unit.setPosition(
      clamp(nearest.x, unit.radius, map.width - unit.radius),
      clamp(nearest.y, unit.radius, map.height - unit.radius)
    );
    this.unitPathStates.delete(unit.id);
  }

  private updateStuckState(unit: Unit, state: UnitPathState, deltaSeconds: number): void {
    if (distance(unit.position, state.lastPosition) <= STUCK_DISTANCE_EPSILON) {
      state.stuckSeconds += deltaSeconds;
    } else {
      state.stuckSeconds = 0;
      state.lastFailureTarget = undefined;
    }
    state.lastPosition = { ...unit.position };
  }

  private pathStateFor(unit: Unit): UnitPathState {
    const existing = this.unitPathStates.get(unit.id);
    if (existing) {
      return existing;
    }
    const state: UnitPathState = {
      waypoints: [],
      waypointIndex: 0,
      lastPosition: { ...unit.position },
      stuckSeconds: 0,
      repathCooldown: 0
    };
    this.unitPathStates.set(unit.id, state);
    return state;
  }

  private reportPathFailure(unit: Unit, state: UnitPathState, target: Position): void {
    if (state.lastFailureTarget && distance(state.lastFailureTarget, target) < TARGET_REPATH_DISTANCE) {
      return;
    }
    state.lastFailureTarget = { ...target };
    this.options.onPathFailed?.(unit, target);
  }

  private pruneUnitStates(units: Unit[]): void {
    const aliveIds = new Set(units.filter((unit) => unit.alive).map((unit) => unit.id));
    this.unitPathStates.forEach((_, unitId) => {
      if (!aliveIds.has(unitId)) {
        this.unitPathStates.delete(unitId);
      }
    });
  }

  private staticObstaclesForBuildings(buildings: Building[]): PathfindingStaticObstacle[] {
    return buildings
      .filter((building) => building.alive)
      .map((building) => ({
        id: building.id,
        x: building.position.x,
        y: building.position.y,
        width: building.definition.size.width,
        height: building.definition.size.height,
        padding: 16
      }));
  }

  private applySeparation(units: Unit[], map: BattleMapDefinition, grid: PathfindingGrid): void {
    for (let i = 0; i < units.length; i += 1) {
      const a = units[i];
      if (!a.alive) {
        continue;
      }
      for (let j = i + 1; j < units.length; j += 1) {
        const b = units[j];
        if (!b.alive || a.team !== b.team) {
          continue;
        }
        const minDistance = a.radius + b.radius + 5;
        const currentDistance = distance(a.position, b.position);
        if (currentDistance <= 0 || currentDistance >= minDistance) {
          continue;
        }
        const push = (minDistance - currentDistance) * 0.5;
        const direction = normalizeVector(a.position.x - b.position.x, a.position.y - b.position.y);
        this.setSeparatedPosition(
          a,
          {
            x: clamp(a.position.x + direction.x * push, a.radius, map.width - a.radius),
            y: clamp(a.position.y + direction.y * push, a.radius, map.height - a.radius)
          },
          grid
        );
        this.setSeparatedPosition(
          b,
          {
            x: clamp(b.position.x - direction.x * push, b.radius, map.width - b.radius),
            y: clamp(b.position.y - direction.y * push, b.radius, map.height - b.radius)
          },
          grid
        );
      }
    }
  }

  private setSeparatedPosition(unit: Unit, point: Position, grid: PathfindingGrid): void {
    if (grid.isWorldWalkable(point)) {
      unit.setPosition(point.x, point.y);
      return;
    }
    const nearest = grid.findNearestWalkablePoint(point, 1);
    if (nearest && distance(nearest, unit.position) <= MAX_GRID_CORRECTION_DISTANCE) {
      unit.setPosition(nearest.x, nearest.y);
    }
  }
}
