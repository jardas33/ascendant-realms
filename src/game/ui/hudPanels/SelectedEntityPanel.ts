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
  resourceSiteWorkerSlotCapacity
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
import type { HUDSnapshot, HudDensityMode } from "./HudTypes";
import type { ControlGroupSummary } from "../../systems/ControlGroupSystem";

type SelectedEntity = HUDSnapshot["selected"][number];

export function renderSelectionSummary(
  selectedOne: SelectedEntity | undefined,
  selected: SelectedEntity[],
  controlGroups: ControlGroupSummary[] = [],
  lumeSiteSummaries: NonNullable<HUDSnapshot["lumeSiteSummaries"]> = {},
  density: HudDensityMode = "standard"
): string {
  const controlGroupSummary = renderControlGroupSummary(controlGroups, density);
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
      ${renderRoleIdentitySummary(HERO_ROLE_IDENTITY, density)}
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
        <span class="${density === "minimal" ? "density-optional" : ""}">Elite bonus ${escapeHtml(selectedOne.enemyEliteBonusSummary ?? "Modest enemy bonus")}</span>
        <span class="${density === "minimal" ? "density-optional" : ""}">Counterplay ${escapeHtml(selectedOne.enemyEliteCounterplay ?? "Focus fire with a grouped army.")}</span>`
      : "";
    const isWorker = selectedOne.definition.id === "worker";
    const resourceAssignment = isWorker && selectedOne.team === "player" ? renderWorkerResourceAssignment(selectedOne) : "";
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
      ${renderRoleIdentitySummary(roleIdentity, density)}
      ${resourceAssignment}
      ${controlGroupSummary}
      ${selectedOne.team === "player" ? renderBehaviourControls([selectedOne]) : ""}
      <div class="stat-list" data-testid="selected-unit-stats">
        <span>Role ${escapeHtml(roleIdentity.label)}</span>
        <span class="density-optional">Tags ${escapeHtml(formatUnitRoleTags(roleIdentity))}</span>
        <span>Rank ${escapeHtml(rank.name)}</span>
        <span class="density-optional">XP ${escapeHtml(xpProgress)}</span>
        <span class="density-optional">Kills ${selectedOne.veterancy.kills}</span>
        <span class="density-optional">Bonuses ${escapeHtml(bonuses)}</span>
        <span class="density-optional">Veterancy ${escapeHtml(retinueState)}</span>
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
    const ownershipTone = selectedOne.owner === "enemy" ? "enemy" : selectedOne.owner === "player" ? "player" : "neutral";
    const resourceLabel = selectedOne.definition.resource.charAt(0).toUpperCase() + selectedOne.definition.resource.slice(1);
    const isPlayerOwned = selectedOne.owner === "player";
    const upgradeSummary = isPlayerOwned
      ? selectedOne.siteLevel >= RESOURCE_SITE_MAX_LEVEL
        ? "Improved · maximum level reached"
        : "Available · Level 2 adds income and a second Worker slot"
      : selectedOne.owner === "enemy"
        ? "Locked · capture this site before upgrading"
        : "Locked · capture this site before upgrading";
    return `
      ${renderSelectionFocus("Resource site selected", selectedOne.definition.name, assignmentInstruction, ownershipTone)}
      <section class="resource-site-summary" data-testid="selected-resource-site-summary" aria-label="Resource site details">
        <div class="resource-site-heading">
          <strong>Resource site</strong>
          <span>${escapeHtml(resourceLabel)}</span>
        </div>
        <div class="resource-site-metrics" data-testid="selected-resource-site-stats">
          <span>Owner ${escapeHtml(ownerLabel)}</span>
          <span>Level ${selectedOne.siteLevel}/${RESOURCE_SITE_MAX_LEVEL}</span>
          <span>Income every ${selectedOne.definition.incomeInterval}s</span>
          <span>Workers ${workerSlotsUsed}/${workerSlotCapacity}</span>
        </div>
        <div class="resource-site-income" data-testid="resource-site-income-summary">
          <strong>${isPlayerOwned ? `Current ${resourceLabel} income` : `${escapeHtml(ownerLabel)} income`}</strong>
          ${
            isPlayerOwned
              ? `<span>Base +${breakdown.baseAmount} · Upgrade +${breakdown.upgradeBonusAmount} · Workers +${breakdown.workerBonusAmount}</span>
                 <span>Total +${breakdown.totalAmount} ${escapeHtml(resourceLabel)} every ${selectedOne.definition.incomeInterval}s</span>`
              : `<span>Player income inactive until this site is captured.</span>`
          }
        </div>
        <div class="resource-site-workers" data-testid="resource-site-worker-summary">
          <strong>Worker assignment</strong>
          <span>Assigned: ${escapeHtml(slotNames)}</span>
          <small>Status: ${escapeHtml(status)}</small>
        </div>
        <div class="resource-site-upgrade" data-testid="resource-site-upgrade-summary">
          <strong>Upgrade</strong>
          <span>${escapeHtml(upgradeSummary)}</span>
          ${isPlayerOwned && selectedOne.siteLevel < RESOURCE_SITE_MAX_LEVEL ? "<small>Effect: adds upgrade income and one additional Worker slot.</small>" : ""}
        </div>
      </section>
      ${lumeSummary ? renderLumeSiteSummary(lumeSummary) : ""}
      <p class="quiet resource-site-next-action">${escapeHtml(assignmentInstruction)}</p>
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
          ? `${renderConstructionSummary(selectedOne)}
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
    ${renderProductionQueue(selectedOne)}
    ${renderUpgradeQueue(selectedOne)}
  `;
}

