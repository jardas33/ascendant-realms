import type Phaser from "phaser";
import { describe, expect, it } from "vitest";
import { BUILDING_BY_ID, UNIT_BY_ID } from "../data/contentIndex";
import { FIRST_CLAIM_MAP } from "../data/maps/firstClaim";
import type { Building } from "../entities/Building";
import type { Unit } from "../entities/Unit";
import { BuildingSystem, findConstructionApproachPoint, isWorkerInConstructionRange } from "./BuildingSystem";

describe("BuildingSystem worker construction", () => {
  it("pauses assigned construction until the Worker is close enough", () => {
    let progressedSeconds = 0;
    const worker = fakeWorker({ x: 260, y: 800 });
    const site = fakeConstructionSite({
      x: 430,
      y: 800,
      assignedWorkerId: worker.id,
      updateConstruction: (deltaSeconds) => {
        progressedSeconds += deltaSeconds;
        return false;
      }
    });
    const system = createSystem([site], [worker]);

    system.update(4);

    expect(progressedSeconds).toBe(0);
    expect(site.constructionProgressing).toBe(false);
    expect(site.constructionStatusDetail).toBe("Worker traveling");
    expect(worker.moveTarget).toBeDefined();

    worker.position = { x: 360, y: 800 };
    system.update(5);

    expect(progressedSeconds).toBe(5);
    expect(site.constructionProgressing).toBe(true);
    expect(site.constructionStatusDetail).toBe("Worker building");
  });

  it("fires the completion callback when an assigned Worker finishes the site", () => {
    const completed: string[] = [];
    const messages: string[] = [];
    const worker = fakeWorker({ x: 360, y: 800 });
    const site = fakeConstructionSite({
      x: 430,
      y: 800,
      assignedWorkerId: worker.id,
      updateConstruction: () => true
    });
    const system = createSystem([site], [worker], {
      onBuilt: (building) => completed.push(building.definition.id),
      onMessage: (message) => messages.push(message)
    });

    system.update(1);

    expect(completed).toEqual(["barracks"]);
    expect(messages).toContain("Barracks complete");
  });

  it("finds a walkable Worker approach point outside construction footprints", () => {
    const worker = fakeWorker({ x: 260, y: 800 });
    const commandHall = fakeCompletedBuilding("command_hall", { x: 260, y: 800 });
    const site = fakeConstructionSite({ x: 430, y: 800, assignedWorkerId: worker.id });

    const approach = findConstructionApproachPoint({
      map: FIRST_CLAIM_MAP,
      building: site,
      worker,
      buildings: [commandHall, site]
    });

    expect(pointInsideFootprint(approach, site)).toBe(false);
    expect(pointInsideFootprint(approach, commandHall)).toBe(false);
    expect(approach.x).toBeGreaterThanOrEqual(worker.radius);
    expect(approach.y).toBeGreaterThanOrEqual(worker.radius);
    expect(approach.x).toBeLessThanOrEqual(FIRST_CLAIM_MAP.width - worker.radius);
    expect(approach.y).toBeLessThanOrEqual(FIRST_CLAIM_MAP.height - worker.radius);
  });

  it("treats diagonal footprint-adjacent Workers as close enough to build", () => {
    const site = fakeConstructionSite({ x: 430, y: 800, assignedWorkerId: "worker-1" });
    const worker = fakeWorker({ x: 337, y: 726 });

    expect(isWorkerInConstructionRange(site, worker)).toBe(true);
  });
});

function createSystem(
  buildings: Building[],
  units: Unit[],
  overrides: Partial<{
    onBuilt: (building: Building) => void;
    onMessage: (message: string) => void;
  }> = {}
): BuildingSystem {
  return new BuildingSystem({
    scene: {} as Phaser.Scene,
    map: FIRST_CLAIM_MAP,
    getBuildings: () => buildings,
    getUnits: () => units,
    getCaptureSites: () => [],
    addBuilding: (building) => buildings.push(building),
    onMessage: overrides.onMessage ?? (() => {}),
    onBuilt: overrides.onBuilt
  });
}

function fakeWorker(position: { x: number; y: number }): Unit {
  return Object.assign(Object.create(Object.prototype), {
    id: "worker-1",
    kind: "unit",
    team: "player",
    alive: true,
    radius: UNIT_BY_ID.worker.radius,
    position,
    definition: UNIT_BY_ID.worker,
    moveTarget: undefined as Unit["moveTarget"],
    commandMove(target: { x: number; y: number }) {
      this.moveTarget = { ...target };
    }
  }) as Unit;
}

function fakeConstructionSite(options: {
  x: number;
  y: number;
  assignedWorkerId?: string;
  updateConstruction?: (deltaSeconds: number) => boolean;
}): Building {
  return Object.assign(Object.create(Object.prototype), {
    id: "site-1",
    kind: "building",
    team: "player",
    alive: true,
    position: { x: options.x, y: options.y },
    radius: Math.max(BUILDING_BY_ID.barracks.size.width, BUILDING_BY_ID.barracks.size.height) / 2,
    definition: BUILDING_BY_ID.barracks,
    assignedWorkerId: options.assignedWorkerId,
    assignedWorkerName: options.assignedWorkerId ? "Worker" : undefined,
    constructionStatusDetail: "",
    constructionProgressing: false,
    isUnderConstruction: () => true,
    updateConstruction: options.updateConstruction ?? (() => false)
  }) as Building;
}

function fakeCompletedBuilding(buildingId: keyof typeof BUILDING_BY_ID, position: { x: number; y: number }): Building {
  const definition = BUILDING_BY_ID[buildingId];
  return Object.assign(Object.create(Object.prototype), {
    id: buildingId,
    kind: "building",
    team: "player",
    alive: true,
    position,
    radius: Math.max(definition.size.width, definition.size.height) / 2,
    definition,
    isUnderConstruction: () => false
  }) as Building;
}

function pointInsideFootprint(point: { x: number; y: number }, building: Building): boolean {
  return (
    Math.abs(point.x - building.position.x) <= building.definition.size.width / 2 &&
    Math.abs(point.y - building.position.y) <= building.definition.size.height / 2
  );
}
