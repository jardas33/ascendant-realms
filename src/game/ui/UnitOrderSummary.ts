import type { Position } from "../core/GameTypes";
import { behaviourModeDefinition, normalizeBehaviourMode, type BehaviourMode } from "../systems/BehaviourModeSystem";

export interface UnitOrderState {
  attackTargetId?: string;
  attackTargetLabel?: string;
  moveTarget?: Position;
  attackMove?: boolean;
  activeRepairTargetId?: string;
  pausedRepairTargetId?: string;
  moveOrderCombatSuppressionSeconds?: number;
  behaviourMode?: BehaviourMode;
}

export interface UnitOrderSummary {
  label: string;
  detail: string;
  tone: "active" | "neutral";
}

export function describeUnitOrder(unit: UnitOrderState): UnitOrderSummary {
  if (unit.attackTargetId) {
    const target = unit.attackTargetLabel ? ` Target: ${unit.attackTargetLabel}.` : "";
    return {
      label: "Attacking",
      detail: `${target} Pursuing until in weapon range; HP drops when attacks land.`.trim(),
      tone: "active"
    };
  }

  if (unit.moveTarget && unit.attackMove) {
    return {
      label: "Attack-moving",
      detail: "Moving while engaging enemies along the route.",
      tone: "active"
    };
  }

  if (unit.activeRepairTargetId) {
    return {
      label: "Repairing",
      detail: "Restoring a friendly completed building; Worker must stay near the footprint.",
      tone: "active"
    };
  }

  if (unit.pausedRepairTargetId) {
    return {
      label: "Repair Paused",
      detail: "Move the Worker back near the damaged building or issue Repair again to resume.",
      tone: "neutral"
    };
  }

  if (unit.moveTarget) {
    if ((unit.moveOrderCombatSuppressionSeconds ?? 0) > 0) {
      return {
        label: "Repositioning",
        detail: "Retreat or move order is taking priority; target reacquisition waits briefly.",
        tone: "active"
      };
    }
    return {
      label: "Moving",
      detail: "Moving to the ordered point; use attack-move to fight along the route.",
      tone: "neutral"
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
