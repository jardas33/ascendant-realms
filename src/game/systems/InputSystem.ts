import Phaser from "phaser";
import { FORMATION_SPACING } from "../core/Constants";
import type { Position } from "../core/GameTypes";
import { formationOffset } from "../core/MathUtils";
import type { BaseEntity } from "../entities/BaseEntity";
import { Building } from "../entities/Building";
import { Unit } from "../entities/Unit";
import { SelectionSystem } from "./SelectionSystem";

interface InputSystemOptions {
  scene: Phaser.Scene;
  selection: SelectionSystem;
  findWorldEntityAt: (point: Position) => BaseEntity | undefined;
  isPlacingBuilding: () => boolean;
  updateBuildingGhost: (point: Position) => void;
  placeBuilding: (point: Position) => boolean;
  cancelPlacement: () => void;
  getSelectedUnits: () => Unit[];
  getSelectedRallyBuildings: () => Building[];
  setRallyPoint: (point: Position, buildings: Building[]) => boolean;
  selectHero: () => void;
  centerOnHero: () => void;
  castAbilitySlot: (slot: number) => void;
  toggleFogDebug?: () => void;
  showMessage: (message: string) => void;
}

export class InputSystem {
  private dragStart?: Position;
  private dragGraphic: Phaser.GameObjects.Graphics;
  private attackMoveMode = false;
  private pointerDownHandler?: (pointer: Phaser.Input.Pointer) => void;
  private pointerMoveHandler?: (pointer: Phaser.Input.Pointer) => void;
  private pointerUpHandler?: (pointer: Phaser.Input.Pointer) => void;
  private keyHandlers: Array<{ event: string; handler: (event?: KeyboardEvent) => void }> = [];
  private aPressedAt = 0;
  private lastAbilityKey?: { slot: number; at: number };

  constructor(private readonly options: InputSystemOptions) {
    this.dragGraphic = options.scene.add.graphics().setDepth(90);
    options.scene.input.mouse?.disableContextMenu();
    this.bindPointer();
    this.bindKeyboard();
  }

  destroy(): void {
    const input = this.options.scene.input;
    if (this.pointerDownHandler) {
      input.off("pointerdown", this.pointerDownHandler);
    }
    if (this.pointerMoveHandler) {
      input.off("pointermove", this.pointerMoveHandler);
    }
    if (this.pointerUpHandler) {
      input.off("pointerup", this.pointerUpHandler);
    }
    const keyboard = this.options.scene.input.keyboard;
    if (keyboard) {
      this.keyHandlers.forEach(({ event, handler }) => keyboard.off(event, handler));
    }
    this.dragGraphic.destroy();
  }

  private bindPointer(): void {
    const input = this.options.scene.input;

    this.pointerDownHandler = (pointer: Phaser.Input.Pointer) => {
      const point = this.toWorld(pointer);
      if (pointer.leftButtonDown() || pointer.button === 0) {
        this.dragStart = point;
      }
    };

    this.pointerMoveHandler = (pointer: Phaser.Input.Pointer) => {
      const point = this.toWorld(pointer);
      if (this.options.isPlacingBuilding()) {
        this.options.updateBuildingGhost(point);
      }
      if (!this.dragStart || !pointer.leftButtonDown() || this.options.isPlacingBuilding()) {
        return;
      }
      this.drawDragBox(this.dragStart, point);
    };

    this.pointerUpHandler = (pointer: Phaser.Input.Pointer) => {
      const point = this.toWorld(pointer);
      if (pointer.rightButtonReleased() || pointer.button === 2) {
        this.handleRightClick(point);
        return;
      }

      if (this.options.isPlacingBuilding()) {
        this.options.placeBuilding(point);
        this.clearDrag();
        return;
      }

      const start = this.dragStart;
      const additive = this.isShift(pointer);
      if (start && Math.hypot(point.x - start.x, point.y - start.y) > 12) {
        this.options.selection.selectBox(this.rectFromPoints(start, point), additive);
      } else {
        this.options.selection.selectAt(point, additive);
      }
      this.clearDrag();
    };

    input.on("pointerdown", this.pointerDownHandler);
    input.on("pointermove", this.pointerMoveHandler);
    input.on("pointerup", this.pointerUpHandler);
  }

