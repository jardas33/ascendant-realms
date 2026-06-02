import { describe, expect, it } from "vitest";
import { createMinimapRenderSignature, renderMinimap, type MinimapSnapshot } from "./MinimapView";

describe("renderMinimap", () => {
  const snapshot: MinimapSnapshot = {
    mapWidth: 2400,
    mapHeight: 1600,
    markers: [
      { id: "player-unit", kind: "unit", team: "player", x: 240, y: 800 },
      { id: "enemy-building", kind: "building", team: "enemy", x: 2160, y: 800, size: 4 },
      { id: "neutral-camp", kind: "camp", team: "neutral", x: 1200, y: 400 },
      {
        id: "crown-shrine",
        kind: "capture-site",
        team: "neutral",
        x: 1200,
        y: 800,
        resource: "crowns",
        resourceColor: "#f0d978",
        isObjective: true
      }
    ],
    camera: { x: 600, y: 400, width: 1200, height: 800 },
    pings: [{ id: 1, x: 1800, y: 1200, ageSeconds: 0.7, durationSeconds: 2.8, color: "#ff7268", label: "Enemy wave incoming" }],
    fog: { enabled: false }
  };

  it("renders live markers, camera bounds, and alert pings in map coordinates", () => {
    const markup = renderMinimap(snapshot);

    expect(markup).toContain("data-minimap=\"true\"");
    expect(markup).toContain("class=\"minimap-unit\"");
    expect(markup).toContain("cx=\"10\"");
    expect(markup).toContain("class=\"minimap-building\"");
    expect(markup).toContain("x=\"88\"");
    expect(markup).toContain("class=\"minimap-site-marker neutral objective\"");
    expect(markup).toContain("Objective resource site");
    expect(markup).toContain("stroke=\"#f0d978\"");
    expect(markup).toContain("class=\"minimap-camera\"");
    expect(markup).toContain("x=\"25\"");
    expect(markup).toContain("width=\"50\"");
    expect(markup).toContain("Enemy wave incoming");
  });

  it("reuses stable minimap markup and invalidates when camera or ping state changes", () => {
    const first = renderMinimap(snapshot);
    const second = renderMinimap({ ...snapshot, markers: [...snapshot.markers] });
    const movedCamera = {
      ...snapshot,
      camera: { ...snapshot.camera, x: snapshot.camera.x + 100 }
    };
    const agedPing = {
      ...snapshot,
      pings: snapshot.pings.map((ping) => ({ ...ping, ageSeconds: ping.ageSeconds + 0.5 }))
    };

    expect(second).toBe(first);
    expect(createMinimapRenderSignature(movedCamera)).not.toBe(createMinimapRenderSignature(snapshot));
    expect(renderMinimap(movedCamera)).not.toBe(first);
    expect(createMinimapRenderSignature(agedPing)).not.toBe(createMinimapRenderSignature(snapshot));
  });
});
