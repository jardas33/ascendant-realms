import { describe, expect, it } from "vitest";
import { BUILDING_BY_ID, UNIT_BY_ID } from "../../data/contentIndex";
import { Building } from "../../entities/Building";
import { CaptureSite } from "../../entities/CaptureSite";
import { Unit } from "../../entities/Unit";
import { renderCommandActions } from "./CommandPanel";
import type { HUDSnapshot } from "./HudTypes";

describe("CommandPanel", () => {
  it("keeps the Command Hall Worker-only and moves basic army actions to Barracks", () => {
    const commandHall = fakeBuilding("player-command-hall", "command_hall");
    const barracks = fakeBuilding("player-barracks", "barracks");

    const commandHallMarkup = renderCommandActions(commandHall, fakeSnapshot(["command_hall"]));
    const barracksMarkup = renderCommandActions(barracks, fakeSnapshot(["command_hall", "barracks"]));

    expect(commandHallMarkup).not.toContain('data-command-kind="build"');
    expect(commandHallMarkup).toContain('data-testid="command-train-worker"');
    expect(commandHallMarkup).not.toContain('data-testid="command-train-militia"');
    expect(commandHallMarkup).not.toContain('data-testid="command-train-ranger"');
    expect(commandHallMarkup).not.toContain('data-testid="command-train-acolyte"');
    expect(commandHallMarkup).not.toContain('data-testid="command-upgrade-infantry_weapons_1"');
    expect(commandHallMarkup).not.toContain('data-testid="command-upgrade-reinforced_armor_1"');
    expect(commandHallMarkup).not.toContain('data-testid="command-upgrade-ranger_training_1"');
    expect(commandHallMarkup).not.toContain('data-testid="command-upgrade-aether_study_1"');
    expect(commandHallMarkup).toContain('data-testid="command-upgrade-camp_foundations_1"');
    expect(commandHallMarkup).toContain("Owner: Command Hall");
    expect(commandHallMarkup).toContain("Effect: Base hub: +1 armor.");
    expect(commandHallMarkup).toContain("Cost: 50 Crowns");
    expect(commandHallMarkup).toContain("Base hub: trains Workers only, anchors the camp, and researches core upgrades.");
    expect(barracksMarkup).toContain('data-testid="command-train-militia"');
    expect(barracksMarkup).toContain('data-testid="command-train-ranger"');
    expect(barracksMarkup).toContain('data-testid="command-upgrade-infantry_weapons_1"');
    expect(barracksMarkup).toContain('data-testid="command-upgrade-reinforced_armor_1"');
    expect(barracksMarkup).toContain('data-testid="command-upgrade-ranger_training_1"');
    expect(barracksMarkup).toContain("Cost: 60 Crowns, 20 Iron");
    expect(barracksMarkup).toContain("Cost: 120 Crowns, 70 Iron");
    expect(barracksMarkup).toContain("Owner: Barracks");
    expect(barracksMarkup).toContain("Requires: completed Barracks");
    expect(barracksMarkup).toContain("Frontline / Melee");
    expect(barracksMarkup).toContain("Tags: Frontline / Melee / Holds Ground");
    expect(barracksMarkup).toContain("Ranged / Focus Fire");
  });

  it("keeps costs visible when a command is locked", () => {
    const commandHall = fakeBuilding("player-command-hall", "command_hall");

    const markup = renderCommandActions(
      commandHall,
      fakeSnapshot(["command_hall"], { crowns: 0, stone: 0, iron: 0, aether: 0 })
    );

    expect(markup).toContain("Insufficient resources. Cost: 50 Crowns");
    expect(markup).toContain("Insufficient resources. Cost: 90 Crowns, 70 Stone");
    expect(markup).not.toContain("Insufficient resources. Cost: 120 Crowns, 70 Iron");
  });

  it("keeps long command copy behind compact details without removing accessible labels", () => {
    const barracks = fakeBuilding("player-barracks", "barracks");

    const markup = renderCommandActions(barracks, fakeSnapshot(["command_hall", "barracks"]));

    expect(markup).toContain('class="command-entry ready"');
    expect(markup).toContain("command-details");
    expect(markup).toContain('aria-describedby="command-details-train-militia"');
    expect(markup).toContain("Show command details for Train Militia");
    expect(markup).toContain("Tags: Frontline / Melee / Holds Ground");
    expect(markup).not.toContain("command-description");
    expect(markup).not.toContain("command-effect");
  });

  it("explains incomplete building roles and unlocks without exposing completed actions", () => {
    const cases = [
      {
        site: fakeBuilding("player-barracks-site", "barracks", false),
        role: "Army production: trains Militia and Rangers and researches basic troop upgrades.",
        unlocks: "Unlocks when complete: trains Militia, Ranger; researches Infantry Weapons I, Reinforced Armor I, Ranger Training I."
      },
      {
        site: fakeBuilding("player-mystic-site", "mystic_lodge", false),
        role: "Mystic support: trains Acolytes and researches Aether Study I.",
        unlocks: "Unlocks when complete: trains Acolyte; researches Aether Study I."
      },
      {
        site: fakeBuilding("player-watchtower-site", "watchtower", false),
        role: "Defense: inactive while incomplete, attacks nearby enemies when complete, and researches tower defenses.",
        unlocks: "Unlocks when complete: researches Sentry Bracing I; defensive attack (14 damage, 220 range)."
      }
    ];

    cases.forEach(({ site, role, unlocks }) => {
      const markup = renderCommandActions(site, fakeSnapshot(["command_hall"]));

      expect(markup).toContain("Construction");
      expect(markup).toContain(role);
      expect(markup).toContain(unlocks);
      expect(markup).toContain("Incomplete - completed-building actions locked.");
      expect(markup).toContain("Select a Worker and right-click this site to continue construction.");
      expect(markup).not.toContain('data-action="train"');
      expect(markup).not.toContain('data-action="upgrade"');
    });
  });

  it("shows locked, researching, and researched upgrade states with tech-tree copy", () => {
    const watchtower = fakeBuilding("player-watchtower", "watchtower");

    const lockedMarkup = renderCommandActions(watchtower, fakeSnapshot(["command_hall", "watchtower"]));
    expect(lockedMarkup).toContain('data-testid="command-upgrade-sentry_bracing_1"');
    expect(lockedMarkup).toContain("Requires Camp Foundations 1. Cost: 90 Crowns, 80 Stone, 40 Iron");
    expect(lockedMarkup).toContain("Owner: Watchtower");
    expect(lockedMarkup).toContain("Requires: completed Watchtower, Camp Foundations I");
    expect(lockedMarkup).toContain("Effect: Watchtowers: +1 armor.");

    watchtower.upgradeQueue = [{ upgradeId: "sentry_bracing_1", remaining: 10, total: 20, announce: true, paidCost: {} }];
    const queuedMarkup = renderCommandActions(watchtower, fakeSnapshot(["command_hall", "watchtower"], undefined, ["camp_foundations_1"]));
    expect(queuedMarkup).toContain("Researching. Cost: 90 Crowns, 80 Stone, 40 Iron");

    watchtower.upgradeQueue = [];
    const researchedMarkup = renderCommandActions(
      watchtower,
      fakeSnapshot(["command_hall", "watchtower"], undefined, ["camp_foundations_1", "sentry_bracing_1"])
    );
    expect(researchedMarkup).toContain("Researched. Cost: 90 Crowns, 80 Stone, 40 Iron");
  });

  it("shows Mystic Lodge train and research ownership only when complete", () => {
    const incompleteMarkup = renderCommandActions(fakeBuilding("player-mystic-site", "mystic_lodge", false), fakeSnapshot(["command_hall"]));
    const completedMarkup = renderCommandActions(fakeBuilding("player-mystic-lodge", "mystic_lodge"), fakeSnapshot(["command_hall", "mystic_lodge"]));

    expect(incompleteMarkup).not.toContain('data-testid="command-train-acolyte"');
    expect(incompleteMarkup).not.toContain('data-testid="command-upgrade-aether_study_1"');
    expect(completedMarkup).toContain('data-testid="command-train-acolyte"');
    expect(completedMarkup).toContain('data-testid="command-upgrade-aether_study_1"');
    expect(completedMarkup).toContain("A simple rite improves Acolyte focus");
  });

  it("renders Worker building commands without production queues", () => {
    const worker = fakeWorker();

    const markup = renderCommandActions(worker, fakeSnapshot(["command_hall"]));

    expect(markup).toContain('data-testid="command-build-barracks"');
    expect(markup).toContain("Build Barracks");
    expect(markup).toContain("Cost: 180 Crowns, 120 Stone");
    expect(markup).toContain('data-testid="command-build-mystic_lodge"');
    expect(markup).toContain("Build Mystic Lodge");
    expect(markup).toContain("Cost: 160 Crowns, 100 Stone, 80 Aether");
    expect(markup).toContain('data-testid="command-build-watchtower"');
    expect(markup).toContain("Build Watchtower");
    expect(markup).toContain("Cost: 120 Crowns, 100 Stone, 40 Iron");
    expect(markup).not.toContain('data-action="train"');
    expect(markup).not.toContain('data-action="upgrade"');
  });

  it("renders Worker repair commands for damaged completed friendly buildings", () => {
    const worker = fakeWorker();

    const markup = renderCommandActions(
      worker,
      fakeSnapshot(["command_hall"], undefined, [], [
        {
          id: "player-barracks",
          name: "Barracks",
          hp: 420,
          maxHp: 600,
          isRepairable: true,
          status: "Damaged: 420/600 HP"
        },
        {
          id: "player-command-hall",
          name: "Command Hall",
          hp: 1450,
          maxHp: 1450,
          isRepairable: false,
          status: "Full health"
        }
      ])
    );

    expect(markup).toContain('data-testid="command-repair-player-barracks"');
    expect(markup).toContain("Repair Barracks");
    expect(markup).toContain('data-command-state="ready"');
    expect(markup).toContain("Damaged: 420/600 HP. Cost: none");
    expect(markup).toContain("move or attack orders stop repair until Repair is issued again");
    expect(markup).toContain("Full health. HP 1450/1450");
    expect(markup).toContain('data-disabled-reason="Full health"');
  });

  it("renders Worker resource-site assignment commands with invalid site reasons", () => {
    const worker = fakeWorker();

    const markup = renderCommandActions(
      worker,
      fakeSnapshot(["command_hall"], undefined, [], [], [
        fakeResourceSiteSummary({
          id: "crown_shrine",
          name: "Crown Shrine",
          resource: "crowns",
          owner: "player",
          baseIncomeAmount: 30,
          incomeInterval: 5,
          workerBonusPerWorkerAmount: 6,
          totalIncomeAmount: 30,
          isAssignable: true,
          status: "Captured - empty Worker slot"
        }),
        fakeResourceSiteSummary({
          id: "stone_quarry",
          name: "Stone Quarry",
          resource: "stone",
          owner: "neutral",
          baseIncomeAmount: 25,
          incomeInterval: 5,
          workerBonusPerWorkerAmount: 5,
          totalIncomeAmount: 25,
          isAssignable: false,
          status: "Neutral - capture before assigning a Worker"
        })
      ])
    );

    expect(markup).toContain('data-testid="command-assign-resource-site-crown_shrine"');
    expect(markup).toContain("Assign Crown Shrine");
    expect(markup).toContain("Level 1. Slots 0/1. Total +30/5s");
    expect(markup).toContain("Base +30, upgrade +0, Workers +0.");
    expect(markup).toContain("Neutral - capture before assigning a Worker");
    expect(markup).toContain('data-testid="command-assign-resource-site-stone_quarry"');
    expect(markup).toContain('data-disabled-reason="Capture before assigning"');
    expect(markup).toContain("disabled");
  });

  it("keeps a filled resource-site Worker slot locked for other Workers", () => {
    const worker = fakeWorker();

    const markup = renderCommandActions(
      worker,
      fakeSnapshot(["command_hall"], undefined, [], [], [
        fakeResourceSiteSummary({
          id: "crown_shrine",
          name: "Crown Shrine",
          resource: "crowns",
          owner: "player",
          baseIncomeAmount: 30,
          incomeInterval: 5,
          workerBonusAmount: 6,
          totalIncomeAmount: 36,
          workerSlotsUsed: 1,
          workerSlotsAvailable: 0,
          workerSlots: [{ workerId: "other-worker", workerName: "Worker", status: "Worker working", boostActive: true }],
          assignedWorkerId: "other-worker",
          assignedWorkerName: "Worker",
          isAssignable: false,
          status: "Worker working"
        })
      ])
    );

    expect(markup).toContain("Worker working");
    expect(markup).toContain('data-disabled-reason="Worker slots full"');
    expect(markup).toContain("disabled");
  });

  it("renders captured resource-site upgrade commands with cost and slot effect", () => {
    const site = fakeCaptureSite("crown_shrine");

    const markup = renderCommandActions(
      site,
      fakeSnapshot(["command_hall"], undefined, [], [], [
        fakeResourceSiteSummary({
          id: "crown_shrine",
          name: "Crown Shrine",
          resource: "crowns",
          owner: "player",
          level: 1,
          baseIncomeAmount: 30,
          incomeInterval: 5,
          workerBonusPerWorkerAmount: 6,
          totalIncomeAmount: 30,
          upgradeStatus: "Upgrade to Level 2: +income and 2 Worker slots."
        })
      ])
    );

    expect(markup).toContain('data-testid="command-upgrade-resource-site-crown_shrine"');
    expect(markup).toContain("Upgrade Crown Shrine");
    expect(markup).toContain("Cost: 120 Crowns, 80 Stone");
    expect(markup).toContain("adds a modest income bonus and unlocks a second Worker slot");
  });

  it("keeps Worker building costs visible when a structure is unaffordable", () => {
    const worker = fakeWorker();

    const markup = renderCommandActions(
      worker,
      fakeSnapshot(["command_hall"], { crowns: 380, stone: 255, iron: 140, aether: 75 })
    );

    expect(markup).toContain('data-testid="command-build-barracks"');
    expect(markup).toContain('data-testid="command-build-watchtower"');
    expect(markup).toContain("Insufficient resources. Cost: 160 Crowns, 100 Stone, 80 Aether");
  });

  it("renders a compact Patrol command for combat-capable selected units", () => {
    const militia = fakeCombatUnit("player-militia", "militia");

    const markup = renderCommandActions(undefined, {
      ...fakeSnapshot(["command_hall"]),
      selected: [militia]
    });

    expect(markup).toContain('data-action="patrol"');
    expect(markup).toContain('data-action="stop"');
    expect(markup).toContain('data-testid="command-patrol-selected"');
    expect(markup).toContain('data-testid="command-stop-selected"');
    expect(markup).toContain("Hotkey P");
    expect(markup).toContain("session-only patrol order");
  });

  it("does not show Patrol for Worker-only selections", () => {
    const markup = renderCommandActions(undefined, {
      ...fakeSnapshot(["command_hall"]),
      selected: [fakeWorker()]
    });

    expect(markup).not.toContain('data-action="patrol"');
  });

  it("renders Retinue reinforcement availability and disabled reasons", () => {
    const readyMarkup = renderCommandActions(undefined, {
      ...fakeSnapshot(["command_hall"]),
      retinueReinforcement: {
        available: true,
        cost: { crowns: 75 },
        reserveCount: 2,
        readyReserveCount: 1,
        used: false
      }
    });
    const lockedMarkup = renderCommandActions(undefined, {
      ...fakeSnapshot(["command_hall"]),
      retinueReinforcement: {
        available: false,
        reason: "No Ready reserve Retinue",
        cost: { crowns: 75 },
        reserveCount: 1,
        readyReserveCount: 0,
        used: false
      }
    });

    expect(readyMarkup).toContain('data-action="retinue-reinforcement"');
    expect(readyMarkup).toContain('data-testid="command-retinue-reinforcement-retinue"');
    expect(readyMarkup).toContain("Ready reserves 1/2");
    expect(readyMarkup).toContain("Cost: 75 Crowns");
    expect(lockedMarkup).toContain('data-disabled-reason="No Ready reserve Retinue"');
    expect(lockedMarkup).toContain("No Ready reserve Retinue. Cost: 75 Crowns");
  });
});

