import Phaser from "phaser";
import type { BattleMapDefinition, Position, ResourceBag } from "../core/GameTypes";
import { payCost } from "../core/MathUtils";
import { requireBuilding } from "../data/contentIndex";
import { Building } from "../entities/Building";
import type { CaptureSite } from "../entities/CaptureSite";
import { canPlaceBuilding, placementReasonText, type PlacementResult } from "./BuildingPlacementRules";

interface BuildingSystemOptions {
  scene: Phaser.Scene;
  map: BattleMapDefinition;
  getBuildings: () => Building[];
  getCaptureSites: () => CaptureSite[];
  addBuilding: (building: Building) => void;
  onMessage: (message: string, x?: number, y?: number) => void;
  onConstructionStarted?: (building: Building) => void;
  onBuilt?: (building: Building) => void;
}

export class BuildingSystem {
  pendingBuildingId?: string;
  private ghost?: Phaser.GameObjects.Rectangle;
  private ghostLabel?: Phaser.GameObjects.Text;
  placementMessage = "";

  constructor(private readonly options: BuildingSystemOptions) {}

  startPlacement(buildingId: string, preview?: { anchor?: Position; resources?: ResourceBag }): void {
    const definition = requireBuilding(buildingId);
    this.pendingBuildingId = buildingId;
    this.ghost?.destroy();
    this.ghost = this.options.scene.add
      .rectangle(0, 0, definition.size.width, definition.size.height, 0xe8e1b0, 0.35)
      .setStrokeStyle(2, 0xf4e8a4, 0.8)
      .setDepth(30);
    this.ghostLabel = this.options.scene.add
      .text(0, -definition.size.height / 2 - 22, "Choose building site", {
        fontFamily: "Verdana, Arial, sans-serif",
        fontSize: "11px",
        color: "#f5efc2",
        stroke: "#101511",
        strokeThickness: 3
      })
      .setOrigin(0.5)
      .setDepth(31);
    this.placementMessage = "Choose a buildable site near your base.";

    if (preview?.anchor && preview.resources) {
      const point = this.findInitialPreviewPoint(preview.anchor, buildingId, preview.resources);
      this.updateGhost(point.x, point.y, preview.resources);
    }
  }

  cancelPlacement(): void {
    this.pendingBuildingId = undefined;
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
    const definition = requireBuilding(this.pendingBuildingId);
    const result = this.getPlacementResult(x, y, definition.id, resources);
    const valid = result.ok;
    this.ghost.setPosition(x, y);
    this.ghost.setFillStyle(valid ? 0xa6e5a1 : 0xe36d62, 0.34);
    this.ghost.setStrokeStyle(2, valid ? 0xb9ffba : 0xff9b90, 0.9);
    this.ghostLabel?.setPosition(x, y - definition.size.height / 2 - 22);
    this.placementMessage = valid ? "Valid building site." : placementReasonText(result.reason);
    this.ghostLabel?.setText(this.placementMessage);
    this.ghostLabel?.setColor(valid ? "#b9ffba" : "#ffb1a9");
  }

  tryPlace(x: number, y: number, resources: ResourceBag): boolean {
    if (!this.pendingBuildingId) {
      return false;
    }

    const definition = requireBuilding(this.pendingBuildingId);

    const placement = this.getPlacementResult(x, y, definition.id, resources);
    if (!placement.ok) {
      this.options.onMessage(placementReasonText(placement.reason), x, y);
      return false;
    }

    payCost(resources, definition.cost);
    const building = new Building(this.options.scene, definition, "player", x, y, {
      constructionState: definition.constructionTimeSeconds > 0 ? "underConstruction" : "completed"
    });
    this.options.addBuilding(building);
    this.options.onConstructionStarted?.(building);
    if (building.isCompleted()) {
      this.options.onBuilt?.(building);
    }
    this.options.onMessage(
      building.isCompleted() ? `${definition.name} built` : `${definition.name} construction started`,
      x,
      y - 30
    );
    this.cancelPlacement();
    return true;
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
