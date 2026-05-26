import { expect, type Page } from "@playwright/test";
import { clickReady, expectBattleLoaded, seedSaveBeforeAppBoot, SAVE_KEY } from "./shared-helpers";

const EMPTY_RESOURCES = { crowns: 0, stone: 0, iron: 0, aether: 0 };
const SCENE_TRANSITION_CLICK_OPTIONS = {
  allowTargetGoneAfterClick: true,
  attempts: 1,
  domFallbackTimeoutMs: 2_000,
  normalClickTimeoutMs: 1_500
} as const;
const ONE_SHOT_CHOICE_CLICK_OPTIONS = {
  allowTargetDisabledAfterClick: true
} as const;
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

async function campaignStatusIncludes(page: Page, expectedStatusText: string): Promise<boolean> {
  const text = await page
    .getByTestId("campaign-status")
    .textContent({ timeout: 1_000 })
    .catch(() => "");
  return text?.includes(expectedStatusText) ?? false;
}

// Test-only seed helper: writes a known post-Ashen campaign save so Chapter 2 specs do not replay Chapter 1.
export async function seedPostAshenCampaign(page: Page, options: SeedPostAshenOptions = {}): Promise<void> {
  const save = {
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
            resourcesSpent: EMPTY_RESOURCES,
            completedNodeIds: CHAPTER_ONE_COMPLETED_NODE_IDS,
            unlockedNodeIds: POST_ASHEN_UNLOCKED_NODE_IDS,
            lockedNodeIds: [],
            nodeRewardsClaimedIds: CHAPTER_ONE_COMPLETED_NODE_IDS,
            choiceIdsClaimed: [],
            townServiceClaimedIds: [],
            townServiceUseCounts: {},
            activeModifierIds: [],
            strongholdUpgradeRanks: {},
            retinueUnits: [],
            rivals: [],
            rivalTrophies: options.includeMalrecTrophy === true
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
        };
  await seedSaveBeforeAppBoot(page, "seedPostAshenCampaign", save);
  await expect(page.getByTestId("menu-continue-campaign")).toBeEnabled();
}

