import Phaser from "phaser";
import { buildingBattleAssetIds } from "../assets/AssetKeys";
import { clamp } from "../core/MathUtils";
import type { BuildingConstructionState, BuildingDefinition, Cost, Position, Team } from "../core/GameTypes";
import { recordRenderLifecycleMetrics } from "../systems/RenderLifecycleMetrics";
import { resolveBuildingPlaceholderPresentation } from "../ui/PlaceholderBattlefieldPresentation";
import { resolveEntityPresentationConfig, type BuildingPresentationConfig } from "../ui/EntityPresentationConfig";
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
  readonly appliedUpgradeIds = new Set<string>();

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
    const presentation = resolveEntityPresentationConfig("building") as BuildingPresentationConfig;
    this.createCommonView(scene, definition.name, team === "player" ? 0x80d982 : 0xe46960, true, {
      fixedDepth: presentation.depth.fixedDepth
    });
    this.setLabelVisibleByDefault(
      resolveBuildingPlaceholderPresentation({
        buildingId: definition.id,
        team,
        baseColor: definition.color
      }).labelVisibleByDefault
    );
    const layout = this.addBattleView(scene, definition, team, presentation);
    const selectionRadius = Math.max(
      this.radius + presentation.layout.selectionRadiusAddPx,
      Math.max(definition.size.width, definition.size.height) * presentation.layout.selectionRadiusSizeMultiplier
    );
    this.configureCommonViewLayout({
      healthBarY: layout.visualTop - presentation.layout.healthTopOffsetPx,
      healthBarWidth: Math.max(
        presentation.layout.healthMinWidthPx,
        definition.size.width * presentation.layout.healthWidthSizeMultiplier
      ),
      healthBarHeight: presentation.layout.healthHeightPx,
      labelY: layout.visualBottom + presentation.layout.labelBottomOffsetPx,
      selectionRadius,
      selectionWidth: Math.max(
        definition.size.width * presentation.layout.selectionWidthSizeMultiplier,
        selectionRadius * presentation.layout.selectionWidthRadiusMultiplier
      ),
      selectionHeight: Math.max(
        presentation.layout.selectionMinHeightPx,
        definition.size.height * presentation.layout.selectionHeightSizeMultiplier
      ),
      selectionY: layout.visualBottom + presentation.layout.selectionYOffsetPx
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
    team: Team,
    layoutConfig: BuildingPresentationConfig
  ): { visualTop: number; visualBottom: number } {
    const assetId = buildingBattleAssetIds(definition.id).find((candidate) => scene.textures.exists(candidate));
    const shadow = scene.add.ellipse(
      0,
      definition.size.height * layoutConfig.shadow.ySizeHeightMultiplier,
      definition.size.width * layoutConfig.shadow.widthSizeMultiplier,
      definition.size.height * layoutConfig.shadow.heightSizeMultiplier,
      0x000000,
      layoutConfig.shadow.opacity
    );
    this.view?.addAt(shadow, 0);

    if (assetId) {
      const originY = layoutConfig.sprite.originY;
      const sprite = scene.add.image(0, 0, assetId).setOrigin(0.5, originY);
      recordRenderLifecycleMetrics({ spritesCreated: 1 });
      const maxWidth = definition.size.width * layoutConfig.sprite.maxWidthSizeMultiplier;
      const maxHeight = definition.size.height * layoutConfig.sprite.maxHeightSizeMultiplier;
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

    const placeholder = resolveBuildingPlaceholderPresentation({
      buildingId: definition.id,
      team,
      baseColor: definition.color
    });
    const base = scene.add
      .rectangle(0, 0, definition.size.width, definition.size.height, placeholder.fillColor, 0.96)
      .setStrokeStyle(3, placeholder.strokeColor, 0.9);
    this.view?.addAt(base, 1);
    const accent = placeholder.accentColor;
    if (placeholder.silhouette === "command") {
      this.view?.addAt(scene.add.rectangle(0, -definition.size.height * 0.44, definition.size.width * 0.86, 14, accent, 0.72), 2);
      this.view?.addAt(scene.add.rectangle(0, 4, definition.size.width * 0.34, definition.size.height * 0.58, 0x111713, 0.32), 3);
    } else if (placeholder.silhouette === "barracks") {
      this.view?.addAt(scene.add.rectangle(0, -definition.size.height * 0.34, definition.size.width * 0.82, 8, accent, 0.68), 2);
      this.view?.addAt(scene.add.rectangle(-definition.size.width * 0.32, 0, 8, definition.size.height * 0.72, 0x111713, 0.34), 3);
      this.view?.addAt(scene.add.rectangle(definition.size.width * 0.32, 0, 8, definition.size.height * 0.72, 0x111713, 0.34), 4);
    } else if (placeholder.silhouette === "shrine") {
      this.view?.addAt(scene.add.rectangle(0, -definition.size.height * 0.08, definition.size.width * 0.28, definition.size.height * 0.92, 0x112c2f, 0.72), 2);
      this.view?.addAt(scene.add.circle(0, -definition.size.height * 0.42, 9, accent, 0.82), 3);
    } else if (placeholder.silhouette === "tower") {
      this.view?.addAt(scene.add.rectangle(0, -definition.size.height * 0.16, definition.size.width * 0.46, definition.size.height * 0.9, 0x151d17, 0.42), 2);
      this.view?.addAt(scene.add.rectangle(0, -definition.size.height * 0.58, definition.size.width * 0.78, 12, accent, 0.72), 3);
    } else {
      this.view?.addAt(scene.add.rectangle(0, 0, definition.size.width * 0.62, definition.size.height * 0.52, accent, 0.42), 2);
    }
    return {
      visualTop: definition.size.height * layoutConfig.fallback.visualTopSizeMultiplier,
      visualBottom: definition.size.height * layoutConfig.fallback.visualBottomSizeMultiplier
    };
  }
}
