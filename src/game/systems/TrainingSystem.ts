import Phaser from "phaser";
import type { ResourceBag, Team } from "../core/GameTypes";
import { addResources, canAfford, payCost } from "../core/MathUtils";
import { requireUnit } from "../data/contentIndex";
import { Building } from "../entities/Building";
import { Unit } from "../entities/Unit";
import { checkPrerequisites, type TechState } from "./PrerequisiteSystem";

interface TrainingSystemOptions {
  scene: Phaser.Scene;
  addUnit: (unit: Unit) => void;
  onMessage: (message: string, x?: number, y?: number) => void;
  onUnitTrained?: (unit: Unit) => void;
  getTechState?: (team: Team) => TechState;
}

export class TrainingSystem {
  private spawnCounter = 0;

  constructor(private readonly options: TrainingSystemOptions) {}

  queueTraining(building: Building, unitId: string, resources: ResourceBag, options: { announce?: boolean } = {}): boolean {
    const unitDefinition = requireUnit(unitId);
    const announce = options.announce ?? building.team === "player";
    if (!building.isCompleted()) {
      if (announce) {
        this.options.onMessage("Construction must finish first", building.position.x, building.position.y - 60);
      }
      return false;
    }
    if (!building.definition.trainOptions.includes(unitId)) {
      return false;
    }
    const techState = this.options.getTechState?.(building.team);
    if (techState) {
      const prerequisite = checkPrerequisites(unitDefinition.prerequisites, techState);
      if (!prerequisite.ok) {
        if (announce) {
          this.options.onMessage(prerequisite.reason ?? "Locked", building.position.x, building.position.y - 60);
        }
        return false;
      }
    }
    if (!canAfford(resources, unitDefinition.cost)) {
      if (announce) {
        this.options.onMessage("Not enough resources", building.position.x, building.position.y - 60);
      }
      return false;
    }
    payCost(resources, unitDefinition.cost);
    building.trainingQueue.push({
      unitId,
      remaining: unitDefinition.trainTime,
      total: unitDefinition.trainTime,
      announce,
      paidCost: { ...unitDefinition.cost }
    });
    if (announce) {
      this.options.onMessage(`Training ${unitDefinition.name}`, building.position.x, building.position.y - 60);
    }
    return true;
  }

  cancelTraining(building: Building, queueIndex: number, resources: ResourceBag): boolean {
    if (queueIndex < 0 || queueIndex >= building.trainingQueue.length) {
      return false;
    }
    const [canceled] = building.trainingQueue.splice(queueIndex, 1);
    if (!canceled) {
      return false;
    }
    addResources(resources, canceled.paidCost);
    const unitDefinition = requireUnit(canceled.unitId);
    this.options.onMessage(`Canceled ${unitDefinition.name}`, building.position.x, building.position.y - 60);
    return true;
  }

  update(deltaSeconds: number, buildings: Building[]): void {
    buildings.forEach((building) => {
      if (!building.alive || !building.isCompleted() || building.trainingQueue.length === 0) {
        return;
      }

      const active = building.trainingQueue[0];
      active.remaining -= deltaSeconds;
      if (active.remaining > 0) {
        return;
      }

      building.trainingQueue.shift();
      this.spawnTrainedUnit(building, active.unitId, building.team, active.announce);
    });
  }

  private spawnTrainedUnit(building: Building, unitId: string, team: Team, announce: boolean): void {
    const unitDefinition = requireUnit(unitId);
    const offsetIndex = this.spawnCounter;
    this.spawnCounter += 1;
    const angle = offsetIndex * 1.7;
    const distanceFromBuilding = building.radius + unitDefinition.radius + 24;
    const unit = new Unit(
      this.options.scene,
      unitDefinition,
      team,
      building.position.x + Math.cos(angle) * distanceFromBuilding,
      building.position.y + Math.sin(angle) * distanceFromBuilding
    );
    this.options.addUnit(unit);
    this.options.onUnitTrained?.(unit);
    if (announce) {
      this.options.onMessage(`${unitDefinition.name} ready`, unit.position.x, unit.position.y - 28);
    }
  }
}
