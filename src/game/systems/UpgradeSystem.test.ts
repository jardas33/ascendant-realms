import { describe, expect, it, vi } from "vitest";
import type { ResourceBag } from "../core/GameTypes";
import type { Building } from "../entities/Building";
import { UpgradeSystem } from "./UpgradeSystem";

describe("UpgradeSystem", () => {
  it("pays immediately, researches over time, and marks completion", () => {
    const researched = new Set<string>();
    const completed = vi.fn();
    const messages = vi.fn();
    const resources: ResourceBag = { crowns: 200, stone: 0, iron: 100, aether: 0 };
    const building = fakeBuilding("barracks", ["infantry_weapons_1"]);
    const system = new UpgradeSystem({
      getTechState: () => ({
        completedBuildingIds: new Set(["command_hall", "barracks"]),
        researchedUpgradeIds: researched,
        heroLevel: 1
      }),
      isResearched: (_team, upgradeId) => researched.has(upgradeId),
      markResearched: (_team, upgradeId) => researched.add(upgradeId),
      onMessage: messages,
      onUpgradeCompleted: completed
    });

    expect(system.queueUpgrade(building, "infantry_weapons_1", resources)).toBe(true);
    expect(resources).toEqual({ crowns: 80, stone: 0, iron: 30, aether: 0 });
    expect(building.upgradeQueue).toHaveLength(1);

    system.update(18, [building]);

    expect(researched.has("infantry_weapons_1")).toBe(true);
    expect(building.upgradeQueue).toHaveLength(0);
    expect(completed).toHaveBeenCalledOnce();
  });
});

function fakeBuilding(buildingId: string, upgradeOptions: string[]): Building {
  return {
    id: `player_${buildingId}`,
    alive: true,
    team: "player",
    position: { x: 260, y: 800 },
    definition: { id: buildingId, upgradeOptions },
    upgradeQueue: [],
    isCompleted: () => true
  } as unknown as Building;
}
