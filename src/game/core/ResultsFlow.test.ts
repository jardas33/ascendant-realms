import { afterEach, beforeEach, describe, expect, it } from "vitest";
import {
  buildRewardItemPresentations,
  createDefeatTips,
  equipRewardItemNow
} from "./ResultsFlow";
import { completeCampaignNodeWithRewards, createStartedCampaignSave } from "./CampaignRules";
import { calculateLiveHeroStats, createItemInstance } from "./HeroProgressionRules";
import { SaveSystem } from "./SaveSystem";
import type { BattleStats } from "./GameTypes";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import { HERO_CLASS_BY_ID, ITEM_BY_ID, ORIGIN_BY_ID, SKILL_NODE_BY_ID } from "../data/contentIndex";
import { createNewHeroSave } from "../data/heroes";

describe("results reward flow", () => {
  let originalLocalStorage: Storage | undefined;

  beforeEach(() => {
    originalLocalStorage = globalThis.localStorage;
    Object.defineProperty(globalThis, "localStorage", {
      configurable: true,
      value: createMemoryStorage()
    });
  });

  afterEach(() => {
    Object.defineProperty(globalThis, "localStorage", {
      configurable: true,
      value: originalLocalStorage
    });
  });

  it("labels new, duplicate, and already-owned rewards for the results screen", () => {
    const rewards = buildRewardItemPresentations({
      itemIds: ["weathered_command_sword", "weathered_command_sword", "captains_seal"],
      itemById: ITEM_BY_ID,
      startingInventory: [createItemInstance("captains_seal", "test")]
    });

    expect(rewards.map((entry) => entry.state)).toEqual(["new", "duplicate", "already_owned"]);
  });

  it("equips a reward item, recalculates stats, and persists the equipped slot", () => {
    const hero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      inventory: [createItemInstance("weathered_command_sword", "test")]
    };
    const itemInstanceId = hero.inventory[0].instanceId;
    const beforeStats = calculateLiveHeroStats(hero, HERO_CLASS_BY_ID.warlord, ORIGIN_BY_ID.exiled_noble, SKILL_NODE_BY_ID, ITEM_BY_ID);

    const result = equipRewardItemNow({
      hero,
      itemInstanceId,
      itemById: ITEM_BY_ID,
      heroClass: HERO_CLASS_BY_ID.warlord,
      origin: ORIGIN_BY_ID.exiled_noble,
      skillById: SKILL_NODE_BY_ID
    });

    expect(result.ok).toBe(true);
    expect(result.hero.equipment.weapon).toBe(itemInstanceId);
    expect(result.hero.inventory.some((instance) => instance.itemId === "weathered_command_sword")).toBe(true);
    expect(result.deltas.some((delta) => delta.key === "damage" && delta.delta > 0)).toBe(true);

    SaveSystem.saveHero(result.hero);
    const loaded = SaveSystem.load();
    expect(loaded?.hero.equipment.weapon).toBe(itemInstanceId);
    const afterStats = calculateLiveHeroStats(loaded!.hero, HERO_CLASS_BY_ID.warlord, ORIGIN_BY_ID.exiled_noble, SKILL_NODE_BY_ID, ITEM_BY_ID);
    expect(afterStats.damage).toBeGreaterThan(beforeStats.damage);
  });

  it("creates contextual defeat tips from battle stats", () => {
    const stats: BattleStats = {
      unitsKilled: 0,
      buildingsDestroyed: 0,
      resourcesCaptured: 0,
      buildingsBuilt: 1,
      builtBuildingIds: ["watchtower"],
      unitsTrained: 0,
      trainedUnitIds: [],
      enemyWavesSurvived: 0,
      xpGained: 0,
      timeSeconds: 95,
      completedObjectiveIds: [],
      outcome: "defeat"
    };

    const tips = createDefeatTips(stats);

    expect(tips.join(" ")).toContain("Crown Shrine");
    expect(tips.join(" ")).toContain("Barracks");
    expect(tips.join(" ")).toContain("Militia");
    expect(tips.join(" ")).toContain("Story or Easy");
  });

  it("recommends equipping prior rewards before retrying when the hero has unused gear", () => {
    const stats: BattleStats = {
      unitsKilled: 2,
      buildingsDestroyed: 0,
      resourcesCaptured: 1,
      buildingsBuilt: 1,
      builtBuildingIds: ["barracks"],
      unitsTrained: 2,
      trainedUnitIds: ["militia", "ranger"],
      enemyWavesSurvived: 0,
      xpGained: 0,
      timeSeconds: 250,
      completedObjectiveIds: [],
      outcome: "defeat"
    };
    const hero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      inventory: [createItemInstance("weathered_command_sword", "test")],
      equipment: {}
    };

    const tips = createDefeatTips(stats, { hero });

    expect(tips.join(" ")).toContain("equip rewards");
  });

  it("adds Ashen Outpost objective tips before generic defeat advice", () => {
    const stats: BattleStats = {
      unitsKilled: 6,
      buildingsDestroyed: 0,
      resourcesCaptured: 2,
      buildingsBuilt: 2,
      builtBuildingIds: ["barracks", "mystic_lodge"],
      unitsTrained: 6,
      trainedUnitIds: ["militia", "ranger", "militia", "ranger", "acolyte", "militia"],
      enemyWavesSurvived: 2,
      xpGained: 0,
      timeSeconds: 420,
      completedObjectiveIds: [],
      outcome: "defeat"
    };

    const tips = createDefeatTips(stats, { mapId: "ashen_outpost", campaignNodeId: "ashen_outpost" });

    expect(tips[0]).toContain("Burned Shrine");
    expect(tips[0]).toContain("gate Watchtower");
  });

  it("advances Ashen Outpost defeat advice after Burned Shrine is complete", () => {
    const stats: BattleStats = {
      unitsKilled: 10,
      buildingsDestroyed: 0,
      resourcesCaptured: 3,
      buildingsBuilt: 3,
      builtBuildingIds: ["barracks", "mystic_lodge", "watchtower"],
      unitsTrained: 8,
      trainedUnitIds: ["militia", "ranger", "militia", "ranger", "acolyte", "militia", "ranger", "militia"],
      enemyWavesSurvived: 3,
      xpGained: 0,
      timeSeconds: 560,
      completedObjectiveIds: ["capture_burned_shrine"],
      outcome: "defeat"
    };

    const tips = createDefeatTips(stats, { mapId: "ashen_outpost" });

    expect(tips[0]).toContain("Enemy Barracks");
    expect(tips[0]).toContain("Stronghold");
  });

  it("saves campaign node completion and does not grant the same node reward twice", () => {
    const campaign = createStartedCampaignSave();
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "border_village")!;

    const completed = completeCampaignNodeWithRewards({ campaign, hero, node });
    SaveSystem.saveGame(completed.hero, completed.campaign);
    const loaded = SaveSystem.load();
    const repeated = completeCampaignNodeWithRewards({
      campaign: loaded!.campaign,
      hero: loaded!.hero,
      node
    });

    expect(loaded?.campaign.completedNodeIds).toContain(node.id);
    expect(loaded?.campaign.nodeRewardsClaimedIds).toContain(node.id);
    expect(loaded?.campaign.resources.crowns).toBe(50);
    expect(loaded?.hero.inventory.some((instance) => instance.itemId === "weathered_command_sword")).toBe(true);
    expect(repeated.nodeReward.itemIds).toEqual([]);
    expect(repeated.nodeReward.resources).toEqual({});
    expect(repeated.campaign.resources.crowns).toBe(50);
    expect(repeated.hero.inventory.filter((instance) => instance.itemId === "weathered_command_sword")).toHaveLength(1);
  });
});

function createMemoryStorage(): Storage {
  const data = new Map<string, string>();
  return {
    get length() {
      return data.size;
    },
    clear: () => data.clear(),
    getItem: (key: string) => data.get(key) ?? null,
    key: (index: number) => [...data.keys()][index] ?? null,
    removeItem: (key: string) => {
      data.delete(key);
    },
    setItem: (key: string, value: string) => {
      data.set(key, value);
    }
  };
}
