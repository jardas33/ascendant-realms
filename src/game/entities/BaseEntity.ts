import Phaser from "phaser";
import type { ActiveStatusEffect, EntityKind, Position, Team } from "../core/GameTypes";
import { clamp } from "../core/MathUtils";
import { resolveSelectionRingPresentation } from "../ui/SelectionPresentation";

let nextEntityNumber = 1;
const STATUS_BADGE_RADIUS = 5;
const STATUS_BADGE_GAP = 5;
const STATUS_BADGE_LABEL = "BURN";
const STATUS_BADGE_LABEL_GAP = 5;
const STATUS_BADGE_VERTICAL_GAP = 6;

export function createEntityId(prefix: string): string {
  const id = `${prefix}-${nextEntityNumber}`;
  nextEntityNumber += 1;
  return id;
}

export function resetEntityIds(seed = 1): void {
  nextEntityNumber = seed;
}

export abstract class BaseEntity {
  readonly id: string;
  kind: EntityKind;
  team: Team;
  position: Position;
  radius: number;
  maxHp: number;
  hp: number;
  armor: number;
  alive = true;
  selected = false;
  statusEffects: ActiveStatusEffect[] = [];
  // TODO: Split saveable simulation state from Phaser view objects before replay, persistent retinues, or multiplayer research.
  view?: Phaser.GameObjects.Container;

  protected selectionRing?: Phaser.GameObjects.Ellipse;
  protected healthBack?: Phaser.GameObjects.Rectangle;
  protected healthFill?: Phaser.GameObjects.Rectangle;
  protected label?: Phaser.GameObjects.Text;
  private statusBadge?: Phaser.GameObjects.Arc;
  private statusBadgeLabel?: Phaser.GameObjects.Text;
  private healthBarWidth = 0;
  private healthBarHeight = 0;
  private labelVisibleByDefault = true;
  private diagnosticLabelHidden = false;

  protected constructor(options: {
    id?: string;
    kind: EntityKind;
    team: Team;
    x: number;
    y: number;
    radius: number;
    maxHp: number;
    armor: number;
  }) {
    this.id = options.id ?? createEntityId(options.kind);
    this.kind = options.kind;
    this.team = options.team;
    this.position = { x: options.x, y: options.y };
    this.radius = options.radius;
    this.maxHp = options.maxHp;
    this.hp = options.maxHp;
    this.armor = options.armor;
  }

  protected createCommonView(scene: Phaser.Scene, label: string, healthColor: number, showHealth = true): void {
    this.view = scene.add.container(this.position.x, this.position.y);
    const selectionRadius = this.radius + 7;
    // Entity-specific sprite layout decides the final footprint position; keep selected state as a ground marker.
    this.selectionRing = scene.add
      .ellipse(0, 0, selectionRadius * 2.1, Math.max(8, selectionRadius * 0.62), 0xf5f3d1, 0.08)
      .setStrokeStyle(2, 0xf5f3d1, 0.86)
      .setSmoothness(48);
    this.selectionRing.setVisible(false);
    this.view.add(this.selectionRing);

    if (showHealth) {
      const width = Math.max(34, this.radius * 2.4);
      const height = 5;
      const y = -this.radius - 13;
      this.healthBarWidth = width;
      this.healthBarHeight = height;
      this.healthBack = scene.add
        .rectangle(-width / 2 - 1.5, y, width + 3, height + 3, 0x070b08, 0.82)
        .setOrigin(0, 0.5)
        .setStrokeStyle(1, 0xf2e7ad, 0.38);
      this.healthFill = scene.add.rectangle(-width / 2, y, width, height, healthColor, 0.96).setOrigin(0, 0.5);
      this.view.add([this.healthBack, this.healthFill]);
    }

    this.statusBadge = scene.add.circle(0, 0, STATUS_BADGE_RADIUS, 0xff743d, 0.95).setVisible(false);
    this.statusBadgeLabel = scene.add
      .text(0, 0, STATUS_BADGE_LABEL, {
        fontFamily: "Verdana, Arial, sans-serif",
        fontSize: "9px",
        color: "#ffc29a",
        stroke: "#111713",
        strokeThickness: 4
      })
      .setOrigin(0, 0.5)
      .setVisible(false);
    this.updateStatusBadgePosition();
    this.view.add([this.statusBadge, this.statusBadgeLabel]);

    this.label = scene.add
      .text(0, this.radius + 11, label, {
        fontFamily: "Verdana, Arial, sans-serif",
        fontSize: "10px",
        color: "#e9ecd8",
        stroke: "#111713",
        strokeThickness: 3
      })
      .setOrigin(0.5, 0);
    this.view.add(this.label);
    this.view.setDepth(this.kind === "building" ? 5 : 10);
    this.updateHealthBar();
  }

