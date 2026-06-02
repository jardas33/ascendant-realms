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
import { clickReady, continueSavedCampaign, createHero, openFreshMainMenu, seedCampaignSave, startNewCampaign } from "../e2e/shared-helpers";

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
  durationMs: number;
};

const OUTPUT_DIR = path.resolve(process.cwd(), "visual-qa", "latest");
const FULL_HD: VisualViewport = { label: "full-hd", width: 1920, height: 1080 };
const WIDE_DESKTOP: VisualViewport = { label: "wide-desktop", width: 1600, height: 900 };
const LAPTOP: VisualViewport = { label: "laptop", width: 1366, height: 768 };
const DESKTOP: VisualViewport = { label: "desktop", width: 1440, height: 900 };
const TABLET: VisualViewport = { label: "tablet", width: 1024, height: 768 };
const MOBILE: VisualViewport = { label: "mobile", width: 390, height: 844 };
const EXPECTED_SCREENSHOT_COUNT = 213;
const VISUAL_QA_GROUP_TIMEOUT_MS = 900_000;
const VISUAL_QA_BATTLE_LOAD_TIMEOUT_MS = 90_000;
const SCREENSHOT_TIMEOUT_MS = 45_000;
const SCREENSHOT_ATTEMPTS = 1;
const VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS = {
  allowTargetGoneAfterClick: true,
  attempts: 1,
  domFallbackTimeoutMs: 2_000,
  normalClickTimeoutMs: 1_500
} as const;

const V0103_PERFORMANCE_VISUAL_SCENARIOS = [
  ["perf_battle_baseline", "battle", "v0103-perf-battle-baseline.png", "Ordinary private battle baseline with profiler-compatible counters."],
  ["perf_campaign_map_interaction", "campaign", "v0103-perf-campaign-map-interaction.png", "Campaign map interaction sample from the Performance Lab."],
  ["perf_fog_heavy_camera", "battle", "v0103-perf-fog-heavy-camera.png", "Fog-heavy camera posture with minimap visible."],
  ["perf_label_heavy_site_cluster", "battle", "v0103-perf-label-heavy-site-cluster.png", "Capture-site label and ring density sample."],
  ["perf_large_unit_cluster", "battle", "v0103-perf-large-unit-cluster.png", "Dense local unit cluster using existing unit types only."],
  ["perf_lume_activation_pulse", "battle", "v0103-perf-lume-activation-pulse.png", "Lume activation pulse and tracker posture."],
  ["perf_lume_always", "battle", "v0103-perf-lume-always.png", "Explicit Always-visible Lume inspection posture."],
  ["perf_lume_auto", "battle", "v0103-perf-lume-auto.png", "Default Auto Lume overlay with stable links quieter."],
  ["perf_lume_contested_severed", "battle", "v0103-perf-lume-contested-severed.png", "Lume severed transition sample with hostile marker."],
  ["perf_lume_hidden", "battle", "v0103-perf-lume-hidden.png", "Hidden Lume overlay posture."],
  ["perf_minimap_interaction", "battle", "v0103-perf-minimap-interaction.png", "Minimap interaction and camera-focus sample."],
  ["perf_notification_heavy", "battle", "v0103-perf-notification-heavy.png", "Notification-priority sample with deduped status row."],
  ["perf_selected_command_hall", "battle", "v0103-perf-selected-command-hall.png", "Selected Command Hall command panel sample."],
  ["perf_selected_hero", "battle", "v0103-perf-selected-hero.png", "Selected hero HUD and command posture."],
  ["perf_selected_squad", "battle", "v0103-perf-selected-squad.png", "Selected squad summary and command posture."],
  ["perf_selected_worker", "battle", "v0103-perf-selected-worker.png", "Selected Worker command posture."]
] as const;

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

async function takeScreenshotWithRetry(
  page: Page,
  group: string,
  fileName: string,
  viewport: VisualViewport
): Promise<{ retryUsed: boolean; durationMs: number }> {
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
      const durationMs = Date.now() - attemptStartedAt;
      console.log(
        `[visual-qa] DONE screenshot group="${group}" file="${fileName}" elapsed=${elapsedMs()}ms duration=${durationMs}ms retry=${retryUsed ? "yes" : "no"}`
      );
      return { retryUsed, durationMs };
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
  const { retryUsed, durationMs } = await takeScreenshotWithRetry(page, group, fileName, viewport);
  visualQaRecords.push({
    group,
    title,
    fileName,
    viewport: viewportLabel(viewport),
    note,
    retryUsed,
    durationMs
  });
}

async function expectBattleLoaded(page: Page, context = "visual QA battle loaded"): Promise<void> {
  await expect(page.getByTestId("battle-hud"), `${context}: battle HUD`).toBeVisible({
    timeout: VISUAL_QA_BATTLE_LOAD_TIMEOUT_MS
  });
  await expect(page.getByTestId("battle-resources"), `${context}: resources`).toContainText("Crowns", {
    timeout: VISUAL_QA_BATTLE_LOAD_TIMEOUT_MS
  });
  await expect(page.getByTestId("battle-hero-panel"), `${context}: hero panel`).toBeVisible({
    timeout: VISUAL_QA_BATTLE_LOAD_TIMEOUT_MS
  });
  await expect(page.getByTestId("battle-minimap"), `${context}: minimap shell`).toBeVisible({
    timeout: VISUAL_QA_BATTLE_LOAD_TIMEOUT_MS
  });
  await expect(page.getByTestId("minimap"), `${context}: minimap`).toBeVisible({
    timeout: VISUAL_QA_BATTLE_LOAD_TIMEOUT_MS
  });
  await expect(page.locator("canvas"), `${context}: Phaser canvas`).toBeVisible({
    timeout: VISUAL_QA_BATTLE_LOAD_TIMEOUT_MS
  });
  await page.waitForFunction(
    () => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      return Boolean(scene?.scene.isActive() && scene.hero && scene.activeMap && scene.runtime && scene.game?.canvas);
    },
    undefined,
    { timeout: VISUAL_QA_BATTLE_LOAD_TIMEOUT_MS }
  );
}

async function launchPublicSkirmishBattle(page: Page, heroName: string): Promise<void> {
  await seedCampaignSave(page, { hero: { heroName } });
  await clickReady(page.getByTestId("menu-skirmish"), `${heroName} skirmish menu`);
  await expect(page.getByTestId("skirmish-setup")).toBeVisible();
  await clickReady(page.getByTestId("setup-start-battle"), `${heroName} skirmish start battle`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
  await expectBattleLoaded(page, `${heroName} skirmish battle`);
}

async function openPrivatePlaytestHub(page: Page): Promise<void> {
  await openFreshMainMenu(page);
  await clickReady(page.getByTestId("menu-playtest-hub"), "visual QA open private playtest hub");
  await expect(page.getByTestId("playtest-hub")).toBeVisible();
}

async function launchPrivateHudScenario(page: Page, scenarioId: string): Promise<void> {
  await page.getByTestId(`playtest-scenario-${scenarioId}`).scrollIntoViewIfNeeded();
  await clickReady(
    page.getByTestId(`playtest-scenario-${scenarioId}`),
    `visual QA launch private HUD scenario ${scenarioId}`,
    VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS
  );
  await expectBattleLoaded(page, `visual QA private HUD scenario ${scenarioId}`);
}

async function setPrivateHudDensity(page: Page, mode: "minimal" | "standard" | "debug"): Promise<void> {
  await page.getByTestId(`hud-density-${mode}`).click();
  await expect(page.getByTestId(`battle-hud-density-${mode}`)).toBeVisible();
}

async function returnToPrivateHub(page: Page): Promise<void> {
  await clickReady(page.getByTestId("private-hub-exit"), "visual QA return to private playtest hub");
  await expect(page.getByTestId("playtest-hub")).toBeVisible();
}

async function showArtSlotDiagnostics(page: Page): Promise<void> {
  await page.evaluate(() => {
    const api = (window as any).__ASCENDANT_RUNTIME_ART_SLOTS__;
    if (!api?.showDiagnostics()) {
      throw new Error("Runtime art slot diagnostics API was not enabled.");
    }
  });
  await expect(page.getByTestId("art-slot-diagnostics-panel")).toBeVisible();
}

async function hideArtSlotDiagnostics(page: Page): Promise<void> {
  await page.evaluate(() => {
    (window as any).__ASCENDANT_RUNTIME_ART_SLOTS__?.hideDiagnostics();
  });
  await expect(page.getByTestId("art-slot-diagnostics-panel")).toBeHidden();
}

async function enableArtSlotMockMode(page: Page): Promise<void> {
  await page.evaluate(() => {
    const api = (window as any).__ASCENDANT_RUNTIME_ART_SLOTS__;
    if (!api?.enableMockMode()) {
      throw new Error("Runtime art slot mock mode was not enabled.");
    }
  });
  await expect(page.locator("html")).toHaveAttribute("data-runtime-art-mock", "true");
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

async function stageV086BattlefieldShell(page: Page): Promise<void> {
  await page.evaluate(() => {
    const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const commandHall = scene.buildings.find(
      (building: any) => building.alive && building.team === "player" && building.definition.id === "command_hall"
    );
    const site = scene.captureSites.find((entry: any) => entry.definition.id === "cinder_crossing") ?? scene.captureSites[0];
    if (!commandHall || !site) {
      throw new Error("Missing Command Hall or capture site for v0.86 shell staging.");
    }
    const hook = (window as any).__ASCENDANT_TEST_HOOKS__?.captureSite;
    if (hook) {
      hook(site.definition.id);
    }
    scene.selectionSystem.setSelection([commandHall]);
    scene.cameraSystem.centerOn(site.position);
    scene.update(performance.now(), 250);
    scene.refreshBattleHud?.(0);
  });
  await expect(page.getByTestId("selection-side-panel")).toContainText("Command Hall");
  await expect(page.getByTestId("command-train-worker")).toBeVisible();
  await expect(page.getByTestId("battle-minimap")).toBeVisible();
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

async function expectNoVisibleHorizontalOverflow(page: Page, label: string): Promise<void> {
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
          Number(style.opacity || "1") <= 0 ||
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
            text: (element.textContent ?? "").trim().replace(/\s+/g, " ").slice(0, 90)
          };
        }
        return undefined;
      })
      .filter(Boolean)
      .slice(0, 10);
    return { viewportWidth, offenders };
  });

  expect(result.offenders, `${label} should not overflow ${result.viewportWidth}px viewport width`).toEqual([]);
}

async function expectNoKeyCardTextOverflow(page: Page, selectors: string[], label: string): Promise<void> {
  const offenders = await page.evaluate((selectorList) => {
    const roots = selectorList.flatMap((selector) => Array.from(document.querySelectorAll<HTMLElement>(selector)));
    return roots
      .map((element) => {
        const style = window.getComputedStyle(element);
        const rect = element.getBoundingClientRect();
        const overflowX = style.overflowX;
        if (
          style.display === "none" ||
          style.visibility === "hidden" ||
          rect.width === 0 ||
          rect.height === 0 ||
          overflowX === "auto" ||
          overflowX === "scroll"
        ) {
          return undefined;
        }
        if (element.scrollWidth > element.clientWidth + 3) {
          return {
            selector: selectorList.find((selector) => element.matches(selector)) ?? element.tagName.toLowerCase(),
            testId: element.getAttribute("data-testid") ?? "",
            className: String(element.className),
            clientWidth: element.clientWidth,
            scrollWidth: element.scrollWidth,
            text: (element.textContent ?? "").trim().replace(/\s+/g, " ").slice(0, 90)
          };
        }
        return undefined;
      })
      .filter(Boolean)
      .slice(0, 10);
  }, selectors);

  expect(offenders, `${label} key card text should stay inside card widths`).toEqual([]);
}

async function expectNoCampaignNodeOverlap(page: Page, label: string): Promise<void> {
  const overlaps = await page.evaluate(() => {
    const nodes = Array.from(document.querySelectorAll<HTMLElement>(".campaign-map-grid .campaign-node"))
      .filter((node) => {
        const style = window.getComputedStyle(node);
        const rect = node.getBoundingClientRect();
        return style.display !== "none" && style.visibility !== "hidden" && rect.width > 0 && rect.height > 0;
      })
      .map((node) => {
        const rect = node.getBoundingClientRect();
        return {
          id: node.dataset.campaignNode ?? node.getAttribute("data-testid") ?? "",
          left: rect.left,
          right: rect.right,
          top: rect.top,
          bottom: rect.bottom
        };
      });
    const pairs: string[] = [];
    for (let index = 0; index < nodes.length; index += 1) {
      for (let compare = index + 1; compare < nodes.length; compare += 1) {
        const first = nodes[index];
        const second = nodes[compare];
        const width = Math.min(first.right, second.right) - Math.max(first.left, second.left);
        const height = Math.min(first.bottom, second.bottom) - Math.max(first.top, second.top);
        if (width > 2 && height > 2) {
          pairs.push(`${first.id} overlaps ${second.id} by ${Math.round(width)}x${Math.round(height)}`);
        }
      }
    }
    return pairs;
  });

  expect(overlaps, `${label} campaign nodes should not overlap`).toEqual([]);
}

async function expectCampaignPrimaryActionAboveFold(page: Page, label: string): Promise<void> {
  const result = await page.getByTestId("campaign-start-node").evaluate((button) => {
    const main = document.querySelector("main");
    const rect = button.getBoundingClientRect();
    return {
      top: rect.top,
      bottom: rect.bottom,
      viewportHeight: window.innerHeight,
      mainScrollTop: main?.scrollTop ?? 0,
      visible: rect.width > 0 && rect.height > 0
    };
  });
  expect(result.visible, `${label} primary mission action visible`).toBe(true);
  expect(result.mainScrollTop, `${label} primary mission action should not need default page scroll`).toBe(0);
  expect(result.top, `${label} primary mission action top`).toBeGreaterThanOrEqual(-2);
  expect(result.bottom, `${label} primary mission action bottom`).toBeLessThanOrEqual(result.viewportHeight + 2);
}

