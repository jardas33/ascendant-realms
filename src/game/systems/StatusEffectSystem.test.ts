import { describe, expect, it, vi } from "vitest";
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

  it("keeps empty and non-expiring status arrays stable", () => {
    const emptyEffects: ActiveStatusEffect[] = [];
    const emptyTarget = { statusEffects: emptyEffects, updateStatusVisual: vi.fn() };

    expect(tickStatusEffects(emptyTarget, 0.25)).toEqual([]);
    expect(emptyTarget.statusEffects).toBe(emptyEffects);
    expect(emptyTarget.updateStatusVisual).not.toHaveBeenCalled();

    const activeEffects = [createBurnStatus({ damagePerSecond: 0, durationSeconds: 5, tickInterval: 1 })];
    const activeTarget = { statusEffects: activeEffects, updateStatusVisual: vi.fn() };

    expect(tickStatusEffects(activeTarget, 0.25)).toEqual([]);
    expect(activeTarget.statusEffects).toBe(activeEffects);
    expect(activeTarget.updateStatusVisual).toHaveBeenCalledTimes(1);
  });
});
