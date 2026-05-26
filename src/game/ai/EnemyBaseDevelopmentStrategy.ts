import type { Position, ResourceBag } from "../core/GameTypes";
import { canAfford, distance } from "../core/MathUtils";
import { UPGRADE_BY_ID } from "../data/contentIndex";
import type { Building } from "../entities/Building";
import type { CaptureSite } from "../entities/CaptureSite";
import type { Unit } from "../entities/Unit";
import { checkPrerequisites } from "../systems/PrerequisiteSystem";
import { nearbyUnitPower, totalUnitPower } from "./EnemyResourceSiteStrategy";

export type EnemyStrategyStage = "early" | "mid" | "late";
export type EnemyBaseStage = "outpost" | "fortified_camp" | "war_camp";

export interface EnemyTechCandidate {
  upgradeId: string;
  building: Building;
  priority: number;
  reason: string;
}

export interface EnemyBaseDevelopmentContext {
  elapsedSeconds: number;
  resources: ResourceBag;
  buildings: Building[];
  sites: CaptureSite[];
  enemyUnits: Unit[];
  playerUnits: Unit[];
  enemyBasePosition: Position;
  researchedUpgradeIds: ReadonlySet<string>;
}

export interface EnemyBaseDevelopmentPlan {
  stage: EnemyStrategyStage;
  baseStage: EnemyBaseStage;
  ownedSiteCount: number;
  improvedOwnedSiteCount: number;
  enemyStockpileScore: number;
  enemyArmyPower: number;
  baseThreatPower: number;
  attackWaveSizeBonus: number;
  defenseReserveUnits: number;
  techCandidates: EnemyTechCandidate[];
  status: string;
}

const BASE_THREAT_RADIUS = 520;
const MIDGAME_SECONDS = 240;
const LATEGAME_SECONDS = 480;

const ENEMY_TECH_ROLE_ALIASES: Record<string, string[]> = {
  enemy_stronghold: ["command_hall"],
  enemy_barracks: ["barracks", "mystic_lodge"]
};

export function createEnemyBaseDevelopmentPlan(context: EnemyBaseDevelopmentContext): EnemyBaseDevelopmentPlan {
  const ownedSites = context.sites.filter((site) => site.alive && site.owner === "enemy");
  const improvedOwnedSiteCount = ownedSites.filter((site) => site.siteLevel >= 2).length;
  const enemyStockpileScore = stockpileScore(context.resources);
  const enemyArmyPower = totalUnitPower(context.enemyUnits);
  const baseThreatPower = nearbyUnitPower(context.playerUnits, context.enemyBasePosition, BASE_THREAT_RADIUS);
  const stage = determineEnemyStrategyStage({
    elapsedSeconds: context.elapsedSeconds,
    ownedSiteCount: ownedSites.length,
    improvedOwnedSiteCount,
    enemyStockpileScore,
    researchedUpgradeCount: context.researchedUpgradeIds.size,
    baseThreatPower
  });
  const baseStage = stage === "late" ? "war_camp" : stage === "mid" ? "fortified_camp" : "outpost";
  const attackWaveSizeBonus =
    stage === "late" && ownedSites.length >= 2 && (improvedOwnedSiteCount > 0 || enemyStockpileScore >= 720) ? 2 : stage === "mid" && improvedOwnedSiteCount > 0 ? 1 : 0;
  const defenseReserveUnits = baseThreatPower > 0 ? 2 : stage === "late" ? 1 : 0;

  return {
    stage,
    baseStage,
    ownedSiteCount: ownedSites.length,
    improvedOwnedSiteCount,
    enemyStockpileScore,
    enemyArmyPower,
    baseThreatPower,
    attackWaveSizeBonus,
    defenseReserveUnits,
    techCandidates: chooseEnemyTechCandidates(context, stage),
    status: statusForStage(stage, baseThreatPower)
  };
}

export function determineEnemyStrategyStage(input: {
  elapsedSeconds: number;
  ownedSiteCount: number;
  improvedOwnedSiteCount: number;
  enemyStockpileScore: number;
  researchedUpgradeCount: number;
  baseThreatPower: number;
}): EnemyStrategyStage {
  if (
    input.elapsedSeconds >= LATEGAME_SECONDS &&
    (input.ownedSiteCount >= 2 ||
      input.improvedOwnedSiteCount > 0 ||
      input.enemyStockpileScore >= 700 ||
      input.researchedUpgradeCount >= 2)
  ) {
    return "late";
  }
  if (
    input.elapsedSeconds >= MIDGAME_SECONDS ||
    input.ownedSiteCount >= 2 ||
    input.improvedOwnedSiteCount > 0 ||
    input.enemyStockpileScore >= 450 ||
    input.researchedUpgradeCount > 0 ||
    input.baseThreatPower > 0
  ) {
    return "mid";
  }
  return "early";
}

