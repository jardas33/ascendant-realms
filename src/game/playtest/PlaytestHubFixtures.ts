import { createCampaignBattleLaunchRequest, createTutorialBattleLaunchRequest } from "../battle/BattleLaunchRequest";
import type { BattleRewardResult, BattleStats } from "../core/GameTypes";
import { createStartedCampaignSave } from "../core/CampaignRules";
import { createItemInstance } from "../core/HeroProgressionRules";
import { createFallbackCampaignSave, createFallbackHeroSave } from "../core/SaveSystem";
import { selectedCampaignNode } from "../campaign/CampaignNavigation";
import { createNewHeroSave } from "../data/heroes";
import { getCampaignScenarioLaunchModifiers } from "../core/campaign/CampaignMissionRules";
import type { ResultsData } from "../results/ResultsTypes";
import type { CampaignSaveData, HeroSaveData } from "../save/SaveTypes";
import {
  PRIVATE_LUME_DEMO_ID,
  PRIVATE_LUME_DEMO_NOTICE,
  PRIVATE_PLAYTEST_HUB_NOTICE
} from "./PrivatePlaytestTools";

export function createPlaytestHubHeroSave(): HeroSaveData {
  const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
  return {
    ...hero,
    level: 3,
    xp: 185,
    skillPoints: 2,
    completedBattles: 3,
    unlockedAbilities: ["rally_banner", "heroic_strike", "war_cry"],
    allocatedSkills: {
      warrior_cleave_training: 1,
      commander_rally_drill: 1
    },
    inventory: [
      playtestItem("weathered_command_sword", "playtest:weathered_command_sword"),
      playtestItem("emberbrand_shard", "playtest:emberbrand_shard"),
      playtestItem("cinderseer_focus", "playtest:cinderseer_focus"),
      playtestItem("oathbound_aegis", "playtest:oathbound_aegis")
    ],
    equipment: {
      weapon: "playtest:weathered_command_sword",
      armor: "playtest:oathbound_aegis",
      relic: "playtest:emberbrand_shard"
    },
    factionReputation: {
      free_marches: 24,
      ashen_covenant: -16,
      sylvan_concord: 0,
      common_folk: 18,
      old_faith: 7
    }
  };
}

function playtestItem(itemId: string, instanceId: string) {
  return {
    ...createItemInstance(itemId, "private_playtest_hub", "2026-06-01T00:00:00.000Z", { affixes: [] }),
    instanceId
  };
}

export function createPlaytestHubCampaignSave(options: {
  selectedNodeId?: string;
  completedNodeIds?: string[];
  unlockedNodeIds?: string[];
  retinueMode?: "ready" | "recovering";
} = {}): CampaignSaveData {
  const base = createStartedCampaignSave(createFallbackCampaignSave());
  const completedNodeIds = options.completedNodeIds ?? ["border_village", "old_stone_road"];
  const unlockedNodeIds =
    options.unlockedNodeIds ?? ["border_village", "old_stone_road", "aether_well_ruins", "bandit_hillfort", "marcher_camp", "refugee_caravan"];
  const recovering = options.retinueMode === "recovering";
  return {
    ...base,
    completedNodeIds,
    unlockedNodeIds,
    selectedNodeId: options.selectedNodeId ?? "border_village",
    resources: { crowns: 155, stone: 95, iron: 60, aether: 40 },
    resourcesSpent: { crowns: 35, stone: 20, iron: 0, aether: 0 },
    nodeRewardsClaimedIds: [...completedNodeIds],
    optionalObjectiveCompletionIds: ["border_village:defeat_enemy_commander"],
    activeModifierIds: ["well_rested"],
    strongholdUpgradeRanks: { quartermaster_stores_i: 1, training_yard_i: 1 },
    retinueUnits: [
      {
        retinueUnitId: "playtest-retinue-militia-ready",
        unitTypeId: "militia",
        name: "Salto Shieldhand",
        rank: "seasoned",
        xp: 125,
        kills: 4,
        sourceBattleId: "border_village",
        acquiredAt: "2026-06-01T00:00:00.000Z",
        status: "active",
        battlesSurvived: 2,
        missionsDeployed: 2
      },
      {
        retinueUnitId: "playtest-retinue-ranger-recovering",
        unitTypeId: "ranger",
        name: "Fordwatch Ranger",
        rank: "veteran",
        xp: 210,
        kills: 7,
        sourceBattleId: "old_stone_road",
        acquiredAt: "2026-06-01T00:00:00.000Z",
        status: recovering ? "recovering" : "active",
        battlesSurvived: 3,
        missionsDeployed: 2,
        recoveryMissionsRemaining: recovering ? 1 : 0
      }
    ],
    retinueDeploymentIds: recovering
      ? ["playtest-retinue-militia-ready"]
      : ["playtest-retinue-militia-ready", "playtest-retinue-ranger-recovering"],
    rivals: [
      {
        enemyHeroId: "captain_malrec",
        encounters: 1,
        defeats: 0,
        victoriesAgainstPlayer: 0,
        lastEncounterNodeId: "ashen_outpost",
        lastOutcome: "unseen",
        disposition: "wary",
        activeModifiers: [],
        isKnownToPlayer: true
      }
    ],
    rivalTrophies: []
  };
}

