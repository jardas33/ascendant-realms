import { Building } from "../../entities/Building";
import { CaptureSite } from "../../entities/CaptureSite";
import { Hero } from "../../entities/Hero";
import { Unit } from "../../entities/Unit";
import {
  BEHAVIOUR_MODE_DEFINITIONS,
  behaviourModeDefinition,
  summarizeBehaviourModes,
  type BehaviourMode
} from "../../systems/BehaviourModeSystem";
import {
  RESOURCE_SITE_MAX_LEVEL,
  resourceSiteIncomeBreakdown,
  resourceSiteWorkerSlotCapacity,
  workerSiteBonusAmount
} from "../../systems/ResourceSystem";
import {
  formatUnitVeterancyBonusSummary,
  formatUnitVeterancyXpProgress,
  getUnitVeterancyRank
} from "../../data/unitVeterancy";
import {
  HERO_ROLE_IDENTITY,
  formatUnitRoleTags,
  getUnitRoleIdentity,
  summarizeUnitRoleMix,
  type UnitRoleIdentity
} from "../../data/unitRoles";
import { describeUnitOrder, summarizeUnitOrders } from "../UnitOrderSummary";
import { escapeHtml, formatBuildingRole, formatBuildingUnlockSummary, renderProgress, unitName, upgradeName } from "./HudFormatting";
import type { HUDSnapshot } from "./HudTypes";
import type { ControlGroupSummary } from "../../systems/ControlGroupSystem";

type SelectedEntity = HUDSnapshot["selected"][number];

