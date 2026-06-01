import type { LumeNetworkHudSummary } from "../../core/GameTypes";
import type { HUDBattlefieldEventSnapshot, HUDEnemyDoctrineSnapshot, HUDObjectiveSnapshot } from "./HudTypes";
import { escapeHtml } from "./HudFormatting";

export function renderObjectives(
  objectives: HUDObjectiveSnapshot[] | undefined,
  enemyDoctrine?: HUDEnemyDoctrineSnapshot,
  battlefieldEvent?: HUDBattlefieldEventSnapshot,
  lumeNetwork?: LumeNetworkHudSummary,
  privatePlaytestNotice?: string,
  privatePlaytestHub = false
): string {
  if ((!objectives || objectives.length === 0) && !enemyDoctrine && !battlefieldEvent && !lumeNetwork && !privatePlaytestNotice) {
    return "";
  }
  const missionObjectives = objectives ?? [];
  const completedCount = missionObjectives.filter((objective) => objective.completed).length;
  const nextObjectiveIndex = missionObjectives.findIndex((objective) => !objective.completed);
  const showLumeProgressOnly = Boolean(lumeNetwork && missionObjectives.length === 0);
  const showMissionSummary = missionObjectives.length > 0;
  return `
    <div class="objectives-panel" data-testid="battle-objectives">
      ${privatePlaytestNotice ? renderPrivatePlaytestNotice(privatePlaytestNotice, privatePlaytestHub) : ""}
      ${battlefieldEvent ? renderBattlefieldEvent(battlefieldEvent) : ""}
      ${lumeNetwork ? renderLumeNetwork(lumeNetwork) : ""}
      ${enemyDoctrine ? renderEnemyDoctrine(enemyDoctrine) : ""}
      ${
        showMissionSummary
          ? `<strong>Objectives ${completedCount}/${missionObjectives.length}</strong>`
          : showLumeProgressOnly
          ? `<strong data-testid="lume-links-progress">${escapeHtml(lumeNetwork?.progressLabel ?? `LUME LINKS ${lumeNetwork?.activeLinkCount ?? 0}/${lumeNetwork?.maxActiveLinks ?? 0}`)}</strong>`
          : ""
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

function renderPrivatePlaytestNotice(notice: string, privatePlaytestHub: boolean): string {
  return `
    <div class="private-playtest-row" data-testid="private-playtest-demo-warning">
      <span>Private</span>
      <div>
        <b>${privatePlaytestHub ? "PLAYTEST HUB - no save changes" : "PRIVATE DEMO - rewards and campaign progress disabled"}</b>
        <details class="objective-details">
          <summary>Details</summary>
          <small>${escapeHtml(notice)}</small>
        </details>
        ${
          privatePlaytestHub
            ? `<button class="hud-button compact mini" type="button" data-testid="private-hub-exit" data-action="private-demo-exit">Return to Hub</button>`
            : ""
        }
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
        ${renderLumeVisibilityControls(network)}
        ${renderLumeFocusControls(network)}
        ${renderPrivateDemoActions(network)}
      </div>
    </div>
  `;
}

function renderLumeVisibilityControls(network: LumeNetworkHudSummary): string {
  const controls = network.visibilityControls ?? [];
  if (controls.length === 0) {
    return "";
  }
  return `
    <div class="lume-visibility-row" data-testid="lume-visibility-controls" aria-label="Lume link visibility">
      <span>Links: <strong>${escapeHtml(network.visibilityLabel ?? "Auto")}</strong></span>
      <div>
        ${controls
          .map(
            (control) => `
              <button class="hud-button compact mini${control.active ? " active" : ""}" type="button" data-testid="lume-visibility-${
                control.mode
              }" data-action="lume-visibility" data-id="${control.mode}" aria-pressed="${control.active ? "true" : "false"}" title="${escapeHtml(
                control.description
              )}">${escapeHtml(control.label)}</button>
            `
          )
          .join("")}
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
    <div class="battlefield-event-row compact-tracker-row" data-testid="battlefield-event-status">
      <span>Event</span>
      <div>
        <b>${escapeHtml(event.title)}</b>
        <small>${escapeHtml(event.objective)}</small>
        <small>${escapeHtml(event.progress)}</small>
        <details class="objective-details">
          <summary>Details</summary>
          <small>Counterplay: ${escapeHtml(event.counterplay)}</small>
          ${event.planMatched ? `<small>Plan support: active</small>` : ""}
        </details>
      </div>
    </div>
  `;
}

function renderEnemyDoctrine(doctrine: HUDEnemyDoctrineSnapshot): string {
  return `
    <div class="enemy-doctrine-row compact-tracker-row" data-testid="enemy-doctrine-status">
      <span>Doctrine</span>
      <div>
        <b>${escapeHtml(doctrine.name)}</b>
        <small>${escapeHtml(doctrine.status)}</small>
        <small>${escapeHtml(doctrine.warning)}</small>
        <details class="objective-details">
          <summary>Counterplay</summary>
          <small>${escapeHtml(doctrine.counterplay)}</small>
          ${doctrine.elite ? `<small>Elite: ${escapeHtml(doctrine.elite)}</small>` : ""}
        </details>
      </div>
    </div>
  `;
}
