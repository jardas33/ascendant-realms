import type {
  BattleDifficulty,
  BattleDifficultyDefinition,
  BattlePhaseDefinition,
  EnemyAIPersonalityDefinition,
  EnemyAIPersonalityId,
  EnemyAIConfig,
  Position,
  ResourceBag
} from "../core/GameTypes";
import { addResources, distance } from "../core/MathUtils";
import {
  applyAIPersonalityToConfig,
  applyAIPersonalityToDifficulty,
  applyAIPersonalityToPhase,
  getAIPersonality
} from "../data/aiPersonalities";
import {
  FIRST_MATCH_TUTORIAL_PROTECTION,
  getBattleDifficulty,
  getBattlePhase,
  scaledEnemyIncome
} from "../data/battlePacing";
import { CaptureSite } from "../entities/CaptureSite";
import { Building } from "../entities/Building";
import { Unit } from "../entities/Unit";
import { TrainingSystem } from "../systems/TrainingSystem";
import { AIStateMachine } from "./AIStateMachine";

interface PlayerMilestones {
  isFirstBattle: boolean;
  hasCapturedSite: boolean;
  hasBuiltProduction: boolean;
}

interface EnemyAIOptions {
  resources: ResourceBag;
  getUnits: () => Unit[];
  getBuildings: () => Building[];
  getCaptureSites: () => CaptureSite[];
  training: TrainingSystem;
  getAttackTarget: () => Building | undefined;
  getElapsedSeconds: () => number;
  getPlayerMilestones: () => PlayerMilestones;
  onAlert: (message: string, x?: number, y?: number) => void;
  onWaveLaunched: (units: Unit[]) => void;
  difficulty: BattleDifficulty;
  config: EnemyAIConfig;
  aiPersonalityId?: EnemyAIPersonalityId;
  attackWarningLeadSeconds?: number;
}

export class EnemyAIController {
  readonly state = new AIStateMachine();
  private incomeTimer = 0;
  private trainTimer = 0;
  private expandTimer: number;
  private attackTimer: number;
  private trainPlanIndex = 0;
  private attacksLaunched = 0;
  private readonly alerted = new Set<string>();
  private readonly difficulty: BattleDifficultyDefinition;
  private readonly config: EnemyAIConfig;
  private readonly personality: EnemyAIPersonalityDefinition;

  constructor(private readonly options: EnemyAIOptions) {
    this.personality = getAIPersonality(options.aiPersonalityId);
    this.difficulty = applyAIPersonalityToDifficulty(getBattleDifficulty(options.difficulty), this.personality);
    this.config = applyAIPersonalityToConfig(options.config, this.personality);
    this.expandTimer = Math.max(0, this.config.expandInterval - this.config.initialExpandDelay);
    this.attackTimer = 0;
  }

  adjustNextAttackTiming(seconds: number): void {
    if (!Number.isFinite(seconds) || seconds === 0) {
      return;
    }
    this.attackTimer = Math.max(0, this.attackTimer - seconds);
  }

  update(deltaSeconds: number): void {
    const enemyBuildings = this.options.getBuildings().filter((building) => building.alive && building.team === "enemy");
    if (enemyBuildings.length === 0) {
      return;
    }

    const elapsedSeconds = this.options.getElapsedSeconds();
    const phase = applyAIPersonalityToPhase(getBattlePhase(elapsedSeconds), this.personality);
    this.incomeTimer += deltaSeconds;
    this.trainTimer += deltaSeconds;
    this.expandTimer += deltaSeconds;
    this.attackTimer += deltaSeconds;

    if (this.incomeTimer >= this.config.incomeInterval) {
      this.incomeTimer = 0;
      addResources(this.options.resources, scaledEnemyIncome(this.config.incomePerTick, this.difficulty.enemyIncomeMultiplier));
    }

    if (this.trainTimer >= this.config.trainInterval) {
      this.trainTimer = 0;
      this.trainEnemyUnit(phase);
    }

    if (this.shouldDefend()) {
      this.state.set("DEFEND");
      this.defendBase();
      return;
    }

    const enemyArmy = this.enemyArmy();
    const attackWave = this.selectAttackWave(enemyArmy, phase);
    this.maybeAlert(
      "gathering",
      "Enemy forces are gathering.",
      this.attacksLaunched === 0 &&
        elapsedSeconds >= Math.max(20, this.config.initialAttackDelay - 35 - (this.options.attackWarningLeadSeconds ?? 0))
    );
    if (this.canSendAttackWave(attackWave, phase)) {
      this.attackTimer = 0;
      this.attacksLaunched += 1;
      this.state.set("ATTACK");
      this.options.onAlert("Enemy attack incoming.");
      this.sendAttackWave(attackWave);
      this.options.onWaveLaunched(attackWave);
      return;
    }

    if (this.expandTimer >= this.config.expandInterval) {
      this.expandTimer = 0;
      this.state.set(enemyArmy.length >= 3 ? "EXPAND" : "BUILD_ARMY");
      this.maybeAlert("scouts", "Enemy scouts are moving.", true);
      this.captureNearestSite(enemyArmy);
    }
  }

