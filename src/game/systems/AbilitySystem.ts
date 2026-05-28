import Phaser from "phaser";
import type { AbilityDefinition } from "../core/GameTypes";
import { distance } from "../core/MathUtils";
import { applyHeroAbilityUpgrades } from "../core/HeroProgressionRules";
import { ITEM_BY_ID, SKILL_NODE_BY_ID, requireAbility } from "../data/contentIndex";
import type { BaseEntity } from "../entities/BaseEntity";
import { Building } from "../entities/Building";
import { Hero } from "../entities/Hero";
import { Projectile } from "../entities/Projectile";
import { Unit } from "../entities/Unit";
import { CollisionSystem } from "./CollisionSystem";

interface AbilitySystemOptions {
  scene: Phaser.Scene;
  getUnits: () => Unit[];
  getBuildings: () => Building[];
  addProjectile: (projectile: Projectile) => void;
  onDamage: (target: BaseEntity, amount: number) => void;
  onKill: (killer: Hero, target: BaseEntity) => void;
  onMessage: (message: string, x?: number, y?: number, color?: string, options?: AbilitySystemMessageOptions) => void;
}

interface AbilitySystemMessageOptions {
  durationSeconds?: number;
  priority?: "normal" | "command" | "pressure" | "objective";
}

export class AbilitySystem {
  constructor(private readonly options: AbilitySystemOptions) {}

  update(deltaSeconds: number, hero: Hero): void {
    if (hero.alive) {
      hero.tickCooldowns(deltaSeconds);
    }
  }

  castPrimary(hero: Hero, selected: BaseEntity[]): boolean {
    return this.castAbility(hero, hero.primaryAbilityId, selected);
  }

  castAbility(hero: Hero, abilityId: string, selected: BaseEntity[]): boolean {
    const ability = applyHeroAbilityUpgrades(requireAbility(abilityId), hero, SKILL_NODE_BY_ID, ITEM_BY_ID).ability;
    if (!hero.alive) {
      return false;
    }
    if (!hero.unlockedAbilities.includes(ability.id)) {
      this.showAbilityMessage("Ability not learned", hero.position.x, hero.position.y - 44, "#ffd27a");
      return false;
    }
    if (hero.abilityCooldowns[ability.id] > 0) {
      if (hero.abilityCooldowns[ability.id] < ability.cooldown - 0.5) {
        this.showAbilityMessage("Ability cooling down", hero.position.x, hero.position.y - 44, "#ffd27a");
      }
      return false;
    }
    if (hero.mana < ability.manaCost) {
      this.showAbilityMessage("Not enough mana", hero.position.x, hero.position.y - 44, "#74d3f2");
      return false;
    }

    const didCast = this.applyAbility(hero, ability, selected);
    if (!didCast) {
      return false;
    }

    hero.mana -= ability.manaCost;
    hero.abilityCooldowns[ability.id] = ability.cooldown;
    return true;
  }

  private applyAbility(hero: Hero, ability: AbilityDefinition, selected: BaseEntity[]): boolean {
    // TODO: Move effect handlers into a data-addressable registry before adding many classes, spell schools, or mods.
    switch (ability.effectType) {
      case "rally-banner":
        return this.rallyBanner(hero, ability);
      case "cleave":
        return this.damageAroundHero(hero, ability, 0xffd47a, "Cleave");
      case "war-cry":
        return this.warCry(hero, ability);
      case "firebolt":
        return this.firebolt(hero, ability);
      case "arcane-burst":
        return this.arcaneBurst(hero, ability);
      case "blink":
        return this.blink(hero, ability);
      case "heal":
        return this.heal(hero, ability, selected);
      case "blessing":
        return this.blessing(hero, ability);
      case "sanctify-ground":
        return this.sanctifyGround(hero, ability);
      default:
        return false;
    }
  }

  private rallyBanner(hero: Hero, ability: AbilityDefinition): boolean {
    const allies = this.options
      .getUnits()
      .filter((unit) => unit.alive && unit.team === hero.team && unit.id !== hero.id && distance(unit.position, hero.position) <= ability.radius);
    allies.forEach((unit) => unit.applyDamageBuff(1 + ability.amount, ability.duration));
    this.pulse(hero.position.x, hero.position.y, ability.radius, 0xf4d36c);
    this.showAbilityMessage(`Rallied ${allies.length} allies`, hero.position.x, hero.position.y - 52, "#ffe590");
    return true;
  }

  private firebolt(hero: Hero, ability: AbilityDefinition): boolean {
    const target = this.nearestHostile(hero, ability.range);
    if (!target) {
      this.showAbilityMessage("No target in range", hero.position.x, hero.position.y - 44, "#ffd27a");
      return false;
    }
    this.options.addProjectile(
      new Projectile(this.options.scene, {
        sourceId: hero.id,
        targetId: target.id,
        team: hero.team,
        x: hero.position.x,
        y: hero.position.y,
        damage: ability.amount,
        speed: 460,
        color: 0xff7b35
      })
    );
    this.showAbilityMessage(ability.name, hero.position.x, hero.position.y - 52, "#ffb06b");
    return true;
  }

  private heal(hero: Hero, ability: AbilityDefinition, selected: BaseEntity[]): boolean {
    const selectedAlly = selected.find(
      (entity) =>
        entity instanceof Unit &&
        entity.team === hero.team &&
        entity.alive &&
        entity.hp < entity.maxHp &&
        distance(hero.position, entity.position) <= ability.range
    );
    const target = selectedAlly instanceof Unit ? selectedAlly : hero;
    const healed = target.heal(ability.amount);
    this.pulse(target.position.x, target.position.y, 42, 0x9cffae);
    this.showAbilityMessage(`+${Math.round(healed)} HP`, target.position.x, target.position.y - 44, "#aef7b7");
    return healed > 0;
  }

