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
              xp: 35,
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
    expect(save.campaign.resources.crowns).toBe(350);
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
    await page.keyboard.press("Escape");
    await expect(page.getByTestId("battle-status")).toContainText(/cancel/i);
  });
});