  private trainEnemyUnit(phase: BattlePhaseDefinition): void {
    // TODO: Route future enemy construction through BuildingSystem before production decisions.
    const production = this.options
      .getBuildings()
      .find(
        (building) =>
          building.alive &&
          building.team === "enemy" &&
          building.isCompleted() &&
          building.definition.id === this.config.productionBuildingId &&
          building.definition.trainOptions.length > 0
      );
    if (!production) {
      return;
    }

    if (this.config.unitPlan.length === 0) {
      return;
    }
    const unitId = this.nextTrainUnitId(phase);
    if (!unitId) {
      return;
    }
    this.options.training.queueTraining(production, unitId, this.options.resources, { announce: false });
  }

  private nextTrainUnitId(phase: BattlePhaseDefinition): string | undefined {
    for (let attempt = 0; attempt < this.config.unitPlan.length; attempt += 1) {
      const unitId = this.config.unitPlan[this.trainPlanIndex % this.config.unitPlan.length];
      this.trainPlanIndex += 1;
      if (phase.enemy.trainUnitIds.includes(unitId)) {
        return unitId;
      }
    }
    return undefined;
  }

  private captureNearestSite(army: Unit[]): void {
    if (army.length === 0) {
      return;
    }
    const uncaptured = this.options
      .getCaptureSites()
      .filter((site) => site.owner !== "enemy")
      .sort((a, b) => distance(army[0].position, a.position) - distance(army[0].position, b.position));
    const target = uncaptured[0];
    if (!target) {
      return;
    }
    army.slice(0, Math.min(this.config.expandSquadSize, army.length)).forEach((unit, index) => {
      unit.commandMove({ x: target.position.x + index * 20, y: target.position.y + index * 16 }, true);
    });
  }

  private sendAttackWave(army: Unit[]): void {
    const target = this.options.getAttackTarget();
    if (!target) {
      return;
    }
    army.forEach((unit) => unit.commandAttack(target.id));
  }

  private canSendAttackWave(wave: Unit[], phase: BattlePhaseDefinition): boolean {
    if (!phase.enemy.baseAttackAllowed || wave.length === 0) {
      return false;
    }

    const elapsedSeconds = this.options.getElapsedSeconds();
    const milestones = this.options.getPlayerMilestones();
    const requiredTimer = this.attacksLaunched === 0 ? this.config.initialAttackDelay : this.config.attackInterval;
    if (this.attackTimer < requiredTimer) {
      return false;
    }

    if (this.attacksLaunched === 0 && elapsedSeconds < this.config.initialAttackDelay) {
      return false;
    }

    if (milestones.isFirstBattle && this.attacksLaunched === 0) {
      if (elapsedSeconds < FIRST_MATCH_TUTORIAL_PROTECTION.firstAttackAllowedAfterSeconds) {
        return false;
      }
      if (!milestones.hasCapturedSite && elapsedSeconds < FIRST_MATCH_TUTORIAL_PROTECTION.firstAttackForceAfterSeconds) {
        return false;
      }
    }

    return wave.length >= Math.min(this.config.minAttackArmySize, Math.max(1, this.maxAttackWaveSize(phase)));
  }

