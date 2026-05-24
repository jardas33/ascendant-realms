import { Building } from "../../entities/Building";
import { Hero } from "../../entities/Hero";
import { Unit } from "../../entities/Unit";
import {
  BEHAVIOUR_MODE_DEFINITIONS,
  behaviourModeDefinition,
  summarizeBehaviourModes,
  type BehaviourMode
} from "../../systems/BehaviourModeSystem";
import {
  formatUnitVeterancyBonusSummary,
  formatUnitVeterancyXpProgress,
  getUnitVeterancyRank
} from "../../data/unitVeterancy";
import { describeUnitOrder, summarizeUnitOrders } from "../UnitOrderSummary";
import { escapeHtml, renderProgress, unitName, upgradeName } from "./HudFormatting";
import type { HUDSnapshot } from "./HudTypes";

type SelectedEntity = HUDSnapshot["selected"][number];

export function renderSelectionSummary(selectedOne: SelectedEntity | undefined, selected: SelectedEntity[]): string {
  if (!selectedOne) {
    if (selected.length > 1) {
      const selectedUnits = selected.filter((entity): entity is Unit => entity instanceof Unit);
      const productionBuildings = selected.filter(
        (entity): entity is Building => entity instanceof Building && entity.isCompleted() && entity.definition.trainOptions.length > 0
      );
      const hiddenCount = Math.max(0, selected.length - 12);
      return `<p class="selection-count"><strong>${selected.length} selected</strong><span>Commands apply to this group.</span></p>
      ${selectedUnits.length > 0 ? renderOrderSummary("Current Orders", summarizeUnitOrders(selectedUnits)) : ""}
      ${renderBehaviourControls(selectedUnits)}
      <div class="selection-grid">${selected
        .slice(0, 12)
        .map((entity) => `<span>${escapeHtml(entity.definition.name)}</span>`)
        .join("")}</div>${hiddenCount > 0 ? `<p class="quiet">+${hiddenCount} more selected.</p>` : ""}${
        productionBuildings.length > 0
          ? `<p class="quiet">Rally Point: ${productionBuildings.some((building) => building.rallyPoint) ? "Set" : "None"}. Right-click ground to set rally point.</p>`
          : ""
      }`;
    }
    return `<p class="quiet">Select your hero, troops, or buildings.</p>`;
  }

  if (selectedOne instanceof Hero) {
    const order = describeUnitOrder(selectedOne);
    return `
      ${renderOrderSummary(order.label, order.detail, order.tone)}
      ${renderBehaviourControls([selectedOne])}
      <div class="hero-command-summary">
        <span><strong>Damage</strong>${Math.round(selectedOne.damage)}</span>
        <span><strong>Range</strong>${selectedOne.range}</span>
        <span><strong>Armor</strong>${selectedOne.armor}</span>
      </div>
    `;
  }

  if (selectedOne instanceof Unit) {
    const order = describeUnitOrder(selectedOne);
    const rank = getUnitVeterancyRank(selectedOne.veterancy.rank);
    const xpProgress = formatUnitVeterancyXpProgress(selectedOne.veterancy.xp);
    const bonuses = formatUnitVeterancyBonusSummary(selectedOne.veterancy.rank);
    const retinueState = selectedOne.retinueUnitId ? "Deployed retinue veteran" : "Normal battle unit";
    return `
      ${renderOrderSummary(order.label, order.detail, order.tone)}
      ${renderBehaviourControls([selectedOne])}
      <div class="stat-list" data-testid="selected-unit-stats">
        <span>Rank ${escapeHtml(rank.name)}</span>
        <span>XP ${escapeHtml(xpProgress)}</span>
        <span>Kills ${selectedOne.veterancy.kills}</span>
        <span>Bonuses ${escapeHtml(bonuses)}</span>
        <span>Retinue ${escapeHtml(retinueState)}</span>
        <span>HP ${Math.ceil(selectedOne.hp)}/${selectedOne.maxHp}</span>
        <span>Damage ${Math.round(selectedOne.damage)}</span>
        <span>Range ${selectedOne.range}</span>
        <span>Armor ${selectedOne.armor}</span>
      </div>
    `;
  }

  const training = selectedOne.trainingQueue[0];
  const showRally = selectedOne.isCompleted() && selectedOne.definition.trainOptions.length > 0;
  return `
    <div class="stat-list">
      <span>HP ${Math.ceil(selectedOne.hp)}/${selectedOne.maxHp}</span>
      <span>Armor ${selectedOne.armor}</span>
      ${
        selectedOne.isUnderConstruction()
          ? `<span>Status ${escapeHtml(selectedOne.constructionStatusDetail ?? "Under construction")}</span>
             <span>Construction ${Math.round(selectedOne.constructionProgress * 100)}%</span>
             <span>Worker ${escapeHtml(selectedOne.assignedWorkerName ?? (selectedOne.assignedWorkerId ? "Assigned" : "Unassigned"))}</span>`
          : training
            ? `<span>Training ${escapeHtml(unitName(training.unitId))} ${Math.ceil(training.remaining)}s</span>`
            : "<span>Queue idle</span>"
      }
      ${
        selectedOne.upgradeQueue[0]
          ? `<span>Research ${escapeHtml(upgradeName(selectedOne.upgradeQueue[0].upgradeId))}</span>`
          : "<span>Research idle</span>"
      }
      ${showRally ? `<span>Rally Point: ${selectedOne.rallyPoint ? "Set" : "None"}</span>` : ""}
    </div>
    ${showRally ? `<p class="quiet">Right-click ground to set rally point.</p>` : ""}
    ${selectedOne.isUnderConstruction() ? renderProgress("Construction", selectedOne.constructionProgress) : ""}
    ${renderProductionQueue(selectedOne)}
    ${renderUpgradeQueue(selectedOne)}
  `;
}

