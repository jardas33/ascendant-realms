import { describe, expect, it } from "vitest";
import { BUILDING_BY_ID } from "../../data/contentIndex";
import {
  clamp,
  escapeHtml,
  formatBuildingRole,
  formatBuildingSummary,
  formatBuildingUnlockSummary,
  formatInverseMultiplierPercent,
  formatMultiplierPercent,
  toCssColor
} from "./HudFormatting";

describe("HudFormatting", () => {
  it("escapes text inserted into HUD markup", () => {
    expect(escapeHtml(`Aster & "allies" <ready>`)).toBe("Aster &amp; &quot;allies&quot; &lt;ready&gt;");
  });

  it("clamps minimap click ratios", () => {
    expect(clamp(-0.2, 0, 1)).toBe(0);
    expect(clamp(0.4, 0, 1)).toBe(0.4);
    expect(clamp(1.4, 0, 1)).toBe(1);
  });

  it("formats HUD colors and multiplier labels", () => {
    expect(toCssColor(0xf0d978)).toBe("#f0d978");
    expect(formatMultiplierPercent(1.1)).toBe("+10%");
    expect(formatInverseMultiplierPercent(0.9)).toBe("-10%");
  });

  it("summarizes building roles and completion unlocks from existing actions", () => {
    expect(formatBuildingRole(BUILDING_BY_ID.command_hall)).toBe("Base hub: trains Workers and anchors the camp.");
    expect(formatBuildingUnlockSummary(BUILDING_BY_ID.barracks)).toBe(
      "Unlocks when complete: trains Militia, Ranger; researches Infantry Weapons I, Reinforced Armor I, Ranger Training I."
    );
    expect(formatBuildingUnlockSummary(BUILDING_BY_ID.mystic_lodge)).toBe(
      "Unlocks when complete: trains Acolyte; researches Aether Study I."
    );
    expect(formatBuildingUnlockSummary(BUILDING_BY_ID.watchtower)).toBe(
      "Unlocks when complete: defensive attack (14 damage, 220 range)."
    );
    expect(formatBuildingSummary(BUILDING_BY_ID.barracks)).toContain(
      "researches Infantry Weapons I, Reinforced Armor I, Ranger Training I"
    );
  });
});
