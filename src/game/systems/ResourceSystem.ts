import { CAPTURE_TIME_SECONDS } from "../core/Constants";
import type { CaptureSiteFirstCaptureBonusDefinition, Cost, ResourceBag, Team } from "../core/GameTypes";
import { addResources, canAfford, distance, payCost } from "../core/MathUtils";
import type { BaseEntity } from "../entities/BaseEntity";
import { CaptureSite } from "../entities/CaptureSite";
import type { Unit } from "../entities/Unit";

interface ResourceSystemOptions {
  resources: Record<"player" | "enemy", ResourceBag>;
  onCapture: (site: CaptureSite, newOwner: Team) => void;
  onIncome: (site: CaptureSite, owner: Team, amount: number, breakdown?: ResourceIncomeBreakdown) => void;
  getCaptureSites?: () => CaptureSite[];
  onMessage?: (message: string, x?: number, y?: number, color?: string, options?: ResourceSystemMessageOptions) => void;
  onCaptureBonus?: (site: CaptureSite, owner: Team, bonus: CaptureSiteFirstCaptureBonusDefinition) => void;
  adjustFirstCaptureBonus?: (
    site: CaptureSite,
    owner: Team,
    bonus: CaptureSiteFirstCaptureBonusDefinition
  ) => CaptureSiteFirstCaptureBonusDefinition;
}

interface ResourceSystemMessageOptions {
  durationSeconds?: number;
  priority?: "normal" | "command" | "pressure" | "objective";
}

interface ResourceSiteUpgradeOptions {
  owner?: Extract<Team, "player" | "enemy">;
  announce?: boolean;
}

export interface ResourceIncomeBreakdown {
  baseAmount: number;
  upgradeBonusAmount: number;
  workerBonusAmount: number;
  totalAmount: number;
  activeWorkerCount: number;
  abstractEnemyWorkerCount: number;
  assignedWorkerName?: string;
  assignedWorkerNames: string[];
}

export interface ResourceSiteWorkerSlotSummary {
  workerId?: string;
  workerName?: string;
  status: string;
  boostActive: boolean;
}

export interface ResourceSiteAssignmentSummary {
  id: string;
  name: string;
  resource: CaptureSite["definition"]["resource"];
  owner: Team;
  level: number;
  maxLevel: number;
  baseIncomeAmount: number;
  upgradeBonusAmount: number;
  incomeInterval: number;
  workerBonusAmount: number;
  workerBonusPerWorkerAmount: number;
  boostedIncomeAmount: number;
  totalIncomeAmount: number;
  workerSlotCapacity: number;
  workerSlotsUsed: number;
  workerSlotsAvailable: number;
  workerSlots: ResourceSiteWorkerSlotSummary[];
  abstractEnemyWorkerSlotsUsed: number;
  assignedWorkerId?: string;
  assignedWorkerName?: string;
  isAssignable: boolean;
  status: string;
  canUpgrade: boolean;
  upgradeCost: Cost;
  upgradeStatus: string;
}

export const WORKER_SITE_ASSIGNMENT_BONUS_RATIO = 0.2;
export const RESOURCE_SITE_UPGRADE_BONUS_RATIO = 0.15;
export const RESOURCE_SITE_MAX_LEVEL = 2;
export const RESOURCE_SITE_UPGRADE_COST: Cost = { crowns: 120, stone: 80 };

export class ResourceSystem {
  private readonly claimedFirstCaptureBonuses = new Set<string>();

  constructor(private readonly options: ResourceSystemOptions) {}

  update(deltaSeconds: number, sites: CaptureSite[], units: Unit[]): void {
    sites.forEach((site) => {
      this.updateCapture(deltaSeconds, site, units);
      this.updateWorkerAssignment(site, units);
      this.updateIncome(deltaSeconds, site);
      site.updateVisuals();
    });
    this.pruneStaleWorkerAssignmentIntents(sites, units);
  }

