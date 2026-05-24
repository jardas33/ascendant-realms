import { describe, expect, it } from "vitest";
import { BUILDING_BY_ID, UNIT_BY_ID } from "../../data/contentIndex";
import { Building } from "../../entities/Building";
import { Unit } from "../../entities/Unit";
import { renderCommandActions } from "./CommandPanel";
import type { HUDSnapshot } from "./HudTypes";

describe("CommandPanel", () => {
  it("labels train and upgrade command costs clearly on the Command Hall", () => {
    const commandHall = fakeBuilding("player-command-hall", "command_hall");
    const barracks = fakeBuilding("player-barracks", "barracks");

    const commandHallMarkup = renderCommandActions(commandHall, fakeSnapshot(["command_hall"]));
    const barracksMarkup = renderCommandActions(barracks, fakeSnapshot(["command_hall", "barracks"]));

    expect(commandHallMarkup).not.toContain('data-command-kind="build"');
    expect(commandHallMarkup).toContain('data-testid="command-train-worker"');
    expect(commandHallMarkup).toContain("Cost: 50 Crowns");
    expect(commandHallMarkup).toContain('data-testid="command-upgrade-infantry_weapons_1"');
    expect(commandHallMarkup).toContain("Cost: 120 Crowns, 70 Iron");
    expect(barracksMarkup).toContain('data-testid="command-train-militia"');
    expect(barracksMarkup).toContain("Cost: 60 Crowns, 20 Iron");
  });

  it("keeps costs visible when a command is locked", () => {
    const commandHall = fakeBuilding("player-command-hall", "command_hall");

    const markup = renderCommandActions(
      commandHall,
      fakeSnapshot(["command_hall"], { crowns: 0, stone: 0, iron: 0, aether: 0 })
    );

    expect(markup).toContain("Insufficient resources. Cost: 50 Crowns");
    expect(markup).toContain("Insufficient resources. Cost: 120 Crowns, 70 Iron");
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

function fakeBuilding(id: string, buildingId: string): Building {
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
    isCompleted: () => true
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
  resources = { crowns: 999, stone: 999, iron: 999, aether: 999 }
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
      researchedUpgradeIds: new Set<string>(),
      heroLevel: 1
    },
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
