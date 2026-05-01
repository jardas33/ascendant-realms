import { expect, test, type Page } from "@playwright/test";

const SAVE_KEY = "ascendant-realms-save-v1";

type CampaignResources = {
  crowns: number;
  stone: number;
  iron: number;
  aether: number;
};

interface SyntheticResultsOptions {
  mapId?: string;
  campaignNodeId?: string;
  rewardTableId?: string;
  difficulty?: "story" | "easy" | "normal" | "hard";
  completedObjectiveIds?: string[];
  defeatBattleXp?: number;
}

const EMPTY_RESOURCES: CampaignResources = {
  crowns: 0,
  stone: 0,
  iron: 0,
  aether: 0
};

const BASE_HERO = {
  heroName: "Deep QA",
  classId: "warlord",
  originId: "exiled_noble",
  level: 1,
  xp: 0,
  skillPoints: 0,
  unlockedAbilities: ["rally_banner"],
  completedBattles: 0,
  clearedMapIds: [],
  inventory: [],
  equipment: {},
  allocatedSkills: {},
  factionReputation: {
    free_marches: 10,
    ashen_covenant: -10,
    sylvan_concord: 0,
    common_folk: 0,
    old_faith: 0
  },
  stats: {
    might: 8,
    command: 8,
    arcana: 2,
    faith: 3
  }
};

const BASE_CAMPAIGN = {
  started: true,
  difficulty: "easy",
  resources: { ...EMPTY_RESOURCES },
  resourcesSpent: { ...EMPTY_RESOURCES },
  completedNodeIds: [],
  unlockedNodeIds: ["border_village"],
  lockedNodeIds: [],
  nodeRewardsClaimedIds: [],
  choiceIdsClaimed: [],
  townServiceClaimedIds: [],
  townServiceUseCounts: {},
  activeModifierIds: []
};

function attachConsoleFailure(page: Page): void {
  page.on("console", (message) => {
    if (message.type() === "error") {
      throw new Error(`Browser console error: ${message.text()}`);
    }
  });
  page.on("pageerror", (error) => {
    throw error;
  });
}

async function openMainMenu(page: Page): Promise<void> {
  attachConsoleFailure(page);
  await page.goto("/");
  await expect(page.getByTestId("main-menu")).toBeVisible();
}

async function openFreshMainMenu(page: Page): Promise<void> {
  attachConsoleFailure(page);
  await page.goto("/");
  await page.evaluate((key) => localStorage.removeItem(key), SAVE_KEY);
  await page.reload();
  await expect(page.getByTestId("main-menu")).toBeVisible();
}

async function seedSave(page: Page, options: {
  hero?: Record<string, unknown>;
  campaign?: Record<string, unknown>;
} = {}): Promise<void> {
  const save = {
    version: 2,
    createdAt: "2026-04-26T00:00:00.000Z",
    updatedAt: "2026-04-26T00:00:00.000Z",
    hero: {
      ...BASE_HERO,
      ...options.hero
    },
    campaign: {
      ...BASE_CAMPAIGN,
      ...options.campaign
    },
    settings: {},
    statistics: {}
  };
  await page.goto("/");
  await page.evaluate(
    ({ key, value }) => {
      localStorage.setItem(key, JSON.stringify(value));
    },
    { key: SAVE_KEY, value: save }
  );
  await page.reload();
  await expect(page.getByTestId("main-menu")).toBeVisible();
}

async function readSave(page: Page): Promise<Record<string, any>> {
  return page.evaluate((key) => {
    const raw = localStorage.getItem(key);
    if (!raw) {
      throw new Error("Expected a save in localStorage.");
    }
    return JSON.parse(raw);
  }, SAVE_KEY);
}

async function createHero(page: Page, name: string): Promise<void> {
  await expect(page.getByTestId("hero-creation")).toBeVisible();
  await page.getByTestId("hero-name-input").fill(name);
  await page.getByTestId("hero-start").click();
}

async function expectBattleLoaded(page: Page): Promise<void> {
  await expect(page.getByTestId("battle-hud")).toBeVisible({ timeout: 15_000 });
  await expect(page.getByTestId("battle-resources")).toContainText("Crowns");
  await expect(page.getByTestId("battle-hero-panel")).toBeVisible();
  await expect(page.getByTestId("battle-minimap")).toBeVisible();
  await expect(page.getByTestId("minimap")).toBeVisible();
}

async function clickCenteredCanvas(page: Page, xRatio: number, yRatio: number, button: "left" | "right" = "left"): Promise<void> {
  const canvas = page.locator("canvas");
  const box = await canvas.boundingBox();
  expect(box).not.toBeNull();
  if (!box) {
    return;
  }
  await page.mouse.click(box.x + box.width * xRatio, box.y + box.height * yRatio, { button });
}

async function waitForBattleScene(page: Page): Promise<void> {
  await page.waitForFunction(() => Boolean(window.ascendantRealmsGame?.scene.getScene("BattleScene")?.scene.isActive()));
}

async function worldToScreen(page: Page, point: { x: number; y: number }): Promise<{ x: number; y: number }> {
  return page.evaluate((target) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const canvasBounds = scene.game.canvas.getBoundingClientRect();
    const camera = scene.cameras.main;
    return {
      x: canvasBounds.left + target.x - camera.scrollX,
      y: canvasBounds.top + target.y - camera.scrollY
    };
  }, point);
}

async function clickWorldPoint(page: Page, point: { x: number; y: number }, button: "left" | "right" = "left"): Promise<void> {
  const screen = await worldToScreen(page, point);
  await page.mouse.click(screen.x, screen.y, { button });
}

async function advanceBattleSimulation(page: Page, seconds: number, step = 0.25): Promise<void> {
  await page.evaluate(
    ({ totalSeconds, stepSeconds }) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const iterations = Math.ceil(totalSeconds / stepSeconds);
      for (let index = 0; index < iterations; index += 1) {
        scene.runtime.tick(stepSeconds);
        scene.movementSystem.update(stepSeconds, scene.units, scene.activeMap, scene.buildings);
        scene.resourceSystem.update(stepSeconds, scene.captureSites, scene.units);
      }
    },
    { totalSeconds: seconds, stepSeconds: step }
  );
}

async function selectPlayerBuildingFromScene(page: Page, buildingId: string): Promise<void> {
  await page.evaluate((targetBuildingId) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const building = scene.buildings.find(
      (entry: any) => entry.team === "player" && entry.definition.id === targetBuildingId && entry.alive
    );
    if (!building) {
      throw new Error(`Player building ${targetBuildingId} was not found.`);
    }
    scene.cameraSystem.centerOn(building.position);
    scene.selectionSystem.setSelection([building]);
  }, buildingId);
}

async function getBattleSnapshot(page: Page): Promise<Record<string, any>> {
  return page.evaluate(() => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    return {
      selectedIds: scene.selectionSystem.getSelectedIds(),
      resources: { ...scene.resources.player },
      stats: { ...scene.runtime.stats },
      units: scene.units.map((unit: any) => ({
        id: unit.id,
        unitId: unit.definition.id,
        kind: unit.kind,
        team: unit.team,
        alive: unit.alive,
        x: unit.position.x,
        y: unit.position.y,
        moveTarget: unit.moveTarget ? { ...unit.moveTarget } : undefined
      })),
      buildings: scene.buildings.map((building: any) => ({
        id: building.id,
        buildingId: building.definition.id,
        team: building.team,
        alive: building.alive,
        x: building.position.x,
        y: building.position.y,
        constructionState: building.constructionState,
        constructionProgress: building.constructionProgress,
        trainingQueueLength: building.trainingQueue.length,
        rallyPoint: building.rallyPoint ? { ...building.rallyPoint } : undefined
      })),
      captureSites: scene.captureSites.map((site: any) => ({
        id: site.definition.id,
        owner: site.owner,
        capturingTeam: site.capturingTeam,
        captureProgress: site.captureProgress
      }))
    };
  });
}

async function completePlayerBuilding(page: Page, buildingId: string): Promise<void> {
  await page.evaluate((targetBuildingId) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const building = scene.buildings.find(
      (entry: any) => entry.team === "player" && entry.definition.id === targetBuildingId && entry.alive
    );
    if (!building) {
      throw new Error(`Player building ${targetBuildingId} was not found.`);
    }
    scene.buildingSystem.update(building.constructionTimeSeconds + 1);
  }, buildingId);
  await page.waitForFunction(
    (targetBuildingId) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const building = scene?.buildings.find(
        (entry: any) => entry.team === "player" && entry.definition.id === targetBuildingId && entry.alive
      );
      return building?.constructionState === "completed";
    },
    buildingId,
    { timeout: 5_000 }
  );
}

async function completeTrainingQueues(page: Page): Promise<void> {
  await page.evaluate(() => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    scene.trainingSystem.update(30, scene.buildings);
  });
}

async function completeUpgradeQueues(page: Page): Promise<void> {
  await page.evaluate(() => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    for (let index = 0; index < 4; index += 1) {
      scene.upgradeSystem.update(60, scene.buildings);
    }
  });
}

async function setBattlePlayerResources(page: Page, resources: CampaignResources): Promise<void> {
  await page.evaluate((nextResources) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    scene.resources.player = { ...scene.resources.player, ...nextResources };
  }, resources);
}