function renderConstructionSummary(building: Building): string {
  const presentation = constructionPresentation(building);
  const progressPercent = constructionProgressPercent(building.constructionProgress);
  const workerLabel = building.assignedWorkerName ?? (building.assignedWorkerId ? "Worker" : "Unassigned");
  return `
    <div class="construction-summary construction-state-${presentation.stateClass}" data-testid="construction-status" role="group" aria-label="Construction status: ${escapeHtml(presentation.stateLabel)}">
      <div class="construction-summary-header">
        <strong>Construction status</strong>
        <span>${escapeHtml(presentation.stateLabel)}</span>
      </div>
      <div class="construction-summary-grid">
        <span>Status ${escapeHtml(presentation.stateLabel)}</span>
        <span>Construction ${progressPercent}%</span>
        <span>Worker ${escapeHtml(workerLabel)}</span>
      </div>
      <div class="progress-line construction-summary-progress" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="${progressPercent}" aria-label="Construction progress ${progressPercent}%">
        <span>Progress</span>
        <div class="progress-strip"><i style="width:${progressPercent}%"></i></div>
      </div>
      <small class="construction-summary-detail">${escapeHtml(presentation.detail)}</small>
      <small class="construction-summary-action">${escapeHtml(presentation.action)}</small>
    </div>
  `;
}

function constructionProgressPercent(progress: number): number {
  return Number.isFinite(progress) ? Math.round(Math.max(0, Math.min(1, progress)) * 100) : 0;
}

