import { describe, expect, it } from "vitest";
import type { BattleMapDefinition } from "../core/GameTypes";
import { PathfindingGrid } from "./PathfindingGrid";

function testMap(overrides: Partial<BattleMapDefinition> = {}): BattleMapDefinition {
  return {
    id: "path_test",
    name: "Path Test",
    role: "test",
    description: "Pathfinding test map",
    strategicNotes: [],
    width: 500,
    height: 500,
    playerStart: { x: 40, y: 40 },
    enemyStart: { x: 460, y: 460 },
    visualPaths: [],
    terrainZones: [{ id: "grass", type: "grass", x: 0, y: 0, width: 500, height: 500 }],
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

describe("PathfindingGrid", () => {
  it("finds a path around a blocked rectangle", () => {
    const grid = PathfindingGrid.fromMap(
      testMap({
        terrainZones: [
          { id: "grass", type: "grass", x: 0, y: 0, width: 500, height: 500 },
          { id: "block", type: "blocked", x: 200, y: 120, width: 100, height: 260 }
        ]
      }),
      { cellSize: 50 }
    );

    const result = grid.findPath({ x: 60, y: 250 }, { x: 440, y: 250 });

    expect(result?.complete).toBe(true);
    expect(result?.waypoints.length).toBeGreaterThan(1);
    result?.waypoints.forEach((point) => {
      expect(point.x < 200 || point.x > 300 || point.y < 120 || point.y > 380).toBe(true);
    });
  });

  it("returns no complete path when the map is fully split", () => {
    const grid = PathfindingGrid.fromMap(
      testMap({
        terrainZones: [
          { id: "grass", type: "grass", x: 0, y: 0, width: 500, height: 500 },
          { id: "wall", type: "water", x: 225, y: 0, width: 50, height: 500 }
        ]
      }),
      { cellSize: 50 }
    );

    expect(grid.findPath({ x: 60, y: 250 }, { x: 440, y: 250 }, { allowPartial: false })).toBeUndefined();
    expect(grid.findPath({ x: 60, y: 250 }, { x: 440, y: 250 }, { allowPartial: true })?.complete).toBe(false);
  });

  it("starts and ends near requested points", () => {
    const grid = PathfindingGrid.fromMap(testMap(), { cellSize: 50 });
    const result = grid.findPath({ x: 62, y: 66 }, { x: 434, y: 438 });

    expect(result?.complete).toBe(true);
    expect(result?.startCell).toEqual({ x: 1, y: 1 });
    expect(result?.endCell).toEqual({ x: 8, y: 8 });
    expect(result?.waypoints.at(-1)).toEqual({ x: 434, y: 438 });
  });

  it("treats static buildings as blocked cells", () => {
    const grid = PathfindingGrid.fromMap(testMap(), {
      cellSize: 50,
      staticObstacles: [{ id: "hall", x: 250, y: 250, width: 120, height: 120, padding: 0 }]
    });
    const result = grid.findPath({ x: 60, y: 250 }, { x: 440, y: 250 });

    expect(grid.isWorldWalkable({ x: 250, y: 250 })).toBe(false);
    expect(result?.complete).toBe(true);
    result?.waypoints.forEach((point) => {
      expect(point.x < 190 || point.x > 310 || point.y < 190 || point.y > 310).toBe(true);
    });
  });

  it("keeps precise open points walkable when their coarse static cell is blocked", () => {
    const grid = PathfindingGrid.fromMap(testMap(), {
      cellSize: 80,
      staticObstacles: [{ id: "hall", x: 260, y: 250, width: 96, height: 82, padding: 16 }]
    });

    expect(grid.isCellWalkable(2, 3)).toBe(false);
    expect(grid.isWorldWalkable({ x: 260, y: 250 })).toBe(false);
    expect(grid.isWorldWalkable({ x: 180, y: 250 })).toBe(true);

    const result = grid.findPath({ x: 440, y: 250 }, { x: 180, y: 250 });

    expect(result?.complete).toBe(true);
    expect(result?.endCell).toEqual({ x: 2, y: 3 });
    expect(result?.waypoints.at(-1)).toEqual({ x: 180, y: 250 });
  });

  it("keeps precise blocker interiors solid even when the cell center is open", () => {
    const grid = PathfindingGrid.fromMap(
      testMap({
        width: 900,
        height: 900,
        terrainZones: [{ id: "grass", type: "grass", x: 0, y: 0, width: 900, height: 900 }]
      }),
      {
      cellSize: 40,
      staticObstacles: [{ id: "barracks", x: 360, y: 680, width: 82, height: 64, padding: 16 }]
      }
    );

    expect(grid.isCellWalkable(9, 15)).toBe(true);
    expect(grid.isWorldWalkable({ x: 392, y: 639 })).toBe(false);
    expect(grid.isWorldWalkable({ x: 382, y: 625 })).toBe(true);
  });
});
