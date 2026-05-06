import { describe, expect, it } from "vitest";
import { createSkirmishBattleLaunchRequest } from "../battle/BattleLaunchRequest";
import type { BattleStats } from "../core/GameTypes";
import { createItemInstance } from "../core/HeroProgressionRules";
import { SaveSystem, createFallbackCampaignSave } from "../core/SaveSystem";
import { createNewHeroSave } from "../data/heroes";
import { keepResultsRewardItem } from "./ResultsEquipActions";
import { createInventorySceneData, createRetryBattleData, renderPrimaryActions } from "./ResultsNavigation";
import { renderBattleSummary } from "./ResultsObjectiveSummary";
import { renderRetinueRecruitment } from "./ResultsRetinuePanel";
import type { ResultsData } from "./ResultsTypes";
import { createResultsViewModel, initialResultsStatus, isRepeatBattleClear } from "./ResultsViewModel";

describe("results scene helpers", () => {
  it("builds the same high-level status and subtitle data outside ResultsScene", () => {
    const data = createResultsData({
      rewardItemIds: ["weathered_command_sword"],
      rewardLevelUp: {
        previousLevel: 1,
        newLevel: 2,
        levelsGained: 1,
        skillPointsGained: 1
      },
      heroSave: {
        ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
        level: 2,
        xp: 125,
        skillPoints: 1
      }
    });

    const viewModel = createResultsViewModel(data);

    expect(initialResultsStatus(data)).toContain("received an item and gained a skill point");
    expect(viewModel.title).toBe("Victory");
    expect(viewModel.subtitle).toContain("First Claim");
    expect(viewModel.subtitle).toContain("Easy");
    expect(viewModel.subtitle).toContain("7:00");
    expect(viewModel.skillPointsGained).toBe(1);
  });

  it("keeps navigation payload decisions outside the scene coordinator", () => {
    const startingHero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const defeatedHero = {
      ...startingHero,
      inventory: [createItemInstance("weathered_command_sword", "test")]
    };
    const data = createResultsData({
      stats: {
        ...baseStats(),
        outcome: "defeat"
      },
      heroSave: defeatedHero,
      startingHeroSave: startingHero,
      launchRequest: createSkirmishBattleLaunchRequest(defeatedHero, {
        mode: "campaign_node",
        mapId: "first_claim",
        difficulty: "easy",
        campaignNodeId: "border_village"
      })
    });

    const retry = createRetryBattleData(data);
    const inventory = createInventorySceneData(data);
    const actions = renderPrimaryActions(data);

    expect(retry.launchRequest.heroSave.inventory).toHaveLength(0);
    expect((inventory.heroSave as { inventory: unknown[] }).inventory).toHaveLength(0);
    expect(inventory.returnMode).toBe("campaign");
    expect(actions).toContain("Retry");
    expect(actions).toContain("Open Hero Inventory");
    expect(actions).toContain("Campaign Map");
  });

  it("refreshes campaign retry retinue from the current save", () => {
    const originalLocalStorage = globalThis.localStorage;
    Object.defineProperty(globalThis, "localStorage", {
      configurable: true,
      value: createMemoryStorage()
    });

    try {
      const startingHero = createNewHeroSave("Aster", "warlord", "exiled_noble");
      SaveSystem.saveGame(startingHero, {
        ...createFallbackCampaignSave(),
        started: true,
        retinueUnits: [
          {
            retinueUnitId: "retinue:saved:ranger",
            unitTypeId: "ranger",
            rank: "veteran",
            xp: 130,
            kills: 3,
            sourceBattleId: "old_stone_road",
            acquiredAt: "2026-05-02T12:00:00.000Z",
            status: "active"
          }
        ]
      });
      const defeatedHero = {
        ...startingHero,
        inventory: [createItemInstance("weathered_command_sword", "test")]
      };
      const data = createResultsData({
        stats: {
          ...baseStats(),
          outcome: "defeat"
        },
        heroSave: defeatedHero,
        startingHeroSave: startingHero,
        launchRequest: createSkirmishBattleLaunchRequest(defeatedHero, {
          mode: "campaign_node",
          mapId: "first_claim",
          difficulty: "easy",
          campaignNodeId: "border_village",
          retinueUnits: [
            {
              retinueUnitId: "retinue:lost:militia",
              unitTypeId: "militia",
              rank: "veteran",
              xp: 120,
              kills: 2,
              sourceBattleId: "border_village",
              acquiredAt: "2026-05-02T11:00:00.000Z",
              status: "active"
            }
          ]
        })
      });

      const retry = createRetryBattleData(data);

      expect(retry.launchRequest.retinueUnits?.map((unit) => unit.retinueUnitId)).toEqual(["retinue:saved:ranger"]);
    } finally {
      Object.defineProperty(globalThis, "localStorage", {
        configurable: true,
        value: originalLocalStorage
      });
    }
  });

  it("shows saved hero progress on defeat when battle XP was earned but not saved", () => {
    const startingHero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      xp: 80
    };
    const defeatedHero = {
      ...startingHero,
      level: 3,
      xp: 320,
      skillPoints: 2
    };
    const data = createResultsData({
      stats: {
        ...baseStats(),
        outcome: "defeat",
        xpGained: 240
      },
      heroSave: defeatedHero,
      startingHeroSave: startingHero
    });

    const viewModel = createResultsViewModel(data);

    expect(initialResultsStatus(data)).toContain("battle XP");
    expect(viewModel.title).toBe("Defeat");
    expect(viewModel.xp.afterHero).toBe(startingHero);
    expect(viewModel.xp.levelsGained).toBe(0);
    expect(viewModel.xp.skillPointsGained).toBe(0);
    expect(viewModel.skillPointsGained).toBe(0);
  });

  it("labels repeat battle clears as reduced rewards", () => {
    const startingHero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      clearedMapIds: ["first_claim"]
    };
    const data = createResultsData({
      startingHeroSave: startingHero,
      heroSave: startingHero,
      launchRequest: createSkirmishBattleLaunchRequest(startingHero, {
        mapId: "first_claim",
        difficulty: "easy"
      })
    });

    expect(isRepeatBattleClear(data)).toBe(true);
    expect(initialResultsStatus(data)).toContain("Repeat clear complete");
    expect(initialResultsStatus(data)).toContain("weighted item rolls");
  });

  it("points Cinderfen Watch results toward route completion", () => {
    const heroSave = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const data = createResultsData({
      heroSave,
      startingHeroSave: heroSave,
      launchRequest: createSkirmishBattleLaunchRequest(heroSave, {
        mode: "campaign_node",
        mapId: "cinderfen_watchpost",
        difficulty: "normal",
        campaignNodeId: "cinderfen_watch"
      }),
      campaignResult: {
        completedNodeId: "cinderfen_watch",
        completedNodeName: "Cinderfen Watch",
        unlockedNodeIds: ["cinderfen_aftermath"],
        unlockedNodeNames: ["Cinderfen Aftermath"],
        nodeReward: { itemIds: [], resources: {}, xp: 62 },
        nodeLevelUp: { previousLevel: 1, newLevel: 1, levelsGained: 0, skillPointsGained: 0 },
        campaignResources: { crowns: 0, stone: 0, iron: 0, aether: 0 }
      }
    });

    expect(initialResultsStatus(data)).toContain("Cinderfen Watch secured");
    expect(initialResultsStatus(data)).toContain("resolve Cinderfen Aftermath");
  });

  it("reports when a victory reward is intentionally kept in inventory", () => {
    const rewardInstance = createItemInstance("weathered_command_sword", "results_test");
    const heroSave = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      inventory: [rewardInstance]
    };
    const data = createResultsData({
      heroSave,
      rewardItemIds: ["weathered_command_sword"],
      reward: {
        itemIds: ["weathered_command_sword"],
        itemInstances: [rewardInstance],
        resources: {},
        xp: 45,
        duplicateConversions: []
      }
    });

    const result = keepResultsRewardItem(data, rewardInstance.instanceId);

    expect(result.ok).toBe(true);
    expect(result.data.heroSave.equipment.weapon).toBeUndefined();
    expect(result.message).toContain("Weathered Command Sword");
    expect(result.message).toContain("kept in inventory");
  });

  it("renders clearer veteran and retinue recruitment copy", () => {
    const heroSave = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const veteran = {
      unitInstanceId: "unit-veteran",
      unitTypeId: "militia",
      unitName: "Militia",
      xp: 140,
      rank: "veteran" as const,
      rankName: "Veteran",
      kills: 3,
      damageDealt: 120,
      survivedBattle: true,
      rankedUp: true,
      previousRank: "seasoned" as const
    };
    const recruit = {
      ...veteran,
      unitInstanceId: "unit-recruit",
      xp: 20,
      rank: "recruit" as const,
      rankName: "Recruit",
      kills: 0,
      rankedUp: false,
      previousRank: undefined
    };
    const data = createResultsData({
      heroSave,
      launchRequest: createSkirmishBattleLaunchRequest(heroSave, {
        mode: "campaign_node",
        mapId: "first_claim",
        difficulty: "easy",
        campaignNodeId: "border_village"
      }),
      stats: {
        ...baseStats(),
        veteranSummary: {
          rankedUpUnits: [veteran],
          notableVeterans: [veteran, recruit],
          topSurvivor: veteran
        }
      }
    });
    const fullCampaign = {
      ...createFallbackCampaignSave(),
      retinueUnits: [
        {
          retinueUnitId: "retinue:old:militia",
          unitTypeId: "militia",
          rank: "veteran" as const,
          xp: 140,
          kills: 3,
          sourceBattleId: "old_stone_road",
          acquiredAt: "2026-05-02T12:00:00.000Z",
          status: "active" as const
        },
        {
          retinueUnitId: "retinue:old:ranger",
          unitTypeId: "ranger",
          rank: "seasoned" as const,
          xp: 80,
          kills: 1,
          sourceBattleId: "old_stone_road",
          acquiredAt: "2026-05-02T12:00:00.000Z",
          status: "active" as const
        }
      ]
    };

    const summaryHtml = renderBattleSummary(data, createResultsViewModel(data));
    const retinueHtml = renderRetinueRecruitment(data, fullCampaign);

    expect(summaryHtml).toContain("Rank-up");
    expect(summaryHtml).toContain("140/230 XP to Elite");
    expect(summaryHtml).toContain("Rank bonus: +8% HP, +8% damage");
    expect(summaryHtml).toContain("Eligible: survived at Seasoned rank or better.");
    expect(retinueHtml).toContain("2/2 active");
    expect(retinueHtml).toContain("Retinue is full");
    expect(retinueHtml).toContain("Eligible recruits this battle: 1");
    expect(retinueHtml).toContain("Not eligible: needs Seasoned rank or better.");
    expect(retinueHtml).toContain("Capacity Full");
  });

  it("renders campaign rival outcome and consequence copy", () => {
    const data = createResultsData({
      stats: {
        ...baseStats(),
        enemyHeroId: "veyra_cinders",
        enemyHeroName: "Veyra of the Cinders",
        enemyHeroDefeated: true
      },
      rivalResult: {
        enemyHeroId: "veyra_cinders",
        name: "Veyra of the Cinders",
        title: "Hexfire Seer",
        lastOutcome: "defeated",
        outcomeLabel: "Defeated",
        previousDisposition: "wary",
        disposition: "humiliated",
        dispositionLabel: "Humiliated",
        encounters: 2,
        defeats: 1,
        victoriesAgainstPlayer: 0,
        consequenceText: "Veyra is humiliated, and the Border Marches celebrate the victory.",
        rewardText: "+90 XP, +20 Aether, Cinder-Seer Lens, +1 Old Faith reputation, Trophy: Cinder-Seer's Cracked Lens",
        firstDefeatRewardEarned: true,
        duplicateFirstDefeatRewardPrevented: false,
        trophyEarned: {
          trophyId: "trophy_veyra_cinder_lens",
          enemyHeroId: "veyra_cinders",
          earnedAt: "2026-05-02T19:58:00.000Z",
          sourceNodeId: "aether_well_ruins",
          label: "Cinder-Seer's Cracked Lens",
          description: "A cracked aether lens recovered after Veyra of the Cinders was driven from the ruins.",
          effect: "First defeat claimed: +20 Aether, +90 XP, and +1 Old Faith reputation."
        },
        rewardXp: 90,
        activeModifiers: []
      }
    });

    const summaryHtml = renderBattleSummary(data, createResultsViewModel(data));

    expect(summaryHtml).toContain("Rival Defeated");
    expect(summaryHtml).toContain("Veyra of the Cinders");
    expect(summaryHtml).toContain("Defeated");
    expect(summaryHtml).toContain("Humiliated");
    expect(summaryHtml).toContain("+90 XP, +20 Aether");
    expect(summaryHtml).toContain("Trophy earned");
    expect(summaryHtml).toContain("Cinder-Seer&#039;s Cracked Lens");
    expect(summaryHtml).toContain("Rival state persists on the campaign save");
  });

  it("explains repeat rival defeats without duplicating first-defeat rewards", () => {
    const data = createResultsData({
      stats: {
        ...baseStats(),
        enemyHeroId: "gorak_emberhand",
        enemyHeroName: "Gorak Emberhand",
        enemyHeroDefeated: true
      },
      rivalResult: {
        enemyHeroId: "gorak_emberhand",
        name: "Gorak Emberhand",
        title: "Ashen Raider Captain",
        lastOutcome: "defeated",
        outcomeLabel: "Defeated",
        previousDisposition: "humiliated",
        disposition: "enraged",
        dispositionLabel: "Enraged",
        encounters: 3,
        defeats: 2,
        victoriesAgainstPlayer: 0,
        consequenceText: "Gorak withdraws with wounded pride. Their first-defeat reward was already claimed.",
        firstDefeatRewardEarned: false,
        duplicateFirstDefeatRewardPrevented: true,
        rewardXp: 0,
        activeModifiers: []
      }
    });

    const summaryHtml = renderBattleSummary(data, createResultsViewModel(data));

    expect(summaryHtml).toContain("Rival Defeated");
    expect(summaryHtml).toContain("Gorak Emberhand");
    expect(summaryHtml).toContain("Enraged");
    expect(summaryHtml).toContain("One-time first-defeat reward");
    expect(summaryHtml).toContain("Already claimed for this campaign");
  });

  it("explains rival triumph defeats and preserves retry/prep actions", () => {
    const heroSave = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const data = createResultsData({
      heroSave,
      launchRequest: createSkirmishBattleLaunchRequest(heroSave, {
        mode: "campaign_node",
        mapId: "ashen_outpost",
        difficulty: "normal",
        campaignNodeId: "ashen_outpost"
      }),
      stats: {
        ...baseStats(),
        outcome: "defeat",
        enemyHeroId: "captain_malrec",
        enemyHeroName: "Captain Malrec",
        enemyHeroDefeated: false
      },
      rivalResult: {
        enemyHeroId: "captain_malrec",
        name: "Captain Malrec",
        title: "Outpost Commander",
        lastOutcome: "triumphant",
        outcomeLabel: "Triumphant",
        previousDisposition: "wary",
        disposition: "emboldened",
        dispositionLabel: "Emboldened",
        encounters: 1,
        defeats: 0,
        victoriesAgainstPlayer: 1,
        consequenceText: "Captain Malrec is emboldened after driving you back.",
        firstDefeatRewardEarned: false,
        duplicateFirstDefeatRewardPrevented: false,
        rewardXp: 0,
        activeModifiers: ["rival_emboldened_damage_5"]
      }
    });

    const summaryHtml = renderBattleSummary(data, createResultsViewModel(data));
    const actionsHtml = renderPrimaryActions(data);

    expect(summaryHtml).toContain("Rival Outcome");
    expect(summaryHtml).toContain("Captain Malrec");
    expect(summaryHtml).toContain("Triumphant");
    expect(summaryHtml).toContain("Emboldened");
    expect(summaryHtml).toContain("Captain Malrec is emboldened after driving you back.");
    expect(summaryHtml).toContain("triumphant rivals gain +5% damage");
    expect(actionsHtml).toContain("Retry");
    expect(actionsHtml).toContain("Open Hero Inventory");
    expect(actionsHtml).toContain("Campaign Map");
  });
});

function createResultsData(overrides: Partial<ResultsData> = {}): ResultsData {
  const heroSave = createNewHeroSave("Aster", "warlord", "exiled_noble");
  return {
    stats: baseStats(),
    heroSave,
    startingHeroSave: heroSave,
    rewardItemIds: [],
    launchRequest: createSkirmishBattleLaunchRequest(heroSave, {
      mapId: "first_claim",
      difficulty: "easy"
    }),
    ...overrides
  };
}

function baseStats(): BattleStats {
  return {
    unitsKilled: 8,
    buildingsDestroyed: 1,
    resourcesCaptured: 2,
    firstSiteCaptured: "Crown Shrine",
    buildingsBuilt: 1,
    builtBuildingIds: ["barracks"],
    unitsTrained: 4,
    trainedUnitIds: ["militia"],
    enemyWavesSurvived: 1,
    xpGained: 45,
    timeSeconds: 420,
    completedObjectiveIds: [],
    outcome: "victory"
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
