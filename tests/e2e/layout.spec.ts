import { expect, test, type Locator, type Page } from "@playwright/test";
import {
  completeCinderfenOverlookChoice,
  completeCinderfenWatchVictory,
  launchCinderfenCrossing,
  launchCinderfenWatch,
  openCinderfenWaystation,
  seedCompletedCinderfenRouteCampaign,
  seedPostAshenCampaign,
  seedPostCinderfenCrossingCampaign
} from "./chapter2-helpers";
import { continueSavedCampaign, openFreshMainMenu, seedCampaignSave } from "./shared-helpers";

const LAYOUT_VIEWPORTS = [
  { width: 1366, height: 768, label: "desktop" },
  { width: 820, height: 620, label: "tablet-short" },
  { width: 390, height: 844, label: "mobile-tall" },
  { width: 360, height: 640, label: "mobile-short" }
];
const CINDERFEN_READABILITY_VIEWPORTS = [
  { width: 1366, height: 768, label: "desktop" },
  { width: 820, height: 620, label: "tablet" },
  { width: 390, height: 844, label: "mobile portrait" },
  { width: 844, height: 390, label: "mobile landscape" }
];
const CINDERFEN_BATTLE_READABILITY_VIEWPORTS = [
  { width: 1366, height: 768, label: "desktop" },
  { width: 390, height: 844, label: "mobile portrait" },
  { width: 844, height: 390, label: "mobile landscape" }
];

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

async function expectTutorialOverlayHasFeedbackPriority(page: Page, label: string): Promise<void> {
  const result = await page.evaluate(() => {
    const tutorial = document.querySelector<HTMLElement>("[data-testid='tutorial-overlay']");
    const status = document.querySelector<HTMLElement>("[data-testid='battle-status']");
    if (!tutorial || !status) {
      return { present: false, tutorialZIndex: NaN, statusZIndex: NaN };
    }
    return {
      present: true,
      tutorialZIndex: Number(window.getComputedStyle(tutorial).zIndex),
      statusZIndex: Number(window.getComputedStyle(status).zIndex)
    };
  });

  expect(result.present, `${label} tutorial and status feedback are present`).toBe(true);
  expect(Number.isFinite(result.tutorialZIndex), `${label} tutorial z-index is explicit`).toBe(true);
  expect(Number.isFinite(result.statusZIndex), `${label} status z-index is explicit`).toBe(true);
  expect(result.tutorialZIndex, `${label} tutorial should render above battle status feedback`).toBeGreaterThan(
    result.statusZIndex
  );
}

async function expectWithinViewportWidth(page: Page, locator: Locator, label: string): Promise<void> {
  await locator.evaluate((element) => element.scrollIntoView({ block: "nearest", inline: "nearest" }));
  const box = await locator.boundingBox();
  expect(box, `${label} has a layout box`).not.toBeNull();
  const viewport = page.viewportSize();
  expect(viewport, `${label} viewport exists`).not.toBeNull();
  if (!box || !viewport) {
    return;
  }
  expect(box.x, `${label} left edge`).toBeGreaterThanOrEqual(-2);
  expect(box.x + box.width, `${label} right edge`).toBeLessThanOrEqual(viewport.width + 2);
}

async function expectReachableButton(
  page: Page,
  locator: Locator,
  label: string,
  options: { enabled?: boolean } = {}
): Promise<void> {
  await locator.evaluate((element) => element.scrollIntoView({ block: "nearest", inline: "nearest" }));
  await expect(locator, `${label} visible`).toBeVisible();
  if (options.enabled !== false) {
    await expect(locator, `${label} enabled`).toBeEnabled();
  }
  await expectInViewport(page, locator, label);
  const box = await locator.boundingBox();
  expect(box, `${label} has button dimensions`).not.toBeNull();
  if (!box) {
    return;
  }
  expect(box.width, `${label} tap width`).toBeGreaterThanOrEqual(40);
  expect(box.height, `${label} tap height`).toBeGreaterThanOrEqual(32);
}

async function launchTutorialOverlay(page: Page, label: string): Promise<void> {
  await openFreshMainMenu(page);
  await expectNoHorizontalOverflow(page, `${label} main menu`);
  await expectReachableButton(page, page.getByTestId("menu-tutorial"), `${label} Tutorial`);
  await page.getByTestId("menu-tutorial").click();
  await expect(page.getByTestId("battle-hud")).toBeVisible({ timeout: 15_000 });
  await expect(page.getByTestId("tutorial-overlay")).toBeVisible();
}

