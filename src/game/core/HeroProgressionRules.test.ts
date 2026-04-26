import { describe, expect, it } from "vitest";
import {
  allocateSkillPoint,
  calculateLiveHeroStats,
  equipItem,
  grantItemRewards,
  pickBattleRewardItemIds
} from "./HeroProgressionRules";
import { HERO_CLASS_BY_ID, ITEM_BY_ID, ORIGIN_BY_ID, REWARD_TABLE_BY_ID, SKILL_NODE_BY_ID } from "../data/contentIndex";
import { createNewHeroSave } from "../data/heroes";

describe("hero RPG progression rules", () => {
  it("spends skill points and unlocks class abilities from data", () => {
    const hero = {
      ...createNewHeroSave("Mira", "warlord", "exiled_noble"),
      skillPoints: 2,
      allocatedSkills: { combat_drill: 1 }
    };

    const result = allocateSkillPoint(hero, "warlord_cleave", SKILL_NODE_BY_ID);

    expect(result.ok).toBe(true);
    expect(result.hero.skillPoints).toBe(1);
    expect(result.hero.allocatedSkills.warlord_cleave).toBe(1);
    expect(result.hero.unlockedAbilities).toContain("cleave");
  });

  it("applies skill and equipment stat modifiers without mutating base data", () => {
    const hero = {
      ...createNewHeroSave("Ilya", "arcanist", "temple_orphan"),
      inventory: ["emberglass_wand"],
      equipment: { weapon: "emberglass_wand" },
      allocatedSkills: { magic_focus: 2 }
    };

    const stats = calculateLiveHeroStats(
      hero,
      HERO_CLASS_BY_ID[hero.classId],
      ORIGIN_BY_ID[hero.originId],
      SKILL_NODE_BY_ID,
      ITEM_BY_ID
    );

    expect(stats.arcana).toBeGreaterThan(HERO_CLASS_BY_ID.arcanist.baseStats.arcana);
    expect(stats.maxMana).toBeGreaterThan(HERO_CLASS_BY_ID.arcanist.baseStats.maxMana);
  });

  it("equips only owned items and picks new battle rewards deterministically", () => {
    const hero = createNewHeroSave("Tamsin", "shepherd", "temple_orphan");
    const denied = equipItem(hero, "green_chapel_icon", ITEM_BY_ID);
    expect(denied.ok).toBe(false);

    const rewardIds = pickBattleRewardItemIds(REWARD_TABLE_BY_ID.first_claim_rewards, 0, hero.inventory);
    const rewarded = grantItemRewards(hero, rewardIds);
    const equipped = equipItem(rewarded, rewardIds[0], ITEM_BY_ID);

    expect(rewardIds).toHaveLength(1);
    expect(rewarded.inventory).toContain(rewardIds[0]);
    expect(equipped.ok).toBe(true);
  });
});
