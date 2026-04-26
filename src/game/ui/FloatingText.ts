import Phaser from "phaser";
import { DEFAULT_SETTINGS } from "../core/Settings";
import type { SaveSettingsData } from "../save/SaveTypes";

export class FloatingText {
  private static settings: SaveSettingsData = DEFAULT_SETTINGS;

  static configure(settings: SaveSettingsData): void {
    FloatingText.settings = settings;
  }

  static show(scene: Phaser.Scene, text: string, x: number, y: number, color = "#f5efc2"): void {
    if (!FloatingText.settings.floatingTextEnabled) {
      return;
    }

    const label = scene.add
      .text(x, y, text, {
        fontFamily: "Verdana, Arial, sans-serif",
        fontSize: "14px",
        color,
        stroke: "#101511",
        strokeThickness: 4
      })
      .setOrigin(0.5)
      .setDepth(100);

    if (FloatingText.settings.reducedMotionEnabled) {
      scene.time.delayedCall(650, () => label.destroy());
      return;
    }

    scene.tweens.add({
      targets: label,
      y: y - 34,
      alpha: 0,
      duration: 1100,
      ease: "Sine.easeOut",
      onComplete: () => label.destroy()
    });
  }
}
