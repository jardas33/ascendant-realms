import { describe, expect, it } from "vitest";
import { createSkirmishBattleLaunchRequest, createTutorialBattleLaunchRequest } from "../battle/BattleLaunchRequest";
import type { BattleStats } from "../core/GameTypes";
import { createItemInstance } from "../core/HeroProgressionRules";
import { SaveSystem, createFallbackCampaignSave } from "../core/SaveSystem";
import { ITEM_BY_ID } from "../data/contentIndex";
import { createNewHeroSave } from "../data/heroes";
import { RELIC_REWARD_BY_ENEMY_HERO_ID } from "../data/relicRewards";
import { chooseResultsRelicReward, keepResultsRewardItem } from "./ResultsEquipActions";
import { createInventorySceneData, createRetryBattleData, renderPrimaryActions } from "./ResultsNavigation";
import { renderBattleSummary } from "./ResultsObjectiveSummary";
import { renderVictoryRewards } from "./ResultsRewardPanel";
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
        ],
        retinueDeploymentIds: ["retinue:saved:ranger"]
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

  it("uses defeat guidance actions that match campaign or skirmish context", () => {
    const heroSave = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const skirmishData = createResultsData({
      stats: {
        ...baseStats(),
        outcome: "defeat"
      },
      heroSave,
      launchRequest: createSkirmishBattleLaunchRequest(heroSave, {
        mapId: "cinderfen_causeway",
        difficulty: "normal"
      })
    });
    const campaignData = createResultsData({
      stats: {
        ...baseStats(),
        outcome: "defeat"
      },
      heroSave,
      launchRequest: createSkirmishBattleLaunchRequest(heroSave, {
        mode: "campaign_node",
        mapId: "cinderfen_causeway",
        difficulty: "normal",
        campaignNodeId: "cinderfen_crossing"
      })
    });

    expect(createResultsViewModel(skirmishData).guidance.actions).toContain("Hold after each wave");
    expect(createResultsViewModel(skirmishData).guidance.actions).not.toContain("Use camp or Chapel support");
    expect(createResultsViewModel(campaignData).guidance.actions).toContain("Use camp or Chapel support");
  });

  it("gives tutorial defeat no-save/no-reward retry guidance", () => {
    const heroSave = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const data = createResultsData({
      stats: {
        ...baseStats(),
        outcome: "defeat"
      },
      heroSave,
      startingHeroSave: heroSave,
      launchRequest: createTutorialBattleLaunchRequest(heroSave)
    });
    const viewModel = createResultsViewModel(data);
    const actions = renderPrimaryActions(data);

    expect(initialResultsStatus(data)).toContain("no-save and no-reward");
    expect(viewModel.guidance.title).toBe("Training Attempt Ended");
    expect(viewModel.guidance.body).toContain("Nothing was saved or lost");
    expect(actions).toContain("Retry Tutorial");
    expect(actions).toContain("Main Menu");
    expect(actions).not.toContain("Open Hero Inventory");
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

  it("distinguishes campaign replay rewards and optional objective state on Results", () => {
    const heroSave = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const data = createResultsData({
      heroSave,
      startingHeroSave: {
        ...heroSave,
        clearedMapIds: ["ashen_outpost"]
      },
      stats: {
        ...baseStats(),
        completedObjectiveIds: ["capture_burned_shrine"]
      },
      launchRequest: createSkirmishBattleLaunchRequest(heroSave, {
        mode: "campaign_node",
        mapId: "ashen_outpost",
        difficulty: "normal",
        campaignNodeId: "ashen_outpost"
      }),
      campaignResult: {
        completedNodeId: "ashen_outpost",
        completedNodeName: "Ashen Outpost",
        unlockedNodeIds: [],
        unlockedNodeNames: [],
        nodeReward: { itemIds: [], resources: {}, xp: 0 },
        nodeLevelUp: { previousLevel: 1, newLevel: 1, levelsGained: 0, skillPointsGained: 0 },
        campaignResources: { crowns: 0, stone: 0, iron: 0, aether: 0 },
        wasFirstClear: false,
        wasReplay: true,
        nodeRewardClaimed: false,
        nodeRewardAlreadyClaimed: true,
        optionalObjectives: [
          {
            key: "ashen_outpost:capture_burned_shrine",
            objectiveId: "capture_burned_shrine",
            name: "Burned Shrine",
            description: "Capture the burned shrine before the main push.",
            completedThisRun: true,
            persisted: true,
            newlyRecorded: false,
            statusLabel: "Already recorded"
          }
        ]
      }
    });

    const status = initialResultsStatus(data);
    const summaryHtml = renderBattleSummary(data, createResultsViewModel(data));

    expect(status).toContain("replay complete");
    expect(status).toContain("campaign node rewards and one-time objective credit do not duplicate");
    expect(summaryHtml).toContain("Completed - already recorded");
  });

  it("renders campaign mission type, active modifier, and after-action copy in reward results", () => {
    const heroSave = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const data = createResultsData({
      heroSave,
      startingHeroSave: heroSave,
      launchRequest: createSkirmishBattleLaunchRequest(heroSave, {
        mode: "campaign_node",
        mapId: "ashen_outpost",
        difficulty: "normal",
        campaignNodeId: "ashen_outpost",
        modifiers: [{ id: "mission_fortified_enemy" }]
      }),
      campaignResult: {
        completedNodeId: "ashen_outpost",
        completedNodeName: "Ashen Outpost",
        unlockedNodeIds: ["cinderfen_overlook"],
        unlockedNodeNames: ["Cinderfen Overlook"],
        nodeReward: { itemIds: [], resources: { crowns: 130, stone: 70, iron: 80, aether: 55 }, xp: 100 },
        nodeLevelUp: { previousLevel: 1, newLevel: 1, levelsGained: 0, skillPointsGained: 0 },
        campaignResources: { crowns: 130, stone: 70, iron: 80, aether: 55 },
        wasFirstClear: true,
        wasReplay: false,
        nodeRewardClaimed: true,
        nodeRewardAlreadyClaimed: false
      }
    });

    const html = renderVictoryRewards(data, {
      currentItemInSlot: () => undefined,
      previewEquipDeltas: () => []
    });

    expect(html).toContain("Mission type");
    expect(html).toContain("Assault");
    expect(html).toContain("Primary objective");
    expect(html).toContain("Fortified Enemy");
    expect(html).toContain("enemy defenders hold a slightly stronger reserve");
    expect(html).toContain("The outpost is broken");
    expect(html).toContain("Act 1 Step 6: Champion Relic Milestone");
    expect(html).toContain("Choose and equip a relic");
    expect(html).toContain("Chapter 2 after first clear");
  });

  it("renders enemy doctrine and elite squad after-action summary", () => {
    const data = createResultsData({
      launchRequest: createSkirmishBattleLaunchRequest(createNewHeroSave("Aster", "warlord", "exiled_noble"), {
        mode: "campaign_node",
        campaignNodeId: "ashen_outpost",
        mapId: "ashen_outpost",
        tacticalPlanId: "champion_hunt"
      }),
      stats: {
        ...baseStats(),
        enemyDoctrineId: "fortress",
        enemyDoctrineActionCount: 2,
        enemyDoctrineTelemetryLabels: ["Fortress tech: fortify enemy base hub"],
        enemyEliteSquadIds: ["cinder_iron_guard"],
        enemyEliteUnitsDefeated: ["cinder_iron_guard"]
      }
    });

    const summaryHtml = renderBattleSummary(data, createResultsViewModel(data));

    expect(summaryHtml).toContain("Enemy Tactics");
    expect(summaryHtml).toContain("Fortress");
    expect(summaryHtml).toContain("Attack economy first");
    expect(summaryHtml).toContain("Cinder Iron Guard");
    expect(summaryHtml).toContain("Elite defeated");
    expect(summaryHtml).toContain("Tactical Plan");
    expect(summaryHtml).toContain("Champion Hunt");
    expect(summaryHtml).toContain("Hero starts with +6% maximum Mana");
    expect(summaryHtml).toContain("battle-only readability signals");
  });

  it("points champion relic Results toward equip, skill, and replay guidance", () => {
    const heroSave = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const data = createResultsData({
      heroSave,
      startingHeroSave: heroSave,
      launchRequest: createSkirmishBattleLaunchRequest(heroSave, {
        mode: "campaign_node",
        mapId: "ashen_outpost",
        difficulty: "normal",
        campaignNodeId: "ashen_outpost"
      }),
      campaignResult: {
        completedNodeId: "ashen_outpost",
        completedNodeName: "Ashen Outpost",
        unlockedNodeIds: ["cinderfen_overlook"],
        unlockedNodeNames: ["Cinderfen Overlook"],
        nodeReward: { itemIds: ["oathbound_aegis"], resources: { crowns: 130 }, xp: 100 },
        nodeLevelUp: { previousLevel: 1, newLevel: 2, levelsGained: 1, skillPointsGained: 1 },
        campaignResources: { crowns: 130, stone: 0, iron: 0, aether: 0 },
        wasFirstClear: true,
        wasReplay: false,
        nodeRewardClaimed: true,
        nodeRewardAlreadyClaimed: false
      },
      relicRewardChoice: {
        sourceDefinition: RELIC_REWARD_BY_ENEMY_HERO_ID.captain_malrec,
        sourceEnemyHeroId: "captain_malrec",
        sourceLabel: "Captain Malrec champion relic",
        choiceLabel: "Choose one relic for this hero build.",
        options: [
          {
            definition: RELIC_REWARD_BY_ENEMY_HERO_ID.captain_malrec,
            item: ITEM_BY_ID.outpost_command_signet,
            sourceMatched: true,
            owned: false
          }
        ]
      }
    });

    const status = initialResultsStatus(data);
    const guidance = createResultsViewModel(data).guidance;

    expect(status).toContain("Relic choice available");
    expect(status).toContain("Spend skill points or replay optional objectives");
    expect(guidance).toMatchObject({
      title: "Champion Relic Milestone"
    });
    expect(guidance.actions).toContain("Choose or equip relic");
    expect(guidance.actions).toContain("Spend skill point");
    expect(guidance.actions).toContain("Replay optional objectives");
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
          status: "active" as const,
          battlesSurvived: 3,
          missionsDeployed: 2
        },
        {
          retinueUnitId: "retinue:old:ranger",
          unitTypeId: "ranger",
          rank: "seasoned" as const,
          xp: 80,
          kills: 1,
          sourceBattleId: "old_stone_road",
          acquiredAt: "2026-05-02T12:00:00.000Z",
          status: "active" as const,
          battlesSurvived: 2,
          missionsDeployed: 1
        },
        {
          retinueUnitId: "retinue:old:acolyte",
          unitTypeId: "acolyte",
          rank: "seasoned" as const,
          xp: 70,
          kills: 1,
          sourceBattleId: "old_stone_road",
          acquiredAt: "2026-05-02T12:00:00.000Z",
          status: "active" as const,
          battlesSurvived: 1,
          missionsDeployed: 0
        },
        {
          retinueUnitId: "retinue:old:militia-2",
          unitTypeId: "militia",
          rank: "seasoned" as const,
          xp: 60,
          kills: 1,
          sourceBattleId: "old_stone_road",
          acquiredAt: "2026-05-02T12:00:00.000Z",
          status: "active" as const,
          battlesSurvived: 1,
          missionsDeployed: 0
        },
        {
          retinueUnitId: "retinue:old:ranger-2",
          unitTypeId: "ranger",
          rank: "seasoned" as const,
          xp: 65,
          kills: 1,
          sourceBattleId: "old_stone_road",
          acquiredAt: "2026-05-02T12:00:00.000Z",
          status: "active" as const,
          battlesSurvived: 1,
          missionsDeployed: 0
        }
      ],
      retinueDeploymentIds: ["retinue:old:militia", "retinue:old:ranger"]
    };

    const summaryHtml = renderBattleSummary(data, createResultsViewModel(data));
    const retinueHtml = renderRetinueRecruitment(data, fullCampaign);

    expect(summaryHtml).toContain("Rank-up");
    expect(summaryHtml).toContain("140/230 XP to Elite");
    expect(summaryHtml).toContain("Rank bonus: +8% HP, +8% damage");
    expect(summaryHtml).toContain("Eligible: survived at Seasoned rank or better.");
    expect(summaryHtml).toContain("Veterancy scope");
    expect(summaryHtml).toContain("Battle-only for normal trained units");
    expect(summaryHtml).toContain("Normal trained units stay battle-only unless you add an eligible survivor");
    expect(retinueHtml).toContain("5/5 roster");
    expect(retinueHtml).toContain("2/2 selected");
    expect(retinueHtml).toContain("Retinue roster is full");
    expect(retinueHtml).toContain("Eligible recruits this battle: 1");
    expect(retinueHtml).toContain("Not eligible: needs Seasoned rank or better.");
    expect(retinueHtml).toContain("Capacity Full");
  });

  it("renders deployed retinue survivor and loss summary in campaign Results", () => {
    const heroSave = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const data = createResultsData({
      heroSave,
      launchRequest: createSkirmishBattleLaunchRequest(heroSave, {
        mode: "campaign_node",
        mapId: "first_claim",
        difficulty: "easy",
        campaignNodeId: "border_village",
        retinueUnits: [
          {
            retinueUnitId: "retinue:old:militia",
            unitTypeId: "militia",
            rank: "veteran",
            xp: 140,
            kills: 3,
            sourceBattleId: "old_stone_road",
            acquiredAt: "2026-05-02T12:00:00.000Z",
            status: "active",
            battlesSurvived: 3,
            missionsDeployed: 2
          },
          {
            retinueUnitId: "retinue:old:ranger",
            unitTypeId: "ranger",
            rank: "seasoned",
            xp: 80,
            kills: 1,
            sourceBattleId: "old_stone_road",
            acquiredAt: "2026-05-02T12:00:00.000Z",
            status: "active",
            battlesSurvived: 2,
            missionsDeployed: 1
          }
        ]
      }),
      stats: {
        ...baseStats(),
        retinueUnitIdsLost: ["retinue:old:ranger"]
      }
    });

    const summaryHtml = renderBattleSummary(data, createResultsViewModel(data));

    expect(summaryHtml).toContain("Retinue Deployed");
    expect(summaryHtml).toContain("2 units");
    expect(summaryHtml).toContain("Survived");
    expect(summaryHtml).toContain("Veteran Militia");
    expect(summaryHtml).toContain("Lost");
    expect(summaryHtml).toContain("Seasoned Ranger");
    expect(summaryHtml).toContain("Low-HP Retinue survivors recover");
  });

  it("renders retinue recovery, returned-ready, and reinforcement results", () => {
    const heroSave = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const data = createResultsData({
      heroSave,
      launchRequest: createSkirmishBattleLaunchRequest(heroSave, {
        mode: "campaign_node",
        mapId: "first_claim",
        difficulty: "easy",
        campaignNodeId: "border_village",
        retinueUnits: [
          {
            retinueUnitId: "retinue:old:militia",
            unitTypeId: "militia",
            rank: "veteran",
            xp: 140,
            kills: 3,
            sourceBattleId: "old_stone_road",
            acquiredAt: "2026-05-02T12:00:00.000Z",
            status: "active"
          }
        ],
        retinueReserveUnits: [
          {
            retinueUnitId: "retinue:reserve:ranger",
            unitTypeId: "ranger",
            rank: "seasoned",
            xp: 85,
            kills: 1,
            sourceBattleId: "old_stone_road",
            acquiredAt: "2026-05-02T12:00:00.000Z",
            status: "active"
          },
          {
            retinueUnitId: "retinue:recovering:acolyte",
            unitTypeId: "acolyte",
            rank: "seasoned",
            xp: 92,
            kills: 2,
            sourceBattleId: "aether_well_ruins",
            acquiredAt: "2026-05-02T12:00:00.000Z",
            status: "recovering",
            recoveryMissionsRemaining: 1
          }
        ]
      }),
      stats: {
        ...baseStats(),
        retinueParticipatingUnitIds: ["retinue:old:militia", "retinue:reserve:ranger"],
        retinueUnitIdsRecovering: ["retinue:old:militia"],
        retinueUnitIdsReturnedReady: ["retinue:recovering:acolyte"],
        retinueReinforcementUsed: true,
        retinueReinforcementUnitId: "retinue:reserve:ranger"
      }
    });

    const summaryHtml = renderBattleSummary(data, createResultsViewModel(data));

    expect(summaryHtml).toContain("Reinforcement");
    expect(summaryHtml).toContain("Seasoned Ranger");
    expect(summaryHtml).toContain("Entering recovery");
    expect(summaryHtml).toContain("Veteran Militia");
    expect(summaryHtml).toContain("Returned Ready");
    expect(summaryHtml).toContain("Seasoned Acolyte");
  });

  it("renders campaign rival outcome and persistent relic reward copy", () => {
    const relicInstance = createItemInstance("cinderseer_focus", "test", "2026-05-27T21:30:00.000Z", { affixes: [] });
    const data = createResultsData({
      heroSave: {
        ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
        skillPoints: 1,
        allocatedSkills: { magic_focus: 1 },
        inventory: [relicInstance],
        equipment: { relic: relicInstance.instanceId }
      },
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
        activeModifiers: [],
        relicRewardText: "Cinder-Seer Focus added to inventory. Relic effects are active when equipped."
      },
      relicReward: {
        definition: RELIC_REWARD_BY_ENEMY_HERO_ID.veyra_cinders,
        item: ITEM_BY_ID.cinderseer_focus,
        status: "granted",
        itemInstance: relicInstance,
        inventoryLabel: "Cinder-Seer Focus added to hero inventory."
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
    expect(summaryHtml).toContain("Relic Reward");
    expect(summaryHtml).toContain("Cinder-Seer Focus");
    expect(summaryHtml).toContain("Relic effects are active when equipped");
    expect(summaryHtml).toContain("Relic Equipped");
    expect(summaryHtml).toContain("Equipped relic");
    expect(summaryHtml).toContain("Seer synergy active");
    expect(summaryHtml).toContain("Spend skill points in Hero Inventory");
  });

  it("renders and resolves an inline relic reward choice", () => {
    const heroSave = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const data = createResultsData({
      heroSave,
      stats: {
        ...baseStats(),
        enemyHeroId: "captain_malrec",
        enemyHeroName: "Captain Malrec",
        enemyHeroDefeated: true
      },
      relicRewardChoice: {
        sourceDefinition: RELIC_REWARD_BY_ENEMY_HERO_ID.captain_malrec,
        sourceEnemyHeroId: "captain_malrec",
        sourceLabel: "Captain Malrec champion relic",
        choiceLabel: "Choose one relic for this hero build.",
        options: [
          {
            definition: RELIC_REWARD_BY_ENEMY_HERO_ID.captain_malrec,
            item: ITEM_BY_ID.outpost_command_signet,
            sourceMatched: true,
            owned: false
          },
          {
            definition: RELIC_REWARD_BY_ENEMY_HERO_ID.veyra_cinders,
            item: ITEM_BY_ID.cinderseer_focus,
            sourceMatched: false,
            owned: false
          }
        ]
      }
    });

    const summaryHtml = renderBattleSummary(data, createResultsViewModel(data));
    const chosen = chooseResultsRelicReward(data, "outpost_command_signet");

    expect(initialResultsStatus(data)).toContain("Relic choice available");
    expect(summaryHtml).toContain("Relic Reward Choice");
    expect(summaryHtml).toContain("Commander");
    expect(summaryHtml).toContain("Choose Relic");
    expect(chosen.ok).toBe(true);
    expect(chosen.data.relicReward?.item.id).toBe("outpost_command_signet");
    expect(chosen.data.relicRewardChoice).toBeUndefined();
    expect(chosen.data.heroSave.inventory.map((instance) => instance.itemId)).toContain("outpost_command_signet");
  });

  it("keeps tutorial results free of relic reward grants", () => {
    const heroSave = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const data = createResultsData({
      heroSave,
      startingHeroSave: heroSave,
      launchRequest: createTutorialBattleLaunchRequest(heroSave),
      stats: {
        ...baseStats(),
        enemyHeroId: "captain_malrec",
        enemyHeroName: "Captain Malrec",
        enemyHeroDefeated: true
      }
    });

    const summaryHtml = renderBattleSummary(data, createResultsViewModel(data));

    expect(summaryHtml).not.toContain("Relic Reward");
    expect(summaryHtml).not.toContain("Outpost Command Signet");
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
