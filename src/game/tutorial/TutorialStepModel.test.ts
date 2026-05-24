import { describe, expect, it } from "vitest";
import { TUTORIALS } from "../data/tutorials";
import {
  advanceTutorialStep,
  createCompletionConditionLabel,
  createTutorialStepViewModel,
  firstTutorialStepId,
  getNextTutorialStepId,
  getTutorialStep,
  isTutorialStepComplete
} from "./TutorialStepModel";

const tutorial = TUTORIALS[0];

describe("TutorialStepModel", () => {
  it("keeps the planned Proving Grounds step order explicit", () => {
    expect(firstTutorialStepId(tutorial)).toBe("camera_controls");
    expect(tutorial.steps.map((step) => step.id)).toEqual([
      "camera_controls",
      "select_hero",
      "move_hero",
      "capture_crown_shrine",
      "gather_crowns",
      "select_command_hall",
      "build_barracks",
      "train_militia",
      "set_barracks_rally",
      "use_rally_banner",
      "hold_safe_pressure",
      "finish_training"
    ]);
  });

  it("creates a current-step view model with next-step information", () => {
    const viewModel = createTutorialStepViewModel(tutorial, "select_hero");

    expect(viewModel).toMatchObject({
      tutorialId: "proving_grounds_basics",
      stepId: "select_hero",
      stepNumber: 2,
      totalSteps: 12,
      isComplete: false,
      isFinalStep: false,
      advanceActionLabel: "Next Objective",
      nextStepId: "move_hero"
    });
    expect(viewModel.instruction).toContain("Click Aster");
    expect(viewModel.completionConditionLabel).toBe("Select the hero");
    expect(viewModel.progressLabel).toBe("Step 2 of 12");
  });

  it("advances linearly and stays on the final step", () => {
    expect(getNextTutorialStepId(tutorial, "select_hero")).toBe("move_hero");
    expect(advanceTutorialStep(tutorial, "select_hero")).toBe("move_hero");
    expect(getNextTutorialStepId(tutorial, "finish_training")).toBeUndefined();
    expect(advanceTutorialStep(tutorial, "finish_training")).toBe("finish_training");
  });

  it("throws on invalid step ids instead of silently selecting the wrong objective", () => {
    expect(() => getTutorialStep(tutorial, "missing_step")).toThrow(/missing_step/);
    expect(() => getNextTutorialStepId(tutorial, "missing_step")).toThrow(/missing_step/);
  });

  it("reports completed progress for simple completion signals", () => {
    const viewModel = createTutorialStepViewModel(tutorial, "select_hero", { heroSelected: true });

    expect(viewModel.isComplete).toBe(true);
    expect(viewModel.progressLabel).toBe("Step 2 of 12: complete");
  });

  it("labels final-step advancement as tutorial completion", () => {
    const viewModel = createTutorialStepViewModel(tutorial, "finish_training", { finished: true });

    expect(viewModel.isFinalStep).toBe(true);
    expect(viewModel.advanceActionLabel).toBe("Complete Tutorial");
  });

  it("evaluates simple completion conditions by required action and references", () => {
    expect(isTutorialStepComplete(getTutorialStep(tutorial, "select_hero"), { heroSelected: true })).toBe(true);
    expect(isTutorialStepComplete(getTutorialStep(tutorial, "move_hero"), { heroMoved: true })).toBe(true);
    expect(isTutorialStepComplete(getTutorialStep(tutorial, "capture_crown_shrine"), { capturedSiteIds: ["crown_shrine"] })).toBe(true);
    expect(isTutorialStepComplete(getTutorialStep(tutorial, "gather_crowns"), { resourceAmounts: { crowns: 1 } })).toBe(true);
    expect(isTutorialStepComplete(getTutorialStep(tutorial, "build_barracks"), { completedBuildingIds: ["barracks"] })).toBe(true);
    expect(isTutorialStepComplete(getTutorialStep(tutorial, "train_militia"), { trainedUnitIds: ["militia"] })).toBe(true);
    expect(isTutorialStepComplete(getTutorialStep(tutorial, "set_barracks_rally"), { rallyBuildingIds: ["barracks"] })).toBe(true);
    expect(isTutorialStepComplete(getTutorialStep(tutorial, "use_rally_banner"), { usedAbilityIds: ["rally_banner"] })).toBe(true);
    expect(isTutorialStepComplete(getTutorialStep(tutorial, "hold_safe_pressure"), { defeatedUnitIds: ["raider"] })).toBe(true);
    expect(isTutorialStepComplete(getTutorialStep(tutorial, "finish_training"), { finished: true })).toBe(true);
  });

  it("keeps labels derived from ids readable without coupling tests to long copy", () => {
    expect(createCompletionConditionLabel(getTutorialStep(tutorial, "capture_crown_shrine"))).toBe("Capture Crown Shrine");
    expect(createCompletionConditionLabel(getTutorialStep(tutorial, "build_barracks"))).toBe("Build Barracks");
    expect(createCompletionConditionLabel(getTutorialStep(tutorial, "use_rally_banner"))).toBe("Use Rally Banner");
  });

  it("teaches the v0.19 production roles without adding tutorial steps", () => {
    expect(getTutorialStep(tutorial, "select_command_hall").instruction).toContain("trains Workers, not army units");
    expect(getTutorialStep(tutorial, "select_command_hall").hint).toContain("Command Hall -> Worker");
    expect(getTutorialStep(tutorial, "build_barracks").hint).toContain("Worker -> building");
    expect(getTutorialStep(tutorial, "train_militia").hint).toContain("Barracks -> army and upgrades");
    expect(getTutorialStep(tutorial, "train_militia").hint).toContain("Watchtower -> defense");
    expect(tutorial.steps).toHaveLength(12);
  });
});
