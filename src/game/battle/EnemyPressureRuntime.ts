import type { EnemyStrategicPressurePlanDefinition, PressureStageDefinition } from "../core/GameTypes";
import { ENEMY_PRESSURE_PLAN_BY_ID } from "../data/contentIndex";
import type { BattleLaunchMode } from "./BattleLaunchRequest";
import type { BattleRuntime } from "./BattleRuntime";

interface EnemyPressureRuntimeOptions {
  planId?: string;
  mode: BattleLaunchMode;
  mapId: string;
  campaignNodeId?: string;
  runtime: BattleRuntime;
  showWarning: (message: string) => void;
  adjustNextWaveTiming?: (seconds: number) => void;
}

interface PendingPressureStage {
  stage: PressureStageDefinition;
  fireAtSeconds: number;
}

export class EnemyPressureRuntime {
  private readonly triggeredStageIds = new Set<string>();
  private readonly completedStageIds = new Set<string>();
  private readonly pendingStages: PendingPressureStage[] = [];
  private readonly capturedSiteIds = new Set<string>();
  private firstArmyUnitTrained = false;

  constructor(
    private readonly plan: EnemyStrategicPressurePlanDefinition,
    private readonly options: EnemyPressureRuntimeOptions
  ) {
    this.options.runtime.recordEnemyPressurePlan(plan.id);
  }

  get planId(): string {
    return this.plan.id;
  }

  update(): void {
    this.plan.stages.forEach((stage) => {
      if (this.triggeredStageIds.has(stage.id)) {
        return;
      }
      if (this.isTimeTriggerReady(stage)) {
        this.queueStage(stage);
      }
    });
    this.flushPendingStages();
  }

  recordPlayerCapturedSite(captureSiteId: string): void {
    this.capturedSiteIds.add(captureSiteId);
    this.plan.stages.forEach((stage) => {
      if (
        stage.trigger.type === "player_captures_site" &&
        stage.trigger.captureSiteId === captureSiteId &&
        !this.triggeredStageIds.has(stage.id)
      ) {
        this.queueStage(stage);
      }
    });
  }

  recordPlayerDestroyedStructure(buildingId: string): void {
    this.plan.stages.forEach((stage) => {
      if (
        stage.trigger.type === "player_destroys_structure" &&
        stage.trigger.buildingId === buildingId &&
        !this.triggeredStageIds.has(stage.id)
      ) {
        this.queueStage(stage);
      }
    });
  }

  recordPlayerTrainedUnit(unitId: string): void {
    if (this.firstArmyUnitTrained) {
      return;
    }
    this.firstArmyUnitTrained = true;
    this.plan.stages.forEach((stage) => {
      const matchesUnit = !stage.trigger.unitIds || stage.trigger.unitIds.includes(unitId);
      if (stage.trigger.type === "player_trains_first_army_unit" && matchesUnit && !this.triggeredStageIds.has(stage.id)) {
        this.queueStage(stage);
      }
    });
  }

  recordEnemyHeroDefeated(enemyHeroId: string): void {
    this.plan.stages.forEach((stage) => {
      const matchesHero = !stage.trigger.enemyHeroId || stage.trigger.enemyHeroId === enemyHeroId;
      if (stage.trigger.type === "enemy_hero_defeated" && matchesHero && !this.triggeredStageIds.has(stage.id)) {
        this.queueStage(stage);
      }
    });
  }

  private isTimeTriggerReady(stage: PressureStageDefinition): boolean {
    if (stage.trigger.type === "battle_start_time") {
      const readyAt = stage.battleTimeSeconds ?? stage.delaySeconds ?? 0;
      return this.options.runtime.elapsedSeconds >= readyAt;
    }
    if (stage.trigger.type === "late_battle_time") {
      return this.options.runtime.elapsedSeconds >= (stage.battleTimeSeconds ?? Number.POSITIVE_INFINITY);
    }
    return false;
  }

  private queueStage(stage: PressureStageDefinition): void {
    if (this.triggeredStageIds.has(stage.id)) {
      return;
    }
    this.triggeredStageIds.add(stage.id);
    this.pendingStages.push({
      stage,
      fireAtSeconds: this.options.runtime.elapsedSeconds + (stage.delaySeconds ?? 0)
    });
    this.flushPendingStages();
  }

  private flushPendingStages(): void {
    const ready = this.pendingStages.filter((entry) => entry.fireAtSeconds <= this.options.runtime.elapsedSeconds);
    if (ready.length === 0) {
      return;
    }
    this.pendingStages.splice(
      0,
      this.pendingStages.length,
      ...this.pendingStages.filter((entry) => entry.fireAtSeconds > this.options.runtime.elapsedSeconds)
    );
    ready.forEach((entry) => this.completeStage(entry.stage));
  }

  private completeStage(stage: PressureStageDefinition): void {
    if (this.completedStageIds.has(stage.id) || !this.isConditionMet(stage)) {
      return;
    }
    this.completedStageIds.add(stage.id);
    const warningShown = Boolean(stage.warningCopy);
    if (stage.warningCopy) {
      this.options.showWarning(stage.warningCopy);
    }
    const reinforcementApplied = this.applyAction(stage);
    this.options.runtime.recordEnemyPressureStage({
      planId: this.plan.id,
      stageId: stage.id,
      telemetryLabel: stage.telemetryLabel,
      warningShown,
      reinforcementApplied,
      completedAtSeconds: this.options.runtime.elapsedSeconds
    });
  }

  private isConditionMet(stage: PressureStageDefinition): boolean {
    const condition = stage.condition;
    if (!condition) {
      return true;
    }
    if (condition.type === "stage_completed") {
      return Boolean(condition.stageId && this.completedStageIds.has(condition.stageId));
    }
    if (condition.type === "capture_site_not_enemy_owned") {
      return Boolean(condition.captureSiteId && this.capturedSiteIds.has(condition.captureSiteId));
    }
    return true;
  }

  private applyAction(stage: PressureStageDefinition): boolean {
    if (stage.action.type === "adjust_next_wave_timing" && Number.isFinite(stage.action.seconds)) {
      this.options.adjustNextWaveTiming?.(stage.action.seconds ?? 0);
    }
    // Reinforcement, contest, and defensive-hold actions stay telemetry/copy-only until
    // a later phase proves they can use existing units without construction or worker logic.
    return false;
  }
}

export function createEnemyPressureRuntime(options: EnemyPressureRuntimeOptions): EnemyPressureRuntime | undefined {
  if (!options.planId || options.mode !== "campaign_node" || !options.campaignNodeId) {
    return undefined;
  }
  const plan = ENEMY_PRESSURE_PLAN_BY_ID[options.planId];
  if (!plan || plan.scope !== "campaign_node" || !plan.enabledByDefault) {
    return undefined;
  }
  if (!plan.allowedNodeIds.includes(options.campaignNodeId) || !plan.allowedMapIds.includes(options.mapId)) {
    return undefined;
  }
  return new EnemyPressureRuntime(plan, options);
}
