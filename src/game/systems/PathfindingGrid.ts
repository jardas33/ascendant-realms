import type { BattleMapDefinition, Position, TerrainZoneDefinition } from "../core/GameTypes";
import { clamp, distance } from "../core/MathUtils";

export const DEFAULT_PATHFINDING_CELL_SIZE = 80;

export interface PathfindingCell {
  x: number;
  y: number;
  center: Position;
  walkable: boolean;
  blockedTerrain: boolean;
  staticBlocked: boolean;
  softBlocked: boolean;
}

export interface PathfindingStaticObstacle {
  id?: string;
  x: number;
  y: number;
  width: number;
  height: number;
  padding?: number;
}

export interface PathfindingGridOptions {
  cellSize?: number;
  staticObstacles?: PathfindingStaticObstacle[];
}

export interface PathfindingResult {
  waypoints: Position[];
  complete: boolean;
  startCell: GridCoord;
  endCell: GridCoord;
}

export interface GridCoord {
  x: number;
  y: number;
}

interface SearchNode extends GridCoord {
  key: string;
  g: number;
  f: number;
}

interface Rectangle {
  x: number;
  y: number;
  width: number;
  height: number;
}

const DIRECTIONS: GridCoord[] = [
  { x: 1, y: 0 },
  { x: -1, y: 0 },
  { x: 0, y: 1 },
  { x: 0, y: -1 },
  { x: 1, y: 1 },
  { x: 1, y: -1 },
  { x: -1, y: 1 },
  { x: -1, y: -1 }
];

export class PathfindingGrid {
  readonly columns: number;
  readonly rows: number;
  readonly cells: PathfindingCell[];
  private readonly blockedTerrainRectangles: Rectangle[] = [];
  private readonly staticObstacleRectangles: Rectangle[] = [];

  constructor(
    readonly width: number,
    readonly height: number,
    readonly cellSize = DEFAULT_PATHFINDING_CELL_SIZE,
    cells?: PathfindingCell[]
  ) {
    this.columns = Math.ceil(width / cellSize);
    this.rows = Math.ceil(height / cellSize);
    this.cells = cells ?? this.createEmptyCells();
  }

  static fromMap(map: BattleMapDefinition, options: PathfindingGridOptions = {}): PathfindingGrid {
    const grid = new PathfindingGrid(map.width, map.height, options.cellSize ?? DEFAULT_PATHFINDING_CELL_SIZE);
    grid.applyTerrainZones(map.terrainZones);
    grid.applyStaticObstacles(options.staticObstacles ?? []);
    return grid;
  }

  findPath(start: Position, goal: Position, options: { allowPartial?: boolean; maxEndpointSearchCells?: number } = {}): PathfindingResult | undefined {
    const allowPartial = options.allowPartial ?? true;
    const goalIsWalkable = this.isWorldWalkable(goal);
    const startCell = this.isWorldWalkable(start)
      ? this.worldToCell(start)
      : this.findNearestWalkableCell(start, options.maxEndpointSearchCells ?? 6);
    const endCell = goalIsWalkable ? this.worldToCell(goal) : this.findNearestWalkableCell(goal, options.maxEndpointSearchCells ?? 8);
    if (!startCell || !endCell) {
      return undefined;
    }

    if (this.sameCell(startCell, endCell)) {
      return {
        waypoints: [this.isWorldWalkable(goal) ? this.clampPoint(goal) : this.cellCenter(endCell)],
        complete: this.isWorldWalkable(goal),
        startCell,
        endCell
      };
    }

    const open: SearchNode[] = [
      {
        ...startCell,
        key: this.key(startCell),
        g: 0,
        f: this.heuristic(startCell, endCell)
      }
    ];
    const closed = new Set<string>();
    const cameFrom = new Map<string, string>();
    const gScore = new Map<string, number>([[this.key(startCell), 0]]);
    let closestKey = this.key(startCell);
    let closestScore = this.heuristic(startCell, endCell);

    while (open.length > 0) {
      open.sort((a, b) => a.f - b.f);
      const current = open.shift()!;
      if (this.sameCell(current, endCell)) {
        return this.buildResult(cameFrom, current.key, startCell, endCell, start, goal, true);
      }

      closed.add(current.key);
      const currentHeuristic = this.heuristic(current, endCell);
      if (currentHeuristic < closestScore) {
        closestKey = current.key;
        closestScore = currentHeuristic;
      }

      this.neighbors(current, goalIsWalkable ? endCell : undefined).forEach((neighbor) => {
        const neighborKey = this.key(neighbor);
        if (closed.has(neighborKey)) {
          return;
        }

        const moveCost = current.x !== neighbor.x && current.y !== neighbor.y ? 14 : 10;
        const tentativeG = current.g + moveCost;
        if (tentativeG >= (gScore.get(neighborKey) ?? Number.POSITIVE_INFINITY)) {
          return;
        }

        cameFrom.set(neighborKey, current.key);
        gScore.set(neighborKey, tentativeG);
        const existing = open.find((entry) => entry.key === neighborKey);
        const f = tentativeG + this.heuristic(neighbor, endCell);
        if (existing) {
          existing.g = tentativeG;
          existing.f = f;
          return;
        }
        open.push({ ...neighbor, key: neighborKey, g: tentativeG, f });
      });
    }

    if (!allowPartial || closestKey === this.key(startCell)) {
      return undefined;
    }
    return this.buildResult(cameFrom, closestKey, startCell, this.coordFromKey(closestKey), start, goal, false);
  }

