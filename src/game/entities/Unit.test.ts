import { describe, expect, it } from "vitest";
import { resolveEntityPresentationConfig } from "../ui/EntityPresentationConfig";

describe("Unit presentation configuration seam", () => {
  it("keeps normal-unit and hero render constants distinct without gameplay fields", () => {
    const unit = resolveEntityPresentationConfig("unit");
    const hero = resolveEntityPresentationConfig("hero");

    expect(unit.layout.healthWidthPx).toBe(42);
    expect(hero.layout.healthWidthPx).toBe(56);
    expect(unit.layout.selectionWidthRadiusMultiplier).toBe(2.15);
    expect(hero.layout.selectionWidthRadiusMultiplier).toBe(2.35);
    expect(unit.fallback.visualTopRadiusMultiplier).toBe(-1.28);
    expect(hero.fallback.visualTopRadiusMultiplier).toBe(-1.62);
    expect(Object.keys(unit)).not.toContain("radius");
    expect(Object.keys(hero)).not.toContain("position");
  });

  it("preserves fixed legacy depth and shadow attachment values", () => {
    const unit = resolveEntityPresentationConfig("unit");

    expect(unit.depth.fixedDepth).toBe(10);
    expect(unit.shadow).toEqual({
      yRadiusMultiplier: 0.58,
      widthRadiusMultiplier: 2.5,
      heightRadiusMultiplier: 0.72,
      opacity: 0.32
    });
    expect(unit.layout.selectionYOffsetPx).toBe(0.5);
  });
});
