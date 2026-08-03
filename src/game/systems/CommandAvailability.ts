import type { BuildingDefinition, Cost, ResourceBag, Team, UnitDefinition, UpgradeDefinition } from "../core/GameTypes";
import { canAfford } from "../core/MathUtils";
import { checkPrerequisites, type TechState } from "./PrerequisiteSystem";

export type CommandAvailabilityReasonCode =
  | "construction_incomplete"
  | "invalid_source"
  | "prerequisite_missing"
  | "insufficient_resources"
  | "already_researched"
  | "already_queued";

export interface CommandAvailabilityDecision {
  available: boolean;
  reasonCode?: CommandAvailabilityReasonCode;
  reason?: string;
  missingResources?: Partial<ResourceBag>;
}

export interface CommandSource {
  alive: boolean;
  team: Team;
  kind: string;
  definition: Pick<UnitDefinition, "buildOptions"> | Pick<BuildingDefinition, "buildOptions">;
  isCompleted?: () => boolean;
}

const RESOURCE_KEYS: Array<keyof ResourceBag> = ["crowns", "stone", "iron", "aether"];
const RESOURCE_NAMES: Record<keyof ResourceBag, string> = {
  crowns: "Crowns",
  stone: "Stone",
  iron: "Iron",
  aether: "Aether"
};

export function buildCommandAvailability(
  source: CommandSource | undefined,
  definition: BuildingDefinition | undefined,
  techState: TechState,
  resources: ResourceBag
): CommandAvailabilityDecision {
  if (!source || !definition || !source.alive || source.team !== "player") {
    return unavailable("invalid_source", "Unavailable");
  }
  if (source.kind === "building" && source.isCompleted && !source.isCompleted()) {
    return unavailable("construction_incomplete", "Construction must finish first");
  }
  if (!source.definition.buildOptions?.includes(definition.id)) {
    return unavailable("invalid_source", "Unavailable");
  }
  const prerequisite = checkPrerequisites(definition.prerequisites, techState);
  if (!prerequisite.ok) {
    return unavailable("prerequisite_missing", prerequisite.reason ?? "Unavailable");
  }
  return affordabilityDecision(definition.cost, resources);
}

export function trainingCommandAvailability(
  building: { alive: boolean; team: Team; isCompleted: () => boolean; definition: { trainOptions: string[] } },
  definition: UnitDefinition,
  resources: ResourceBag,
  techState?: TechState
): CommandAvailabilityDecision {
  if (!building.alive) {
    return unavailable("invalid_source", "Unavailable");
  }
  if (!building.isCompleted()) {
    return unavailable("construction_incomplete", "Construction must finish first");
  }
  if (!building.definition.trainOptions.includes(definition.id)) {
    return unavailable("invalid_source", "Unavailable");
  }
  if (techState) {
    const prerequisite = checkPrerequisites(definition.prerequisites, techState);
    if (!prerequisite.ok) {
      return unavailable("prerequisite_missing", prerequisite.reason ?? "Unavailable");
    }
  }
  return affordabilityDecision(definition.cost, resources);
}

export function upgradeCommandAvailability(
  building: { alive: boolean; team: Team; isCompleted: () => boolean; definition: { upgradeOptions: string[] } },
  definition: UpgradeDefinition,
  resources: ResourceBag,
  techState: TechState,
  isResearched: boolean,
  isQueued: boolean
): CommandAvailabilityDecision {
  if (!building.alive) {
    return unavailable("invalid_source", "Unavailable");
  }
  if (!building.isCompleted()) {
    return unavailable("construction_incomplete", "Construction must finish first");
  }
  if (!building.definition.upgradeOptions.includes(definition.id)) {
    return unavailable("invalid_source", "Unavailable");
  }
  if (isResearched) {
    return unavailable("already_researched", "Researched");
  }
  if (isQueued) {
    return unavailable("already_queued", "Researching");
  }
  const prerequisite = checkPrerequisites(definition.prerequisites, techState);
  if (!prerequisite.ok) {
    return unavailable("prerequisite_missing", prerequisite.reason ?? "Unavailable");
  }
  return affordabilityDecision(definition.cost, resources);
}

export function missingResourceDeficit(cost: Cost, resources: ResourceBag): Partial<ResourceBag> {
  const missing: Partial<ResourceBag> = {};
  RESOURCE_KEYS.forEach((key) => {
    const amount = Math.max(0, (cost[key] ?? 0) - resources[key]);
    if (amount > 0) {
      missing[key] = amount;
    }
  });
  return missing;
}

export function formatMissingResourceReason(missing: Partial<ResourceBag>): string {
  const parts = RESOURCE_KEYS
    .filter((key) => (missing[key] ?? 0) > 0)
    .map((key) => `${missing[key]} ${RESOURCE_NAMES[key]}`);
  return parts.length > 0 ? `Need ${parts.join(" and ")}` : "Unavailable";
}

function affordabilityDecision(cost: Cost, resources: ResourceBag): CommandAvailabilityDecision {
  if (canAfford(resources, cost)) {
    return { available: true };
  }
  const missingResources = missingResourceDeficit(cost, resources);
  return unavailable("insufficient_resources", formatMissingResourceReason(missingResources), missingResources);
}

function unavailable(
  reasonCode: CommandAvailabilityReasonCode,
  reason: string,
  missingResources?: Partial<ResourceBag>
): CommandAvailabilityDecision {
  return { available: false, reasonCode, reason, missingResources };
}
