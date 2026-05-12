import { expect, type Page } from "@playwright/test";

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

async function gotoReadyMainMenu(page: Page, context: string): Promise<void> {
  await page.goto("/", { waitUntil: "domcontentloaded" });
  await expect(
    page.getByTestId("main-menu"),
    `${context}: expected main menu after app boot`
  ).toBeVisible({ timeout: MAIN_MENU_BOOT_TIMEOUT_MS });
  await expect(
    page.getByTestId("menu-new-campaign"),
    `${context}: expected main menu actions after app boot`
  ).toBeVisible({ timeout: MAIN_MENU_BOOT_TIMEOUT_MS });
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

  await openMainMenuForStorageSeed(page, "seedCampaignSave");
  await page.evaluate(
    ({ key, value }) => {
      localStorage.clear();
      localStorage.setItem(key, JSON.stringify(value));
    },
    { key: SAVE_KEY, value: save }
  );
  await openMainMenuAfterStorageSeed(page, "seedCampaignSave");
}

export async function continueSavedCampaign(page: Page): Promise<void> {
  await page.getByTestId("menu-continue-campaign").click();
  await expect(page.getByTestId("campaign-map")).toBeVisible();
}
