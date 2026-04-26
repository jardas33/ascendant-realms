import type { Position } from "../core/GameTypes";
import { Grid } from "./Grid";

export class Pathfinder {
  constructor(private readonly grid: Grid) {}

  findPath(start: Position, goal: Position): Position[] {
    // MVP uses direct movement. This method preserves the future A* integration boundary.
    if (!this.grid.isWalkable(goal)) {
      return [start];
    }
    return [start, goal];
  }
}