  private arcaneBurst(hero: Hero, ability: AbilityDefinition): boolean {
    const target = this.nearestHostile(hero, ability.range);
    if (!target) {
      this.showAbilityMessage("No target in range", hero.position.x, hero.position.y - 44, "#ffd27a");
      return false;
    }
    const hits = this.damageArea(hero, target.position.x, target.position.y, ability.radius, ability.amount);
    this.pulse(target.position.x, target.position.y, ability.radius, 0x9f86ff);
    this.showAbilityMessage(`Arcane Burst hit ${hits}`, target.position.x, target.position.y - 52, "#c9b9ff");
    return hits > 0;
  }

  private blink(hero: Hero, ability: AbilityDefinition): boolean {
    const target = this.nearestHostile(hero, 520);
    const direction = target
      ? {
          x: target.position.x - hero.position.x,
          y: target.position.y - hero.position.y
        }
      : { x: 1, y: 0 };
    const length = Math.max(1, Math.hypot(direction.x, direction.y));
    const distanceToTravel = Math.min(ability.range, length);
    this.pulse(hero.position.x, hero.position.y, 54, 0x83d8ff);
    hero.setPosition(hero.position.x + (direction.x / length) * distanceToTravel, hero.position.y + (direction.y / length) * distanceToTravel);
    hero.moveTarget = undefined;
    this.pulse(hero.position.x, hero.position.y, 54, 0x83d8ff);
    this.showAbilityMessage("Blink", hero.position.x, hero.position.y - 52, "#aee7ff");
    return true;
  }

  private warCry(hero: Hero, ability: AbilityDefinition): boolean {
    const hits = this.damageArea(hero, hero.position.x, hero.position.y, ability.radius, ability.amount);
    const allies = this.options
      .getUnits()
      .filter((unit) => unit.alive && unit.team === hero.team && unit.id !== hero.id && distance(unit.position, hero.position) <= ability.radius);
    allies.forEach((unit) => unit.applyDamageBuff(1.12, ability.duration));
    this.pulse(hero.position.x, hero.position.y, ability.radius, 0xf4a64d);
    this.showAbilityMessage(`War Cry hit ${hits}`, hero.position.x, hero.position.y - 52, "#ffc182");
    return hits > 0 || allies.length > 0;
  }

  private blessing(hero: Hero, ability: AbilityDefinition): boolean {
    const allies = this.options
      .getUnits()
      .filter((unit) => unit.alive && unit.team === hero.team && distance(unit.position, hero.position) <= ability.radius);
    let totalHealed = 0;
    allies.forEach((unit) => {
      totalHealed += unit.heal(ability.amount);
      unit.applyDamageBuff(1.15, ability.duration);
    });
    this.pulse(hero.position.x, hero.position.y, ability.radius, 0xd7ff99);
    this.showAbilityMessage(`Blessed ${allies.length} allies`, hero.position.x, hero.position.y - 52, "#ddffba");
    return allies.length > 0 || totalHealed > 0;
  }

  private sanctifyGround(hero: Hero, ability: AbilityDefinition): boolean {
    const allies = this.options
      .getUnits()
      .filter((unit) => unit.alive && unit.team === hero.team && distance(unit.position, hero.position) <= ability.radius);
    allies.forEach((unit) => unit.heal(ability.amount));
    const hits = this.damageArea(hero, hero.position.x, hero.position.y, ability.radius, ability.amount);
    this.pulse(hero.position.x, hero.position.y, ability.radius, 0xb9ffd0);
    this.showAbilityMessage("Sanctified ground", hero.position.x, hero.position.y - 52, "#caffd8");
    return hits > 0 || allies.length > 0;
  }

  private damageAroundHero(hero: Hero, ability: AbilityDefinition, color: number, label: string): boolean {
    const hits = this.damageArea(hero, hero.position.x, hero.position.y, ability.radius, ability.amount);
    this.pulse(hero.position.x, hero.position.y, ability.radius, color);
    this.showAbilityMessage(`${label} hit ${hits}`, hero.position.x, hero.position.y - 52, "#ffdca3");
    return hits > 0;
  }

  private showAbilityMessage(message: string, x: number, y: number, color: string): void {
    this.options.onMessage(message, x, y, color, { priority: "command" });
  }

  private damageArea(hero: Hero, x: number, y: number, radius: number, amount: number): number {
    const targets = [...this.options.getUnits(), ...this.options.getBuildings()].filter((entity) => {
      return entity.alive && CollisionSystem.isHostile(hero.team, entity.team) && distance({ x, y }, entity.position) <= radius;
    });
    targets.forEach((target) => this.damageTarget(hero, target, amount));
    return targets.length;
  }

  private damageTarget(hero: Hero, target: BaseEntity, amount: number): void {
    const wasAlive = target.alive;
    const actual = target.takeDamage(amount);
    this.options.onDamage(target, actual);
    if (wasAlive && !target.alive) {
      this.options.onKill(hero, target);
      target.destroyView();
    }
  }

  private nearestHostile(hero: Hero, range: number): BaseEntity | undefined {
    return CollisionSystem.nearest(hero.position, [...this.options.getUnits(), ...this.options.getBuildings()], (entity) => {
      return entity.alive && CollisionSystem.isHostile(hero.team, entity.team) && distance(hero.position, entity.position) <= range;
    });
  }

  private pulse(x: number, y: number, radius: number, color: number): void {
    const ring = this.options.scene.add.circle(x, y, 12).setStrokeStyle(4, color, 0.9).setDepth(80);
    this.options.scene.tweens.add({
      targets: ring,
      radius,
      alpha: 0,
      duration: 650,
      ease: "Sine.easeOut",
      onComplete: () => ring.destroy()
    });
  }
}
