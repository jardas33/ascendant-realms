import { describe, expect, it } from "vitest";
import type { BattleMapDefinition, Position } from "../core/GameTypes";
import type { Building } from "../entities/Building";
import type { Unit } from "../entities/Unit";
import { createFormationMoveTargets } from "./FormationMovement";

describe("FormationMovement", () => {
  it("gives multi-unit movement separated destinations when nearby ground is safe", () => {
    const units = [fakeUnit("militia"), fakeUnit("ranger"), fakeUnit("hero", 19)];

    const targets = createFormationMoveTargets({ x: 300, y: 300 }, units, { map: testMap() });

    expect(targets).toHaveLength(3);
    expect(targets[0]).toEqual({ x: 300, y: 300 });
    expect(new Set(targets.map((target) => `${Math.round(target.x)},${Math.round(target.y)}`)).size).toBe(3);
  });

  it("falls back to the clicked point when an offset lands in blocked terrain", () => {
    const units = [fakeUnit("militia"), fakeUnit("ranger")];
    const map = testMap({
      terrainZones: [
        { id: "grass", type: "grass", x: 0, y: 0, width: 600, height: 600 },
        { id: "blocked", type: "blocked", x: 230, y: 320, width: 60, height: 60 }
      ]
    });

    const targets = createFormationMoveTargets({ x: 300, y: 300 }, units, { map, spacing: 60 });

    expect(targets[1]).toEqual({ x: 300, y: 300 });
  });

  it("shrinks offsets near building blockers instead of placing units inside footprints", () => {
    const units = [fakeUnit("militia"), fakeUnit("ranger")];
    const targets = createFormationMoveTargets({ x: 300, y: 300 }, units, {
      map: testMap(),
      spacing: 60,
      buildings: [fakeBuilding({ x: 260, y: 340 })]
    });

    expect(Math.hypot(targets[1].x - 256, targets[1].y - 336)).toBeGreaterThan(8);
    expect(targets[1].x).toBeGreaterThanOrEqual(13);
    expect(targets[1].y).toBeGreaterThanOrEqual(13);
  });
});

function testMap(overrides: Partial<BattleMapDefinition> = {}): BattleMapDefinition {
  return {
    id: "formation_test",
    name: "Formation Test",
    role: "test",
    description: "Formation movement test map",
    strategicNotes: [],
    width: 600,
    height: 600,
    playerStart: { x: 40, y: 40 },
    enemyStart: { x: 500, y: 500 },
    visualPaths: [],
    terrainZones: [{ id: "grass", type: "grass", x: 0, y: 0, width: 600, height: 600 }],
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
      rewardTableId: "formation_rewards"
    },
    ...overrides
  };
}

function fakeUnit(id: string, radius = 13): Unit {
  return {
    id,
    radius
  } as Unit;
}

function fakeBuilding(position: Position): Building {
  return {
    alive: true,
    position,
    definition: {
      size: { width: 96, height: 82 }
    }
  } as Building;
}
