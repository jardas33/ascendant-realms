import { expect, test, type Page } from "@playwright/test";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import {
  completeCinderfenVictory,
  completeCinderfenOverlookChoice,
  launchCinderfenCrossing,
  launchCinderfenWatch,
  seedCompletedCinderfenRouteCampaign,
  seedPostAshenCampaign,
  seedPostCinderfenCrossingCampaign
} from "../e2e/chapter2-helpers";
import { continueSavedCampaign, createHero, openFreshMainMenu, startNewCampaign } from "../e2e/shared-helpers";

type VisualViewport = {
  label: string;
  width: number;
  height: number;
};

type CaptureRecord = {
  group: string;
  title: string;
  fileName: string;
  viewport: string;
  note: string;
  retryUsed: boolean;
};

const OUTPUT_DIR = path.resolve(process.cwd(), "visual-qa", "latest");
const FULL_HD: VisualViewport = { label: "full-hd", width: 1920, height: 1080 };
const LAPTOP: VisualViewport = { label: "laptop", width: 1366, height: 768 };
const DESKTOP: VisualViewport = { label: "desktop", width: 1440, height: 900 };
const TABLET: VisualViewport = { label: "tablet", width: 1024, height: 768 };
const MOBILE: VisualViewport = { label: "mobile", width: 390, height: 844 };
const EXPECTED_SCREENSHOT_COUNT = 26;
const VISUAL_QA_GROUP_TIMEOUT_MS = 180_000;
const SCREENSHOT_TIMEOUT_MS = 45_000;
const SCREENSHOT_ATTEMPTS = 2;

const visualQaRecords: CaptureRecord[] = [];
const visualQaConsoleErrors: string[] = [];
let visualQaStartedAt = Date.now();

