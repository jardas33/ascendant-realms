import type { LumeNetworkHudSummary } from "../../core/GameTypes";
import type { HUDBattlefieldEventSnapshot, HUDEnemyDoctrineSnapshot, HUDObjectiveSnapshot } from "./HudTypes";
import { escapeHtml } from "./HudFormatting";

export function renderObjectives(
  objectives: HUDObjectiveSnapshot[] | undefined,
  enemyDoctrine?: HUDEnemyDoctrineSnapshot,
  battlefieldEvent?: HUDBattlefieldEventSnapshot,
  lumeNetwork?: LumeNetworkHudSummary,
  privatePlaytestNotice?: string
): string {
  if ((!objectives || objectives.length === 0) && !enemyDoctrine && !battlefieldEvent && !lumeNetwork && !privatePlaytestNotice) {
    return "";
  }
  const missionObjectives = objectives ?? [];
  const completedCount = missionObjectives.filter((objective) => objective.completed).length;
  const nextObjectiveIndex = missionObjectives.findIndex((objective) => !objective.completed);
  const showLumeProgressOnly = Boolean(lumeNetwork && missionObjectives.length === 0);
  return `
    <div class="objectives-panel" data-testid="battle-objectives">
      ${privatePlaytestNotice ? renderPrivatePlaytestNotice(privatePlaytestNotice) : ""}
      ${battlefieldEvent ? renderBattlefieldEvent(battlefieldEvent) : ""}
      ${lumeNetwork ? renderLumeNetwork(lumeNetwork) : ""}
      ${enemyDoctrine ? renderEnemyDoctrine(enemyDoctrine) : ""}
      ${
        showLumeProgressOnly
          ? `<strong data-testid="lume-links-progress">${escapeHtml(lumeNetwork?.progressLabel ?? `LUME LINKS ${lumeNetwork?.activeLinkCount ?? 0}/${lumeNetwork?.maxActiveLinks ?? 0}`)}</strong>`
          : `<strong>Objectives ${completedCount}/${missionObjectives.length}</strong>`
      }
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

function renderPrivatePlaytestNotice(notice: string): string {
  return `
    <div class="private-playtest-row" data-testid="private-playtest-demo-warning">
      <span>Private</span>
      <div>
        <b>PRIVATE DEMO - rewards and campaign progress disabled</b>
        <details class="objective-details">
          <summary>Details</summary>
          <small>${escapeHtml(notice)}</small>
        </details>
      </div>
    </div>
  `;
}

function renderLumeNetwork(network: LumeNetworkHudSummary): string {
  return `
    <div class="lume-network-row" data-testid="lume-network-status">
      <span>Lume</span>
      <div>
        <b>${escapeHtml(network.title)}</b>
        <small class="lume-objective-line">${escapeHtml(network.objective)}</small>
        <small>${escapeHtml(network.status)}</small>
        ${
          network.optionalSiteName
            ? `<small class="lume-optional-line"><strong>OPTIONAL LINK</strong> Capture ${escapeHtml(network.optionalSiteName)}</small>`
            : ""
        }
        <details class="objective-details" data-testid="lume-network-details">
          <summary>Details</summary>
          <small>${escapeHtml(network.benefit)}</small>
          <small>Counterplay: ${escapeHtml(network.counterplay)}</small>
          ${network.detailsLabel ? `<small>${escapeHtml(network.detailsLabel)}</small>` : ""}
        </details>
        ${renderLumeFocusControls(network)}
        ${renderPrivateDemoActions(network)}
      </div>
    </div>
  `;
}

function renderLumeFocusControls(network: LumeNetworkHudSummary): string {
  const controls = network.focusControls ?? [];
  if (controls.length === 0) {
    return "";
  }
  return `
    <div class="lume-control-row" data-testid="lume-focus-controls">
      ${controls
        .map(
          (control) => `
            <button class="hud-button compact mini" type="button" data-testid="lume-focus-${escapeHtml(
              control.siteId
            )}" data-action="lume-focus" data-id="${escapeHtml(control.siteId)}">${escapeHtml(control.label)}</button>
          `
        )
        .join("")}
    </div>
  `;
}

function renderPrivateDemoActions(network: LumeNetworkHudSummary): string {
  if (!network.privateDemo) {
    return "";
  }
  return `
    <div class="lume-control-row private-demo-actions" data-testid="private-demo-actions">
      <button class="hud-button compact mini" type="button" data-testid="private-demo-exit" data-action="private-demo-exit">Exit Demo</button>
      ${
        network.finishDemoAvailable
          ? `<button class="hud-button compact mini" type="button" data-testid="private-demo-finish" data-action="private-demo-finish">Finish Demo &amp; View Results</button>`
          : ""
      }
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
