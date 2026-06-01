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
import {
  SAVE_KEY,
  clickReady,
  continueSavedCampaign,
  expectBattleLoaded,
  openFreshMainMenu,
  seedCampaignSave,
  startNewCampaign
} from "./shared-helpers";

const LAYOUT_VIEWPORTS = [
  { width: 1366, height: 768, label: "desktop" },
  { width: 820, height: 620, label: "tablet-short" },
  { width: 390, height: 844, label: "mobile-tall" },
  { width: 360, height: 640, label: "mobile-short" }
];
const DESKTOP_ACCEPTANCE_VIEWPORTS = [
  { width: 1920, height: 1080, label: "full-hd" },
  { width: 1600, height: 900, label: "wide-desktop" },
  { width: 1366, height: 768, label: "laptop" }
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
const HOSTED_LAYOUT_CORE_TIMEOUT_MS = 120_000;
const HOSTED_CINDERFEN_BATTLE_TIMEOUT_MS = 180_000;
const UI_TRANSITION_CLICK_OPTIONS = {
  allowTargetGoneAfterClick: true,
  attempts: 1,
  domFallbackTimeoutMs: 2_000,
  normalClickTimeoutMs: 1_500
} as const;

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

  expect(overlaps, `${label} campaign node cards should not overlap`).toEqual([]);
}

async function expectActionAboveFold(page: Page, locator: Locator, label: string): Promise<void> {
  const box = await waitForLayoutBox(page, locator);
  expect(box, `${label} has a layout box`).not.toBeNull();
  const viewport = page.viewportSize();
  expect(viewport, `${label} viewport exists`).not.toBeNull();
  const mainScrollTop = await page.locator("main").evaluate((element) => element.scrollTop).catch(() => 0);
  expect(mainScrollTop, `${label} should not require default page scroll`).toBe(0);
  if (!box || !viewport) {
    return;
  }
  expect(box.y, `${label} top edge`).toBeGreaterThanOrEqual(-2);
  expect(box.y + box.height, `${label} bottom edge`).toBeLessThanOrEqual(viewport.height + 2);
}