  private selectAttackWave(army: Unit[], phase: BattlePhaseDefinition): Unit[] {
    const maxSize = this.maxAttackWaveSize(phase);
    if (maxSize <= 0) {
      return [];
    }

    const candidates = this.attackCandidates(army, phase);
    const selected: Unit[] = [];
    const counts: Record<string, number> = {};

    phase.enemy.preferredAttackUnitIds.forEach((unitId) => {
      if (selected.length >= maxSize) {
        return;
      }
      const candidate = candidates.find((unit) => {
        return unit.definition.id === unitId && !selected.includes(unit) && this.hasCompositionRoom(unit.definition.id, counts, phase);
      });
      if (candidate) {
        selected.push(candidate);
        counts[candidate.definition.id] = (counts[candidate.definition.id] ?? 0) + 1;
      }
    });

    candidates.forEach((unit) => {
      if (selected.length >= maxSize || selected.includes(unit) || !this.hasCompositionRoom(unit.definition.id, counts, phase)) {
        return;
      }
      selected.push(unit);
      counts[unit.definition.id] = (counts[unit.definition.id] ?? 0) + 1;
    });

    return selected;
  }

  private maxAttackWaveSize(phase: BattlePhaseDefinition): number {
    const milestones = this.options.getPlayerMilestones();
    const elapsedSeconds = this.options.getElapsedSeconds();
    let maxSize = Math.min(this.config.attackWaveSize, phase.enemy.maxAttackWaveSize);
    if (
      milestones.isFirstBattle &&
      !milestones.hasBuiltProduction &&
      elapsedSeconds < FIRST_MATCH_TUTORIAL_PROTECTION.largeAttackAllowedAfterSeconds
    ) {
      maxSize = Math.min(maxSize, FIRST_MATCH_TUTORIAL_PROTECTION.earlyAttackMaxWaveSize);
    }
    return maxSize;
  }

  private canJoinAttack(unit: Unit, phase: BattlePhaseDefinition): boolean {
    if (!unit.alive || unit.team !== "enemy") {
      return false;
    }
    const unitId = unit.definition.id;
    if (!phase.enemy.allowedAttackUnitIds.includes(unitId)) {
      return false;
    }
    if (unitId === "enemy_commander") {
      const canJoinFirstAttack = this.personality.commander.joinsFirstAttack || this.attacksLaunched > 0;
      return canJoinFirstAttack && phase.enemy.commanderAllowed && this.options.getElapsedSeconds() >= this.difficulty.commanderJoinDelay;
    }
    return true;
  }

  private hasCompositionRoom(unitId: string, counts: Record<string, number>, phase: BattlePhaseDefinition): boolean {
    const cap = phase.enemy.maxAttackByUnitId?.[unitId];
    return cap === undefined || (counts[unitId] ?? 0) < cap;
  }

  private maybeAlert(id: string, message: string, condition: boolean): void {
    if (!condition || this.alerted.has(id)) {
      return;
    }
    this.alerted.add(id);
    this.options.onAlert(message);
  }

  private attackCandidates(army: Unit[], phase: BattlePhaseDefinition): Unit[] {
    const candidates = army.filter((unit) => this.canJoinAttack(unit, phase));
    const reserveCount = Math.min(this.personality.defense.reserveDefenseUnits, Math.max(0, candidates.length - 1));
    if (reserveCount <= 0) {
      return candidates;
    }
    return candidates.slice(0, Math.max(1, candidates.length - reserveCount));
  }

  private defendBase(): void {
    const threat = this.findDefenseThreat();
    if (!threat) {
      return;
    }
    this.enemyArmy()
      .slice(0, this.config.defenseSquadSize)
      .forEach((unit) => unit.commandAttack(threat.id));
  }

  private findDefenseThreat(): Unit | undefined {
    const enemyBase = this.options
      .getBuildings()
      .find((building) => building.alive && building.team === "enemy" && building.definition.id === this.config.baseBuildingId);
    if (!enemyBase) {
      return undefined;
    }
    const baseThreat = this.options
      .getUnits()
      .find(
        (unit) =>
          unit.alive &&
          unit.team === "player" &&
          distance(unit.position, enemyBase.position) <= this.config.defendRadius
      );
    if (baseThreat) {
      return baseThreat;
    }

    if (!this.personality.defense.protectCaptureSites) {
      return undefined;
    }
    const defendedSites = this.options.getCaptureSites().filter((site) => site.owner === "enemy");
    return this.options
      .getUnits()
      .find(
        (unit) =>
          unit.alive &&
          unit.team === "player" &&
          defendedSites.some((site) => distance(unit.position, site.position as Position) <= this.config.defendRadius * 0.72)
      );
  }

  private shouldDefend(): boolean {
    return Boolean(this.findDefenseThreat());
  }

  private enemyArmy(): Unit[] {
    return this.options.getUnits().filter((unit) => unit.alive && unit.team === "enemy");
  }
}
