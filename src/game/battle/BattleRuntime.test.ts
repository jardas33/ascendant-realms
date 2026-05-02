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
import { createSkirmishBattleLaunchRequest, requireBattleLaunch } from "./BattleLaunchRequest";

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
      timeSeconds: 2.5
    });
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

  it("allows the runtime to complete only once", () => {
    const runtime = createBattleRuntime({ launch: createTestLaunch() });
    const heroSave = createFallbackHeroSave();

    expect(runtime.completeBattle({ outcome: "victory", heroSave })).not.toBeNull();
    expect(runtime.completeBattle({ outcome: "defeat", heroSave })).toBeNull();
  });
});
