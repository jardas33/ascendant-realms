import Phaser from "phaser";
import { resourceIconAssetId } from "../assets/AssetKeys";
import type { CaptureSiteDefinition, Team } from "../core/GameTypes";
import { RESOURCE_DEFINITIONS } from "../data/resources";
import { BaseEntity } from "./BaseEntity";

export class CaptureSite extends BaseEntity {
  readonly definition: CaptureSiteDefinition;
  owner: Team = "neutral";
  capturingTeam: Team = "neutral";
  captureProgress = 0;
  incomeTimer = 0;
  assignedWorkerId?: string;
  assignedWorkerName?: string;
  workerAssignmentStatusDetail = "Empty worker slot";
  workerAssignmentBoostActive = false;

  private ring?: Phaser.GameObjects.Arc;
  private progressRing?: Phaser.GameObjects.Arc;

  constructor(scene: Phaser.Scene, definition: CaptureSiteDefinition) {
    super({
      kind: "capture-site",
      team: "neutral",
      x: definition.x,
      y: definition.y,
      radius: definition.radius,
      maxHp: 1,
      armor: 0
    });
    this.definition = definition;
    this.createCommonView(scene, definition.name, this.siteColor(), false);
    this.ring = scene.add.circle(0, 0, definition.radius, 0x223029, 0.22).setStrokeStyle(4, this.siteColor(), 0.9);
    this.progressRing = scene.add.circle(0, 0, definition.radius - 8).setStrokeStyle(3, 0xf3e7a3, 0.85);
    this.progressRing.setVisible(false);
    const core = this.createCore(scene, definition);
    this.view?.addAt(this.ring, 0);
    this.view?.add(core);
    this.view?.add(this.progressRing);
    this.view?.setDepth(2);
  }

  setOwner(owner: Team): void {
    this.owner = owner;
    this.team = owner;
    this.captureProgress = 0;
    this.capturingTeam = "neutral";
    this.incomeTimer = 0;
    this.clearWorkerAssignment();
    this.updateVisuals();
  }

  setWorkerAssignment(workerId: string, workerName: string, status = `${workerName} traveling`): void {
    this.assignedWorkerId = workerId;
    this.assignedWorkerName = workerName;
    this.workerAssignmentStatusDetail = status;
    this.workerAssignmentBoostActive = false;
  }

  clearWorkerAssignment(status = "Empty worker slot"): void {
    this.assignedWorkerId = undefined;
    this.assignedWorkerName = undefined;
    this.workerAssignmentStatusDetail = status;
    this.workerAssignmentBoostActive = false;
  }

  updateVisuals(): void {
    const ownerColor = this.ownerColor();
    this.ring?.setStrokeStyle(4, ownerColor, 0.95);
    if (this.progressRing) {
      this.progressRing.setVisible(this.captureProgress > 0 && this.captureProgress < 1);
      this.progressRing.setScale(0.35 + this.captureProgress * 0.65);
    }
  }

  private siteColor(): number {
    return RESOURCE_DEFINITIONS.find((entry) => entry.id === this.definition.resource)?.color ?? 0xf4e8a4;
  }

  private createCore(scene: Phaser.Scene, definition: CaptureSiteDefinition): Phaser.GameObjects.GameObject {
    const assetId = resourceIconAssetId(definition.resource);
    if (assetId && scene.textures.exists(assetId)) {
      const image = scene.add.image(0, 0, assetId);
      image.setDisplaySize(42, 42);
      return image;
    }
    return scene.add.circle(0, 0, 18, this.siteColor(), 0.95).setStrokeStyle(2, 0x0f1512, 0.8);
  }

  private ownerColor(): number {
    if (this.owner === "player") {
      return 0x7de087;
    }
    if (this.owner === "enemy") {
      return 0xe15e55;
    }
    return this.siteColor();
  }
}
