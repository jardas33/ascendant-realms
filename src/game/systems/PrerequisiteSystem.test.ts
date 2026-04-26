import { describe, expect, it } from "vitest";
import { checkPrerequisites } from "./PrerequisiteSystem";

describe("checkPrerequisites", () => {
  it("accepts completed buildings and researched upgrades", () => {
    expect(
      checkPrerequisites(
        { buildingIds: ["barracks"], upgradeIds: ["infantry_weapons_1"], heroLevel: 2 },
        {
          completedBuildingIds: new Set(["command_hall", "barracks"]),
          researchedUpgradeIds: new Set(["infantry_weapons_1"]),
          heroLevel: 3
        }
      )
    ).toEqual({ ok: true });
  });

  it("returns readable lock reasons", () => {
    expect(
      checkPrerequisites(
        { buildingIds: ["mystic_lodge"] },
        {
          completedBuildingIds: new Set(["command_hall"]),
          researchedUpgradeIds: new Set(),
          heroLevel: 1
        }
      )
    ).toEqual({ ok: false, reason: "Requires Mystic Lodge" });
  });
});
