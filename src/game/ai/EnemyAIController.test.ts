import { describe, expect, it, vi } from "vitest";
import type { Building } from "../entities/Building";
import type { CaptureSite } from "../entities/CaptureSite";
import type { Unit } from "../entities/Unit";
import type { TrainingSystem } from "../systems/TrainingSystem";
import { EnemyAIController } from "./EnemyAIController";

describe("EnemyAIController first battle pacing", () => {
  it("holds the Normal first attack until 3:00 and caps it to two units without player production", () => {
    const attacked: string[] = [];
    const waves: Unit[][] = [];
    const units = [
      fakeEnemyUnit("raider", "enemy_raider_1", attacked),
      fakeEnemyUnit("raider", "enemy_raider_2", attacked),
      fakeEnemyUnit("hexer", "enemy_hexer_1", attacked),
      fakeEnemyUnit("enemy_commander", "enemy_commander_1", attacked)
    ];
    let elapsedSeconds = 179;
    const controller = createController({
      units,
      getElapsedSeconds: () => elapsedSeconds,
      hasCapturedSite: false,
      hasBuiltProduction: false,
      onWaveLaunched: (wave) => waves.push(wave)
    });

    controller.update(179);
    expect(attacked).toEqual([]);
    expect(waves).toEqual([]);

    elapsedSeconds = 180;
    controller.update(1);

    expect(attacked).toEqual(["enemy_raider_1", "enemy_raider_2"]);
    expect(waves).toHaveLength(1);
    expect(waves[0].map((unit) => unit.definition.id)).toEqual(["raider", "raider"]);
  });

  it("keeps the enemy commander out of the first Normal attack even when production is ready", () => {
    const attacked: string[] = [];
    const waves: Unit[][] = [];
    const units = [
      fakeEnemyUnit("raider", "enemy_raider_1", attacked),
      fakeEnemyUnit("raider", "enemy_raider_2", attacked),
      fakeEnemyUnit("hexer", "enemy_hexer_1", attacked),
      fakeEnemyUnit("enemy_commander", "enemy_commander_1", attacked)
    ];
    const controller = createController({
      units,
      getElapsedSeconds: () => 180,
      hasCapturedSite: true,
      hasBuiltProduction: true,
      onWaveLaunched: (wave) => waves.push(wave)
    });

    controller.update(180);

    expect(attacked).toEqual(["enemy_raider_1", "enemy_raider_2", "enemy_hexer_1"]);
    expect(waves[0].map((unit) => unit.definition.id)).toEqual(["raider", "raider", "hexer"]);
  });
});

function createController(options: {
  units: Unit[];
  getElapsedSeconds: () => number;
  hasCapturedSite: boolean;
  hasBuiltProduction: boolean;
  onWaveLaunched: (units: Unit[]) => void;
}): EnemyAIController {
  return new EnemyAIController({
    resources: { crowns: 0, stone: 0, iron: 0, aether: 0 },
    getUnits: () => options.units,
    getBuildings: () => [fakeBuilding("enemy_stronghold", "enemy"), fakeBuilding("command_hall", "player")],
    getCaptureSites: () => [] as CaptureSite[],
    training: { queueTraining: vi.fn() } as unknown as TrainingSystem,
    getAttackTarget: () => fakeBuilding("command_hall", "player"),
    getElapsedSeconds: options.getElapsedSeconds,
    getPlayerMilestones: () => ({
      isFirstBattle: true,
      hasCapturedSite: options.hasCapturedSite,
      hasBuiltProduction: options.hasBuiltProduction
    }),
    onAlert: vi.fn(),
    onWaveLaunched: options.onWaveLaunched,
    difficulty: "normal",
    config: {
      incomeInterval: 5,
      incomePerTick: { crowns: 90, stone: 45, iron: 45, aether: 35 },
      trainInterval: 5.4,
      expandInterval: 21,
      initialExpandDelay: 18,
      attackInterval: 62,
      initialAttackDelay: 180,
      minAttackArmySize: 2,
      attackWaveSize: 7,
      expandSquadSize: 2,
      defenseSquadSize: 6,
      defendRadius: 400,
      baseBuildingId: "enemy_stronghold",
      productionBuildingId: "enemy_barracks",
      attackTargetBuildingId: "command_hall",
      unitPlan: ["raider", "raider", "hexer", "raider", "brute"]
    }
  });
}

function fakeEnemyUnit(unitId: string, id: string, attacked: string[]): Unit {
  return {
    id,
    alive: true,
    team: "enemy",
    position: { x: 2000, y: 800 },
    definition: { id: unitId },
    commandAttack: () => attacked.push(id),
    commandMove: vi.fn()
  } as unknown as Unit;
}

function fakeBuilding(buildingId: string, team: "player" | "enemy"): Building {
  return {
    id: `${team}_${buildingId}`,
    alive: true,
    team,
    position: team === "enemy" ? { x: 2140, y: 800 } : { x: 260, y: 800 },
    definition: { id: buildingId },
    isCompleted: () => true
  } as unknown as Building;
}
