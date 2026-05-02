import { expect, test, type Page } from "@playwright/test";

const SAVE_KEY = "ascendant-realms-save-v1";
type SmokeDifficulty = "story" | "easy" | "normal" | "hard";

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

async function launchSkirmishBattle(page: Page, difficulty: SmokeDifficulty, heroName: string): Promise<void> {
  await openFreshMainMenu(page);
  await page.getByTestId("menu-skirmish").click();
  await createHero(page, heroName);
  await expect(page.getByTestId("skirmish-setup")).toBeVisible();
  await page.getByTestId(`setup-difficulty-${difficulty}`).click();
  await page.getByTestId("setup-start-battle").click();
  await expectBattleLoaded(page);
}

async function readDifficultyBattleState(page: Page): Promise<{
  difficulty: SmokeDifficulty;
  fogActive: boolean;
  enemyUnitDefinitionIds: string[];
}> {
  return page.evaluate(() => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    scene.update(performance.now(), 250);
    return {
      difficulty: scene.launch.request.difficulty,
      fogActive: scene.isFogActive(),
      enemyUnitDefinitionIds: scene.units
        .filter((unit: any) => unit.team === "enemy" && unit.alive)
        .map((unit: any) => unit.definition.id)
    };
  });
}

test.describe("Ascendant Realms browser smoke flows", () => {
  test("main menu boots", async ({ page }) => {
    await openFreshMainMenu(page);

    await expect(page.getByRole("heading", { name: "Ascendant Realms" })).toBeVisible();
    await expect(page.getByText("Prototype v0.2", { exact: true })).toBeVisible();
    await expect(page.getByText("v0.2 Prototype - Campaign, Stronghold, Affixes, Veterancy and Retinue")).toBeVisible();
    await expect(page.getByText("Prototype v0.1", { exact: true })).toHaveCount(0);
    await expect(page.getByTestId("menu-new-campaign")).toBeVisible();
    await expect(page.getByTestId("menu-skirmish")).toBeVisible();
    await expect(page.getByTestId("menu-inventory")).toBeVisible();
    await expect(page.getByTestId("menu-asset-gallery")).toBeVisible();
    await expect(page.getByTestId("menu-settings")).toBeVisible();
    await expect(page.getByTestId("menu-reset-save")).toBeVisible();
  });

  test("settings screen persists accessibility options", async ({ page }) => {
    await openFreshMainMenu(page);

    await page.getByTestId("menu-settings").click();
    await expect(page.getByTestId("settings-screen")).toBeVisible();
    await page.getByTestId("settings-master-volume").evaluate((input) => {
      const range = input as HTMLInputElement;
      range.value = "0.35";
      range.dispatchEvent(new Event("input", { bubbles: true }));
    });
    await page.getByTestId("settings-ui-scale").evaluate((input) => {
      const range = input as HTMLInputElement;
      range.value = "1.15";
      range.dispatchEvent(new Event("input", { bubbles: true }));
    });
    await page.getByTestId("settings-floating-text").uncheck();
    await page.getByTestId("settings-reduced-motion").check();
    await page.getByTestId("settings-colorblind-minimap").check();
    await page.getByTestId("settings-fog-override").selectOption("disabled");
    await page.getByTestId("settings-save").click();
    await expect(page.getByTestId("settings-status")).toContainText("Settings saved");
    await page.getByTestId("settings-back").click();
    await expect(page.getByTestId("main-menu")).toBeVisible();

    await page.getByTestId("menu-settings").click();
    await expect(page.getByTestId("settings-master-volume")).toHaveValue("0.35");
    await expect(page.getByTestId("settings-ui-scale")).toHaveValue("1.15");
    await expect(page.getByTestId("settings-floating-text")).not.toBeChecked();
    await expect(page.getByTestId("settings-reduced-motion")).toBeChecked();
    await expect(page.getByTestId("settings-colorblind-minimap")).toBeChecked();
    await expect(page.getByTestId("settings-fog-override")).toHaveValue("disabled");

    const persistedSettings = await page.evaluate((key) => {
      const raw = localStorage.getItem(key);
      return raw ? JSON.parse(raw).settings : undefined;
    }, SAVE_KEY);
    expect(persistedSettings).toMatchObject({
      floatingTextEnabled: false,
      reducedMotionEnabled: true,
      colorblindMinimapPalette: true,
      fogEnabledOverride: "disabled"
    });
    expect(await page.evaluate(() => document.documentElement.dataset.reducedMotion)).toBe("true");
    expect(await page.evaluate(() => document.documentElement.dataset.colorblindMinimap)).toBe("true");

    await page.getByTestId("settings-back").click();
    await page.getByTestId("menu-skirmish").click();
    await page.waitForFunction(() =>
      Boolean(document.querySelector('[data-testid="hero-creation"], [data-testid="skirmish-setup"]'))
    );
    if (await page.getByTestId("hero-creation").isVisible()) {
      await createHero(page, "E2E Settings");
    }
    await expect(page.getByTestId("skirmish-setup")).toBeVisible();
    await page.getByTestId("setup-difficulty-normal").click();
    await page.getByTestId("setup-start-battle").click();
    await expectBattleLoaded(page);

    const battleSettings = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      const floatingTextCount = () =>
        scene.children.list.filter((child: any) => child?.type === "Text" && child.depth === 100 && /^-/.test(child.text ?? "")).length;
      const playerUnit = scene.units.find((unit: any) => unit.team === "player" && unit.alive);
      const enemyUnit = scene.units.find((unit: any) => unit.team === "enemy" && unit.alive);
      if (!playerUnit || !enemyUnit) {
        throw new Error("Expected player and enemy units for floating text regression check.");
      }
      const beforeFloatingText = floatingTextCount();
      enemyUnit.setPosition(playerUnit.position.x + 28, playerUnit.position.y);
      enemyUnit.moveTarget = undefined;
      enemyUnit.attackTargetId = undefined;
      enemyUnit.attackMove = false;
      enemyUnit.attackCooldownRemaining = 0;
      playerUnit.attackCooldownRemaining = 999;
      for (let index = 0; index < 20; index += 1) {
        scene.combatSystem.update(0.1);
      }
      return {
        floatingTextEnabled: scene.settings.floatingTextEnabled,
        beforeFloatingText,
        afterFloatingText: floatingTextCount(),
        fogOverride: scene.settings.fogEnabledOverride,
        fogActive: scene.isFogActive(),
        reducedMotionDataset: document.documentElement.dataset.reducedMotion,
        colorblindDataset: document.documentElement.dataset.colorblindMinimap,
        colorblindSnapshot: scene.createMinimapSnapshot().colorblindPalette
      };
    });
    expect(battleSettings.floatingTextEnabled).toBe(false);
    expect(battleSettings.afterFloatingText).toBe(battleSettings.beforeFloatingText);
    expect(battleSettings.fogOverride).toBe("disabled");
    expect(battleSettings.fogActive).toBe(false);
    expect(battleSettings.reducedMotionDataset).toBe("true");
    expect(battleSettings.colorblindDataset).toBe("true");
    expect(battleSettings.colorblindSnapshot).toBe(true);
    await expect(page.getByTestId("minimap").locator(".minimap-unit[fill='#56b4e9']").first()).toBeVisible();
    await expect(page.getByTestId("minimap").locator(".minimap-unit[fill='#d55e00']").first()).toBeVisible();
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
    const fogVisibility = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      scene.update(performance.now(), 250);
      const quarryCampLabel = scene.neutralCampLabels.find((entry: any) => entry.id === "quarry_imps");
      const quarryUnits = scene.units.filter(
        (unit: any) =>
          unit.team === "neutral" &&
          unit.alive &&
          Math.hypot(unit.position.x - 1160, unit.position.y - 520) < 120
      );
      const quarrySite = scene.captureSites.find((site: any) => site.definition.id === "stone_quarry");
      const crownShrine = scene.captureSites.find((site: any) => site.definition.id === "crown_shrine");
      const minimap = scene.createMinimapSnapshot();
      const minimapMarkerIds = minimap.markers.map((marker: any) => marker.id);
      const hiddenQuarryUnitIds = quarryUnits.map((unit: any) => unit.id);
      return {
        fogActive: scene.isFogActive(),
        minimapFogActive: minimap.fog.enabled,
        minimapFogCellCount: minimap.fog.cells?.length ?? 0,
        minimapMarkerIds,
        hiddenQuarryUnitIds,
        quarryCampLabelVisible: quarryCampLabel?.label.visible,
        quarryUnitsVisible: quarryUnits.map((unit: any) => unit.view?.visible),
        quarryCampId: quarryCampLabel?.id,
        quarrySiteId: quarrySite?.id,
        quarrySiteVisible: quarrySite?.view?.visible,
        crownShrineVisible: crownShrine?.view?.visible
      };
    });
    expect(fogVisibility.fogActive).toBe(true);
    expect(fogVisibility.minimapFogActive).toBe(true);
    expect(fogVisibility.minimapFogCellCount).toBeGreaterThan(0);
    expect(fogVisibility.minimapMarkerIds).not.toContain(fogVisibility.quarryCampId);
    expect(fogVisibility.minimapMarkerIds).not.toContain(fogVisibility.quarrySiteId);
    expect(fogVisibility.minimapMarkerIds).not.toEqual(expect.arrayContaining(fogVisibility.hiddenQuarryUnitIds));
    expect(fogVisibility.quarryCampLabelVisible).toBe(false);
    expect(fogVisibility.quarryUnitsVisible.every((visible: boolean) => visible === false)).toBe(true);
    expect(fogVisibility.quarrySiteVisible).toBe(false);
    expect(fogVisibility.crownShrineVisible).toBe(true);
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

  test("skirmish difficulty selection changes fog and starting pressure", async ({ page }) => {
    await launchSkirmishBattle(page, "story", "E2E Story");
    const storyBattle = await readDifficultyBattleState(page);
    expect(storyBattle.difficulty).toBe("story");
    expect(storyBattle.fogActive).toBe(false);
    expect(storyBattle.enemyUnitDefinitionIds).toEqual(["raider"]);

    await launchSkirmishBattle(page, "normal", "E2E Normal");
    const normalBattle = await readDifficultyBattleState(page);
    expect(normalBattle.difficulty).toBe("normal");
    expect(normalBattle.fogActive).toBe(true);
    expect(normalBattle.enemyUnitDefinitionIds).toEqual(expect.arrayContaining(["raider", "hexer", "enemy_commander"]));
    expect(normalBattle.enemyUnitDefinitionIds.filter((unitId) => unitId === "raider")).toHaveLength(2);
    expect(normalBattle.enemyUnitDefinitionIds).toHaveLength(4);
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
