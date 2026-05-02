import type {
  BattleDifficulty,
  BattleRewardResult,
  BattleStats,
  EnemyAIPersonalityId,
  Position,
  ResourceBag,
  RewardLevelUpSummary,
  RewardTableDefinition
} from "../core/GameTypes";
import { grantBattleRewards, rollBattleRewards } from "../core/HeroProgressionRules";
import { addResources, cloneResources } from "../core/MathUtils";
import { ITEM_BY_ID } from "../data/contentIndex";
import { getStrongholdBattleEffects } from "../data/strongholdUpgrades";
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
  aiPersonalityId?: EnemyAIPersonalityId;
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
  secondaryObjectiveIds: string[];
  objectiveBuildingIds: {
    playerBase: string;
    enemyBase: string;
  };
}

export interface BattleCompletionInput {
  outcome: BattleOutcome;
  heroSave: HeroSaveData;
  startingHeroSave?: HeroSaveData;
  deterministicRewards?: boolean;
  rng?: () => number;
}

export interface BattleCompletionResult {
  outcome: BattleOutcome;
  stats: BattleStats;
  heroSave: HeroSaveData;
  rewardItemIds: string[];
  reward: BattleRewardResult;
  rewardLevelUp: RewardLevelUpSummary;
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

  recordBuildingBuilt(buildingId?: string): void {
    this.stats.buildingsBuilt += 1;
    if (buildingId) {
      this.stats.builtBuildingIds.push(buildingId);
    }
  }

  recordUnitTrained(unitId?: string): void {
    this.stats.unitsTrained += 1;
    if (unitId) {
      this.stats.trainedUnitIds.push(unitId);
    }
  }

  recordEnemyWaveSurvived(): void {
    this.stats.enemyWavesSurvived += 1;
  }

  recordXpGained(amount: number): void {
    this.stats.xpGained += Math.max(0, amount);
  }

  recordSecondaryObjective(objectiveId: string): boolean {
    if (this.stats.completedObjectiveIds.includes(objectiveId)) {
      return false;
    }
    this.stats.completedObjectiveIds.push(objectiveId);
    return true;
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
      startingHeroSave: this.launch.request.heroSave,
      rewardTable: this.launch.rewardTable,
      stats: this.stats,
      mapId: this.launch.map.id
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
    builtBuildingIds: [],
    unitsTrained: 0,
    trainedUnitIds: [],
    enemyWavesSurvived: 0,
    xpGained: 0,
    timeSeconds: 0,
    completedObjectiveIds: [],
    outcome: "defeat"
  };
}

export function createInitialBattleResources(launch: ResolvedBattleLaunch): Record<"player" | "enemy", ResourceBag> {
  const player = cloneResources(launch.map.scenario.startingResources.player);
  addResources(player, getStrongholdBattleEffects(launch.request.modifiers).startingResources);
  return {
    player,
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
    aiPersonalityId: request.aiPersonalityId,
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
    secondaryObjectiveIds: map.scenario.objectives.secondaryObjectives?.map((objective) => objective.id) ?? [],
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
  input: BattleCompletionInput & { rewardTable: RewardTableDefinition; stats: BattleStats; mapId?: string }
): BattleCompletionResult {
  const stats = {
    ...input.stats,
    completedObjectiveIds: [...input.stats.completedObjectiveIds],
    outcome: input.outcome
  };
  const emptyReward: BattleRewardResult = {
    itemIds: [],
    resources: {},
    xp: 0
  };
  const emptyLevelUp: RewardLevelUpSummary = {
    previousLevel: input.heroSave.level,
    newLevel: input.heroSave.level,
    levelsGained: 0,
    skillPointsGained: 0
  };
  if (input.outcome !== "victory") {
    return {
      outcome: input.outcome,
      stats,
      heroSave: input.heroSave,
      rewardItemIds: [],
      reward: emptyReward,
      rewardLevelUp: emptyLevelUp,
      shouldSaveHero: false
    };
  }

  const reward = rollBattleRewards({
    table: input.rewardTable,
    completedBattlesBeforeVictory: input.heroSave.completedBattles,
    inventory: input.heroSave.inventory,
    deterministic: input.deterministicRewards,
    isFirstClear: input.mapId ? !input.heroSave.clearedMapIds.includes(input.mapId) : undefined,
    mapId: input.mapId,
    rng: input.rng
  });
  stats.xpGained += reward.xp;
  const heroWithBattleCount = {
    ...input.heroSave,
    completedBattles: input.heroSave.completedBattles + 1
  };
  const granted = grantBattleRewards(heroWithBattleCount, reward, input.mapId, {
    itemById: ITEM_BY_ID,
    source: input.mapId ? `battle:${input.mapId}` : "battle_reward"
  });
  const baselineHero = input.startingHeroSave ?? input.heroSave;
  const levelUp: RewardLevelUpSummary = {
    previousLevel: baselineHero.level,
    newLevel: granted.hero.level,
    levelsGained: Math.max(0, granted.hero.level - baselineHero.level),
    skillPointsGained: Math.max(0, granted.hero.skillPoints - baselineHero.skillPoints)
  };

  return {
    outcome: "victory",
    stats,
    heroSave: granted.hero,
    rewardItemIds: granted.reward.itemIds,
    reward: granted.reward,
    rewardLevelUp: levelUp,
    shouldSaveHero: true
  };
}
