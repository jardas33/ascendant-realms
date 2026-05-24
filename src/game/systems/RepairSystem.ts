import type { BattleMapDefinition, Position } from "../core/GameTypes";
import { distance } from "../core/MathUtils";
import type { BaseEntity } from "../entities/BaseEntity";
import { Building } from "../entities/Building";
import type { Unit } from "../entities/Unit";
import { findConstructionApproachPoint, isPointInBuildingWorkRange } from "./BuildingSystem";

interface RepairSystemMessageOptions {
  durationSeconds?: number;
  priority?: "normal" | "command" | "pressure" | "objective";
}

interface RepairSystemOptions {
  map: BattleMapDefinition;
  getUnits: () => Unit[];
  getBuildings: () => Building[];
  onMessage: (message: string, x?: number, y?: number, color?: string, options?: RepairSystemMessageOptions) => void;
}

export interface RepairTargetSummary {
  id: string;
  name: string;
  hp: number;
  maxHp: number;
  isRepairable: boolean;
  status: string;
}

export const WORKER_REPAIR_RATE_PER_SECOND = 12;

export class RepairSystem {
  constructor(private readonly options: RepairSystemOptions) {}

  update(deltaSeconds: number): void {
    this.options.getUnits().forEach((worker) => {
      if (!isRepairWorker(worker) || !worker.alive) {
        return;
      }
      const targetId = worker.activeRepairTargetId ?? worker.pausedRepairTargetId;
      if (!targetId) {
        return;
      }
      const target = this.buildingForId(targetId);
      if (!target || !isFriendlyRepairTarget(worker, target) || !target.isCompleted()) {
        worker.clearRepairWork(targetId);
        return;
      }
      if (target.hp >= target.maxHp) {
        worker.clearRepairWork(targetId);
        return;
      }

      const closeEnough = isWorkerInRepairRange(target, worker);
      const movingAwayFromWorkRange =
        worker.pausedRepairTargetId === target.id &&
        worker.moveTarget !== undefined &&
        !isPointInBuildingWorkRange(target, worker.moveTarget);
      const attackingAwayFromRepair = worker.pausedRepairTargetId === target.id && worker.attackTargetId !== undefined;

      if (movingAwayFromWorkRange || attackingAwayFromRepair) {
        return;
      }

      if (!closeEnough) {
        if (worker.activeRepairTargetId !== target.id) {
          return;
        }
        const approach = findRepairApproachPoint({
          map: this.options.map,
          target,
          worker,
          buildings: this.options.getBuildings()
        });
        commandWorkerToRepairApproach(worker, approach, target.id);
        return;
      }

      worker.markRepairWork(target.id);
      target.heal(WORKER_REPAIR_RATE_PER_SECOND * deltaSeconds);
      if (target.hp >= target.maxHp) {
        worker.clearRepairWork(target.id);
        this.options.onMessage(`${target.definition.name} repaired`, target.position.x, target.position.y - 54, "#d9eee8", {
          priority: "command"
        });
      }
    });
  }

  requestRepair(worker: Unit | undefined, target: Building | undefined): boolean {
    const validation = validateRepairRequest(worker, target);
    if (!validation.ok) {
      const point = target?.position ?? worker?.position;
      this.options.onMessage(validation.reason, point?.x, point ? point.y - 36 : undefined, "#ffd27a", {
        priority: "command"
      });
      return false;
    }

    const repairWorker = worker!;
    const repairTarget = target!;
    if (isWorkerInRepairRange(repairTarget, repairWorker)) {
      repairWorker.markRepairWork(repairTarget.id);
      repairWorker.moveTarget = undefined;
    } else {
      const approach = findRepairApproachPoint({
        map: this.options.map,
        target: repairTarget,
        worker: repairWorker,
        buildings: this.options.getBuildings()
      });
      commandWorkerToRepairApproach(repairWorker, approach, repairTarget.id);
    }

    this.options.onMessage(
      `Repair order accepted: ${repairWorker.definition.name} -> ${repairTarget.definition.name}`,
      repairTarget.position.x,
      repairTarget.position.y - 54,
      "#d9eee8",
      { priority: "command" }
    );
    return true;
  }

  issueRepairOrder(target: BaseEntity | undefined, selectedUnits: Unit[]): boolean {
    if (!(target instanceof Building) || target.team !== "player") {
      return false;
    }

    const workers = selectedUnits.filter((unit) => isRepairWorker(unit) && unit.alive && unit.team === "player");
    if (workers.length === 0) {
      return false;
    }

    const validation = validateRepairRequest(workers[0], target);
    if (!validation.ok) {
      this.options.onMessage(validation.reason, target.position.x, target.position.y - 54, "#ffd27a", {
        priority: "command"
      });
      return true;
    }

    workers.forEach((worker) => this.requestRepair(worker, target));
    return true;
  }

  repairTargetSummaries(): RepairTargetSummary[] {
    return this.options
      .getBuildings()
      .filter((building) => building.alive && building.team === "player" && building.isCompleted())
      .map((building) => ({
        id: building.id,
        name: building.definition.name,
        hp: building.hp,
        maxHp: building.maxHp,
        isRepairable: building.hp < building.maxHp,
        status: building.hp < building.maxHp ? `Damaged: ${Math.ceil(building.hp)}/${building.maxHp} HP` : "Full health"
      }));
  }

  private buildingForId(buildingId: string): Building | undefined {
    return this.options.getBuildings().find((building) => building.id === buildingId && building.alive);
  }
}

export function isWorkerInRepairRange(building: Building, worker: Unit): boolean {
  return isPointInBuildingWorkRange(building, worker.position);
}

export function isRepairWorker(unit: Unit): boolean {
  return unit.definition.id === "worker";
}

export function validateRepairRequest(
  worker: Unit | undefined,
  target: Building | undefined
): { ok: true } | { ok: false; reason: string } {
  if (!worker || !worker.alive || worker.team !== "player" || !isRepairWorker(worker)) {
    return { ok: false, reason: "Select a Worker to repair." };
  }
  if (!target?.alive) {
    return { ok: false, reason: "No repair target selected." };
  }
  if (!isFriendlyRepairTarget(worker, target)) {
    return { ok: false, reason: "Workers cannot repair enemy buildings." };
  }
  if (!target.isCompleted()) {
    return { ok: false, reason: "Construction must finish before repairs." };
  }
  if (target.hp >= target.maxHp) {
    return { ok: false, reason: `${target.definition.name} is already at full health.` };
  }
  return { ok: true };
}

function isFriendlyRepairTarget(worker: Unit, target: Building): boolean {
  return target.team === worker.team && target.team === "player";
}

function findRepairApproachPoint(options: {
  map: BattleMapDefinition;
  target: Building;
  worker: Unit;
  buildings: Building[];
}): Position {
  return findConstructionApproachPoint({
    map: options.map,
    building: options.target,
    worker: options.worker,
    buildings: options.buildings
  });
}

function commandWorkerToRepairApproach(worker: Unit, approach: Position, targetId: string): void {
  if (worker.moveTarget && distance(worker.moveTarget, approach) <= 4) {
    worker.markRepairWork(targetId);
    return;
  }
  worker.commandRepairMove(approach, targetId);
}
