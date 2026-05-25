import type { BuildingDefinition, Cost, UnitDefinition, UpgradeDefinition } from "../../core/GameTypes";
import { canAfford } from "../../core/MathUtils";
import { BUILDING_BY_ID, UNIT_BY_ID, UPGRADE_BY_ID } from "../../data/contentIndex";
import { Building } from "../../entities/Building";
import { CaptureSite } from "../../entities/CaptureSite";
import { Unit } from "../../entities/Unit";
import { checkPrerequisites } from "../../systems/PrerequisiteSystem";
import { RESOURCE_SITE_MAX_LEVEL, RESOURCE_SITE_UPGRADE_COST } from "../../systems/ResourceSystem";
import { formatCost } from "../BuildMenu";
import {
  escapeHtml,
  formatBuildingRole,
  formatBuildingSummary,
  formatBuildingUnlockSummary,
  formatUnitSummary,
  formatUpgradeCategory,
  formatUpgradeEffects,
  formatUpgradeOwner,
  formatUpgradeRequirements
} from "./HudFormatting";
import type { HUDSnapshot } from "./HudTypes";

export function renderCommandActions(selectedOne: UnitDefinitionOwner | undefined, snapshot: HUDSnapshot): string {
  if (!(selectedOne instanceof Building) && !(selectedOne instanceof Unit) && !(selectedOne instanceof CaptureSite)) {
    return "";
  }

  if (selectedOne instanceof Building && !selectedOne.isCompleted()) {
    return `<div class="action-group"><strong>Construction</strong><p class="quiet">${escapeHtml(formatBuildingRole(selectedOne.definition))}</p><p class="quiet">${escapeHtml(formatBuildingUnlockSummary(selectedOne.definition))}</p><p class="quiet">Incomplete - completed-building actions locked. Select a Worker and right-click this site to continue construction.</p></div>`;
  }

  const buildButtons = selectedOne instanceof Unit || selectedOne instanceof Building ? (selectedOne.definition.buildOptions ?? [])
    .map((buildingId) => BUILDING_BY_ID[buildingId])
    .filter((definition): definition is BuildingDefinition => definition !== undefined)
    .map((definition) => {
      const prerequisite = checkPrerequisites(definition.prerequisites, snapshot.techState);
      const lockReason = !prerequisite.ok
        ? prerequisite.reason
        : canAfford(snapshot.resources, definition.cost)
          ? undefined
          : "Insufficient resources";
      return renderCommandButton({
        action: "build",
        verb: "Build",
        id: definition.id,
        sourceId: selectedOne.id,
        name: definition.name,
        detail: formatCommandDetail(definition.cost, lockReason),
        description: definition.description,
        effect: formatBuildingSummary(definition),
        locked: Boolean(lockReason)
      });
    })
    .join("") : "";

  const trainButtons = selectedOne instanceof Building ? selectedOne.definition.trainOptions
    .map((unitId) => UNIT_BY_ID[unitId])
    .filter((definition): definition is UnitDefinition => definition !== undefined)
    .map((definition) => {
      const prerequisite = checkPrerequisites(definition.prerequisites, snapshot.techState);
      const lockReason = !prerequisite.ok
        ? prerequisite.reason
        : canAfford(snapshot.resources, definition.cost)
          ? undefined
          : "Insufficient resources";
      return renderCommandButton({
        action: "train",
        verb: "Train",
        id: definition.id,
        sourceId: selectedOne.id,
        name: definition.name,
        detail: formatCommandDetail(definition.cost, lockReason),
        description: `${definition.role}. ${definition.description}`,
        effect: formatUnitSummary(definition),
        locked: Boolean(lockReason)
      });
    })
    .join("") : "";

  const upgradeButtons = selectedOne instanceof Building ? selectedOne.definition.upgradeOptions
    .map((upgradeId) => UPGRADE_BY_ID[upgradeId])
    .filter((definition): definition is UpgradeDefinition => definition !== undefined)
    .map((definition) => {
      const researched = snapshot.techState.researchedUpgradeIds.has(definition.id);
      const queued = selectedOne.upgradeQueue.some((entry) => entry.upgradeId === definition.id);
      const prerequisite = checkPrerequisites(definition.prerequisites, snapshot.techState);
      const lockReason = researched
        ? "Researched"
        : queued
          ? "Researching"
          : !prerequisite.ok
            ? prerequisite.reason
            : canAfford(snapshot.resources, definition.cost)
              ? undefined
              : "Insufficient resources";
      return renderCommandButton({
        action: "upgrade",
        verb: "Research",
        id: definition.id,
        sourceId: selectedOne.id,
        name: definition.name,
        detail: formatCommandDetail(definition.cost, lockReason),
        description: `${definition.description} ${formatUpgradeOwner(definition)}. ${formatUpgradeRequirements(definition)}. ${formatUpgradeCategory(definition)}.`,
        effect: `Effect: ${formatUpgradeEffects(definition)}`,
        locked: Boolean(lockReason)
      });
    })
    .join("") : "";

  const repairButtons =
    selectedOne instanceof Unit && selectedOne.definition.id === "worker"
      ? snapshot.repairTargets
          .map((target) =>
            renderCommandButton({
              action: "repair",
              verb: "Repair",
              id: target.id,
              sourceId: selectedOne.id,
              name: target.name,
              detail: target.isRepairable
                ? `${target.status}. Cost: none`
                : `Already repaired. HP ${Math.ceil(target.hp)}/${target.maxHp}`,
              description: target.isRepairable
                ? "Worker must stay near the building; move or attack orders stop repair until Repair is issued again."
                : "Full health.",
              effect: target.isRepairable ? "Effect: restores building HP slowly over time." : undefined,
              locked: !target.isRepairable
            })
          )
          .join("")
      : "";

  const resourceSiteButtons =
    selectedOne instanceof Unit && selectedOne.definition.id === "worker"
      ? snapshot.resourceSites
          .map((site) => {
            const assignedToThisWorker = site.workerSlots.some((slot) => slot.workerId === selectedOne.id);
            const fullForThisWorker = site.workerSlotsUsed >= site.workerSlotCapacity && !assignedToThisWorker;
            const locked = site.owner !== "player" || fullForThisWorker;
            return renderCommandButton({
              action: "assign-resource-site",
              verb: assignedToThisWorker ? "Reassign" : "Assign",
              id: site.id,
              sourceId: selectedOne.id,
              name: site.name,
              detail:
                site.owner === "player"
                  ? `Level ${site.level}. Slots ${site.workerSlotsUsed}/${site.workerSlotCapacity}. Total +${site.totalIncomeAmount}/${site.incomeInterval}s`
                  : site.status,
              description:
                site.owner === "player"
                  ? `Captured ${site.resource} site. Base +${site.baseIncomeAmount}, upgrade +${site.upgradeBonusAmount}, Workers +${site.workerBonusAmount}. ${site.status}.`
                  : "Capture this resource site before assigning a Worker.",
              effect: site.owner === "player" ? "Effect: adds a small bonus to this site's existing passive income." : undefined,
              locked
            });
          })
          .join("")
      : "";

  const resourceSiteUpgradeButtons =
    selectedOne instanceof CaptureSite
      ? (() => {
          const site = snapshot.resourceSites.find((entry) => entry.id === selectedOne.id);
          const level = site?.level ?? selectedOne.siteLevel;
          const owner = site?.owner ?? selectedOne.owner;
          const upgradeCost = site?.upgradeCost ?? RESOURCE_SITE_UPGRADE_COST;
          const lockReason =
            owner !== "player"
              ? "Capture before upgrading"
              : level >= RESOURCE_SITE_MAX_LEVEL
                ? "Improved"
                : canAfford(snapshot.resources, upgradeCost)
                  ? undefined
                  : "Insufficient resources";
          return renderCommandButton({
            action: "upgrade-resource-site",
            verb: "Upgrade",
            id: selectedOne.id,
            sourceId: selectedOne.id,
            name: selectedOne.definition.name,
            detail: formatCommandDetail(upgradeCost, lockReason),
            description: site?.upgradeStatus ?? "Upgrade captured sites to improve income and Worker capacity.",
            effect: "Effect: adds a modest income bonus and unlocks a second Worker slot.",
            locked: Boolean(lockReason)
          });
        })()
      : "";

  const sections = [];
  if (selectedOne instanceof Building) {
    sections.push(`<div class="action-group"><strong>Role</strong><p class="quiet">${escapeHtml(formatBuildingRole(selectedOne.definition))}</p></div>`);
  }
  if (trainButtons) {
    sections.push(`<div class="action-group"><strong>Train</strong>${trainButtons}</div>`);
  }
  if (buildButtons) {
    sections.push(`<div class="action-group"><strong>Build</strong>${buildButtons}</div>`);
  }
  if (repairButtons) {
    sections.push(`<div class="action-group"><strong>Repair</strong>${repairButtons}</div>`);
  }
  if (resourceSiteButtons) {
    sections.push(`<div class="action-group"><strong>Resource Sites</strong>${resourceSiteButtons}</div>`);
  }
  if (resourceSiteUpgradeButtons) {
    sections.push(`<div class="action-group"><strong>Site Upgrade</strong>${resourceSiteUpgradeButtons}</div>`);
  }
  if (upgradeButtons) {
    sections.push(`<div class="action-group"><strong>Upgrades</strong>${upgradeButtons}</div>`);
  }
  return sections.join("");
}

