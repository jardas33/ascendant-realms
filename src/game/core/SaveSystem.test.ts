import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { LEVEL_XP_THRESHOLDS, SAVE_KEY } from "./Constants";
import { calculateLevelFromXp, xpProgressForLevel } from "./Progression";
import {
  CURRENT_SAVE_VERSION,
  SaveSystem,
  createFallbackCampaignSave,
  createFallbackHeroSave,
  isCampaignSaveData,
  isHeroSaveData,
  migrateSaveToCurrent,
  migrateV1ToV2,
  normalizeCampaignSaveData,
  normalizeHeroSaveData
} from "./SaveSystem";
import { createItemInstance } from "./HeroProgressionRules";
import type { CampaignSaveData, HeroSaveData } from "../save/SaveTypes";

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

    expect(migrated?.inventory.map((instance) => instance.itemId)).toEqual(["founders_promise"]);
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

    expect(normalized?.inventory.map((instance) => instance.itemId)).toEqual(["captains_seal", "missing_item"]);
    expect(normalized?.equipment.trinket).toBe(normalized?.inventory.find((instance) => instance.itemId === "captains_seal")?.instanceId);
    expect(normalized?.equipment.weapon).toBe(normalized?.inventory.find((instance) => instance.itemId === "missing_item")?.instanceId);
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
      townServiceClaimedIds: ["marcher_camp:purchase_emberglass_wand", "marcher_camp:purchase_emberglass_wand"],
      townServiceUseCounts: { "marcher_camp:buy_supplies": 2, bad: -1 },
      activeModifierIds: ["inspired_militia", "missing_modifier", "inspired_militia"],
      resources: { crowns: 25, stone: -5, iron: 12.8, aether: 3 },
      resourcesSpent: { crowns: 60, stone: -4, iron: 2, aether: 1 },
      selectedNodeId: "old_stone_road"
    });

    expect(isCampaignSaveData(normalized)).toBe(true);
    expect(normalized?.resources).toEqual({ crowns: 25, stone: 0, iron: 12, aether: 3 });
    expect(normalized?.completedNodeIds).toEqual(["border_village"]);
    expect(normalized?.unlockedNodeIds).toEqual(["border_village", "old_stone_road"]);
    expect(normalized?.lockedNodeIds).toEqual(["refugee_caravan"]);
    expect(normalized?.choiceIdsClaimed).toEqual(["chapel_of_the_marches:ask_for_guidance"]);
    expect(normalized?.townServiceClaimedIds).toEqual(["marcher_camp:purchase_emberglass_wand"]);
    expect(normalized?.townServiceUseCounts).toEqual({ "marcher_camp:buy_supplies": 2 });
    expect(normalized?.activeModifierIds).toEqual(["inspired_militia"]);
    expect(normalized?.selectedNodeId).toBe("old_stone_road");
    expect(normalized?.resourcesSpent).toEqual({ crowns: 60, stone: 0, iron: 2, aether: 1 });
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
    expect(normalized?.resourcesSpent).toEqual({ crowns: 0, stone: 0, iron: 0, aether: 0 });
    expect(normalized?.choiceIdsClaimed).toEqual([]);
    expect(normalized?.townServiceClaimedIds).toEqual([]);
    expect(normalized?.townServiceUseCounts).toEqual({});
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

