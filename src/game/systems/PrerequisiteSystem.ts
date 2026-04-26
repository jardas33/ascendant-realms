import type { TechPrerequisites } from "../core/GameTypes";

export interface TechState {
  completedBuildingIds: Set<string>;
  researchedUpgradeIds: Set<string>;
  heroLevel?: number;
}

export interface PrerequisiteResult {
  ok: boolean;
  reason?: string;
}

export function checkPrerequisites(prerequisites: TechPrerequisites | undefined, state: TechState): PrerequisiteResult {
  if (!prerequisites) {
    return { ok: true };
  }

  const missingBuilding = prerequisites.buildingIds?.find((buildingId) => !state.completedBuildingIds.has(buildingId));
  if (missingBuilding) {
    return { ok: false, reason: `Requires ${formatTechId(missingBuilding)}` };
  }

  const missingUpgrade = prerequisites.upgradeIds?.find((upgradeId) => !state.researchedUpgradeIds.has(upgradeId));
  if (missingUpgrade) {
    return { ok: false, reason: `Requires ${formatTechId(missingUpgrade)}` };
  }

  if (prerequisites.heroLevel !== undefined && (state.heroLevel ?? 1) < prerequisites.heroLevel) {
    return { ok: false, reason: `Requires hero level ${prerequisites.heroLevel}` };
  }

  return { ok: true };
}

export function formatTechId(value: string): string {
  return value.replaceAll("_", " ").replace(/\b\w/g, (letter) => letter.toUpperCase());
}
