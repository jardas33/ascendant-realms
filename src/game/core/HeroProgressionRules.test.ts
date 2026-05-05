import { describe, expect, it } from "vitest";
import {
  allocateSkillPoint,
  calculateLiveHeroStats,
  createItemInstance,
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
      inventory: [createItemInstance("emberglass_wand", "test")],
      allocatedSkills: { magic_focus: 2 }
    };
    hero.equipment = { weapon: hero.inventory[0].instanceId };

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

  it("applies equipped item affix modifiers to live hero stats", () => {
    const baseHero = createNewHeroSave("Mira", "warlord", "exiled_noble");
    const instance = createItemInstance("weathered_command_sword", "test", "2026-05-01T00:00:00.000Z", {
      affixes: ["sharp"]
    });
    const hero = {
      ...baseHero,
      inventory: [instance],
      equipment: { weapon: instance.instanceId }
    };

    const before = calculateLiveHeroStats(
      baseHero,
      HERO_CLASS_BY_ID[hero.classId],
      ORIGIN_BY_ID[hero.originId],
      SKILL_NODE_BY_ID,
      ITEM_BY_ID
    );
    const after = calculateLiveHeroStats(
      hero,
      HERO_CLASS_BY_ID[hero.classId],
      ORIGIN_BY_ID[hero.originId],
      SKILL_NODE_BY_ID,
      ITEM_BY_ID
    );

    expect(after.damage - before.damage).toBe(6);
    expect(after.command - before.command).toBe(1);
  });

  it("equips only owned items and picks new battle rewards deterministically", () => {
    const hero = createNewHeroSave("Tamsin", "shepherd", "temple_orphan");
    const denied = equipItem(hero, "green_chapel_icon", ITEM_BY_ID);
    const unknown = equipItem(hero, "missing_item", ITEM_BY_ID);
    expect(denied.ok).toBe(false);
    expect(unknown.ok).toBe(false);

    const rewardIds = pickBattleRewardItemIds(REWARD_TABLE_BY_ID.first_claim_rewards, 0, hero.inventory);
    const rewarded = grantItemRewards(hero, rewardIds);
    const rewardInstance = rewarded.inventory.find((instance) => instance.itemId === rewardIds[0]);
    const equipped = equipItem(rewarded, rewardInstance?.instanceId ?? "", ITEM_BY_ID);

    expect(rewardIds).toHaveLength(1);
    expect(rewarded.inventory.some((instance) => instance.itemId === rewardIds[0])).toBe(true);
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

  it("honors first-clear item pools on deterministic Cinderfen repeat rewards", () => {
    const causewayFirstClearReward = rollBattleRewards({
      table: REWARD_TABLE_BY_ID.cinderfen_causeway_rewards,
      completedBattlesBeforeVictory: 5,
      inventory: [],
      deterministic: true,
      isFirstClear: true,
      mapId: "cinderfen_causeway"
    });
    const causewayRepeatReward = rollBattleRewards({
      table: REWARD_TABLE_BY_ID.cinderfen_causeway_rewards,
      completedBattlesBeforeVictory: 6,
      inventory: [],
      deterministic: true,
      isFirstClear: false,
      mapId: "cinderfen_causeway"
    });
    const watchFirstClearReward = rollBattleRewards({
      table: REWARD_TABLE_BY_ID.cinderfen_watchpost_rewards,
      completedBattlesBeforeVictory: 6,
      inventory: [],
      deterministic: true,
      isFirstClear: true,
      mapId: "cinderfen_watchpost"
    });
    const watchRepeatReward = rollBattleRewards({
      table: REWARD_TABLE_BY_ID.cinderfen_watchpost_rewards,
      completedBattlesBeforeVictory: 7,
      inventory: [],
      deterministic: true,
      isFirstClear: false,
      mapId: "cinderfen_watchpost"
    });

    expect(causewayFirstClearReward.itemIds).toHaveLength(1);
    expect(causewayFirstClearReward.xp).toBe(65);
    expect(causewayFirstClearReward.resources).toMatchObject({
      crowns: 30,
      stone: 20,
      iron: 16,
      aether: 12
    });
    expect(causewayRepeatReward.itemIds).toEqual([]);
    expect(causewayRepeatReward.xp).toBe(4);
    expect(causewayRepeatReward.resources).toMatchObject({
      crowns: 6,
      iron: 3,
      aether: 2
    });
    expect(causewayRepeatReward.resources.stone).toBeUndefined();
    expect(watchFirstClearReward.itemIds).toHaveLength(1);
    expect(watchFirstClearReward.xp).toBe(66);
    expect(watchFirstClearReward.resources).toMatchObject({
      crowns: 34,
      stone: 20,
      iron: 16,
      aether: 10
    });
    expect(watchRepeatReward.itemIds).toEqual([]);
    expect(watchRepeatReward.xp).toBe(3);
    expect(watchRepeatReward.resources).toMatchObject({
      crowns: 5,
      iron: 2,
      aether: 1
    });
    expect(watchRepeatReward.resources.stone).toBeUndefined();
  });

  it("grants reward XP, item instances, and per-map first-clear history", () => {
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

    expect(granted.hero.inventory.some((instance) => instance.itemId === "captains_seal")).toBe(true);
    expect(granted.grantedItemInstances).toHaveLength(1);
    expect(granted.grantedItemInstances[0]).toMatchObject({
      itemId: "captains_seal",
      source: "battle_reward",
      affixes: []
    });
    expect(granted.hero.clearedMapIds).toContain("first_claim");
    expect(granted.hero.level).toBe(2);
    expect(granted.hero.skillPoints).toBe(1);
    expect(granted.levelUp.skillPointsGained).toBe(1);
  });

  it("rolls deterministic affixes when reward instances are generated for tests", () => {
    const hero = createNewHeroSave("Vale", "warlord", "exiled_noble");
    const granted = grantBattleRewards(
      hero,
      {
        itemIds: ["scouts_bow"],
        resources: {},
        xp: 0
      },
      undefined,
      {
        itemById: ITEM_BY_ID,
        deterministicAffixes: true,
        acquiredAt: "2026-05-01T00:00:00.000Z"
      }
    );

    expect(granted.grantedItemInstances).toHaveLength(1);
    expect(granted.grantedItemInstances[0]).toMatchObject({
      itemId: "scouts_bow",
      affixes: ["sharp"]
    });
  });

  it("keeps non-unique duplicate rewards as separate instances", () => {
    const hero = {
      ...createNewHeroSave("Vale", "warlord", "exiled_noble"),
      inventory: [createItemInstance("emberglass_wand", "test")]
    };

    const granted = grantBattleRewards(
      hero,
      {
        itemIds: ["emberglass_wand"],
        resources: {},
        xp: 0
      },
      undefined,
      { itemById: ITEM_BY_ID }
    );

    expect(granted.hero.inventory.filter((instance) => instance.itemId === "emberglass_wand")).toHaveLength(2);
    expect(granted.duplicateConversions).toEqual([]);
  });

  it("converts unique duplicate rewards into resources", () => {
    const hero = {
      ...createNewHeroSave("Vale", "warlord", "exiled_noble"),
      inventory: [createItemInstance("weathered_command_sword", "test")]
    };

    const granted = grantBattleRewards(
      hero,
      {
        itemIds: ["weathered_command_sword"],
        resources: {},
        xp: 0
      },
      undefined,
      { itemById: ITEM_BY_ID }
    );

    expect(granted.hero.inventory.filter((instance) => instance.itemId === "weathered_command_sword")).toHaveLength(1);
    expect(granted.grantedItemInstances).toEqual([]);
    expect(granted.duplicateConversions).toEqual([
      { itemId: "weathered_command_sword", reason: "unique_duplicate", resources: { crowns: 40 } }
    ]);
    expect(granted.reward.resources.crowns).toBe(40);
  });
});
