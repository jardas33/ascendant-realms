import { describe, expect, it, vi } from "vitest";
import type { BattleMapDefinition, Position, Team } from "../core/GameTypes";
import type { Building } from "../entities/Building";
import type { Unit } from "../entities/Unit";
import { MovementSystem } from "./MovementSystem";

describe("MovementSystem", () => {
  it("does not snap a crowded unit to a distant grid center when separation is blocked", () => {
    const system = new MovementSystem();
    const unit = fakeUnit({ id: "player-1", team: "player", x: 120, y: 120 });
    const overlapping = fakeUnit({ id: "player-2", team: "player", x: 121, y: 120 });

    system.update(0.1, [unit, overlapping], testMap(), [fakeBuilding({ x: 120, y: 120 })]);

    expect(distance(unit.position, { x: 120, y: 120 })).toBeLessThanOrEqual(2);
    expect(distance(overlapping.position, { x: 121, y: 120 })).toBeLessThanOrEqual(2);
  });

  it("keeps repeated move commands advancing instead of resetting to the original point", () => {
    const system = new MovementSystem();
    const unit = fakeUnit({ id: "player-1", team: "player", x: 40, y: 40, moveTarget: { x: 200, y: 40 } });
    const original = { ...unit.position };

    for (let i = 0; i < 5; i += 1) {
      unit.moveTarget = { x: 200, y: 40 };
      system.update(0.1, [unit], testMap());
    }

    expect(unit.position.x).toBeGreaterThan(original.x + 20);
    expect(distance(unit.position, original)).toBeGreaterThan(20);
  });

  it("does not erase move-away combat suppression just because pathing already cleared the target", () => {
    const system = new MovementSystem();
    const unit = fakeUnit({ id: "player-1", team: "player", x: 40, y: 40 });
    unit.moveOrderCombatSuppressionSeconds = 0.75;

    system.update(0.1, [unit], testMap());

    expect(unit.moveOrderCombatSuppressionSeconds).toBe(0.75);
  });

  it("recovers a move-ordered unit that starts inside a blocked building cell", () => {
    const system = new MovementSystem();
    const unit = fakeUnit({ id: "player-1", team: "player", x: 120, y: 120, moveTarget: { x: 220, y: 120 } });

    system.update(0.1, [unit], testMap(), [fakeBuilding({ x: 120, y: 120 })]);

    expect(distance(unit.position, { x: 120, y: 120 })).toBeGreaterThan(20);
    expect(unit.moveTarget).toEqual({ x: 220, y: 120 });
  });

  it("moves toward exact open points that share a coarse static building cell", () => {
    const system = new MovementSystem();
    const unit = fakeUnit({ id: "player-1", team: "player", x: 120, y: 250, moveTarget: { x: 180, y: 250 } });

    system.update(0.1, [unit], testMap({ width: 500, height: 500 }), [
      fakeBuilding({ x: 260, y: 250 }, { width: 96, height: 82 })
    ]);

    expect(unit.position.x).toBeGreaterThan(120);
    expect(unit.moveTarget).toEqual({ x: 180, y: 250 });
  });

  it("moves player units out of a tight player building cluster", () => {
    const system = new MovementSystem();
    const cluster = playerBuildingCluster();
    const units = [
      fakeUnit({ id: "worker", team: "player", x: 326, y: 862, moveTarget: { x: 610, y: 830 } }),
      fakeUnit({ id: "militia", team: "player", x: 338, y: 884, moveTarget: { x: 626, y: 846 } }),
      fakeUnit({ id: "ranger", team: "player", x: 318, y: 906, moveTarget: { x: 642, y: 862 } })
    ];
    const starts = units.map((unit) => ({ ...unit.position }));

    for (let i = 0; i < 30; i += 1) {
      system.update(0.1, units, firstClaimLikeMap(), cluster);
    }

    units.forEach((unit, index) => {
      expect(unit.position.x).toBeGreaterThan(starts[index].x + 24);
      expect(distance(unit.position, starts[index])).toBeGreaterThan(32);
    });
  });

  it("lets a unit near the base cluster advance toward an enemy attack target", () => {
    const system = new MovementSystem();
    const cluster = playerBuildingCluster();
    const unit = fakeUnit({ id: "player-ranger", team: "player", x: 330, y: 884, moveTarget: { x: 720, y: 820 } });
    const start = { ...unit.position };

    for (let i = 0; i < 35; i += 1) {
      system.update(0.1, [unit], firstClaimLikeMap(), cluster);
    }

    expect(unit.position.x).toBeGreaterThan(start.x + 40);
    expect(distance(unit.position, { x: 720, y: 820 })).toBeLessThan(distance(start, { x: 720, y: 820 }) - 40);
  });

  it("treats exact open ground beside blocked terrain as walkable instead of an invisible rock", () => {
    const system = new MovementSystem();
    const unit = fakeUnit({ id: "player-1", team: "player", x: 760, y: 130, moveTarget: { x: 700, y: 130 } });

    system.update(0.2, [unit], {
      ...testMap({ width: 1000, height: 500 }),
      terrainZones: [
        { id: "grass", type: "grass", x: 0, y: 0, width: 1000, height: 500 },
        { id: "water", type: "water", x: 720, y: 160, width: 120, height: 120 }
      ]
    });

    expect(unit.position.x).toBeLessThan(760);
    expect(unit.moveTarget).toEqual({ x: 700, y: 130 });
  });
});

