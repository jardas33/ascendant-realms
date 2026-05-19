import Phaser from "phaser";
import { FORMATION_SPACING } from "../core/Constants";
import type { Position } from "../core/GameTypes";
import { formationOffset } from "../core/MathUtils";
import type { BaseEntity } from "../entities/BaseEntity";
import { Building } from "../entities/Building";
import { Unit } from "../entities/Unit";
import { shouldIgnoreGameKeyboardEvent } from "./KeyboardFocusGuard";
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
  showMessage: (message: string, x?: number, y?: number, color?: string, options?: InputMessageOptions) => void;
}

interface InputMessageOptions {
  durationSeconds?: number;
  priority?: "normal" | "command" | "pressure" | "objective";
}

export class InputSystem {
  private dragStart?: Position;
  private dragGraphic: Phaser.GameObjects.Graphics;
  private attackMoveMode = false;
  private pointerDownHandler?: (pointer: Phaser.Input.Pointer) => void;
  private pointerMoveHandler?: (pointer: Phaser.Input.Pointer) => void;
  private pointerUpHandler?: (pointer: Phaser.Input.Pointer) => void;
  private globalPointerMoveHandler?: (event: PointerEvent) => void;
  private globalPointerReleaseHandler?: (event: PointerEvent) => void;
  private globalPointerCancelHandler?: () => void;
  private globalKeyDownHandler?: (event: KeyboardEvent) => void;
  private keyHandlers: Array<{ event: string; handler: (event?: KeyboardEvent) => void }> = [];
  private aPressedAt = 0;
  private lastAbilityKey?: { slot: number; at: number };
  private cursorMode: "" | "attack" = "";

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
    if (this.globalPointerMoveHandler) {
      window.removeEventListener("pointermove", this.globalPointerMoveHandler);
    }
    if (this.globalPointerReleaseHandler) {
      window.removeEventListener("pointerup", this.globalPointerReleaseHandler);
    }
    if (this.globalPointerCancelHandler) {
      window.removeEventListener("pointercancel", this.globalPointerCancelHandler);
      window.removeEventListener("blur", this.globalPointerCancelHandler);
    }
    if (this.globalKeyDownHandler) {
      window.removeEventListener("keydown", this.globalKeyDownHandler, true);
    }
    const keyboard = this.options.scene.input.keyboard;
    if (keyboard) {
      this.keyHandlers.forEach(({ event, handler }) => keyboard.off(event, handler));
    }
    this.setCanvasCursor("");
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
      if (this.dragStart && !pointer.leftButtonDown()) {
        return;
      }
      if (!this.dragStart || this.options.isPlacingBuilding()) {
        if (!this.options.isPlacingBuilding()) {
          this.updateAttackCursor(point);
        }
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
      if (!start) {
        return;
      }
      this.completeDrag(point, additive);
    };

    input.on("pointerdown", this.pointerDownHandler);
    input.on("pointermove", this.pointerMoveHandler);
    input.on("pointerup", this.pointerUpHandler);

