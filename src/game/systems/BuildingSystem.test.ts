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
    worker.activeConstructionSiteId = "site-1";
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
    expect(site.constructionStatusDetail).toBe("Building");
    expect(worker.activeConstructionSiteId).toBe(site.id);
  });

  it("does not pull a Worker back after an explicit move-away order", () => {
    let progressedSeconds = 0;
    const worker = fakeWorker({ x: 360, y: 800 });
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

    system.update(1);
    expect(progressedSeconds).toBe(1);
    expect(worker.activeConstructionSiteId).toBe(site.id);

    const explicitMoveTarget = { x: 160, y: 640 };
    worker.commandMove(explicitMoveTarget);
    worker.position = { x: 230, y: 650 };
    system.update(5);

    expect(progressedSeconds).toBe(1);
    expect(site.constructionProgressing).toBe(false);
    expect(site.constructionStatusDetail).toBe("Paused - Worker away");
    expect(worker.moveTarget).toEqual(explicitMoveTarget);
    expect(worker.activeConstructionSiteId).toBeUndefined();
    expect(worker.pausedConstructionSiteId).toBe(site.id);
  });

  it("pauses immediately when an explicit move-away is issued before the Worker leaves range", () => {
    let progressedSeconds = 0;
    const worker = fakeWorker({ x: 360, y: 800 });
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

    system.update(1);
    worker.commandMove({ x: 160, y: 640 });
    system.update(3);

    expect(progressedSeconds).toBe(1);
    expect(site.constructionProgressing).toBe(false);
    expect(site.constructionStatusDetail).toBe("Paused - Worker away");
    expect(worker.moveTarget).toEqual({ x: 160, y: 640 });
  });

  it("resumes paused construction when the assigned Worker moves back into range", () => {
    let progressedSeconds = 0;
    const worker = fakeWorker({ x: 360, y: 800 });
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

    system.update(1);
    worker.commandMove({ x: 160, y: 640 });
    worker.position = { x: 230, y: 650 };
    system.update(5);

    worker.commandMove({ x: 360, y: 800 });
    worker.position = { x: 360, y: 800 };
    system.update(4);

    expect(progressedSeconds).toBe(5);
    expect(site.constructionProgressing).toBe(true);
    expect(site.constructionStatusDetail).toBe("Building");
    expect(worker.activeConstructionSiteId).toBe(site.id);
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

  it("finds Worker approach points around each player building type", () => {
    const worker = fakeWorker({ x: 260, y: 800 });
    const commandHall = fakeCompletedBuilding("command_hall", { x: 260, y: 800 });
    const sites = [
      fakeConstructionSite({ x: 430, y: 800, assignedWorkerId: worker.id, buildingId: "barracks" }),
      fakeConstructionSite({ x: 300, y: 930, assignedWorkerId: worker.id, buildingId: "mystic_lodge" }),
      fakeConstructionSite({ x: 480, y: 930, assignedWorkerId: worker.id, buildingId: "watchtower" })
    ];

    sites.forEach((site) => {
      const buildings = [commandHall, ...sites];
      const approach = findConstructionApproachPoint({
        map: FIRST_CLAIM_MAP,
        building: site,
        worker,
        buildings
      });

      expect(pointInsideFootprint(approach, site)).toBe(false);
      buildings.forEach((building) => {
        expect(pointInsidePaddedFootprint(approach, building, worker.radius)).toBe(false);
      });
    });
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
    activeConstructionSiteId: undefined as Unit["activeConstructionSiteId"],
    pausedConstructionSiteId: undefined as Unit["pausedConstructionSiteId"],
    moveTarget: undefined as Unit["moveTarget"],
    commandMove(target: { x: number; y: number }) {
      if (this.activeConstructionSiteId) {
        this.pausedConstructionSiteId = this.activeConstructionSiteId;
      }
      this.activeConstructionSiteId = undefined;
      this.moveTarget = { ...target };
    },
    commandConstructionMove(target: { x: number; y: number }, siteId: string) {
      this.activeConstructionSiteId = siteId;
      this.pausedConstructionSiteId = undefined;
      this.moveTarget = { ...target };
    },
    markConstructionWork(siteId: string) {
      this.activeConstructionSiteId = siteId;
      this.pausedConstructionSiteId = undefined;
    }
  }) as Unit;
}

function fakeConstructionSite(options: {
  x: number;
  y: number;
  assignedWorkerId?: string;
  buildingId?: keyof typeof BUILDING_BY_ID;
  updateConstruction?: (deltaSeconds: number) => boolean;
}): Building {
  const definition = BUILDING_BY_ID[options.buildingId ?? "barracks"];
  return Object.assign(Object.create(Object.prototype), {
    id: "site-1",
    kind: "building",
    team: "player",
    alive: true,
    position: { x: options.x, y: options.y },
    radius: Math.max(definition.size.width, definition.size.height) / 2,
    definition,
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

function pointInsidePaddedFootprint(point: { x: number; y: number }, building: Building, padding: number): boolean {
  return (
    Math.abs(point.x - building.position.x) <= building.definition.size.width / 2 + padding &&
    Math.abs(point.y - building.position.y) <= building.definition.size.height / 2 + padding
  );
}
