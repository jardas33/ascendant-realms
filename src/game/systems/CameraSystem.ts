import Phaser from "phaser";
import { CAMERA_PAN_SPEED } from "../core/Constants";
import type { BattleMapDefinition, Position } from "../core/GameTypes";
import { clampCameraCenterPosition } from "./CameraBounds";
import type { BattlefieldViewportLayout } from "../ui/hudPanels/HudRoot";
import { isEditableElementFocused } from "./KeyboardFocusGuard";

export class CameraSystem {
  private cursors: Phaser.Types.Input.Keyboard.CursorKeys;
  private keys: Record<string, Phaser.Input.Keyboard.Key>;
  private baseViewportWidth: number;
  private baseViewportHeight: number;
  private rightInset = 0;

  constructor(private readonly scene: Phaser.Scene, private readonly map: BattleMapDefinition) {
    this.scene.cameras.main.setBounds(0, 0, map.width, map.height);
    this.cursors = this.scene.input.keyboard!.createCursorKeys();
    this.keys = this.scene.input.keyboard!.addKeys("W,A,S,D") as Record<string, Phaser.Input.Keyboard.Key>;
    this.baseViewportWidth = Math.max(1, Math.round(this.scene.game.canvas.width || this.scene.scale.width));
    this.baseViewportHeight = Math.max(1, Math.round(this.scene.game.canvas.height || this.scene.scale.height));
  }

  setBattlefieldViewportBase(width: number, height: number): void {
    const nextWidth = Math.max(1, Math.round(width));
    const nextHeight = Math.max(1, Math.round(height));
    if (nextWidth === this.baseViewportWidth && nextHeight === this.baseViewportHeight) {
      return;
    }
    this.baseViewportWidth = nextWidth;
    this.baseViewportHeight = nextHeight;
    this.applyBattlefieldViewport();
  }

  setBattlefieldRightInset(rightInset: number): BattlefieldViewportLayout {
    const nextInset = Phaser.Math.Clamp(Math.round(rightInset), 0, Math.max(0, this.baseViewportWidth - 1));
    if (nextInset !== this.rightInset) {
      this.rightInset = nextInset;
      this.applyBattlefieldViewport();
    }
    return this.battlefieldViewportLayout();
  }

  battlefieldViewportLayout(): BattlefieldViewportLayout {
    const rightEdge = this.baseViewportWidth - this.rightInset;
    return {
      width: rightEdge,
      height: this.baseViewportHeight,
      rightEdge,
      rightInset: this.rightInset
    };
  }

  update(deltaSeconds: number): void {
    if (isEditableElementFocused()) {
      return;
    }
    const camera = this.scene.cameras.main;
    const distance = CAMERA_PAN_SPEED * deltaSeconds;
    if (this.cursors.left.isDown || this.keys.A.isDown) {
      camera.scrollX -= distance;
    }
    if (this.cursors.right.isDown || this.keys.D.isDown) {
      camera.scrollX += distance;
    }
    if (this.cursors.up.isDown || this.keys.W.isDown) {
      camera.scrollY -= distance;
    }
    if (this.cursors.down.isDown || this.keys.S.isDown) {
      camera.scrollY += distance;
    }
    this.clampCameraScroll();
  }

  centerOn(position: Position): void {
    const camera = this.scene.cameras.main;
    const clamped = clampCameraCenterPosition(position, this.map, {
      width: camera.width,
      height: camera.height,
      zoom: camera.zoom
    });
    camera.centerOn(clamped.x, clamped.y);
    this.clampCameraScroll();
  }

  private clampCameraScroll(): void {
    const camera = this.scene.cameras.main;
    const visibleWidth = Math.min(this.map.width, camera.width / Math.max(0.01, camera.zoom));
    const visibleHeight = Math.min(this.map.height, camera.height / Math.max(0.01, camera.zoom));
    camera.scrollX = Phaser.Math.Clamp(camera.scrollX, 0, Math.max(0, this.map.width - visibleWidth));
    camera.scrollY = Phaser.Math.Clamp(camera.scrollY, 0, Math.max(0, this.map.height - visibleHeight));
  }

  private applyBattlefieldViewport(): void {
    const camera = this.scene.cameras.main;
    const layout = this.battlefieldViewportLayout();
    camera.setViewport(0, 0, layout.width, layout.height);
    this.clampCameraScroll();
  }
}
