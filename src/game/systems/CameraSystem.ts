import Phaser from "phaser";
import { CAMERA_PAN_SPEED } from "../core/Constants";
import type { BattleMapDefinition, Position } from "../core/GameTypes";
import { clampCameraCenterPosition } from "./CameraBounds";
import { isEditableElementFocused } from "./KeyboardFocusGuard";

export class CameraSystem {
  private cursors: Phaser.Types.Input.Keyboard.CursorKeys;
  private keys: Record<string, Phaser.Input.Keyboard.Key>;

  constructor(private readonly scene: Phaser.Scene, private readonly map: BattleMapDefinition) {
    this.scene.cameras.main.setBounds(0, 0, map.width, map.height);
    this.cursors = this.scene.input.keyboard!.createCursorKeys();
    this.keys = this.scene.input.keyboard!.addKeys("W,A,S,D") as Record<string, Phaser.Input.Keyboard.Key>;
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
}
