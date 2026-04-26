import Phaser from "phaser";
import { ATTACK_MOVE_SEARCH_RADIUS, DEFAULT_AGGRO_RADIUS } from "../core/Constants";
import type { Position } from "../core/GameTypes";
import { distance, normalizeVector } from "../core/MathUtils";
import type { BaseEntity } from "../entities/BaseEntity";
import { Building } from "../entities/Building";
import { Projectile } from "../entities/Projectile";
import { Unit } from "../entities/Unit";
import { CollisionSystem } from "./CollisionSystem";

type Combatant = Unit | Building;

interface CombatSystemOptions {
  scene: Phaser.Scene;
  getUnits: () => Unit[];
  getBuildings: () => Building[];
  getProjectiles: () => Projectile[];
  addProjectile: (projectile: Projectile) => void;
  onDamage: (target: BaseEntity, amount: number) => void;
  onKill: (killer: Combatant | Projectile, target: BaseEntity) => void;
}

export class CombatSystem {
  constructor(private readonly options: CombatSystemOptions) {}

  update(deltaSeconds: number): void {
    this.updateProjectiles(deltaSeconds);
    const attackers: Combatant[] = [...this.options.getUnits(), ...this.options.getBuildings()].filter(
      (entity) => entity.alive && (!(entity instanceof Building) || entity.isCompleted())
    );

    attackers.forEach((attacker) => {
      attacker.attackCooldownRemaining = Math.max(0, attacker.attackCooldownRemaining - deltaSeconds);

      const target = this.resolveTarget(attacker);
      if (!target) {
        return;
      }

      const range = this.getRange(attacker);
      const targetDistance = distance(attacker.position, target.position);
      if (targetDistance > range) {
        if (attacker instanceof Unit && (attacker.attackTargetId || attacker.attackMove || attacker.team !== "player")) {
          const direction = normalizeVector(target.position.x - attacker.position.x, target.position.y - attacker.position.y);
          attacker.moveTarget = {
            x: target.position.x - direction.x * Math.max(18, range * 0.7),
            y: target.position.y - direction.y * Math.max(18, range * 0.7)
          };
        }
        return;
      }

      if (this.getCooldown(attacker) > 0) {
        return;
      }

      this.attack(attacker, target);
    });
  }

  private updateProjectiles(deltaSeconds: number): void {
    const projectiles = this.options.getProjectiles();
    for (let i = projectiles.length - 1; i >= 0; i -= 1) {
      const projectile = projectiles[i];
      const target = this.findEntityById(projectile.targetId);
      if (!target || !target.alive) {
        projectile.destroyView();
        projectiles.splice(i, 1);
        continue;
      }
      if (projectile.moveToward(target.position, deltaSeconds)) {
        this.applyDamage(projectile, target, projectile.damage);
        projectile.destroyView();
        projectiles.splice(i, 1);
      }
    }
  }

  private resolveTarget(attacker: Combatant): BaseEntity | undefined {
    const explicitTarget = attacker instanceof Unit && attacker.attackTargetId ? this.findEntityById(attacker.attackTargetId) : undefined;
    if (explicitTarget?.alive && CollisionSystem.isHostile(attacker.team, explicitTarget.team)) {
      return explicitTarget;
    }

    if (attacker instanceof Unit && attacker.attackTargetId && (!explicitTarget || !explicitTarget.alive)) {
      attacker.attackTargetId = undefined;
    }

    const searchRadius = attacker instanceof Building ? this.getRange(attacker) : attacker.attackMove ? ATTACK_MOVE_SEARCH_RADIUS : DEFAULT_AGGRO_RADIUS;
    return CollisionSystem.nearest(attacker.position, [...this.options.getUnits(), ...this.options.getBuildings()], (entity) => {
      return CollisionSystem.isHostile(attacker.team, entity.team) && distance(attacker.position, entity.position) <= searchRadius;
    });
  }

  private attack(attacker: Combatant, target: BaseEntity): void {
    const damage = this.getDamage(attacker);
    if (attacker instanceof Unit) {
      attacker.attackCooldownRemaining = attacker.attackCooldown;
      if (attacker.range > 45) {
        this.options.addProjectile(
          new Projectile(this.options.scene, {
            sourceId: attacker.id,
            targetId: target.id,
            team: attacker.team,
            x: attacker.position.x,
            y: attacker.position.y,
            damage,
            speed: 360,
            color: attacker.definition.projectileColor ?? 0xfff0a6
          })
        );
      } else {
        this.applyDamage(attacker, target, damage);
      }
      return;
    }

    if (attacker.definition.attack) {
      attacker.attackCooldownRemaining = attacker.definition.attack.cooldown;
      this.options.addProjectile(
        new Projectile(this.options.scene, {
          sourceId: attacker.id,
          targetId: target.id,
          team: attacker.team,
          x: attacker.position.x,
          y: attacker.position.y,
          damage,
          speed: 420,
          color: attacker.definition.attack.projectileColor
        })
      );
    }
  }

  private applyDamage(source: Combatant | Projectile, target: BaseEntity, amount: number): void {
    const wasAlive = target.alive;
    const actual = target.takeDamage(amount);
    this.options.onDamage(target, actual);
    if (wasAlive && !target.alive) {
      this.options.onKill(source, target);
      target.destroyView();
    }
  }

  private getDamage(attacker: Combatant): number {
    if (attacker instanceof Unit) {
      return attacker.damage;
    }
    return attacker.definition.attack?.damage ?? 0;
  }

  private getRange(attacker: Combatant): number {
    if (attacker instanceof Unit) {
      return attacker.range;
    }
    return attacker.definition.attack?.range ?? 0;
  }

  private getCooldown(attacker: Combatant): number {
    return attacker.attackCooldownRemaining;
  }

  private findEntityById(id: string): BaseEntity | undefined {
    return [...this.options.getUnits(), ...this.options.getBuildings()].find((entity) => entity.id === id);
  }
}
