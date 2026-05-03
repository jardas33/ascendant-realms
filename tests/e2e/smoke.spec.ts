import { expect, test, type Page } from "@playwright/test";

const SAVE_KEY = "ascendant-realms-save-v1";
type SmokeDifficulty = "story" | "easy" | "normal" | "hard";

const EMPTY_RESOURCES = { crowns: 0, stone: 0, iron: 0, aether: 0 };
const CHAPTER_ONE_COMPLETED_NODE_IDS = [
  "border_village",
  "old_stone_road",
  "marcher_camp",
  "aether_well_ruins",
  "bandit_hillfort",
  "chapel_of_the_marches",
  "refugee_caravan",
  "ashen_outpost"
];
const POST_ASHEN_UNLOCKED_NODE_IDS = [...CHAPTER_ONE_COMPLETED_NODE_IDS, "cinderfen_overlook"];

interface SeedPostAshenOptions {
  includeMalrecTrophy?: boolean;
}

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

async function seedPostAshenCampaign(page: Page, options: SeedPostAshenOptions = {}): Promise<void> {
  await page.goto("/");
  await page.evaluate(
    ({ key, completedNodeIds, unlockedNodeIds, emptyResources, includeMalrecTrophy }) => {
      localStorage.setItem(
        key,
        JSON.stringify({
          version: 2,
          createdAt: "2026-05-03T12:00:00.000Z",
          updatedAt: "2026-05-03T12:00:00.000Z",
          hero: {
            heroName: "E2E Cinderfen",
            classId: "warlord",
            originId: "exiled_noble",
            level: 4,
            xp: 520,
            skillPoints: 3,
            unlockedAbilities: ["rally_banner"],
            completedBattles: 5,
            clearedMapIds: ["first_claim", "broken_ford", "ashen_outpost"],
            inventory: [
              {
                instanceId: "e2e-weathered-command-sword",
                itemId: "weathered_command_sword",
                acquiredAt: "2026-05-03T12:00:00.000Z",
                source: "e2e_seed",
                affixes: []
              }
            ],
            equipment: {},
            allocatedSkills: {},
            factionReputation: {
              free_marches: 25,
              ashen_covenant: -50,
              sylvan_concord: 0,
              common_folk: 25,
              old_faith: 25
            },
            stats: { might: 11, command: 10, arcana: 2, faith: 3 }
          },
          campaign: {
            started: true,
            difficulty: "normal",
            resources: { crowns: 260, stone: 180, iron: 120, aether: 80 },
            resourcesSpent: emptyResources,
            completedNodeIds,
            unlockedNodeIds,
            lockedNodeIds: [],
            nodeRewardsClaimedIds: completedNodeIds,
            choiceIdsClaimed: [],
            townServiceClaimedIds: [],
            townServiceUseCounts: {},
            activeModifierIds: [],
            strongholdUpgradeRanks: {},
            retinueUnits: [],
            rivals: [],
            rivalTrophies: includeMalrecTrophy
              ? [
                  {
                    trophyId: "trophy_malrec_outpost_standard",
                    enemyHeroId: "captain_malrec",
                    earnedAt: "2026-05-03T12:00:00.000Z",
                    sourceNodeId: "ashen_outpost",
                    label: "Malrec's Outpost Standard",
                    description: "The torn fortress standard of Captain Malrec's Ashen Outpost command.",
                    effect: "Milestone one-time first-defeat reward claimed."
                  }
                ]
              : [],
            selectedChapterId: "cinderfen_road",
            selectedNodeId: "cinderfen_overlook"
          },
          settings: {},
          statistics: {}
        })
      );
    },
    {
      key: SAVE_KEY,
      completedNodeIds: CHAPTER_ONE_COMPLETED_NODE_IDS,
      unlockedNodeIds: POST_ASHEN_UNLOCKED_NODE_IDS,
      emptyResources: EMPTY_RESOURCES,
      includeMalrecTrophy: options.includeMalrecTrophy === true
    }
  );
  await page.reload();
  await expect(page.getByTestId("main-menu")).toBeVisible();
}

async function readStoredSave(page: Page): Promise<any> {
  return page.evaluate((key) => {
    const raw = localStorage.getItem(key);
    if (!raw) {
      throw new Error("Expected a saved game.");
    }
    return JSON.parse(raw);
  }, SAVE_KEY);
}

async function expectBattleLoaded(page: Page): Promise<void> {
  await expect(page.getByTestId("battle-hud")).toBeVisible({ timeout: 15_000 });
  await expect(page.getByTestId("battle-resources")).toContainText("Crowns");
  await expect(page.getByTestId("battle-hero-panel")).toBeVisible();
  await expect(page.getByTestId("battle-minimap")).toBeVisible();
  await expect(page.getByTestId("minimap")).toBeVisible();
}

