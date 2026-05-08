import { describe, expect, it } from "vitest";
import { createFallbackCampaignSave, createFallbackHeroSave } from "../../../src/game/save/SaveSystem";
import {
  cloneFixture,
  expectCampaignResources,
  expectHeroCore,
  expectNoFixtureCrash,
  migrateSaveObjectToCurrent,
  saveFixturePath
} from "./SaveFixtureTestUtils";

describe("SaveFixtureTestUtils", () => {
  it("deep clones fixture-shaped data before migration tests mutate it", () => {
    const source = {
      nested: {
        values: ["border_village"]
      }
    };

    const clone = cloneFixture(source);
    clone.nested.values.push("old_stone_road");

    expect(source.nested.values).toEqual(["border_village"]);
    expect(clone.nested.values).toEqual(["border_village", "old_stone_road"]);
  });

  it("passes inline save-shaped data through the current migration path", () => {
    const input = {
      version: 2,
      createdAt: "2026-05-08T00:00:00.000Z",
      updatedAt: "2026-05-08T00:00:00.000Z",
      hero: {
        ...createFallbackHeroSave(),
        heroName: "Fixture Scout",
        xp: 125
      },
      campaign: {
        ...createFallbackCampaignSave(),
        started: true,
        resources: { crowns: 40, stone: 12, iron: 7, aether: 3 }
      },
      settings: undefined,
      statistics: { fixtureHarness: true }
    };

    const migrated = expectNoFixtureCrash("inline V2 fixture migration", () => migrateSaveObjectToCurrent(input));

    expectHeroCore(migrated, { heroName: "Fixture Scout", xp: 125 });
    expectCampaignResources(migrated, { crowns: 40, stone: 12, iron: 7, aether: 3 });
    expect(migrated?.statistics).toEqual({ fixtureHarness: true });
  });

  it("rejects unsafe fixture path traversal", () => {
    expect(() => saveFixturePath("../outside.json")).toThrow("plain filename");
  });
});
