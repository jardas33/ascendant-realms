import type { ResourceBag, Team, UpgradeDefinition } from "../core/GameTypes";
import { addResources, canAfford, payCost } from "../core/MathUtils";
import { requireUpgrade } from "../data/contentIndex";
import { Building } from "../entities/Building";
import { checkPrerequisites, type TechState } from "./PrerequisiteSystem";

interface UpgradeSystemOptions {
  getTechState: (team: Team) => TechState;
  isResearched: (team: Team, upgradeId: string) => boolean;
  markResearched: (team: Team, upgradeId: string) => void;
  onMessage: (message: string, x?: number, y?: number) => void;
  onUpgradeCompleted: (team: Team, upgrade: UpgradeDefinition) => void;
}

export class UpgradeSystem {
  constructor(private readonly options: UpgradeSystemOptions) {}

  queueUpgrade(building: Building, upgradeId: string, resources: ResourceBag, options: { announce?: boolean } = {}): boolean {
    const upgrade = requireUpgrade(upgradeId);
    const announce = options.announce ?? building.team === "player";
    if (!building.isCompleted()) {
      if (announce) {
        this.options.onMessage("Construction must finish first", building.position.x, building.position.y - 60);
      }
      return false;
    }
    if (!building.definition.upgradeOptions.includes(upgradeId)) {
      return false;
    }
    if (this.options.isResearched(building.team, upgradeId)) {
      if (announce) {
        this.options.onMessage("Upgrade already researched", building.position.x, building.position.y - 60);
      }
      return false;
    }
    if (building.upgradeQueue.some((entry) => entry.upgradeId === upgradeId)) {
      if (announce) {
        this.options.onMessage("Upgrade already queued", building.position.x, building.position.y - 60);
      }
      return false;
    }
    const prerequisite = checkPrerequisites(upgrade.prerequisites, this.options.getTechState(building.team));
    if (!prerequisite.ok) {
      if (announce) {
        this.options.onMessage(prerequisite.reason ?? "Locked", building.position.x, building.position.y - 60);
      }
      return false;
    }
    if (!canAfford(resources, upgrade.cost)) {
      if (announce) {
        this.options.onMessage("Not enough resources", building.position.x, building.position.y - 60);
      }
      return false;
    }

    payCost(resources, upgrade.cost);
    building.upgradeQueue.push({
      upgradeId,
      remaining: upgrade.researchTimeSeconds,
      total: upgrade.researchTimeSeconds,
      announce,
      paidCost: { ...upgrade.cost }
    });
    if (announce) {
      this.options.onMessage(`Researching ${upgrade.name}`, building.position.x, building.position.y - 60);
    }
    return true;
  }

  cancelUpgrade(building: Building, queueIndex: number, resources: ResourceBag): boolean {
    if (queueIndex < 0 || queueIndex >= building.upgradeQueue.length) {
      return false;
    }
    const [canceled] = building.upgradeQueue.splice(queueIndex, 1);
    if (!canceled) {
      return false;
    }
    addResources(resources, canceled.paidCost);
    const upgrade = requireUpgrade(canceled.upgradeId);
    this.options.onMessage(`Canceled ${upgrade.name}`, building.position.x, building.position.y - 60);
    return true;
  }

  update(deltaSeconds: number, buildings: Building[]): void {
    buildings.forEach((building) => {
      if (!building.alive || !building.isCompleted() || building.upgradeQueue.length === 0) {
        return;
      }

      const active = building.upgradeQueue[0];
      active.remaining -= deltaSeconds;
      if (active.remaining > 0) {
        return;
      }

      building.upgradeQueue.shift();
      const upgrade = requireUpgrade(active.upgradeId);
      if (!this.options.isResearched(building.team, upgrade.id)) {
        this.options.markResearched(building.team, upgrade.id);
        this.options.onUpgradeCompleted(building.team, upgrade);
      }
      if (active.announce) {
        this.options.onMessage(`${upgrade.name} complete`, building.position.x, building.position.y - 60);
      }
    });
  }
}
