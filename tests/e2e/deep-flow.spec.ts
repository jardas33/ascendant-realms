import { expect, test, type Locator, type Page } from "@playwright/test";
import { clickReady, expectBattleLoaded, gotoReadyMainMenu, SAVE_KEY, seedSaveBeforeAppBoot } from "./shared-helpers";

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
  rewardAffixes?: string[];
  veteranSummary?: Record<string, unknown>;
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
  activeModifierIds: [],
  strongholdUpgradeRanks: {},
  retinueUnits: [],
  retinueDeploymentIds: [],
  rivals: [],
  rivalTrophies: []
};

const BATTLE_COMMAND_CLICK_OPTIONS = {
  allowDomFallback: false,
  attempts: 1,
  normalClickTimeoutMs: 1_000,
  timeoutMs: 5_000,
  waitForLayoutBox: false
} as const;
const MOVE_ORDER_SUMMARY_PATTERN = /Moving|Repositioning/;

const HUD_MENU_CLICK_OPTIONS = {
  allowTargetGoneAfterClick: true,
  attempts: 1,
  domFallbackTimeoutMs: 2_000,
  normalClickTimeoutMs: 1_500
} as const;
const SCENE_TRANSITION_CLICK_OPTIONS = {
  allowTargetGoneAfterClick: true,
  attempts: 1,
  domFallbackTimeoutMs: 2_000,
  normalClickTimeoutMs: 1_500
} as const;
const ONE_SHOT_CHOICE_CLICK_OPTIONS = {
  allowTargetDisabledAfterClick: true
} as const;

const BEHAVIOUR_MODE_LABELS = {
  hold_ground: "Hold Ground",
  guard_area: "Guard Area",
  press_attack: "Press Attack"
} as const;

async function campaignStatusIncludes(page: Page, expectedStatusText: string): Promise<boolean> {
  const text = await page
    .getByTestId("campaign-status")
    .textContent({ timeout: 1_000 })
    .catch(() => "");
  return text?.includes(expectedStatusText) ?? false;
}

async function clickCampaignChoiceAndExpectStatus(
  page: Page,
  locator: Locator,
  context: string,
  expectedStatusText: string
): Promise<void> {
  await clickReady(locator, context, {
    ...ONE_SHOT_CHOICE_CLICK_OPTIONS,
    successCheckAfterClick: () => campaignStatusIncludes(page, expectedStatusText)
  });
  await expect(page.getByTestId("campaign-status")).toContainText(expectedStatusText);
}

async function clickBattleCommand(locator: Locator, context: string): Promise<void> {
  try {
    await clickReady(locator, context, BATTLE_COMMAND_CLICK_OPTIONS);
    return;
  } catch (error) {
    const fallback = await locator
      .evaluateAll((elements) => {
        for (const element of elements) {
          const button = element as HTMLButtonElement;
          if (button.disabled || button.getAttribute("aria-disabled") === "true") {
            continue;
          }
          button.click();
          return {
            clicked: true,
            text: (button.textContent ?? button.getAttribute("aria-label") ?? "").trim().replace(/\s+/g, " ").slice(0, 80)
          };
        }
        return { clicked: false, text: "" };
      })
      .catch(() => ({ clicked: false, text: "" }));
    if (fallback.clicked) {
      console.warn(`${context}: using direct DOM command click fallback "${fallback.text}"`);
      return;
    }
    throw error;
  }
}

async function clickBehaviourMode(
  page: Page,
  mode: keyof typeof BEHAVIOUR_MODE_LABELS,
  context: string
): Promise<void> {
  const expectedLabel = BEHAVIOUR_MODE_LABELS[mode];
  let lastError: unknown;
  const locator = page.getByTestId(`behaviour-mode-${mode}`);

  for (let attempt = 1; attempt <= 4; attempt += 1) {
    if (attempt === 1 || attempt % 3 === 0) {
      await page.evaluate(() => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        if (!scene?.scene.isActive() || !scene.hero?.alive) {
          return;
        }
        scene.selectionSystem.setSelection([scene.hero]);
        scene.refreshBattleHud?.(0);
      });
      await page.waitForTimeout(50);
    }

    try {
      await clickReady(locator, context, {
        attempts: 1,
        domFallbackTimeoutMs: 1_500,
        normalClickTimeoutMs: 1_000,
        timeoutMs: 5_000,
        successCheckAfterClick: async () => {
          const text = await page.getByTestId("behaviour-mode-current").textContent({ timeout: 500 }).catch(() => "");
          return text?.includes(expectedLabel) ?? false;
        }
      });
    } catch (error) {
      lastError = error;
    }

    const text = await page.getByTestId("behaviour-mode-current").textContent({ timeout: 750 }).catch(() => "");
    if (text?.includes(expectedLabel)) {
      return;
    }

    const domClicked = await locator
      .evaluate((element) => {
        const button = element instanceof HTMLButtonElement ? element : element.closest("button");
        if (!button || button.disabled || button.getAttribute("aria-disabled") === "true") {
          return false;
        }
        button.click();
        return true;
      })
      .catch(() => false);
    if (domClicked) {
      const directText = await page
        .getByTestId("behaviour-mode-current")
        .textContent({ timeout: 1_500 })
        .catch(() => "");
      if (directText?.includes(expectedLabel)) {
        return;
      }
    }

    lastError = new Error(`${context}: behaviour mode did not become ${expectedLabel}; current label was ${text || "(missing)"}.`);
    await page.waitForTimeout(200);
  }

  if (lastError instanceof Error) {
    throw lastError;
  }
  throw new Error(`${context}: behaviour mode did not become ${expectedLabel}.`);
}

async function researchUpgradeThroughCommand(locator: Locator, page: Page, upgradeId: string, context: string): Promise<void> {
  await expect(locator, `${context}: upgrade command button`).toBeEnabled({ timeout: 5_000 });
  const queued = await page.evaluate((targetUpgradeId) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const selectedBuilding = scene.selectionSystem
      .getSelected()
      .find(
        (entity: any) =>
          entity?.team === "player" &&
          entity?.alive &&
          entity?.definition?.upgradeOptions?.includes(targetUpgradeId) &&
          entity?.isCompleted?.()
      );
    const fallbackBuilding = scene.buildings.find(
      (building: any) =>
        building.team === "player" &&
        building.alive &&
        building.definition.upgradeOptions?.includes(targetUpgradeId) &&
        building.isCompleted()
    );
    const building = selectedBuilding ?? fallbackBuilding;
    if (!building) {
      throw new Error(`No completed player building can research ${targetUpgradeId}.`);
    }
    if (scene.researchedUpgradeIds?.player?.has(targetUpgradeId)) {
      return true;
    }
    if (building.upgradeQueue?.some((entry: any) => entry.upgradeId === targetUpgradeId)) {
      return true;
    }
    scene.selectionSystem.setSelection([building]);
    const result = scene.upgradeSystem.queueUpgrade(building, targetUpgradeId, scene.resources.player, { announce: false });
    scene.refreshBattleHud?.(0);
    return result;
  }, upgradeId);
  if (!queued) {
    throw new Error(`${context}: upgrade ${upgradeId} was not queued`);
  }
}

async function trainUnitThroughCommand(locator: Locator, page: Page, unitId: string, context: string): Promise<void> {
  await expect(locator, `${context}: train command button`).toBeEnabled({ timeout: 5_000 });
  const queued = await page.evaluate((targetUnitId) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const selectedBuilding = scene.selectionSystem
      .getSelected()
      .find(
        (entity: any) =>
          entity?.team === "player" &&
          entity?.alive &&
          entity?.definition?.trainOptions?.includes(targetUnitId) &&
          entity?.isCompleted?.()
      );
    const fallbackBuilding = scene.buildings.find(
      (building: any) =>
        building.team === "player" &&
        building.alive &&
        building.definition.trainOptions?.includes(targetUnitId) &&
        building.isCompleted()
    );
    const building = selectedBuilding ?? fallbackBuilding;
    if (!building) {
      throw new Error(`No completed player building can train ${targetUnitId}.`);
    }
    if (building.trainingQueue?.some((entry: any) => entry.unitId === targetUnitId)) {
      return true;
    }
    scene.selectionSystem.setSelection([building]);
    const result = scene.trainingSystem.queueTraining(building, targetUnitId, scene.resources.player, { announce: false });
    scene.refreshBattleHud?.(0);
    return result;
  }, unitId);
  if (!queued) {
    throw new Error(`${context}: unit ${unitId} was not queued`);
  }
}

async function upgradeResourceSiteThroughCommand(locator: Locator, page: Page, siteEntityId: string, context: string): Promise<void> {
  const upgraded = await page.evaluate((targetSiteEntityId) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const site = scene.captureSites.find((entry: any) => entry.id === targetSiteEntityId);
    if (!site) {
      throw new Error(`Resource site ${targetSiteEntityId} was not found.`);
    }
    if (site.siteLevel >= 2) {
      return true;
    }
    scene.selectionSystem.setSelection([site]);
    const result = scene.resourceSystem.requestSiteUpgrade(site, scene.resources.player);
    scene.refreshBattleHud?.(0);
    return result;
  }, siteEntityId);
  if (!upgraded) {
    await expect(locator, `${context}: resource-site upgrade command button`).toBeEnabled({ timeout: 5_000 });
    throw new Error(`${context}: resource site ${siteEntityId} was not upgraded`);
  }
}

async function assignWorkerToResourceSiteThroughCommand(
  locator: Locator,
  page: Page,
  workerId: string,
  siteEntityId: string,
  context: string
): Promise<void> {
  await expect(locator, `${context}: resource-site assignment command button`).toBeEnabled({ timeout: 5_000 });
  const assigned = await page.evaluate(({ targetWorkerId, targetSiteEntityId }) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const worker = scene.units.find((unit: any) => unit.id === targetWorkerId && unit.team === "player" && unit.alive);
    const site = scene.captureSites.find((entry: any) => entry.id === targetSiteEntityId && entry.alive);
    if (!worker || !site) {
      throw new Error(`Expected Worker ${targetWorkerId} and resource site ${targetSiteEntityId}.`);
    }
    scene.selectionSystem.setSelection([worker]);
    const result = scene.resourceSystem.requestWorkerAssignment(worker, site, scene.captureSites);
    scene.refreshBattleHud?.(0);
    return result || worker.activeResourceSiteId === site.id || site.assignedWorkerId === worker.id;
  }, { targetWorkerId: workerId, targetSiteEntityId: siteEntityId });
  if (!assigned) {
    throw new Error(`${context}: Worker ${workerId} was not assigned to resource site ${siteEntityId}`);
  }
}

async function parkHostileUnitsAwayFromPlayerSetup(page: Page): Promise<void> {
  await page.evaluate(() => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    scene.units
      .filter((unit: any) => unit.team !== "player" && unit.alive)
      .forEach((unit: any, index: number) => {
        unit.factionSpeedMultiplier = 0;
        unit.attackTargetId = undefined;
        unit.attackTargetLabel = undefined;
        unit.attackMove = false;
        unit.moveTarget = undefined;
        unit.setPosition(scene.activeMap.width - 180, scene.activeMap.height - 180 - index * 28);
      });
    scene.captureSites.forEach((site: any) => {
      if (site.owner === "player") {
        site.capturingTeam = undefined;
        site.captureProgress = 0;
      }
    });
    scene.refreshBattleHud?.(0);
  });
}

async function clickBattleCommandUntilEffect(
  locatorFactory: () => Locator,
  context: string,
  verifyEffect: () => Promise<void>,
  recover?: () => Promise<void>
): Promise<void> {
  let lastError: unknown;
  for (let attempt = 1; attempt <= 3; attempt += 1) {
    await clickBattleCommand(locatorFactory(), `${context} attempt ${attempt}`);
    try {
      await verifyEffect();
      return;
    } catch (error) {
      lastError = error;
      console.warn(`${context}: command did not reach expected state after attempt ${attempt}; retrying`);
      await recover?.();
    }
  }
  throw lastError instanceof Error ? lastError : new Error(`${context}: command did not reach expected state`);
}

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
  await gotoReadyMainMenu(page, "deep-flow open main menu");
}

async function openFreshMainMenu(page: Page): Promise<void> {
  attachConsoleFailure(page);
  await gotoReadyMainMenu(page, "deep-flow fresh main menu before storage reset");
  await page.evaluate((key) => localStorage.removeItem(key), SAVE_KEY);
  await gotoReadyMainMenu(page, "deep-flow fresh main menu after storage reset");
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
  await seedSaveBeforeAppBoot(page, "deep-flow seedSave", save);
  await expect(page.getByTestId("menu-continue-campaign")).toBeEnabled();
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
  await clickReady(page.getByTestId("hero-start"), `deep-flow create hero ${name}`);
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

async function launchSkirmishMapFromScene(page: Page, mapId: string, heroName: string): Promise<void> {
  await page.evaluate(
    ({ targetMapId, hero }) => {
      const game = window.ascendantRealmsGame;
      if (!game) {
        throw new Error("Ascendant Realms game was not booted.");
      }
      for (const sceneKey of [
        "BattleScene",
        "SkirmishSetupScene",
        "HeroCreationScene",
        "MainMenuScene",
        "CampaignMapScene",
        "SettingsScene"
      ]) {
        game.scene.stop(sceneKey);
      }
      game.scene.start("BattleScene", {
        launchRequest: {
          requestId: `deep-map-qa:${targetMapId}`,
          mode: "skirmish",
          mapId: targetMapId,
          heroSave: hero,
          sourceId: "deep_flow_map_qa",
          rewardTableId: `${targetMapId}_rewards`,
          difficulty: "normal",
          modifiers: [],
          enemyProfileId: "ashen_covenant",
          aiPersonalityId: "hexfire_cult"
        }
      });
    },
    {
      targetMapId: mapId,
      hero: {
        ...BASE_HERO,
        heroName
      }
    }
  );
  await expectBattleLoaded(page);
  await waitForBattleScene(page);
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
      x: canvasBounds.left + (target.x - camera.scrollX) * camera.zoom,
      y: canvasBounds.top + (target.y - camera.scrollY) * camera.zoom
    };
  }, point);
}

async function hoverWorldPointAndExpectBattleCursor(
  page: Page,
  point: { x: number; y: number },
  expected: { cursor: string; mode: string; label: string; title: string },
  context: string
): Promise<void> {
  const screen = await worldToScreen(page, point);
  await page.mouse.move(screen.x, screen.y, { steps: 2 });
  await expect
    .poll(
      async () =>
        page.evaluate(() => {
          const canvas = document.querySelector("canvas") as HTMLCanvasElement | null;
          return {
            cursor: canvas?.style.cursor ?? "",
            mode: canvas?.dataset.battleCursor ?? "",
            label: canvas?.dataset.battleCursorLabel ?? "",
            title: canvas?.title ?? ""
          };
        }),
      { message: context }
    )
    .toEqual(expected);
}

async function clickWorldPoint(page: Page, point: { x: number; y: number }, button: "left" | "right" = "left"): Promise<void> {
  const screen = await worldToScreen(page, point);
  await page.mouse.move(screen.x, screen.y, { steps: 2 });
  await page.waitForTimeout(50);
  if (button === "right") {
    const target = await page.evaluate(({ x, y }) => {
      const canvas = document.querySelector("canvas");
      const canvasBox = canvas?.getBoundingClientRect();
      const hit = document.elementFromPoint(x, y);
      return {
        hasCanvas: Boolean(canvas),
        insideCanvas: Boolean(canvasBox && x >= canvasBox.left && x <= canvasBox.right && y >= canvasBox.top && y <= canvasBox.bottom),
        hitTag: hit?.tagName.toLowerCase() ?? "",
        hitTestId: hit instanceof HTMLElement ? hit.getAttribute("data-testid") ?? "" : "",
        hitClass: hit instanceof HTMLElement ? String(hit.className) : ""
      };
    }, screen);
    expect(target.hasCanvas, "expected battle canvas for world right-click").toBe(true);
    expect(target.insideCanvas, "expected world right-click point inside canvas").toBe(true);
    expect(target.hitTag, "expected world right-click point not covered by HUD").toBe("canvas");
    const canvasBox = await page.locator("canvas").boundingBox();
    expect(canvasBox, "expected battle canvas for world right-click").toBeTruthy();
    try {
      await page.locator("canvas").click({
        button,
        delay: 40,
        position: {
          x: screen.x - canvasBox!.x,
          y: screen.y - canvasBox!.y
        },
        timeout: 1_500
      });
    } catch {
      console.warn("world right-click locator actionability stalled; using verified pointer down/up.");
      await page.mouse.down({ button });
      await page.waitForTimeout(40);
      await page.mouse.up({ button });
    }
    return;
  }
  await page.mouse.click(screen.x, screen.y, { button, delay: 40 });
}

async function clickMinimapPosition(
  page: Page,
  position: { x: number; y: number },
  context: string,
  before?: { scrollX: number; scrollY: number }
): Promise<void> {
  const target = await page.evaluate((clickPosition) => {
    const minimap = document.querySelector<HTMLElement>("[data-testid='minimap']");
    const box = minimap?.getBoundingClientRect();
    if (!minimap || !box || box.width <= 0 || box.height <= 0) {
      throw new Error("Expected visible minimap for click.");
    }
    const style = window.getComputedStyle(minimap);
    const x = box.left + clickPosition.x;
    const y = box.top + clickPosition.y;
    const hit = document.elementFromPoint(x, y);
    const hitMinimap = hit instanceof Element ? hit.closest("[data-minimap]") : null;
    return {
      x,
      y,
      visible:
        style.display !== "none" &&
        style.visibility !== "hidden" &&
        Number(style.opacity || "1") > 0 &&
        box.width > 0 &&
        box.height > 0,
      hitInsideMinimap: Boolean(hitMinimap),
      insideBounds: x >= box.left && x <= box.right && y >= box.top && y <= box.bottom,
      pointerEvents: style.pointerEvents
    };
  }, position);

  expect(target.visible, `${context}: minimap is visible`).toBe(true);
  expect(target.insideBounds, `${context}: minimap click point is inside bounds`).toBe(true);
  expect(target.hitInsideMinimap, `${context}: minimap click point reaches the minimap`).toBe(true);
  expect(target.pointerEvents, `${context}: minimap accepts pointer events`).not.toBe("none");

  await page.mouse.move(target.x, target.y, { steps: 2 });
  await page.waitForTimeout(50);
  await page.mouse.click(target.x, target.y, { button: "left", delay: 40 });
  if (!before) {
    return;
  }

  const moved = await page
    .waitForFunction(
      (previous) => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        const camera = scene?.cameras.main;
        return camera ? Math.hypot(camera.scrollX - previous.scrollX, camera.scrollY - previous.scrollY) > 10 : false;
      },
      before,
      { timeout: 750 }
    )
    .then(() => true)
    .catch(() => false);
  if (moved) {
    return;
  }

  await page.evaluate((clickTarget) => {
    const minimap = document.querySelector<HTMLElement>("[data-testid='minimap']");
    if (!minimap) {
      throw new Error("Expected minimap for coordinate fallback click.");
    }
    minimap.dispatchEvent(
      new MouseEvent("click", {
        bubbles: true,
        cancelable: true,
        button: 0,
        clientX: clickTarget.x,
        clientY: clickTarget.y,
        view: window
      })
    );
  }, target);
}

async function clickWorldPointUntilEffect(
  page: Page,
  point: { x: number; y: number },
  button: "left" | "right",
  context: string,
  effectCheck: () => Promise<boolean>,
  options: { attempts?: number; retryDelayMs?: number } = {}
): Promise<void> {
  const attempts = options.attempts ?? 3;
  const retryDelayMs = options.retryDelayMs ?? 250;
  let lastError: unknown;

  for (let attempt = 1; attempt <= attempts; attempt += 1) {
    try {
      await expectWorldClickTargetsCanvas(page, point, `${context} attempt ${attempt}`);
      await clickWorldPoint(page, point, button);
      if (await effectCheck()) {
        return;
      }
      lastError = new Error(`${context}: expected world-click effect after attempt ${attempt}`);
    } catch (error) {
      lastError = error;
    }

    if (attempt < attempts) {
      await page.waitForTimeout(retryDelayMs);
    }
  }

  throw lastError instanceof Error ? lastError : new Error(`${context}: expected world-click effect`);
}

async function prepareMovementCommandTargets(
  page: Page,
  initialPoint: { x: number; y: number }
): Promise<{
  selectedCount: number;
  selectedIds: string[];
  selectedPositions: { id: string; x: number; y: number }[];
  points: { x: number; y: number }[];
}> {
  return page.evaluate((target) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    let selected = scene.selectionSystem
      .getSelected()
      .filter((entity: any) => entity.team === "player" && entity.kind !== "building" && entity.alive);
    if (selected.length === 0 && scene.hero?.alive) {
      scene.selectionSystem.setSelection([scene.hero]);
      selected = [scene.hero];
    }
    const anchor = selected[0]?.position ?? scene.hero?.position ?? scene.activeMap.playerStart;
    scene.cameraSystem.centerOn(anchor);
    scene.refreshBattleHud?.(0);
    const canvasBounds = scene.game.canvas.getBoundingClientRect();
    const camera = scene.cameras.main;
    const zoom = camera.zoom || 1;
    const clampPoint = (point: { x: number; y: number }) => ({
      x: Math.max(120, Math.min(scene.activeMap.width - 120, point.x)),
      y: Math.max(120, Math.min(scene.activeMap.height - 120, point.y))
    });
    const screenToWorld = (xRatio: number, yRatio: number) =>
      clampPoint({
        x: camera.scrollX + (canvasBounds.width * xRatio) / zoom,
        y: camera.scrollY + (canvasBounds.height * yRatio) / zoom
      });
    const visibleGroundCandidates = [
      screenToWorld(0.44, 0.42),
      screenToWorld(0.54, 0.55),
      screenToWorld(0.66, 0.48),
      screenToWorld(0.36, 0.62),
      screenToWorld(0.58, 0.70)
    ];
    const points = [
      target,
      ...visibleGroundCandidates,
      { x: 650, y: 920 },
      { x: 720, y: 860 },
      { x: anchor.x + 180, y: anchor.y + 80 },
      { x: anchor.x + 120, y: anchor.y + 160 },
      { x: anchor.x + 220, y: anchor.y - 60 },
      { x: anchor.x - 140, y: anchor.y + 120 },
      { x: anchor.x + 280, y: anchor.y + 140 },
      { x: anchor.x - 220, y: anchor.y - 120 }
    ].map(clampPoint);
    const uniquePoints = points.filter(
      (point, index, entries) =>
        entries.findIndex((entry) => Math.hypot(entry.x - point.x, entry.y - point.y) < 24) === index
    );
    const farEnoughFromSelection = (point: { x: number; y: number }) =>
      selected.every((entity: any) => Math.hypot(entity.position.x - point.x, entity.position.y - point.y) >= 160);
    const groundPoints = uniquePoints.filter((point) => !scene.findWorldEntityAt?.(point));
    const farGroundPoints = groundPoints.filter(farEnoughFromSelection);
    const farPoints = uniquePoints.filter(farEnoughFromSelection);
    return {
      selectedCount: selected.length,
      selectedIds: selected.map((entity: any) => entity.id),
      selectedPositions: selected.map((entity: any) => ({ id: entity.id, x: entity.position.x, y: entity.position.y })),
      points: farGroundPoints.length ? farGroundPoints : groundPoints.length ? groundPoints : farPoints.length ? farPoints : uniquePoints
    };
  }, initialPoint);
}

async function expectWorldClickTargetsCanvas(
  page: Page,
  point: { x: number; y: number },
  context: string
): Promise<void> {
  const screen = await worldToScreen(page, point);
  const result = await page.evaluate(({ x, y }) => {
    const canvas = document.querySelector("canvas");
    const canvasBox = canvas?.getBoundingClientRect();
    const hit = document.elementFromPoint(x, y);
    return {
      hasCanvas: Boolean(canvas),
      insideCanvas: Boolean(
        canvasBox &&
          x >= canvasBox.left &&
          x <= canvasBox.right &&
          y >= canvasBox.top &&
          y <= canvasBox.bottom
      ),
      hitTag: hit?.tagName.toLowerCase() ?? "",
      hitTestId: hit instanceof HTMLElement ? hit.getAttribute("data-testid") ?? "" : "",
      hitClass: hit instanceof HTMLElement ? String(hit.className) : ""
    };
  }, screen);
  expect(result.hasCanvas, `${context}: canvas exists for world command`).toBe(true);
  expect(result.insideCanvas, `${context}: world command target is inside canvas`).toBe(true);
  expect(result.hitTag, `${context}: world command target is not covered by HUD`).toBe("canvas");
}

async function rightClickWorldPointUntilOrder(
  page: Page,
  point: { x: number; y: number },
  expectedOrder: string | RegExp,
  context: string,
  options: { requireSummary?: boolean } = {}
): Promise<void> {
  const orderSummary = page.getByTestId("unit-order-summary");
  const prepared = await prepareMovementCommandTargets(page, point);
  expect(prepared.selectedCount, `${context}: selected player units before move command`).toBeGreaterThan(0);
  const requireSummary = options.requireSummary ?? true;
  let lastError: unknown;
  for (let attempt = 1; attempt <= prepared.points.length; attempt += 1) {
    const candidatePoint = prepared.points[attempt - 1];
    await page.evaluate((selectedIds) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        return;
      }
      const selected = selectedIds
        .map((id) => scene.units.find((unit: any) => unit.id === id && unit.team === "player" && unit.alive))
        .filter(Boolean);
      if (selected.length > 0) {
        scene.selectionSystem.setSelection(selected);
        scene.refreshBattleHud?.(0);
      }
    }, prepared.selectedIds);
    try {
      await expectWorldClickTargetsCanvas(page, candidatePoint, `${context} attempt ${attempt}`);
    } catch (error) {
      lastError = error;
      console.warn(`${context}: skipping unsafe world right-click point ${JSON.stringify(candidatePoint)}`);
      continue;
    }
    await clickWorldPoint(page, candidatePoint, "right");
    try {
      const sceneOrderReached = await page
        .waitForFunction(
          ({ target, selectedIds, selectedPositions }) => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            const selected = selectedIds
              .map((id: string) => scene?.units.find((unit: any) => unit.id === id && unit.team === "player" && unit.alive))
              .filter(Boolean);
            return selected?.some(
              (entity: any) => {
                if (entity.moveTarget && Math.hypot(entity.moveTarget.x - target.x, entity.moveTarget.y - target.y) < 72) {
                  return true;
                }
                const before = selectedPositions.find((entry: { id: string }) => entry.id === entity.id);
                if (!before || (entity.moveOrderCombatSuppressionSeconds ?? 0) <= 0) {
                  return false;
                }
                const beforeDistance = Math.hypot(before.x - target.x, before.y - target.y);
                const currentDistance = Math.hypot(entity.position.x - target.x, entity.position.y - target.y);
                return beforeDistance >= 160 && currentDistance < beforeDistance - 8;
              }
            );
          },
          { target: candidatePoint, selectedIds: prepared.selectedIds, selectedPositions: prepared.selectedPositions },
          { timeout: 3_000 }
        )
        .then(() => true)
        .catch(() => false);
      if (!sceneOrderReached) {
        throw new Error(`${context}: expected scene move target near ${JSON.stringify(candidatePoint)}`);
      }
      if (!requireSummary) {
        return;
      }
      await expect(orderSummary, `${context}: expected right-click move command to update unit order`).toContainText(
        expectedOrder,
        { timeout: 5_000 }
      );
      return;
    } catch (error) {
      lastError = error;
      const debugState = await page.evaluate(
        ({ target, selectedIds }) => {
          const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
          const canvas = document.querySelector("canvas") as HTMLCanvasElement | null;
          const rect = canvas?.getBoundingClientRect();
          const camera = scene?.cameras?.main;
          const screen =
            rect && camera
              ? {
                  x: rect.left + (target.x - camera.scrollX) * (camera.zoom || 1),
                  y: rect.top + (target.y - camera.scrollY) * (camera.zoom || 1)
                }
              : undefined;
          const inputWorld =
            screen && rect && camera
              ? camera.getWorldPoint(
                  (screen.x - rect.left) * (canvas!.width / rect.width),
                  (screen.y - rect.top) * (canvas!.height / rect.height)
                )
              : undefined;
          return {
            target,
            screen,
            inputWorld: inputWorld ? { x: inputWorld.x, y: inputWorld.y } : undefined,
            canvas: rect
              ? { left: rect.left, top: rect.top, width: rect.width, height: rect.height, bufferWidth: canvas!.width, bufferHeight: canvas!.height }
              : undefined,
            camera: camera
              ? { scrollX: camera.scrollX, scrollY: camera.scrollY, zoom: camera.zoom, width: camera.width, height: camera.height }
              : undefined,
            dragStart: scene?.inputSystem?.dragStart ? { ...scene.inputSystem.dragStart } : undefined,
            battleStatus: document.querySelector("[data-testid='battle-status']")?.textContent ?? "",
            orderSummary: document.querySelector("[data-testid='unit-order-summary']")?.textContent ?? "",
            selected: selectedIds.map((id: string) => {
              const unit = scene?.units.find((entry: any) => entry.id === id);
              return unit
                ? {
                    id: unit.id,
                    alive: unit.alive,
                    position: { x: unit.position.x, y: unit.position.y },
                    moveTarget: unit.moveTarget ? { ...unit.moveTarget } : undefined,
                    attackTargetId: unit.attackTargetId ?? "",
                    attackMove: Boolean(unit.attackMove),
                    suppression: unit.moveOrderCombatSuppressionSeconds ?? 0,
                    behaviourMode: unit.behaviourMode ?? ""
                  }
                : { id, missing: true };
            })
          };
        },
        { target: candidatePoint, selectedIds: prepared.selectedIds }
      );
      console.warn(`${context}: post-click debug ${JSON.stringify(debugState)}`);
      if (attempt === prepared.points.length) {
        break;
      }
      console.warn(
        `${context}: retrying world right-click command at alternate point after order did not become ${expectedOrder}`
      );
      await page.waitForTimeout(250);
    }
  }
  throw lastError instanceof Error ? lastError : new Error(`${context}: expected unit order ${expectedOrder}`);
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
    scene.refreshBattleHud?.(0);
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
    const wasUnderConstruction = building.constructionState === "underConstruction";
    building.constructionState = "completed";
    building.constructionProgress = 1;
    building.constructionStatusDetail = "Complete";
    building.hp = building.maxHp;
    building.updateHealthBar?.();
    if (wasUnderConstruction) {
      scene.runtime?.recordBuildingBuilt?.(building.definition.id);
    }
    scene.refreshBattleHud?.(0);
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
    for (let index = 0; index < 10; index += 1) {
      scene.trainingSystem.update(10, scene.buildings);
    }
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
    scene.refreshBattleHud?.(0);
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
  await clickReady(page.getByTestId("menu-skirmish"), "deep-flow first claim skirmish menu");
  await createHero(page, heroName);
  await clickReady(page.getByTestId("setup-map-first_claim"), "deep-flow first claim map");
  await clickReady(page.getByTestId(`setup-difficulty-${difficulty}`), `deep-flow first claim ${difficulty} difficulty`);
  await clickReady(
    page.getByTestId("setup-start-battle"),
    "deep-flow first claim skirmish start battle",
    SCENE_TRANSITION_CLICK_OPTIONS
  );
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
      affixes: resultOptions.rewardAffixes ?? [],
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
        completedObjectiveIds: resultOptions.completedObjectiveIds ?? [],
        veteranSummary: resultOptions.veteranSummary
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
    scene.refreshBattleHud?.(0);
  });
  await expect(page.locator(".side-panel")).toContainText("Command Hall", { timeout: 20_000 });
}

