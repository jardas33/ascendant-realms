import { describe, expect, it } from "vitest";
import type { RetinueUnitSaveData } from "../save/SaveTypes";
import {
  RETINUE_REINFORCEMENT_COST,
  evaluateRetinueReinforcement,
  retinueReinforcementCost,
  selectRetinueReinforcementUnit
} from "./RetinueReinforcementRules";

const readyReserve: RetinueUnitSaveData = {
  retinueUnitId: "retinue:test:ranger",
  unitTypeId: "ranger",
  name: "Old Road Ranger",
  rank: "veteran",
  xp: 140,
  kills: 3,
  sourceBattleId: "old_stone_road",
  acquiredAt: "2026-05-02T12:00:00.000Z",
  status: "active"
};

describe("RetinueReinforcementRules", () => {
  it("allows one campaign reinforcement when a Ready reserve and Crowns are available", () => {
    const result = evaluateRetinueReinforcement({
      mode: "campaign_node",
      resources: { crowns: 75, stone: 0, iron: 0, aether: 0 },
      reserveUnits: [readyReserve],
      commandHallAlive: true
    });

    expect(result).toMatchObject({
      ok: true,
      cost: RETINUE_REINFORCEMENT_COST,
      reserveCount: 1,
      readyReserveCount: 1
    });
    expect(selectRetinueReinforcementUnit([readyReserve])?.retinueUnitId).toBe("retinue:test:ranger");
  });

  it("uses Guarded Advance to modestly reduce the one-use reinforcement cost", () => {
    const result = evaluateRetinueReinforcement({
      mode: "campaign_node",
      resources: { crowns: 60, stone: 0, iron: 0, aether: 0 },
      reserveUnits: [readyReserve],
      commandHallAlive: true,
      modifiers: [{ id: "tactical_guarded_advance" }]
    });

    expect(retinueReinforcementCost([{ id: "tactical_guarded_advance" }])).toEqual({ crowns: 60 });
    expect(result).toMatchObject({
      ok: true,
      cost: { crowns: 60 }
    });
  });

  it("blocks tutorial, repeat use, destroyed base, insufficient Crowns, and recovering reserves", () => {
    const base = {
      mode: "campaign_node" as const,
      resources: { crowns: 75, stone: 0, iron: 0, aether: 0 },
      reserveUnits: [readyReserve],
      commandHallAlive: true
    };

    expect(evaluateRetinueReinforcement({ ...base, mode: "tutorial", rewardsDisabled: true })).toMatchObject({
      ok: false,
      reason: "Campaign battle only"
    });
    expect(evaluateRetinueReinforcement({ ...base, alreadyUsed: true })).toMatchObject({
      ok: false,
      reason: "Already used this battle"
    });
    expect(evaluateRetinueReinforcement({ ...base, commandHallAlive: false })).toMatchObject({
      ok: false,
      reason: "Command Hall destroyed"
    });
    expect(evaluateRetinueReinforcement({ ...base, resources: { crowns: 74, stone: 0, iron: 0, aether: 0 } })).toMatchObject({
      ok: false,
      reason: "Insufficient Crowns"
    });
    expect(
      evaluateRetinueReinforcement({
        ...base,
        reserveUnits: [{ ...readyReserve, status: "recovering", recoveryMissionsRemaining: 1 }]
      })
    ).toMatchObject({
      ok: false,
      reason: "No Ready reserve Retinue"
    });
  });
});
