import type { Cost, ResourceBag } from "../core/GameTypes";
import { canAfford } from "../core/MathUtils";
import { isRetinueEligibleUnitTypeId } from "../core/RetinueRules";
import type { BattleLaunchMode } from "../battle/BattleLaunchRequest";
import type { RetinueUnitSaveData } from "../save/SaveTypes";

export const RETINUE_REINFORCEMENT_COST: Cost = { crowns: 75 };

export interface RetinueReinforcementState {
  mode: BattleLaunchMode;
  rewardsDisabled?: boolean;
  alreadyUsed?: boolean;
  commandHallAlive?: boolean;
  resources: ResourceBag;
  reserveUnits: readonly RetinueUnitSaveData[];
}

export interface RetinueReinforcementAvailability {
  ok: boolean;
  reason?: string;
  cost: Cost;
  reserveCount: number;
  readyReserveCount: number;
  used: boolean;
}

export function readyReinforcementReserveUnits(units: readonly RetinueUnitSaveData[]): RetinueUnitSaveData[] {
  return units.filter(
    (unit) => unit.status === "active" && isRetinueEligibleUnitTypeId(unit.unitTypeId)
  );
}

export function selectRetinueReinforcementUnit(units: readonly RetinueUnitSaveData[]): RetinueUnitSaveData | undefined {
  return readyReinforcementReserveUnits(units)[0];
}

export function evaluateRetinueReinforcement(state: RetinueReinforcementState): RetinueReinforcementAvailability {
  const readyReserveCount = readyReinforcementReserveUnits(state.reserveUnits).length;
  const base = {
    cost: RETINUE_REINFORCEMENT_COST,
    reserveCount: state.reserveUnits.length,
    readyReserveCount,
    used: Boolean(state.alreadyUsed)
  };
  if (state.mode !== "campaign_node" || state.rewardsDisabled) {
    return { ...base, ok: false, reason: "Campaign battle only" };
  }
  if (state.alreadyUsed) {
    return { ...base, ok: false, reason: "Already used this battle" };
  }
  if (!state.commandHallAlive) {
    return { ...base, ok: false, reason: "Command Hall destroyed" };
  }
  if (readyReserveCount === 0) {
    return { ...base, ok: false, reason: "No Ready reserve Retinue" };
  }
  if (!canAfford(state.resources, RETINUE_REINFORCEMENT_COST)) {
    return { ...base, ok: false, reason: "Insufficient Crowns" };
  }
  return { ...base, ok: true };
}
