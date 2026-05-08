import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { SAVE_KEY } from "../../../src/game/core/Constants";
import { DEFAULT_SETTINGS } from "../../../src/game/core/Settings";
import { CURRENT_SAVE_VERSION, SaveSystem } from "../../../src/game/save/SaveSystem";
import {
  expectCampaignProgress,
  expectCampaignResources,
  expectHeroCore,
  expectInventoryInstance,
  expectNoFixtureCrash,
  expectRetinueUnit,
  expectRivalState,
  expectRivalTrophy,
  loadSaveFixtureText,
  migrateSaveFixtureToCurrent,
  parseSaveFixture
} from "./SaveFixtureTestUtils";

const currentFixtureFiles = [
  "v1-basic-hero.json",
  "v2-settings-only.json",
  "v2-campaign-progress.json",
  "v2-affixed-inventory.json",
  "v2-legacy-equipment-catalog-id.json",
  "v2-retinue-rivals-cinderfen.json",
  "v2-missing-optional-fields.json",
  "v2-future-extra-fields.json"
];

describe("save migration fixtures", () => {
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

  it("rejects invalid JSON safely without replacing the current save", () => {
    const invalid = loadSaveFixtureText("invalid-json.txt");
    const validLegacy = loadSaveFixtureText("v1-basic-hero.json");
    globalThis.localStorage.setItem(SAVE_KEY, validLegacy);

    expect(parseSaveFixture("invalid-json.txt")).toBeNull();
    expect(SaveSystem.load()?.hero.heroName).toBe("Legacy Aster");
    expect(SaveSystem.importSaveJson(invalid)).toBe(false);
    expect(globalThis.localStorage.getItem(SAVE_KEY)).toBe(validLegacy);
  });

  it("loads settings-only saves without treating them as playable progress", () => {
    globalThis.localStorage.setItem(SAVE_KEY, loadSaveFixtureText("v2-settings-only.json"));

    const loaded = SaveSystem.load();

    expect(loaded?.version).toBe(CURRENT_SAVE_VERSION);
    expect(SaveSystem.isSettingsOnlySave(loaded)).toBe(true);
    expect(SaveSystem.hasSave()).toBe(false);
    expect(loaded?.settings).toMatchObject({
      masterVolume: 0.35,
      screenShakeEnabled: false,
      floatingTextEnabled: false,
      fogEnabledOverride: "enabled",
      reducedMotionEnabled: true,
      uiScale: 1.15,
      colorblindMinimapPalette: true
    });
  });

  it("migrates a legacy V1 hero fixture into the current V2 shape", () => {
    const migrated = migrateSaveFixtureToCurrent("v1-basic-hero.json");

    expect(migrated?.version).toBe(CURRENT_SAVE_VERSION);
    expect(migrated?.createdAt).toBe("2026-01-01T00:00:00.000Z");
    expect(migrated?.updatedAt).toBe("2026-01-01T00:00:00.000Z");
    expect(migrated?.settings).toEqual(DEFAULT_SETTINGS);
    expectHeroCore(migrated, {
      heroName: "Legacy Aster",
      level: 3,
      xp: 220,
      skillPoints: 1
    });
    expectCampaignResources(migrated, { crowns: 60, stone: 20, iron: 5, aether: 2 });
    expect(migrated?.hero.inventory.map((entry) => entry.itemId)).toEqual(["weathered_command_sword"]);
    expect(migrated?.hero.equipment.weapon).toBe(migrated?.hero.inventory[0].instanceId);
    expect(migrated?.campaign.choiceIdsClaimed).toEqual(["chapel_of_the_marches:pray_for_strength"]);
  });

  it("loads current V2 campaign progress with resources, choices, purchases, upgrades, and Chapter 2 selection", () => {
    const migrated = migrateSaveFixtureToCurrent("v2-campaign-progress.json");

    expectHeroCore(migrated, {
      heroName: "Cinderfen Marshal",
      level: 4,
      xp: 360
    });
    expectCampaignResources(migrated, { crowns: 90, stone: 34, iron: 22, aether: 17 });
    expect(migrated?.campaign.resourcesSpent).toEqual({ crowns: 150, stone: 50, iron: 35, aether: 12 });
    expectCampaignProgress(migrated, {
      completedNodeIds: ["ashen_outpost", "cinderfen_overlook", "cinderfen_crossing"],
      unlockedNodeIds: ["cinderfen_waystation", "cinderfen_watch"],
      nodeRewardsClaimedIds: ["border_village", "cinderfen_crossing"],
      choiceIdsClaimed: ["cinderfen_overlook:aid_marsh_refugees", "cinderfen_waystation:refugee_scouts"],
      townServiceClaimedIds: ["marcher_camp:purchase_emberglass_wand", "cinderfen_waystation:refugee_scouts"],
      selectedChapterId: "cinderfen_road",
      selectedNodeId: "cinderfen_watch"
    });
    expect(migrated?.campaign.townServiceUseCounts).toMatchObject({
      "marcher_camp:buy_supplies": 2,
      "cinderfen_waystation:shrine_attunement": 1
    });
    expect(migrated?.campaign.strongholdUpgradeRanks).toEqual({
      training_yard_i: 1,
      quartermaster_stores_i: 1,
      quartermaster_stores_ii: 1
    });
    expect(migrated?.campaign.activeModifierIds).toEqual(["inspired_militia", "shrine_attunement"]);
  });

  it("preserves affixed item instances and equipment links", () => {
    const migrated = migrateSaveFixtureToCurrent("v2-affixed-inventory.json");

    expectInventoryInstance(migrated, "fixture:captains_seal:1", {
      itemId: "captains_seal",
      source: "battle_reward:bandit_hillfort",
      affixes: ["commanding", "sturdy"],
      locked: true,
      favorite: true
    });
    expectInventoryInstance(migrated, "fixture:emberglass_wand:1", {
      itemId: "emberglass_wand",
      affixes: ["sharp", "aether_touched"]
    });
    expect(migrated?.hero.equipment.trinket).toBe("fixture:captains_seal:1");
    expect(migrated?.hero.equipment.weapon).toBe("fixture:emberglass_wand:1");
    expect(migrated?.campaign.townServiceClaimedIds).toEqual(["marcher_camp:purchase_emberglass_wand"]);
  });

  it("migrates legacy equipment catalog IDs when they appear inside a V2-shaped save", () => {
    const migrated = migrateSaveFixtureToCurrent("v2-legacy-equipment-catalog-id.json");
    const trinket = migrated?.hero.inventory.find((entry) => entry.itemId === "captains_seal");
    const weapon = migrated?.hero.inventory.find((entry) => entry.itemId === "scouts_bow");

    expect(trinket).toBeDefined();
    expect(weapon).toBeDefined();
    expect(migrated?.hero.equipment.trinket).toBe(trinket?.instanceId);
    expect(migrated?.hero.equipment.weapon).toBe(weapon?.instanceId);
    expect(migrated?.hero.inventory.map((entry) => entry.itemId)).toEqual(["captains_seal", "scouts_bow"]);
  });

  it("preserves retinue, rival state, rival trophies, and completed Cinderfen route progress", () => {
    const migrated = migrateSaveFixtureToCurrent("v2-retinue-rivals-cinderfen.json");

    expectCampaignProgress(migrated, {
      completedNodeIds: ["cinderfen_overlook", "cinderfen_crossing", "cinderfen_watch", "cinderfen_aftermath"],
      unlockedNodeIds: ["cinderfen_waystation", "cinderfen_aftermath"],
      choiceIdsClaimed: ["cinderfen_overlook:raise_malrecs_standard", "cinderfen_aftermath:aid_the_fenfolk"],
      selectedChapterId: "cinderfen_road",
      selectedNodeId: "cinderfen_aftermath"
    });
    expectRetinueUnit(migrated, "retinue:cinderfen_crossing:ranger-1", {
      unitTypeId: "ranger",
      rank: "veteran",
      xp: 155,
      kills: 6,
      sourceBattleId: "cinderfen_crossing",
      status: "active"
    });
    expectRivalState(migrated, "captain_malrec", {
      encounters: 1,
      defeats: 1,
      lastOutcome: "defeated",
      disposition: "humiliated",
      isKnownToPlayer: true
    });
    expectRivalState(migrated, "veyra_cinders", {
      encounters: 2,
      victoriesAgainstPlayer: 1,
      lastOutcome: "triumphant",
      disposition: "emboldened"
    });
    expectRivalTrophy(migrated, "trophy_malrec_outpost_standard", {
      enemyHeroId: "captain_malrec",
      sourceNodeId: "ashen_outpost",
      label: "Malrec's Outpost Standard"
    });
    expect(migrated?.campaign.strongholdUpgradeRanks).toEqual({
      training_yard_i: 1,
      training_yard_ii: 1,
      watch_post_i: 1
    });
  });

  it("normalizes missing optional V2 fields into safe defaults", () => {
    const migrated = migrateSaveFixtureToCurrent("v2-missing-optional-fields.json");

    expectHeroCore(migrated, { heroName: "Sparse Save", level: 2, xp: 100 });
    expect(migrated?.version).toBe(CURRENT_SAVE_VERSION);
    expect(typeof migrated?.createdAt).toBe("string");
    expect(typeof migrated?.updatedAt).toBe("string");
    expect(migrated?.hero.inventory).toEqual([]);
    expect(migrated?.hero.equipment).toEqual({});
    expect(migrated?.hero.factionReputation).toMatchObject({
      free_marches: 10,
      ashen_covenant: -10,
      common_folk: 0
    });
    expect(migrated?.campaign.resources).toEqual({ crowns: 0, stone: 0, iron: 0, aether: 0 });
    expect(migrated?.campaign.resourcesSpent).toEqual({ crowns: 0, stone: 0, iron: 0, aether: 0 });
    expect(migrated?.campaign.retinueUnits).toEqual([]);
    expect(migrated?.campaign.rivals).toEqual([]);
    expect(migrated?.campaign.rivalTrophies).toEqual([]);
    expect(migrated?.campaign.selectedChapterId).toBe("border_marches");
    expect(migrated?.settings).toEqual(DEFAULT_SETTINGS);
    expect(migrated?.statistics).toEqual({});
  });

  it("tolerates future-ish unknown fields without crashing current normalization", () => {
    const migrated = expectNoFixtureCrash("future-ish fixture migration", () =>
      migrateSaveFixtureToCurrent("v2-future-extra-fields.json")
    );

    expectHeroCore(migrated, { heroName: "Future Tolerant", xp: 410 });
    expectCampaignResources(migrated, { crowns: 77, stone: 33, iron: 21, aether: 9 });
    expect(migrated?.campaign.resources).not.toHaveProperty("crystals");
    expect(migrated).not.toHaveProperty("futureExpansion");
    expect(migrated?.hero).not.toHaveProperty("futureHeroField");
    expect(migrated?.campaign).not.toHaveProperty("futureCampaignField");
    expect(migrated?.hero.factionReputation.future_faction).toBe(7);
    expect(migrated?.statistics).toEqual({
      futureTelemetryOptIn: false,
      fixture: "future-extra-fields"
    });
  });

  it("keeps every current save fixture loadable through the migration path", () => {
    currentFixtureFiles.forEach((filename) => {
      const migrated = expectNoFixtureCrash(`${filename} migration`, () => migrateSaveFixtureToCurrent(filename));
      expect(migrated?.version).toBe(CURRENT_SAVE_VERSION);
    });
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
