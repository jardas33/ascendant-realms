import { describe, expect, it, vi } from "vitest";
import type { Building } from "../entities/Building";
import type { CaptureSite } from "../entities/CaptureSite";
import type { Unit } from "../entities/Unit";
import type { TrainingSystem } from "../systems/TrainingSystem";
import type { EnemyAIConfig } from "../core/GameTypes";
import { ResourceSystem } from "../systems/ResourceSystem";
import { EnemyAIController } from "./EnemyAIController";
import { chooseEnemyResourceSitePlan, scoreEnemyResourceSite } from "./EnemyResourceSiteStrategy";

const CAPTURE_TIME_SECONDS_FOR_TEST = 12;

describe("EnemyAIController first battle pacing", () => {
  it("holds the Normal first attack until 3:15 and caps it to two units without player production", () => {
    const attacked: string[] = [];
    const waves: Unit[][] = [];
    const units = [
      fakeEnemyUnit("raider", "enemy_raider_1", attacked),
      fakeEnemyUnit("raider", "enemy_raider_2", attacked),
      fakeEnemyUnit("hexer", "enemy_hexer_1", attacked),
      fakeEnemyUnit("enemy_commander", "enemy_commander_1", attacked)
    ];
    let elapsedSeconds = 194;
    const controller = createController({
      units,
      getElapsedSeconds: () => elapsedSeconds,
      hasCapturedSite: false,
      hasBuiltProduction: false,
      onWaveLaunched: (wave) => waves.push(wave)
    });

    controller.update(194);
    expect(attacked).toEqual([]);
    expect(waves).toEqual([]);

    elapsedSeconds = 195;
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
      getElapsedSeconds: () => 195,
      hasCapturedSite: true,
      hasBuiltProduction: true,
      onWaveLaunched: (wave) => waves.push(wave)
    });

    controller.update(195);

    expect(attacked).toEqual(["enemy_raider_1", "enemy_raider_2", "enemy_hexer_1"]);
    expect(waves[0].map((unit) => unit.definition.id)).toEqual(["raider", "raider", "hexer"]);
  });

  it("uses the map AI config for first attack timing and wave size", () => {
    const attacked: string[] = [];
    const waves: Unit[][] = [];
    const units = [
      fakeEnemyUnit("raider", "enemy_raider_1", attacked),
      fakeEnemyUnit("raider", "enemy_raider_2", attacked),
      fakeEnemyUnit("hexer", "enemy_hexer_1", attacked),
      fakeEnemyUnit("brute", "enemy_brute_1", attacked)
    ];
    let elapsedSeconds = 229;
    const controller = createController({
      units,
      getElapsedSeconds: () => elapsedSeconds,
      hasCapturedSite: true,
      hasBuiltProduction: true,
      config: {
        initialAttackDelay: 230,
        attackWaveSize: 2,
        minAttackArmySize: 2
      },
      onWaveLaunched: (wave) => waves.push(wave)
    });

    controller.update(229);
    expect(attacked).toEqual([]);

    elapsedSeconds = 230;
    controller.update(1);

    expect(attacked).toEqual(["enemy_raider_1", "enemy_raider_2"]);
    expect(waves[0]).toHaveLength(2);
  });

  it("can announce the first enemy gathering warning earlier without moving the attack", () => {
    const alerts: string[] = [];
    const units = [
      fakeEnemyUnit("raider", "enemy_raider_1", []),
      fakeEnemyUnit("raider", "enemy_raider_2", []),
      fakeEnemyUnit("hexer", "enemy_hexer_1", [])
    ];
    let elapsedSeconds = 134;
    const controller = createController({
      units,
      getElapsedSeconds: () => elapsedSeconds,
      hasCapturedSite: true,
      hasBuiltProduction: true,
      config: { expandInterval: 9999, initialExpandDelay: 9999 },
      attackWarningLeadSeconds: 25,
      onAlert: (message) => alerts.push(message),
      onWaveLaunched: vi.fn()
    });

    controller.update(134);
    expect(alerts).toEqual([]);

    elapsedSeconds = 135;
    controller.update(1);

    expect(alerts).toEqual(["Enemy forces are gathering."]);
  });
});

