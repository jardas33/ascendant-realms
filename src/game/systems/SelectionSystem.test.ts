import type Phaser from "phaser";
import { describe, expect, it, vi } from "vitest";
import type { BaseEntity } from "../entities/BaseEntity";
import { SelectionSystem } from "./SelectionSystem";

describe("SelectionSystem", () => {
  it("selects multiple battlefield units inside a marquee rectangle and ignores buildings", () => {
    const militia = fakeEntity("unit-1", "unit", 100, 100);
    const ranger = fakeEntity("unit-2", "unit", 140, 120);
    const outside = fakeEntity("unit-3", "unit", 260, 260);
    const building = fakeEntity("barracks", "building", 120, 110);
    const selection = new SelectionSystem(() => [militia, ranger, outside, building]);

    selection.selectBox(fakeRectangle(80, 80, 90, 80), false);

    expect(selection.getSelectedIds()).toEqual(["unit-1", "unit-2"]);
    expect(militia.setSelected).toHaveBeenCalledWith(true);
    expect(ranger.setSelected).toHaveBeenCalledWith(true);
    expect(outside.setSelected).not.toHaveBeenCalledWith(true);
    expect(building.setSelected).not.toHaveBeenCalledWith(true);
  });
});

function fakeEntity(id: string, kind: "unit" | "building", x: number, y: number): BaseEntity {
  return {
    id,
    kind,
    team: "player",
    alive: true,
    position: { x, y },
    radius: 12,
    setSelected: vi.fn()
  } as unknown as BaseEntity;
}

function fakeRectangle(x: number, y: number, width: number, height: number): Phaser.Geom.Rectangle {
  return {
    x,
    y,
    width,
    height,
    contains: (pointX: number, pointY: number) => pointX >= x && pointX <= x + width && pointY >= y && pointY <= y + height
  } as Phaser.Geom.Rectangle;
}
