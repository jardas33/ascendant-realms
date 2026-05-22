import { describe, expect, it } from "vitest";
import type { BaseEntity } from "../entities/BaseEntity";
import { CollisionSystem } from "./CollisionSystem";

describe("CollisionSystem", () => {
  it("can use a small interaction radius without changing raw entity radius", () => {
    const enemy = fakeEntity({ id: "enemy-stone-imp", x: 100, y: 100, radius: 14 });

    expect(CollisionSystem.findEntityAt(123, 100, [enemy], { minimumRadius: 24 })?.id).toBe("enemy-stone-imp");
    expect(enemy.radius).toBe(14);
  });

  it("keeps nearby empty terrain from becoming an entity hit", () => {
    const enemy = fakeEntity({ id: "enemy-stone-imp", x: 100, y: 100, radius: 14 });

    expect(CollisionSystem.findEntityAt(129, 100, [enemy], { minimumRadius: 24 })).toBeUndefined();
  });

  it("uses optional padding for visible unit-body tolerance", () => {
    const enemy = fakeEntity({ id: "enemy-stone-imp", x: 100, y: 100, radius: 14 });

    expect(CollisionSystem.findEntityAt(117, 100, [enemy], { padding: 4 })?.id).toBe("enemy-stone-imp");
    expect(CollisionSystem.findEntityAt(119, 100, [enemy], { padding: 4 })).toBeUndefined();
  });
});

function fakeEntity(options: { id: string; x: number; y: number; radius: number }): BaseEntity {
  return {
    id: options.id,
    kind: "unit",
    alive: true,
    team: "enemy",
    position: { x: options.x, y: options.y },
    radius: options.radius
  } as BaseEntity;
}