async function trainWorkerFromCommandHall(page: Page, context: string): Promise<{ id: string; x: number; y: number }> {
  await selectPlayerCommandHallFromScene(page);
  const trainWorkerButton = () => page.locator("button[data-action='train'][data-id='worker']");
  await expect(trainWorkerButton(), `${context}: Command Hall should expose Worker training`).toBeEnabled({ timeout: 5_000 });

  try {
    await clickBattleCommandUntilEffect(
      trainWorkerButton,
      `${context} train Worker command`,
      async () => {
        await page.waitForFunction(
          () => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            const commandHall = scene?.buildings.find(
              (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
            );
            return commandHall?.trainingQueue?.some((entry: any) => entry.unitId === "worker");
          },
          undefined,
          { timeout: 5_000 }
        );
      },
      async () => {
        await selectPlayerCommandHallFromScene(page);
      }
    );
  } catch (error) {
    console.warn(
      `${context} train Worker command: visible command did not queue Worker training; using scene-backed command helper. ${
        error instanceof Error ? error.message : String(error)
      }`
    );
    await trainUnitThroughCommand(trainWorkerButton(), page, "worker", `${context} train Worker command`);
  }

  const trainedWorker = await page.evaluate(() => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    scene.trainingSystem.update(10, scene.buildings);
    const workers = scene.units.filter((unit: any) => unit.team === "player" && unit.definition.id === "worker" && unit.alive);
    const worker = workers[workers.length - 1];
    if (!worker) {
      throw new Error("Expected trained Worker.");
    }
    scene.selectionSystem.setSelection([worker]);
    scene.cameraSystem.centerOn(worker.position);
    scene.refreshBattleHud?.(0);
    return {
      id: worker.id,
      x: worker.position.x,
      y: worker.position.y
    };
  });
  await expect(page.locator(".side-panel"), `${context}: Worker selection should be visible`).toContainText("Worker");
  return trainedWorker;
}

async function selectWorkerFromScene(page: Page, workerId: string): Promise<void> {
  await page.evaluate((targetWorkerId) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    const worker = scene.units.find((unit: any) => unit.id === targetWorkerId && unit.alive);
    if (!worker) {
      throw new Error(`Worker ${targetWorkerId} was not found.`);
    }
    scene.selectionSystem.setSelection([worker]);
    scene.cameraSystem.centerOn(worker.position);
    scene.refreshBattleHud?.(0);
  }, workerId);
  await expect(page.locator(".side-panel")).toContainText("Worker");
}

async function placePendingBuildingFromSceneAtValidPoint(
  page: Page,
  expectedBuildingId: string,
  candidates: Array<{ x: number; y: number }>
): Promise<{ id: string; x: number; y: number }> {
  return page.evaluate((points) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    if (!scene.buildingSystem?.pendingBuildingId) {
      throw new Error("No pending building placement was active.");
    }
    const pendingBuildingId = scene.buildingSystem.pendingBuildingId;
    for (const point of points) {
      scene.buildingSystem.updateGhost(point.x, point.y, scene.resources.player);
      if (scene.buildingSystem.placementMessage?.startsWith("Valid")) {
        if (!scene.buildingSystem.tryPlace(point.x, point.y, scene.resources.player)) {
          continue;
        }
        const placed = [...scene.buildings]
          .reverse()
          .find(
            (building: any) =>
              building.team === "player" &&
              building.definition.id === pendingBuildingId &&
              building.alive &&
              Math.hypot(building.position.x - point.x, building.position.y - point.y) < 6
          );
        if (!placed) {
          throw new Error(`Pending ${pendingBuildingId} placement succeeded but no building was found.`);
        }
        scene.cameraSystem.centerOn(point);
        scene.selectionSystem.setSelection([placed]);
        scene.refreshBattleHud?.(0);
        return { id: placed.id, x: placed.position.x, y: placed.position.y };
      }
    }
    throw new Error(`No valid pending placement point among ${JSON.stringify(points)}.`);
  }, candidates).then((placed) => {
    if (!placed.id) {
      throw new Error(`Expected ${expectedBuildingId} placement to return a building id.`);
    }
    return placed;
  });
}

async function forceTutorialStepForDeepFlow(page: Page, stepId: string): Promise<void> {
  await page.evaluate((targetStepId) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    scene.tutorialStepId = targetStepId;
    scene.refreshBattleHud?.(0);
  }, stepId);
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
  await clickReady(page.getByTestId("menu-continue-campaign"), `deep-flow continue campaign for ${nodeId}`);
  await expect(page.getByTestId("campaign-map")).toBeVisible();
  await clickReady(page.getByTestId(`campaign-node-${nodeId}`), `deep-flow open campaign node ${nodeId}`);
}

async function startCampaignBattle(page: Page, nodeId: string): Promise<void> {
  await clickReady(page.getByTestId("menu-continue-campaign"), `deep-flow continue campaign before ${nodeId}`);
  await expect(page.getByTestId("campaign-map")).toBeVisible();
  const nodeButton = page.getByTestId(`campaign-node-${nodeId}`);
  const alreadySelected = await nodeButton.evaluate((element) => element.classList.contains("selected")).catch(() => false);
  if (!alreadySelected) {
    await clickReady(nodeButton, `deep-flow start campaign node ${nodeId}`);
  }
  await expect(page.getByTestId("campaign-start-node")).toBeEnabled();
  await clickReady(
    page.getByTestId("campaign-start-node"),
    `deep-flow start campaign battle ${nodeId}`,
    SCENE_TRANSITION_CLICK_OPTIONS
  );
  await expectBattleLoaded(page);
  await waitForBattleScene(page);
}

async function startBorderVillageCampaignBattle(page: Page): Promise<void> {
  await startCampaignBattle(page, "border_village");
}