export function completedEnemyTechBuildingIds(buildings: Building[]): Set<string> {
  const completed = new Set<string>();
  buildings
    .filter((building) => building.alive && building.team === "enemy" && building.isCompleted())
    .forEach((building) => {
      completed.add(building.definition.id);
      ENEMY_TECH_ROLE_ALIASES[building.definition.id]?.forEach((alias) => completed.add(alias));
    });
  return completed;
}

export function chooseEnemyTechCandidates(
  context: EnemyBaseDevelopmentContext,
  stage: EnemyStrategyStage
): EnemyTechCandidate[] {
  const candidates: EnemyTechCandidate[] = [];
  const ownedSites = context.sites.filter((site) => site.alive && site.owner === "enemy");
  const improvedOwnedSiteCount = ownedSites.filter((site) => site.siteLevel >= 2).length;
  const aetherPressure =
    context.resources.aether >= 120 ||
    ownedSites.some((site) => site.definition.resource === "aether") ||
    context.enemyUnits.some((unit) => unit.definition.id === "hexer");
  const threatenedSites = ownedSites.filter(
    (site) =>
      nearbyUnitPower(context.playerUnits, site.position, site.definition.radius + 220) > 0 ||
      site.captureProgress > 0
  );
  const hasThreat = context.playerUnits.some((unit) => distance(unit.position, context.enemyBasePosition) <= BASE_THREAT_RADIUS) || threatenedSites.length > 0;

  addCandidate(context, candidates, "camp_foundations_1", hasThreat ? 96 : stage === "late" ? 84 : stage === "mid" || ownedSites.length > 0 ? 72 : 0, "fortify enemy base hub");
  addCandidate(context, candidates, "sentry_bracing_1", hasThreat ? 94 : stage === "late" ? 68 : 0, "brace existing enemy watchtower");
  addCandidate(context, candidates, "infantry_weapons_1", stage === "late" ? 86 : stage === "mid" && ownedSites.length > 0 ? 78 : 0, "escalate raider melee pressure");
  addCandidate(context, candidates, "reinforced_armor_1", stage === "late" ? 82 : hasThreat && improvedOwnedSiteCount > 0 ? 76 : 0, "improve mixed squad durability");
  addCandidate(context, candidates, "aether_study_1", aetherPressure && stage !== "early" ? 74 : 0, "improve hexfire support pressure");

  return candidates.sort((left, right) => right.priority - left.priority);
}

function addCandidate(
  context: EnemyBaseDevelopmentContext,
  candidates: EnemyTechCandidate[],
  upgradeId: string,
  priority: number,
  reason: string
): void {
  if (priority <= 0 || context.researchedUpgradeIds.has(upgradeId)) {
    return;
  }
  const upgrade = UPGRADE_BY_ID[upgradeId];
  if (!upgrade || !canAfford(context.resources, upgrade.cost)) {
    return;
  }
  const building = context.buildings.find(
    (entry) =>
      entry.alive &&
      entry.team === "enemy" &&
      entry.isCompleted() &&
      entry.definition.upgradeOptions.includes(upgradeId) &&
      !entry.upgradeQueue.some((queued) => queued.upgradeId === upgradeId)
  );
  if (!building) {
    return;
  }
  const prerequisite = checkPrerequisites(upgrade.prerequisites, {
    completedBuildingIds: completedEnemyTechBuildingIds(context.buildings),
    researchedUpgradeIds: new Set(context.researchedUpgradeIds)
  });
  if (!prerequisite.ok) {
    return;
  }
  candidates.push({ upgradeId, building, priority, reason });
}

function stockpileScore(resources: ResourceBag): number {
  return resources.crowns * 0.65 + resources.stone * 0.55 + resources.iron * 0.72 + resources.aether * 0.78;
}

function statusForStage(stage: EnemyStrategyStage, baseThreatPower: number): string {
  if (baseThreatPower > 0) {
    return "Enemy defending base.";
  }
  if (stage === "late") {
    return "Enemy pressure is escalating.";
  }
  if (stage === "mid") {
    return "Enemy is fortifying.";
  }
  return "Enemy scouts are probing.";
}