async function expectResultsPrimaryActionsAboveFold(page: Page, label: string): Promise<void> {
  const selector = ".results-primary-actions, .private-demo-primary-actions";
  const result = await page.locator(selector).first().evaluate((actions) => {
    const main = document.querySelector("main");
    const rect = actions.getBoundingClientRect();
    return {
      top: rect.top,
      bottom: rect.bottom,
      viewportHeight: window.innerHeight,
      mainScrollTop: main?.scrollTop ?? 0,
      visible: rect.width > 0 && rect.height > 0
    };
  });
  expect(result.visible, `${label} Results primary actions visible`).toBe(true);
  expect(result.mainScrollTop, `${label} Results primary actions should not need page scroll`).toBe(0);
  expect(result.top, `${label} Results action top`).toBeGreaterThanOrEqual(-2);
  expect(result.bottom, `${label} Results action bottom`).toBeLessThanOrEqual(result.viewportHeight + 2);
}

async function expectBattleHudAcceptance(page: Page, label: string): Promise<void> {
  await expectBattleLoaded(page);
  if ((await page.getByTestId("battle-objectives").count()) > 0) {
    await expect(page.getByTestId("battle-objectives"), `${label} objective tracker`).toBeVisible();
  } else {
    await expect(page.getByTestId("battle-status"), `${label} battle status fallback`).toBeVisible();
  }
  await expect(page.getByTestId("battle-minimap"), `${label} minimap shell`).toBeVisible();
  await expect(page.getByTestId("minimap"), `${label} minimap canvas`).toBeVisible();
  await expectNoVisibleHorizontalOverflow(page, `${label} battle HUD`);
  await expectNoKeyCardTextOverflow(
    page,
    [".top-bar", "[data-testid='battle-objectives']", ".side-panel", "[data-testid='battle-minimap']", "[data-testid='battle-hero-panel']"],
    `${label} battle HUD`
  );
}

async function expectPrivateDemoControlsPosture(page: Page, expectedVisible: boolean, label: string): Promise<void> {
  const controls = page.getByTestId("private-demo-actions");
  const finish = page.getByTestId("private-demo-finish");
  if (expectedVisible) {
    await expect(controls, `${label} private demo controls`).toBeVisible();
    await expect(page.getByTestId("private-playtest-demo-warning"), `${label} private demo warning`).toBeVisible();
    return;
  }
  await expect(controls, `${label} private demo controls should be absent`).toHaveCount(0);
  await expect(finish, `${label} private demo finish should be absent`).toHaveCount(0);
}

async function expectLumeControlsAbsent(page: Page, label: string): Promise<void> {
  await expect(page.getByTestId("lume-visibility-controls"), `${label} Lume controls should be absent`).toHaveCount(0);
}

async function selectFirstPlayerArmy(page: Page): Promise<void> {
  await page.evaluate(() => {
    const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const units = scene.units.filter((unit: any) => unit.team === "player" && unit.alive).slice(0, 4);
    if (units.length === 0) {
      throw new Error("No player units available for visual QA selection.");
    }
    scene.selectionSystem.setSelection(units);
    scene.cameraSystem.centerOn(units[0].position);
    scene.refreshBattleHud?.(0);
  });
  await expect(page.getByTestId("selection-side-panel")).toBeVisible();
  await expect(page.getByTestId("selected-role-summary")).toBeVisible();
}

async function selectCommandHall(page: Page): Promise<void> {
  await page.evaluate(() => {
    const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const commandHall = scene.buildings.find(
      (building: any) => building.alive && building.team === "player" && building.definition.id === "command_hall"
    );
    if (!commandHall) {
      throw new Error("Missing player Command Hall.");
    }
    scene.selectionSystem.setSelection([commandHall]);
    scene.cameraSystem.centerOn(commandHall.position);
    scene.refreshBattleHud?.(0);
  });
  await expect(page.getByTestId("selection-side-panel")).toContainText("Command Hall");
}

async function stageContestedCaptureSite(page: Page, siteId: string): Promise<void> {
  await page.evaluate((requestedSiteId) => {
    const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const site = scene.captureSites.find((entry: any) => entry.definition.id === requestedSiteId) ?? scene.captureSites[0];
    if (!site) {
      throw new Error("Missing capture site for visual QA contested state.");
    }
    site.owner = "player";
    site.team = "player";
    site.capturingTeam = "enemy";
    site.captureProgress = 0.42;
    site.updateVisuals?.();
    scene.selectionSystem.setSelection([site]);
    scene.cameraSystem.centerOn(site.position);
    scene.refreshBattleHud?.(0);
  }, siteId);
  await expect(page.getByTestId("selected-resource-site-stats")).toContainText("Enemy contesting");
}

async function selectLumeSite(page: Page, siteId: string): Promise<void> {
  await page.evaluate((requestedSiteId) => {
    const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const site = scene.captureSites.find((entry: any) => entry.definition.id === requestedSiteId);
    if (!site) {
      throw new Error(`Missing Lume site ${requestedSiteId}.`);
    }
    scene.selectionSystem.setSelection([site]);
    scene.cameraSystem.centerOn(site.position);
    scene.refreshBattleHud?.(0);
    scene.renderLumeNetworkLinks?.();
  }, siteId);
  await expect(page.getByTestId("selected-lume-site-summary")).toBeVisible();
}

async function stageV095FogRoadWaterView(page: Page): Promise<void> {
  await page.evaluate(() => {
    const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    scene.settings.fogEnabledOverride = "enabled";
    scene.fogDebugDisabled = false;
    scene.cameraSystem.centerOn({ x: 930, y: 300 });
    scene.updateFogOfWar?.(0, true);
    scene.refreshBattleHud?.(0);
  });
}

async function selectHeroForVisualQa(page: Page): Promise<void> {
  await page.evaluate(() => {
    const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    scene.selectionSystem.setSelection([scene.hero]);
    scene.cameraSystem.centerOn(scene.hero.position);
    scene.refreshBattleHud?.(0);
  });
  await expect(page.getByTestId("battle-hero-panel")).toBeVisible();
}

async function trainAndSelectWorkerForVisualQa(page: Page): Promise<void> {
  await page.evaluate(() => {
    const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const commandHall = scene.buildings.find(
      (building: any) => building.alive && building.team === "player" && building.definition.id === "command_hall"
    );
    if (!commandHall) {
      throw new Error("Missing player Command Hall.");
    }
    scene.resources.player.crowns = Math.max(scene.resources.player.crowns, 500);
    scene.resources.player.stone = Math.max(scene.resources.player.stone, 250);
    scene.trainingSystem.queueTraining(commandHall, "worker", scene.resources.player, { announce: false });
    scene.trainingSystem.update(90, scene.buildings);
    const worker = scene.units.find((unit: any) => unit.alive && unit.team === "player" && unit.definition.id === "worker");
    if (!worker) {
      throw new Error("Worker did not train for visual QA.");
    }
    scene.selectionSystem.setSelection([worker]);
    scene.cameraSystem.centerOn(worker.position);
    scene.refreshBattleHud?.(0);
  });
  await expect(page.getByTestId("selection-side-panel")).toContainText("Worker");
}

async function selectUnitTypeForVisualQa(page: Page, unitId: string, team: "player" | "enemy"): Promise<void> {
  await page.evaluate(
    ({ unitId, team }) => {
      const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      if (team === "enemy") {
        scene.fogDebugDisabled = true;
        scene.updateFogOfWar?.(0, true);
      }
      const unit = scene.units.find((entry: any) => entry.alive && entry.team === team && entry.definition.id === unitId);
      if (!unit) {
        throw new Error(`Missing ${team} ${unitId} for visual QA.`);
      }
      scene.selectionSystem.setSelection([unit]);
      scene.cameraSystem.centerOn(unit.position);
      scene.refreshBattleHud?.(0);
    },
    { unitId, team }
  );
  await expect(page.getByTestId("selection-side-panel")).toBeVisible();
}

async function selectEnemyForV097Inspection(page: Page): Promise<void> {
  await page.evaluate(() => {
    const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    scene.fogDebugDisabled = true;
    scene.updateFogOfWar?.(0, true);
    const enemy = scene.units.find((unit: any) => unit.team === "enemy" && unit.alive);
    if (!enemy) {
      throw new Error("Missing enemy unit for v0.97 inspection visual QA.");
    }
    scene.selectionSystem.inspect(enemy);
    scene.cameraSystem.centerOn(enemy.position);
    scene.refreshBattleHud?.(0);
  });
  await expect(page.getByTestId("selection-focus-summary")).toContainText("Enemy inspected");
}

async function stageV097CommandMarkers(page: Page): Promise<void> {
  await page.evaluate(() => {
    const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
    if (!scene?.scene.isActive() || !scene.hero?.alive || !hooks?.showCommandFeedbackMarker) {
      throw new Error("Missing v0.97 command marker hook for visual QA.");
    }
    scene.settings.reducedMotionEnabled = false;
    scene.cameraSystem.centerOn(scene.hero.position);
    const anchor = scene.hero.position;
    const markerKinds = ["move", "attack", "patrol", "rally", "build", "ability", "invalid", "focus"];
    markerKinds.forEach((kind, index) => {
      hooks.showCommandFeedbackMarker(kind, anchor.x - 130 + index * 36, anchor.y - 70 + (index % 3) * 36);
    });
    scene.refreshBattleHud?.(0);
  });
  await expect
    .poll(async () => page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.getCommandFeedbackMarkerCount?.() ?? 0))
    .toBeGreaterThan(0);
}

async function stageV097ReducedMotionMarker(page: Page): Promise<void> {
  await page.evaluate(() => {
    const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
    if (!scene?.scene.isActive() || !scene.hero?.alive || !hooks?.showCommandFeedbackMarker) {
      throw new Error("Missing v0.97 command marker hook for reduced-motion visual QA.");
    }
    scene.settings.reducedMotionEnabled = true;
    scene.cameraSystem.centerOn(scene.hero.position);
    hooks.showCommandFeedbackMarker("invalid", scene.hero.position.x + 64, scene.hero.position.y + 18);
    scene.refreshBattleHud?.(0);
  });
  await expect
    .poll(async () => page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.getCommandFeedbackMarkerCount?.() ?? 0))
    .toBe(1);
}

async function stageCaptureSiteVisualState(
  page: Page,
  state: "neutral" | "player" | "enemy" | "contested" | "objective"
): Promise<void> {
  await page.evaluate((requestedState) => {
    const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    scene.fogDebugDisabled = true;
    scene.updateFogOfWar?.(0, true);
    const site = scene.captureSites.find((entry: any) => entry.definition.id === "crown_shrine") ?? scene.captureSites[0];
    if (!site) {
      throw new Error("Missing capture site for v0.95 visual QA.");
    }
    site.setObjectiveRelevant?.(requestedState === "objective");
    if (requestedState === "player") {
      site.setOwner("player");
    } else if (requestedState === "enemy") {
      site.setOwner("enemy");
    } else if (requestedState === "contested") {
      site.setOwner("player");
      site.capturingTeam = "enemy";
      site.captureProgress = 0.46;
      site.updateVisuals?.();
    } else {
      site.setOwner("neutral");
      site.capturingTeam = "neutral";
      site.captureProgress = 0;
      site.updateVisuals?.();
    }
    scene.selectionSystem.setSelection([site]);
    scene.cameraSystem.centerOn(site.position);
    scene.refreshBattleHud?.(0);
  }, state);
  await expect(page.getByTestId("selected-resource-site-stats")).toBeVisible();
}

