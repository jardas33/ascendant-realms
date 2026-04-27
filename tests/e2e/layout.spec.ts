import { expect, test, type Locator, type Page } from "@playwright/test";

const LAYOUT_VIEWPORTS = [
  { width: 1366, height: 768, label: "desktop" },
  { width: 820, height: 620, label: "tablet-short" },
  { width: 390, height: 844, label: "mobile-tall" },
  { width: 360, height: 640, label: "mobile-short" }
];

async function openFreshMainMenu(page: Page): Promise<void> {
  await page.goto("/");
  await page.evaluate(() => localStorage.clear());
  await page.reload();
  await expect(page.getByTestId("main-menu")).toBeVisible();
}

async function createHero(page: Page, name: string): Promise<void> {
  await expect(page.getByTestId("hero-creation")).toBeVisible();
  await page.getByTestId("hero-name-input").fill(name);
  await page.getByTestId("hero-start").click();
}

async function startNewCampaign(page: Page): Promise<void> {
  await openFreshMainMenu(page);
  await page.getByTestId("menu-new-campaign").click();
  await createHero(page, "Layout Campaign");
  await expect(page.getByTestId("campaign-map")).toBeVisible();
}

async function expectNoHorizontalOverflow(page: Page, label: string): Promise<void> {
  const result = await page.evaluate(() => {
    const root = document.getElementById("ui-root");
    const viewportWidth = window.innerWidth;
    const offenders = Array.from(root?.querySelectorAll<HTMLElement>("*") ?? [])
      .map((element) => {
        const style = window.getComputedStyle(element);
        const rect = element.getBoundingClientRect();
        if (
          style.display === "none" ||
          style.visibility === "hidden" ||
          rect.width === 0 ||
          rect.height === 0 ||
          element.closest("[aria-hidden='true']")
        ) {
          return undefined;
        }
        if (rect.left < -2 || rect.right > viewportWidth + 2) {
          return {
            tag: element.tagName.toLowerCase(),
            className: String(element.className),
            testId: element.getAttribute("data-testid") ?? "",
            left: Math.round(rect.left),
            right: Math.round(rect.right),
            width: Math.round(rect.width),
            text: (element.textContent ?? "").trim().replace(/\s+/g, " ").slice(0, 80)
          };
        }
        return undefined;
      })
      .filter(Boolean)
      .slice(0, 8);
    return { viewportWidth, offenders };
  });

  expect(result.offenders, `${label} horizontal overflow at ${result.viewportWidth}px`).toEqual([]);
}

async function scrollMainToBottom(page: Page): Promise<void> {
  await page.locator("main").evaluate((element) => {
    element.scrollTop = element.scrollHeight;
  });
}

async function expectInViewport(page: Page, locator: Locator, label: string): Promise<void> {
  const box = await locator.boundingBox();
  expect(box, `${label} has a layout box`).not.toBeNull();
  const viewport = page.viewportSize();
  expect(viewport, `${label} viewport exists`).not.toBeNull();
  if (!box || !viewport) {
    return;
  }
  expect(box.x, `${label} left edge`).toBeGreaterThanOrEqual(-2);
  expect(box.x + box.width, `${label} right edge`).toBeLessThanOrEqual(viewport.width + 2);
  expect(box.y, `${label} top edge`).toBeGreaterThanOrEqual(-2);
  expect(box.y + box.height, `${label} bottom edge`).toBeLessThanOrEqual(viewport.height + 2);
}

async function expectBattleCommandButtonsReachable(page: Page, actions: string[], label: string): Promise<void> {
  const result = await page.evaluate((requestedActions) => {
    const panel = document.querySelector<HTMLElement>(".side-panel");
    if (!panel) {
      return { count: 0, offenders: ["missing side panel"], labels: [] };
    }
    const panelRect = panel.getBoundingClientRect();
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;
    const buttons = requestedActions.flatMap((action) =>
      Array.from(panel.querySelectorAll<HTMLButtonElement>(`button[data-action="${action}"]`))
    );
    const offenders = buttons
      .map((button) => {
        const rect = button.getBoundingClientRect();
        const label = button.getAttribute("aria-label") ?? button.textContent?.replace(/\s+/g, " ").trim() ?? "";
        const problems = [];
        if (rect.left < -1 || rect.right > viewportWidth + 1) {
          problems.push("outside viewport width");
        }
        if (rect.top < panelRect.top - 1 || rect.bottom > panelRect.bottom + 1 || rect.top < -1 || rect.bottom > viewportHeight + 1) {
          problems.push("not visible in command panel");
        }
        if (rect.width < 72 || rect.height < 40) {
          problems.push(`small tap target ${Math.round(rect.width)}x${Math.round(rect.height)}`);
        }
        return problems.length > 0 ? `${label}: ${problems.join(", ")}` : undefined;
      })
      .filter((entry): entry is string => Boolean(entry));
    return {
      count: buttons.length,
      offenders,
      labels: buttons.map((button) => button.getAttribute("aria-label") ?? button.textContent?.replace(/\s+/g, " ").trim() ?? "")
    };
  }, actions);

  expect(result.count, `${label} command buttons for ${actions.join(", ")} are present`).toBeGreaterThan(0);
  expect(result.offenders, `${label} command buttons should be visible, wide enough, and inside the panel`).toEqual([]);
}