async function placePlayerBuildingFromScene(page: Page, buildingId: string): Promise<string> {
  return page.evaluate((targetBuildingId) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const commandHall = scene.buildings.find(
      (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
    );
    if (!commandHall) {
      throw new Error("Player Command Hall was not found.");
    }

    const offsets = [
      { x: 150, y: 0 },
      { x: 0, y: 132 },
      { x: 150, y: 132 },
      { x: -118, y: 0 },
      { x: 0, y: -132 },
      { x: 232, y: 0 },
      { x: 232, y: 124 },
      { x: 126, y: -124 },
      { x: -118, y: 126 },
      { x: 300, y: -96 },
      { x: 300, y: 104 }
    ];

    for (const offset of offsets) {
      const point = {
        x: commandHall.position.x + offset.x,
        y: commandHall.position.y + offset.y
      };
      scene.buildingSystem.startPlacement(targetBuildingId, {
        anchor: commandHall.position,
        resources: scene.resources.player
      });
      scene.buildingSystem.updateGhost(point.x, point.y, scene.resources.player);
      if (scene.buildingSystem.tryPlace(point.x, point.y, scene.resources.player)) {
        const building = scene.buildings.find(
          (entry: any) =>
            entry.team === "player" &&
            entry.definition.id === targetBuildingId &&
            Math.hypot(entry.position.x - point.x, entry.position.y - point.y) < 4
        );
        if (!building) {
          throw new Error(`Placed ${targetBuildingId}, but could not find it afterward.`);
        }
        return building.id;
      }
    }

    scene.buildingSystem.cancelPlacement();
    throw new Error(`Could not find a valid placement for ${targetBuildingId}.`);
  }, buildingId);
}

async function startFirstClaimSkirmish(
  page: Page,
  heroName: string,
  difficulty: "story" | "easy" | "normal" | "hard" = "normal"
): Promise<void> {
  await openFreshMainMenu(page);
  await page.getByTestId("menu-skirmish").click();
  await createHero(page, heroName);
  await page.getByTestId("setup-map-first_claim").click();
  await page.getByTestId(`setup-difficulty-${difficulty}`).click();
  await page.getByTestId("setup-start-battle").click();
  await expectBattleLoaded(page);
  await waitForBattleScene(page);
}

async function startSyntheticResults(page: Page, outcome: "victory" | "defeat", options: SyntheticResultsOptions = {}): Promise<void> {
  await openMainMenu(page);
  await page.evaluate(({ selectedOutcome, baseHero, resultOptions }) => {
    const game = window.ascendantRealmsGame;
    if (!game) {
      throw new Error("Ascendant Realms game was not booted.");
    }
    const rewardInstance = {
      instanceId: "deep-qa:weathered_command_sword:1",
      itemId: "weathered_command_sword",
      acquiredAt: "2026-04-26T00:00:00.000Z",
      source: "deep_e2e",
      affixes: [],
      locked: false,
      favorite: false
    };
    const startingHero = {
      ...baseHero,
      heroName: "Result Hero",
      xp: 80,
      inventory: []
    };
    const heroSave =
      selectedOutcome === "victory"
        ? {
            ...startingHero,
            level: 2,
            xp: 125,
            skillPoints: 1,
            completedBattles: 1,
            clearedMapIds: ["first_claim"],
            inventory: [rewardInstance]
          }
        : resultOptions.defeatBattleXp
          ? {
              ...startingHero,
              level: 3,
              xp: startingHero.xp + resultOptions.defeatBattleXp,
              skillPoints: 2
            }
          : startingHero;
    game.scene.start("ResultsScene", {
      heroSave,
      startingHeroSave: startingHero,
      launchRequest: {
        requestId: "deep-results",
        mode: "campaign_node",
        mapId: resultOptions.mapId ?? "first_claim",
        heroSave,
        sourceId: "deep_e2e",
        rewardTableId: resultOptions.rewardTableId ?? "first_claim_rewards",
        difficulty: resultOptions.difficulty ?? "easy",
        modifiers: [],
        enemyProfileId: "ashen_covenant",
        aiPersonalityId: "balanced_warlord",
        campaignNodeId: resultOptions.campaignNodeId ?? "border_village"
      },
      stats: {
        outcome: selectedOutcome,
        unitsKilled: selectedOutcome === "victory" ? 8 : 1,
        buildingsDestroyed: selectedOutcome === "victory" ? 1 : 0,
        resourcesCaptured: selectedOutcome === "victory" ? 2 : 0,
        firstSiteCaptured: selectedOutcome === "victory" ? "Crown Shrine" : undefined,
        buildingsBuilt: selectedOutcome === "victory" ? 1 : 0,
        builtBuildingIds: selectedOutcome === "victory" ? ["barracks"] : [],
        unitsTrained: selectedOutcome === "victory" ? 4 : 0,
        trainedUnitIds: selectedOutcome === "victory" ? ["militia"] : [],
        enemyWavesSurvived: selectedOutcome === "victory" ? 1 : 0,
        xpGained: selectedOutcome === "victory" ? 45 : resultOptions.defeatBattleXp ?? 0,
        timeSeconds: selectedOutcome === "victory" ? 420 : 95,
        completedObjectiveIds: resultOptions.completedObjectiveIds ?? []
      },
      reward: selectedOutcome === "victory"
        ? {
            itemIds: ["weathered_command_sword"],
            itemInstances: [rewardInstance],
            resources: { crowns: 50 },
            xp: 45,
            duplicateConversions: []
          }
        : {
            itemIds: [],
            itemInstances: [],
            resources: {},
            xp: 0,
            duplicateConversions: []
          },
      rewardLevelUp: selectedOutcome === "victory"
        ? { previousLevel: 1, newLevel: 2, levelsGained: 1, skillPointsGained: 1 }
        : { previousLevel: 1, newLevel: 1, levelsGained: 0, skillPointsGained: 0 },
      campaignResult: selectedOutcome === "victory"
        ? {
            completedNodeId: "border_village",
            completedNodeName: "Border Village",
            unlockedNodeIds: ["old_stone_road"],
            unlockedNodeNames: ["Old Stone Road"],
            nodeReward: {
              itemIds: [],
              itemInstances: [],
              resources: { crowns: 50 },
              xp: 30,
              duplicateConversions: []
            },
            nodeLevelUp: { previousLevel: 2, newLevel: 2, levelsGained: 0, skillPointsGained: 0 },
            campaignResources: { crowns: 50, stone: 0, iron: 0, aether: 0 }
          }
        : undefined
    });
  }, { selectedOutcome: outcome, baseHero: BASE_HERO, resultOptions: options });
  await expect(page.locator(".results-panel")).toBeVisible();
}

async function selectPlayerCommandHallFromScene(page: Page): Promise<void> {
  await page.evaluate(() => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const commandHall = scene.buildings.find(
      (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
    );
    if (!commandHall) {
      throw new Error("Player Command Hall was not found.");
    }
    scene.cameraSystem.centerOn(commandHall.position);
    scene.selectionSystem.setSelection([commandHall]);
  });
}

async function forceActiveBattleOutcome(page: Page, outcome: "victory" | "defeat"): Promise<void> {
  await page.evaluate((selectedOutcome) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const objectiveId = selectedOutcome === "victory"
      ? scene.activeMap.scenario.objectives.enemyBaseBuildingId
      : scene.activeMap.scenario.objectives.playerBaseBuildingId;
    const team = selectedOutcome === "victory" ? "enemy" : "player";
    const target = scene.buildings.find(
      (building: any) => building.team === team && building.definition.id === objectiveId && building.alive
    );
    if (!target) {
      throw new Error(`Could not find ${selectedOutcome} objective building ${objectiveId}.`);
    }
    target.takeDamage(target.maxHp + target.armor + 10_000);
    scene.checkEndConditions();
  }, outcome);
  await expect(page.locator(".results-panel")).toBeVisible({ timeout: 15_000 });
}

async function openCampaignNode(page: Page, nodeId: string): Promise<void> {
  await page.getByTestId("menu-continue-campaign").click();
  await expect(page.getByTestId("campaign-map")).toBeVisible();
  await page.getByTestId(`campaign-node-${nodeId}`).click();
}

async function startCampaignBattle(page: Page, nodeId: string): Promise<void> {
  await page.getByTestId("menu-continue-campaign").click();
  await expect(page.getByTestId("campaign-map")).toBeVisible();
  await page.getByTestId(`campaign-node-${nodeId}`).click();
  await expect(page.getByTestId("campaign-start-node")).toBeEnabled();
  await page.getByTestId("campaign-start-node").click();
  await expectBattleLoaded(page);
  await waitForBattleScene(page);
}

async function startBorderVillageCampaignBattle(page: Page): Promise<void> {
  await startCampaignBattle(page, "border_village");
}

