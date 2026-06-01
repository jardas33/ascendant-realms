import Phaser from "phaser";
import type { Position } from "../core/GameTypes";
import { distance } from "../core/MathUtils";
import type { BaseEntity } from "../entities/BaseEntity";

export class SelectionSystem {
  private readonly selectedIds = new Set<string>();
  private inspectedEntity?: BaseEntity;

  constructor(private readonly getSelectableEntities: () => BaseEntity[]) {}

  getSelected(): BaseEntity[] {
    const all = this.getSelectableEntities();
    const selected = all.filter((entity) => this.selectedIds.has(entity.id) && entity.alive);
    if (
      this.inspectedEntity?.alive &&
      this.selectedIds.has(this.inspectedEntity.id) &&
      !selected.some((entity) => entity.id === this.inspectedEntity?.id)
    ) {
      selected.push(this.inspectedEntity);
    }
    return selected;
  }

  getSelectedIds(): string[] {
    return [...this.selectedIds];
  }

  clear(): void {
    this.getSelectableEntities().forEach((entity) => entity.setSelected(false));
    this.inspectedEntity?.setSelected(false);
    this.inspectedEntity = undefined;
    this.selectedIds.clear();
  }

  setSelection(entities: BaseEntity[]): void {
    this.clear();
    const selectableIds = new Set(this.getSelectableEntities().map((entity) => entity.id));
    entities.forEach((entity) => {
      if (entity.alive) {
        entity.setSelected(true);
        this.selectedIds.add(entity.id);
        if (!selectableIds.has(entity.id)) {
          this.inspectedEntity = entity;
        }
      }
    });
  }

  inspect(entity: BaseEntity): void {
    this.setSelection([entity]);
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
      if (!entity.alive || entity.team !== "player" || (entity.kind !== "unit" && entity.kind !== "hero")) {
        return;
      }
      if (rect.contains(entity.position.x, entity.position.y)) {
        entity.setSelected(true);
        this.selectedIds.add(entity.id);
      }
    });
  }
}
