import { describe, expect, it, vi } from "vitest";
import { HERO_CLASSES } from "../data/heroClasses";
import { ORIGINS } from "../data/origins";

vi.mock("phaser", () => ({
  default: {
    Scene: class MockScene {}
  }
}));

const { createHeroCreationSummary } = await import("./HeroCreationScene");

describe("HeroCreationScene presentation summary", () => {
  it("keeps the canonical default choice player-readable", () => {
    const summary = createHeroCreationSummary({
      heroName: "Aster",
      heroClass: HERO_CLASSES[0],
      origin: ORIGINS[0],
      nextMode: "campaign"
    });

    expect(summary).toMatchObject({
      heroName: "Aster",
      className: "Warlord",
      originName: "Exiled Noble",
      status: "Ready to begin."
    });
    expect(summary.meaning).toContain(HERO_CLASSES[0].description);
    expect(summary.meaning).toContain(ORIGINS[0].description);
    expect(summary.actionDescription).not.toContain("class IDs");
  });

  it("reflects independent alternate choices without exposing internal ids", () => {
    const summary = createHeroCreationSummary({
      heroName: "WASD Aster",
      heroClass: HERO_CLASSES.find((heroClass) => heroClass.id === "arcanist")!,
      origin: ORIGINS.find((origin) => origin.id === "temple_orphan")!,
      nextMode: "campaign"
    });

    expect(summary.heroName).toBe("WASD Aster");
    expect(summary.className).toBe("Arcanist");
    expect(summary.originName).toBe("Temple Orphan");
    expect(summary.meaning).not.toContain("arcanist");
    expect(summary.meaning).not.toContain("temple_orphan");
  });

  it("documents the existing blank-name fallback without changing it", () => {
    const summary = createHeroCreationSummary({
      heroName: "   ",
      heroClass: HERO_CLASSES[0],
      origin: ORIGINS[0],
      nextMode: "campaign"
    });

    expect(summary.heroName).toBe("Aster");
    expect(summary.status).toBe("Blank names use the existing Aster default.");
  });
});