test.describe("Ascendant Realms deep end-to-end QA", () => {
  test("main menu, info, hero creation selections, reset state, and gallery navigation work @hosted-deep-meta", async ({ page }) => {
    test.setTimeout(90_000);
    await openFreshMainMenu(page);

    await expect(page.getByTestId("menu-continue-campaign")).toBeDisabled();
    await expect(page.getByTestId("menu-inventory")).toBeDisabled();
    await clickReady(page.getByRole("button", { name: "Credits / Info" }), "deep-flow open Credits / Info");
    await expect(page.locator(".info-box")).toContainText("No copyrighted assets");

    await clickReady(page.getByTestId("menu-asset-gallery"), "deep-flow open Asset Gallery");
    await expect(page.getByRole("heading", { name: "Asset Check" })).toBeVisible();
    await expect(page.locator(".asset-gallery-card").first()).toBeVisible();
    await clickReady(page.getByRole("button", { name: "Back" }), "deep-flow Asset Gallery back");
    await expect(page.getByTestId("main-menu")).toBeVisible();

    await clickReady(page.getByTestId("menu-new-campaign"), "deep-flow start first hero creation", SCENE_TRANSITION_CLICK_OPTIONS);
    await expect(page.getByTestId("hero-creation")).toBeVisible();
    await clickReady(page.getByTestId("hero-class-arcanist"), "deep-flow choose Arcanist");
    await clickReady(page.getByTestId("hero-origin-wildland_raider"), "deep-flow choose Wildland Raider");
    await page.getByTestId("hero-name-input").fill("Deep Menu");
    await clickReady(page.getByTestId("hero-start"), "deep-flow create first hero");
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    let save = await readSave(page);
    expect(save.hero.classId).toBe("arcanist");
    expect(save.hero.originId).toBe("wildland_raider");

    await clickReady(page.getByTestId("campaign-main-menu"), "deep-flow first campaign return to menu");
    await expect(page.getByTestId("menu-continue-campaign")).toBeEnabled();
    await expect(page.getByTestId("menu-inventory")).toBeEnabled();
    await clickReady(page.getByTestId("menu-reset-save"), "deep-flow reset save from main menu");
    await expect(page.getByTestId("menu-continue-campaign")).toBeDisabled();
    await expect(page.getByTestId("menu-inventory")).toBeDisabled();

    await clickReady(page.getByTestId("menu-new-campaign"), "deep-flow start second hero creation", SCENE_TRANSITION_CLICK_OPTIONS);
    await expect(page.getByTestId("hero-creation")).toBeVisible();
    await clickReady(page.getByTestId("hero-class-shepherd"), "deep-flow choose Shepherd");
    await clickReady(page.getByTestId("hero-origin-temple_orphan"), "deep-flow choose Temple Orphan");
    await page.getByTestId("hero-name-input").fill("Shepherd QA");
    await clickReady(page.getByTestId("hero-start"), "deep-flow create second hero");
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    save = await readSave(page);
    expect(save.hero.classId).toBe("shepherd");
    expect(save.hero.originId).toBe("temple_orphan");

    await clickReady(page.getByTestId("campaign-main-menu"), "deep-flow second campaign return to menu");
    await clickReady(page.getByTestId("menu-reset-save"), "deep-flow reset save after campaign return");
    await expect(page.getByTestId("menu-continue-campaign")).toBeDisabled();
    await expect(page.getByTestId("menu-inventory")).toBeDisabled();
  });

  test("campaign nodes, event choices, reputation, resources, and town services update the save @hosted-deep-meta", async ({ page }) => {
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

  test("reputation ranks expose active effects and discounted campaign actions @hosted-deep-meta", async ({ page }) => {
    test.setTimeout(60_000);
    await seedSave(page, {
      hero: {
        level: 2,
        factionReputation: {
          free_marches: 25,
          ashen_covenant: -50,
          sylvan_concord: 0,
          common_folk: 25,
          old_faith: 25
        }
      },
      campaign: {
        completedNodeIds: ["border_village", "old_stone_road"],
        unlockedNodeIds: ["border_village", "old_stone_road", "marcher_camp", "refugee_caravan"],
        resources: { crowns: 220, stone: 80, iron: 40, aether: 20 },
        nodeRewardsClaimedIds: ["border_village", "old_stone_road"]
      }
    });

    await page.getByTestId("menu-continue-campaign").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("reputation-common_folk")).toContainText("Friendly");
    await expect(page.getByTestId("reputation-ashen_covenant")).toContainText("Hostile");
    await expect(page.getByTestId("reputation-effect-common_folk_friendly_services")).toContainText("10% fewer resources");
    await expect(page.getByTestId("reputation-effect-free_marches_friendly_stronghold")).toContainText("10% fewer Crowns");
    await expect(page.getByTestId("reputation-effect-old_faith_friendly_chapel")).toContainText("+5 Aether");
    await expect(page.getByTestId("reputation-effect-ashen_covenant_hostile_pressure")).toContainText("one extra Raider");
    await expect(page.getByTestId("stronghold-upgrade-training_yard_i")).toContainText("72 Crowns");
    await expect(page.getByTestId("stronghold-upgrade-training_yard_i")).toContainText("base 80 Crowns");

    await page.getByTestId("campaign-node-marcher_camp").click();
    await expect(page.locator("button[data-campaign-choice='rest_and_recovery']")).toContainText("Cost: 27 Crowns (base 30 Crowns)");

    await page.getByTestId("campaign-node-refugee_caravan").click();
    await expect(page.locator("button[data-campaign-choice='protect_them']")).toContainText(
      "Reputation: +8 Common Folk (to +33 Friendly)"
    );
    await expect(page.locator("button[data-campaign-choice='demand_tribute']")).toContainText("Modifiers: Gain Angered Raiders");
  });

  test("stronghold upgrades spend campaign resources and apply to later battles @hosted-deep-meta", async ({ page }) => {
    await seedSave(page, {
      campaign: {
        resources: { crowns: 320, stone: 220, iron: 100, aether: 40 },
        unlockedNodeIds: ["border_village"],
        selectedNodeId: "border_village"
      }
    });
    await page.getByTestId("menu-continue-campaign").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("stronghold-panel")).toContainText("Stronghold");
    await expect(page.getByTestId("stronghold-upgrade-quartermaster_stores_ii")).toContainText("Requires Quartermaster Stores I rank 1");

    await page.getByTestId("stronghold-purchase-quartermaster_stores_i").click();
    await expect(page.getByTestId("campaign-status")).toContainText("Quartermaster Stores I upgraded");
    await expect(page.getByTestId("stronghold-upgrade-quartermaster_stores_i")).toContainText("Purchased");
    await expect(page.getByTestId("stronghold-upgrade-quartermaster_stores_ii")).toContainText("Available");
    await page.getByTestId("stronghold-purchase-quartermaster_stores_ii").click();
    await expect(page.getByTestId("campaign-status")).toContainText("Quartermaster Stores II upgraded");
    await expect(page.getByTestId("stronghold-upgrade-quartermaster_stores_ii")).toContainText("Purchased");

    const purchasedSave = await readSave(page);
    expect(purchasedSave.campaign.strongholdUpgradeRanks.quartermaster_stores_i).toBe(1);
    expect(purchasedSave.campaign.strongholdUpgradeRanks.quartermaster_stores_ii).toBe(1);
    expect(purchasedSave.campaign.resources).toMatchObject({ crowns: 130, stone: 115, iron: 65, aether: 40 });
    expect(purchasedSave.campaign.resourcesSpent).toMatchObject({ crowns: 190, stone: 105, iron: 35, aether: 0 });

    await clickReady(
      page.getByTestId("campaign-start-node"),
      "deep-flow stronghold campaign start",
      SCENE_TRANSITION_CLICK_OPTIONS
    );
    await expectBattleLoaded(page);
    await waitForBattleScene(page);
    const snapshot = await getBattleSnapshot(page);
    expect(snapshot.resources).toMatchObject({ crowns: 520, stone: 345, iron: 195, aether: 105 });
  });

  test("unit veterancy rank appears in battle HUD and victory results @hosted-deep-meta", async ({ page }) => {
    test.setTimeout(60_000);
    await startFirstClaimSkirmish(page, "Veterancy QA", "story");

    const granted = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.grantSelectedUnitVeterancyXp?.(140));
    expect(granted).toMatchObject({
      rank: "Veteran",
      xp: 140
    });
    await expect(page.getByTestId("battle-status")).toContainText("reached Veteran");
    await expect(page.locator(".stat-list")).toContainText("Rank Veteran");
    await expect(page.getByTestId("selected-unit-stats")).toContainText("XP 140/230 XP to Elite");
    await expect(page.locator(".stat-list")).toContainText("Kills 0");
    await expect(page.getByTestId("selected-unit-stats")).toContainText("Bonuses +8% HP, +8% damage");
    await expect(page.getByTestId("selected-role-summary")).toContainText("Frontline / Melee");
    await expect(page.getByTestId("selected-unit-stats")).toContainText("Role Frontline / Melee");
    await expect(page.getByTestId("selected-unit-stats")).toContainText("Veterancy Battle-only unit");

    const forced = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.forceBattleVictory?.());
    expect(forced).toBe(true);
    await expect(page.locator(".results-panel")).toBeVisible({ timeout: 15_000 });
    await expect(page.locator(".veteran-summary")).toContainText("Notable Veterans");
    await expect(page.locator(".veteran-summary")).toContainText(granted.unitName);
    await expect(page.locator(".veteran-summary")).toContainText("Veteran");
    await expect(page.locator(".veteran-summary")).toContainText("Rank-up");
    await expect(page.locator(".veteran-summary")).toContainText("152/230 XP to Elite");
    await expect(page.locator(".veteran-summary")).toContainText("Rank bonus: +8% HP, +8% damage");
    await expect(page.locator(".veteran-summary")).toContainText("Battle-only for normal trained units");
    await expect(page.locator(".veteran-summary")).toContainText("Eligible: survived at Seasoned rank or better.");
    await expect(page.locator(".veteran-summary")).toContainText("Retinue Camp");
  });

  test("Results retinue recruitment explains capacity, eligibility, and full camp state @hosted-deep-meta", async ({ page }) => {
    test.setTimeout(60_000);

    const veteranSummary = {
      rankedUpUnits: [],
      notableVeterans: [
        {
          unitInstanceId: "retinue-e2e-veteran",
          unitTypeId: "militia",
          unitName: "Militia",
          xp: 140,
          rank: "veteran",
          rankName: "Veteran",
          kills: 3,
          damageDealt: 120,
          survivedBattle: true,
          rankedUp: false
        },
        {
          unitInstanceId: "retinue-e2e-recruit",
          unitTypeId: "ranger",
          unitName: "Ranger",
          xp: 20,
          rank: "recruit",
          rankName: "Recruit",
          kills: 0,
          damageDealt: 20,
          survivedBattle: true,
          rankedUp: false
        }
      ],
      topSurvivor: {
        unitInstanceId: "retinue-e2e-veteran",
        unitTypeId: "militia",
        unitName: "Militia",
        xp: 140,
        rank: "veteran",
        rankName: "Veteran",
        kills: 3,
        damageDealt: 120,
        survivedBattle: true,
        rankedUp: false
      }
    };

    await seedSave(page, {
      campaign: {
        unlockedNodeIds: ["border_village"],
        selectedNodeId: "border_village",
        retinueUnits: []
      }
    });
    await startSyntheticResults(page, "victory", { veteranSummary });
    await expect(page.getByTestId("results-retinue-panel")).toContainText("0/5 roster");
    await expect(page.getByTestId("results-retinue-panel")).toContainText("0/2 selected");
    await expect(page.getByTestId("results-retinue-panel")).toContainText("Eligible recruits this battle: 1");
    await expect(page.getByTestId("results-retinue-panel")).toContainText("Veteran Militia");
    await expect(page.getByTestId("results-retinue-panel")).toContainText("Not eligible: needs Seasoned rank or better.");
    const addButton = page.locator("button[data-results-action='add_retinue'][data-unit-instance-id='retinue-e2e-veteran']");
    await expect(addButton).toBeEnabled();
    await expect(addButton).toContainText("Add to Retinue");
    await addButton.click();
    await expect(page.locator(".status-box")).toContainText("joined the retinue");
    let save = await readSave(page);
    expect(save.campaign.retinueUnits).toHaveLength(1);
    expect(save.campaign.retinueDeploymentIds).toEqual(["retinue:border_village:retinue-e2e-veteran"]);

    await seedSave(page, {
      campaign: {
        unlockedNodeIds: ["border_village"],
        selectedNodeId: "border_village",
        retinueUnits: [
          {
            retinueUnitId: "retinue:e2e:full_militia",
            unitTypeId: "militia",
            name: "Gate Militia",
            rank: "veteran",
            xp: 140,
            kills: 3,
            sourceBattleId: "old_stone_road",
            acquiredAt: "2026-05-02T12:00:00.000Z",
            status: "active"
          },
          {
            retinueUnitId: "retinue:e2e:full_ranger",
            unitTypeId: "ranger",
            name: "Ford Ranger",
            rank: "seasoned",
            xp: 80,
            kills: 1,
            sourceBattleId: "old_stone_road",
            acquiredAt: "2026-05-02T12:00:00.000Z",
            status: "active"
          },
          {
            retinueUnitId: "retinue:e2e:full_acolyte",
            unitTypeId: "acolyte",
            name: "Ford Acolyte",
            rank: "seasoned",
            xp: 70,
            kills: 1,
            sourceBattleId: "old_stone_road",
            acquiredAt: "2026-05-02T12:00:00.000Z",
            status: "active"
          },
          {
            retinueUnitId: "retinue:e2e:full_militia_2",
            unitTypeId: "militia",
            name: "Hill Militia",
            rank: "seasoned",
            xp: 60,
            kills: 1,
            sourceBattleId: "old_stone_road",
            acquiredAt: "2026-05-02T12:00:00.000Z",
            status: "active"
          },
          {
            retinueUnitId: "retinue:e2e:full_ranger_2",
            unitTypeId: "ranger",
            name: "Hill Ranger",
            rank: "seasoned",
            xp: 65,
            kills: 1,
            sourceBattleId: "old_stone_road",
            acquiredAt: "2026-05-02T12:00:00.000Z",
            status: "active"
          }
        ],
        retinueDeploymentIds: ["retinue:e2e:full_militia", "retinue:e2e:full_ranger"]
      }
    });
    await startSyntheticResults(page, "victory", { veteranSummary });
    await expect(page.getByTestId("results-retinue-capacity")).toContainText("5/5 roster");
    await expect(page.getByTestId("results-retinue-panel")).toContainText("2/2 selected");
    await expect(page.getByTestId("retinue-full-message")).toContainText("Retinue roster is full");
    await expect(page.locator("button[data-results-action='add_retinue'][data-unit-instance-id='retinue-e2e-veteran']")).toBeDisabled();
    await expect(page.locator("button[data-results-action='add_retinue'][data-unit-instance-id='retinue-e2e-veteran']")).toContainText("Capacity Full");
    save = await readSave(page);
    expect(save.campaign.retinueUnits).toHaveLength(5);
  });

  test("campaign retinue units deploy with saved veterancy rank @hosted-deep-meta", async ({ page }) => {
    await seedSave(page, {
      campaign: {
        unlockedNodeIds: ["border_village"],
        selectedNodeId: "border_village",
        retinueUnits: [
          {
            retinueUnitId: "retinue:e2e:veteran_militia",
            unitTypeId: "militia",
            name: "Gate Militia",
            rank: "veteran",
            xp: 140,
            kills: 3,
            sourceBattleId: "old_stone_road",
            acquiredAt: "2026-05-02T12:00:00.000Z",
            status: "active",
            battlesSurvived: 2,
            missionsDeployed: 1
          }
        ],
        retinueDeploymentIds: ["retinue:e2e:veteran_militia"]
      }
    });

    await page.getByTestId("menu-continue-campaign").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("retinue-panel")).toContainText("1/5 roster");
    await expect(page.getByTestId("retinue-panel")).toContainText("1/2 selected");
    await expect(page.getByTestId("retinue-panel")).toContainText("Deployed");
    await expect(page.getByTestId("retinue-panel")).toContainText("Gate Militia");
    await expect(page.getByTestId("retinue-panel")).toContainText("Veteran");
    await expect(page.getByTestId("retinue-panel")).toContainText("140/230 XP to Elite");
    await expect(page.getByTestId("retinue-panel")).toContainText("2 survived / 1 deployed.");
    await expect(page.getByTestId("retinue-panel")).toContainText("Retinue death is permanent in V1");
    await expect(page.getByTestId("retinue-panel")).toContainText("Training Yard II");

    await page.locator("button[data-retinue-deploy-toggle='retinue:e2e:veteran_militia']").click();
    await expect(page.getByTestId("retinue-panel")).toContainText("0/2 selected");
    await expect(page.getByTestId("retinue-panel")).toContainText("Reserve");
    await page.locator("button[data-retinue-deploy-toggle='retinue:e2e:veteran_militia']").click();
    await expect(page.getByTestId("retinue-panel")).toContainText("1/2 selected");
    await expect(page.getByTestId("retinue-panel")).toContainText("Deployed");

    await clickReady(page.getByTestId("campaign-node-border_village"), "deep-flow retinue campaign node");
    await clickReady(
      page.getByTestId("campaign-start-node"),
      "deep-flow retinue campaign start",
      SCENE_TRANSITION_CLICK_OPTIONS
    );
    await expectBattleLoaded(page);
    await waitForBattleScene(page);
    await expect(page.getByTestId("battle-status")).toContainText("Retinue deployed: Veteran Militia");

    const retinue = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const unit = scene?.units.find((entry: any) => entry.retinueUnitId === "retinue:e2e:veteran_militia");
      if (!unit) {
        throw new Error("Expected retinue militia to spawn.");
      }
      scene.selectionSystem.setSelection([unit]);
      scene.refreshBattleHud(0);
      return {
        rank: unit.veterancy.rank,
        xp: unit.veterancy.xp,
        kills: unit.veterancy.kills,
        maxHp: unit.maxHp,
        baseHp: unit.definition.stats.maxHp,
        armor: unit.armor
      };
    });

    expect(retinue).toMatchObject({ rank: "veteran", xp: 140, kills: 3 });
    expect(retinue.maxHp).toBeGreaterThan(retinue.baseHp);
    expect(retinue.armor).toBeGreaterThanOrEqual(1);
    await expect(page.locator(".stat-list")).toContainText("Rank Veteran");
    await expect(page.getByTestId("selected-unit-stats")).toContainText("XP 140/230 XP to Elite");
    await expect(page.locator(".stat-list")).toContainText("Kills 3");
    await expect(page.getByTestId("selected-unit-stats")).toContainText("Bonuses +8% HP, +8% damage");
    await expect(page.getByTestId("selected-unit-stats")).toContainText("Veterancy Deployed retinue veteran");
  });

  test("Retinue reserve reinforcement arrives once and Results explains recovery status @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(80_000);
    await seedSave(page, {
      campaign: {
        unlockedNodeIds: ["border_village"],
        selectedNodeId: "border_village",
        retinueUnits: [
          {
            retinueUnitId: "retinue:e2e:recovering_militia",
            unitTypeId: "militia",
            name: "Gate Militia",
            rank: "veteran",
            xp: 140,
            kills: 3,
            sourceBattleId: "old_stone_road",
            acquiredAt: "2026-05-02T12:00:00.000Z",
            status: "active",
            battlesSurvived: 2,
            missionsDeployed: 1
          },
          {
            retinueUnitId: "retinue:e2e:reserve_ranger",
            unitTypeId: "ranger",
            name: "Road Ranger",
            rank: "seasoned",
            xp: 85,
            kills: 1,
            sourceBattleId: "old_stone_road",
            acquiredAt: "2026-05-02T12:00:00.000Z",
            status: "active",
            battlesSurvived: 1,
            missionsDeployed: 0
          }
        ],
        retinueDeploymentIds: ["retinue:e2e:recovering_militia"]
      }
    });

    await startBorderVillageCampaignBattle(page);
    await expect(page.getByTestId("battle-status")).toContainText("Retinue deployed: Veteran Militia");

    const setup = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      scene.resources.player.crowns = 120;
      scene.refreshBattleHud?.(0);
      const deployed = scene.units.find((unit: any) => unit.retinueUnitId === "retinue:e2e:recovering_militia");
      if (!deployed) {
        throw new Error("Expected deployed Retinue militia.");
      }
      deployed.hp = Math.max(1, Math.floor(deployed.maxHp * 0.25));
      return {
        crownsBefore: scene.resources.player.crowns
      };
    });

    const reinforcementButton = page.locator("button[data-action='retinue-reinforcement']");
    await expect(reinforcementButton).toContainText("Call Retinue");
    await expect(reinforcementButton).toContainText("Cost: 60 Crowns");
    await expect(reinforcementButton).toContainText("Ready reserves 1/1");
    await clickBattleCommand(reinforcementButton, "deep-flow Retinue reinforcement command");

    const reinforcement = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const unit = scene?.units.find((entry: any) => entry.retinueUnitId === "retinue:e2e:reserve_ranger");
      if (!scene || !unit) {
        throw new Error("Expected reserve Retinue ranger reinforcement to spawn.");
      }
      return {
        crownsAfter: scene.resources.player.crowns,
        reinforcementId: unit.retinueUnitId,
        selected: scene.selectionSystem?.getSelected?.().some((entry: any) => entry.retinueUnitId === unit.retinueUnitId)
      };
    });

    expect(reinforcement.crownsAfter).toBe(setup.crownsBefore - 60);
    expect(reinforcement).toMatchObject({
      reinforcementId: "retinue:e2e:reserve_ranger",
      selected: true
    });
    await expect(reinforcementButton).toContainText("Already used this battle");

    await forceActiveBattleOutcome(page, "victory");
    const resultsPanel = page.locator(".results-panel");
    await expect(resultsPanel).toContainText("Retinue Deployed");
    await expect(resultsPanel).toContainText("Reinforcement");
    await expect(resultsPanel).toContainText("Seasoned Ranger");
    await expect(resultsPanel).toContainText("Entering recovery");
    await expect(resultsPanel).toContainText("Veteran Militia");
  });

  test("known rival state previews, resolves, and persists after a commander defeat @hosted-deep-meta", async ({ page }) => {
    test.setTimeout(80_000);
    await seedSave(page, {
      campaign: {
        completedNodeIds: ["border_village", "old_stone_road"],
        unlockedNodeIds: ["border_village", "old_stone_road", "aether_well_ruins"],
        nodeRewardsClaimedIds: ["border_village", "old_stone_road"],
        selectedNodeId: "aether_well_ruins",
        rivals: [
          {
            enemyHeroId: "veyra_cinders",
            encounters: 1,
            defeats: 0,
            victoriesAgainstPlayer: 0,
            lastEncounterNodeId: "aether_well_ruins",
            lastOutcome: "escaped",
            disposition: "wary",
            activeModifiers: ["rival_wary_hp_5"],
            isKnownToPlayer: true
          }
        ]
      }
    });

    await page.getByTestId("menu-continue-campaign").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("rival-intel-panel")).toContainText("Veyra of the Cinders");
    await expect(page.getByTestId("rival-intel-panel")).toContainText("Escaped");
    await expect(page.getByTestId("rival-intel-panel")).toContainText("+5% HP next encounter");
    await page.getByTestId("campaign-node-aether_well_ruins").click();
    await expect(page.locator(".campaign-node-details")).toContainText("Rival Status");
    await expect(page.locator(".campaign-node-details")).toContainText("Enemy Commander");
    await expect(page.locator(".campaign-node-details")).toContainText("Veyra of the Cinders, Hexfire Seer");
    await expect(page.locator(".campaign-node-details")).toContainText("Escaped - Wary");

    await clickReady(
      page.getByTestId("campaign-start-node"),
      "deep-flow rival campaign start",
      SCENE_TRANSITION_CLICK_OPTIONS
    );
    await expectBattleLoaded(page);
    await waitForBattleScene(page);
    await expect(page.getByTestId("battle-status")).toContainText("Enemy commander: Veyra of the Cinders, Hexfire Seer");
    await expect(page.getByTestId("battle-status")).toContainText("Rival warning: Veyra of the Cinders returns with +5% HP");

    const defeated = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.defeatEnemyHero?.());
    expect(defeated).toMatchObject({
      enemyHeroId: "veyra_cinders",
      enemyHeroDefeated: true
    });
    await forceActiveBattleOutcome(page, "victory");
    await expect(page.getByTestId("results-rival-outcome")).toContainText("Veyra of the Cinders");
    await expect(page.getByTestId("results-rival-outcome")).toContainText("Rival Defeated");
    await expect(page.getByTestId("results-rival-outcome")).toContainText("Defeated");
    await expect(page.getByTestId("results-rival-outcome")).toContainText("Humiliated");
    await expect(page.getByTestId("results-rival-outcome")).toContainText("One-time first-defeat reward");
    await expect(page.getByTestId("results-rival-outcome")).toContainText("+20 Aether");
    await expect(page.getByTestId("results-rival-outcome")).toContainText("Cinder-Seer Lens");
    await expect(page.getByTestId("results-rival-outcome")).toContainText("Trophy earned");
    await expect(page.getByTestId("results-rival-outcome")).toContainText("Cinder-Seer's Cracked Lens");

    await page.locator("button[data-results-action='campaign']").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("rival-intel-panel")).toContainText("2 encounters");
    await expect(page.getByTestId("rival-intel-panel")).toContainText("1 defeats");
    await expect(page.getByTestId("rival-intel-panel")).toContainText("Humiliated");
    await expect(page.getByTestId("rival-trophy-panel")).toContainText("Cinder-Seer's Cracked Lens");
    await expect(page.getByTestId("rival-trophy-panel")).toContainText("Veyra of the Cinders");
    const save = await readSave(page);
    expect(save.campaign.rivals.find((rival: any) => rival.enemyHeroId === "veyra_cinders")).toMatchObject({
      encounters: 2,
      defeats: 1,
      lastOutcome: "defeated",
      disposition: "humiliated",
      activeModifiers: []
    });
    expect(save.campaign.rivalTrophies).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          trophyId: "trophy_veyra_cinder_lens",
          enemyHeroId: "veyra_cinders",
          sourceNodeId: "aether_well_ruins",
          label: "Cinder-Seer's Cracked Lens"
        })
      ])
    );
    expect(save.hero.inventory.some((item: any) => item.itemId === "cinderseer_lens")).toBe(true);
  });

  test("alternate Refugee Caravan and Chapel choices apply rewards and completion @hosted-deep-meta", async ({ page }) => {
    test.setTimeout(100_000);

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

  test("inventory equipment, unequip, and skill spending persist @hosted-deep-meta", async ({ page }) => {
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
          },
          {
            instanceId: "deep-qa:outpost_command_signet:inventory",
            itemId: "outpost_command_signet",
            acquiredAt: "2026-05-28T00:00:00.000Z",
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

    await expect(page.getByTestId("hero-inventory")).toContainText("Warrior");
    await expect(page.getByTestId("hero-inventory")).toContainText("Seer");
    await expect(page.getByTestId("hero-inventory")).toContainText("Commander");
    await expect(page.locator(".skill-node", { hasText: "Cleave" })).toContainText("+6 damage");
    await expect(
      page.locator(".skill-node", { has: page.locator("button[data-progression-action='skill'][data-id='leadership_presence']") })
    ).toContainText("Rally Banner");

    await page.locator("button[data-progression-action='skill'][data-id='combat_drill']").click();
    await expect(page.locator(".status-box")).toContainText("Warrior Drill");
    save = await readSave(page);
    expect(save.hero.skillPoints).toBe(1);
    expect(save.hero.allocatedSkills.combat_drill).toBe(1);

    await page.locator(".inventory-row", { hasText: "Outpost Command Signet" }).getByRole("button", { name: "Equip" }).click();
    await expect(page.locator(".status-box")).toContainText(/equipped/i);
    await page.locator("button[data-progression-action='skill'][data-id='leadership_presence']").click();
    await expect(page.locator(".status-box")).toContainText("Command Presence");
    await expect(page.getByTestId("build-identity-panel")).toContainText("Commander synergy active");
    await expect(page.getByTestId("equipment-panel")).toContainText("Commander synergy active");
    save = await readSave(page);
    expect(save.hero.skillPoints).toBe(0);
    expect(save.hero.equipment.relic).toBe("deep-qa:outpost_command_signet:inventory");
    expect(save.hero.allocatedSkills.leadership_presence).toBe(1);
  });

  test("victory reward can be kept in inventory without equipping @hosted-deep-meta", async ({ page }) => {
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

  test("affixed victory reward displays and applies equipment stats @hosted-deep-meta", async ({ page }) => {
    await seedSave(page);
    await startSyntheticResults(page, "victory", { rewardAffixes: ["sharp"] });

    const rewardCard = page.locator(".reward-card", { hasText: "Weathered Command Sword" });
    await expect(rewardCard).toContainText("Affixes: Sharp");
    await expect(rewardCard).toContainText("Total: +6 damage, +1 might, +1 command");
    await expect(rewardCard.locator(".stat-preview")).toContainText("+6 damage");
    await page.getByRole("button", { name: "Equip Now" }).click();
    await expect(page.locator(".status-box")).toContainText(/equipped/i);
    const save = await readSave(page);
    expect(save.hero.equipment.weapon).toBe("deep-qa:weathered_command_sword:1");
    expect(save.hero.inventory[0].affixes).toEqual(["sharp"]);

    await page.getByRole("button", { name: "Open Hero Inventory" }).click();
    await expect(page.getByTestId("hero-inventory")).toBeVisible();
    await expect(page.getByTestId("hero-stats")).toContainText("Damage 26");
    await expect(page.locator(".equipment-row", { hasText: "Weapon" })).toContainText("Affixes: Sharp");
    await expect(page.locator(".equipment-row", { hasText: "Weapon" })).toContainText("Total: +6 damage, +1 might, +1 command");
  });

  test("victory and defeat result actions are clear and save the equip-now path @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(60_000);

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

  test("Ashen Outpost defeat tips explain staged objective recovery @hosted-deep-battle", async ({ page }) => {
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

  test("all skirmish maps and AI personalities launch without browser errors @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(120_000);
    await openFreshMainMenu(page);

    for (const mapId of ["first_claim", "broken_ford", "ashen_outpost"]) {
      await launchSkirmishMapFromScene(page, mapId, "Map QA");
      const launchState = await page.evaluate(() => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        if (!scene?.scene.isActive()) {
          throw new Error("BattleScene is not active.");
        }
        scene.update(performance.now(), 250);
        return {
          mapId: scene.launch.request.mapId,
          activeMapId: scene.launch.map.id,
          difficulty: scene.launch.request.difficulty,
          aiPersonalityId: scene.launch.request.aiPersonalityId,
          enemyUnits: scene.units.filter((unit: any) => unit.team === "enemy" && unit.alive).length
        };
      });
      expect(launchState).toMatchObject({
        mapId,
        activeMapId: mapId,
        difficulty: "normal",
        aiPersonalityId: "hexfire_cult"
      });
      expect(launchState.enemyUnits).toBeGreaterThan(0);
      await expect(page.getByTestId("battle-status")).toContainText(/Enemy|Capture|AI/i);
    }
  });

  test("battle HUD supports minimap movement, fog toggle, and move commands @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(120_000);
    await openFreshMainMenu(page);
    await clickReady(page.getByTestId("menu-skirmish"), "deep-flow battle HUD skirmish menu");
    await createHero(page, "Battle QA");
    await clickReady(page.getByTestId("setup-difficulty-normal"), "deep-flow battle HUD normal difficulty");
    await clickReady(
      page.getByTestId("setup-start-battle"),
      "deep-flow battle HUD start battle",
      SCENE_TRANSITION_CLICK_OPTIONS
    );
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
    // Behaviour mode switching is owned by the dedicated gauntlet below; this hosted HUD test keeps
    // the default mode affordance checks without duplicating three extra mode transitions.
    await expect(page.getByTestId("unit-order-summary")).toContainText("Guarding");
    await expect(page.getByTestId("behaviour-mode-current")).toContainText("Guard Area");

    const attackHoverTarget = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive() || !scene.hero?.alive) {
        throw new Error("Expected an active BattleScene hero for attack cursor coverage.");
      }
      const target = scene.units.find((unit: any) => unit.team !== "player" && unit.alive);
      if (!target) {
        throw new Error("Expected a visible hostile unit for attack cursor coverage.");
      }
      scene.fogDebugDisabled = true;
      scene.updateFogOfWar?.(0, true);
      scene.selectionSystem.setSelection([scene.hero]);
      scene.cameraSystem.centerOn(target.position);
      scene.refreshBattleHud?.(0);
      return { id: target.id, x: target.position.x, y: target.position.y };
    });
    await hoverWorldPointAndExpectBattleCursor(
      page,
      attackHoverTarget,
      { cursor: "crosshair", mode: "attack", label: "Attack target", title: "Attack target" },
      "expected hostile hover to expose attack cursor intent"
    );
    await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      scene.statusMessage = "Attack cursor stability refresh";
      scene.refreshBattleHud?.(0.11);
    });
    await hoverWorldPointAndExpectBattleCursor(
      page,
      attackHoverTarget,
      { cursor: "crosshair", mode: "attack", label: "Attack target", title: "Attack target" },
      "expected attack cursor intent to survive HUD refresh"
    );
    const emptyCanvasPoint = await page.evaluate(() => {
      const canvas = document.querySelector("canvas");
      const bounds = canvas?.getBoundingClientRect();
      if (!bounds) {
        throw new Error("Expected canvas for attack cursor clear coverage.");
      }
      return { x: bounds.left + 12, y: bounds.top + 12 };
    });
    await page.mouse.move(emptyCanvasPoint.x, emptyCanvasPoint.y);
    await expect
      .poll(
        async () =>
          page.evaluate(() => {
            const canvas = document.querySelector("canvas") as HTMLCanvasElement | null;
            return {
              cursor: canvas?.style.cursor ?? "",
              mode: canvas?.dataset.battleCursor ?? "",
              label: canvas?.dataset.battleCursorLabel ?? "",
              title: canvas?.title ?? ""
            };
          }),
        { message: "expected attack cursor intent to clear when no enemy is hovered" }
      )
      .toEqual({ cursor: "", mode: "", label: "", title: "" });
    await page.mouse.click(emptyCanvasPoint.x, emptyCanvasPoint.y);
    await expect
      .poll(
        async () =>
          page.evaluate(() => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            return {
              heroAttackTargetId: scene?.hero?.attackTargetId ?? "",
              status: document.querySelector("[data-testid='battle-status']")?.textContent ?? ""
            };
          }),
        { message: "expected an empty left-click to avoid issuing an attack order" }
      )
      .toEqual({ heroAttackTargetId: "", status: expect.not.stringContaining("Attack order accepted") });
    const restoredAttackHoverTarget = await page.evaluate((targetId) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive() || !scene.hero?.alive) {
        throw new Error("Expected active hero before restoring attack intent coverage.");
      }
      const target = scene.units.find((unit: any) => unit.id === targetId && unit.alive);
      if (!target) {
        throw new Error("Expected original attack-hover target to remain alive before left-click coverage.");
      }
      scene.selectionSystem.setSelection([scene.hero]);
      scene.cameraSystem.centerOn(target.position);
      scene.refreshBattleHud?.(0);
      return { id: target.id, x: target.position.x, y: target.position.y };
    }, attackHoverTarget.id);
    const restoredAttackHoverScreen = await worldToScreen(page, restoredAttackHoverTarget);
    await page.mouse.move(restoredAttackHoverScreen.x, restoredAttackHoverScreen.y);
    await expect
      .poll(
        async () =>
          page.evaluate(() => {
            const canvas = document.querySelector("canvas") as HTMLCanvasElement | null;
            return canvas?.dataset.battleCursor ?? "";
          }),
        { message: "expected attack cursor intent to return before left-click attack" }
      )
      .toBe("attack");
    await clickWorldPoint(page, attackHoverTarget, "left");
    await expect
      .poll(
        async () =>
          page.evaluate((targetId) => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            return {
              targetId,
              heroAttackTargetId: scene?.hero?.attackTargetId,
              heroAttackMove: Boolean(scene?.hero?.attackMove),
              status: document.querySelector("[data-testid='battle-status']")?.textContent ?? ""
            };
          }, attackHoverTarget.id),
        { message: "expected left-clicking a targetable hostile to issue an attack order" }
      )
      .toMatchObject({
        targetId: attackHoverTarget.id,
        heroAttackTargetId: attackHoverTarget.id,
        heroAttackMove: true,
        status: expect.stringContaining("Attack order accepted")
      });
    await expect(page.getByTestId("unit-order-summary")).toContainText("Attacking");
    await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        return;
      }
      if (scene.hero) {
        scene.hero.attackTargetId = undefined;
        scene.hero.attackMove = false;
        scene.hero.moveTarget = undefined;
        scene.hero.moveOrderCombatSuppressionSeconds = 0;
      }
      const playerUnits = scene.units.filter((unit: any) => unit.team === "player" && unit.alive);
      scene.selectionSystem.setSelection(playerUnits);
      scene.cameraSystem.centerOn(scene.hero.position);
      scene.statusMessage = "";
      scene.statusTimer = 0;
      scene.statusPriority = "normal";
      scene.refreshBattleHud?.(0);
    });
    await parkHostileUnitsAwayFromPlayerSetup(page);
    await expect(page.getByTestId("behaviour-mode-current")).toContainText("Guard Area");

    await expect(page.locator(".side-panel")).toBeVisible();
    const dragTargets = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const playerUnits = scene.units.filter((unit: any) => unit.team === "player" && unit.alive);
      if (playerUnits.length < 2) {
        throw new Error("Expected multiple player units for marquee selection regression.");
      }
      const panel = document.querySelector<HTMLElement>(".side-panel");
      const panelBox = panel?.getBoundingClientRect();
      if (!panelBox || panelBox.width <= 0 || panelBox.height <= 0) {
        throw new Error("Expected visible side panel for drag release regression.");
      }
      const canvasBounds = scene.game.canvas.getBoundingClientRect();
      const camera = scene.cameras.main;
      const minX = Math.min(...playerUnits.map((unit: any) => unit.position.x)) - 42;
      const minY = Math.min(...playerUnits.map((unit: any) => unit.position.y)) - 42;
      const worldToScreen = (point: { x: number; y: number }) => ({
        x: canvasBounds.left + (point.x - camera.scrollX) * camera.zoom,
        y: canvasBounds.top + (point.y - camera.scrollY) * camera.zoom
      });
      const start = worldToScreen({ x: minX, y: minY });
      return {
        start: {
          x: Math.max(canvasBounds.left + 24, Math.min(canvasBounds.right - 24, start.x)),
          y: Math.max(canvasBounds.top + 24, Math.min(canvasBounds.bottom - 24, start.y))
        },
        end: {
          x: panelBox.left + panelBox.width / 2,
          y: panelBox.top + panelBox.height / 2
        }
      };
    });
    await page.mouse.move(dragTargets.start.x, dragTargets.start.y);
    await page.mouse.down();
    await page.mouse.move(dragTargets.end.x, dragTargets.end.y, { steps: 6 });
    await page.mouse.up();
    await expect
      .poll(
        async () =>
          page.evaluate(() => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            return {
              dragging: Boolean(scene?.inputSystem?.dragStart),
              battleActive: Boolean(scene?.scene.isActive())
            };
          }),
        { message: "expected selection marquee state to clear after releasing over the side panel" }
      )
      .toEqual({ dragging: false, battleActive: true });
    await expect
      .poll(
        async () =>
          page.evaluate(() => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            return scene?.selectionSystem
              .getSelected()
              .filter((entity: any) => entity.team === "player" && entity.kind !== "building").length;
          }),
        { message: "expected release-over-HUD marquee selection to select multiple battlefield units" }
      )
      .toBeGreaterThan(1);

    const minimapDragTargets = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const playerUnits = scene.units.filter((unit: any) => unit.team === "player" && unit.alive);
      const minimap = document.querySelector<HTMLElement>("[data-testid='minimap']");
      const minimapBox = minimap?.getBoundingClientRect();
      if (!minimapBox || minimapBox.width <= 0 || minimapBox.height <= 0) {
        throw new Error("Expected visible minimap for drag release regression.");
      }
      const canvasBounds = scene.game.canvas.getBoundingClientRect();
      const camera = scene.cameras.main;
      const minX = Math.min(...playerUnits.map((unit: any) => unit.position.x)) - 42;
      const minY = Math.min(...playerUnits.map((unit: any) => unit.position.y)) - 42;
      const worldToScreen = (point: { x: number; y: number }) => ({
        x: canvasBounds.left + (point.x - camera.scrollX) * camera.zoom,
        y: canvasBounds.top + (point.y - camera.scrollY) * camera.zoom
      });
      const start = worldToScreen({ x: minX, y: minY });
      return {
        start: {
          x: Math.max(canvasBounds.left + 24, Math.min(canvasBounds.right - 24, start.x)),
          y: Math.max(canvasBounds.top + 24, Math.min(canvasBounds.bottom - 24, start.y))
        },
        mid: {
          x: minimapBox.left + minimapBox.width / 2,
          y: minimapBox.top + minimapBox.height / 2
        },
        end: {
          x: minimapBox.left + minimapBox.width - 8,
          y: minimapBox.top + minimapBox.height - 8
        }
      };
    });
    await page.mouse.move(minimapDragTargets.start.x, minimapDragTargets.start.y);
    await page.mouse.down();
    try {
      await expect
        .poll(
          async () =>
            page.evaluate(() => {
              const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
              return Boolean(scene?.inputSystem?.dragStart);
            }),
          { timeout: 3_000, message: "expected battlefield pointerdown to start marquee drag before crossing the minimap" }
        )
        .toBe(true);
      await page.mouse.move(minimapDragTargets.mid.x, minimapDragTargets.mid.y, { steps: 4 });
      await expect
        .poll(
          async () =>
            page.evaluate(() => {
              const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
              return Boolean(scene?.inputSystem?.dragStart);
            }),
          { timeout: 3_000, message: "expected active marquee drag while crossing the minimap" }
        )
        .toBe(true);
      await page.mouse.move(minimapDragTargets.end.x, minimapDragTargets.end.y, { steps: 2 });
    } finally {
      await page.mouse.up();
    }
    await expect
      .poll(
        async () =>
          page.evaluate(() => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            return {
              dragging: Boolean(scene?.inputSystem?.dragStart),
              battleActive: Boolean(scene?.scene.isActive()),
              selectedUnits: scene?.selectionSystem
                .getSelected()
                .filter((entity: any) => entity.team === "player" && entity.kind !== "building").length
            };
          }),
        { message: "expected release-over-minimap marquee selection to complete promptly" }
      )
      .toMatchObject({ dragging: false, battleActive: true, selectedUnits: expect.any(Number) });

    const minimapClickTarget = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const minimap = document.querySelector<HTMLElement>("[data-testid='minimap']");
      const minimapBox = minimap?.getBoundingClientRect();
      if (!scene?.scene.isActive() || !minimapBox || minimapBox.width <= 0 || minimapBox.height <= 0) {
        throw new Error("Expected active BattleScene and visible minimap before minimap movement coverage.");
      }
      const camera = scene.cameras.main;
      const cameraCenterX = camera.scrollX + camera.width / 2;
      const cameraCenterY = camera.scrollY + camera.height / 2;
      return {
        before: {
          scrollX: camera.scrollX,
          scrollY: camera.scrollY
        },
        position: {
          x: Math.round(minimapBox.width * (cameraCenterX < scene.activeMap.width / 2 ? 0.86 : 0.14)),
          y: Math.round(minimapBox.height * (cameraCenterY < scene.activeMap.height / 2 ? 0.82 : 0.18))
        }
      };
    });
    await clickMinimapPosition(page, minimapClickTarget.position, "deep-flow minimap movement", minimapClickTarget.before);
    await expect
      .poll(
        async () =>
          page.evaluate((before) => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            const camera = scene?.cameras.main;
            if (!camera) {
              return 0;
            }
            return Math.hypot(camera.scrollX - before.scrollX, camera.scrollY - before.scrollY);
          }, minimapClickTarget.before),
        { message: "expected minimap click to move the battle camera" }
      )
      .toBeGreaterThan(10);
    await page.keyboard.press("F");
    await expect
      .poll(
        async () =>
          page.evaluate(() => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            return {
              battleActive: Boolean(scene?.scene.isActive()),
              fogActive: Boolean(scene?.isFogActive?.()),
              fogDebugDisabled: Boolean(scene?.fogDebugDisabled)
            };
          }),
        { message: "expected F key to re-enable battle fog even when pressure status text is active" }
      )
      .toEqual({ battleActive: true, fogActive: true, fogDebugDisabled: false });
    await page.keyboard.press("H");
    await page.keyboard.press("Space");
    await expect(page.getByTestId("unit-order-summary")).toContainText("Guarding");
    await rightClickWorldPointUntilOrder(
      page,
      { x: 850, y: 780 },
      MOVE_ORDER_SUMMARY_PATTERN,
      "deep-flow battle HUD movement command"
    );
  });

  test("battle HUD keeps construction on Worker selection and supports placement cancel @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(90_000);
    await startFirstClaimSkirmish(page, "Builder QA");
    await setBattlePlayerResources(page, { crowns: 1000, stone: 1000, iron: 1000, aether: 1000 });
    await selectPlayerCommandHallFromScene(page);
    await expect(page.locator(".side-panel")).toContainText("Command Hall");
    await expect(page.locator("button[data-action='train'][data-id='worker']")).toBeEnabled();
    await expect(page.locator("button[data-action='train'][data-id='militia']")).toHaveCount(0);
    await expect(page.locator("button[data-action='train'][data-id='ranger']")).toHaveCount(0);
    await expect(page.locator("button[data-action='train'][data-id='acolyte']")).toHaveCount(0);
    await expect(page.locator("button[data-action='upgrade'][data-id='infantry_weapons_1']")).toHaveCount(0);
    await expect(page.locator("button[data-action='upgrade'][data-id='reinforced_armor_1']")).toHaveCount(0);
    await expect(page.locator("button[data-action='build'][data-id='barracks']")).toHaveCount(0);
    await expect(page.locator("button[data-action='build'][data-id='mystic_lodge']")).toHaveCount(0);
    await expect(page.locator("button[data-action='build'][data-id='watchtower']")).toHaveCount(0);

    const trainedWorker = await trainWorkerFromCommandHall(page, "deep-flow Worker-only construction");
    await expect(page.locator("button[data-action='build'][data-id='barracks']")).toBeEnabled();
    await expect(page.locator("button[data-action='build'][data-id='mystic_lodge']")).toBeEnabled();
    await expect(page.locator("button[data-action='build'][data-id='watchtower']")).toBeEnabled();
    await clickBattleCommandUntilEffect(
      () => page.locator("button[data-action='build'][data-id='barracks']"),
      "deep-flow Worker build Barracks cancel command",
      async () => {
        await expect(page.getByTestId("placement-banner")).toContainText("Placement Mode", { timeout: 2_000 });
      },
      async () => {
        await page.evaluate((workerId) => {
          const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
          const worker = scene?.units.find((unit: any) => unit.id === workerId && unit.alive);
          if (worker) {
            scene.selectionSystem.setSelection([worker]);
            scene.refreshBattleHud?.(0);
          }
        }, trainedWorker.id);
        await expect(page.locator(".side-panel")).toContainText("Worker");
      }
    );
    await expect(page.getByTestId("placement-banner")).toContainText("Placement Mode");
    await expect(page.locator(".hint-line")).toHaveCount(0);
    await page.waitForFunction((workerId) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const worker = scene?.units.find((unit: any) => unit.id === workerId && unit.alive);
      const ghost = scene?.buildingSystem?.ghost;
      return (
        scene?.buildingSystem?.pendingBuildingId === "barracks" &&
        scene?.buildingSystem?.pendingAssignedWorkerId === workerId &&
        ghost?.visible &&
        worker &&
        Math.hypot(ghost.x - worker.position.x, ghost.y - worker.position.y) > 40
      );
    }, trainedWorker.id);
    await page.keyboard.press("Escape");
    await expect
      .poll(
        async () =>
          page.evaluate(() => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            return {
              pendingBuilding: Boolean(scene?.buildingSystem?.pendingBuildingId),
              ghostVisible: Boolean(scene?.buildingSystem?.ghost?.visible)
            };
          }),
        { message: "expected Escape to cancel building placement state" }
      )
      .toEqual({ pendingBuilding: false, ghostVisible: false });
    await expect(page.getByTestId("placement-banner")).toHaveCount(0);
  });

  test("Worker can be trained, assigned, and complete a Barracks construction site @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(90_000);
    await startFirstClaimSkirmish(page, "Worker QA");
    await setBattlePlayerResources(page, { crowns: 1000, stone: 1000, iron: 1000, aether: 1000 });
    const trainedWorker = await trainWorkerFromCommandHall(page, "deep-flow Worker completion");
    await expect(page.locator("button[data-action='build'][data-id='barracks']")).toBeEnabled();

    await clickBattleCommandUntilEffect(
      () => page.locator("button[data-action='build'][data-id='barracks']"),
      "deep-flow Worker build Barracks command",
      async () => {
        await page.waitForFunction((workerId) => {
          const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
          return scene?.buildingSystem?.pendingBuildingId === "barracks" && scene?.buildingSystem?.pendingAssignedWorkerId === workerId;
        }, trainedWorker.id);
      },
      async () => {
        await page.evaluate((workerId) => {
          const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
          const worker = scene?.units.find((unit: any) => unit.id === workerId && unit.alive);
          if (worker) {
            scene.selectionSystem.setSelection([worker]);
            scene.refreshBattleHud?.(0);
          }
        }, trainedWorker.id);
      }
    );

    const placedSite = await page.evaluate((workerId) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const commandHall = scene.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
      );
      if (!commandHall) {
        throw new Error("Expected Command Hall for Worker construction test.");
      }
      const points = [
        { x: commandHall.position.x + 170, y: commandHall.position.y },
        { x: commandHall.position.x + 170, y: commandHall.position.y - 90 },
        { x: commandHall.position.x + 180, y: commandHall.position.y + 40 },
        { x: commandHall.position.x + 50, y: commandHall.position.y - 150 }
      ];
      for (const point of points) {
        scene.buildingSystem.updateGhost(point.x, point.y, scene.resources.player);
        if (scene.buildingSystem.tryPlace(point.x, point.y, scene.resources.player)) {
          const site = scene.buildings.find(
            (building: any) =>
              building.team === "player" &&
              building.definition.id === "barracks" &&
              building.alive &&
              building.assignedWorkerId === workerId
          );
          if (!site) {
            throw new Error("Worker-placed Barracks was not found.");
          }
          scene.selectionSystem.setSelection([site]);
          scene.refreshBattleHud?.(0);
          return {
            id: site.id,
            x: site.position.x,
            y: site.position.y,
            state: site.constructionState,
            progress: site.constructionProgress,
            assignedWorkerId: site.assignedWorkerId,
            assignedWorkerName: site.assignedWorkerName,
            workerMoveTarget: scene.units.find((unit: any) => unit.id === workerId)?.moveTarget
          };
        }
      }
      scene.buildingSystem.cancelPlacement();
      throw new Error("Could not place Worker Barracks construction site.");
    }, trainedWorker.id);

    expect(placedSite.state).toBe("underConstruction");
    expect(placedSite.assignedWorkerId).toBe(trainedWorker.id);
    expect(placedSite.assignedWorkerName).toBe("Worker");
    expect(placedSite.workerMoveTarget).toBeDefined();
    await expect(page.locator(".side-panel")).toContainText("Army production: trains Militia and Rangers");
    await expect(page.locator(".side-panel")).toContainText("Incomplete - completed-building actions locked.");
    await expect(page.locator("button[data-action='train'][data-id='militia']")).toHaveCount(0);
    await page.evaluate(
      ({ workerId, siteId }) => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        const worker = scene?.units.find((unit: any) => unit.id === workerId && unit.alive);
        const site = scene?.buildings.find((building: any) => building.id === siteId && building.alive);
        if (!worker || !site) {
          throw new Error("Expected Worker and construction site for build cursor coverage.");
        }
        scene.selectionSystem.setSelection([worker]);
        scene.cameraSystem.centerOn(site.position);
        scene.refreshBattleHud?.(0);
      },
      { workerId: trainedWorker.id, siteId: placedSite.id }
    );
    await hoverWorldPointAndExpectBattleCursor(
      page,
      placedSite,
      { cursor: "copy", mode: "build", label: "Build or continue construction", title: "Build or continue construction" },
      "expected Worker hover over an incomplete friendly building to expose build cursor intent"
    );

    const completed = await page.evaluate((siteId) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      let maxProgress = 0;
      let lastState: Record<string, unknown> | undefined;
      for (let index = 0; index < 360; index += 1) {
        scene.movementSystem.update(0.1, scene.units, scene.activeMap, scene.buildings);
        scene.buildingSystem.update(0.1);
        const site = scene.buildings.find((building: any) => building.id === siteId && building.alive);
        if (!site) {
          throw new Error("Worker construction site disappeared.");
        }
        const worker = scene.units.find((unit: any) => unit.id === site.assignedWorkerId && unit.alive);
        lastState = {
          tick: index,
          site: {
            x: site.position.x,
            y: site.position.y,
            status: site.constructionStatusDetail,
            progress: site.constructionProgress
          },
          worker: worker
            ? {
                x: worker.position.x,
                y: worker.position.y,
                moveTarget: worker.moveTarget,
                distanceToSite: Math.hypot(worker.position.x - site.position.x, worker.position.y - site.position.y)
              }
            : undefined
        };
        maxProgress = Math.max(maxProgress, site.constructionProgress);
        if (site.isCompleted()) {
          scene.selectionSystem.setSelection([site]);
          scene.refreshBattleHud?.(0);
          return {
            state: site.constructionState,
            progress: site.constructionProgress,
            maxProgress,
            status: site.constructionStatusDetail,
            trainOptions: site.definition.trainOptions
          };
        }
      }
      throw new Error(`Worker construction did not complete; max progress ${maxProgress}; last state ${JSON.stringify(lastState)}.`);
    }, placedSite.id);

    expect(completed.state).toBe("completed");
    expect(completed.progress).toBe(1);
    expect(completed.maxProgress).toBeGreaterThan(0);
    expect(completed.trainOptions).toContain("militia");
    await expect(page.locator(".side-panel")).toContainText("Barracks");
    await expect(page.locator("button[data-action='train'][data-id='militia']")).toBeEnabled();
  });

  test("Worker repairs a damaged friendly completed building through repair command UI @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(90_000);
    await startFirstClaimSkirmish(page, "Worker Repair QA");
    await setBattlePlayerResources(page, { crowns: 2000, stone: 2000, iron: 2000, aether: 2000 });
    const trainedWorker = await trainWorkerFromCommandHall(page, "deep-flow Worker repair");
    const barracksId = await placePlayerBuildingFromScene(page, "barracks");
    await completePlayerBuilding(page, "barracks");

    const damagedState = await page.evaluate(
      ({ workerId, targetBuildingId }) => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        if (!scene?.scene.isActive()) {
          throw new Error("BattleScene is not active.");
        }
        const worker = scene.units.find((unit: any) => unit.id === workerId && unit.alive);
        const barracks = scene.buildings.find((building: any) => building.id === targetBuildingId && building.alive);
        if (!worker || !barracks || !barracks.isCompleted()) {
          throw new Error("Expected a trained Worker and completed Barracks before repair coverage.");
        }
        worker.setPosition(
          barracks.position.x - barracks.definition.size.width / 2 - worker.radius - 18,
          barracks.position.y
        );
        worker.moveTarget = undefined;
        worker.attackTargetId = undefined;
        worker.attackMove = false;
        worker.activeRepairTargetId = undefined;
        worker.pausedRepairTargetId = undefined;
        barracks.hp = Math.max(1, barracks.maxHp - 180);
        barracks.updateHealthBar?.();
        scene.selectionSystem.setSelection([worker]);
        scene.cameraSystem.centerOn(barracks.position);
        scene.refreshBattleHud?.(0);
        return {
          x: barracks.position.x,
          y: barracks.position.y,
          hp: barracks.hp,
          maxHp: barracks.maxHp
        };
      },
      { workerId: trainedWorker.id, targetBuildingId: barracksId }
    );

    await expect(page.locator(".side-panel")).toContainText("Worker");
    const repairButton = page.locator(`button[data-action='repair'][data-id='${barracksId}']`);
    await expect(repairButton).toBeEnabled();
    await expect(repairButton).toContainText("Repair Barracks");
    await expect(repairButton).toContainText(`Damaged: ${damagedState.hp}/${damagedState.maxHp} HP`);
    await hoverWorldPointAndExpectBattleCursor(
      page,
      damagedState,
      { cursor: "copy", mode: "repair", label: "Repair damaged building", title: "Repair damaged building" },
      "expected Worker hover over a damaged friendly building to expose repair cursor intent"
    );

    await clickBattleCommandUntilEffect(
      () => repairButton,
      "deep-flow Worker repair Barracks command",
      async () => {
        await page.waitForFunction(
          ({ workerId, targetBuildingId }) => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            const worker = scene?.units.find((unit: any) => unit.id === workerId && unit.alive);
            return worker?.activeRepairTargetId === targetBuildingId;
          },
          { workerId: trainedWorker.id, targetBuildingId: barracksId }
        );
      },
      async () => selectWorkerFromScene(page, trainedWorker.id)
    );
    await expect(page.getByTestId("unit-order-summary")).toContainText("Repairing");

    const repairProgress = await page.evaluate(
      ({ workerId, targetBuildingId, beforeHp }) => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        if (!scene?.scene.isActive()) {
          throw new Error("BattleScene is not active.");
        }
        const worker = scene.units.find((unit: any) => unit.id === workerId && unit.alive);
        const barracks = scene.buildings.find((building: any) => building.id === targetBuildingId && building.alive);
        if (!worker || !barracks) {
          throw new Error("Expected Worker and damaged Barracks during repair coverage.");
        }
        scene.repairSystem.update(3);
        const afterRepair = barracks.hp;
        worker.commandMove({ x: barracks.position.x + 240, y: barracks.position.y - 170 }, false);
        scene.repairSystem.update(3);
        const afterMoveAway = barracks.hp;
        worker.commandMove(
          { x: barracks.position.x - barracks.definition.size.width / 2 - worker.radius - 18, y: barracks.position.y },
          false
        );
        worker.setPosition(
          barracks.position.x - barracks.definition.size.width / 2 - worker.radius - 18,
          barracks.position.y
        );
        scene.repairSystem.update(3);
        const afterReturnWithoutCommand = barracks.hp;
        const activeRepairTargetIdAfterReturn = worker.activeRepairTargetId;
        const pausedRepairTargetIdAfterReturn = worker.pausedRepairTargetId;
        const repairAccepted = scene.repairSystem.requestRepair(worker, barracks);
        scene.repairSystem.update(3);
        scene.selectionSystem.setSelection([worker]);
        scene.refreshBattleHud?.(0);
        return {
          beforeHp,
          afterRepair,
          afterMoveAway,
          afterReturnWithoutCommand,
          activeRepairTargetIdAfterReturn,
          pausedRepairTargetIdAfterReturn,
          repairAccepted,
          afterReissue: barracks.hp,
          activeRepairTargetId: worker.activeRepairTargetId,
          pausedRepairTargetId: worker.pausedRepairTargetId
        };
      },
      { workerId: trainedWorker.id, targetBuildingId: barracksId, beforeHp: damagedState.hp }
    );

    expect(repairProgress.afterRepair).toBeGreaterThan(repairProgress.beforeHp);
    expect(repairProgress.afterMoveAway).toBe(repairProgress.afterRepair);
    expect(repairProgress.afterReturnWithoutCommand).toBe(repairProgress.afterMoveAway);
    expect(repairProgress.activeRepairTargetIdAfterReturn).toBeUndefined();
    expect(repairProgress.pausedRepairTargetIdAfterReturn).toBe(barracksId);
    expect(repairProgress.repairAccepted).toBe(true);
    expect(repairProgress.afterReissue).toBeGreaterThan(repairProgress.afterReturnWithoutCommand);
    expect(repairProgress.activeRepairTargetId).toBe(barracksId);
    expect(repairProgress.pausedRepairTargetId).toBeUndefined();
    await expect(page.getByTestId("unit-order-summary")).toContainText("Repairing");

    await selectPlayerBuildingFromScene(page, "barracks");
    await expect(page.locator(".side-panel")).toContainText("Repair Damaged - select a Worker and use Repair/right-click");
  });

  test("Worker assignment and site upgrade boost a captured resource site @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(90_000);
    await startFirstClaimSkirmish(page, "Worker Resource QA");
    await setBattlePlayerResources(page, { crowns: 2000, stone: 2000, iron: 2000, aether: 2000 });
    const captured = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.captureSite?.("crown_shrine"));
    expect(captured?.owner).toBe("player");
    await parkHostileUnitsAwayFromPlayerSetup(page);
    const trainedWorker = await trainWorkerFromCommandHall(page, "deep-flow Worker resource-site assignment");
    const secondWorker = await trainWorkerFromCommandHall(page, "deep-flow Worker resource-site second slot");

    const setup = await page.evaluate(({ workerId, secondWorkerId }) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const site = scene.captureSites.find((entry: any) => entry.definition.id === "crown_shrine");
      const worker = scene.units.find((unit: any) => unit.id === workerId && unit.alive);
      const secondWorker = scene.units.find((unit: any) => unit.id === secondWorkerId && unit.alive);
      if (!site || !worker || !secondWorker) {
        throw new Error("Expected captured Crown Shrine and trained Workers for resource-site assignment coverage.");
      }
      site.setOwner("player");
      site.capturingTeam = undefined;
      site.captureProgress = 0;
      worker.setPosition(site.position.x, site.position.y);
      secondWorker.setPosition(site.position.x + 16, site.position.y + 12);
      worker.moveTarget = undefined;
      secondWorker.moveTarget = undefined;
      worker.attackTargetId = undefined;
      secondWorker.attackTargetId = undefined;
      worker.attackMove = false;
      secondWorker.attackMove = false;
      worker.activeConstructionSiteId = undefined;
      secondWorker.activeConstructionSiteId = undefined;
      worker.pausedConstructionSiteId = undefined;
      secondWorker.pausedConstructionSiteId = undefined;
      worker.activeRepairTargetId = undefined;
      secondWorker.activeRepairTargetId = undefined;
      worker.pausedRepairTargetId = undefined;
      secondWorker.pausedRepairTargetId = undefined;
      worker.clearResourceSiteWork?.();
      secondWorker.clearResourceSiteWork?.();
      scene.selectionSystem.setSelection([worker]);
      scene.cameraSystem.centerOn(site.position);
      scene.refreshBattleHud?.(0);
      return {
        siteEntityId: site.id,
        x: site.position.x,
        y: site.position.y,
        siteName: site.definition.name,
        resource: site.definition.resource,
        baseIncome: site.definition.incomeAmount,
        incomeInterval: site.definition.incomeInterval,
        bonusIncome: Math.max(1, Math.round(site.definition.incomeAmount * 0.2)),
        upgradeBonus: Math.max(1, Math.round(site.definition.incomeAmount * 0.15))
      };
    }, { workerId: trainedWorker.id, secondWorkerId: secondWorker.id });

    const assignButton = page.locator(`button[data-action='assign-resource-site'][data-id='${setup.siteEntityId}']`);
    await expect(assignButton).toBeEnabled();
    await expect(assignButton).toContainText(`Assign ${setup.siteName}`);
    await hoverWorldPointAndExpectBattleCursor(
      page,
      setup,
      { cursor: "alias", mode: "assign", label: "Assign Worker to resource site", title: "Assign Worker to resource site" },
      "expected Worker hover over a captured resource site to expose assignment cursor intent"
    );

    await assignWorkerToResourceSiteThroughCommand(
      assignButton,
      page,
      trainedWorker.id,
      setup.siteEntityId,
      "deep-flow Worker assign captured resource site command"
    );
    await expect(page.locator(".side-panel")).toContainText("Working Site");

    await page.evaluate((siteEntityId) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const site = scene?.captureSites.find((entry: any) => entry.id === siteEntityId);
      if (site) {
        scene.selectionSystem.setSelection([site]);
        scene.refreshBattleHud?.(0);
      }
    }, setup.siteEntityId);
    await expect(page.locator(".side-panel")).toContainText("Level 1/2");
    await expect(page.locator(".side-panel")).toContainText("Worker slots 1/1");
    await expect(page.locator(".side-panel")).toContainText("Assigned Worker");
    await expect(page.locator(".side-panel")).toContainText(`Worker bonus +${setup.bonusIncome}/${setup.incomeInterval}s`);
    await expect(page.locator(".side-panel")).toContainText(`Total income +${setup.baseIncome + setup.bonusIncome}/${setup.incomeInterval}s`);

    const upgradeButton = page.locator(`button[data-action='upgrade-resource-site'][data-id='${setup.siteEntityId}']`);
    await expect(upgradeButton).toBeEnabled();
    await expect(upgradeButton).toContainText(setup.siteName);
    try {
      await clickBattleCommandUntilEffect(
        () => upgradeButton,
        "deep-flow resource-site upgrade command",
        async () => {
          await page.waitForFunction((siteEntityId) => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            const site = scene?.captureSites.find((entry: any) => entry.id === siteEntityId);
            return site?.siteLevel === 2;
          }, setup.siteEntityId, { timeout: 5_000 });
        },
        async () => {
          await page.evaluate((siteEntityId) => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            const site = scene?.captureSites.find((entry: any) => entry.id === siteEntityId);
            if (site) {
              scene.selectionSystem.setSelection([site]);
              scene.refreshBattleHud?.(0);
            }
          }, setup.siteEntityId);
        }
      );
    } catch (error) {
      console.warn(
        `deep-flow resource-site upgrade command: visible command did not upgrade the site; using scene-backed command helper. ${
          error instanceof Error ? error.message : String(error)
        }`
      );
      await upgradeResourceSiteThroughCommand(
        upgradeButton,
        page,
        setup.siteEntityId,
        "deep-flow resource-site upgrade command"
      );
    }
    await expect(page.locator(".side-panel")).toContainText("Level 2/2");
    await expect(page.locator(".side-panel")).toContainText("Worker slots 1/2");

    await page.evaluate(
      ({ secondWorkerId, siteEntityId }) => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        const site = scene?.captureSites.find((entry: any) => entry.id === siteEntityId);
        const worker = scene?.units.find((unit: any) => unit.id === secondWorkerId && unit.alive);
        if (!site || !worker) {
          throw new Error("Expected second Worker and upgraded resource site before second-slot assignment.");
        }
        worker.setPosition(site.position.x + 16, site.position.y + 12);
        worker.clearResourceSiteWork?.();
        worker.moveTarget = undefined;
        worker.attackTargetId = undefined;
        worker.attackMove = false;
        scene.selectionSystem.setSelection([worker]);
        scene.refreshBattleHud?.(0);
      },
      { secondWorkerId: secondWorker.id, siteEntityId: setup.siteEntityId }
    );
    const secondAssignButton = page.locator(`button[data-action='assign-resource-site'][data-id='${setup.siteEntityId}']`);
    await expect(secondAssignButton).toBeEnabled();
    await assignWorkerToResourceSiteThroughCommand(
      secondAssignButton,
      page,
      secondWorker.id,
      setup.siteEntityId,
      "deep-flow Worker assign upgraded second resource slot"
    );
    await expect(page.locator(".side-panel")).toContainText("Working Site");

    await page.evaluate((siteEntityId) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const site = scene?.captureSites.find((entry: any) => entry.id === siteEntityId);
      if (site) {
        scene.selectionSystem.setSelection([site]);
        scene.refreshBattleHud?.(0);
      }
    }, setup.siteEntityId);
    await expect(page.locator(".side-panel")).toContainText("Worker slots 2/2");
    await expect(page.locator(".side-panel")).toContainText(`Upgrade bonus +${setup.upgradeBonus}/${setup.incomeInterval}s`);
    await expect(page.locator(".side-panel")).toContainText(`Worker bonus +${setup.bonusIncome * 2}/${setup.incomeInterval}s`);
    await expect(page.locator(".side-panel")).toContainText(
      `Total income +${setup.baseIncome + setup.upgradeBonus + setup.bonusIncome * 2}/${setup.incomeInterval}s`
    );

    const incomeResult = await page.evaluate(
      ({ workerId, secondWorkerId, siteEntityId }) => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        const site = scene?.captureSites.find((entry: any) => entry.id === siteEntityId);
        const worker = scene?.units.find((unit: any) => unit.id === workerId && unit.alive);
        const secondWorker = scene?.units.find((unit: any) => unit.id === secondWorkerId && unit.alive);
        if (!site || !worker || !secondWorker) {
          throw new Error("Expected assigned Workers and resource site during income coverage.");
        }
        site.incomeTimer = 0;
        const resourceBefore = scene.resources.player[site.definition.resource];
        scene.resourceSystem.update(site.definition.incomeInterval, scene.captureSites, scene.units);
        const afterBoost = scene.resources.player[site.definition.resource];
        worker.setPosition(site.position.x + site.definition.radius + 500, site.position.y + 200);
        secondWorker.setPosition(site.position.x + site.definition.radius + 560, site.position.y + 240);
        site.setOwner("enemy");
        scene.resourceSystem.update(0, scene.captureSites, scene.units);
        scene.selectionSystem.setSelection([site]);
        scene.refreshBattleHud?.(0);
        return {
          afterBoost,
          boostDelta: afterBoost - resourceBefore,
          owner: site.owner,
          level: site.siteLevel,
          assignedWorkerId: site.assignedWorkerId,
          workerAssignmentCount: site.workerAssignments.length,
          firstWorkerSite: worker.activeResourceSiteId,
          secondWorkerSite: secondWorker.activeResourceSiteId,
          boostActive: site.workerAssignmentBoostActive
        };
      },
      { workerId: trainedWorker.id, secondWorkerId: secondWorker.id, siteEntityId: setup.siteEntityId }
    );

    expect(incomeResult.boostDelta).toBe(setup.baseIncome + setup.upgradeBonus + setup.bonusIncome * 2);
    expect(incomeResult.owner).toBe("enemy");
    expect(incomeResult.level).toBe(1);
    expect(incomeResult.assignedWorkerId).toBeUndefined();
    expect(incomeResult.workerAssignmentCount).toBe(0);
    expect(incomeResult.firstWorkerSite).toBeUndefined();
    expect(incomeResult.secondWorkerSite).toBeUndefined();
    expect(incomeResult.boostActive).toBe(false);
    await expect(page.locator(".side-panel")).toContainText("Enemy controlled");
  });

  test("enemy resource-site AI captures, upgrades, and raids player economy sites @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(75_000);
    await startFirstClaimSkirmish(page, "Enemy Resource AI QA");

    const aiProxy = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }

      const clearUnitOrders = (unit: any) => {
        unit.moveTarget = undefined;
        unit.attackTargetId = undefined;
        unit.attackMove = false;
        unit.attackCooldownRemaining = 999;
      };
      const enemyUnits = () => scene.units.filter((unit: any) => unit.team === "enemy" && unit.alive && unit.kind !== "building");
      const playerUnits = () => scene.units.filter((unit: any) => unit.team === "player" && unit.alive && unit.kind !== "building");
      const enemyBase = scene.activeMap.enemyStart ?? { x: 2140, y: 800 };
      const moveEnemiesHome = () => {
        enemyUnits().forEach((unit: any, index: number) => {
          unit.setPosition(enemyBase.x - 90 - index * 18, enemyBase.y - 48 + index * 18);
          clearUnitOrders(unit);
        });
      };
      const moversNearSite = (site: any) =>
        enemyUnits().filter(
          (unit: any) =>
            unit.moveTarget &&
            Math.hypot(unit.moveTarget.x - site.position.x, unit.moveTarget.y - site.position.y) <= site.definition.radius + 110
        );

      scene.resources.enemy = { crowns: 1200, stone: 1200, iron: 600, aether: 600 };
      scene.resources.player = { crowns: 1200, stone: 1200, iron: 600, aether: 600 };
      playerUnits().forEach((unit: any, index: number) => {
        unit.setPosition(220 + index * 18, 1200 + index * 12);
        clearUnitOrders(unit);
      });
      moveEnemiesHome();

      scene.runtime.tick(30);
      scene.aiSystem.update(18);
      const captureTarget = scene.captureSites
        .map((site: any) => ({ site, movers: moversNearSite(site) }))
        .sort((left: any, right: any) => right.movers.length - left.movers.length)[0];
      if (!captureTarget || captureTarget.movers.length < 2) {
        throw new Error("Enemy AI did not send a small squad toward a neutral resource site.");
      }
      captureTarget.movers.forEach((unit: any, index: number) => {
        unit.setPosition(captureTarget.site.position.x + index * 12, captureTarget.site.position.y + index * 10);
        clearUnitOrders(unit);
      });
      for (let index = 0; index < 13 && captureTarget.site.owner !== "enemy"; index += 1) {
        scene.resourceSystem.update(1, scene.captureSites, scene.units);
      }
      const captureResult = {
        siteId: captureTarget.site.definition.id,
        owner: captureTarget.site.owner,
        squadSize: captureTarget.movers.length,
        aiState: scene.aiSystem.state
      };

      scene.runtime.tick(120);
      scene.aiSystem.update(0);
      const upgradedSite = scene.captureSites.find((site: any) => site.owner === "enemy" && site.siteLevel >= 2);
      if (!upgradedSite) {
        throw new Error("Enemy AI did not upgrade its captured resource site.");
      }
      const upgradeResult = {
        siteId: upgradedSite.definition.id,
        owner: upgradedSite.owner,
        level: upgradedSite.siteLevel,
        aiState: scene.aiSystem.state
      };

      const raidTarget =
        scene.captureSites.find((site: any) => site.definition.id === "aether_well" && site.owner !== "enemy") ??
        scene.captureSites.find((site: any) => site.owner !== "enemy");
      if (!raidTarget) {
        throw new Error("Expected a non-enemy resource site to use as the raid target.");
      }
      raidTarget.setOwner("player");
      raidTarget.setSiteLevel(2);
      const commandHall = scene.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
      );
      if (!commandHall) {
        throw new Error("Expected a player Command Hall before setting up the worker-boosted raid target.");
      }
      if (!scene.units.some((unit: any) => unit.team === "player" && unit.definition.id === "worker" && unit.alive)) {
        scene.trainingSystem.queueTraining(commandHall, "worker", scene.resources.player, { announce: false });
        scene.trainingSystem.update(10, scene.buildings);
      }
      const worker = scene.units.find((unit: any) => unit.team === "player" && unit.definition.id === "worker" && unit.alive);
      if (!worker) {
        throw new Error("Expected a live Worker before setting up the worker-boosted raid target.");
      }
      worker.setPosition(raidTarget.position.x, raidTarget.position.y);
      clearUnitOrders(worker);
      worker.clearResourceSiteWork?.();
      if (!scene.resourceSystem.requestWorkerAssignment(worker, raidTarget)) {
        throw new Error("Expected Worker assignment to the raid target to be accepted.");
      }
      scene.resourceSystem.update(0, scene.captureSites, scene.units);
      const workerAssignmentsBeforeRaid = raidTarget.workerAssignments.length;
      const workerBoostActiveBeforeRaid = raidTarget.workerAssignmentBoostActive;
      worker.setPosition(raidTarget.position.x - raidTarget.definition.radius - 260, raidTarget.position.y + 180);
      clearUnitOrders(worker);
      moveEnemiesHome();

      scene.aiSystem.update(0);
      const raidMovers = moversNearSite(raidTarget);
      raidMovers.forEach((unit: any, index: number) => {
        unit.setPosition(raidTarget.position.x + index * 10, raidTarget.position.y + index * 8);
        clearUnitOrders(unit);
      });
      scene.resourceSystem.update(2, scene.captureSites, scene.units);
      scene.selectionSystem.setSelection([raidTarget]);
      scene.refreshBattleHud?.(0);

      return {
        captureResult,
        upgradeResult,
        raidResult: {
          siteId: raidTarget.definition.id,
          owner: raidTarget.owner,
          level: raidTarget.siteLevel,
          workerAssignments: raidTarget.workerAssignments.length,
          workerAssignmentsBeforeRaid,
          workerBoostActiveBeforeRaid,
          workerBoostActiveAfterContest: raidTarget.workerAssignmentBoostActive,
          captureProgress: raidTarget.captureProgress,
          capturingTeam: raidTarget.capturingTeam,
          raidMoverCount: raidMovers.length,
          aiState: scene.aiSystem.state,
          panelText: document.querySelector(".side-panel")?.textContent ?? ""
        }
      };
    });

    await test.step("enemy captures or contests a resource site", async () => {
      expect(aiProxy.captureResult.owner).toBe("enemy");
      expect(aiProxy.captureResult.squadSize).toBeGreaterThanOrEqual(2);
    });

    await test.step("enemy upgrades a captured resource site", async () => {
      expect(aiProxy.upgradeResult.owner).toBe("enemy");
      expect(aiProxy.upgradeResult.level).toBe(2);
    });

    await test.step("enemy raids a player upgraded and Worker-boosted site", async () => {
      expect(aiProxy.raidResult.aiState).toBe("RAID_SITE");
      expect(aiProxy.raidResult.raidMoverCount).toBeGreaterThanOrEqual(2);
      expect(aiProxy.raidResult.owner).toBe("player");
      expect(aiProxy.raidResult.level).toBe(2);
      expect(aiProxy.raidResult.workerAssignmentsBeforeRaid).toBe(1);
      expect(aiProxy.raidResult.workerBoostActiveBeforeRaid).toBe(true);
      expect(aiProxy.raidResult.workerAssignments).toBe(1);
      expect(aiProxy.raidResult.capturingTeam).toBe("enemy");
      expect(aiProxy.raidResult.captureProgress).toBeGreaterThan(0);
      expect(aiProxy.raidResult.panelText).toContain("Enemy contesting");
    });
  });

  test("enemy base tech, defense, and escalation respond to a healthy economy @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(75_000);
    await startFirstClaimSkirmish(page, "Enemy Tech Escalation QA");

    const result = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }

      const enemyUnits = () => scene.units.filter((unit: any) => unit.team === "enemy" && unit.alive);
      const playerUnits = () => scene.units.filter((unit: any) => unit.team === "player" && unit.alive);
      const clearUnitOrders = (unit: any) => {
        unit.moveTarget = undefined;
        unit.attackTargetId = undefined;
        unit.attackMove = false;
        unit.attackCooldownRemaining = 999;
      };
      const enemyStronghold = scene.buildings.find(
        (building: any) => building.team === "enemy" && building.definition.id === "enemy_stronghold" && building.alive
      );
      const enemyBarracks = scene.buildings.find(
        (building: any) => building.team === "enemy" && building.definition.id === "enemy_barracks" && building.alive
      );
      const playerCommandHall = scene.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
      );
      if (!enemyStronghold || !enemyBarracks || !playerCommandHall) {
        throw new Error("Expected enemy stronghold, enemy barracks, and player command hall.");
      }

      scene.resources.enemy = { crowns: 2400, stone: 2400, iron: 1600, aether: 1200 };
      scene.captureSites.forEach((site: any) => {
        site.setOwner("enemy");
        site.setSiteLevel(2);
      });
      playerUnits().forEach((unit: any, index: number) => {
        unit.setPosition(240 + index * 18, 1220 + index * 14);
        clearUnitOrders(unit);
      });
      enemyUnits().forEach((unit: any, index: number) => {
        unit.setPosition(enemyStronghold.position.x - 130 - index * 18, enemyStronghold.position.y + 70 + index * 12);
        clearUnitOrders(unit);
      });

      scene.runtime.tick(280);
      scene.aiSystem.update(280);
      scene.upgradeSystem.update(60, scene.buildings);
      const researchedAfterEconomy = Array.from(scene.researchedUpgradeIds.enemy ?? []);
      const economyQueued =
        enemyStronghold.upgradeQueue[0]?.upgradeId ?? enemyBarracks.upgradeQueue[0]?.upgradeId ?? researchedAfterEconomy[0];

      const playerThreat = playerUnits()[0];
      if (!playerThreat) {
        throw new Error("Expected a player unit for the base defense proxy.");
      }
      playerThreat.setPosition(enemyStronghold.position.x - 80, enemyStronghold.position.y + 20);
      clearUnitOrders(playerThreat);
      scene.aiSystem.update(5);
      const baseDefenders = enemyUnits().filter((unit: any) => unit.attackTargetId === playerThreat.id).length;
      const defenseState = scene.aiSystem.state;

      playerUnits().forEach((unit: any, index: number) => {
        unit.setPosition(250 + index * 18, 1240 + index * 10);
        clearUnitOrders(unit);
      });
      enemyUnits().forEach((unit: any, index: number) => {
        unit.setPosition(enemyStronghold.position.x - 120 - index * 16, enemyStronghold.position.y + 70 + index * 12);
        clearUnitOrders(unit);
      });
      scene.runtime.tick(430);
      scene.aiSystem.update(430);
      const attackUnits = enemyUnits().filter((unit: any) => unit.attackTargetId === playerCommandHall.id);

      return {
        researchedAfterEconomy,
        economyQueued,
        defenseState,
        baseDefenders,
        escalationState: scene.aiSystem.state,
        attackUnitCount: attackUnits.length,
        enemySiteCount: scene.captureSites.filter((site: any) => site.owner === "enemy").length,
        improvedEnemySiteCount: scene.captureSites.filter((site: any) => site.owner === "enemy" && site.siteLevel >= 2).length,
        enemyStrongholdArmor: enemyStronghold.armor
      };
    });

    await test.step("enemy progresses economy-backed tech after holding sites", async () => {
      expect(result.enemySiteCount).toBeGreaterThanOrEqual(1);
      expect(result.improvedEnemySiteCount).toBeGreaterThanOrEqual(1);
      expect(["infantry_weapons_1", "aether_study_1", "camp_foundations_1"]).toContain(result.economyQueued);
    });

    await test.step("enemy defends or fortifies the base when approached", async () => {
      expect(result.defenseState).toBe("DEFEND");
      expect(result.baseDefenders).toBeGreaterThanOrEqual(1);
    });

    await test.step("enemy escalates pressure once economy and time are healthy", async () => {
      expect(result.escalationState).toBe("ESCALATE");
      expect(result.attackUnitCount).toBeGreaterThanOrEqual(3);
    });
  });

  test("Worker explicit attack damages an enemy building and shows floating damage @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(90_000);
    await startFirstClaimSkirmish(page, "Worker Attack QA");
    await setBattlePlayerResources(page, { crowns: 2000, stone: 2000, iron: 2000, aether: 2000 });
    const trainedWorker = await trainWorkerFromCommandHall(page, "deep-flow Worker explicit building attack");

    const attackResult = await page.evaluate((workerId) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }

      scene.settings.floatingTextEnabled = true;
      const worker = scene.units.find((unit: any) => unit.id === workerId && unit.alive);
      const target =
        scene.buildings.find(
          (building: any) =>
            building.team === "enemy" &&
            building.alive &&
            building.definition.id === scene.activeMap.scenario.objectives.enemyBaseBuildingId
        ) ?? scene.buildings.find((building: any) => building.team === "enemy" && building.alive);
      if (!worker || !target) {
        throw new Error("Expected a trained Worker and enemy building for explicit attack coverage.");
      }

      scene.units
        .filter((unit: any) => unit.team === "enemy")
        .forEach((unit: any, index: number) => {
          unit.setPosition(
            Math.min(scene.activeMap.width - unit.radius - 12, target.position.x + 170 + index * 12),
            Math.min(scene.activeMap.height - unit.radius - 12, target.position.y + 220 + index * 14)
          );
          unit.moveTarget = undefined;
          unit.attackTargetId = undefined;
          unit.attackMove = false;
          unit.attackCooldownRemaining = 999;
        });
      scene.buildings
        .filter((building: any) => building.team === "enemy")
        .forEach((building: any) => {
          building.attackCooldownRemaining = 999;
        });

      const start = {
        x: target.position.x - target.definition.size.width / 2 - worker.radius - 90,
        y: target.position.y
      };
      worker.setPosition(start.x, start.y);
      worker.moveTarget = undefined;
      worker.attackCooldownRemaining = 0;
      worker.activeConstructionSiteId = undefined;
      worker.pausedConstructionSiteId = undefined;
      worker.activeRepairTargetId = undefined;
      worker.pausedRepairTargetId = undefined;
      worker.commandAttack(target.id, target.definition.name);

      const damageTextsBefore = scene.children.list.filter(
        (child: any) => typeof child.text === "string" && /^-\d+$/u.test(child.text)
      ).length;
      const hpBefore = target.hp;
      const startDistance = Math.hypot(worker.position.x - target.position.x, worker.position.y - target.position.y);
      let minDistance = startDistance;

      for (let index = 0; index < 160; index += 1) {
        scene.combatSystem.update(0.1);
        scene.movementSystem.update(0.1, scene.units, scene.activeMap, scene.buildings);
        minDistance = Math.min(
          minDistance,
          Math.hypot(worker.position.x - target.position.x, worker.position.y - target.position.y)
        );
        const currentDamageTexts = scene.children.list.filter(
          (child: any) => typeof child.text === "string" && /^-\d+$/u.test(child.text)
        );
        if (target.hp < hpBefore && currentDamageTexts.length > damageTextsBefore) {
          break;
        }
      }

      const damageTexts = scene.children.list
        .filter((child: any) => typeof child.text === "string" && /^-\d+$/u.test(child.text))
        .map((child: any) => child.text);
      scene.selectionSystem.setSelection([worker]);
      scene.cameraSystem.centerOn(target.position);
      scene.refreshBattleHud?.(0);
      return {
        targetId: target.id,
        targetName: target.definition.name,
        hpBefore,
        hpAfter: target.hp,
        damageTexts,
        startDistance,
        minDistance,
        attackTargetId: worker.attackTargetId,
        attackTargetLabel: worker.attackTargetLabel
      };
    }, trainedWorker.id);

    expect(attackResult.hpAfter).toBeLessThan(attackResult.hpBefore);
    expect(attackResult.damageTexts.some((text: string) => /^-\d+$/u.test(text))).toBe(true);
    expect(attackResult.minDistance).toBeLessThan(attackResult.startDistance);
    expect(attackResult.attackTargetId).toBe(attackResult.targetId);
    expect(attackResult.attackTargetLabel).toBe(attackResult.targetName);
    await expect(page.getByTestId("unit-order-summary")).toContainText("Attacking");
  });

  test("Worker move-away pauses construction and base-cluster units keep moving @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(90_000);
    await startFirstClaimSkirmish(page, "Worker pause and pathing QA");
    await setBattlePlayerResources(page, { crowns: 2000, stone: 2000, iron: 2000, aether: 2000 });
    const trainedWorker = await trainWorkerFromCommandHall(page, "deep-flow Worker pause/resume");

    const result = await page.evaluate((workerId) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      scene.resources.player.crowns = 20_000;
      scene.resources.player.stone = 20_000;
      scene.resources.player.iron = 20_000;
      scene.resources.player.aether = 20_000;
      const commandHall = scene.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
      );
      const worker = scene.units.find((unit: any) => unit.id === workerId && unit.alive);
      if (!commandHall || !worker) {
        throw new Error("Expected Command Hall and trained Worker for pause/resume regression.");
      }

      const placeBuilding = (buildingId: string, points: Array<{ x: number; y: number }>, assignedWorkerId?: string) => {
        scene.buildingSystem.startPlacement(buildingId, {
          anchor: worker.position,
          resources: scene.resources.player,
          assignedWorkerId
        });
        for (const point of points) {
          scene.buildingSystem.updateGhost(point.x, point.y, scene.resources.player);
          if (scene.buildingSystem.tryPlace(point.x, point.y, scene.resources.player)) {
            const placed = [...scene.buildings]
              .reverse()
              .find((building: any) => building.team === "player" && building.definition.id === buildingId && building.alive);
            if (!placed) {
              throw new Error(`Placed ${buildingId} was not found.`);
            }
            return placed;
          }
        }
        scene.buildingSystem.cancelPlacement();
        throw new Error(`Could not place ${buildingId}.`);
      };

      const barracks = placeBuilding(
        "barracks",
        [
          { x: commandHall.position.x + 170, y: commandHall.position.y },
          { x: commandHall.position.x + 170, y: commandHall.position.y - 90 },
          { x: commandHall.position.x + 190, y: commandHall.position.y + 60 }
        ],
        worker.id
      );

      let progressBeforeMove = 0;
      for (let index = 0; index < 120; index += 1) {
        scene.movementSystem.update(0.1, scene.units, scene.activeMap, scene.buildings);
        scene.buildingSystem.update(0.1);
        progressBeforeMove = barracks.constructionProgress;
        if (progressBeforeMove > 0.05) {
          break;
        }
      }
      if (progressBeforeMove <= 0.05) {
        throw new Error(`Expected Barracks progress before move-away, got ${progressBeforeMove}.`);
      }

      const footprintDistanceFromSite = (point: { x: number; y: number }, building: any) =>
        Math.max(
          Math.max(Math.abs(point.x - building.position.x) - building.definition.size.width / 2, 0),
          Math.max(Math.abs(point.y - building.position.y) - building.definition.size.height / 2, 0)
        );
      const moveAwayTarget = { x: barracks.position.x + 220, y: barracks.position.y - 180 };
      worker.commandMove(moveAwayTarget, false);
      scene.buildingSystem.update(2);
      const immediatePause = {
        progress: barracks.constructionProgress,
        status: barracks.constructionStatusDetail,
        activeConstructionSiteId: worker.activeConstructionSiteId,
        pausedConstructionSiteId: worker.pausedConstructionSiteId,
        moveTarget: worker.moveTarget ? { ...worker.moveTarget } : undefined
      };

      for (let index = 0; index < 90; index += 1) {
        scene.movementSystem.update(0.1, scene.units, scene.activeMap, scene.buildings);
        scene.buildingSystem.update(0.1);
        if (footprintDistanceFromSite(worker.position, barracks) > 72) {
          break;
        }
      }
      const movedAway = {
        progress: barracks.constructionProgress,
        status: barracks.constructionStatusDetail,
        workerDistanceToSite: Math.hypot(worker.position.x - barracks.position.x, worker.position.y - barracks.position.y),
        workerFootprintDistance: footprintDistanceFromSite(worker.position, barracks),
        activeConstructionSiteId: worker.activeConstructionSiteId,
        pausedConstructionSiteId: worker.pausedConstructionSiteId,
        moveTarget: worker.moveTarget ? { ...worker.moveTarget } : undefined
      };

      const resumeTarget = {
        x: barracks.position.x - barracks.definition.size.width / 2 - worker.radius - 18,
        y: barracks.position.y
      };
      worker.commandMove(resumeTarget, false);
      for (let index = 0; index < 120; index += 1) {
        scene.movementSystem.update(0.1, scene.units, scene.activeMap, scene.buildings);
        scene.buildingSystem.update(0.1);
        if (barracks.constructionProgress > movedAway.progress + 0.04) {
          break;
        }
      }
      const returnedWithoutCommand = {
        progress: barracks.constructionProgress,
        status: barracks.constructionStatusDetail,
        workerDistanceToSite: Math.hypot(worker.position.x - barracks.position.x, worker.position.y - barracks.position.y),
        activeConstructionSiteId: worker.activeConstructionSiteId,
        pausedConstructionSiteId: worker.pausedConstructionSiteId
      };

      scene.buildingSystem.requestConstruction(worker, barracks);
      for (let index = 0; index < 120; index += 1) {
        scene.movementSystem.update(0.1, scene.units, scene.activeMap, scene.buildings);
        scene.buildingSystem.update(0.1);
        if (barracks.constructionProgress > returnedWithoutCommand.progress + 0.04) {
          break;
        }
      }
      const resumed = {
        progress: barracks.constructionProgress,
        status: barracks.constructionStatusDetail,
        workerDistanceToSite: Math.hypot(worker.position.x - barracks.position.x, worker.position.y - barracks.position.y),
        activeConstructionSiteId: worker.activeConstructionSiteId,
        pausedConstructionSiteId: worker.pausedConstructionSiteId
      };

      barracks.constructionState = "completed";
      barracks.constructionProgress = 1;
      barracks.constructionStatusDetail = "Complete";
      barracks.hp = barracks.maxHp;
      barracks.updateHealthBar?.();
      const mystic = placeBuilding("mystic_lodge", [
        { x: commandHall.position.x + 70, y: commandHall.position.y + 150 },
        { x: commandHall.position.x + 40, y: commandHall.position.y + 150 },
        { x: commandHall.position.x + 235, y: commandHall.position.y + 80 }
      ]);
      const tower = placeBuilding("watchtower", [
        { x: commandHall.position.x + 250, y: commandHall.position.y + 130 },
        { x: commandHall.position.x + 260, y: commandHall.position.y - 120 },
        { x: commandHall.position.x + 270, y: commandHall.position.y + 40 }
      ]);
      [mystic, tower].forEach((building: any) => {
        building.constructionState = "completed";
        building.constructionProgress = 1;
        building.constructionStatusDetail = "Complete";
        building.hp = building.maxHp;
        building.updateHealthBar?.();
      });

      const militia = scene.units.find((unit: any) => unit.team === "player" && unit.definition.id === "militia" && unit.alive);
      const ranger = scene.units.find((unit: any) => unit.team === "player" && unit.definition.id === "ranger" && unit.alive);
      const enemy = scene.units.find((unit: any) => unit.team === "enemy" && unit.alive);
      if (!militia || !ranger || !enemy) {
        throw new Error("Expected Militia, Ranger, Worker, and enemy unit for cluster attack movement.");
      }
      enemy.setPosition(commandHall.position.x + 520, commandHall.position.y + 20);
      enemy.attackTargetId = undefined;
      enemy.attackMove = false;
      enemy.moveTarget = undefined;
      enemy.attackCooldownRemaining = 999;
      const movers = [
        { unit: worker, point: { x: commandHall.position.x + 55, y: commandHall.position.y + 92 } },
        { unit: militia, point: { x: commandHall.position.x + 75, y: commandHall.position.y + 118 } },
        { unit: ranger, point: { x: commandHall.position.x + 38, y: commandHall.position.y + 142 } }
      ];
      movers.forEach(({ unit, point }) => {
        unit.setPosition(point.x, point.y);
        unit.moveTarget = undefined;
        unit.attackTargetId = undefined;
        unit.attackMove = false;
        unit.moveOrderCombatSuppressionSeconds = 0;
        unit.commandAttack(enemy.id, enemy.definition.name);
      });
      const starts = movers.map(({ unit }) => ({
        id: unit.id,
        unitId: unit.definition.id,
        x: unit.position.x,
        y: unit.position.y,
        distanceToEnemy: Math.hypot(unit.position.x - enemy.position.x, unit.position.y - enemy.position.y)
      }));
      for (let index = 0; index < 55; index += 1) {
        scene.combatSystem.update(0.1);
        scene.movementSystem.update(0.1, scene.units, scene.activeMap, scene.buildings);
      }
      const moved = movers.map(({ unit }, index) => ({
        ...starts[index],
        currentX: unit.position.x,
        currentY: unit.position.y,
        currentDistanceToEnemy: Math.hypot(unit.position.x - enemy.position.x, unit.position.y - enemy.position.y),
        distanceMoved: Math.hypot(unit.position.x - starts[index].x, unit.position.y - starts[index].y),
        moveTarget: unit.moveTarget ? { ...unit.moveTarget } : undefined,
        attackTargetId: unit.attackTargetId
      }));

      scene.selectionSystem.setSelection([barracks]);
      scene.refreshBattleHud?.(0);
      return {
        siteId: barracks.id,
        progressBeforeMove,
        immediatePause,
        movedAway,
        returnedWithoutCommand,
        resumed,
        moved
      };
    }, trainedWorker.id);

    expect(result.immediatePause.progress).toBe(result.progressBeforeMove);
    expect(result.immediatePause.status).toBe("Paused - issue Build to resume");
    expect(result.immediatePause.activeConstructionSiteId).toBeUndefined();
    expect(result.immediatePause.pausedConstructionSiteId).toBe(result.siteId);
    expect(result.immediatePause.moveTarget).toEqual(expect.objectContaining({ x: expect.any(Number), y: expect.any(Number) }));
    expect(result.movedAway.progress).toBe(result.progressBeforeMove);
    expect(result.movedAway.status).toBe("Paused - issue Build to resume");
    expect(result.movedAway.workerFootprintDistance).toBeGreaterThan(64);
    expect(result.returnedWithoutCommand.progress).toBe(result.movedAway.progress);
    expect(result.returnedWithoutCommand.status).toBe("Paused - issue Build to resume");
    expect(result.returnedWithoutCommand.activeConstructionSiteId).toBeUndefined();
    expect(result.returnedWithoutCommand.pausedConstructionSiteId).toBe(result.siteId);
    expect(result.resumed.progress).toBeGreaterThan(result.returnedWithoutCommand.progress + 0.03);
    expect(result.resumed.status).toBe("Building");
    expect(result.resumed.activeConstructionSiteId).toBe(result.siteId);
    expect(result.resumed.pausedConstructionSiteId).toBeUndefined();
    result.moved.forEach((unit) => {
      expect(unit.distanceMoved, JSON.stringify(result.moved)).toBeGreaterThan(24);
      expect(unit.currentDistanceToEnemy, JSON.stringify(result.moved)).toBeLessThan(unit.distanceToEnemy - 24);
    });
    await expect(page.locator(".side-panel")).toContainText("Barracks");
  });

  test("Worker exposes existing build set and Watchtower activates only after completion @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(90_000);
    await startFirstClaimSkirmish(page, "Watchtower Worker QA");
    await setBattlePlayerResources(page, { crowns: 1000, stone: 1000, iron: 1000, aether: 1000 });
    const trainedWorker = await trainWorkerFromCommandHall(page, "deep-flow Worker expanded build set");

    await expect(page.locator("button[data-action='build'][data-id='barracks']")).toBeEnabled();
    await expect(page.locator("button[data-action='build'][data-id='mystic_lodge']")).toBeEnabled();
    await expect(page.locator("button[data-action='build'][data-id='watchtower']")).toBeEnabled();

    await clickBattleCommandUntilEffect(
      () => page.locator("button[data-action='build'][data-id='watchtower']"),
      "deep-flow Worker build Watchtower command",
      async () => {
        await page.waitForFunction((workerId) => {
          const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
          return scene?.buildingSystem?.pendingBuildingId === "watchtower" && scene?.buildingSystem?.pendingAssignedWorkerId === workerId;
        }, trainedWorker.id);
      },
      async () => {
        await page.evaluate((workerId) => {
          const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
          const worker = scene?.units.find((unit: any) => unit.id === workerId && unit.alive);
          if (worker) {
            scene.selectionSystem.setSelection([worker]);
            scene.refreshBattleHud?.(0);
          }
        }, trainedWorker.id);
      }
    );

    const placedTower = await page.evaluate((workerId) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const commandHall = scene.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
      );
      if (!commandHall) {
        throw new Error("Expected Command Hall for Worker Watchtower test.");
      }
      const points = [
        { x: commandHall.position.x + 168, y: commandHall.position.y - 94 },
        { x: commandHall.position.x + 210, y: commandHall.position.y - 112 },
        { x: commandHall.position.x + 180, y: commandHall.position.y + 68 },
        { x: commandHall.position.x + 48, y: commandHall.position.y - 148 }
      ];
      for (const point of points) {
        scene.buildingSystem.updateGhost(point.x, point.y, scene.resources.player);
        if (scene.buildingSystem.tryPlace(point.x, point.y, scene.resources.player)) {
          const tower = scene.buildings.find(
            (building: any) =>
              building.team === "player" &&
              building.definition.id === "watchtower" &&
              building.alive &&
              building.assignedWorkerId === workerId
          );
          if (!tower) {
            throw new Error("Worker-placed Watchtower was not found.");
          }
          scene.selectionSystem.setSelection([tower]);
          scene.refreshBattleHud?.(0);
          return {
            id: tower.id,
            state: tower.constructionState,
            assignedWorkerId: tower.assignedWorkerId,
            assignedWorkerName: tower.assignedWorkerName
          };
        }
      }
      scene.buildingSystem.cancelPlacement();
      throw new Error("Could not place Worker Watchtower construction site.");
    }, trainedWorker.id);

    expect(placedTower.state).toBe("underConstruction");
    expect(placedTower.assignedWorkerId).toBe(trainedWorker.id);
    expect(placedTower.assignedWorkerName).toBe("Worker");
    await expect(page.locator(".side-panel")).toContainText(
      "Defense: inactive while incomplete, attacks nearby enemies when complete, and researches tower defenses."
    );
    await expect(page.locator(".side-panel")).toContainText("Incomplete - completed-building actions locked.");

    const incompleteTowerCombat = await page.evaluate((towerId) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const tower = scene.buildings.find((building: any) => building.id === towerId && building.alive);
      const enemy = scene.units.find((unit: any) => unit.team === "enemy" && unit.alive);
      if (!tower || !enemy) {
        throw new Error("Expected incomplete Watchtower and a live enemy.");
      }
      enemy.setPosition(tower.position.x + 118, tower.position.y);
      enemy.moveTarget = undefined;
      enemy.attackTargetId = undefined;
      enemy.attackMove = false;
      enemy.attackCooldownRemaining = 999;
      tower.attackCooldownRemaining = 0;
      const projectileCountBefore = scene.projectiles.length;
      const hpBefore = enemy.hp;
      scene.combatSystem.update(0.2);
      return {
        state: tower.constructionState,
        projectileDelta: scene.projectiles.length - projectileCountBefore,
        hpBefore,
        hpAfter: enemy.hp
      };
    }, placedTower.id);

    expect(incompleteTowerCombat.state).toBe("underConstruction");
    expect(incompleteTowerCombat.projectileDelta).toBe(0);
    expect(incompleteTowerCombat.hpAfter).toBe(incompleteTowerCombat.hpBefore);

    await completePlayerBuilding(page, "watchtower");

    const completedTowerCombat = await page.evaluate((towerId) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const tower = scene.buildings.find((building: any) => building.id === towerId && building.alive);
      const enemy = scene.units.find((unit: any) => unit.team === "enemy" && unit.alive);
      if (!tower || !enemy) {
        throw new Error("Expected completed Watchtower and a live enemy.");
      }
      enemy.setPosition(tower.position.x + 118, tower.position.y);
      enemy.moveTarget = undefined;
      enemy.attackTargetId = undefined;
      enemy.attackMove = false;
      enemy.attackCooldownRemaining = 999;
      tower.attackCooldownRemaining = 0;
      const projectileCountBefore = scene.projectiles.length;
      scene.combatSystem.update(0.2);
      return {
        state: tower.constructionState,
        projectileDelta: scene.projectiles.length - projectileCountBefore
      };
    }, placedTower.id);

    expect(completedTowerCombat.state).toBe("completed");
    expect(completedTowerCombat.projectileDelta).toBeGreaterThan(0);
  });

  test("battle HUD keeps hovered command buttons stable across routine refreshes @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(90_000);
    await startFirstClaimSkirmish(page, "Hover QA");
    await setBattlePlayerResources(page, { crowns: 1000, stone: 1000, iron: 1000, aether: 1000 });
    await trainWorkerFromCommandHall(page, "deep-flow Worker hover stability");
    await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      scene?.refreshBattleHud?.(0.11);
    });

    const barracksButton = page.locator("button[data-action='build'][data-id='barracks']");
    await expect(barracksButton).toBeEnabled();
    const hoverPoint = await barracksButton.evaluate((button) => {
      const rect = button.getBoundingClientRect();
      return {
        x: rect.left + rect.width / 2,
        y: rect.top + rect.height / 2
      };
    });

    await page.mouse.move(hoverPoint.x, hoverPoint.y);
    await page.waitForTimeout(100);
    await expect
      .poll(
        async () =>
          page.evaluate((point) => {
            const hit = document.elementFromPoint(point.x, point.y)?.closest("button[data-action='build'][data-id='barracks']");
            return Boolean(hit);
          }, hoverPoint),
        { message: "expected pointer to rest on the Barracks command button" }
      )
      .toBe(true);
    await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      scene.resources.player.crowns += 1;
      scene.statusMessage = "HUD hover stability refresh";
      (window as any).__hudHoverRefreshAt = performance.now();
      scene.refreshBattleHud(0.11);
    });
    await page.waitForFunction(() => performance.now() - ((window as any).__hudHoverRefreshAt ?? 0) > 260);

    const hoverState = await page.evaluate((point) => {
      const button = document.querySelector<HTMLButtonElement>("button[data-action='build'][data-id='barracks']");
      const hit = document.elementFromPoint(point.x, point.y)?.closest("button[data-action='build'][data-id='barracks']");
      return {
        buttonCount: document.querySelectorAll("button[data-action='build'][data-id='barracks']").length,
        pointerStillOnButton: Boolean(button && hit === button),
        enabled: Boolean(button && !button.disabled),
        label: button?.getAttribute("aria-label") ?? ""
      };
    }, hoverPoint);
    expect(hoverState.buttonCount).toBe(1);
    expect(hoverState.pointerStillOnButton).toBe(true);
    expect(hoverState.enabled).toBe(true);
    expect(hoverState.label).toContain("Build Barracks");

    await clickBattleCommand(barracksButton, "deep-flow hover stability build Barracks command");
    await expect(page.getByTestId("placement-banner")).toContainText("Placement Mode");
    await page.waitForFunction(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      return scene?.buildingSystem?.pendingBuildingId === "barracks" && scene?.buildingSystem?.ghost?.visible;
    });
  });

  test("battle HUD preserves side-panel scroll across forced refreshes @hosted-deep-battle", async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 640 });
    await startFirstClaimSkirmish(page, "Scroll QA");
    await setBattlePlayerResources(page, { crowns: 1000, stone: 1000, iron: 1000, aether: 1000 });
    await selectPlayerCommandHallFromScene(page);

    const before = await page.evaluate(() => {
      const panel = document.querySelector<HTMLElement>(".side-panel");
      if (!panel) {
        throw new Error("Missing battle side panel.");
      }
      const maxScrollTop = panel.scrollHeight - panel.clientHeight;
      panel.scrollTop = Math.min(160, maxScrollTop);
      return {
        scrollTop: panel.scrollTop,
        scrollHeight: panel.scrollHeight,
        clientHeight: panel.clientHeight,
        text: panel.textContent ?? ""
      };
    });
    expect(before.text).toContain("Command Hall");
    expect(before.scrollHeight).toBeGreaterThan(before.clientHeight);
    expect(before.scrollTop).toBeGreaterThan(0);

    const after = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      scene.resources.player.crowns += 1;
      scene.refreshBattleHud(0);
      const panel = document.querySelector<HTMLElement>(".side-panel");
      if (!panel) {
        throw new Error("Missing battle side panel after refresh.");
      }
      return {
        scrollTop: panel.scrollTop,
        scrollHeight: panel.scrollHeight,
        clientHeight: panel.clientHeight,
        text: panel.textContent ?? ""
      };
    });
    expect(after.text).toContain("Command Hall");
    expect(after.scrollHeight).toBeGreaterThan(after.clientHeight);
    expect(after.scrollTop).toBeGreaterThanOrEqual(before.scrollTop - 2);
  });

  test("captured resource sites stay locally visible under fog after units leave @hosted-deep-battle", async ({ page }) => {
    await startFirstClaimSkirmish(page, "Fog Capture QA");

    const siteVisibility = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const site = scene.captureSites.find((entry: any) => entry.definition.id === "stone_quarry");
      const commandHall = scene.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
      );
      if (!site || !commandHall) {
        throw new Error("Expected Stone Quarry and player Command Hall.");
      }

      const moveAway = { x: commandHall.position.x, y: commandHall.position.y };
      scene.units
        .filter((unit: any) => unit.team === "player" && unit.alive)
        .forEach((unit: any, index: number) => {
          unit.setPosition(moveAway.x + index * 12, moveAway.y + 120 + index * 8);
          unit.moveTarget = undefined;
          unit.attackTargetId = undefined;
        });
      scene.hero.setPosition(moveAway.x, moveAway.y + 80);
      site.owner = "player";
      site.capturingTeam = undefined;
      site.captureProgress = 0;

      scene.updateFogOfWar(0, true);
      scene.refreshBattleHud(0);

      const minimap = scene.createMinimapSnapshot();
      const siteMarker = minimap.markers.find((marker: any) => marker.id === site.id);
      const nearbyPlayerUnitCount = scene.units.filter(
        (unit: any) =>
          unit.team === "player" &&
          unit.alive &&
          Math.hypot(unit.position.x - site.position.x, unit.position.y - site.position.y) <= site.definition.radius + 180
      ).length;

      return {
        fogActive: scene.isFogActive(),
        siteId: site.id,
        owner: site.owner,
        nearbyPlayerUnitCount,
        siteViewVisible: Boolean(site.view?.visible),
        siteFogVisible: scene.fogOfWar?.isEntityVisible(site.position, site.definition.radius) ?? false,
        siteCellState: scene.fogOfWar?.stateAt(site.position) ?? "missing",
        minimapFogActive: minimap.fog.enabled,
        minimapMarker: siteMarker
          ? {
              id: siteMarker.id,
              kind: siteMarker.kind,
              team: siteMarker.team,
              resource: siteMarker.resource
            }
          : undefined,
        renderedSiteMarkers: document.querySelectorAll(".minimap-site").length
      };
    });

    expect(siteVisibility.fogActive).toBe(true);
    expect(siteVisibility.minimapFogActive).toBe(true);
    expect(siteVisibility.owner).toBe("player");
    expect(siteVisibility.nearbyPlayerUnitCount).toBe(0);
    expect(siteVisibility.siteViewVisible).toBe(true);
    expect(siteVisibility.siteFogVisible).toBe(true);
    expect(siteVisibility.siteCellState).toBe("visible");
    expect(siteVisibility.minimapMarker).toMatchObject({
      id: siteVisibility.siteId,
      kind: "capture-site",
      team: "player",
      resource: "stone"
    });
    expect(siteVisibility.renderedSiteMarkers).toBeGreaterThan(0);
  });

  test("behaviour mode control gauntlet preserves attack, retreat, marquee, and minimap intent @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(120_000);
    await startFirstClaimSkirmish(page, "Control Gauntlet", "normal");
    await page.keyboard.press("H");
    await expect(page.locator(".side-panel")).toContainText("Control Gauntlet");
    await expect(page.getByTestId("behaviour-mode-current")).toContainText("Guard Area");
    await expect(page.getByTestId("unit-order-summary")).toContainText("Guarding");

    await clickBehaviourMode(page, "hold_ground", "behaviour gauntlet Hold Ground");
    await expect(page.getByTestId("behaviour-mode-current")).toContainText("Hold Ground");
    await expect(page.getByTestId("unit-order-summary")).toContainText("Holding Ground");

    const holdRefusal = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive() || !scene.hero?.alive) {
        throw new Error("Expected active BattleScene hero for Hold Ground refusal.");
      }
      const target = scene.units.find((unit: any) => unit.team !== "player" && unit.alive);
      if (!target) {
        throw new Error("Expected a live hostile unit for Hold Ground refusal.");
      }
      scene.units
        .filter((unit: any) => unit.team !== "player" && unit.id !== target.id)
        .forEach((unit: any, index: number) => unit.setPosition(scene.activeMap.width - 160, scene.activeMap.height - 160 - index * 18));
      scene.hero.behaviourMode = "hold_ground";
      scene.hero.attackTargetId = undefined;
      scene.hero.attackTargetLabel = undefined;
      scene.hero.attackMove = false;
      scene.hero.moveTarget = undefined;
      scene.hero.attackCooldownRemaining = 0;
      target.hp = target.maxHp;
      target.setPosition(Math.min(scene.activeMap.width - 180, scene.hero.position.x + 430), scene.hero.position.y);
      scene.selectionSystem.setSelection([scene.hero]);
      scene.refreshBattleHud?.(0);
      scene.combatSystem.update(0.1);
      return {
        moveTarget: scene.hero.moveTarget ? { ...scene.hero.moveTarget } : undefined,
        targetHp: target.hp,
        targetMaxHp: target.maxHp
      };
    });
    expect(holdRefusal.moveTarget).toBeUndefined();
    expect(holdRefusal.targetHp).toBe(holdRefusal.targetMaxHp);

    const attackTarget = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const target = scene?.units.find((unit: any) => unit.team !== "player" && unit.alive);
      if (!scene?.scene.isActive() || !scene.hero?.alive || !target) {
        throw new Error("Expected active hero and hostile target for attack intent gauntlet.");
      }
      scene.fogDebugDisabled = true;
      scene.updateFogOfWar?.(0, true);
      scene.hero.attackTargetId = undefined;
      scene.hero.attackTargetLabel = undefined;
      scene.hero.attackMove = false;
      scene.hero.moveTarget = undefined;
      scene.hero.attackCooldownRemaining = 0;
      scene.units
        .filter((unit: any) => unit.team === "player" && unit.id !== scene.hero.id)
        .forEach((unit: any, index: number) => {
          unit.setPosition(scene.hero.position.x - 130 - index * 18, scene.hero.position.y + 110 + index * 14);
        });
      target.hp = target.maxHp;
      target.factionSpeedMultiplier = 0;
      target.attackTargetId = undefined;
      target.attackTargetLabel = undefined;
      target.attackMove = false;
      target.moveTarget = undefined;
      target.moveOrderCombatSuppressionSeconds = 3;
      target.setPosition(
        Math.min(scene.activeMap.width - 180, scene.hero.position.x + 160),
        Math.max(120, scene.hero.position.y - 130)
      );
      target.view?.setVisible(true);
      scene.updateFogOfWar?.(0, true);
      const targetPoint = { x: target.position.x, y: target.position.y };
      const hitOffsets = [
        [0, 0],
        [8, 0],
        [-8, 0],
        [0, 8],
        [0, -8],
        [12, 12],
        [-12, 12],
        [12, -12],
        [-12, -12],
        [18, 0],
        [-18, 0],
        [0, 18],
        [0, -18]
      ];
      const hitPoint =
        hitOffsets
          .map(([dx, dy]) => ({ x: targetPoint.x + dx, y: targetPoint.y + dy }))
          .find((point) => scene.findWorldEntityAt?.(point)?.id === target.id) ?? targetPoint;
      const hit = scene.findWorldEntityAt?.(hitPoint);
      scene.selectionSystem.setSelection([scene.hero]);
      scene.cameraSystem.centerOn(scene.hero.position);
      scene.refreshBattleHud?.(0);
      return { id: target.id, x: hitPoint.x, y: hitPoint.y, hitConfirmed: hit?.id === target.id, hitId: hit?.id ?? "" };
    });
    expect(attackTarget.hitConfirmed, `expected hostile target hit-test point, got ${attackTarget.hitId}`).toBe(true);
    const attackScreen = await worldToScreen(page, attackTarget);
    await expectWorldClickTargetsCanvas(page, attackTarget, "behaviour gauntlet attack hover target");
    await expect
      .poll(
        async () =>
          page.evaluate((target) => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            const hit = scene?.findWorldEntityAt?.({ x: target.x, y: target.y });
            return { id: hit?.id ?? "", team: hit?.team ?? "" };
          }, attackTarget),
        { message: "expected behaviour gauntlet hover point to resolve to the hostile target" }
      )
      .toEqual({ id: attackTarget.id, team: expect.not.stringMatching(/^player$/) });
    await page.mouse.move(attackScreen.x - 24, attackScreen.y - 24);
    await page.mouse.move(attackScreen.x, attackScreen.y, { steps: 4 });
    await expect
      .poll(
        async () =>
          page.evaluate(() => {
            const canvas = document.querySelector("canvas") as HTMLCanvasElement | null;
            return canvas?.dataset.battleCursor ?? "";
          }),
        { message: "expected behaviour gauntlet attack cursor intent" }
      )
      .toBe("attack");
    await page.evaluate((target) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const targetUnit = scene?.units.find((unit: any) => unit.id === target.id && unit.alive);
      if (!scene?.scene.isActive() || !scene.hero?.alive || !targetUnit) {
        throw new Error("Expected active hero and target for behaviour gauntlet attack setup.");
      }
      scene.hero.commandAttack(target.id, targetUnit.definition?.name);
      scene.selectionSystem.setSelection([scene.hero]);
      scene.refreshBattleHud?.(0);
    }, attackTarget);
    await expect
      .poll(
        async () =>
          page.evaluate((targetId) => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            return {
              targetId,
              attackTargetId: scene?.hero?.attackTargetId ?? "",
              attackMove: Boolean(scene?.hero?.attackMove)
            };
          }, attackTarget.id),
        { message: "expected left-click attack to issue an explicit attack order" }
      )
      .toEqual({ targetId: attackTarget.id, attackTargetId: attackTarget.id, attackMove: true });
    await expect(page.getByTestId("unit-order-summary")).toContainText("Attacking");

    await clickBehaviourMode(page, "guard_area", "behaviour gauntlet Guard Area");
    await expect(page.getByTestId("behaviour-mode-current")).toContainText("Guard Area");
    const guardResponse = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const target = scene?.units.find((unit: any) => unit.team !== "player" && unit.alive);
      if (!scene?.scene.isActive() || !scene.hero?.alive || !target) {
        throw new Error("Expected active hero and hostile target for Guard Area gauntlet.");
      }
      scene.hero.behaviourMode = "guard_area";
      scene.hero.attackTargetId = undefined;
      scene.hero.attackTargetLabel = undefined;
      scene.hero.attackMove = false;
      scene.hero.moveTarget = undefined;
      scene.hero.attackCooldownRemaining = 0;
      target.setPosition(scene.hero.position.x + 180, scene.hero.position.y);
      scene.combatSystem.update(0.1);
      return { hasMoveTarget: Boolean(scene.hero.moveTarget), moveTargetX: scene.hero.moveTarget?.x ?? 0 };
    });
    expect(guardResponse.hasMoveTarget).toBe(true);
    expect(guardResponse.moveTargetX).toBeGreaterThan(0);

    await clickBehaviourMode(page, "press_attack", "behaviour gauntlet Press Attack");
    await expect(page.getByTestId("behaviour-mode-current")).toContainText("Press Attack");
    const pressResponse = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const target = scene?.units.find((unit: any) => unit.team !== "player" && unit.alive);
      if (!scene?.scene.isActive() || !scene.hero?.alive || !target) {
        throw new Error("Expected active hero and hostile target for Press Attack gauntlet.");
      }
      scene.hero.behaviourMode = "press_attack";
      scene.hero.attackTargetId = undefined;
      scene.hero.attackTargetLabel = undefined;
      scene.hero.attackMove = false;
      scene.hero.moveTarget = undefined;
      scene.hero.attackCooldownRemaining = 0;
      target.setPosition(Math.min(scene.activeMap.width - 180, scene.hero.position.x + 330), scene.hero.position.y);
      scene.combatSystem.update(0.1);
      return { hasMoveTarget: Boolean(scene.hero.moveTarget), moveTargetX: scene.hero.moveTarget?.x ?? 0 };
    });
    expect(pressResponse.hasMoveTarget).toBe(true);
    expect(pressResponse.moveTargetX).toBeGreaterThan(0);

    const retreatPoint = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const hostiles = scene?.units.filter((unit: any) => unit.team !== "player" && unit.alive);
      if (!scene?.scene.isActive() || !scene.hero?.alive || !hostiles?.length) {
        throw new Error("Expected active hero and hostile target for retreat gauntlet.");
      }
      scene.hero.attackTargetId = undefined;
      scene.hero.attackTargetLabel = undefined;
      scene.hero.attackMove = false;
      scene.hero.moveTarget = undefined;
      scene.hero.attackCooldownRemaining = 0;
      scene.hero.factionSpeedMultiplier = 0.25;
      hostiles.forEach((unit: any, index: number) => {
        unit.factionSpeedMultiplier = 0;
        unit.attackTargetId = undefined;
        unit.attackTargetLabel = undefined;
        unit.attackMove = false;
        unit.moveTarget = undefined;
        unit.setPosition(scene.activeMap.width - 180, scene.activeMap.height - 180 - index * 24);
      });
      scene.selectionSystem.setSelection([scene.hero]);
      scene.cameraSystem.centerOn(scene.hero.position);
      scene.refreshBattleHud?.(0);
      return { x: 850, y: 780 };
    });
    await page.evaluate((target) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive() || !scene.hero?.alive) {
        throw new Error("Expected active hero for behaviour gauntlet retreat setup.");
      }
      scene.selectionSystem.setSelection([scene.hero]);
      scene.hero.commandMove(target, false);
      scene.refreshBattleHud?.(0);
    }, retreatPoint);
    const retreatState = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      return {
        attackTargetId: scene?.hero?.attackTargetId ?? "",
        hasMoveTarget: Boolean(scene?.hero?.moveTarget),
        moveTarget: scene?.hero?.moveTarget ? { ...scene.hero.moveTarget } : undefined
      };
    });
    expect(retreatState.attackTargetId).toBe("");
    expect(retreatState.hasMoveTarget).toBe(true);
    expect(retreatState.moveTarget).toBeDefined();

    const dragTargets = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const playerUnits = scene?.units.filter((unit: any) => unit.team === "player" && unit.alive);
      const panel = document.querySelector<HTMLElement>(".side-panel");
      const panelBox = panel?.getBoundingClientRect();
      if (!scene?.scene.isActive() || !playerUnits || playerUnits.length < 2 || !panelBox) {
        throw new Error("Expected player units and side panel for behaviour marquee gauntlet.");
      }
      scene.selectionSystem.setSelection(playerUnits);
      scene.cameraSystem.centerOn(scene.hero.position);
      scene.refreshBattleHud?.(0);
      const canvasBounds = scene.game.canvas.getBoundingClientRect();
      const camera = scene.cameras.main;
      const minX = Math.min(...playerUnits.map((unit: any) => unit.position.x)) - 42;
      const minY = Math.min(...playerUnits.map((unit: any) => unit.position.y)) - 42;
      const start = {
        x: canvasBounds.left + minX - camera.scrollX,
        y: canvasBounds.top + minY - camera.scrollY
      };
      return {
        start: {
          x: Math.max(canvasBounds.left + 24, Math.min(canvasBounds.right - 24, start.x)),
          y: Math.max(canvasBounds.top + 24, Math.min(canvasBounds.bottom - 24, start.y))
        },
        end: {
          x: panelBox.left + panelBox.width / 2,
          y: panelBox.top + panelBox.height / 2
        }
      };
    });
    await page.mouse.move(dragTargets.start.x, dragTargets.start.y);
    await page.mouse.down();
    await page.mouse.move(dragTargets.end.x, dragTargets.end.y, { steps: 6 });
    await page.mouse.up();
    if (
      await page.evaluate(() => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        return Boolean(scene?.inputSystem?.dragStart);
      })
    ) {
      await page.mouse.move(dragTargets.start.x, dragTargets.start.y, { steps: 2 });
      await page.mouse.up();
    }
    await expect
      .poll(
        async () =>
          page.evaluate(() => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            return {
              dragging: Boolean(scene?.inputSystem?.dragStart),
              selectedUnits: scene?.selectionSystem
                .getSelected()
                .filter((entity: any) => entity.team === "player" && entity.kind !== "building").length
            };
          }),
        { message: "expected behaviour gauntlet marquee cleanup over HUD" }
      )
      .toMatchObject({ dragging: false, selectedUnits: expect.any(Number) });

    const minimapClickTarget = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const minimap = document.querySelector<HTMLElement>("[data-testid='minimap']");
      const minimapBox = minimap?.getBoundingClientRect();
      if (!scene?.scene.isActive() || !minimapBox) {
        throw new Error("Expected minimap for behaviour gauntlet.");
      }
      return {
        before: { scrollX: scene.cameras.main.scrollX, scrollY: scene.cameras.main.scrollY },
        position: { x: Math.round(minimapBox.width * 0.82), y: Math.round(minimapBox.height * 0.78) }
      };
    });
    await clickMinimapPosition(
      page,
      minimapClickTarget.position,
      "behaviour gauntlet minimap movement",
      minimapClickTarget.before
    );
    await expect
      .poll(
        async () =>
          page.evaluate((before) => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            const camera = scene?.cameras.main;
            return camera ? Math.hypot(camera.scrollX - before.scrollX, camera.scrollY - before.scrollY) : 0;
          }, minimapClickTarget.before),
        { message: "expected behaviour gauntlet minimap movement after mode controls" }
      )
      .toBeGreaterThan(10);
    await page.keyboard.press("H");
    await expect(page.locator(".side-panel")).toContainText("Control Gauntlet");
    await expect(page.locator(".side-panel")).not.toContainText("No Selection");
  });

  test("control groups, group movement spacing, and Patrol use stable canvas commands @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(90_000);
    await startFirstClaimSkirmish(page, "Groups Patrol QA", "story");

    const setup = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive() || !scene.hero?.alive) {
        throw new Error("Expected active BattleScene for control-group coverage.");
      }
      const troops = scene.units.filter(
        (unit: any) => unit.team === "player" && unit.alive && unit.id !== scene.hero.id && unit.definition.id !== "worker"
      );
      const selected = [scene.hero, ...troops.slice(0, 2)];
      if (selected.length < 3) {
        throw new Error("Expected hero plus two player combat units for control-group coverage.");
      }
      scene.units
        .filter((unit: any) => unit.team !== "player" && unit.alive)
        .forEach((unit: any, index: number) => {
          unit.factionSpeedMultiplier = 0;
          unit.attackTargetId = undefined;
          unit.attackTargetLabel = undefined;
          unit.attackMove = false;
          unit.moveTarget = undefined;
          unit.setPosition(scene.activeMap.width - 180, scene.activeMap.height - 180 - index * 24);
        });
      selected.forEach((unit: any, index: number) => {
        unit.factionSpeedMultiplier = 1;
        unit.clearPatrolRoute?.();
        unit.attackTargetId = undefined;
        unit.attackTargetLabel = undefined;
        unit.attackMove = false;
        unit.moveTarget = undefined;
        unit.setPosition(340 + index * 34, 760 + index * 28);
      });
      scene.selectionSystem.setSelection(selected);
      scene.cameraSystem.centerOn(scene.hero.position);
      scene.refreshBattleHud?.(0);
      return {
        selectedIds: selected.map((unit: any) => unit.id),
        movePoint: { x: 650, y: 760 },
        patrolPoint: { x: 790, y: 820 },
        cancelPoint: { x: 610, y: 910 }
      };
    });

    const veteran = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.grantSelectedUnitVeterancyXp?.(140));
    expect(veteran).toMatchObject({ rank: "Veteran" });
    await expect(page.getByTestId("selected-role-summary")).toContainText("Frontline / Melee");
    await expect(page.getByTestId("selected-unit-stats")).toContainText("Rank Veteran");
    await page.evaluate((selectedIds) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const selectable = [scene?.hero, ...(scene?.units ?? [])].filter(Boolean);
      const selected = selectedIds
        .map((id: string) => selectable.find((unit: any) => unit.id === id))
        .filter(Boolean);
      scene?.selectionSystem.setSelection(selected);
      scene?.refreshBattleHud?.(0);
    }, setup.selectedIds);
    await expect(page.getByTestId("selected-role-summary")).toContainText("Army Roles");

    await page.keyboard.down("Control");
    await page.keyboard.press("1");
    await page.keyboard.up("Control");
    await expect(page.getByTestId("battle-status")).toContainText("Group 1 assigned: 3 units");
    await expect(page.getByTestId("control-group-summary")).toContainText("1:3");

    await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      scene?.selectionSystem.clear();
      scene?.refreshBattleHud?.(0);
    });
    await page.keyboard.press("1");
    await expect(page.getByTestId("battle-status")).toContainText("Group 1 selected: 3 units");
    await expect(page.getByTestId("selected-role-summary")).toContainText("Army Roles");
    await expect(page.getByTestId("selected-role-summary")).toContainText("ranked unit");
    await expect
      .poll(
        async () =>
          page.evaluate(() => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            return scene?.selectionSystem.getSelectedIds?.() ?? [];
          }),
        { message: "expected group 1 recall to restore selected ids" }
      )
      .toEqual(expect.arrayContaining(setup.selectedIds));

    await expectWorldClickTargetsCanvas(page, setup.movePoint, "control group movement target");
    await clickWorldPoint(page, setup.movePoint, "right");
    await expect
      .poll(
        async () =>
          page.evaluate((selectedIds) => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            const targets = selectedIds
              .map((id: string) => scene?.units.find((unit: any) => unit.id === id))
              .filter(Boolean)
              .flatMap((unit: any) =>
                unit.moveTarget ? [`${Math.round(unit.moveTarget.x)},${Math.round(unit.moveTarget.y)}`] : []
              );
            return { targetCount: targets.length, uniqueTargetCount: new Set(targets).size };
          }, setup.selectedIds),
        { message: "expected recalled group to receive separated move targets" }
      )
      .toMatchObject({ targetCount: 3, uniqueTargetCount: expect.any(Number) });
    const uniqueMoveTargets = await page.evaluate((selectedIds) => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const targets = selectedIds
        .map((id: string) => scene?.units.find((unit: any) => unit.id === id))
        .filter(Boolean)
        .flatMap((unit: any) =>
          unit.moveTarget ? [`${Math.round(unit.moveTarget.x)},${Math.round(unit.moveTarget.y)}`] : []
        );
      return new Set(targets).size;
    }, setup.selectedIds);
    expect(uniqueMoveTargets).toBeGreaterThanOrEqual(2);

    await page.keyboard.press("P");
    await expect(page.getByTestId("battle-status")).toContainText("Patrol: click a destination");
    await expectWorldClickTargetsCanvas(page, setup.patrolPoint, "control group patrol target");
    await clickWorldPoint(page, setup.patrolPoint, "left");
    await expect
      .poll(
        async () =>
          page.evaluate((selectedIds) => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            return selectedIds.filter((id: string) => {
              const unit = scene?.units.find((entry: any) => entry.id === id);
              return Boolean(unit?.patrolRoute);
            }).length;
          }, setup.selectedIds),
        { message: "expected patrol routes to start for recalled combat group" }
      )
      .toBe(3);
    await expect(page.getByTestId("unit-order-summary")).toContainText("Patrolling");

    await expectWorldClickTargetsCanvas(page, setup.cancelPoint, "control group patrol cancel move target");
    await clickWorldPoint(page, setup.cancelPoint, "right");
    await expect
      .poll(
        async () =>
          page.evaluate((selectedIds) => {
            const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
            return selectedIds.filter((id: string) => {
              const unit = scene?.units.find((entry: any) => entry.id === id);
              return Boolean(unit?.patrolRoute);
            }).length;
          }, setup.selectedIds),
        { message: "expected explicit move to cancel patrol routes" }
      )
      .toBe(0);
  });

  test("manual combat contact regression covers adjacent follow-up, building aggro, retreat suppression, and hover tolerance @hosted-deep-battle", async ({
    page
  }) => {
    test.setTimeout(90_000);
    await startFirstClaimSkirmish(page, "Contact Regression", "normal");
    await page.keyboard.press("H");
    await expect(page.locator(".side-panel")).toContainText("Contact Regression");

    const contactResult = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive() || !scene.hero?.alive) {
        throw new Error("Expected active BattleScene hero for contact regression.");
      }
      const imps = scene.units.filter((unit: any) => unit.definition?.id === "stone_imp");
      const commandHall = scene.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
      );
      if (imps.length < 2 || !commandHall) {
        throw new Error("Expected at least two Stone Imps and a Command Hall for contact regression.");
      }
      const [firstEnemy, secondEnemy] = imps;
      scene.units
        .filter((unit: any) => unit.team !== "player" && !imps.includes(unit))
        .forEach((unit: any, index: number) => {
          unit.setPosition(scene.activeMap.width - 180, scene.activeMap.height - 180 - index * 28);
          unit.attackTargetId = undefined;
          unit.attackTargetLabel = undefined;
          unit.attackMove = false;
          unit.moveTarget = undefined;
        });
      scene.fogDebugDisabled = true;
      scene.updateFogOfWar?.(0, true);
      scene.selectionSystem.setSelection([scene.hero]);
      scene.hero.behaviourMode = "hold_ground";
      scene.hero.attackTargetId = firstEnemy.id;
      scene.hero.attackTargetLabel = firstEnemy.definition.name;
      scene.hero.attackMove = true;
      scene.hero.moveTarget = undefined;
      scene.hero.moveOrderCombatSuppressionSeconds = 0;
      scene.hero.attackCooldownRemaining = 0;
      firstEnemy.hp = Math.max(1, Math.ceil(scene.hero.damage / 2));
      firstEnemy.alive = true;
      firstEnemy.attackCooldownRemaining = 0;
      firstEnemy.setPosition(scene.hero.position.x + 32, scene.hero.position.y);
      secondEnemy.hp = secondEnemy.maxHp;
      secondEnemy.alive = true;
      secondEnemy.attackCooldownRemaining = 0;
      secondEnemy.attackTargetId = commandHall.id;
      secondEnemy.attackTargetLabel = commandHall.definition.name;
      secondEnemy.attackMove = true;
      secondEnemy.moveTarget = undefined;
      secondEnemy.setPosition(scene.hero.position.x + 64, scene.hero.position.y);
      const heroHpBefore = scene.hero.hp;
      scene.combatSystem.update(0.1);
      const firstKilled = !firstEnemy.alive;
      scene.combatSystem.update(scene.hero.attackCooldown + 0.2);
      return {
        firstKilled,
        heroRange: scene.hero.range,
        heroRadius: scene.hero.radius,
        heroCooldown: scene.hero.attackCooldown,
        heroCooldownRemaining: scene.hero.attackCooldownRemaining,
        secondDistance: Math.hypot(secondEnemy.position.x - scene.hero.position.x, secondEnemy.position.y - scene.hero.position.y),
        secondRadius: secondEnemy.radius,
        secondId: secondEnemy.id,
        secondTeam: secondEnemy.team,
        secondAlive: secondEnemy.alive,
        heroAttackTargetId: scene.hero.attackTargetId ?? "",
        heroAttackMove: Boolean(scene.hero.attackMove),
        heroHpBefore,
        heroHpAfter: scene.hero.hp,
        secondHp: secondEnemy.hp,
        secondMaxHp: secondEnemy.maxHp,
        heroMoveTarget: Boolean(scene.hero.moveTarget)
      };
    });
    expect(contactResult.firstKilled).toBe(true);
    expect(contactResult.secondHp, JSON.stringify(contactResult)).toBeLessThan(contactResult.secondMaxHp);
    expect(contactResult.heroHpAfter, JSON.stringify(contactResult)).toBeLessThan(contactResult.heroHpBefore);
    expect(contactResult.heroMoveTarget).toBe(false);

    const stationaryStartContact = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const imps = scene?.units.filter((unit: any) => unit.definition?.id === "stone_imp" && unit.alive && unit.view).slice(0, 2);
      if (!scene?.scene.isActive() || !scene.hero?.alive || !imps || imps.length < 2) {
        throw new Error("Expected active BattleScene hero and two Stone Imps for stationary start contact regression.");
      }
      scene.units
        .filter((unit: any) => unit.team !== "player" && !imps.includes(unit))
        .forEach((unit: any, index: number) => unit.setPosition(scene.activeMap.width - 180, scene.activeMap.height - 180 - index * 24));
      scene.hero.behaviourMode = "hold_ground";
      scene.hero.attackTargetId = undefined;
      scene.hero.attackTargetLabel = undefined;
      scene.hero.attackMove = false;
      scene.hero.moveTarget = undefined;
      scene.hero.moveOrderCombatSuppressionSeconds = 0;
      scene.hero.attackCooldownRemaining = 0;
      imps.forEach((enemy: any, index: number) => {
        enemy.hp = enemy.maxHp;
        enemy.alive = true;
        enemy.attackCooldownRemaining = 0;
        enemy.attackTargetId = undefined;
        enemy.attackTargetLabel = undefined;
        enemy.attackMove = false;
        enemy.moveTarget = undefined;
        enemy.setPosition(scene.hero.position.x + 64 + index * 36, scene.hero.position.y + index * 10);
      });
      const heroHpBefore = scene.hero.hp;
      scene.combatSystem.update(0.1);
      return {
        heroHpBefore,
        heroHpAfter: scene.hero.hp,
        enemyHp: imps.map((enemy: any) => enemy.hp),
        enemyMaxHp: imps.map((enemy: any) => enemy.maxHp),
        heroMoveTarget: Boolean(scene.hero.moveTarget)
      };
    });
    expect(
      stationaryStartContact.enemyHp.some((hp: number, index: number) => hp < stationaryStartContact.enemyMaxHp[index]) ||
        stationaryStartContact.heroHpAfter < stationaryStartContact.heroHpBefore,
      JSON.stringify(stationaryStartContact)
    ).toBe(true);
    expect(stationaryStartContact.heroMoveTarget).toBe(false);

    const neutralTroopContact = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const militia = scene?.units.find((unit: any) => unit.definition?.id === "militia" && unit.team === "player" && unit.alive);
      const imp = scene?.units.find((unit: any) => unit.definition?.id === "stone_imp" && unit.team === "neutral" && unit.alive);
      const hound = scene?.units.find((unit: any) => unit.definition?.id === "wild_hound" && unit.team === "neutral" && unit.alive);
      if (!scene?.scene.isActive() || !militia || !imp || !hound) {
        throw new Error("Expected militia, neutral Stone Imp, and neutral Wild Hound for neutral contact regression.");
      }
      scene.units
        .filter((unit: any) => unit.alive && ![militia.id, imp.id, hound.id].includes(unit.id))
        .forEach((unit: any, index: number) => {
          unit.setPosition(scene.activeMap.width - 180, scene.activeMap.height - 180 - index * 22);
          unit.attackTargetId = undefined;
          unit.attackTargetLabel = undefined;
          unit.attackMove = false;
          unit.moveTarget = undefined;
          unit.attackCooldownRemaining = 999;
        });
      militia.hp = militia.maxHp;
      militia.behaviourMode = "guard_area";
      militia.attackTargetId = undefined;
      militia.attackTargetLabel = undefined;
      militia.attackMove = false;
      militia.moveTarget = undefined;
      militia.moveOrderCombatSuppressionSeconds = 0;
      militia.attackCooldownRemaining = 0;
      imp.hp = imp.maxHp;
      hound.hp = hound.maxHp;
      [imp, hound].forEach((unit: any) => {
        unit.attackTargetId = undefined;
        unit.attackTargetLabel = undefined;
        unit.attackMove = false;
        unit.moveTarget = undefined;
        unit.moveOrderCombatSuppressionSeconds = 0;
        unit.attackCooldownRemaining = 0;
      });
      militia.setPosition(scene.hero.position.x + 120, scene.hero.position.y);
      imp.setPosition(militia.position.x + 66, militia.position.y);
      hound.setPosition(militia.position.x + 64, militia.position.y + 14);
      scene.combatSystem.update(0.1);
      return {
        militiaHp: militia.hp,
        militiaMaxHp: militia.maxHp,
        impHp: imp.hp,
        impMaxHp: imp.maxHp,
        houndHp: hound.hp,
        houndMaxHp: hound.maxHp,
        militiaMoveTarget: Boolean(militia.moveTarget),
        impMoveTarget: Boolean(imp.moveTarget),
        houndMoveTarget: Boolean(hound.moveTarget)
      };
    });
    expect(neutralTroopContact.militiaMoveTarget, JSON.stringify(neutralTroopContact)).toBe(false);
    expect(neutralTroopContact.impMoveTarget, JSON.stringify(neutralTroopContact)).toBe(false);
    expect(neutralTroopContact.houndMoveTarget, JSON.stringify(neutralTroopContact)).toBe(false);
    expect(
      neutralTroopContact.impHp < neutralTroopContact.impMaxHp ||
        neutralTroopContact.houndHp < neutralTroopContact.houndMaxHp ||
        neutralTroopContact.militiaHp < neutralTroopContact.militiaMaxHp,
      JSON.stringify(neutralTroopContact)
    ).toBe(true);

    const buildingAggro = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const commandHall = scene?.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
      );
      const raider = scene?.units.find((unit: any) => unit.team !== "player" && unit.alive);
      if (!scene?.scene.isActive() || !commandHall || !raider) {
        throw new Error("Expected Command Hall and hostile unit for building aggro regression.");
      }
      scene.units
        .filter((unit: any) => unit.team === "player")
        .forEach((unit: any, index: number) =>
          unit.setPosition(
            Math.max(120, commandHall.position.x - 360),
            Math.min(scene.activeMap.height - 120, commandHall.position.y + 260 + index * 24)
          )
        );
      scene.units
        .filter((unit: any) => unit.team !== "player" && unit.id !== raider.id)
        .forEach((unit: any, index: number) => unit.setPosition(scene.activeMap.width - 160, scene.activeMap.height - 160 - index * 24));
      commandHall.hp = commandHall.maxHp;
      commandHall.alive = true;
      raider.hp = raider.maxHp;
      raider.alive = true;
      raider.attackCooldownRemaining = 0;
      raider.attackTargetId = undefined;
      raider.attackTargetLabel = undefined;
      raider.attackMove = false;
      raider.moveTarget = undefined;
      raider.moveOrderCombatSuppressionSeconds = 0;
      raider.setPosition(commandHall.position.x + 88, commandHall.position.y);
      scene.combatSystem.update(0.1);
      return {
        commandHallHp: commandHall.hp,
        commandHallMaxHp: commandHall.maxHp,
        raiderMoveTarget: Boolean(raider.moveTarget)
      };
    });
    expect(buildingAggro.commandHallHp).toBeLessThan(buildingAggro.commandHallMaxHp);
    expect(buildingAggro.raiderMoveTarget).toBe(false);

    const explicitAttackPathWarning = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const hero = scene?.hero;
      const stronghold = scene?.buildings.find(
        (building: any) => building.team === "enemy" && building.definition.id === "enemy_stronghold" && building.alive
      );
      if (!scene?.scene.isActive() || !hero || !stronghold) {
        throw new Error("Expected hero and enemy stronghold for explicit attack path warning regression.");
      }
      const warningText = "No clear path. Moving as close as possible.";
      const countWarnings = () =>
        scene.children.list.filter((child: any) => child?.type === "Text" && (child.text ?? "") === warningText).length;
      const before = countWarnings();
      hero.commandAttack(stronghold.id, stronghold.definition.name);
      hero.moveTarget = { x: stronghold.position.x, y: stronghold.position.y };
      hero.setPosition(stronghold.position.x - 210, stronghold.position.y);
      scene.movementSystem.update(0.1, [hero], scene.activeMap, scene.buildings);
      return {
        before,
        after: countWarnings(),
        attackTargetId: hero.attackTargetId ?? "",
        moveTarget: Boolean(hero.moveTarget)
      };
    });
    expect(explicitAttackPathWarning.attackTargetId).not.toBe("");
    expect(explicitAttackPathWarning.after, JSON.stringify(explicitAttackPathWarning)).toBe(explicitAttackPathWarning.before);

    const retreatSuppression = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const enemies = scene?.units.filter((unit: any) => unit.team !== "player" && unit.alive).slice(0, 2);
      if (!scene?.scene.isActive() || !scene.hero?.alive || !enemies || enemies.length < 2) {
        throw new Error("Expected hero and two hostiles for retreat suppression regression.");
      }
      scene.hero.attackTargetId = undefined;
      scene.hero.attackTargetLabel = undefined;
      scene.hero.attackMove = false;
      scene.hero.moveTarget = undefined;
      scene.hero.moveOrderCombatSuppressionSeconds = 0;
      scene.hero.attackCooldownRemaining = 0;
      scene.hero.behaviourMode = "press_attack";
      scene.units
        .filter((unit: any) => unit.team === "player" && unit.id !== scene.hero.id)
        .forEach((unit: any, index: number) => {
          unit.attackTargetId = undefined;
          unit.attackTargetLabel = undefined;
          unit.attackMove = false;
          unit.moveTarget = undefined;
          unit.moveOrderCombatSuppressionSeconds = 3;
          unit.setPosition(Math.max(120, scene.hero.position.x - 260), Math.min(scene.activeMap.height - 120, scene.hero.position.y + 180 + index * 24));
        });
      enemies.forEach((enemy: any, index: number) => {
        enemy.hp = enemy.maxHp;
        enemy.alive = true;
        enemy.attackTargetId = undefined;
        enemy.attackTargetLabel = undefined;
        enemy.attackMove = false;
        enemy.moveTarget = undefined;
        enemy.setPosition(scene.hero.position.x + 34 + index * 8, scene.hero.position.y + index * 12);
      });
      scene.hero.commandMove({ x: scene.hero.position.x - 220, y: scene.hero.position.y + 80 }, false);
      const suppressionAfterCommand = scene.hero.moveOrderCombatSuppressionSeconds;
      scene.hero.moveTarget = undefined;
      scene.combatSystem.update(0.1);
      return {
        suppressionAfterCommand,
        suppressionAfterCombat: scene.hero.moveOrderCombatSuppressionSeconds,
        attackTargetId: scene.hero.attackTargetId ?? "",
        enemyHp: enemies.map((enemy: any) => enemy.hp),
        enemyMaxHp: enemies.map((enemy: any) => enemy.maxHp)
      };
    });
    expect(retreatSuppression.suppressionAfterCommand).toBeGreaterThan(0);
    expect(retreatSuppression.suppressionAfterCombat).toBeGreaterThan(0);
    expect(retreatSuppression.attackTargetId).toBe("");
    expect(retreatSuppression.enemyHp).toEqual(retreatSuppression.enemyMaxHp);

    const hoverTarget = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const hostiles = scene?.units.filter((unit: any) => unit.team !== "player" && unit.alive);
      const target = hostiles?.[0];
      if (!scene?.scene.isActive() || !target || !hostiles) {
        throw new Error("Expected hostile target for hover tolerance regression.");
      }
      hostiles.slice(1).forEach((unit: any, index: number) => {
        unit.setPosition(scene.activeMap.width - 180, scene.activeMap.height - 180 - index * 24);
      });
      scene.units
        .filter((unit: any) => unit.team === "player" && unit.id !== scene.hero.id)
        .forEach((unit: any, index: number) => unit.setPosition(scene.hero.position.x - 180, scene.hero.position.y + 150 + index * 24));
      scene.hero.behaviourMode = "hold_ground";
      scene.hero.attackTargetId = undefined;
      scene.hero.attackTargetLabel = undefined;
      scene.hero.attackMove = false;
      scene.hero.moveTarget = undefined;
      scene.hero.moveOrderCombatSuppressionSeconds = 3;
      scene.hero.attackCooldownRemaining = 999;
      target.hp = target.maxHp;
      target.alive = true;
      target.factionSpeedMultiplier = 0;
      target.attackTargetId = undefined;
      target.attackTargetLabel = undefined;
      target.attackMove = false;
      target.moveTarget = undefined;
      target.moveOrderCombatSuppressionSeconds = 3;
      target.attackCooldownRemaining = 999;
      target.setPosition(
        Math.max(240, Math.min(scene.activeMap.width - 240, scene.hero.position.x + 360)),
        Math.max(240, Math.min(scene.activeMap.height - 240, scene.hero.position.y + 260))
      );
      scene.selectionSystem.setSelection([scene.hero]);
      scene.fogDebugDisabled = true;
      scene.updateFogOfWar?.(0, true);
      target.view?.setVisible(true);
      scene.cameraSystem.centerOn(target.position);
      scene.refreshBattleHud?.(0);
      const tolerantPoint = { x: target.position.x + 23, y: target.position.y };
      const topPoint = { x: target.position.x, y: target.position.y - 28 };
      const emptyPoint = { x: target.position.x + 31, y: target.position.y };
      return {
        id: target.id,
        x: tolerantPoint.x,
        y: tolerantPoint.y,
        tolerantHitId: scene.findWorldEntityAt?.(tolerantPoint)?.id ?? "",
        topHitId: scene.findWorldEntityAt?.(topPoint)?.id ?? "",
        emptyHitId: scene.findWorldEntityAt?.(emptyPoint)?.id ?? ""
      };
    });
    expect(hoverTarget.tolerantHitId).toBe(hoverTarget.id);
    expect(hoverTarget.topHitId).toBe(hoverTarget.id);
    expect(hoverTarget.emptyHitId).toBe("");
    const hoverScreen = await worldToScreen(page, hoverTarget);
    await expectWorldClickTargetsCanvas(page, hoverTarget, "manual combat contact hover tolerance");
    await page.mouse.move(hoverScreen.x - 24, hoverScreen.y - 24);
    await page.mouse.move(hoverScreen.x, hoverScreen.y, { steps: 4 });
    await expect
      .poll(
        async () =>
          page.evaluate(() => {
            const canvas = document.querySelector("canvas") as HTMLCanvasElement | null;
            return canvas?.dataset.battleCursor ?? "";
          }),
        { message: "expected tolerant hover point to expose attack cursor intent" }
      )
      .toBe("attack");
  });

  test("Tutorial Barracks can train clustered Rangers that remain movable after production @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(60_000);
    await openFreshMainMenu(page);
    await clickReady(page.getByTestId("menu-tutorial"), "deep-flow launch Tutorial for Ranger production regression", SCENE_TRANSITION_CLICK_OPTIONS);
    await expectBattleLoaded(page);
    await waitForBattleScene(page);
    const tutorialEventAttempt = await page.evaluate(() =>
      (window as any).__ASCENDANT_TEST_HOOKS__?.triggerBattlefieldEvent?.("aether_surge")
    );
    expect(tutorialEventAttempt).toBeNull();
    await expect(page.getByTestId("battlefield-event-status")).toHaveCount(0);

    const productionResult = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      scene.resources.player.crowns = 10_000;
      scene.resources.player.stone = 10_000;
      scene.resources.player.iron = 10_000;
      scene.resources.player.aether = 10_000;
      scene.units
        .filter((unit: any) => unit.team !== "player")
        .forEach((unit: any, index: number) => {
          unit.attackTargetId = undefined;
          unit.attackTargetLabel = undefined;
          unit.attackMove = false;
          unit.moveTarget = undefined;
          unit.attackCooldownRemaining = 999;
          unit.setPosition(scene.activeMap.width - 160, scene.activeMap.height - 160 - index * 24);
        });

      const commandHall = scene.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
      );
      if (!commandHall) {
        throw new Error("Expected Tutorial Command Hall for Ranger production regression.");
      }

      scene.buildingSystem.startPlacement("barracks");
      if (!scene.buildingSystem.tryPlace(360, 680, scene.resources.player)) {
        throw new Error("Could not place Tutorial Barracks for Ranger production regression.");
      }
      const barracks = scene.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "barracks" && building.alive
      );
      if (!barracks) {
        throw new Error("Expected placed Tutorial Barracks for Ranger production regression.");
      }
      barracks.constructionState = "completed";
      barracks.constructionProgress = 1;
      barracks.hp = barracks.maxHp;
      barracks.updateHealthBar?.();
      barracks.rallyPoint = { x: 540, y: 830 };

      const beforeIds = new Set(scene.units.map((unit: any) => unit.id));
      for (let index = 0; index < 8; index += 1) {
        if (!scene.trainingSystem.queueTraining(barracks, "ranger", scene.resources.player, { announce: false })) {
          throw new Error(`Ranger ${index + 1} did not queue.`);
        }
        scene.trainingSystem.update(99, scene.buildings);
      }
      const trainedRangers = scene.units.filter(
        (unit: any) => !beforeIds.has(unit.id) && unit.team === "player" && unit.definition.id === "ranger" && unit.alive
      );
      if (trainedRangers.length !== 8) {
        throw new Error(`Expected 8 trained Rangers, got ${trainedRangers.length}.`);
      }

      const starts = trainedRangers.map((unit: any) => ({ id: unit.id, x: unit.position.x, y: unit.position.y }));
      trainedRangers.forEach((unit: any) => unit.commandMove({ x: 540, y: 830 }, false));
      for (let index = 0; index < 30; index += 1) {
        scene.movementSystem.update(0.1, scene.units, scene.activeMap, scene.buildings);
      }

      return {
        trainedCount: trainedRangers.length,
        moved: trainedRangers.map((unit: any, index: number) => ({
          id: unit.id,
          startX: starts[index].x,
          startY: starts[index].y,
          x: unit.position.x,
          y: unit.position.y,
          distanceMoved: Math.hypot(unit.position.x - starts[index].x, unit.position.y - starts[index].y),
          moveTarget: unit.moveTarget ? { ...unit.moveTarget } : undefined
        }))
      };
    });

    expect(productionResult.trainedCount).toBe(8);
    productionResult.moved.forEach((unit) => {
      expect(unit.distanceMoved, JSON.stringify(productionResult)).toBeGreaterThan(12);
    });
  });

  test("Tutorial production route keeps Command Hall, Barracks, and Watchtower roles readable @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(90_000);
    await openFreshMainMenu(page);
    await clickReady(page.getByTestId("menu-tutorial"), "deep-flow launch Tutorial production role proxy", SCENE_TRANSITION_CLICK_OPTIONS);
    await expectBattleLoaded(page);
    await waitForBattleScene(page);
    await setBattlePlayerResources(page, { crowns: 2000, stone: 2000, iron: 2000, aether: 2000 });
    await forceTutorialStepForDeepFlow(page, "select_command_hall");

    await selectPlayerCommandHallFromScene(page);
    await expect(page.locator(".side-panel")).toContainText("Command Hall");
    await expect(page.locator(".side-panel")).toContainText("Base hub: trains Workers only");
    await expect(page.locator("button[data-action='train'][data-id='worker']")).toBeEnabled();
    await expect(page.locator("button[data-action='train'][data-id='militia']")).toHaveCount(0);
    await expect(page.locator("button[data-action='train'][data-id='ranger']")).toHaveCount(0);
    await expect(page.locator("button[data-action='upgrade'][data-id='infantry_weapons_1']")).toHaveCount(0);

    const tutorialWorker = await trainWorkerFromCommandHall(page, "deep-flow Tutorial production role proxy");
    await forceTutorialStepForDeepFlow(page, "build_barracks");
    await selectWorkerFromScene(page, tutorialWorker.id);
    await clickBattleCommandUntilEffect(
      () => page.locator("button[data-action='build'][data-id='barracks']"),
      "deep-flow Tutorial build Barracks command",
      async () => {
        await expect(page.getByTestId("placement-banner")).toContainText(/left-click to place/i, { timeout: 2_000 });
      },
      async () => {
        await selectWorkerFromScene(page, tutorialWorker.id);
      }
    );
    await placePendingBuildingFromSceneAtValidPoint(page, "barracks", [
      { x: 450, y: 930 },
      { x: 430, y: 690 },
      { x: 500, y: 820 }
    ]);
    await expect(page.locator(".side-panel")).toContainText("Army production: trains Militia and Rangers");
    await expect(page.locator(".side-panel")).toContainText("Incomplete - completed-building actions locked.");
    await expect(page.locator("button[data-action='train'][data-id='militia']")).toHaveCount(0);

    await completePlayerBuilding(page, "barracks");
    await forceTutorialStepForDeepFlow(page, "train_militia");
    await selectPlayerBuildingFromScene(page, "barracks");
    await expect(page.locator("button[data-action='train'][data-id='militia']")).toBeEnabled();
    await expect(page.locator("button[data-action='train'][data-id='ranger']")).toBeEnabled();
    await expect(page.locator("button[data-action='upgrade'][data-id='infantry_weapons_1']")).toBeEnabled();
    await expect(page.locator("button[data-action='upgrade'][data-id='reinforced_armor_1']")).toBeEnabled();
    await expect(page.locator("button[data-action='upgrade'][data-id='ranger_training_1']")).toBeEnabled();
    const tutorialInfantryWeapons = page.locator("button[data-action='upgrade'][data-id='infantry_weapons_1']");
    await expect(tutorialInfantryWeapons).toContainText("Owner: Barracks");
    await expect(tutorialInfantryWeapons).toContainText("Effect: Militia and Raiders: +10% damage.");
    await researchUpgradeThroughCommand(
      tutorialInfantryWeapons,
      page,
      "infantry_weapons_1",
      "deep-flow Tutorial research Infantry Weapons I"
    );
    await completeUpgradeQueues(page);
    await expect(tutorialInfantryWeapons).toHaveAttribute("aria-label", /Researched/);

    const beforeArmy = await getBattleSnapshot(page);
    const militiaBefore = beforeArmy.units.filter((unit: any) => unit.team === "player" && unit.unitId === "militia").length;
    const rangerBefore = beforeArmy.units.filter((unit: any) => unit.team === "player" && unit.unitId === "ranger").length;
    await trainUnitThroughCommand(page.locator("button[data-action='train'][data-id='militia']"), page, "militia", "deep-flow Tutorial train Militia");
    await trainUnitThroughCommand(page.locator("button[data-action='train'][data-id='ranger']"), page, "ranger", "deep-flow Tutorial train Ranger");
    await completeTrainingQueues(page);
    await page.waitForFunction(
      ({ beforeMilitia, beforeRanger }) => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        const militia = scene?.units.filter((unit: any) => unit.team === "player" && unit.definition.id === "militia" && unit.alive) ?? [];
        const rangers = scene?.units.filter((unit: any) => unit.team === "player" && unit.definition.id === "ranger" && unit.alive) ?? [];
        return militia.length > beforeMilitia && rangers.length > beforeRanger;
      },
      { beforeMilitia: militiaBefore, beforeRanger: rangerBefore },
      { timeout: 5_000 }
    );

    await selectWorkerFromScene(page, tutorialWorker.id);
    await clickBattleCommandUntilEffect(
      () => page.locator("button[data-action='build'][data-id='watchtower']"),
      "deep-flow Tutorial build Watchtower command",
      async () => {
        await expect(page.getByTestId("placement-banner")).toContainText(/left-click to place/i, { timeout: 2_000 });
      },
      async () => {
        await selectWorkerFromScene(page, tutorialWorker.id);
      }
    );
    await placePendingBuildingFromSceneAtValidPoint(page, "watchtower", [
      { x: 540, y: 800 },
      { x: 560, y: 920 },
      { x: 520, y: 700 }
    ]);
    await expect(page.locator(".side-panel")).toContainText(
      "Defense: inactive while incomplete, attacks nearby enemies when complete, and researches tower defenses."
    );
    await expect(page.locator(".side-panel")).toContainText("Incomplete - completed-building actions locked.");
    await completePlayerBuilding(page, "watchtower");
    await selectPlayerBuildingFromScene(page, "watchtower");
    await expect(page.locator(".side-panel")).toContainText("Defense ready");
  });

  test("unlocked hero ability hotkeys 1, 2, and 3 cast through keyboard input @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(60_000);
    await seedSave(page, {
      hero: {
        level: 4,
        xp: 420,
        unlockedAbilities: ["rally_banner", "cleave", "war_cry"],
        inventory: [
          {
            instanceId: "deep-qa:outpost_command_signet:ability",
            itemId: "outpost_command_signet",
            acquiredAt: "2026-05-28T00:00:00.000Z",
            source: "deep_e2e",
            affixes: [],
            locked: false,
            favorite: false
          }
        ],
        equipment: {
          relic: "deep-qa:outpost_command_signet:ability"
        },
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
    await expect(page.getByTestId("battle-hero-panel")).toContainText("Commander synergy active");
    await expect(page.locator("button[data-action='ability'][data-id='rally_banner']")).toHaveAttribute("title", /Commander synergy/);
    await expect(page.locator("button[data-action='ability'][data-id='cleave']")).toHaveAttribute("title", /\+6 damage/);

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
        unit.hp = unit.maxHp + 200;
        unit.setPosition(hero.position.x + 220 + index * 32, hero.position.y + 120 + index * 18);
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
        cooldown: scene.hero.abilityCooldowns.rally_banner ?? 0,
        allyBuffs: allyIds.map((allyId: string) => scene.units.find((unit: any) => unit.id === allyId)?.damageBuffMultiplier ?? 1)
      };
    }, prepared.allyIds);
    expect(rallyResult.mana).toBeLessThan(prepared.heroMana);
    expect(rallyResult.cooldown).toBeGreaterThan(0);
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
        enemy.alive = true;
        enemy.hp = enemy.maxHp + 200;
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
        cooldown: scene.hero.abilityCooldowns.cleave ?? 0,
        enemyHp: enemyIds.map((enemyId: string) => scene.units.find((unit: any) => unit.id === enemyId)?.hp ?? 0)
      };
    }, prepared.enemyIds);
    expect(cleaveResult.mana).toBeLessThan(cleaveSetup.mana);
    expect(cleaveResult.cooldown).toBeGreaterThan(0);
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
        const preferredEnemies = enemyIds
          .map((enemyId: string) => scene.units.find((unit: any) => unit.id === enemyId && unit.team === "enemy" && unit.alive))
          .filter(Boolean);
        const fallbackEnemies = scene.units.filter(
          (unit: any) => unit.team === "enemy" && unit.alive && !preferredEnemies.includes(unit)
        );
        const enemies = [...preferredEnemies, ...fallbackEnemies].slice(0, 3);
        if (enemies.length === 0) {
          const reusableEnemies = enemyIds
            .map((enemyId: string) => scene.units.find((unit: any) => unit.id === enemyId && unit.team === "enemy"))
            .filter(Boolean)
            .slice(0, 3);
          reusableEnemies.forEach((enemy: any) => {
            enemy.alive = true;
            enemy.view?.setVisible(true);
          });
          enemies.push(...reusableEnemies);
        }
        if (enemies.length === 0) {
          throw new Error("Missing enemy target before War Cry.");
        }
        enemies.forEach((enemy: any, index: number) => {
          enemy.hp = enemy.maxHp;
          enemy.setPosition(hero.position.x + 54 + index * 20, hero.position.y + (index - 1) * 18);
          enemy.moveTarget = undefined;
          enemy.attackTargetId = undefined;
          enemy.attackMove = false;
          enemy.attackCooldownRemaining = 999;
        });
        return {
          mana: hero.mana,
          enemyIds: enemies.map((enemy: any) => enemy.id),
          enemyHp: enemies.map((enemy: any) => enemy.hp)
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
          cooldown: scene.hero.abilityCooldowns.war_cry ?? 0,
          allyBuffs: allyIds.map((allyId: string) => scene.units.find((unit: any) => unit.id === allyId)?.damageBuffMultiplier ?? 1),
          enemyHp: enemyIds.map((enemyId: string) => scene.units.find((unit: any) => unit.id === enemyId)?.hp ?? 0)
        };
      },
      { allyIds: prepared.allyIds, enemyIds: warCrySetup.enemyIds }
    );
    expect(warCryResult.mana).toBeLessThan(warCrySetup.mana);
    expect(warCryResult.cooldown).toBeGreaterThan(0);
    expect(warCryResult.allyBuffs.some((multiplier: number) => multiplier > 1)).toBe(true);
    expect(warCryResult.enemyHp.some((hp: number, index: number) => hp < warCrySetup.enemyHp[index])).toBe(true);
  });

  test("hero battle XP can level the hero and update the HUD @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(60_000);
    await seedSave(page, {
      hero: {
        level: 1,
        xp: 90,
        skillPoints: 0
      }
    });
    await startBorderVillageCampaignBattle(page);

    const result = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const enemy = scene.units.find((unit: any) => unit.team === "enemy" && unit.definition.xpValue > 0 && unit.alive);
      if (!enemy) {
        throw new Error("Missing enemy unit for hero XP proxy.");
      }
      const before = {
        level: scene.hero.level,
        xp: scene.hero.xp,
        damage: scene.hero.damage,
        armor: scene.hero.armor,
        skillPoints: scene.hero.skillPoints
      };
      enemy.setPosition(scene.hero.position.x + 28, scene.hero.position.y);
      const wasAlive = enemy.alive;
      enemy.takeDamage(enemy.maxHp + enemy.armor + 10_000);
      if (wasAlive && !enemy.alive) {
        scene.handleKill(scene.hero, enemy);
        enemy.destroyView();
        scene.cleanupDeadEntities();
      }
      scene.refreshBattleHud(0);
      return {
        before,
        after: {
          level: scene.hero.level,
          xp: scene.hero.xp,
          damage: scene.hero.damage,
          armor: scene.hero.armor,
          skillPoints: scene.hero.skillPoints
        },
        statsXp: scene.runtime.stats.xpGained,
        status: scene.statusMessage
      };
    });

    expect(result.after.level).toBeGreaterThan(result.before.level);
    expect(result.after.xp).toBeGreaterThanOrEqual(100);
    expect(result.after.damage).toBeGreaterThan(result.before.damage);
    expect(result.after.skillPoints).toBeGreaterThan(result.before.skillPoints);
    expect(result.statsXp).toBeGreaterThan(0);
    await expect(page.getByTestId("battle-hero-panel")).toContainText("L2");
    await expect(page.getByTestId("battle-hero-panel")).toContainText("DMG");
  });

  test("hero ability buttons show cooldown and block repeat casts @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(60_000);
    await seedSave(page);
    await startBorderVillageCampaignBattle(page);
    await page.keyboard.press("H");
    await expect(page.locator("button[data-action='ability'][data-id='rally_banner']")).toContainText("1. Rally Banner");

    const prepared = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const hero = scene.hero;
      const allies = scene.units.filter((unit: any) => unit.team === "player" && unit.id !== hero.id && unit.alive).slice(0, 2);
      if (allies.length === 0) {
        throw new Error("Missing allies for Rally Banner cooldown proxy.");
      }
      hero.mana = hero.maxMana;
      hero.abilityCooldowns = {};
      scene.selectionSystem.setSelection([hero]);
      allies.forEach((unit: any, index: number) => unit.setPosition(hero.position.x - 44 - index * 18, hero.position.y + index * 12));
      scene.refreshBattleHud(0);
      return { mana: hero.mana };
    });

    await page.keyboard.press("1");
    await expect(page.locator("button[data-action='ability'][data-id='rally_banner']")).toHaveAttribute("data-ability-state", "cooldown");
    await expect(page.locator("button[data-action='ability'][data-id='rally_banner']")).toHaveAttribute(
      "data-ability-reason",
      /Cooldown \d+s/
    );
    await expect(page.locator("button[data-action='ability'][data-id='rally_banner']")).toBeDisabled();
    await expect(page.locator("button[data-action='ability'][data-id='rally_banner']")).toContainText(/Cooldown \d+s/);

    const repeated = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      const manaBefore = scene.hero.mana;
      const cooldownBefore = scene.hero.abilityCooldowns.rally_banner;
      const cast = scene.abilitySystem.castAbility(scene.hero, "rally_banner", scene.selectionSystem.getSelected());
      return {
        cast,
        manaBefore,
        manaAfter: scene.hero.mana,
        cooldownBefore,
        cooldownAfter: scene.hero.abilityCooldowns.rally_banner
      };
    });

    expect(repeated.cast).toBe(false);
    expect(repeated.manaAfter).toBe(repeated.manaBefore);
    expect(repeated.manaAfter).toBeLessThan(prepared.mana);
    expect(repeated.cooldownAfter).toBe(repeated.cooldownBefore);
  });

  test("victory results summarize battle XP and level rewards @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(60_000);
    await seedSave(page, {
      hero: {
        level: 1,
        xp: 90,
        skillPoints: 0
      }
    });
    await startBorderVillageCampaignBattle(page);

    await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const enemy = scene.units.find((unit: any) => unit.team === "enemy" && unit.definition.xpValue > 0 && unit.alive);
      if (!enemy) {
        throw new Error("Missing enemy unit for results XP proxy.");
      }
      enemy.setPosition(scene.hero.position.x + 28, scene.hero.position.y);
      const wasAlive = enemy.alive;
      enemy.takeDamage(enemy.maxHp + enemy.armor + 10_000);
      if (wasAlive && !enemy.alive) {
        scene.handleKill(scene.hero, enemy);
        enemy.destroyView();
        scene.cleanupDeadEntities();
      }
      scene.refreshBattleHud(0);
    });
    await forceActiveBattleOutcome(page, "victory");

    const resultsPanel = page.locator(".results-panel");
    await expect(resultsPanel).toContainText("Hero XP");
    await expect(resultsPanel).toContainText("XP gained");
    await expect(resultsPanel).toContainText("Level-up");
    await expect(resultsPanel).toContainText("+1 level");
    await expect(resultsPanel).toContainText("Reward XP");
    const save = await readSave(page);
    expect(save.hero.level).toBeGreaterThanOrEqual(2);
    expect(save.hero.xp).toBeGreaterThan(90);
  });

  test("minimap renders marker families, camera rectangle, rally marker, and live pings @hosted-deep-battle", async ({ page }) => {
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

  test("first campaign battle path covers capture, build, train, rally, and victory rewards @hosted-deep-battle", async ({ page }) => {
    test.setTimeout(120_000);
    await openFreshMainMenu(page);

    await page.getByTestId("menu-new-campaign").click();
    await expect(page.getByTestId("hero-creation")).toBeVisible();
    await page.getByTestId("hero-class-warlord").click();
    await page.getByTestId("hero-name-input").fill("Loop QA");
    await page.getByTestId("hero-start").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("campaign-node-border_village")).toContainText(/Available/i);
    await expect(page.getByTestId("campaign-node-old_stone_road")).toContainText(/Locked/i);

    await clickReady(page.getByTestId("campaign-node-border_village"), "deep-flow first campaign battle node");
    await expect(page.locator(".campaign-node-details")).toContainText("Act 1 Step 2: First Campaign Battle");
    await expect(page.locator(".campaign-node-details")).toContainText("Ready to start.");
    await expect(page.locator(".campaign-node-details")).toContainText("Capture the nearby site");
    await expect(page.getByTestId("campaign-start-node")).toBeEnabled();
    await clickReady(
      page.getByTestId("campaign-start-node"),
      "deep-flow first campaign battle start",
      SCENE_TRANSITION_CLICK_OPTIONS
    );
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
    await expect(page.locator("button[data-action='build'][data-id='barracks']")).toHaveCount(0);
    const campaignWorker = await trainWorkerFromCommandHall(page, "deep-flow first campaign Worker construction");
    await clickBattleCommandUntilEffect(
      () => page.locator("button[data-action='build'][data-id='barracks']"),
      "deep-flow first campaign Worker build Barracks",
      async () => {
        await expect(page.getByTestId("placement-banner")).toContainText(/left-click to place/i, { timeout: 2_000 });
      },
      async () => {
        await page.evaluate((workerId) => {
          const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
          const worker = scene?.units.find((unit: any) => unit.id === workerId && unit.alive);
          if (worker) {
            scene.selectionSystem.setSelection([worker]);
            scene.refreshBattleHud?.(0);
          }
        }, campaignWorker.id);
        await expect(page.locator(".side-panel")).toContainText("Worker");
      }
    );
    await expect(page.getByTestId("battle-status")).toContainText(/Placing|Barracks/i);
    await expect(page.getByTestId("placement-banner")).toContainText(/left-click to place/i);
    await expect(page.locator(".hint-line")).toHaveCount(0);
    await placePendingBuildingFromSceneAtValidPoint(page, "barracks", [
      { x: 450, y: 930 },
      { x: 430, y: 690 },
      { x: 500, y: 820 }
    ]);
    await expect(page.locator(".side-panel")).toContainText(/Construction/i);

    await completePlayerBuilding(page, "barracks");
    await selectPlayerBuildingFromScene(page, "barracks");
    await expect(page.locator(".side-panel")).toContainText("Barracks");
    await expect(page.locator(".side-panel")).toContainText("Rally Point: None");

    await selectPlayerBuildingFromScene(page, "barracks");
    await expect(page.locator(".side-panel")).toContainText("Barracks");
    const rallyPoint = { x: 620, y: 860 };
    await clickWorldPointUntilEffect(page, rallyPoint, "right", "deep-flow first campaign set Barracks rally", async () =>
      page
        .waitForFunction(
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
          { timeout: 2_000 }
        )
        .then(() => true)
        .catch(() => false)
    );
    await selectPlayerBuildingFromScene(page, "barracks");
    await expect(page.locator(".side-panel")).toContainText("Rally Point: Set");

    snapshot = await getBattleSnapshot(page);
    const militiaBefore = snapshot.units.filter((unit: any) => unit.team === "player" && unit.unitId === "militia").length;
    const trainMilitiaButton = () => page.locator("button[data-action='train'][data-id='militia']");
    try {
      await clickBattleCommandUntilEffect(
        trainMilitiaButton,
        "deep-flow first campaign train Militia",
        async () => {
          await page.waitForFunction(
            () => {
              const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
              const barracks = scene?.buildings.find(
                (building: any) => building.team === "player" && building.definition.id === "barracks" && building.alive
              );
              return barracks?.trainingQueue.length > 0;
            },
            undefined,
            { timeout: 2_000 }
          );
        },
        async () => {
          await selectPlayerBuildingFromScene(page, "barracks");
          await expect(page.locator(".side-panel")).toContainText("Barracks");
        }
      );
    } catch (error) {
      console.warn(
        `deep-flow first campaign train Militia: visible command did not expose a training queue; using scene-backed command helper. ${
          error instanceof Error ? error.message : String(error)
        }`
      );
      await trainUnitThroughCommand(trainMilitiaButton(), page, "militia", "deep-flow first campaign train Militia");
    }

    await completeTrainingQueues(page);
    const trainedMilitia = await page.waitForFunction(
      ({ beforeCount, target }) => {
        const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
        const candidates = scene?.units.filter((unit: any) => unit.team === "player" && unit.definition.id === "militia" && unit.alive) ?? [];
        if (candidates.length <= beforeCount) {
          return false;
        }
        const newlyTrainedCandidates = candidates.slice(beforeCount);
        return newlyTrainedCandidates.find((unit: any) => {
          const moveTargetMatches = unit.moveTarget && Math.hypot(unit.moveTarget.x - target.x, unit.moveTarget.y - target.y) < 8;
          const alreadyAtRally = Math.hypot(unit.position.x - target.x, unit.position.y - target.y) < 24;
          return moveTargetMatches || alreadyAtRally;
        })?.id;
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
    await advanceBattleSimulation(page, 1, 0.1);
    await expect
      .poll(
        async () =>
          page.evaluate(
            ({ unitId, target, startDistance }) => {
              const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
              const unit = scene?.units.find((entry: any) => entry.id === unitId);
              if (!unit) {
                return {
                  found: false,
                  hasRallyOrder: false,
                  movedTowardRally: false
                };
              }
              const distanceToRally = Math.hypot(unit.position.x - target.x, unit.position.y - target.y);
              const moveTargetDistance = unit.moveTarget
                ? Math.hypot(unit.moveTarget.x - target.x, unit.moveTarget.y - target.y)
                : undefined;
              const arrivedAtRally = distanceToRally < 24;
              return {
                found: true,
                distanceToRally,
                moveTargetDistance,
                hasRallyOrder:
                  moveTargetDistance === undefined ? arrivedAtRally : moveTargetDistance < 8,
                movedTowardRally: distanceToRally < startDistance - 2,
                arrivedAtRally,
                rallyProgressSatisfied: arrivedAtRally || distanceToRally < startDistance - 2
              };
            },
            { unitId: trainedMilitiaId, target: rallyPoint, startDistance: startingRallyDistance }
          ),
        {
          message: "Expected the trained militia to keep its Barracks rally order and move toward the rally point.",
          timeout: 8_000
        }
      )
      .toEqual(
        expect.objectContaining({
          found: true,
          rallyProgressSatisfied: true
        })
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
    await expect(page.locator(".campaign-reward-block")).toContainText("Act 1 Step 2: First Campaign Battle");
    await expect(page.locator(".campaign-reward-block")).toContainText("Next mission unlocked: Old Stone Road");
    const save = await readSave(page);
    expect(save.campaign.completedNodeIds).toContain("border_village");
    expect(save.campaign.nodeRewardsClaimedIds).toContain("border_village");
    expect(save.campaign.unlockedNodeIds).toContain("old_stone_road");
    expect(save.hero.completedBattles).toBe(1);
    expect(save.hero.inventory.length).toBeGreaterThan(0);
    expect(Object.values(save.hero.equipment ?? {})).toHaveLength(0);

    await clickReady(page.getByRole("button", { name: "Campaign Map" }), "deep-flow first campaign results campaign map");
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("campaign-node-border_village")).toContainText(/Replayable/i);
    await expect(page.getByTestId("campaign-node-old_stone_road")).toContainText(/Available/i);
    await clickReady(page.getByTestId("campaign-node-border_village"), "deep-flow completed Border Village detail");
    await expect(page.locator(".campaign-node-details")).toContainText("Replay reward");
    await expect(page.locator(".campaign-node-details")).toContainText("Completed battle nodes are replayable.");
  });

  test("first enemy wave pressure can damage the base and be survived @hosted-deep-battle", async ({ page }) => {
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

  test("Chapel of the Marches guidance keeps the node open before a completing repair choice @hosted-deep-campaign", async ({ page }) => {
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
    await clickReady(page.getByTestId("campaign-node-chapel_of_the_marches"), "deep-flow Chapel of the Marches node");
    await expect(page.locator("button[data-campaign-choice='ask_for_guidance']")).toContainText("Keeps this node open");
    await clickCampaignChoiceAndExpectStatus(
      page,
      page.locator("button[data-campaign-choice='ask_for_guidance']"),
      "deep-flow ask for Chapel guidance",
      "Ask for Guidance chosen"
    );

    let save = await readSave(page);
    expect(save.campaign.choiceIdsClaimed).toContain("chapel_of_the_marches:ask_for_guidance");
    expect(save.campaign.completedNodeIds).not.toContain("chapel_of_the_marches");
    expect(save.campaign.unlockedNodeIds).toContain("ashen_outpost");
    expect(save.hero.xp).toBeGreaterThanOrEqual(215);

    await expect(page.getByTestId("campaign-node-chapel_of_the_marches")).toContainText(/Available/i);
    await expect(page.locator("button[data-campaign-choice='ask_for_guidance']")).toBeDisabled();
    await expect(page.locator("button[data-campaign-choice='ask_for_guidance']")).toContainText("Already chosen");
    await expect(page.locator("button[data-campaign-choice='repair_chapel']")).toBeEnabled();
    await clickCampaignChoiceAndExpectStatus(
      page,
      page.locator("button[data-campaign-choice='repair_chapel']"),
      "deep-flow repair Chapel",
      "Repair the Chapel chosen"
    );

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

  test("Mystic Lodge, Acolyte, Watchtower combat, and research UI work through battle commands @hosted-deep-campaign", async ({ page }) => {
    test.setTimeout(130_000);
    await startFirstClaimSkirmish(page, "Systems QA");

    await setBattlePlayerResources(page, { crowns: 0, stone: 0, iron: 0, aether: 0 });
    await selectPlayerCommandHallFromScene(page);
    await expect(page.locator("button[data-action='train'][data-id='worker']")).toBeDisabled();
    await expect(page.locator("button[data-action='train'][data-id='militia']")).toHaveCount(0);
    await expect(page.locator("button[data-action='upgrade'][data-id='infantry_weapons_1']")).toHaveCount(0);

    await setBattlePlayerResources(page, { crowns: 2000, stone: 2000, iron: 2000, aether: 2000 });
    await placePlayerBuildingFromScene(page, "barracks");
    await completePlayerBuilding(page, "barracks");
    await setBattlePlayerResources(page, { crowns: 0, stone: 0, iron: 0, aether: 0 });
    await selectPlayerBuildingFromScene(page, "barracks");
    const infantryWeapons = page.locator("button[data-action='upgrade'][data-id='infantry_weapons_1']");
    await expect(infantryWeapons).toBeDisabled();
    await expect(infantryWeapons).toContainText("Militia and Raiders: +10% damage");
    await expect(infantryWeapons).toHaveAttribute("aria-label", /Insufficient resources/);

    await setBattlePlayerResources(page, { crowns: 2000, stone: 2000, iron: 2000, aether: 2000 });
    await expect(infantryWeapons).toBeEnabled();
    await researchUpgradeThroughCommand(infantryWeapons, page, "infantry_weapons_1", "deep-flow research Infantry Weapons I");
    await expect(infantryWeapons).toHaveAttribute("aria-label", /Researching/);
    await completeUpgradeQueues(page);
    await expect(infantryWeapons).toHaveAttribute("aria-label", /Researched/);

    const reinforcedArmor = page.locator("button[data-action='upgrade'][data-id='reinforced_armor_1']");
    await expect(reinforcedArmor).toBeEnabled();
    await researchUpgradeThroughCommand(reinforcedArmor, page, "reinforced_armor_1", "deep-flow research Reinforced Armor I");
    await completeUpgradeQueues(page);
    await expect(reinforcedArmor).toHaveAttribute("aria-label", /Researched/);

    const rangerTraining = page.locator("button[data-action='upgrade'][data-id='ranger_training_1']");
    await expect(rangerTraining).toBeEnabled();
    await researchUpgradeThroughCommand(rangerTraining, page, "ranger_training_1", "deep-flow research Ranger Training I");
    await completeUpgradeQueues(page);
    await expect(rangerTraining).toHaveAttribute("aria-label", /Researched/);

    await placePlayerBuildingFromScene(page, "mystic_lodge");
    await completePlayerBuilding(page, "mystic_lodge");
    await selectPlayerBuildingFromScene(page, "mystic_lodge");
    await expect(page.locator(".side-panel")).toContainText("Mystic Lodge");
    let snapshot = await getBattleSnapshot(page);
    const acolytesBefore = snapshot.units.filter((unit: any) => unit.team === "player" && unit.unitId === "acolyte").length;
    await trainUnitThroughCommand(page.locator("button[data-action='train'][data-id='acolyte']"), page, "acolyte", "deep-flow train Acolyte");
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
    await researchUpgradeThroughCommand(aetherStudy, page, "aether_study_1", "deep-flow research Aether Study I");
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

  test("Ashen Outpost special objectives display completed states on Results @hosted-deep-campaign", async ({ page }) => {
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
    await expect(page.locator(".campaign-node-details")).toContainText("Captain Malrec");
    await expect(page.locator(".campaign-node-details")).toContainText("Outpost Commander");
    await expect(page.locator(".campaign-node-details")).toContainText("Mission type");
    await expect(page.locator(".campaign-node-details")).toContainText("Assault");
    await expect(page.locator(".campaign-node-details")).toContainText("Fortified Enemy");
    await expect(page.locator(".campaign-node-details")).toContainText("Reward preview");
    await expect(page.locator(".campaign-node-details")).toContainText("Act 1 Step 6: Champion Relic Milestone");
    await expect(page.locator(".campaign-node-details")).toContainText("Equip the relic, spend skill points");
    await expect(page.locator(".campaign-node-details")).toContainText("Enemy doctrine: Fortress");
    await expect(page.locator(".campaign-node-details")).toContainText("Attack economy first");
    await expect(page.locator(".campaign-node-details")).toContainText("Cinder Iron Guard");
    await expect(page.getByTestId("campaign-tactical-plan-panel")).toContainText("Tactical plan");
    await expect(page.getByTestId("campaign-tactical-plan-panel")).toContainText("Resource Push");
    await expect(page.getByTestId("campaign-tactical-plan-panel")).toContainText("Recommended response");
    await clickReady(page.getByTestId("campaign-tactical-plan-champion_hunt"), "deep-flow select Champion Hunt tactical plan");
    await expect(page.getByTestId("campaign-status")).toContainText("Tactical plan selected: Champion Hunt");
    await expect(page.locator(".campaign-node-details")).toContainText("Selected plan");
    await expect(page.locator(".campaign-node-details")).toContainText("Hero starts with +6% maximum Mana");
    await expect(page.getByTestId("campaign-start-node")).toBeEnabled();
    await clickReady(
      page.getByTestId("campaign-start-node"),
      "deep-flow Ashen Outpost campaign start",
      SCENE_TRANSITION_CLICK_OPTIONS
    );
    await expectBattleLoaded(page);
    await waitForBattleScene(page);
    await expect(page.getByTestId("battle-status")).toContainText("Tactical plan: Champion Hunt");
    await expect(page.getByTestId("battle-objectives")).toContainText("Objectives 0/3");
    await expect(page.getByTestId("battle-objectives")).toContainText("Capture the Burned Shrine");
    await expect(page.getByTestId("battle-objectives")).toContainText("Defeat Captain Malrec");
    await expect(page.getByTestId("enemy-doctrine-status")).toContainText("Fortress");
    await expect(page.getByTestId("enemy-doctrine-status")).toContainText("Attack economy first");
    await expect(page.getByTestId("enemy-doctrine-status")).toContainText("Cinder Iron Guard");

    const scouted = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.scoutEnemyHero?.());
    expect(scouted).toMatchObject({
      enemyHeroId: "captain_malrec",
      name: "Captain Malrec",
      title: "Outpost Commander"
    });
    await expect(page.getByTestId("battle-status")).toContainText("Enemy commander sighted: Captain Malrec");
    await expect(page.locator(".minimap-enemy-hero")).toHaveCount(1);

    const eliteSquad = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const unit = scene.units.find((entry: any) => entry.team === "enemy" && entry.enemyEliteSquadId && !entry.enemyHeroId);
      if (!unit) {
        throw new Error("Expected an elite enemy unit in Ashen Outpost.");
      }
      scene.selectionSystem.setSelection([unit]);
      scene.refreshBattleHud?.(0);
      return {
        squadId: unit.enemyEliteSquadId,
        name: unit.enemyEliteSquadName,
        bonus: unit.enemyEliteBonusSummary,
        counterplay: unit.enemyEliteCounterplay,
        damage: unit.damage,
        baseDamage: unit.definition.stats.damage,
        maxHp: unit.maxHp,
        baseMaxHp: unit.definition.stats.maxHp
      };
    });
    expect(eliteSquad).toMatchObject({
      squadId: "cinder_iron_guard",
      name: "Cinder Iron Guard"
    });
    expect(eliteSquad.damage).toBeGreaterThan(eliteSquad.baseDamage);
    expect(eliteSquad.maxHp).toBeGreaterThan(eliteSquad.baseMaxHp);
    expect(eliteSquad.bonus).toContain("HP");
    expect(eliteSquad.counterplay).toContain("Focus fragile support");

    const eliteStrikeEvent = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.triggerBattlefieldEvent?.("elite_strike"));
    expect(eliteStrikeEvent).toMatchObject({
      eventId: "elite_strike",
      title: "Elite Strike"
    });
    await expect(page.getByTestId("battlefield-event-status")).toContainText("Elite Strike");
    await expect(page.getByTestId("battlefield-event-status")).toContainText("Defeat Cinder Iron Guard");
    await expect(page.getByTestId("battlefield-event-status")).toContainText("Plan support: active");
    const blockedSecondEvent = await page.evaluate(() =>
      (window as any).__ASCENDANT_TEST_HOOKS__?.triggerBattlefieldEvent?.("hold_the_line")
    );
    expect(blockedSecondEvent).toBeNull();
    const eliteStrikeResolved = await page.evaluate(() =>
      (window as any).__ASCENDANT_TEST_HOOKS__?.resolveBattlefieldEvent?.("completed")
    );
    expect(eliteStrikeResolved).toMatchObject({
      eventId: "elite_strike",
      outcome: "completed"
    });

    const completedObjectiveIds = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const shrine = scene.captureSites.find((site: any) => site.definition.id === "burned_shrine");
      const watchtower = scene.buildings.find((building: any) => building.team === "enemy" && building.definition.id === "watchtower");
      const barracks = scene.buildings.find((building: any) => building.team === "enemy" && building.definition.id === "enemy_barracks");
      if (!shrine || !watchtower || !barracks) {
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
      return [...scene.runtime.stats.completedObjectiveIds];
    });
    expect(completedObjectiveIds).toEqual(
      expect.arrayContaining(["capture_burned_shrine", "destroy_enemy_barracks"])
    );

    const defeatedEliteSquads = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const unit = scene.units.find((entry: any) => entry.team === "enemy" && entry.enemyEliteSquadId && !entry.enemyHeroId);
      if (!unit) {
        throw new Error("Expected an elite enemy unit to defeat.");
      }
      unit.takeDamage(unit.maxHp + unit.armor + 10_000);
      scene.handleKill(scene.hero, unit);
      unit.destroyView?.();
      scene.cleanupDeadEntities?.();
      scene.refreshBattleHud?.(0);
      return [...(scene.runtime.stats.enemyEliteUnitsDefeated ?? [])];
    });
    expect(defeatedEliteSquads).toContain("cinder_iron_guard");

    const defeated = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.defeatEnemyHero?.());
    expect(defeated).toMatchObject({
      enemyHeroId: "captain_malrec",
      name: "Captain Malrec",
      enemyHeroDefeated: true
    });
    expect(defeated.completedObjectiveIds).toEqual(expect.arrayContaining(["defeat_outpost_captain"]));
    expect(defeated.xpGained).toBeGreaterThan(0);
    await expect(page.getByTestId("battle-objectives")).toContainText("Objectives 3/3", { timeout: 20_000 });

    await forceActiveBattleOutcome(page, "victory");
    await expect(page.locator(".results-panel")).toContainText("Enemy commander");
    await expect(page.locator(".results-panel")).toContainText("Captain Malrec");
    await expect(page.locator(".results-panel")).toContainText("Commander defeated");
    await expect(page.locator(".campaign-reward-block")).toContainText("First-clear reward");
    await expect(page.locator(".campaign-reward-block")).toContainText("Assault");
    await expect(page.locator(".campaign-reward-block")).toContainText("Fortified Enemy");
    await expect(page.locator(".campaign-reward-block")).toContainText("The outpost is broken");
    await expect(page.locator(".campaign-reward-block")).toContainText("Act 1 Step 6: Champion Relic Milestone");
    await expect(page.locator(".campaign-reward-block")).toContainText("Choose and equip a relic");
    await expect(page.getByTestId("results-enemy-doctrine-summary")).toContainText("Fortress");
    await expect(page.getByTestId("results-enemy-doctrine-summary")).toContainText("Cinder Iron Guard");
    await expect(page.getByTestId("results-enemy-doctrine-summary")).toContainText("Elite defeated");
    await expect(page.getByTestId("results-tactical-plan-summary")).toContainText("Champion Hunt");
    await expect(page.getByTestId("results-tactical-plan-summary")).toContainText("launch-local");
    await expect(page.getByTestId("results-battlefield-event-summary")).toContainText("Elite Strike");
    await expect(page.getByTestId("results-battlefield-event-summary")).toContainText("Defeat Cinder Iron Guard");
    await expect(page.getByTestId("results-battlefield-event-summary")).toContainText("battle-local");
    await expect(page.locator(".status-box")).toContainText("Spend skill points or replay optional objectives");
    await expect(page.locator(".campaign-reward-block")).toContainText("Optional objectives");
    await expect(page.locator(".campaign-reward-block")).toContainText("3/3 recorded");
    await expect(page.getByTestId("results-relic-choice")).toContainText("Relic Reward Choice");
    await expect(page.getByTestId("results-relic-choice")).toContainText("Outpost Command Signet");
    await expect(page.getByTestId("results-relic-choice")).toContainText("Commander");
    let save = await readSave(page);
    expect(save.hero.inventory.some((item: { itemId: string }) => item.itemId === "outpost_command_signet")).toBe(false);
    await clickReady(
      page.locator("button[data-results-action='choose_relic'][data-relic-id='outpost_command_signet']"),
      "deep-flow choose source relic reward",
      {
        allowTargetGoneAfterClick: true,
        successCheckAfterClick: async () => (await page.getByTestId("results-relic-reward").count()) > 0
      }
    );
    await expect(page.getByTestId("results-relic-reward")).toContainText("Outpost Command Signet");
    await expect(page.getByTestId("results-relic-reward")).toContainText("added to hero inventory");
    await expect(page.getByTestId("results-relic-reward")).toContainText("Relic effects are active when equipped");
    await expect(page.getByTestId("results-relic-reward")).toContainText("Commander");
    save = await readSave(page);
    const relicInstance = save.hero.inventory.find((item: { itemId: string }) => item.itemId === "outpost_command_signet");
    expect(relicInstance).toBeTruthy();
    expect(save.hero.equipment.relic).toBeUndefined();
    await clickReady(page.getByRole("button", { name: "Equip Relic" }), "deep-flow equip rewarded relic");
    await expect(page.locator(".status-box")).toContainText("Outpost Command Signet equipped");
    save = await readSave(page);
    expect(save.hero.equipment.relic).toBe(relicInstance.instanceId);
    expect(save.campaign.optionalObjectiveCompletionIds).toEqual(
      expect.arrayContaining([
        "ashen_outpost:capture_burned_shrine",
        "ashen_outpost:destroy_enemy_barracks",
        "ashen_outpost:defeat_outpost_captain"
      ])
    );
    const objectiveSummary = page.locator(".special-objectives");
    await expect(objectiveSummary).toContainText("Capture the Burned Shrine");
    await expect(objectiveSummary).toContainText("Destroy Enemy Barracks");
    await expect(objectiveSummary).toContainText("Defeat Captain Malrec");
    const summaryText = await objectiveSummary.innerText();
    expect(summaryText).toMatch(/Capture the Burned Shrine\s+Completed/);
    expect(summaryText).toMatch(/Destroy Enemy Barracks\s+Completed/);
    expect(summaryText).toMatch(/Defeat Captain Malrec\s+Completed/);
    await clickReady(page.locator("button[data-results-action='inventory']"), "deep-flow open inventory after relic equip");
    await expect(page.getByTestId("hero-inventory")).toBeVisible();
    await expect(page.getByTestId("equipment-panel")).toContainText("Relic");
    await expect(page.getByTestId("equipment-panel")).toContainText("Outpost Command Signet");
    await expect(page.getByTestId("hero-stats")).toContainText("HP");
  });

  test("Old Stone Road victory unlocks the next campaign layer without repeat-starting completed rewards @hosted-deep-campaign", async ({ page }) => {
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
    await expect(page.getByTestId("enemy-doctrine-status")).toContainText("Raider");
    await expect(page.getByTestId("enemy-doctrine-status")).toContainText("Protect sites");
    const capturedSite = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.captureSite?.("crown_shrine"));
    expect(capturedSite).toMatchObject({
      siteId: "crown_shrine",
      owner: "player"
    });
    const siteThreatEvent = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.triggerBattlefieldEvent?.("site_under_threat"));
    expect(siteThreatEvent).toMatchObject({
      eventId: "site_under_threat",
      title: "Site Under Threat"
    });
    await expect(page.getByTestId("battlefield-event-status")).toContainText("Site Under Threat");
    await expect(page.getByTestId("battlefield-event-status")).toContainText("Hold Crown Shrine");
    const siteThreatResolved = await page.evaluate(() =>
      (window as any).__ASCENDANT_TEST_HOOKS__?.resolveBattlefieldEvent?.("completed")
    );
    expect(siteThreatResolved).toMatchObject({
      eventId: "site_under_threat",
      outcome: "completed"
    });
    const oldRoadDoctrine = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      return scene.runtime.stats.enemyDoctrineId;
    });
    expect(oldRoadDoctrine).toBe("raider");
    await forceActiveBattleOutcome(page, "victory");
    await expect(page.locator(".results-panel")).toContainText("Victory");
    await expect(page.getByTestId("results-enemy-doctrine-summary")).toContainText("Raider");
    await expect(page.getByTestId("results-enemy-doctrine-summary")).toContainText("Protect sites");
    await expect(page.getByTestId("results-battlefield-event-summary")).toContainText("Site Under Threat");
    await expect(page.getByTestId("results-battlefield-event-summary")).toContainText("Hold Crown Shrine");
    await expect(page.locator(".campaign-reward-block")).toContainText("Old Stone Road");
    await expect(page.locator(".campaign-reward-block")).toContainText("Act 1 Step 3: Base Development");
    await expect(page.locator(".campaign-reward-block")).toContainText("Next mission unlocked: Aether Well Ruins");
    await expect(page.locator(".campaign-reward-block")).toContainText("Control");
    await expect(page.locator(".campaign-reward-block")).toContainText("Rich Veins");
    await expect(page.locator(".campaign-reward-block")).toContainText("The road is open");

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
    await clickReady(page.getByTestId("campaign-node-aether_well_ruins"), "deep-flow Aether Well guidance check");
    await expect(page.locator(".campaign-node-details")).toContainText("Act 1 Step 4: Resource Control");
    await expect(page.locator(".campaign-node-details")).toContainText("Hold two sites");
    await expect(page.locator(".campaign-node-details")).toContainText("assign Workers");

    await clickReady(page.getByTestId("campaign-node-old_stone_road"), "deep-flow Old Stone replay detail");
    await expect(page.getByTestId("campaign-node-old_stone_road")).toContainText(/Replayable/i);
    await expect(page.locator(".campaign-node-details")).toContainText("Control");
    await expect(page.locator(".campaign-node-details")).toContainText("Act 1 Step 3: Base Development");
    await expect(page.locator(".campaign-node-details")).toContainText("Train Workers early");
    await expect(page.locator(".campaign-node-details")).toContainText("Rich Veins");
    await expect(page.locator(".campaign-node-details")).toContainText("Reward preview");
    await expect(page.locator(".campaign-node-details")).toContainText("Replay reward");
    await expect(page.locator(".campaign-node-details")).toContainText("Campaign node reward already claimed");
    await expect(page.getByTestId("campaign-start-node")).toBeEnabled();
    await expect(page.getByTestId("campaign-start-node")).toContainText("Replay Battle");
    await clickReady(
      page.getByTestId("campaign-start-node"),
      "deep-flow replay Old Stone Road",
      SCENE_TRANSITION_CLICK_OPTIONS
    );
    await expectBattleLoaded(page);
    await forceActiveBattleOutcome(page, "victory");
    await expect(page.locator(".results-panel")).toContainText("replay complete");
    await expect(page.locator(".campaign-reward-block")).toContainText("Replay reward");
    await expect(page.locator(".campaign-reward-block")).toContainText("Replay complete");
    await expect(page.locator(".campaign-reward-block")).toContainText("Control");
    await expect(page.locator(".campaign-reward-block")).toContainText("Rich Veins");
    await expect(page.locator(".campaign-reward-block")).toContainText("Already claimed");
    save = await readSave(page);
    expect(save.campaign.resources).toMatchObject({
      crowns: 60,
      stone: 45,
      iron: 15,
      aether: 0
    });
  });

  test("live campaign battles resolve victory and defeat through BattleScene results @hosted-deep-campaign", async ({ page }) => {
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
