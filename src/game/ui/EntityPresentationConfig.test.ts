import { describe, expect, it } from "vitest";
import {
  calculateUnitContentAwareVisualLayout,
  calculateBuildingContentAwareVisualLayout,
  getCommonPresentationDefaults,
  presentationConfigHasGameplayFields,
  resolveEntityPresentationConfig,
  resolveBuildingContentAwarePresentationMetadata,
  resolveUnitContentAwarePresentationMetadata
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

  it("exposes only the three canonical humanoid assets with validated source metadata", () => {
    const warlord = resolveUnitContentAwarePresentationMetadata("warlord_hero_battle_sprite");
    const militia = resolveUnitContentAwarePresentationMetadata("militia_unit_sprite");
    const ranger = resolveUnitContentAwarePresentationMetadata("ranger_unit_sprite");

    expect([warlord, militia, ranger].every(Boolean)).toBe(true);
    expect(warlord?.sourceCanvas).toEqual({ width: 512, height: 512 });
    expect(warlord?.alphaThreshold).toBe(8);
    expect(warlord?.alphaContentBounds).toEqual({
      left: 0.1875,
      top: 0.0703125,
      right: 0.814453125,
      bottom: 0.9296875
    });
    expect(militia?.feetAnchor).toEqual({ x: 0.5, y: 0.9296875 });
    expect(ranger?.manualFeetAnchor).toBe(false);
    expect(resolveUnitContentAwarePresentationMetadata("wild_hound_unit_sprite")).toBeUndefined();
    expect(resolveUnitContentAwarePresentationMetadata("missing_asset")).toBeUndefined();
  });

  it("grounds content-aware layouts and preserves the legacy target-content height", () => {
    const hero = calculateUnitContentAwareVisualLayout("warlord_hero_battle_sprite", 19);
    const militia = calculateUnitContentAwareVisualLayout("militia_unit_sprite", 13);

    expect(hero).toBeDefined();
    expect(militia).toBeDefined();
    expect(hero?.targetContentHeight).toBeCloseTo(19 * 4.35, 8);
    expect(militia?.targetContentHeight).toBeCloseTo(13 * 3.65, 8);
    expect(hero?.visualBottom).toBeCloseTo(0, 8);
    expect(militia?.visualBottom).toBeCloseTo(0, 8);
    expect(hero?.visualTop).toBeLessThan(0);
    expect(Number.isFinite(hero?.scale)).toBe(true);
    expect(calculateUnitContentAwareVisualLayout("wild_hound_unit_sprite", 13)).toBeUndefined();
    expect(calculateUnitContentAwareVisualLayout("militia_unit_sprite", Number.NaN)).toBeUndefined();
  });

  it("resolves only the exact Command Hall building metadata and grounds its content bounds", () => {
    const metadata = resolveBuildingContentAwarePresentationMetadata("command_hall_building_sprite");
    const layout = calculateBuildingContentAwareVisualLayout("command_hall_building_sprite", 100, 80, 768, 768);

    expect(metadata).toBeDefined();
    expect(metadata?.sourceCanvas).toEqual({ width: 768, height: 768 });
    expect(metadata?.alphaThreshold).toBe(8);
    expect(metadata?.alphaContentBounds).toEqual({
      left: 0.0703125,
      top: 0.11848958333333333,
      right: 0.9296875,
      bottom: 0.8815104166666666
    });
    expect(metadata?.groundAnchor).toEqual({ x: 0.5, y: 0.8815104166666666 });
    expect(metadata?.fitPolicy).toBe("content-bounds-within-legacy-envelope");
    expect(metadata?.groundAnchorMode).toBe("manual-authored");
    expect(resolveBuildingContentAwarePresentationMetadata("barracks_building_sprite")).toBeUndefined();
    expect(layout).toBeDefined();
    expect(layout?.contentWidth).toBeCloseTo(660 * (124 / 660), 10);
    expect(layout?.contentHeight).toBeCloseTo(586 * (124 / 660), 10);
    expect(layout?.scale).toBeCloseTo(Math.min(124 / 660, 113.6 / 586), 10);
    expect(layout?.visualTop).toBeLessThan(0);
    expect(layout?.visualBottom).toBeCloseTo(36.8, 10);
    expect((0.8815104166666666 - 0.8815104166666666) * 768 * (layout?.scale ?? 0)).toBe(0);
    expect(calculateBuildingContentAwareVisualLayout("command_hall_building_sprite", 100, 80, 767, 768)).toBeUndefined();
    expect(calculateBuildingContentAwareVisualLayout("command_hall_building_sprite", 100, 80, Number.NaN, 768)).toBeUndefined();
  });
});
