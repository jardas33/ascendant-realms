import type { TutorialStepViewModel } from "../../tutorial/TutorialStepModel";
import { escapeHtml } from "./HudFormatting";

export function renderTutorialPanel(step: TutorialStepViewModel | undefined): string {
  if (!step) {
    return "";
  }
  return `
    <section class="tutorial-panel" data-testid="tutorial-overlay" aria-label="Tutorial objective" aria-live="polite" aria-describedby="tutorial-instruction tutorial-condition">
      <div class="tutorial-panel-header">
        <span class="tutorial-drag-handle" data-testid="tutorial-drag-handle" title="Drag tutorial objective panel">Proving Grounds</span>
        <b data-testid="tutorial-progress">${escapeHtml(step.progressLabel)}</b>
        <div class="tutorial-panel-controls" aria-label="Tutorial panel controls">
          <button class="hud-button compact mini tutorial-panel-control" type="button" data-testid="tutorial-minimize" data-action="tutorial-minimize" aria-expanded="true" aria-label="Hide or show tutorial objective panel">
            <span class="tutorial-minimize-expanded">Hide</span>
            <span class="tutorial-minimize-collapsed">Show</span>
          </button>
          <button class="hud-button compact mini tutorial-panel-control" type="button" data-testid="tutorial-reset" data-action="tutorial-reset" aria-label="Reset tutorial objective panel position">Reset</button>
        </div>
      </div>
      <div class="tutorial-panel-body" data-testid="tutorial-panel-body">
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
          <button class="hud-button compact tutorial-secondary" data-testid="tutorial-exit" data-action="exit-menu" aria-label="Exit Tutorial and return to main menu">Exit Tutorial</button>
        </div>
      </div>
    </section>
  `;
}
