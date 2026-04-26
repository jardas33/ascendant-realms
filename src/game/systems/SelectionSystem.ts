import Phaser from "phaser";
import type { Position } from "../core/GameTypes";
import { distance } from "../core/MathUtils";
import type { BaseEntity } from "../entities/BaseEntity";

export class SelectionSystem {
  private readonly selectedIds = new Set<string>();

  constructor(private readonly getSelectableEntities: () => BaseEntity[]) {}

  getSelected(): BaseEntity[] {
    const all = this.getSelectableEntities();
    return all.filter((entity) => this.selectedIds.has(entity.id) && entity.alive);
  }

  getSelectedIds(): string[] {
    return [...this.selectedIds];
  }

  clear(): void {
    this.getSelectableEntities().forEach((entity) => entity.setSelected(false));
    this.selectedIds.clear();
  }

  setSelection(entities: BaseEntity[]): void {
    this.clear();
    entities.forEach((entity) => {
      if (entity.alive) {
        entity.setSelected(true);
        this.selectedIds.add(entity.id);
      }
    });
  }

  selectAt(point: Position, additive: boolean): BaseEntity | undefined {
    const candidates = this.getSelectableEntities()
      .filter((entity) => entity.alive && distance(point, entity.position) <= Math.max(entity.radius, 22))
      .sort((a, b) => {
        if (a.kind === "hero") {
          return -1;
        }
        if (b.kind === "hero") {
          return 1;
        }
        return a.radius - b.radius;
      });

    const entity = candidates[0];
    if (!entity) {
      if (!additive) {
        this.clear();
      }
      return undefined;
    }

    if (!additive) {
      this.clear();
    }

    if (this.selectedIds.has(entity.id) && additive) {
      entity.setSelected(false);
      this.selectedIds.delete(entity.id);
    } else {
      entity.setSelected(true);
      this.selectedIds.add(entity.id);
    }
    return entity;
  }

  selectBox(rect: Phaser.Geom.Rectangle, additive: boolean): void {
    if (!additive) {
      this.clear();
    }

    this.getSelectableEntities().forEach((entity) => {
      if (!entity.alive || entity.kind === "building") {
        return;
      }
      if (rect.contains(entity.position.x, entity.position.y)) {
        entity.setSelected(true);
        this.selectedIds.add(entity.id);
      }
    });
  }
}
