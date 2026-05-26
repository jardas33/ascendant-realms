import { describe, expect, it, vi } from "vitest";
import type { BaseEntity } from "../entities/BaseEntity";
import type { Hero } from "../entities/Hero";
import type { Unit } from "../entities/Unit";
import { AbilitySystem } from "./AbilitySystem";

function createFakeScene() {
  const ring = {
    setStrokeStyle: vi.fn(() => ring),
    setDepth: vi.fn(() => ring),
    destroy: vi.fn()
  };
  return {
    add: {
      circle: vi.fn(() => ring)
    },
    tweens: {
      add: vi.fn((config: { onComplete?: () => void }) => config.onComplete?.())
    }
  };
}

function createHero(): Hero {
  return {
    id: "hero-player",
    alive: true,
    team: "player",
    position: { x: 100, y: 100 },
    mana: 100,
    maxMana: 100,
    unlockedAbilities: ["rally_banner", "cleave"],
    abilityCooldowns: {},
    primaryAbilityId: "rally_banner"
  } as unknown as Hero;
}

function createUnit(id: string, team: "player" | "enemy", x: number, y: number): Unit {
  return {
    id,
    alive: true,
    team,
    position: { x, y },
    hp: 100,
    maxHp: 100,
    radius: 16,
    applyDamageBuff: vi.fn(),
    takeDamage: vi.fn((amount: number) => amount),
    destroyView: vi.fn()
  } as unknown as Unit;
}

describe("AbilitySystem", () => {
  it("casts Rally Banner once, buffs valid allies, and blocks cooldown spam", () => {
    const hero = createHero();
    const ally = createUnit("ally", "player", 120, 100);
    const enemy = createUnit("enemy", "enemy", 125, 100);
    const system = new AbilitySystem({
      scene: createFakeScene() as never,
      getUnits: () => [ally, enemy],
      getBuildings: () => [],
      addProjectile: vi.fn(),
      onDamage: vi.fn(),
      onKill: vi.fn(),
      onMessage: vi.fn()
    });

    expect(system.castAbility(hero, "rally_banner", [])).toBe(true);
    const manaAfterCast = hero.mana;
    expect(ally.applyDamageBuff).toHaveBeenCalledWith(1.25, 8);
    expect(enemy.applyDamageBuff).not.toHaveBeenCalled();
    expect(hero.abilityCooldowns.rally_banner).toBe(18);

    expect(system.castAbility(hero, "rally_banner", [])).toBe(false);
    expect(hero.mana).toBe(manaAfterCast);
    expect(ally.applyDamageBuff).toHaveBeenCalledTimes(1);
  });

  it("applies Cleave damage only to hostile targets in range", () => {
    const hero = createHero();
    const ally = createUnit("ally", "player", 120, 100);
    const closeEnemy = createUnit("enemy-close", "enemy", 145, 100);
    const farEnemy = createUnit("enemy-far", "enemy", 400, 100);
    const onDamage = vi.fn();
    const system = new AbilitySystem({
      scene: createFakeScene() as never,
      getUnits: () => [ally, closeEnemy, farEnemy],
      getBuildings: () => [],
      addProjectile: vi.fn(),
      onDamage,
      onKill: vi.fn(),
      onMessage: vi.fn()
    });

    expect(system.castAbility(hero, "cleave", [])).toBe(true);

    expect(closeEnemy.takeDamage).toHaveBeenCalledWith(38);
    expect(farEnemy.takeDamage).not.toHaveBeenCalled();
    expect((ally as unknown as BaseEntity & { takeDamage: ReturnType<typeof vi.fn> }).takeDamage).not.toHaveBeenCalled();
    expect(onDamage).toHaveBeenCalledWith(closeEnemy, 38);
  });
});
