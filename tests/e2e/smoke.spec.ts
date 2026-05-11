import { expect, test, type Page } from "@playwright/test";
import {
  buyCinderfenWaystationService,
  captureCinderShrineWithHook,
  completeCinderfenOverlookChoice,
  completeCinderfenVictory,
  completeCinderfenWatchVictory,
  launchCinderfenCrossing,
  launchCinderfenWatch,
  openCinderfenWaystation,
  readStoredSave,
  seedPostAshenCampaign,
  seedPostCinderfenCrossingCampaign
} from "./chapter2-helpers";
import { runSemanticCommandLog, type SemanticCommand } from "./semantic-command-log";
import { createHero, openFreshMainMenu, SAVE_KEY, seedCampaignSave, startNewCampaign } from "./shared-helpers";

type SmokeDifficulty = "story" | "easy" | "normal" | "hard";

async function expectBattleLoaded(page: Page): Promise<void> {
  await expect(page.getByTestId("battle-hud")).toBeVisible({ timeout: 30_000 });
  await expect(page.getByTestId("battle-resources")).toContainText("Crowns");
  await expect(page.getByTestId("battle-hero-panel")).toBeVisible();
  await expect(page.getByTestId("battle-minimap")).toBeVisible();
  await expect(page.getByTestId("minimap")).toBeVisible();
}

async function launchSkirmishBattle(page: Page, difficulty: SmokeDifficulty, heroName: string): Promise<void> {
  await seedCampaignSave(page, { hero: { heroName } });
  await page.getByTestId("menu-skirmish").click();
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

async function expectTutorialObjective(page: Page, title: string, progressText: string): Promise<void> {
  await expect(page.getByTestId("tutorial-overlay")).toBeVisible();
  await expect(page.getByTestId("tutorial-objective")).toContainText(title);
  await expect(page.getByTestId("tutorial-progress")).toContainText(progressText);
}

async function completeTutorialSceneStep(page: Page, stepId: string): Promise<Record<string, unknown> | null> {
  return page.evaluate((targetStepId) => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }

    const refresh = () => {
      scene.update(performance.now(), 16);
      scene.refreshBattleHud?.(0);
    };

    if (targetStepId === "select_hero") {
      scene.selectionSystem.setSelection([scene.hero]);
      refresh();
      return { selectedHero: true };
    }

    if (targetStepId === "move_hero") {
      scene.selectionSystem.setSelection([scene.hero]);
      scene.hero.setPosition(scene.activeMap.scenario.heroSpawn.x + 86, scene.activeMap.scenario.heroSpawn.y - 8);
      scene.hero.moveTarget = undefined;
      scene.cameraSystem.centerOn(scene.hero.position);
      refresh();
      return { heroX: scene.hero.position.x, heroY: scene.hero.position.y };
    }

    if (targetStepId === "capture_crown_shrine") {
      return window.__ASCENDANT_TEST_HOOKS__?.captureSite?.("crown_shrine") ?? null;
    }

    if (targetStepId === "gather_crowns") {
      const beforeCrowns = scene.resources.player.crowns;
      for (let index = 0; index < 7; index += 1) {
        scene.resourceSystem.update(1, scene.captureSites, scene.units);
      }
      if (scene.resources.player.crowns <= beforeCrowns) {
        scene.resources.player.crowns = beforeCrowns + 30;
      }
      refresh();
      return { beforeCrowns, afterCrowns: scene.resources.player.crowns };
    }

    if (targetStepId === "select_command_hall") {
      const commandHall = scene.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
      );
      if (!commandHall) {
        throw new Error("Missing Command Hall.");
      }
      scene.selectionSystem.setSelection([commandHall]);
      scene.cameraSystem.centerOn(commandHall.position);
      refresh();
      return { selectedBuilding: commandHall.definition.id };
    }

    if (targetStepId === "build_barracks") {
      const commandHall = scene.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "command_hall" && building.alive
      );
      if (!commandHall) {
        throw new Error("Missing Command Hall for Barracks placement.");
      }
      scene.resources.player.crowns = Math.max(scene.resources.player.crowns, 500);
      scene.resources.player.stone = Math.max(scene.resources.player.stone, 500);
      const points = [
        { x: commandHall.position.x + 170, y: commandHall.position.y - 90 },
        { x: commandHall.position.x + 180, y: commandHall.position.y + 40 },
        { x: commandHall.position.x + 50, y: commandHall.position.y - 150 },
        { x: commandHall.position.x + 230, y: commandHall.position.y - 15 }
      ];
      for (const point of points) {
        scene.buildingSystem.startPlacement("barracks", { anchor: commandHall.position, resources: scene.resources.player });
        scene.buildingSystem.updateGhost(point.x, point.y, scene.resources.player);
        if (scene.buildingSystem.tryPlace(point.x, point.y, scene.resources.player)) {
          const barracks = scene.buildings.find(
            (building: any) => building.team === "player" && building.definition.id === "barracks" && building.alive
          );
          if (!barracks) {
            throw new Error("Barracks placement succeeded but no Barracks exists.");
          }
          scene.buildingSystem.update(barracks.constructionTimeSeconds + 1);
          scene.selectionSystem.setSelection([barracks]);
          refresh();
          return { builtBuilding: barracks.definition.id, completed: barracks.isCompleted() };
        }
      }
      scene.buildingSystem.cancelPlacement();
      throw new Error("Could not place Barracks for tutorial smoke.");
    }

    if (targetStepId === "train_militia") {
      const barracks = scene.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "barracks" && building.alive && building.isCompleted()
      );
      if (!barracks) {
        throw new Error("Missing completed Barracks.");
      }
      scene.resources.player.crowns = Math.max(scene.resources.player.crowns, 300);
      scene.resources.player.iron = Math.max(scene.resources.player.iron, 120);
      scene.selectionSystem.setSelection([barracks]);
      if (!scene.trainingSystem.queueTraining(barracks, "militia", scene.resources.player)) {
        throw new Error("Militia training did not queue.");
      }
      scene.trainingSystem.update(8, scene.buildings);
      refresh();
      return { trainedUnitIds: [...scene.runtime.stats.trainedUnitIds] };
    }

    if (targetStepId === "set_barracks_rally") {
      const barracks = scene.buildings.find(
        (building: any) => building.team === "player" && building.definition.id === "barracks" && building.alive
      );
      if (!barracks) {
        throw new Error("Missing Barracks for rally point.");
      }
      const point = { x: barracks.position.x + 220, y: barracks.position.y - 40 };
      scene.selectionSystem.setSelection([barracks]);
      scene.setRallyPoint(point, [barracks]);
      refresh();
      return { rallyPoint: barracks.rallyPoint };
    }

    if (targetStepId === "use_rally_banner") {
      scene.selectionSystem.setSelection([scene.hero]);
      const cast = scene.abilitySystem.castAbility(scene.hero, "rally_banner", scene.selectionSystem.getSelected());
      refresh();
      return { cast, cooldown: scene.hero.abilityCooldowns.rally_banner, mana: scene.hero.mana };
    }

    if (targetStepId === "hold_safe_pressure") {
      const beforeHeroXp = scene.hero.xp;
      const enemy = scene.units.find((unit: any) => unit.team === "enemy" && unit.definition.id === "raider" && unit.alive);
      if (!enemy) {
        throw new Error("Missing Raider for tutorial pressure step.");
      }
      enemy.setPosition(scene.hero.position.x + 28, scene.hero.position.y + 8);
      const wasAlive = enemy.alive;
      enemy.takeDamage(enemy.maxHp + enemy.armor + 9999);
      if (wasAlive && !enemy.alive) {
        scene.handleKill(scene.hero, enemy);
        enemy.destroyView();
        scene.cleanupDeadEntities();
      }
      refresh();
      return {
        beforeHeroXp,
        afterHeroXp: scene.hero.xp,
        runtimeXp: scene.runtime.stats.xpGained,
        unitsKilled: scene.runtime.stats.unitsKilled
      };
    }

    throw new Error(`Unsupported tutorial step helper: ${targetStepId}`);
  }, stepId);
}