test.describe("Ascendant Realms deep end-to-end QA", () => {
  test("main menu, info, hero creation selections, reset state, and gallery navigation work", async ({ page }) => {
    test.setTimeout(60_000);
    await openFreshMainMenu(page);

    await expect(page.getByTestId("menu-continue-campaign")).toBeDisabled();
    await expect(page.getByTestId("menu-inventory")).toBeDisabled();
    await page.getByRole("button", { name: "Credits / Info" }).click();
    await expect(page.locator(".info-box")).toContainText("No copyrighted assets");

    await page.getByTestId("menu-asset-gallery").click();
    await expect(page.getByRole("heading", { name: "Asset Check" })).toBeVisible();
    await expect(page.locator(".asset-gallery-card").first()).toBeVisible();
    await page.getByRole("button", { name: "Back" }).click();
    await expect(page.getByTestId("main-menu")).toBeVisible();

    await page.getByTestId("menu-new-campaign").click();
    await expect(page.getByTestId("hero-creation")).toBeVisible();
    await page.getByTestId("hero-class-arcanist").click();
    await page.getByTestId("hero-origin-wildland_raider").click();
    await page.getByTestId("hero-name-input").fill("Deep Menu");
    await page.getByTestId("hero-start").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    let save = await readSave(page);
    expect(save.hero.classId).toBe("arcanist");
    expect(save.hero.originId).toBe("wildland_raider");

    await page.getByTestId("campaign-main-menu").click();
    await expect(page.getByTestId("menu-continue-campaign")).toBeEnabled();
    await expect(page.getByTestId("menu-inventory")).toBeEnabled();
    await page.getByTestId("menu-reset-save").click();
    await expect(page.getByTestId("menu-continue-campaign")).toBeDisabled();
    await expect(page.getByTestId("menu-inventory")).toBeDisabled();

    await page.getByTestId("menu-new-campaign").click();
    await expect(page.getByTestId("hero-creation")).toBeVisible();
    await page.getByTestId("hero-class-shepherd").click();
    await page.getByTestId("hero-origin-temple_orphan").click();
    await page.getByTestId("hero-name-input").fill("Shepherd QA");
    await page.getByTestId("hero-start").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    save = await readSave(page);
    expect(save.hero.classId).toBe("shepherd");
    expect(save.hero.originId).toBe("temple_orphan");

    await page.getByTestId("campaign-main-menu").click();
    await page.getByTestId("menu-reset-save").click();
    await expect(page.getByTestId("menu-continue-campaign")).toBeDisabled();
    await expect(page.getByTestId("menu-inventory")).toBeDisabled();
  });

  test("campaign nodes, event choices, reputation, resources, and town services update the save", async ({ page }) => {
    await seedSave(page, {
      hero: {
        level: 2,
        xp: 130,
        skillPoints: 1
      },
      campaign: {
        resources: { crowns: 260, stone: 120, iron: 55, aether: 30 },
        completedNodeIds: ["border_village", "old_stone_road"],
        unlockedNodeIds: [
          "border_village",
          "old_stone_road",
          "aether_well_ruins",
          "bandit_hillfort",
          "refugee_caravan",
          "marcher_camp"
        ],
        nodeRewardsClaimedIds: ["border_village", "old_stone_road"]
      }
    });

    await page.getByTestId("menu-continue-campaign").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("campaign-bank")).toContainText("260");

    await page.getByTestId("campaign-node-refugee_caravan").click();
    await expect(page.getByRole("button", { name: /Recruit Volunteers/i })).toBeEnabled();
    await page.getByRole("button", { name: /Demand Tribute/i }).click();
    await expect(page.getByTestId("campaign-status")).toContainText("Demand Tribute chosen");
    let save = await readSave(page);
    expect(save.campaign.completedNodeIds).toContain("refugee_caravan");
    expect(save.campaign.choiceIdsClaimed).toContain("refugee_caravan:demand_tribute");
    expect(save.campaign.resources.crowns).toBe(325);
    expect(save.campaign.activeModifierIds).toContain("angered_raiders");
    expect(save.hero.factionReputation.common_folk).toBe(-8);
    await expect(page.locator("button[data-campaign-choice='demand_tribute']")).toBeDisabled();
    await expect(page.locator("button[data-campaign-choice='demand_tribute']")).toContainText("Already chosen");
    await expect(page.locator("button[data-campaign-choice='protect_them']")).toBeDisabled();
    await expect(page.locator("button[data-campaign-choice='protect_them']")).toContainText("Node completed");

    await page.getByTestId("campaign-node-marcher_camp").click();
    await page.getByRole("button", { name: /Rest and Recovery/i }).click();
    await expect(page.getByTestId("campaign-status")).toContainText("Rest and Recovery used");
    await page.getByRole("button", { name: /Rest and Recovery/i }).click();
    save = await readSave(page);
    expect(save.campaign.activeModifierIds).toContain("well_rested");
    expect(save.campaign.townServiceUseCounts["marcher_camp:rest_and_recovery"]).toBe(2);
    expect(save.campaign.resourcesSpent.crowns).toBeGreaterThanOrEqual(60);

    await page.getByRole("button", { name: /Purchase Emberglass Wand/i }).click();
    await expect(page.getByTestId("campaign-status")).toContainText("Purchase Emberglass Wand used");
    await expect(page.getByRole("button", { name: /Purchase Emberglass Wand/i })).toBeDisabled();
    save = await readSave(page);
    expect(save.hero.inventory.some((item: { itemId: string }) => item.itemId === "emberglass_wand")).toBe(true);
    expect(save.campaign.townServiceClaimedIds).toContain("marcher_camp:purchase_emberglass_wand");
  });

  test("alternate Refugee Caravan and Chapel choices apply rewards and completion", async ({ page }) => {
    test.setTimeout(70_000);

    const earlyCampaign = {
      completedNodeIds: ["border_village", "old_stone_road"],
      unlockedNodeIds: ["border_village", "old_stone_road", "refugee_caravan"],
      nodeRewardsClaimedIds: ["border_village", "old_stone_road"]
    };

    await seedSave(page, {
      campaign: {
        ...earlyCampaign,
        resources: { crowns: 100, stone: 0, iron: 5, aether: 0 }
      }
    });
    await openCampaignNode(page, "refugee_caravan");
    await expect(page.locator("button[data-campaign-choice='recruit_volunteers']")).toBeDisabled();
    await expect(page.locator("button[data-campaign-choice='recruit_volunteers']")).toContainText("Requires hero level 2");
    await page.locator("button[data-campaign-choice='protect_them']").click();
    await expect(page.getByTestId("campaign-status")).toContainText("Protect Them chosen");
    let save = await readSave(page);
    expect(save.campaign.completedNodeIds).toContain("refugee_caravan");
    expect(save.campaign.choiceIdsClaimed).toContain("refugee_caravan:protect_them");
    expect(save.campaign.resources.crowns).toBe(60);
    expect(save.campaign.activeModifierIds).toContain("inspired_militia");
    expect(save.hero.inventory.some((item: { itemId: string }) => item.itemId === "scouts_bow")).toBe(true);
    expect(save.hero.xp).toBe(40);
    expect(save.hero.factionReputation.common_folk).toBe(8);
    expect(save.hero.factionReputation.free_marches).toBe(12);
    await expect(page.locator("button[data-campaign-choice='protect_them']")).toBeDisabled();
    await expect(page.locator("button[data-campaign-choice='protect_them']")).toContainText("Already chosen");
    await expect(page.locator("button[data-campaign-choice='recruit_volunteers']")).toBeDisabled();
    await expect(page.locator("button[data-campaign-choice='recruit_volunteers']")).toContainText("Node completed");

    await seedSave(page, {
      hero: { level: 2 },
      campaign: {
        ...earlyCampaign,
        resources: { crowns: 100, stone: 0, iron: 5, aether: 0 }
      }
    });
    await openCampaignNode(page, "refugee_caravan");
    await page.locator("button[data-campaign-choice='recruit_volunteers']").click();
    await expect(page.getByTestId("campaign-status")).toContainText("Recruit Volunteers chosen");
    save = await readSave(page);
    expect(save.campaign.completedNodeIds).toContain("refugee_caravan");
    expect(save.campaign.choiceIdsClaimed).toContain("refugee_caravan:recruit_volunteers");
    expect(save.campaign.resources.crowns).toBe(85);
    expect(save.campaign.resources.iron).toBe(35);
    expect(save.campaign.activeModifierIds).toContain("inspired_militia");
    expect(save.hero.inventory.some((item: { itemId: string }) => item.itemId === "marcher_plate")).toBe(true);
    expect(save.hero.xp).toBe(25);
    expect(save.hero.factionReputation.common_folk).toBe(-4);
    expect(save.hero.factionReputation.free_marches).toBe(12);
    await expect(page.locator("button[data-campaign-choice='recruit_volunteers']")).toBeDisabled();
    await expect(page.locator("button[data-campaign-choice='recruit_volunteers']")).toContainText("Already chosen");
    await expect(page.locator("button[data-campaign-choice='demand_tribute']")).toBeDisabled();
    await expect(page.locator("button[data-campaign-choice='demand_tribute']")).toContainText("Node completed");

    await seedSave(page, {
      campaign: {
        resources: { crowns: 0, stone: 0, iron: 0, aether: 5 },
        completedNodeIds: ["border_village", "old_stone_road", "aether_well_ruins"],
        unlockedNodeIds: ["border_village", "old_stone_road", "aether_well_ruins", "chapel_of_the_marches"],
        nodeRewardsClaimedIds: ["border_village", "old_stone_road", "aether_well_ruins"]
      }
    });
    await openCampaignNode(page, "chapel_of_the_marches");
    await page.locator("button[data-campaign-choice='pray_for_strength']").click();
    await expect(page.getByTestId("campaign-status")).toContainText("Pray for Strength chosen");
    save = await readSave(page);
    expect(save.campaign.completedNodeIds).toContain("chapel_of_the_marches");
    expect(save.campaign.choiceIdsClaimed).toContain("chapel_of_the_marches:pray_for_strength");
    expect(save.campaign.unlockedNodeIds).toContain("ashen_outpost");
    expect(save.campaign.resources.aether).toBe(25);
    expect(save.campaign.activeModifierIds).toContain("blessed_road");
    expect(save.hero.xp).toBe(40);
    expect(save.hero.factionReputation.old_faith).toBe(3);
    expect(save.hero.factionReputation.common_folk).toBe(1);
    await expect(page.locator("button[data-campaign-choice='pray_for_strength']")).toBeDisabled();
    await expect(page.locator("button[data-campaign-choice='pray_for_strength']")).toContainText("Already chosen");
    await expect(page.locator("button[data-campaign-choice='repair_chapel']")).toBeDisabled();
    await expect(page.locator("button[data-campaign-choice='repair_chapel']")).toContainText("Node completed");
  });

  test("inventory equipment, unequip, and skill spending persist", async ({ page }) => {
    await seedSave(page, {
      hero: {
        skillPoints: 2,
        inventory: [
          {
            instanceId: "deep-qa:weathered_command_sword:inventory",
            itemId: "weathered_command_sword",
            acquiredAt: "2026-04-26T00:00:00.000Z",
            source: "deep_e2e",
            affixes: [],
            locked: false,
            favorite: false
          },
          {
            instanceId: "deep-qa:marcher_plate:inventory",
            itemId: "marcher_plate",
            acquiredAt: "2026-04-26T00:00:00.000Z",
            source: "deep_e2e",
            affixes: [],
            locked: false,
            favorite: false
          }
        ]
      }
    });

    await page.getByTestId("menu-inventory").click();
    await expect(page.getByTestId("hero-inventory")).toBeVisible();
    await page.locator(".inventory-row", { hasText: "Weathered Command Sword" }).getByRole("button", { name: "Equip" }).click();
    await expect(page.locator(".status-box")).toContainText(/equipped/i);
    let save = await readSave(page);
    expect(save.hero.equipment.weapon).toBe("deep-qa:weathered_command_sword:inventory");

    await page.locator(".equipment-row", { hasText: "Weapon" }).getByRole("button", { name: "Unequip" }).click();
    save = await readSave(page);
    expect(save.hero.equipment.weapon).toBeUndefined();

    await page.locator("button[data-progression-action='skill'][data-id='combat_drill']").click();
    await expect(page.locator(".status-box")).toContainText("Battle Drill");
    save = await readSave(page);
    expect(save.hero.skillPoints).toBe(1);
    expect(save.hero.allocatedSkills.combat_drill).toBe(1);
  });

  test("victory reward can be kept in inventory without equipping", async ({ page }) => {
    await seedSave(page);
    await startSyntheticResults(page, "victory");

    await expect(page.locator(".results-panel")).toContainText("Battle Rewards");
    await expect(page.locator(".reward-card")).toContainText("Already saved to inventory");
    await expect(page.getByRole("button", { name: "Equip Now" })).toBeVisible();
    await expect(page.getByRole("button", { name: "Keep in Inventory" })).toBeVisible();
    await page.getByRole("button", { name: "Keep in Inventory" }).click();
    await expect(page.locator(".status-box")).toContainText("Weathered Command Sword kept in inventory");
    await expect(page.getByRole("button", { name: "Equip Now" })).toBeEnabled();

    await page.getByRole("button", { name: "Open Hero Inventory" }).click();
    await expect(page.getByTestId("hero-inventory")).toBeVisible();
    await expect(page.getByTestId("inventory-list")).toContainText("Weathered Command Sword");
    await expect(page.getByTestId("inventory-list")).toContainText("New");
    await expect(page.locator(".equipment-row", { hasText: "Weapon" })).toContainText("Empty");
    await expect(page.locator(".inventory-row", { hasText: "Weathered Command Sword" }).getByRole("button", { name: "Equip Now" })).toBeVisible();
  });

  test("victory and defeat result actions are clear and save the equip-now path", async ({ page }) => {
    await seedSave(page);
    await startSyntheticResults(page, "victory");

    await expect(page.locator(".results-panel")).toContainText("Battle Rewards");
    await expect(page.locator(".results-panel")).toContainText("Old Stone Road");
    await page.getByRole("button", { name: "Equip Now" }).click();
    await expect(page.locator(".status-box")).toContainText(/equipped/i);
    let save = await readSave(page);
    expect(save.hero.equipment.weapon).toBe("deep-qa:weathered_command_sword:1");

    await page.getByRole("button", { name: "Open Hero Inventory" }).click();
    await expect(page.getByTestId("hero-inventory")).toBeVisible();

    await startSyntheticResults(page, "defeat", { defeatBattleXp: 240 });
    await expect(page.locator(".defeat-tips")).toContainText("Capture");
    await expect(page.locator(".results-panel")).toContainText("XP saved");
    await expect(page.locator(".results-panel")).toContainText("Battle XP earned");
    await expect(page.locator(".results-panel")).toContainText("240 (not saved)");
    await expect(page.locator(".results-panel")).toContainText("No victory rewards or battle XP were saved");
    await expect(page.locator(".results-title-row .skill-points")).toContainText("Hero Level");
    await expect(page.locator(".results-title-row .skill-points")).toContainText("1");
    await expect(page.locator(".results-panel")).toContainText("No level-up");
    await expect(page.getByRole("button", { name: "Retry" })).toBeVisible();
    await expect(page.getByRole("button", { name: "Open Hero Inventory" })).toBeVisible();
    await expect(page.getByRole("button", { name: "Campaign Map" })).toBeVisible();
    await page.getByRole("button", { name: "Open Hero Inventory" }).click();
    await expect(page.getByTestId("hero-inventory")).toBeVisible();
    await expect(page.getByTestId("hero-inventory")).toContainText("Hero Inventory");
    await expect(page.getByTestId("hero-inventory")).not.toContainText("Victory Progression");
    await expect(page.getByTestId("hero-inventory").locator(".progression-title-row")).toContainText("Level 1");
    await expect(page.getByTestId("hero-inventory").locator(".skill-points strong")).toHaveText("0");
    save = await readSave(page);
    expect(save.hero.equipment.weapon).toBe("deep-qa:weathered_command_sword:1");
  });

  test("Ashen Outpost defeat tips explain staged objective recovery", async ({ page }) => {
    await seedSave(page);

    await startSyntheticResults(page, "defeat", {
      mapId: "ashen_outpost",
      campaignNodeId: "ashen_outpost",
      rewardTableId: "ashen_outpost_rewards",
      difficulty: "normal"
    });
    await expect(page.locator(".defeat-tips")).toContainText("Burned Shrine");
    await expect(page.locator(".defeat-tips")).toContainText("gate Watchtower");

    await startSyntheticResults(page, "defeat", {
      mapId: "ashen_outpost",
      campaignNodeId: "ashen_outpost",
      rewardTableId: "ashen_outpost_rewards",
      difficulty: "normal",
      completedObjectiveIds: ["capture_burned_shrine"]
    });
    await expect(page.locator(".defeat-tips")).toContainText("Enemy Barracks");
    await expect(page.locator(".defeat-tips")).toContainText("Stronghold");
  });

  test("all skirmish maps and AI personalities launch without browser errors", async ({ page }) => {
    test.setTimeout(90_000);
    await openFreshMainMenu(page);
    await page.getByTestId("menu-skirmish").click();
    await createHero(page, "Map QA");

    for (const mapId of ["first_claim", "broken_ford", "ashen_outpost"]) {
      await expect(page.getByTestId("skirmish-setup")).toBeVisible();
      await page.getByTestId(`setup-map-${mapId}`).click();
      await page.getByTestId("setup-difficulty-normal").click();
      await page.getByTestId("setup-personality-hexfire_cult").click();
      await page.getByTestId("setup-start-battle").click();
      await expectBattleLoaded(page);
      await expect(page.getByTestId("battle-status")).toContainText(/Enemy|Capture|AI/i);
      await page.getByRole("button", { name: "Menu" }).click();
      await expect(page.getByTestId("main-menu")).toBeVisible();
      await page.getByTestId("menu-skirmish").click();
    }
  });

  test("battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions", async ({ page }) => {
    await openFreshMainMenu(page);
    await page.getByTestId("menu-skirmish").click();
    await createHero(page, "Battle QA");
    await page.getByTestId("setup-difficulty-normal").click();
    await page.getByTestId("setup-start-battle").click();
    await expectBattleLoaded(page);
    await waitForBattleScene(page);

    const openingSelection = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("Expected an active BattleScene for opening selection coverage.");
      }
      const selected = scene.selectionSystem.getSelected();
      return {
        hasHero: selected.some((entity: any) => entity.kind === "hero"),
        selectedPlayerUnits: selected.filter((entity: any) => entity.team === "player" && entity.kind !== "building").length,
        totalPlayerUnits: scene.units.filter((unit: any) => unit.team === "player" && unit.alive).length
      };
    });
    expect(openingSelection.hasHero).toBe(true);
    expect(openingSelection.selectedPlayerUnits).toBe(openingSelection.totalPlayerUnits);
    expect(openingSelection.selectedPlayerUnits).toBeGreaterThan(1);

    const heroStart = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive() || !scene.hero?.alive) {
        throw new Error("Expected an active BattleScene hero for click-selection coverage.");
      }
      scene.cameraSystem.centerOn(scene.hero.position);
      return { x: scene.hero.position.x, y: scene.hero.position.y };
    });
    await clickWorldPoint(page, heroStart, "left");
    await page.waitForFunction(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      return scene?.selectionSystem.getSelected().some((entity: any) => entity.kind === "hero");
    });
    await expect(page.locator(".side-panel")).toContainText("Battle QA");
    await expect(page.getByTestId("unit-order-summary")).toContainText("Guarding");

    await page.getByTestId("minimap").click({ position: { x: 90, y: 60 } });
    await page.keyboard.press("F");
    await expect(page.getByTestId("battle-status")).toContainText(/Fog/i);
    await page.keyboard.press("H");
    await page.keyboard.press("Space");
    await expect(page.getByTestId("unit-order-summary")).toContainText("Guarding");
    await clickWorldPoint(page, { x: 850, y: 780 }, "right");
    await expect(page.getByTestId("unit-order-summary")).toContainText("Moving");

    await selectPlayerCommandHallFromScene(page);
    await expect(page.locator(".side-panel")).toContainText("Command Hall");
    await expect(page.locator(".side-panel")).toContainText("Build");
    await page.locator("button[data-action='build'][data-id='barracks']").click();
    await expect(page.getByTestId("battle-status")).toContainText(/Placing|Barracks/i);
    await expect(page.getByTestId("placement-banner")).toContainText("Placement Mode");
    await expect(page.locator(".hint-line")).toHaveCount(0);
    await page.waitForFunction(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const commandHall = scene?.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
      );
      const ghost = scene?.buildingSystem?.ghost;
      return (
        scene?.buildingSystem?.pendingBuildingId === "barracks" &&
        ghost?.visible &&
        commandHall &&
        Math.hypot(ghost.x - commandHall.position.x, ghost.y - commandHall.position.y) > 40
      );
    });
    await page.keyboard.press("Escape");
    await expect(page.getByTestId("battle-status")).toContainText(/cancel/i);
  });

  test("unlocked hero ability hotkeys 1, 2, and 3 cast through keyboard input", async ({ page }) => {
    test.setTimeout(60_000);
    await seedSave(page, {
      hero: {
        level: 4,
        xp: 420,
        unlockedAbilities: ["rally_banner", "cleave", "war_cry"],
        allocatedSkills: {
          combat_drill: 1,
          warlord_cleave: 1,
          leadership_presence: 2,
          warlord_war_cry: 1
        }
      }
    });
    await startBorderVillageCampaignBattle(page);

    await page.keyboard.press("H");
    await expect(page.locator("button[data-action='ability'][data-id='rally_banner']")).toContainText("1. Rally Banner");
    await expect(page.locator("button[data-action='ability'][data-id='cleave']")).toContainText("2. Cleave");
    await expect(page.locator("button[data-action='ability'][data-id='war_cry']")).toContainText("3. War Cry");

    const prepared = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const hero = scene.hero;
      const allies = scene.units.filter((unit: any) => unit.team === "player" && unit.kind !== "hero" && unit.alive);
      const enemies = scene.units.filter((unit: any) => unit.team === "enemy" && unit.alive).slice(0, 3);
      if (allies.length === 0 || enemies.length < 2) {
        throw new Error("Expected nearby player units and enemy targets for ability hotkey coverage.");
      }

      scene.cameraSystem.centerOn(hero.position);
      scene.selectionSystem.setSelection([hero]);
      hero.mana = hero.maxMana;
      hero.abilityCooldowns = {};
      allies.forEach((unit: any, index: number) => {
        unit.setPosition(hero.position.x - 42 - index * 16, hero.position.y + index * 16);
        unit.damageBuffMultiplier = 1;
        unit.damageBuffRemaining = 0;
      });
      enemies.forEach((unit: any, index: number) => {
        unit.hp = unit.maxHp;
        unit.setPosition(hero.position.x + 52 + index * 22, hero.position.y + (index - 1) * 18);
        unit.moveTarget = undefined;
        unit.attackTargetId = undefined;
        unit.attackMove = false;
        unit.attackCooldownRemaining = 999;
      });
      scene.refreshBattleHud(0.11);

      return {
        heroMana: hero.mana,
        heroMaxMana: hero.maxMana,
        allyIds: allies.map((unit: any) => unit.id),
        enemyIds: enemies.map((unit: any) => unit.id)
      };
    });
    expect(prepared.heroMaxMana).toBeGreaterThanOrEqual(80);

    await page.keyboard.press("1");
    await page.waitForFunction(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      return (scene?.hero.abilityCooldowns.rally_banner ?? 0) > 0;
    });
    const rallyResult = await page.evaluate((allyIds) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      return {
        mana: scene.hero.mana,
        status: scene.statusMessage,
        allyBuffs: allyIds.map((allyId: string) => scene.units.find((unit: any) => unit.id === allyId)?.damageBuffMultiplier ?? 1)
      };
    }, prepared.allyIds);
    expect(rallyResult.mana).toBeLessThan(prepared.heroMana);
    expect(rallyResult.status).toMatch(/Rallied/i);
    expect(rallyResult.allyBuffs.some((multiplier: number) => multiplier > 1)).toBe(true);

    const cleaveSetup = await page.evaluate((enemyIds) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const hero = scene.hero;
      hero.mana = hero.maxMana;
      enemyIds.forEach((enemyId: string, index: number) => {
        const enemy = scene.units.find((unit: any) => unit.id === enemyId);
        if (!enemy) {
          throw new Error(`Missing enemy ${enemyId} before Cleave.`);
        }
        enemy.hp = enemy.maxHp;
        enemy.setPosition(hero.position.x + 48 + index * 18, hero.position.y + index * 10);
      });
      return {
        mana: hero.mana,
        enemyHp: enemyIds.map((enemyId: string) => scene.units.find((unit: any) => unit.id === enemyId)?.hp ?? 0)
      };
    }, prepared.enemyIds);
    await page.keyboard.press("2");
    await page.waitForFunction(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      return (scene?.hero.abilityCooldowns.cleave ?? 0) > 0;
    });
    const cleaveResult = await page.evaluate((enemyIds) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      return {
        mana: scene.hero.mana,
        status: scene.statusMessage,
        enemyHp: enemyIds.map((enemyId: string) => scene.units.find((unit: any) => unit.id === enemyId)?.hp ?? 0)
      };
    }, prepared.enemyIds);
    expect(cleaveResult.mana).toBeLessThan(cleaveSetup.mana);
    expect(cleaveResult.status).toMatch(/Cleave hit/i);
    expect(cleaveResult.enemyHp.some((hp: number, index: number) => hp < cleaveSetup.enemyHp[index])).toBe(true);

    const warCrySetup = await page.evaluate(
      ({ allyIds, enemyIds }) => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        const hero = scene.hero;
        hero.mana = hero.maxMana;
        allyIds.forEach((allyId: string, index: number) => {
          const ally = scene.units.find((unit: any) => unit.id === allyId);
          if (!ally) {
            throw new Error(`Missing ally ${allyId} before War Cry.`);
          }
          ally.damageBuffMultiplier = 1;
          ally.damageBuffRemaining = 0;
          ally.setPosition(hero.position.x - 42 - index * 16, hero.position.y + index * 16);
        });
        enemyIds.forEach((enemyId: string, index: number) => {
          const enemy = scene.units.find((unit: any) => unit.id === enemyId);
          if (!enemy) {
            throw new Error(`Missing enemy ${enemyId} before War Cry.`);
          }
          enemy.hp = enemy.maxHp;
          enemy.setPosition(hero.position.x + 54 + index * 20, hero.position.y + (index - 1) * 18);
        });
        return {
          mana: hero.mana,
          enemyHp: enemyIds.map((enemyId: string) => scene.units.find((unit: any) => unit.id === enemyId)?.hp ?? 0)
        };
      },
      { allyIds: prepared.allyIds, enemyIds: prepared.enemyIds }
    );
    await page.keyboard.press("3");
    await page.waitForFunction(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      return (scene?.hero.abilityCooldowns.war_cry ?? 0) > 0;
    });
    const warCryResult = await page.evaluate(
      ({ allyIds, enemyIds }) => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        return {
          mana: scene.hero.mana,
          status: scene.statusMessage,
          allyBuffs: allyIds.map((allyId: string) => scene.units.find((unit: any) => unit.id === allyId)?.damageBuffMultiplier ?? 1),
          enemyHp: enemyIds.map((enemyId: string) => scene.units.find((unit: any) => unit.id === enemyId)?.hp ?? 0)
        };
      },
      { allyIds: prepared.allyIds, enemyIds: prepared.enemyIds }
    );
    expect(warCryResult.mana).toBeLessThan(warCrySetup.mana);
    expect(warCryResult.status).toMatch(/War Cry hit/i);
    expect(warCryResult.allyBuffs.some((multiplier: number) => multiplier > 1)).toBe(true);
    expect(warCryResult.enemyHp.some((hp: number, index: number) => hp < warCrySetup.enemyHp[index])).toBe(true);
  });

  test("minimap renders marker families, camera rectangle, rally marker, and live pings", async ({ page }) => {
    test.setTimeout(60_000);
    await startFirstClaimSkirmish(page, "Minimap QA", "story");

    await setBattlePlayerResources(page, { crowns: 1000, stone: 1000, iron: 1000, aether: 1000 });
    await placePlayerBuildingFromScene(page, "barracks");
    await completePlayerBuilding(page, "barracks");
    await selectPlayerBuildingFromScene(page, "barracks");
    await clickWorldPoint(page, { x: 650, y: 920 }, "right");
    await expect(page.getByTestId("battle-status")).toContainText(/Rally point set/i);

    const minimapState = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const commandHall = scene.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
      );
      const barracks = scene.buildings.find((building: any) => building.team === "player" && building.definition.id === "barracks" && building.alive);
      const crownShrine = scene.captureSites.find((site: any) => site.definition.id === "crown_shrine");
      const enemyWave = scene.units.filter((unit: any) => unit.team === "enemy" && unit.alive).slice(0, 2);
      if (!commandHall || !barracks || !crownShrine || enemyWave.length === 0) {
        throw new Error("Expected Command Hall, Barracks, Crown Shrine, and enemy units for minimap matrix coverage.");
      }

      crownShrine.owner = "player";
      const threateningEnemy = enemyWave[0];
      threateningEnemy.setPosition(crownShrine.position.x + crownShrine.definition.radius - 8, crownShrine.position.y);
      scene.trackEnemyWave(enemyWave);
      scene.warnIfCommandHallUnderAttack(commandHall);
      scene.updateResourceSiteWarnings(0.25);
      scene.refreshBattleHud(0.11);

      const snapshot = scene.createMinimapSnapshot();
      const markerKinds = [...new Set(snapshot.markers.map((marker: any) => marker.kind))];
      const markerIds = snapshot.markers.map((marker: any) => marker.id);
      const markerTeams = [...new Set(snapshot.markers.map((marker: any) => marker.team))];
      const pingLabels = snapshot.pings.map((ping: any) => ping.label);
      return {
        markerKinds,
        markerIds,
        markerTeams,
        pingLabels,
        camera: snapshot.camera,
        rallyMarkerId: `rally-${barracks.id}`,
        commandHallId: commandHall.id,
        barracksId: barracks.id,
        crownShrineId: crownShrine.id,
        renderedCounts: {
          sites: document.querySelectorAll(".minimap-site").length,
          buildings: document.querySelectorAll(".minimap-building").length,
          units: document.querySelectorAll(".minimap-unit").length,
          camps: document.querySelectorAll(".minimap-camp").length,
          rally: document.querySelectorAll(".minimap-rally").length,
          pings: document.querySelectorAll(".minimap-ping").length,
          camera: document.querySelectorAll(".minimap-camera").length
        }
      };
    });

    expect(minimapState.markerKinds).toEqual(expect.arrayContaining(["unit", "building", "capture-site", "camp", "rally"]));
    expect(minimapState.markerTeams).toEqual(expect.arrayContaining(["player", "enemy", "neutral"]));
    expect(minimapState.markerIds).toEqual(
      expect.arrayContaining([minimapState.commandHallId, minimapState.barracksId, minimapState.crownShrineId, minimapState.rallyMarkerId])
    );
    expect(minimapState.camera.width).toBeGreaterThan(0);
    expect(minimapState.camera.height).toBeGreaterThan(0);
    expect(minimapState.pingLabels).toEqual(
      expect.arrayContaining(["Rally point set", "Enemy wave 1 incoming", "Command Hall under attack", "Crown Shrine under attack"])
    );
    expect(minimapState.renderedCounts.sites).toBeGreaterThan(0);
    expect(minimapState.renderedCounts.buildings).toBeGreaterThan(0);
    expect(minimapState.renderedCounts.units).toBeGreaterThan(0);
    expect(minimapState.renderedCounts.camps).toBeGreaterThan(0);
    expect(minimapState.renderedCounts.rally).toBeGreaterThan(0);
    expect(minimapState.renderedCounts.pings).toBeGreaterThanOrEqual(4);
    expect(minimapState.renderedCounts.camera).toBe(1);
  });

  test("first campaign battle path covers capture, build, train, rally, and victory rewards", async ({ page }) => {
    test.setTimeout(90_000);
    await openFreshMainMenu(page);

    await page.getByTestId("menu-new-campaign").click();
    await expect(page.getByTestId("hero-creation")).toBeVisible();
    await page.getByTestId("hero-class-warlord").click();
    await page.getByTestId("hero-name-input").fill("Loop QA");
    await page.getByTestId("hero-start").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("campaign-node-border_village")).toContainText(/Available/i);

    await page.getByTestId("campaign-node-border_village").click();
    await expect(page.getByTestId("campaign-start-node")).toBeEnabled();
    await page.getByTestId("campaign-start-node").click();
    await expectBattleLoaded(page);
    await waitForBattleScene(page);

    await page.keyboard.press("H");
    await page.keyboard.press("Space");
    await page.waitForFunction(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      return scene?.selectionSystem.getSelected().some((entity: any) => entity.kind === "hero");
    });

    await clickWorldPoint(page, { x: 850, y: 780 }, "right");
    await advanceBattleSimulation(page, 35);
    await page.waitForFunction(
      () => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        const site = scene?.captureSites.find((entry: any) => entry.definition.id === "crown_shrine");
        return site?.owner === "player" || (site?.capturingTeam === "player" && site.captureProgress > 0);
      },
      undefined,
      { timeout: 20_000 }
    );
    let snapshot = await getBattleSnapshot(page);
    const crownShrine = snapshot.captureSites.find((site: any) => site.id === "crown_shrine");
    expect(crownShrine.owner === "player" || crownShrine.captureProgress > 0).toBe(true);

    await selectPlayerCommandHallFromScene(page);
    await expect(page.locator(".side-panel")).toContainText("Command Hall");
    await page.locator("button[data-action='build'][data-id='barracks']").click();
    await expect(page.getByTestId("battle-status")).toContainText(/Placing|Barracks/i);
    await expect(page.getByTestId("placement-banner")).toContainText(/left-click to place/i);
    await expect(page.locator(".hint-line")).toHaveCount(0);
    await clickWorldPoint(page, { x: 450, y: 930 }, "left");
    await page.waitForFunction(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      return scene?.buildings.some(
        (building: any) =>
          building.team === "player" &&
          building.definition.id === "barracks" &&
          building.alive &&
          building.constructionState === "underConstruction"
      );
    });
    await expect(page.locator(".side-panel")).toContainText(/Construction/i);

    await completePlayerBuilding(page, "barracks");
    await selectPlayerBuildingFromScene(page, "barracks");
    await expect(page.locator(".side-panel")).toContainText("Barracks");
    await expect(page.locator(".side-panel")).toContainText("Rally Point: None");

    snapshot = await getBattleSnapshot(page);
    const militiaBefore = snapshot.units.filter((unit: any) => unit.team === "player" && unit.unitId === "militia").length;
    await page.locator("button[data-action='train'][data-id='militia']").click();
    await page.waitForFunction(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const barracks = scene?.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "barracks" && building.alive
      );
      return barracks?.trainingQueue.length > 0;
    });

    const rallyPoint = { x: 650, y: 920 };
    await clickWorldPoint(page, rallyPoint, "right");
    await page.waitForFunction(
      (target) => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        const barracks = scene?.buildings.find(
          (building: any) => building.team === "player" && building.definition.id === "barracks" && building.alive
        );
        if (!barracks?.rallyPoint) {
          return false;
        }
        return Math.hypot(barracks.rallyPoint.x - target.x, barracks.rallyPoint.y - target.y) < 8;
      },
      rallyPoint,
      { timeout: 5_000 }
    );
    await expect(page.getByTestId("battle-status")).toContainText(/Rally point set/i);

    await completeTrainingQueues(page);
    const trainedMilitia = await page.waitForFunction(
      ({ beforeCount, target }) => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        const candidates = scene?.units.filter((unit: any) => unit.team === "player" && unit.definition.id === "militia" && unit.alive) ?? [];
        if (candidates.length <= beforeCount) {
          return false;
        }
        return candidates.find(
          (unit: any) => unit.moveTarget && Math.hypot(unit.moveTarget.x - target.x, unit.moveTarget.y - target.y) < 8
        )?.id;
      },
      { beforeCount: militiaBefore, target: rallyPoint },
      { timeout: 5_000 }
    );
    const trainedMilitiaId = await trainedMilitia.jsonValue();
    expect(trainedMilitiaId).toBeTruthy();

    const startingRallyDistance = await page.evaluate(
      ({ unitId, target }) => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        const unit = scene?.units.find((entry: any) => entry.id === unitId);
        if (!unit) {
          throw new Error("Trained militia was not found.");
        }
        return Math.hypot(unit.position.x - target.x, unit.position.y - target.y);
      },
      { unitId: trainedMilitiaId, target: rallyPoint }
    );
    await page.waitForFunction(
      ({ unitId, target, startDistance }) => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        const unit = scene?.units.find((entry: any) => entry.id === unitId);
        if (!unit) {
          return false;
        }
        return Math.hypot(unit.position.x - target.x, unit.position.y - target.y) < startDistance - 2;
      },
      { unitId: trainedMilitiaId, target: rallyPoint, startDistance: startingRallyDistance },
      { timeout: 5_000 }
    );

    snapshot = await getBattleSnapshot(page);
    const barracks = snapshot.buildings.find((building: any) => building.team === "player" && building.buildingId === "barracks");
    expect(barracks?.constructionState).toBe("completed");
    expect(barracks?.rallyPoint).toBeTruthy();
    expect(snapshot.stats.buildingsBuilt).toBeGreaterThanOrEqual(1);
    expect(snapshot.stats.unitsTrained).toBeGreaterThanOrEqual(1);

    await forceActiveBattleOutcome(page, "victory");
    await expect(page.locator(".results-panel")).toContainText("Victory");
    await expect(page.locator(".results-panel")).toContainText("Border Village");
    const save = await readSave(page);
    expect(save.campaign.completedNodeIds).toContain("border_village");
    expect(save.campaign.nodeRewardsClaimedIds).toContain("border_village");
    expect(save.campaign.unlockedNodeIds).toContain("old_stone_road");
    expect(save.hero.completedBattles).toBe(1);
    expect(save.hero.inventory.length).toBeGreaterThan(0);
    expect(Object.values(save.hero.equipment ?? {})).toHaveLength(0);
  });

  test("first enemy wave pressure can damage the base and be survived", async ({ page }) => {
    test.setTimeout(60_000);
    await seedSave(page);
    await startBorderVillageCampaignBattle(page);

    const pressure = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const commandHall = scene.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
      );
      const waveUnits = scene.units
        .filter((unit: any) => unit.team === "enemy" && unit.alive && unit.definition.id === "raider")
        .slice(0, 2);
      if (!commandHall || waveUnits.length === 0) {
        throw new Error("Expected player Command Hall and at least one enemy Raider wave unit.");
      }

      scene.trackEnemyWave(waveUnits);
      waveUnits.forEach((unit: any, index: number) => {
        unit.setPosition(commandHall.position.x + 22 + index * 8, commandHall.position.y + index * 8);
        unit.commandAttack(commandHall.id);
        unit.attackCooldownRemaining = 0;
      });

      const commandHallHpBefore = commandHall.hp;
      for (let index = 0; index < 90; index += 1) {
        scene.combatSystem.update(0.1);
      }
      scene.refreshBattleHud(0.11);
      const minimapPingLabels = scene.createMinimapSnapshot().pings.map((ping: any) => ping.label);
      return {
        commandHallHpBefore,
        commandHallHpAfter: commandHall.hp,
        trackedWaveCount: scene.trackedEnemyWaves.length,
        enemyWavesSurvived: scene.runtime.stats.enemyWavesSurvived,
        minimapPingLabels,
        battleStatus: scene.statusMessage
      };
    });

    expect(pressure.commandHallHpAfter).toBeLessThan(pressure.commandHallHpBefore);
    expect(pressure.trackedWaveCount).toBe(1);
    expect(pressure.enemyWavesSurvived).toBe(0);
    expect(pressure.minimapPingLabels).toEqual(expect.arrayContaining(["Enemy wave 1 incoming", "Command Hall under attack"]));
    expect(pressure.battleStatus).toMatch(/Command Hall is under attack/i);

    const survival = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const commandHall = scene.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
      );
      const trackedWave = scene.trackedEnemyWaves[0];
      if (!commandHall || !trackedWave) {
        throw new Error("Expected a live Command Hall and tracked enemy wave.");
      }

      trackedWave.unitIds.forEach((unitId: string) => {
        const unit = scene.units.find((entry: any) => entry.id === unitId);
        unit?.takeDamage(unit.maxHp + unit.armor + 10_000);
      });
      scene.updateTrackedEnemyWaves();
      scene.refreshBattleHud(0.11);

      return {
        commandHallAlive: commandHall.alive,
        remainingTrackedWaveCount: scene.trackedEnemyWaves.length,
        enemyWavesSurvived: scene.runtime.stats.enemyWavesSurvived,
        battleStatus: scene.statusMessage,
        hudStatusText: document.querySelector('[data-testid="battle-status"]')?.textContent ?? ""
      };
    });

    expect(survival.commandHallAlive).toBe(true);
    expect(survival.remainingTrackedWaveCount).toBe(0);
    expect(survival.enemyWavesSurvived).toBe(1);
    expect(survival.battleStatus).toMatch(/Enemy wave 1 defeated/i);
    expect(survival.hudStatusText).toContain("Enemy wave 1 defeated");
  });

  test("Chapel of the Marches guidance keeps the node open before a completing repair choice", async ({ page }) => {
    await seedSave(page, {
      hero: {
        level: 3,
        xp: 200,
        skillPoints: 2
      },
      campaign: {
        resources: { crowns: 140, stone: 100, iron: 20, aether: 5 },
        completedNodeIds: ["border_village", "old_stone_road", "aether_well_ruins"],
        unlockedNodeIds: [
          "border_village",
          "old_stone_road",
          "aether_well_ruins",
          "bandit_hillfort",
          "refugee_caravan",
          "marcher_camp",
          "chapel_of_the_marches"
        ],
        nodeRewardsClaimedIds: ["border_village", "old_stone_road", "aether_well_ruins"],
        activeModifierIds: ["angered_raiders"]
      }
    });

    await page.getByTestId("menu-continue-campaign").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await page.getByTestId("campaign-node-chapel_of_the_marches").click();
    await expect(page.locator("button[data-campaign-choice='ask_for_guidance']")).toContainText("Keeps this node open");
    await page.locator("button[data-campaign-choice='ask_for_guidance']").click();
    await expect(page.getByTestId("campaign-status")).toContainText("Ask for Guidance chosen");

    let save = await readSave(page);
    expect(save.campaign.choiceIdsClaimed).toContain("chapel_of_the_marches:ask_for_guidance");
    expect(save.campaign.completedNodeIds).not.toContain("chapel_of_the_marches");
    expect(save.campaign.unlockedNodeIds).toContain("ashen_outpost");
    expect(save.hero.xp).toBeGreaterThanOrEqual(215);

    await expect(page.getByTestId("campaign-node-chapel_of_the_marches")).toContainText(/Available/i);
    await expect(page.locator("button[data-campaign-choice='ask_for_guidance']")).toBeDisabled();
    await expect(page.locator("button[data-campaign-choice='ask_for_guidance']")).toContainText("Already chosen");
    await expect(page.locator("button[data-campaign-choice='repair_chapel']")).toBeEnabled();
    await page.locator("button[data-campaign-choice='repair_chapel']").click();
    await expect(page.getByTestId("campaign-status")).toContainText("Repair the Chapel chosen");

    save = await readSave(page);
    expect(save.campaign.choiceIdsClaimed).toContain("chapel_of_the_marches:repair_chapel");
    expect(save.campaign.completedNodeIds).toContain("chapel_of_the_marches");
    expect(save.campaign.resources.crowns).toBe(95);
    expect(save.campaign.resources.stone).toBe(45);
    expect(save.campaign.resources.aether).toBe(40);
    expect(save.campaign.activeModifierIds).toContain("local_support");
    expect(save.campaign.activeModifierIds).not.toContain("angered_raiders");
    expect(save.hero.inventory.some((item: { itemId: string }) => item.itemId === "green_chapel_icon")).toBe(true);
    expect(save.hero.factionReputation.old_faith).toBe(7);
    await expect(page.locator("button[data-campaign-choice='repair_chapel']")).toBeDisabled();
    await expect(page.locator("button[data-campaign-choice='repair_chapel']")).toContainText("Already chosen");
    await expect(page.locator("button[data-campaign-choice='pray_for_strength']")).toBeDisabled();
    await expect(page.locator("button[data-campaign-choice='pray_for_strength']")).toContainText("Node completed");
  });

  test("Mystic Lodge, Acolyte, Watchtower combat, and research UI work through battle commands", async ({ page }) => {
    test.setTimeout(80_000);
    await startFirstClaimSkirmish(page, "Systems QA");

    await setBattlePlayerResources(page, { crowns: 0, stone: 0, iron: 0, aether: 0 });
    await selectPlayerCommandHallFromScene(page);
    const infantryWeapons = page.locator("button[data-action='upgrade'][data-id='infantry_weapons_1']");
    await expect(infantryWeapons).toBeDisabled();
    await expect(infantryWeapons).toContainText("Militia/Raider: +10% damage");
    await expect(infantryWeapons).toHaveAttribute("aria-label", /Insufficient resources/);

    await setBattlePlayerResources(page, { crowns: 2000, stone: 2000, iron: 2000, aether: 2000 });
    await expect(infantryWeapons).toBeEnabled();
    await infantryWeapons.click();
    await expect(infantryWeapons).toHaveAttribute("aria-label", /Researching/);
    await completeUpgradeQueues(page);
    await expect(infantryWeapons).toHaveAttribute("aria-label", /Researched/);

    const reinforcedArmor = page.locator("button[data-action='upgrade'][data-id='reinforced_armor_1']");
    await expect(reinforcedArmor).toBeEnabled();
    await reinforcedArmor.click();
    await completeUpgradeQueues(page);
    await expect(reinforcedArmor).toHaveAttribute("aria-label", /Researched/);

    await placePlayerBuildingFromScene(page, "barracks");
    await completePlayerBuilding(page, "barracks");
    await selectPlayerBuildingFromScene(page, "barracks");
    const rangerTraining = page.locator("button[data-action='upgrade'][data-id='ranger_training_1']");
    await expect(rangerTraining).toBeEnabled();
    await rangerTraining.click();
    await completeUpgradeQueues(page);
    await expect(rangerTraining).toHaveAttribute("aria-label", /Researched/);

    await placePlayerBuildingFromScene(page, "mystic_lodge");
    await completePlayerBuilding(page, "mystic_lodge");
    await selectPlayerBuildingFromScene(page, "mystic_lodge");
    await expect(page.locator(".side-panel")).toContainText("Mystic Lodge");
    let snapshot = await getBattleSnapshot(page);
    const acolytesBefore = snapshot.units.filter((unit: any) => unit.team === "player" && unit.unitId === "acolyte").length;
    await page.locator("button[data-action='train'][data-id='acolyte']").click();
    await completeTrainingQueues(page);
    await page.waitForFunction(
      (beforeCount) => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        const acolytes = scene?.units.filter((unit: any) => unit.team === "player" && unit.definition.id === "acolyte" && unit.alive) ?? [];
        return acolytes.length > beforeCount;
      },
      acolytesBefore,
      { timeout: 5_000 }
    );

    const aetherStudy = page.locator("button[data-action='upgrade'][data-id='aether_study_1']");
    await expect(aetherStudy).toBeEnabled();
    await aetherStudy.click();
    await completeUpgradeQueues(page);
    await expect(aetherStudy).toHaveAttribute("aria-label", /Researched/);

    await placePlayerBuildingFromScene(page, "watchtower");
    await completePlayerBuilding(page, "watchtower");
    const towerCombat = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const tower = scene.buildings.find(
        (building: any) =>
          building.team === "player" &&
          building.definition.id === "watchtower" &&
          building.alive &&
          building.constructionState === "completed"
      );
      const enemy = scene.units.find((unit: any) => unit.team === "enemy" && unit.alive);
      if (!tower || !enemy) {
        throw new Error("Expected a completed player Watchtower and a live enemy unit.");
      }
      enemy.setPosition(tower.position.x + 118, tower.position.y);
      enemy.moveTarget = undefined;
      enemy.attackTargetId = undefined;
      enemy.attackMove = false;
      enemy.attackCooldownRemaining = 999;
      tower.attackCooldownRemaining = 0;
      const hpBefore = enemy.hp;
      for (let index = 0; index < 60; index += 1) {
        scene.combatSystem.update(0.1);
      }
      return {
        hpBefore,
        hpAfter: enemy.hp,
        alive: enemy.alive
      };
    });
    expect(towerCombat.hpAfter).toBeLessThan(towerCombat.hpBefore);

    snapshot = await getBattleSnapshot(page);
    expect(snapshot.units.some((unit: any) => unit.team === "player" && unit.unitId === "acolyte" && unit.alive)).toBe(true);
    const researchedUpgradeIds = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      return Array.from(scene?.researchedUpgradeIds?.player ?? []);
    });
    expect(researchedUpgradeIds).toEqual(
      expect.arrayContaining(["infantry_weapons_1", "reinforced_armor_1", "ranger_training_1", "aether_study_1"])
    );
  });

  test("Ashen Outpost special objectives display completed states on Results", async ({ page }) => {
    test.setTimeout(60_000);
    await seedSave(page, {
      hero: {
        level: 4,
        xp: 320,
        skillPoints: 3
      },
      campaign: {
        difficulty: "normal",
        resources: { crowns: 220, stone: 160, iron: 95, aether: 80 },
        completedNodeIds: [
          "border_village",
          "old_stone_road",
          "aether_well_ruins",
          "bandit_hillfort",
          "chapel_of_the_marches"
        ],
        unlockedNodeIds: [
          "border_village",
          "old_stone_road",
          "aether_well_ruins",
          "bandit_hillfort",
          "refugee_caravan",
          "marcher_camp",
          "chapel_of_the_marches",
          "ashen_outpost"
        ],
        nodeRewardsClaimedIds: [
          "border_village",
          "old_stone_road",
          "aether_well_ruins",
          "bandit_hillfort",
          "chapel_of_the_marches"
        ]
      }
    });

    await page.getByTestId("menu-continue-campaign").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await page.getByTestId("campaign-node-ashen_outpost").click();
    await expect(page.getByTestId("campaign-start-node")).toBeEnabled();
    await page.getByTestId("campaign-start-node").click();
    await expectBattleLoaded(page);
    await waitForBattleScene(page);
    await expect(page.getByTestId("battle-objectives")).toContainText("Objectives 0/3");
    await expect(page.getByTestId("battle-objectives")).toContainText("Capture the Burned Shrine");

    const completedObjectiveIds = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const shrine = scene.captureSites.find((site: any) => site.definition.id === "burned_shrine");
      const watchtower = scene.buildings.find((building: any) => building.team === "enemy" && building.definition.id === "watchtower");
      const barracks = scene.buildings.find((building: any) => building.team === "enemy" && building.definition.id === "enemy_barracks");
      const captain = scene.units.find((unit: any) => unit.team === "enemy" && unit.definition.id === "enemy_commander");
      if (!shrine || !watchtower || !barracks || !captain) {
        throw new Error("Expected Ashen Outpost shrine, gate watchtower, enemy barracks, and outpost captain.");
      }
      const watchtowerHpBefore = watchtower.hp;
      shrine.owner = "player";
      shrine.capturingTeam = undefined;
      shrine.captureProgress = 0;
      scene.completeSecondaryObjective("capture_site", "burned_shrine", shrine.position);
      if (!(watchtower.hp < watchtowerHpBefore && watchtower.alive)) {
        throw new Error("Expected Burned Shrine objective to weaken the gate Watchtower without destroying it.");
      }
      barracks.takeDamage(barracks.maxHp + barracks.armor + 10_000);
      scene.completeSecondaryObjective("destroy_building", "enemy_barracks", barracks.position);
      captain.takeDamage(captain.maxHp + captain.armor + 10_000);
      scene.completeSecondaryObjective("defeat_unit", "enemy_commander", captain.position);
      return [...scene.runtime.stats.completedObjectiveIds];
    });
    expect(completedObjectiveIds).toEqual(
      expect.arrayContaining(["capture_burned_shrine", "destroy_enemy_barracks", "defeat_outpost_captain"])
    );
    await expect(page.getByTestId("battle-objectives")).toContainText("Objectives 3/3");

    await forceActiveBattleOutcome(page, "victory");
    const objectiveSummary = page.locator(".special-objectives");
    await expect(objectiveSummary).toContainText("Capture the Burned Shrine");
    await expect(objectiveSummary).toContainText("Destroy Enemy Barracks");
    await expect(objectiveSummary).toContainText("Defeat the Outpost Captain");
    const summaryText = await objectiveSummary.innerText();
    expect(summaryText).toMatch(/Capture the Burned Shrine\s+Completed/);
    expect(summaryText).toMatch(/Destroy Enemy Barracks\s+Completed/);
    expect(summaryText).toMatch(/Defeat the Outpost Captain\s+Completed/);
  });

  test("Old Stone Road victory unlocks the next campaign layer without repeat-starting completed rewards", async ({ page }) => {
    test.setTimeout(60_000);
    await seedSave(page, {
      hero: {
        level: 2,
        xp: 120,
        skillPoints: 1,
        completedBattles: 1,
        clearedMapIds: ["first_claim"],
        inventory: [
          {
            instanceId: "deep-qa:weathered_command_sword:old-road",
            itemId: "weathered_command_sword",
            acquiredAt: "2026-04-26T00:00:00.000Z",
            source: "campaign_node:border_village",
            affixes: [],
            locked: false,
            favorite: false
          }
        ]
      },
      campaign: {
        resources: { crowns: 0, stone: 0, iron: 0, aether: 0 },
        completedNodeIds: ["border_village"],
        unlockedNodeIds: ["border_village", "old_stone_road"],
        nodeRewardsClaimedIds: ["border_village"]
      }
    });

    await startCampaignBattle(page, "old_stone_road");
    await forceActiveBattleOutcome(page, "victory");
    await expect(page.locator(".results-panel")).toContainText("Victory");
    await expect(page.locator(".campaign-reward-block")).toContainText("Old Stone Road");

    let save = await readSave(page);
    expect(save.campaign.completedNodeIds).toContain("old_stone_road");
    expect(save.campaign.nodeRewardsClaimedIds).toContain("old_stone_road");
    expect(save.campaign.unlockedNodeIds).toEqual(
      expect.arrayContaining(["aether_well_ruins", "bandit_hillfort", "refugee_caravan", "marcher_camp"])
    );
    expect(save.campaign.resources).toMatchObject({
      crowns: 60,
      stone: 45,
      iron: 15,
      aether: 0
    });

    await page.getByRole("button", { name: "Campaign Map" }).click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("campaign-node-old_stone_road")).toContainText(/Completed/i);
    await expect(page.getByTestId("campaign-node-aether_well_ruins")).toContainText(/Available/i);
    await expect(page.getByTestId("campaign-node-bandit_hillfort")).toContainText(/Available/i);
    await expect(page.getByTestId("campaign-node-refugee_caravan")).toContainText(/Available/i);
    await expect(page.getByTestId("campaign-node-marcher_camp")).toContainText(/Available/i);

    await page.getByTestId("campaign-node-old_stone_road").click();
    await expect(page.getByTestId("campaign-start-node")).toBeDisabled();
    save = await readSave(page);
    expect(save.campaign.resources).toMatchObject({
      crowns: 60,
      stone: 45,
      iron: 15,
      aether: 0
    });
  });

  test("live campaign battles resolve victory and defeat through BattleScene results", async ({ page }) => {
    test.setTimeout(80_000);

    await seedSave(page);
    await startBorderVillageCampaignBattle(page);
    await forceActiveBattleOutcome(page, "victory");
    await expect(page.locator(".results-panel")).toContainText("Victory");
    await expect(page.locator(".campaign-reward-block")).toContainText("Border Village");
    let save = await readSave(page);
    expect(save.campaign.completedNodeIds).toContain("border_village");
    expect(save.campaign.unlockedNodeIds).toContain("old_stone_road");
    expect(save.campaign.nodeRewardsClaimedIds).toContain("border_village");
    expect(save.campaign.resources.crowns).toBeGreaterThan(0);
    expect(save.hero.completedBattles).toBe(1);
    expect(save.hero.inventory.length).toBeGreaterThan(0);

    await page.getByRole("button", { name: "Campaign Map" }).click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("campaign-node-border_village")).toContainText(/Completed/i);
    await expect(page.getByTestId("campaign-node-old_stone_road")).toContainText(/Available/i);

    await seedSave(page);
    await startBorderVillageCampaignBattle(page);
    await forceActiveBattleOutcome(page, "defeat");
    await expect(page.locator(".results-panel")).toContainText("Defeat");
    await expect(page.locator(".defeat-tips")).toBeVisible();
    save = await readSave(page);
    expect(save.campaign.completedNodeIds).not.toContain("border_village");
    expect(save.campaign.nodeRewardsClaimedIds).not.toContain("border_village");
    expect(save.hero.completedBattles).toBe(0);
    expect(save.hero.inventory.length).toBe(0);
  });
});
