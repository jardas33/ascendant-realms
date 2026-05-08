import { describe, expect, it } from "vitest";
import { TUTORIALS } from "../../data/tutorials";
import { createTutorialStepViewModel } from "../../tutorial/TutorialStepModel";
import { renderTutorialPanel } from "./TutorialPanel";

describe("TutorialPanel", () => {
  it("renders concise objective, instruction, hint, progress, and exit copy", () => {
    const step = createTutorialStepViewModel(TUTORIALS[0], "select_hero");
    const html = renderTutorialPanel(step);

    expect(html).toContain('data-testid="tutorial-overlay"');
    expect(html).toContain("Proving Grounds");
    expect(html).toContain("Select Hero");
    expect(html).toContain("Select Aster");
    expect(html).toContain("Press H or click the hero");
    expect(html).toContain("Step 2 of 12");
    expect(html).toContain("Select the hero");
    expect(html).toContain("Exit Tutorial");
  });

  it("renders nothing outside tutorial mode", () => {
    expect(renderTutorialPanel(undefined)).toBe("");
  });
});
