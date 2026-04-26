import { describe, expect, it } from "vitest";
import { LEVEL_XP_THRESHOLDS } from "./Constants";
import { calculateLevelFromXp, xpProgressForLevel } from "./Progression";
import {
  createFallbackCampaignSave,
  createFallbackHeroSave,
  isCampaignSaveData,
  isHeroSaveData,
  normalizeCampaignSaveData,
  normalizeHeroSaveData
} from "./SaveSystem";

describe("calculateLevelFromXp", () => {
  it("keeps a fresh hero at level 1", () => {
    expect(calculateLevelFromXp(0, LEVEL_XP_THRESHOLDS)).toBe(1);
  });

  it("returns the highest earned level", () => {
    expect(calculateLevelFromXp(250, LEVEL_XP_THRESHOLDS)).toBe(3);
    expect(calculateLevelFromXp(699, LEVEL_XP_THRESHOLDS)).toBe(4);
    expect(calculateLevelFromXp(700, LEVEL_XP_THRESHOLDS)).toBe(5);
  });

  it("calculates XP bar progress from the shared level curve", () => {
    expect(xpProgressForLevel(50, 1, LEVEL_XP_THRESHOLDS).percent).toBe(50);
    expect(xpProgressForLevel(175, 2, LEVEL_XP_THRESHOLDS).percent).toBe(50);
    expect(xpProgressForLevel(999, 5, LEVEL_XP_THRESHOLDS).percent).toBe(100);
  });

  it("rejects malformed hero saves before loading", () => {
    expect(isHeroSaveData(createFallbackHeroSave())).toBe(true);
    expect(isHeroSaveData({ heroName: "Broken" })).toBe(false);
    expect(isHeroSaveData({ ...createFallbackHeroSave(), level: "2" })).toBe(false);
  });

  it("migrates older item saves into the inventory field", () => {
    const migrated = normalizeHeroSaveData({
      ...createFallbackHeroSave(),
      inventory: undefined,
      items: ["founders_promise"]
    });

    expect(migrated?.inventory).toEqual(["founders_promise"]);
    expect(migrated?.equipment).toEqual({});
    expect(migrated?.allocatedSkills).toEqual({});
    expect(migrated?.clearedMapIds).toEqual([]);
  });

  it("persists valid inventory equipment and cleared map history", () => {
    const normalized = normalizeHeroSaveData({
      ...createFallbackHeroSave(),
      inventory: ["captains_seal"],
      equipment: {
        trinket: "captains_seal",
        weapon: "missing_item"
      },
      clearedMapIds: ["first_claim", "first_claim", "broken_ford"]
    });

    expect(normalized?.inventory).toEqual(["captains_seal"]);
    expect(normalized?.equipment).toEqual({ trinket: "captains_seal" });
    expect(normalized?.clearedMapIds).toEqual(["first_claim", "broken_ford"]);
  });

  it("normalizes numeric progression fields into safe ranges", () => {
    const normalized = normalizeHeroSaveData({
      ...createFallbackHeroSave(),
      level: -5,
      xp: -10,
      skillPoints: -3,
      completedBattles: -1,
      allocatedSkills: {
        combat_drill: 1.9
      },
      stats: {
        might: -2,
        command: 8,
        arcana: 2,
        faith: 3
      }
    });

    expect(normalized?.level).toBe(1);
    expect(normalized?.xp).toBe(0);
    expect(normalized?.skillPoints).toBe(0);
    expect(normalized?.completedBattles).toBe(0);
    expect(normalized?.allocatedSkills.combat_drill).toBe(1);
    expect(normalized?.stats.might).toBe(0);
  });

  it("normalizes campaign save progress", () => {
    const normalized = normalizeCampaignSaveData({
      ...createFallbackCampaignSave(),
      started: true,
      difficulty: "normal",
      completedNodeIds: ["border_village", "border_village"],
      unlockedNodeIds: ["border_village", "old_stone_road"],
      lockedNodeIds: ["refugee_caravan", "refugee_caravan"],
      nodeRewardsClaimedIds: ["border_village"],
      choiceIdsClaimed: ["chapel_of_the_marches:ask_for_guidance", "chapel_of_the_marches:ask_for_guidance"],
      activeModifierIds: ["inspired_militia", "missing_modifier", "inspired_militia"],
      resources: { crowns: 25, stone: -5, iron: 12.8, aether: 3 },
      selectedNodeId: "old_stone_road"
    });

    expect(isCampaignSaveData(normalized)).toBe(true);
    expect(normalized?.resources).toEqual({ crowns: 25, stone: 0, iron: 12, aether: 3 });
    expect(normalized?.completedNodeIds).toEqual(["border_village"]);
    expect(normalized?.unlockedNodeIds).toEqual(["border_village", "old_stone_road"]);
    expect(normalized?.lockedNodeIds).toEqual(["refugee_caravan"]);
    expect(normalized?.choiceIdsClaimed).toEqual(["chapel_of_the_marches:ask_for_guidance"]);
    expect(normalized?.activeModifierIds).toEqual(["inspired_militia"]);
    expect(normalized?.selectedNodeId).toBe("old_stone_road");
  });

  it("migrates older campaign saves without a resource bank", () => {
    const normalized = normalizeCampaignSaveData({
      started: true,
      difficulty: "easy",
      completedNodeIds: ["border_village"],
      unlockedNodeIds: ["border_village", "old_stone_road"],
      nodeRewardsClaimedIds: ["border_village"]
    });

    expect(normalized?.resources).toEqual({ crowns: 0, stone: 0, iron: 0, aether: 0 });
    expect(normalized?.choiceIdsClaimed).toEqual([]);
    expect(normalized?.lockedNodeIds).toEqual([]);
    expect(normalized?.activeModifierIds).toEqual([]);
  });

  it("normalizes reputation defaults and clamps reputation values", () => {
    const normalized = normalizeHeroSaveData({
      ...createFallbackHeroSave(),
      factionReputation: {
        free_marches: 150,
        common_folk: -120
      }
    });

    expect(normalized?.factionReputation.free_marches).toBe(100);
    expect(normalized?.factionReputation.common_folk).toBe(-100);
    expect(normalized?.factionReputation.ashen_covenant).toBe(-10);
    expect(normalized?.factionReputation.old_faith).toBe(0);
  });
});
