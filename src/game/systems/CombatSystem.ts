import Phaser from "phaser";
import { ATTACK_MOVE_SEARCH_RADIUS, DEFAULT_AGGRO_RADIUS } from "../core/Constants";
import type { FactionModifierDefinition, Position } from "../core/GameTypes";
import { distance, normalizeVector } from "../core/MathUtils";
import { FACTION_BY_ID } from "../data/contentIndex";
import type { BaseEntity } from "../entities/BaseEntity";
import { Building } from "../entities/Building";
import { Projectile } from "../entities/Projectile";
import { Unit } from "../entities/Unit";
import { DEFAULT_BEHAVIOUR_MODE, normalizeBehaviourMode } from "./BehaviourModeSystem";
import { CollisionSystem } from "./CollisionSystem";
import { applyStatusEffect, createBurnStatus } from "./StatusEffectSystem";

type Combatant = Unit | Building;

const MELEE_VISUAL_CONTACT_MARGIN = 32;
const MELEE_BUILDING_VISUAL_CONTACT_MARGIN = 44;
const MELEE_VISIBLE_CONTACT_FLOOR = 66;
const MELEE_BUILDING_APPROACH_CLEARANCE = 22;
const MELEE_APPROACH_RANGE_BUFFER = 6;
const PRESS_ATTACK_SEARCH_RADIUS = DEFAULT_AGGRO_RADIUS + 120;
const EXPLICIT_WORKER_BUILDING_DAMAGE_FLOOR = 4;

interface CombatSystemOptions {
  scene: Phaser.Scene;
  getUnits: () => Unit[];
  getBuildings: () => Building[];
  getProjectiles: () => Projectile[];
  addProjectile: (projectile: Projectile) => void;
  onDamage: (target: BaseEntity, amount: number, source: Combatant | Projectile) => void;
  onUnitDamage?: (source: Unit, target: BaseEntity, amount: number) => void;
  onKill: (killer: Combatant | Projectile, target: BaseEntity) => void;
  onStatusApplied?: (target: BaseEntity, statusName: string) => void;
  adjustIncomingDamage?: (amount: number, target: BaseEntity, source: Combatant | Projectile) => number;
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

