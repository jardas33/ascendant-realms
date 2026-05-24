import Phaser from "phaser";
import type { BattleMapDefinition, Position, ResourceBag } from "../core/GameTypes";
import { distance, payCost } from "../core/MathUtils";
import { requireBuilding } from "../data/contentIndex";
import { applyStrongholdBuildingEffects, type StrongholdBattleEffects } from "../data/strongholdUpgrades";
import { Building } from "../entities/Building";
import type { CaptureSite } from "../entities/CaptureSite";
import type { Unit } from "../entities/Unit";
import { canPlaceBuilding, placementReasonText, type PlacementResult } from "./BuildingPlacementRules";
import { DEFAULT_PATHFINDING_CELL_SIZE, PathfindingGrid, type PathfindingStaticObstacle } from "./PathfindingGrid";

interface BuildingSystemOptions {
  scene: Phaser.Scene;
  map: BattleMapDefinition;
  getBuildings: () => Building[];
  getUnits?: () => Unit[];
  getCaptureSites: () => CaptureSite[];
  addBuilding: (building: Building) => void;
  onMessage: (message: string, x?: number, y?: number, color?: string, options?: BuildingSystemMessageOptions) => void;
  onConstructionStarted?: (building: Building) => void;
  onBuilt?: (building: Building) => void;
  strongholdEffects?: StrongholdBattleEffects;
}

interface BuildingSystemMessageOptions {
  durationSeconds?: number;
  priority?: "normal" | "command" | "pressure" | "objective";
}

export const BUILDING_WORKER_FOOTPRINT_RANGE = 64;
const CONSTRUCTION_PATHFINDING_CELL_SIZE = DEFAULT_PATHFINDING_CELL_SIZE / 2;

export class BuildingSystem {
  pendingBuildingId?: string;
  pendingAssignedWorkerId?: string;
  private ghost?: Phaser.GameObjects.Rectangle;
  private ghostLabel?: Phaser.GameObjects.Text;
  placementMessage = "";
  private firstConstructionBoostUsed = false;

  constructor(private readonly options: BuildingSystemOptions) {}

  startPlacement(buildingId: string, preview?: { anchor?: Position; resources?: ResourceBag; assignedWorkerId?: string }): void {
    const definition = requireBuilding(buildingId);
    this.pendingBuildingId = buildingId;
    this.pendingAssignedWorkerId = preview?.assignedWorkerId;
    this.ghost?.destroy();
    this.ghostLabel?.destroy();
    this.ghost = this.options.scene.add
      .rectangle(0, 0, definition.size.width, definition.size.height, 0xe8e1b0, 0.46)
      .setStrokeStyle(3, 0xf4e8a4, 0.95)
      .setDepth(42);
    this.ghostLabel = this.options.scene.add
      .text(0, -definition.size.height / 2 - 22, `Place ${definition.name}`, {
        fontFamily: "Verdana, Arial, sans-serif",
        fontSize: "11px",
        color: "#f5efc2",
        backgroundColor: "#08100c",
        stroke: "#101511",
        strokeThickness: 3
      })
      .setOrigin(0.5)
      .setPadding(6, 3, 6, 3)
      .setDepth(43);
    this.placementMessage = `Placing ${definition.name}: choose valid ground near your base.`;

    if (preview?.anchor && preview.resources) {
      const point = this.findInitialPreviewPoint(preview.anchor, buildingId, preview.resources);
      this.updateGhost(point.x, point.y, preview.resources);
    }
  }

  cancelPlacement(): void {
    this.pendingBuildingId = undefined;
    this.pendingAssignedWorkerId = undefined;
    this.ghost?.destroy();
    this.ghostLabel?.destroy();
    this.ghost = undefined;
    this.ghostLabel = undefined;
    this.placementMessage = "";
  }

  update(deltaSeconds: number): void {
    this.options.getBuildings().forEach((building) => {
      if (!building.alive || !building.isUnderConstruction()) {
        return;
      }
      if (!this.canProgressConstruction(building)) {
        return;
      }
      if (building.updateConstruction(deltaSeconds)) {
        this.options.onBuilt?.(building);
        this.options.onMessage(`${building.definition.name} complete`, building.position.x, building.position.y - 54);
      }
    });
  }

