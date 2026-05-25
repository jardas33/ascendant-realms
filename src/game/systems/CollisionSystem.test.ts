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

  it("can include a narrow top/head hit area without making side terrain targetable", () => {
    const enemy = fakeEntity({ id: "enemy-stone-imp", x: 100, y: 100, radius: 14 });

    expect(
      CollisionSystem.findEntityAt(100, 72, [enemy], {
        minimumRadius: 24,
        topPadding: 6
      })?.id
    ).toBe("enemy-stone-imp");
    expect(
      CollisionSystem.findEntityAt(129, 100, [enemy], {
        minimumRadius: 24,
        topPadding: 6
      })
    ).toBeUndefined();
  });

  it("can include a narrow building-top hit area without widening side terrain", () => {
    const commandHall = fakeEntity({ id: "player-command-hall", kind: "building", x: 100, y: 100, radius: 48 });

    expect(CollisionSystem.findEntityAt(100, 45, [commandHall], { topPadding: 8 })?.id).toBe("player-command-hall");
    expect(CollisionSystem.findEntityAt(157, 100, [commandHall], { topPadding: 8 })).toBeUndefined();
  });

  it("can target visible building corners through an explicit footprint without widening empty terrain", () => {
    const stronghold = fakeEntity({ id: "enemy-stronghold", kind: "building", x: 100, y: 100, radius: 52 });

    const options = {
      footprint: (entity: BaseEntity) =>
        entity.kind === "building" ? { x: entity.position.x - 52, y: entity.position.y - 44, width: 104, height: 88 } : undefined
    };

    expect(CollisionSystem.findEntityAt(150, 144, [stronghold], options)?.id).toBe("enemy-stronghold");
    expect(CollisionSystem.findEntityAt(158, 150, [stronghold], options)).toBeUndefined();
  });
});

function fakeEntity(options: { id: string; x: number; y: number; radius: number; kind?: "unit" | "building" }): BaseEntity {
  return {
    id: options.id,
    kind: options.kind ?? "unit",
    alive: true,
    team: "enemy",
    position: { x: options.x, y: options.y },
    radius: options.radius
  } as BaseEntity;
}
