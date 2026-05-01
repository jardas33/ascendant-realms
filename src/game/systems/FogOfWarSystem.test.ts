import { describe, expect, it } from "vitest";
import { FogOfWarSystem, isEntityVisibleToPlayer } from "./FogOfWarSystem";

describe("FogOfWarSystem", () => {
  it("starts every cell as unseen", () => {
    const fog = new FogOfWarSystem(400, 400, 100);

    expect(fog.cells()).toHaveLength(16);
    expect(fog.cells().every((cell) => cell.state === "unseen")).toBe(true);
    expect(fog.stateAt({ x: 50, y: 50 })).toBe("unseen");
  });

  it("reveals cells around friendly vision sources", () => {
    const fog = new FogOfWarSystem(500, 500, 100);

    fog.update([{ x: 150, y: 150, radius: 120 }]);

    expect(fog.stateAt({ x: 150, y: 150 })).toBe("visible");
    expect(fog.isVisible({ x: 210, y: 150 })).toBe(true);
    expect(fog.stateAt({ x: 450, y: 450 })).toBe("unseen");
  });

  it("uses precise vision checks for entities inside coarse visible cells", () => {
    const fog = new FogOfWarSystem(300, 300, 100);

    fog.update([{ x: 50, y: 50, radius: 10 }]);

    expect(fog.stateAt({ x: 95, y: 95 })).toBe("visible");
    expect(fog.isVisible({ x: 95, y: 95 })).toBe(false);
    expect(fog.isEntityVisible({ x: 95, y: 95 }, 60)).toBe(true);
  });

  it("keeps previously visible cells explored after vision leaves", () => {
    const fog = new FogOfWarSystem(600, 400, 100);

    fog.update([{ x: 100, y: 100, radius: 110 }]);
    expect(fog.stateAt({ x: 100, y: 100 })).toBe("visible");

    fog.update([{ x: 500, y: 300, radius: 80 }]);

    expect(fog.stateAt({ x: 100, y: 100 })).toBe("explored");
    expect(fog.stateAt({ x: 500, y: 300 })).toBe("visible");
  });

  it("hides non-player entities outside current vision", () => {
    const fog = new FogOfWarSystem(800, 600, 100);
    fog.update([{ x: 100, y: 100, radius: 120 }]);

    expect(isEntityVisibleToPlayer({ team: "enemy", position: { x: 650, y: 450 } }, fog, true)).toBe(false);
    expect(isEntityVisibleToPlayer({ team: "neutral", position: { x: 650, y: 450 } }, fog, true)).toBe(false);
    expect(isEntityVisibleToPlayer({ team: "player", position: { x: 650, y: 450 } }, fog, true)).toBe(true);
    expect(isEntityVisibleToPlayer({ team: "enemy", position: { x: 650, y: 450 } }, fog, false)).toBe(true);
  });
});
