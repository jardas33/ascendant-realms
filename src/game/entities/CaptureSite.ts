import Phaser from "phaser";
import { resourceIconAssetId } from "../assets/AssetKeys";
import type { CaptureSiteDefinition, Team } from "../core/GameTypes";
import { RESOURCE_DEFINITIONS } from "../data/resources";
import { recordRenderLifecycleMetrics } from "../systems/RenderLifecycleMetrics";
import { resolveCaptureSitePresentation } from "../ui/CaptureSitePresentation";
import { BaseEntity } from "./BaseEntity";

export type ResourceSiteLevel = 1 | 2;
export type CaptureSiteDiagnosticRingMode = "normal" | "minimal";

export interface CaptureSiteWorkerAssignment {
  workerId: string;
  workerName: string;
  statusDetail: string;
  boostActive: boolean;
}

export class CaptureSite extends BaseEntity {
  readonly definition: CaptureSiteDefinition;
  owner: Team = "neutral";
  capturingTeam: Team = "neutral";
  captureProgress = 0;
  incomeTimer = 0;
  siteLevel: ResourceSiteLevel = 1;
  workerAssignments: CaptureSiteWorkerAssignment[] = [];
  assignedWorkerId?: string;
  assignedWorkerName?: string;
  workerAssignmentStatusDetail = "Empty worker slot";
  workerAssignmentBoostActive = false;
  abstractEnemyWorkerSlots = 0;
  objectiveRelevant = false;