async function showVisualQaResults(page: Page, outcome: "victory" | "defeat", wasReplay = false): Promise<void> {
  await page.waitForFunction(() => Boolean((window as any).ascendantRealmsGame), undefined, { timeout: 10_000 });
  await page.evaluate(
    ({ outcome, wasReplay }) => {
      const game = (window as any).ascendantRealmsGame;
      if (!game) {
        throw new Error("Ascendant Realms game was not booted.");
      }
      const battleScene = game.scene.getScene("BattleScene");
      if (battleScene?.scene.isActive()) {
        game.scene.stop("BattleScene");
      }
      const startingHero = {
        heroName: "Visual Results",
        classId: "warlord",
        originId: "exiled_noble",
        level: 2,
        xp: 115,
        skillPoints: 1,
        unlockedAbilities: ["rally_banner"],
        completedBattles: wasReplay ? 4 : 3,
        clearedMapIds: ["first_claim", "broken_ford"],
        inventory: [],
        equipment: {},
        allocatedSkills: {},
        factionReputation: { free_marches: 8, ashen_covenant: -8, sylvan_concord: 0, common_folk: 2, old_faith: 0 },
        stats: { might: 8, command: 8, arcana: 2, faith: 3 }
      };
      const hero = {
        ...startingHero,
        xp: outcome === "victory" ? startingHero.xp + 65 : startingHero.xp,
        completedBattles: outcome === "victory" ? startingHero.completedBattles + 1 : startingHero.completedBattles
      };
      game.scene.start("ResultsScene", {
        heroSave: hero,
        startingHeroSave: startingHero,
        launchRequest: {
          requestId: `v090-visual-${outcome}${wasReplay ? "-replay" : ""}`,
          mode: "campaign_node",
          mapId: "broken_ford",
          heroSave: hero,
          sourceId: "visual_qa",
          rewardTableId: "broken_ford_rewards",
          difficulty: "easy",
          modifiers: [],
          enemyProfileId: "ashen_covenant",
          aiPersonalityId: "raider_captain",
          campaignNodeId: "old_stone_road",
          isReplay: wasReplay
        },
        stats: {
          outcome,
          unitsKilled: outcome === "victory" ? 18 : 5,
          buildingsDestroyed: outcome === "victory" ? 2 : 0,
          resourcesCaptured: outcome === "victory" ? 2 : 1,
          firstSiteCaptured: "Old Stone Ford",
          buildingsBuilt: 3,
          builtBuildingIds: ["barracks", "watchtower"],
          unitsTrained: 9,
          trainedUnitIds: ["militia", "ranger"],
          enemyWavesSurvived: outcome === "victory" ? 3 : 1,
          xpGained: outcome === "victory" ? 65 : 12,
          timeSeconds: outcome === "victory" ? 408 : 292,
          completedObjectiveIds: outcome === "victory" ? ["capture_old_ford", "destroy_enemy_barracks"] : ["capture_old_ford"],
          veteranSummary: {
            rankedUpUnits: outcome === "victory" ? [{ unitName: "Militia", rankName: "Veteran", unitInstanceId: "visual-militia-1" }] : [],
            topSurvivor: { unitName: "Ranger", rankName: "Seasoned", unitInstanceId: "visual-ranger-1" },
            notableVeterans: []
          }
        },
        reward:
          outcome === "victory"
            ? {
                itemIds: [],
                itemInstances: [],
                resources: wasReplay ? { crowns: 20 } : { crowns: 80, stone: 35 },
                xp: wasReplay ? 18 : 65,
                duplicateConversions: []
              }
            : undefined,
        rewardLevelUp:
          outcome === "victory" && !wasReplay
            ? { previousLevel: 2, newLevel: 3, levelsGained: 1, skillPointsGained: 1 }
            : { previousLevel: 2, newLevel: 2, levelsGained: 0, skillPointsGained: 0 },
        campaignResult: {
          completedNodeId: "old_stone_road",
          completedNodeName: "Old Stone Road",
          unlockedNodeNames: outcome === "victory" && !wasReplay ? ["Aether Well Ruins"] : [],
          wasReplay,
          nodeRewardAlreadyClaimed: wasReplay,
          unlockedNodeIds: outcome === "victory" && !wasReplay ? ["aether_well_ruins"] : [],
          nodeReward:
            outcome === "victory" && !wasReplay
              ? { itemIds: [], itemInstances: [], resources: { crowns: 60, stone: 30 }, xp: 55, duplicateConversions: [] }
              : { itemIds: [], itemInstances: [], resources: {}, xp: 0, duplicateConversions: [] },
          nodeLevelUp: { previousLevel: 2, newLevel: outcome === "victory" && !wasReplay ? 3 : 2, levelsGained: outcome === "victory" && !wasReplay ? 1 : 0, skillPointsGained: outcome === "victory" && !wasReplay ? 1 : 0 },
          campaignResources: { crowns: 140, stone: 60, iron: 20, aether: 15 }
        }
      });
    },
    { outcome, wasReplay }
  );
  await expect(page.locator(".results-panel")).toBeVisible({ timeout: 15_000 });
  await expect(page.getByTestId("results-full-details")).not.toHaveAttribute("open", "");
}