describe("EnemyAIController resource-site strategy", () => {
  it("scores upgraded or Worker-boosted player resource sites as economy pressure targets", () => {
    const neutralSite = fakeSite("stone_quarry", "Stone Quarry", "neutral", { x: 1200, y: 600, incomeAmount: 24 });
    const boostedPlayerSite = fakeSite("aether_well", "Aether Well", "player", {
      x: 1500,
      y: 620,
      resource: "aether",
      incomeAmount: 18,
      siteLevel: 2,
      workerAssignments: [{ workerId: "worker-1", workerName: "Worker", statusDetail: "Worker working", boostActive: true }],
      workerAssignmentBoostActive: true
    });
    const context = {
      sites: [neutralSite, boostedPlayerSite],
      enemyUnits: [fakeEnemyUnit("raider", "enemy_raider_1", [])],
      playerUnits: [],
      enemyBasePosition: { x: 2140, y: 800 },
      knownEnemySiteIds: new Set<string>()
    };

    const neutralScore = scoreEnemyResourceSite(neutralSite, context);
    const playerScore = scoreEnemyResourceSite(boostedPlayerSite, context);
    const plan = chooseEnemyResourceSitePlan(context, new Set(["raid"]));

    expect(playerScore.task).toBe("raid");
    expect(playerScore.score).toBeGreaterThan(neutralScore.score);
    expect(plan?.site.definition.id).toBe("aether_well");
  });

  it("sends a small squad to capture a neutral resource site through normal movement", () => {
    const moved: Array<{ unitId: string; target: { x: number; y: number }; attackMove: boolean }> = [];
    const site = fakeSite("crown_shrine", "Crown Shrine", "neutral", { x: 2050, y: 760 });
    const units = [fakeEnemyUnit("raider", "enemy_raider_1", [], moved), fakeEnemyUnit("hexer", "enemy_hexer_1", [], moved)];
    const controller = createController({
      units,
      captureSites: [site],
      getElapsedSeconds: () => 30,
      hasCapturedSite: false,
      hasBuiltProduction: false,
      config: { expandInterval: 1, initialExpandDelay: 0, initialAttackDelay: 9999 },
      onWaveLaunched: vi.fn()
    });

    controller.update(1);

    expect(moved.map((entry) => entry.unitId)).toEqual(["enemy_raider_1", "enemy_hexer_1"]);
    expect(moved[0]).toMatchObject({ target: { x: site.position.x, y: site.position.y }, attackMove: true });
  });

  it("retakes a player site that was previously enemy-owned", () => {
    const moved: Array<{ unitId: string; target: { x: number; y: number }; attackMove: boolean }> = [];
    const site = fakeSite("iron_vein", "Iron Vein", "enemy", { x: 1580, y: 610, resource: "iron", incomeAmount: 25 });
    const units = [fakeEnemyUnit("raider", "enemy_raider_1", [], moved), fakeEnemyUnit("hexer", "enemy_hexer_1", [], moved)];
    let elapsedSeconds = 20;
    const controller = createController({
      units,
      captureSites: [site],
      getElapsedSeconds: () => elapsedSeconds,
      hasCapturedSite: true,
      hasBuiltProduction: true,
      config: { expandInterval: 1, initialExpandDelay: 0, initialAttackDelay: 9999 },
      onWaveLaunched: vi.fn()
    });

    controller.update(1);
    site.setOwner("player");
    elapsedSeconds = 50;
    moved.length = 0;
    controller.update(1);

    expect(controller.state.current).toBe("CONTEST_SITE");
    expect(moved.map((entry) => entry.unitId)).toEqual(["enemy_raider_1", "enemy_hexer_1"]);
    expect(moved[0].target).toMatchObject(site.position);
  });

  it("upgrades a captured enemy site under cooldown and resource rules", () => {
    const site = fakeSite("crown_shrine", "Crown Shrine", "enemy", { x: 2050, y: 760, incomeAmount: 30 });
    const resources = { crowns: 500, stone: 500, iron: 0, aether: 0 };
    const resourceSystem = new ResourceSystem({
      resources: { player: { crowns: 0, stone: 0, iron: 0, aether: 0 }, enemy: resources },
      getCaptureSites: () => [site],
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onMessage: vi.fn()
    });
    const controller = createController({
      units: [fakeEnemyUnit("raider", "enemy_raider_1", [])],
      captureSites: [site],
      resources,
      resourceSystem,
      getElapsedSeconds: () => 140,
      hasCapturedSite: true,
      hasBuiltProduction: true,
      config: { initialAttackDelay: 9999 },
      onWaveLaunched: vi.fn()
    });

    controller.update(0);

    expect(site.siteLevel).toBe(2);
    expect(resources.crowns).toBe(380);
    expect(resources.stone).toBe(420);
  });

  it("does not call the upgrade system for neutral or player-owned sites", () => {
    const playerSite = fakeSite("crown_shrine", "Crown Shrine", "player", { x: 2050, y: 760 });
    const neutralSite = fakeSite("stone_quarry", "Stone Quarry", "neutral", { x: 1900, y: 700 });
    const resourceSystem = { requestSiteUpgrade: vi.fn() } as unknown as ResourceSystem;
    const controller = createController({
      units: [fakeEnemyUnit("raider", "enemy_raider_1", [])],
      captureSites: [playerSite, neutralSite],
      resourceSystem,
      getElapsedSeconds: () => 140,
      hasCapturedSite: true,
      hasBuiltProduction: true,
      config: { initialAttackDelay: 9999 },
      onWaveLaunched: vi.fn()
    });

    controller.update(140);

    expect(resourceSystem.requestSiteUpgrade).not.toHaveBeenCalled();
  });

  it("pressures player resource sites with cooldown instead of every-tick raid spam", () => {
    const moved: Array<{ unitId: string; target: { x: number; y: number }; attackMove: boolean }> = [];
    const site = fakeSite("aether_well", "Aether Well", "player", {
      x: 1580,
      y: 610,
      resource: "aether",
      incomeAmount: 18,
      siteLevel: 2,
      workerAssignments: [{ workerId: "worker-1", workerName: "Worker", statusDetail: "Worker working", boostActive: true }],
      workerAssignmentBoostActive: true
    });
    const units = [
      fakeEnemyUnit("raider", "enemy_raider_1", [], moved),
      fakeEnemyUnit("hexer", "enemy_hexer_1", [], moved),
      fakeEnemyUnit("brute", "enemy_brute_1", [], moved)
    ];
    let elapsedSeconds = 151;
    const controller = createController({
      units,
      captureSites: [site],
      getElapsedSeconds: () => elapsedSeconds,
      hasCapturedSite: true,
      hasBuiltProduction: true,
      config: { initialAttackDelay: 9999, expandInterval: 9999, initialExpandDelay: 9999 },
      onWaveLaunched: vi.fn()
    });

    controller.update(151);
    const firstRaidMoveCount = moved.length;
    elapsedSeconds = 152;
    controller.update(1);

    expect(controller.state.current).toBe("RAID_SITE");
    expect(firstRaidMoveCount).toBeGreaterThan(0);
    expect(moved).toHaveLength(firstRaidMoveCount);
  });

  it("regroups a weak raid that becomes heavily outmatched at the target site", () => {
    const moved: Array<{ unitId: string; target: { x: number; y: number }; attackMove: boolean }> = [];
    const site = fakeSite("aether_well", "Aether Well", "player", { x: 1580, y: 610, resource: "aether", incomeAmount: 18 });
    const units = [fakeEnemyUnit("raider", "enemy_raider_1", [], moved), fakeEnemyUnit("hexer", "enemy_hexer_1", [], moved)];
    const playerThreats = [
      fakePlayerUnit("player_militia_1", { x: 260, y: 210 }, 150),
      fakePlayerUnit("player_militia_2", { x: 280, y: 230 }, 150),
      fakePlayerUnit("player_ranger_1", { x: 240, y: 200 }, 150)
    ];
    let elapsedSeconds = 151;
    const controller = createController({
      units: [...units, ...playerThreats],
      captureSites: [site],
      getElapsedSeconds: () => elapsedSeconds,
      hasCapturedSite: true,
      hasBuiltProduction: true,
      config: { initialAttackDelay: 9999, expandInterval: 9999, initialExpandDelay: 9999 },
      onWaveLaunched: vi.fn()
    });

    controller.update(151);
    playerThreats[0].position = { x: 1580, y: 610 };
    playerThreats[1].position = { x: 1595, y: 625 };
    playerThreats[2].position = { x: 1560, y: 600 };
    elapsedSeconds = 160;
    controller.update(9);

    expect(controller.state.current).toBe("RETREAT");
    expect(moved.at(-2)?.target.x).toBe(2140);
    expect(moved.at(-1)?.attackMove).toBe(false);
  });

  it("defends a valuable enemy-owned site when player units threaten it", () => {
    const attacked: string[] = [];
    const site = fakeSite("crown_shrine", "Crown Shrine", "enemy", { x: 1720, y: 720, incomeAmount: 30, siteLevel: 2 });
    const threat = fakePlayerUnit("player_militia_1", { x: 1728, y: 728 }, 80);
    const units = [
      fakeEnemyUnit("raider", "enemy_raider_1", attacked),
      fakeEnemyUnit("hexer", "enemy_hexer_1", attacked),
      threat
    ];
    const controller = createController({
      units,
      captureSites: [site],
      getElapsedSeconds: () => 90,
      hasCapturedSite: true,
      hasBuiltProduction: true,
      config: { initialAttackDelay: 9999, expandInterval: 9999, initialExpandDelay: 9999 },
      onWaveLaunched: vi.fn()
    });

    controller.update(1);

    expect(controller.state.current).toBe("DEFEND");
    expect(attacked).toEqual(["enemy_raider_1", "enemy_hexer_1"]);
  });
});

