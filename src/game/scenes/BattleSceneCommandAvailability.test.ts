import { describe, expect, it, vi } from "vitest";

vi.mock("phaser", () => ({
  default: {
    Scene: class Scene {},
    Scenes: { Events: { SHUTDOWN: "shutdown" } },
    Math: {
      Clamp: (value: number, min: number, max: number) => Math.min(max, Math.max(min, value)),
      Distance: { Between: () => 0 }
    },
    Geom: { Line: class Line {} },
    GameObjects: { Container: class Container {}, Graphics: class Graphics {}, Text: class Text {} }
  }
}));
import { BUILDING_BY_ID, UNIT_BY_ID } from "../data/contentIndex";
import { Building } from "../entities/Building";
import { Unit } from "../entities/Unit";
import type { HUDCommandAvailabilitySnapshot } from "../ui/hudPanels/HudTypes";
import { BattleScene } from "./BattleScene";

describe("BattleScene command availability ownership gate", () => {
  it("keeps enemy building snapshots free of player build, train, and upgrade entries", () => {
    const scene = fakeScene();
    const enemyBarracks = fakeBuilding("enemy-barracks", "enemy");

    expect(createSnapshot(scene, enemyBarracks)).toEqual([]);
  });

  it("keeps enemy unit snapshots free of build entries while preserving friendly entries", () => {
    const scene = fakeScene();
    const enemyWorker = fakeUnit("enemy-worker", "enemy");
    const playerWorker = fakeUnit("player-worker", "player");

    expect(createSnapshot(scene, enemyWorker)).toEqual([]);
    expect(createSnapshot(scene, playerWorker).map((entry) => entry.action)).toEqual(
      playerWorker.definition.buildOptions?.map(() => "build")
    );
  });

  it("preserves friendly building train and upgrade decisions", () => {
    const scene = fakeScene();
    const playerBarracks = fakeBuilding("player-barracks", "player");

    expect(createSnapshot(scene, playerBarracks).map((entry) => entry.action)).toEqual([
      ...playerBarracks.definition.trainOptions.map(() => "train"),
      ...playerBarracks.definition.upgradeOptions.map(() => "upgrade")
    ]);
  });
});

function createSnapshot(scene: unknown, selected: Unit | Building): HUDCommandAvailabilitySnapshot[] {
  return (BattleScene.prototype as any).createCommandAvailabilitySnapshot.call(scene, [selected]);
}

function fakeScene() {
  return {
    getTechState: () => ({
      completedBuildingIds: new Set<string>(["command_hall", "barracks"]),
      researchedUpgradeIds: new Set<string>(),
      heroLevel: 1
    }),
    resources: {
      player: { crowns: 999, stone: 999, iron: 999, aether: 999 }
    },
    trainingSystem: {
      getTrainingAvailability: () => ({ available: true })
    },
    upgradeSystem: {
      getUpgradeAvailability: () => ({ available: true })
    }
  };
}

function fakeBuilding(id: string, team: "player" | "enemy"): Building {
  const definition = BUILDING_BY_ID.barracks;
  return Object.assign(Object.create(Building.prototype), {
    id,
    kind: "building",
    team,
    alive: true,
    definition,
    trainingQueue: [],
    upgradeQueue: [],
    isCompleted: () => true
  }) as Building;
}

function fakeUnit(id: string, team: "player" | "enemy"): Unit {
  return Object.assign(Object.create(Unit.prototype), {
    id,
    kind: "unit",
    team,
    alive: true,
    definition: UNIT_BY_ID.worker
  }) as Unit;
}
