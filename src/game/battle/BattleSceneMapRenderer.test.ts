import { describe, expect, it } from "vitest";
import { BROKEN_FORD_MAP } from "../data/maps/brokenFord";
import {
  createRoadShoulderPoints,
  createTerrainPresentationGeometryFingerprint,
  createWaterShorelinePoints,
  shouldShowBattlefieldGuides
} from "./BattleSceneMapRenderer";

describe("battlefield guide presentation", () => {
  it("keeps the full validation grid out of normal play until placement begins", () => {
    expect(shouldShowBattlefieldGuides("minimal", false)).toBe(false);
    expect(shouldShowBattlefieldGuides("standard", false)).toBe(false);
    expect(shouldShowBattlefieldGuides("minimal", true)).toBe(true);
    expect(shouldShowBattlefieldGuides("standard", true)).toBe(true);
  });

  it("preserves the full grid for explicit debug review mode", () => {
    expect(shouldShowBattlefieldGuides("debug", false)).toBe(true);
    expect(shouldShowBattlefieldGuides("debug", true)).toBe(true);
  });

  it("derives deterministic presentation geometry without mutating map ownership", () => {
    const before = JSON.stringify(BROKEN_FORD_MAP);
    const first = createTerrainPresentationGeometryFingerprint(BROKEN_FORD_MAP);
    const second = createTerrainPresentationGeometryFingerprint(BROKEN_FORD_MAP);

    expect(first).toBe(second);
    expect(JSON.stringify(BROKEN_FORD_MAP)).toBe(before);

    const changedPath = structuredClone(BROKEN_FORD_MAP);
    changedPath.visualPaths[0].points[0].x += 1;
    expect(createTerrainPresentationGeometryFingerprint(changedPath)).not.toBe(first);
  });

  it("keeps road shoulders and water shorelines inside presentation-only bounds", () => {
    const road = BROKEN_FORD_MAP.visualPaths[0];
    const shoulders = createRoadShoulderPoints(road.points, road.width, road.id);
    expect(shoulders.length).toBe((road.points.length - 1) * 2);
    expect(shoulders.every((point) => Number.isFinite(point.x) && Number.isFinite(point.y))).toBe(true);

    const water = BROKEN_FORD_MAP.terrainZones.find((zone) => zone.type === "water");
    expect(water).toBeDefined();
    const shoreline = createWaterShorelinePoints(water!);
    expect(shoreline.every((point) =>
      point.x >= water!.x && point.x <= water!.x + water!.width &&
      point.y >= water!.y && point.y <= water!.y + water!.height
    )).toBe(true);
  });
});
