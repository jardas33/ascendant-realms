import { describe, expect, it, vi } from "vitest";
import type { Position, Team } from "../core/GameTypes";
import { Building } from "../entities/Building";
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
    expect(player.hp).toBeLessThan(player.maxHp);
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

    expect(enemy.hp).toBe(enemy.maxHp);
    expect(player.moveOrderCombatSuppressionSeconds).toBe(0);

    combat.update(0.1);

    expect(enemy.hp).toBeLessThan(enemy.maxHp);
    expect(player.moveTarget).toBeUndefined();
  });

  it("does not reacquire a target on the same frame a move-away suppression window expires", () => {
    const player = fakeUnit({
      id: "player-militia",
      team: "player",
      x: 100,
      y: 100,
      moveTarget: { x: 260, y: 100 },
      moveOrderCombatSuppressionSeconds: 0.1
    });
    const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 124, y: 100 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(player.moveTarget).toEqual({ x: 260, y: 100 });
    expect(player.moveOrderCombatSuppressionSeconds).toBe(0);
    expect(enemy.hp).toBe(enemy.maxHp);
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
    const player = fakeUnit({ id: "player-militia", team: "player", x: 100, y: 100, behaviourMode: "guard_area" });
    const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 220, y: 100 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(player.moveTarget).toBeDefined();
    expect(player.moveTarget?.x).toBeGreaterThan(player.position.x);
    expect(player.moveTarget?.x).toBeLessThan(enemy.position.x);
  });

  it("keeps Hold Ground units from chasing distant enemies", () => {
    const player = fakeUnit({ id: "player-militia", team: "player", x: 100, y: 100, behaviourMode: "hold_ground" });
    const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 220, y: 100 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(player.moveTarget).toBeUndefined();
    expect(enemy.hp).toBe(enemy.maxHp);
  });

  it("lets Hold Ground units respond to nearby direct attackers without chasing idle distant enemies", () => {
    const player = fakeUnit({ id: "player-militia", team: "player", x: 100, y: 100, behaviourMode: "hold_ground" });
    const directAttacker = fakeUnit({
      id: "enemy-hexer",
      team: "enemy",
      x: 240,
      y: 100,
      attackTargetId: "player-militia"
    });
    const distantIdle = fakeUnit({ id: "enemy-raider", team: "enemy", x: 430, y: 100 });
    const combat = createCombat([player, directAttacker, distantIdle]);

    combat.update(0.1);

    expect(player.moveTarget).toBeDefined();
    expect(player.moveTarget?.x).toBeGreaterThan(player.position.x);
    expect(player.moveTarget?.x).toBeLessThan(directAttacker.position.x);
    expect(distantIdle.hp).toBe(distantIdle.maxHp);
  });

  it("lets Hold Ground units attack immediate-range enemies", () => {
    const player = fakeUnit({ id: "player-militia", team: "player", x: 100, y: 100, behaviourMode: "hold_ground" });
    const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 124, y: 100 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(enemy.hp).toBeLessThan(enemy.maxHp);
    expect(player.moveTarget).toBeUndefined();
  });

  it("keeps ranged Hold Ground units from over-pursuing enemies outside their weapon reach", () => {
    const player = fakeUnit({
      id: "player-ranger",
      team: "player",
      x: 100,
      y: 100,
      range: 160,
      behaviourMode: "hold_ground"
    });
    const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 300, y: 100 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(player.moveTarget).toBeUndefined();
    expect(enemy.hp).toBe(enemy.maxHp);
  });

  it("lets Press Attack units pursue threats beyond the default guard leash", () => {
    const player = fakeUnit({ id: "player-militia", team: "player", x: 100, y: 100, behaviourMode: "press_attack" });
    const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 430, y: 100 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(player.moveTarget).toBeDefined();
    expect(player.moveTarget?.x).toBeGreaterThan(player.position.x);
    expect(player.moveTarget?.x).toBeLessThan(enemy.position.x);
  });

  it("keeps Press Attack pursuit bounded instead of chasing across the map", () => {
    const player = fakeUnit({ id: "player-militia", team: "player", x: 100, y: 100, behaviourMode: "press_attack" });
    const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 510, y: 100 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(player.moveTarget).toBeUndefined();
    expect(enemy.hp).toBe(enemy.maxHp);
  });

  it("lets explicit attack orders override Hold Ground refusal", () => {
    const player = fakeUnit({
      id: "player-militia",
      team: "player",
      x: 100,
      y: 100,
      behaviourMode: "hold_ground",
      attackTargetId: "enemy-raider"
    });
    const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 430, y: 100 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(player.moveTarget).toBeDefined();
    expect(player.attackTargetId).toBe("enemy-raider");
  });

  it("keeps Guard Area units inside the local leash", () => {
    const player = fakeUnit({ id: "player-militia", team: "player", x: 100, y: 100, behaviourMode: "guard_area" });
    const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 390, y: 100 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(player.moveTarget).toBeUndefined();
    expect(enemy.hp).toBe(enemy.maxHp);
  });

  it("keeps Press Attack from overriding explicit move-away suppression", () => {
    const player = fakeUnit({
      id: "player-militia",
      team: "player",
      x: 100,
      y: 100,
      moveTarget: { x: 260, y: 100 },
      behaviourMode: "press_attack",
      moveOrderCombatSuppressionSeconds: 0.25
    });
    const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 124, y: 100 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(player.moveTarget).toEqual({ x: 260, y: 100 });
    expect(enemy.hp).toBe(enemy.maxHp);
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

  it("lets Hold Ground reacquire a visible-contact hostile after killing the first adjacent enemy", () => {
    const player = fakeUnit({
      id: "player-hero",
      team: "player",
      x: 100,
      y: 100,
      radius: 19,
      range: 34,
      damage: 12,
      behaviourMode: "hold_ground",
      attackTargetId: "enemy-stone-imp-1"
    });
    const firstImp = fakeUnit({ id: "enemy-stone-imp-1", team: "enemy", x: 132, y: 100, radius: 14, range: 26, hp: 8 });
    const secondImp = fakeUnit({ id: "enemy-stone-imp-2", team: "enemy", x: 150, y: 100, radius: 14, range: 26 });
    const distantImp = fakeUnit({ id: "enemy-stone-imp-3", team: "enemy", x: 430, y: 100, radius: 14, range: 26 });
    const combat = createCombat([player, firstImp, secondImp, distantImp]);

    combat.update(0.1);
    expect(firstImp.alive).toBe(false);

    combat.update(1.1);

    expect(player.attackTargetId).toBeUndefined();
    expect(secondImp.hp).toBeLessThan(secondImp.maxHp);
    expect(distantImp.hp).toBe(distantImp.maxHp);
    expect(player.moveTarget).toBeUndefined();
  });

  it("lets enemy melee units attack a nearby Command Hall footprint when no better target exists", () => {
    const raider = fakeUnit({ id: "enemy-raider", team: "enemy", x: 188, y: 100, radius: 13, range: 28 });
    const commandHall = fakeBuilding({
      id: "player-command-hall",
      buildingId: "command_hall",
      name: "Command Hall",
      team: "player",
      x: 100,
      y: 100,
      width: 96,
      height: 82
    });
    const combat = createCombat([raider], [commandHall]);

    combat.update(0.1);

    expect(commandHall.hp).toBeLessThan(commandHall.maxHp);
    expect(raider.moveTarget).toBeUndefined();
  });

  it("lets enemy ranged units target a nearby Command Hall without requiring melee contact", () => {
    const addProjectile = vi.fn();
    const ranger = fakeUnit({ id: "enemy-ranger", team: "enemy", x: 210, y: 100, radius: 13, range: 140 });
    const commandHall = fakeBuilding({
      id: "player-command-hall",
      buildingId: "command_hall",
      name: "Command Hall",
      team: "player",
      x: 100,
      y: 100,
      width: 96,
      height: 82
    });
    const combat = new CombatSystem({
      scene: fakeProjectileScene() as never,
      getUnits: () => [ranger],
      getBuildings: () => [commandHall],
      getProjectiles: () => [],
      addProjectile,
      onDamage: vi.fn(),
      onKill: vi.fn()
    });

    combat.update(0.1);

    expect(addProjectile).toHaveBeenCalledTimes(1);
    expect(ranger.moveTarget).toBeUndefined();
    expect(commandHall.hp).toBe(commandHall.maxHp);
  });

  it("does not make enemy melee units globally chase distant buildings", () => {
    const raider = fakeUnit({ id: "enemy-raider", team: "enemy", x: 390, y: 100, radius: 13, range: 28 });
    const commandHall = fakeBuilding({
      id: "player-command-hall",
      buildingId: "command_hall",
      name: "Command Hall",
      team: "player",
      x: 100,
      y: 100,
      width: 96,
      height: 82
    });
    const combat = createCombat([raider], [commandHall]);

    combat.update(0.1);

    expect(commandHall.hp).toBe(commandHall.maxHp);
    expect(raider.moveTarget).toBeUndefined();
  });

  it("keeps move-away suppression active even if pathing has already cleared the move target", () => {
    const player = fakeUnit({
      id: "player-militia",
      team: "player",
      x: 100,
      y: 100,
      moveOrderCombatSuppressionSeconds: 0.25,
      behaviourMode: "press_attack"
    });
    const firstEnemy = fakeUnit({ id: "enemy-raider-1", team: "enemy", x: 124, y: 100 });
    const secondEnemy = fakeUnit({ id: "enemy-raider-2", team: "enemy", x: 130, y: 112 });
    const combat = createCombat([player, firstEnemy, secondEnemy]);

    combat.update(0.1);

    expect(firstEnemy.hp).toBe(firstEnemy.maxHp);
    expect(secondEnemy.hp).toBe(secondEnemy.maxHp);
    expect(player.attackTargetId).toBeUndefined();
    expect(player.moveOrderCombatSuppressionSeconds).toBeGreaterThan(0);
  });

  it("fills a readable target label for explicit attack orders", () => {
    const player = fakeUnit({
      id: "player-hero",
      team: "player",
      x: 100,
      y: 100,
      range: 40,
      attackTargetId: "enemy-stone-imp"
    });
    const enemy = fakeUnit({ id: "enemy-stone-imp", team: "enemy", x: 130, y: 100, radius: 14, range: 26 });
    const combat = createCombat([player, enemy]);

    combat.update(0.1);

    expect(player.attackTargetLabel).toBe("Raider");
  });
});

