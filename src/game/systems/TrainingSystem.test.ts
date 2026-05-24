import type Phaser from "phaser";
import { describe, expect, it, vi } from "vitest";
import type { BattleMapDefinition, Position } from "../core/GameTypes";
import { BUILDING_BY_ID, UNIT_BY_ID } from "../data/contentIndex";
import { FIRST_CLAIM_MAP } from "../data/maps/firstClaim";
import type { Building } from "../entities/Building";
import type { Unit } from "../entities/Unit";
import { MovementSystem } from "./MovementSystem";
import { DEFAULT_PATHFINDING_CELL_SIZE, PathfindingGrid, type PathfindingStaticObstacle } from "./PathfindingGrid";
import { findWalkableTrainedUnitSpawnPoint, TrainingSystem } from "./TrainingSystem";

describe("TrainingSystem", () => {
  it("trains Workers from the Command Hall without moving army production", () => {
    const commandHall = fakeBuilding("command_hall", { x: 260, y: 800 });
    const trainedUnits: Unit[] = [];
    const training = new TrainingSystem({
      scene: createSceneStub(),
      addUnit: (unit) => trainedUnits.push(unit),
      onMessage: () => {},
      resolveSpawnPoint: ({ preferredPoint }) => preferredPoint
    });
    const resources = { crowns: 100, stone: 0, iron: 0, aether: 0 };

    expect(training.queueTraining(commandHall, "worker", resources)).toBe(true);
    expect(resources.crowns).toBe(50);

    training.update(99, [commandHall]);

    expect(trainedUnits).toHaveLength(1);
    expect(trainedUnits[0].definition.id).toBe("worker");
    expect(UNIT_BY_ID.worker.buildOptions).toEqual(["barracks", "mystic_lodge", "watchtower"]);
    expect(commandHall.definition.trainOptions).toEqual(["worker"]);
    expect(commandHall.definition.buildOptions).toEqual([]);
    expect(BUILDING_BY_ID.barracks.trainOptions).toEqual(["militia", "ranger"]);
  });

  it("keeps later Tutorial Rangers from spawning in blocked Command Hall cells", () => {
    const commandHall = fakeBuilding("command_hall", { x: 260, y: 800 });
    const barracks = fakeBuilding("barracks", { x: 360, y: 680 });
    const ranger = UNIT_BY_ID.ranger;
    const preferredPoint = preferredTrainingSpawnPoint(barracks, ranger.radius, 5);
    const grid = tutorialGrid([commandHall, barracks]);

    expect(isOutsideBuildingFootprints(preferredPoint, ranger.radius, [commandHall, barracks])).toBe(false);

    const spawnPoint = findWalkableTrainedUnitSpawnPoint({
      map: FIRST_CLAIM_MAP,
      buildings: [commandHall, barracks],
      building: barracks,
      unitDefinition: ranger,
      preferredPoint,
      spawnIndex: 5
    });

    expect(grid.isWorldWalkable(spawnPoint)).toBe(true);
    expect(isOutsideBuildingFootprints(spawnPoint, ranger.radius, [commandHall, barracks])).toBe(true);
  });

  it("trains a cluster of Tutorial Rangers that can answer rally and near-base move orders", () => {
    const commandHall = fakeBuilding("command_hall", { x: 260, y: 800 });
    const barracks = fakeBuilding("barracks", { x: 360, y: 680 });
    barracks.rallyPoint = { x: 540, y: 830 };
    const buildings = [commandHall, barracks];
    const trainedUnits: Unit[] = [];
    const training = new TrainingSystem({
      scene: createSceneStub(),
      addUnit: (unit) => trainedUnits.push(unit),
      onMessage: vi.fn(),
      resolveSpawnPoint: (context) =>
        findWalkableTrainedUnitSpawnPoint({
          ...context,
          map: FIRST_CLAIM_MAP,
          buildings
        })
    });

    for (let index = 0; index < 8; index += 1) {
      const queued = training.queueTraining(
        barracks,
        "ranger",
        { crowns: 10_000, stone: 10_000, iron: 10_000, aether: 10_000 },
        { announce: false }
      );
      expect(queued).toBe(true);
      training.update(99, [barracks]);
    }

    expect(trainedUnits).toHaveLength(8);
    const grid = tutorialGrid(buildings);
    trainedUnits.forEach((unit) => {
      expect(grid.isWorldWalkable(unit.position)).toBe(true);
      expect(unit.moveTarget).toEqual(barracks.rallyPoint);
    });

    const starts = new Map(trainedUnits.map((unit) => [unit.id, { ...unit.position }]));
    const movement = new MovementSystem();
    for (let index = 0; index < 20; index += 1) {
      movement.update(0.1, trainedUnits, FIRST_CLAIM_MAP, buildings);
    }

    trainedUnits.forEach((unit) => {
      expect(distance(unit.position, starts.get(unit.id)!)).toBeGreaterThan(12);
    });

    const visibleOpenWestOfCommandHall = { x: 180, y: 800 };
    const visibleOpenCell = grid.worldToCell(visibleOpenWestOfCommandHall);
    expect(grid.isCellWalkable(visibleOpenCell.x, visibleOpenCell.y)).toBe(false);
    expect(grid.isWorldWalkable(visibleOpenWestOfCommandHall)).toBe(true);

    [
      { label: "visible-open west side of the Command Hall", target: visibleOpenWestOfCommandHall },
      { label: "north side of the Barracks", target: { x: 430, y: 620 } },
      { label: "main road rally lane", target: { x: 540, y: 830 } }
    ].forEach((order) => {
      const orderStarts = new Map(trainedUnits.map((unit) => [unit.id, { ...unit.position }]));
      trainedUnits.forEach((unit) => unit.commandMove(order.target, false));
      for (let index = 0; index < 20; index += 1) {
        movement.update(0.1, trainedUnits, FIRST_CLAIM_MAP, buildings);
      }
      trainedUnits.forEach((unit) => {
        expect(distance(unit.position, orderStarts.get(unit.id)!), order.label).toBeGreaterThan(12);
      });
    });
  });
});

