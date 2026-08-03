import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { AssetLoader } from "../assets/AssetLoader";
import type { RuntimeAssetManifest } from "../assets/AssetManifestTypes";
import { renderEntityPortrait, resolveEntityPortrait } from "./EntityPortrait";

const manifest: RuntimeAssetManifest = {
  version: 1,
  generatedAt: "test",
  priorityOrder: ["final", "manual", "placeholder"],
  assets: {
    militia_sprite: {
      id: "militia_sprite",
      category: "unit-sprite",
      displayName: "Militia",
      filename: "militia.png",
      targetFolder: "units",
      usage: "test",
      priority: 1,
      required: false,
      available: true,
      source: "manual",
      path: "/assets/militia.png",
      preferredWidth: 256,
      preferredHeight: 256
    }
  }
};

describe("EntityPortrait", () => {
  let previousManifest: RuntimeAssetManifest;

  beforeEach(() => {
    previousManifest = AssetLoader.getManifest();
    AssetLoader.setManifest(manifest);
  });

  afterEach(() => AssetLoader.setManifest(previousManifest));

  it("honours manifest source priority over caller ordering", () => {
    const finalAsset = { ...manifest.assets.militia_sprite, id: "militia_sprite_final", source: "final" as const };
    AssetLoader.setManifest({ ...manifest, assets: { ...manifest.assets, militia_sprite_final: finalAsset } });

    expect(resolveEntityPortrait({
      kind: "unit",
      name: "Militia",
      role: "Frontline / Melee",
      team: "player",
      accent: "#80d982",
      assetIds: ["militia_sprite", "militia_sprite_final"]
    }).assetId).toBe("militia_sprite_final");
  });

  it("uses the first available canonical source and preserves accessible identity", () => {
    const resolution = resolveEntityPortrait({
      kind: "unit",
      name: "Militia",
      role: "Frontline / Melee",
      team: "player",
      accent: "#80d982",
      assetIds: ["missing", "militia_sprite"]
    });

    expect(resolution).toMatchObject({
      source: "asset",
      assetId: "militia_sprite",
      initials: "M",
      accessibleLabel: "Selected Frontline / Melee portrait for Militia"
    });
    expect(renderEntityPortrait({
      kind: "unit",
      name: "Militia",
      role: "Frontline / Melee",
      team: "player",
      accent: "#80d982",
      assetIds: ["militia_sprite"]
    })).toContain('data-portrait-source="asset"');
  });

  it("renders a non-empty semantic fallback when art is unavailable", () => {
    const markup = renderEntityPortrait({
      kind: "building",
      name: "Field Barracks",
      role: "Building",
      team: "player",
      accent: "#80d982",
      assetIds: ["missing"]
    });

    expect(markup).toContain('data-portrait-source="fallback"');
    expect(markup).toContain(">FB</span>");
    expect(markup).toContain('aria-label="Selected Building portrait for Field Barracks"');
    expect(markup).not.toContain("missing");
  });

  it("keeps a failed image recoverable without a broken-image glyph or retry loop", () => {
    const markup = renderEntityPortrait({
      kind: "hero",
      name: "Aster",
      role: "Hero / Commander",
      team: "player",
      accent: "#80d982",
      assetIds: ["militia_sprite"]
    });

    const onerror = markup.match(/onerror="([^"]+)"/)?.[1];
    expect(onerror).toContain("dataset.portraitSource='fallback'");
    expect(onerror).toContain("closest('[data-testid=selected-entity-portrait]')");
    expect(markup).toContain('class="selected-entity-portrait-fallback" hidden');
  });
});
