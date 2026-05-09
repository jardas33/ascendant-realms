import { expect, test, type Page } from "@playwright/test";
import { launchCinderfenWatch, seedPostCinderfenCrossingCampaign } from "./chapter2-helpers";
import { createHero, openFreshMainMenu } from "./shared-helpers";

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

async function expectBattleLoaded(page: Page): Promise<void> {
  await expect(page.getByTestId("battle-hud")).toBeVisible({ timeout: 30_000 });
  await expect(page.getByTestId("battle-resources")).toContainText("Crowns");
  await expect(page.getByTestId("battle-hero-panel")).toBeVisible();
  await expect(page.getByTestId("battle-minimap")).toBeVisible();
  await expect(page.getByTestId("minimap")).toBeVisible();
}

async function captureSiteWithHook(page: Page, siteId: string): Promise<any> {
  return page.evaluate((targetSiteId) => {
    const hook = (window as any).__ASCENDANT_TEST_HOOKS__?.captureSite;
    if (!hook) {
      throw new Error("Missing captureSite test hook.");
    }
    return hook(targetSiteId);
  }, siteId);
}

async function readPressureState(page: Page): Promise<{
  mode: string | undefined;
  campaignNodeId: string | undefined;
  mapId: string | undefined;
  requestPressurePlanId: string | undefined;
  statsPressurePlanId: string | undefined;
  triggeredStageIds: string[];
  completedStageIds: string[];
  pressureWarningsShown: number;
  pressureReinforcementApplied: boolean;
  status: string;
}> {
  return page.evaluate(() => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    return {
      mode: scene.launch.request.mode,
      campaignNodeId: scene.launch.request.campaignNodeId,
      mapId: scene.activeMap.id,
      requestPressurePlanId: scene.launch.request.enemyPressurePlanId,
      statsPressurePlanId: scene.runtime.stats.enemyPressurePlanId,
      triggeredStageIds: [...(scene.runtime.stats.enemyPressureTriggeredStageIds ?? [])],
      completedStageIds: [...(scene.runtime.stats.enemyPressureCompletedStageIds ?? [])],
      pressureWarningsShown: scene.runtime.stats.enemyPressureWarningsShown ?? 0,
      pressureReinforcementApplied: scene.runtime.stats.enemyPressureReinforcementApplied ?? false,
      status: scene.statusMessage
    };
  });
}

async function advancePressureRuntime(page: Page, seconds: number): Promise<string> {
  return page.evaluate((elapsedSeconds) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    scene.runtime.tick(elapsedSeconds);
    scene.enemyPressureRuntime?.update();
    scene.refreshBattleHud?.(0);
    return scene.statusMessage;
  }, seconds);
}

async function showNormalStatusMessage(page: Page, message: string): Promise<string> {
  return page.evaluate((statusMessage) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    scene.showMessage(statusMessage);
    scene.refreshBattleHud?.(0);
    return scene.statusMessage;
  }, message);
}

test.describe("Enemy Strategic Pressure V1 browser coverage", () => {
  test("campaign Cinderfen Watch shows scoped pressure warning after Watch Road capture", async ({ page }) => {
    attachConsoleFailure(page);
    await seedPostCinderfenCrossingCampaign(page);

    await page.getByTestId("menu-continue-campaign").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await launchCinderfenWatch(page);

    let pressureState = await readPressureState(page);
    expect(pressureState).toMatchObject({
      mode: "campaign_node",
      campaignNodeId: "cinderfen_watch",
      mapId: "cinderfen_watchpost",
      requestPressurePlanId: "ashen_watch_captain_pressure",
      statsPressurePlanId: "ashen_watch_captain_pressure",
      triggeredStageIds: [],
      pressureWarningsShown: 0,
      pressureReinforcementApplied: false
    });

    const capture = await captureSiteWithHook(page, "watch_road_toll");
    expect(capture).toMatchObject({
      siteId: "watch_road_toll",
      owner: "player",
      completedObjectiveIds: expect.arrayContaining(["capture_watch_road"])
    });
    pressureState = await readPressureState(page);
    expect(pressureState.triggeredStageIds).toEqual(expect.arrayContaining(["watch_road_response"]));
    expect(pressureState.completedStageIds).toEqual(expect.arrayContaining(["watch_road_response"]));
    expect(pressureState.pressureWarningsShown).toBe(1);

    const pressureWarning = "Enemy horns answer your advance. Expect faster pressure on the raised road.";
    expect(await advancePressureRuntime(page, 36)).toBe(pressureWarning);
    await expect(page.getByTestId("battle-status")).toContainText(pressureWarning);
    expect(await showNormalStatusMessage(page, "Generic battle update")).toBe(pressureWarning);
    await expect(page.getByTestId("battle-status")).toContainText(
      pressureWarning
    );
    pressureState = await readPressureState(page);
    expect(pressureState.triggeredStageIds).toEqual(expect.arrayContaining(["watch_road_response", "watch_road_reinforcement"]));
    expect(pressureState.completedStageIds).toEqual(expect.arrayContaining(["watch_road_response", "watch_road_reinforcement"]));
    expect(pressureState.pressureWarningsShown).toBe(2);
    expect(pressureState.pressureReinforcementApplied).toBe(false);
    await expectBattleLoaded(page);
  });

  test("tutorial and skirmish launches do not activate pressure plans", async ({ page }) => {
    attachConsoleFailure(page);
    await openFreshMainMenu(page);

    await page.getByTestId("menu-tutorial").click();
    await expectBattleLoaded(page);
    await expect(page.getByTestId("tutorial-overlay")).toBeVisible();
    let pressureState = await readPressureState(page);
    expect(pressureState.mode).toBe("tutorial");
    expect(pressureState.requestPressurePlanId).toBeUndefined();
    expect(pressureState.statsPressurePlanId).toBeUndefined();
    expect(pressureState.triggeredStageIds).toEqual([]);
    expect(pressureState.pressureWarningsShown).toBe(0);
    await expect(page.getByTestId("battle-status")).not.toContainText("The Watch Captain tightens the road guard.");

    await openFreshMainMenu(page);
    await page.getByTestId("menu-skirmish").click();
    await createHero(page, "Pressure Skirmish Guard");
    await page.getByTestId("setup-map-cinderfen_watchpost").click();
    await page.getByTestId("setup-difficulty-normal").click();
    await page.getByTestId("setup-start-battle").click();
    await expectBattleLoaded(page);

    pressureState = await readPressureState(page);
    expect(pressureState.mode).toBe("skirmish");
    expect(pressureState.mapId).toBe("cinderfen_watchpost");
    expect(pressureState.requestPressurePlanId).toBeUndefined();
    expect(pressureState.statsPressurePlanId).toBeUndefined();
    expect(pressureState.triggeredStageIds).toEqual([]);

    await captureSiteWithHook(page, "watch_road_toll");
    await expect(page.getByTestId("battle-status")).not.toContainText("The Watch Captain tightens the road guard.");
    pressureState = await readPressureState(page);
    expect(pressureState.triggeredStageIds).toEqual([]);
    expect(pressureState.pressureWarningsShown).toBe(0);
  });
});
