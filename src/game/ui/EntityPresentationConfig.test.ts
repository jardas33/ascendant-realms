import { describe, expect, it } from "vitest";
import {
  getCommonPresentationDefaults,
  presentationConfigHasGameplayFields,
  resolveEntityPresentationConfig
} from "./EntityPresentationConfig";

describe("EntityPresentationConfig", () => {
  it("resolves the legacy-equivalent unit, hero, and building defaults", () => {
    const unit = resolveEntityPresentationConfig("unit");
    const hero = resolveEntityPresentationConfig("hero");
    const building = resolveEntityPresentationConfig("building");

    expect(unit.sprite.targetHeightRadiusMultiplier).toBe(3.65);
    expect(hero.sprite.targetHeightRadiusMultiplier).toBe(4.35);
    expect(unit.shadow.opacity).toBe(0.32);
    expect(building.sprite.maxWidthSizeMultiplier).toBe(1.24);
    expect(building.sprite.maxHeightSizeMultiplier).toBe(1.42);
    expect(unit.depth).toEqual({ mode: "fixed-type-legacy", fixedDepth: 10, active: false });
    expect(hero.depth).toEqual({ mode: "fixed-type-legacy", fixedDepth: 12, active: false });
    expect(building.depth).toEqual({ mode: "fixed-type-legacy", fixedDepth: 5, active: false });
  });

  it("keeps common BaseEntity constants centralized and frozen", () => {
    const common = getCommonPresentationDefaults();

    expect(common.selection).toEqual({
      radiusAddPx: 7,
      widthRadiusMultiplier: 2.1,
      heightRadiusMultiplier: 0.62,
      minHeightPx: 8
    });
    expect(common.health).toEqual({ minWidthPx: 34, widthRadiusMultiplier: 2.4, heightPx: 5, topOffsetPx: 13 });
    expect(Object.isFrozen(common)).toBe(true);
    expect(Object.isFrozen(common.selection)).toBe(true);
  });

  it("deep-freezes defaults and prevents gameplay fields from entering the seam", () => {
    const config = resolveEntityPresentationConfig("unit");

    expect(Object.isFrozen(config)).toBe(true);
    expect(Object.isFrozen(config.sprite)).toBe(true);
    expect(Object.isFrozen(config.layout)).toBe(true);
    expect(config.inactiveFuture.yDepthPolicyActive).toBe(false);
    expect(presentationConfigHasGameplayFields(config)).toBe(false);
    expect(Object.keys(config)).not.toEqual(expect.arrayContaining(["radius", "position", "footprint", "range", "vision", "id"]));
  });

  it("accepts bounded presentation-only overrides and rejects invalid ones fail-closed", () => {
    const valid = resolveEntityPresentationConfig("unit", { shadow: { opacity: 0.4 } });
    const invalid = resolveEntityPresentationConfig("unit", { shadow: { opacity: Number.NaN } });
    const outOfRange = resolveEntityPresentationConfig("unit", { sprite: { originY: 2 } });
    const mismatched = resolveEntityPresentationConfig("hero", { family: "building" });

    expect(valid.shadow.opacity).toBe(0.4);
    expect(invalid.shadow.opacity).toBe(0.32);
    expect(outOfRange.sprite.originY).toBe(0.8);
    expect(mismatched.family).toBe("hero");
    expect(mismatched.depth.fixedDepth).toBe(12);
  });

  it("never activates future alpha, asset, or depth metadata", () => {
    for (const family of ["unit", "hero", "building"] as const) {
      const config = resolveEntityPresentationConfig(family, {
        inactiveFuture: {
          alphaBoundsPopulated: true,
          yDepthPolicyActive: true
        }
      });
      expect(config.inactiveFuture).toEqual({
        alphaBoundsPopulated: false,
        feetAnchorPopulated: false,
        targetContentHeightPopulated: false,
        perAssetOverridesActive: false,
        yDepthPolicyActive: false,
        restrictedDepthBandActive: false
      });
      expect(config.depth.active).toBe(false);
    }
  });

  it("drops unknown nested override keys instead of carrying gameplay data", () => {
    const config = resolveEntityPresentationConfig("unit", {
      layout: { radius: 999, healthWidthPx: 48 },
      sprite: { footprint: 999, originY: 0.75 },
      depth: { fixedDepth: 11, position: { x: 4, y: 8 } }
    });

    expect(config.layout.healthWidthPx).toBe(48);
    expect(config.sprite.originY).toBe(0.75);
    expect(config.depth.fixedDepth).toBe(11);
    expect(JSON.stringify(config)).not.toMatch(/radius|footprint|position/);
  });
});
