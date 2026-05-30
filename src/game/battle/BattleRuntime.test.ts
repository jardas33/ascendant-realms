import { describe, expect, it } from "vitest";
import {
  completeBattle,
  createBattleRuntime,
  createBattleSetupSnapshot,
  evaluateBattleObjectives
} from "./BattleRuntime";
import { createFallbackHeroSave } from "../core/SaveSystem";
import { MAPS } from "../data/maps";
import { requireRewardTable } from "../data/contentIndex";
import { createSkirmishBattleLaunchRequest, createTutorialBattleLaunchRequest, requireBattleLaunch } from "./BattleLaunchRequest";

const testMap = MAPS[0];
const testHeroSave = createFallbackHeroSave();

function createTestLaunch() {
  return requireBattleLaunch(createSkirmishBattleLaunchRequest(testHeroSave, { mapId: testMap.id, sourceId: "runtime_test" }));
}

describe("BattleRuntime", () => {
  it("creates a setup snapshot from map data", () => {
    const setup = createBattleSetupSnapshot(createTestLaunch());

    expect(setup.requestId).toBe("skirmish:runtime_test:first_claim");
    expect(setup.mode).toBe("skirmish");
    expect(setup.mapId).toBe(testMap.id);
    expect(setup.aiPersonalityId).toBe("balanced_warlord");
    expect(setup.heroSpawn).toEqual(testMap.scenario.heroSpawn);
    expect(setup.buildingSpawnCount).toBe(testMap.scenario.buildingSpawns.length);
    expect(setup.unitSpawnCount).toBe(testMap.scenario.unitSpawns.length);
    expect(setup.captureSiteCount).toBe(testMap.captureSites.length);
    expect(setup.neutralUnitCount).toBe(8);
    expect(setup.secondaryObjectiveIds).toEqual([]);
    expect(setup.objectiveBuildingIds).toEqual({
      playerBase: "command_hall",
      enemyBase: "enemy_stronghold"
    });
  });

  it("clones starting resources so runtime edits do not mutate map data", () => {
    const runtime = createBattleRuntime({ launch: createTestLaunch() });

    expect(runtime.resources.player).toEqual(testMap.scenario.startingResources.player);
    runtime.resources.player.crowns = 9999;
    expect(testMap.scenario.startingResources.player.crowns).toBe(380);
  });

  it("applies stronghold starting resource modifiers at launch", () => {
    const launch = requireBattleLaunch(
      createSkirmishBattleLaunchRequest(testHeroSave, {
        mapId: testMap.id,
        sourceId: "runtime_test",
        modifiers: [{ id: "stronghold:quartermaster_stores_i" }, { id: "stronghold:quartermaster_stores_ii" }]
      })
    );
    const runtime = createBattleRuntime({ launch });

    expect(runtime.resources.player.crowns).toBe(testMap.scenario.startingResources.player.crowns + 140);
    expect(runtime.resources.player.stone).toBe(testMap.scenario.startingResources.player.stone + 90);
    expect(runtime.resources.player.iron).toBe(testMap.scenario.startingResources.player.iron + 55);
    expect(runtime.resources.player.aether).toBe(testMap.scenario.startingResources.player.aether + 30);
  });

  it("applies Resource Push tactical plan starting resources at launch", () => {
    const launch = requireBattleLaunch(
      createSkirmishBattleLaunchRequest(testHeroSave, {
        mode: "campaign_node",
        campaignNodeId: "border_village",
        mapId: testMap.id,
        sourceId: "runtime_test",
        tacticalPlanId: "resource_push"
      })
    );
    const runtime = createBattleRuntime({ launch });

    expect(runtime.setup.tacticalPlanId).toBe("resource_push");
    expect(runtime.resources.player.crowns).toBe(testMap.scenario.startingResources.player.crowns + 35);
    expect(runtime.resources.player.stone).toBe(testMap.scenario.startingResources.player.stone + 20);
  });

  it("keeps objective resolution compatible with current skirmish rules", () => {
    expect(evaluateBattleObjectives({ playerBaseAlive: true, enemyBaseAlive: true })).toBeUndefined();
    expect(evaluateBattleObjectives({ playerBaseAlive: true, enemyBaseAlive: false })).toBe("victory");
    expect(evaluateBattleObjectives({ playerBaseAlive: false, enemyBaseAlive: true })).toBe("defeat");
    expect(evaluateBattleObjectives({ playerBaseAlive: false, enemyBaseAlive: false })).toBe("victory");
  });

  it("records battle stats through the runtime", () => {
    const runtime = createBattleRuntime({ launch: createTestLaunch() });

    runtime.tick(2.5);
    runtime.recordUnitKilled();
    runtime.recordBuildingDestroyed();
    runtime.recordResourceCaptured("crown_shrine");
    runtime.recordBuildingBuilt("barracks");
    runtime.recordUnitTrained("militia");
    runtime.recordEnemyWaveSurvived();
    runtime.recordXpGained(30);
    runtime.recordEnemyHeroPresence("captain_malrec", "Captain Malrec");
    runtime.recordEnemyHeroJoinedAttack("captain_malrec", 390);
    runtime.recordEnemyHeroPressure("captain_malrec", "Captain Malrec");
    runtime.recordEnemyHeroDefeated("captain_malrec", "Captain Malrec", 420);
    runtime.recordBattlefieldEventStarted({
      eventId: "site_under_threat",
      objectiveLabel: "Hold Crown Shrine",
      telemetryLabel: "Site Under Threat started: Hold Crown Shrine",
      planMatched: true
    });
    runtime.recordBattlefieldEventCompleted("site_under_threat", "Site Under Threat completed: Crown Shrine held.");
    expect(runtime.recordSecondaryObjective("capture_burned_shrine")).toBe(true);
    expect(runtime.recordSecondaryObjective("capture_burned_shrine")).toBe(false);

    expect(runtime.stats).toMatchObject({
      unitsKilled: 1,
      buildingsDestroyed: 1,
      resourcesCaptured: 1,
      firstSiteCaptured: "crown_shrine",
      buildingsBuilt: 1,
      builtBuildingIds: ["barracks"],
      unitsTrained: 1,
      trainedUnitIds: ["militia"],
      enemyWavesSurvived: 1,
      xpGained: 30,
      completedObjectiveIds: ["capture_burned_shrine"],
      timeSeconds: 2.5,
      enemyHeroId: "captain_malrec",
      enemyHeroName: "Captain Malrec",
      enemyHeroJoinedAttackAtSeconds: 390,
      lossesInvolvingEnemyHero: 1,
      enemyHeroDefeated: true,
      enemyHeroDefeatedAtSeconds: 420,
      battlefieldEventIds: ["site_under_threat"],
      battlefieldEventCompletedIds: ["site_under_threat"],
      battlefieldEventPlanMatchedIds: ["site_under_threat"],
      battlefieldEventObjectiveLabels: ["Hold Crown Shrine"]
    });
  });

  it("clones battle-only battlefield event telemetry into completion results", () => {
    const runtime = createBattleRuntime({ launch: createTestLaunch() });
    runtime.recordBattlefieldEventStarted({
      eventId: "hold_the_line",
      objectiveLabel: "Protect Command Hall",
      telemetryLabel: "Hold the Line started: Protect Command Hall"
    });
    runtime.recordBattlefieldEventFailed("hold_the_line", "Hold the Line failed: Command Hall destroyed.");

    const result = runtime.completeBattle({ outcome: "defeat", heroSave: createFallbackHeroSave() });

    expect(result?.stats.battlefieldEventIds).toEqual(["hold_the_line"]);
    expect(result?.stats.battlefieldEventFailedIds).toEqual(["hold_the_line"]);
    expect(result?.stats.battlefieldEventTelemetryLabels).toEqual([
      "Hold the Line started: Protect Command Hall",
      "Hold the Line failed: Command Hall destroyed."
    ]);
    expect(result?.shouldSaveHero).toBe(false);
  });

  it("records battle-only enemy pressure telemetry without save output", () => {
    const runtime = createBattleRuntime({ launch: createTestLaunch() });

    expect(
      runtime.recordEnemyPressureStage({
        planId: "causeway_contest_pressure",
        stageId: "shrine_route_warning",
        telemetryLabel: "shrine_route_warning",
        warningShown: true,
        completedAtSeconds: 88
      })
    ).toBe(true);
    expect(
      runtime.recordEnemyPressureStage({
        planId: "causeway_contest_pressure",
        stageId: "shrine_route_warning",
        telemetryLabel: "shrine_route_warning",
        warningShown: true,
        completedAtSeconds: 90
      })
    ).toBe(false);

    expect(runtime.stats).toMatchObject({
      enemyPressurePlanId: "causeway_contest_pressure",
      enemyPressureTriggeredStageIds: ["shrine_route_warning"],
      enemyPressureCompletedStageIds: ["shrine_route_warning"],
      enemyPressureTelemetryLabels: ["shrine_route_warning"],
      enemyPressureWarningsShown: 1,
      enemyPressureFirstTriggeredAtSeconds: 88
    });
  });

  it("preserves battle-only veteran summaries without changing save output", () => {
    const runtime = createBattleRuntime({ launch: createTestLaunch() });
    runtime.recordVeterancySummary({
      rankedUpUnits: [
        {
          unitInstanceId: "unit-1",
          unitTypeId: "militia",
          unitName: "Militia",
          xp: 120,
          rank: "veteran",
          rankName: "Veteran",
          kills: 2,
          damageDealt: 84,
          survivedBattle: true,
          rankedUp: true,
          previousRank: "seasoned"
        }
      ],
      notableVeterans: [],
      topSurvivor: {
        unitInstanceId: "unit-1",
        unitTypeId: "militia",
        unitName: "Militia",
        xp: 120,
        rank: "veteran",
        rankName: "Veteran",
        kills: 2,
        damageDealt: 84,
        survivedBattle: true,
        rankedUp: true,
        previousRank: "seasoned"
      }
    });

    const result = runtime.completeBattle({ outcome: "defeat", heroSave: createFallbackHeroSave() });

    expect(result?.stats.veteranSummary?.topSurvivor?.rank).toBe("veteran");
    expect(result?.shouldSaveHero).toBe(false);
    expect(runtime.stats.veteranSummary?.rankedUpUnits[0].kills).toBe(2);
  });

  it("produces victory rewards and save output without writing storage directly", () => {
    const heroSave = createFallbackHeroSave();
    const rewardTable = requireRewardTable(testMap.scenario.rewardTableId);
    const result = completeBattle({
      outcome: "victory",
      stats: {
        unitsKilled: 3,
        buildingsDestroyed: 1,
        resourcesCaptured: 2,
        firstSiteCaptured: "crown_shrine",
        buildingsBuilt: 1,
        builtBuildingIds: ["barracks"],
        unitsTrained: 2,
        trainedUnitIds: ["militia", "ranger"],
        enemyWavesSurvived: 1,
        xpGained: 80,
        timeSeconds: 120,
        completedObjectiveIds: ["capture_burned_shrine"],
        outcome: "victory"
      },
      heroSave,
      rewardTable,
      mapId: testMap.id,
      deterministicRewards: true
    });

    expect(result.shouldSaveHero).toBe(true);
    expect(result.rewardItemIds).toEqual(["weathered_command_sword"]);
    expect(result.reward.xp).toBe(75);
    expect(result.heroSave.completedBattles).toBe(heroSave.completedBattles + 1);
    expect(result.heroSave.clearedMapIds).toContain(testMap.id);
    expect(result.heroSave.inventory.some((instance) => instance.itemId === "weathered_command_sword")).toBe(true);
    expect(result.reward.itemInstances?.[0].affixes).toEqual(["sharp"]);
    expect(result.heroSave.xp).toBe(75);
    expect(result.stats.xpGained).toBe(155);
    expect(result.stats.outcome).toBe("victory");
  });

  it("preserves live battle XP on victory and then applies reward XP", () => {
    const startingHero = createFallbackHeroSave();
    const liveBattleHero = {
      ...startingHero,
      xp: 105,
      level: 2,
      skillPoints: 1
    };
    const rewardTable = requireRewardTable(testMap.scenario.rewardTableId);
    const result = completeBattle({
      outcome: "victory",
      stats: {
        ...createBattleRuntime({ launch: createTestLaunch() }).stats,
        xpGained: 15,
        outcome: "victory"
      },
      startingHeroSave: startingHero,
      heroSave: liveBattleHero,
      rewardTable,
      mapId: testMap.id,
      deterministicRewards: true
    });

    expect(result.heroSave.xp).toBe(180);
    expect(result.heroSave.level).toBe(2);
    expect(result.heroSave.skillPoints).toBe(1);
    expect(result.stats.xpGained).toBe(90);
    expect(result.rewardLevelUp).toEqual({
      previousLevel: 1,
      newLevel: 2,
      levelsGained: 1,
      skillPointsGained: 1
    });
  });

  it("keeps defeat rewards empty and avoids save output", () => {
    const heroSave = createFallbackHeroSave();
    const rewardTable = requireRewardTable(testMap.scenario.rewardTableId);
    const result = completeBattle({
      outcome: "defeat",
      stats: {
        unitsKilled: 0,
        buildingsDestroyed: 0,
        resourcesCaptured: 0,
        buildingsBuilt: 0,
        builtBuildingIds: [],
        unitsTrained: 0,
        trainedUnitIds: [],
        enemyWavesSurvived: 0,
        xpGained: 0,
        timeSeconds: 44,
        completedObjectiveIds: [],
        outcome: "defeat"
      },
      heroSave,
      rewardTable
    });

    expect(result.shouldSaveHero).toBe(false);
    expect(result.rewardItemIds).toEqual([]);
    expect(result.reward).toEqual({ itemIds: [], resources: {}, xp: 0 });
    expect(result.heroSave).toBe(heroSave);
    expect(result.heroSave.inventory).toEqual(heroSave.inventory);
    expect(result.heroSave.completedBattles).toBe(heroSave.completedBattles);
  });

  it("keeps tutorial completion no-reward and returns the starting hero", () => {
    const startingHero = createFallbackHeroSave();
    const runtime = createBattleRuntime({ launch: requireBattleLaunch(createTutorialBattleLaunchRequest(startingHero)) });
    runtime.recordXpGained(80);
    const changedHero = {
      ...startingHero,
      xp: 999,
      completedBattles: 3,
      inventory: [
        {
          instanceId: "tutorial-should-not-persist",
          itemId: "weathered_command_sword",
          acquiredAt: "2026-05-08T00:00:00.000Z",
          source: "tutorial",
          affixes: []
        }
      ],
      clearedMapIds: ["first_claim"]
    };

    const result = runtime.completeBattle({ outcome: "victory", heroSave: changedHero });

    expect(result?.shouldSaveHero).toBe(false);
    expect(result?.rewardItemIds).toEqual([]);
    expect(result?.reward).toEqual({ itemIds: [], resources: {}, xp: 0 });
    expect(result?.rewardLevelUp).toEqual({
      previousLevel: startingHero.level,
      newLevel: startingHero.level,
      levelsGained: 0,
      skillPointsGained: 0
    });
    expect(result?.stats.xpGained).toBe(0);
    expect(result?.heroSave).toEqual(startingHero);
    expect(result?.heroSave.inventory).toEqual([]);
    expect(result?.heroSave.completedBattles).toBe(0);
    expect(result?.heroSave.clearedMapIds).toEqual([]);
  });

  it("allows the runtime to complete only once", () => {
    const runtime = createBattleRuntime({ launch: createTestLaunch() });
    const heroSave = createFallbackHeroSave();

    expect(runtime.completeBattle({ outcome: "victory", heroSave })).not.toBeNull();
    expect(runtime.completeBattle({ outcome: "defeat", heroSave })).toBeNull();
  });
});