  isWorldWalkable(point: Position): boolean {
    const cell = this.worldToCell(point);
    const current = this.cellAt(cell.x, cell.y);
    if (current.softBlocked) {
      return false;
    }
    const clampedPoint = this.clampPoint(point);
    if (this.blockedTerrainRectangles.some((rect) => this.pointInRectangle(clampedPoint, rect))) {
      return false;
    }
    if (this.staticObstacleRectangles.some((rect) => this.pointInRectangle(clampedPoint, rect))) {
      return false;
    }
    if ((current.blockedTerrain && this.blockedTerrainRectangles.length === 0) || (current.staticBlocked && this.staticObstacleRectangles.length === 0)) {
      return false;
    }
    if (current.blockedTerrain || current.staticBlocked) {
      return true;
    }
    return current.walkable;
  }

  findNearestWalkablePoint(point: Position, maxRadiusCells = 4): Position | undefined {
    const cell = this.findNearestWalkableCell(point, maxRadiusCells);
    return cell ? this.cellCenter(cell) : undefined;
  }

  worldToCell(point: Position): GridCoord {
    return {
      x: clamp(Math.floor(this.clampPoint(point).x / this.cellSize), 0, this.columns - 1),
      y: clamp(Math.floor(this.clampPoint(point).y / this.cellSize), 0, this.rows - 1)
    };
  }

  cellCenter(coord: GridCoord): Position {
    return {
      x: clamp(coord.x * this.cellSize + this.cellSize / 2, 0, this.width),
      y: clamp(coord.y * this.cellSize + this.cellSize / 2, 0, this.height)
    };
  }

  isCellWalkable(x: number, y: number): boolean {
    if (x < 0 || y < 0 || x >= this.columns || y >= this.rows) {
      return false;
    }
    return this.cellAt(x, y).walkable;
  }

  private createEmptyCells(): PathfindingCell[] {
    const cells: PathfindingCell[] = [];
    for (let y = 0; y < this.rows; y += 1) {
      for (let x = 0; x < this.columns; x += 1) {
        cells.push({
          x,
          y,
          center: this.cellCenter({ x, y }),
          walkable: true,
          blockedTerrain: false,
          staticBlocked: false,
          softBlocked: false
        });
      }
    }
    return cells;
  }

  private applyTerrainZones(zones: TerrainZoneDefinition[]): void {
    zones
      .filter((zone) => zone.type === "blocked" || zone.type === "water")
      .forEach((zone) => {
        const rect = { x: zone.x, y: zone.y, width: zone.width, height: zone.height };
        this.blockedTerrainRectangles.push(rect);
        this.cells.forEach((cell) => {
          if (!this.pointInRectangle(cell.center, rect)) {
            return;
          }
          cell.blockedTerrain = true;
          cell.walkable = false;
        });
      });
  }

  private applyStaticObstacles(obstacles: PathfindingStaticObstacle[]): void {
    obstacles.forEach((obstacle) => {
      const padding = obstacle.padding ?? 12;
      const rect = {
        x: obstacle.x - obstacle.width / 2 - padding,
        y: obstacle.y - obstacle.height / 2 - padding,
        width: obstacle.width + padding * 2,
        height: obstacle.height + padding * 2
      };
      this.staticObstacleRectangles.push(rect);
      this.cells.forEach((cell) => {
        if (!this.pointInRectangle(cell.center, rect)) {
          return;
        }
        cell.staticBlocked = true;
        cell.walkable = false;
      });
    });
  }

