import { describe, expect, it } from "vitest";
import { BUILDING_BY_ID, UNIT_BY_ID } from "../../data/contentIndex";
import { Building } from "../../entities/Building";
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
    expect(commandHallMarkup).toContain("Effect: Command Hall: +1 armor.");
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
    expect(markup).toContain("Damaged: 420/600 HP. Cost: none");
    expect(markup).toContain("move or attack orders stop repair until Repair is issued again");
    expect(markup).toContain("Already repaired. HP 1450/1450");
  });

  it("renders Worker resource-site assignment commands with invalid site reasons", () => {
    const worker = fakeWorker();

    const markup = renderCommandActions(
      worker,
      fakeSnapshot(["command_hall"], undefined, [], [], [
        {
          id: "crown_shrine",
          name: "Crown Shrine",
          resource: "crowns",
          owner: "player",
          baseIncomeAmount: 30,
          incomeInterval: 5,
          workerBonusAmount: 6,
          boostedIncomeAmount: 30,
          isAssignable: true,
          status: "Captured - empty Worker slot"
        },
        {
          id: "stone_quarry",
          name: "Stone Quarry",
          resource: "stone",
          owner: "neutral",
          baseIncomeAmount: 25,
          incomeInterval: 5,
          workerBonusAmount: 5,
          boostedIncomeAmount: 25,
          isAssignable: false,
          status: "Neutral - capture before assigning a Worker"
        }
      ])
    );

    expect(markup).toContain('data-testid="command-assign-resource-site-crown_shrine"');
    expect(markup).toContain("Assign Crown Shrine");
    expect(markup).toContain("Base +30, Worker +6/5s");
    expect(markup).toContain("Boosted tick +36 while Worker is assigned and nearby.");
    expect(markup).toContain("Neutral - capture before assigning a Worker");
    expect(markup).toContain('data-testid="command-assign-resource-site-stone_quarry"');
    expect(markup).toContain("disabled");
  });

  it("keeps a filled resource-site Worker slot locked for other Workers", () => {
    const worker = fakeWorker();

    const markup = renderCommandActions(
      worker,
      fakeSnapshot(["command_hall"], undefined, [], [], [
        {
          id: "crown_shrine",
          name: "Crown Shrine",
          resource: "crowns",
          owner: "player",
          baseIncomeAmount: 30,
          incomeInterval: 5,
          workerBonusAmount: 6,
          boostedIncomeAmount: 36,
          assignedWorkerId: "other-worker",
          assignedWorkerName: "Worker",
          isAssignable: false,
          status: "Worker working"
        }
      ])
    );

    expect(markup).toContain("Worker working");
    expect(markup).toContain("disabled");
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
