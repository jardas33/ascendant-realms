import type {
  BattleDifficulty,
  BattlefieldEventId,
  BattleRewardResult,
  BattleStats,
  EnemyDoctrineId,
  EnemyAIPersonalityId,
  Position,
  ResourceBag,
  RewardLevelUpSummary,
  RewardTableDefinition,
  UnitVeterancyBattleSummary
} from "../core/GameTypes";
import { grantBattleRewards, rollBattleRewards } from "../core/HeroProgressionRules";
import { addResources, cloneResources } from "../core/MathUtils";
import { ITEM_BY_ID } from "../data/contentIndex";
import { getStrongholdBattleEffects } from "../data/strongholdUpgrades";
import { getTacticalPlanBattleEffects } from "../data/tacticalPlans";
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
  enemyHeroId?: string;
  enemyPressurePlanId?: string;
  tacticalPlanId?: string;
}

export interface BattleCompletionInput {
  outcome: BattleOutcome;
  heroSave: HeroSaveData;
  startingHeroSave?: HeroSaveData;
  deterministicRewards?: boolean;
  rewardsDisabled?: boolean;
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

  recordVeterancySummary(summary: UnitVeterancyBattleSummary): void {
    this.stats.veteranSummary = cloneVeterancySummary(summary);
  }

  recordRetinueLosses(retinueUnitIds: string[]): void {
    this.stats.retinueUnitIdsLost = [...new Set(retinueUnitIds)];
  }

  recordRetinueSurvivorHealth(survivors: Array<{ retinueUnitId: string; hpRatio: number }>): void {
    this.stats.retinueSurvivorHealth = survivors.map((survivor) => ({
      retinueUnitId: survivor.retinueUnitId,
      hpRatio: Math.max(0, Math.min(1, survivor.hpRatio))
    }));
  }

  recordRetinueReinforcement(retinueUnitId: string): void {
    this.stats.retinueReinforcementUsed = true;
    this.stats.retinueReinforcementUnitId = retinueUnitId;
  }

  recordEnemyHeroPresence(enemyHeroId: string | undefined, enemyHeroName?: string): void {
    if (!enemyHeroId) {
      return;
    }
    this.stats.enemyHeroId = enemyHeroId;
    this.stats.enemyHeroName = enemyHeroName;
  }

  recordEnemyHeroDefeated(enemyHeroId: string | undefined, enemyHeroName?: string, defeatedAtSeconds = this.elapsedSeconds): void {
    if (!enemyHeroId) {
      return;
    }
    this.recordEnemyHeroPresence(enemyHeroId, enemyHeroName);
    this.stats.enemyHeroDefeated = true;
    this.stats.enemyHeroDefeatedAtSeconds = Math.max(0, defeatedAtSeconds);
  }

  recordEnemyHeroJoinedAttack(enemyHeroId: string | undefined, joinedAtSeconds = this.elapsedSeconds): void {
    if (!enemyHeroId || this.stats.enemyHeroJoinedAttackAtSeconds !== undefined) {
      return;
    }
    this.stats.enemyHeroId = enemyHeroId;
    this.stats.enemyHeroJoinedAttackAtSeconds = Math.max(0, joinedAtSeconds);
  }

  recordEnemyHeroPressure(enemyHeroId: string | undefined, enemyHeroName?: string): void {
    if (!enemyHeroId) {
      return;
    }
    this.recordEnemyHeroPresence(enemyHeroId, enemyHeroName);
    this.stats.lossesInvolvingEnemyHero = (this.stats.lossesInvolvingEnemyHero ?? 0) + 1;
  }

  recordEnemyPressurePlan(planId: string | undefined): void {
    if (!planId) {
      return;
    }
    this.stats.enemyPressurePlanId = planId;
  }

  recordEnemyDoctrine(doctrineId: EnemyDoctrineId | undefined): void {
    if (!doctrineId) {
      return;
    }
    this.stats.enemyDoctrineId = doctrineId;
  }

  recordEnemyDoctrineAction(label: string): void {
    if (!label.trim()) {
      return;
    }
    this.stats.enemyDoctrineActionCount = (this.stats.enemyDoctrineActionCount ?? 0) + 1;
    const labels = (this.stats.enemyDoctrineTelemetryLabels ??= []);
    if (!labels.includes(label)) {
      labels.push(label);
    }
  }

