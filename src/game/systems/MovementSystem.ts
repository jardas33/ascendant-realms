import type { BattleMapDefinition } from "../core/GameTypes";
import { clamp, distance, normalizeVector } from "../core/MathUtils";
import type { Unit } from "../entities/Unit";

export class MovementSystem {
  update(deltaSeconds: number, units: Unit[], map: BattleMapDefinition): void {
    units.forEach((unit) => {
      if (!unit.alive) {
        return;
      }
      unit.updateBuffs(deltaSeconds);
      if (!unit.moveTarget) {
        return;
      }

      const dx = unit.moveTarget.x - unit.position.x;
      const dy = unit.moveTarget.y - unit.position.y;
      const remaining = Math.hypot(dx, dy);
      if (remaining <= 4) {
        unit.moveTarget = undefined;
        return;
      }

      const step = Math.min(remaining, unit.speed * deltaSeconds);
      unit.setPosition(
        clamp(unit.position.x + (dx / remaining) * step, unit.radius, map.width - unit.radius),
        clamp(unit.position.y + (dy / remaining) * step, unit.radius, map.height - unit.radius)
      );
    });

    this.applySeparation(units, map);
  }

  private applySeparation(units: Unit[], map: BattleMapDefinition): void {
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
        a.setPosition(
          clamp(a.position.x + direction.x * push, a.radius, map.width - a.radius),
          clamp(a.position.y + direction.y * push, a.radius, map.height - a.radius)
        );
        b.setPosition(
          clamp(b.position.x - direction.x * push, b.radius, map.width - b.radius),
          clamp(b.position.y - direction.y * push, b.radius, map.height - b.radius)
        );
      }
    }
  }
}