  requestWorkerAssignment(worker: Unit | undefined, site: CaptureSite | undefined, sites = this.currentSites()): boolean {
    const validation = validateWorkerSiteAssignmentRequest(worker, site);
    if (!validation.ok) {
      const point = site?.position ?? worker?.position;
      this.showAssignmentMessage(validation.reason, point?.x, point ? point.y - 36 : undefined, "#ffd27a");
      return false;
    }

    const assignedWorker = worker!;
    const targetSite = site!;
    sites.forEach((candidate) => {
      if (candidate.id !== targetSite.id && candidate.hasWorkerAssignment(assignedWorker.id)) {
        candidate.clearWorkerAssignment(assignedWorker.id);
      }
    });

    targetSite.setWorkerAssignment(assignedWorker.id, assignedWorker.definition.name);
    if (isWorkerInResourceSiteRange(targetSite, assignedWorker)) {
      assignedWorker.moveTarget = undefined;
      assignedWorker.markResourceSiteWork(targetSite.id, targetSite.definition.name);
      targetSite.updateWorkerAssignment(assignedWorker.id, `${assignedWorker.definition.name} working`, true);
    } else {
      commandWorkerToResourceSite(assignedWorker, targetSite);
    }

    this.showAssignmentMessage(
      `Worker assignment accepted: ${assignedWorker.definition.name} -> ${targetSite.definition.name}`,
      targetSite.position.x,
      targetSite.position.y - 54,
      "#d9eee8"
    );
    return true;
  }

  issueWorkerAssignmentOrder(target: BaseEntity | undefined, selectedUnits: Unit[]): boolean {
    if (!(target instanceof CaptureSite)) {
      return false;
    }

    const worker = selectedUnits.find((unit) => isResourceSiteWorker(unit) && unit.alive && unit.team === "player");
    if (!worker) {
      return false;
    }

    this.requestWorkerAssignment(worker, target);
    return true;
  }

  requestSiteUpgrade(site: CaptureSite | undefined, resources: ResourceBag, options: ResourceSiteUpgradeOptions = {}): boolean {
    const owner = options.owner ?? "player";
    const announce = options.announce ?? true;
    const validation = validateResourceSiteUpgradeRequest(site, resources, owner);
    if (!validation.ok) {
      const point = site?.position;
      if (announce) {
        this.showAssignmentMessage(validation.reason, point?.x, point ? point.y - 46 : undefined, "#ffd27a");
      }
      return false;
    }

    const targetSite = site!;
    if (!payCost(resources, RESOURCE_SITE_UPGRADE_COST)) {
      if (announce) {
        this.showAssignmentMessage("Insufficient resources for site upgrade.", targetSite.position.x, targetSite.position.y - 46, "#ffd27a");
      }
      return false;
    }
    targetSite.setSiteLevel(2);
    if (announce) {
      this.showAssignmentMessage(
        `${targetSite.definition.name} improved: income bonus online and a second Worker slot unlocked.`,
        targetSite.position.x,
        targetSite.position.y - 58,
        "#d9eee8"
      );
    }
    return true;
  }

  resourceSiteSummaries(sites = this.currentSites()): ResourceSiteAssignmentSummary[] {
    return sites.map((site) => {
      const workerBonusPerWorkerAmount = workerSiteBonusAmount(site);
      const breakdown = resourceSiteIncomeBreakdown(site);
      const workerSlotCapacity = resourceSiteWorkerSlotCapacity(site);
      const workerSlots = resourceSiteWorkerSlots(site);
      const assignedWorkerName = site.assignedWorkerName;
      return {
        id: site.id,
        name: site.definition.name,
        resource: site.definition.resource,
        owner: site.owner,
        level: site.siteLevel,
        maxLevel: RESOURCE_SITE_MAX_LEVEL,
        baseIncomeAmount: site.definition.incomeAmount,
        upgradeBonusAmount: breakdown.upgradeBonusAmount,
        incomeInterval: site.definition.incomeInterval,
        workerBonusAmount: breakdown.workerBonusAmount,
        workerBonusPerWorkerAmount,
        boostedIncomeAmount: breakdown.totalAmount,
        totalIncomeAmount: breakdown.totalAmount,
        workerSlotCapacity,
        workerSlotsUsed: site.workerAssignments.length,
        workerSlotsAvailable: Math.max(0, workerSlotCapacity - site.workerAssignments.length),
        workerSlots,
        abstractEnemyWorkerSlotsUsed: site.owner === "enemy" ? site.abstractEnemyWorkerSlots : 0,
        assignedWorkerId: site.assignedWorkerId,
        assignedWorkerName,
        isAssignable: site.owner === "player" && site.workerAssignments.length < workerSlotCapacity,
        status: resourceSiteAssignmentStatus(site),
        canUpgrade: site.owner === "player" && site.siteLevel < RESOURCE_SITE_MAX_LEVEL,
        upgradeCost: RESOURCE_SITE_UPGRADE_COST,
        upgradeStatus: resourceSiteUpgradeStatus(site)
      };
    });
  }

