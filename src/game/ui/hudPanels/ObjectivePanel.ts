import type { HUDObjectiveSnapshot } from "./HudTypes";
import { escapeHtml } from "./HudFormatting";

export function renderObjectives(objectives: HUDObjectiveSnapshot[] | undefined): string {
  if (!objectives || objectives.length === 0) {
    return "";
  }
  const completedCount = objectives.filter((objective) => objective.completed).length;
  const nextObjectiveIndex = objectives.findIndex((objective) => !objective.completed);
  return `
    <div class="objectives-panel" data-testid="battle-objectives">
      <strong>Objectives ${completedCount}/${objectives.length}</strong>
      ${objectives
        .map((objective, index) => {
          const isNext = index === nextObjectiveIndex;
          const state = objective.completed ? "Done" : isNext ? "Next" : "Open";
          const classes = ["objective-row", objective.completed ? "completed" : "", isNext ? "current" : ""]
            .filter(Boolean)
            .join(" ");
          return `
            <div class="${classes}" data-objective-id="${escapeHtml(objective.id)}">
              <span>${state}</span>
              <div>
                <b>${escapeHtml(objective.name)}</b>
                <small>${escapeHtml(objective.description)}</small>
              </div>
            </div>
          `;
        })
        .join("")}
    </div>
  `;
}
