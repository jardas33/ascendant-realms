import { describe, expect, it } from "vitest";
import { BUILDING_BY_ID, UNIT_BY_ID } from "../data/contentIndex";
import { FIRST_CLAIM_MAP } from "../data/maps/firstClaim";
import type { Building } from "../entities/Building";
import type { Unit } from "../entities/Unit";
import { RepairSystem, isWorkerInRepairRange } from "./RepairSystem";

describe("RepairSystem worker repair", () => {
  it("does not repair a damaged completed building from proximity alone", () => {
    const worker = fakeWorker({ x: 360, y: 800 });
    const barracks = fakeBuilding("barracks", { x: 430, y: 800 }, { hp: 360 });
    const system = createSystem([barracks], [worker]);

    system.update(4);

    expect(barracks.hp).toBe(360);
    expect(worker.activeRepairTargetId).toBeUndefined();
    expect(worker.pausedRepairTargetId).toBeUndefined();
  });

  it.each(["command_hall", "barracks", "mystic_lodge", "watchtower"] as const)(
    "repairs damaged friendly completed %s buildings while the Worker is in range",
    (buildingId) => {
      const worker = fakeWorker({ x: 360, y: 800 });
      const building = fakeBuilding(buildingId, { x: 430, y: 800 }, { hp: BUILDING_BY_ID[buildingId].maxHp - 120 });
      const messages: string[] = [];
      const system = createSystem([building], [worker], messages);

      expect(system.requestRepair(worker, building)).toBe(true);
      const before = building.hp;
      system.update(1.5);

      expect(building.hp).toBeGreaterThan(before);
      expect(building.hp).toBeLessThanOrEqual(building.maxHp);
      expect(worker.activeRepairTargetId).toBe(building.id);
      expect(messages).toContain(`Repair order accepted: Worker -> ${building.definition.name}`);
    }
  );

  it("does not repair enemy buildings", () => {
    const worker = fakeWorker({ x: 360, y: 800 });
    const enemyBarracks = fakeBuilding("barracks", { x: 430, y: 800 }, { team: "enemy", hp: 300 });
    const messages: string[] = [];
    const system = createSystem([enemyBarracks], [worker], messages);

    expect(system.requestRepair(worker, enemyBarracks)).toBe(false);
    system.update(4);

    expect(enemyBarracks.hp).toBe(300);
    expect(worker.activeRepairTargetId).toBeUndefined();
    expect(messages).toContain("Workers cannot repair enemy buildings.");
  });

  it("does not repair full-health completed buildings and reports the clear status", () => {
    const worker = fakeWorker({ x: 360, y: 800 });
    const barracks = fakeBuilding("barracks", { x: 430, y: 800 });
    const messages: string[] = [];
    const system = createSystem([barracks], [worker], messages);

    expect(system.requestRepair(worker, barracks)).toBe(false);

    expect(worker.activeRepairTargetId).toBeUndefined();
    expect(messages).toContain("Barracks is already at full health.");
  });

  it("does not treat incomplete construction sites as repair targets", () => {
    const worker = fakeWorker({ x: 360, y: 800 });
    const site = fakeBuilding("barracks", { x: 430, y: 800 }, { hp: 300, completed: false });
    const messages: string[] = [];
    const system = createSystem([site], [worker], messages);

    expect(system.requestRepair(worker, site)).toBe(false);
    system.update(5);

    expect(site.hp).toBe(300);
    expect(worker.activeRepairTargetId).toBeUndefined();
    expect(messages).toContain("Construction must finish before repairs.");
  });

  it("pauses after an explicit move-away and only resumes when Repair is issued again", () => {
    const worker = fakeWorker({ x: 360, y: 800 });
    const barracks = fakeBuilding("barracks", { x: 430, y: 800 }, { hp: 360 });
    const system = createSystem([barracks], [worker]);

    expect(system.requestRepair(worker, barracks)).toBe(true);
    system.update(1);
    const repairedBeforeMove = barracks.hp;

    const moveAway = { x: 140, y: 650 };
    worker.commandMove(moveAway);
    worker.position = { x: 210, y: 660 };
    system.update(5);

    expect(barracks.hp).toBe(repairedBeforeMove);
    expect(worker.moveTarget).toEqual(moveAway);
    expect(worker.activeRepairTargetId).toBeUndefined();
    expect(worker.pausedRepairTargetId).toBe(barracks.id);

    worker.commandMove({ x: 360, y: 800 });
    worker.position = { x: 360, y: 800 };
    system.update(2);

    expect(barracks.hp).toBe(repairedBeforeMove);
    expect(worker.activeRepairTargetId).toBeUndefined();

    expect(system.requestRepair(worker, barracks)).toBe(true);
    system.update(2);

    expect(barracks.hp).toBeGreaterThan(repairedBeforeMove);
    expect(worker.activeRepairTargetId).toBe(barracks.id);
  });

  it("pauses repair when the Worker receives an explicit attack order", () => {
    const worker = fakeWorker({ x: 360, y: 800 });
    const barracks = fakeBuilding("barracks", { x: 430, y: 800 }, { hp: 360 });
    const system = createSystem([barracks], [worker]);

    expect(system.requestRepair(worker, barracks)).toBe(true);
    system.update(1);
    const repairedBeforeAttack = barracks.hp;

    worker.commandAttack("enemy-raider", "Raider");
    system.update(4);

    expect(barracks.hp).toBe(repairedBeforeAttack);
    expect(worker.attackTargetId).toBe("enemy-raider");
    expect(worker.activeRepairTargetId).toBeUndefined();
    expect(worker.pausedRepairTargetId).toBe(barracks.id);
  });


  it("moves an active repair Worker to a valid approach point without entering the footprint", () => {
    const worker = fakeWorker({ x: 240, y: 790 });
    const commandHall = fakeBuilding("command_hall", { x: 260, y: 800 });
    const watchtower = fakeBuilding("watchtower", { x: 470, y: 830 }, { hp: 220 });
    const system = createSystem([commandHall, watchtower], [worker]);

    expect(system.requestRepair(worker, watchtower)).toBe(true);

    expect(worker.moveTarget).toBeDefined();
    expect(worker.activeRepairTargetId).toBe(watchtower.id);
    expect(pointInsideFootprint(worker.moveTarget!, watchtower)).toBe(false);
    expect(isWorkerInRepairRange(watchtower, worker)).toBe(false);
  });
});