function testMap(overrides: Partial<BattleMapDefinition> = {}): BattleMapDefinition {
  return {
    id: "movement_test",
    name: "Movement Test",
    role: "test",
    description: "Movement system test map",
    strategicNotes: [],
    width: 240,
    height: 240,
    playerStart: { x: 40, y: 40 },
    enemyStart: { x: 200, y: 200 },
    visualPaths: [],
    terrainZones: [{ id: "grass", type: "grass", x: 0, y: 0, width: 240, height: 240 }],
    captureSites: [],
    neutralCamps: [],
    scenario: {
      startingResources: {
        player: { crowns: 0, stone: 0, iron: 0, aether: 0 },
        enemy: { crowns: 0, stone: 0, iron: 0, aether: 0 }
      },
      heroSpawn: { x: 40, y: 40 },
      buildingSpawns: [],
      unitSpawns: [],
      objectives: {
        playerBaseBuildingId: "command_hall",
        enemyBaseBuildingId: "enemy_stronghold"
      },
      enemyAI: {
        incomeInterval: 5,
        incomePerTick: {},
        trainInterval: 5,
        expandInterval: 5,
        initialExpandDelay: 5,
        attackInterval: 5,
        initialAttackDelay: 5,
        minAttackArmySize: 1,
        attackWaveSize: 1,
        expandSquadSize: 1,
        defenseSquadSize: 1,
        defendRadius: 100,
        baseBuildingId: "enemy_stronghold",
        productionBuildingId: "enemy_barracks",
        attackTargetBuildingId: "command_hall",
        unitPlan: ["raider"]
      },
      rewardTableId: "first_claim_rewards"
    },
    ...overrides
  };
}

function firstClaimLikeMap(): BattleMapDefinition {
  return testMap({
    width: 2400,
    height: 1600,
    playerStart: { x: 260, y: 800 },
    enemyStart: { x: 2140, y: 800 },
    terrainZones: [
      { id: "central_grass", type: "grass", x: 0, y: 0, width: 2400, height: 1600 },
      { id: "player_build", type: "buildable", x: 70, y: 590, width: 520, height: 440 },
      { id: "north_water", type: "water", x: 720, y: 160, width: 380, height: 140 },
      { id: "broken_ridge", type: "blocked", x: 1060, y: 660, width: 260, height: 100 }
    ]
  });
}

function fakeUnit(options: { id: string; team: Team; x: number; y: number; moveTarget?: Position }): Unit {
  return {
    id: options.id,
    team: options.team,
    alive: true,
    position: { x: options.x, y: options.y },
    radius: 13,
    speed: 90,
    moveTarget: options.moveTarget,
    updateBuffs: vi.fn(),
    setPosition(this: { position: Position }, x: number, y: number) {
      this.position.x = x;
      this.position.y = y;
    }
  } as unknown as Unit;
}

function fakeBuilding(position: Position, size: { width: number; height: number } = { width: 120, height: 120 }): Building {
  return {
    id: "blocked-building",
    alive: true,
    position,
    definition: {
      size
    }
  } as Building;
}

function playerBuildingCluster(): Building[] {
  return [
    fakeBuilding({ x: 260, y: 800 }, { width: 96, height: 82 }),
    fakeBuilding({ x: 410, y: 800 }, { width: 82, height: 64 }),
    fakeBuilding({ x: 292, y: 930 }, { width: 72, height: 62 }),
    fakeBuilding({ x: 476, y: 918 }, { width: 48, height: 72 })
  ];
}

function distance(a: Position, b: Position): number {
  return Math.hypot(a.x - b.x, a.y - b.y);
}
