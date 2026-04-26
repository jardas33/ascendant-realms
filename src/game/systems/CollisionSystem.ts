import type { Position, Team } from "../core/GameTypes";
import { distance } from "../core/MathUtils";
import type { BaseEntity } from "../entities/BaseEntity";

export class CollisionSystem {
  static isHostile(a: Team, b: Team): boolean {
    if (a === b) {
      return false;
    }
    return a !== "neutral" || b !== "neutral";
  }

  static findEntityAt<T extends BaseEntity>(x: number, y: number, entities: T[]): T | undefined {
    return entities
      .filter((entity) => entity.alive && distance({ x, y }, entity.position) <= entity.radius)
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
