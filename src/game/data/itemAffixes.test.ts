import { describe, expect, it } from "vitest";
import {
  generateItemAffixIds,
  getAffixCountForRarity,
  getItemAffixStatMods,
  getItemInstanceAffixes,
  getItemTotalStatMods,
  ITEM_AFFIXES
} from "./itemAffixes";
import { ITEM_BY_ID } from "./contentIndex";
import { createItemInstance } from "../core/HeroProgressionRules";

describe("item affixes", () => {
  it("uses compact rarity rules with deterministic counts for tests", () => {
    expect(getAffixCountForRarity("common", { deterministic: true })).toBe(1);
    expect(getAffixCountForRarity("uncommon", { deterministic: true })).toBe(1);
    expect(getAffixCountForRarity("rare", { deterministic: true })).toBe(2);
    expect(getAffixCountForRarity("epic", { deterministic: true })).toBe(2);
    expect(getAffixCountForRarity("legendary", { deterministic: true })).toBe(3);

    expect(getAffixCountForRarity("common", { rng: () => 0.99 })).toBe(0);
    expect(getAffixCountForRarity("rare", { rng: () => 0.1 })).toBe(2);
    expect(getAffixCountForRarity("rare", { rng: () => 0.9 })).toBe(1);
  });

  it("generates deterministic weighted affixes by item slot", () => {
    expect(ITEM_AFFIXES).toHaveLength(9);
    expect(generateItemAffixIds(ITEM_BY_ID.weathered_command_sword, { deterministic: true })).toEqual(["sharp"]);
    expect(generateItemAffixIds(ITEM_BY_ID.captains_seal, { deterministic: true })).toEqual(["sturdy", "guarding"]);
  });

  it("filters affixes to allowed item slots", () => {
    const armorAffixes = generateItemAffixIds(ITEM_BY_ID.marcher_plate, { deterministic: true, count: 5 });

    expect(armorAffixes).toContain("sturdy");
    expect(armorAffixes).not.toContain("sharp");
    expect(armorAffixes).not.toContain("rangers");
  });

  it("summarizes affix and total stat modifiers for item instances", () => {
    const instance = createItemInstance("weathered_command_sword", "test", "2026-05-01T00:00:00.000Z", {
      affixes: ["sharp", "rangers", "guarding"]
    });

    expect(getItemInstanceAffixes(ITEM_BY_ID.weathered_command_sword, instance).map((affix) => affix.id)).toEqual(["sharp", "rangers"]);
    expect(getItemAffixStatMods(ITEM_BY_ID.weathered_command_sword, instance)).toEqual({ damage: 2, range: 16 });
    expect(getItemTotalStatMods(ITEM_BY_ID.weathered_command_sword, instance)).toMatchObject({
      damage: 6,
      range: 16,
      might: 1,
      command: 1
    });
  });
});
