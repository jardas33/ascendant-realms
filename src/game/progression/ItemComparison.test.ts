import { describe, expect, it } from "vitest";
import { createItemInstance } from "../core/HeroProgressionRules";
import { HERO_CLASS_BY_ID, ITEM_BY_ID, ORIGIN_BY_ID, SKILL_NODE_BY_ID } from "../data/contentIndex";
import { createNewHeroSave } from "../data/heroes";
import { formatItemAffixes, formatItemAffixStats, formatItemBaseStats, formatItemTotalStats, formatStatMods, previewEquipDelta } from "./ItemComparison";

const catalogs = {
  heroClassById: HERO_CLASS_BY_ID,
  originById: ORIGIN_BY_ID,
  skillNodeById: SKILL_NODE_BY_ID,
  itemById: ITEM_BY_ID
};

describe("item comparison presentation helpers", () => {
  it("formats stat modifiers with existing labels and signs", () => {
    expect(formatStatMods({ maxHp: 36, armor: 2, speed: -4 })).toBe("+36 HP, +2 armor, -4 speed");
    expect(formatStatMods({})).toBe("No stat modifiers");
  });

  it("previews the stat delta for equipping an owned item", () => {
    const instance = createItemInstance("weathered_command_sword", "test");
    const hero = {
      ...createNewHeroSave("Mira", "warlord", "exiled_noble"),
      inventory: [instance]
    };

    expect(previewEquipDelta(hero, ITEM_BY_ID.weathered_command_sword, false, catalogs)).toBe("Preview: +4 damage, +1 might, +1 command");
  });

  it("formats affix names, affix stats, and total item stats", () => {
    const instance = createItemInstance("weathered_command_sword", "test", "2026-05-01T00:00:00.000Z", {
      affixes: ["sharp"]
    });
    const hero = {
      ...createNewHeroSave("Mira", "warlord", "exiled_noble"),
      inventory: [instance]
    };

    expect(formatItemAffixes(ITEM_BY_ID.weathered_command_sword, instance)).toBe("Affixes: Sharp");
    expect(formatItemBaseStats(ITEM_BY_ID.weathered_command_sword)).toBe("Base: +4 damage, +1 might, +1 command");
    expect(formatItemAffixStats(ITEM_BY_ID.weathered_command_sword, instance)).toBe("Affix stats: +2 damage");
    expect(formatItemTotalStats(ITEM_BY_ID.weathered_command_sword, instance)).toBe("Total: +6 damage, +1 might, +1 command");
    expect(previewEquipDelta(hero, ITEM_BY_ID.weathered_command_sword, false, catalogs, instance.instanceId)).toBe(
      "Preview: +6 damage, +1 might, +1 command"
    );
  });

  it("keeps equipped and missing item preview messages stable", () => {
    const instance = createItemInstance("weathered_command_sword", "test");
    const hero = {
      ...createNewHeroSave("Mira", "warlord", "exiled_noble"),
      inventory: [instance],
      equipment: { weapon: instance.instanceId }
    };
    const emptyInventoryHero = createNewHeroSave("Mira", "warlord", "exiled_noble");

    expect(previewEquipDelta(hero, ITEM_BY_ID.weathered_command_sword, true, catalogs)).toBe("Currently equipped.");
    expect(previewEquipDelta(emptyInventoryHero, ITEM_BY_ID.weathered_command_sword, false, catalogs)).toBe("Item is not in this hero's inventory.");
  });
});