function constructionPresentation(building: Building): {
  stateLabel: string;
  stateClass: "active" | "traveling" | "paused" | "missing" | "unassigned" | "assigned";
  detail: string;
  action: string;
} {
  const detail = building.constructionStatusDetail?.trim() ?? "";
  const normalized = detail.toLowerCase();
  const playerAction = "Continue: select Worker and right-click site.";

  if (!building.assignedWorkerId) {
    return {
      stateLabel: "Unassigned",
      stateClass: "unassigned",
      detail: "No Worker is assigned, so construction is paused.",
      action: playerAction
    };
  }
  if (normalized.includes("missing")) {
    return {
      stateLabel: "Worker missing",
      stateClass: "missing",
      detail: `${building.assignedWorkerName ?? "Assigned Worker"} is unavailable; progress cannot advance.`,
      action: "Continue: select another Worker and right-click site."
    };
  }
  if (normalized.includes("paused") || normalized.includes("away")) {
    return {
      stateLabel: "Paused",
      stateClass: "paused",
      detail: "The assigned Worker is away or paused; progress is not advancing.",
      action: "Continue: issue Build/Resume or right-click this site with the Worker."
    };
  }
  if (normalized.includes("traveling") || normalized.includes("moving")) {
    return {
      stateLabel: "Worker traveling",
      stateClass: "traveling",
      detail: "The assigned Worker is moving to the site; progress resumes on arrival.",
      action: "Action: wait for the Worker to arrive, or reissue Build if needed."
    };
  }
  if (building.constructionProgressing || normalized === "building") {
    return {
      stateLabel: "Building",
      stateClass: "active",
      detail: "The assigned Worker is in range and construction is advancing.",
      action: "Action: no input required while construction is advancing."
    };
  }
  return {
    stateLabel: "Assigned",
    stateClass: "assigned",
    detail: detail || "The Worker is assigned; progress begins when the site is reached.",
    action: playerAction
  };
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

function renderControlGroupSummary(groups: ControlGroupSummary[], density: HudDensityMode): string {
  if (groups.length === 0) {
    return "";
  }

  return `
    <div class="control-group-summary" data-testid="control-group-summary">
      <strong>Control Groups</strong>
      <span>${groups.map((group) => `${group.slot}:${group.count}`).join(" ")}</span>
    <small class="${density === "minimal" ? "density-optional" : ""}">Ctrl+1-5 assigns; 1-5 recalls.</small>
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

function renderWorkerResourceAssignment(worker: Unit): string {
  const assignment = worker.activeResourceSiteLabel
    ? `Assigned to ${worker.activeResourceSiteLabel}`
    : worker.activeResourceSiteId
      ? "Assigned to a resource site"
      : "No resource site assigned";
  const detail = worker.activeResourceSiteId
    ? "This Worker is assigned; assigning elsewhere will replace the current site assignment."
    : "Select a captured resource site and right-click it, or use the Resource Sites command.";
  return `
    <div class="worker-resource-assignment" data-testid="selected-worker-resource-assignment" aria-label="Worker resource-site assignment">
      <strong>Resource assignment</strong>
      <span>${escapeHtml(assignment)}</span>
      <small>${escapeHtml(detail)}</small>
    </div>
  `;
}

function renderRoleIdentitySummary(identity: UnitRoleIdentity, density: HudDensityMode): string {
  return `
    <div class="role-identity-summary" data-testid="selected-role-summary">
      <strong>${escapeHtml(identity.label)}</strong>
      <span class="${density === "minimal" ? "density-optional" : ""}">${escapeHtml(identity.summary)}</span>
      <small class="${density === "minimal" ? "density-optional" : ""}">${escapeHtml(identity.tacticalHint)}</small>
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
    return `Worker slots full (${site.workerAssignments.length}/${resourceSiteWorkerSlotCapacity(site)}). Assign a different site to replace a Worker assignment.`;
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
    <section class="order-summary ${tone}" data-testid="unit-order-summary" aria-label="Current order" role="status">
      <strong>${escapeHtml(label)}</strong>
      <span>${escapeHtml(detail)}</span>
    </section>
  `;
}

function renderProductionQueue(building: Building): string {
  if (building.team !== "player" || !building.alive || !building.isCompleted() || building.trainingQueue.length === 0) {
    return "";
  }
  return `
    <section class="queue-list" aria-label="Training queue" data-testid="training-queue">
      <div class="queue-heading"><strong>Training Queue</strong><span>${escapeHtml(building.definition.name)}</span></div>
      ${building.trainingQueue
        .map((item, index) => {
          const active = index === 0;
          const progress = queueProgressPercent(item.remaining, item.total);
          const unitLabel = unitName(item.unitId);
          const positionLabel = `Queue position ${index + 1}`;
          const stateLabel = active ? "Training now" : `Queued · Position ${index + 1}`;
          return `
            <div class="queue-row ${active ? "queue-row-active" : "queue-row-waiting"}" data-queue-type="training" data-queue-index="${index}">
              <div class="queue-item-copy">
                <span class="queue-item-name">${escapeHtml(unitLabel)}</span>
                <span class="queue-entry-state">${escapeHtml(stateLabel)}</span>
                ${
                  active
                    ? renderQueueProgress(`Training ${unitLabel} progress`, progress)
                    : `<span class="queue-position">${escapeHtml(positionLabel)}</span>`
                }
              </div>
              <button class="hud-button compact mini queue-cancel" type="button" data-action="cancel-train" data-source-id="${building.id}" data-index="${index}" aria-label="Cancel ${escapeHtml(unitLabel)} training, queue position ${index + 1}" title="Cancel ${escapeHtml(unitLabel)} training, queue position ${index + 1}">Cancel</button>
            </div>
          `;
        })
        .join("")}
    </section>
  `;
}

function renderUpgradeQueue(building: Building): string {
  if (building.team !== "player" || !building.alive || !building.isCompleted() || building.upgradeQueue.length === 0) {
    return "";
  }
  return `
    <section class="queue-list" aria-label="Research queue" data-testid="research-queue">
      <div class="queue-heading"><strong>Research Queue</strong><span>${escapeHtml(building.definition.name)}</span></div>
      ${building.upgradeQueue
        .map((item, index) => {
          const active = index === 0;
          const progress = queueProgressPercent(item.remaining, item.total);
          const upgradeLabel = upgradeName(item.upgradeId);
          const positionLabel = `Queue position ${index + 1}`;
          const stateLabel = active ? "Researching now" : `Queued · Position ${index + 1}`;
          return `
            <div class="queue-row ${active ? "queue-row-active" : "queue-row-waiting"}" data-queue-type="research" data-queue-index="${index}">
              <div class="queue-item-copy">
                <span class="queue-item-name">${escapeHtml(upgradeLabel)}</span>
                <span class="queue-entry-state">${escapeHtml(stateLabel)}</span>
                ${
                  active
                    ? renderQueueProgress(`Research ${upgradeLabel} progress`, progress)
                    : `<span class="queue-position">${escapeHtml(positionLabel)}</span>`
                }
              </div>
              <button class="hud-button compact mini queue-cancel" type="button" data-action="cancel-upgrade" data-source-id="${building.id}" data-index="${index}" aria-label="Cancel ${escapeHtml(upgradeLabel)} research, queue position ${index + 1}" title="Cancel ${escapeHtml(upgradeLabel)} research, queue position ${index + 1}">Cancel</button>
            </div>
          `;
        })
        .join("")}
    </section>
  `;
}

function queueProgressPercent(remaining: number, total: number): number {
  if (!Number.isFinite(total) || total <= 0 || !Number.isFinite(remaining)) {
    return 0;
  }
  return Math.round(Math.max(0, Math.min(1, (total - remaining) / total)) * 100);
}

function renderQueueProgress(label: string, percent: number): string {
  return `
    <div class="queue-progress" role="progressbar" aria-label="${escapeHtml(label)}" aria-valuemin="0" aria-valuemax="100" aria-valuenow="${percent}">
      <div class="queue-progress-track"><i style="width:${percent}%"></i></div>
      <span>${percent}%</span>
    </div>
  `;
}