async function writeIndex(records: CaptureRecord[], consoleErrors: string[]): Promise<void> {
  const viewportSummary = [...new Set(records.map((record) => record.viewport))].join(", ");
  const groupSummary = [...new Set(records.map((record) => record.group))].join(", ");
  const retryCount = records.filter((record) => record.retryUsed).length;
  const durationMs = elapsedMs();
  const screenshotDurationTotal = records.reduce((total, record) => total + record.durationMs, 0);
  const averageScreenshotDuration = records.length > 0 ? Math.round(screenshotDurationTotal / records.length) : 0;
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
    `- Total harness duration: ${durationMs} ms`,
    `- Average screenshot duration: ${averageScreenshotDuration} ms`,
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
      `  - Screenshot duration: ${record.durationMs} ms`,
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
    expect(visualQaRecords, `visual QA should preserve the full ${EXPECTED_SCREENSHOT_COUNT}-screenshot review set`).toHaveLength(
      EXPECTED_SCREENSHOT_COUNT
    );
    expect(visualQaConsoleErrors, "visual QA should not record browser console errors").toEqual([]);
    expect(
      visualQaRecords.filter((record) => record.retryUsed).map((record) => record.fileName),
      "v0.90 visual QA screenshots must not require retry acceptance"
    ).toEqual([]);
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

  test("captures v0.98 meta-progression rescue views", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "v098-meta-progression-rescue";
    const consoleErrors = attachConsoleCollector(page, group);

    await useViewport(page, FULL_HD);
    await seedPostCinderfenCrossingCampaign(page);
    await page.getByTestId("menu-inventory").click();
    await expect(page.getByTestId("hero-overview")).toBeVisible();
    await expect(page.getByTestId("skills-panel")).toBeVisible();
    await expectNoVisibleHorizontalOverflow(page, `${group} hero overview 1920`);
    await captureView(
      page,
      group,
      "v0.98 hero overview 1920",
      "v098-hero-overview-1920.png",
      FULL_HD,
      "Hero overview, skill points, equipment, inventory, relic, and Retinue summary at 1920x1080."
    );

    await useViewport(page, WIDE_DESKTOP);
    await expectNoVisibleHorizontalOverflow(page, `${group} hero overview 1600`);
    await captureView(
      page,
      group,
      "v0.98 hero overview 1600",
      "v098-hero-overview-1600.png",
      WIDE_DESKTOP,
      "Hero meta-progression rescue remains readable at 1600x900."
    );

    await useViewport(page, LAPTOP);
    await expectNoVisibleHorizontalOverflow(page, `${group} hero overview 1366`);
    await captureView(
      page,
      group,
      "v0.98 hero overview 1366",
      "v098-hero-overview-1366.png",
      LAPTOP,
      "Hero meta-progression rescue avoids card overflow at 1366x768."
    );

    await useViewport(page, FULL_HD);
    await openFreshMainMenu(page);
    await seedPostCinderfenCrossingCampaign(page);
    await continueSavedCampaign(page);
    await page.getByTestId("campaign-tab-stronghold").click();
    await expect(page.getByTestId("stronghold-overview")).toBeVisible();
    await expectNoVisibleHorizontalOverflow(page, `${group} stronghold 1920`);
    await captureView(
      page,
      group,
      "v0.98 Stronghold rescue",
      "v098-campaign-stronghold-1920.png",
      FULL_HD,
      "Stronghold tab uses tier summary, available/locked counts, costs, benefits, and collapsed details."
    );

    await useViewport(page, WIDE_DESKTOP);
    await page.getByTestId("campaign-tab-hero").click();
    await expect(page.getByTestId("retinue-panel")).toBeVisible();
    await expectNoVisibleHorizontalOverflow(page, `${group} retinue 1600`);
    await captureView(
      page,
      group,
      "v0.98 Retinue rescue",
      "v098-campaign-retinue-1600.png",
      WIDE_DESKTOP,
      "Hero tab shows Retinue Ready/Recovering/Deployed/Reserve status without a roster prose wall."
    );

    await useViewport(page, LAPTOP);
    await page.getByTestId("campaign-tab-inventory").click();
    await expect(page.getByTestId("campaign-tab-panel-inventory")).toBeVisible();
    await expectNoVisibleHorizontalOverflow(page, `${group} campaign inventory 1366`);
    await captureView(
      page,
      group,
      "v0.98 campaign inventory action",
      "v098-campaign-inventory-1366.png",
      LAPTOP,
      "Campaign Inventory tab keeps the key Hero Inventory action prominent at 1366x768."
    );

    await useViewport(page, FULL_HD);
    await showVisualQaResults(page, "victory");
    await expect(page.getByTestId("results-meta-progress-summary")).toBeVisible();
    await expectNoVisibleHorizontalOverflow(page, `${group} results progression 1920`);
    await captureView(
      page,
      group,
      "v0.98 Results progression summary",
      "v098-results-progression-summary-1920.png",
      FULL_HD,
      "Ordinary victory Results show compact XP, reward, relic, Retinue, and Stronghold progression summary."
    );

    await useViewport(page, LAPTOP);
    await page.getByTestId("results-full-details").getByText("Show Full Battle Details", { exact: true }).click();
    await expect(page.getByTestId("results-full-details")).toHaveAttribute("open", "");
    await expectNoVisibleHorizontalOverflow(page, `${group} results expanded 1366`);
    await captureView(
      page,
      group,
      "v0.98 Results expanded details",
      "v098-results-expanded-1366.png",
      LAPTOP,
      "Expanded Results details remain collapsed-by-default and readable after opening at 1366x768."
    );

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures tutorial review views", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "tutorial";
    const consoleErrors = attachConsoleCollector(page, group);

    await useViewport(page, DESKTOP);
    await openFreshMainMenu(page);
    await clickReady(page.getByTestId("menu-tutorial"), `${group} desktop tutorial launch`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expectBattleLoaded(page, `${group} desktop tutorial`);
    await expect(page.getByTestId("tutorial-overlay")).toBeVisible();
    await captureView(page, group, "Tutorial launch", "tutorial-desktop.png", DESKTOP, "Proving Grounds tutorial overlay and battle HUD.");

    await useViewport(page, MOBILE);
    await openFreshMainMenu(page);
    await clickReady(page.getByTestId("menu-tutorial"), `${group} mobile tutorial launch`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expectBattleLoaded(page, `${group} mobile tutorial`);
    await expect(page.getByTestId("tutorial-overlay")).toBeVisible();
    await captureView(page, group, "Tutorial launch mobile", "tutorial-mobile.png", MOBILE, "Mobile Proving Grounds overlay and battle HUD density.");

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures v0.96 first-session onboarding and help views", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "v096-first-session-onboarding";
    const consoleErrors = attachConsoleCollector(page, group);

    await useViewport(page, FULL_HD);
    await openFreshMainMenu(page);
    await clickReady(page.getByTestId("menu-tutorial"), `${group} first objective tutorial launch`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expectBattleLoaded(page, `${group} first objective tutorial`);
    await expect(page.getByTestId("tutorial-objective")).toContainText("Select Aster");
    await expect(page.getByTestId("tutorial-next")).toHaveCount(0);
    await captureView(
      page,
      group,
      "v0.96 Tutorial first objective 1920",
      "v096-tutorial-first-objective-1920.png",
      FULL_HD,
      "Tutorial opens with Select Aster as the first explicit action and no advance button before completion."
    );

    await useViewport(page, WIDE_DESKTOP);
    await expect(page.getByTestId("tutorial-overlay")).toBeVisible();
    await captureView(
      page,
      group,
      "v0.96 Tutorial first objective 1600",
      "v096-tutorial-first-objective-1600.png",
      WIDE_DESKTOP,
      "Tutorial overlay remains readable at 1600x900 with reason and focus controls."
    );

    await useViewport(page, LAPTOP);
    await expect(page.getByTestId("tutorial-overlay")).toBeVisible();
    await captureView(
      page,
      group,
      "v0.96 Tutorial first objective 1366",
      "v096-tutorial-first-objective-1366.png",
      LAPTOP,
      "Tutorial overlay stays inside the 1366x768 viewport with the first action visible."
    );

    await useViewport(page, WIDE_DESKTOP);
    await page.getByTestId("tutorial-more-help").locator("summary").click();
    await expect(page.getByTestId("tutorial-more-help")).toHaveAttribute("open", "");
    await captureView(
      page,
      group,
      "v0.96 Tutorial More Help",
      "v096-tutorial-more-help-1600.png",
      WIDE_DESKTOP,
      "Tutorial More Help expands without camera forcing or panel drag interference."
    );

    await page.getByTestId("tutorial-dismiss").click();
    await expect(page.getByTestId("tutorial-reopen")).toBeVisible();
    await captureView(
      page,
      group,
      "v0.96 Tutorial dismissed",
      "v096-tutorial-dismissed-1600.png",
      WIDE_DESKTOP,
      "Dismissed Tutorial guidance leaves a compact Show Tutorial Help recovery action."
    );

    await useViewport(page, FULL_HD);
    await startNewCampaign(page, "Visual v096 Onboarding");
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.locator(".campaign-selected-panel")).toContainText("Salto Outskirts");
    await expect(page.getByTestId("campaign-onboarding-card")).toBeVisible();
    await expectCampaignPrimaryActionAboveFold(page, `${group} campaign onboarding 1920`);
    await expectNoCampaignNodeOverlap(page, `${group} campaign onboarding 1920`);
    await captureView(
      page,
      group,
      "v0.96 Campaign onboarding 1920",
      "v096-campaign-onboarding-1920.png",
      FULL_HD,
      "Fresh campaign keeps Salto selected, Start Battle visible, and first-session guidance below the primary action."
    );

    await useViewport(page, LAPTOP);
    await expectCampaignPrimaryActionAboveFold(page, `${group} campaign onboarding 1366`);
    await expectNoCampaignNodeOverlap(page, `${group} campaign onboarding 1366`);
    await captureView(
      page,
      group,
      "v0.96 Campaign onboarding 1366",
      "v096-campaign-onboarding-1366.png",
      LAPTOP,
      "Campaign onboarding remains map-first at 1366x768 with the primary action above the fold."
    );

    await useViewport(page, WIDE_DESKTOP);
    await page.getByTestId("campaign-help-surface").locator("summary").click();
    await expect(page.getByTestId("campaign-help-surface")).toHaveAttribute("open", "");
    await captureView(
      page,
      group,
      "v0.96 Campaign quick help",
      "v096-campaign-quick-help-1600.png",
      WIDE_DESKTOP,
      "Campaign Quick Help groups controls without stealing default map-shell space."
    );

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

  test("captures v0.90 desktop campaign acceptance matrix", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "v090-campaign-desktop-acceptance";
    const consoleErrors = attachConsoleCollector(page, group);

    await useViewport(page, FULL_HD);
    await openFreshMainMenu(page);
    await expect(page.getByTestId("main-menu")).toBeVisible();
    await expectNoVisibleHorizontalOverflow(page, `${group} main menu 1920`);
    await captureView(page, group, "v0.90 main menu 1920", "v090-main-menu-1920.png", FULL_HD, "Main menu at 1920x1080 for desktop regression intake.");

    await useViewport(page, WIDE_DESKTOP);
    await openFreshMainMenu(page);
    await expect(page.getByTestId("main-menu")).toBeVisible();
    await expectNoVisibleHorizontalOverflow(page, `${group} main menu 1600`);
    await captureView(page, group, "v0.90 main menu 1600", "v090-main-menu-1600.png", WIDE_DESKTOP, "Main menu at 1600x900 with primary actions visible.");

    await useViewport(page, LAPTOP);
    await openFreshMainMenu(page);
    await expect(page.getByTestId("main-menu")).toBeVisible();
    await expectNoVisibleHorizontalOverflow(page, `${group} main menu 1366`);
    await captureView(page, group, "v0.90 main menu 1366", "v090-main-menu-1366.png", LAPTOP, "Main menu at 1366x768 acceptance viewport.");

    await useViewport(page, FULL_HD);
    await startNewCampaign(page, "Visual v090 Campaign");
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("campaign-node-border_village")).toContainText(/Available/i);
    await expect(page.locator(".campaign-selected-panel")).toContainText("Salto Outskirts");
    await expect(page.getByTestId("campaign-route-layer")).toBeVisible();
    await expectCampaignPrimaryActionAboveFold(page, `${group} fresh campaign 1920`);
    await expectNoCampaignNodeOverlap(page, `${group} fresh campaign 1920`);
    await expectNoVisibleHorizontalOverflow(page, `${group} fresh campaign 1920`);
    await captureView(
      page,
      group,
      "v0.90 fresh campaign map 1920",
      "v090-fresh-campaign-map-1920.png",
      FULL_HD,
      "Fresh campaign opens to Salto Outskirts selected, with map, routes, and primary action above the fold."
    );

    await useViewport(page, LAPTOP);
    await expectCampaignPrimaryActionAboveFold(page, `${group} fresh campaign 1366`);
    await expectNoCampaignNodeOverlap(page, `${group} fresh campaign 1366`);
    await expectNoVisibleHorizontalOverflow(page, `${group} fresh campaign 1366`);
    await captureView(
      page,
      group,
      "v0.90 fresh campaign map 1366",
      "v090-fresh-campaign-map-1366.png",
      LAPTOP,
      "Fresh campaign map at 1366x768 without page scroll or node overlap."
    );

    await useViewport(page, FULL_HD);
    await page.getByTestId("campaign-node-border_village").click();
    await expect(page.locator(".campaign-selected-panel")).toContainText("Salto Outskirts");
    await expectCampaignPrimaryActionAboveFold(page, `${group} unlocked mission 1920`);
    await captureView(
      page,
      group,
      "v0.90 selected unlocked mission",
      "v090-selected-unlocked-mission-1920.png",
      FULL_HD,
      "Selected unlocked mission panel shows concise facts and Start Battle without scrolling."
    );

    await useViewport(page, LAPTOP);
    await page.getByTestId("campaign-node-aether_well_ruins").click();
    await expect(page.locator(".campaign-selected-panel")).toContainText("Aether Well Ruins");
    await expect(page.getByTestId("campaign-start-node")).toBeDisabled();
    await expectCampaignPrimaryActionAboveFold(page, `${group} locked mission 1366`);
    await captureView(
      page,
      group,
      "v0.90 selected locked mission",
      "v090-selected-locked-mission-1366.png",
      LAPTOP,
      "Locked Aether Well preview keeps lock reason and disabled primary action visible at 1366x768."
    );

    await page.locator(".campaign-node-more summary").click();
    await expect(page.locator(".campaign-node-more")).toHaveAttribute("open", "");
    await page.locator("[data-testid='campaign-selected-panel']").evaluate((panel) => {
      const target = panel as HTMLElement;
      target.scrollTop = Math.min(220, Math.max(0, target.scrollHeight - target.clientHeight));
    });
    await page.getByTestId("campaign-node-border_village").click();
    await expect(page.locator(".campaign-selected-panel")).toContainText("Salto Outskirts");
    await expect(page.locator(".campaign-node-more")).not.toHaveAttribute("open", "");
    await expectCampaignPrimaryActionAboveFold(page, `${group} Salto reset 1366`);
    await captureView(
      page,
      group,
      "v0.93 Salto panel reset",
      "v093-salto-panel-reset-1366.png",
      LAPTOP,
      "Salto Outskirts selected after inspecting and scrolling the locked Aether Well preview; More Details collapsed and Start Battle visible."
    );

    await useViewport(page, WIDE_DESKTOP);
    for (const [tab, title, fileName, expectedTestId] of [
      ["map", "v0.90 campaign tab Map", "v090-campaign-tab-map-1600.png", "campaign-tab-panel-map"],
      ["stronghold", "v0.90 campaign tab Stronghold", "v090-campaign-tab-stronghold-1600.png", "campaign-tab-panel-stronghold"],
      ["hero", "v0.90 campaign tab Hero", "v090-campaign-tab-hero-1600.png", "campaign-tab-panel-hero"],
      ["inventory", "v0.90 campaign tab Inventory", "v090-campaign-tab-inventory-1600.png", "campaign-tab-panel-inventory"],
      ["intel", "v0.90 campaign tab Intel", "v090-campaign-tab-intel-1600.png", "campaign-tab-panel-intel"],
      ["reputation", "v0.90 campaign tab Reputation", "v090-campaign-tab-reputation-1600.png", "campaign-tab-panel-reputation"]
    ] as const) {
      await page.getByTestId(`campaign-tab-${tab}`).click();
      await expect(page.getByTestId(expectedTestId)).toBeVisible();
      await expectNoVisibleHorizontalOverflow(page, `${group} ${tab} tab 1600`);
      if (tab === "map") {
        await expectNoCampaignNodeOverlap(page, `${group} map tab 1600`);
        await expectCampaignPrimaryActionAboveFold(page, `${group} map tab 1600`);
      }
      await captureView(
        page,
        group,
        title,
        fileName,
        WIDE_DESKTOP,
        `${tab} campaign tab at 1600x900 with card hierarchy and no horizontal overflow.`
      );
    }

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures v0.94 menu, creation, campaign density, and Results compaction views", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "v094-presentation-rescue";
    const consoleErrors = attachConsoleCollector(page, group);

    await useViewport(page, FULL_HD);
    await openFreshMainMenu(page);
    await expect(page.getByTestId("main-menu-panel")).toBeVisible();
    await expectNoVisibleHorizontalOverflow(page, `${group} main menu 1920`);
    await captureView(
      page,
      group,
      "v0.94 main menu rescue 1920",
      "v094-main-menu-1920.png",
      FULL_HD,
      "Wider desktop main menu panel with grouped Play, Practice, and Manage actions."
    );

    await useViewport(page, WIDE_DESKTOP);
    await openFreshMainMenu(page);
    await expect(page.getByTestId("main-menu-panel")).toBeVisible();
    await expectNoVisibleHorizontalOverflow(page, `${group} main menu 1600`);
    await captureView(
      page,
      group,
      "v0.94 main menu rescue 1600",
      "v094-main-menu-1600.png",
      WIDE_DESKTOP,
      "Intermediate desktop main menu keeps the primary campaign action prominent."
    );

    await useViewport(page, LAPTOP);
    await openFreshMainMenu(page);
    await expect(page.getByTestId("main-menu-panel")).toBeVisible();
    await expectNoVisibleHorizontalOverflow(page, `${group} main menu 1366`);
    await captureView(
      page,
      group,
      "v0.94 main menu rescue 1366",
      "v094-main-menu-1366.png",
      LAPTOP,
      "Laptop main menu avoids a narrow floating stack while retaining all actions."
    );

    await page.getByTestId("menu-new-campaign").click();
    await expect(page.getByTestId("hero-creation-step-class")).toBeVisible();
    await expect(page.getByTestId("hero-creation-step-origin")).toBeVisible();
    await expect(page.getByTestId("hero-creation-step-review")).toBeVisible();
    await expectNoVisibleHorizontalOverflow(page, `${group} creation class 1366`);
    await captureView(
      page,
      group,
      "v0.94 Ascendant creation class step",
      "v094-creation-class-step-1366.png",
      LAPTOP,
      "Step 1/2/3 hero creation layout with class choices, origin choices, and review visible without prose walls."
    );

    await useViewport(page, WIDE_DESKTOP);
    await page.getByTestId("hero-class-arcanist").click();
    await expect(page.getByTestId("hero-class-arcanist")).toHaveAttribute("aria-pressed", "true");
    await expectNoVisibleHorizontalOverflow(page, `${group} creation selected class 1600`);
    await captureView(
      page,
      group,
      "v0.94 Ascendant creation selected class",
      "v094-creation-selected-class-1600.png",
      WIDE_DESKTOP,
      "Selected class state is obvious and class traits remain compact."
    );

    await useViewport(page, LAPTOP);
    await page.getByTestId("hero-origin-wildland_raider").click();
    await expect(page.getByTestId("hero-origin-wildland_raider")).toHaveAttribute("aria-pressed", "true");
    await expect(page.locator(".creation-selected-strip")).toContainText("Wildland Raider");
    await expectNoVisibleHorizontalOverflow(page, `${group} creation selected origin 1366`);
    await captureView(
      page,
      group,
      "v0.94 Ascendant creation selected origin",
      "v094-creation-selected-origin-1366.png",
      LAPTOP,
      "Selected origin state and review strip are readable on laptop."
    );

    await useViewport(page, FULL_HD);
    await expect(page.getByTestId("hero-creation-step-review")).toBeVisible();
    await captureView(
      page,
      group,
      "v0.94 Ascendant creation review step",
      "v094-creation-review-1920.png",
      FULL_HD,
      "Review step keeps Begin Campaign visible while preserving unchanged hero rules."
    );

    await page.getByTestId("hero-name-input").fill("Visual v094");
    await page.getByTestId("hero-start").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.locator(".campaign-selected-panel")).toContainText("Salto Outskirts");
    await expectCampaignPrimaryActionAboveFold(page, `${group} fresh campaign 1920`);
    await expectNoCampaignNodeOverlap(page, `${group} fresh campaign 1920`);
    await expectNoVisibleHorizontalOverflow(page, `${group} fresh campaign 1920`);
    await captureView(
      page,
      group,
      "v0.94 fresh campaign density 1920",
      "v094-fresh-campaign-1920.png",
      FULL_HD,
      "Fresh campaign opens map-first with Salto Outskirts selected and compact mission facts."
    );

    await useViewport(page, WIDE_DESKTOP);
    await page.getByTestId("campaign-node-border_village").click();
    await expect(page.locator(".campaign-selected-panel")).toContainText("Salto Outskirts");
    await captureView(
      page,
      group,
      "v0.94 Salto selected 1600",
      "v094-salto-selected-1600.png",
      WIDE_DESKTOP,
      "Salto Outskirts compact panel shows status, objective, rewards, and action without long prose."
    );

    await useViewport(page, LAPTOP);
    await page.getByTestId("campaign-node-aether_well_ruins").click();
    await expect(page.locator(".campaign-selected-panel")).toContainText("Aether Well Ruins");
    await page.locator(".campaign-node-more summary").click();
    await expect(page.locator(".campaign-node-more")).toHaveAttribute("open", "");
    await expectNoVisibleHorizontalOverflow(page, `${group} expanded mission details 1366`);
    await captureView(
      page,
      group,
      "v0.94 expanded mission details 1366",
      "v094-expanded-mission-details-1366.png",
      LAPTOP,
      "Secondary doctrine, modifier, and briefing prose lives behind More Details."
    );
    await page.getByTestId("campaign-node-border_village").click();
    await expect(page.locator(".campaign-selected-panel")).toContainText("Salto Outskirts");
    await expect(page.locator(".campaign-node-more")).not.toHaveAttribute("open", "");
    await expectCampaignPrimaryActionAboveFold(page, `${group} Salto reset 1366`);
    await captureView(
      page,
      group,
      "v0.94 Salto after another mission 1366",
      "v094-salto-after-another-mission-1366.png",
      LAPTOP,
      "Returning to Salto after a locked preview preserves the v0.93 panel reset and compact default state."
    );

    await useViewport(page, WIDE_DESKTOP);
    for (const [tab, title, fileName, expectedTestId] of [
      ["map", "v0.94 campaign tab Map", "v094-campaign-tab-map-1600.png", "campaign-tab-panel-map"],
      ["stronghold", "v0.94 campaign tab Stronghold", "v094-campaign-tab-stronghold-1600.png", "campaign-tab-panel-stronghold"],
      ["hero", "v0.94 campaign tab Hero", "v094-campaign-tab-hero-1600.png", "campaign-tab-panel-hero"],
      ["inventory", "v0.94 campaign tab Inventory", "v094-campaign-tab-inventory-1600.png", "campaign-tab-panel-inventory"],
      ["intel", "v0.94 campaign tab Intel", "v094-campaign-tab-intel-1600.png", "campaign-tab-panel-intel"],
      ["reputation", "v0.94 campaign tab Reputation", "v094-campaign-tab-reputation-1600.png", "campaign-tab-panel-reputation"]
    ] as const) {
      await page.getByTestId(`campaign-tab-${tab}`).click();
      await expect(page.getByTestId(expectedTestId)).toBeVisible();
      await expectNoVisibleHorizontalOverflow(page, `${group} ${tab} tab 1600`);
      await captureView(
        page,
        group,
        title,
        fileName,
        WIDE_DESKTOP,
        `${tab} tab uses card hierarchy with primary summary first and optional details collapsed where possible.`
      );
    }

    await openFreshMainMenu(page);
    await showVisualQaResults(page, "victory");
    await expectResultsPrimaryActionsAboveFold(page, `${group} compact Results 1600`);
    await captureView(
      page,
      group,
      "v0.94 Results compact",
      "v094-results-compact-1600.png",
      WIDE_DESKTOP,
      "Ordinary Results compact state preserves outcome, reward, XP, veteran, and action priority above full details."
    );

    await useViewport(page, LAPTOP);
    await page.getByText("Show Full Battle Details", { exact: true }).click();
    await expect(page.getByTestId("results-detail-accordion")).toBeVisible();
    await expectNoVisibleHorizontalOverflow(page, `${group} expanded Results 1366`);
    await captureView(
      page,
      group,
      "v0.94 Results expanded details",
      "v094-results-expanded-1366.png",
      LAPTOP,
      "Expanded ordinary Results use accordion groups and compact metrics without changing reward data."
    );

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures v0.99 Act 1 mission presentation and Results summary", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "v099-act1-presentation";
    const consoleErrors = attachConsoleCollector(page, group);

    await useViewport(page, FULL_HD);
    await startNewCampaign(page, "Visual v099 Act 1");
    await expect(page.locator(".campaign-selected-panel")).toContainText("Salto Outskirts");
    await expect(page.locator(".campaign-selected-panel")).toContainText("Recommended next step");
    await expectCampaignPrimaryActionAboveFold(page, `${group} Salto fresh 1920`);
    await expectNoCampaignNodeOverlap(page, `${group} Salto fresh 1920`);
    await captureView(
      page,
      group,
      "v0.99 Salto Outskirts fresh",
      "v099-act1-salto-outskirts-1920.png",
      FULL_HD,
      "Salto Outskirts opens as a concise first mission card with premise, objective, rewards, and next-step copy."
    );

    await seedCampaignSave(page, {
      campaign: {
        completedNodeIds: ["border_village", "old_stone_road"],
        unlockedNodeIds: ["border_village", "old_stone_road", "marcher_camp", "refugee_caravan", "aether_well_ruins", "bandit_hillfort"],
        nodeRewardsClaimedIds: ["border_village", "old_stone_road"],
        selectedNodeId: "old_stone_road"
      }
    });
    await continueSavedCampaign(page);
    await useViewport(page, WIDE_DESKTOP);
    for (const [nodeId, title, fileName, expectedCopy] of [
      ["old_stone_road", "v0.99 Old Stone Road replay", "v099-act1-old-stone-road-1600.png", "Replay"],
      ["marcher_camp", "v0.99 Marcher Camp support", "v099-act1-marcher-camp-1600.png", "A Barrosan support camp"],
      ["refugee_caravan", "v0.99 Refugee Caravan choice", "v099-act1-refugee-caravan-1600.png", "reputation and resource choice"],
      ["aether_well_ruins", "v0.99 Aether Well Ruins", "v099-act1-aether-well-1600.png", "A ruined well on Broken Ford"],
      ["bandit_hillfort", "v0.99 Bandit Hillfort", "v099-act1-bandit-hillfort-1600.png", "stable army timing"]
    ] as const) {
      await page.getByTestId(`campaign-node-${nodeId}`).click();
      await expect(page.locator(".campaign-selected-panel")).toContainText(expectedCopy);
      await expect(page.locator(".campaign-selected-panel")).toContainText("Recommended next step");
      await expectNoVisibleHorizontalOverflow(page, `${group} ${nodeId} 1600`);
      await captureView(page, group, title, fileName, WIDE_DESKTOP, `${nodeId} mission-card presentation and next-step copy.`);
    }

    await seedCampaignSave(page, {
      campaign: {
        completedNodeIds: ["border_village", "old_stone_road", "aether_well_ruins"],
        unlockedNodeIds: [
          "border_village",
          "old_stone_road",
          "marcher_camp",
          "refugee_caravan",
          "aether_well_ruins",
          "bandit_hillfort",
          "chapel_of_the_marches"
        ],
        nodeRewardsClaimedIds: ["border_village", "old_stone_road", "aether_well_ruins"],
        selectedNodeId: "chapel_of_the_marches"
      }
    });
    await continueSavedCampaign(page);
    await useViewport(page, LAPTOP);
    await page.getByTestId("campaign-node-chapel_of_the_marches").click();
    await expect(page.locator(".campaign-selected-panel")).toContainText("Chapel of the Barrosan Marches");
    await expect(page.locator(".campaign-selected-panel")).toContainText("one clear support choice");
    await expectNoVisibleHorizontalOverflow(page, `${group} chapel 1366`);
    await captureView(
      page,
      group,
      "v0.99 Chapel of the Barrosan Marches",
      "v099-act1-chapel-1366.png",
      LAPTOP,
      "Chapel support node keeps the default card compact and event details behind disclosure."
    );

    await seedCampaignSave(page, {
      campaign: {
        completedNodeIds: ["border_village", "old_stone_road", "aether_well_ruins", "bandit_hillfort", "chapel_of_the_marches"],
        unlockedNodeIds: [
          "border_village",
          "old_stone_road",
          "marcher_camp",
          "refugee_caravan",
          "aether_well_ruins",
          "bandit_hillfort",
          "chapel_of_the_marches",
          "ashen_outpost"
        ],
        nodeRewardsClaimedIds: ["border_village", "old_stone_road", "aether_well_ruins", "bandit_hillfort", "chapel_of_the_marches"],
        selectedNodeId: "ashen_outpost"
      }
    });
    await continueSavedCampaign(page);
    await useViewport(page, WIDE_DESKTOP);
    await page.getByTestId("campaign-node-ashen_outpost").click();
    await expect(page.locator(".campaign-selected-panel")).toContainText("The Act 1 finale");
    await expect(page.locator(".campaign-selected-panel")).toContainText("Defeat Captain Malrec");
    await captureView(
      page,
      group,
      "v0.99 Ashen Outpost finale",
      "v099-act1-ashen-outpost-1600.png",
      WIDE_DESKTOP,
      "Ashen Outpost card frames the finale, Malrec objective, milestone reward, and next step without changing gameplay."
    );
    await page.locator(".campaign-node-more summary").click();
    await expect(page.locator(".campaign-node-more")).toHaveAttribute("open", "");
    await expect(page.locator(".campaign-node-details")).toContainText("Malrec believes disciplined control over Lume");
    await captureView(
      page,
      group,
      "v0.99 Ashen Outpost More Details",
      "v099-act1-ashen-outpost-details-1600.png",
      WIDE_DESKTOP,
      "Expanded Ashen Outpost details preserve doctrine, Malrec, tactical-plan, and reward intel behind disclosure."
    );

    await openFreshMainMenu(page);
    await showVisualQaResults(page, "victory");
    await expect(page.getByTestId("results-overview")).toContainText("Destroy the enemy Stronghold after stabilizing road income");
    await expect(page.getByTestId("results-overview")).toContainText("Next mission unlocked: Aether Well Ruins");
    await captureView(
      page,
      group,
      "v0.99 ordinary Results summary",
      "v099-act1-results-summary-1600.png",
      WIDE_DESKTOP,
      "Ordinary Results overview names the mission objective and recommended next action above the fold."
    );

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures v0.100 private playtest hub and scenario gallery families", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "v0100-private-playtest-hub";
    const consoleErrors = attachConsoleCollector(page, group);
    await page.addInitScript(() => {
      Reflect.set(window, "__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__", true);
    });

    await useViewport(page, FULL_HD);
    await openFreshMainMenu(page);
    await page.getByTestId("menu-playtest-hub").click();
    await expect(page.getByTestId("playtest-hub")).toBeVisible();
    await captureView(page, group, "v0.100 Playtest Hub 1920", "v0100-playtest-hub-1920.png", FULL_HD, "Private scenario gallery at 1920x1080.");

    await useViewport(page, WIDE_DESKTOP);
    await captureView(page, group, "v0.100 Playtest Hub 1600", "v0100-playtest-hub-1600.png", WIDE_DESKTOP, "Private scenario gallery at 1600x900.");

    await useViewport(page, LAPTOP);
    await captureView(page, group, "v0.100 Playtest Hub 1366", "v0100-playtest-hub-1366.png", LAPTOP, "Private scenario gallery at 1366x768.");

    await page.getByTestId("playtest-scenario-campaign_salto_selected").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await captureView(page, group, "v0.100 Campaign Shell entry", "v0100-hub-campaign-shell.png", LAPTOP, "Campaign Shell gallery entry with Salto selected.");
    await page.getByTestId("campaign-playtest-hub-return").click();
    await expect(page.getByTestId("playtest-hub")).toBeVisible();

    await page.getByTestId("playtest-scenario-ascendant_creation").click();
    await expect(page.getByTestId("hero-creation")).toBeVisible();
    await captureView(page, group, "v0.100 First Session entry", "v0100-hub-first-session.png", LAPTOP, "First Session gallery entry for Ascendant creation.");
    await page.getByTestId("hero-back").click();
    await expect(page.getByTestId("playtest-hub")).toBeVisible();

    await page.getByTestId("playtest-scenario-battle_selected_hero").click();
    await expectBattleLoaded(page);
    await captureView(page, group, "v0.100 Battle Shell entry", "v0100-hub-battle-shell.png", LAPTOP, "Battle Shell gallery entry with selected hero.");
    await page.getByTestId("private-hub-exit").click();
    await expect(page.getByTestId("playtest-hub")).toBeVisible();

    await page.getByTestId("playtest-scenario-lume_first_link").click();
    await expectBattleLoaded(page);
    await expect(page.getByTestId("lume-links-progress")).toContainText("LUME LINKS 1/2");
    await captureView(page, group, "v0.100 Lume entry", "v0100-hub-lume-flow.png", LAPTOP, "Lume gallery entry with first link active.");
    await page.getByTestId("private-hub-exit").click();
    await expect(page.getByTestId("playtest-hub")).toBeVisible();

    await page.getByTestId("playtest-scenario-meta_retinue_ready").click();
    await expect(page.getByTestId("campaign-tab-panel-hero")).toBeVisible();
    await captureView(page, group, "v0.100 Meta entry", "v0100-hub-meta-flow.png", LAPTOP, "Meta gallery entry with Retinue ready preview.");
    await page.getByTestId("campaign-playtest-hub-return").click();
    await expect(page.getByTestId("playtest-hub")).toBeVisible();

    await page.getByTestId("playtest-scenario-ordinary_results").click();
    await expect(page.getByTestId("results-overview")).toBeVisible();
    await captureView(page, group, "v0.100 Results entry", "v0100-hub-results-flow.png", LAPTOP, "Meta gallery entry with ordinary Results fixture.");

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures v0.103 battlefield clutter and private performance lab states", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "v0103-clutter-performance";
    const consoleErrors = attachConsoleCollector(page, group);
    await page.addInitScript(() => {
      Reflect.set(window, "__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__", true);
    });

    await useViewport(page, FULL_HD);
    await openFreshMainMenu(page);
    await page.getByTestId("menu-playtest-hub").click();
    await expect(page.getByTestId("playtest-hub")).toBeVisible();
    await captureView(page, group, "v0.103 Performance Hub 1920", "v0103-performance-hub-1920.png", FULL_HD, "Private hub includes Performance Lab without exposing production shortcuts.");

    await useViewport(page, WIDE_DESKTOP);
    await captureView(page, group, "v0.103 Performance Hub 1600", "v0103-performance-hub-1600.png", WIDE_DESKTOP, "Performance Lab remains readable at 1600x900.");

    await useViewport(page, LAPTOP);
    await captureView(page, group, "v0.103 Performance Hub 1366", "v0103-performance-hub-1366.png", LAPTOP, "Performance Lab remains usable at 1366x768.");

    await page.getByTestId("playtest-group-performance_lab").scrollIntoViewIfNeeded();
    await captureView(page, group, "v0.103 Performance Lab group", "v0103-performance-lab-group-1366.png", LAPTOP, "Performance Lab group shows deterministic private QA entries.");

    await expect(page.getByTestId("private-performance-toggle")).toBeVisible();
    await captureView(page, group, "v0.103 Profiler off", "v0103-profiler-off-1366.png", LAPTOP, "Profiler toggle is present but off by default.");
    await page.getByTestId("private-performance-toggle").click();
    await expect(page.getByTestId("private-performance-panel")).toBeVisible();
    await page.waitForTimeout(650);
    await captureView(page, group, "v0.103 Profiler active", "v0103-profiler-active-1366.png", LAPTOP, "Profiler panel records only after explicit private toggle.");
    await page.getByTestId("private-performance-toggle").click();
    await captureView(page, group, "v0.103 Profiler summary", "v0103-profiler-summary-1366.png", LAPTOP, "Profiler summary remains local/private after stopping.");

    for (const [scenarioId, kind, fileName, note] of V0103_PERFORMANCE_VISUAL_SCENARIOS) {
      await page.getByTestId(`playtest-scenario-${scenarioId}`).scrollIntoViewIfNeeded();
      await page.getByTestId(`playtest-scenario-${scenarioId}`).click();
      if (kind === "campaign") {
        await expect(page.getByTestId("campaign-map")).toBeVisible();
        await captureView(page, group, `v0.103 ${scenarioId}`, fileName, LAPTOP, note);
        await page.getByTestId("campaign-playtest-hub-return").click();
        await expect(page.getByTestId("playtest-hub")).toBeVisible();
        continue;
      }

      await expectBattleLoaded(page);
      if (scenarioId.startsWith("perf_lume")) {
        await expect(page.getByTestId("lume-network-status")).toBeVisible();
      }
      await captureView(page, group, `v0.103 ${scenarioId}`, fileName, LAPTOP, note);

      if (scenarioId === "perf_lume_auto") {
        await page.getByTestId("lume-network-details").locator("summary").click();
        await expect(page.getByTestId("lume-network-details")).toHaveAttribute("open", "");
        await captureView(
          page,
          group,
          "v0.103 Lume Auto details",
          "v0103-perf-lume-auto-details.png",
          LAPTOP,
          "Lume Auto keeps benefit/counterplay behind deliberate details disclosure."
        );
      }

      if (scenarioId === "perf_label_heavy_site_cluster") {
        await expect(page.getByTestId("selected-resource-site-stats")).toBeVisible();
        await useViewport(page, WIDE_DESKTOP);
        await captureView(
          page,
          group,
          "v0.103 capture-site label density 1600",
          "v0103-perf-label-heavy-site-cluster-1600.png",
          WIDE_DESKTOP,
          "Capture-site labels and rings stay readable after v0.103 default-label reduction."
        );
        await useViewport(page, LAPTOP);
      }

      await page.getByTestId("private-hub-exit").click();
      await expect(page.getByTestId("playtest-hub")).toBeVisible();
    }

    await page.getByTestId("playtest-scenario-perf_results_disclosure").scrollIntoViewIfNeeded();
    await page.getByTestId("playtest-scenario-perf_results_disclosure").click();
    await expect(page.getByTestId("results-overview")).toBeVisible();
    await captureView(page, group, "v0.103 Results compact", "v0103-perf-results-compact.png", LAPTOP, "Compact Results remain above the fold for performance-lab review.");
    await page.getByTestId("results-full-details").getByText("Show Full Battle Details", { exact: true }).click();
    await expect(page.getByTestId("results-full-details")).toHaveAttribute("open", "");
    await captureView(page, group, "v0.103 Results expanded", "v0103-perf-results-expanded.png", LAPTOP, "Expanded Results details remain deliberate disclosure for review.");

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures v0.90 battle HUD, Lume, and private Results acceptance matrix", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "v090-battle-lume-acceptance";
    const consoleErrors = attachConsoleCollector(page, group);

    await useViewport(page, FULL_HD);
    await startNewCampaign(page, "Visual v090 Battle");
    await clickReady(page.getByTestId("campaign-start-node"), `${group} start ordinary battle`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expectBattleLoaded(page, `${group} ordinary battle start`);
    await expectBattleHudAcceptance(page, `${group} ordinary battle start 1920`);
    await expectPrivateDemoControlsPosture(page, false, `${group} ordinary battle`);
    await expectLumeControlsAbsent(page, `${group} ordinary battle`);
    await captureView(
      page,
      group,
      "v0.90 ordinary battle start",
      "v090-ordinary-battle-start-1920.png",
      FULL_HD,
      "Ordinary battle start at 1920x1080 with objectives, command panel, minimap, and no private-demo/Lume controls."
    );

    await useViewport(page, WIDE_DESKTOP);
    await selectFirstPlayerArmy(page);
    await expectBattleHudAcceptance(page, `${group} selected units 1600`);
    await captureView(
      page,
      group,
      "v0.90 selected units",
      "v090-selected-units-1600.png",
      WIDE_DESKTOP,
      "Selected army group at 1600x900 with role/order summary and command panel readable."
    );

    await useViewport(page, LAPTOP);
    await selectCommandHall(page);
    await expectBattleHudAcceptance(page, `${group} selected building 1366`);
    await captureView(
      page,
      group,
      "v0.90 selected building",
      "v090-selected-building-1366.png",
      LAPTOP,
      "Selected Command Hall at 1366x768 with building role and production actions contained."
    );

    await useViewport(page, WIDE_DESKTOP);
    await stageContestedCaptureSite(page, "crown_shrine");
    await expectBattleHudAcceptance(page, `${group} contested site 1600`);
    await captureView(
      page,
      group,
      "v0.90 contested capture site",
      "v090-contested-capture-site-1600.png",
      WIDE_DESKTOP,
      "Contested resource-site selection shows capture progress and assignment guidance without HUD collision."
    );

    await useViewport(page, FULL_HD);
    await startNewCampaign(page, "Visual v090 Lume");
    await page.getByTestId("campaign-node-aether_well_ruins").click();
    await clickReady(page.getByTestId("campaign-private-lume-demo"), `${group} start private Lume demo`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expectBattleLoaded(page, `${group} Lume demo start`);
    await expectPrivateDemoControlsPosture(page, true, `${group} Lume inactive`);
    await expect(page.getByTestId("lume-network-status")).toContainText("LUME WARD");
    await captureView(
      page,
      group,
      "v0.90 Lume inactive",
      "v090-lume-inactive-1920.png",
      FULL_HD,
      "Private Lume mission before link activation with eligible controls and no-save warning visible."
    );

    await centerCaptureSite(page, "west_stone_cut", true);
    await centerCaptureSite(page, "ford_toll", true);
    await expect(page.getByTestId("lume-network-status")).toContainText("LUME WARD ACTIVE");
    await captureView(
      page,
      group,
      "v0.90 Lume active stable",
      "v090-lume-active-stable-1920.png",
      FULL_HD,
      "Linked Ward active state at 1920x1080 with stable Lume tracker and Finish Demo action."
    );

    await useViewport(page, WIDE_DESKTOP);
    await selectLumeSite(page, "north_aether_spring");
    await captureView(
      page,
      group,
      "v0.90 Lume selected highlighted",
      "v090-lume-selected-highlighted-1600.png",
      WIDE_DESKTOP,
      "Selected Lume site at 1600x900 shows link guidance and highlight context."
    );

    await useViewport(page, LAPTOP);
    await page.getByTestId("lume-visibility-hidden").click();
    await expect(page.getByTestId("lume-visibility-controls")).toContainText("Links: Hidden");
    await captureView(
      page,
      group,
      "v0.90 Lume hidden",
      "v090-lume-hidden-1366.png",
      LAPTOP,
      "Lume links hidden at 1366x768 while mission HUD remains readable."
    );

    await page.getByTestId("lume-visibility-always").click();
    await expect(page.getByTestId("lume-visibility-controls")).toContainText("Links: Always");
    await captureView(
      page,
      group,
      "v0.90 Lume always visible",
      "v090-lume-always-visible-1366.png",
      LAPTOP,
      "Lume links forced always-visible at 1366x768 for visual review."
    );

    await page.getByTestId("private-demo-finish").click();
    await expect(page.locator(".results-panel")).toBeVisible();
    await expect(page.getByTestId("private-demo-full-details")).not.toHaveAttribute("open", "");
    await expectResultsPrimaryActionsAboveFold(page, `${group} private Results compact`);
    await captureView(
      page,
      group,
      "v0.90 private-demo Results compact",
      "v090-private-results-compact-1366.png",
      LAPTOP,
      "Private demo Results compact state keeps no-save summary and primary actions above the fold."
    );

    await page.getByTestId("private-demo-full-details").locator("summary").click();
    await expect(page.getByTestId("private-demo-full-details")).toHaveAttribute("open", "");
    await captureView(
      page,
      group,
      "v0.90 private-demo Results expanded",
      "v090-private-results-expanded-1366.png",
      LAPTOP,
      "Private demo Results expanded full battle details remain behind deliberate disclosure."
    );

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures v0.95 procedural battlefield readability states", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "v095-battlefield-readability";
    const consoleErrors = attachConsoleCollector(page, group);

    await useViewport(page, FULL_HD);
    await startNewCampaign(page, "Visual v095 Battle");
    await clickReady(page.getByTestId("campaign-start-node"), `${group} start ordinary battle`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expectBattleHudAcceptance(page, `${group} ordinary battle start 1920`);
    await captureView(
      page,
      group,
      "v0.95 ordinary battle start 1920",
      "v095-ordinary-battle-start-1920.png",
      FULL_HD,
      "Ordinary battle start at 1920x1080 with procedural terrain, capture-site rings, minimap, and HUD readable."
    );

    await useViewport(page, WIDE_DESKTOP);
    await expectBattleHudAcceptance(page, `${group} ordinary battle start 1600`);
    await captureView(
      page,
      group,
      "v0.95 ordinary battle start 1600",
      "v095-ordinary-battle-start-1600.png",
      WIDE_DESKTOP,
      "Ordinary battle start at 1600x900 checks mid-desktop terrain and HUD density."
    );

    await useViewport(page, LAPTOP);
    await expectBattleHudAcceptance(page, `${group} ordinary battle start 1366`);
    await captureView(
      page,
      group,
      "v0.95 ordinary battle start 1366",
      "v095-ordinary-battle-start-1366.png",
      LAPTOP,
      "Ordinary battle start at 1366x768 keeps primary HUD and minimap readable."
    );

    await useViewport(page, WIDE_DESKTOP);
    await stageV095FogRoadWaterView(page);
    await expectBattleHudAcceptance(page, `${group} fog road water 1600`);
    await captureView(
      page,
      group,
      "v0.95 fog roads water",
      "v095-fog-roads-water-1600.png",
      WIDE_DESKTOP,
      "Fog, roads, water, and terrain patches remain distinct without changing fog logic."
    );

    await useViewport(page, FULL_HD);
    await selectHeroForVisualQa(page);
    await captureView(
      page,
      group,
      "v0.95 selected hero",
      "v095-selected-hero-1920.png",
      FULL_HD,
      "Hero placeholder silhouette and label priority are readable against terrain."
    );

    await useViewport(page, WIDE_DESKTOP);
    await trainAndSelectWorkerForVisualQa(page);
    await captureView(
      page,
      group,
      "v0.95 selected Worker",
      "v095-selected-worker-1600.png",
      WIDE_DESKTOP,
      "Worker placeholder silhouette reads as utility while selected label and command context remain clear."
    );

    await useViewport(page, LAPTOP);
    await selectUnitTypeForVisualQa(page, "militia", "player");
    await captureView(
      page,
      group,
      "v0.95 selected melee",
      "v095-selected-melee-1366.png",
      LAPTOP,
      "Militia frontline placeholder is distinct and selection feedback remains visible at 1366x768."
    );

    await useViewport(page, WIDE_DESKTOP);
    await selectUnitTypeForVisualQa(page, "ranger", "player");
    await captureView(
      page,
      group,
      "v0.95 selected ranged",
      "v095-selected-ranged-1600.png",
      WIDE_DESKTOP,
      "Ranger ranged placeholder uses a slimmer chevron silhouette with quieter routine labels."
    );

    await useViewport(page, LAPTOP);
    await selectUnitTypeForVisualQa(page, "raider", "enemy");
    await captureView(
      page,
      group,
      "v0.95 selected enemy",
      "v095-selected-enemy-1366.png",
      LAPTOP,
      "Enemy placeholder silhouette stays readable after fog reveal without changing enemy behavior."
    );

    await useViewport(page, FULL_HD);
    await selectCommandHall(page);
    await captureView(
      page,
      group,
      "v0.95 selected building",
      "v095-selected-building-1920.png",
      FULL_HD,
      "Command Hall placeholder building silhouette and minimap marker remain readable."
    );

    const siteStates: Array<["neutral" | "player" | "enemy" | "contested" | "objective", string, string, VisualViewport]> = [
      ["neutral", "v0.95 neutral capture site", "v095-site-neutral-1600.png", WIDE_DESKTOP],
      ["player", "v0.95 player capture site", "v095-site-player-1366.png", LAPTOP],
      ["enemy", "v0.95 enemy capture site", "v095-site-enemy-1600.png", WIDE_DESKTOP],
      ["contested", "v0.95 contested capture site", "v095-site-contested-1366.png", LAPTOP],
      ["objective", "v0.95 objective capture site", "v095-site-objective-1920.png", FULL_HD]
    ];
    for (const [state, title, fileName, viewport] of siteStates) {
      await useViewport(page, viewport);
      await stageCaptureSiteVisualState(page, state);
      await expectBattleHudAcceptance(page, `${group} ${state} capture site`);
      await captureView(
        page,
        group,
        title,
        fileName,
        viewport,
        `${state} capture-site state checks ownership ring, label priority, and minimap readability.`
      );
    }

    await useViewport(page, FULL_HD);
    await startNewCampaign(page, "Visual v095 Lume");
    await page.getByTestId("campaign-node-aether_well_ruins").click();
    await clickReady(page.getByTestId("campaign-private-lume-demo"), `${group} start private Lume demo`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expectBattleLoaded(page, `${group} Lume demo start`);
    await centerCaptureSite(page, "west_stone_cut", true);
    await centerCaptureSite(page, "ford_toll", true);
    await expect(page.getByTestId("lume-network-status")).toContainText("LUME WARD ACTIVE");
    await captureView(
      page,
      group,
      "v0.95 Lume active Auto",
      "v095-lume-auto-1920.png",
      FULL_HD,
      "Lume active Auto mode remains readable over rescued placeholder terrain."
    );

    await useViewport(page, WIDE_DESKTOP);
    await page.getByTestId("lume-visibility-hidden").click();
    await captureView(
      page,
      group,
      "v0.95 Lume Hidden",
      "v095-lume-hidden-1600.png",
      WIDE_DESKTOP,
      "Lume Hidden mode keeps the battle shell and minimap readable without link clutter."
    );

    await useViewport(page, LAPTOP);
    await page.getByTestId("lume-visibility-always").click();
    await captureView(
      page,
      group,
      "v0.95 Lume Always",
      "v095-lume-always-1366.png",
      LAPTOP,
      "Lume Always mode remains a deliberate review posture while terrain and labels stay legible."
    );

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures v0.97 selection, command marker, and camera feedback polish", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "v097-tactical-feedback-polish";
    const consoleErrors = attachConsoleCollector(page, group);

    await useViewport(page, FULL_HD);
    await startNewCampaign(page, "Visual v097 Battle");
    await clickReady(page.getByTestId("campaign-start-node"), `${group} start ordinary battle`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expectBattleHudAcceptance(page, `${group} battle start`);

    await selectHeroForVisualQa(page);
    await expect(page.getByTestId("selection-focus-summary")).toContainText("Hero selected");
    await captureView(
      page,
      group,
      "v0.97 selected hero focus",
      "v097-selected-hero-focus-1920.png",
      FULL_HD,
      "Hero selection has a distinct champion focus card and concise order summary."
    );

    await useViewport(page, WIDE_DESKTOP);
    await trainAndSelectWorkerForVisualQa(page);
    await expect(page.getByTestId("selection-focus-summary")).toContainText("Worker selected");
    await captureView(
      page,
      group,
      "v0.97 selected Worker focus",
      "v097-selected-worker-focus-1600.png",
      WIDE_DESKTOP,
      "Worker selection emphasizes utility commands without turning into a prose wall."
    );

    await useViewport(page, LAPTOP);
    await selectFirstPlayerArmy(page);
    await expect(page.getByTestId("selection-focus-summary")).toContainText("Squad selected");
    await captureView(
      page,
      group,
      "v0.97 selected squad focus",
      "v097-selected-squad-focus-1366.png",
      LAPTOP,
      "Multi-unit selection shows group count, roles, and current orders in a compact 1366x768 HUD."
    );

    await useViewport(page, FULL_HD);
    await selectCommandHall(page);
    await expect(page.getByTestId("selection-focus-summary")).toContainText("Building selected");
    await captureView(
      page,
      group,
      "v0.97 selected building focus",
      "v097-selected-building-focus-1920.png",
      FULL_HD,
      "Building selection uses a distinct focus card and keeps production/rally actions readable."
    );

    await useViewport(page, LAPTOP);
    await selectEnemyForV097Inspection(page);
    await captureView(
      page,
      group,
      "v0.97 enemy inspection focus",
      "v097-enemy-inspection-focus-1366.png",
      LAPTOP,
      "Enemy inspection reads as read-only target information and does not expose player behaviour controls."
    );

    await useViewport(page, WIDE_DESKTOP);
    await stageV097CommandMarkers(page);
    await captureView(
      page,
      group,
      "v0.97 command marker set",
      "v097-command-markers-1600.png",
      WIDE_DESKTOP,
      "Move, attack, Patrol, rally, build, ability, invalid, and focus markers are short-lived procedural canvas marks."
    );

    await useViewport(page, LAPTOP);
    await stageV097ReducedMotionMarker(page);
    await captureView(
      page,
      group,
      "v0.97 reduced-motion invalid marker",
      "v097-reduced-motion-invalid-marker-1366.png",
      LAPTOP,
      "Reduced-motion command feedback uses a static brief hold instead of animated flourish."
    );

    await page.evaluate(() => {
      const scene: any = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
      if (scene?.settings) {
        scene.settings.reducedMotionEnabled = false;
      }
    });
    await useViewport(page, WIDE_DESKTOP);
    await selectCommandHall(page);
    await page.locator(".command-tray .command-details summary").first().click();
    await expect(page.locator(".command-tray .command-details[open]").first()).toBeVisible();
    await captureView(
      page,
      group,
      "v0.97 command details disclosure",
      "v097-command-details-disclosure-1600.png",
      WIDE_DESKTOP,
      "Command panel keeps compact labels first while More Details carries longer command explanation."
    );

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures v0.104 HUD density and profiler-guided rendering states", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "v0104-hud-density-performance";
    const consoleErrors = attachConsoleCollector(page, group);

    await useViewport(page, LAPTOP);
    await launchPublicSkirmishBattle(page, "Visual v0104 Public");
    await expect(page.getByTestId("battle-hud-density-minimal")).toBeVisible();
    await expect(page.getByTestId("hud-density-controls")).toHaveCount(0);
    await captureView(page, group, "v0.104 public Minimal 1366", "v0104-public-battle-minimal-1366.png", LAPTOP, "Public battle launches with Minimal HUD density and no private density controls.");

    await useViewport(page, WIDE_DESKTOP);
    await captureView(page, group, "v0.104 public Minimal 1600", "v0104-public-battle-minimal-1600.png", WIDE_DESKTOP, "Public Minimal HUD remains compact at 1600x900.");

    await useViewport(page, FULL_HD);
    await captureView(page, group, "v0.104 public Minimal 1920", "v0104-public-battle-minimal-1920.png", FULL_HD, "Public Minimal HUD remains readable at 1920x1080.");

    await page.addInitScript(() => {
      Reflect.set(window, "__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__", true);
    });
    await useViewport(page, LAPTOP);
    await openPrivatePlaytestHub(page);
    await page.getByTestId("playtest-group-performance_lab").scrollIntoViewIfNeeded();
    await captureView(page, group, "v0.104 profiler disabled", "v0104-profiler-disabled-1366.png", LAPTOP, "Profiler remains disabled until explicitly toggled.");
    await page.getByTestId("private-performance-toggle").click();
    await expect(page.getByTestId("private-performance-panel")).toBeVisible();
    await page.waitForTimeout(650);
    await captureView(page, group, "v0.104 profiler enabled", "v0104-profiler-enabled-1366.png", LAPTOP, "Profiler panel records only after private toggle.");
    await page.getByTestId("private-performance-toggle").click();
    await openPrivatePlaytestHub(page);

    await launchPrivateHudScenario(page, "perf_hud_minimal");
    await expect(page.getByTestId("battle-hud-density-minimal")).toBeVisible();
    await captureView(page, group, "v0.104 private Minimal selected hero", "v0104-private-hud-minimal-selected-hero-1366.png", LAPTOP, "Private lab can inspect the public Minimal density with selected hero essentials.");
    await returnToPrivateHub(page);

    await launchPrivateHudScenario(page, "perf_selected_worker");
    await setPrivateHudDensity(page, "minimal");
    await captureView(page, group, "v0.104 Worker Minimal", "v0104-worker-minimal-1366.png", LAPTOP, "Selected Worker keeps utility commands usable in Minimal density.");
    await returnToPrivateHub(page);

    await launchPrivateHudScenario(page, "perf_selected_command_hall");
    await setPrivateHudDensity(page, "minimal");
    await captureView(page, group, "v0.104 building Minimal", "v0104-building-minimal-1366.png", LAPTOP, "Selected Command Hall keeps production controls usable in Minimal density.");
    await returnToPrivateHub(page);

    await launchPrivateHudScenario(page, "perf_hud_standard");
    await expect(page.getByTestId("battle-hud-density-standard")).toBeVisible();
    await captureView(page, group, "v0.104 private Standard", "v0104-private-hud-standard-1366.png", LAPTOP, "Private Standard density preserves full detail-review surfaces.");
    await useViewport(page, WIDE_DESKTOP);
    await captureView(page, group, "v0.104 private Standard 1600", "v0104-private-hud-standard-1600.png", WIDE_DESKTOP, "Private Standard density remains readable at 1600x900.");
    await useViewport(page, LAPTOP);
    await returnToPrivateHub(page);

    await launchPrivateHudScenario(page, "perf_hud_debug");
    await expect(page.getByTestId("battle-hud-density-debug")).toBeVisible();
    await expect(page.getByTestId("battle-hud-debug-counters")).toBeVisible();
    await captureView(page, group, "v0.104 private Debug", "v0104-private-hud-debug-1366.png", LAPTOP, "Private Debug density exposes rendering counters without saving state.");
    await useViewport(page, FULL_HD);
    await captureView(page, group, "v0.104 private Debug 1920", "v0104-private-hud-debug-1920.png", FULL_HD, "Private Debug density remains readable at 1920x1080.");
    await useViewport(page, LAPTOP);
    await returnToPrivateHub(page);

    await launchPrivateHudScenario(page, "perf_notification_heavy");
    await setPrivateHudDensity(page, "minimal");
    await captureView(page, group, "v0.104 urgent alert Minimal", "v0104-urgent-alert-minimal-1366.png", LAPTOP, "Minimal density preserves urgent battle status and critical alert posture.");
    await returnToPrivateHub(page);

    await launchPrivateHudScenario(page, "perf_lume_auto");
    await setPrivateHudDensity(page, "minimal");
    await captureView(page, group, "v0.104 Lume Auto Minimal", "v0104-lume-auto-minimal-1366.png", LAPTOP, "Lume Auto remains readable with optional detail copy hidden.");
    await returnToPrivateHub(page);

    await launchPrivateHudScenario(page, "perf_lume_hidden");
    await setPrivateHudDensity(page, "minimal");
    await captureView(page, group, "v0.104 Lume Hidden Minimal", "v0104-lume-hidden-minimal-1366.png", LAPTOP, "Hidden Lume overlay stays visually quiet in Minimal density.");
    await returnToPrivateHub(page);

    await launchPrivateHudScenario(page, "perf_lume_always");
    await expect(page.getByTestId("battle-hud-density-standard")).toBeVisible();
    await captureView(page, group, "v0.104 Lume Always Standard", "v0104-lume-always-standard-1366.png", LAPTOP, "Always-visible Lume inspection remains a private Standard-density review state.");
    await returnToPrivateHub(page);

    await launchPrivateHudScenario(page, "tutorial_proving_grounds");
    await setPrivateHudDensity(page, "minimal");
    await expect(page.getByTestId("tutorial-overlay")).toBeVisible();
    await captureView(page, group, "v0.104 Tutorial Minimal", "v0104-tutorial-guidance-minimal-1366.png", LAPTOP, "Tutorial guidance remains visible while the public battle HUD uses Minimal density.");
    await returnToPrivateHub(page);

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures v0.108 representative battle benchmark states", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "v0108-representative-battle-benchmark";
    const consoleErrors = attachConsoleCollector(page, group);
    await page.addInitScript(() => {
      Reflect.set(window, "__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__", true);
    });

    await useViewport(page, LAPTOP);
    await openPrivatePlaytestHub(page);
    await page.getByTestId("playtest-group-representative_battle_benchmark").scrollIntoViewIfNeeded();

    await launchPrivateHudScenario(page, "benchmark_battle_tier_s_smoke");
    await captureView(page, group, "v0.108 Tier S smoke", "v0108-benchmark-tier-s-smoke-1366.png", LAPTOP, "Tier S representative smoke with hero, Worker, two player military types, Ashen pressure, one Lume link, minimap, and no-save posture.");
    await returnToPrivateHub(page);

    await useViewport(page, WIDE_DESKTOP);
    await launchPrivateHudScenario(page, "benchmark_battle_tier_m_representative");
    await captureView(page, group, "v0.108 Tier M representative", "v0108-benchmark-tier-m-representative-1600.png", WIDE_DESKTOP, "Tier M representative battle posture for desktop acceptance discussion.");
    await returnToPrivateHub(page);

    await useViewport(page, FULL_HD);
    await launchPrivateHudScenario(page, "benchmark_battle_tier_l_stress");
    await captureView(page, group, "v0.108 Tier L stress", "v0108-benchmark-tier-l-stress-1920.png", FULL_HD, "Tier L stress remains private/local-only density evidence.");
    await returnToPrivateHub(page);

    await useViewport(page, LAPTOP);
    await launchPrivateHudScenario(page, "benchmark_battle_lume_hidden");
    await captureView(page, group, "v0.108 Lume Hidden", "v0108-benchmark-lume-hidden-1366.png", LAPTOP, "Representative Tier M with Lume Hidden mode for quieter overlay comparison.");
    await returnToPrivateHub(page);

    await useViewport(page, WIDE_DESKTOP);
    await launchPrivateHudScenario(page, "benchmark_battle_lume_auto");
    await captureView(page, group, "v0.108 Lume Auto", "v0108-benchmark-lume-auto-1600.png", WIDE_DESKTOP, "Representative Tier M with default Lume Auto mode.");
    await returnToPrivateHub(page);

    await useViewport(page, FULL_HD);
    await launchPrivateHudScenario(page, "benchmark_battle_lume_always");
    await captureView(page, group, "v0.108 Lume Always", "v0108-benchmark-lume-always-1920.png", FULL_HD, "Representative Tier M with Always-visible Lume inspection mode.");
    await returnToPrivateHub(page);

    await useViewport(page, LAPTOP);
    await launchPrivateHudScenario(page, "benchmark_battle_fog_heavy");
    await captureView(page, group, "v0.108 fog-heavy", "v0108-benchmark-fog-heavy-1366.png", LAPTOP, "Representative Tier M fog-heavy posture with minimap and objective surfaces visible.");
    await returnToPrivateHub(page);

    await useViewport(page, WIDE_DESKTOP);
    await launchPrivateHudScenario(page, "benchmark_battle_notification_heavy");
    await captureView(page, group, "v0.108 notification-heavy", "v0108-benchmark-notification-heavy-1600.png", WIDE_DESKTOP, "Representative Tier M notification-heavy posture with bounded Ashen pressure copy.");
    await returnToPrivateHub(page);

    await useViewport(page, LAPTOP);
    await launchPrivateHudScenario(page, "benchmark_battle_minimap_interaction");
    await captureView(page, group, "v0.108 minimap interaction", "v0108-benchmark-minimap-interaction-1366.png", LAPTOP, "Representative Tier M minimap interaction posture with focus marker evidence.");
    await returnToPrivateHub(page);

    await launchPrivateHudScenario(page, "benchmark_battle_results_transition");
    const transitioned = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.forceBattleVictory?.() ?? false);
    expect(transitioned).toBe(true);
    await expect(page.getByTestId("private-demo-lume-summary")).toBeVisible();
    await captureView(page, group, "v0.108 Results transition", "v0108-benchmark-results-transition-1366.png", LAPTOP, "Representative Tier M no-save battle-to-private-Results transition.");
    await clickReady(page.getByTestId("results-playtest-hub"), `${group} return from results`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expect(page.getByTestId("playtest-hub")).toBeVisible();

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures v0.106 runtime art slot fallback harness states", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "v0106-runtime-art-slot-fallbacks";
    const consoleErrors = attachConsoleCollector(page, group);

    await useViewport(page, LAPTOP);
    await launchPublicSkirmishBattle(page, "Visual v0106 Public");
    await expect(page.getByTestId("art-slot-diagnostics-toggle")).toHaveCount(0);
    await captureView(page, group, "v0.106 public diagnostics hidden", "v0106-art-slot-public-hidden-1366.png", LAPTOP, "Public battle has no runtime art slot diagnostics API or overlay.");

    await page.addInitScript(() => {
      Reflect.set(window, "__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__", true);
    });
    await useViewport(page, LAPTOP);
    await openPrivatePlaytestHub(page);
    await page.getByTestId("playtest-group-art_slot_fallbacks").scrollIntoViewIfNeeded();
    await expect(page.getByTestId("art-slot-diagnostics-toggle")).toBeVisible();
    await expect(page.getByTestId("art-slot-diagnostics-panel")).toBeHidden();
    await captureView(page, group, "v0.106 diagnostics off", "v0106-art-slot-diagnostics-off-1366.png", LAPTOP, "Private Playtest Hub shows Art Slot Fallbacks and diagnostics toggle without opening the panel.");

    await showArtSlotDiagnostics(page);
    await expect(page.getByTestId("art-slot-diagnostics-fallback-count")).toContainText("52");
    await captureView(page, group, "v0.106 diagnostics on", "v0106-art-slot-diagnostics-on-1366.png", LAPTOP, "Diagnostics panel lists all runtime art slots as placeholder fallbacks.");

    await useViewport(page, FULL_HD);
    await page.getByTestId("playtest-group-art_slot_fallbacks").scrollIntoViewIfNeeded();
    await captureView(page, group, "v0.106 diagnostics 1920", "v0106-art-slot-diagnostics-on-1920.png", FULL_HD, "Diagnostics panel remains readable at 1920x1080.");

    await useViewport(page, WIDE_DESKTOP);
    await page.getByTestId("playtest-group-art_slot_fallbacks").scrollIntoViewIfNeeded();
    await captureView(page, group, "v0.106 diagnostics 1600", "v0106-art-slot-diagnostics-on-1600.png", WIDE_DESKTOP, "Diagnostics panel remains readable at 1600x900.");
    await hideArtSlotDiagnostics(page);

    await useViewport(page, FULL_HD);
    await clickReady(page.getByTestId("playtest-scenario-art_slot_menu_fallback"), `${group} menu fallback`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expect(page.getByTestId("main-menu")).toBeVisible();
    await captureView(page, group, "v0.106 menu fallback", "v0106-art-slot-menu-fallback-1920.png", FULL_HD, "Main menu background, logo, and button-frame slots use CSS/DOM fallbacks.");
    await clickReady(page.getByTestId("main-menu-return-hub"), `${group} return from menu`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expect(page.getByTestId("playtest-hub")).toBeVisible();

    await useViewport(page, WIDE_DESKTOP);
    await clickReady(page.getByTestId("playtest-scenario-art_slot_campaign_fallback"), `${group} campaign fallback`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await captureView(page, group, "v0.106 campaign fallback", "v0106-art-slot-campaign-fallback-1600.png", WIDE_DESKTOP, "Campaign background, route, chapter, and node frame slots use CSS/DOM fallbacks.");
    await clickReady(page.getByTestId("campaign-playtest-hub-return"), `${group} return from campaign`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expect(page.getByTestId("playtest-hub")).toBeVisible();

    await useViewport(page, LAPTOP);
    await launchPrivateHudScenario(page, "art_slot_battlefield_terrain_fallback");
    await captureView(page, group, "v0.106 battlefield terrain fallback", "v0106-art-slot-battlefield-terrain-fallback-1366.png", LAPTOP, "Battlefield terrain, fog, minimap, capture, and objective slots use procedural fallbacks.");
    await returnToPrivateHub(page);

    await launchPrivateHudScenario(page, "art_slot_unit_fallback");
    await expect(page.getByTestId("unit-order-summary")).toBeVisible();
    await captureView(page, group, "v0.106 unit fallback", "v0106-art-slot-unit-fallback-1366.png", LAPTOP, "Unit slots use placeholder silhouettes with selection and command panel fallbacks.");
    await returnToPrivateHub(page);

    await launchPrivateHudScenario(page, "art_slot_building_fallback");
    await expect(page.getByTestId("battle-hud")).toBeVisible();
    await captureView(page, group, "v0.106 building fallback", "v0106-art-slot-building-fallback-1366.png", LAPTOP, "Building and construction-state slots use placeholder building shapes and CSS command frames.");
    await returnToPrivateHub(page);

    await launchPrivateHudScenario(page, "art_slot_lume_fallback");
    await expect(page.getByTestId("lume-network-status")).toBeVisible();
    await captureView(page, group, "v0.106 Lume fallback", "v0106-art-slot-lume-fallback-1366.png", LAPTOP, "Lume endpoint, link, and transition slots use existing vector fallbacks.");
    await returnToPrivateHub(page);

    await launchPrivateHudScenario(page, "art_slot_hud_fallback");
    await expect(page.getByTestId("battle-minimap")).toBeVisible();
    await captureView(page, group, "v0.106 HUD fallback", "v0106-art-slot-hud-fallback-1366.png", LAPTOP, "HUD and command-panel frame slots use CSS fallbacks with diagnostics still private.");
    await returnToPrivateHub(page);

    await clickReady(page.getByTestId("playtest-scenario-art_slot_results_fallback"), `${group} results fallback`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expect(page.getByTestId("results-overview")).toBeVisible();
    await captureView(page, group, "v0.106 Results fallback", "v0106-art-slot-results-fallback-1366.png", LAPTOP, "Results, hero, relic, stronghold, intel, and reputation frame slots remain CSS/DOM fallbacks.");
    await clickReady(page.getByTestId("results-playtest-hub"), `${group} return from results`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expect(page.getByTestId("playtest-hub")).toBeVisible();

    await enableArtSlotMockMode(page);
    await showArtSlotDiagnostics(page);
    await launchPrivateHudScenario(page, "art_slot_mock_routing");
    await expect(page.getByTestId("art-slot-diagnostics-mock-count")).toContainText("52");
    await captureView(page, group, "v0.106 private mock routing", "v0106-art-slot-mock-routing-1366.png", LAPTOP, "Private mock routing mode uses diagnostic styling without loading or approving runtime art.");

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures v0.90 ordinary Results and Tutorial acceptance matrix", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "v090-results-tutorial-acceptance";
    const consoleErrors = attachConsoleCollector(page, group);

    await useViewport(page, WIDE_DESKTOP);
    await openFreshMainMenu(page);
    await showVisualQaResults(page, "victory");
    await expectResultsPrimaryActionsAboveFold(page, `${group} victory results 1600`);
    await captureView(
      page,
      group,
      "v0.90 normal Victory Results",
      "v090-normal-victory-results-1600.png",
      WIDE_DESKTOP,
      "Ordinary victory Results at 1600x900 with outcome, mission, rewards, XP, veterans, and actions above full details."
    );

    await useViewport(page, LAPTOP);
    await openFreshMainMenu(page);
    await showVisualQaResults(page, "defeat");
    await expectResultsPrimaryActionsAboveFold(page, `${group} defeat results 1366`);
    await captureView(
      page,
      group,
      "v0.90 normal Defeat Results",
      "v090-normal-defeat-results-1366.png",
      LAPTOP,
      "Ordinary defeat Results at 1366x768 with retry/prep actions visible before full battle details."
    );

    await useViewport(page, WIDE_DESKTOP);
    await openFreshMainMenu(page);
    await showVisualQaResults(page, "victory", true);
    await expectResultsPrimaryActionsAboveFold(page, `${group} replay results 1600`);
    await captureView(
      page,
      group,
      "v0.90 replay Results",
      "v090-replay-results-1600.png",
      WIDE_DESKTOP,
      "Replay Results at 1600x900 keep replay-safe reward language and visible return/replay actions."
    );

    await useViewport(page, WIDE_DESKTOP);
    await openFreshMainMenu(page);
    await clickReady(page.getByTestId("menu-tutorial"), `${group} tutorial launch`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expectBattleLoaded(page, `${group} tutorial launch`);
    await expect(page.getByTestId("tutorial-overlay")).toBeVisible();
    await expectBattleHudAcceptance(page, `${group} tutorial 1600`);
    await captureView(
      page,
      group,
      "v0.90 Tutorial",
      "v090-tutorial-1600.png",
      WIDE_DESKTOP,
      "Tutorial battle at 1600x900 keeps overlay, objectives, minimap, and command panel readable."
    );

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures v0.84 guided private Lume demo views", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "v084-guided-private-lume";
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
    await captureView(
      page,
      group,
      "v0.87 campaign shell 1920",
      "v087-campaign-shell-1920.png",
      FULL_HD,
      "Second-polish campaign shell at 1920x1080: enlarged map, chapter lanes, selected Salto Outskirts, and primary action visible."
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
    await captureView(
      page,
      group,
      "v0.87 campaign shell 1366",
      "v087-campaign-shell-1366.png",
      LAPTOP,
      "Second-polish campaign shell at 1366x768 with no default map-tab page scroll and compact selected mission panel."
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
    await captureView(
      page,
      group,
      "v0.87 locked Aether Well preview",
      "v087-aether-well-preview-1920.png",
      FULL_HD,
      "Locked Aether Well preview keeps the primary action disabled while More Details holds extended briefing text."
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

    await clickReady(page.getByTestId("campaign-private-lume-demo"), `${group} start private Lume demo`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expectBattleLoaded(page, `${group} private Lume demo start`);
    await expect(page.getByTestId("private-playtest-demo-warning")).toBeVisible();
    await captureView(
      page,
      group,
      "Private Lume demo HUD",
      "v084-private-lume-hud-1920.png",
      FULL_HD,
      "Private Aether Well Lume demo battle HUD with compact no-save ribbon, Lume tracker, focus controls, and Exit Demo."
    );

    await page.getByTestId("lume-visibility-hidden").click();
    await expect(page.getByTestId("lume-visibility-controls")).toContainText("Links: Hidden");
    await captureView(
      page,
      group,
      "Private Lume demo hidden links",
      "v085-private-lume-hidden-links-1920.png",
      FULL_HD,
      "Private Lume demo with stable link overlay hidden while HUD guidance remains visible."
    );

    await page.getByTestId("lume-visibility-always").click();
    await expect(page.getByTestId("lume-visibility-controls")).toContainText("Links: Always");
    await captureView(
      page,
      group,
      "Private Lume demo always links",
      "v085-private-lume-always-links-1920.png",
      FULL_HD,
      "Private Lume demo with all eligible links visible for deliberate overlay inspection."
    );
    await page.getByTestId("lume-visibility-auto").click();

    await centerCaptureSite(page, "west_stone_cut", true);
    await centerCaptureSite(page, "ford_toll", true);
    await expect(page.getByTestId("lume-network-status")).toContainText("LUME WARD ACTIVE");
    await expect(page.getByTestId("private-demo-finish")).toBeVisible();
    await expect(page.getByTestId("lume-focus-north_aether_spring")).toBeVisible();
    await captureView(
      page,
      group,
      "Private Lume demo linked ward active",
      "v084-private-lume-active-1920.png",
      FULL_HD,
      "Linked Ward activated in the private demo with optional North Aether focus and Finish Demo action visible."
    );

    await useViewport(page, LAPTOP);
    await captureView(
      page,
      group,
      "Private Lume demo laptop HUD",
      "v084-private-lume-hud-1366.png",
      LAPTOP,
      "Private demo HUD at 1366x768 with warning and Lume row still readable."
    );

    await page.getByTestId("private-demo-finish").click();
    await expect(page.locator(".results-panel")).toBeVisible();
    await expect(page.getByTestId("private-demo-lume-summary")).toContainText("LUME NETWORK SUMMARY");
    await captureView(
      page,
      group,
      "Private Lume demo Results rescue",
      "v085-private-lume-results-1366.png",
      LAPTOP,
      "Private demo Results show a no-save heading, Lume summary, and primary actions before full telemetry."
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
    await useViewport(page, FULL_HD);
    await launchCinderfenCrossing(page, { battleLoadTimeoutMs: VISUAL_QA_BATTLE_LOAD_TIMEOUT_MS });
    await stageV086BattlefieldShell(page);
    await captureView(
      page,
      group,
      "v0.86 battlefield shell 1920",
      "v086-battlefield-shell-1920.png",
      FULL_HD,
      "Compact Command Hall actions, capture-site label chips, fog softness, and minimap markers at 1920x1080."
    );
    await useViewport(page, LAPTOP);
    await stageV086BattlefieldShell(page);
    await captureView(
      page,
      group,
      "v0.86 battlefield shell 1366",
      "v086-battlefield-shell-1366.png",
      LAPTOP,
      "Compact battlefield shell at 1366x768 with right-side actions, objective tracker, capture labels, and minimap legibility."
    );
    await useViewport(page, DESKTOP);
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
    await clickReady(page.getByRole("button", { name: "Replay Battle" }), `${group} replay battle`, VISUAL_QA_SCENE_TRANSITION_CLICK_OPTIONS);
    await expectBattleLoaded(page, `${group} replay battle`);
    await completeCinderfenVictory(page);
    await captureView(
      page,
      group,
      "v0.87 Results replay",
      "v087-results-replay-desktop.png",
      DESKTOP,
      "Replay Results retain the compact overview, replay-safe reward copy, and collapsed full battle details."
    );

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });

  test("captures Cinderfen Watch battle and defeat review views", async ({ page }) => {
    test.setTimeout(VISUAL_QA_GROUP_TIMEOUT_MS);
    const group = "cinderfen-watch";
    const consoleErrors = attachConsoleCollector(page, group);

    await seedPostCinderfenCrossingCampaign(page);
    await continueSavedCampaign(page);
    await launchCinderfenWatch(page, { battleLoadTimeoutMs: VISUAL_QA_BATTLE_LOAD_TIMEOUT_MS });
    await captureView(page, group, "Cinderfen Watch launch", "cinderfen-watch-desktop.png", DESKTOP, "Cinderfen Watch initial battle view.");
    await triggerWatchPressureWarning(page);
    await captureView(page, group, "Cinderfen Watch pressure warning", "cinderfen-watch-pressure-desktop.png", DESKTOP, "Watch Road pressure status warning visible.");
    await forceBattleDefeat(page);
    await captureView(page, group, "Results defeat", "results-defeat-desktop.png", DESKTOP, "Cinderfen Watch defeat results and guidance tips.");
    await useViewport(page, LAPTOP);
    await captureView(
      page,
      group,
      "v0.87 Results defeat 1366",
      "v087-results-defeat-1366.png",
      LAPTOP,
      "Normal defeat Results at 1366x768 keep retry and prep actions above collapsed full battle details."
    );

    expect(consoleErrors, `${group}: visual QA should not record browser console errors`).toEqual([]);
  });
});