  private findNearestWalkableCell(point: Position, maxRadiusCells: number): GridCoord | undefined {
    const origin = this.worldToCell(point);
    if (this.isCellWalkable(origin.x, origin.y)) {
      return origin;
    }

    let best: GridCoord | undefined;
    let bestDistance = Number.POSITIVE_INFINITY;
    for (let radius = 1; radius <= maxRadiusCells; radius += 1) {
      for (let y = origin.y - radius; y <= origin.y + radius; y += 1) {
        for (let x = origin.x - radius; x <= origin.x + radius; x += 1) {
          if (Math.abs(x - origin.x) !== radius && Math.abs(y - origin.y) !== radius) {
            continue;
          }
          if (!this.isCellWalkable(x, y)) {
            continue;
          }
          const candidate = { x, y };
          const candidateDistance = distance(point, this.cellCenter(candidate));
          if (candidateDistance < bestDistance) {
            best = candidate;
            bestDistance = candidateDistance;
          }
        }
      }
      if (best) {
        return best;
      }
    }
    return undefined;
  }

  private buildResult(
    cameFrom: Map<string, string>,
    endKey: string,
    startCell: GridCoord,
    endCell: GridCoord,
    requestedStart: Position,
    requestedGoal: Position,
    complete: boolean
  ): PathfindingResult {
    const coords = this.reconstructCells(cameFrom, endKey);
    const waypoints = coords.slice(1).map((coord) => this.cellCenter(coord));
    if (complete && waypoints.length > 0 && this.isWorldWalkable(requestedGoal)) {
      waypoints[waypoints.length - 1] = this.clampPoint(requestedGoal);
    }
    return {
      waypoints: this.smoothWaypoints(this.clampPoint(requestedStart), waypoints),
      complete,
      startCell,
      endCell
    };
  }

  private reconstructCells(cameFrom: Map<string, string>, endKey: string): GridCoord[] {
    const keys = [endKey];
    let current = endKey;
    while (cameFrom.has(current)) {
      current = cameFrom.get(current)!;
      keys.push(current);
    }
    return keys.reverse().map((key) => this.coordFromKey(key));
  }

  private smoothWaypoints(start: Position, waypoints: Position[]): Position[] {
    if (waypoints.length <= 2) {
      return waypoints;
    }
    const smoothed: Position[] = [];
    let anchor = start;
    let index = 0;
    while (index < waypoints.length) {
      let chosen = index;
      for (let candidate = waypoints.length - 1; candidate >= index; candidate -= 1) {
        if (this.hasLineOfSight(anchor, waypoints[candidate])) {
          chosen = candidate;
          break;
        }
      }
      smoothed.push(waypoints[chosen]);
      anchor = waypoints[chosen];
      index = chosen + 1;
    }
    return smoothed;
  }

  private hasLineOfSight(a: Position, b: Position): boolean {
    const length = distance(a, b);
    const steps = Math.max(1, Math.ceil(length / (this.cellSize * 0.45)));
    for (let index = 1; index <= steps; index += 1) {
      const t = index / steps;
      if (!this.isWorldWalkable({ x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t })) {
        return false;
      }
    }
    return true;
  }

  private neighbors(coord: GridCoord, walkableEndpoint?: GridCoord): GridCoord[] {
    return DIRECTIONS.flatMap((direction) => {
      const next = { x: coord.x + direction.x, y: coord.y + direction.y };
      if (!this.isSearchCellWalkable(next, walkableEndpoint)) {
        return [];
      }
      if (
        direction.x !== 0 &&
        direction.y !== 0 &&
        (!this.isCellWalkable(coord.x + direction.x, coord.y) || !this.isCellWalkable(coord.x, coord.y + direction.y))
      ) {
        return [];
      }
      return [next];
    });
  }

  private isSearchCellWalkable(coord: GridCoord, walkableEndpoint?: GridCoord): boolean {
    return (
      this.isCellWalkable(coord.x, coord.y) ||
      (walkableEndpoint !== undefined && this.sameCell(coord, walkableEndpoint))
    );
  }

  private heuristic(a: GridCoord, b: GridCoord): number {
    const dx = Math.abs(a.x - b.x);
    const dy = Math.abs(a.y - b.y);
    return 10 * (dx + dy) + (14 - 20) * Math.min(dx, dy);
  }

  private cellAt(x: number, y: number): PathfindingCell {
    return this.cells[y * this.columns + x];
  }

  private pointInRectangle(point: Position, rect: { x: number; y: number; width: number; height: number }): boolean {
    return point.x >= rect.x && point.x <= rect.x + rect.width && point.y >= rect.y && point.y <= rect.y + rect.height;
  }

  private sameCell(a: GridCoord, b: GridCoord): boolean {
    return a.x === b.x && a.y === b.y;
  }

  private key(coord: GridCoord): string {
    return `${coord.x},${coord.y}`;
  }

  private coordFromKey(key: string): GridCoord {
    const [x, y] = key.split(",").map(Number);
    return { x, y };
  }

  private clampPoint(point: Position): Position {
    return {
      x: clamp(point.x, 0, this.width),
      y: clamp(point.y, 0, this.height)
    };
  }
}
