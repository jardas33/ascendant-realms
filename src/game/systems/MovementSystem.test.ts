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
});

function testMap(): BattleMapDefinition {
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
    }
  };
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

function fakeBuilding(position: Position): Building {
  return {
    id: "blocked-building",
    alive: true,
    position,
    definition: {
      size: { width: 120, height: 120 }
    }
  } as Building;
}

function distance(a: Position, b: Position): number {
  return Math.hypot(a.x - b.x, a.y - b.y);
}
