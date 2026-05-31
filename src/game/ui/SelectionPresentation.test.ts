import { describe, expect, it } from "vitest";
import { resolveSelectionRingPresentation } from "./SelectionPresentation";

describe("resolveSelectionRingPresentation", () => {
  it("uses distinct restrained rings for player, enemy, and neutral selection", () => {
    const player = resolveSelectionRingPresentation("player", "unit");
    const enemy = resolveSelectionRingPresentation("enemy", "unit");
    const neutral = resolveSelectionRingPresentation("neutral", "capture-site");

    expect(player.strokeColor).not.toBe(enemy.strokeColor);
    expect(enemy.strokeColor).not.toBe(neutral.strokeColor);
    expect(player.fillAlpha).toBeLessThan(0.2);
    expect(enemy.strokeWidth).toBeGreaterThanOrEqual(3);
  });
});
