import { describe, expect, it } from "vitest";
import { BUILDING_BY_ID, UPGRADE_BY_ID } from "./contentIndex";
import { UPGRADES } from "./upgrades";

describe("tech tree foundation", () => {
  it("gives every upgrade owner, category, tier, cost, prerequisite, and readable effect text", () => {
    UPGRADES.forEach((upgrade) => {
      expect(upgrade.ownerBuildingId, `${upgrade.id} owner`).toBeTruthy();
      expect(upgrade.category, `${upgrade.id} category`).toBeTruthy();
      expect(upgrade.tier, `${upgrade.id} tier`).toBeGreaterThan(0);
      expect(upgrade.prerequisites, `${upgrade.id} prerequisites`).toBeTruthy();
      expect(upgrade.effectSummary.trim(), `${upgrade.id} effect summary`).not.toBe("");
      expect(upgrade.cost, `${upgrade.id} cost`).toBeDefined();
    });
  });

  it("keeps the first player tech layer small and building-owned", () => {
    expect(BUILDING_BY_ID.command_hall.upgradeOptions).toEqual(["camp_foundations_1"]);
    expect(BUILDING_BY_ID.barracks.upgradeOptions).toEqual([
      "infantry_weapons_1",
      "reinforced_armor_1",
      "ranger_training_1"
    ]);
    expect(BUILDING_BY_ID.mystic_lodge.upgradeOptions).toEqual(["aether_study_1"]);
    expect(BUILDING_BY_ID.watchtower.upgradeOptions).toEqual(["sentry_bracing_1"]);

    const playerUpgradeIds = [
      ...BUILDING_BY_ID.command_hall.upgradeOptions,
      ...BUILDING_BY_ID.barracks.upgradeOptions,
      ...BUILDING_BY_ID.mystic_lodge.upgradeOptions,
      ...BUILDING_BY_ID.watchtower.upgradeOptions
    ];
    expect(playerUpgradeIds).toHaveLength(6);
    playerUpgradeIds.forEach((upgradeId) => {
      const upgrade = UPGRADE_BY_ID[upgradeId];
      expect(BUILDING_BY_ID[upgrade.ownerBuildingId].upgradeOptions).toContain(upgradeId);
    });
  });

  it("adds only one safe prerequisite link for the new defensive tower upgrade", () => {
    expect(UPGRADE_BY_ID.camp_foundations_1.prerequisites).toEqual({ buildingIds: ["command_hall"] });
    expect(UPGRADE_BY_ID.sentry_bracing_1.prerequisites).toEqual({
      buildingIds: ["watchtower"],
      upgradeIds: ["camp_foundations_1"]
    });
  });
});