    this.globalPointerMoveHandler = (event: PointerEvent) => {
      if (this.dragStart && !this.options.isPlacingBuilding()) {
        this.drawDragBox(this.dragStart, this.toWorldFromClient(event.clientX, event.clientY));
        return;
      }
      if (event.target !== this.options.scene.game.canvas) {
        this.setCanvasCursor("");
      }
    };
    this.globalPointerReleaseHandler = (event: PointerEvent) => {
      if (!this.dragStart || this.options.isPlacingBuilding()) {
        this.clearDrag();
        return;
      }
      this.completeDrag(this.toWorldFromClient(event.clientX, event.clientY), event.shiftKey);
    };
    this.globalPointerCancelHandler = () => this.clearDrag();
    window.addEventListener("pointermove", this.globalPointerMoveHandler);
    window.addEventListener("pointerup", this.globalPointerReleaseHandler);
    window.addEventListener("pointercancel", this.globalPointerCancelHandler);
    window.addEventListener("blur", this.globalPointerCancelHandler);
  }

  private bindKeyboard(): void {
    const keyboard = this.options.scene.input.keyboard!;
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
        this.showCommandMessage("Attack-move: right click a destination");
      }
      if (!event?.shiftKey) {
        this.attackMoveMode = false;
      }
      this.aPressedAt = 0;
    });
    this.keyHandlers.forEach(({ event, handler }) => keyboard.on(event, handler));
    this.globalKeyDownHandler = (event: KeyboardEvent) => {
      if (event.repeat || shouldIgnoreGameKeyboardEvent(event)) {
        return;
      }
      if (event.key.toLowerCase() === "h") {
        this.options.selectHero();
      }
    };
    window.addEventListener("keydown", this.globalKeyDownHandler, true);
  }

  private addKeyHandler(event: string, handler: (event?: KeyboardEvent) => void): void {
    this.keyHandlers.push({
      event,
      handler: (keyboardEvent) => {
        if (shouldIgnoreGameKeyboardEvent(keyboardEvent)) {
          return;
        }
        handler(keyboardEvent);
      }
    });
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

    const selectedUnits = this.options.getSelectedUnits().filter((unit) => unit.alive);
    const target = this.options.findWorldEntityAt(point);
    if (this.issueAttackOrder(target, selectedUnits)) {
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
    this.showCommandMessage(
      `${this.attackMoveMode ? "Attack-move accepted" : "Move order accepted"}: ${this.selectionLabel(selectedUnits)}`,
      point
    );
    this.attackMoveMode = false;
  }

  private issueAttackOrder(target: BaseEntity | undefined, selectedUnits: Unit[]): boolean {
    if (!target?.alive || target.team === "player" || selectedUnits.length === 0) {
      return false;
    }

    const targetLabel = this.entityLabel(target);
    selectedUnits.forEach((unit) => unit.commandAttack(target.id, targetLabel));
    this.showCommandMessage(
      `Attack order accepted: ${this.selectionLabel(selectedUnits)} -> ${targetLabel}`,
      target.position
    );
    return true;
  }

  private updateAttackCursor(point: Position): void {
    const selectedUnits = this.options.getSelectedUnits().filter((unit) => unit.alive);
    const target = this.options.findWorldEntityAt(point);
    this.setCanvasCursor(target?.alive && target.team !== "player" && selectedUnits.length > 0 ? "attack" : "");
  }

  private setCanvasCursor(mode: "" | "attack"): void {
    if (this.cursorMode === mode) {
      return;
    }
    const canvas = this.options.scene.game.canvas;
    this.cursorMode = mode;
    if (mode === "attack") {
      canvas.style.cursor = "crosshair";
      canvas.dataset.battleCursor = "attack";
      return;
    }
    canvas.style.cursor = "";
    delete canvas.dataset.battleCursor;
  }

  private showCommandMessage(message: string, point?: Position): void {
    this.options.showMessage(message, point?.x, point ? point.y - 24 : undefined, "#d9eee8", { priority: "command" });
  }

  private selectionLabel(units: Unit[]): string {
    if (units.length === 1) {
      return units[0].definition.name;
    }
    return `${units.length} units`;
  }

  private entityLabel(entity: BaseEntity): string {
    if (entity instanceof Unit || entity instanceof Building) {
      return entity.definition.name;
    }
    return entity.kind;
  }

  private toWorld(pointer: Phaser.Input.Pointer): Position {
    const point = pointer.positionToCamera(this.options.scene.cameras.main) as Phaser.Math.Vector2;
    return { x: point.x, y: point.y };
  }

  private toWorldFromClient(clientX: number, clientY: number): Position {
    const canvas = this.options.scene.game.canvas;
    const rect = canvas.getBoundingClientRect();
    const scaleX = rect.width > 0 ? canvas.width / rect.width : 1;
    const scaleY = rect.height > 0 ? canvas.height / rect.height : 1;
    const point = this.options.scene.cameras.main.getWorldPoint((clientX - rect.left) * scaleX, (clientY - rect.top) * scaleY);
    return { x: point.x, y: point.y };
  }

  private completeDrag(point: Position, additive: boolean): void {
    const start = this.dragStart;
    if (!start) {
      return;
    }
    if (Math.hypot(point.x - start.x, point.y - start.y) > 12) {
      this.options.selection.selectBox(this.rectFromPoints(start, point), additive);
    } else if (!this.issueAttackOrder(this.options.findWorldEntityAt(point), this.options.getSelectedUnits().filter((unit) => unit.alive))) {
      this.options.selection.selectAt(point, additive);
    } else {
      this.attackMoveMode = false;
    }
    this.clearDrag();
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
    this.setCanvasCursor("");
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
