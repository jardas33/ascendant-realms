import type { Position, Team, VisibilityState } from "../core/GameTypes";

const STATE_VALUE: Record<VisibilityState, number> = {
  unseen: 0,
  explored: 1,
  visible: 2
};

const VALUE_STATE: VisibilityState[] = ["unseen", "explored", "visible"];

export interface VisionSource extends Position {
  radius: number;
}

export interface VisibilityCellSnapshot {
  x: number;
  y: number;
  width: number;
  height: number;
  state: VisibilityState;
}

export interface VisibilityEntity {
  team: Team;
  position: Position;
  radius?: number;
}

export class FogOfWarSystem {
  readonly columns: number;
  readonly rows: number;
  readonly states: Uint8Array;
  private currentSources: VisionSource[] = [];

  constructor(
    readonly mapWidth: number,
    readonly mapHeight: number,
    readonly cellSize = 160
  ) {
    this.columns = Math.ceil(mapWidth / cellSize);
    this.rows = Math.ceil(mapHeight / cellSize);
    this.states = new Uint8Array(this.columns * this.rows);
  }

  update(sources: VisionSource[]): void {
    this.currentSources = sources.map((source) => ({ ...source }));
    for (let index = 0; index < this.states.length; index += 1) {
      if (this.states[index] === STATE_VALUE.visible) {
        this.states[index] = STATE_VALUE.explored;
      }
    }

    sources.forEach((source) => this.reveal(source));
  }

  stateAt(position: Position): VisibilityState {
    return VALUE_STATE[this.states[this.indexForPosition(position)] ?? 0] ?? "unseen";
  }

  isVisible(position: Position): boolean {
    if (this.currentSources.length === 0) {
      return this.stateAt(position) === "visible";
    }
    return this.currentSources.some((source) => distance(position, source) <= source.radius);
  }

  isEntityVisible(position: Position, radius = 0): boolean {
    if (this.currentSources.length === 0) {
      return this.stateAt(position) === "visible";
    }
    return this.currentSources.some((source) => distance(position, source) <= source.radius + radius);
  }

  isExplored(position: Position): boolean {
    return this.stateAt(position) !== "unseen";
  }

  cells(): VisibilityCellSnapshot[] {
    const cells: VisibilityCellSnapshot[] = [];
    for (let row = 0; row < this.rows; row += 1) {
      for (let column = 0; column < this.columns; column += 1) {
        const x = column * this.cellSize;
        const y = row * this.cellSize;
        cells.push({
          x,
          y,
          width: Math.min(this.cellSize, this.mapWidth - x),
          height: Math.min(this.cellSize, this.mapHeight - y),
          state: VALUE_STATE[this.states[this.index(column, row)] ?? 0] ?? "unseen"
        });
      }
    }
    return cells;
  }

  private reveal(source: VisionSource): void {
    if (source.radius <= 0) {
      return;
    }

    const minColumn = this.clampColumn(Math.floor((source.x - source.radius) / this.cellSize));
    const maxColumn = this.clampColumn(Math.floor((source.x + source.radius) / this.cellSize));
    const minRow = this.clampRow(Math.floor((source.y - source.radius) / this.cellSize));
    const maxRow = this.clampRow(Math.floor((source.y + source.radius) / this.cellSize));
    const cellPadding = Math.SQRT2 * this.cellSize * 0.5;

    for (let row = minRow; row <= maxRow; row += 1) {
      for (let column = minColumn; column <= maxColumn; column += 1) {
        const center = this.cellCenter(column, row);
        if (distance(center, source) <= source.radius + cellPadding) {
          this.states[this.index(column, row)] = STATE_VALUE.visible;
        }
      }
    }
  }

  private cellCenter(column: number, row: number): Position {
    const x = column * this.cellSize;
    const y = row * this.cellSize;
    return {
      x: Math.min(this.mapWidth, x + Math.min(this.cellSize, this.mapWidth - x) / 2),
      y: Math.min(this.mapHeight, y + Math.min(this.cellSize, this.mapHeight - y) / 2)
    };
  }

  private indexForPosition(position: Position): number {
    return this.index(
      this.clampColumn(Math.floor(position.x / this.cellSize)),
      this.clampRow(Math.floor(position.y / this.cellSize))
    );
  }

  private index(column: number, row: number): number {
    return row * this.columns + column;
  }

  private clampColumn(column: number): number {
    return Math.max(0, Math.min(this.columns - 1, column));
  }

  private clampRow(row: number): number {
    return Math.max(0, Math.min(this.rows - 1, row));
  }
}

export function isEntityVisibleToPlayer(entity: VisibilityEntity, fog: FogOfWarSystem, fogEnabled: boolean): boolean {
  if (!fogEnabled || entity.team === "player") {
    return true;
  }
  return fog.isEntityVisible(entity.position, entity.radius ?? 0);
}

function distance(a: Position, b: Position): number {
  return Math.hypot(a.x - b.x, a.y - b.y);
}
