import { describe, expect, it } from "vitest";
import { STARTING_PLAYER_RESOURCES } from "../core/Constants";
import { cloneResources } from "../core/MathUtils";
import { requireBuilding } from "../data/contentIndex";
import { MAPS } from "../data/maps";
import { canPlaceBuilding } from "./BuildingPlacementRules";

describe("canPlaceBuilding", () => {
  const map = MAPS[0];
  const barracks = requireBuilding("barracks");
  const commandHall = {
    alive: true,
    team: "player" as const,
    position: map.playerStart,
    radius: 60
  };

  it("allows a funded building near an owned building", () => {
    expect(
      canPlaceBuilding({
        point: { x: 430, y: 800 },
        definition: barracks,
        resources: cloneResources(STARTING_PLAYER_RESOURCES),
        map,
        buildings: [commandHall],
        captureSites: [],
        team: "player"
      })
    ).toEqual({ ok: true });
  });

  it("rejects blocked terrain and missing resources with explicit reasons", () => {
    expect(
      canPlaceBuilding({
        point: { x: 1080, y: 690 },
        definition: barracks,
        resources: cloneResources(STARTING_PLAYER_RESOURCES),
        map,
        buildings: [commandHall],
        captureSites: [],
        team: "player"
      }).reason
    ).toBe("blocked-terrain");

    expect(
      canPlaceBuilding({
        point: { x: 430, y: 800 },
        definition: barracks,
        resources: { crowns: 0, stone: 0, iron: 0, aether: 0 },
        map,
        buildings: [commandHall],
        captureSites: [],
        team: "player"
      }).reason
    ).toBe("missing-resources");
  });

  it("rejects placements whose footprint crosses map bounds or blocked terrain", () => {
    expect(
      canPlaceBuilding({
        point: { x: 20, y: 800 },
        definition: barracks,
        resources: cloneResources(STARTING_PLAYER_RESOURCES),
        map,
        buildings: [commandHall],
        captureSites: [],
        team: "player"
      }).reason
    ).toBe("outside-map");

    expect(
      canPlaceBuilding({
        point: { x: 1022, y: 690 },
        definition: barracks,
        resources: cloneResources(STARTING_PLAYER_RESOURCES),
        map,
        buildings: [{ ...commandHall, position: { x: 900, y: 690 } }],
        captureSites: [],
        team: "player"
      }).reason
    ).toBe("blocked-terrain");
  });

  it("rejects clear ground outside buildable zones with a specific reason", () => {
    expect(
      canPlaceBuilding({
        point: { x: 720, y: 800 },
        definition: barracks,
        resources: cloneResources(STARTING_PLAYER_RESOURCES),
        map,
        buildings: [commandHall],
        captureSites: [],
        team: "player"
      }).reason
    ).toBe("not-buildable-terrain");
  });
});
