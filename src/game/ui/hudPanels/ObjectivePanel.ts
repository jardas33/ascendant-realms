import type { HUDObjectiveSnapshot } from "./HudTypes";
import { escapeHtml } from "./HudFormatting";

export function renderObjectives(objectives: HUDObjectiveSnapshot[] | undefined): string {
  if (!objectives || objectives.length === 0) {
    return "";
  }
  const completedCount = objectives.filter((objective) => objective.completed).length;
  return `
    <div class="objectives-panel" data-testid="battle-objectives">
      <strong>Objectives ${completedCount}/${objectives.length}</strong>
      ${objectives
        .map(
          (objective) => `
            <div class="objective-row ${objective.completed ? "completed" : ""}" data-objective-id="${escapeHtml(objective.id)}">
              <span>${objective.completed ? "Done" : "Open"}</span>
              <div>
                <b>${escapeHtml(objective.name)}</b>
                <small>${escapeHtml(objective.description)}</small>
              </div>
            </div>
          `
        )
        .join("")}
    </div>
  `;
}
