import { describe, expect, it } from "vitest";
import { renderPauseMenu } from "./PauseMenuPanel";

describe("PauseMenuPanel", () => {
  it("renders resume and explicit exit actions when visible", () => {
    const html = renderPauseMenu({
      visible: true,
      title: "Paused",
      description: "Battle simulation is paused."
    });

    expect(html).toContain('data-testid="battle-pause-menu"');
    expect(html).toContain('data-testid="battle-resume"');
    expect(html).toContain('data-testid="battle-exit-menu"');
    expect(html).toContain("Exit to Main Menu");
  });

  it("renders nothing when hidden", () => {
    expect(renderPauseMenu(undefined)).toBe("");
    expect(renderPauseMenu({ visible: false, title: "Paused", description: "Hidden" })).toBe("");
  });
});