function createCombat(units: Unit[], buildings: Building[] = []): CombatSystem {
  return new CombatSystem({
    scene: {} as never,
    getUnits: () => units,
    getBuildings: () => buildings,
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
  attackTargetLabel?: string;
  behaviourMode?: "hold_ground" | "guard_area" | "press_attack";
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
    attackTargetLabel: options.attackTargetLabel,
    behaviourMode: options.behaviourMode ?? "guard_area",
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

function fakeBuilding(options: {
  id: string;
  buildingId: string;
  name: string;
  team: Team;
  x: number;
  y: number;
  width: number;
  height: number;
  hp?: number;
}): Building {
  return Object.assign(Object.create(Building.prototype), {
    id: options.id,
    kind: "building",
    alive: true,
    team: options.team,
    position: { x: options.x, y: options.y },
    radius: Math.max(options.width, options.height) / 2,
    maxHp: 500,
    hp: options.hp ?? 500,
    armor: 0,
    attackCooldownRemaining: 0,
    definition: {
      id: options.buildingId,
      name: options.name,
      factionId: options.team === "player" ? "free_marches" : "ashen_covenant",
      size: { width: options.width, height: options.height },
      attack: undefined
    },
    isCompleted: () => true,
    takeDamage(rawDamage: number) {
      const damage = Math.max(1, Math.round(rawDamage - this.armor));
      this.hp = Math.max(0, this.hp - damage);
      if (this.hp <= 0) {
        this.alive = false;
      }
      return damage;
    },
    destroyView: vi.fn()
  }) as Building;
}

function fakeProjectileScene(): unknown {
  const gameObject = {
    displayWidth: 0,
    y: 0,
    add: vi.fn(),
    addAt: vi.fn(),
    destroy: vi.fn(),
    moveTo: vi.fn(),
    setColor: vi.fn().mockReturnThis(),
    setDepth: vi.fn().mockReturnThis(),
    setDisplaySize: vi.fn().mockReturnThis(),
    setOrigin: vi.fn().mockReturnThis(),
    setPosition: vi.fn().mockReturnThis(),
    setSize: vi.fn().mockReturnThis(),
    setSmoothness: vi.fn().mockReturnThis(),
    setStrokeStyle: vi.fn().mockReturnThis(),
    setVisible: vi.fn().mockReturnThis(),
    setY: vi.fn().mockReturnThis()
  };
  return {
    add: {
      circle: vi.fn(() => gameObject),
      container: vi.fn(() => gameObject),
      ellipse: vi.fn(() => gameObject),
      rectangle: vi.fn(() => ({ ...gameObject })),
      text: vi.fn(() => gameObject)
    }
  };
}