function fakeBuilding(id: string, buildingId: string, completed = true): Building {
  const definition = BUILDING_BY_ID[buildingId];
  if (!definition) {
    throw new Error(`Missing building ${buildingId}`);
  }

  return Object.assign(Object.create(Building.prototype), {
    id,
    kind: "building",
    team: "player",
    alive: true,
    definition,
    trainingQueue: [],
    upgradeQueue: [],
    isCompleted: () => completed
  }) as Building;
}

function fakeWorker(): Unit {
  return Object.assign(Object.create(Unit.prototype), {
    id: "player-worker",
    kind: "unit",
    team: "player",
    alive: true,
    definition: UNIT_BY_ID.worker
  }) as Unit;
}

function fakeCombatUnit(id: string, unitId: string): Unit {
  const definition = UNIT_BY_ID[unitId as keyof typeof UNIT_BY_ID];
  if (!definition) {
    throw new Error(`Missing unit ${unitId}`);
  }
  return Object.assign(Object.create(Unit.prototype), {
    id,
    kind: "unit",
    team: "player",
    alive: true,
    definition
  }) as Unit;
}

function fakeCaptureSite(id: string): CaptureSite {
  return Object.assign(Object.create(CaptureSite.prototype), {
    id,
    kind: "capture-site",
    team: "player",
    owner: "player",
    alive: true,
    siteLevel: 1,
    workerAssignments: [],
    definition: {
      id,
      name: "Crown Shrine",
      resource: "crowns",
      x: 850,
      y: 780,
      radius: 76,
      incomeAmount: 30,
      incomeInterval: 5
    }
  }) as CaptureSite;
}