async function completeCinderfenVictory(page: Page): Promise<{
  cinderCrossingOwner: string;
  cinderGuardianBruteAlive: boolean;
  enemyBarracksAlive: boolean;
  enemyStrongholdAlive: boolean;
  completedObjectiveIds: string[];
}> {
  const result = await page.evaluate(() => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    if (scene.activeMap?.id !== "cinderfen_causeway") {
      throw new Error(`Expected Cinderfen Causeway, found ${scene.activeMap?.id ?? "none"}.`);
    }

    const completeSecondary = (type: string, targetId: string, point?: { x: number; y: number }) => {
      if (typeof scene.completeSecondaryObjective === "function") {
        scene.completeSecondaryObjective(type, targetId, point);
        return;
      }
      const objective = scene.activeMap.scenario.objectives.secondaryObjectives?.find(
        (entry: any) => entry.type === type && entry.targetId === targetId
      );
      if (objective) {
        scene.runtime.recordSecondaryObjective(objective.id);
      }
    };

    const cinderCrossing = scene.captureSites.find((site: any) => site.definition.id === "cinder_crossing");
    if (!cinderCrossing) {
      throw new Error("Cinder Shrine capture site was not found.");
    }
    const cinderObjectiveAlreadyComplete = scene.runtime.stats.completedObjectiveIds.includes("capture_cinder_crossing");
    if (cinderCrossing.owner !== "player") {
      cinderCrossing.setOwner("player");
      if (!cinderObjectiveAlreadyComplete) {
        scene.runtime.recordResourceCaptured(cinderCrossing.definition.id);
      }
    }
    if (!cinderObjectiveAlreadyComplete) {
      completeSecondary("capture_site", "cinder_crossing", cinderCrossing.position);
    }

    const cinderBrute = scene.units.find(
      (unit: any) => unit.team === "neutral" && unit.definition.id === "brute" && unit.alive
    );
    if (!cinderBrute) {
      throw new Error("Cinder Guardian Brute was not found.");
    }
    cinderBrute.takeDamage(cinderBrute.maxHp + cinderBrute.armor + 10_000);
    cinderBrute.destroyView?.();
    completeSecondary("defeat_unit", "brute", cinderBrute.position);

    const enemyBarracks = scene.buildings.find(
      (building: any) => building.team === "enemy" && building.definition.id === "enemy_barracks" && building.alive
    );
    if (!enemyBarracks) {
      throw new Error("Enemy Barracks was not found.");
    }
    enemyBarracks.takeDamage(enemyBarracks.maxHp + enemyBarracks.armor + 10_000);
    enemyBarracks.destroyView?.();
    completeSecondary("destroy_building", "enemy_barracks", enemyBarracks.position);

    const enemyStronghold = scene.buildings.find(
      (building: any) => building.team === "enemy" && building.definition.id === "enemy_stronghold" && building.alive
    );
    if (!enemyStronghold) {
      throw new Error("Enemy Stronghold was not found.");
    }
    enemyStronghold.takeDamage(enemyStronghold.maxHp + enemyStronghold.armor + 10_000);
    enemyStronghold.destroyView?.();

    const completedObjectiveIds = [...scene.runtime.stats.completedObjectiveIds];
    const summary = {
      cinderCrossingOwner: cinderCrossing.owner,
      cinderGuardianBruteAlive: cinderBrute.alive,
      enemyBarracksAlive: enemyBarracks.alive,
      enemyStrongholdAlive: enemyStronghold.alive,
      completedObjectiveIds
    };
    scene.checkEndConditions();
    return summary;
  });
  await expect(page.locator(".results-panel")).toBeVisible({ timeout: 15_000 });
  return result;
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

    await expect(page.getByTestId("campaign-chapter-border_marches")).toContainText("Unlocked");
    await expect(page.getByTestId("campaign-chapter-cinderfen_road")).toContainText("Locked");
    await expect(page.getByTestId("campaign-chapter-cinderfen_road")).toContainText("Chapter 2: Cinderfen Road");
    await expect(page.getByTestId("campaign-node-border_village")).toContainText(/Available/i);
    await page.getByTestId("campaign-node-aether_well_ruins").click();
    await expect(page.getByTestId("campaign-node-aether_well_ruins")).toContainText(/Locked/i);
    await expect(page.getByTestId("campaign-start-node")).toBeDisabled();
    await expect(page.getByTestId("campaign-node-cinderfen_overlook")).toContainText(/Locked/i);
    await expect(page.getByTestId("campaign-node-cinderfen_crossing")).toContainText(/Locked/i);
    await page.getByTestId("campaign-node-cinderfen_crossing").click();
    await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Causeway");
    await expect(page.locator(".campaign-node-details")).toContainText("Hexfire Cult");
    await expect(page.locator(".campaign-node-details")).toContainText("Scout's Bow");
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

  test("post-Ashen campaign resolves Cinderfen Overlook, wins Cinderfen Crossing, and persists rewards", async ({ page }) => {
    test.setTimeout(70_000);
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

    await page.locator("button[data-campaign-choice='aid_marsh_refugees']").click();
    await expect(page.getByTestId("campaign-status")).toContainText("Aid the Marsh Refugees chosen");
    await expect(page.getByTestId("campaign-node-cinderfen_overlook")).toContainText(/Completed/i);
    await expect(page.getByTestId("campaign-node-cinderfen_crossing")).toContainText(/Available/i);
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

    await page.getByTestId("campaign-node-cinderfen_crossing").click();
    await expect(page.getByTestId("campaign-node-cinderfen_crossing")).toContainText(/Available/i);
    await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Causeway");
    await expect(page.locator(".campaign-node-details")).toContainText("Normal");
    await expect(page.locator(".campaign-node-details")).toContainText("Hexfire Cult");
    await expect(page.locator(".campaign-node-details")).toContainText("Scout's Bow");
    await expect(page.getByTestId("campaign-start-node")).toBeEnabled();

    await page.getByTestId("campaign-start-node").click();
    await expectBattleLoaded(page);
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
    expect(battleState.playerMilitiaCount).toBe(4);
    expect(battleState.minimapMarkers).toBeGreaterThan(0);
    expect(battleState.resources).toMatchObject({ crowns: 480, stone: 325, iron: 195, aether: 110 });
    save = await readStoredSave(page);
    expect(save.campaign.activeModifierIds).not.toContain("inspired_militia");

    const shrineCapture = await page.evaluate(() => {
      const hook = (window as any).__ASCENDANT_TEST_HOOKS__?.captureSite;
      if (!hook) {
        throw new Error("Missing captureSite test hook.");
      }
      return hook("cinder_crossing");
    });
    expect(shrineCapture).toMatchObject({
      siteId: "cinder_crossing",
      owner: "player",
      firstCaptureBonus: {
        id: "cinder_shrine_surge",
        label: "Cinder Shrine Surge",
        resources: { aether: 20 }
      },
      completedObjectiveIds: expect.arrayContaining(["capture_cinder_crossing"])
    });
    expect(shrineCapture.beforeResources.aether).toBe(110);
    expect(shrineCapture.afterResources.aether).toBe(130);
    expect(shrineCapture.status).toContain("Cinder Shrine Surge");
    await expect(page.getByTestId("battle-status")).toContainText("Cinder Shrine Surge");
    await expect(page.getByTestId("battle-resources")).toContainText("130");

    const duplicateShrineCapture = await page.evaluate(() => {
      const hook = (window as any).__ASCENDANT_TEST_HOOKS__?.captureSite;
      if (!hook) {
        throw new Error("Missing captureSite test hook.");
      }
      return hook("cinder_crossing");
    });
    expect(duplicateShrineCapture.beforeResources.aether).toBe(130);
    expect(duplicateShrineCapture.afterResources.aether).toBe(130);

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
    await expect(page.locator(".campaign-reward-block")).toContainText("No new nodes");
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
    expect(save.campaign.resources).toMatchObject({ crowns: 245, stone: 200, iron: 150, aether: 92 });
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
    await page.getByTestId("campaign-node-cinderfen_crossing").click();
    await expect(page.getByTestId("campaign-start-node")).toBeDisabled();
    await expect(page.locator(".campaign-node-details")).toContainText("Unlocks");
    await expect(page.locator(".campaign-node-details")).toContainText("None");
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
    await page.getByTestId("campaign-node-cinderfen_crossing").click();
    await expect(page.getByTestId("campaign-start-node")).toBeDisabled();
    save = await readStoredSave(page);
    expect(save.campaign.resources).toMatchObject(rewardSnapshot.resources);
    expect(save.hero.xp).toBe(rewardSnapshot.xp);
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

    await standardChoice.click();
    await expect(page.getByTestId("campaign-status")).toContainText("Raise Malrec's Standard chosen");
    await expect(page.getByTestId("campaign-node-cinderfen_overlook")).toContainText(/Completed/i);
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
