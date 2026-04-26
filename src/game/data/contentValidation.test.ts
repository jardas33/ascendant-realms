import { describe, expect, it } from "vitest";
import { CAMPAIGN_NODES } from "./campaignNodes";
import { MAPS } from "./maps";
import { validateContent } from "./contentValidation";

describe("content validation", () => {
  it("keeps data references valid for non-coder edits", () => {
    expect(validateContent()).toEqual([]);
  });

  it("covers multiple skirmish maps with complete setup metadata", () => {
    expect(MAPS.map((map) => map.id)).toEqual(expect.arrayContaining(["first_claim", "broken_ford"]));
    MAPS.forEach((map) => {
      expect(map.role.length).toBeGreaterThan(0);
      expect(map.description.length).toBeGreaterThan(0);
      expect(map.captureSites.length).toBeGreaterThan(0);
      expect(map.neutralCamps.length).toBeGreaterThan(0);
      expect(map.visualPaths.length).toBeGreaterThan(0);
      expect(map.scenario.objectives).toEqual({
        playerBaseBuildingId: "command_hall",
        enemyBaseBuildingId: "enemy_stronghold"
      });
    });
    expect(MAPS.find((map) => map.id === "broken_ford")?.captureSites).toHaveLength(4);
    expect(MAPS.find((map) => map.id === "broken_ford")?.neutralCamps).toHaveLength(3);
  });

  it("defines the first mini-campaign chain", () => {
    expect(CAMPAIGN_NODES.map((node) => node.id)).toEqual(
      expect.arrayContaining([
        "border_village",
        "old_stone_road",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "ashen_outpost"
      ])
    );
    expect(CAMPAIGN_NODES).toHaveLength(6);
  });
});