  private updateCapture(deltaSeconds: number, site: CaptureSite, units: Unit[]): void {
    const nearbyPlayer = units.some(
      (unit) => unit.alive && unit.team === "player" && distance(unit.position, site.position) <= site.radius
    );
    const nearbyEnemy = units.some(
      (unit) => unit.alive && unit.team === "enemy" && distance(unit.position, site.position) <= site.radius
    );

    if ((nearbyPlayer && nearbyEnemy) || (!nearbyPlayer && !nearbyEnemy)) {
      return;
    }

    const capturingTeam: Team = nearbyPlayer ? "player" : "enemy";
    if (site.owner === capturingTeam) {
      site.captureProgress = 0;
      site.capturingTeam = "neutral";
      return;
    }

    if (site.capturingTeam !== capturingTeam) {
      site.capturingTeam = capturingTeam;
      site.captureProgress = 0;
    }

    site.captureProgress += deltaSeconds / CAPTURE_TIME_SECONDS;
    if (site.captureProgress >= 1) {
      site.setOwner(capturingTeam);
      this.options.onCapture(site, capturingTeam);
      this.applyFirstCaptureBonus(site, capturingTeam);
    }
  }

  private updateIncome(deltaSeconds: number, site: CaptureSite): void {
    if (site.owner !== "player" && site.owner !== "enemy") {
      return;
    }

    site.incomeTimer += deltaSeconds;
    if (site.incomeTimer < site.definition.incomeInterval) {
      return;
    }

    site.incomeTimer = 0;
    const ownerResources = this.options.resources[site.owner];
    const breakdown = resourceSiteIncomeBreakdown(site);
    const totalAmount = breakdown.totalAmount;
    ownerResources[site.definition.resource] += totalAmount;
    this.options.onIncome(site, site.owner, totalAmount, breakdown);
  }

  private updateWorkerAssignment(site: CaptureSite, units: Unit[]): void {
    if (!site.alive || site.owner !== "player") {
      this.clearSiteAssignments(site, units, site.owner === "neutral" ? "Capture site before assigning a Worker" : "Site control lost");
      return;
    }

    if (site.workerAssignments.length === 0) {
      site.workerAssignmentBoostActive = false;
      site.workerAssignmentStatusDetail = "Empty worker slot";
      return;
    }

    [...site.workerAssignments].forEach((assignment) => {
      const worker = units.find((unit) => unit.id === assignment.workerId);
      if (!worker || !isResourceSiteWorker(worker) || !worker.alive || worker.team !== "player") {
        this.clearSiteAssignment(site, assignment.workerId, units, "Assigned Worker missing");
        return;
      }

      if (worker.activeResourceSiteId !== site.id) {
        this.clearSiteAssignment(site, assignment.workerId, units);
        return;
      }

      if (!isWorkerInResourceSiteRange(site, worker)) {
        site.updateWorkerAssignment(assignment.workerId, `${worker.definition.name} traveling`, false);
        commandWorkerToResourceSite(worker, site);
        return;
      }

      worker.moveTarget = undefined;
      worker.markResourceSiteWork(site.id, site.definition.name);
      site.updateWorkerAssignment(assignment.workerId, `${worker.definition.name} working`, true);
    });
  }

  private clearSiteAssignment(site: CaptureSite, workerId: string, units: Unit[], status = "Empty worker slot"): void {
    site.clearWorkerAssignment(workerId, status);
    units.find((unit) => unit.id === workerId)?.clearResourceSiteWork(site.id);
  }

