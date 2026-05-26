import type { Position, ResourceKey, Team } from "../core/GameTypes";
import { distance } from "../core/MathUtils";
import type { CaptureSite } from "../entities/CaptureSite";
import type { Unit } from "../entities/Unit";

export type EnemyResourceSiteTask = "capture" | "retake" | "defend" | "raid";

export interface EnemyResourceSiteScore {
  site: CaptureSite;
  task: EnemyResourceSiteTask;
  relationship: "neutral" | "friendly" | "enemy";
  score: number;
  nearbyPlayerPower: number;
  nearbyEnemyPower: number;
  recommendedSquadSize: number;
  reason: string;
}

export interface EnemyResourceSiteStrategyContext {
  sites: CaptureSite[];
  enemyUnits: Unit[];
  playerUnits: Unit[];
  enemyBasePosition: Position;
  knownEnemySiteIds?: ReadonlySet<string>;
}

const RESOURCE_WEIGHTS: Record<ResourceKey, number> = {
  crowns: 1.18,
  stone: 1,
  iron: 1.08,
  aether: 1.16
};

const SITE_THREAT_RADIUS_PADDING = 190;

export function classifySiteForEnemy(site: CaptureSite): EnemyResourceSiteScore["relationship"] {
  if (site.owner === "enemy") {
    return "friendly";
  }
  if (site.owner === "player") {
    return "enemy";
  }
  return "neutral";
}

export function chooseEnemyResourceSitePlan(
  context: EnemyResourceSiteStrategyContext,
  taskFilter: ReadonlySet<EnemyResourceSiteTask>
): EnemyResourceSiteScore | undefined {
  return context.sites
    .map((site) => scoreEnemyResourceSite(site, context))
    .filter((entry) => taskFilter.has(entry.task))
    .filter((entry) => entry.score > 0)
    .sort((left, right) => right.score - left.score)[0];
}

export function scoreEnemyResourceSite(site: CaptureSite, context: EnemyResourceSiteStrategyContext): EnemyResourceSiteScore {
  const relationship = classifySiteForEnemy(site);
  const nearbyPlayerPower = nearbyUnitPower(context.playerUnits, site.position, site.definition.radius + SITE_THREAT_RADIUS_PADDING);
  const nearbyEnemyPower = nearbyUnitPower(context.enemyUnits, site.position, site.definition.radius + SITE_THREAT_RADIUS_PADDING);
  const distancePenalty = Math.max(0, distance(context.enemyBasePosition, site.position) / 165);
  const incomeValue = site.definition.incomeAmount * (RESOURCE_WEIGHTS[site.definition.resource] ?? 1);
  const levelValue = site.siteLevel >= 2 ? 18 : 0;
  const abstractEnemyValue = relationship === "friendly" ? site.abstractEnemyWorkerSlots * 7 : 0;
  const playerWorkerPressureValue =
    relationship === "enemy" ? site.workerAssignments.length * 14 + (site.workerAssignmentBoostActive ? 8 : 0) : 0;
  const lostSiteValue = relationship === "enemy" && context.knownEnemySiteIds?.has(site.definition.id) ? 38 : 0;
  const contestedValue = site.captureProgress > 0 ? 8 : 0;

  if (relationship === "friendly") {
    const threatened = nearbyPlayerPower > 0;
    return {
      site,
      task: "defend",
      relationship,
      score: threatened ? incomeValue + levelValue + abstractEnemyValue + nearbyPlayerPower * 7 - distancePenalty : 0,
      nearbyPlayerPower,
      nearbyEnemyPower,
      recommendedSquadSize: site.siteLevel >= 2 || nearbyPlayerPower >= 4 ? 3 : 2,
      reason: threatened ? "defend threatened enemy resource site" : "friendly site is quiet"
    };
  }

  if (relationship === "enemy") {
    const score =
      34 +
      incomeValue +
      levelValue +
      playerWorkerPressureValue +
      lostSiteValue +
      contestedValue -
      distancePenalty -
      nearbyPlayerPower * 4.4 +
      nearbyEnemyPower * 1.8;
    return {
      site,
      task: lostSiteValue > 0 ? "retake" : "raid",
      relationship,
      score,
      nearbyPlayerPower,
      nearbyEnemyPower,
      recommendedSquadSize: site.siteLevel >= 2 || site.workerAssignments.length > 0 || lostSiteValue > 0 ? 3 : 2,
      reason: lostSiteValue > 0 ? "retake previously held resource site" : "pressure player resource economy"
    };
  }

  return {
    site,
    task: "capture",
    relationship,
    score: 28 + incomeValue + contestedValue - distancePenalty - nearbyPlayerPower * 3.2 + nearbyEnemyPower,
    nearbyPlayerPower,
    nearbyEnemyPower,
    recommendedSquadSize: nearbyPlayerPower > 0 ? 3 : 2,
    reason: "capture neutral resource site"
  };
}

export function isSitePlanOutmatched(plan: EnemyResourceSiteScore, squad: Unit[]): boolean {
  const squadPower = totalUnitPower(squad);
  const pressureMultiplier = plan.task === "defend" ? 1.75 : 1.38;
  return plan.nearbyPlayerPower > squadPower * pressureMultiplier + 1.5;
}

export function totalUnitPower(units: Unit[]): number {
  return units.filter((unit) => unit.alive).reduce((sum, unit) => sum + unitPower(unit), 0);
}

export function nearbyUnitPower(units: Unit[], point: Position, radius: number): number {
  return totalUnitPower(units.filter((unit) => unit.alive && distance(unit.position, point) <= radius));
}

export function combatUnitsForTeam(units: Unit[], team: Team): Unit[] {
  return units.filter((unit) => unit.alive && unit.team === team);
}

function unitPower(unit: Unit): number {
  const stats = unit.definition.stats;
  const hp = typeof unit.hp === "number" ? unit.hp : (stats?.maxHp ?? 80);
  const damage = typeof unit.damage === "number" ? unit.damage : (stats?.damage ?? 6);
  const range = typeof unit.range === "number" ? unit.range : (stats?.range ?? 38);
  const armor = typeof unit.armor === "number" ? unit.armor : (stats?.armor ?? 0);
  return Math.max(1, hp / 85 + damage * 0.9 + range / 170 + armor * 0.65);
}
