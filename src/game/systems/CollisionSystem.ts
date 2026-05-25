import type { Position, Team } from "../core/GameTypes";
import { distance } from "../core/MathUtils";
import type { BaseEntity } from "../entities/BaseEntity";

interface EntityHitTestOptions<T extends BaseEntity> {
  minimumRadius?: number;
  padding?: number | ((entity: T) => number);
  topPadding?: number | ((entity: T) => number);
  footprint?: (entity: T) => { x: number; y: number; width: number; height: number } | undefined;
}

export class CollisionSystem {
  static isHostile(a: Team, b: Team): boolean {
    if (a === b) {
      return false;
    }
    return a !== "neutral" || b !== "neutral";
  }

  static findEntityAt<T extends BaseEntity>(
    x: number,
    y: number,
    entities: T[],
    options: EntityHitTestOptions<T> = {}
  ): T | undefined {
    return entities
      .filter((entity) => {
        if (!entity.alive) {
          return false;
        }
        const padding = typeof options.padding === "function" ? options.padding(entity) : options.padding ?? 0;
        const topPadding = typeof options.topPadding === "function" ? options.topPadding(entity) : options.topPadding ?? 0;
        const hitRadius = Math.max(entity.radius + padding, options.minimumRadius ?? entity.radius);
        if (distance({ x, y }, entity.position) <= hitRadius) {
          return true;
        }
        const footprint = options.footprint?.(entity);
        if (footprint && pointInRectangle(x, y, footprint)) {
          return true;
        }
        const dx = Math.abs(x - entity.position.x);
        const dy = entity.position.y - y;
        return topPadding > 0 && dy > 0 && dy <= hitRadius + topPadding && dx <= hitRadius * 0.55;
      })
      .sort((a, b) => b.radius - a.radius)[0];
  }

  static nearest<T extends BaseEntity>(from: Position, entities: T[], predicate: (entity: T) => boolean): T | undefined {
    let best: T | undefined;
    let bestDistance = Number.POSITIVE_INFINITY;
    entities.forEach((entity) => {
      if (!entity.alive || !predicate(entity)) {
        return;
      }
      const current = distance(from, entity.position);
      if (current < bestDistance) {
        best = entity;
        bestDistance = current;
      }
    });
    return best;
  }
}

function pointInRectangle(
  x: number,
  y: number,
  rectangle: { x: number; y: number; width: number; height: number }
): boolean {
  return (
    x >= rectangle.x &&
    x <= rectangle.x + rectangle.width &&
    y >= rectangle.y &&
    y <= rectangle.y + rectangle.height
  );
}
