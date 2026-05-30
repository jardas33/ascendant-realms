import type { HUDBattlefieldEventSnapshot, HUDEnemyDoctrineSnapshot, HUDObjectiveSnapshot } from "./HudTypes";
import { escapeHtml } from "./HudFormatting";

export function renderObjectives(
  objectives: HUDObjectiveSnapshot[] | undefined,
  enemyDoctrine?: HUDEnemyDoctrineSnapshot,
  battlefieldEvent?: HUDBattlefieldEventSnapshot
): string {
  if ((!objectives || objectives.length === 0) && !enemyDoctrine && !battlefieldEvent) {
    return "";
  }
  const missionObjectives = objectives ?? [];
  const completedCount = missionObjectives.filter((objective) => objective.completed).length;
  const nextObjectiveIndex = missionObjectives.findIndex((objective) => !objective.completed);
  return `
    <div class="objectives-panel" data-testid="battle-objectives">
      ${battlefieldEvent ? renderBattlefieldEvent(battlefieldEvent) : ""}
      ${enemyDoctrine ? renderEnemyDoctrine(enemyDoctrine) : ""}
      <strong>Objectives ${completedCount}/${missionObjectives.length}</strong>
      ${missionObjectives
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

function renderBattlefieldEvent(event: HUDBattlefieldEventSnapshot): string {
  return `
    <div class="battlefield-event-row" data-testid="battlefield-event-status">
      <span>Event</span>
      <div>
        <b>${escapeHtml(event.title)}</b>
        <small>${escapeHtml(event.objective)} - ${escapeHtml(event.progress)}</small>
        <small>Counterplay: ${escapeHtml(event.counterplay)}</small>
        ${event.planMatched ? `<small>Plan support: active</small>` : ""}
      </div>
    </div>
  `;
}

function renderEnemyDoctrine(doctrine: HUDEnemyDoctrineSnapshot): string {
  return `
    <div class="enemy-doctrine-row" data-testid="enemy-doctrine-status">
      <span>Doctrine</span>
      <div>
        <b>${escapeHtml(doctrine.name)}</b>
        <small>${escapeHtml(doctrine.status)}</small>
        <small>${escapeHtml(doctrine.warning)}</small>
        <small>Counterplay: ${escapeHtml(doctrine.counterplay)}</small>
        ${doctrine.elite ? `<small>Elite: ${escapeHtml(doctrine.elite)}</small>` : ""}
      </div>
    </div>
  `;
}
