import { describe, expect, it, vi } from "vitest";
import type { Position, Team } from "../core/GameTypes";
import type { Building } from "../entities/Building";
import { Unit } from "../entities/Unit";
import { CombatSystem } from "./CombatSystem";

describe("CombatSystem", () => {
  it("stops player units to fight when an enemy enters weapon range", () => {
    const player = fakeUnit({ id: "player-militia", team: "player", x: 100, y: 100, moveTarget: { x: 260, y: 100 } });
    const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 124, y: 100 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(player.moveTarget).toBeUndefined();
    expect(enemy.hp).toBeLessThan(enemy.maxHp);
  });

  it("does not pull a player unit off a normal move order to chase distant aggro", () => {
    const moveTarget = { x: 260, y: 100 };
    const player = fakeUnit({ id: "player-militia", team: "player", x: 100, y: 100, moveTarget });
    const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 220, y: 100 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(player.moveTarget).toEqual(moveTarget);
    expect(enemy.hp).toBe(enemy.maxHp);
  });

  it("lets idle player units guard-chase nearby hostile targets", () => {
    const player = fakeUnit({ id: "player-militia", team: "player", x: 100, y: 100 });
    const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 220, y: 100 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(player.moveTarget).toBeDefined();
    expect(player.moveTarget?.x).toBeGreaterThan(player.position.x);
    expect(player.moveTarget?.x).toBeLessThan(enemy.position.x);
  });
});

function createCombat(units: Unit[]): CombatSystem {
  return new CombatSystem({
    scene: {} as never,
    getUnits: () => units,
    getBuildings: () => [] as Building[],
    getProjectiles: () => [],
    addProjectile: vi.fn(),
    onDamage: vi.fn(),
    onKill: vi.fn()
  });
}

function fakeUnit(options: {
  id: string;
  team: Team;
  x: number;
  y: number;
  moveTarget?: Position;
  attackMove?: boolean;
}): Unit {
  return Object.assign(Object.create(Unit.prototype), {
    id: options.id,
    kind: "unit",
    alive: true,
    team: options.team,
    position: { x: options.x, y: options.y },
    radius: 13,
    maxHp: 100,
    hp: 100,
    armor: 0,
    attackCooldownRemaining: 0,
    moveTarget: options.moveTarget ? { ...options.moveTarget } : undefined,
    attackMove: options.attackMove ?? false,
    damageBuffMultiplier: 1,
    upgradeDamageMultiplier: 1,
    upgradeRangeMultiplier: 1,
    upgradeAttackCooldownMultiplier: 1,
    factionSpeedMultiplier: 1,
    appliedUpgradeIds: new Set<string>(),
    definition: {
      id: options.team === "player" ? "militia" : "raider",
      name: options.team === "player" ? "Militia" : "Raider",
      factionId: options.team === "player" ? "free_marches" : "ashen_covenant",
      stats: {
        maxHp: 100,
        damage: 10,
        range: 28,
        attackCooldown: 1,
        speed: 90,
        armor: 0
      }
    },
    takeDamage(rawDamage: number) {
      const damage = Math.max(1, Math.round(rawDamage - this.armor));
      this.hp = Math.max(0, this.hp - damage);
      if (this.hp <= 0) {
        this.alive = false;
      }
      return damage;
    },
    destroyView: vi.fn()
  }) as Unit;
}