const tutorialCompletionCommandLog: readonly SemanticCommand[] = [
  {
    id: "advance-select-hero",
    action: "clickTestId",
    target: { type: "testId", id: "tutorial-next" },
    expected: { title: "Select Aster", progress: "Step 2 of 12" },
    debugLabel: "Advance to Select Aster"
  },
  {
    id: "select-hero",
    action: "selectHero",
    target: { type: "battleEntity", id: "hero" },
    debugLabel: "Select Aster"
  },
  {
    id: "advance-move-hero",
    action: "clickTestId",
    target: { type: "testId", id: "tutorial-next" },
    expected: { title: "Move Aster", progress: "Step 3 of 12" },
    debugLabel: "Advance to Move Hero"
  },
  {
    id: "move-hero",
    action: "moveHeroToSemanticLocation",
    target: { type: "semanticLocation", id: "road_ahead" },
    debugLabel: "Move Aster to the road"
  },
  {
    id: "advance-capture-site",
    action: "clickTestId",
    target: { type: "testId", id: "tutorial-next" },
    expected: { title: "Capture Crown Shrine", progress: "Step 4 of 12" },
    debugLabel: "Advance to Capture Crown Shrine"
  },
  {
    id: "capture-crown-shrine",
    action: "captureSite",
    target: { type: "battleEntity", id: "crown_shrine" },
    debugLabel: "Capture Crown Shrine"
  },
  {
    id: "advance-gather-resources",
    action: "clickTestId",
    target: { type: "testId", id: "tutorial-next" },
    expected: { title: "Gather Battle Crowns", progress: "Step 5 of 12" },
    debugLabel: "Advance to Gather Resources"
  },
  {
    id: "gather-crowns",
    action: "captureSite",
    target: { type: "battleEntity", id: "gather_crowns" },
    debugLabel: "Tick Crown income"
  },
  {
    id: "advance-command-hall",
    action: "clickTestId",
    target: { type: "testId", id: "tutorial-next" },
    expected: { title: "Select Command Hall", progress: "Step 6 of 12" },
    debugLabel: "Advance to Select Command Hall"
  },
  {
    id: "select-command-hall",
    action: "selectBuilding",
    target: { type: "battleEntity", id: "command_hall" },
    debugLabel: "Select Command Hall"
  },
  {
    id: "advance-build-barracks",
    action: "clickTestId",
    target: { type: "testId", id: "tutorial-next" },
    expected: { title: "Build Barracks", progress: "Step 7 of 12" },
    debugLabel: "Advance to Build Barracks"
  },
  {
    id: "build-barracks",
    action: "buildBarracks",
    target: { type: "battleEntity", id: "barracks" },
    debugLabel: "Build Barracks"
  },
  {
    id: "advance-train-militia",
    action: "clickTestId",
    target: { type: "testId", id: "tutorial-next" },
    expected: { title: "Train Militia", progress: "Step 8 of 12" },
    debugLabel: "Advance to Train Militia"
  },
  {
    id: "train-militia",
    action: "trainMilitia",
    target: { type: "battleEntity", id: "militia" },
    debugLabel: "Train Militia"
  },
  {
    id: "advance-set-rally",
    action: "clickTestId",
    target: { type: "testId", id: "tutorial-next" },
    expected: { title: "Set Rally Point", progress: "Step 9 of 12" },
    debugLabel: "Advance to Set Rally Point"
  },
  {
    id: "set-rally",
    action: "setRally",
    target: { type: "semanticLocation", id: "forward_safe" },
    debugLabel: "Set Barracks rally point"
  },
  {
    id: "advance-use-ability",
    action: "clickTestId",
    target: { type: "testId", id: "tutorial-next" },
    expected: { title: "Cast Rally Banner", progress: "Step 10 of 12" },
    debugLabel: "Advance to Cast Rally Banner"
  },
  {
    id: "use-rally-banner",
    action: "useHeroAbility",
    target: { type: "battleEntity", id: "rally_banner" },
    debugLabel: "Use Rally Banner"
  },
  {
    id: "advance-safe-pressure",
    action: "clickTestId",
    target: { type: "testId", id: "tutorial-next" },
    expected: { title: "Group Up And Hold", progress: "Step 11 of 12" },
    debugLabel: "Advance to Group Up And Hold"
  },
  {
    id: "defeat-safe-pressure",
    action: "defeatEnemy",
    target: { type: "battleEntity", id: "raider" },
    debugLabel: "Defeat safe Raider pressure"
  },
  {
    id: "advance-finish-training",
    action: "clickTestId",
    target: { type: "testId", id: "tutorial-next" },
    expected: { title: "Training Complete", progress: "Step 12 of 12: complete", text: "No rewards:" },
    debugLabel: "Advance to Training Complete"
  },
  {
    id: "assert-no-save-before-complete",
    action: "assertNoSavePollution",
    debugLabel: "Assert tutorial has not written a save"
  }
];

