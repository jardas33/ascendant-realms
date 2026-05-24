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

  it("does not queue research from incomplete buildings", () => {
    const resources: ResourceBag = { crowns: 200, stone: 0, iron: 100, aether: 0 };
    const building = fakeBuilding("barracks", ["infantry_weapons_1"], false);
    const messages = vi.fn();
    const system = createUpgradeSystem({ messages });

    expect(system.queueUpgrade(building, "infantry_weapons_1", resources)).toBe(false);
    expect(resources).toEqual({ crowns: 200, stone: 0, iron: 100, aether: 0 });
    expect(building.upgradeQueue).toHaveLength(0);
    expect(messages).toHaveBeenCalledWith("Construction must finish first", 260, 740, "#ffd27a", { priority: "command" });
  });

  it("keeps prerequisite-locked upgrades unqueued until prerequisite research completes", () => {
    const researched = new Set<string>();
    const resources: ResourceBag = { crowns: 300, stone: 300, iron: 100, aether: 0 };
    const watchtower = fakeBuilding("watchtower", ["sentry_bracing_1"]);
    const system = createUpgradeSystem({
      researched,
      completedBuildingIds: new Set(["command_hall", "watchtower"])
    });

    expect(system.queueUpgrade(watchtower, "sentry_bracing_1", resources)).toBe(false);
    expect(watchtower.upgradeQueue).toHaveLength(0);

    researched.add("camp_foundations_1");
    expect(system.queueUpgrade(watchtower, "sentry_bracing_1", resources)).toBe(true);
    expect(watchtower.upgradeQueue).toHaveLength(1);
  });
});

function createUpgradeSystem(options: {
  researched?: Set<string>;
  completedBuildingIds?: Set<string>;
  messages?: ReturnType<typeof vi.fn>;
} = {}): UpgradeSystem {
  const researched = options.researched ?? new Set<string>();
  return new UpgradeSystem({
    getTechState: () => ({
      completedBuildingIds: options.completedBuildingIds ?? new Set(["command_hall", "barracks"]),
      researchedUpgradeIds: researched,
      heroLevel: 1
    }),
    isResearched: (_team, upgradeId) => researched.has(upgradeId),
    markResearched: (_team, upgradeId) => researched.add(upgradeId),
    onMessage: options.messages ?? vi.fn(),
    onUpgradeCompleted: vi.fn()
  });
}

function fakeBuilding(buildingId: string, upgradeOptions: string[], completed = true): Building {
  return {
    id: `player_${buildingId}`,
    alive: true,
    team: "player",
    position: { x: 260, y: 800 },
    definition: { id: buildingId, upgradeOptions },
    upgradeQueue: [],
    isCompleted: () => completed
  } as unknown as Building;
}
