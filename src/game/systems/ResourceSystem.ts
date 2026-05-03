import { CAPTURE_TIME_SECONDS } from "../core/Constants";
import type { CaptureSiteFirstCaptureBonusDefinition, ResourceBag, Team } from "../core/GameTypes";
import { addResources, distance } from "../core/MathUtils";
import { CaptureSite } from "../entities/CaptureSite";
import type { Unit } from "../entities/Unit";

interface ResourceSystemOptions {
  resources: Record<"player" | "enemy", ResourceBag>;
  onCapture: (site: CaptureSite, newOwner: Team) => void;
  onIncome: (site: CaptureSite, owner: Team, amount: number) => void;
  onCaptureBonus?: (site: CaptureSite, owner: Team, bonus: CaptureSiteFirstCaptureBonusDefinition) => void;
}

export class ResourceSystem {
  private readonly claimedFirstCaptureBonuses = new Set<string>();

  constructor(private readonly options: ResourceSystemOptions) {}

  update(deltaSeconds: number, sites: CaptureSite[], units: Unit[]): void {
    sites.forEach((site) => {
      this.updateCapture(deltaSeconds, site, units);
      this.updateIncome(deltaSeconds, site);
      site.updateVisuals();
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
    ownerResources[site.definition.resource] += site.definition.incomeAmount;
    this.options.onIncome(site, site.owner, site.definition.incomeAmount);
  }

  private applyFirstCaptureBonus(site: CaptureSite, owner: Team): void {
    if (owner !== "player" && owner !== "enemy") {
      return;
    }
    const bonus = site.definition.firstCaptureBonus;
    if (!bonus) {
      return;
    }
    const claimId = `${site.definition.id}:${owner}:${bonus.id}`;
    if (this.claimedFirstCaptureBonuses.has(claimId)) {
      return;
    }

    this.claimedFirstCaptureBonuses.add(claimId);
    addResources(this.options.resources[owner], bonus.resources);
    this.options.onCaptureBonus?.(site, owner, bonus);
  }
}
