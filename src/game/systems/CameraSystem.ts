import Phaser from "phaser";
import { CAMERA_PAN_SPEED } from "../core/Constants";
import type { BattleMapDefinition, Position } from "../core/GameTypes";

export class CameraSystem {
  private cursors: Phaser.Types.Input.Keyboard.CursorKeys;
  private keys: Record<string, Phaser.Input.Keyboard.Key>;

  constructor(private readonly scene: Phaser.Scene, map: BattleMapDefinition) {
    this.scene.cameras.main.setBounds(0, 0, map.width, map.height);
    this.cursors = this.scene.input.keyboard!.createCursorKeys();
    this.keys = this.scene.input.keyboard!.addKeys("W,A,S,D") as Record<string, Phaser.Input.Keyboard.Key>;
  }

  update(deltaSeconds: number): void {
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
  }

  centerOn(position: Position): void {
    this.scene.cameras.main.centerOn(position.x, position.y);
  }
}