export function createPlaytestHubBattleLaunchRequest(scenarioId: string, heroSave = createPlaytestHubHeroSave()) {
  if (scenarioId === "tutorial_proving_grounds") {
    return createTutorialBattleLaunchRequest(createFallbackHeroSave(), {
      mapId: "first_claim",
      sourceId: "private_playtest_hub_tutorial",
      privatePlaytestHubScenarioId: scenarioId,
      privatePlaytestNotice: PRIVATE_PLAYTEST_HUB_NOTICE
    });
  }

  const isLumeScenario = scenarioId.startsWith("lume") || scenarioId.startsWith("perf_lume");
  const nodeId = isLumeScenario ? "aether_well_ruins" : "border_village";
  const node = selectedCampaignNode(nodeId);
  if (!node || node.nodeType !== "battle") {
    throw new Error(`Missing playtest hub battle node ${nodeId}.`);
  }
  return createCampaignBattleLaunchRequest(heroSave, node, {
    requestId: `private-playtest-hub:${scenarioId}:${node.mapId}`,
    sourceId: `private_playtest_hub_${scenarioId}`,
    rewardsDisabled: true,
    privatePlaytestDemoId: isLumeScenario ? PRIVATE_LUME_DEMO_ID : undefined,
    privatePlaytestNotice: isLumeScenario ? PRIVATE_LUME_DEMO_NOTICE : PRIVATE_PLAYTEST_HUB_NOTICE,
    privatePlaytestHubScenarioId: scenarioId,
    modifiers: getCampaignScenarioLaunchModifiers(node),
    retinueUnits: [],
    retinueReserveUnits: []
  });
}