  recordEnemyEliteSquad(squadId: string | undefined): void {
    if (!squadId) {
      return;
    }
    const ids = (this.stats.enemyEliteSquadIds ??= []);
    if (!ids.includes(squadId)) {
      ids.push(squadId);
    }
  }

  recordEnemyEliteUnitDefeated(squadId: string | undefined): void {
    if (!squadId) {
      return;
    }
    const defeated = (this.stats.enemyEliteUnitsDefeated ??= []);
    defeated.push(squadId);
  }

  recordBattlefieldEventStarted(options: {
    eventId: BattlefieldEventId;
    objectiveLabel: string;
    telemetryLabel: string;
    planMatched?: boolean;
  }): void {
    const ids = (this.stats.battlefieldEventIds ??= []);
    if (!ids.includes(options.eventId)) {
      ids.push(options.eventId);
    }
    const objectiveLabels = (this.stats.battlefieldEventObjectiveLabels ??= []);
    if (options.objectiveLabel.trim() && !objectiveLabels.includes(options.objectiveLabel)) {
      objectiveLabels.push(options.objectiveLabel);
    }
    this.recordBattlefieldEventTelemetry(options.telemetryLabel);
    if (options.planMatched) {
      const planMatchedIds = (this.stats.battlefieldEventPlanMatchedIds ??= []);
      if (!planMatchedIds.includes(options.eventId)) {
        planMatchedIds.push(options.eventId);
      }
    }
  }

  recordBattlefieldEventCompleted(eventId: BattlefieldEventId, telemetryLabel: string): void {
    const completed = (this.stats.battlefieldEventCompletedIds ??= []);
    if (!completed.includes(eventId)) {
      completed.push(eventId);
    }
    this.recordBattlefieldEventTelemetry(telemetryLabel);
  }

  recordBattlefieldEventFailed(eventId: BattlefieldEventId, telemetryLabel: string): void {
    const failed = (this.stats.battlefieldEventFailedIds ??= []);
    if (!failed.includes(eventId)) {
      failed.push(eventId);
    }
    this.recordBattlefieldEventTelemetry(telemetryLabel);
  }

  private recordBattlefieldEventTelemetry(label: string): void {
    if (!label.trim()) {
      return;
    }
    const labels = (this.stats.battlefieldEventTelemetryLabels ??= []);
    if (!labels.includes(label)) {
      labels.push(label);
    }
  }

  recordEnemyPressureStage(options: {
    planId: string;
    stageId: string;
    telemetryLabel: string;
    warningShown?: boolean;
    reinforcementApplied?: boolean;
    completedAtSeconds?: number;
  }): boolean {
    this.recordEnemyPressurePlan(options.planId);
    const triggered = (this.stats.enemyPressureTriggeredStageIds ??= []);
    if (triggered.includes(options.stageId)) {
      return false;
    }
    triggered.push(options.stageId);
    (this.stats.enemyPressureCompletedStageIds ??= []).push(options.stageId);
    (this.stats.enemyPressureTelemetryLabels ??= []).push(options.telemetryLabel);
    this.stats.enemyPressureFirstTriggeredAtSeconds ??= Math.max(0, options.completedAtSeconds ?? this.elapsedSeconds);
    if (options.warningShown) {
      this.stats.enemyPressureWarningsShown = (this.stats.enemyPressureWarningsShown ?? 0) + 1;
    }
    if (options.reinforcementApplied) {
      this.stats.enemyPressureReinforcementApplied = true;
    }
    return true;
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
      rewardsDisabled: input.rewardsDisabled ?? this.launch.request.rewardsDisabled,
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
    outcome: "defeat",
    retinueUnitIdsLost: [],
    enemyHeroDefeated: false,
    lossesInvolvingEnemyHero: 0
  };
}