      try {
        const target = this.resolveTarget(attacker);
        if (!target) {
          if (attacker instanceof Unit && attacker.patrolRoute) {
            attacker.resumePatrolRoute();
          }
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
      } finally {
        if (attacker instanceof Unit) {
          attacker.moveOrderCombatSuppressionSeconds = Math.max(
            0,
            attacker.moveOrderCombatSuppressionSeconds - deltaSeconds
          );
        }
      }
    });
  }

  private moveTowardTargetIfAllowed(attacker: Combatant, target: BaseEntity, range: number): void {
    if (!(attacker instanceof Unit) || !this.shouldChaseTarget(attacker, target)) {
      return;
    }

    const direction = normalizeVector(target.position.x - attacker.position.x, target.position.y - attacker.position.y);
    const approachDistance = this.getApproachDistance(attacker, target, range);
    attacker.moveTarget = {
      x: target.position.x - direction.x * approachDistance,
      y: target.position.y - direction.y * approachDistance
    };
  }

  private getApproachDistance(attacker: Unit, target: BaseEntity, range: number): number {
    const defaultApproachDistance = Math.max(18, range * 0.7);
    if (!(target instanceof Building) || this.getRange(attacker) > 45) {
      return defaultApproachDistance;
    }

    const targetFootprintRadius = Math.hypot(target.definition.size.width / 2, target.definition.size.height / 2);
    const buildingApproachDistance = Math.min(
      range - MELEE_APPROACH_RANGE_BUFFER,
      targetFootprintRadius + attacker.radius + MELEE_BUILDING_APPROACH_CLEARANCE
    );
    return Math.max(defaultApproachDistance, buildingApproachDistance);
  }

  private shouldChaseTarget(attacker: Unit, target: BaseEntity): boolean {
    if (attacker.attackTargetId || attacker.attackMove || attacker.team !== "player") {
      return true;
    }
    if (normalizeBehaviourMode(attacker.behaviourMode) === "hold_ground") {
      return target instanceof Unit && target.attackTargetId === attacker.id && distance(attacker.position, target.position) <= DEFAULT_AGGRO_RADIUS;
    }
    return !attacker.moveTarget;
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
      !attacker.attackMove &&
      !attacker.attackTargetId &&
      attacker.moveOrderCombatSuppressionSeconds > 0
    ) {
      return undefined;
    }

    let explicitTarget = attacker instanceof Unit && attacker.attackTargetId ? this.findEntityById(attacker.attackTargetId) : undefined;
    if (attacker instanceof Unit && attacker.attackTargetId && (!explicitTarget?.alive || !CollisionSystem.isHostile(attacker.team, explicitTarget.team))) {
      this.clearExplicitAttackTarget(attacker);
      explicitTarget = undefined;
    }

    if (attacker instanceof Unit) {
      const contactTarget = this.findImmediateMeleeContactTarget(attacker);
      if (
        contactTarget &&
        (!explicitTarget || !this.isWithinEffectiveRange(attacker, explicitTarget)) &&
        this.shouldImmediateContactOverrideExplicitTarget(attacker, explicitTarget, contactTarget)
      ) {
        return contactTarget;
      }
    }

    if (explicitTarget?.alive && CollisionSystem.isHostile(attacker.team, explicitTarget.team)) {
      if (attacker instanceof Unit) {
        attacker.attackTargetLabel = this.entityLabel(explicitTarget);
      }
      return explicitTarget;
    }

    return CollisionSystem.nearest(attacker.position, [...this.options.getUnits(), ...this.options.getBuildings()], (entity) => {
      return this.canAcquireTarget(attacker, entity);
    });
  }

  private clearExplicitAttackTarget(attacker: Unit): void {
    attacker.attackTargetId = undefined;
    attacker.attackTargetLabel = undefined;
    attacker.attackMove = false;
  }

  private findImmediateMeleeContactTarget(attacker: Unit): BaseEntity | undefined {
    if (this.getRange(attacker) > 45) {
      return undefined;
    }
    return CollisionSystem.nearest(attacker.position, [...this.options.getUnits(), ...this.options.getBuildings()], (entity) => {
      return (
        CollisionSystem.isHostile(attacker.team, entity.team) &&
        this.canWorkerEngageBuilding(attacker, entity) &&
        this.isWithinEffectiveRange(attacker, entity)
      );
    });
  }

  private shouldImmediateContactOverrideExplicitTarget(
    attacker: Unit,
    explicitTarget: BaseEntity | undefined,
    contactTarget: BaseEntity
  ): boolean {
    if (!explicitTarget) {
      return true;
    }
    if (attacker.definition.id === "worker" && explicitTarget instanceof Building && contactTarget instanceof Building) {
      return false;
    }
    return true;
  }

  private isWithinEffectiveRange(attacker: Combatant, target: BaseEntity): boolean {
    return distance(attacker.position, target.position) <= this.getEffectiveRange(attacker, target);
  }

  private canAcquireTarget(attacker: Combatant, target: BaseEntity): boolean {
    if (!CollisionSystem.isHostile(attacker.team, target.team)) {
      return false;
    }

    const targetDistance = distance(attacker.position, target.position);
    if (attacker instanceof Building) {
      return targetDistance <= this.getRange(attacker);
    }
    if (!this.canWorkerEngageBuilding(attacker, target)) {
      return false;
    }
    if (attacker.attackMove) {
      return targetDistance <= ATTACK_MOVE_SEARCH_RADIUS;
    }
    if (attacker.team !== "player") {
      return targetDistance <= DEFAULT_AGGRO_RADIUS;
    }

    const mode = normalizeBehaviourMode(attacker.behaviourMode ?? DEFAULT_BEHAVIOUR_MODE);
    if (mode === "hold_ground") {
      const directlyAttacked = target instanceof Unit && target.attackTargetId === attacker.id;
      return targetDistance <= this.getEffectiveRange(attacker, target) || (directlyAttacked && targetDistance <= DEFAULT_AGGRO_RADIUS);
    }
    if (mode === "press_attack") {
      return targetDistance <= PRESS_ATTACK_SEARCH_RADIUS;
    }
    return targetDistance <= DEFAULT_AGGRO_RADIUS;
  }

  private canWorkerEngageBuilding(attacker: Unit, target: BaseEntity): boolean {
    if (attacker.definition.id !== "worker" || !(target instanceof Building)) {
      return true;
    }
    return attacker.attackTargetId === target.id || attacker.attackMove;
  }

  private attack(attacker: Combatant, target: BaseEntity): void {
    const damage = this.getDamage(attacker, target);
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
    const adjustedAmount = this.options.adjustIncomingDamage?.(amount, target, source) ?? amount;
    const actual = target.takeDamage(Math.max(0, adjustedAmount));
    this.options.onDamage(target, actual, source);
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

  private getDamage(attacker: Combatant, target: BaseEntity): number {
    if (attacker instanceof Unit) {
      const damage = this.applyLowHealthDamageModifiers(attacker, attacker.damage);
      if (this.isExplicitWorkerBuildingAttack(attacker, target)) {
        return Math.max(damage, target.armor + EXPLICIT_WORKER_BUILDING_DAMAGE_FLOOR);
      }
      return damage;
    }
    return attacker.definition.attack?.damage ?? 0;
  }

  private isExplicitWorkerBuildingAttack(attacker: Unit, target: BaseEntity): boolean {
    return attacker.definition.id === "worker" && target instanceof Building && attacker.attackTargetId === target.id;
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
    // Sprite footprints and separation can make melee units look adjacent while their centers are outside raw stat range.
    const targetFootprintRadius =
      target instanceof Building
        ? Math.hypot(target.definition.size.width / 2, target.definition.size.height / 2)
        : target.radius;
    const visualContactMargin =
      target instanceof Building ? MELEE_BUILDING_VISUAL_CONTACT_MARGIN : MELEE_VISUAL_CONTACT_MARGIN;
    return Math.max(range, attacker.radius + targetFootprintRadius + visualContactMargin, MELEE_VISIBLE_CONTACT_FLOOR);
  }

  private getCooldown(attacker: Combatant): number {
    return attacker.attackCooldownRemaining;
  }

  private findEntityById(id: string): BaseEntity | undefined {
    return [...this.options.getUnits(), ...this.options.getBuildings()].find((entity) => entity.id === id);
  }

  private entityLabel(entity: BaseEntity): string {
    if (entity instanceof Unit || entity instanceof Building) {
      return entity.definition.name;
    }
    return entity.kind;
  }
}
