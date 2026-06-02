import { expect, type Locator, type Page } from "@playwright/test";

export const SAVE_KEY = "ascendant-realms-save-v1";

type CampaignResources = {
  crowns: number;
  stone: number;
  iron: number;
  aether: number;
};

type SeedCampaignOptions = {
  hero?: Record<string, unknown>;
  campaign?: Record<string, unknown>;
  settings?: Record<string, unknown>;
  statistics?: Record<string, unknown>;
};

type ClickReadyOptions = {
  allowDomFallback?: boolean;
  allowTargetDisabledAfterClick?: boolean;
  allowTargetGoneAfterClick?: boolean;
  attempts?: number;
  domFallbackTimeoutMs?: number;
  normalClickTimeoutMs?: number;
  successCheckAfterClick?: () => Promise<boolean>;
  timeoutMs?: number;
  waitForLayoutBox?: boolean;
};

const EMPTY_RESOURCES: CampaignResources = {
  crowns: 0,
  stone: 0,
  iron: 0,
  aether: 0
};

// Cold dev-server release runs can spend most of the first boot preloading battle textures before the menu mounts.
const MAIN_MENU_BOOT_TIMEOUT_MS = 45_000;
const MAIN_MENU_NAVIGATION_TIMEOUT_MS = 15_000;
const MAIN_MENU_NAVIGATION_ATTEMPTS = 3;
const MAIN_MENU_READY_PROBE_TIMEOUT_MS = 5_000;
const MAIN_MENU_FINAL_READY_TIMEOUT_MS = 10_000;
const CLICK_READY_TIMEOUT_MS = 10_000;
const CLICK_READY_NORMAL_CLICK_TIMEOUT_MS = 2_000;
const CLICK_READY_DOM_FALLBACK_TIMEOUT_MS = 2_000;
const CLICK_READY_ATTEMPTS = 2;
const CLICK_READY_LAYOUT_BOX_ATTEMPTS = 20;
const STORAGE_SEED_WINDOW_NAME_PREFIX = "__ASCENDANT_REALMS_E2E_SAVE_SEED__:";