async function selectBattleBuilding(page: Page, buildingId: string, expectedName: string): Promise<void> {
  await page.evaluate(({ buildingId }) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const building = scene.buildings.find(
      (entry: any) => entry.team === "player" && entry.definition.id === buildingId && entry.alive
    );
    if (!building) {
      throw new Error(`Missing player building: ${buildingId}`);
    }
    scene.cameraSystem.centerOn(building.position);
    scene.selectionSystem.setSelection([building]);
    scene.update(performance.now(), 200);
  }, { buildingId });
  await expect(page.locator(".side-panel")).toContainText(expectedName);
}

async function createCompletedBarracksAndSelect(page: Page): Promise<void> {
  await page.evaluate(() => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    let barracks = scene.buildings.find(
      (entry: any) => entry.team === "player" && entry.definition.id === "barracks" && entry.alive
    );
    if (!barracks) {
      const commandHall = scene.buildings.find(
        (entry: any) => entry.team === "player" && entry.definition.id === "command_hall" && entry.alive
      );
      if (!commandHall) {
        throw new Error("Missing Command Hall.");
      }
      scene.buildingSystem.startPlacement("barracks", { anchor: commandHall.position, resources: scene.resources.player });
      const ghost = scene.buildingSystem.ghost;
      if (!ghost || !scene.buildingSystem.tryPlace(ghost.x, ghost.y, scene.resources.player)) {
        throw new Error("Unable to place Barracks for layout check.");
      }
      barracks = scene.buildings.find(
        (entry: any) => entry.team === "player" && entry.definition.id === "barracks" && entry.alive
      );
    }
    scene.buildingSystem.update((barracks.definition.constructionTimeSeconds ?? 25) + 1);
    scene.cameraSystem.centerOn(barracks.position);
    scene.selectionSystem.setSelection([barracks]);
    scene.update(performance.now(), 200);
  });
  await expect(page.locator(".side-panel")).toContainText("Barracks");
}

async function expectBottomActionReachable(page: Page, locator: Locator, label: string): Promise<void> {
  await scrollMainToBottom(page);
  await expectInViewport(page, locator, label);
}

async function showVictoryResults(page: Page): Promise<void> {
  await openFreshMainMenu(page);
  await page.evaluate(() => {
    const game = window.ascendantRealmsGame;
    if (!game) {
      throw new Error("Ascendant Realms game was not booted.");
    }
    const rewardInstance = {
      instanceId: "layout:ashbound_censer:manual-audit",
      itemId: "ashbound_censer",
      acquiredAt: "2026-04-26T17:55:00.000Z",
      source: "layout_audit",
      affixes: [],
      locked: false,
      favorite: false
    };
    const startingHero = {
      heroName: "Layout Hero",
      classId: "warlord",
      originId: "exiled_noble",
      level: 1,
      xp: 80,
      skillPoints: 0,
      unlockedAbilities: ["rally_banner"],
      completedBattles: 1,
      clearedMapIds: ["first_claim"],
      inventory: [],
      equipment: {},
      allocatedSkills: {},
      factionReputation: { free_marches: 0, ashen_covenant: 0, sylvan_concord: 0, common_folk: 0, old_faith: 0 },
      stats: { might: 8, command: 8, arcana: 2, faith: 3 }
    };
    const hero = {
      ...startingHero,
      level: 2,
      xp: 165,
      skillPoints: 1,
      inventory: [rewardInstance],
      completedBattles: 2,
      clearedMapIds: ["first_claim", "ashen_outpost"]
    };
    game.scene.start("ResultsScene", {
      heroSave: hero,
      startingHeroSave: startingHero,
      launchRequest: {
        requestId: "layout-results",
        mode: "campaign_node",
        mapId: "ashen_outpost",
        heroSave: hero,
        sourceId: "layout",
        rewardTableId: "ashen_outpost_rewards",
        difficulty: "normal",
        modifiers: [],
        enemyProfileId: "ashen_covenant",
        aiPersonalityId: "hexfire_cult",
        campaignNodeId: "ashen_outpost"
      },
      stats: {
        outcome: "victory",
        unitsKilled: 42,
        buildingsDestroyed: 4,
        resourcesCaptured: 4,
        firstSiteCaptured: "Burned Shrine",
        buildingsBuilt: 5,
        builtBuildingIds: ["barracks", "mystic_lodge", "watchtower"],
        unitsTrained: 16,
        trainedUnitIds: ["militia", "ranger", "acolyte"],
        enemyWavesSurvived: 5,
        xpGained: 85,
        timeSeconds: 628,
        completedObjectiveIds: ["capture_burned_shrine", "destroy_enemy_barracks", "defeat_outpost_captain"]
      },
      reward: {
        itemIds: ["ashbound_censer"],
        itemInstances: [rewardInstance],
        resources: { crowns: 120, stone: 45, iron: 35, aether: 25 },
        xp: 85,
        duplicateConversions: []
      },
      rewardLevelUp: { previousLevel: 1, newLevel: 2, levelsGained: 1, skillPointsGained: 1 },
      campaignResult: {
        completedNodeId: "ashen_outpost",
        completedNodeName: "Ashen Outpost",
        unlockedNodeNames: ["Future Roads"],
        nodeReward: {
          itemIds: ["oathbound_aegis"],
          itemInstances: [],
          resources: { crowns: 125, stone: 65, iron: 75, aether: 50 },
          xp: 90,
          duplicateConversions: [{ itemId: "oathbound_aegis", reason: "unique_duplicate", resources: { aether: 25 } }]
        },
        nodeLevelUp: { previousLevel: 2, newLevel: 2, levelsGained: 0, skillPointsGained: 0 },
        campaignResources: { crowns: 245, stone: 110, iron: 110, aether: 100 }
      }
    });
  });
  await expect(page.locator(".results-panel")).toBeVisible();
}

