import { describe, expect, it } from "vitest";
import { BORDER_MARCHES_NODES } from "./borderMarchesNodes";
import {
  ENEMY_DOCTRINES,
  ENEMY_ELITE_SQUADS,
  selectEnemyDoctrineForBattle,
  selectEnemyDoctrineForCampaignNode,
  selectEnemyEliteSquadForBattle,
  shouldApplyEliteSquadToUnit
} from "./enemyDoctrines";

describe("enemy doctrines", () => {
  it("selects doctrine profiles from mission type and modifier context", () => {
    expect(selectEnemyDoctrineForCampaignNode(BORDER_MARCHES_NODES.find((node) => node.id === "old_stone_road"))?.id).toBe("raider");
    expect(selectEnemyDoctrineForCampaignNode(BORDER_MARCHES_NODES.find((node) => node.id === "ashen_outpost"))?.id).toBe("fortress");
    expect(
      selectEnemyDoctrineForBattle({
        mode: "campaign_node",
        missionTypeId: "defense",
        modifierIds: ["mission_enemy_patrols"]
      })?.id
    ).toBe("warband");
    expect(
      selectEnemyDoctrineForBattle({
        mode: "campaign_node",
        missionTypeId: "control",
        enemyHeroId: "veyra_cinders"
      })?.id
    ).toBe("hunter");
  });

  it("keeps Tutorial and training-safe routes free of doctrine complexity", () => {
    expect(selectEnemyDoctrineForBattle({ mode: "tutorial", missionTypeId: "control" })).toBeUndefined();
    expect(
      selectEnemyDoctrineForBattle({
        mode: "campaign_node",
        missionTypeId: "skirmish_training",
        modifierIds: ["mission_enemy_patrols"]
      })
    ).toBeUndefined();
  });

  it("caps elite squads to modest battle-only eligible scenarios", () => {
    const outpostElite = selectEnemyEliteSquadForBattle({
      mode: "campaign_node",
      campaignNodeId: "ashen_outpost",
      missionTypeId: "assault",
      modifierIds: ["mission_fortified_enemy"],
      enemyHeroId: "captain_malrec",
      difficulty: "normal"
    });

    expect(outpostElite?.id).toBe("cinder_iron_guard");
    expect(outpostElite?.maxUnitsPerBattle).toBeLessThanOrEqual(2);
    expect(outpostElite?.maxHpMultiplier).toBeLessThanOrEqual(1.1);
    expect(outpostElite?.damageMultiplier).toBeLessThanOrEqual(1.08);
    expect(selectEnemyEliteSquadForBattle({ mode: "tutorial", missionTypeId: "assault" })).toBeUndefined();
    expect(shouldApplyEliteSquadToUnit(outpostElite, "brute", 0)).toBe(true);
    expect(shouldApplyEliteSquadToUnit(outpostElite, "hexer", 0)).toBe(false);
    expect(shouldApplyEliteSquadToUnit(outpostElite, "brute", outpostElite?.maxUnitsPerBattle ?? 2)).toBe(false);
  });

  it("keeps player-facing doctrine and elite copy present", () => {
    expect(ENEMY_DOCTRINES).toHaveLength(4);
    ENEMY_DOCTRINES.forEach((doctrine) => {
      expect(doctrine.threatWarning.length).toBeGreaterThan(10);
      expect(doctrine.counterplay.length).toBeGreaterThan(10);
      expect(doctrine.tags.length).toBeGreaterThan(0);
    });
    ENEMY_ELITE_SQUADS.forEach((squad) => {
      expect(squad.description.length).toBeGreaterThan(10);
      expect(squad.counterplay.length).toBeGreaterThan(10);
    });
  });
});
