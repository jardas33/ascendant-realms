import { describe, expect, it } from "vitest";
import { UPGRADE_BY_ID } from "../data/contentIndex";
import type { Unit } from "../entities/Unit";
import { applyUpgradeToUnit } from "./UpgradeEffects";

describe("applyUpgradeToUnit", () => {
  it("applies damage and armor effects once", () => {
    const militia = fakeUnit("militia", 1);

    expect(applyUpgradeToUnit(militia, UPGRADE_BY_ID.infantry_weapons_1)).toBe(true);
    expect(militia.upgradeDamageMultiplier).toBeCloseTo(1.1);

    expect(applyUpgradeToUnit(militia, UPGRADE_BY_ID.reinforced_armor_1)).toBe(true);
    expect(militia.armor).toBe(2);

    expect(applyUpgradeToUnit(militia, UPGRADE_BY_ID.reinforced_armor_1)).toBe(false);
    expect(militia.armor).toBe(2);
  });

  it("applies ranger training range and cooldown modifiers", () => {
    const ranger = fakeUnit("ranger", 0);

    expect(applyUpgradeToUnit(ranger, UPGRADE_BY_ID.ranger_training_1)).toBe(true);

    expect(ranger.upgradeRangeMultiplier).toBeCloseTo(1.1);
    expect(ranger.upgradeAttackCooldownMultiplier).toBeCloseTo(0.9);
  });
});

function fakeUnit(unitId: string, armor: number): Unit {
  return {
    definition: { id: unitId },
    upgradeDamageMultiplier: 1,
    upgradeRangeMultiplier: 1,
    upgradeAttackCooldownMultiplier: 1,
    armor,
    appliedUpgradeIds: new Set<string>()
  } as unknown as Unit;
}
