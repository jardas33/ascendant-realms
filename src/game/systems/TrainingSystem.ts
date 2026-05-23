import Phaser from "phaser";
import type { BattleMapDefinition, Position, ResourceBag, Team, UnitDefinition } from "../core/GameTypes";
import { addResources, canAfford, payCost } from "../core/MathUtils";
import { requireUnit } from "../data/contentIndex";
import type { StrongholdBattleEffects } from "../data/strongholdUpgrades";
import { Building } from "../entities/Building";
import { Unit } from "../entities/Unit";
import { DEFAULT_PATHFINDING_CELL_SIZE, PathfindingGrid, type PathfindingStaticObstacle } from "./PathfindingGrid";
import { checkPrerequisites, type TechState } from "./PrerequisiteSystem";
import { applyRallyPointToTrainedUnit } from "./RallyPointSystem";

interface TrainingSystemOptions {
  scene: Phaser.Scene;
  addUnit: (unit: Unit) => void;
  onMessage: (message: string, x?: number, y?: number, color?: string, options?: TrainingSystemMessageOptions) => void;
  onUnitTrained?: (unit: Unit) => void;
  getTechState?: (team: Team) => TechState;
  strongholdEffects?: Pick<StrongholdBattleEffects, "unitTrainingTimeMultipliers">;
  resolveSpawnPoint?: (context: TrainingSpawnPointContext) => Position;
}

interface TrainingSystemMessageOptions {
  durationSeconds?: number;
  priority?: "normal" | "command" | "pressure" | "objective";
}

export interface TrainingSpawnPointContext {
  building: Building;
  unitDefinition: UnitDefinition;
  preferredPoint: Position;
  spawnIndex: number;
}

export interface TrainingSpawnPlacementOptions extends TrainingSpawnPointContext {
  map: BattleMapDefinition;
  buildings: Building[];
}

const TRAINING_SPAWN_CLEARANCE = 24;
const TRAINING_SPAWN_BUILDING_CLEARANCE = 8;
const TRAINING_SPAWN_ANGLE_STEP = 1.7;
const TRAINING_SPAWN_RING_STEP = 28;
const TRAINING_SPAWN_ANGLE_OFFSETS = [0, -0.55, 0.55, -1.1, 1.1, Math.PI, -Math.PI / 2, Math.PI / 2];
const TRAINING_SPAWN_RING_OFFSETS = [0, TRAINING_SPAWN_RING_STEP, TRAINING_SPAWN_RING_STEP * 2, TRAINING_SPAWN_RING_STEP * 3];

export function findWalkableTrainedUnitSpawnPoint(options: TrainingSpawnPlacementOptions): Position {
  const grid = PathfindingGrid.fromMap(options.map, {
    cellSize: DEFAULT_PATHFINDING_CELL_SIZE,
    staticObstacles: staticObstaclesForTrainingBuildings(options.buildings)
  });
  const baseDistance = options.building.radius + options.unitDefinition.radius + TRAINING_SPAWN_CLEARANCE;
  const baseAngle = options.spawnIndex * TRAINING_SPAWN_ANGLE_STEP;
  const candidates = [
    options.preferredPoint,
    ...TRAINING_SPAWN_RING_OFFSETS.flatMap((ringOffset) =>
      TRAINING_SPAWN_ANGLE_OFFSETS.map((angleOffset) => ({
        x: options.building.position.x + Math.cos(baseAngle + angleOffset) * (baseDistance + ringOffset),
        y: options.building.position.y + Math.sin(baseAngle + angleOffset) * (baseDistance + ringOffset)
      }))
    )
  ];

  const valid = candidates
    .map((candidate) => clampSpawnPoint(candidate, options.map, options.unitDefinition.radius))
    .filter((candidate) =>
      grid.isWorldWalkable(candidate) &&
      hasBuildingClearance(candidate, options.unitDefinition.radius, options.buildings)
    )
    .sort((a, b) => distanceSquared(a, options.preferredPoint) - distanceSquared(b, options.preferredPoint))[0];

  if (valid) {
    return valid;
  }

  const nearest = grid.findNearestWalkablePoint(options.preferredPoint, 6);
  if (nearest) {
    return clampSpawnPoint(nearest, options.map, options.unitDefinition.radius);
  }

  return options.preferredPoint;
}

export class TrainingSystem {
  private spawnCounter = 0;

  constructor(private readonly options: TrainingSystemOptions) {}

