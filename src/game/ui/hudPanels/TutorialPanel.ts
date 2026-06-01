import type { TutorialStepViewModel } from "../../tutorial/TutorialStepModel";
import { escapeHtml } from "./HudFormatting";

export function renderTutorialPanel(step: TutorialStepViewModel | undefined): string {
  if (!step) {
    return "";
  }
  if (step.dismissed) {
    return `
    <section class="tutorial-panel tutorial-reopen-panel" data-testid="tutorial-overlay" aria-label="Tutorial guidance hidden" aria-live="polite">
      <button class="hud-button compact tutorial-primary" type="button" data-testid="tutorial-reopen" data-action="tutorial-reopen">Show Tutorial Help</button>
    </section>
  `;
  }
  const helpCopy = [step.hint, step.moreHelp, `Complete: ${step.completionConditionLabel}`].filter(Boolean);
  return `
    <section class="tutorial-panel" data-testid="tutorial-overlay" aria-label="Tutorial objective" aria-live="polite" aria-describedby="tutorial-instruction tutorial-condition" title="Drag empty panel space to move the objective box">
      <div class="tutorial-panel-header">
        <span class="tutorial-drag-handle" data-testid="tutorial-drag-handle">Proving Grounds</span>
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
        ${step.reason ? `<small class="tutorial-reason" data-testid="tutorial-reason">${escapeHtml(step.reason)}</small>` : ""}
        ${
          helpCopy.length > 0
            ? `<details class="tutorial-more-help" data-testid="tutorial-more-help">
                <summary>More Help</summary>
                ${helpCopy.map((copy) => `<p>${escapeHtml(copy ?? "")}</p>`).join("")}
              </details>`
            : ""
        }
        <div class="tutorial-panel-footer">
          <span data-testid="tutorial-condition" id="tutorial-condition">${escapeHtml(step.completionConditionLabel)}</span>
          ${
            step.focusTarget
              ? `<button class="hud-button compact tutorial-secondary" data-testid="tutorial-focus" data-action="tutorial-focus" aria-label="${escapeHtml(
                  step.focusTarget.label
                )}">${escapeHtml(step.focusTarget.label)}</button>`
              : ""
          }
          <button class="hud-button compact tutorial-secondary" data-testid="tutorial-dismiss" data-action="tutorial-dismiss" aria-label="Dismiss tutorial guidance">Dismiss</button>
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
