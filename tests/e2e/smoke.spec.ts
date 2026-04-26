import { expect, test, type Page } from "@playwright/test";

async function openFreshMainMenu(page: Page): Promise<void> {
  await page.goto("/");
  await page.evaluate(() => localStorage.clear());
  await page.reload();
  await expect(page.getByTestId("main-menu")).toBeVisible();
}

async function createHero(page: Page, name: string): Promise<void> {
  await expect(page.getByTestId("hero-creation")).toBeVisible();
  await page.getByTestId("hero-name-input").fill(name);
  await page.getByTestId("hero-start").click();
}

async function startNewCampaign(page: Page): Promise<void> {
  await openFreshMainMenu(page);
  await page.getByTestId("menu-new-campaign").click();
  await createHero(page, "E2E Campaign");
  await expect(page.getByTestId("campaign-map")).toBeVisible();
}

async function expectBattleLoaded(page: Page): Promise<void> {
  await expect(page.getByTestId("battle-hud")).toBeVisible({ timeout: 15_000 });
  await expect(page.getByTestId("battle-resources")).toContainText("Crowns");
  await expect(page.getByTestId("battle-hero-panel")).toBeVisible();
  await expect(page.getByTestId("battle-minimap")).toBeVisible();
  await expect(page.getByTestId("minimap")).toBeVisible();
}

test.describe("Ascendant Realms browser smoke flows", () => {
  test("main menu boots", async ({ page }) => {
    await openFreshMainMenu(page);

    await expect(page.getByRole("heading", { name: "Ascendant Realms" })).toBeVisible();
    await expect(page.getByTestId("menu-new-campaign")).toBeVisible();
    await expect(page.getByTestId("menu-skirmish")).toBeVisible();
    await expect(page.getByTestId("menu-inventory")).toBeVisible();
    await expect(page.getByTestId("menu-asset-gallery")).toBeVisible();
    await expect(page.getByTestId("menu-reset-save")).toBeVisible();
  });

  test("new campaign flow opens the campaign map and blocks locked nodes", async ({ page }) => {
    await startNewCampaign(page);

    await expect(page.getByTestId("campaign-node-border_village")).toContainText(/Available/i);
    await page.getByTestId("campaign-node-aether_well_ruins").click();
    await expect(page.getByTestId("campaign-node-aether_well_ruins")).toContainText(/Locked/i);
    await expect(page.getByTestId("campaign-start-node")).toBeDisabled();
  });

  test("campaign Border Village launches a battle scene", async ({ page }) => {
    await startNewCampaign(page);

    await page.getByTestId("campaign-node-border_village").click();
    await expect(page.getByTestId("campaign-start-node")).toBeEnabled();
    await page.getByTestId("campaign-start-node").click();
    await expectBattleLoaded(page);
  });

  test("skirmish setup lists maps and launches Broken Ford", async ({ page }) => {
    await openFreshMainMenu(page);
    await page.getByTestId("menu-skirmish").click();
    await createHero(page, "E2E Skirmish");

    await expect(page.getByTestId("skirmish-setup")).toBeVisible();
    await expect(page.getByTestId("setup-map-first_claim")).toBeVisible();
    await expect(page.getByTestId("setup-map-broken_ford")).toBeVisible();
    await expect(page.getByTestId("setup-map-ashen_outpost")).toBeVisible();
    await expect(page.getByTestId("setup-difficulty-easy")).toBeVisible();
    await expect(page.getByTestId("setup-difficulty-normal")).toBeVisible();

    await page.getByTestId("setup-map-broken_ford").click();
    await page.getByTestId("setup-start-battle").click();
    await expectBattleLoaded(page);
  });

  test("inventory screen opens without crashing", async ({ page }) => {
    await openFreshMainMenu(page);
    await page.getByTestId("menu-skirmish").click();
    await createHero(page, "E2E Inventory");
    await expect(page.getByTestId("skirmish-setup")).toBeVisible();
    await page.getByTestId("setup-back").click();
    await expect(page.getByTestId("main-menu")).toBeVisible();

    await expect(page.getByTestId("menu-inventory")).toBeEnabled();
    await page.getByTestId("menu-inventory").click();
    await expect(page.getByTestId("hero-inventory")).toBeVisible();
    await expect(page.getByTestId("hero-stats")).toBeVisible();
    await expect(page.getByTestId("equipment-panel")).toBeVisible();
    await expect(page.getByTestId("inventory-list")).toBeVisible();
  });
});