async function executeTutorialCommand(command: SemanticCommand, page: Page): Promise<unknown> {
  if (command.action === "clickTestId") {
    if (!command.target?.id) {
      throw new Error(`Command ${command.id} is missing a test id target.`);
    }
    await page.getByTestId(command.target.id).click({ timeout: command.timeoutMs });
    await expectTutorialCommandState(page, command);
    return null;
  }

  if (command.action === "clickText") {
    if (!command.target?.id) {
      throw new Error(`Command ${command.id} is missing a text target.`);
    }
    await page.getByText(command.target.id).click({ timeout: command.timeoutMs });
    await expectTutorialCommandState(page, command);
    return null;
  }

  if (command.action === "waitForStepText") {
    await expectTutorialCommandState(page, command);
    return null;
  }

  if (command.action === "assertNoSavePollution") {
    expect(await page.evaluate((key) => localStorage.getItem(key), SAVE_KEY)).toBeNull();
    return null;
  }

  const stepId = tutorialStepForCommand(command);
  return completeTutorialSceneStep(page, stepId);
}

async function expectTutorialCommandState(page: Page, command: SemanticCommand): Promise<void> {
  if (command.expected?.title || command.expected?.progress) {
    await expectTutorialObjective(page, command.expected.title ?? "", command.expected.progress ?? "");
  }
  if (command.expected?.text) {
    await expect(page.getByTestId("tutorial-instruction")).toContainText(command.expected.text);
  }
}

function tutorialStepForCommand(command: SemanticCommand): string {
  if (command.action === "selectHero") {
    return "select_hero";
  }
  if (command.action === "moveHeroToSemanticLocation") {
    return "move_hero";
  }
  if (command.action === "captureSite") {
    return command.target?.id === "gather_crowns" ? "gather_crowns" : "capture_crown_shrine";
  }
  if (command.action === "selectBuilding") {
    return "select_command_hall";
  }
  if (command.action === "buildBarracks") {
    return "build_barracks";
  }
  if (command.action === "trainMilitia") {
    return "train_militia";
  }
  if (command.action === "setRally") {
    return "set_barracks_rally";
  }
  if (command.action === "useHeroAbility") {
    return "use_rally_banner";
  }
  if (command.action === "defeatEnemy") {
    return "hold_safe_pressure";
  }
  throw new Error(`Unsupported tutorial command action: ${command.action}`);
}

