import { describe, expect, it } from "vitest";
import { playerFacingStatus, renderMatchContext } from "./HudRoot";

describe("HudRoot player presentation", () => {
  it("keeps match time while removing internal AI state wording", () => {
    expect(playerFacingStatus("AI: EXPAND - Time 00:42")).toBe("Match active · Time 00:42");
  });

  it("preserves actionable transient statuses", () => {
    expect(playerFacingStatus("Select a Worker and right-click the site.")).toBe("Select a Worker and right-click the site.");
  });

  it("does not expose the internal AI state in the player-facing status contract", () => {
    expect(playerFacingStatus("AI: BUILD_ARMY - Time 01:05")).not.toContain("AI:");
    expect(playerFacingStatus("AI: BUILD_ARMY - Time 01:05")).toContain("Time 01:05");
  });

  it("renders canonical opponent, difficulty, and current fixed speed without internal keys", () => {
    const markup = renderMatchContext({
      opponentFactionName: "Ashen Covenant",
      difficultyLabel: "Easy",
      speedLabel: "1×"
    });

    expect(markup).toContain("Opponent: <strong>Ashen Covenant</strong>");
    expect(markup).toContain(">Easy</span>");
    expect(markup).toContain(">1×</span>");
    expect(markup).not.toContain("ashen_covenant");
    expect(markup).not.toContain("easy_ai");
  });

  it("renders no match context for special launches without canonical metadata", () => {
    expect(renderMatchContext(undefined)).toBe("");
  });
});
