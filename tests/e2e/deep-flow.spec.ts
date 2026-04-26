import { expect, test, type Page } from "@playwright/test";

const SAVE_KEY = "ascendant-realms-save-v1";

type CampaignResources = {
  crowns: number;
  stone: number;
  iron: number;
  aether: number;
};

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

async function startSyntheticResults(page: Page, outcome: "victory" | "defeat"): Promise<void> {
  await openMainMenu(page);
  await page.evaluate(({ selectedOutcome, baseHero }) => {
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
    const heroSave = selectedOutcome === "victory"
      ? {
          ...startingHero,
          level: 2,
          xp: 125,
          skillPoints: 1,
          completedBattles: 1,
          clearedMapIds: ["first_claim"],
          inventory: [rewardInstance]
        }
      : startingHero;
    game.scene.start("ResultsScene", {
      heroSave,
      startingHeroSave: startingHero,
      launchRequest: {
        requestId: "deep-results",
        mode: "campaign_node",
        mapId: "first_claim",
        heroSave,
        sourceId: "deep_e2e",
        rewardTableId: "first_claim_rewards",
        difficulty: "easy",
        modifiers: [],
        enemyProfileId: "ashen_covenant",
        aiPersonalityId: "balanced_warlord",
        campaignNodeId: "border_village"
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
        xpGained: selectedOutcome === "victory" ? 45 : 0,
        timeSeconds: selectedOutcome === "victory" ? 420 : 95,
        completedObjectiveIds: []
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
  }, { selectedOutcome: outcome, baseHero: BASE_HERO });
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

async function startBorderVillageCampaignBattle(page: Page): Promise<void> {
  await page.getByTestId("menu-continue-campaign").click();
  await expect(page.getByTestId("campaign-map")).toBeVisible();
  await page.getByTestId("campaign-node-border_village").click();
  await expect(page.getByTestId("campaign-start-node")).toBeEnabled();
  await page.getByTestId("campaign-start-node").click();
  await expectBattleLoaded(page);
  await waitForBattleScene(page);
}

test.describe("Ascendant Realms deep end-to-end QA", () => {
  test("main menu, info, hero creation selections, reset state, and gallery navigation work", async ({ page }) => {
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

    await page.getByTestId("campaign-main-menu").click();
    await expect(page.getByTestId("menu-continue-campaign")).toBeEnabled();
    await expect(page.getByTestId("menu-inventory")).toBeEnabled();
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
    expect(save.campaign.resources.crowns).toBe(340);
    expect(save.campaign.activeModifierIds).toContain("angered_raiders");
    expect(save.hero.factionReputation.common_folk).toBe(-8);

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

    await startSyntheticResults(page, "defeat");
    await expect(page.locator(".defeat-tips")).toContainText("Capture");
    await expect(page.getByRole("button", { name: "Retry" })).toBeVisible();
    await expect(page.getByRole("button", { name: "Campaign Map" })).toBeVisible();
    save = await readSave(page);
    expect(save.hero.equipment.weapon).toBe("deep-qa:weathered_command_sword:1");
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

    await page.getByTestId("minimap").click({ position: { x: 90, y: 60 } });
    await page.keyboard.press("F");
    await expect(page.getByTestId("battle-status")).toContainText(/Fog/i);
    await page.keyboard.press("H");

    await selectPlayerCommandHallFromScene(page);
    await expect(page.locator(".side-panel")).toContainText("Command Hall");
    await expect(page.locator(".side-panel")).toContainText("Build");
    await page.locator("button[data-action='build'][data-id='barracks']").click();
    await expect(page.getByTestId("battle-status")).toContainText(/Placing|Barracks/i);
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
