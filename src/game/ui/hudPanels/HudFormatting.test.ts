import { describe, expect, it } from "vitest";
import {
  clamp,
  escapeHtml,
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
});