function createController(options: {
  units: Unit[];
  getElapsedSeconds: () => number;
  hasCapturedSite: boolean;
  hasBuiltProduction: boolean;
  onWaveLaunched: (units: Unit[]) => void;
  captureSites?: CaptureSite[];
  resources?: { crowns: number; stone: number; iron: number; aether: number };
  resourceSystem?: ResourceSystem;
  config?: Partial<EnemyAIConfig>;
  attackWarningLeadSeconds?: number;
  onAlert?: (message: string) => void;
}): EnemyAIController {
  const baseConfig: EnemyAIConfig = {
    incomeInterval: 5,
    incomePerTick: { crowns: 90, stone: 45, iron: 45, aether: 35 },
    trainInterval: 5.8,
    expandInterval: 21,
    initialExpandDelay: 18,
    attackInterval: 66,
    initialAttackDelay: 195,
    minAttackArmySize: 2,
    attackWaveSize: 6,
    expandSquadSize: 2,
    defenseSquadSize: 6,
    defendRadius: 400,
    baseBuildingId: "enemy_stronghold",
    productionBuildingId: "enemy_barracks",
    attackTargetBuildingId: "command_hall",
    unitPlan: ["raider", "raider", "hexer", "raider", "brute"]
  };
  const resources = options.resources ?? { crowns: 0, stone: 0, iron: 0, aether: 0 };
  return new EnemyAIController({
    resources,
    getUnits: () => options.units,
    getBuildings: () => [fakeBuilding("enemy_stronghold", "enemy"), fakeBuilding("command_hall", "player")],
    getCaptureSites: () => options.captureSites ?? ([] as CaptureSite[]),
    resourceSystem:
      options.resourceSystem ??
      ({
        requestSiteUpgrade: vi.fn(() => false)
      } as unknown as ResourceSystem),
    training: { queueTraining: vi.fn() } as unknown as TrainingSystem,
    getAttackTarget: () => fakeBuilding("command_hall", "player"),
    getElapsedSeconds: options.getElapsedSeconds,
    getPlayerMilestones: () => ({
      isFirstBattle: true,
      hasCapturedSite: options.hasCapturedSite,
      hasBuiltProduction: options.hasBuiltProduction
    }),
    onAlert: options.onAlert ?? vi.fn(),
    onWaveLaunched: options.onWaveLaunched,
    difficulty: "normal",
    config: { ...baseConfig, ...options.config },
    attackWarningLeadSeconds: options.attackWarningLeadSeconds
  });
}