async function expectBattleCommandButtonsReachable(page: Page, actions: string[], label: string): Promise<void> {
  const result = await page.evaluate((requestedActions) => {
    const panel = document.querySelector<HTMLElement>(".side-panel");
    if (!panel) {
      return { count: 0, offenders: ["missing side panel"], labels: [] };
    }
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;
    const buttons = requestedActions.flatMap((action) =>
      Array.from(panel.querySelectorAll<HTMLButtonElement>(`button[data-action="${action}"]`))
    );
    const offenders = buttons
      .map((button) => {
        button.scrollIntoView({ block: "nearest", inline: "nearest" });
        const rect = button.getBoundingClientRect();
        const nextPanelRect = panel.getBoundingClientRect();
        const label = button.getAttribute("aria-label") ?? button.textContent?.replace(/\s+/g, " ").trim() ?? "";
        const problems = [];
        if (rect.left < -1 || rect.right > viewportWidth + 1) {
          problems.push("outside viewport width");
        }
        if (rect.top < nextPanelRect.top - 1 || rect.bottom > nextPanelRect.bottom + 1 || rect.top < -1 || rect.bottom > viewportHeight + 1) {
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
    scene.refreshBattleHud?.(0);
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
    scene.refreshBattleHud?.(0);
  });
  await expect(page.locator(".side-panel")).toContainText("Barracks");
}

async function expectBottomActionReachable(page: Page, locator: Locator, label: string): Promise<void> {
  await scrollMainToBottom(page);
  await expectInViewport(page, locator, label);
}

async function expectCampaignSupportPanelsReadable(page: Page, label: string): Promise<void> {
  for (const [testId, expectedText] of [
    ["campaign-bank", "Crowns"],
    ["stronghold-panel", "Stronghold"],
    ["retinue-panel", "Retinue"],
    ["rival-intel-panel", "Rival Intel"],
    ["campaign-reputation", "Common Folk"]
  ] as const) {
    const panel = page.getByTestId(testId);
    await expect(panel, `${label} ${testId}`).toContainText(expectedText);
    await expectWithinViewportWidth(page, panel, `${label} ${testId}`);
  }
}

async function expectCinderfenBattleHudReadable(
  page: Page,
  label: string,
  expected: { mapName: string; objectiveTexts: string[] }
): Promise<void> {
  await expect(page.getByTestId("battle-status")).toContainText(expected.mapName);
  for (const objectiveText of expected.objectiveTexts) {
    await expect(page.getByTestId("battle-objectives")).toContainText(objectiveText);
  }
  await expect(page.getByTestId("battle-resources")).toContainText("Crowns");
  await expect(page.getByTestId("battle-resources")).toContainText("Aether");
  await expect(page.getByTestId("battle-minimap")).toBeVisible();
  await expect(page.getByTestId("minimap")).toBeVisible();
  await expectNoHorizontalOverflow(page, `${label} battle hud`);
  await expectWithinViewportWidth(page, page.getByTestId("battle-objectives"), `${label} objectives panel`);
  await expectWithinViewportWidth(page, page.locator(".side-panel"), `${label} command panel`);
  await expectWithinViewportWidth(page, page.getByTestId("battle-minimap"), `${label} minimap`);
  await selectBattleBuilding(page, "command_hall", "Command Hall");
  await expectNoHorizontalOverflow(page, `${label} command hall commands`);
  await expectBattleCommandButtonsReachable(page, ["build", "upgrade"], `${label} command hall`);
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

async function startAshenOutpostSkirmish(page: Page, heroName: string): Promise<void> {
  await seedCampaignSave(page, { hero: { heroName } });
  await page.getByTestId("menu-skirmish").click();
  await expect(page.getByTestId("skirmish-setup")).toBeVisible();
  await page.getByTestId("setup-map-ashen_outpost").click();
  await page.getByTestId("setup-difficulty-normal").click();
  await page.getByTestId("setup-start-battle").click();
  await expect(page.getByTestId("battle-hud")).toBeVisible({ timeout: 15_000 });
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
      await seedCampaignSave(page, { hero: { heroName: `Layout ${viewport.label}` } });
      await continueSavedCampaign(page);
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

    test(`tutorial entry and first objective overlay stay readable on ${viewport.label}`, async ({ page }) => {
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await launchTutorialOverlay(page, viewport.label);
      await expect(page.getByTestId("tutorial-objective")).toContainText("Camera Controls");
      await expect(page.getByTestId("tutorial-instruction")).toContainText("Pan with WASD or arrow keys");
      await expect(page.getByTestId("tutorial-progress")).toContainText("Step 1 of 12: complete");
      await expectNoHorizontalOverflow(page, `${viewport.label} tutorial overlay`);
      await expectInViewport(page, page.getByTestId("tutorial-overlay"), `${viewport.label} tutorial overlay`);
      await expectTutorialOverlayHasFeedbackPriority(page, `${viewport.label} tutorial overlay`);
      const overlayBox = await page.getByTestId("tutorial-overlay").boundingBox();
      expect(overlayBox, `${viewport.label} tutorial overlay has width`).not.toBeNull();
      if (overlayBox) {
        expect(overlayBox.width, `${viewport.label} tutorial overlay stays readable`).toBeGreaterThanOrEqual(
          Math.min(320, viewport.width - 24) - 2
        );
      }
      await expectReachableButton(page, page.getByTestId("tutorial-next"), `${viewport.label} tutorial next`);
      await expectReachableButton(page, page.getByTestId("tutorial-exit"), `${viewport.label} tutorial exit`);
      await expectWithinViewportWidth(page, page.locator(".side-panel"), `${viewport.label} battle command panel`);
    });
  }

  for (const viewport of [
    { width: 1366, height: 768, label: "desktop" },
    { width: 820, height: 620, label: "tablet-short" },
    { width: 390, height: 844, label: "mobile-tall" },
    { width: 360, height: 640, label: "mobile-short" }
  ]) {
    test(`battle HUD and results layout stay inside the viewport on ${viewport.label}`, async ({ page }) => {
      test.setTimeout(60_000);
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await seedCampaignSave(page, { hero: { heroName: `Layout Battle ${viewport.label}` } });
      await continueSavedCampaign(page);
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
      await expectBottomActionReachable(
        page,
        page.locator(".results-panel").getByRole("button", { name: "Main Menu" }),
        `${viewport.label} results main menu`
      );
    });
  }

  for (const viewport of CINDERFEN_READABILITY_VIEWPORTS) {
    test(`v0.3 Cinderfen menu and campaign readability fit ${viewport.label}`, async ({ page }) => {
      test.setTimeout(90_000);
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await seedPostAshenCampaign(page, { includeMalrecTrophy: true });
      await expect(page.getByText("Prototype v0.3", { exact: true })).toBeVisible();
      await expect(page.getByText("Cinderfen Route Baseline", { exact: true })).toBeVisible();
      await expectNoHorizontalOverflow(page, `${viewport.label} main menu`);
      await expectReachableButton(page, page.getByTestId("menu-new-campaign"), `${viewport.label} New Campaign`);
      await expectReachableButton(page, page.getByTestId("menu-continue-campaign"), `${viewport.label} Continue Campaign`);
      await expectReachableButton(page, page.getByTestId("menu-skirmish"), `${viewport.label} Skirmish`);

      await continueSavedCampaign(page);
      await expectNoHorizontalOverflow(page, `${viewport.label} post-Ashen campaign map`);
      await expect(page.getByTestId("campaign-chapter-border_marches")).toContainText("Chapter 1: Border Marches");
      await expect(page.getByTestId("campaign-chapter-cinderfen_road")).toContainText("Chapter 2: Cinderfen Road");
      await expect(page.getByTestId("campaign-node-border_village")).toContainText(/Completed/i);
      await expect(page.getByTestId("campaign-node-cinderfen_overlook")).toContainText(/Available/i);
      await expectCampaignSupportPanelsReadable(page, `${viewport.label} campaign map`);

      await page.getByTestId("campaign-node-cinderfen_overlook").click();
      await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Overlook");
      await expect(page.locator(".campaign-node-details")).toContainText("Aid the Marsh Refugees");
      await expect(page.locator(".campaign-node-details")).toContainText("Study the Cinders");
      await expect(page.locator(".campaign-node-details")).toContainText("Raise Malrec's Standard");
      const standardChoice = page.locator("button[data-campaign-choice='raise_malrecs_standard']");
      await expect(standardChoice).toContainText("Cost: None");
      await expect(standardChoice).toContainText("Rewards: 10 XP");
      await expect(standardChoice).toContainText("Reputation: +3 The Free Marches");
      await expect(standardChoice).toContainText("Modifiers: Gain Well Rested");
      await expectReachableButton(page, standardChoice, `${viewport.label} Malrec trophy choice`);
      await expectNoHorizontalOverflow(page, `${viewport.label} Cinderfen Overlook details`);

      await completeCinderfenOverlookChoice(page, "raise_malrecs_standard", "Raise Malrec's Standard chosen");
      await openCinderfenWaystation(page);
      await expect(page.locator(".campaign-node-details")).toContainText("Town Services");
      await expect(page.locator("button[data-campaign-choice='marsh_guides']")).toContainText("Cost: 35 Crowns");
      await expect(page.locator("button[data-campaign-choice='shrine_attunement']")).toContainText("Cost: 12 Aether");
      await expect(page.locator("button[data-campaign-choice='shrine_attunement']")).toContainText(
        "Modifiers: Gain Shrine Attunement"
      );
      await expect(page.locator("button[data-campaign-choice='shrine_attunement']")).toContainText("Keeps this node open");
      await expectReachableButton(
        page,
        page.locator("button[data-campaign-choice='marsh_guides']"),
        `${viewport.label} Marsh Guides service`
      );
      await expectReachableButton(
        page,
        page.locator("button[data-campaign-choice='shrine_attunement']"),
        `${viewport.label} Shrine Attunement service`
      );
      await expectNoHorizontalOverflow(page, `${viewport.label} Cinderfen Waystation details`);

      await page.getByTestId("campaign-node-cinderfen_crossing").click();
      await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Causeway");
      await expect(page.locator(".campaign-node-details")).toContainText("Scout's Bow");
      await expectReachableButton(page, page.getByTestId("campaign-start-node"), `${viewport.label} Crossing start`);

      await seedCompletedCinderfenRouteCampaign(page);
      await continueSavedCampaign(page);
      await expectNoHorizontalOverflow(page, `${viewport.label} completed Cinderfen campaign map`);
      await expect(page.getByTestId("campaign-node-cinderfen_aftermath")).toContainText(/Completed/i);
      await expect(page.locator(".guidance-card").filter({ hasText: "Cinderfen route secured" })).toContainText(
        "Chapter 2 route complete"
      );
      await expect(page.locator(".guidance-card").filter({ hasText: "Cinderfen route secured" })).toContainText(
        "future Cinderfen roads"
      );
      await page.getByTestId("campaign-node-cinderfen_aftermath").click();
      await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Aftermath");
      await expect(page.locator(".campaign-node-details")).toContainText("Secure the Watch Road");
      await expect(page.locator(".campaign-node-details")).toContainText("Aid the Fenfolk");
      await expect(page.locator(".campaign-node-details")).toContainText("Study the Ashen Marks");
      await expect(page.locator("button[data-campaign-choice='aid_the_fenfolk']")).toContainText("Already chosen");
      await expectReachableButton(
        page,
        page.locator("button[data-campaign-choice='aid_the_fenfolk']"),
        `${viewport.label} completed Aftermath choice`,
        { enabled: false }
      );
      await expectNoHorizontalOverflow(page, `${viewport.label} Cinderfen Aftermath details`);
    });
  }

  for (const viewport of CINDERFEN_BATTLE_READABILITY_VIEWPORTS) {
    test(`Cinderfen battle HUD and Watch results readability fit ${viewport.label}`, async ({ page }) => {
      test.setTimeout(viewport.label === "mobile portrait" ? 120_000 : 90_000);
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await seedPostAshenCampaign(page);
      await continueSavedCampaign(page);
      await page.getByTestId("campaign-node-cinderfen_overlook").click();
      await completeCinderfenOverlookChoice(page, "aid_marsh_refugees", "Aid the Marsh Refugees chosen");
      await launchCinderfenCrossing(page);
      await expectCinderfenBattleHudReadable(page, `${viewport.label} Crossing`, {
        mapName: "Cinderfen Causeway",
        objectiveTexts: ["Claim the Cinder Shrine", "Cinder Shrine Surge", "Clear Cinder Guardians", "Destroy Enemy Barracks"]
      });

      await seedPostCinderfenCrossingCampaign(page);
      await continueSavedCampaign(page);
      await launchCinderfenWatch(page);
      await expectCinderfenBattleHudReadable(page, `${viewport.label} Watch`, {
        mapName: "Cinderfen Watchpost",
        objectiveTexts: ["Capture the Watch Road", "Clear the Marsh Raider Camp", "Destroy the Watchpost Tower"]
      });

      if (viewport.label === "mobile portrait") {
        await completeCinderfenWatchVictory(page);
        const resultsPanel = page.locator(".results-panel");
        await expect(resultsPanel).toContainText("Victory");
        await expect(resultsPanel).toContainText("Cinderfen Watchpost");
        await expect(resultsPanel).toContainText("Reward XP");
        await expect(page.locator(".campaign-reward-block")).toContainText("Cinderfen Aftermath");
        await expect(page.locator(".special-objectives")).toContainText("Capture the Watch Road");
        await expect(page.locator(".special-objectives")).toContainText("Destroy the Watchpost Tower");
        await expectNoHorizontalOverflow(page, "mobile portrait Cinderfen Watch results");
        await expectReachableButton(
          page,
          page.locator(".results-panel").getByRole("button", { name: "Campaign Map" }),
          "mobile portrait results Campaign Map"
        );
      }
    });
  }

  test("Ashen Outpost objectives do not cover the fortress focus area on desktop", async ({ page }) => {
    await page.setViewportSize({ width: 1366, height: 768 });
    await startAshenOutpostSkirmish(page, "Layout Ashen");
    await expect(page.getByTestId("battle-objectives")).toBeVisible();

    const fortressPoints = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      scene.cameraSystem.centerOn(scene.activeMap.enemyStart);
      scene.update(performance.now(), 200);
      const canvasBounds = scene.game.canvas.getBoundingClientRect();
      const camera = scene.cameras.main;
      return ["enemy_stronghold", "enemy_barracks", "watchtower"].map((buildingId) => {
        const building = scene.buildings.find(
          (entry: any) => entry.team === "enemy" && entry.definition.id === buildingId && entry.alive
        );
        if (!building) {
          throw new Error(`Missing ${buildingId}.`);
        }
        return {
          id: buildingId,
          x: canvasBounds.left + building.position.x - camera.scrollX,
          y: canvasBounds.top + building.position.y - camera.scrollY
        };
      });
    });

    const objectivesBox = await page.getByTestId("battle-objectives").boundingBox();
    expect(objectivesBox, "Ashen objectives panel has a layout box").not.toBeNull();
    if (!objectivesBox) {
      return;
    }
    for (const point of fortressPoints) {
      const covered =
        point.x >= objectivesBox.x &&
        point.x <= objectivesBox.x + objectivesBox.width &&
        point.y >= objectivesBox.y &&
        point.y <= objectivesBox.y + objectivesBox.height;
      expect(covered, `${point.id} should stay visible outside the objectives panel`).toBe(false);
    }
  });

  test("Ashen Outpost landmarks are scoutable under fog without HUD overlap", async ({ page }) => {
    await page.setViewportSize({ width: 1366, height: 768 });
    await startAshenOutpostSkirmish(page, "Scout Ashen");
    await expect(page.getByTestId("battle-objectives")).toContainText("Capture the Burned Shrine");

    const result = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }

      const playerUnits = scene.units.filter((unit: any) => unit.team === "player" && unit.alive);
      if (playerUnits.length === 0) {
        throw new Error("Expected player units for Ashen scouting coverage.");
      }

      const readHudRects = () =>
        Array.from(
          document.querySelectorAll<HTMLElement>(
            ".top-bar, [data-testid='battle-hero-panel'], .side-panel, [data-testid='battle-minimap'], [data-testid='battle-objectives'], [data-testid='battle-status'], .hint-line"
          )
        )
          .filter((element) => {
            const style = window.getComputedStyle(element);
            const rect = element.getBoundingClientRect();
            return style.display !== "none" && style.visibility !== "hidden" && rect.width > 0 && rect.height > 0;
          })
          .map((element) => {
            const rect = element.getBoundingClientRect();
            return {
              label: element.getAttribute("data-testid") ?? element.className,
              left: rect.left,
              right: rect.right,
              top: rect.top,
              bottom: rect.bottom
            };
          });

      const screenFor = (point: { x: number; y: number }) => {
        const canvasBounds = scene.game.canvas.getBoundingClientRect();
        const camera = scene.cameras.main;
        return {
          x: canvasBounds.left + point.x - camera.scrollX,
          y: canvasBounds.top + point.y - camera.scrollY
        };
      };

      const scoutPoint = (point: { x: number; y: number }) => {
        playerUnits.forEach((unit: any, index: number) => {
          const angle = (index / Math.max(1, playerUnits.length)) * Math.PI * 2;
          unit.setPosition(point.x + Math.cos(angle) * 28, point.y + Math.sin(angle) * 28);
          unit.moveTarget = undefined;
          unit.attackTargetId = undefined;
          unit.attackMove = false;
        });
        scene.cameraSystem.centerOn(point);
        scene.updateFogOfWar(0, true);
        scene.refreshBattleHud(0.11);
        const screen = screenFor(point);
        const coveredBy = readHudRects()
          .filter((rect) => screen.x >= rect.left && screen.x <= rect.right && screen.y >= rect.top && screen.y <= rect.bottom)
          .map((rect) => rect.label);
        return {
          screen,
          coveredBy
        };
      };

      scene.updateFogOfWar(0, true);
      const initialSnapshot = scene.createMinimapSnapshot();
      const initialMarkerIds = new Set(initialSnapshot.markers.map((marker: any) => marker.id));
      const enemyStronghold = scene.buildings.find((building: any) => building.team === "enemy" && building.definition.id === "enemy_stronghold");
      if (!enemyStronghold) {
        throw new Error("Expected Ashen enemy Stronghold.");
      }

      const captureSiteIds = ["burned_shrine", "west_supply_pyre", "south_iron_pit", "north_stone_scar"];
      const sites = captureSiteIds.map((siteId) => {
        const site = scene.captureSites.find((entry: any) => entry.definition.id === siteId);
        if (!site) {
          throw new Error(`Missing Ashen capture site: ${siteId}`);
        }
        const scout = scoutPoint(site.position);
        const markerIds = new Set(scene.createMinimapSnapshot().markers.map((marker: any) => marker.id));
        return {
          id: siteId,
          visible: Boolean(site.view?.visible),
          markerVisible: markerIds.has(site.id),
          coveredBy: scout.coveredBy
        };
      });

      const camps = scene.neutralCampLabels.map((camp: any) => {
        const scout = scoutPoint(camp.position);
        const markerIds = new Set(scene.createMinimapSnapshot().markers.map((marker: any) => marker.id));
        return {
          id: camp.id,
          labelVisible: Boolean(camp.label.visible),
          markerVisible: markerIds.has(camp.id),
          coveredBy: scout.coveredBy
        };
      });

      const fortressBuildings = ["enemy_stronghold", "enemy_barracks", "watchtower"].map((buildingId) => {
        const building = scene.buildings.find((entry: any) => entry.team === "enemy" && entry.definition.id === buildingId && entry.alive);
        if (!building) {
          throw new Error(`Missing Ashen fortress building: ${buildingId}`);
        }
        const scout = scoutPoint(building.position);
        const markerIds = new Set(scene.createMinimapSnapshot().markers.map((marker: any) => marker.id));
        return {
          id: buildingId,
          visible: Boolean(building.view?.visible),
          markerVisible: markerIds.has(building.id),
          coveredBy: scout.coveredBy
        };
      });

      return {
        fogEnabled: initialSnapshot.fog.enabled,
        hasFogCells: (initialSnapshot.fog.cells?.length ?? 0) > 0,
        enemyStrongholdHiddenAtStart: !initialMarkerIds.has(enemyStronghold.id),
        sites,
        camps,
        fortressBuildings
      };
    });

    expect(result.fogEnabled).toBe(true);
    expect(result.hasFogCells).toBe(true);
    expect(result.enemyStrongholdHiddenAtStart).toBe(true);
    for (const site of result.sites) {
      expect(site.visible, `${site.id} should become visible after scouting`).toBe(true);
      expect(site.markerVisible, `${site.id} should appear on the minimap after scouting`).toBe(true);
      expect(site.coveredBy, `${site.id} should not be covered by HUD while centered`).toEqual([]);
    }
    for (const camp of result.camps) {
      expect(camp.labelVisible, `${camp.id} label should become visible after scouting`).toBe(true);
      expect(camp.markerVisible, `${camp.id} should appear on the minimap after scouting`).toBe(true);
      expect(camp.coveredBy, `${camp.id} should not be covered by HUD while centered`).toEqual([]);
    }
    for (const building of result.fortressBuildings) {
      expect(building.visible, `${building.id} should become visible after scouting`).toBe(true);
      expect(building.markerVisible, `${building.id} should appear on the minimap after scouting`).toBe(true);
      expect(building.coveredBy, `${building.id} should not be covered by HUD while centered`).toEqual([]);
    }
  });
});
