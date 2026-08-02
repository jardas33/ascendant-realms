import { describe, expect, it, vi } from "vitest";

vi.mock("phaser", () => {
  class Stub {}
  const recursiveNamespace = new Proxy(
    {},
    {
      get: () => Stub
    }
  );
  return {
    default: {
      Scene: Stub,
      Scenes: { Events: { SHUTDOWN: "shutdown" } },
      Math: { Clamp: (value: number, min: number, max: number) => Math.min(max, Math.max(min, value)), Distance: { Between: () => 0 } },
      Geom: recursiveNamespace,
      GameObjects: recursiveNamespace,
      Physics: recursiveNamespace,
      Display: recursiveNamespace
    }
  };
});

import { BROKEN_FORD_MAP } from "../data/maps/brokenFord";
import { createMissionObjectiveSnapshots } from "./BattleScene";

describe("canonical battle primary objective snapshots", () => {
  it("defines the exact Broken Ford primary copy without fabricating secondary objectives", () => {
    const objectives = BROKEN_FORD_MAP.scenario.objectives;

    expect(objectives.playerBaseBuildingId).toBe("command_hall");
    expect(objectives.enemyBaseBuildingId).toBe("enemy_stronghold");
    expect(objectives.primaryObjective).toEqual({
      id: "destroy_enemy_stronghold",
      name: "Destroy the Enemy Stronghold",
      description: "Build your forces, cross Broken Ford, and destroy the enemy Stronghold."
    });
    expect(objectives.secondaryObjectives).toBeUndefined();
  });

  it("serializes primary before secondaries and keeps secondary source order", () => {
    const snapshots = createMissionObjectiveSnapshots(
      {
        playerBaseBuildingId: "command_hall",
        enemyBaseBuildingId: "enemy_stronghold",
        primaryObjective: { id: "primary", name: "Primary", description: "Conquer the base." },
        secondaryObjectives: [
          { id: "first", name: "First", description: "First side task.", type: "capture_site", targetId: "site-a" },
          { id: "second", name: "Second", description: "Second side task.", type: "destroy_building", targetId: "building-b" }
        ]
      },
      ["second"],
      true
    );

    expect(snapshots.map((objective) => objective.id)).toEqual(["primary", "first", "second"]);
    expect(snapshots[0]).toMatchObject({ isPrimary: true, completed: false });
    expect(snapshots[1]).toMatchObject({ completed: false });
    expect(snapshots[2]).toMatchObject({ completed: true });
  });

  it("completes primary only from canonical enemy-base presence, not status or non-base deaths", () => {
    const objective = {
      playerBaseBuildingId: "command_hall",
      enemyBaseBuildingId: "enemy_stronghold",
      primaryObjective: { id: "primary", name: "Primary", description: "Conquer the base." }
    };

    expect(createMissionObjectiveSnapshots(objective, ["primary"], true)[0].completed).toBe(false);
    expect(createMissionObjectiveSnapshots(objective, [], false)[0].completed).toBe(true);
  });

  it("keeps maps without a primary truthful and does not infer a fallback from base IDs", () => {
    const snapshots = createMissionObjectiveSnapshots(
      {
        playerBaseBuildingId: "command_hall",
        enemyBaseBuildingId: "enemy_stronghold"
      },
      [],
      true
    );

    expect(snapshots).toEqual([]);
  });

  it("can suppress the map primary for the private Lume objective path", () => {
    const snapshots = createMissionObjectiveSnapshots(
      {
        playerBaseBuildingId: "command_hall",
        enemyBaseBuildingId: "enemy_stronghold",
        primaryObjective: {
          id: "destroy_enemy_stronghold",
          name: "Destroy the Enemy Stronghold",
          description: "Build your forces, cross Broken Ford, and destroy the enemy Stronghold."
        }
      },
      [],
      true,
      false
    );

    expect(snapshots).toEqual([]);
  });
});