export function createInitialBattleResources(launch: ResolvedBattleLaunch): Record<"player" | "enemy", ResourceBag> {
  const player = cloneResources(launch.map.scenario.startingResources.player);
  addResources(player, getStrongholdBattleEffects(launch.request.modifiers).startingResources);
  addResources(player, getTacticalPlanBattleEffects(launch.request.modifiers).startingResources);
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
    },
    enemyHeroId: request.enemyHeroId,
    enemyPressurePlanId: request.enemyPressurePlanId,
    tacticalPlanId: request.tacticalPlanId
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
    outcome: input.outcome,
    retinueUnitIdsLost: [...(input.stats.retinueUnitIdsLost ?? [])],
    retinueParticipatingUnitIds: [...(input.stats.retinueParticipatingUnitIds ?? [])],
    retinueUnitIdsRecovering: [...(input.stats.retinueUnitIdsRecovering ?? [])],
    retinueUnitIdsReturnedReady: [...(input.stats.retinueUnitIdsReturnedReady ?? [])],
    retinueSurvivorHealth: (input.stats.retinueSurvivorHealth ?? []).map((entry) => ({ ...entry })),
    retinueReinforcementUsed: input.stats.retinueReinforcementUsed ?? false,
    retinueReinforcementUnitId: input.stats.retinueReinforcementUnitId,
    enemyHeroDefeated: input.stats.enemyHeroDefeated ?? false,
    lossesInvolvingEnemyHero: input.stats.lossesInvolvingEnemyHero ?? 0,
    enemyPressureTriggeredStageIds: [...(input.stats.enemyPressureTriggeredStageIds ?? [])],
    enemyPressureCompletedStageIds: [...(input.stats.enemyPressureCompletedStageIds ?? [])],
    enemyPressureTelemetryLabels: [...(input.stats.enemyPressureTelemetryLabels ?? [])],
    enemyPressureWarningsShown: input.stats.enemyPressureWarningsShown ?? 0,
    enemyPressureFirstTriggeredAtSeconds: input.stats.enemyPressureFirstTriggeredAtSeconds,
    enemyPressureReinforcementApplied: input.stats.enemyPressureReinforcementApplied ?? false,
    enemyDoctrineId: input.stats.enemyDoctrineId,
    enemyDoctrineActionCount: input.stats.enemyDoctrineActionCount ?? 0,
    enemyDoctrineTelemetryLabels: [...(input.stats.enemyDoctrineTelemetryLabels ?? [])],
    enemyEliteSquadIds: [...(input.stats.enemyEliteSquadIds ?? [])],
    enemyEliteUnitsDefeated: [...(input.stats.enemyEliteUnitsDefeated ?? [])],
    battlefieldEventIds: [...(input.stats.battlefieldEventIds ?? [])],
    battlefieldEventCompletedIds: [...(input.stats.battlefieldEventCompletedIds ?? [])],
    battlefieldEventFailedIds: [...(input.stats.battlefieldEventFailedIds ?? [])],
    battlefieldEventPlanMatchedIds: [...(input.stats.battlefieldEventPlanMatchedIds ?? [])],
    battlefieldEventObjectiveLabels: [...(input.stats.battlefieldEventObjectiveLabels ?? [])],
    battlefieldEventTelemetryLabels: [...(input.stats.battlefieldEventTelemetryLabels ?? [])],
    veteranSummary: input.stats.veteranSummary ? cloneVeterancySummary(input.stats.veteranSummary) : undefined
  };
  const baselineHero = input.startingHeroSave ?? input.heroSave;
  if (input.rewardsDisabled) {
    stats.xpGained = 0;
  }
  const emptyReward: BattleRewardResult = {
    itemIds: [],
    resources: {},
    xp: 0
  };
  const emptyLevelUp: RewardLevelUpSummary = {
    previousLevel: baselineHero.level,
    newLevel: baselineHero.level,
    levelsGained: 0,
    skillPointsGained: 0
  };
  if (input.outcome !== "victory" || input.rewardsDisabled) {
    return {
      outcome: input.outcome,
      stats,
      heroSave: input.rewardsDisabled ? baselineHero : input.heroSave,
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
    source: input.mapId ? `battle:${input.mapId}` : "battle_reward",
    deterministicAffixes: input.deterministicRewards,
    rng: input.rng
  });
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

function cloneVeterancySummary(summary: UnitVeterancyBattleSummary): UnitVeterancyBattleSummary {
  return {
    rankedUpUnits: summary.rankedUpUnits.map((entry) => ({ ...entry })),
    notableVeterans: summary.notableVeterans.map((entry) => ({ ...entry })),
    topSurvivor: summary.topSurvivor ? { ...summary.topSurvivor } : undefined
  };
}
