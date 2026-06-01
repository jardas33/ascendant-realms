import { describe, expect, it } from "vitest";
import { clampCameraCenterPosition } from "./CameraBounds";

describe("CameraSystem", () => {
  it("clamps focus targets inside the map while preserving reachable centers", () => {
    const map = { width: 1200, height: 800 };
    const viewport = { width: 400, height: 300, zoom: 1 };

    expect(clampCameraCenterPosition({ x: 20, y: 20 }, map, viewport)).toEqual({ x: 200, y: 150 });
    expect(clampCameraCenterPosition({ x: 600, y: 400 }, map, viewport)).toEqual({ x: 600, y: 400 });
    expect(clampCameraCenterPosition({ x: 1180, y: 790 }, map, viewport)).toEqual({ x: 1000, y: 650 });
  });

  it("centers maps smaller than the viewport instead of producing negative scroll space", () => {
    expect(clampCameraCenterPosition({ x: 0, y: 0 }, { width: 300, height: 220 }, { width: 800, height: 600, zoom: 1 })).toEqual({
      x: 150,
      y: 110
    });
  });
});
