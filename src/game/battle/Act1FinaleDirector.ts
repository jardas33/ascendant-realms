import type { Act1FinalePhaseId, BattlefieldEventId, TacticalPlanId } from "../core/GameTypes";
import { ACT1_FINALE_NODE_ID, ACT1_FINALE_PHASES, type Act1FinalePhaseDefinition } from "../data/act1Finale";

export interface Act1FinaleDirectorContext {
  elapsedSeconds: number;
  tacticalPlanId?: TacticalPlanId;
  completedObjectiveIds: readonly string[];
  resourcesCaptured: number;
  playerOwnedSiteCount: number;
  enemyProductionAlive: boolean;
  enemyCommanderAlive: boolean;
  enemyCommanderDefeated: boolean;
}

export interface Act1FinalePhaseSnapshot {
  id: Act1FinalePhaseId;
  title: string;
  objective: string;
  completed: boolean;
  active: boolean;
  planMatched: boolean;
}

export interface Act1FinaleTransition {
  type: "phase_started" | "phase_completed" | "commander_released" | "finale_completed";
  phase: Act1FinalePhaseDefinition;
  telemetryLabel: string;
  eventIds?: BattlefieldEventId[];
  planMatched?: boolean;
}

export interface Act1FinaleDirectorUpdate {
  transitions: Act1FinaleTransition[];
  activePhase?: Act1FinalePhaseSnapshot;
}

export class Act1FinaleDirector {
  private activeIndex = 0;
  private started = false;
  private commanderReleased = false;
  private completed = false;
  private readonly completedPhaseIds = new Set<Act1FinalePhaseId>();
  private readonly startedPhaseIds = new Set<Act1FinalePhaseId>();

  get isEnabled(): boolean {
    return true;
  }

  get isCommanderReleased(): boolean {
    return this.commanderReleased;
  }

  get isCompleted(): boolean {
    return this.completed;
  }

  update(context: Act1FinaleDirectorContext): Act1FinaleDirectorUpdate {
    const transitions: Act1FinaleTransition[] = [];
    if (!this.started) {
      this.started = true;
      transitions.push(this.startPhase(ACT1_FINALE_PHASES[0], context));
    }

    let guard = 0;
    while (!this.completed && guard < ACT1_FINALE_PHASES.length) {
      guard += 1;
      const phase = ACT1_FINALE_PHASES[this.activeIndex];
      if (!phase || !this.isPhaseComplete(phase.id, context)) {
        break;
      }
      transitions.push({
        type: "phase_completed",
        phase,
        telemetryLabel: `${phase.title} completed: ${phase.completionHint}.`,
        eventIds: phase.id === "secure_foothold" ? phase.preferredEventIds : undefined,
        planMatched: this.phasePlanMatched(phase, context)
      });
      this.completedPhaseIds.add(phase.id);

      if (phase.id === "break_fortified_line" && !this.commanderReleased) {
        this.commanderReleased = true;
        transitions.push({
          type: "commander_released",
          phase: ACT1_FINALE_PHASES[2],
          telemetryLabel: "Captain Malrec released for the final commander defense.",
          eventIds: ACT1_FINALE_PHASES[2].preferredEventIds,
          planMatched: this.phasePlanMatched(ACT1_FINALE_PHASES[2], context)
        });
      }

      if (this.activeIndex >= ACT1_FINALE_PHASES.length - 1) {
        this.completed = true;
        transitions.push({
          type: "finale_completed",
          phase,
          telemetryLabel: `${ACT1_FINALE_NODE_ID} finale completed.`,
          planMatched: this.phasePlanMatched(phase, context)
        });
        break;
      }

      this.activeIndex += 1;
      transitions.push(this.startPhase(ACT1_FINALE_PHASES[this.activeIndex], context));
    }

    return {
      transitions,
      activePhase: this.activePhaseSnapshot(context)
    };
  }

  currentPhaseSnapshot(context: Act1FinaleDirectorContext): Act1FinalePhaseSnapshot | undefined {
    return this.activePhaseSnapshot(context);
  }

  private startPhase(phase: Act1FinalePhaseDefinition, context: Act1FinaleDirectorContext): Act1FinaleTransition {
    this.startedPhaseIds.add(phase.id);
    return {
      type: "phase_started",
      phase,
      telemetryLabel: `${phase.title} started: ${phase.objective}`,
      eventIds: phase.preferredEventIds,
      planMatched: this.phasePlanMatched(phase, context)
    };
  }

  private isPhaseComplete(phaseId: Act1FinalePhaseId, context: Act1FinaleDirectorContext): boolean {
    switch (phaseId) {
      case "secure_foothold":
        return (
          context.completedObjectiveIds.includes("capture_burned_shrine") ||
          context.resourcesCaptured > 0 ||
          context.playerOwnedSiteCount > 0
        );
      case "break_fortified_line":
        return context.completedObjectiveIds.includes("destroy_enemy_barracks") || !context.enemyProductionAlive;
      case "defeat_rival_commander":
        return context.enemyCommanderDefeated;
    }
  }

  private activePhaseSnapshot(context: Act1FinaleDirectorContext): Act1FinalePhaseSnapshot | undefined {
    const phase = ACT1_FINALE_PHASES[this.activeIndex];
    if (!phase) {
      return undefined;
    }
    return {
      id: phase.id,
      title: phase.title,
      objective: phase.objective,
      completed: this.completedPhaseIds.has(phase.id),
      active: !this.completed && this.startedPhaseIds.has(phase.id),
      planMatched: this.phasePlanMatched(phase, context)
    };
  }

  private phasePlanMatched(phase: Act1FinalePhaseDefinition, context: Act1FinaleDirectorContext): boolean {
    return context.tacticalPlanId === phase.recommendedPlanId;
  }
}
