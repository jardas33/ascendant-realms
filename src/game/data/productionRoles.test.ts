import { describe, expect, it } from "vitest";
import { BUILDING_BY_ID, UNIT_BY_ID, UPGRADE_BY_ID } from "./contentIndex";

describe("production role architecture", () => {
  it("keeps Command Hall as the Worker-only base hub", () => {
    const commandHall = BUILDING_BY_ID.command_hall;

    expect(commandHall.trainOptions).toEqual(["worker"]);
    expect(commandHall.buildOptions).toEqual([]);
    expect(commandHall.upgradeOptions).toEqual([]);
    expect(commandHall.trainOptions).not.toEqual(expect.arrayContaining(["militia", "ranger", "acolyte"]));
    expect(commandHall.upgradeOptions).not.toEqual(
      expect.arrayContaining(["infantry_weapons_1", "reinforced_armor_1", "ranger_training_1", "aether_study_1"])
    );
    expect(UNIT_BY_ID.worker.buildOptions).toEqual(["barracks", "mystic_lodge", "watchtower"]);
  });

  it("keeps Barracks as basic army production and research owner", () => {
    expect(BUILDING_BY_ID.barracks.trainOptions).toEqual(["militia", "ranger"]);
    expect(BUILDING_BY_ID.barracks.upgradeOptions).toEqual(["infantry_weapons_1", "reinforced_armor_1", "ranger_training_1"]);
    expect(UPGRADE_BY_ID.infantry_weapons_1.prerequisites?.buildingIds).toEqual(["barracks"]);
    expect(UPGRADE_BY_ID.reinforced_armor_1.prerequisites?.buildingIds).toEqual(["barracks"]);
    expect(UPGRADE_BY_ID.ranger_training_1.prerequisites?.buildingIds).toEqual(["barracks"]);
  });

  it("keeps Mystic Lodge and Watchtower on their completed-building roles", () => {
    expect(BUILDING_BY_ID.mystic_lodge.trainOptions).toEqual(["acolyte"]);
    expect(BUILDING_BY_ID.mystic_lodge.upgradeOptions).toEqual(["aether_study_1"]);
    expect(UPGRADE_BY_ID.aether_study_1.prerequisites?.buildingIds).toEqual(["mystic_lodge"]);

    expect(BUILDING_BY_ID.watchtower.trainOptions).toEqual([]);
    expect(BUILDING_BY_ID.watchtower.upgradeOptions).toEqual([]);
    expect(BUILDING_BY_ID.watchtower.attack).toEqual(
      expect.objectContaining({
        damage: 14,
        range: 220
      })
    );
  });
});
