import { describe, expect, it } from "vitest";
import { resolveCaptureSitePresentation } from "./CaptureSitePresentation";

describe("resolveCaptureSitePresentation", () => {
  it("prioritizes selected and contested capture-site label states", () => {
    expect(
      resolveCaptureSitePresentation({
        owner: "player",
        capturingTeam: "enemy",
        captureProgress: 0.4,
        selected: true,
        resourceColor: 0xf0d978
      }).labelPrefix
    ).toBe("SELECTED");

    expect(
      resolveCaptureSitePresentation({
        owner: "player",
        capturingTeam: "enemy",
        captureProgress: 0.4,
        resourceColor: 0xf0d978
      }).state
    ).toBe("contested");
  });

  it("distinguishes friendly, enemy, neutral, and objective labels", () => {
    const friendly = resolveCaptureSitePresentation({
      owner: "player",
      capturingTeam: "neutral",
      captureProgress: 0,
      resourceColor: 0xf0d978
    });
    expect(friendly.labelPrefix).toBe("HELD");
    expect(friendly.ringAlpha).toBeLessThan(0.5);
    expect(friendly.ringWidth).toBe(2);

    expect(
      resolveCaptureSitePresentation({
        owner: "enemy",
        capturingTeam: "neutral",
        captureProgress: 0,
        resourceColor: 0xf0d978
      }).labelPrefix
    ).toBe("ENEMY");
    expect(
      resolveCaptureSitePresentation({
        owner: "neutral",
        capturingTeam: "neutral",
        captureProgress: 0,
        objectiveRelevant: true,
        resourceColor: 0xf0d978
      }).labelPrefix
    ).toBe("OBJECTIVE");
  });
});
