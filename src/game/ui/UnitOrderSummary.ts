import type { Position } from "../core/GameTypes";
import { behaviourModeDefinition, normalizeBehaviourMode, type BehaviourMode } from "../systems/BehaviourModeSystem";

export interface UnitOrderState {
  alive?: boolean;
  team?: "player" | "enemy" | "neutral";
  attackTargetId?: string;
  attackTargetLabel?: string;
  moveTarget?: Position;
  attackMove?: boolean;
  activeRepairTargetId?: string;
  pausedRepairTargetId?: string;
  activeConstructionSiteId?: string;
  pausedConstructionSiteId?: string;
  activeResourceSiteId?: string;
  activeResourceSiteLabel?: string;
  moveOrderCombatSuppressionSeconds?: number;
  behaviourMode?: BehaviourMode;
  patrolRoute?: unknown;
}

export interface UnitOrderIntent {
  kind: "target" | "destination";
  label: string;
  /** Stable in-memory comparison key; never render this value to players. */
  key: string;
}

export interface UnitOrderSummary {
  label: string;
  detail: string;
  tone: "active" | "neutral";
  intent?: UnitOrderIntent;
}

function orderIntent(unit: UnitOrderState): UnitOrderIntent | undefined {
  if (unit.team === "enemy" || unit.alive === false) {
    return undefined;
  }
  if (unit.attackTargetId) {
    return {
      kind: "target",
      label: unit.attackTargetLabel ?? "Target unavailable",
      key: `attack:${unit.attackTargetId}`
    };
  }
  if (unit.activeRepairTargetId || unit.pausedRepairTargetId) {
    return {
      kind: "target",
      label: "Repair target",
      key: `repair:${unit.activeRepairTargetId ?? unit.pausedRepairTargetId}`
    };
  }
  if (unit.activeConstructionSiteId || unit.pausedConstructionSiteId) {
    return {
      kind: "target",
      label: "Build site",
      key: `build:${unit.activeConstructionSiteId ?? unit.pausedConstructionSiteId}`
    };
  }
  if (unit.activeResourceSiteId) {
    return {
      kind: "target",
      label: unit.activeResourceSiteLabel ?? "Resource site",
      key: `resource:${unit.activeResourceSiteId}`
    };
  }
  if (unit.patrolRoute && unit.moveTarget) {
    return {
      kind: "destination",
      label: "Patrol point",
      key: `patrol:${unit.moveTarget.x}:${unit.moveTarget.y}`
    };
  }
  if (unit.moveTarget) {
    return {
      kind: "destination",
      label: "Map destination",
      key: `move:${unit.moveTarget.x}:${unit.moveTarget.y}`
    };
  }
  return undefined;
}

export function describeUnitOrder(unit: UnitOrderState): UnitOrderSummary {
  if (unit.alive === false) {
    return {
      label: "Unavailable",
      detail: "This unit is destroyed and has no actionable order.",
      tone: "neutral"
    };
  }

  if (unit.team === "enemy") {
    return {
      label: "Activity hidden",
      detail: "Enemy orders are not shown in the player HUD.",
      tone: "neutral"
    };
  }

  if (unit.attackTargetId) {
    const target = unit.attackTargetLabel ? ` Target: ${unit.attackTargetLabel}.` : "";
    return {
      label: "Attacking",
      detail: `${target} Pursuing until in weapon range; HP drops when attacks land.`.trim(),
      tone: "active",
      intent: orderIntent(unit)
    };
  }

  if (unit.moveTarget && unit.attackMove) {
    if (unit.patrolRoute) {
      return {
        label: "Patrolling",
        detail: "Moving between the patrol point and origin; fights nearby enemies by current behavior.",
        tone: "active",
        intent: orderIntent(unit)
      };
    }
    return {
      label: "Attack-moving",
      detail: "Moving while engaging enemies along the route.",
      tone: "active",
      intent: orderIntent(unit)
    };
  }

  if (unit.activeRepairTargetId) {
    return {
      label: unit.moveTarget ? "Traveling to Repair" : "Repairing",
      detail: unit.moveTarget
        ? "Worker is traveling to the damaged building; repair begins when it arrives."
        : "Restoring a friendly completed building; Worker must stay near the footprint.",
      tone: "active",
      intent: orderIntent(unit)
    };
  }

  if (unit.activeConstructionSiteId) {
    return {
      label: unit.moveTarget ? "Traveling to Build" : "Building",
      detail: unit.moveTarget
        ? "Worker is traveling to the construction site; progress resumes when it arrives."
        : "Worker is building or finishing this construction site.",
      tone: "active",
      intent: orderIntent(unit)
    };
  }

  if (unit.activeResourceSiteId) {
    const site = unit.activeResourceSiteLabel ? ` Site: ${unit.activeResourceSiteLabel}.` : "";
    const moving = unit.moveTarget ? " Moving to the assigned site; bonus starts when the Worker is in range." : "";
    return {
      label: unit.moveTarget ? "Moving to Assigned Site" : "Assigned to Site",
      detail: `${site}${moving || " Boosting captured-site income while assigned and nearby."}`.trim(),
      tone: "active",
      intent: orderIntent(unit)
    };
  }

  if (unit.pausedRepairTargetId) {
    return {
      label: "Repair Paused",
      detail: "Issue Repair again on the damaged building to resume.",
      tone: "neutral",
      intent: orderIntent(unit)
    };
  }

  if (unit.pausedConstructionSiteId) {
    return {
      label: "Construction Paused",
      detail: "Issue Build/Resume on the construction site, or right-click it with a Worker, to continue.",
      tone: "neutral",
      intent: orderIntent(unit)
    };
  }

  if (unit.moveTarget) {
    if ((unit.moveOrderCombatSuppressionSeconds ?? 0) > 0) {
      return {
        label: "Repositioning",
        detail: "Retreat or move order is taking priority; target reacquisition waits briefly.",
        tone: "active",
        intent: orderIntent(unit)
      };
    }
    return {
      label: "Moving",
      detail: "Moving to the ordered point; use attack-move to fight along the route.",
      tone: "neutral",
      intent: orderIntent(unit)
    };
  }

  const mode = normalizeBehaviourMode(unit.behaviourMode);
  if (mode === "hold_ground") {
    return {
      label: "Holding Ground",
      detail: behaviourModeDefinition(mode).orderDetail,
      tone: "neutral"
    };
  }
  if (mode === "press_attack") {
    return {
      label: "Pressing Attack",
      detail: behaviourModeDefinition(mode).orderDetail,
      tone: "active"
    };
  }

  return {
    label: "Guarding",
    detail: behaviourModeDefinition(mode).orderDetail,
    tone: "neutral"
  };
}

export function summarizeUnitOrders(units: UnitOrderState[]): string {
  const counts = units.reduce<Record<string, number>>((summary, unit) => {
    const label = describeUnitOrder(unit).label;
    summary[label] = (summary[label] ?? 0) + 1;
    return summary;
  }, {});

  return Object.entries(counts)
    .map(([label, count]) => `${count} ${label}`)
    .join(", ");
}
