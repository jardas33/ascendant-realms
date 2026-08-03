import { describe, expect, it } from "vitest";
import { shouldShowBattlefieldGuides } from "./BattleSceneMapRenderer";

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
});
