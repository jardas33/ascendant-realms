import type {
  BattleDifficulty,
  BattleStats,
  Position,
  ResourceBag,
  RewardTableDefinition
} from "../core/GameTypes";
import { grantItemRewards, pickBattleRewardItemIds } from "../core/HeroProgressionRules";
import { cloneResources } from "../core/MathUtils";
import type { HeroSaveData } from "../save/SaveTypes";
import type { BattleLaunchMode, ResolvedBattleLaunch } from "./BattleLaunchRequest";

export type BattleOutcome = BattleStats["outcome"];

export interface BattleObjectivePresence {
  playerBaseAlive: boolean;
  enemyBaseAlive: boolean;
}

export interface BattleSetupSnapshot {
  requestId: string;
  mode: BattleLaunchMode;
  sourceId: string;
  difficulty: BattleDifficulty;
  modifiers: string[];
  mapId: string;
  mapName: string;
  heroSpawn: Position;
  playerStart: Position;
  enemyStart: Position;
  buildingSpawnCount: number;
  unitSpawnCount: number;
  neutralCampCount: number;
  neutralUnitCount: number;
  captureSiteCount: number;
  startingResources: Record<"player" | "enemy", ResourceBag>;
  rewardTableId: string;
  objectiveBuildingIds: {
    playerBase: string;
    enemyBase: string;
  };
}

export interface BattleCompletionInput {
  outcome: BattleOutcome;
  heroSave: HeroSaveData;
}

export interface BattleCompletionResult {
  outcome: BattleOutcome;
  stats: BattleStats;
  heroSave: HeroSaveData;
  rewardItemIds: string[];
  shouldSaveHero: boolean;
}

export class BattleRuntime {
  readonly launch: ResolvedBattleLaunch;
  readonly setup: BattleSetupSnapshot;
  readonly resources: Record<"player" | "enemy", ResourceBag>;
  readonly stats: BattleStats;

  elapsedSeconds = 0;
  ended = false;

  constructor(options: { launch: ResolvedBattleLaunch }) {
    this.launch = options.launch;
    this.resources = createInitialBattleResources(options.launch);
    this.stats = createInitialBattleStats();
    this.setup = createBattleSetupSnapshot(options.launch);
  }

  tick(deltaSeconds: number): void {
    if (this.ended) {
      return;
    }
    this.elapsedSeconds += Math.max(0, deltaSeconds);
    this.stats.timeSeconds = this.elapsedSeconds;
  }

  recordUnitKilled(): void {
    this.stats.unitsKilled += 1;
  }

  recordBuildingDestroyed(): void {
    this.stats.buildingsDestroyed += 1;
  }

  recordResourceCaptured(siteId?: string): void {
    this.stats.resourcesCaptured += 1;
    this.stats.firstSiteCaptured ??= siteId;
  }

  recordBuildingBuilt(): void {
    this.stats.buildingsBuilt += 1;
  }

  recordUnitTrained(): void {
    this.stats.unitsTrained += 1;
  }

  recordEnemyWaveSurvived(): void {
    this.stats.enemyWavesSurvived += 1;
  }

  recordXpGained(amount: number): void {
    this.stats.xpGained += Math.max(0, amount);
  }

  evaluateObjectives(presence: BattleObjectivePresence): BattleOutcome | undefined {
    return evaluateBattleObjectives(presence);
  }

  completeBattle(input: BattleCompletionInput): BattleCompletionResult | null {
    if (this.ended) {
      return null;
    }
    this.ended = true;
    this.stats.outcome = input.outcome;
    this.stats.timeSeconds = this.elapsedSeconds;
    return completeBattle({
      ...input,
      rewardTable: this.launch.rewardTable,
      stats: this.stats
    });
  }
}

export function createBattleRuntime(options: { launch: ResolvedBattleLaunch }): BattleRuntime {
  return new BattleRuntime(options);
}

export function createInitialBattleStats(): BattleStats {
  return {
    unitsKilled: 0,
    buildingsDestroyed: 0,
    resourcesCaptured: 0,
    buildingsBuilt: 0,
    unitsTrained: 0,
    enemyWavesSurvived: 0,
    xpGained: 0,
    timeSeconds: 0,
    outcome: "defeat"
  };
}

export function createInitialBattleResources(launch: ResolvedBattleLaunch): Record<"player" | "enemy", ResourceBag> {
  return {
    player: cloneResources(launch.map.scenario.startingResources.player),
    enemy: cloneResources(launch.map.scenario.startingResources.enemy)
  };
}

export function createBattleSetupSnapshot(launch: ResolvedBattleLaunch): BattleSetupSnapshot {
  const { map, request, rewardTableId } = launch;
  return {
    requestId: request.requestId,
    mode: request.mode,
    sourceId: request.sourceId,
    difficulty: request.difficulty,
    modifiers: request.modifiers.map((modifier) => modifier.id),
    mapId: map.id,
    mapName: map.name,
    heroSpawn: { ...map.scenario.heroSpawn },
    playerStart: { ...map.playerStart },
    enemyStart: { ...map.enemyStart },
    buildingSpawnCount: map.scenario.buildingSpawns.length,
    unitSpawnCount: map.scenario.unitSpawns.length,
    neutralCampCount: map.neutralCamps.length,
    neutralUnitCount: map.neutralCamps.reduce((total, camp) => total + camp.unitIds.length, 0),
    captureSiteCount: map.captureSites.length,
    startingResources: createInitialBattleResources(launch),
    rewardTableId,
    objectiveBuildingIds: {
      playerBase: map.scenario.objectives.playerBaseBuildingId,
      enemyBase: map.scenario.objectives.enemyBaseBuildingId
    }
  };
}

export function evaluateBattleObjectives(presence: BattleObjectivePresence): BattleOutcome | undefined {
  if (!presence.enemyBaseAlive) {
    return "victory";
  }
  if (!presence.playerBaseAlive) {
    return "defeat";
  }
  return undefined;
}

export function completeBattle(
  input: BattleCompletionInput & { rewardTable: RewardTableDefinition; stats: BattleStats }
): BattleCompletionResult {
  const stats = { ...input.stats, outcome: input.outcome };
  if (input.outcome !== "victory") {
    return {
      outcome: input.outcome,
      stats,
      heroSave: input.heroSave,
      rewardItemIds: [],
      shouldSaveHero: false
    };
  }

  const rewardItemIds = pickBattleRewardItemIds(
    input.rewardTable,
    input.heroSave.completedBattles,
    input.heroSave.inventory
  );
  const heroWithBattleCount = {
    ...input.heroSave,
    completedBattles: input.heroSave.completedBattles + 1
  };

  return {
    outcome: "victory",
    stats,
    heroSave: grantItemRewards(heroWithBattleCount, rewardItemIds),
    rewardItemIds,
    shouldSaveHero: true
  };
}
