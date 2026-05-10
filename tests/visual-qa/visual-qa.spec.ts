import { expect, test, type Page } from "@playwright/test";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import {
  completeCinderfenOverlookChoice,
  launchCinderfenCrossing,
  launchCinderfenWatch,
  seedPostAshenCampaign,
  seedPostCinderfenCrossingCampaign
} from "../e2e/chapter2-helpers";
import { continueSavedCampaign, createHero, openFreshMainMenu } from "../e2e/shared-helpers";

type VisualViewport = {
  label: string;
  width: number;
  height: number;
};

type CaptureRecord = {
  title: string;
  fileName: string;
  viewport: string;
  note: string;
};

const OUTPUT_DIR = path.resolve(process.cwd(), "visual-qa", "latest");
const DESKTOP: VisualViewport = { label: "desktop", width: 1440, height: 900 };
const TABLET: VisualViewport = { label: "tablet", width: 1024, height: 768 };
const MOBILE: VisualViewport = { label: "mobile", width: 390, height: 844 };

function attachConsoleCollector(page: Page, consoleErrors: string[]): void {
  page.on("console", (message) => {
    if (message.type() === "error") {
      consoleErrors.push(message.text());
    }
  });
  page.on("pageerror", (error) => {
    consoleErrors.push(error.message);
  });
}

async function useViewport(page: Page, viewport: VisualViewport): Promise<void> {
  await page.setViewportSize({ width: viewport.width, height: viewport.height });
}

async function settleForScreenshot(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle").catch(() => undefined);
  await page.waitForTimeout(150);
}

async function captureView(
  page: Page,
  records: CaptureRecord[],
  title: string,
  fileName: string,
  viewport: VisualViewport,
  note: string
): Promise<void> {
  await settleForScreenshot(page);
  await page.screenshot({
    path: path.join(OUTPUT_DIR, fileName),
    fullPage: false
  });
  records.push({
    title,
    fileName,
    viewport: `${viewport.width}x${viewport.height} ${viewport.label}`,
    note
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

async function writeIndex(records: CaptureRecord[], consoleErrors: string[]): Promise<void> {
  const lines = [
    "# Ascendant Realms Visual QA Capture",
    "",
    `Generated: ${new Date().toISOString()}`,
    "",
    "Output folder: `visual-qa/latest/`",
    "",
    "## Captures",
    "",
    ...records.flatMap((record) => [
      `- ${record.title}`,
      `  - File: \`${record.fileName}\``,
      `  - Viewport: ${record.viewport}`,
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
}

test.describe("Ascendant Realms visual QA capture", () => {
  test("captures the current menu, campaign, tutorial, skirmish, and Cinderfen battle views", async ({ page }) => {
    test.setTimeout(120_000);
    await mkdir(OUTPUT_DIR, { recursive: true });
    const records: CaptureRecord[] = [];
    const consoleErrors: string[] = [];
    attachConsoleCollector(page, consoleErrors);

    await useViewport(page, DESKTOP);
    await openFreshMainMenu(page);
    await expect(page.getByTestId("main-menu")).toBeVisible();
    await captureView(page, records, "Main menu", "main-menu-desktop.png", DESKTOP, "Desktop title screen and primary navigation.");

    await useViewport(page, TABLET);
    await openFreshMainMenu(page);
    await expect(page.getByTestId("main-menu")).toBeVisible();
    await captureView(page, records, "Main menu tablet", "main-menu-tablet.png", TABLET, "Tablet menu composition check.");

    await useViewport(page, MOBILE);
    await openFreshMainMenu(page);
    await expect(page.getByTestId("main-menu")).toBeVisible();
    await captureView(page, records, "Main menu mobile", "main-menu-mobile.png", MOBILE, "Mobile menu crop and scroll check.");

    await useViewport(page, DESKTOP);
    await openFreshMainMenu(page);
    await page.getByTestId("menu-tutorial").click();
    await expectBattleLoaded(page);
    await expect(page.getByTestId("tutorial-overlay")).toBeVisible();
    await captureView(page, records, "Tutorial launch", "tutorial-desktop.png", DESKTOP, "Proving Grounds tutorial overlay and battle HUD.");

    await seedPostAshenCampaign(page, { includeMalrecTrophy: true });
    await continueSavedCampaign(page);
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await captureView(page, records, "Campaign map", "campaign-map-desktop.png", DESKTOP, "Post-Ashen campaign map with Cinderfen route available.");

    await openFreshMainMenu(page);
    await page.getByTestId("menu-skirmish").click();
    await createHero(page, "Visual QA");
    await expect(page.getByTestId("skirmish-setup")).toBeVisible();
    await captureView(page, records, "Skirmish setup", "skirmish-setup-desktop.png", DESKTOP, "Skirmish setup map and difficulty selection.");

    await seedPostAshenCampaign(page);
    await continueSavedCampaign(page);
    await page.getByTestId("campaign-node-cinderfen_overlook").click();
    await completeCinderfenOverlookChoice(page, "aid_marsh_refugees", "Aid the Marsh Refugees chosen");
    await launchCinderfenCrossing(page);
    await captureView(page, records, "Cinderfen Crossing launch", "cinderfen-crossing-desktop.png", DESKTOP, "Cinderfen Causeway initial battle view.");
    await centerCaptureSite(page, "cinder_crossing", true);
    await captureView(page, records, "Cinderfen Shrine captured", "cinderfen-crossing-shrine-desktop.png", DESKTOP, "Cinder Shrine centered after capture-site hook.");

    await seedPostCinderfenCrossingCampaign(page);
    await continueSavedCampaign(page);
    await launchCinderfenWatch(page);
    await captureView(page, records, "Cinderfen Watch launch", "cinderfen-watch-desktop.png", DESKTOP, "Cinderfen Watchpost initial battle view.");
    await triggerWatchPressureWarning(page);
    await captureView(page, records, "Cinderfen Watch pressure warning", "cinderfen-watch-pressure-desktop.png", DESKTOP, "Watch Road pressure status warning visible.");

    await writeIndex(records, consoleErrors);
    expect(consoleErrors, "visual QA should not record browser console errors").toEqual([]);
  });
});