function formatCommandDetail(cost: Cost, lockReason?: string): string {
  const costText = `Cost: ${formatCost(cost)}`;
  return lockReason ? `${lockReason}. ${costText}` : costText;
}

type UnitDefinitionOwner = HUDSnapshot["selected"][number];

function renderCommandButton(options: {
  action: "build" | "train" | "upgrade" | "repair" | "assign-resource-site" | "upgrade-resource-site";
  verb: string;
  id: string;
  sourceId: string;
  name: string;
  detail: string;
  description?: string;
  effect?: string;
  locked: boolean;
}): string {
  const extra = [options.description, options.effect].filter(Boolean).join(" ");
  const label = `${options.verb} ${options.name}. ${options.detail}${extra ? `. ${extra}` : ""}`;
  return `
    <button
      class="hud-button command-button ${options.locked ? "locked" : ""}"
      data-action="${options.action}"
      data-command-kind="${options.action}"
      data-command-cost="${escapeHtml(options.detail)}"
      data-testid="command-${options.action}-${options.id}"
      data-id="${options.id}"
      data-source-id="${options.sourceId}"
      aria-label="${escapeHtml(label)}"
      title="${escapeHtml(label)}"
      ${options.locked ? "disabled" : ""}
    >
      <span class="command-label">
        <span class="command-verb">${escapeHtml(options.verb)}</span>
        <span class="command-name">${escapeHtml(options.name)}</span>
      </span>
      <small>${escapeHtml(options.detail)}</small>
      ${options.description ? `<span class="command-description">${escapeHtml(options.description)}</span>` : ""}
      ${options.effect ? `<span class="command-effect">${escapeHtml(options.effect)}</span>` : ""}
    </button>
  `;
}
