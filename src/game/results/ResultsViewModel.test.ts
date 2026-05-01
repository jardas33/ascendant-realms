import { describe, expect, it } from "vitest";
import { createSkirmishBattleLaunchRequest } from "../battle/BattleLaunchRequest";
import type { BattleStats } from "../core/GameTypes";
import { createItemInstance } from "../core/HeroProgressionRules";
import { createNewHeroSave } from "../data/heroes";
import { keepResultsRewardItem } from "./ResultsEquipActions";
import { createInventorySceneData, createRetryBattleData, renderPrimaryActions } from "./ResultsNavigation";
import type { ResultsData } from "./ResultsTypes";
import { createResultsViewModel, initialResultsStatus } from "./ResultsViewModel";

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
