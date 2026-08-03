import type { ResourceBag, Team, UpgradeDefinition } from "../core/GameTypes";
import { addResources, payCost } from "../core/MathUtils";
import { requireUpgrade } from "../data/contentIndex";
import { Building } from "../entities/Building";
import { upgradeCommandAvailability, type CommandAvailabilityDecision } from "./CommandAvailability";
import type { TechState } from "./PrerequisiteSystem";

interface UpgradeSystemOptions {
  getTechState: (team: Team) => TechState;
  isResearched: (team: Team, upgradeId: string) => boolean;
  markResearched: (team: Team, upgradeId: string) => void;
  onMessage: (message: string, x?: number, y?: number, color?: string, options?: UpgradeSystemMessageOptions) => void;
  onUpgradeCompleted: (team: Team, upgrade: UpgradeDefinition) => void;
}

interface UpgradeSystemMessageOptions {
  durationSeconds?: number;
  priority?: "normal" | "command" | "pressure" | "objective";
}

export class UpgradeSystem {
  constructor(private readonly options: UpgradeSystemOptions) {}

  getUpgradeAvailability(building: Building, upgradeId: string, resources: ResourceBag): CommandAvailabilityDecision {
    return upgradeCommandAvailability(
      building,
      requireUpgrade(upgradeId),
      resources,
      this.options.getTechState(building.team),
      this.options.isResearched(building.team, upgradeId),
      building.upgradeQueue.some((entry) => entry.upgradeId === upgradeId)
    );
  }

  queueUpgrade(building: Building, upgradeId: string, resources: ResourceBag, options: { announce?: boolean } = {}): boolean {
    const upgrade = requireUpgrade(upgradeId);
    const announce = options.announce ?? building.team === "player";
    const availability = this.getUpgradeAvailability(building, upgradeId, resources);
    if (!availability.available) {
      if (announce) {
        this.options.onMessage(availability.reason ?? "Unavailable", building.position.x, building.position.y - 60, "#ffd27a", {
          priority: "command"
        });
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
      this.options.onMessage(`Research queued: ${upgrade.name}`, building.position.x, building.position.y - 60, "#d9eee8", {
        priority: "command"
      });
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
    this.options.onMessage(`Canceled ${upgrade.name}`, building.position.x, building.position.y - 60, "#ffd27a", {
      priority: "command"
    });
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
        this.options.onMessage(`${upgrade.name} complete`, building.position.x, building.position.y - 60, "#d9eee8", {
          priority: "command"
        });
      }
    });
  }
}