test.describe("Ascendant Realms browser smoke flows", () => {
  test("main menu boots", async ({ page }) => {
    await openFreshMainMenu(page);

    await expect(page.getByRole("heading", { name: "Ascendant Realms" })).toBeVisible();
    await expect(page.getByText("Prototype v0.3", { exact: true })).toBeVisible();
    await expect(page.getByText("Cinderfen Route Baseline", { exact: true })).toBeVisible();
    await expect(page.getByText("Prototype v0.2", { exact: true })).toHaveCount(0);
    await expect(page.getByText("v0.2 Prototype - Campaign, Stronghold, Affixes, Veterancy and Retinue")).toHaveCount(0);
    await expect(page.getByText("Prototype v0.1", { exact: true })).toHaveCount(0);
    await expect(page.getByTestId("menu-new-campaign")).toBeVisible();
    await expect(page.getByTestId("menu-tutorial")).toBeVisible();
    await expect(page.getByTestId("menu-skirmish")).toBeVisible();
    await expect(page.getByTestId("menu-inventory")).toBeVisible();
    await expect(page.getByTestId("menu-asset-gallery")).toBeVisible();
    await expect(page.getByTestId("menu-settings")).toBeVisible();
    await expect(page.getByTestId("menu-reset-save")).toBeVisible();
  });

  test("tutorial entry launches a no-reward shell and returns to menu", async ({ page }) => {
    test.setTimeout(75_000);
    await openFreshMainMenu(page);

    await page.getByTestId("menu-tutorial").click();
    await expectBattleLoaded(page);
    await expect(page.getByTestId("tutorial-overlay")).toBeVisible();
    await expect(page.getByTestId("tutorial-objective")).toContainText("Find Your Army");
    await expect(page.getByTestId("tutorial-progress")).toContainText("Step 1 of 12: complete");
    await expect(page.getByTestId("tutorial-next")).toContainText("Next Objective");
    const overlayBox = await page.getByTestId("tutorial-overlay").boundingBox();
    const viewport = page.viewportSize();
    expect(overlayBox).not.toBeNull();
    expect(viewport).not.toBeNull();
    if (overlayBox && viewport) {
      expect(overlayBox.x).toBeGreaterThanOrEqual(-2);
      expect(overlayBox.x + overlayBox.width).toBeLessThanOrEqual(viewport.width + 2);
    }
    await expect(page.getByTestId("tutorial-info-panel")).toHaveCount(0);
    await expect(page.getByTestId("skirmish-setup")).toHaveCount(0);
    const tutorialLaunch = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      return {
        mode: scene?.launch?.request?.mode,
        mapId: scene?.launch?.request?.mapId,
        sourceId: scene?.launch?.request?.sourceId,
        rewardsDisabled: scene?.launch?.request?.rewardsDisabled,
        heroName: scene?.heroSave?.heroName,
        completedBattles: scene?.heroSave?.completedBattles
      };
    });
    expect(tutorialLaunch).toMatchObject({
      mode: "tutorial",
      mapId: "first_claim",
      sourceId: "proving_grounds_basics",
      rewardsDisabled: true,
      heroName: "Aster",
      completedBattles: 0
    });
    expect(await page.evaluate((key) => localStorage.getItem(key), SAVE_KEY)).toBeNull();

    const commandResults = await runSemanticCommandLog(page, tutorialCompletionCommandLog, executeTutorialCommand);
    const built = commandResults.get("build-barracks") as Record<string, unknown> | null;
    const trained = commandResults.get("train-militia") as Record<string, unknown> | null;
    const rally = commandResults.get("set-rally") as Record<string, unknown> | null;
    const ability = commandResults.get("use-rally-banner") as Record<string, unknown> | null;
    const pressure = commandResults.get("defeat-safe-pressure") as Record<string, unknown> | null;

    expect(built).toMatchObject({ builtBuilding: "barracks", completed: true });
    expect(trained?.trainedUnitIds).toContain("militia");
    expect(rally?.rallyPoint).toBeTruthy();
    expect(ability).toMatchObject({ cast: true });
    expect(pressure).toMatchObject({
      afterHeroXp: 0,
      runtimeXp: 0
    });
    expect(Number(pressure?.unitsKilled ?? 0)).toBeGreaterThanOrEqual(1);
    await expect(page.getByTestId("tutorial-instruction")).toContainText("No rewards:");
    await expect(page.getByTestId("tutorial-instruction")).toContainText("campaign progress");
    await expect(page.getByTestId("tutorial-next")).toContainText("Complete Tutorial");
    expect(await page.evaluate((key) => localStorage.getItem(key), SAVE_KEY)).toBeNull();
    await page.getByTestId("tutorial-next").click();
    await expect(page.getByTestId("main-menu")).toBeVisible();
    await expect(page.getByTestId("tutorial-complete-notice")).toContainText("Training complete");
    await expect(page.getByTestId("tutorial-complete-notice")).toContainText("Nothing was saved");
    expect(await page.evaluate((key) => localStorage.getItem(key), SAVE_KEY)).toBeNull();
    await expect(page.getByTestId("menu-new-campaign")).toBeVisible();
    await expect(page.getByTestId("menu-skirmish")).toBeVisible();
  });

  test("tutorial exit returns to menu without saving", async ({ page }) => {
    await openFreshMainMenu(page);

    await page.getByTestId("menu-tutorial").click();
    await expectBattleLoaded(page);
    await expect(page.getByTestId("tutorial-overlay")).toBeVisible();
    await page.getByTestId("tutorial-exit").click();
    await expect(page.getByTestId("main-menu")).toBeVisible();
    await expect(page.getByTestId("tutorial-complete-notice")).toHaveCount(0);
    expect(await page.evaluate((key) => localStorage.getItem(key), SAVE_KEY)).toBeNull();
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
    await startNewCampaign(page, "E2E Campaign");

    await expect(page.getByTestId("campaign-chapter-border_marches")).toContainText("Unlocked");
    await expect(page.getByTestId("campaign-chapter-cinderfen_road")).toContainText("Locked");
    await expect(page.getByTestId("campaign-chapter-cinderfen_road")).toContainText("Chapter 2: Cinderfen Road");
    await expect(page.getByTestId("campaign-node-border_village")).toContainText(/Available/i);
    await page.getByTestId("campaign-node-aether_well_ruins").click();
    await expect(page.getByTestId("campaign-node-aether_well_ruins")).toContainText(/Locked/i);
    await expect(page.getByTestId("campaign-start-node")).toBeDisabled();
    await expect(page.getByTestId("campaign-node-cinderfen_overlook")).toContainText(/Locked/i);
    await expect(page.getByTestId("campaign-node-cinderfen_waystation")).toContainText(/Locked/i);
    await expect(page.getByTestId("campaign-node-cinderfen_crossing")).toContainText(/Locked/i);
    await expect(page.getByTestId("campaign-node-cinderfen_watch")).toContainText(/Locked/i);
    await expect(page.getByTestId("campaign-node-cinderfen_aftermath")).toContainText(/Locked/i);
    await page.getByTestId("campaign-node-cinderfen_crossing").click();
    await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Causeway");
    await expect(page.locator(".campaign-node-details")).toContainText("Hexfire Cult");
    await expect(page.locator(".campaign-node-details")).toContainText("Scout's Bow");
    await expect(page.getByTestId("campaign-start-node")).toBeDisabled();
    await page.getByTestId("campaign-node-cinderfen_watch").click();
    await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Watchpost");
    await expect(page.getByTestId("campaign-start-node")).toBeDisabled();
    await page.getByTestId("campaign-node-cinderfen_aftermath").click();
    await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Aftermath");
    await expect(page.getByTestId("campaign-start-node")).toHaveCount(0);
  });

  test("campaign Border Village launches a battle scene", async ({ page }) => {
    await startNewCampaign(page, "E2E Campaign");

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

  test("post-Ashen campaign resolves Cinderfen Overlook, wins Cinderfen Crossing, and persists rewards", async ({ page }) => {
    test.setTimeout(85_000);
    await seedPostAshenCampaign(page);

    await page.getByTestId("menu-continue-campaign").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("campaign-chapter-border_marches")).toContainText("Chapter 1: Border Marches");
    await expect(page.getByTestId("campaign-node-border_village")).toContainText(/Completed/i);
    await expect(page.getByTestId("campaign-node-old_stone_road")).toContainText(/Completed/i);
    await expect(page.getByTestId("campaign-node-ashen_outpost")).toContainText(/Completed/i);
    await expect(page.getByTestId("campaign-chapter-cinderfen_road")).toContainText("Chapter 2: Cinderfen Road");
    await expect(page.getByTestId("campaign-chapter-cinderfen_road")).toContainText("Unlocked");
    await page.getByTestId("campaign-node-cinderfen_overlook").click();
    await expect(page.getByTestId("campaign-node-cinderfen_overlook")).toContainText(/Available/i);
    await expect(page.locator(".campaign-node-details")).toContainText("Scout the Causeway");
    await expect(page.locator(".campaign-node-details")).toContainText("Aid the Marsh Refugees");
    await expect(page.locator(".campaign-node-details")).toContainText("Study the Cinders");
    await expect(page.locator(".campaign-node-details")).toContainText("Raise Malrec's Standard");
    await expect(page.locator("button[data-campaign-choice='raise_malrecs_standard']")).toBeDisabled();
    await expect(page.locator("button[data-campaign-choice='raise_malrecs_standard']")).toContainText(
      "Requires trophy Malrec's Outpost Standard"
    );
    await expect(page.locator("button[data-campaign-choice='aid_marsh_refugees']")).toContainText("Cost: 55 Crowns");
    await expect(page.locator("button[data-campaign-choice='aid_marsh_refugees']")).toContainText(
      "Reputation: +6 Common Folk"
    );
    await expect(page.locator("button[data-campaign-choice='aid_marsh_refugees']")).toContainText(
      "Modifiers: Gain Inspired Militia"
    );
    await expect(page.locator("button[data-campaign-choice='aid_marsh_refugees']")).toContainText("Completes this node");
    await expect(page.getByTestId("campaign-node-cinderfen_crossing")).toContainText(/Locked/i);
    await expect(page.getByTestId("campaign-node-cinderfen_waystation")).toContainText(/Locked/i);
    await expect(page.getByTestId("campaign-node-cinderfen_watch")).toContainText(/Locked/i);

    await completeCinderfenOverlookChoice(page, "aid_marsh_refugees", "Aid the Marsh Refugees chosen");
    await expect(page.getByTestId("campaign-node-cinderfen_overlook")).toContainText(/Completed/i);
    await expect(page.getByTestId("campaign-node-cinderfen_waystation")).toContainText(/Available/i);
    await expect(page.getByTestId("campaign-node-cinderfen_crossing")).toContainText(/Available/i);
    await expect(page.getByTestId("campaign-node-cinderfen_watch")).toContainText(/Locked/i);
    await expect(page.locator("button[data-campaign-choice='aid_marsh_refugees']")).toBeDisabled();
    await expect(page.locator("button[data-campaign-choice='aid_marsh_refugees']")).toContainText("Already chosen");

    let save = await readStoredSave(page);
    expect(save.campaign.completedNodeIds).toContain("cinderfen_overlook");
    expect(save.campaign.choiceIdsClaimed).toContain("cinderfen_overlook:aid_marsh_refugees");
    expect(save.campaign.resources.crowns).toBe(205);
    expect(save.campaign.resources.iron).toBe(130);
    expect(save.campaign.resourcesSpent.crowns).toBe(55);
    expect(save.campaign.activeModifierIds).toContain("inspired_militia");
    expect(save.hero.xp).toBe(545);
    expect(save.hero.factionReputation.common_folk).toBe(31);
    expect(save.hero.factionReputation.free_marches).toBe(27);

    await openCinderfenWaystation(page);
    await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Waystation");
    await expect(page.locator(".campaign-node-details")).toContainText("Town Services");
    await expect(page.locator("button[data-campaign-choice='marsh_guides']")).toContainText("Cost: 35 Crowns");
    await expect(page.locator("button[data-campaign-choice='marsh_guides']")).toContainText("Modifiers: Gain Marsh Guides");
    await expect(page.locator("button[data-campaign-choice='ash_filters']")).toContainText("Cost: 35 Crowns, 15 Aether");
    await expect(page.locator("button[data-campaign-choice='refugee_scouts']")).toContainText("Reputation: +2 Common Folk");
    await expect(page.locator("button[data-campaign-choice='shrine_attunement']")).toContainText("Cost: 12 Aether");
    await expect(page.locator("button[data-campaign-choice='shrine_attunement']")).toContainText(
      "Modifiers: Gain Shrine Attunement"
    );
    await expect(page.locator("button[data-campaign-choice='shrine_attunement']")).toContainText("Keeps this node open");
    await buyCinderfenWaystationService(page, "shrine_attunement", "Shrine Attunement used");
    await expect(page.getByTestId("campaign-node-cinderfen_waystation")).toContainText(/Available/i);
    save = await readStoredSave(page);
    expect(save.campaign.completedNodeIds).not.toContain("cinderfen_waystation");
    expect(save.campaign.resources.aether).toBe(68);
    expect(save.campaign.resourcesSpent.aether).toBe(12);
    expect(save.campaign.activeModifierIds).toEqual(expect.arrayContaining(["inspired_militia", "shrine_attunement"]));
    expect(save.campaign.townServiceUseCounts["cinderfen_waystation:shrine_attunement"]).toBe(1);

    await page.getByTestId("campaign-node-cinderfen_crossing").click();
    await expect(page.getByTestId("campaign-node-cinderfen_crossing")).toContainText(/Available/i);
    await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Causeway");
    await expect(page.locator(".campaign-node-details")).toContainText("Normal");
    await expect(page.locator(".campaign-node-details")).toContainText("Hexfire Cult");
    await expect(page.locator(".campaign-node-details")).toContainText("Scout's Bow");
    await expect(page.getByTestId("campaign-start-node")).toBeEnabled();

    await launchCinderfenCrossing(page);
    await expect(page.getByTestId("battle-status")).toContainText("Cinderfen Causeway");
    await expect(page.getByTestId("battle-status")).toContainText("Normal");
    await expect(page.getByTestId("battle-objectives")).toContainText("Claim the Cinder Shrine");
    await expect(page.getByTestId("battle-objectives")).toContainText("Cinder Shrine Surge");
    await expect(page.getByTestId("battle-objectives")).toContainText("+20 Aether");
    await expect(page.getByTestId("battle-objectives")).toContainText("Clear Cinder Guardians");
    await expect(page.getByTestId("battle-objectives")).toContainText("Destroy Enemy Barracks");
    await expect(page.getByTestId("battle-resources")).toContainText("Aether");

    const battleState = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      scene.update(performance.now(), 250);
      return {
        mapName: scene.activeMap.name,
        campaignNodeId: scene.launch.request.campaignNodeId,
        mode: scene.launch.request.mode,
        rewardTableId: scene.launch.rewardTableId,
        captureSites: scene.activeMap.captureSites.map((site: any) => site.id),
        cinderShrine: scene.activeMap.captureSites.find((site: any) => site.id === "cinder_crossing"),
        neutralCamps: scene.activeMap.neutralCamps.map((camp: any) => camp.id),
        objectives: scene.runtime.setup.secondaryObjectiveIds,
        modifiers: scene.launch.request.modifiers.map((modifier: any) => modifier.id),
        minimapMarkers: scene.createMinimapSnapshot().markers.length,
        playerMilitiaCount: scene.units.filter((unit: any) => unit.team === "player" && unit.definition.id === "militia").length,
        difficulty: scene.launch.request.difficulty,
        resources: scene.resources.player
      };
    });
    expect(battleState).toMatchObject({
      mapName: "Cinderfen Causeway",
      campaignNodeId: "cinderfen_crossing",
      mode: "campaign_node",
      rewardTableId: "cinderfen_causeway_rewards",
      difficulty: "normal"
    });
    expect(battleState.captureSites).toEqual(
      expect.arrayContaining(["causeway_toll", "reedcut_quarry", "sunken_iron_cache", "cinder_crossing"])
    );
    expect(battleState.cinderShrine).toMatchObject({
      name: "Cinder Shrine",
      firstCaptureBonus: {
        id: "cinder_shrine_surge",
        label: "Cinder Shrine Surge",
        resources: { aether: 20 }
      }
    });
    expect(battleState.neutralCamps).toEqual(
      expect.arrayContaining(["reedcut_raiders", "sunken_hexfire_pickets", "cinder_guardians"])
    );
    expect(battleState.objectives).toEqual(
      expect.arrayContaining(["capture_cinder_crossing", "clear_cinder_guardians", "destroy_cinderfen_barracks"])
    );
    expect(battleState.modifiers).toContain("inspired_militia");
    expect(battleState.modifiers).toContain("shrine_attunement");
    expect(battleState.playerMilitiaCount).toBe(4);
    expect(battleState.minimapMarkers).toBeGreaterThan(0);
    expect(battleState.resources).toMatchObject({ crowns: 480, stone: 325, iron: 195, aether: 110 });
    save = await readStoredSave(page);
    expect(save.campaign.activeModifierIds).not.toContain("inspired_militia");
    expect(save.campaign.activeModifierIds).not.toContain("shrine_attunement");

    const shrineCapture = await captureCinderShrineWithHook(page);
    expect(shrineCapture).toMatchObject({
      siteId: "cinder_crossing",
      owner: "player",
      firstCaptureBonus: {
        id: "cinder_shrine_surge",
        label: "Cinder Shrine Surge",
        resources: { aether: 25 }
      },
      completedObjectiveIds: expect.arrayContaining(["capture_cinder_crossing"])
    });
    expect(shrineCapture.beforeResources.aether).toBe(110);
    expect(shrineCapture.afterResources.aether).toBe(135);
    expect(shrineCapture.status).toContain("Cinder Shrine Surge");
    await expect(page.getByTestId("battle-status")).toContainText("Cinder Shrine Surge");
    await expect(page.getByTestId("battle-resources")).toContainText("135");

    const duplicateShrineCapture = await captureCinderShrineWithHook(page);
    expect(duplicateShrineCapture.beforeResources.aether).toBe(135);
    expect(duplicateShrineCapture.afterResources.aether).toBe(135);

    const completed = await completeCinderfenVictory(page);
    expect(completed).toMatchObject({
      cinderCrossingOwner: "player",
      cinderGuardianBruteAlive: false,
      enemyBarracksAlive: false,
      enemyStrongholdAlive: false
    });
    expect(completed.completedObjectiveIds).toEqual(
      expect.arrayContaining(["capture_cinder_crossing", "clear_cinder_guardians", "destroy_cinderfen_barracks"])
    );

    const resultsPanel = page.locator(".results-panel");
    await expect(resultsPanel).toContainText("Victory");
    await expect(resultsPanel).toContainText("Cinderfen Causeway");
    await expect(resultsPanel).toContainText("Normal");
    await expect(resultsPanel).toContainText("Reward XP");
    await expect(resultsPanel).toContainText("65");
    await expect(resultsPanel).toContainText("30 Crowns, 20 Stone, 16 Iron, 12 Aether");
    await expect(page.locator(".campaign-reward-block")).toContainText("Cinderfen Crossing");
    await expect(page.locator(".campaign-reward-block")).toContainText("Cinderfen Watch");
    await expect(page.locator(".campaign-reward-block")).toContainText("Node XP");
    await expect(page.locator(".campaign-reward-block")).toContainText("60");
    await expect(page.locator(".campaign-reward-block")).toContainText("40 Crowns, 20 Stone, 20 Iron, 12 Aether");
    await expect(page.locator(".campaign-reward-block")).toContainText("Scout's Bow");
    const objectiveSummary = page.locator(".special-objectives");
    await expect(objectiveSummary).toContainText("Claim the Cinder Shrine");
    await expect(objectiveSummary).toContainText("Clear Cinder Guardians");
    await expect(objectiveSummary).toContainText("Destroy Enemy Barracks");
    const objectiveSummaryText = await objectiveSummary.innerText();
    expect(objectiveSummaryText).toMatch(/Claim the Cinder Shrine\s+Completed/);
    expect(objectiveSummaryText).toMatch(/Clear Cinder Guardians\s+Completed/);
    expect(objectiveSummaryText).toMatch(/Destroy Enemy Barracks\s+Completed/);

    save = await readStoredSave(page);
    expect(save.campaign.completedNodeIds).toContain("cinderfen_crossing");
    expect(save.campaign.nodeRewardsClaimedIds).toContain("cinderfen_crossing");
    expect(save.campaign.resources).toMatchObject({ crowns: 245, stone: 200, iron: 150, aether: 80 });
    expect(save.hero.xp).toBe(670);
    expect(save.hero.completedBattles).toBe(6);
    expect(save.hero.clearedMapIds).toContain("cinderfen_causeway");
    expect(save.hero.inventory.map((item: any) => item.itemId)).toContain("scouts_bow");
    const rewardSnapshot = {
      resources: save.campaign.resources,
      xp: save.hero.xp,
      inventoryCount: save.hero.inventory.length
    };

    await page.getByRole("button", { name: "Campaign Map" }).click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("campaign-node-cinderfen_crossing")).toContainText(/Completed/i);
    await expect(page.getByTestId("campaign-node-cinderfen_watch")).toContainText(/Available/i);
    await expect(page.getByTestId("campaign-node-cinderfen_aftermath")).toContainText(/Locked/i);
    await page.getByTestId("campaign-node-cinderfen_crossing").click();
    await expect(page.getByTestId("campaign-start-node")).toBeDisabled();
    await expect(page.locator(".campaign-node-details")).toContainText("Unlocks");
    await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Watch");
    await expect(page.locator(".campaign-node-details")).not.toContainText("Future map not implemented");
    save = await readStoredSave(page);
    expect(save.campaign.resources).toMatchObject(rewardSnapshot.resources);
    expect(save.hero.xp).toBe(rewardSnapshot.xp);
    expect(save.hero.inventory).toHaveLength(rewardSnapshot.inventoryCount);

    await page.reload();
    await expect(page.getByTestId("main-menu")).toBeVisible();
    await page.getByTestId("menu-continue-campaign").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("campaign-node-cinderfen_crossing")).toContainText(/Completed/i);
    await expect(page.getByTestId("campaign-node-cinderfen_watch")).toContainText(/Available/i);
    await expect(page.getByTestId("campaign-node-cinderfen_aftermath")).toContainText(/Locked/i);
    await page.getByTestId("campaign-node-cinderfen_crossing").click();
    await expect(page.getByTestId("campaign-start-node")).toBeDisabled();
    save = await readStoredSave(page);
    expect(save.campaign.resources).toMatchObject(rewardSnapshot.resources);
    expect(save.hero.xp).toBe(rewardSnapshot.xp);
    expect(save.hero.inventory).toHaveLength(rewardSnapshot.inventoryCount);
  });

  test("post-Crossing campaign launches Cinderfen Watch and persists completion", async ({ page }) => {
    test.setTimeout(65_000);
    await seedPostCinderfenCrossingCampaign(page);

    await page.getByTestId("menu-continue-campaign").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("campaign-node-cinderfen_crossing")).toContainText(/Completed/i);
    await expect(page.getByTestId("campaign-node-cinderfen_watch")).toContainText(/Available/i);
    await expect(page.getByTestId("campaign-node-cinderfen_aftermath")).toContainText(/Locked/i);
    await page.getByTestId("campaign-node-cinderfen_watch").click();
    await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Watch");
    await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Watchpost");
    await expect(page.locator(".campaign-node-details")).toContainText("Normal");
    await expect(page.locator(".campaign-node-details")).toContainText("Hexfire Cult");
    await expect(page.getByTestId("campaign-start-node")).toBeEnabled();

    await openCinderfenWaystation(page);
    await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Waystation");
    await buyCinderfenWaystationService(page, "marsh_guides", "Marsh Guides used");
    let save = await readStoredSave(page);
    expect(save.campaign.resources.crowns).toBe(210);
    expect(save.campaign.resourcesSpent.crowns).toBe(90);
    expect(save.campaign.activeModifierIds).toContain("marsh_guides");

    await launchCinderfenWatch(page);
    await expect(page.getByTestId("battle-status")).toContainText("Cinderfen Watchpost");
    await expect(page.getByTestId("battle-status")).toContainText("Normal");
    await expect(page.getByTestId("battle-objectives")).toContainText("Capture the Watch Road");
    await expect(page.getByTestId("battle-objectives")).toContainText("Clear the Marsh Raider Camp");
    await expect(page.getByTestId("battle-objectives")).toContainText("Destroy the Watchpost Tower");

    const battleState = await page.evaluate(() => {
      const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.scene.isActive()) {
        throw new Error("BattleScene is not active.");
      }
      scene.update(performance.now(), 250);
      return {
        mapName: scene.activeMap.name,
        campaignNodeId: scene.launch.request.campaignNodeId,
        mode: scene.launch.request.mode,
        rewardTableId: scene.launch.rewardTableId,
        captureSites: scene.activeMap.captureSites.map((site: any) => site.id),
        neutralCamps: scene.activeMap.neutralCamps.map((camp: any) => camp.id),
        objectives: scene.runtime.setup.secondaryObjectiveIds,
        modifiers: scene.launch.request.modifiers.map((modifier: any) => modifier.id),
        minimapMarkers: scene.createMinimapSnapshot().markers.length,
        playerMilitiaCount: scene.units.filter((unit: any) => unit.team === "player" && unit.definition.id === "militia").length,
        difficulty: scene.launch.request.difficulty,
        resources: scene.resources.player
      };
    });
    expect(battleState).toMatchObject({
      mapName: "Cinderfen Watchpost",
      campaignNodeId: "cinderfen_watch",
      mode: "campaign_node",
      rewardTableId: "cinderfen_watchpost_rewards",
      difficulty: "normal"
    });
    expect(battleState.captureSites).toEqual(expect.arrayContaining(["watch_road_toll", "blackreed_stonecut", "ash_cistern"]));
    expect(battleState.neutralCamps).toEqual(expect.arrayContaining(["marsh_raider_camp", "watch_road_pickets"]));
    expect(battleState.objectives).toEqual(
      expect.arrayContaining(["capture_watch_road", "clear_marsh_raider_camp", "destroy_watchpost_tower"])
    );
    expect(battleState.modifiers).toContain("marsh_guides");
    expect(battleState.playerMilitiaCount).toBe(3);
    expect(battleState.minimapMarkers).toBeGreaterThan(0);
    expect(battleState.resources).toMatchObject({ crowns: 500, stone: 335, iron: 205, aether: 115 });
    save = await readStoredSave(page);
    expect(save.campaign.activeModifierIds).not.toContain("marsh_guides");

    const completed = await completeCinderfenWatchVictory(page);
    expect(completed).toMatchObject({
      watchRoadOwner: "player",
      marshBruteAlive: false,
      watchtowerAlive: false,
      enemyStrongholdAlive: false
    });
    expect(completed.completedObjectiveIds).toEqual(
      expect.arrayContaining(["capture_watch_road", "clear_marsh_raider_camp", "destroy_watchpost_tower"])
    );

    const resultsPanel = page.locator(".results-panel");
    await expect(resultsPanel).toContainText("Victory");
    await expect(resultsPanel).toContainText("Cinderfen Watchpost");
    await expect(resultsPanel).toContainText("Reward XP");
    await expect(resultsPanel).toContainText("66");
    await expect(resultsPanel).toContainText("34 Crowns, 20 Stone, 16 Iron, 10 Aether");
    await expect(page.locator(".campaign-reward-block")).toContainText("Cinderfen Watch");
    await expect(page.locator(".campaign-reward-block")).toContainText("Cinderfen Aftermath");
    await expect(page.locator(".campaign-reward-block")).toContainText("Node XP");
    await expect(page.locator(".campaign-reward-block")).toContainText("62");
    await expect(page.locator(".campaign-reward-block")).toContainText("40 Crowns, 22 Stone, 18 Iron, 10 Aether");
    const objectiveSummary = page.locator(".special-objectives");
    await expect(objectiveSummary).toContainText("Capture the Watch Road");
    await expect(objectiveSummary).toContainText("Clear the Marsh Raider Camp");
    await expect(objectiveSummary).toContainText("Destroy the Watchpost Tower");

    save = await readStoredSave(page);
    expect(save.campaign.completedNodeIds).toContain("cinderfen_watch");
    expect(save.campaign.nodeRewardsClaimedIds).toContain("cinderfen_watch");
    expect(save.campaign.resources).toMatchObject({ crowns: 250, stone: 222, iron: 168, aether: 90 });
    expect(save.hero.xp).toBe(798);
    expect(save.hero.completedBattles).toBe(7);
    expect(save.hero.clearedMapIds).toContain("cinderfen_watchpost");
    const rewardSnapshot = {
      resources: save.campaign.resources,
      xp: save.hero.xp,
      inventoryCount: save.hero.inventory.length
    };

    await page.getByRole("button", { name: "Campaign Map" }).click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await expect(page.getByTestId("campaign-node-cinderfen_watch")).toContainText(/Completed/i);
    await expect(page.getByTestId("campaign-node-cinderfen_aftermath")).toContainText(/Available/i);
    await page.getByTestId("campaign-node-cinderfen_watch").click();
    await expect(page.getByTestId("campaign-start-node")).toBeDisabled();
    await page.getByTestId("campaign-node-cinderfen_aftermath").click();
    await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Aftermath");
    await expect(page.locator(".campaign-node-details")).toContainText("Secure the Watch Road");
    await expect(page.locator(".campaign-node-details")).toContainText("Aid the Fenfolk");
    await expect(page.locator(".campaign-node-details")).toContainText("Study the Ashen Marks");
    await expect(page.locator("button[data-campaign-choice='aid_the_fenfolk']")).toContainText("Cost: 40 Crowns");
    await expect(page.locator("button[data-campaign-choice='aid_the_fenfolk']")).toContainText("Reputation: +5 Common Folk");
    await page.locator("button[data-campaign-choice='aid_the_fenfolk']").click();
    await expect(page.getByTestId("campaign-status")).toContainText("Aid the Fenfolk chosen");
    await expect(page.getByTestId("campaign-status")).toContainText("Cinderfen route secured");
    await expect(page.getByTestId("campaign-status")).toContainText("Chapter 2 route complete");
    await expect(page.getByTestId("campaign-status")).toContainText("future Cinderfen roads");
    await expect(page.locator(".guidance-card").filter({ hasText: "Cinderfen route secured" })).toContainText(
      "Chapter 2 route complete"
    );
    await expect(page.getByTestId("campaign-node-cinderfen_aftermath")).toContainText(/Completed/i);
    save = await readStoredSave(page);
    expect(save.campaign.completedNodeIds).toContain("cinderfen_aftermath");
    expect(save.campaign.choiceIdsClaimed).toContain("cinderfen_aftermath:aid_the_fenfolk");
    expect(save.campaign.resources).toMatchObject({ crowns: 210, stone: 222, iron: 176, aether: 90 });
    expect(save.campaign.resourcesSpent.crowns).toBe(130);
    expect(save.hero.xp).toBe(810);
    expect(save.hero.factionReputation.common_folk).toBe(36);
    const aftermathSnapshot = {
      resources: save.campaign.resources,
      xp: save.hero.xp,
      reputation: save.hero.factionReputation.common_folk
    };

    await page.getByTestId("campaign-node-cinderfen_aftermath").click();
    await expect(page.locator("button[data-campaign-choice='aid_the_fenfolk']")).toBeDisabled();
    await expect(page.locator("button[data-campaign-choice='aid_the_fenfolk']")).toContainText("Already chosen");
    save = await readStoredSave(page);
    expect(save.campaign.resources).toMatchObject(aftermathSnapshot.resources);
    expect(save.hero.xp).toBe(aftermathSnapshot.xp);
    expect(save.hero.factionReputation.common_folk).toBe(aftermathSnapshot.reputation);
    expect(save.hero.inventory).toHaveLength(rewardSnapshot.inventoryCount);
  });

  test("post-Ashen Cinderfen event reacts to Malrec's trophy standard", async ({ page }) => {
    await seedPostAshenCampaign(page, { includeMalrecTrophy: true });

    await page.getByTestId("menu-continue-campaign").click();
    await expect(page.getByTestId("campaign-map")).toBeVisible();
    await page.getByTestId("campaign-node-cinderfen_overlook").click();

    const standardChoice = page.locator("button[data-campaign-choice='raise_malrecs_standard']");
    await expect(standardChoice).toBeEnabled();
    await expect(standardChoice).toContainText("Raise Malrec's Standard");
    await expect(standardChoice).toContainText("Cost: None");
    await expect(standardChoice).toContainText("Rewards: 10 XP");
    await expect(standardChoice).toContainText("Reputation: +3 The Free Marches");
    await expect(standardChoice).toContainText("Modifiers: Gain Well Rested");
    await expect(standardChoice).toContainText("Completes this node");
    await expect(standardChoice).not.toContainText("Requires trophy");

    await completeCinderfenOverlookChoice(page, "raise_malrecs_standard", "Raise Malrec's Standard chosen");
    await expect(page.getByTestId("campaign-node-cinderfen_overlook")).toContainText(/Completed/i);
    await expect(page.getByTestId("campaign-node-cinderfen_waystation")).toContainText(/Available/i);
    await expect(page.getByTestId("campaign-node-cinderfen_crossing")).toContainText(/Available/i);
    await expect(standardChoice).toBeDisabled();
    await expect(standardChoice).toContainText("Already chosen");

    const save = await readStoredSave(page);
    expect(save.campaign.completedNodeIds).toContain("cinderfen_overlook");
    expect(save.campaign.choiceIdsClaimed).toContain("cinderfen_overlook:raise_malrecs_standard");
    expect(save.campaign.rivalTrophies.map((trophy: any) => trophy.trophyId)).toEqual(["trophy_malrec_outpost_standard"]);
    expect(save.campaign.activeModifierIds).toContain("well_rested");
    expect(save.hero.xp).toBe(530);
    expect(save.hero.factionReputation.free_marches).toBe(28);
    expect(save.campaign.resources).toMatchObject({ crowns: 260, stone: 180, iron: 120, aether: 80 });
  });

  test("skirmish setup lists maps and launches Broken Ford", async ({ page }) => {
    await openFreshMainMenu(page);
    await page.getByTestId("menu-skirmish").click();
    await createHero(page, "E2E Skirmish");

    await expect(page.getByTestId("skirmish-setup")).toBeVisible();
    await expect(page.getByTestId("setup-map-first_claim")).toBeVisible();
    await expect(page.getByTestId("setup-map-broken_ford")).toBeVisible();
    await expect(page.getByTestId("setup-map-ashen_outpost")).toBeVisible();
    await expect(page.getByTestId("setup-map-cinderfen_causeway")).toBeVisible();
    await expect(page.getByTestId("setup-map-cinderfen_watchpost")).toBeVisible();
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
    await seedCampaignSave(page, { hero: { heroName: "E2E Inventory" } });

    await expect(page.getByTestId("menu-inventory")).toBeEnabled();
    await page.getByTestId("menu-inventory").click();
    await expect(page.getByTestId("hero-inventory")).toBeVisible();
    await expect(page.getByTestId("hero-stats")).toBeVisible();
    await expect(page.getByTestId("equipment-panel")).toBeVisible();
    await expect(page.getByTestId("inventory-list")).toBeVisible();
  });
});