function describeError(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

function isTransientScreenshotError(error: unknown): boolean {
  const message = describeError(error);
  return message.includes("Timeout") || message.includes("timeout") || message.includes("page screenshot");
}

function viewportLabel(viewport: VisualViewport): string {
  return `${viewport.width}x${viewport.height} ${viewport.label}`;
}

function elapsedMs(): number {
  return Date.now() - visualQaStartedAt;
}

function attachConsoleCollector(page: Page, group: string): string[] {
  const consoleErrors: string[] = [];
  const recordError = (message: string) => {
    const entry = `[${group}] ${message}`;
    consoleErrors.push(entry);
    visualQaConsoleErrors.push(entry);
  };

  page.on("console", (message) => {
    if (message.type() === "error") {
      recordError(message.text());
    }
  });
  page.on("pageerror", (error) => {
    recordError(error.message);
  });

  return consoleErrors;
}

async function useViewport(page: Page, viewport: VisualViewport): Promise<void> {
  await page.setViewportSize({ width: viewport.width, height: viewport.height });
}

async function settleForScreenshot(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle", { timeout: 5_000 }).catch(() => undefined);
  await page.waitForTimeout(150);
}

async function takeScreenshotWithRetry(page: Page, group: string, fileName: string, viewport: VisualViewport): Promise<boolean> {
  let retryUsed = false;
  let lastError: unknown;

  for (let attempt = 1; attempt <= SCREENSHOT_ATTEMPTS; attempt += 1) {
    const attemptStartedAt = Date.now();
    console.log(
      `[visual-qa] START screenshot group="${group}" file="${fileName}" viewport="${viewportLabel(viewport)}" url="${page.url()}" elapsed=${elapsedMs()}ms attempt=${attempt}`
    );

    try {
      await settleForScreenshot(page);
      await page.screenshot({
        path: path.join(OUTPUT_DIR, fileName),
        fullPage: false,
        animations: "disabled",
        caret: "hide",
        timeout: SCREENSHOT_TIMEOUT_MS
      });
      console.log(
        `[visual-qa] DONE screenshot group="${group}" file="${fileName}" elapsed=${elapsedMs()}ms duration=${Date.now() - attemptStartedAt}ms retry=${retryUsed ? "yes" : "no"}`
      );
      return retryUsed;
    } catch (error) {
      lastError = error;
      console.warn(
        `[visual-qa] FAIL screenshot group="${group}" file="${fileName}" elapsed=${elapsedMs()}ms duration=${Date.now() - attemptStartedAt}ms error="${describeError(error)}"`
      );

      if (!isTransientScreenshotError(error) || attempt === SCREENSHOT_ATTEMPTS) {
        break;
      }

      retryUsed = true;
      console.warn(`[visual-qa] RETRY screenshot group="${group}" file="${fileName}" nextAttempt=${attempt + 1}`);
      await page.waitForLoadState("domcontentloaded", { timeout: 2_000 }).catch(() => undefined);
    }
  }

  throw new Error(
    `[visual-qa] screenshot ${fileName} in group ${group} failed after ${SCREENSHOT_ATTEMPTS} attempt(s): ${describeError(lastError)}`
  );
}

async function captureView(
  page: Page,
  group: string,
  title: string,
  fileName: string,
  viewport: VisualViewport,
  note: string
): Promise<void> {
  const retryUsed = await takeScreenshotWithRetry(page, group, fileName, viewport);
  visualQaRecords.push({
    group,
    title,
    fileName,
    viewport: viewportLabel(viewport),
    note,
    retryUsed
  });
}

async function expectBattleLoaded(page: Page): Promise<void> {
  await expect(page.getByTestId("battle-hud")).toBeVisible({ timeout: 30_000 });
  await expect(page.getByTestId("battle-resources")).toContainText("Crowns");
  await expect(page.getByTestId("battle-hero-panel")).toBeVisible();
  await expect(page.getByTestId("battle-minimap")).toBeVisible();
  await expect(page.getByTestId("minimap")).toBeVisible();
}

async function centerCaptureSite(page: Page, siteId: string, capture: boolean): Promise<void> {
  await page.evaluate(
    ({ siteId, capture }) => {
      const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const site = scene.captureSites.find((entry: any) => entry.definition.id === siteId);
      if (!site) {
        throw new Error(`Capture site ${siteId} was not found.`);
      }
      scene.cameraSystem.centerOn(site.position);
      if (capture) {
        const hook = (window as any).__ASCENDANT_TEST_HOOKS__?.captureSite;
        if (!hook) {
          throw new Error("Missing captureSite test hook.");
        }
        hook(siteId);
      }
      scene.update(performance.now(), 250);
      scene.refreshBattleHud?.(0);
    },
    { siteId, capture }
  );
}

async function triggerWatchPressureWarning(page: Page): Promise<void> {
  await centerCaptureSite(page, "watch_road_toll", true);
  await page.evaluate(() => {
    const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    scene.runtime.tick(36);
    scene.enemyPressureRuntime?.update();
    scene.refreshBattleHud?.(0);
  });
  await expect(page.getByTestId("battle-status")).toContainText("Enemy horns answer your advance");
}

async function triggerCrossingPressureWarning(page: Page): Promise<void> {
  await page.evaluate(() => {
    const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    scene.enemyPressureRuntime?.update();
    scene.update(performance.now(), 4500);
    scene.update(performance.now() + 31_000, 31_000);
    scene.enemyPressureRuntime?.update();
    scene.refreshBattleHud?.(0);
  });
  await expect(page.getByTestId("battle-status")).toContainText("Ashen scouts mark the center road");
}

async function forceBattleDefeat(page: Page): Promise<void> {
  await page.evaluate(() => {
    const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const objectiveId = scene.activeMap.scenario.objectives.playerBaseBuildingId;
    const target = scene.buildings.find(
      (building: any) => building.team === "player" && building.definition.id === objectiveId && building.alive
    );
    if (!target) {
      throw new Error(`Could not find player objective building ${objectiveId}.`);
    }
    target.takeDamage(target.maxHp + target.armor + 10_000);
    scene.checkEndConditions();
  });
  await expect(page.locator(".results-panel")).toBeVisible({ timeout: 15_000 });
}

async function writeIndex(records: CaptureRecord[], consoleErrors: string[]): Promise<void> {
  const viewportSummary = [...new Set(records.map((record) => record.viewport))].join(", ");
  const groupSummary = [...new Set(records.map((record) => record.group))].join(", ");
  const retryCount = records.filter((record) => record.retryUsed).length;
  const lines = [
    "# Ascendant Realms Visual QA Capture",
    "",
    `Generated: ${new Date().toISOString()}`,
    "",
    "Output folder: `visual-qa/latest/`",
    "",
    "## Summary",
    "",
    `- Screenshot count: ${records.length}`,
    `- Browser console error count: ${consoleErrors.length}`,
    `- Viewports covered: ${viewportSummary}`,
    `- Capture groups: ${groupSummary}`,
    `- Screenshot retries used: ${retryCount}`,
    "- Harness: `tests/visual-qa/visual-qa.spec.ts`",
    "",
    "## Captures",
    "",
    ...records.flatMap((record) => [
      `- ${record.title}`,
      `  - Group: \`${record.group}\``,
      `  - File: \`${record.fileName}\``,
      `  - Viewport: ${record.viewport}`,
      `  - Retry used: ${record.retryUsed ? "yes" : "no"}`,
      `  - Note: ${record.note}`
    ]),
    "",
    "## Console Errors",
    "",
    ...(consoleErrors.length === 0 ? ["None recorded."] : consoleErrors.map((error) => `- ${error}`)),
    "",
    "## Review Policy",
    "",
    "These screenshots are visual review artifacts only. They are not pixel-perfect baselines and are intentionally ignored by git."
  ];

  await writeFile(path.join(OUTPUT_DIR, "index.md"), `${lines.join("\n")}\n`, "utf8");
  console.log(
    `Visual QA wrote ${records.length} screenshot(s) across ${groupSummary} to ${OUTPUT_DIR}. Browser console errors: ${consoleErrors.length}. Screenshot retries: ${retryCount}.`
  );
}

test.describe("Ascendant Realms visual QA capture", () => {
  test.beforeAll(async () => {
    visualQaStartedAt = Date.now();
    visualQaRecords.length = 0;
    visualQaConsoleErrors.length = 0;
    await mkdir(OUTPUT_DIR, { recursive: true });
  });

  test.afterAll(async () => {
    await writeIndex(visualQaRecords, visualQaConsoleErrors);
    expect(visualQaRecords, "visual QA should preserve the full 26-screenshot review set").toHaveLength(
      EXPECTED_SCREENSHOT_COUNT
    );
    expect(visualQaConsoleErrors, "visual QA should not record browser console errors").toEqual([]);
  });

  test("captures menu, gallery, and inventory review views", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "menu-gallery-inventory";
    const consoleErrors = attachConsoleCollector(page, group);

    await useViewport(page, DESKTOP);
    await openFreshMainMenu(page);
    await expect(page.getByTestId("main-menu")).toBeVisible();
    await captureView(page, group, "Main menu", "main-menu-desktop.png", DESKTOP, "Desktop title screen and primary navigation.");

    await page.getByTestId("menu-asset-gallery").click();
    await expect(page.locator(".asset-gallery-card").first()).toBeVisible();
    await captureView(page, group, "Asset Gallery", "asset-gallery-desktop.png", DESKTOP, "Manual asset gallery and image-load status surface.");

    await useViewport(page, TABLET);
    await openFreshMainMenu(page);
    await expect(page.getByTestId("main-menu")).toBeVisible();
    await captureView(page, group, "Main menu tablet", "main-menu-tablet.png", TABLET, "Tablet menu composition check.");

    await useViewport(page, MOBILE);
    await openFreshMainMenu(page);
    await expect(page.getByTestId("main-menu")).toBeVisible();
    await captureView(page, group, "Main menu mobile", "main-menu-mobile.png", MOBILE, "Mobile menu crop and scroll check.");

    await useViewport(page, DESKTOP);
    await seedPostCinderfenCrossingCampaign(page);
    await page.getByTestId("menu-inventory").click();
    await expect(page.getByTestId("hero-inventory")).toBeVisible();
    await captureView(page, group, "Hero Inventory", "hero-inventory-desktop.png", DESKTOP, "Saved hero equipment, inventory, stats, and skill panel.");

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures tutorial review views", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "tutorial";
    const consoleErrors = attachConsoleCollector(page, group);

    await useViewport(page, DESKTOP);
    await openFreshMainMenu(page);
    await page.getByTestId("menu-tutorial").click();
    await expectBattleLoaded(page);
    await expect(page.getByTestId("tutorial-overlay")).toBeVisible();
    await captureView(page, group, "Tutorial launch", "tutorial-desktop.png", DESKTOP, "Proving Grounds tutorial overlay and battle HUD.");

    await useViewport(page, MOBILE);
    await openFreshMainMenu(page);
    await page.getByTestId("menu-tutorial").click();
    await expectBattleLoaded(page);
    await expect(page.getByTestId("tutorial-overlay")).toBeVisible();
    await captureView(page, group, "Tutorial launch mobile", "tutorial-mobile.png", MOBILE, "Mobile Proving Grounds overlay and battle HUD density.");

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures campaign map and skirmish setup review views", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "campaign-skirmish";
    const consoleErrors = attachConsoleCollector(page, group);

    await useViewport(page, DESKTOP);
    await seedPostAshenCampaign(page, { includeMalrecTrophy: true });
    await continueSavedCampaign(page);
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await captureView(page, group, "Campaign map", "campaign-map-desktop.png", DESKTOP, "Post-Ashen campaign map with Cinderfen route available.");

    await seedCompletedCinderfenRouteCampaign(page);
    await continueSavedCampaign(page);
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await captureView(page, group, "Campaign route complete", "campaign-route-complete-desktop.png", DESKTOP, "Completed Cinderfen route campaign map state.");

    await openFreshMainMenu(page);
    await page.getByTestId("menu-skirmish").click();
    await createHero(page, "Visual QA");
    await expect(page.getByTestId("skirmish-setup")).toBeVisible();
    await captureView(page, group, "Skirmish setup", "skirmish-setup-desktop.png", DESKTOP, "Skirmish setup map and difficulty selection.");

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures v0.83 campaign map rescue and private Lume launch views", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "v083-campaign-map-private-lume";
    const consoleErrors = attachConsoleCollector(page, group);

    await useViewport(page, FULL_HD);
    await startNewCampaign(page, "Visual v083");
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await captureView(
      page,
      group,
      "Campaign map rescue 1920",
      "v083-campaign-map-1920.png",
      FULL_HD,
      "Map-first campaign layout at 1920x1080 with selected node panel beside the map."
    );

    await useViewport(page, LAPTOP);
    await captureView(
      page,
      group,
      "Campaign map rescue 1366",
      "v083-campaign-map-1366.png",
      LAPTOP,
      "Map-first campaign layout at 1366x768; node cards should not overlap."
    );

    await useViewport(page, FULL_HD);
    await page.getByTestId("campaign-node-aether_well_ruins").click();
    await expect(page.getByTestId("campaign-start-node")).toBeDisabled();
    await captureView(
      page,
      group,
      "Locked Aether Well selected",
      "v083-aether-well-locked-1920.png",
      FULL_HD,
      "Locked Aether Well node selected with concise status and no normal launch access."
    );

    await useViewport(page, LAPTOP);
    await page.getByTestId("campaign-tab-stronghold").click();
    await expect(page.getByTestId("campaign-tab-panel-stronghold")).toBeVisible();
    await captureView(
      page,
      group,
      "Stronghold support tab",
      "v083-stronghold-tab-1366.png",
      LAPTOP,
      "Support content moved into tabs instead of burying the campaign map."
    );

    await useViewport(page, FULL_HD);
    await page.getByTestId("campaign-tab-map").click();
    await expect(page.getByTestId("campaign-private-playtest-tools")).toBeVisible();
    await captureView(
      page,
      group,
      "Private playtest launch tools",
      "v083-private-playtest-tools-1920.png",
      FULL_HD,
      "Package/dev private demo action is visible above the map and clearly marked no-save."
    );

    await page.getByTestId("campaign-private-lume-demo").click();
    await expectBattleLoaded(page);
    await expect(page.getByTestId("private-playtest-demo-warning")).toBeVisible();
    await captureView(
      page,
      group,
      "Private Lume demo HUD",
      "v083-private-lume-hud-1920.png",
      FULL_HD,
      "Private Aether Well Lume demo battle HUD with no-save warning and Lume objective row."
    );

    await centerCaptureSite(page, "west_stone_cut", true);
    await centerCaptureSite(page, "ford_toll", true);
    await expect(page.getByTestId("lume-network-status")).toContainText(/active/i);
    await captureView(
      page,
      group,
      "Private Lume demo linked ward active",
      "v083-private-lume-active-1920.png",
      FULL_HD,
      "Linked Ward activated in the private demo through the existing capture-site hook."
    );

    await useViewport(page, LAPTOP);
    await captureView(
      page,
      group,
      "Private Lume demo laptop HUD",
      "v083-private-lume-hud-1366.png",
      LAPTOP,
      "Private demo HUD at 1366x768 with warning and Lume row still readable."
    );

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures Cinderfen Crossing battle and victory review views", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "cinderfen-crossing";
    const consoleErrors = attachConsoleCollector(page, group);

    await seedPostAshenCampaign(page);
    await continueSavedCampaign(page);
    await page.getByTestId("campaign-node-cinderfen_overlook").click();
    await completeCinderfenOverlookChoice(page, "aid_marsh_refugees", "Aid the Marsh Refugees chosen");
    await launchCinderfenCrossing(page);
    await captureView(page, group, "Cinderfen Crossing launch", "cinderfen-crossing-desktop.png", DESKTOP, "Cinderfen Crossing initial battle view.");
    await useViewport(page, TABLET);
    await captureView(page, group, "Cinderfen Crossing tablet", "cinderfen-crossing-tablet.png", TABLET, "Tablet Cinderfen battle HUD density.");
    await useViewport(page, DESKTOP);
    await centerCaptureSite(page, "cinder_crossing", true);
    await captureView(page, group, "Cinderfen Shrine captured", "cinderfen-crossing-shrine-desktop.png", DESKTOP, "Cinder Shrine centered after capture-site hook.");
    await triggerCrossingPressureWarning(page);
    await captureView(page, group, "Cinderfen Crossing pressure warning", "cinderfen-crossing-pressure-desktop.png", DESKTOP, "Causeway pressure status warning after Cinder Shrine capture.");
    await completeCinderfenVictory(page);
    await captureView(page, group, "Results victory", "results-victory-desktop.png", DESKTOP, "Cinderfen Crossing victory rewards and objective summary.");

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures Cinderfen Watch battle and defeat review views", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "cinderfen-watch";
    const consoleErrors = attachConsoleCollector(page, group);

    await seedPostCinderfenCrossingCampaign(page);
    await continueSavedCampaign(page);
    await launchCinderfenWatch(page);
    await captureView(page, group, "Cinderfen Watch launch", "cinderfen-watch-desktop.png", DESKTOP, "Cinderfen Watch initial battle view.");
    await triggerWatchPressureWarning(page);
    await captureView(page, group, "Cinderfen Watch pressure warning", "cinderfen-watch-pressure-desktop.png", DESKTOP, "Watch Road pressure status warning visible.");
    await forceBattleDefeat(page);
    await captureView(page, group, "Results defeat", "results-defeat-desktop.png", DESKTOP, "Cinderfen Watch defeat results and guidance tips.");

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });
});
