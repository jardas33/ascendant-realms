import Phaser from "phaser";
import { buildingBattleAssetIds } from "../assets/AssetKeys";
import { clamp } from "../core/MathUtils";
import type { BuildingConstructionState, BuildingDefinition, Cost, Position, Team } from "../core/GameTypes";
import { BaseEntity } from "./BaseEntity";

export interface TrainingQueueItem {
  unitId: string;
  remaining: number;
  total: number;
  announce: boolean;
  paidCost: Cost;
}

export interface UpgradeQueueItem {
  upgradeId: string;
  remaining: number;
  total: number;
  announce: boolean;
  paidCost: Cost;
}

export class Building extends BaseEntity {
  readonly definition: BuildingDefinition;
  attackCooldownRemaining = 0;
  trainingQueue: TrainingQueueItem[] = [];
  upgradeQueue: UpgradeQueueItem[] = [];
  constructionState: BuildingConstructionState;
  constructionProgress: number;
  constructionTimeSeconds: number;
  assignedWorkerId?: string;
  assignedWorkerName?: string;
  constructionStatusDetail?: string;
  constructionProgressing = false;
  rallyPoint?: Position;
  rallyTargetId?: string;

  constructor(
    scene: Phaser.Scene,
    definition: BuildingDefinition,
    team: Team,
    x: number,
    y: number,
    options: {
      constructionState?: Exclude<BuildingConstructionState, "planned">;
      constructionProgress?: number;
      assignedWorkerId?: string;
      assignedWorkerName?: string;
    } = {}
  ) {
    super({
      kind: "building",
      team,
      x,
      y,
      radius: Math.max(definition.size.width, definition.size.height) / 2,
      maxHp: definition.maxHp,
      armor: definition.armor
    });
    this.definition = definition;
    this.constructionTimeSeconds = definition.constructionTimeSeconds;
    this.constructionState =
      options.constructionState ??
      (definition.constructionTimeSeconds > 0 && team === "player" ? "underConstruction" : "completed");
    this.constructionProgress = this.constructionState === "completed" ? 1 : clamp(options.constructionProgress ?? 0, 0, 1);
    this.assignedWorkerId = options.assignedWorkerId;
    this.assignedWorkerName = options.assignedWorkerName;
    this.constructionStatusDetail = this.isUnderConstruction()
      ? this.assignedWorkerId
        ? `Waiting for ${this.assignedWorkerName ?? "Worker"}`
        : "Under construction"
      : "Complete";
    this.createCommonView(scene, definition.name, team === "player" ? 0x80d982 : 0xe46960, true);
    const layout = this.addBattleView(scene, definition, team);
    const selectionRadius = Math.max(this.radius + 7, Math.max(definition.size.width, definition.size.height) * 0.64);
    this.configureCommonViewLayout({
      healthBarY: layout.visualTop - 14,
      healthBarWidth: Math.max(64, definition.size.width * 1.08),
      healthBarHeight: 7,
      labelY: layout.visualBottom + 8,
      selectionRadius,
      selectionWidth: Math.max(definition.size.width * 1.16, selectionRadius * 2.05),
      selectionHeight: Math.max(18, definition.size.height * 0.38),
      selectionY: layout.visualBottom - 2
    });
    this.setSelectionRingLayer(1);
    this.applyInitialConstructionHealth();
    this.updateConstructionVisuals();
  }

  hasTraining(): boolean {
    return this.trainingQueue.length > 0;
  }

  isCompleted(): boolean {
    return this.constructionState === "completed";
  }

  isUnderConstruction(): boolean {
    return this.constructionState === "underConstruction";
  }

  updateConstruction(deltaSeconds: number): boolean {
    if (this.constructionState !== "underConstruction") {
      this.constructionProgressing = false;
      return false;
    }

    if (this.constructionTimeSeconds <= 0) {
      this.completeConstruction();
      return true;
    }

    this.constructionProgressing = true;
    this.constructionProgress = clamp(this.constructionProgress + deltaSeconds / this.constructionTimeSeconds, 0, 1);
    this.raiseConstructionHealthFloor();
    if (this.constructionProgress >= 1) {
      this.completeConstruction();
      return true;
    }
    this.updateConstructionVisuals();
    return false;
  }

  private completeConstruction(): void {
    this.constructionState = "completed";
    this.constructionProgress = 1;
    this.constructionProgressing = false;
    this.constructionStatusDetail = "Complete";
    this.hp = this.maxHp;
    this.updateHealthBar();
    this.updateConstructionVisuals();
  }

  private applyInitialConstructionHealth(): void {
    if (this.constructionState !== "underConstruction") {
      return;
    }
    this.hp = Math.max(1, Math.ceil(this.maxHp * 0.25));
    this.updateHealthBar();
  }

  private raiseConstructionHealthFloor(): void {
    const healthFloorRatio = 0.25 + this.constructionProgress * 0.75;
    this.hp = Math.max(this.hp, Math.ceil(this.maxHp * healthFloorRatio));
    this.updateHealthBar();
  }

  private updateConstructionVisuals(): void {
    const constructing = this.constructionState === "underConstruction";
    this.view?.setAlpha(constructing ? 0.62 : 1);
  }

  private addBattleView(
    scene: Phaser.Scene,
    definition: BuildingDefinition,
    team: Team
  ): { visualTop: number; visualBottom: number } {
    const assetId = buildingBattleAssetIds(definition.id).find((candidate) => scene.textures.exists(candidate));
    const shadow = scene.add.ellipse(0, definition.size.height * 0.3, definition.size.width * 1.1, definition.size.height * 0.46, 0x000000, 0.28);
    this.view?.addAt(shadow, 0);

    if (assetId) {
      const originY = 0.66;
      const sprite = scene.add.image(0, 0, assetId).setOrigin(0.5, originY);
      const maxWidth = definition.size.width * 1.24;
      const maxHeight = definition.size.height * 1.42;
      const scale = Math.min(maxWidth / Math.max(1, sprite.width), maxHeight / Math.max(1, sprite.height));
      sprite.setScale(scale);
      const visualHeight = sprite.height * scale;
      if (team === "enemy") {
        sprite.setTint(0xf0aaa0);
      }
      this.view?.addAt(sprite, 1);
      return {
        visualTop: -visualHeight * originY,
        visualBottom: Math.max(definition.size.height * 0.46, visualHeight * (1 - originY))
      };
    }

    const rect = scene.add
      .rectangle(0, 0, definition.size.width, definition.size.height, definition.color, 0.96)
      .setStrokeStyle(3, team === "player" ? 0xd8edc2 : 0x3b1714, 0.9);
    this.view?.addAt(rect, 1);
    return {
      visualTop: -definition.size.height / 2,
      visualBottom: definition.size.height / 2
    };
  }
}
