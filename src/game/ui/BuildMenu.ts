import type { Cost } from "../core/GameTypes";

export function formatCost(cost: Cost): string {
  const parts = [
    cost.crowns ? `${cost.crowns} Crowns` : "",
    cost.stone ? `${cost.stone} Stone` : "",
    cost.iron ? `${cost.iron} Iron` : "",
    cost.aether ? `${cost.aether} Aether` : ""
  ].filter(Boolean);
  return parts.length > 0 ? parts.join(", ") : "Free";
}
