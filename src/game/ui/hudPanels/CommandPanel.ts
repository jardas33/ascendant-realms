import type { BuildingDefinition, UnitDefinition, UpgradeDefinition } from "../../core/GameTypes";
import { canAfford } from "../../core/MathUtils";
import { BUILDING_BY_ID, UNIT_BY_ID, UPGRADE_BY_ID } from "../../data/contentIndex";
import { Building } from "../../entities/Building";
import { checkPrerequisites } from "../../systems/PrerequisiteSystem";
import { formatCost } from "../BuildMenu";
import {
  escapeHtml,
  formatBuildingSummary,
  formatUnitSummary,
  formatUpgradeEffects
} from "./HudFormatting";
import type { HUDSnapshot } from "./HudTypes";

export function renderCommandActions(selectedOne: UnitDefinitionOwner | undefined, snapshot: HUDSnapshot): string {
  if (!(selectedOne instanceof Building)) {
    return "";
  }

  if (!selectedOne.isCompleted()) {
    return `<div class="action-group"><strong>Construction</strong><p class="quiet">Production unlocks when this building is complete.</p></div>`;
  }

  const buildButtons = selectedOne.definition.buildOptions
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
        detail: lockReason ?? formatCost(definition.cost),
        description: definition.description,
        effect: formatBuildingSummary(definition),
        locked: Boolean(lockReason)
      });
    })
    .join("");

  const trainButtons = selectedOne.definition.trainOptions
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
        detail: lockReason ?? formatCost(definition.cost),
        description: `${definition.role}. ${definition.description}`,
        effect: formatUnitSummary(definition),
        locked: Boolean(lockReason)
      });
    })
    .join("");

  const upgradeButtons = selectedOne.definition.upgradeOptions
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
        detail: lockReason ?? formatCost(definition.cost),
        description: definition.description,
        effect: formatUpgradeEffects(definition),
        locked: Boolean(lockReason)
      });
    })
    .join("");

  const sections = [];
  if (buildButtons) {
    sections.push(`<div class="action-group"><strong>Build</strong>${buildButtons}</div>`);
  }
  if (trainButtons) {
    sections.push(`<div class="action-group"><strong>Train</strong>${trainButtons}</div>`);
  }
  if (upgradeButtons) {
    sections.push(`<div class="action-group"><strong>Upgrades</strong>${upgradeButtons}</div>`);
  }
  return sections.join("");
}

type UnitDefinitionOwner = HUDSnapshot["selected"][number];

function renderCommandButton(options: {
  action: "build" | "train" | "upgrade";
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
