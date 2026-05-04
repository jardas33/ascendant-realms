import { expect, type Page } from "@playwright/test";

const SAVE_KEY = "ascendant-realms-save-v1";
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

type CinderfenOverlookChoiceId = "aid_marsh_refugees" | "raise_malrecs_standard";
type CinderfenWaystationServiceId = "ash_filters" | "marsh_guides" | "refugee_scouts" | "shrine_attunement";

// Test-only seed helper: writes a known post-Ashen campaign save so Chapter 2 specs do not replay Chapter 1.
export async function seedPostAshenCampaign(page: Page, options: SeedPostAshenOptions = {}): Promise<void> {
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

// Test-only seed helper: starts the Watch spec after Crossing rewards have already persisted.
export async function seedPostCinderfenCrossingCampaign(page: Page): Promise<void> {
  await page.goto("/");
  await page.evaluate(
    ({ key, completedNodeIds, unlockedNodeIds, emptyResources }) => {
      localStorage.setItem(
        key,
        JSON.stringify({
          version: 2,
          createdAt: "2026-05-03T12:00:00.000Z",
          updatedAt: "2026-05-03T12:00:00.000Z",
          hero: {
            heroName: "E2E Cinderfen Watch",
            classId: "warlord",
            originId: "exiled_noble",
            level: 4,
            xp: 670,
            skillPoints: 3,
            unlockedAbilities: ["rally_banner"],
            completedBattles: 6,
            clearedMapIds: ["first_claim", "broken_ford", "ashen_outpost", "cinderfen_causeway"],
            inventory: [
              {
                instanceId: "e2e-weathered-command-sword",
                itemId: "weathered_command_sword",
                acquiredAt: "2026-05-03T12:00:00.000Z",
                source: "e2e_seed",
                affixes: []
              },
              {
                instanceId: "e2e-scouts-bow",
                itemId: "scouts_bow",
                acquiredAt: "2026-05-03T12:05:00.000Z",
                source: "campaign:cinderfen_crossing",
                affixes: []
              }
            ],
            equipment: {},
            allocatedSkills: {},
            factionReputation: {
              free_marches: 27,
              ashen_covenant: -50,
              sylvan_concord: 0,
              common_folk: 31,
              old_faith: 25
            },
            stats: { might: 11, command: 10, arcana: 2, faith: 3 }
          },
          campaign: {
            started: true,
            difficulty: "normal",
            resources: { crowns: 245, stone: 200, iron: 150, aether: 80 },
            resourcesSpent: { ...emptyResources, crowns: 55, aether: 12 },
            completedNodeIds,
            unlockedNodeIds,
            lockedNodeIds: [],
            nodeRewardsClaimedIds: completedNodeIds,
            choiceIdsClaimed: ["cinderfen_overlook:aid_marsh_refugees"],
            townServiceClaimedIds: [],
            townServiceUseCounts: { "cinderfen_waystation:shrine_attunement": 1 },
            activeModifierIds: [],
            strongholdUpgradeRanks: {},
            retinueUnits: [],
            rivals: [],
            rivalTrophies: [],
            selectedChapterId: "cinderfen_road",
            selectedNodeId: "cinderfen_watch"
          },
          settings: {},
          statistics: {}
        })
      );
    },
    {
      key: SAVE_KEY,
      completedNodeIds: [...CHAPTER_ONE_COMPLETED_NODE_IDS, "cinderfen_overlook", "cinderfen_crossing"],
      unlockedNodeIds: [
        ...CHAPTER_ONE_COMPLETED_NODE_IDS,
        "cinderfen_overlook",
        "cinderfen_waystation",
        "cinderfen_crossing",
        "cinderfen_watch"
      ],
      emptyResources: EMPTY_RESOURCES
    }
  );
  await page.reload();
  await expect(page.getByTestId("main-menu")).toBeVisible();
}

// Test-only save reader used by Chapter 2 persistence assertions.
export async function readStoredSave(page: Page): Promise<any> {
  return page.evaluate((key) => {
    const raw = localStorage.getItem(key);
    if (!raw) {
      throw new Error("Expected a saved game.");
    }
    return JSON.parse(raw);
  }, SAVE_KEY);
}

// UI-path helper: uses the same stable data-campaign-choice selector a player click would exercise.
export async function completeCinderfenOverlookChoice(
  page: Page,
  choiceId: CinderfenOverlookChoiceId,
  expectedStatusText: string
): Promise<void> {
  await page.locator(`button[data-campaign-choice='${choiceId}']`).click();
  await expect(page.getByTestId("campaign-status")).toContainText(expectedStatusText);
}

// UI-path helper: opens the Waystation with stable campaign node test IDs.
export async function openCinderfenWaystation(page: Page): Promise<void> {
  await page.getByTestId("campaign-node-cinderfen_waystation").click();
  await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Waystation");
}

// UI-path helper: buys a Waystation service through the campaign choice button.
export async function buyCinderfenWaystationService(
  page: Page,
  serviceId: CinderfenWaystationServiceId,
  expectedStatusText: string
): Promise<void> {
  await page.locator(`button[data-campaign-choice='${serviceId}']`).click();
  await expect(page.getByTestId("campaign-status")).toContainText(expectedStatusText);
}

// UI-path helper: launches Crossing via campaign node/start test IDs, then waits for the battle shell.
export async function launchCinderfenCrossing(page: Page): Promise<void> {
  await page.getByTestId("campaign-node-cinderfen_crossing").click();
  await expect(page.getByTestId("campaign-node-cinderfen_crossing")).toContainText(/Available/i);
  await expect(page.getByTestId("campaign-start-node")).toBeEnabled();
  await page.getByTestId("campaign-start-node").click();
  await expectChapter2BattleLoaded(page);
}

// UI-path helper: launches Watch via campaign node/start test IDs, then waits for the battle shell.
export async function launchCinderfenWatch(page: Page): Promise<void> {
  await page.getByTestId("campaign-node-cinderfen_watch").click();
  await expect(page.getByTestId("campaign-node-cinderfen_watch")).toContainText(/Available/i);
  await expect(page.getByTestId("campaign-start-node")).toBeEnabled();
  await page.getByTestId("campaign-start-node").click();
  await expectChapter2BattleLoaded(page);
}

// Safe hook helper: calls the Playwright-only captureSite hook exposed by the game test harness.
export async function captureCinderShrineWithHook(page: Page): Promise<any> {
  return page.evaluate(() => {
    const hook = (window as any).__ASCENDANT_TEST_HOOKS__?.captureSite;
    if (!hook) {
      throw new Error("Missing captureSite test hook.");
    }
    return hook("cinder_crossing");
  });
}

// Test-only fast-forward helper: mutates BattleScene state after launch assertions cover Crossing wiring.
export async function completeCinderfenVictory(page: Page): Promise<{
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

// Test-only fast-forward helper: mutates BattleScene state after launch assertions cover Watch wiring.
export async function completeCinderfenWatchVictory(page: Page): Promise<{
  watchRoadOwner: string;
  marshBruteAlive: boolean;
  watchtowerAlive: boolean;
  enemyStrongholdAlive: boolean;
  completedObjectiveIds: string[];
}> {
  const result = await page.evaluate(() => {
    const scene: any = window.ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.scene.isActive()) {
      throw new Error("BattleScene is not active.");
    }
    if (scene.activeMap?.id !== "cinderfen_watchpost") {
      throw new Error(`Expected Cinderfen Watchpost, found ${scene.activeMap?.id ?? "none"}.`);
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

    const watchRoad = scene.captureSites.find((site: any) => site.definition.id === "watch_road_toll");
    if (!watchRoad) {
      throw new Error("Watch Road Toll capture site was not found.");
    }
    const watchObjectiveAlreadyComplete = scene.runtime.stats.completedObjectiveIds.includes("capture_watch_road");
    if (watchRoad.owner !== "player") {
      watchRoad.setOwner("player");
      if (!watchObjectiveAlreadyComplete) {
        scene.runtime.recordResourceCaptured(watchRoad.definition.id);
      }
    }
    if (!watchObjectiveAlreadyComplete) {
      completeSecondary("capture_site", "watch_road_toll", watchRoad.position);
    }

    const marshBrute = scene.units.find(
      (unit: any) => unit.team === "neutral" && unit.definition.id === "brute" && unit.alive
    );
    if (!marshBrute) {
      throw new Error("Marsh Raider Camp Brute was not found.");
    }
    marshBrute.takeDamage(marshBrute.maxHp + marshBrute.armor + 10_000);
    marshBrute.destroyView?.();
    completeSecondary("defeat_unit", "brute", marshBrute.position);

    const watchtower = scene.buildings.find(
      (building: any) => building.team === "enemy" && building.definition.id === "watchtower" && building.alive
    );
    if (!watchtower) {
      throw new Error("Watchpost Tower was not found.");
    }
    watchtower.takeDamage(watchtower.maxHp + watchtower.armor + 10_000);
    watchtower.destroyView?.();
    completeSecondary("destroy_building", "watchtower", watchtower.position);

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
      watchRoadOwner: watchRoad.owner,
      marshBruteAlive: marshBrute.alive,
      watchtowerAlive: watchtower.alive,
      enemyStrongholdAlive: enemyStronghold.alive,
      completedObjectiveIds
    };
    scene.checkEndConditions();
    return summary;
  });
  await expect(page.locator(".results-panel")).toBeVisible({ timeout: 15_000 });
  return result;
}

async function expectChapter2BattleLoaded(page: Page): Promise<void> {
  await expect(page.getByTestId("battle-hud")).toBeVisible({ timeout: 30_000 });
  await expect(page.getByTestId("battle-resources")).toContainText("Crowns");
  await expect(page.getByTestId("battle-hero-panel")).toBeVisible();
  await expect(page.getByTestId("battle-minimap")).toBeVisible();
  await expect(page.getByTestId("minimap")).toBeVisible();
}