export function createPlaytestHubResultsData(kind: "private-demo" | "victory" | "defeat"): ResultsData {
  const hero = createPlaytestHubHeroSave();
  const startHero = { ...hero, xp: Math.max(0, hero.xp - 55), level: Math.max(1, hero.level - 1), skillPoints: Math.max(0, hero.skillPoints - 1) };
  const node = selectedCampaignNode(kind === "private-demo" ? "aether_well_ruins" : "border_village");
  if (!node || node.nodeType !== "battle") {
    throw new Error("Missing playtest hub Results node.");
  }
  const reward: BattleRewardResult = {
    xp: kind === "defeat" ? 0 : 55,
    resources: kind === "defeat" ? {} : { crowns: 50, stone: 20 },
    itemIds: kind === "defeat" ? [] : ["weathered_command_sword"]
  };
  const launchRequest = createCampaignBattleLaunchRequest(startHero, node, {
    requestId: `private-playtest-hub-results:${kind}`,
    sourceId: `private_playtest_hub_results_${kind}`,
    rewardsDisabled: true,
    privatePlaytestDemoId: kind === "private-demo" ? PRIVATE_LUME_DEMO_ID : undefined,
    privatePlaytestNotice: kind === "private-demo" ? PRIVATE_LUME_DEMO_NOTICE : PRIVATE_PLAYTEST_HUB_NOTICE,
    privatePlaytestHubScenarioId: kind === "private-demo" ? "private_demo_results" : kind === "defeat" ? "defeat_results" : "ordinary_results"
  });
  const stats: BattleStats = {
    outcome: kind === "defeat" ? "defeat" : "victory",
    unitsKilled: kind === "defeat" ? 5 : 18,
    buildingsDestroyed: kind === "defeat" ? 0 : 4,
    resourcesCaptured: kind === "defeat" ? 1 : 3,
    firstSiteCaptured: "crown_shrine",
    buildingsBuilt: kind === "defeat" ? 1 : 3,
    builtBuildingIds: ["barracks"],
    unitsTrained: kind === "defeat" ? 3 : 8,
    trainedUnitIds: ["militia", "ranger"],
    enemyWavesSurvived: kind === "defeat" ? 1 : 4,
    xpGained: kind === "defeat" ? 12 : 55,
    timeSeconds: kind === "defeat" ? 520 : 820,
    completedObjectiveIds: kind === "defeat" ? ["capture_crown_shrine"] : ["capture_crown_shrine", "destroy_enemy_stronghold"],
    veteranSummary: {
      rankedUpUnits: [],
      notableVeterans: [
        {
          unitInstanceId: "playtest-veteran-1",
          unitTypeId: "militia",
          unitName: "Salto Shieldhand",
          xp: 125,
          rank: "seasoned",
          rankName: "Seasoned",
          kills: 4,
          damageDealt: 420,
          survivedBattle: true,
          rankedUp: false
        }
      ]
    },
    retinueParticipatingUnitIds: ["playtest-retinue-militia-ready"],
    retinueUnitIdsRecovering: kind === "defeat" ? ["playtest-retinue-militia-ready"] : [],
    retinueUnitIdsReturnedReady: kind === "defeat" ? [] : ["playtest-retinue-ranger-recovering"],
    retinueReinforcementUsed: kind !== "defeat",
    lumeNetworkId: kind === "private-demo" ? "aether_well_ruins_lume_ward" : undefined,
    lumeLinkActivatedIds: kind === "private-demo" ? ["west_stone_cut_to_ford_toll"] : undefined,
    lumeLinkSeveredIds: kind === "private-demo" ? [] : undefined,
    lumeObjectiveCompleted: kind === "private-demo" ? true : undefined,
    lumeTelemetryLabels: kind === "private-demo" ? ["Linked Ward awakened", "West Stone Cut to Ford Toll active"] : undefined
  };

  return {
    stats,
    heroSave: hero,
    startingHeroSave: startHero,
    rewardItemIds: reward.itemIds,
    reward,
    rewardLevelUp: {
      previousLevel: startHero.level,
      newLevel: hero.level,
      levelsGained: kind === "defeat" ? 0 : 1,
      skillPointsGained: kind === "defeat" ? 0 : 1
    },
    launchRequest,
    campaignResult:
      kind === "private-demo"
        ? undefined
        : {
            completedNodeId: node.id,
            completedNodeName: node.name,
            unlockedNodeIds: kind === "defeat" ? [] : ["old_stone_road"],
            unlockedNodeNames: kind === "defeat" ? [] : ["Old Stone Road"],
            nodeReward: reward,
            nodeLevelUp: {
              previousLevel: startHero.level,
              newLevel: hero.level,
              levelsGained: kind === "defeat" ? 0 : 1,
              skillPointsGained: kind === "defeat" ? 0 : 1
            },
            campaignResources: { crowns: 155, stone: 95, iron: 60, aether: 40 },
            wasFirstClear: kind !== "defeat",
            wasReplay: false,
            nodeRewardClaimed: kind !== "defeat",
            nodeRewardAlreadyClaimed: false,
            optionalObjectives: []
          }
  };
}
