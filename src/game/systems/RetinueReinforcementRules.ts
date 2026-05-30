import type { Cost, ResourceBag } from "../core/GameTypes";
import { canAfford } from "../core/MathUtils";
import { isRetinueEligibleUnitTypeId } from "../core/RetinueRules";
import type { BattleLaunchMode, BattleLaunchModifier } from "../battle/BattleLaunchRequest";
import { getTacticalPlanBattleEffects } from "../data/tacticalPlans";
import type { RetinueUnitSaveData } from "../save/SaveTypes";

export const RETINUE_REINFORCEMENT_COST: Cost = { crowns: 75 };

export interface RetinueReinforcementState {
  mode: BattleLaunchMode;
  rewardsDisabled?: boolean;
  alreadyUsed?: boolean;
  commandHallAlive?: boolean;
  resources: ResourceBag;
  reserveUnits: readonly RetinueUnitSaveData[];
  modifiers?: readonly BattleLaunchModifier[];
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

export function retinueReinforcementCost(modifiers: readonly BattleLaunchModifier[] = []): Cost {
  const multiplier = getTacticalPlanBattleEffects(modifiers).retinueReinforcementCostMultiplier;
  return {
    crowns: Math.max(1, Math.round((RETINUE_REINFORCEMENT_COST.crowns ?? 0) * multiplier))
  };
}

export function evaluateRetinueReinforcement(state: RetinueReinforcementState): RetinueReinforcementAvailability {
  const readyReserveCount = readyReinforcementReserveUnits(state.reserveUnits).length;
  const cost = retinueReinforcementCost(state.modifiers);
  const base = {
    cost,
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
  if (!canAfford(state.resources, cost)) {
    return { ...base, ok: false, reason: "Insufficient Crowns" };
  }
  return { ...base, ok: true };
}
