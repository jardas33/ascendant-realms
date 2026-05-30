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
import { DEFAULT_SETTINGS, normalizeSettingsData, shouldShowFloatingText } from "./Settings";
import { calculateLiveHeroStats, createItemInstance, getAllocatedBuildArchetypes } from "./HeroProgressionRules";
import { getRelicInventoryState } from "./progression/RelicInventoryRules";
import { applyCampaignChoice, createStartedCampaignSave } from "./CampaignRules";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import { HERO_CLASS_BY_ID, ITEM_BY_ID, ORIGIN_BY_ID, SKILL_NODE_BY_ID } from "../data/contentIndex";
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

  it("preserves existing item instances while removing duplicate instance ids", () => {
    const itemInstance = createItemInstance("captains_seal", "test");
    const normalized = normalizeHeroSaveData({
      ...createFallbackHeroSave(),
      inventory: [
        { ...itemInstance, affixes: ["steady", "steady"], locked: true, favorite: true },
        { ...itemInstance, source: "duplicate" }
      ],
      equipment: {
        trinket: itemInstance.instanceId
      }
    });

    expect(normalized?.inventory).toHaveLength(1);
    expect(normalized?.inventory[0]).toMatchObject({
      instanceId: itemInstance.instanceId,
      itemId: "captains_seal",
      affixes: ["steady"],
      locked: true,
      favorite: true
    });
    expect(normalized?.equipment.trinket).toBe(itemInstance.instanceId);
  });

  it("loads old saves without relic fields as an empty relic inventory", () => {
    const normalized = normalizeHeroSaveData({
      ...createFallbackHeroSave(),
      inventory: undefined,
      equipment: undefined
    });

    expect(normalized).not.toBeNull();
    expect(normalized?.equipment.relic).toBeUndefined();
    expect(getRelicInventoryState(normalized!, ITEM_BY_ID)).toEqual({
      acquiredRelicIds: [],
      equippedRelicIds: []
    });
  });

  it("ignores unknown relic ids in relic inventory helpers without rejecting the save", () => {
    const normalized = normalizeHeroSaveData({
      ...createFallbackHeroSave(),
      inventory: ["future_unknown_relic"],
      equipment: {
        relic: "future_unknown_relic"
      }
    });

    expect(normalized?.equipment.relic).toBe(normalized?.inventory[0].instanceId);
    expect(getRelicInventoryState(normalized!, ITEM_BY_ID)).toEqual({
      acquiredRelicIds: [],
      equippedRelicIds: []
    });
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

  it("keeps unknown skill ids loadable while skill helpers ignore them", () => {
    const normalized = normalizeHeroSaveData({
      ...createFallbackHeroSave(),
      allocatedSkills: {
        future_unknown_skill: 4,
        combat_drill: 1
      }
    });

    expect(normalized?.allocatedSkills.future_unknown_skill).toBe(4);
    expect(getAllocatedBuildArchetypes(normalized!, SKILL_NODE_BY_ID)).toEqual(["warrior"]);
    const stats = calculateLiveHeroStats(normalized!, HERO_CLASS_BY_ID.warlord, ORIGIN_BY_ID.exiled_noble, SKILL_NODE_BY_ID, ITEM_BY_ID);
    expect(stats.damage).toBeGreaterThan(HERO_CLASS_BY_ID.warlord.baseStats.damage);
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
      optionalObjectiveCompletionIds: [
        "ashen_outpost:capture_burned_shrine",
        "ashen_outpost:capture_burned_shrine",
        "ashen_outpost:missing_objective",
        "missing_node:capture_burned_shrine"
      ],
      choiceIdsClaimed: ["chapel_of_the_marches:ask_for_guidance", "chapel_of_the_marches:ask_for_guidance"],
      townServiceClaimedIds: ["marcher_camp:purchase_emberglass_wand", "marcher_camp:purchase_emberglass_wand"],
      townServiceUseCounts: { "marcher_camp:buy_supplies": 2, bad: -1 },
      activeModifierIds: ["inspired_militia", "missing_modifier", "inspired_militia"],
      strongholdUpgradeRanks: { training_yard_i: 1.8, quartermaster_stores_ii: 1, missing_upgrade: 2, watch_post_i: -1 },
      retinueUnits: [
        {
          retinueUnitId: "retinue:border_village:unit-1",
          unitTypeId: "militia",
          name: "Gate Militia",
          rank: "veteran",
          xp: 120.8,
          kills: 2.4,
          sourceBattleId: "border_village",
          acquiredAt: "2026-05-02T12:00:00.000Z",
          status: "active",
          battlesSurvived: 2.9,
          missionsDeployed: 1.2
        },
        {
          retinueUnitId: "retinue:border_village:unit-1",
          unitTypeId: "militia",
          rank: "veteran",
          xp: 120,
          kills: 2,
          sourceBattleId: "duplicate",
          acquiredAt: "2026-05-02T12:00:00.000Z",
          status: "active"
        },
        {
          retinueUnitId: "bad",
          unitTypeId: "missing_unit",
          rank: "legend",
          xp: 999,
          kills: 999,
          sourceBattleId: "bad",
          acquiredAt: "bad",
          status: "active"
        },
        {
          retinueUnitId: "bad-worker",
          unitTypeId: "worker",
          rank: "veteran",
          xp: 120,
          kills: 2,
          sourceBattleId: "bad",
          acquiredAt: "bad",
          status: "active"
        }
      ],
      retinueDeploymentIds: ["retinue:border_village:unit-1", "missing-retinue", "retinue:border_village:unit-1"],
      rivals: [
        {
          enemyHeroId: "veyra_cinders",
          encounters: 2.8,
          defeats: 1.2,
          victoriesAgainstPlayer: 1.9,
          lastEncounterNodeId: "aether_well_ruins",
          lastOutcome: "escaped",
          disposition: "wary",
          activeModifiers: ["rival_wary_hp_5", "missing_modifier", "rival_wary_hp_5"],
          isKnownToPlayer: true
        },
        {
          enemyHeroId: "veyra_cinders",
          encounters: 99,
          defeats: 99,
          victoriesAgainstPlayer: 99,
          lastOutcome: "triumphant",
          disposition: "emboldened",
          activeModifiers: ["rival_emboldened_damage_5"],
          isKnownToPlayer: true
        },
        {
          enemyHeroId: "missing_rival",
          encounters: 1,
          defeats: 0,
          victoriesAgainstPlayer: 0,
          lastOutcome: "escaped",
          disposition: "wary",
          activeModifiers: [],
          isKnownToPlayer: true
        }
      ],
      rivalTrophies: [
        {
          trophyId: "trophy_veyra_cinder_lens",
          enemyHeroId: "veyra_cinders",
          earnedAt: "2026-05-02T19:58:00.000Z",
          sourceNodeId: "aether_well_ruins",
          label: "Cinder-Seer's Cracked Lens",
          description: "A cracked aether lens.",
          effect: "First defeat claimed."
        },
        {
          trophyId: "trophy_veyra_cinder_lens",
          enemyHeroId: "veyra_cinders",
          earnedAt: "duplicate",
          sourceNodeId: "aether_well_ruins",
          label: "Duplicate",
          description: "Duplicate"
        },
        {
          trophyId: "bad",
          enemyHeroId: "missing_rival",
          earnedAt: "bad",
          sourceNodeId: "missing_node",
          label: "",
          description: ""
        }
      ],
      resources: { crowns: 25, stone: -5, iron: 12.8, aether: 3 },
      resourcesSpent: { crowns: 60, stone: -4, iron: 2, aether: 1 },
      selectedChapterId: "missing_chapter",
      selectedNodeId: "old_stone_road"
    });

    expect(isCampaignSaveData(normalized)).toBe(true);
    expect(normalized?.resources).toEqual({ crowns: 25, stone: 0, iron: 12, aether: 3 });
    expect(normalized?.completedNodeIds).toEqual(["border_village"]);
    expect(normalized?.unlockedNodeIds).toEqual(["border_village", "old_stone_road"]);
    expect(normalized?.lockedNodeIds).toEqual(["refugee_caravan"]);
    expect(normalized?.optionalObjectiveCompletionIds).toEqual(["ashen_outpost:capture_burned_shrine"]);
    expect(normalized?.choiceIdsClaimed).toEqual(["chapel_of_the_marches:ask_for_guidance"]);
    expect(normalized?.townServiceClaimedIds).toEqual(["marcher_camp:purchase_emberglass_wand"]);
    expect(normalized?.townServiceUseCounts).toEqual({ "marcher_camp:buy_supplies": 2 });
    expect(normalized?.activeModifierIds).toEqual(["inspired_militia"]);
    expect(normalized?.strongholdUpgradeRanks).toEqual({ training_yard_i: 1, quartermaster_stores_ii: 1 });
    expect(normalized?.retinueUnits).toEqual([
      {
        retinueUnitId: "retinue:border_village:unit-1",
        unitTypeId: "militia",
        name: "Gate Militia",
        rank: "veteran",
        xp: 120,
        kills: 2,
        sourceBattleId: "border_village",
        acquiredAt: "2026-05-02T12:00:00.000Z",
        status: "active",
        battlesSurvived: 2,
        missionsDeployed: 1
      }
    ]);
    expect(normalized?.retinueDeploymentIds).toEqual(["retinue:border_village:unit-1"]);
    expect(normalized?.rivals).toEqual([
      {
        enemyHeroId: "veyra_cinders",
        encounters: 2,
        defeats: 1,
        victoriesAgainstPlayer: 1,
        lastEncounterNodeId: "aether_well_ruins",
        lastOutcome: "escaped",
        disposition: "wary",
        activeModifiers: ["rival_wary_hp_5"],
        isKnownToPlayer: true
      }
    ]);
    expect(normalized?.rivalTrophies).toEqual([
      {
        trophyId: "trophy_veyra_cinder_lens",
        enemyHeroId: "veyra_cinders",
        earnedAt: "2026-05-02T19:58:00.000Z",
        sourceNodeId: "aether_well_ruins",
        label: "Cinder-Seer's Cracked Lens",
        description: "A cracked aether lens.",
        effect: "First defeat claimed."
      }
    ]);
    expect(normalized?.selectedChapterId).toBe("border_marches");
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
    expect(normalized?.optionalObjectiveCompletionIds).toEqual([]);
    expect(normalized?.choiceIdsClaimed).toEqual([]);
    expect(normalized?.townServiceClaimedIds).toEqual([]);
    expect(normalized?.townServiceUseCounts).toEqual({});
    expect(normalized?.lockedNodeIds).toEqual([]);
    expect(normalized?.activeModifierIds).toEqual([]);
    expect(normalized?.strongholdUpgradeRanks).toEqual({});
    expect(normalized?.retinueUnits).toEqual([]);
    expect(normalized?.retinueDeploymentIds).toEqual([]);
    expect(normalized?.rivals).toEqual([]);
    expect(normalized?.rivalTrophies).toEqual([]);
    expect(normalized?.selectedChapterId).toBe("border_marches");
  });

  it("preserves valid Chapter 2 selected chapter and node state", () => {
    const normalized = normalizeCampaignSaveData({
      ...createFallbackCampaignSave(),
      started: true,
      difficulty: "easy",
      completedNodeIds: ["ashen_outpost", "cinderfen_overlook", "cinderfen_crossing"],
      unlockedNodeIds: ["cinderfen_overlook", "cinderfen_waystation", "cinderfen_crossing", "cinderfen_watch"],
      selectedChapterId: "cinderfen_road",
      selectedNodeId: "cinderfen_watch"
    });

    expect(normalized?.selectedChapterId).toBe("cinderfen_road");
    expect(normalized?.selectedNodeId).toBe("cinderfen_watch");
  });

  it("migrates legacy stronghold upgrade ids into rank data", () => {
    const normalized = normalizeCampaignSaveData({
      ...createFallbackCampaignSave(),
      started: true,
      difficulty: "easy",
      strongholdUpgradeIds: ["training_yard_i", "quartermaster_stores_ii", "missing_upgrade", "training_yard_i"]
    });

    expect(normalized?.strongholdUpgradeRanks).toEqual({ training_yard_i: 1, quartermaster_stores_ii: 1 });
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
    expect(migrated?.settings).toEqual(DEFAULT_SETTINGS);
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
    expect(parsed.settings).toEqual(DEFAULT_SETTINGS);
    expect(parsed.statistics).toEqual({});
  });

  it("saves and loads completed Cinderfen Overlook choice state", () => {
    const hero = createFallbackHeroSave();
    const campaign = createStartedCampaignSave({
      ...createFallbackCampaignSave(),
      resources: { crowns: 100, stone: 0, iron: 0, aether: 20 },
      completedNodeIds: [
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost"
      ],
      unlockedNodeIds: [
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost",
        "cinderfen_overlook"
      ]
    });
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_overlook")!;
    const choice = node.choices!.find((entry) => entry.id === "aid_marsh_refugees")!;
    const applied = applyCampaignChoice({ campaign, hero, node, choice });

    expect(applied.ok).toBe(true);
    expect(SaveSystem.saveGame(applied.hero, applied.campaign)).toBe(true);
    const loaded = SaveSystem.load();

    expect(loaded?.campaign.completedNodeIds).toContain("cinderfen_overlook");
    expect(loaded?.campaign.unlockedNodeIds).toContain("cinderfen_crossing");
    expect(loaded?.campaign.choiceIdsClaimed).toContain("cinderfen_overlook:aid_marsh_refugees");
    expect(loaded?.campaign.resources).toMatchObject({ crowns: 45, iron: 10 });
    expect(loaded?.campaign.resourcesSpent.crowns).toBe(55);
    expect(loaded?.campaign.activeModifierIds).toContain("inspired_militia");
    expect(loaded?.hero.factionReputation.common_folk).toBe(hero.factionReputation.common_folk + 6);
    expect(loaded?.hero.xp).toBe(25);
  });

  it("saves and loads Cinderfen Waystation service state without duplicating one-time rewards", () => {
    const hero = createFallbackHeroSave();
    const campaign = createStartedCampaignSave({
      ...createFallbackCampaignSave(),
      resources: { crowns: 90, stone: 0, iron: 0, aether: 45 },
      completedNodeIds: [
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost",
        "cinderfen_overlook"
      ],
      unlockedNodeIds: [
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost",
        "cinderfen_overlook",
        "cinderfen_waystation",
        "cinderfen_crossing"
      ]
    });
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_waystation")!;
    const repeatable = node.choices!.find((entry) => entry.id === "shrine_attunement")!;
    const oneTime = node.choices!.find((entry) => entry.id === "refugee_scouts")!;
    const first = applyCampaignChoice({ campaign, hero, node, choice: repeatable });
    const second = applyCampaignChoice({ campaign: first.campaign, hero: first.hero, node, choice: oneTime });

    expect(second.ok).toBe(true);
    expect(SaveSystem.saveGame(second.hero, second.campaign)).toBe(true);
    const loaded = SaveSystem.load();
    const repeatedOneTime = applyCampaignChoice({ campaign: loaded!.campaign, hero: loaded!.hero, node, choice: oneTime });

    expect(loaded?.campaign.completedNodeIds).not.toContain("cinderfen_waystation");
    expect(loaded?.campaign.resources).toMatchObject({ crowns: 65, aether: 33 });
    expect(loaded?.campaign.resourcesSpent).toMatchObject({ crowns: 25, aether: 12 });
    expect(loaded?.campaign.activeModifierIds).toContain("shrine_attunement");
    expect(loaded?.campaign.townServiceUseCounts["cinderfen_waystation:shrine_attunement"]).toBe(1);
    expect(loaded?.campaign.townServiceClaimedIds).toContain("cinderfen_waystation:refugee_scouts");
    expect(loaded?.campaign.choiceIdsClaimed).toContain("cinderfen_waystation:refugee_scouts");
    expect(loaded?.hero.factionReputation.common_folk).toBe(hero.factionReputation.common_folk + 2);
    expect(repeatedOneTime.ok).toBe(false);
    expect(repeatedOneTime.reason).toContain("Already purchased");
    expect(repeatedOneTime.campaign.resources.crowns).toBe(65);
    expect(repeatedOneTime.hero.xp).toBe(hero.xp + 10);
  });

  it("saves and loads the Malrec Standard Cinderfen trophy choice without duplicating rewards", () => {
    const hero = createFallbackHeroSave();
    const campaign = createStartedCampaignSave({
      ...createFallbackCampaignSave(),
      resources: { crowns: 0, stone: 0, iron: 0, aether: 0 },
      completedNodeIds: [
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost"
      ],
      unlockedNodeIds: [
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost",
        "cinderfen_overlook"
      ],
      rivalTrophies: [
        {
          trophyId: "trophy_malrec_outpost_standard",
          enemyHeroId: "captain_malrec",
          earnedAt: "2026-05-03T12:00:00.000Z",
          sourceNodeId: "ashen_outpost",
          label: "Malrec's Outpost Standard",
          description: "The torn fortress standard of Captain Malrec's Ashen Outpost command."
        }
      ]
    });
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_overlook")!;
    const choice = node.choices!.find((entry) => entry.id === "raise_malrecs_standard")!;
    const applied = applyCampaignChoice({ campaign, hero, node, choice });

    expect(applied.ok).toBe(true);
    expect(SaveSystem.saveGame(applied.hero, applied.campaign)).toBe(true);
    const loaded = SaveSystem.load();
    const repeated = applyCampaignChoice({ campaign: loaded!.campaign, hero: loaded!.hero, node, choice });

    expect(loaded?.campaign.rivalTrophies.map((trophy) => trophy.trophyId)).toEqual(["trophy_malrec_outpost_standard"]);
    expect(loaded?.campaign.choiceIdsClaimed).toContain("cinderfen_overlook:raise_malrecs_standard");
    expect(loaded?.campaign.activeModifierIds).toContain("well_rested");
    expect(loaded?.hero.xp).toBe(hero.xp + 10);
    expect(loaded?.hero.factionReputation.free_marches).toBe(hero.factionReputation.free_marches + 3);
    expect(repeated.ok).toBe(false);
    expect(repeated.campaign.activeModifierIds).toEqual(["well_rested"]);
    expect(repeated.hero.xp).toBe(hero.xp + 10);
  });

  it("saves and loads Cinderfen Aftermath choice state without duplicating rewards", () => {
    const hero = createFallbackHeroSave();
    const campaign = createStartedCampaignSave({
      ...createFallbackCampaignSave(),
      resources: { crowns: 100, stone: 50, iron: 0, aether: 25 },
      completedNodeIds: [
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost",
        "cinderfen_overlook",
        "cinderfen_crossing",
        "cinderfen_watch"
      ],
      unlockedNodeIds: [
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost",
        "cinderfen_overlook",
        "cinderfen_waystation",
        "cinderfen_crossing",
        "cinderfen_watch",
        "cinderfen_aftermath"
      ]
    });
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_aftermath")!;
    const choice = node.choices!.find((entry) => entry.id === "aid_the_fenfolk")!;
    const applied = applyCampaignChoice({ campaign, hero, node, choice });

    expect(applied.ok).toBe(true);
    expect(SaveSystem.saveGame(applied.hero, applied.campaign)).toBe(true);
    const loaded = SaveSystem.load();
    const repeated = applyCampaignChoice({ campaign: loaded!.campaign, hero: loaded!.hero, node, choice });

    expect(loaded?.campaign.completedNodeIds).toContain("cinderfen_aftermath");
    expect(loaded?.campaign.choiceIdsClaimed).toContain("cinderfen_aftermath:aid_the_fenfolk");
    expect(loaded?.campaign.resources).toMatchObject({ crowns: 60, iron: 8 });
    expect(loaded?.campaign.resourcesSpent.crowns).toBe(40);
    expect(loaded?.hero.factionReputation.common_folk).toBe(hero.factionReputation.common_folk + 5);
    expect(loaded?.hero.xp).toBe(hero.xp + 12);
    expect(repeated.ok).toBe(false);
    expect(repeated.reason).toContain("Node completed");
    expect(repeated.reason).toContain("Already chosen");
    expect(repeated.campaign.resources).toMatchObject({ crowns: 60, iron: 8 });
    expect(repeated.hero.xp).toBe(hero.xp + 12);
  });

  it("loads V2 saves and normalizes settings", () => {
    const v2 = {
      version: 2,
      createdAt: "2026-01-01T00:00:00.000Z",
      updatedAt: "2026-01-02T00:00:00.000Z",
      hero: createFallbackHeroSave(),
      campaign: createFallbackCampaignSave(),
      settings: { masterVolume: 2, sfxVolume: 0.2, floatingTextEnabled: false, uiScale: 9 },
      statistics: { futureBattles: 0 }
    };
    globalThis.localStorage.setItem(SAVE_KEY, JSON.stringify(v2));

    const loaded = SaveSystem.load();

    expect(loaded?.version).toBe(2);
    expect(loaded?.createdAt).toBe(v2.createdAt);
    expect(loaded?.settings).toEqual({
      ...DEFAULT_SETTINGS,
      masterVolume: 1,
      sfxVolume: 0.2,
      floatingTextEnabled: false,
      uiScale: 1.25
    });
    expect(loaded?.statistics).toEqual(v2.statistics);
  });

  it("saves and loads reputation values without campaign migration fields", () => {
    const hero = {
      ...createFallbackHeroSave(),
      factionReputation: {
        free_marches: 50,
        ashen_covenant: -50,
        sylvan_concord: 0,
        common_folk: 25,
        old_faith: 25
      }
    };
    const campaign = createFallbackCampaignSave();

    expect(SaveSystem.saveGame(hero, campaign)).toBe(true);
    const loaded = SaveSystem.load();

    expect(loaded?.hero.factionReputation).toMatchObject(hero.factionReputation);
    expect(loaded?.campaign.activeModifierIds).toEqual([]);
    expect(loaded?.campaign.strongholdUpgradeRanks).toEqual({});
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
    expect(migrated?.campaign.optionalObjectiveCompletionIds).toEqual([]);
    expect(migrated?.campaign.choiceIdsClaimed).toEqual([]);
    expect(migrated?.campaign.townServiceClaimedIds).toEqual([]);
    expect(migrated?.campaign.townServiceUseCounts).toEqual({});
    expect(migrated?.campaign.strongholdUpgradeRanks).toEqual({});
    expect(migrated?.campaign.retinueDeploymentIds).toEqual([]);
    expect(migrated?.settings).toEqual(DEFAULT_SETTINGS);
    expect(migrated?.statistics).toEqual({});
  });

  it("saves settings and keeps them through later hero writes", () => {
    const settings = normalizeSettingsData({
      ...DEFAULT_SETTINGS,
      masterVolume: 0.35,
      floatingTextEnabled: false,
      reducedMotionEnabled: true,
      uiScale: 1.15
    });

    expect(SaveSystem.saveSettings(settings)).toBe(true);
    const settingsOnly = SaveSystem.load();
    expect(SaveSystem.isSettingsOnlySave(settingsOnly)).toBe(true);
    expect(SaveSystem.hasSave()).toBe(false);
    expect(settingsOnly?.settings).toEqual(settings);

    expect(SaveSystem.saveHero(createFallbackHeroSave())).toBe(true);
    const loaded = SaveSystem.load();
    expect(SaveSystem.isSettingsOnlySave(loaded)).toBe(false);
    expect(SaveSystem.hasSave()).toBe(true);
    expect(loaded?.settings).toEqual(settings);
  });

  it("uses accessibility settings for feature gates", () => {
    expect(shouldShowFloatingText(DEFAULT_SETTINGS)).toBe(true);
    expect(shouldShowFloatingText({ ...DEFAULT_SETTINGS, floatingTextEnabled: false })).toBe(false);
  });

  it("saves and loads town purchases and campaign spending totals", () => {
    const hero = {
      ...createFallbackHeroSave(),
      inventory: [
        createItemInstance("emberglass_wand", "test", "2026-05-01T00:00:00.000Z", {
          affixes: ["aether_touched"]
        })
      ]
    };
    const campaign = {
      ...createFallbackCampaignSave(),
      started: true,
      resources: { crowns: 45, stone: 25, iron: 12, aether: 6 },
      resourcesSpent: { crowns: 55, stone: 0, iron: 0, aether: 0 },
      townServiceClaimedIds: ["marcher_camp:purchase_emberglass_wand"],
      townServiceUseCounts: { "marcher_camp:purchase_emberglass_wand": 1 },
      strongholdUpgradeRanks: { training_yard_i: 1, quartermaster_stores_ii: 1 }
    };

    expect(SaveSystem.saveGame(hero, campaign)).toBe(true);
    const loaded = SaveSystem.load();

    expect(loaded?.hero.inventory.map((instance) => instance.itemId)).toEqual(["emberglass_wand"]);
    expect(loaded?.hero.inventory[0].affixes).toEqual(["aether_touched"]);
    expect(loaded?.campaign.resourcesSpent.crowns).toBe(55);
    expect(loaded?.campaign.townServiceClaimedIds).toEqual(["marcher_camp:purchase_emberglass_wand"]);
    expect(loaded?.campaign.townServiceUseCounts).toEqual({ "marcher_camp:purchase_emberglass_wand": 1 });
    expect(loaded?.campaign.strongholdUpgradeRanks).toEqual({ training_yard_i: 1, quartermaster_stores_ii: 1 });
  });

  it("saves and loads retinue units through campaign data", () => {
    const hero = createFallbackHeroSave();
    const campaign = {
      ...createFallbackCampaignSave(),
      started: true,
      retinueUnits: [
        {
          retinueUnitId: "retinue:border_village:unit-1",
          unitTypeId: "ranger",
          name: "Old Road Ranger",
          rank: "veteran" as const,
          xp: 140,
          kills: 3,
          sourceBattleId: "border_village",
          acquiredAt: "2026-05-02T12:00:00.000Z",
          status: "active" as const,
          battlesSurvived: 1,
          missionsDeployed: 0
        }
      ],
      retinueDeploymentIds: ["retinue:border_village:unit-1"]
    };

    expect(SaveSystem.saveGame(hero, campaign)).toBe(true);
    const loaded = SaveSystem.load();

    expect(loaded?.campaign.retinueUnits).toEqual(campaign.retinueUnits);
    expect(loaded?.campaign.retinueDeploymentIds).toEqual(["retinue:border_village:unit-1"]);
  });

  it("loads Retinue recovery fields safely and filters unavailable deployment ids", () => {
    const normalized = normalizeCampaignSaveData({
      ...createFallbackCampaignSave(),
      started: true,
      retinueUnits: [
        {
          retinueUnitId: "retinue:ready:militia",
          unitTypeId: "militia",
          rank: "veteran",
          xp: 140,
          kills: 3,
          sourceBattleId: "border_village",
          acquiredAt: "2026-05-02T12:00:00.000Z",
          status: "active"
        },
        {
          retinueUnitId: "retinue:legacy:wounded",
          unitTypeId: "ranger",
          rank: "seasoned",
          xp: 80,
          kills: 1,
          sourceBattleId: "old_stone_road",
          acquiredAt: "2026-05-02T12:00:00.000Z",
          status: "wounded",
          recoveryMissionsRemaining: 0
        },
        {
          retinueUnitId: "retinue:lost:acolyte",
          unitTypeId: "acolyte",
          rank: "veteran",
          xp: 150,
          kills: 2,
          sourceBattleId: "aether_well_ruins",
          acquiredAt: "2026-05-02T12:00:00.000Z",
          status: "lost"
        }
      ],
      retinueDeploymentIds: ["retinue:ready:militia", "retinue:legacy:wounded", "retinue:lost:acolyte"]
    });

    expect(normalized?.retinueUnits).toEqual([
      expect.objectContaining({ retinueUnitId: "retinue:ready:militia", status: "active" }),
      expect.objectContaining({
        retinueUnitId: "retinue:legacy:wounded",
        status: "recovering",
        recoveryMissionsRemaining: 1
      })
    ]);
    expect(normalized?.retinueDeploymentIds).toEqual(["retinue:ready:militia"]);
  });

  it("saves and loads rival state and trophy records through campaign data", () => {
    const hero = createFallbackHeroSave();
    const campaign = {
      ...createFallbackCampaignSave(),
      started: true,
      rivals: [
        {
          enemyHeroId: "captain_malrec",
          encounters: 1,
          defeats: 0,
          victoriesAgainstPlayer: 1,
          lastEncounterNodeId: "ashen_outpost",
          lastOutcome: "triumphant" as const,
          disposition: "emboldened" as const,
          activeModifiers: ["rival_emboldened_damage_5" as const],
          isKnownToPlayer: true
        }
      ],
      rivalTrophies: [
        {
          trophyId: "trophy_malrec_outpost_standard",
          enemyHeroId: "captain_malrec",
          earnedAt: "2026-05-02T19:58:00.000Z",
          sourceNodeId: "ashen_outpost",
          label: "Malrec's Outpost Standard",
          description: "The torn fortress standard of Captain Malrec's Ashen Outpost command.",
          effect: "Milestone first defeat claimed."
        }
      ]
    };

    expect(SaveSystem.saveGame(hero, campaign)).toBe(true);
    const loaded = SaveSystem.load();

    expect(loaded?.campaign.rivals).toEqual(campaign.rivals);
    expect(loaded?.campaign.rivalTrophies).toEqual(campaign.rivalTrophies);
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
