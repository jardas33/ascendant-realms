import { describe, expect, it } from "vitest";
import {
  calculateBuildingContentAwareVisualLayout,
  resolveEntityPresentationConfig
} from "../ui/EntityPresentationConfig";

describe("Building presentation configuration seam", () => {
  it("preserves legacy fit, shadow, and selection constants", () => {
    const building = resolveEntityPresentationConfig("building");

    expect(building.sprite).toEqual({ originY: 0.66, maxWidthSizeMultiplier: 1.24, maxHeightSizeMultiplier: 1.42 });
    expect(building.shadow).toEqual({
      ySizeHeightMultiplier: 0.3,
      widthSizeMultiplier: 1.1,
      heightSizeMultiplier: 0.46,
      opacity: 0.28
    });
    expect(building.layout.selectionWidthSizeMultiplier).toBe(1.16);
    expect(building.layout.selectionHeightSizeMultiplier).toBe(0.38);
    expect(building.fallback).toEqual({ visualTopSizeMultiplier: -0.5, visualBottomSizeMultiplier: 0.5 });
  });

  it("does not expose footprint, placement, or collision data", () => {
    const building = resolveEntityPresentationConfig("building");
    const serialized = JSON.stringify(building);

    expect(serialized).not.toMatch(/footprint|collision|placement|navigation|range|vision|radius/);
  });

  it("keeps content-aware Command Hall layout render-only and bounded by the legacy envelope", () => {
    const layout = calculateBuildingContentAwareVisualLayout("command_hall_building_sprite", 120, 90, 768, 768);

    expect(layout).toBeDefined();
    expect(layout?.contentWidth).toBeLessThanOrEqual(120 * 1.24);
    expect(layout?.contentHeight).toBeLessThanOrEqual(90 * 1.42);
    expect(layout?.originX).toBe(0.5);
    expect(layout?.originY).toBe(0.8815104166666666);
    expect(layout?.shadowY).toBe(0);
    expect(calculateBuildingContentAwareVisualLayout("enemy_barracks_building_sprite", 120, 90, 768, 768)).toBeUndefined();
  });
});
