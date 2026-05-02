import { distance } from "../core/MathUtils";
import type { BaseEntity } from "../entities/BaseEntity";
import { Building } from "../entities/Building";
import { Unit } from "../entities/Unit";
import { ENEMY_HERO_ABILITY_BY_ID, ENEMY_HERO_BY_ID } from "../data/enemyHeroes";
import { applyStatusEffect, createBurnStatus } from "./StatusEffectSystem";

interface EnemyHeroAbilitySystemOptions {
  getUnits: () => Unit[];
  getBuildings: () => Building[];
  getElapsedSeconds: () => number;
  getEnemyBase: () => Building | undefined;
  applyDamage: (source: Unit, target: BaseEntity, amount: number) => void;
  onStatusApplied: (target: BaseEntity, statusName: string) => void;
  onMessage: (message: string, x?: number, y?: number, color?: string) => void;
}

export class EnemyHeroAbilitySystem {
  constructor(private readonly options: EnemyHeroAbilitySystemOptions) {}

  update(deltaSeconds: number): void {
    this.options
      .getUnits()
      .filter((unit) => unit.alive && unit.team === "enemy" && unit.enemyHeroId)
      .forEach((unit) => {
        this.tickCooldowns(unit, deltaSeconds);
        this.tryCast(unit);
      });
  }

  private tickCooldowns(unit: Unit, deltaSeconds: number): void {
    unit.enemyHeroAbilityCooldowns.forEach((remaining, abilityId) => {
      unit.enemyHeroAbilityCooldowns.set(abilityId, Math.max(0, remaining - deltaSeconds));
    });
  }

  private tryCast(unit: Unit): void {
    const hero = unit.enemyHeroId ? ENEMY_HERO_BY_ID[unit.enemyHeroId] : undefined;
    if (!hero) {
      return;
    }

    for (const abilityId of hero.abilities) {
      const ability = ENEMY_HERO_ABILITY_BY_ID[abilityId];
      if (!ability || (unit.enemyHeroAbilityCooldowns.get(ability.id) ?? 0) > 0) {
        continue;
      }
      if (this.castAbility(unit, ability)) {
        unit.enemyHeroAbilityCooldowns.set(ability.id, ability.cooldownSeconds);
        return;
      }
    }
  }

  private castAbility(unit: Unit, ability: (typeof ENEMY_HERO_ABILITY_BY_ID)[keyof typeof ENEMY_HERO_ABILITY_BY_ID]): boolean {
    const effect = ability.effect;
    if (effect.type === "damage-and-burn") {
      const target = this.nearestPlayerEntity(unit, ability.range);
      if (!target) {
        return false;
      }
      this.options.applyDamage(unit, target, effect.damage);
      if (target.alive) {
        applyStatusEffect(
          target,
          createBurnStatus({
            id: `${ability.id}:${unit.id}`,
            name: "Ember Burn",
            damagePerSecond: effect.burn.damagePerSecond,
            durationSeconds: effect.burn.durationSeconds,
            tickInterval: effect.burn.tickInterval,
            sourceId: unit.id,
            sourceTeam: unit.team
          })
        );
        this.options.onStatusApplied(target, "Ember Burn");
      }
      this.announce(unit, ability.name);
      return true;
    }

    if (effect.type === "direct-damage") {
      const target = this.nearestPlayerEntity(unit, ability.range);
      if (!target) {
        return false;
      }
      this.options.applyDamage(unit, target, effect.damage);
      this.announce(unit, ability.name);
      return true;
    }

    if (effect.type === "damage-buff") {
      const allies = this.nearbyEnemyUnits(unit, effect.radius)
        .filter((ally) => ally.id !== unit.id && ally.damageBuffRemaining <= 0)
        .slice(0, effect.maxTargets ?? 99);
      if (allies.length === 0) {
        return false;
      }
      allies.forEach((ally) => ally.applyDamageBuff(effect.multiplier, effect.durationSeconds));
      this.announce(unit, ability.name);
      return true;
    }

    if (effect.requiresNearEnemyBase) {
      const enemyBase = this.options.getEnemyBase();
      if (!enemyBase || distance(unit.position, enemyBase.position) > ability.range) {
        return false;
      }
    }
    const allies = this.nearbyEnemyUnits(unit, effect.radius).filter((ally) => ally.armorBuffRemaining <= 0);
    if (allies.length === 0) {
      return false;
    }
    allies.forEach((ally) => ally.applyArmorBuff(effect.armorBonus, effect.durationSeconds));
    this.announce(unit, ability.name);
    return true;
  }

  private nearestPlayerEntity(source: Unit, range: number): BaseEntity | undefined {
    const candidates: BaseEntity[] = [
      ...this.options.getUnits().filter((unit) => unit.alive && unit.team === "player"),
      ...this.options.getBuildings().filter((building) => building.alive && building.team === "player")
    ];
    return candidates
      .filter((entity) => distance(source.position, entity.position) <= range)
      .sort((left, right) => distance(source.position, left.position) - distance(source.position, right.position))[0];
  }

  private nearbyEnemyUnits(source: Unit, radius: number): Unit[] {
    return this.options
      .getUnits()
      .filter((unit) => unit.alive && unit.team === "enemy" && distance(source.position, unit.position) <= radius);
  }

  private announce(unit: Unit, abilityName: string): void {
    if (this.options.getElapsedSeconds() < 0.5) {
      return;
    }
    this.options.onMessage(`${unit.enemyHeroName ?? unit.definition.name} uses ${abilityName}`, unit.position.x, unit.position.y - 56, "#f6a46f");
  }
}
