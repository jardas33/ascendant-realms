import { describe, expect, it } from "vitest";
import { BUILDING_BY_ID, UNIT_BY_ID, UPGRADE_BY_ID } from "../data/contentIndex";
import {
  buildCommandAvailability,
  trainingCommandAvailability,
  upgradeCommandAvailability
} from "./CommandAvailability";

const techState = {
  completedBuildingIds: new Set(["command_hall", "barracks"]),
  researchedUpgradeIds: new Set<string>(),
  heroLevel: 1
};

const resources = { crowns: 0, stone: 0, iron: 0, aether: 0 };

describe("CommandAvailability", () => {
  it("returns stable exact resource deficits in crowns, stone, iron, aether order", () => {
    const decision = buildCommandAvailability(
      {
        alive: true,
        team: "player",
        kind: "unit",
        definition: { buildOptions: ["mystic_lodge"] }
      },
      BUILDING_BY_ID.mystic_lodge,
      techState,
      resources
    );

    expect(decision).toEqual({
      available: false,
      reasonCode: "insufficient_resources",
      reason: "Need 160 Crowns and 100 Stone and 80 Aether",
      missingResources: { crowns: 160, stone: 100, aether: 80 }
    });
  });

  it("reports construction and prerequisite locks before affordability", () => {
    const incomplete = buildCommandAvailability(
      {
        alive: true,
        team: "player",
        kind: "building",
        isCompleted: () => false,
        definition: { buildOptions: ["barracks"] }
      },
      BUILDING_BY_ID.barracks,
      techState,
      { crowns: 10_000, stone: 10_000, iron: 10_000, aether: 10_000 }
    );
    expect(incomplete).toMatchObject({ available: false, reasonCode: "construction_incomplete" });

    const locked = upgradeCommandAvailability(
      {
        alive: true,
        team: "player",
        isCompleted: () => true,
        definition: { upgradeOptions: ["sentry_bracing_1"] }
      },
      UPGRADE_BY_ID.sentry_bracing_1,
      { crowns: 10_000, stone: 10_000, iron: 10_000, aether: 10_000 },
      techState,
      false,
      false
    );
    expect(locked).toMatchObject({ available: false, reasonCode: "prerequisite_missing" });
  });

  it("uses the same contract for training and research guards", () => {
    const building = {
      alive: true,
      team: "player" as const,
      isCompleted: () => true,
      definition: { trainOptions: ["militia"], upgradeOptions: ["infantry_weapons_1"] }
    };
    const train = trainingCommandAvailability(building, UNIT_BY_ID.militia, resources, techState);
    expect(train).toMatchObject({ available: false, reasonCode: "insufficient_resources" });

    const upgrade = upgradeCommandAvailability(
      building,
      UPGRADE_BY_ID.infantry_weapons_1,
      { crowns: 10_000, stone: 10_000, iron: 10_000, aether: 10_000 },
      techState,
      false,
      false
    );
    expect(upgrade).toEqual({ available: true });
    expect(upgradeCommandAvailability(
      building,
      UPGRADE_BY_ID.infantry_weapons_1,
      { crowns: 10_000, stone: 10_000, iron: 10_000, aether: 10_000 },
      techState,
      false,
      true
    )).toMatchObject({ available: false, reasonCode: "already_queued", reason: "Researching" });
  });
});