  protected configureCommonViewLayout(options: {
    healthBarY?: number;
    healthBarWidth?: number;
    healthBarHeight?: number;
    labelY?: number;
    selectionRadius?: number;
    selectionWidth?: number;
    selectionHeight?: number;
    selectionY?: number;
  }): void {
    if (this.selectionRing) {
      const selectionWidth =
        options.selectionWidth ??
        (options.selectionRadius !== undefined ? options.selectionRadius * 2.1 : undefined);
      const selectionHeight =
        options.selectionHeight ??
        (options.selectionRadius !== undefined ? Math.max(8, options.selectionRadius * 0.62) : undefined);
      if (selectionWidth !== undefined && selectionHeight !== undefined) {
        this.selectionRing.setSize(selectionWidth, selectionHeight);
      }
      if (options.selectionY !== undefined) {
        this.selectionRing.setY(options.selectionY);
      }
    }

    if (this.healthBack && this.healthFill) {
      const width = options.healthBarWidth ?? this.healthBarWidth;
      const height = options.healthBarHeight ?? this.healthBarHeight;
      const y = options.healthBarY ?? this.healthBack.y;
      this.healthBarWidth = width;
      this.healthBarHeight = height;
      this.healthBack.setPosition(-width / 2 - 1.5, y).setDisplaySize(width + 3, height + 3);
      this.healthFill.setPosition(-width / 2, y).setDisplaySize(width, height);
      this.updateHealthBar();
      this.updateStatusBadgePosition();
    }

    if (options.labelY !== undefined) {
      this.label?.setY(options.labelY);
    }
  }

  protected setSelectionRingLayer(index: number): void {
    if (!this.view || !this.selectionRing) {
      return;
    }
    this.view.moveTo(this.selectionRing, index);
  }

  setPosition(x: number, y: number): void {
    this.position.x = x;
    this.position.y = y;
    this.view?.setPosition(x, y);
  }

  takeDamage(rawDamage: number): number {
    if (!this.alive) {
      return 0;
    }
    const damage = Math.max(1, Math.round(rawDamage - this.armor));
    this.hp = clamp(this.hp - damage, 0, this.maxHp);
    this.updateHealthBar();
    if (this.hp <= 0) {
      this.alive = false;
      this.setSelected(false);
    }
    return damage;
  }

  heal(amount: number): number {
    if (!this.alive) {
      return 0;
    }
    const before = this.hp;
    this.hp = clamp(this.hp + amount, 0, this.maxHp);
    this.updateHealthBar();
    return this.hp - before;
  }

  applyStatusEffect(effect: ActiveStatusEffect): void {
    const existing = this.statusEffects.find((entry) => entry.id === effect.id && entry.sourceId === effect.sourceId);
    if (existing) {
      existing.remainingSeconds = Math.max(existing.remainingSeconds, effect.remainingSeconds);
      existing.durationSeconds = Math.max(existing.durationSeconds, effect.durationSeconds);
      existing.damagePerSecond = Math.max(existing.damagePerSecond, effect.damagePerSecond);
      existing.tickInterval = effect.tickInterval;
      this.updateStatusVisual();
      return;
    }
    this.statusEffects.push({ ...effect });
    this.updateStatusVisual();
  }

  updateStatusVisual(): void {
    const burning = this.statusEffects.some((effect) => effect.type === "burn" && effect.remainingSeconds > 0);
    this.statusBadge?.setVisible(burning);
    this.statusBadgeLabel?.setVisible(burning);
    if (burning) {
      this.label?.setColor("#ffb187");
      this.updateLabelVisibility();
      return;
    }
    this.label?.setColor("#e9ecd8");
    this.updateLabelVisibility();
  }

  setSelected(selected: boolean): void {
    this.selected = selected;
    this.updateLabelVisibility();
    if (!this.selectionRing) {
      return;
    }
    const presentation = resolveSelectionRingPresentation(this.team, this.kind);
    this.selectionRing
      .setVisible(selected)
      .setStrokeStyle(presentation.strokeWidth, presentation.strokeColor, presentation.strokeAlpha)
      .setFillStyle(presentation.fillColor, presentation.fillAlpha);
  }

  setDiagnosticLabelHidden(hidden: boolean): void {
    if (this.diagnosticLabelHidden === hidden) {
      return;
    }
    this.diagnosticLabelHidden = hidden;
    this.updateLabelVisibility();
  }

  updateHealthBar(): void {
    if (!this.healthFill || !this.healthBack) {
      return;
    }
    const ratio = clamp(this.hp / this.maxHp, 0, 1);
    this.healthFill.displayWidth = this.healthBarWidth * ratio;
  }

  protected setLabelVisibleByDefault(visible: boolean): void {
    this.labelVisibleByDefault = visible;
    this.updateLabelVisibility();
  }

  protected updateLabelVisibility(): void {
    if (this.diagnosticLabelHidden) {
      this.label?.setVisible(false);
      return;
    }
    const hasPriorityStatus = this.statusEffects.some((effect) => effect.remainingSeconds > 0);
    this.label?.setVisible(this.labelVisibleByDefault || this.selected || hasPriorityStatus);
  }

  private updateStatusBadgePosition(): void {
    if (!this.statusBadge) {
      return;
    }
    if (this.healthBack && this.healthBarWidth > 0) {
      const markerX = -this.healthBarWidth / 2 + STATUS_BADGE_RADIUS;
      const markerY = this.healthBack.y - this.healthBarHeight - STATUS_BADGE_RADIUS - STATUS_BADGE_VERTICAL_GAP;
      this.statusBadge.setPosition(markerX, markerY);
      this.statusBadgeLabel?.setPosition(markerX + STATUS_BADGE_RADIUS + STATUS_BADGE_LABEL_GAP, markerY);
      return;
    }
    const markerX = this.radius + STATUS_BADGE_RADIUS + STATUS_BADGE_GAP;
    const markerY = -this.radius - STATUS_BADGE_RADIUS - STATUS_BADGE_GAP;
    this.statusBadge.setPosition(markerX, markerY);
    this.statusBadgeLabel?.setPosition(markerX + STATUS_BADGE_RADIUS + STATUS_BADGE_LABEL_GAP, markerY);
  }

  destroyView(): void {
    this.view?.destroy(true);
    this.view = undefined;
  }
}
