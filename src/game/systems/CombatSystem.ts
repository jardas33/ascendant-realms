import Phaser from "phaser";
import { ATTACK_MOVE_SEARCH_RADIUS, DEFAULT_AGGRO_RADIUS } from "../core/Constants";
import type { FactionModifierDefinition, Position } from "../core/GameTypes";
import { distance, normalizeVector } from "../core/MathUtils";
import { FACTION_BY_ID } from "../data/contentIndex";
import type { BaseEntity } from "../entities/BaseEntity";
import { Building } from "../entities/Building";
import { Projectile } from "../entities/Projectile";
import { Unit } from "../entities/Unit";
import { CollisionSystem } from "./CollisionSystem";
import { applyStatusEffect, createBurnStatus } from "./StatusEffectSystem";

type Combatant = Unit | Building;

interface CombatSystemOptions {
  scene: Phaser.Scene;
  getUnits: () => Unit[];
  getBuildings: () => Building[];
  getProjectiles: () => Projectile[];
  addProjectile: (projectile: Projectile) => void;
  onDamage: (target: BaseEntity, amount: number) => void;
  onUnitDamage?: (source: Unit, target: BaseEntity, amount: number) => void;
  onKill: (killer: Combatant | Projectile, target: BaseEntity) => void;
  onStatusApplied?: (target: BaseEntity, statusName: string) => void;
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
      if (attacker instanceof Unit) {
        attacker.moveOrderCombatSuppressionSeconds = Math.max(
          0,
          attacker.moveOrderCombatSuppressionSeconds - deltaSeconds
        );
      }

      const target = this.resolveTarget(attacker);
      if (!target) {
        return;
      }

      const range = this.getEffectiveRange(attacker, target);
      const targetDistance = distance(attacker.position, target.position);
      if (targetDistance > range) {
        this.moveTowardTargetIfAllowed(attacker, target, range);
        return;
      }

      if (attacker instanceof Unit) {
        attacker.moveTarget = undefined;
      }

      if (this.getCooldown(attacker) > 0) {
        return;
      }

      this.attack(attacker, target);
    });
  }

  private moveTowardTargetIfAllowed(attacker: Combatant, target: BaseEntity, range: number): void {
    if (!(attacker instanceof Unit) || !this.shouldChaseTarget(attacker)) {
      return;
    }

    const direction = normalizeVector(target.position.x - attacker.position.x, target.position.y - attacker.position.y);
    attacker.moveTarget = {
      x: target.position.x - direction.x * Math.max(18, range * 0.7),
      y: target.position.y - direction.y * Math.max(18, range * 0.7)
    };
  }

  private shouldChaseTarget(attacker: Unit): boolean {
    return Boolean(attacker.attackTargetId || attacker.attackMove || attacker.team !== "player" || !attacker.moveTarget);
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
        const source = this.findEntityById(projectile.sourceId);
        this.applyDamage(source instanceof Unit || source instanceof Building ? source : projectile, target, projectile.damage);
        projectile.destroyView();
        projectiles.splice(i, 1);
      }
    }
  }

  private resolveTarget(attacker: Combatant): BaseEntity | undefined {
    if (
      attacker instanceof Unit &&
      attacker.team === "player" &&
      attacker.moveTarget &&
      !attacker.attackMove &&
      !attacker.attackTargetId &&
      attacker.moveOrderCombatSuppressionSeconds > 0
    ) {
      return undefined;
    }

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
    if (actual > 0 && source instanceof Unit) {
      this.options.onUnitDamage?.(source, target, actual);
    }
    if (actual > 0 && target.alive) {
      this.applyOnHitEffects(source, target);
    }
    if (wasAlive && !target.alive) {
      this.options.onKill(source, target);
      target.destroyView();
    }
  }

  private getDamage(attacker: Combatant): number {
    if (attacker instanceof Unit) {
      return this.applyLowHealthDamageModifiers(attacker, attacker.damage);
    }
    return attacker.definition.attack?.damage ?? 0;
  }

  private applyLowHealthDamageModifiers(attacker: Unit, damage: number): number {
    return this.factionModifiersFor(attacker)
      .filter((modifier) => modifier.type === "low-health-damage" && this.modifierAppliesToSource(modifier, attacker))
      .reduce((currentDamage, modifier) => {
        const threshold = modifier.hpThreshold ?? 0.5;
        if (attacker.hp / attacker.maxHp > threshold) {
          return currentDamage;
        }
        return currentDamage * (modifier.damageMultiplier ?? 1);
      }, damage);
  }

  private applyOnHitEffects(source: Combatant | Projectile, target: BaseEntity): void {
    if (!(source instanceof Unit) && !(source instanceof Building)) {
      return;
    }
    this.factionModifiersFor(source)
      .filter((modifier) => modifier.type === "burn-on-hit" && this.modifierAppliesToSource(modifier, source))
      .forEach((modifier) => {
        if (!modifier.burn) {
          return;
        }
        applyStatusEffect(
          target,
          createBurnStatus({
            id: `${modifier.id}:${source.definition.id}`,
            name: "Burn",
            damagePerSecond: modifier.burn.damagePerSecond,
            durationSeconds: modifier.burn.durationSeconds,
            tickInterval: modifier.burn.tickInterval,
            sourceId: source.id,
            sourceTeam: source.team
          })
        );
        this.options.onStatusApplied?.(target, "Burn");
      });
  }

  private factionModifiersFor(source: Unit | Building): FactionModifierDefinition[] {
    return FACTION_BY_ID[source.definition.factionId]?.mechanics.factionModifiers ?? [];
  }

  private modifierAppliesToSource(modifier: FactionModifierDefinition, source: Unit | Building): boolean {
    return !modifier.unitIds || modifier.unitIds.includes(source.definition.id);
  }

  private getRange(attacker: Combatant): number {
    if (attacker instanceof Unit) {
      return attacker.range;
    }
    return attacker.definition.attack?.range ?? 0;
  }

  private getEffectiveRange(attacker: Combatant, target: BaseEntity): number {
    const range = this.getRange(attacker);
    if (!(attacker instanceof Unit) || range > 45) {
      return range;
    }
    return Math.max(range, attacker.radius + target.radius + 4);
  }

  private getCooldown(attacker: Combatant): number {
    return attacker.attackCooldownRemaining;
  }

  private findEntityById(id: string): BaseEntity | undefined {
    return [...this.options.getUnits(), ...this.options.getBuildings()].find((entity) => entity.id === id);
  }
}
