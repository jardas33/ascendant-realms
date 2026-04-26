import { describe, expect, it } from "vitest";
import {
  allocateSkillPoint,
  calculateLiveHeroStats,
  equipItem,
  grantBattleRewards,
  grantItemRewards,
  pickBattleRewardItemIds,
  rollBattleRewards
} from "./HeroProgressionRules";
import type { RewardTableDefinition } from "./GameTypes";
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
    const unknown = equipItem(hero, "missing_item", ITEM_BY_ID);
    expect(denied.ok).toBe(false);
    expect(unknown.ok).toBe(false);

    const rewardIds = pickBattleRewardItemIds(REWARD_TABLE_BY_ID.first_claim_rewards, 0, hero.inventory);
    const rewarded = grantItemRewards(hero, rewardIds);
    const equipped = equipItem(rewarded, rewardIds[0], ITEM_BY_ID);

    expect(rewardIds).toHaveLength(1);
    expect(rewarded.inventory).toContain(rewardIds[0]);
    expect(equipped.ok).toBe(true);
  });

  it("rolls weighted battle rewards with an injected random source", () => {
    const table: RewardTableDefinition = {
      id: "test_rewards",
      name: "Test Rewards",
      guaranteedItemIds: [],
      weightedItemPool: [
        { itemId: "weathered_command_sword", weight: 1 },
        { itemId: "aether_lens", weight: 9 }
      ],
      resourceRewards: [{ resource: "crowns", amount: 25 }],
      xpRewards: [{ amount: 10 }],
      rolls: 1
    };

    const reward = rollBattleRewards({
      table,
      completedBattlesBeforeVictory: 1,
      inventory: [],
      rng: () => 0.5,
      isFirstClear: false
    });

    expect(reward.itemIds).toEqual(["aether_lens"]);
    expect(reward.resources.crowns).toBe(25);
    expect(reward.xp).toBe(10);
  });

  it("grants reward XP, inventory, and per-map first-clear history", () => {
    const hero = {
      ...createNewHeroSave("Vale", "warlord", "exiled_noble"),
      xp: 90
    };
    const granted = grantBattleRewards(
      hero,
      {
        itemIds: ["captains_seal"],
        resources: { crowns: 50 },
        xp: 20
      },
      "first_claim"
    );

    expect(granted.hero.inventory).toContain("captains_seal");
    expect(granted.hero.clearedMapIds).toContain("first_claim");
    expect(granted.hero.level).toBe(2);
    expect(granted.hero.skillPoints).toBe(1);
    expect(granted.levelUp.skillPointsGained).toBe(1);
  });
});
