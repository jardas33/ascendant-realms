import { describe, expect, it } from "vitest";
import { resolveBattlefieldViewportLayout } from "../ui/hudPanels/HudRoot";
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

  it("reserves exactly the visible panel width without accumulating an inset", () => {
    expect(resolveBattlefieldViewportLayout(1280, 720, 0, 1280, 960)).toEqual({
      width: 960,
      height: 720,
      rightEdge: 960,
      rightInset: 320
    });
    expect(resolveBattlefieldViewportLayout(1280, 720, 0, 1280, null)).toEqual({
      width: 1280,
      height: 720,
      rightEdge: 1280,
      rightInset: 0
    });
    expect(resolveBattlefieldViewportLayout(1280, 720, 0, 1280, 1078)).toEqual({
      width: 1078,
      height: 720,
      rightEdge: 1078,
      rightInset: 202
    });
  });

  it("maps a responsive canvas and panel using their measured CSS coordinates", () => {
    expect(resolveBattlefieldViewportLayout(1920, 1080, 40, 1920, 1500)).toEqual({
      width: 1460,
      height: 1080,
      rightEdge: 1460,
      rightInset: 460
    });
  });
});