function fakeResourceSiteSummary(
  overrides: Partial<HUDSnapshot["resourceSites"][number]> & Pick<HUDSnapshot["resourceSites"][number], "id" | "name" | "resource" | "owner">
): HUDSnapshot["resourceSites"][number] {
  const baseIncomeAmount = overrides.baseIncomeAmount ?? 30;
  const incomeInterval = overrides.incomeInterval ?? 5;
  const workerBonusPerWorkerAmount = overrides.workerBonusPerWorkerAmount ?? 6;
  const workerBonusAmount = overrides.workerBonusAmount ?? 0;
  const workerSlotCapacity = overrides.workerSlotCapacity ?? 1;
  const workerSlotsUsed = overrides.workerSlotsUsed ?? 0;
  return {
    level: overrides.level ?? 1,
    maxLevel: overrides.maxLevel ?? 2,
    baseIncomeAmount,
    upgradeBonusAmount: overrides.upgradeBonusAmount ?? 0,
    incomeInterval,
    workerBonusAmount,
    workerBonusPerWorkerAmount,
    boostedIncomeAmount: overrides.boostedIncomeAmount ?? baseIncomeAmount + workerBonusAmount,
    totalIncomeAmount: overrides.totalIncomeAmount ?? baseIncomeAmount + workerBonusAmount,
    workerSlotCapacity,
    workerSlotsUsed,
    workerSlotsAvailable: overrides.workerSlotsAvailable ?? Math.max(0, workerSlotCapacity - workerSlotsUsed),
    workerSlots: overrides.workerSlots ?? Array.from({ length: workerSlotCapacity }, () => ({ status: "Empty worker slot", boostActive: false })),
    abstractEnemyWorkerSlotsUsed: overrides.abstractEnemyWorkerSlotsUsed ?? 0,
    assignedWorkerId: overrides.assignedWorkerId,
    assignedWorkerName: overrides.assignedWorkerName,
    isAssignable: overrides.isAssignable ?? overrides.owner === "player",
    status: overrides.status ?? "Captured - empty Worker slot",
    canUpgrade: overrides.canUpgrade ?? overrides.owner === "player",
    upgradeCost: overrides.upgradeCost ?? { crowns: 120, stone: 80 },
    upgradeStatus: overrides.upgradeStatus ?? "Upgrade to Level 2: +income and 2 Worker slots.",
    ...overrides
  };
}

function fakeSnapshot(
  completedBuildingIds: string[],
  resources = { crowns: 999, stone: 999, iron: 999, aether: 999 },
  researchedUpgradeIds: string[] = [],
  repairTargets: HUDSnapshot["repairTargets"] = [],
  resourceSites: HUDSnapshot["resourceSites"] = []
): HUDSnapshot {
  return {
    resources,
    selected: [],
    hero: {} as HUDSnapshot["hero"],
    elapsedSeconds: 0,
    isPlacing: false,
    status: "",
    techState: {
      completedBuildingIds: new Set(completedBuildingIds),
      researchedUpgradeIds: new Set<string>(researchedUpgradeIds),
      heroLevel: 1
    },
    repairTargets,
    resourceSites,
    minimap: {
      mapWidth: 1,
      mapHeight: 1,
      camera: { x: 0, y: 0, width: 1, height: 1 },
      markers: [],
      pings: [],
      fog: { enabled: false }
    }
  };
}