  queueTraining(building: Building, unitId: string, resources: ResourceBag, options: { announce?: boolean } = {}): boolean {
    const unitDefinition = requireUnit(unitId);
    const announce = options.announce ?? building.team === "player";
    if (!building.isCompleted()) {
      if (announce) {
        this.options.onMessage("Construction must finish first", building.position.x, building.position.y - 60, "#ffd27a", {
          priority: "command"
        });
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
          this.options.onMessage(prerequisite.reason ?? "Locked", building.position.x, building.position.y - 60, "#ffd27a", {
            priority: "command"
          });
        }
        return false;
      }
    }
    if (!canAfford(resources, unitDefinition.cost)) {
      if (announce) {
        this.options.onMessage(`Not enough resources for ${unitDefinition.name}`, building.position.x, building.position.y - 60, "#ffd27a", {
          priority: "command"
        });
      }
      return false;
    }
    payCost(resources, unitDefinition.cost);
    const trainTime = this.trainingTime(unitId, unitDefinition.trainTime, building.team);
    building.trainingQueue.push({
      unitId,
      remaining: trainTime,
      total: trainTime,
      announce,
      paidCost: { ...unitDefinition.cost }
    });
    if (announce) {
      this.options.onMessage(`Training queued: ${unitDefinition.name}`, building.position.x, building.position.y - 60, "#d9eee8", {
        priority: "command"
      });
    }
    return true;
  }

  private trainingTime(unitId: string, baseTime: number, team: Team): number {
    if (team !== "player") {
      return baseTime;
    }
    const multiplier = this.options.strongholdEffects?.unitTrainingTimeMultipliers[unitId] ?? 1;
    return Math.max(1, baseTime * multiplier);
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
    this.options.onMessage(`Canceled ${unitDefinition.name}`, building.position.x, building.position.y - 60, "#ffd27a", {
      priority: "command"
    });
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
    const angle = offsetIndex * TRAINING_SPAWN_ANGLE_STEP;
    const distanceFromBuilding = building.radius + unitDefinition.radius + TRAINING_SPAWN_CLEARANCE;
    const preferredPoint = {
      x: building.position.x + Math.cos(angle) * distanceFromBuilding,
      y: building.position.y + Math.sin(angle) * distanceFromBuilding
    };
    const spawnPoint =
      this.options.resolveSpawnPoint?.({
        building,
        unitDefinition,
        preferredPoint,
        spawnIndex: offsetIndex
      }) ?? preferredPoint;
    const unit = new Unit(
      this.options.scene,
      unitDefinition,
      team,
      spawnPoint.x,
      spawnPoint.y
    );
    applyRallyPointToTrainedUnit(building, unit);
    this.options.addUnit(unit);
    this.options.onUnitTrained?.(unit);
    if (announce) {
      this.options.onMessage(
        building.rallyPoint ? `${unitDefinition.name} ready: moving to rally point` : `${unitDefinition.name} ready`,
        unit.position.x,
        unit.position.y - 28,
        "#d9eee8",
        { priority: "command" }
      );
    }
  }
}

function staticObstaclesForTrainingBuildings(buildings: Building[]): PathfindingStaticObstacle[] {
  return buildings
    .filter((building) => building.alive)
    .map((building) => ({
      id: building.id,
      x: building.position.x,
      y: building.position.y,
      width: building.definition.size.width,
      height: building.definition.size.height,
      padding: 16
    }));
}

function clampSpawnPoint(point: Position, map: BattleMapDefinition, unitRadius: number): Position {
  return {
    x: Math.max(unitRadius, Math.min(map.width - unitRadius, point.x)),
    y: Math.max(unitRadius, Math.min(map.height - unitRadius, point.y))
  };
}

function hasBuildingClearance(point: Position, unitRadius: number, buildings: Building[]): boolean {
  return buildings.every((building) => {
    if (!building.alive) {
      return true;
    }
    const dx = Math.max(Math.abs(point.x - building.position.x) - building.definition.size.width / 2, 0);
    const dy = Math.max(Math.abs(point.y - building.position.y) - building.definition.size.height / 2, 0);
    return Math.hypot(dx, dy) >= unitRadius + TRAINING_SPAWN_BUILDING_CLEARANCE;
  });
}

function distanceSquared(a: Position, b: Position): number {
  const dx = a.x - b.x;
  const dy = a.y - b.y;
  return dx * dx + dy * dy;
}