  private clearSiteAssignments(site: CaptureSite, units: Unit[], status = "Empty worker slot"): void {
    const workerIds = site.workerAssignments.map((assignment) => assignment.workerId);
    site.clearAllWorkerAssignments(status);
    workerIds.forEach((workerId) => {
      units.find((unit) => unit.id === workerId)?.clearResourceSiteWork(site.id);
    });
  }

  private pruneStaleWorkerAssignmentIntents(sites: CaptureSite[], units: Unit[]): void {
    units.forEach((worker) => {
      const siteId = worker.activeResourceSiteId;
      if (!siteId) {
        return;
      }
      const site = sites.find((candidate) => candidate.id === siteId);
      if (!site || !site.alive || site.owner !== "player" || !site.hasWorkerAssignment(worker.id)) {
        worker.clearResourceSiteWork(siteId);
      }
    });
  }

  private applyFirstCaptureBonus(site: CaptureSite, owner: Team): void {
    if (owner !== "player" && owner !== "enemy") {
      return;
    }
    const baseBonus = site.definition.firstCaptureBonus;
    if (!baseBonus) {
      return;
    }
    const claimId = `${site.definition.id}:${owner}:${baseBonus.id}`;
    if (this.claimedFirstCaptureBonuses.has(claimId)) {
      return;
    }

    const bonus = this.options.adjustFirstCaptureBonus?.(site, owner, baseBonus) ?? baseBonus;
    this.claimedFirstCaptureBonuses.add(claimId);
    addResources(this.options.resources[owner], bonus.resources);
    this.options.onCaptureBonus?.(site, owner, bonus);
  }

  private currentSites(): CaptureSite[] {
    return this.options.getCaptureSites?.() ?? [];
  }

  private showAssignmentMessage(message: string, x?: number, y?: number, color?: string): void {
    this.options.onMessage?.(message, x, y, color, { priority: "command" });
  }
}

export function workerSiteBonusAmount(site: CaptureSite): number {
  return Math.max(1, Math.round(site.definition.incomeAmount * WORKER_SITE_ASSIGNMENT_BONUS_RATIO));
}

export function resourceSiteUpgradeBonusAmount(site: CaptureSite): number {
  if (site.siteLevel < 2) {
    return 0;
  }
  return Math.max(1, Math.round(site.definition.incomeAmount * RESOURCE_SITE_UPGRADE_BONUS_RATIO));
}

export function resourceSiteWorkerSlotCapacity(site: CaptureSite): number {
  return site.siteLevel >= 2 ? 2 : 1;
}

export function resourceSiteIncomeBreakdown(site: CaptureSite): ResourceIncomeBreakdown {
  const activeAssignments = site.workerAssignments.filter((assignment) => assignment.boostActive);
  const abstractEnemyWorkerCount = site.owner === "enemy" ? site.abstractEnemyWorkerSlots : 0;
  const workerBonusAmount = (activeAssignments.length + abstractEnemyWorkerCount) * workerSiteBonusAmount(site);
  const upgradeBonusAmount = resourceSiteUpgradeBonusAmount(site);
  const totalAmount = site.definition.incomeAmount + upgradeBonusAmount + workerBonusAmount;
  return {
    baseAmount: site.definition.incomeAmount,
    upgradeBonusAmount,
    workerBonusAmount,
    totalAmount,
    activeWorkerCount: activeAssignments.length + abstractEnemyWorkerCount,
    abstractEnemyWorkerCount,
    assignedWorkerName: activeAssignments[0]?.workerName,
    assignedWorkerNames: activeAssignments.map((assignment) => assignment.workerName)
  };
}

export function isWorkerInResourceSiteRange(site: CaptureSite, worker: Unit): boolean {
  return distance(worker.position, site.position) <= site.definition.radius;
}

export function validateWorkerSiteAssignmentRequest(
  worker: Unit | undefined,
  site: CaptureSite | undefined
): { ok: true } | { ok: false; reason: string } {
  if (!worker || !worker.alive || worker.team !== "player" || !isResourceSiteWorker(worker)) {
    return { ok: false, reason: "Select a Worker to assign to a captured resource site." };
  }
  if (!site?.alive) {
    return { ok: false, reason: "No resource site selected." };
  }
  if (site.owner !== "player") {
    return { ok: false, reason: "Capture the resource site before assigning a Worker." };
  }
  if (!site.hasWorkerAssignment(worker.id) && site.workerAssignments.length >= resourceSiteWorkerSlotCapacity(site)) {
    return { ok: false, reason: `${site.definition.name} worker slots are full.` };
  }
  return { ok: true };
}

