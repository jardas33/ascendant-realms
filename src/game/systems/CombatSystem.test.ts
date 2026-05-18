import { describe, expect, it, vi } from "vitest";
import type { Position, Team } from "../core/GameTypes";
import type { Building } from "../entities/Building";
import { Unit } from "../entities/Unit";
import { CombatSystem } from "./CombatSystem";

describe("CombatSystem", () => {
  it("lets player units obey a normal move order away from enemies in weapon range", () => {
    const player = fakeUnit({ id: "player-militia", team: "player", x: 100, y: 100, moveTarget: { x: 260, y: 100 } });
    const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 124, y: 100 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(player.moveTarget).toEqual({ x: 260, y: 100 });
    expect(enemy.hp).toBe(enemy.maxHp);
  });

  it("lets normal move orders interrupt combat briefly without disabling later contact attacks", () => {
    const player = fakeUnit({
      id: "player-militia",
      team: "player",
      x: 100,
      y: 100,
      moveTarget: { x: 260, y: 100 },
      moveOrderCombatSuppressionSeconds: 0.2
    });
    const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 124, y: 100 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(enemy.hp).toBe(enemy.maxHp);
    expect(player.moveTarget).toEqual({ x: 260, y: 100 });

    combat.update(0.2);

    expect(enemy.hp).toBeLessThan(enemy.maxHp);
    expect(player.moveTarget).toBeUndefined();
  });

  it("stops attack-moving player units to fight enemies in weapon range", () => {
    const player = fakeUnit({
      id: "player-militia",
      team: "player",
      x: 100,
      y: 100,
      moveTarget: { x: 260, y: 100 },
      attackMove: true
    });
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

  it("counts melee body contact as attack range for adjacent player attacks", () => {
    const player = fakeUnit({ id: "player-hero", team: "player", x: 100, y: 100, radius: 18, range: 26 });
    const enemy = fakeUnit({ id: "enemy-stone-imp", team: "enemy", x: 134, y: 100, radius: 14, range: 26 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(enemy.hp).toBeLessThan(enemy.maxHp);
  });

  it("counts melee body contact as attack range for adjacent enemy attacks", () => {
    const player = fakeUnit({ id: "player-hero", team: "player", x: 100, y: 100, radius: 18, range: 34 });
    const enemy = fakeUnit({ id: "enemy-stone-imp", team: "enemy", x: 134, y: 100, radius: 14, range: 26 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(player.hp).toBeLessThan(player.maxHp);
  });

  it("counts visual melee contact as attack range when sprite footprints touch", () => {
    const player = fakeUnit({ id: "player-hero", team: "player", x: 100, y: 100, radius: 18, range: 26 });
    const enemy = fakeUnit({ id: "enemy-stone-imp", team: "enemy", x: 146, y: 100, radius: 14, range: 26 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(enemy.hp).toBeLessThan(enemy.maxHp);
    expect(player.moveTarget).toBeUndefined();
  });

  it("reacquires an adjacent melee target after killing the previous explicit target", () => {
    const player = fakeUnit({
      id: "player-hero",
      team: "player",
      x: 100,
      y: 100,
      radius: 18,
      range: 26,
      damage: 12,
      attackTargetId: "enemy-stone-imp-1"
    });
    const firstImp = fakeUnit({ id: "enemy-stone-imp-1", team: "enemy", x: 132, y: 100, radius: 14, range: 26, hp: 8 });
    const secondImp = fakeUnit({ id: "enemy-stone-imp-2", team: "enemy", x: 146, y: 100, radius: 14, range: 26 });
    const combat = createCombat([player, firstImp, secondImp]);

    combat.update(0.1);
    expect(firstImp.alive).toBe(false);

    combat.update(1.1);

    expect(player.attackTargetId).toBeUndefined();
    expect(secondImp.hp).toBeLessThan(secondImp.maxHp);
    expect(player.moveTarget).toBeUndefined();
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
  moveOrderCombatSuppressionSeconds?: number;
  radius?: number;
  range?: number;
  hp?: number;
  damage?: number;
  attackTargetId?: string;
}): Unit {
  return Object.assign(Object.create(Unit.prototype), {
    id: options.id,
    kind: "unit",
    alive: true,
    team: options.team,
    position: { x: options.x, y: options.y },
    radius: options.radius ?? 13,
    maxHp: 100,
    hp: options.hp ?? 100,
    armor: 0,
    attackCooldownRemaining: 0,
    attackTargetId: options.attackTargetId,
    moveTarget: options.moveTarget ? { ...options.moveTarget } : undefined,
    attackMove: options.attackMove ?? false,
    moveOrderCombatSuppressionSeconds:
      options.moveOrderCombatSuppressionSeconds ?? (options.moveTarget && !options.attackMove ? 1.15 : 0),
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
      damage: options.damage ?? 10,
        range: options.range ?? 28,
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
