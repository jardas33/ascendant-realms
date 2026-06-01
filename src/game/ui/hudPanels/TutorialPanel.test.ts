import { describe, expect, it } from "vitest";
import { TUTORIALS } from "../../data/tutorials";
import { createTutorialStepViewModel } from "../../tutorial/TutorialStepModel";
import { renderTutorialPanel } from "./TutorialPanel";

describe("TutorialPanel", () => {
  it("renders concise objective, instruction, hint, progress, and exit copy", () => {
    const step = createTutorialStepViewModel(TUTORIALS[0], "select_hero");
    const html = renderTutorialPanel(step);

    expect(html).toContain('data-testid="tutorial-overlay"');
    expect(html).toContain('aria-live="polite"');
    expect(html).toContain('aria-label="Exit Tutorial and return to main menu"');
    expect(html).toContain('data-testid="tutorial-drag-handle"');
    expect(html).toContain('data-testid="tutorial-minimize"');
    expect(html).toContain('data-testid="tutorial-reset"');
    expect(html).toContain('data-testid="tutorial-panel-body"');
    expect(html).toContain("Drag empty panel space to move the objective box");
    expect(html).toContain("Proving Grounds");
    expect(html).toContain("Hide");
    expect(html).toContain("Reset");
    expect(html).toContain("Select Aster");
    expect(html).toContain("Click Aster");
    expect(html).toContain("hero anchors");
    expect(html).toContain('data-testid="tutorial-more-help"');
    expect(html).toContain("WASD");
    expect(html).toContain('data-testid="tutorial-focus"');
    expect(html).toContain('data-testid="tutorial-dismiss"');
    expect(html).toContain("Step 1 of 12");
    expect(html).toContain("Select the hero");
    expect(html).not.toContain("Next Objective");
    expect(html).toContain("Exit Tutorial");
  });

  it("renders the next action only after a step is complete", () => {
    const html = renderTutorialPanel(createTutorialStepViewModel(TUTORIALS[0], "select_hero", { heroSelected: true }));

    expect(html).toContain('data-testid="tutorial-next"');
    expect(html).toContain('aria-label="Next Objective from Select Aster"');
    expect(html).toContain("Next Objective");
  });

  it("renders completion copy for the final step", () => {
    const html = renderTutorialPanel(createTutorialStepViewModel(TUTORIALS[0], "finish_training", { finished: true }));

    expect(html).toContain("Complete Tutorial");
    expect(html).toContain("No rewards or campaign progress were granted");
    expect(html).toContain("Use the campaign when you are ready");
  });

  it("renders a keyboard reachable reopen state when dismissed", () => {
    const html = renderTutorialPanel({
      ...createTutorialStepViewModel(TUTORIALS[0], "select_hero"),
      dismissed: true
    });

    expect(html).toContain('data-testid="tutorial-reopen"');
    expect(html).toContain("Show Tutorial Help");
    expect(html).not.toContain('data-testid="tutorial-panel-body"');
  });

  it("renders nothing outside tutorial mode", () => {
    expect(renderTutorialPanel(undefined)).toBe("");
  });
});
