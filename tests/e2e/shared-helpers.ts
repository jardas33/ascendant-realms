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

const EMPTY_RESOURCES: CampaignResources = {
  crowns: 0,
  stone: 0,
  iron: 0,
  aether: 0
};

const MAIN_MENU_BOOT_TIMEOUT_MS = 20_000;
const MAIN_MENU_NAVIGATION_TIMEOUT_MS = 15_000;
const MAIN_MENU_NAVIGATION_ATTEMPTS = 3;
const MAIN_MENU_READY_PROBE_TIMEOUT_MS = 5_000;
const MAIN_MENU_FINAL_READY_TIMEOUT_MS = 10_000;
const CLICK_READY_TIMEOUT_MS = 10_000;
const CLICK_READY_ATTEMPTS = 2;
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
    message.includes("intercepts pointer events") ||
    message.includes("frame was detached") ||
    message.includes("Frame was detached")
  );
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

export async function clickReady(locator: Locator, context: string): Promise<void> {
  let lastError: unknown;
  let attemptsUsed = 0;

  for (let attempt = 1; attempt <= CLICK_READY_ATTEMPTS; attempt += 1) {
    attemptsUsed = attempt;
    try {
      await expect(locator, `${context}: expected target to be visible`).toBeVisible({
        timeout: CLICK_READY_TIMEOUT_MS
      });
      await expect(locator, `${context}: expected target to be enabled`).toBeEnabled({
        timeout: CLICK_READY_TIMEOUT_MS
      });
      await locator.scrollIntoViewIfNeeded({ timeout: 5_000 }).catch(() => undefined);
      await locator.click({ timeout: CLICK_READY_TIMEOUT_MS });
      return;
    } catch (error) {
      lastError = error;
      if (!isTransientClickError(error) || attempt === CLICK_READY_ATTEMPTS) {
        break;
      }

      console.warn(
        `${context}: retrying click actionability attempt ${attempt + 1}/${CLICK_READY_ATTEMPTS} after transient error: ${describeNavigationError(error)}`
      );
      await locator.waitFor({ state: "visible", timeout: 1_000 }).catch(() => undefined);
    }
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
  await page.getByTestId("hero-start").click();
}

export async function startNewCampaign(page: Page, heroName: string): Promise<void> {
  await openFreshMainMenu(page);
  await page.getByTestId("menu-new-campaign").click();
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
  await clickReady(page.getByTestId("menu-continue-campaign"), "continue saved campaign");
  await expect(page.getByTestId("campaign-map")).toBeVisible();
}