function fakeBuilding(buildingId: "command_hall" | "barracks", position: Position): Building {
  const definition = BUILDING_BY_ID[buildingId];
  return {
    id: buildingId,
    alive: true,
    team: "player",
    position: { ...position },
    radius: Math.max(definition.size.width, definition.size.height) / 2,
    definition,
    trainingQueue: [],
    isCompleted: () => true
  } as unknown as Building;
}

function preferredTrainingSpawnPoint(building: Building, unitRadius: number, spawnIndex: number): Position {
  const angle = spawnIndex * 1.7;
  const distanceFromBuilding = building.radius + unitRadius + 24;
  return {
    x: building.position.x + Math.cos(angle) * distanceFromBuilding,
    y: building.position.y + Math.sin(angle) * distanceFromBuilding
  };
}

function tutorialGrid(buildings: Building[]): PathfindingGrid {
  return PathfindingGrid.fromMap(FIRST_CLAIM_MAP, {
    cellSize: DEFAULT_PATHFINDING_CELL_SIZE,
    staticObstacles: staticObstaclesForBuildings(buildings)
  });
}

function staticObstaclesForBuildings(buildings: Building[]): PathfindingStaticObstacle[] {
  return buildings.map((building) => ({
    id: building.id,
    x: building.position.x,
    y: building.position.y,
    width: building.definition.size.width,
    height: building.definition.size.height,
    padding: 16
  }));
}

function isOutsideBuildingFootprints(point: Position, unitRadius: number, buildings: Building[]): boolean {
  return buildings.every((building) => {
    const dx = Math.max(Math.abs(point.x - building.position.x) - building.definition.size.width / 2, 0);
    const dy = Math.max(Math.abs(point.y - building.position.y) - building.definition.size.height / 2, 0);
    return Math.hypot(dx, dy) >= unitRadius + 8;
  });
}

function createSceneStub(): Phaser.Scene {
  const makeObject = (overrides: Record<string, unknown> = {}) => {
    const object: Record<string, unknown> = {
      x: 0,
      y: 0,
      width: 48,
      height: 48,
      displayWidth: 0,
      add: vi.fn(() => object),
      addAt: vi.fn(() => object),
      moveTo: vi.fn(() => object),
      setAlpha: vi.fn(() => object),
      setColor: vi.fn(() => object),
      setDepth: vi.fn(() => object),
      setDisplaySize: vi.fn(() => object),
      setOrigin: vi.fn(() => object),
      setPosition: vi.fn((x: number, y: number) => {
        object.x = x;
        object.y = y;
        return object;
      }),
      setSize: vi.fn(() => object),
      setSmoothness: vi.fn(() => object),
      setStrokeStyle: vi.fn(() => object),
      setTint: vi.fn(() => object),
      setVisible: vi.fn(() => object),
      setY: vi.fn((y: number) => {
        object.y = y;
        return object;
      }),
      clearTint: vi.fn(() => object),
      destroy: vi.fn()
    };
    return Object.assign(object, overrides);
  };

  return {
    textures: {
      exists: vi.fn(() => false)
    },
    add: {
      circle: vi.fn(() => makeObject()),
      container: vi.fn((x: number, y: number) => makeObject({ x, y })),
      ellipse: vi.fn(() => makeObject()),
      image: vi.fn(() => makeObject()),
      rectangle: vi.fn(() => makeObject()),
      text: vi.fn(() => makeObject())
    }
  } as unknown as Phaser.Scene;
}

function distance(a: Position, b: Position): number {
  return Math.hypot(a.x - b.x, a.y - b.y);
}