  updateGhost(x: number, y: number, resources: ResourceBag): void {
    if (!this.pendingBuildingId || !this.ghost) {
      return;
    }
    const definition = applyStrongholdBuildingEffects(
      requireBuilding(this.pendingBuildingId),
      "player",
      this.options.strongholdEffects ?? { watchtowerRangeMultiplier: 1 }
    );
    const result = this.getPlacementResult(x, y, definition.id, resources);
    const valid = result.ok;
    this.ghost.setPosition(x, y);
    this.ghost.setFillStyle(valid ? 0xa6e5a1 : 0xe36d62, valid ? 0.46 : 0.5);
    this.ghost.setStrokeStyle(3, valid ? 0xb9ffba : 0xff9b90, 1);
    this.ghostLabel?.setPosition(x, y - definition.size.height / 2 - 22);
    this.placementMessage = valid
      ? `Valid ${definition.name} site. Left-click to place.`
      : `${definition.name}: ${placementReasonText(result.reason)}`;
    this.ghostLabel?.setText(this.placementMessage);
    this.ghostLabel?.setColor(valid ? "#b9ffba" : "#ffb1a9");
  }

  tryPlace(x: number, y: number, resources: ResourceBag): boolean {
    if (!this.pendingBuildingId) {
      return false;
    }

    const definition = applyStrongholdBuildingEffects(
      requireBuilding(this.pendingBuildingId),
      "player",
      this.options.strongholdEffects ?? { watchtowerRangeMultiplier: 1 }
    );

    const placement = this.getPlacementResult(x, y, definition.id, resources);
    if (!placement.ok) {
      this.options.onMessage(placementReasonText(placement.reason), x, y, "#ffd27a", { priority: "command" });
      return false;
    }

    payCost(resources, definition.cost);
    const building = new Building(this.options.scene, definition, "player", x, y, {
      constructionState: definition.constructionTimeSeconds > 0 ? "underConstruction" : "completed",
      assignedWorkerId: this.pendingAssignedWorkerId,
      assignedWorkerName: this.pendingAssignedWorkerId ? this.workerForId(this.pendingAssignedWorkerId)?.definition.name ?? "Worker" : undefined
    });
    this.applyFirstConstructionBoost(building);
    this.options.addBuilding(building);
    this.assignWorkerToConstructionSite(building);
    this.options.onConstructionStarted?.(building);
    if (building.isCompleted()) {
      this.options.onBuilt?.(building);
    }
    this.options.onMessage(
      building.isCompleted() ? `${definition.name} built` : `${definition.name} construction started`,
      x,
      y - 30,
      "#d9eee8",
      { priority: "command" }
    );
    this.cancelPlacement();
    return true;
  }

  private applyFirstConstructionBoost(building: Building): void {
    const multiplier = this.options.strongholdEffects?.firstBuildingConstructionTimeMultiplier ?? 1;
    if (this.firstConstructionBoostUsed || multiplier >= 1 || building.constructionTimeSeconds <= 0) {
      return;
    }
    building.constructionTimeSeconds = Math.max(1, building.constructionTimeSeconds * multiplier);
    this.firstConstructionBoostUsed = true;
  }

  private canProgressConstruction(building: Building): boolean {
    if (!building.assignedWorkerId) {
      building.constructionProgressing = true;
      building.constructionStatusDetail = "Under construction";
      return true;
    }

    const worker = this.workerForId(building.assignedWorkerId);
    if (!worker?.alive) {
      building.constructionProgressing = false;
      building.constructionStatusDetail = `${building.assignedWorkerName ?? "Worker"} missing`;
      return false;
    }

    const closeEnough = isWorkerInConstructionRange(building, worker);
    const movingAwayFromWorkRange =
      worker.pausedConstructionSiteId === building.id &&
      worker.moveTarget !== undefined &&
      !isPointInBuildingWorkRange(building, worker.moveTarget);
    if (movingAwayFromWorkRange) {
      building.constructionProgressing = false;
      building.constructionStatusDetail = "Paused - Worker away";
      return false;
    }
    if (!closeEnough) {
      building.constructionProgressing = false;
      if (worker.activeConstructionSiteId !== building.id) {
        building.constructionStatusDetail = "Paused - Worker away";
        return false;
      }
      building.constructionStatusDetail = `${building.assignedWorkerName ?? worker.definition.name} traveling`;
      const approach = findConstructionApproachPoint({
        map: this.options.map,
        building,
        worker,
        buildings: this.options.getBuildings()
      });
      commandWorkerToConstructionApproach(worker, approach, building.id);
      return false;
    }

    building.constructionProgressing = true;
    worker.markConstructionWork(building.id);
    building.constructionStatusDetail = "Building";
    return true;
  }

  private assignWorkerToConstructionSite(building: Building): void {
    if (!building.assignedWorkerId || !building.isUnderConstruction()) {
      return;
    }
    const worker = this.workerForId(building.assignedWorkerId);
    if (!worker?.alive) {
      building.constructionStatusDetail = `${building.assignedWorkerName ?? "Worker"} missing`;
      return;
    }
    const approach = findConstructionApproachPoint({
      map: this.options.map,
      building,
      worker,
      buildings: this.options.getBuildings()
    });
    commandWorkerToConstructionApproach(worker, approach, building.id);
    building.constructionStatusDetail = `${building.assignedWorkerName ?? worker.definition.name} assigned`;
  }