function createSystem(buildings: Building[], units: Unit[], messages: string[] = []): RepairSystem {
  return new RepairSystem({
    map: FIRST_CLAIM_MAP,
    getBuildings: () => buildings,
    getUnits: () => units,
    onMessage: (message) => messages.push(message)
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
    activeRepairTargetId: undefined as Unit["activeRepairTargetId"],
    pausedRepairTargetId: undefined as Unit["pausedRepairTargetId"],
    moveTarget: undefined as Unit["moveTarget"],
    attackTargetId: undefined as Unit["attackTargetId"],
    attackTargetLabel: undefined as Unit["attackTargetLabel"],
    attackMove: false,
    commandMove(target: { x: number; y: number }) {
      if (this.activeConstructionSiteId) {
        this.pausedConstructionSiteId = this.activeConstructionSiteId;
      }
      if (this.activeRepairTargetId) {
        this.pausedRepairTargetId = this.activeRepairTargetId;
      }
      this.activeConstructionSiteId = undefined;
      this.activeRepairTargetId = undefined;
      this.moveTarget = { ...target };
      this.attackTargetId = undefined;
      this.attackTargetLabel = undefined;
      this.attackMove = false;
    },
    commandAttack(targetId: string, targetLabel?: string) {
      if (this.activeConstructionSiteId) {
        this.pausedConstructionSiteId = this.activeConstructionSiteId;
      }
      if (this.activeRepairTargetId) {
        this.pausedRepairTargetId = this.activeRepairTargetId;
      }
      this.activeConstructionSiteId = undefined;
      this.activeRepairTargetId = undefined;
      this.attackTargetId = targetId;
      this.attackTargetLabel = targetLabel;
      this.attackMove = true;
    },
    commandRepairMove(target: { x: number; y: number }, repairTargetId: string) {
      if (this.activeConstructionSiteId) {
        this.pausedConstructionSiteId = this.activeConstructionSiteId;
      }
      this.activeConstructionSiteId = undefined;
      this.activeRepairTargetId = repairTargetId;
      this.pausedRepairTargetId = undefined;
      this.moveTarget = { ...target };
      this.attackTargetId = undefined;
      this.attackTargetLabel = undefined;
      this.attackMove = false;
    },
    markRepairWork(repairTargetId: string) {
      if (this.activeConstructionSiteId) {
        this.pausedConstructionSiteId = this.activeConstructionSiteId;
      }
      this.activeConstructionSiteId = undefined;
      this.activeRepairTargetId = repairTargetId;
      this.pausedRepairTargetId = undefined;
      this.attackTargetId = undefined;
      this.attackTargetLabel = undefined;
      this.attackMove = false;
    },
    clearRepairWork(repairTargetId?: string) {
      if (!repairTargetId || this.activeRepairTargetId === repairTargetId) {
        this.activeRepairTargetId = undefined;
      }
      if (!repairTargetId || this.pausedRepairTargetId === repairTargetId) {
        this.pausedRepairTargetId = undefined;
      }
    }
  }) as Unit;
}

function fakeBuilding(
  buildingId: keyof typeof BUILDING_BY_ID,
  position: { x: number; y: number },
  options: {
    team?: "player" | "enemy";
    hp?: number;
    completed?: boolean;
  } = {}
): Building {
  const definition = BUILDING_BY_ID[buildingId];
  return Object.assign(Object.create(Object.prototype), {
    id: `${options.team ?? "player"}-${buildingId}`,
    kind: "building",
    team: options.team ?? "player",
    alive: true,
    position,
    radius: Math.max(definition.size.width, definition.size.height) / 2,
    definition,
    hp: options.hp ?? definition.maxHp,
    maxHp: definition.maxHp,
    isCompleted: () => options.completed ?? true,
    isUnderConstruction: () => !(options.completed ?? true),
    heal(amount: number) {
      const before = this.hp;
      this.hp = Math.min(this.maxHp, this.hp + amount);
      return this.hp - before;
    }
  }) as Building;
}

function pointInsideFootprint(point: { x: number; y: number }, building: Building): boolean {
  return (
    Math.abs(point.x - building.position.x) <= building.definition.size.width / 2 &&
    Math.abs(point.y - building.position.y) <= building.definition.size.height / 2
  );
}
