import type { BattleMapDefinition, Position } from "../core/GameTypes";
import { pointInRect } from "../core/MathUtils";

export class Grid {
  readonly columns: number;
  readonly rows: number;

  constructor(
    private readonly map: BattleMapDefinition,
    private readonly cellSize = 48
  ) {
    this.columns = Math.ceil(map.width / cellSize);
    this.rows = Math.ceil(map.height / cellSize);
  }

  isWalkable(position: Position): boolean {
    return !this.map.terrainZones.some(
      (zone) => (zone.type === "blocked" || zone.type === "water") && pointInRect(position, zone)
    );
  }
}
