import type { TutorialStepViewModel } from "../../tutorial/TutorialStepModel";
import { escapeHtml } from "./HudFormatting";

export function renderTutorialPanel(step: TutorialStepViewModel | undefined): string {
  if (!step) {
    return "";
  }
  return `
    <section class="tutorial-panel" data-testid="tutorial-overlay" aria-label="Tutorial objective" aria-live="polite" aria-describedby="tutorial-instruction tutorial-condition">
      <div class="tutorial-panel-header">
        <span>Proving Grounds</span>
        <b data-testid="tutorial-progress">${escapeHtml(step.progressLabel)}</b>
      </div>
      <strong data-testid="tutorial-objective" id="tutorial-objective-title">${escapeHtml(step.title)}</strong>
      <p data-testid="tutorial-instruction" id="tutorial-instruction">${escapeHtml(step.instruction)}</p>
      ${step.hint ? `<small data-testid="tutorial-hint">${escapeHtml(step.hint)}</small>` : ""}
      <div class="tutorial-panel-footer">
        <span data-testid="tutorial-condition" id="tutorial-condition">${escapeHtml(step.completionConditionLabel)}</span>
        ${
          step.isComplete
            ? `<button class="hud-button compact tutorial-primary" data-testid="tutorial-next" data-action="tutorial-next" aria-label="${escapeHtml(
                `${step.advanceActionLabel} from ${step.title}`
              )}">${escapeHtml(
                step.advanceActionLabel
              )}</button>`
            : ""
        }
        <button class="hud-button compact tutorial-secondary" data-testid="tutorial-exit" data-action="menu" aria-label="Exit Tutorial and return to main menu">Exit Tutorial</button>
      </div>
    </section>
  `;
}
