import { describe, expect, it } from "vitest";
import { renderStatusLine, renderHintLine } from "./AlertPanel";
import { renderMinimapPanel } from "./MinimapPanel";
import type { MinimapSnapshot } from "../MinimapView";

describe("HUD volatile regions", () => {
  it("marks high-frequency HUD regions so they can update without replacing stable controls", () => {
    const minimap: MinimapSnapshot = {
      mapWidth: 1000,
      mapHeight: 1000,
      markers: [],
      camera: { x: 0, y: 0, width: 400, height: 400 },
      pings: [],
      fog: { enabled: false }
    };

    expect(renderMinimapPanel(minimap)).toContain('data-hud-volatile="minimap"');
    expect(renderStatusLine("Ready", false)).toContain('data-hud-volatile="status"');
    expect(renderHintLine("Press H")).toContain('data-hud-volatile="hint"');
  });
});