  private ring?: Phaser.GameObjects.Arc;
  private progressRing?: Phaser.GameObjects.Arc;
  private diagnosticRingMode: CaptureSiteDiagnosticRingMode = "normal";
  private lastVisualSignature = "";

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
    this.label?.setStroke("#06100c", 4).setPadding(5, 2, 5, 2).setY(-definition.radius - 30);
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
    this.siteLevel = 1;
    this.clearAllWorkerAssignments();
    this.abstractEnemyWorkerSlots = 0;
    this.updateVisuals();
  }

  setSelected(selected: boolean): void {
    super.setSelected(selected);
    this.updateVisuals();
  }

  setObjectiveRelevant(objectiveRelevant: boolean): void {
    this.objectiveRelevant = objectiveRelevant;
    this.updateVisuals();
  }

  setWorkerAssignment(workerId: string, workerName: string, status = `${workerName} traveling`): void {
    const existing = this.workerAssignments.find((assignment) => assignment.workerId === workerId);
    if (existing) {
      existing.workerName = workerName;
      existing.statusDetail = status;
      existing.boostActive = false;
    } else {
      this.workerAssignments.push({
        workerId,
        workerName,
        statusDetail: status,
        boostActive: false
      });
    }
    this.syncLegacyWorkerAssignmentFields();
  }

  updateWorkerAssignment(workerId: string, statusDetail: string, boostActive: boolean): void {
    const assignment = this.workerAssignments.find((entry) => entry.workerId === workerId);
    if (!assignment) {
      return;
    }
    assignment.statusDetail = statusDetail;
    assignment.boostActive = boostActive;
    this.syncLegacyWorkerAssignmentFields();
  }

  clearWorkerAssignment(workerId?: string, status = "Empty worker slot"): void {
    if (workerId) {
      this.workerAssignments = this.workerAssignments.filter((assignment) => assignment.workerId !== workerId);
    } else {
      this.workerAssignments = [];
    }
    this.syncLegacyWorkerAssignmentFields(status);
  }

  clearAllWorkerAssignments(status = "Empty worker slot"): void {
    this.clearWorkerAssignment(undefined, status);
  }

  hasWorkerAssignment(workerId: string): boolean {
    return this.workerAssignments.some((assignment) => assignment.workerId === workerId);
  }

  setSiteLevel(level: ResourceSiteLevel): void {
    this.siteLevel = level;
    if (level < 2) {
      this.abstractEnemyWorkerSlots = Math.min(this.abstractEnemyWorkerSlots, 1);
    }
  }

  setAbstractEnemyWorkerSlots(slots: number): void {
    this.abstractEnemyWorkerSlots = Math.max(0, Math.min(2, Math.floor(slots)));
  }

  updateVisuals(): void {
    const presentation = resolveCaptureSitePresentation({
      owner: this.owner,
      capturingTeam: this.capturingTeam,
      captureProgress: this.captureProgress,
      selected: this.selected,
      objectiveRelevant: this.objectiveRelevant,
      resourceColor: this.siteColor()
    });
    const progressVisible = this.captureProgress > 0 && this.captureProgress < 1;
    const signature = [
      presentation.state,
      presentation.labelPrefix,
      presentation.labelColor,
      presentation.labelBackground,
      presentation.ringColor,
      presentation.ringAlpha,
      presentation.ringWidth,
      presentation.progressColor,
      Number(this.captureProgress.toFixed(3)),
      progressVisible ? "progress" : "no-progress",
      this.diagnosticRingMode
    ].join("|");
    if (signature === this.lastVisualSignature) {
      return;
    }
    this.lastVisualSignature = signature;
    this.ring
      ?.setFillStyle(
        presentation.ringColor,
        presentation.state === "selected" || presentation.state === "contested" ? 0.16 : presentation.state === "objective" ? 0.1 : 0.06
      )
      .setStrokeStyle(presentation.ringWidth, presentation.ringColor, presentation.ringAlpha);
    this.label
      ?.setText(`${presentation.labelPrefix} - ${this.definition.name}`)
      .setColor(presentation.labelColor)
      .setBackgroundColor(presentation.labelBackground);
    this.setLabelVisibleByDefault(
      presentation.state === "selected" ||
        presentation.state === "contested" ||
        presentation.state === "objective" ||
        presentation.state === "enemy"
    );
    if (this.progressRing) {
      this.progressRing.setVisible(this.captureProgress > 0 && this.captureProgress < 1);
      this.progressRing.setScale(0.35 + this.captureProgress * 0.65);
      this.progressRing.setStrokeStyle(3, presentation.progressColor, 0.9);
    }
    this.applyDiagnosticRingStyle();
    recordRenderLifecycleMetrics({ ringRedraws: 1, labelLayouts: 1 });
  }

  setDiagnosticRingMode(mode: CaptureSiteDiagnosticRingMode): void {
    if (!this.ring) {
      return;
    }
    if (this.diagnosticRingMode === mode) {
      return;
    }
    this.diagnosticRingMode = mode;
    if (mode === "normal") {
      this.lastVisualSignature = "";
      this.updateVisuals();
      return;
    }
    this.applyDiagnosticRingStyle();
    recordRenderLifecycleMetrics({ ringRedraws: 1 });
  }

  private applyDiagnosticRingStyle(): void {
    if (!this.ring) {
      return;
    }
    if (this.diagnosticRingMode === "minimal") {
      this.ring.setFillStyle(this.siteColor(), 0.02).setStrokeStyle(1, this.siteColor(), 0.35);
      this.progressRing?.setAlpha(0.45);
      return;
    }
    this.progressRing?.setAlpha(1);
  }

  private siteColor(): number {
    return RESOURCE_DEFINITIONS.find((entry) => entry.id === this.definition.resource)?.color ?? 0xf4e8a4;
  }

  private createCore(scene: Phaser.Scene, definition: CaptureSiteDefinition): Phaser.GameObjects.GameObject {
    const assetId = resourceIconAssetId(definition.resource);
    if (assetId && scene.textures.exists(assetId)) {
      const image = scene.add.image(0, 0, assetId);
      recordRenderLifecycleMetrics({ spritesCreated: 1 });
      image.setDisplaySize(42, 42);
      return image;
    }
    return scene.add.circle(0, 0, 18, this.siteColor(), 0.95).setStrokeStyle(2, 0x0f1512, 0.8);
  }

  private syncLegacyWorkerAssignmentFields(emptyStatus = "Empty worker slot"): void {
    const firstAssignment = this.workerAssignments[0];
    this.assignedWorkerId = firstAssignment?.workerId;
    this.assignedWorkerName = firstAssignment?.workerName;
    this.workerAssignmentStatusDetail = firstAssignment?.statusDetail ?? emptyStatus;
    this.workerAssignmentBoostActive = this.workerAssignments.some((assignment) => assignment.boostActive);
  }
}
