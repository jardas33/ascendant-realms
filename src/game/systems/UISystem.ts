import { HUD, type HUDSnapshot } from "../ui/HUD";

export class UISystem {
  private elapsed = 0;

  constructor(private readonly hud: HUD) {}

  update(deltaSeconds: number, snapshot: HUDSnapshot): void {
    if (deltaSeconds <= 0) {
      this.elapsed = 0;
      this.hud.update(snapshot, { force: true });
      return;
    }

    this.elapsed += deltaSeconds;
    if (this.elapsed < 0.1) {
      return;
    }
    this.elapsed = 0;
    this.hud.update(snapshot);
  }

  destroy(): void {
    this.hud.destroy();
  }
}
