import type { TutorialStepViewModel } from "../../tutorial/TutorialStepModel";
import { escapeHtml } from "./HudFormatting";

export function renderTutorialPanel(step: TutorialStepViewModel | undefined): string {
  if (!step) {
    return "";
  }
  return `
    <section class="tutorial-panel" data-testid="tutorial-overlay" aria-label="Tutorial objective">
      <div class="tutorial-panel-header">
        <span>Proving Grounds</span>
        <b data-testid="tutorial-progress">${escapeHtml(step.progressLabel)}</b>
      </div>
      <strong data-testid="tutorial-objective">${escapeHtml(step.title)}</strong>
      <p data-testid="tutorial-instruction">${escapeHtml(step.instruction)}</p>
      ${step.hint ? `<small data-testid="tutorial-hint">${escapeHtml(step.hint)}</small>` : ""}
      <div class="tutorial-panel-footer">
        <span data-testid="tutorial-condition">${escapeHtml(step.completionConditionLabel)}</span>
        <button class="hud-button compact" data-testid="tutorial-exit" data-action="menu">Exit Tutorial</button>
      </div>
    </section>
  `;
}