export function validateResourceSiteUpgradeRequest(
  site: CaptureSite | undefined,
  resources: ResourceBag,
  owner: Extract<Team, "player" | "enemy"> = "player"
): { ok: true } | { ok: false; reason: string } {
  if (!site?.alive) {
    return { ok: false, reason: "No resource site selected." };
  }
  if (site.owner !== owner) {
    return {
      ok: false,
      reason:
        owner === "player"
          ? "Capture the resource site before upgrading it."
          : "Enemy can only upgrade enemy-controlled resource sites."
    };
  }
  if (site.siteLevel >= RESOURCE_SITE_MAX_LEVEL) {
    return { ok: false, reason: `${site.definition.name} is already improved.` };
  }
  if (!canAfford(resources, RESOURCE_SITE_UPGRADE_COST)) {
    return { ok: false, reason: "Insufficient resources for site upgrade." };
  }
  return { ok: true };
}

function isResourceSiteWorker(unit: Unit): boolean {
  return unit.definition.id === "worker";
}

function commandWorkerToResourceSite(worker: Unit, site: CaptureSite): void {
  if (worker.moveTarget && distance(worker.moveTarget, site.position) <= 4) {
    worker.markResourceSiteWork(site.id, site.definition.name);
    return;
  }
  worker.commandResourceSiteMove(site.position, site.id, site.definition.name);
}

function resourceSiteWorkerSlots(site: CaptureSite): ResourceSiteWorkerSlotSummary[] {
  const capacity = resourceSiteWorkerSlotCapacity(site);
  const slots: ResourceSiteWorkerSlotSummary[] = site.workerAssignments.slice(0, capacity).map((assignment) => ({
    workerId: assignment.workerId,
    workerName: assignment.workerName,
    status: assignment.statusDetail,
    boostActive: assignment.boostActive
  }));
  while (slots.length < capacity) {
    slots.push({
      status: "Empty worker slot",
      boostActive: false
    });
  }
  return slots;
}

function resourceSiteAssignmentStatus(site: CaptureSite): string {
  if (site.captureProgress > 0 && site.capturingTeam !== "neutral") {
    const teamLabel = site.capturingTeam === "player" ? "Player" : "Enemy";
    return `${teamLabel} contesting - ${Math.round(site.captureProgress * 100)}%`;
  }
  if (site.owner === "neutral") {
    return "Neutral - capture before assigning a Worker";
  }
  if (site.owner === "enemy") {
    if (site.abstractEnemyWorkerSlots > 0) {
      return `Enemy logistics ${site.abstractEnemyWorkerSlots}/${resourceSiteWorkerSlotCapacity(site)} boosting`;
    }
    return "Enemy controlled - capture before assigning a Worker";
  }
  if (site.workerAssignments.length > 0) {
    const activeCount = site.workerAssignments.filter((assignment) => assignment.boostActive).length;
    return activeCount > 0
      ? `${activeCount}/${resourceSiteWorkerSlotCapacity(site)} Worker slot${resourceSiteWorkerSlotCapacity(site) === 1 ? "" : "s"} boosting`
      : site.workerAssignmentStatusDetail;
  }
  return `Captured - ${resourceSiteWorkerSlotCapacity(site)} empty Worker slot${resourceSiteWorkerSlotCapacity(site) === 1 ? "" : "s"}`;
}

function resourceSiteUpgradeStatus(site: CaptureSite): string {
  if (site.owner === "neutral") {
    return "Capture before upgrading.";
  }
  if (site.owner === "enemy") {
    return site.siteLevel >= RESOURCE_SITE_MAX_LEVEL ? "Enemy Level 2 improved site." : "Enemy controlled.";
  }
  if (site.siteLevel >= RESOURCE_SITE_MAX_LEVEL) {
    return "Level 2 improved site.";
  }
  return "Upgrade to Level 2: +income and 2 Worker slots.";
}