function fakeEnemyUnit(
  unitId: string,
  id: string,
  attacked: string[],
  moved?: Array<{ unitId: string; target: { x: number; y: number }; attackMove: boolean }>
): Unit {
  return {
    id,
    alive: true,
    team: "enemy",
    position: { x: 2000, y: 800 },
    hp: 100,
    armor: 0,
    damage: unitId === "brute" ? 12 : 8,
    range: unitId === "hexer" ? 160 : 38,
    definition: {
      id: unitId,
      stats: { maxHp: 100, damage: unitId === "brute" ? 12 : 8, range: unitId === "hexer" ? 160 : 38, armor: 0 }
    },
    commandAttack: () => attacked.push(id),
    commandMove: (target: { x: number; y: number }, attackMove = false) => moved?.push({ unitId: id, target, attackMove })
  } as unknown as Unit;
}

function fakePlayerUnit(id: string, position: { x: number; y: number }, hp: number): Unit {
  return {
    id,
    alive: true,
    team: "player",
    position,
    hp,
    armor: 2,
    damage: 12,
    range: 55,
    definition: {
      id: "militia",
      stats: { maxHp: hp, damage: 12, range: 55, armor: 2 }
    }
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

function fakeSite(
  id: string,
  name: string,
  owner: "player" | "enemy" | "neutral",
  options: {
    x: number;
    y: number;
    resource?: "crowns" | "stone" | "iron" | "aether";
    incomeAmount?: number;
    siteLevel?: 1 | 2;
    workerAssignments?: CaptureSite["workerAssignments"];
    workerAssignmentBoostActive?: boolean;
  }
): CaptureSite {
  const site = {
    id,
    owner,
    team: owner,
    alive: true,
    position: { x: options.x, y: options.y },
    radius: 76,
    captureProgress: 0,
    capturingTeam: "neutral",
    incomeTimer: 0,
    siteLevel: options.siteLevel ?? 1,
    workerAssignments: options.workerAssignments ?? [],
    workerAssignmentBoostActive: options.workerAssignmentBoostActive ?? false,
    abstractEnemyWorkerSlots: 0,
    definition: {
      id,
      name,
      resource: options.resource ?? "crowns",
      x: options.x,
      y: options.y,
      radius: 76,
      incomeAmount: options.incomeAmount ?? 30,
      incomeInterval: 5
    },
    setOwner(nextOwner: "player" | "enemy" | "neutral") {
      this.owner = nextOwner;
      this.team = nextOwner;
      this.captureProgress = 0;
      this.capturingTeam = "neutral";
      this.siteLevel = 1;
      this.workerAssignments = [];
      this.workerAssignmentBoostActive = false;
      this.abstractEnemyWorkerSlots = 0;
    },
    setSiteLevel(level: 1 | 2) {
      this.siteLevel = level;
    },
    setAbstractEnemyWorkerSlots(slots: number) {
      this.abstractEnemyWorkerSlots = Math.max(0, Math.min(2, Math.floor(slots)));
    },
    clearAllWorkerAssignments() {
      this.workerAssignments = [];
      this.workerAssignmentBoostActive = false;
    },
    updateVisuals() {}
  };
  return site as unknown as CaptureSite;
}
