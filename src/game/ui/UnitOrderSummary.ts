import type { Position } from "../core/GameTypes";

export interface UnitOrderState {
  attackTargetId?: string;
  moveTarget?: Position;
  attackMove?: boolean;
}

export interface UnitOrderSummary {
  label: string;
  detail: string;
  tone: "active" | "neutral";
}

export function describeUnitOrder(unit: UnitOrderState): UnitOrderSummary {
  if (unit.attackTargetId) {
    return {
      label: "Attacking",
      detail: "Pursuing the targeted enemy; HP drops when in weapon range.",
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

  if (unit.moveTarget) {
    return {
      label: "Moving",
      detail: "Moving to the ordered point; use attack-move to fight along the route.",
      tone: "neutral"
    };
  }

  return {
    label: "Guarding",
    detail: "Holding position and engaging nearby threats.",
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