describe("save version migration", () => {
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

  it("migrates a V1 save into the V2 shape", () => {
    const v1 = createLegacyV1Save();
    const migrated = migrateV1ToV2(v1);

    expect(migrated?.version).toBe(CURRENT_SAVE_VERSION);
    expect(migrated?.createdAt).toBe(v1.updatedAt);
    expect(migrated?.updatedAt).toBe(v1.updatedAt);
    expect(migrated?.settings).toEqual({});
    expect(migrated?.statistics).toEqual({});
  });

  it("loads V1 saves without losing campaign resources, inventory, equipment, or choice claims", () => {
    const v1 = createLegacyV1Save();
    globalThis.localStorage.setItem(SAVE_KEY, JSON.stringify(v1));

    const loaded = SaveSystem.load();

    expect(loaded?.version).toBe(2);
    expect(loaded?.campaign.resources).toEqual({ crowns: 60, stone: 20, iron: 5, aether: 2 });
    expect(loaded?.campaign.choiceIdsClaimed).toEqual(["chapel_of_the_marches:pray_for_strength"]);
    expect(loaded?.campaign.nodeRewardsClaimedIds).toEqual(["border_village"]);
    expect(loaded?.hero.inventory.map((instance) => instance.itemId)).toEqual(["weathered_command_sword"]);
    expect(loaded?.hero.equipment.weapon).toBe(loaded?.hero.inventory[0].instanceId);
  });

  it("writes new saves as version 2 with created and updated timestamps", () => {
    const hero = createFallbackHeroSave();
    const campaign = createFallbackCampaignSave();

    expect(SaveSystem.saveGame(hero, campaign)).toBe(true);
    const raw = globalThis.localStorage.getItem(SAVE_KEY);
    const parsed = raw ? JSON.parse(raw) : undefined;

    expect(parsed.version).toBe(2);
    expect(typeof parsed.createdAt).toBe("string");
    expect(typeof parsed.updatedAt).toBe("string");
    expect(parsed.settings).toEqual({});
    expect(parsed.statistics).toEqual({});
  });

  it("loads V2 saves and preserves placeholder objects", () => {
    const v2 = {
      version: 2,
      createdAt: "2026-01-01T00:00:00.000Z",
      updatedAt: "2026-01-02T00:00:00.000Z",
      hero: createFallbackHeroSave(),
      campaign: createFallbackCampaignSave(),
      settings: { futureAudio: "placeholder" },
      statistics: { futureBattles: 0 }
    };
    globalThis.localStorage.setItem(SAVE_KEY, JSON.stringify(v2));

    const loaded = SaveSystem.load();

    expect(loaded?.version).toBe(2);
    expect(loaded?.createdAt).toBe(v2.createdAt);
    expect(loaded?.settings).toEqual(v2.settings);
    expect(loaded?.statistics).toEqual(v2.statistics);
  });

  it("normalizes missing V2 fields into safe defaults", () => {
    const migrated = migrateSaveToCurrent({
      version: 2,
      hero: createFallbackHeroSave(),
      campaign: {
        started: true,
        difficulty: "easy"
      }
    });

    expect(migrated?.version).toBe(2);
    expect(typeof migrated?.createdAt).toBe("string");
    expect(typeof migrated?.updatedAt).toBe("string");
    expect(migrated?.campaign.resources).toEqual({ crowns: 0, stone: 0, iron: 0, aether: 0 });
    expect(migrated?.campaign.resourcesSpent).toEqual({ crowns: 0, stone: 0, iron: 0, aether: 0 });
    expect(migrated?.campaign.choiceIdsClaimed).toEqual([]);
    expect(migrated?.campaign.townServiceClaimedIds).toEqual([]);
    expect(migrated?.campaign.townServiceUseCounts).toEqual({});
    expect(migrated?.settings).toEqual({});
    expect(migrated?.statistics).toEqual({});
  });

  it("saves and loads town purchases and campaign spending totals", () => {
    const hero = {
      ...createFallbackHeroSave(),
      inventory: [createItemInstance("emberglass_wand", "test")]
    };
    const campaign = {
      ...createFallbackCampaignSave(),
      started: true,
      resources: { crowns: 45, stone: 25, iron: 12, aether: 6 },
      resourcesSpent: { crowns: 55, stone: 0, iron: 0, aether: 0 },
      townServiceClaimedIds: ["marcher_camp:purchase_emberglass_wand"],
      townServiceUseCounts: { "marcher_camp:purchase_emberglass_wand": 1 }
    };

    expect(SaveSystem.saveGame(hero, campaign)).toBe(true);
    const loaded = SaveSystem.load();

    expect(loaded?.hero.inventory.map((instance) => instance.itemId)).toEqual(["emberglass_wand"]);
    expect(loaded?.campaign.resourcesSpent.crowns).toBe(55);
    expect(loaded?.campaign.townServiceClaimedIds).toEqual(["marcher_camp:purchase_emberglass_wand"]);
    expect(loaded?.campaign.townServiceUseCounts).toEqual({ "marcher_camp:purchase_emberglass_wand": 1 });
  });

  it("rejects invalid JSON and invalid save shapes without clearing storage", () => {
    globalThis.localStorage.setItem(SAVE_KEY, "{not json");

    expect(SaveSystem.load()).toBeNull();
    expect(globalThis.localStorage.getItem(SAVE_KEY)).toBe("{not json");
    expect(migrateSaveToCurrent({ version: 2, hero: { heroName: "Broken" } })).toBeNull();
  });

  it("imports valid legacy saves and refuses invalid imports without replacing the current save", () => {
    const valid = createLegacyV1Save();

    expect(SaveSystem.importSaveJson(JSON.stringify(valid))).toBe(true);
    const imported = SaveSystem.load();
    expect(imported?.version).toBe(2);
    expect(imported?.hero.inventory.map((instance) => instance.itemId)).toEqual(["weathered_command_sword"]);

    const beforeInvalidImport = globalThis.localStorage.getItem(SAVE_KEY);
    expect(SaveSystem.importSaveJson("{not json")).toBe(false);
    expect(globalThis.localStorage.getItem(SAVE_KEY)).toBe(beforeInvalidImport);
    expect(SaveSystem.exportSaveJson()).toContain('"version": 2');
  });
});

function createLegacyV1Save(): {
  version: 1;
  hero: Omit<HeroSaveData, "inventory" | "equipment"> & { inventory: string[]; equipment: Record<string, string> };
  campaign: CampaignSaveData;
  updatedAt: string;
} {
  return {
    version: 1,
    updatedAt: "2026-01-01T00:00:00.000Z",
    hero: {
      ...createFallbackHeroSave(),
      inventory: ["weathered_command_sword"],
      equipment: { weapon: "weathered_command_sword" }
    },
    campaign: {
      ...createFallbackCampaignSave(),
      started: true,
      resources: { crowns: 60, stone: 20, iron: 5, aether: 2 },
      completedNodeIds: ["border_village"],
      unlockedNodeIds: ["border_village", "old_stone_road"],
      nodeRewardsClaimedIds: ["border_village"],
      choiceIdsClaimed: ["chapel_of_the_marches:pray_for_strength"]
    }
  };
}

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
