import Phaser from "phaser";

export class FloatingText {
  static show(scene: Phaser.Scene, text: string, x: number, y: number, color = "#f5efc2"): void {
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