export function renderSelectionSummary(
  selectedOne: SelectedEntity | undefined,
  selected: SelectedEntity[],
  controlGroups: ControlGroupSummary[] = [],
  lumeSiteSummaries: NonNullable<HUDSnapshot["lumeSiteSummaries"]> = {}
): string {
  const controlGroupSummary = renderControlGroupSummary(controlGroups);
  if (!selectedOne) {
    if (selected.length > 1) {
      const selectedUnits = selected.filter((entity): entity is Unit => entity instanceof Unit && entity.team === "player");
      const productionBuildings = selected.filter(
        (entity): entity is Building => entity instanceof Building && entity.isCompleted() && entity.definition.trainOptions.length > 0
      );
      const hiddenCount = Math.max(0, selected.length - 12);
      return `${renderSelectionFocus("Squad selected", `${selected.length} friendly selections`, "Orders apply to the player units in this group.", "player")}
      <p class="selection-count"><strong>${selected.length} selected</strong><span>Commands apply to this group.</span></p>
      ${selectedUnits.length > 0 ? renderOrderSummary("Current Orders", summarizeUnitOrders(selectedUnits)) : ""}
      ${selectedUnits.length > 0 ? renderGroupRoleSummary(selectedUnits) : ""}
      ${controlGroupSummary}
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
    return `${controlGroupSummary}<p class="quiet">Select your hero, troops, or buildings.</p>`;
  }

  if (selectedOne instanceof Hero) {
    const order = describeUnitOrder(selectedOne);
    return `
      ${renderSelectionFocus("Hero selected", "Champion / commander", "Hero abilities and build identity are active from this selection.", "hero")}
      ${renderOrderSummary(order.label, order.detail, order.tone)}
      ${renderRoleIdentitySummary(HERO_ROLE_IDENTITY)}
      ${controlGroupSummary}
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
    const roleIdentity = getUnitRoleIdentity(selectedOne.definition.id);
    const retinueState = selectedOne.retinueUnitId ? "Deployed retinue veteran" : "Battle-only unit";
    const eliteState = selectedOne.enemyEliteSquadId
      ? `<span>Elite ${escapeHtml(selectedOne.enemyEliteSquadName ?? selectedOne.enemyEliteSquadLabel ?? "Enemy squad")}</span>
        <span>Elite bonus ${escapeHtml(selectedOne.enemyEliteBonusSummary ?? "Modest enemy bonus")}</span>
        <span>Counterplay ${escapeHtml(selectedOne.enemyEliteCounterplay ?? "Focus fire with a grouped army.")}</span>`
      : "";
    const isWorker = selectedOne.definition.id === "worker";
    const focusTitle = selectedOne.team === "enemy" ? "Enemy inspected" : isWorker ? "Worker selected" : "Unit selected";
    const focusTone = selectedOne.team === "enemy" ? "enemy" : isWorker ? "worker" : "player";
    const focusDetail =
      selectedOne.team === "enemy"
        ? "Read-only target information. Select your army, then right-click to attack."
        : isWorker
          ? "Utility unit. Build, repair, capture support, and site assignment are available when valid."
          : "Combat unit. Move, attack, Patrol, and behaviour commands are available.";
    return `
      ${renderSelectionFocus(focusTitle, selectedOne.definition.name, focusDetail, focusTone)}
      ${renderOrderSummary(order.label, order.detail, order.tone)}
      ${renderRoleIdentitySummary(roleIdentity)}
      ${controlGroupSummary}
      ${selectedOne.team === "player" ? renderBehaviourControls([selectedOne]) : ""}
      <div class="stat-list" data-testid="selected-unit-stats">
        <span>Role ${escapeHtml(roleIdentity.label)}</span>
        <span>Tags ${escapeHtml(formatUnitRoleTags(roleIdentity))}</span>
        <span>Rank ${escapeHtml(rank.name)}</span>
        <span>XP ${escapeHtml(xpProgress)}</span>
        <span>Kills ${selectedOne.veterancy.kills}</span>
        <span>Bonuses ${escapeHtml(bonuses)}</span>
        <span>Veterancy ${escapeHtml(retinueState)}</span>
        ${eliteState}
        <span>HP ${Math.ceil(selectedOne.hp)}/${selectedOne.maxHp}</span>
        <span>Damage ${Math.round(selectedOne.damage)}</span>
        <span>Range ${selectedOne.range}</span>
        <span>Armor ${selectedOne.armor}</span>
      </div>
    `;
  }

  if (selectedOne instanceof CaptureSite) {
    const lumeSummary = lumeSiteSummaries[selectedOne.definition.id];
    const breakdown = resourceSiteIncomeBreakdown(selectedOne);
    const workerSlotCapacity = resourceSiteWorkerSlotCapacity(selectedOne);
    const abstractEnemySlots = selectedOne.owner === "enemy" ? selectedOne.abstractEnemyWorkerSlots : 0;
    const workerSlotsUsed = selectedOne.owner === "enemy" ? abstractEnemySlots : selectedOne.workerAssignments.length;
    const slotNames =
      selectedOne.workerAssignments.map((assignment) => assignment.workerName).join(", ") ||
      (abstractEnemySlots > 0 ? `Enemy logistics ${abstractEnemySlots}` : "Empty");
    const ownerLabel =
      selectedOne.owner === "player" ? "Friendly captured" : selectedOne.owner === "enemy" ? "Enemy controlled" : "Neutral";
    const assignmentInstruction = siteAssignmentInstruction(selectedOne);
    const status = siteStatusDetail(selectedOne, assignmentInstruction);
    return `
      ${renderSelectionFocus("Site selected", selectedOne.definition.name, assignmentInstruction, selectedOne.owner === "enemy" ? "enemy" : selectedOne.owner === "player" ? "player" : "neutral")}
      <div class="stat-list" data-testid="selected-resource-site-stats">
        <span>Control ${escapeHtml(ownerLabel)}</span>
        <span>Level ${selectedOne.siteLevel}/${RESOURCE_SITE_MAX_LEVEL}</span>
        <span>Resource ${escapeHtml(selectedOne.definition.resource)}</span>
        <span>Base income +${selectedOne.definition.incomeAmount}/${selectedOne.definition.incomeInterval}s</span>
        <span>Upgrade bonus +${breakdown.upgradeBonusAmount}/${selectedOne.definition.incomeInterval}s</span>
        <span>Worker slots ${workerSlotsUsed}/${workerSlotCapacity}</span>
        <span>Assigned ${escapeHtml(slotNames)}</span>
        <span>Worker bonus +${breakdown.workerBonusAmount}/${selectedOne.definition.incomeInterval}s (${workerSiteBonusAmount(selectedOne)} each)</span>
        <span>Total income +${breakdown.totalAmount}/${selectedOne.definition.incomeInterval}s</span>
        <span>Status ${escapeHtml(status)}</span>
      </div>
      ${lumeSummary ? renderLumeSiteSummary(lumeSummary) : ""}
      <p class="quiet">${escapeHtml(assignmentInstruction)}</p>
    `;
  }

  const training = selectedOne.trainingQueue[0];
  const research = selectedOne.upgradeQueue[0];
  const hasTrainingActions = selectedOne.definition.trainOptions.length > 0;
  const hasResearchActions = selectedOne.definition.upgradeOptions.length > 0;
  const showRally = selectedOne.isCompleted() && selectedOne.definition.trainOptions.length > 0;
  return `
    ${renderSelectionFocus(selectedOne.team === "enemy" ? "Enemy building inspected" : "Building selected", selectedOne.definition.name, selectedOne.team === "enemy" ? "Read-only structure information. Attack with selected forces." : "Building actions and rally state appear in the command tray.", selectedOne.team === "enemy" ? "enemy" : "building")}
    <div class="stat-list">
      <span>HP ${Math.ceil(selectedOne.hp)}/${selectedOne.maxHp}</span>
      <span>Armor ${selectedOne.armor}</span>
      <span>Role ${escapeHtml(formatBuildingRole(selectedOne.definition))}</span>
      ${
        selectedOne.isCompleted() && selectedOne.team === "player"
          ? `<span>Repair ${
              selectedOne.hp < selectedOne.maxHp
                ? "Damaged - select a Worker and use Repair/right-click"
                : "Full health"
            }</span>`
          : ""
      }
      ${
        selectedOne.isUnderConstruction()
          ? `<span>Status ${escapeHtml(selectedOne.constructionStatusDetail ?? "Under construction")}</span>
             <span>Construction ${Math.round(selectedOne.constructionProgress * 100)}%</span>
             <span>Assigned ${escapeHtml(selectedOne.assignedWorkerName ?? (selectedOne.assignedWorkerId ? "Worker" : "Unassigned"))}</span>
             <span>Continue: select Worker and right-click site</span>
             <span>${escapeHtml(formatBuildingUnlockSummary(selectedOne.definition))}</span>`
          : training
            ? `<span>Training ${escapeHtml(unitName(training.unitId))} ${Math.ceil(training.remaining)}s</span>`
            : hasTrainingActions
              ? "<span>Queue idle</span>"
              : selectedOne.definition.attack
                ? "<span>Defense ready</span>"
                : "<span>No production queue</span>"
      }
      ${
        selectedOne.isUnderConstruction()
          ? ""
          : research
            ? `<span>Research ${escapeHtml(upgradeName(research.upgradeId))}</span>`
            : hasResearchActions
              ? "<span>Research idle</span>"
              : ""
      }
      ${showRally ? `<span>Rally Point: ${selectedOne.rallyPoint ? "Set" : "None"}</span>` : ""}
    </div>
    ${showRally ? `<p class="quiet">Right-click ground to set rally point.</p>` : ""}
    ${selectedOne.isUnderConstruction() ? renderProgress("Construction", selectedOne.constructionProgress) : ""}
    ${renderProductionQueue(selectedOne)}
    ${renderUpgradeQueue(selectedOne)}
  `;
}

function renderLumeSiteSummary(summary: NonNullable<HUDSnapshot["lumeSiteSummaries"]>[string]): string {
  const stateLabel = summary.state.charAt(0).toUpperCase() + summary.state.slice(1);
  return `
    <div class="role-identity-summary lume-site-summary" data-testid="selected-lume-site-summary">
      <strong>${escapeHtml(summary.title)}: ${escapeHtml(stateLabel)}</strong>
      <span>Linked to ${escapeHtml(summary.linkedSites)}</span>
      <small>${escapeHtml(summary.benefit)}</small>
      <small>${escapeHtml(summary.counterplay)}</small>
    </div>
  `;
}

function renderControlGroupSummary(groups: ControlGroupSummary[]): string {
  if (groups.length === 0) {
    return "";
  }

  return `
    <div class="control-group-summary" data-testid="control-group-summary">
      <strong>Control Groups</strong>
      <span>${groups.map((group) => `${group.slot}:${group.count}`).join(" ")}</span>
      <small>Ctrl+1-5 assigns; 1-5 recalls.</small>
    </div>
  `;
}

function renderSelectionFocus(
  title: string,
  detail: string,
  hint: string,
  tone: "player" | "hero" | "worker" | "building" | "enemy" | "neutral"
): string {
  return `
    <div class="selection-focus ${tone}" data-testid="selection-focus-summary">
      <strong>${escapeHtml(title)}</strong>
      <span>${escapeHtml(detail)}</span>
      <small>${escapeHtml(hint)}</small>
    </div>
  `;
}

function renderRoleIdentitySummary(identity: UnitRoleIdentity): string {
  return `
    <div class="role-identity-summary" data-testid="selected-role-summary">
      <strong>${escapeHtml(identity.label)}</strong>
      <span>${escapeHtml(identity.summary)}</span>
      <small>${escapeHtml(identity.tacticalHint)}</small>
    </div>
  `;
}

function renderGroupRoleSummary(units: Unit[]): string {
  const veteranCount = units.filter((unit) => unit.veterancy?.rank && unit.veterancy.rank !== "recruit").length;
  const veteranLine =
    veteranCount > 0
      ? `${veteranCount} ranked unit${veteranCount === 1 ? "" : "s"} selected; control groups and Patrol preserve rank state.`
      : "No ranked units selected yet; units gain battle XP from combat contribution.";
  return `
    <div class="role-identity-summary group-role-summary" data-testid="selected-role-summary">
      <strong>Army Roles</strong>
      <span>${escapeHtml(summarizeUnitRoleMix(units))}</span>
      <small>${escapeHtml(veteranLine)}</small>
    </div>
  `;
}

function siteAssignmentInstruction(site: CaptureSite): string {
  if (site.owner !== "player") {
    return "Capture this site before assigning a Worker.";
  }
  if (site.workerAssignments.length >= resourceSiteWorkerSlotCapacity(site)) {
    return "Move, attack, build, repair, or assign the Worker elsewhere to stop this boost.";
  }
  return "Select a Worker and right-click this captured site, or use the Worker Resource Sites command.";
}

function siteStatusDetail(site: CaptureSite, fallbackInstruction: string): string {
  if (site.captureProgress > 0 && site.capturingTeam !== "neutral") {
    const teamLabel = site.capturingTeam === "player" ? "Player" : "Enemy";
    return `${teamLabel} contesting ${Math.round(site.captureProgress * 100)}%`;
  }
  if (site.owner === "player") {
    return site.workerAssignmentStatusDetail;
  }
  if (site.owner === "enemy" && site.abstractEnemyWorkerSlots > 0) {
    return `Enemy abstract logistics ${site.abstractEnemyWorkerSlots}/${resourceSiteWorkerSlotCapacity(site)} boosting`;
  }
  return fallbackInstruction;
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
