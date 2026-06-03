import { describe, expect, it, vi } from "vitest";
import type { Position, Team } from "../core/GameTypes";
import type { BaseEntity } from "../entities/BaseEntity";
import { Building } from "../entities/Building";
import type { Projectile } from "../entities/Projectile";
import { Unit } from "../entities/Unit";
import { CombatSystem } from "./CombatSystem";
import { addSpatialQueryCounters, createEmptySpatialQueryCounters, type SpatialQueryMetricsRecorder } from "./SpatialQueryMetrics";

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

  it("lets Workers weakly damage enemy buildings when explicitly ordered", () => {
    const onDamage = vi.fn();
    const worker = fakeUnit({
      id: "player-worker",
      unitId: "worker",
      unitName: "Worker",
      team: "player",
      x: 90,
      y: 100,
      radius: 11,
      range: 22,
      damage: 3,
      attackTargetId: "enemy-stronghold"
    });
    const stronghold = fakeBuilding({
      id: "enemy-stronghold",
      buildingId: "enemy_stronghold",
      name: "Enemy Stronghold",
      team: "enemy",
      x: 180,
      y: 100,
      width: 104,
      height: 88,
      maxHp: 1000,
      hp: 1000,
      armor: 4
    });
    const combat = createCombat([worker], [stronghold], { onDamage });

    combat.update(0.1);

    expect(stronghold.hp).toBeLessThan(stronghold.maxHp);
    expect(stronghold.hp).toBe(996);
    expect(onDamage).toHaveBeenCalledWith(stronghold, 4, worker);
    expect(worker.moveTarget).toBeUndefined();
    expect(worker.attackTargetLabel).toBe("Enemy Stronghold");

    combat.update(0.99);
    expect(stronghold.hp).toBe(996);

    combat.update(0.02);
    expect(stronghold.hp).toBe(992);
    expect(worker.attackTargetId).toBe("enemy-stronghold");
  });

  it("moves explicit Worker building attacks to a walkable contact point inside attack range", () => {
    const worker = fakeUnit({
      id: "player-worker",
      unitId: "worker",
      unitName: "Worker",
      team: "player",
      x: 27,
      y: 100,
      radius: 11,
      range: 22,
      damage: 3,
      attackTargetId: "enemy-stronghold"
    });
    const stronghold = fakeBuilding({
      id: "enemy-stronghold",
      buildingId: "enemy_stronghold",
      name: "Enemy Stronghold",
      team: "enemy",
      x: 180,
      y: 100,
      width: 104,
      height: 88,
      maxHp: 1000,
      hp: 1000,
      armor: 4
    });
    const combat = createCombat([worker], [stronghold]);

    combat.update(0.1);

    expect(stronghold.hp).toBe(stronghold.maxHp);
    expect(worker.moveTarget).toBeDefined();
    const targetDistance = Math.hypot(worker.moveTarget!.x - stronghold.position.x, worker.moveTarget!.y - stronghold.position.y);
    const footprintRadius = Math.hypot(stronghold.definition.size.width / 2, stronghold.definition.size.height / 2);
    expect(targetDistance).toBeGreaterThan(footprintRadius + worker.radius);
    expect(targetDistance).toBeLessThan(112);
  });

  it("keeps explicit Worker building attacks focused on the ordered building instead of nearby buildings", () => {
    const worker = fakeUnit({
      id: "player-worker",
      unitId: "worker",
      unitName: "Worker",
      team: "player",
      x: 27,
      y: 100,
      radius: 11,
      range: 22,
      damage: 3,
      attackTargetId: "enemy-stronghold"
    });
    const nearbyBarracks = fakeBuilding({
      id: "enemy-barracks",
      buildingId: "enemy_barracks",
      name: "Enemy Barracks",
      team: "enemy",
      x: 60,
      y: 100,
      width: 82,
      height: 64,
      maxHp: 550,
      hp: 550,
      armor: 3
    });
    const stronghold = fakeBuilding({
      id: "enemy-stronghold",
      buildingId: "enemy_stronghold",
      name: "Enemy Stronghold",
      team: "enemy",
      x: 180,
      y: 100,
      width: 104,
      height: 88,
      maxHp: 1000,
      hp: 1000,
      armor: 4
    });
    const combat = createCombat([worker], [nearbyBarracks, stronghold]);

    combat.update(0.1);

    expect(nearbyBarracks.hp).toBe(nearbyBarracks.maxHp);
    expect(stronghold.hp).toBe(stronghold.maxHp);
    expect(worker.moveTarget).toBeDefined();
    expect(worker.attackTargetId).toBe("enemy-stronghold");
    expect(worker.attackTargetLabel).toBe("Enemy Stronghold");
  });

  it("keeps idle Workers from auto-attacking nearby enemy buildings", () => {
    const worker = fakeUnit({
      id: "player-worker",
      unitId: "worker",
      unitName: "Worker",
      team: "player",
      x: 90,
      y: 100,
      radius: 11,
      range: 22,
      damage: 3
    });
    const stronghold = fakeBuilding({
      id: "enemy-stronghold",
      buildingId: "enemy_stronghold",
      name: "Enemy Stronghold",
      team: "enemy",
      x: 180,
      y: 100,
      width: 104,
      height: 88,
      hp: 500
    });
    const combat = createCombat([worker], [stronghold]);

    combat.update(0.1);

    expect(stronghold.hp).toBe(stronghold.maxHp);
    expect(worker.moveTarget).toBeUndefined();
    expect(worker.attackTargetId).toBeUndefined();
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

  it("lets small player troops engage visible-contact neutral imps and hounds without stepping first", () => {
    const player = fakeUnit({ id: "player-militia", team: "player", x: 100, y: 100, radius: 13, range: 28 });
    const imp = fakeUnit({ id: "neutral-stone-imp", team: "neutral", x: 166, y: 100, radius: 14, range: 26 });
    const hound = fakeUnit({ id: "neutral-wild-hound", team: "neutral", x: 164, y: 114, radius: 12, range: 24 });
    const combat = createCombat([player, imp, hound]);

    combat.update(0.1);

    expect(player.moveTarget).toBeUndefined();
    expect(imp.moveTarget).toBeUndefined();
    expect(hound.moveTarget).toBeUndefined();
    expect(imp.hp < imp.maxHp || hound.hp < hound.maxHp || player.hp < player.maxHp).toBe(true);
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

  it("lets a stationary Hold Ground hero engage visible-contact imps when no one initially attacks", () => {
    const player = fakeUnit({
      id: "player-hero",
      team: "player",
      x: 100,
      y: 100,
      radius: 19,
      range: 34,
      behaviourMode: "hold_ground"
    });
    const firstImp = fakeUnit({ id: "enemy-stone-imp-1", team: "enemy", x: 164, y: 100, radius: 14, range: 26 });
    const secondImp = fakeUnit({ id: "enemy-stone-imp-2", team: "enemy", x: 168, y: 114, radius: 14, range: 26 });
    const combat = createCombat([player, firstImp, secondImp]);

    combat.update(0.1);

    expect(player.moveTarget).toBeUndefined();
    expect(firstImp.hp < firstImp.maxHp || secondImp.hp < secondImp.maxHp || player.hp < player.maxHp).toBe(true);
  });

  it("lets a Hold Ground hero reacquire the second visible-contact imp after the first dies without moving", () => {
    const player = fakeUnit({
      id: "player-hero",
      team: "player",
      x: 100,
      y: 100,
      radius: 19,
      range: 34,
      damage: 20,
      behaviourMode: "hold_ground",
      attackTargetId: "enemy-stone-imp-1"
    });
    const firstImp = fakeUnit({ id: "enemy-stone-imp-1", team: "enemy", x: 132, y: 100, radius: 14, range: 26, hp: 8 });
    const secondImp = fakeUnit({ id: "enemy-stone-imp-2", team: "enemy", x: 164, y: 100, radius: 14, range: 26 });
    const distantImp = fakeUnit({ id: "enemy-stone-imp-3", team: "enemy", x: 220, y: 100, radius: 14, range: 26 });
    const combat = createCombat([player, firstImp, secondImp, distantImp]);

    combat.update(0.1);
    expect(firstImp.alive).toBe(false);

    combat.update(1.2);

    expect(secondImp.hp).toBeLessThan(secondImp.maxHp);
    expect(distantImp.hp).toBe(distantImp.maxHp);
    expect(player.moveTarget).toBeUndefined();
    expect(player.attackMove).toBe(false);
  });

  it("lets melee contact interrupt a distant explicit target instead of idling beside a hostile", () => {
    const player = fakeUnit({ id: "player-hero", team: "player", x: 100, y: 100, radius: 19, range: 34, behaviourMode: "hold_ground" });
    const raider = fakeUnit({
      id: "enemy-raider",
      team: "enemy",
      x: 154,
      y: 100,
      radius: 14,
      range: 26,
      attackTargetId: "player-command-hall"
    });
    const commandHall = fakeBuilding({
      id: "player-command-hall",
      buildingId: "command_hall",
      name: "Command Hall",
      team: "player",
      x: 500,
      y: 100,
      width: 96,
      height: 82
    });
    const combat = createCombat([player, raider], [commandHall]);

    combat.update(0.1);

    expect(player.hp).toBeLessThan(player.maxHp);
    expect(raider.moveTarget).toBeUndefined();
    expect(commandHall.hp).toBe(commandHall.maxHp);
  });

  it("keeps Hold Ground from chasing after its explicit target dies when only a distant enemy remains", () => {
    const player = fakeUnit({
      id: "player-hero",
      team: "player",
      x: 100,
      y: 100,
      radius: 19,
      range: 34,
      damage: 20,
      behaviourMode: "hold_ground",
      attackTargetId: "enemy-stone-imp-1"
    });
    const firstImp = fakeUnit({ id: "enemy-stone-imp-1", team: "enemy", x: 132, y: 100, radius: 14, range: 26, hp: 8 });
    const distantImp = fakeUnit({ id: "enemy-stone-imp-2", team: "enemy", x: 220, y: 100, radius: 14, range: 26 });
    const combat = createCombat([player, firstImp, distantImp]);

    combat.update(0.1);
    expect(firstImp.alive).toBe(false);

    combat.update(1.2);

    expect(distantImp.hp).toBe(distantImp.maxHp);
    expect(player.moveTarget).toBeUndefined();
    expect(player.attackMove).toBe(false);
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

  it("lets battle-local systems modestly adjust incoming damage before armor", () => {
    const raider = fakeUnit({ id: "enemy-raider", team: "enemy", x: 188, y: 100, radius: 13, range: 28, damage: 10 });
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
    const combat = createCombat([raider], [commandHall], {
      adjustIncomingDamage: (amount, target) => (target.team === "player" ? amount * 0.92 : amount)
    });

    combat.update(0.1);

    expect(commandHall.hp).toBe(commandHall.maxHp - 9);
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

  it("keeps under-construction Watchtowers from firing until completion", () => {
    const addProjectile = vi.fn();
    const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 210, y: 100, radius: 13, range: 28 });
    const incompleteTower = fakeBuilding({
      id: "player-watchtower-site",
      buildingId: "watchtower",
      name: "Watchtower",
      team: "player",
      x: 100,
      y: 100,
      width: 48,
      height: 72,
      isCompleted: false,
      attack: {
        damage: 14,
        range: 220,
        cooldown: 1.1,
        projectileColor: 0xffdf75
      }
    });
    const combat = new CombatSystem({
      scene: fakeProjectileScene() as never,
      getUnits: () => [enemy],
      getBuildings: () => [incompleteTower],
      getProjectiles: () => [],
      addProjectile,
      onDamage: vi.fn(),
      onKill: vi.fn()
    });

    combat.update(0.1);

    expect(addProjectile).not.toHaveBeenCalled();
    expect(enemy.hp).toBe(enemy.maxHp);

    const completedTower = fakeBuilding({
      id: "player-watchtower",
      buildingId: "watchtower",
      name: "Watchtower",
      team: "player",
      x: 100,
      y: 100,
      width: 48,
      height: 72,
      isCompleted: true,
      attack: {
        damage: 14,
        range: 220,
        cooldown: 1.1,
        projectileColor: 0xffdf75
      }
    });
    const completedCombat = new CombatSystem({
      scene: fakeProjectileScene() as never,
      getUnits: () => [enemy],
      getBuildings: () => [completedTower],
      getProjectiles: () => [],
      addProjectile,
      onDamage: vi.fn(),
      onKill: vi.fn()
    });

    completedCombat.update(0.1);

    expect(addProjectile).toHaveBeenCalledTimes(1);
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

  it("preserves nearest target order while using a cached frame entity list", () => {
    const counters = createEmptySpatialQueryCounters();
    const player = fakeUnit({ id: "player-militia", team: "player", x: 100, y: 100, radius: 13, range: 40, damage: 10 });
    const firstEnemy = fakeUnit({ id: "enemy-raider-1", team: "enemy", x: 130, y: 100, radius: 13 });
    const secondEnemy = fakeUnit({ id: "enemy-raider-2", team: "enemy", x: 130, y: 100, radius: 13 });
    const combat = createCombat([player, firstEnemy, secondEnemy], [], {
      spatialMetrics: (delta) => addSpatialQueryCounters(counters, delta)
    });

    combat.update(0.1);

    expect(firstEnemy.hp).toBe(firstEnemy.maxHp - 10);
    expect(secondEnemy.hp).toBe(secondEnemy.maxHp);
    expect(counters.entityListRebuilds).toBeGreaterThan(0);
    expect(counters.targetAcquisitionScans + counters.immediateMeleeScans).toBeGreaterThan(0);
    expect(counters.entitiesVisited).toBeGreaterThan(0);
    expect(counters.distanceCalculations).toBeGreaterThan(0);
  });
});

function createCombat(
  units: Unit[],
  buildings: Building[] = [],
  hooks: {
    onDamage?: (target: BaseEntity, amount: number, source: Unit | Building | Projectile) => void;
    adjustIncomingDamage?: (amount: number, target: BaseEntity, source: Unit | Building | Projectile) => number;
    spatialMetrics?: SpatialQueryMetricsRecorder;
  } = {}
): CombatSystem {
  return new CombatSystem({
    scene: {} as never,
    getUnits: () => units,
    getBuildings: () => buildings,
    getProjectiles: () => [],
    addProjectile: vi.fn(),
    onDamage: hooks.onDamage ?? vi.fn(),
    onKill: vi.fn(),
    adjustIncomingDamage: hooks.adjustIncomingDamage,
    spatialMetrics: hooks.spatialMetrics
  });
}

function fakeUnit(options: {
  id: string;
  unitId?: string;
  unitName?: string;
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
      id: options.unitId ?? (options.team === "player" ? "militia" : "raider"),
      name: options.unitName ?? (options.team === "player" ? "Militia" : "Raider"),
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
  maxHp?: number;
  hp?: number;
  armor?: number;
  isCompleted?: boolean;
  attack?: {
    damage: number;
    range: number;
    cooldown: number;
    projectileColor: number;
  };
}): Building {
  return Object.assign(Object.create(Building.prototype), {
    id: options.id,
    kind: "building",
    alive: true,
    team: options.team,
    position: { x: options.x, y: options.y },
    radius: Math.max(options.width, options.height) / 2,
    maxHp: options.maxHp ?? 500,
    hp: options.hp ?? options.maxHp ?? 500,
    armor: options.armor ?? 0,
    attackCooldownRemaining: 0,
    definition: {
      id: options.buildingId,
      name: options.name,
      factionId: options.team === "player" ? "free_marches" : "ashen_covenant",
      size: { width: options.width, height: options.height },
      attack: options.attack
    },
    isCompleted: () => options.isCompleted ?? true,
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
