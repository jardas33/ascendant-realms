import type { ResourceBag } from "../core/GameTypes";
import type { Building } from "../entities/Building";
import type { Hero } from "../entities/Hero";
import type { Unit } from "../entities/Unit";
import { HUD } from "../ui/HUD";
import type { MinimapSnapshot } from "../ui/MinimapView";
import type { TechState } from "./PrerequisiteSystem";

export class UISystem {
  private elapsed = 0;

  constructor(private readonly hud: HUD) {}

  update(
    deltaSeconds: number,
    snapshot: {
      resources: ResourceBag;
      hero: Hero;
      selected: Array<Unit | Building>;
      elapsedSeconds: number;
      isPlacing: boolean;
      status: string;
      hint?: string;
      techState: TechState;
      minimap: MinimapSnapshot;
    }
  ): void {
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