  private workerForId(workerId: string): Unit | undefined {
    return this.options.getUnits?.().find((unit) => unit.alive && unit.team === "player" && unit.id === workerId);
  }

  private getPlacementResult(x: number, y: number, buildingId: string, resources: ResourceBag): PlacementResult {
    const definition = requireBuilding(buildingId);
    return canPlaceBuilding({
      point: { x, y },
      definition,
      resources,
      map: this.options.map,
      buildings: this.options.getBuildings(),
      captureSites: this.options.getCaptureSites(),
      team: "player"
    });
  }

  private findInitialPreviewPoint(anchor: Position, buildingId: string, resources: ResourceBag): Position {
    const definition = requireBuilding(buildingId);
    const baseDistance = Math.max(definition.size.width, definition.size.height) + 64;
    const directions = [
      { x: 1, y: 0 },
      { x: 0, y: 1 },
      { x: -1, y: 0 },
      { x: 0, y: -1 },
      { x: 0.72, y: 0.72 },
      { x: -0.72, y: 0.72 },
      { x: 0.72, y: -0.72 },
      { x: -0.72, y: -0.72 }
    ];

    for (const distance of [baseDistance, baseDistance + 40, baseDistance + 80]) {
      for (const direction of directions) {
        const point = {
          x: anchor.x + direction.x * distance,
          y: anchor.y + direction.y * distance
        };
        if (this.getPlacementResult(point.x, point.y, buildingId, resources).ok) {
          return point;
        }
      }
    }

    return {
      x: anchor.x + baseDistance,
      y: anchor.y
    };
  }
}

export function constructionWorkerRange(building: Building, worker: Unit): number {
  return Math.max(building.definition.size.width, building.definition.size.height) / 2 + worker.radius + 34;
}

export function isWorkerInConstructionRange(building: Building, worker: Unit): boolean {
  return isPointInBuildingWorkRange(building, worker.position);
}

export function isPointInBuildingWorkRange(building: Building, point: Position): boolean {
  const dx = Math.max(Math.abs(point.x - building.position.x) - building.definition.size.width / 2, 0);
  const dy = Math.max(Math.abs(point.y - building.position.y) - building.definition.size.height / 2, 0);
  return Math.max(dx, dy) <= BUILDING_WORKER_FOOTPRINT_RANGE;
}

export function findConstructionApproachPoint(options: {
  map: BattleMapDefinition;
  building: Building;
  worker: Unit;
  buildings: Building[];
}): Position {
  const { building, worker } = options;
  const halfWidth = building.definition.size.width / 2;
  const halfHeight = building.definition.size.height / 2;
  const clearance = worker.radius + 28;
  const candidates = [
    { x: building.position.x - halfWidth - clearance, y: building.position.y },
    { x: building.position.x + halfWidth + clearance, y: building.position.y },
    { x: building.position.x, y: building.position.y - halfHeight - clearance },
    { x: building.position.x, y: building.position.y + halfHeight + clearance },
    { x: building.position.x - halfWidth - clearance, y: building.position.y - halfHeight - clearance },
    { x: building.position.x + halfWidth + clearance, y: building.position.y - halfHeight - clearance },
    { x: building.position.x - halfWidth - clearance, y: building.position.y + halfHeight + clearance },
    { x: building.position.x + halfWidth + clearance, y: building.position.y + halfHeight + clearance }
  ];
  const grid = PathfindingGrid.fromMap(options.map, {
    cellSize: CONSTRUCTION_PATHFINDING_CELL_SIZE,
    staticObstacles: staticObstaclesForConstructionBuildings(options.buildings)
  });
  const valid = candidates
    .map((candidate) => ({
      x: Math.max(worker.radius, Math.min(options.map.width - worker.radius, candidate.x)),
      y: Math.max(worker.radius, Math.min(options.map.height - worker.radius, candidate.y))
    }))
    .filter((candidate) => grid.isWorldWalkable(candidate))
    .sort((a, b) => distance(a, worker.position) - distance(b, worker.position))[0];

  if (valid) {
    return valid;
  }

  return grid.findNearestWalkablePoint(worker.position, 6) ?? { ...worker.position };
}

function commandWorkerToConstructionApproach(worker: Unit, approach: Position, siteId: string): void {
  if (worker.moveTarget && distance(worker.moveTarget, approach) <= 4) {
    worker.markConstructionWork(siteId);
    return;
  }
  worker.commandConstructionMove(approach, siteId);
}

function staticObstaclesForConstructionBuildings(buildings: Building[]): PathfindingStaticObstacle[] {
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