  private bindKeyboard(): void {
    const keyboard = this.options.scene.input.keyboard!;
    this.addKeyHandler("keydown-H", () => this.options.selectHero());
    this.addKeyHandler("keydown-SPACE", () => this.options.centerOnHero());
    this.addKeyHandler("keydown-ONE", (event) => this.triggerAbilitySlot(0, event));
    this.addKeyHandler("keydown-NUMPAD_ONE", (event) => this.triggerAbilitySlot(0, event));
    this.addKeyHandler("keydown-TWO", (event) => this.triggerAbilitySlot(1, event));
    this.addKeyHandler("keydown-NUMPAD_TWO", (event) => this.triggerAbilitySlot(1, event));
    this.addKeyHandler("keydown-THREE", (event) => this.triggerAbilitySlot(2, event));
    this.addKeyHandler("keydown-NUMPAD_THREE", (event) => this.triggerAbilitySlot(2, event));
    this.addKeyHandler("keydown-F", () => this.options.toggleFogDebug?.());
    this.addKeyHandler("keydown-ESC", () => {
      if (this.options.isPlacingBuilding()) {
        this.options.cancelPlacement();
      } else {
        this.options.selection.clear();
      }
      this.attackMoveMode = false;
    });
    this.addKeyHandler("keydown-A", (event) => {
      if (!event?.repeat && Boolean(event?.shiftKey)) {
        this.aPressedAt = performance.now();
      }
    });
    this.addKeyHandler("keyup-A", (event) => {
      if (this.aPressedAt > 0 && performance.now() - this.aPressedAt <= 220) {
        this.attackMoveMode = true;
        this.options.showMessage("Attack-move: right click a destination");
      }
      if (!event?.shiftKey) {
        this.attackMoveMode = false;
      }
      this.aPressedAt = 0;
    });
    this.keyHandlers.forEach(({ event, handler }) => keyboard.on(event, handler));
  }

  private addKeyHandler(event: string, handler: (event?: KeyboardEvent) => void): void {
    this.keyHandlers.push({ event, handler });
  }

  private triggerAbilitySlot(slot: number, event?: KeyboardEvent): void {
    if (event?.repeat) {
      return;
    }
    const now = performance.now();
    if (this.lastAbilityKey?.slot === slot && now - this.lastAbilityKey.at < 250) {
      return;
    }
    this.lastAbilityKey = { slot, at: now };
    this.options.castAbilitySlot(slot);
  }

  private handleRightClick(point: Position): void {
    if (this.options.isPlacingBuilding()) {
      this.options.cancelPlacement();
      return;
    }

    const target = this.options.findWorldEntityAt(point);
    const selectedUnits = this.options.getSelectedUnits().filter((unit) => unit.alive);
    if (target && target.alive && target.team !== "player") {
      selectedUnits.forEach((unit) => unit.commandAttack(target.id));
      this.attackMoveMode = false;
      return;
    }

    if (selectedUnits.length === 0) {
      this.options.setRallyPoint(point, this.options.getSelectedRallyBuildings());
      this.attackMoveMode = false;
      return;
    }

    selectedUnits.forEach((unit, index) => {
      const offset = formationOffset(index, FORMATION_SPACING);
      unit.commandMove({ x: point.x + offset.x, y: point.y + offset.y }, this.attackMoveMode);
    });
    this.attackMoveMode = false;
  }

  private toWorld(pointer: Phaser.Input.Pointer): Position {
    const point = pointer.positionToCamera(this.options.scene.cameras.main) as Phaser.Math.Vector2;
    return { x: point.x, y: point.y };
  }

  private drawDragBox(start: Position, end: Position): void {
    const rect = this.rectFromPoints(start, end);
    this.dragGraphic.clear();
    this.dragGraphic.lineStyle(2, 0xf6edb4, 0.9);
    this.dragGraphic.fillStyle(0xf6edb4, 0.08);
    this.dragGraphic.fillRect(rect.x, rect.y, rect.width, rect.height);
    this.dragGraphic.strokeRect(rect.x, rect.y, rect.width, rect.height);
  }

  private clearDrag(): void {
    this.dragStart = undefined;
    this.dragGraphic.clear();
  }

  private rectFromPoints(a: Position, b: Position): Phaser.Geom.Rectangle {
    const x = Math.min(a.x, b.x);
    const y = Math.min(a.y, b.y);
    return new Phaser.Geom.Rectangle(x, y, Math.abs(a.x - b.x), Math.abs(a.y - b.y));
  }

  private isShift(pointer: Phaser.Input.Pointer): boolean {
    const event = pointer.event;
    return Boolean(event && "shiftKey" in event && event.shiftKey);
  }
}