const BASE_HERO = {
  heroName: "E2E Seed",
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

function describeNavigationError(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

function isTransientAppNavigationError(error: unknown): boolean {
  const message = describeNavigationError(error);
  return (
    message.includes("net::ERR_ABORTED") ||
    message.includes("net::ERR_NO_BUFFER_SPACE") ||
    message.includes("interrupted by another navigation") ||
    message.includes("Timeout") ||
    message.includes("timeout") ||
    message.includes("frame was detached") ||
    message.includes("Frame was detached")
  );
}

function isTransientClickError(error: unknown): boolean {
  const message = describeNavigationError(error);
  return (
    message.includes("Timeout") ||
    message.includes("timeout") ||
    message.includes("not stable") ||
    message.includes("Element is not stable") ||
    message.includes("layout box") ||
    message.includes("intercepts pointer events") ||
    message.includes("frame was detached") ||
    message.includes("Frame was detached")
  );
}

async function waitForLocatorLayoutBox(
  locator: Locator,
  context: string,
  timeoutMs = CLICK_READY_TIMEOUT_MS
): Promise<void> {
  const startedAt = Date.now();
  let box = await locator.boundingBox().catch(() => null);
  for (let attempt = 1; !box && attempt <= CLICK_READY_LAYOUT_BOX_ATTEMPTS && Date.now() - startedAt < timeoutMs; attempt += 1) {
    await locator.page().waitForTimeout(100);
    box = await locator.boundingBox().catch(() => null);
  }
  if (!box) {
    throw new Error(`${context}: target did not produce a layout box before click`);
  }
}

type DomClickVerification = {
  ok: boolean;
  reason: string;
  tag: string;
  text: string;
  width: number;
  height: number;
};

function isRetryableDomClickVerification(verification: DomClickVerification): boolean {
  return (
    verification.reason === "no matched elements" ||
    verification.reason === "not visibly laid out" ||
    verification.reason.startsWith("center covered by")
  );
}

async function isLocatorTargetDisabled(locator: Locator): Promise<boolean> {
  return locator
    .evaluateAll((elements) =>
      elements.some((element) => {
        const control = element.closest?.("button,a,input,select,textarea,[role='button']");
        if (!control) {
          return false;
        }

        const disabled =
          (control instanceof HTMLButtonElement ||
            control instanceof HTMLInputElement ||
            control instanceof HTMLSelectElement ||
            control instanceof HTMLTextAreaElement) &&
          control.disabled;
        return disabled || control.getAttribute("aria-disabled") === "true";
      })
    )
    .catch(() => false);
}

async function didClickAlreadySucceed(successCheckAfterClick: (() => Promise<boolean>) | undefined): Promise<boolean> {
  if (!successCheckAfterClick) {
    return false;
  }

  return successCheckAfterClick().catch(() => false);
}

async function verifiedDomClick(
  locator: Locator,
  context: string,
  timeoutMs = CLICK_READY_TIMEOUT_MS
): Promise<void> {
  const startedAt = Date.now();
  let lastError: unknown;
  let lastVerification: DomClickVerification | undefined;

  for (let attempt = 1; attempt <= CLICK_READY_LAYOUT_BOX_ATTEMPTS && Date.now() - startedAt < timeoutMs; attempt += 1) {
    try {
      const verification = await locator.evaluateAll((elements): DomClickVerification => {
        let firstFailure: DomClickVerification | undefined;

        for (const element of elements) {
          const control = element as HTMLElement;
          const style = window.getComputedStyle(control);
          const rect = control.getBoundingClientRect();
          const tag = control.tagName.toLowerCase();
          const role = control.getAttribute("role") ?? "";
          const isControl =
            tag === "button" ||
            tag === "a" ||
            tag === "input" ||
            tag === "select" ||
            tag === "textarea" ||
            role === "button";
          const disabled =
            (control instanceof HTMLButtonElement ||
              control instanceof HTMLInputElement ||
              control instanceof HTMLSelectElement ||
              control instanceof HTMLTextAreaElement) &&
            control.disabled;
          const ariaDisabled = control.getAttribute("aria-disabled") === "true";
          const visible =
            style.display !== "none" &&
            style.visibility !== "hidden" &&
            Number(style.opacity || "1") > 0 &&
            rect.width > 0 &&
            rect.height > 0;
          const text = (control.textContent ?? control.getAttribute("aria-label") ?? "")
            .trim()
            .replace(/\s+/g, " ")
            .slice(0, 80);

          const failure = (reason: string): DomClickVerification => ({
            ok: false,
            reason,
            tag,
            text,
            width: rect.width,
            height: rect.height
          });

          if (!isControl) {
            firstFailure ??= failure(`not a DOM control (${tag})`);
            continue;
          }
          if (!visible) {
            firstFailure ??= failure("not visibly laid out");
            continue;
          }
          if (disabled || ariaDisabled) {
            firstFailure ??= failure("disabled");
            continue;
          }

          const centerX = rect.left + rect.width / 2;
          const centerY = rect.top + rect.height / 2;
          const hit = document.elementFromPoint(centerX, centerY);
          const hitControl = hit?.closest?.("button,a,input,select,textarea,[role='button']");
          const covered = Boolean(hit && hit !== control && !control.contains(hit) && hitControl !== control);
          if (covered) {
            const blocker = hit instanceof HTMLElement
              ? `${hit.tagName.toLowerCase()} ${hit.getAttribute("data-testid") ?? hit.className ?? ""}`.trim()
              : "unknown element";
            firstFailure ??= failure(`center covered by ${blocker}`);
            continue;
          }

          control.click();
          return {
            ok: true,
            reason: "verified",
            tag,
            text,
            width: rect.width,
            height: rect.height
          };
        }

        return firstFailure ?? { ok: false, reason: "no matched elements", tag: "", text: "", width: 0, height: 0 };
      });
      lastVerification = verification;

      if (verification.ok) {
        console.warn(
          `${context}: normal click failed; using verified DOM click fallback on ${verification.tag} ${Math.round(
            verification.width
          )}x${Math.round(verification.height)} "${verification.text}"`
        );
        return;
      }

      if (!isRetryableDomClickVerification(verification)) {
        break;
      }
    } catch (error) {
      lastError = error;
      if (!isTransientClickError(error)) {
        break;
      }
    }

    await locator.page().waitForTimeout(100);
  }

  if (lastVerification) {
    throw new Error(`${context}: DOM click fallback refused: ${lastVerification.reason}`);
  }
  throw new Error(`${context}: DOM click fallback failed: ${describeNavigationError(lastError)}`);
}

async function isMainMenuReady(page: Page, timeout = MAIN_MENU_READY_PROBE_TIMEOUT_MS): Promise<boolean> {
  const mainMenuReady = await page
    .getByTestId("main-menu")
    .waitFor({ state: "visible", timeout })
    .then(() => true)
    .catch(() => false);
  if (!mainMenuReady) {
    return false;
  }

  return page
    .getByTestId("menu-new-campaign")
    .waitFor({ state: "visible", timeout })
    .then(() => true)
    .catch(() => false);
}

async function gotoAppRootWithRetry(page: Page, context: string): Promise<void> {
  let lastError: unknown;
  let attemptsUsed = 0;

  for (let attempt = 1; attempt <= MAIN_MENU_NAVIGATION_ATTEMPTS; attempt += 1) {
    attemptsUsed = attempt;
    try {
      await page.goto("/", {
        waitUntil: "commit",
        timeout: MAIN_MENU_NAVIGATION_TIMEOUT_MS
      });
      return;
    } catch (error) {
      lastError = error;
      if (await isMainMenuReady(page)) {
        return;
      }

      if (!isTransientAppNavigationError(error) || attempt === MAIN_MENU_NAVIGATION_ATTEMPTS) {
        break;
      }

      // Hosted visual/layout runs have shown transient app-root navigation aborts/timeouts while a frame is being replaced.
      // Only those setup-navigation aborts are retried; the app still must render the real main menu below.
      console.warn(
        `${context}: retrying app boot navigation attempt ${attempt + 1}/${MAIN_MENU_NAVIGATION_ATTEMPTS} after transient error: ${describeNavigationError(error)}`
      );
      await page.waitForLoadState("domcontentloaded", { timeout: 2_000 }).catch(() => undefined);
    }
  }

  if (lastError && isTransientAppNavigationError(lastError)) {
    console.warn(
      `${context}: checking real main menu after final transient app boot navigation error: ${describeNavigationError(lastError)}`
    );
    if (await isMainMenuReady(page, MAIN_MENU_FINAL_READY_TIMEOUT_MS)) {
      return;
    }
  }

  throw new Error(
    `${context}: app root navigation failed after ${attemptsUsed} attempt(s): ${describeNavigationError(lastError)}`
  );
}

export async function gotoReadyMainMenu(page: Page, context: string): Promise<void> {
  await gotoAppRootWithRetry(page, context);
  await expect(
    page.getByTestId("main-menu"),
    `${context}: expected main menu after app boot`
  ).toBeVisible({ timeout: MAIN_MENU_BOOT_TIMEOUT_MS });
  await expect(
    page.getByTestId("menu-new-campaign"),
    `${context}: expected main menu actions after app boot`
  ).toBeVisible({ timeout: MAIN_MENU_BOOT_TIMEOUT_MS });
}

export async function expectBattleLoaded(
  page: Page,
  context = "battle loaded",
  options: { timeoutMs?: number } = {}
): Promise<void> {
  const timeoutMs = options.timeoutMs ?? 30_000;
  await expect(page.getByTestId("battle-hud"), `${context}: battle HUD`).toBeVisible({ timeout: timeoutMs });
  await expect(page.getByTestId("battle-resources"), `${context}: resources`).toContainText("Crowns", {
    timeout: timeoutMs
  });
  await expect(page.getByTestId("battle-hero-panel"), `${context}: hero panel`).toBeVisible({ timeout: timeoutMs });
  await expect(page.getByTestId("battle-minimap"), `${context}: minimap shell`).toBeVisible({ timeout: timeoutMs });
  await expect(page.getByTestId("minimap"), `${context}: minimap`).toBeVisible({ timeout: timeoutMs });
  await expect(page.locator("canvas"), `${context}: Phaser canvas`).toBeVisible({ timeout: timeoutMs });
  await page.waitForFunction(
    () => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      return Boolean(scene?.scene.isActive() && scene.hero && scene.activeMap && scene.runtime && scene.game?.canvas);
    },
    undefined,
    { timeout: timeoutMs }
  );
}

export async function clickReady(locator: Locator, context: string, options: ClickReadyOptions = {}): Promise<void> {
  const timeoutMs = options.timeoutMs ?? CLICK_READY_TIMEOUT_MS;
  const domFallbackTimeoutMs = options.domFallbackTimeoutMs ?? CLICK_READY_DOM_FALLBACK_TIMEOUT_MS;
  const normalClickTimeoutMs = options.normalClickTimeoutMs ?? CLICK_READY_NORMAL_CLICK_TIMEOUT_MS;
  const attempts = options.attempts ?? CLICK_READY_ATTEMPTS;
  const waitForLayoutBox = options.waitForLayoutBox ?? true;
  const allowDomFallback = options.allowDomFallback ?? true;
  const allowTargetDisabledAfterClick = options.allowTargetDisabledAfterClick ?? false;
  const allowTargetGoneAfterClick = options.allowTargetGoneAfterClick ?? false;
  const successCheckAfterClick = options.successCheckAfterClick;
  let lastError: unknown;
  let attemptsUsed = 0;
  let attemptedNormalClick = false;

  for (let attempt = 1; attempt <= attempts; attempt += 1) {
    attemptsUsed = attempt;
    try {
      await locator.waitFor({ state: "attached", timeout: timeoutMs });
      await expect(locator, `${context}: expected target to be visible`).toBeVisible({
        timeout: timeoutMs
      });
      await expect(locator, `${context}: expected target to be enabled`).toBeEnabled({
        timeout: timeoutMs
      });
      if (waitForLayoutBox) {
        await locator.scrollIntoViewIfNeeded({ timeout: 5_000 }).catch(() => undefined);
        await waitForLocatorLayoutBox(locator, context, timeoutMs);
      }
      attemptedNormalClick = true;
      await locator.click({ timeout: normalClickTimeoutMs });
      return;
    } catch (error) {
      lastError = error;
      if (
        attemptedNormalClick &&
        isTransientClickError(error) &&
        (await didClickAlreadySucceed(successCheckAfterClick))
      ) {
        console.warn(`${context}: follow-up state appeared after normal click; skipping retry/fallback`);
        return;
      }

      if (!isTransientClickError(error) || attempt === attempts) {
        break;
      }

      console.warn(
        `${context}: retrying click actionability attempt ${attempt + 1}/${attempts} after transient error: ${describeNavigationError(error)}`
      );
      await locator.waitFor({ state: "visible", timeout: 1_000 }).catch(() => undefined);
    }
  }

  if (allowTargetGoneAfterClick && lastError && isTransientClickError(lastError)) {
    const remainingTargets = await locator.count().catch(() => 0);
    if (remainingTargets === 0) {
      console.warn(`${context}: target disappeared after normal click; relying on follow-up assertions`);
      return;
    }
  }

  if (allowTargetDisabledAfterClick && attemptedNormalClick && lastError && isTransientClickError(lastError)) {
    if (await isLocatorTargetDisabled(locator)) {
      console.warn(`${context}: target disabled after normal click; relying on follow-up assertions`);
      return;
    }
  }

  if (
    attemptedNormalClick &&
    lastError &&
    isTransientClickError(lastError) &&
    (await didClickAlreadySucceed(successCheckAfterClick))
  ) {
    console.warn(`${context}: follow-up state appeared after normal click; skipping fallback`);
    return;
  }

  if (allowDomFallback && lastError && isTransientClickError(lastError)) {
    await verifiedDomClick(locator, context, domFallbackTimeoutMs);
    return;
  }

  throw new Error(`${context}: click failed after ${attemptsUsed} attempt(s): ${describeNavigationError(lastError)}`);
}

export async function seedSaveBeforeAppBoot(
  page: Page,
  context: string,
  save: Record<string, unknown>,
  options: { clearStorage?: boolean } = {}
): Promise<void> {
  await page.addInitScript(
    ({ prefix }) => {
      if (!window.name.startsWith(prefix)) {
        return;
      }
      const rawPayload = window.name.slice(prefix.length);
      window.name = "";
      const payload = JSON.parse(rawPayload) as { key: string; value: unknown; clearStorage: boolean };
      if (payload.clearStorage) {
        localStorage.clear();
      }
      localStorage.setItem(payload.key, JSON.stringify(payload.value));
    },
    { prefix: STORAGE_SEED_WINDOW_NAME_PREFIX }
  );
  await page.evaluate(
    ({ prefix, key, value, clearStorage }) => {
      window.name = `${prefix}${JSON.stringify({ key, value, clearStorage })}`;
    },
    {
      prefix: STORAGE_SEED_WINDOW_NAME_PREFIX,
      key: SAVE_KEY,
      value: save,
      clearStorage: options.clearStorage === true
    }
  );
  await gotoReadyMainMenu(page, `${context} storage seed boot`);
}

export async function openMainMenuForStorageSeed(page: Page, context: string): Promise<void> {
  await gotoReadyMainMenu(page, `${context} storage seed setup`);
}

export async function openMainMenuAfterStorageSeed(page: Page, context: string): Promise<void> {
  await gotoReadyMainMenu(page, `${context} storage seed reload`);
  await expect(
    page.getByTestId("menu-continue-campaign"),
    `${context}: expected seeded campaign save to enable Continue Campaign`
  ).toBeEnabled({ timeout: MAIN_MENU_BOOT_TIMEOUT_MS });
}

export async function openFreshMainMenu(page: Page): Promise<void> {
  await gotoReadyMainMenu(page, "fresh main menu before storage reset");
  await page.evaluate(() => localStorage.clear());
  await gotoReadyMainMenu(page, "fresh main menu after storage reset");
}

export async function createHero(page: Page, name: string): Promise<void> {
  await expect(page.getByTestId("hero-creation")).toBeVisible();
  await page.getByTestId("hero-name-input").fill(name);
  await clickReady(page.getByTestId("hero-start"), `create hero ${name}`);
}

export async function startNewCampaign(page: Page, heroName: string): Promise<void> {
  await openFreshMainMenu(page);
  await clickReady(page.getByTestId("menu-new-campaign"), "start new campaign");
  await createHero(page, heroName);
  await expect(page.getByTestId("campaign-map")).toBeVisible();
}

export async function seedCampaignSave(page: Page, options: SeedCampaignOptions = {}): Promise<void> {
  const save = {
    version: 2,
    createdAt: "2026-05-06T00:00:00.000Z",
    updatedAt: "2026-05-06T00:00:00.000Z",
    hero: {
      ...BASE_HERO,
      ...options.hero
    },
    campaign: {
      ...BASE_CAMPAIGN,
      ...options.campaign
    },
    settings: {
      ...options.settings
    },
    statistics: {
      ...options.statistics
    }
  };

  await seedSaveBeforeAppBoot(page, "seedCampaignSave", save, { clearStorage: true });
  await expect(
    page.getByTestId("menu-continue-campaign"),
    "seedCampaignSave: expected seeded campaign save to enable Continue Campaign"
  ).toBeEnabled({ timeout: MAIN_MENU_BOOT_TIMEOUT_MS });
}

export async function continueSavedCampaign(page: Page): Promise<void> {
  await clickReady(page.getByTestId("menu-continue-campaign"), "continue saved campaign", {
    allowTargetGoneAfterClick: true,
    successCheckAfterClick: async () => (await page.getByTestId("campaign-map").count()) > 0
  });
  await expect(page.getByTestId("campaign-map")).toBeVisible();
}