// Test-only seed helper: starts the Watch spec after Crossing rewards have already persisted.
export async function seedPostCinderfenCrossingCampaign(page: Page): Promise<void> {
  const completedNodeIds = [...CHAPTER_ONE_COMPLETED_NODE_IDS, "cinderfen_overlook", "cinderfen_crossing"];
  const unlockedNodeIds = [
    ...CHAPTER_ONE_COMPLETED_NODE_IDS,
    "cinderfen_overlook",
    "cinderfen_waystation",
    "cinderfen_crossing",
    "cinderfen_watch"
  ];
  const save = {
          version: 2,
          createdAt: "2026-05-03T12:00:00.000Z",
          updatedAt: "2026-05-03T12:00:00.000Z",
          hero: {
            heroName: "E2E Cinderfen Watch",
            classId: "warlord",
            originId: "exiled_noble",
            level: 4,
            xp: 680,
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
            resourcesSpent: { ...EMPTY_RESOURCES, crowns: 55, aether: 12 },
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
        };
  await seedSaveBeforeAppBoot(page, "seedPostCinderfenCrossingCampaign", save);
  await expect(page.getByTestId("menu-continue-campaign")).toBeEnabled();
}

// Test-only seed helper: creates a frozen v0.3 route-complete save for readability checks without replaying battles.
export async function seedCompletedCinderfenRouteCampaign(page: Page): Promise<void> {
  const completedNodeIds = [
    ...CHAPTER_ONE_COMPLETED_NODE_IDS,
    "cinderfen_overlook",
    "cinderfen_crossing",
    "cinderfen_watch",
    "cinderfen_aftermath"
  ];
  const unlockedNodeIds = [
    ...CHAPTER_ONE_COMPLETED_NODE_IDS,
    "cinderfen_overlook",
    "cinderfen_waystation",
    "cinderfen_crossing",
    "cinderfen_watch",
    "cinderfen_aftermath"
  ];
  const save = {
          version: 2,
          createdAt: "2026-05-05T23:00:00.000Z",
          updatedAt: "2026-05-05T23:00:00.000Z",
          hero: {
            heroName: "E2E Route Complete",
            classId: "warlord",
            originId: "exiled_noble",
            level: 4,
            xp: 820,
            skillPoints: 3,
            unlockedAbilities: ["rally_banner"],
            completedBattles: 7,
            clearedMapIds: ["first_claim", "broken_ford", "ashen_outpost", "cinderfen_causeway", "cinderfen_watchpost"],
            inventory: [
              {
                instanceId: "e2e-weathered-command-sword",
                itemId: "weathered_command_sword",
                acquiredAt: "2026-05-05T23:00:00.000Z",
                source: "e2e_seed",
                affixes: []
              },
              {
                instanceId: "e2e-scouts-bow",
                itemId: "scouts_bow",
                acquiredAt: "2026-05-05T23:05:00.000Z",
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
              common_folk: 36,
              old_faith: 25
            },
            stats: { might: 11, command: 10, arcana: 2, faith: 3 }
          },
          campaign: {
            started: true,
            difficulty: "normal",
            resources: { crowns: 210, stone: 222, iron: 176, aether: 90 },
            resourcesSpent: { ...EMPTY_RESOURCES, crowns: 130, aether: 12 },
            completedNodeIds,
            unlockedNodeIds,
            lockedNodeIds: [],
            nodeRewardsClaimedIds: completedNodeIds,
            choiceIdsClaimed: ["cinderfen_overlook:aid_marsh_refugees", "cinderfen_aftermath:aid_the_fenfolk"],
            townServiceClaimedIds: [],
            townServiceUseCounts: {
              "cinderfen_waystation:marsh_guides": 1,
              "cinderfen_waystation:shrine_attunement": 1
            },
            activeModifierIds: [],
            strongholdUpgradeRanks: { training_yard_i: 1, training_yard_ii: 1 },
            retinueUnits: [
              {
                retinueUnitId: "retinue:e2e:cinderfen_militia",
                unitTypeId: "militia",
                name: "Cinderfen Militia",
                rank: "veteran",
                xp: 140,
                kills: 3,
                sourceBattleId: "cinderfen_watch",
                acquiredAt: "2026-05-05T23:08:00.000Z",
                status: "active"
              },
              {
                retinueUnitId: "retinue:e2e:cinderfen_ranger",
                unitTypeId: "ranger",
                name: "Fen Road Ranger",
                rank: "seasoned",
                xp: 80,
                kills: 2,
                sourceBattleId: "cinderfen_crossing",
                acquiredAt: "2026-05-05T23:06:00.000Z",
                status: "active"
              }
            ],
            rivals: [
              {
                enemyHeroId: "captain_malrec",
                encounters: 1,
                defeats: 1,
                victoriesAgainstPlayer: 0,
                lastEncounterNodeId: "ashen_outpost",
                lastOutcome: "defeated",
                disposition: "humiliated",
                activeModifiers: [],
                isKnownToPlayer: true
              }
            ],
            rivalTrophies: [
              {
                trophyId: "trophy_malrec_outpost_standard",
                enemyHeroId: "captain_malrec",
                earnedAt: "2026-05-05T23:00:00.000Z",
                sourceNodeId: "ashen_outpost",
                label: "Malrec's Outpost Standard",
                description: "The torn fortress standard of Captain Malrec's Ashen Outpost command.",
                effect: "Milestone one-time first-defeat reward claimed."
              }
            ],
            selectedChapterId: "cinderfen_road",
            selectedNodeId: "cinderfen_aftermath"
          },
          settings: {},
          statistics: {}
        };
  await seedSaveBeforeAppBoot(page, "seedCompletedCinderfenRouteCampaign", save);
  await expect(page.getByTestId("menu-continue-campaign")).toBeEnabled();
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
  await clickReady(
    page.locator(`button[data-campaign-choice='${choiceId}']`),
    `complete Cinderfen Overlook ${choiceId}`,
    {
      ...ONE_SHOT_CHOICE_CLICK_OPTIONS,
      successCheckAfterClick: () => campaignStatusIncludes(page, expectedStatusText)
    }
  );
  await expect(page.getByTestId("campaign-status")).toContainText(expectedStatusText);
}

// UI-path helper: opens the Waystation with stable campaign node test IDs.
export async function openCinderfenWaystation(page: Page): Promise<void> {
  await clickReady(page.getByTestId("campaign-node-cinderfen_waystation"), "open Cinderfen Waystation node");
  await expect(page.locator(".campaign-node-details")).toContainText("Cinderfen Waystation");
}

// UI-path helper: buys a Waystation service through the campaign choice button.
export async function buyCinderfenWaystationService(
  page: Page,
  serviceId: CinderfenWaystationServiceId,
  expectedStatusText: string
): Promise<void> {
  await clickReady(page.locator(`button[data-campaign-choice='${serviceId}']`), `buy Cinderfen Waystation ${serviceId}`, {
    successCheckAfterClick: () => campaignStatusIncludes(page, expectedStatusText)
  });
  await expect(page.getByTestId("campaign-status")).toContainText(expectedStatusText);
}

// UI-path helper: launches Crossing via campaign node/start test IDs, then waits for the battle shell.
export async function launchCinderfenCrossing(page: Page): Promise<void> {
  await clickReady(page.getByTestId("campaign-node-cinderfen_crossing"), "launch Cinderfen Crossing node");
  await expect(page.getByTestId("campaign-node-cinderfen_crossing")).toContainText(/Available/i);
  await expect(page.getByTestId("campaign-start-node")).toBeEnabled();
  await clickReady(page.getByTestId("campaign-start-node"), "launch Cinderfen Crossing start", SCENE_TRANSITION_CLICK_OPTIONS);
  await expectBattleLoaded(page, "launch Cinderfen Crossing battle");
}

// UI-path helper: launches Watch via campaign node/start test IDs, then waits for the battle shell.
export async function launchCinderfenWatch(page: Page): Promise<void> {
  await clickReady(page.getByTestId("campaign-node-cinderfen_watch"), "launch Cinderfen Watch node");
  await expect(page.getByTestId("campaign-node-cinderfen_watch")).toContainText(/Available/i);
  await expect(page.getByTestId("campaign-start-node")).toBeEnabled();
  await clickReady(page.getByTestId("campaign-start-node"), "launch Cinderfen Watch start", SCENE_TRANSITION_CLICK_OPTIONS);
  await expectBattleLoaded(page, "launch Cinderfen Watch battle");
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