async function expectNoTextOverflowForSelectors(page: Page, selectors: string[], label: string): Promise<void> {
  const offenders = await page.evaluate((selectorList) => {
    return selectorList
      .flatMap((selector) => Array.from(document.querySelectorAll<HTMLElement>(selector)))
      .map((element) => {
        const style = window.getComputedStyle(element);
        const rect = element.getBoundingClientRect();
        if (
          style.display === "none" ||
          style.visibility === "hidden" ||
          rect.width === 0 ||
          rect.height === 0 ||
          style.overflowX === "auto" ||
          style.overflowX === "scroll"
        ) {
          return undefined;
        }
        if (element.scrollWidth > element.clientWidth + 3) {
          return {
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

  expect(offenders, `${label} key cards should not clip text horizontally`).toEqual([]);
}

async function expectReadableFontSizes(
  page: Page,
  selectors: string[],
  minimumPx: number,
  label: string
): Promise<void> {
  const offenders = await page.evaluate(
    ({ selectorList, minSize }) => {
      return selectorList
        .flatMap((selector) => Array.from(document.querySelectorAll<HTMLElement>(selector)))
        .map((element) => {
          const style = window.getComputedStyle(element);
          const rect = element.getBoundingClientRect();
          if (style.display === "none" || style.visibility === "hidden" || rect.width === 0 || rect.height === 0) {
            return undefined;
          }
          const fontSize = Number.parseFloat(style.fontSize);
          if (fontSize + 0.1 < minSize) {
            return {
              className: String(element.className),
              testId: element.getAttribute("data-testid") ?? "",
              fontSize,
              text: (element.textContent ?? "").trim().replace(/\s+/g, " ").slice(0, 80)
            };
          }
          return undefined;
        })
        .filter(Boolean)
        .slice(0, 10);
    },
    { selectorList: selectors, minSize: minimumPx }
  );

  expect(offenders, `${label} should use readable ${minimumPx}px+ type`).toEqual([]);
}

async function expectNoNestedCardExplosion(page: Page, label: string): Promise<void> {
  const offenders = await page.evaluate(() => {
    return Array.from(
      document.querySelectorAll<HTMLElement>(
        ".campaign-selected-panel .campaign-support-card .campaign-support-card, .campaign-tab-panel .campaign-support-card .campaign-support-card, .results-panel .reward-card .reward-card"
      )
    ).map((element) => ({
      className: String(element.className),
      text: (element.textContent ?? "").trim().replace(/\s+/g, " ").slice(0, 90)
    }));
  });

  expect(offenders, `${label} should not introduce nested-card clutter`).toEqual([]);
}

async function scrollMainToBottom(page: Page): Promise<void> {
  await page.locator("main").evaluate((element) => {
    element.scrollTop = element.scrollHeight;
  });
}

async function expectInViewport(page: Page, locator: Locator, label: string): Promise<void> {
  const box = await waitForLayoutBox(page, locator);
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
  await locator.evaluate((element) => element.scrollIntoView({ block: "center", inline: "nearest" })).catch(() => undefined);
  await locator.scrollIntoViewIfNeeded({ timeout: 1_000 }).catch(() => undefined);
  const box = await waitForLayoutBox(page, locator);
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
  await locator.waitFor({ state: "attached", timeout: 10_000 });
  await locator.evaluate((element) => element.scrollIntoView({ block: "center", inline: "nearest" })).catch(() => undefined);
  await locator.scrollIntoViewIfNeeded({ timeout: 1_000 }).catch(() => undefined);
  await expect(locator, `${label} visible`).toBeVisible({ timeout: 5_000 });
  if (options.enabled !== false) {
    await expect(locator, `${label} enabled`).toBeEnabled({ timeout: 5_000 });
  }
  const box = await waitForLayoutBox(page, locator);
  expect(box, `${label} has button dimensions`).not.toBeNull();
  const viewport = page.viewportSize();
  expect(viewport, `${label} viewport exists`).not.toBeNull();
  if (!box) {
    return;
  }
  if (viewport) {
    expect(box.x, `${label} left edge`).toBeGreaterThanOrEqual(-2);
    expect(box.x + box.width, `${label} right edge`).toBeLessThanOrEqual(viewport.width + 2);
    expect(box.y, `${label} top edge`).toBeGreaterThanOrEqual(-2);
    expect(box.y + box.height, `${label} bottom edge`).toBeLessThanOrEqual(viewport.height + 2);
  }
  expect(box.width, `${label} tap width`).toBeGreaterThanOrEqual(40);
  expect(box.height, `${label} tap height`).toBeGreaterThanOrEqual(32);
}

async function readLayoutBox(locator: Locator): Promise<Awaited<ReturnType<Locator["boundingBox"]>>> {
  const playwrightBox = await locator.boundingBox({ timeout: 500 }).catch(() => null);
  if (playwrightBox) {
    return playwrightBox;
  }
  return locator
    .evaluateAll((elements) => {
      for (const element of elements) {
        const target = element as HTMLElement;
        const style = window.getComputedStyle(target);
        const rect = target.getBoundingClientRect();
        if (
          style.display !== "none" &&
          style.visibility !== "hidden" &&
          Number(style.opacity || "1") > 0 &&
          rect.width > 0 &&
          rect.height > 0
        ) {
          return {
            x: rect.x,
            y: rect.y,
            width: rect.width,
            height: rect.height
          };
        }
      }
      return null;
    })
    .catch(() => null);
}

async function waitForLayoutBox(page: Page, locator: Locator): Promise<Awaited<ReturnType<Locator["boundingBox"]>>> {
  let box = await readLayoutBox(locator);
  for (let attempt = 0; !box && attempt < 20; attempt += 1) {
    await page.waitForTimeout(100);
    box = await readLayoutBox(locator);
  }
  return box;
}

type LayoutBoxSnapshot = {
  x: number;
  y: number;
  width: number;
  height: number;
};

type CommandButtonGeometry = {
  buttonBox: LayoutBoxSnapshot | null;
  panelBox: LayoutBoxSnapshot | null;
  text: string;
  visible: boolean;
};

async function scrollCommandButtonIntoPanel(page: Page, action: string, index: number): Promise<CommandButtonGeometry> {
  let geometry: CommandButtonGeometry = { buttonBox: null, panelBox: null, text: "", visible: false };

  for (let attempt = 0; attempt < 8; attempt += 1) {
    geometry = await page.evaluate(
      ({ action: requestedAction, index: requestedIndex }): CommandButtonGeometry => {
      const readBox = (target: Element): LayoutBoxSnapshot => {
        const rect = target.getBoundingClientRect();
        return {
          x: rect.x,
          y: rect.y,
          width: rect.width,
          height: rect.height
        };
      };
      const container = document.querySelector<HTMLElement>(".side-panel");
      const controls = Array.from(container?.querySelectorAll<HTMLButtonElement>("button[data-action]") ?? []).filter(
        (entry) => entry.dataset.action === requestedAction
      );
      const control = controls[requestedIndex];
      if (!control) {
        return {
          buttonBox: null,
          panelBox: container ? readBox(container) : null,
          text: "",
          visible: false
        };
      }
      if (!container) {
        control.scrollIntoView({ block: "center", inline: "nearest" });
      } else {
        const panelRect = container.getBoundingClientRect();
        const rect = control.getBoundingClientRect();
        const centeredTop =
          container.scrollTop + rect.top - panelRect.top - Math.max(0, (container.clientHeight - rect.height) / 2);
        container.scrollTop = Math.max(0, centeredTop);
      }

      const style = window.getComputedStyle(control);
      const buttonBox = readBox(control);
      const panelBox = container ? readBox(container) : null;
      return {
        buttonBox,
        panelBox,
        text: (control.getAttribute("aria-label") ?? control.textContent ?? "").trim().replace(/\s+/g, " ").slice(0, 180),
        visible:
          style.display !== "none" &&
          style.visibility !== "hidden" &&
          Number(style.opacity || "1") > 0 &&
          buttonBox.width > 0 &&
          buttonBox.height > 0
      };
    },
      { action, index }
    );

    if (
      geometry.buttonBox &&
      geometry.panelBox &&
      geometry.buttonBox.y >= geometry.panelBox.y - 1 &&
      geometry.buttonBox.y + geometry.buttonBox.height <= geometry.panelBox.y + geometry.panelBox.height + 1
    ) {
      return geometry;
    }

    await page.waitForTimeout(100);
  }

  return geometry;
}

async function launchTutorialOverlay(page: Page, label: string): Promise<void> {
  await openFreshMainMenu(page);
  await expectNoHorizontalOverflow(page, `${label} main menu`);
  await expectReachableButton(page, page.getByTestId("menu-tutorial"), `${label} Tutorial`);
  await page.getByTestId("menu-tutorial").evaluate((element) => (element as HTMLElement).click());
  await expectBattleLoaded(page, `${label} tutorial battle`);
  await expect(page.getByTestId("tutorial-overlay")).toBeVisible({ timeout: 15_000 });
  await expect(page.getByTestId("tutorial-next")).toBeVisible({ timeout: 15_000 });
  await expect(page.getByTestId("tutorial-next")).toBeEnabled({ timeout: 15_000 });
  await expectReachableButton(page, page.getByTestId("tutorial-next"), `${label} tutorial next after launch`);
}

async function expectBattleCommandButtonsReachable(page: Page, actions: string[], label: string): Promise<void> {
  const panel = page.locator(".side-panel");
  await expect(panel, `${label} side panel visible before command reachability`).toBeVisible({ timeout: 15_000 });
  await page
    .waitForFunction(
      (requestedActions) => {
        const sidePanel = document.querySelector<HTMLElement>(".side-panel");
        return Boolean(
          sidePanel &&
            requestedActions.some((action) => sidePanel.querySelector(`button[data-action="${action}"]`))
        );
      },
      actions,
      { timeout: 10_000 }
    )
    .catch(async (error) => {
      console.warn(`${label} command button readiness failed: ${error instanceof Error ? error.message : String(error)}`);
      console.warn(`${label} diagnostics: ${JSON.stringify(await commandPanelDiagnostics(page))}`);
      throw error;
    });

  const viewport = page.viewportSize();
  const panelBox = await waitForLayoutBox(page, panel);
  expect(viewport, `${label} viewport exists`).not.toBeNull();
  expect(panelBox, `${label} side panel has a layout box`).not.toBeNull();
  if (!viewport || !panelBox) {
    return;
  }

  let count = 0;
  const offenders: string[] = [];
  for (const action of actions) {
    const buttons = panel.locator(`button[data-action="${action}"]`);
    const actionCount = await buttons.count();
    count += actionCount;
    for (let index = 0; index < actionCount; index += 1) {
      const button = buttons.nth(index);
      await expect(button, `${label} ${action} command ${index + 1} visible`).toBeVisible({ timeout: 5_000 });
      const geometry = await scrollCommandButtonIntoPanel(page, action, index);
      const box = geometry.buttonBox;
      const buttonPanelBox = geometry.panelBox ?? panelBox;
      const fallbackText = (await button.getAttribute("aria-label")) ?? (await button.innerText()).replace(/\s+/g, " ").trim();
      const text = geometry.text || fallbackText;
      const problems = [];
      if (!box) {
        problems.push("missing layout box");
      } else {
        if (box.x < -1 || box.x + box.width > viewport.width + 1) {
          problems.push("outside viewport width");
        }
        if (
          box.y < buttonPanelBox.y - 1 ||
          box.y + box.height > buttonPanelBox.y + buttonPanelBox.height + 1 ||
          box.y < -1 ||
          box.y + box.height > viewport.height + 1
        ) {
          problems.push("not visible in command panel");
        }
        if (box.width < 72 || box.height < 40) {
          problems.push(`small tap target ${Math.round(box.width)}x${Math.round(box.height)}`);
        }
      }
      if (problems.length > 0) {
        offenders.push(`${text}: ${problems.join(", ")}`);
      }
    }
  }

  expect(count, `${label} command buttons for ${actions.join(", ")} are present`).toBeGreaterThan(0);
  expect(offenders, `${label} command buttons should be visible, wide enough, and inside the panel`).toEqual([]);
}

async function commandPanelDiagnostics(page: Page): Promise<Record<string, unknown>> {
  return page
    .evaluate(() => {
      const hud = document.querySelector("[data-testid='battle-hud']");
      const panel = document.querySelector<HTMLElement>(".side-panel");
      return {
        url: window.location.href,
        hasBattleHud: Boolean(hud),
        hasSidePanel: Boolean(panel),
        sidePanelText: (panel?.textContent ?? "").trim().replace(/\s+/g, " ").slice(0, 240)
      };
    })
    .catch((error) => ({
      diagnosticError: error instanceof Error ? error.message : String(error)
    }));
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
  let lastError: unknown;
  for (let attempt = 1; attempt <= 3; attempt += 1) {
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
      const wasUnderConstruction = barracks.constructionState === "underConstruction";
      barracks.constructionState = "completed";
      barracks.constructionProgress = 1;
      barracks.constructionProgressing = false;
      barracks.hp = Math.max(barracks.hp, barracks.maxHp);
      if (wasUnderConstruction) {
        scene.runtime?.recordBuildingBuilt?.(barracks.definition.id);
      }
      scene.cameraSystem.centerOn(barracks.position);
      scene.selectionSystem.setSelection([barracks]);
      (document.activeElement as HTMLElement | null)?.blur?.();
      scene.refreshBattleHud?.(0);
    });

    try {
      await page.waitForFunction(
        () => document.querySelector<HTMLElement>(".side-panel")?.textContent?.includes("Barracks"),
        undefined,
        { timeout: 3_000 }
      );
      await expect(page.locator(".side-panel")).toContainText("Barracks");
      return;
    } catch (error) {
      lastError = error;
      console.warn(`layout Barracks selection did not render after attempt ${attempt}; retrying`);
      await page.waitForTimeout(100);
    }
  }
  throw lastError instanceof Error ? lastError : new Error("layout Barracks selection did not render");
}

async function expectBottomActionReachable(page: Page, locator: Locator, label: string): Promise<void> {
  await scrollMainToBottom(page);
  await expectInViewport(page, locator, label);
}

async function expectCampaignSupportPanelsReadable(page: Page, label: string): Promise<void> {
  for (const [tab, testId, expectedText] of [
    ["stronghold", "campaign-bank", "Crowns"],
    ["stronghold", "stronghold-panel", "Stronghold"],
    ["hero", "retinue-panel", "Retinue"],
    ["intel", "rival-intel-panel", "Rival Intel"],
    ["reputation", "campaign-reputation", "Common Folk"]
  ] as const) {
    await clickReady(page.getByTestId(`campaign-tab-${tab}`), `${label} ${tab} tab`, UI_TRANSITION_CLICK_OPTIONS);
    const panel = page.getByTestId(testId);
    await expect(panel, `${label} ${testId}`).toContainText(expectedText);
    await expectWithinViewportWidth(page, panel, `${label} ${testId}`);
  }
  await clickReady(page.getByTestId("campaign-tab-map"), `${label} map tab`, UI_TRANSITION_CLICK_OPTIONS);
}

async function expectCinderfenBattleHudReadable(
  page: Page,
  label: string,
  expected: { mapName: string; objectiveTexts: string[] }
): Promise<void> {
  await expectBattleLoaded(page, `${label} battle`);
  await expect(page.getByTestId("battle-status")).toBeVisible();
  await expect
    .poll(
      async () =>
        page.evaluate(() => {
          const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
          return scene?.scene.isActive() ? scene.activeMap?.name ?? "" : "";
        }),
      { message: `${label} battle launched expected map` }
    )
    .toBe(expected.mapName);
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
  await expectBattleCommandButtonsReachable(page, ["train"], `${label} command hall`);
}

async function showVictoryResults(page: Page): Promise<void> {
  await page.waitForFunction(() => Boolean(window.ascendantRealmsGame), undefined, { timeout: 10_000 });
  await page.evaluate(() => {
    const game = window.ascendantRealmsGame;
    if (!game) {
      throw new Error("Ascendant Realms game was not booted.");
    }
    const battleScene = game.scene.getScene("BattleScene");
    if (battleScene?.scene.isActive()) {
      game.scene.stop("BattleScene");
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
  await page.waitForFunction(() => {
    const game = window.ascendantRealmsGame;
    return Boolean(game?.scene.getScene("ResultsScene")?.scene.isActive() && document.querySelector(".results-panel"));
  });
}

async function showLayoutResults(page: Page, outcome: "victory" | "defeat", wasReplay = false): Promise<void> {
  await page.waitForFunction(() => Boolean(window.ascendantRealmsGame), undefined, { timeout: 10_000 });
  await page.evaluate(
    ({ outcome, wasReplay }) => {
      const game = window.ascendantRealmsGame;
      if (!game) {
        throw new Error("Ascendant Realms game was not booted.");
      }
      const battleScene = game.scene.getScene("BattleScene");
      if (battleScene?.scene.isActive()) {
        game.scene.stop("BattleScene");
      }
      const startingHero = {
        heroName: "Layout Results",
        classId: "warlord",
        originId: "exiled_noble",
        level: 2,
        xp: 120,
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
        xp: outcome === "victory" ? startingHero.xp + 55 : startingHero.xp,
        completedBattles: outcome === "victory" ? startingHero.completedBattles + 1 : startingHero.completedBattles
      };
      game.scene.start("ResultsScene", {
        heroSave: hero,
        startingHeroSave: startingHero,
        launchRequest: {
          requestId: `layout-v090-${outcome}${wasReplay ? "-replay" : ""}`,
          mode: "campaign_node",
          mapId: "broken_ford",
          heroSave: hero,
          sourceId: "layout",
          rewardTableId: "broken_ford_rewards",
          difficulty: "easy",
          modifiers: [],
          enemyProfileId: "ashen_covenant",
          aiPersonalityId: "raider_captain",
          campaignNodeId: "old_stone_road"
        },
        stats: {
          outcome,
          unitsKilled: outcome === "victory" ? 16 : 4,
          buildingsDestroyed: outcome === "victory" ? 2 : 0,
          resourcesCaptured: outcome === "victory" ? 2 : 1,
          firstSiteCaptured: "Old Stone Ford",
          buildingsBuilt: 3,
          builtBuildingIds: ["barracks", "watchtower"],
          unitsTrained: 8,
          trainedUnitIds: ["militia", "ranger"],
          enemyWavesSurvived: outcome === "victory" ? 3 : 1,
          xpGained: outcome === "victory" ? 55 : 10,
          timeSeconds: outcome === "victory" ? 388 : 270,
          completedObjectiveIds: outcome === "victory" ? ["capture_old_ford", "destroy_enemy_barracks"] : ["capture_old_ford"],
          veteranSummary:
            outcome === "victory"
              ? {
                  rankedUpUnits: [
                    {
                      unitInstanceId: "layout-veteran-1",
                      unitTypeId: "militia",
                      unitName: "Militia",
                      xp: 120,
                      rank: "veteran",
                      rankName: "Veteran",
                      kills: 3,
                      damageDealt: 180,
                      survivedBattle: true,
                      rankedUp: true,
                      previousRank: "seasoned"
                    }
                  ],
                  notableVeterans: [],
                  topSurvivor: {
                    unitInstanceId: "layout-veteran-2",
                    unitTypeId: "ranger",
                    unitName: "Ranger",
                    xp: 70,
                    rank: "seasoned",
                    rankName: "Seasoned",
                    kills: 2,
                    damageDealt: 140,
                    survivedBattle: true,
                    rankedUp: false
                  }
                }
              : undefined
        },
        reward:
          outcome === "victory"
            ? {
                itemIds: [],
                itemInstances: [],
                resources: wasReplay ? { crowns: 20 } : { crowns: 70, stone: 30 },
                xp: wasReplay ? 18 : 55,
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
          unlockedNodeIds: outcome === "victory" && !wasReplay ? ["aether_well_ruins"] : [],
          unlockedNodeNames: outcome === "victory" && !wasReplay ? ["Aether Well Ruins"] : [],
          wasReplay,
          nodeRewardAlreadyClaimed: wasReplay,
          nodeReward:
            outcome === "victory" && !wasReplay
              ? { itemIds: [], itemInstances: [], resources: { crowns: 60, stone: 30 }, xp: 55, duplicateConversions: [] }
              : { itemIds: [], itemInstances: [], resources: {}, xp: 0, duplicateConversions: [] },
          nodeLevelUp: {
            previousLevel: 2,
            newLevel: outcome === "victory" && !wasReplay ? 3 : 2,
            levelsGained: outcome === "victory" && !wasReplay ? 1 : 0,
            skillPointsGained: outcome === "victory" && !wasReplay ? 1 : 0
          },
          campaignResources: { crowns: 130, stone: 55, iron: 15, aether: 10 }
        }
      });
    },
    { outcome, wasReplay }
  );
  await expect(page.locator(".results-panel")).toBeVisible({ timeout: 15_000 });
  await expect(page.getByTestId("results-full-details")).not.toHaveAttribute("open", "");
}

async function startAshenOutpostSkirmish(page: Page, heroName: string): Promise<void> {
  await seedCampaignSave(page, { hero: { heroName } });
  await clickReady(page.getByTestId("menu-skirmish"), "layout Ashen Outpost skirmish menu");
  await expect(page.getByTestId("skirmish-setup")).toBeVisible();
  await clickReady(page.getByTestId("setup-map-ashen_outpost"), "layout Ashen Outpost map");
  await clickReady(page.getByTestId("setup-difficulty-normal"), "layout Ashen Outpost normal difficulty");
  await clickReady(
    page.getByTestId("setup-start-battle"),
    "layout Ashen Outpost skirmish start battle",
    UI_TRANSITION_CLICK_OPTIONS
  );
  await expectBattleLoaded(page, "layout Ashen Outpost battle");
}

test.describe("Ascendant Realms responsive layout", () => {
  for (const viewport of DESKTOP_ACCEPTANCE_VIEWPORTS) {
    test(`v0.90 campaign desktop viewport acceptance on ${viewport.label} @hosted-layout-core`, async ({ page }) => {
      test.setTimeout(HOSTED_LAYOUT_CORE_TIMEOUT_MS);
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await startNewCampaign(page, `Layout v090 ${viewport.label}`);
      await expect(page.getByTestId("campaign-map")).toBeVisible();
      await expect(page.getByTestId("campaign-tab-panel-map")).toBeVisible();
      await expect(page.getByTestId("campaign-route-layer")).toBeVisible();
      await expect(page.getByTestId("campaign-node-border_village")).toContainText(/Available/i);
      await expect(page.locator(".campaign-selected-panel")).toContainText("Salto Outskirts");
      await expect(page.locator(".campaign-selected-panel")).toContainText("Primary objective");
      await expect(page.locator(".campaign-selected-panel")).toContainText("Reward");
      await expect(page.locator(".campaign-node-more")).not.toHaveAttribute("open", "");
      await expect(page.locator(".campaign-node-more summary")).toContainText("More Details");
      await expectActionAboveFold(page, page.getByTestId("campaign-start-node"), `${viewport.label} fresh campaign start`);
      await expectNoCampaignNodeOverlap(page, `${viewport.label} fresh campaign map`);
      await expectNoHorizontalOverflow(page, `${viewport.label} fresh campaign map`);
      await expectNoTextOverflowForSelectors(
        page,
        [".campaign-node", ".campaign-selected-panel", ".campaign-selected-facts"],
        `${viewport.label} fresh campaign map`
      );

      await clickReady(page.getByTestId("campaign-node-aether_well_ruins"), `${viewport.label} locked Aether Well preview`, UI_TRANSITION_CLICK_OPTIONS);
      await expect(page.locator(".campaign-selected-panel")).toContainText("Aether Well Ruins");
      await expect(page.locator(".campaign-selected-panel")).toContainText("Lock reason");
      await expect(page.getByTestId("campaign-start-node")).toBeDisabled();
      await expectActionAboveFold(page, page.getByTestId("campaign-start-node"), `${viewport.label} locked Aether primary action`);
      await expectNoCampaignNodeOverlap(page, `${viewport.label} locked campaign map`);
      await expectNoHorizontalOverflow(page, `${viewport.label} locked campaign map`);

      await page.locator(".campaign-node-more summary").click();
      await expect(page.locator(".campaign-node-more")).toHaveAttribute("open", "");
      await expect(page.locator(".campaign-node-more")).toContainText("Pre-battle intelligence");

      for (const [tab, expectedTestId, expectedText] of [
        ["map", "campaign-tab-panel-map", "Aether Well Ruins"],
        ["stronghold", "campaign-tab-panel-stronghold", "Stronghold"],
        ["hero", "campaign-tab-panel-hero", "Hero"],
        ["inventory", "campaign-tab-panel-inventory", "Inventory And Progression"],
        ["intel", "campaign-tab-panel-intel", "Rival Intel"],
        ["reputation", "campaign-tab-panel-reputation", "Reputation"]
      ] as const) {
        await clickReady(page.getByTestId(`campaign-tab-${tab}`), `${viewport.label} ${tab} tab`, UI_TRANSITION_CLICK_OPTIONS);
        await expect(page.getByTestId(expectedTestId), `${viewport.label} ${tab} panel`).toContainText(expectedText);
        await expectNoHorizontalOverflow(page, `${viewport.label} ${tab} tab`);
      }
    });
  }

  test("v0.93 Salto mission panel resets after inspecting locked details @hosted-layout-core", async ({ page }) => {
    test.setTimeout(HOSTED_LAYOUT_CORE_TIMEOUT_MS);
    await page.setViewportSize({ width: 1366, height: 768 });
    await startNewCampaign(page, "Layout v093 Salto Reset");

    const borderNode = page.getByTestId("campaign-node-border_village");
    const borderNodeBox = await waitForLayoutBox(page, borderNode);
    expect(borderNodeBox, "Border Village node has a click target").not.toBeNull();
    if (borderNodeBox) {
      expect(borderNodeBox.width, "Border Village node target width").toBeGreaterThanOrEqual(44);
      expect(borderNodeBox.height, "Border Village node target height").toBeGreaterThanOrEqual(44);
    }

    await expect(page.locator(".campaign-selected-panel")).toContainText("Salto Outskirts");
    await expect(page.locator(".campaign-node-more")).not.toHaveAttribute("open", "");
    await expectActionAboveFold(page, page.getByTestId("campaign-start-node"), "v0.93 fresh Salto action");

    const saveBefore = await page.evaluate((key) => {
      const raw = localStorage.getItem(key);
      return raw ? JSON.parse(raw) : null;
    }, SAVE_KEY);

    await clickReady(page.getByTestId("campaign-node-aether_well_ruins"), "v0.93 locked Aether Well preview", UI_TRANSITION_CLICK_OPTIONS);
    await expect(page.locator(".campaign-selected-panel")).toContainText("Aether Well Ruins");
    await page.locator(".campaign-node-more summary").click();
    await expect(page.locator(".campaign-node-more")).toHaveAttribute("open", "");
    await expect(page.locator(".campaign-node-more")).toContainText("Pre-battle intelligence");

    const scrolledPreview = await page.evaluate(() => {
      const panel = document.querySelector<HTMLElement>("[data-testid='campaign-selected-panel']");
      if (!panel) {
        throw new Error("Missing selected mission panel.");
      }
      const maxScroll = Math.max(0, panel.scrollHeight - panel.clientHeight);
      panel.scrollTop = Math.min(220, maxScroll);
      return {
        clientHeight: panel.clientHeight,
        scrollHeight: panel.scrollHeight,
        scrollTop: panel.scrollTop
      };
    });
    expect(scrolledPreview.scrollHeight, "Locked mission details should be scrollable for reset coverage").toBeGreaterThan(
      scrolledPreview.clientHeight
    );
    expect(scrolledPreview.scrollTop, "Locked mission panel should have prior scroll before reset").toBeGreaterThan(0);

    await clickReady(borderNode, "v0.93 return to Salto after locked details", UI_TRANSITION_CLICK_OPTIONS);
    await expect(page.locator(".campaign-selected-panel")).toContainText("Salto Outskirts");
    await expect(page.getByTestId("campaign-start-node")).toBeEnabled();
    await expectActionAboveFold(page, page.getByTestId("campaign-start-node"), "v0.93 reset Salto action");
    await expectNoHorizontalOverflow(page, "v0.93 reset Salto campaign map");
    await expectNoCampaignNodeOverlap(page, "v0.93 reset Salto campaign map");
    await expectNoTextOverflowForSelectors(
      page,
      [".campaign-selected-panel", ".campaign-selected-facts", ".campaign-node"],
      "v0.93 reset Salto campaign map"
    );
    await expectReadableFontSizes(
      page,
      [".campaign-selected-summary p", ".campaign-selected-facts span", ".campaign-selected-facts strong", ".campaign-node strong"],
      12,
      "v0.93 campaign body copy"
    );
    await expectNoNestedCardExplosion(page, "v0.93 campaign shell");

    const resetState = await page.evaluate(() => {
      const panel = document.querySelector<HTMLElement>("[data-testid='campaign-selected-panel']");
      const details = panel?.querySelector<HTMLDetailsElement>(".campaign-node-more");
      const action = document.querySelector<HTMLElement>("[data-testid='campaign-start-node']");
      const panelRect = panel?.getBoundingClientRect();
      const actionRect = action?.getBoundingClientRect();
      return {
        activeInPanel: panel ? panel.contains(document.activeElement) || document.activeElement === panel : false,
        actionVisibleInPanel:
          Boolean(panelRect && actionRect) && actionRect!.bottom <= panelRect!.bottom + 2 && actionRect!.top >= panelRect!.top - 2,
        detailsOpen: Boolean(details?.open),
        scrollTop: panel?.scrollTop ?? -1
      };
    });
    expect(resetState.scrollTop, "Salto panel scroll should reset").toBe(0);
    expect(resetState.detailsOpen, "Salto More Details should collapse after node change").toBe(false);
    expect(resetState.actionVisibleInPanel, "Salto primary action should remain visible after reset").toBe(true);
    expect(resetState.activeInPanel, "Selected mission panel should receive safe focus after reset").toBe(true);

    const saveAfter = await page.evaluate((key) => {
      const raw = localStorage.getItem(key);
      return raw ? JSON.parse(raw) : null;
    }, SAVE_KEY);
    expect(saveAfter?.campaign?.completedNodeIds ?? []).toEqual(saveBefore?.campaign?.completedNodeIds ?? []);
    expect(saveAfter?.campaign?.nodeRewardsClaimedIds ?? []).toEqual(saveBefore?.campaign?.nodeRewardsClaimedIds ?? []);
  });

  test("v0.94 menu, Ascendant creation, campaign density, and Results details stay readable @hosted-layout-core", async ({ page }) => {
    test.setTimeout(HOSTED_LAYOUT_CORE_TIMEOUT_MS);
    await page.setViewportSize({ width: 1366, height: 768 });
    await openFreshMainMenu(page);
    await expect(page.getByTestId("main-menu-panel")).toBeVisible();
    await expect(page.locator(".menu-action-group.primary")).toContainText("Play");
    await expectActionAboveFold(page, page.getByTestId("menu-new-campaign"), "v0.94 main menu primary action");
    await expectNoHorizontalOverflow(page, "v0.94 main menu");
    await expectNoTextOverflowForSelectors(
      page,
      [".menu-home-panel", ".menu-action-board", ".menu-action-group"],
      "v0.94 main menu"
    );

    await clickReady(page.getByTestId("menu-new-campaign"), "v0.94 New Campaign", UI_TRANSITION_CLICK_OPTIONS);
    await expect(page.getByTestId("hero-creation-step-class")).toContainText("Step 1");
    await expect(page.getByTestId("hero-creation-step-origin")).toContainText("Step 2");
    await expect(page.getByTestId("hero-creation-step-review")).toContainText("Step 3");
    await expect(page.getByTestId("hero-class-warlord")).toHaveAttribute("aria-pressed", "true");
    await expect(page.getByTestId("hero-origin-exiled_noble")).toHaveAttribute("aria-pressed", "true");
    await clickReady(page.getByTestId("hero-class-arcanist"), "v0.94 select Arcanist", UI_TRANSITION_CLICK_OPTIONS);
    await clickReady(page.getByTestId("hero-origin-wildland_raider"), "v0.94 select Wildland Raider", UI_TRANSITION_CLICK_OPTIONS);
    await expect(page.getByTestId("hero-class-arcanist")).toHaveAttribute("aria-pressed", "true");
    await expect(page.getByTestId("hero-origin-wildland_raider")).toHaveAttribute("aria-pressed", "true");
    await expect(page.locator(".creation-selected-strip")).toContainText("Arcanist");
    await expect(page.locator(".creation-selected-strip")).toContainText("Wildland Raider");
    await expectActionAboveFold(page, page.getByTestId("hero-start"), "v0.94 hero creation Begin Campaign");
    await expectNoHorizontalOverflow(page, "v0.94 hero creation");
    await expectNoTextOverflowForSelectors(
      page,
      [".creation-option-card", ".creation-review-card", ".creation-selected-strip"],
      "v0.94 hero creation"
    );

    await page.getByTestId("hero-name-input").fill("Layout v094");
    await clickReady(page.getByTestId("hero-start"), "v0.94 Begin Campaign", UI_TRANSITION_CLICK_OPTIONS);
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.locator(".campaign-selected-panel")).toContainText("Salto Outskirts");
    await expect(page.locator(".campaign-selected-summary")).toContainText("Primary objective");
    await expect(page.locator(".campaign-selected-summary")).toContainText("Reward");
    await expect(page.locator(".campaign-selected-summary")).not.toContainText("Pre-battle intelligence");
    await expectActionAboveFold(page, page.getByTestId("campaign-start-node"), "v0.94 Salto primary action");
    await expectNoCampaignNodeOverlap(page, "v0.94 fresh campaign map");
    await expectNoHorizontalOverflow(page, "v0.94 fresh campaign map");
    await expectNoTextOverflowForSelectors(
      page,
      [".campaign-node", ".campaign-selected-summary", ".campaign-reward-chips"],
      "v0.94 campaign compact panel"
    );

    await clickReady(page.getByTestId("campaign-node-aether_well_ruins"), "v0.94 locked Aether Well", UI_TRANSITION_CLICK_OPTIONS);
    await expect(page.getByTestId("campaign-start-node")).toBeDisabled();
    await expect(page.locator(".campaign-node-more")).not.toHaveAttribute("open", "");
    await page.locator(".campaign-node-more summary").click();
    await expect(page.locator(".campaign-node-more")).toHaveAttribute("open", "");
    await expect(page.locator(".campaign-node-more")).toContainText("Pre-battle intelligence");
    await expectNoHorizontalOverflow(page, "v0.94 expanded mission details");

    for (const [tab, expectedTestId] of [
      ["stronghold", "campaign-tab-panel-stronghold"],
      ["hero", "campaign-tab-panel-hero"],
      ["inventory", "campaign-tab-panel-inventory"],
      ["intel", "campaign-tab-panel-intel"],
      ["reputation", "campaign-tab-panel-reputation"]
    ] as const) {
      await clickReady(page.getByTestId(`campaign-tab-${tab}`), `v0.94 ${tab} tab`, UI_TRANSITION_CLICK_OPTIONS);
      await expect(page.getByTestId(expectedTestId), `v0.94 ${tab} tab`).toBeVisible();
      await expect(page.getByTestId(expectedTestId).locator(".campaign-summary-card").first()).toBeVisible();
      await expectNoHorizontalOverflow(page, `v0.94 ${tab} tab`);
    }

    await openFreshMainMenu(page);
    await showLayoutResults(page, "victory");
    await expect(page.getByTestId("results-full-details")).not.toHaveAttribute("open", "");
    await expectActionAboveFold(page, page.locator(".results-primary-actions"), "v0.94 compact Results actions");
    await page.getByText("Show Full Battle Details", { exact: true }).click();
    await expect(page.getByTestId("results-full-details")).toHaveAttribute("open", "");
    await expect(page.getByTestId("results-detail-accordion")).toBeVisible();
    await expect(page.locator(".results-detail-group summary")).toContainText(["Battle Metrics And Hero XP", "Veterans And Retinue"]);
    await expectNoHorizontalOverflow(page, "v0.94 expanded Results details");
  });

  test("v0.90 Results primary actions and disclosure remain above the fold @hosted-layout-core", async ({ page }) => {
    test.setTimeout(HOSTED_LAYOUT_CORE_TIMEOUT_MS);
    for (const [viewport, outcome, wasReplay, expectedText] of [
      [{ width: 1600, height: 900, label: "wide victory" }, "victory", false, "Next mission unlocked"],
      [{ width: 1366, height: 768, label: "laptop defeat" }, "defeat", false, "No victory rewards saved"],
      [{ width: 1600, height: 900, label: "wide replay" }, "victory", true, "Replay"]
    ] as const) {
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await openFreshMainMenu(page);
      await showLayoutResults(page, outcome, wasReplay);
      await expect(page.locator(".results-panel")).toContainText(expectedText);
      await expect(page.getByTestId("results-overview")).toBeVisible();
      await expect(page.getByTestId("results-full-details")).not.toHaveAttribute("open", "");
      await expectActionAboveFold(page, page.locator(".results-primary-actions"), `${viewport.label} results actions`);
      await expectNoHorizontalOverflow(page, `${viewport.label} results`);
      await expectNoTextOverflowForSelectors(
        page,
        [".results-overview", ".results-primary-actions", ".results-full-details"],
        `${viewport.label} results`
      );
    }
  });

  test("v0.90 private-demo Results disclosure and ordinary-battle control posture stay isolated @hosted-layout-core", async ({ page }) => {
    test.setTimeout(HOSTED_LAYOUT_CORE_TIMEOUT_MS);
    await page.setViewportSize({ width: 1366, height: 768 });
    await startNewCampaign(page, "Layout v090 Private Demo");
    await clickReady(page.getByTestId("campaign-start-node"), "layout v090 ordinary battle start", UI_TRANSITION_CLICK_OPTIONS);
    await expectBattleLoaded(page, "layout v090 ordinary battle");
    await expect(page.getByTestId("private-demo-actions")).toHaveCount(0);
    await expect(page.getByTestId("private-demo-finish")).toHaveCount(0);
    await expect(page.getByTestId("lume-visibility-controls")).toHaveCount(0);

    await openFreshMainMenu(page);
    await startNewCampaign(page, "Layout v090 Lume Demo");
    await clickReady(page.getByTestId("campaign-node-aether_well_ruins"), "layout v090 Aether Well preview", UI_TRANSITION_CLICK_OPTIONS);
    const privateToolsEnabled = await page.evaluate(
      () =>
        Boolean(window.__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__) ||
        Boolean(document.querySelector("script[src*='@vite/client']"))
    );
    await expect(page.getByTestId("campaign-private-lume-demo")).toHaveCount(privateToolsEnabled ? 1 : 0);
    await page.evaluate(() => {
      const game = window.ascendantRealmsGame;
      if (!game) {
        throw new Error("Ascendant Realms game was not booted.");
      }
      const battleScene = game.scene.getScene("BattleScene");
      if (battleScene?.scene.isActive()) {
        game.scene.stop("BattleScene");
      }
      const heroSave = {
        heroName: "Layout v090 Lume Demo",
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
        factionReputation: { free_marches: 0, ashen_covenant: 0, sylvan_concord: 0, common_folk: 0, old_faith: 0 },
        stats: { might: 8, command: 8, arcana: 2, faith: 3 }
      };
      game.scene.start("ResultsScene", {
        heroSave,
        startingHeroSave: heroSave,
        launchRequest: {
          requestId: "layout-v090-private-demo-results",
          mode: "campaign_node",
          mapId: "broken_ford",
          heroSave,
          sourceId: "layout",
          rewardTableId: "none",
          difficulty: "normal",
          modifiers: [],
          rewardsDisabled: true,
          enemyProfileId: "ashen_covenant",
          aiPersonalityId: "hexfire_cult",
          campaignNodeId: "aether_well_ruins",
          privatePlaytestDemoId: "aether_well_lume_private_demo",
          privatePlaytestNotice: "Private playtest demo only."
        },
        stats: {
          outcome: "victory",
          unitsKilled: 7,
          buildingsDestroyed: 0,
          resourcesCaptured: 2,
          firstSiteCaptured: "West Stone Cut",
          buildingsBuilt: 1,
          builtBuildingIds: ["barracks"],
          unitsTrained: 4,
          trainedUnitIds: ["militia", "ranger"],
          enemyWavesSurvived: 1,
          xpGained: 0,
          timeSeconds: 184,
          completedObjectiveIds: ["lume_network_awakened"],
          lumeNetworkId: "aether_well_ruins_lume_ward",
          lumeLinkActivatedIds: ["west_stone_cut_to_ford_toll"],
          lumeObjectiveCompleted: true
        }
      });
    });
    await expect(page.getByTestId("private-demo-lume-summary")).toContainText("LUME NETWORK SUMMARY");
    await expect(page.getByTestId("private-demo-full-details")).not.toHaveAttribute("open", "");
    await expectActionAboveFold(page, page.getByTestId("private-demo-primary-actions"), "private demo results primary actions");
    await page.getByTestId("private-demo-full-details").locator("summary").click();
    await expect(page.getByTestId("private-demo-full-details")).toHaveAttribute("open", "");
    await expectNoHorizontalOverflow(page, "private demo expanded results");
  });

  for (const viewport of LAYOUT_VIEWPORTS) {
    test(`menu and hero creation fit or scroll on ${viewport.label} @hosted-layout-core`, async ({ page }) => {
      test.setTimeout(HOSTED_LAYOUT_CORE_TIMEOUT_MS);
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await openFreshMainMenu(page);
      await expectNoHorizontalOverflow(page, `${viewport.label} main menu`);
      await expectBottomActionReachable(page, page.getByText("Credits / Info"), `${viewport.label} main menu bottom action`);

      await clickReady(
        page.getByTestId("menu-skirmish"),
        `${viewport.label} skirmish menu from main menu`,
        UI_TRANSITION_CLICK_OPTIONS
      );
      await expect(page.getByTestId("hero-creation")).toBeVisible();
      await expectNoHorizontalOverflow(page, `${viewport.label} hero creation`);
      await expectBottomActionReachable(page, page.getByTestId("hero-start"), `${viewport.label} hero creation start`);
    });

    test(`campaign, setup, inventory, and asset gallery remain reachable on ${viewport.label} @hosted-layout-core`, async ({ page }) => {
      test.setTimeout(HOSTED_LAYOUT_CORE_TIMEOUT_MS);
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await seedCampaignSave(page, { hero: { heroName: `Layout ${viewport.label}` } });
      await continueSavedCampaign(page);
      await expectNoHorizontalOverflow(page, `${viewport.label} campaign map`);
      await expectBottomActionReachable(page, page.getByTestId("campaign-main-menu"), `${viewport.label} campaign actions`);

      await clickReady(page.getByTestId("campaign-main-menu"), `${viewport.label} campaign main menu`);
      await clickReady(
        page.getByTestId("menu-skirmish"),
        `${viewport.label} skirmish menu from campaign return`,
        UI_TRANSITION_CLICK_OPTIONS
      );
      await expect(page.getByTestId("skirmish-setup")).toBeVisible();
      await expectNoHorizontalOverflow(page, `${viewport.label} skirmish setup`);
      await expectBottomActionReachable(page, page.getByTestId("setup-start-battle"), `${viewport.label} setup start`);

      await clickReady(page.getByTestId("setup-back"), `${viewport.label} setup back`, UI_TRANSITION_CLICK_OPTIONS);
      await clickReady(page.getByTestId("menu-inventory"), `${viewport.label} inventory menu`, UI_TRANSITION_CLICK_OPTIONS);
      await expect(page.getByTestId("hero-inventory")).toBeVisible();
      await expectNoHorizontalOverflow(page, `${viewport.label} inventory`);
      await expectBottomActionReachable(page, page.getByText("Main Menu"), `${viewport.label} inventory bottom action`);

      await clickReady(page.getByText("Main Menu"), `${viewport.label} inventory main menu`, UI_TRANSITION_CLICK_OPTIONS);
      await clickReady(
        page.getByTestId("menu-asset-gallery"),
        `${viewport.label} asset gallery menu`,
        UI_TRANSITION_CLICK_OPTIONS
      );
      await expect(page.getByText("Asset Gallery")).toBeVisible();
      await expectNoHorizontalOverflow(page, `${viewport.label} asset gallery`);
      await expectInViewport(page, page.getByRole("button", { name: "Back" }), `${viewport.label} asset gallery back`);
    });

    test(`tutorial entry and first objective overlay stay readable on ${viewport.label} @hosted-layout-core`, async ({ page }) => {
      test.setTimeout(HOSTED_LAYOUT_CORE_TIMEOUT_MS);
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await launchTutorialOverlay(page, viewport.label);
      await expect(page.getByTestId("tutorial-objective")).toContainText("Find Your Army");
      await expect(page.getByTestId("tutorial-instruction")).toContainText("Pan with WASD or arrow keys");
      await expect(page.getByTestId("tutorial-progress")).toContainText("Step 1 of 12: complete");
      await expectNoHorizontalOverflow(page, `${viewport.label} tutorial overlay`);
      await expectInViewport(page, page.getByTestId("tutorial-overlay"), `${viewport.label} tutorial overlay`);
      await expectTutorialOverlayHasFeedbackPriority(page, `${viewport.label} tutorial overlay`);
      const overlayBox = await waitForLayoutBox(page, page.getByTestId("tutorial-overlay"));
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
    test(`battle HUD layout stays inside the viewport on ${viewport.label} @hosted-layout-core`, async ({ page }) => {
      test.setTimeout(HOSTED_LAYOUT_CORE_TIMEOUT_MS);
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await seedCampaignSave(page, { hero: { heroName: `Layout Battle ${viewport.label}` } });
      await continueSavedCampaign(page);
      await clickReady(page.getByTestId("campaign-node-border_village"), `${viewport.label} Salto Outskirts node`);
      await clickReady(
        page.getByTestId("campaign-start-node"),
        `${viewport.label} Salto Outskirts start`,
        UI_TRANSITION_CLICK_OPTIONS
      );
      await expectBattleLoaded(page, `${viewport.label} Salto Outskirts battle`);
      await expectNoHorizontalOverflow(page, `${viewport.label} battle hud`);
      await expectInViewport(page, page.getByTestId("battle-hero-panel"), `${viewport.label} hero panel`);
      await expectInViewport(page, page.getByTestId("battle-minimap"), `${viewport.label} minimap`);
      await selectBattleBuilding(page, "command_hall", "Command Hall");
      await expectNoHorizontalOverflow(page, `${viewport.label} command hall commands`);
      await expectBattleCommandButtonsReachable(page, ["train"], `${viewport.label} command hall`);
      await createCompletedBarracksAndSelect(page);
      await expectNoHorizontalOverflow(page, `${viewport.label} barracks commands`);
      await expectBattleCommandButtonsReachable(page, ["train", "upgrade"], `${viewport.label} barracks`);
    });

    test(`results layout stays inside the viewport on ${viewport.label} @hosted-layout-core`, async ({ page }) => {
      test.setTimeout(HOSTED_LAYOUT_CORE_TIMEOUT_MS);
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await openFreshMainMenu(page);
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
    test(`v0.3 Cinderfen menu and campaign readability fit ${viewport.label} @hosted-layout-cinderfen`, async ({ page }) => {
      // GitHub-hosted release shard evidence and local full-release reproduction show this seeded
      // Cinderfen layout pass can spend extra time recovering from app-root setup navigation retries.
      test.setTimeout(120_000);
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
      await expect(page.getByTestId("campaign-chapter-border_marches")).toContainText("Chapter 1: The Barrosan Marches");
      await expect(page.getByTestId("campaign-chapter-cinderfen_road")).toContainText("Chapter 2: Cinderfen Road");
      await expect(page.getByTestId("campaign-node-border_village")).toContainText(/Completed/i);
      await expect(page.getByTestId("campaign-node-cinderfen_overlook")).toContainText(/Available/i);
      await expectCampaignSupportPanelsReadable(page, `${viewport.label} campaign map`);

      await clickReady(page.getByTestId("campaign-node-cinderfen_overlook"), `${viewport.label} Cinderfen Overlook node`);
      await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Overlook");
      await expect(page.locator(".campaign-node-details")).toContainText("Aid the Marsh Refugees");
      await expect(page.locator(".campaign-node-details")).toContainText("Study the Cinders");
      await expect(page.locator(".campaign-node-details")).toContainText("Raise Malrec's Standard");
      const standardChoice = page.locator("button[data-campaign-choice='raise_malrecs_standard']");
      await expect(standardChoice).toContainText("Cost: None");
      await expect(standardChoice).toContainText("Rewards: 10 XP");
      await expect(standardChoice).toContainText("Reputation: +3 Barrosan Freeholds");
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

      await clickReady(page.getByTestId("campaign-node-cinderfen_crossing"), `${viewport.label} Cinderfen Crossing node`);
      await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Crossing");
      await expect(page.locator(".campaign-node-details")).toContainText("Scout's Bow");
      await expectReachableButton(page, page.getByTestId("campaign-start-node"), `${viewport.label} Crossing start`);

      await seedCompletedCinderfenRouteCampaign(page);
      await continueSavedCampaign(page);
      await expectNoHorizontalOverflow(page, `${viewport.label} completed Cinderfen campaign map`);
      await expect(page.getByTestId("campaign-node-cinderfen_aftermath")).toContainText(/Completed/i);
      await clickReady(page.getByTestId("campaign-tab-hero"), `${viewport.label} completed route hero tab`, UI_TRANSITION_CLICK_OPTIONS);
      await expect(page.locator(".guidance-card").filter({ hasText: "Cinderfen route secured" })).toContainText(
        "Chapter 2 route complete"
      );
      await expect(page.locator(".guidance-card").filter({ hasText: "Cinderfen route secured" })).toContainText(
        "future Cinderfen roads"
      );
      await clickReady(page.getByTestId("campaign-tab-map"), `${viewport.label} completed route map tab`, UI_TRANSITION_CLICK_OPTIONS);
      await clickReady(page.getByTestId("campaign-node-cinderfen_aftermath"), `${viewport.label} Cinderfen Aftermath node`);
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
    test(`Cinderfen Crossing battle HUD readability fits ${viewport.label} @hosted-layout-cinderfen`, async ({ page }) => {
      test.setTimeout(HOSTED_CINDERFEN_BATTLE_TIMEOUT_MS);
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await seedPostAshenCampaign(page);
      await continueSavedCampaign(page);
      await clickReady(page.getByTestId("campaign-node-cinderfen_overlook"), `${viewport.label} reset Cinderfen Overlook node`);
      await completeCinderfenOverlookChoice(page, "aid_marsh_refugees", "Aid the Marsh Refugees chosen");
      await launchCinderfenCrossing(page);
      await expectCinderfenBattleHudReadable(page, `${viewport.label} Crossing`, {
        mapName: "Cinderfen Crossing",
        objectiveTexts: ["Claim the Cinder Shrine", "one-time +20 Aether surge", "Clear Cinder Guardians", "Destroy Enemy Barracks"]
      });
    });

    test(`Cinderfen Watch battle HUD and results readability fit ${viewport.label} @hosted-layout-cinderfen`, async ({ page }) => {
      test.setTimeout(HOSTED_CINDERFEN_BATTLE_TIMEOUT_MS);
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await seedPostCinderfenCrossingCampaign(page);
      await continueSavedCampaign(page);
      await launchCinderfenWatch(page);
      await expectCinderfenBattleHudReadable(page, `${viewport.label} Watch`, {
        mapName: "Cinderfen Watch",
        objectiveTexts: ["Capture the Watch Road", "Clear the Marsh Raider Camp", "Destroy the Watchpost Tower"]
      });

      if (viewport.label === "mobile portrait") {
        await completeCinderfenWatchVictory(page);
        const resultsPanel = page.locator(".results-panel");
        await expect(resultsPanel).toContainText("Victory");
        await expect(resultsPanel).toContainText("Cinderfen Watch");
        await expect(resultsPanel).toContainText("Reward XP");
        await expect(page.locator(".campaign-reward-block")).toContainText("Cinderfen Aftermath");
        await page.getByText("Show Full Battle Details", { exact: true }).click();
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

  test("Ashen Outpost objectives do not cover the fortress focus area on desktop @hosted-layout-cinderfen", async ({ page }) => {
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

  test("Ashen Outpost landmarks are scoutable under fog without HUD overlap @hosted-layout-cinderfen", async ({ page }) => {
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
