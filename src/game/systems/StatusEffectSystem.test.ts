import { describe, expect, it } from "vitest";
import type { ActiveStatusEffect } from "../core/GameTypes";
import { applyStatusEffect, createBurnStatus, tickStatusEffects } from "./StatusEffectSystem";

interface TestCarrier {
  statusEffects: ActiveStatusEffect[];
}

describe("StatusEffectSystem", () => {
  it("applies burn over timed intervals", () => {
    const target: TestCarrier = { statusEffects: [] };
    applyStatusEffect(
      target,
      createBurnStatus({
        damagePerSecond: 3,
        durationSeconds: 4,
        tickInterval: 1,
        sourceId: "hexer_1",
        sourceTeam: "enemy"
      })
    );

    expect(tickStatusEffects(target, 0.5)).toEqual([]);

    const firstTick = tickStatusEffects(target, 0.5);
    expect(firstTick).toEqual([
      {
        effectId: "burn",
        effectName: "Burn",
        damage: 3,
        sourceId: "hexer_1",
        sourceTeam: "enemy"
      }
    ]);

    const remainingTicks = tickStatusEffects(target, 3);
    expect(remainingTicks).toHaveLength(3);
    expect(remainingTicks.reduce((sum, tick) => sum + tick.damage, 0)).toBe(9);
    expect(target.statusEffects).toEqual([]);
  });

  it("refreshes matching status effects instead of duplicating them", () => {
    const target: TestCarrier = { statusEffects: [] };
    applyStatusEffect(target, createBurnStatus({ damagePerSecond: 2, durationSeconds: 2, tickInterval: 1, sourceId: "hexer_1" }));
    tickStatusEffects(target, 1);
    applyStatusEffect(target, createBurnStatus({ damagePerSecond: 4, durationSeconds: 4, tickInterval: 1, sourceId: "hexer_1" }));

    expect(target.statusEffects).toHaveLength(1);
    expect(target.statusEffects[0].remainingSeconds).toBe(4);
    expect(target.statusEffects[0].damagePerSecond).toBe(4);
  });
});