function renderBehaviourControls(units: Unit[]): string {
  if (units.length === 0) {
    return "";
  }

  const summary = summarizeBehaviourModes(units);
  const currentDetail = summary.mode
    ? behaviourModeDefinition(summary.mode).description
    : "Selected units use different behaviour modes.";

  return `
    <div class="behaviour-mode-panel" data-testid="behaviour-mode-panel">
      <div class="behaviour-mode-header">
        <strong>Behaviour</strong>
        <span data-testid="behaviour-mode-current" title="${escapeHtml(currentDetail)}">${escapeHtml(summary.label)}</span>
      </div>
      <div class="behaviour-mode-buttons">
        ${BEHAVIOUR_MODE_DEFINITIONS.map((definition) => renderBehaviourModeButton(definition.id, summary.mode)).join("")}
      </div>
    </div>
  `;
}

function renderBehaviourModeButton(mode: BehaviourMode, currentMode?: BehaviourMode): string {
  const definition = behaviourModeDefinition(mode);
  const active = currentMode === mode;
  return `
    <button
      class="hud-button compact mini behaviour-mode-button ${active ? "active" : ""}"
      data-testid="behaviour-mode-${definition.id}"
      data-action="behaviour-mode"
      data-id="${definition.id}"
      aria-label="Set behaviour mode to ${escapeHtml(definition.label)}. ${escapeHtml(definition.description)}"
      aria-pressed="${active ? "true" : "false"}"
      title="${escapeHtml(definition.description)}"
    >${escapeHtml(definition.shortLabel)}</button>
  `;
}

function renderOrderSummary(label: string, detail: string, tone: "active" | "neutral" = "neutral"): string {
  return `
    <div class="order-summary ${tone}" data-testid="unit-order-summary">
      <strong>${escapeHtml(label)}</strong>
      <span>${escapeHtml(detail)}</span>
    </div>
  `;
}

function renderProductionQueue(building: Building): string {
  if (building.trainingQueue.length === 0) {
    return "";
  }
  return `
    <div class="queue-list">
      <strong>Training Queue</strong>
      ${building.trainingQueue
        .map((item, index) => {
          const progress = item.total > 0 ? 1 - item.remaining / item.total : 1;
          return `
            <div class="queue-row">
              <div>
                <span>${escapeHtml(unitName(item.unitId))}</span>
                ${renderProgress("", progress)}
              </div>
              <button class="hud-button compact mini" data-action="cancel-train" data-source-id="${building.id}" data-index="${index}">Cancel</button>
            </div>
          `;
        })
        .join("")}
    </div>
  `;
}

function renderUpgradeQueue(building: Building): string {
  if (building.upgradeQueue.length === 0) {
    return "";
  }
  return `
    <div class="queue-list">
      <strong>Research Queue</strong>
      ${building.upgradeQueue
        .map((item, index) => {
          const progress = item.total > 0 ? 1 - item.remaining / item.total : 1;
          return `
            <div class="queue-row">
              <div>
                <span>${escapeHtml(upgradeName(item.upgradeId))}</span>
                ${renderProgress("", progress)}
              </div>
              <button class="hud-button compact mini" data-action="cancel-upgrade" data-source-id="${building.id}" data-index="${index}">Cancel</button>
            </div>
          `;
        })
        .join("")}
    </div>
  `;
}
