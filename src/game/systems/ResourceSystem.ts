import { CAPTURE_TIME_SECONDS } from "../core/Constants";
import type { CaptureSiteFirstCaptureBonusDefinition, ResourceBag, Team } from "../core/GameTypes";
import { addResources, distance } from "../core/MathUtils";
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

export interface ResourceIncomeBreakdown {
  baseAmount: number;
  workerBonusAmount: number;
  assignedWorkerName?: string;
}

export interface ResourceSiteAssignmentSummary {
  id: string;
  name: string;
  resource: CaptureSite["definition"]["resource"];
  owner: Team;
  baseIncomeAmount: number;
  incomeInterval: number;
  workerBonusAmount: number;
  boostedIncomeAmount: number;
  assignedWorkerId?: string;
  assignedWorkerName?: string;
  isAssignable: boolean;
  status: string;
}

export const WORKER_SITE_ASSIGNMENT_BONUS_RATIO = 0.2;

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
      if (candidate.assignedWorkerId === assignedWorker.id && candidate.id !== targetSite.id) {
        candidate.clearWorkerAssignment();
      }
    });

    targetSite.setWorkerAssignment(assignedWorker.id, assignedWorker.definition.name);
    if (isWorkerInResourceSiteRange(targetSite, assignedWorker)) {
      assignedWorker.moveTarget = undefined;
      assignedWorker.markResourceSiteWork(targetSite.id, targetSite.definition.name);
      targetSite.workerAssignmentStatusDetail = `${assignedWorker.definition.name} working`;
      targetSite.workerAssignmentBoostActive = true;
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

  resourceSiteSummaries(sites = this.currentSites()): ResourceSiteAssignmentSummary[] {
    return sites.map((site) => {
      const workerBonusAmount = workerSiteBonusAmount(site);
      const assignedWorkerName = site.assignedWorkerName;
      return {
        id: site.id,
        name: site.definition.name,
        resource: site.definition.resource,
        owner: site.owner,
        baseIncomeAmount: site.definition.incomeAmount,
        incomeInterval: site.definition.incomeInterval,
        workerBonusAmount,
        boostedIncomeAmount: site.definition.incomeAmount + (site.workerAssignmentBoostActive ? workerBonusAmount : 0),
        assignedWorkerId: site.assignedWorkerId,
        assignedWorkerName,
        isAssignable: site.owner === "player" && !site.assignedWorkerId,
        status: resourceSiteAssignmentStatus(site)
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
    const breakdown = incomeBreakdownFor(site);
    const totalAmount = breakdown.baseAmount + breakdown.workerBonusAmount;
    ownerResources[site.definition.resource] += totalAmount;
    this.options.onIncome(site, site.owner, totalAmount, breakdown);
  }

  private updateWorkerAssignment(site: CaptureSite, units: Unit[]): void {
    if (!site.alive || site.owner !== "player") {
      this.clearSiteAssignment(site, units, site.owner === "neutral" ? "Capture site before assigning a Worker" : "Site control lost");
      return;
    }

    if (!site.assignedWorkerId) {
      site.workerAssignmentBoostActive = false;
      site.workerAssignmentStatusDetail = "Empty worker slot";
      return;
    }

    const worker = units.find((unit) => unit.id === site.assignedWorkerId);
    if (!worker || !isResourceSiteWorker(worker) || !worker.alive || worker.team !== "player") {
      this.clearSiteAssignment(site, units, "Assigned Worker missing");
      return;
    }

    if (worker.activeResourceSiteId !== site.id) {
      this.clearSiteAssignment(site, units);
      return;
    }

    if (!isWorkerInResourceSiteRange(site, worker)) {
      site.workerAssignmentBoostActive = false;
      site.workerAssignmentStatusDetail = `${worker.definition.name} traveling`;
      commandWorkerToResourceSite(worker, site);
      return;
    }

    worker.moveTarget = undefined;
    worker.markResourceSiteWork(site.id, site.definition.name);
    site.assignedWorkerName = worker.definition.name;
    site.workerAssignmentStatusDetail = `${worker.definition.name} working`;
    site.workerAssignmentBoostActive = true;
  }

  private clearSiteAssignment(site: CaptureSite, units: Unit[], status = "Empty worker slot"): void {
    const workerId = site.assignedWorkerId;
    site.clearWorkerAssignment(status);
    if (workerId) {
      units.find((unit) => unit.id === workerId)?.clearResourceSiteWork(site.id);
    }
  }

  private pruneStaleWorkerAssignmentIntents(sites: CaptureSite[], units: Unit[]): void {
    units.forEach((worker) => {
      const siteId = worker.activeResourceSiteId;
      if (!siteId) {
        return;
      }
      const site = sites.find((candidate) => candidate.id === siteId);
      if (!site || !site.alive || site.owner !== "player" || site.assignedWorkerId !== worker.id) {
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
  if (site.assignedWorkerId && site.assignedWorkerId !== worker.id) {
    return { ok: false, reason: `${site.definition.name} already has an assigned Worker.` };
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

function incomeBreakdownFor(site: CaptureSite): ResourceIncomeBreakdown {
  return {
    baseAmount: site.definition.incomeAmount,
    workerBonusAmount: site.workerAssignmentBoostActive ? workerSiteBonusAmount(site) : 0,
    assignedWorkerName: site.workerAssignmentBoostActive ? site.assignedWorkerName : undefined
  };
}

function resourceSiteAssignmentStatus(site: CaptureSite): string {
  if (site.owner === "neutral") {
    return "Neutral - capture before assigning a Worker";
  }
  if (site.owner === "enemy") {
    return "Enemy controlled - capture before assigning a Worker";
  }
  if (site.assignedWorkerName) {
    return site.workerAssignmentStatusDetail;
  }
  return "Captured - empty Worker slot";
}