test.describe("Ascendant Realms responsive layout", () => {
  for (const viewport of LAYOUT_VIEWPORTS) {
    test(`menu and hero creation fit or scroll on ${viewport.label}`, async ({ page }) => {
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await openFreshMainMenu(page);
      await expectNoHorizontalOverflow(page, `${viewport.label} main menu`);
      await expectBottomActionReachable(page, page.getByText("Credits / Info"), `${viewport.label} main menu bottom action`);

      await page.getByTestId("menu-skirmish").click();
      await expect(page.getByTestId("hero-creation")).toBeVisible();
      await expectNoHorizontalOverflow(page, `${viewport.label} hero creation`);
      await expectBottomActionReachable(page, page.getByTestId("hero-start"), `${viewport.label} hero creation start`);
    });

    test(`campaign, setup, inventory, and asset gallery remain reachable on ${viewport.label}`, async ({ page }) => {
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await startNewCampaign(page);
      await expectNoHorizontalOverflow(page, `${viewport.label} campaign map`);
      await expectBottomActionReachable(page, page.getByTestId("campaign-main-menu"), `${viewport.label} campaign actions`);

      await page.getByTestId("campaign-main-menu").click();
      await page.getByTestId("menu-skirmish").click();
      await expect(page.getByTestId("skirmish-setup")).toBeVisible();
      await expectNoHorizontalOverflow(page, `${viewport.label} skirmish setup`);
      await expectBottomActionReachable(page, page.getByTestId("setup-start-battle"), `${viewport.label} setup start`);

      await page.getByTestId("setup-back").click();
      await page.getByTestId("menu-inventory").click();
      await expect(page.getByTestId("hero-inventory")).toBeVisible();
      await expectNoHorizontalOverflow(page, `${viewport.label} inventory`);
      await expectBottomActionReachable(page, page.getByText("Main Menu"), `${viewport.label} inventory bottom action`);

      await page.getByText("Main Menu").click();
      await page.getByTestId("menu-asset-gallery").click();
      await expect(page.getByText("Asset Gallery")).toBeVisible();
      await expectNoHorizontalOverflow(page, `${viewport.label} asset gallery`);
      await expectInViewport(page, page.getByRole("button", { name: "Back" }), `${viewport.label} asset gallery back`);
    });
  }

  for (const viewport of [
    { width: 820, height: 620, label: "tablet-short" },
    { width: 390, height: 844, label: "mobile-tall" },
    { width: 360, height: 640, label: "mobile-short" }
  ]) {
    test(`battle HUD and results layout stay inside the viewport on ${viewport.label}`, async ({ page }) => {
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await startNewCampaign(page);
      await page.getByTestId("campaign-node-border_village").click();
      await page.getByTestId("campaign-start-node").click();
      await expect(page.getByTestId("battle-hud")).toBeVisible({ timeout: 15_000 });
      await expectNoHorizontalOverflow(page, `${viewport.label} battle hud`);
      await expectInViewport(page, page.getByTestId("battle-hero-panel"), `${viewport.label} hero panel`);
      await expectInViewport(page, page.getByTestId("battle-minimap"), `${viewport.label} minimap`);
      await selectBattleBuilding(page, "command_hall", "Command Hall");
      await expectNoHorizontalOverflow(page, `${viewport.label} command hall commands`);
      await expectBattleCommandButtonsReachable(page, ["build", "upgrade"], `${viewport.label} command hall`);
      await createCompletedBarracksAndSelect(page);
      await expectNoHorizontalOverflow(page, `${viewport.label} barracks commands`);
      await expectBattleCommandButtonsReachable(page, ["train", "upgrade"], `${viewport.label} barracks`);

      await showVictoryResults(page);
      await expectNoHorizontalOverflow(page, `${viewport.label} results`);
      await expectBottomActionReachable(page, page.getByText("Main Menu"), `${viewport.label} results main menu`);
    });
  }
});
