import type {
  BattlefieldEventDefinition,
  BattlefieldEventId,
  EnemyDoctrineId,
  Position,
  ResourceBag,
  TacticalPlanId,
  Team
} from "../core/GameTypes";
import { BATTLEFIELD_EVENT_BY_ID, BATTLEFIELD_EVENTS } from "../data/battlefieldEvents";

const FIRST_EVENT_DELAY_SECONDS = 36;
const MAX_EVENTS_PER_BATTLE = 3;
const PLAN_SUPPORT_DURATION_REDUCTION_SECONDS = 5;

export interface BattlefieldEventSiteSnapshot {
  siteId: string;
  name: string;
  owner: Team;
  position: Position;
  incomeAmount: number;
  siteLevel?: number;
  workerCount?: number;
}

export interface BattlefieldEventUnitSnapshot {
  id: string;
  unitTypeId: string;
  name: string;
  team: Team;
  alive: boolean;
  position: Position;
  enemyEliteSquadId?: string;
  enemyEliteSquadName?: string;
}

export interface BattlefieldEventBuildingSnapshot {
  id: string;
  buildingId: string;
  name: string;
  team: Team;
  alive: boolean;
  position: Position;
}

export interface BattlefieldEventDirectorContext {
  elapsedSeconds: number;
  mode: string;
  rewardsDisabled?: boolean;
  missionTypeId?: string;
  modifierIds: readonly string[];
  doctrineId?: EnemyDoctrineId;
  tacticalPlanId?: TacticalPlanId;
  captureSites: readonly BattlefieldEventSiteSnapshot[];
  units: readonly BattlefieldEventUnitSnapshot[];
  buildings: readonly BattlefieldEventBuildingSnapshot[];
  commandHallAlive: boolean;
  retinueReinforcementAvailable: boolean;
  retinueReinforcementUsed: boolean;
  usedAbilityIds: readonly string[];
}

export interface ActiveBattlefieldEvent {
  id: BattlefieldEventId;
  name: string;
  objectiveLabel: string;
  objectiveSummary: string;
  counterplay: string;
  startedAtSeconds: number;
  endsAtSeconds: number;
  durationSeconds: number;
  targetId?: string;
  targetName?: string;
  targetPosition?: Position;
  targetKind: "site" | "command_hall" | "elite_squad" | "retinue" | "hero";
  eliteSquadId?: string;
  planMatched: boolean;
  startingUsedAbilityIds: string[];
  remainingSeconds: number;
  progressLabel: string;
}

export interface BattlefieldEventTransition {
  type: "started" | "completed" | "failed";
  event: ActiveBattlefieldEvent;
  definition: BattlefieldEventDefinition;
  telemetryLabel: string;
  resourceBonus?: Partial<ResourceBag>;
  heroManaGain?: number;
  pressureNudgeSeconds?: number;
}

export interface BattlefieldEventDirectorUpdate {
  transitions: BattlefieldEventTransition[];
  active?: ActiveBattlefieldEvent;
}

export class BattlefieldEventDirector {
  private active?: Omit<ActiveBattlefieldEvent, "remainingSeconds" | "progressLabel">;
  private cooldownSeconds = 0;
  private startedCount = 0;
  private readonly seenIds = new Set<BattlefieldEventId>();

  update(deltaSeconds: number, context: BattlefieldEventDirectorContext): BattlefieldEventDirectorUpdate {
    this.cooldownSeconds = Math.max(0, this.cooldownSeconds - Math.max(0, deltaSeconds));
    const transitions: BattlefieldEventTransition[] = [];

    if (!isBattlefieldEventDirectorEnabled(context)) {
      this.active = undefined;
      return { transitions };
    }

    if (this.active) {
      const transition = this.evaluateActiveEvent(context);
      if (transition) {
        transitions.push(transition);
      }
      return { transitions, active: this.activeSnapshot(context) };
    }

    if (
      this.cooldownSeconds > 0 ||
      this.startedCount >= MAX_EVENTS_PER_BATTLE ||
      context.elapsedSeconds < FIRST_EVENT_DELAY_SECONDS
    ) {
      return { transitions };
    }

    const definition = this.chooseNextEvent(context);
    if (!definition) {
      return { transitions };
    }
    const transition = this.startEvent(definition, context);
    return transition ? { transitions: [transition], active: this.activeSnapshot(context) } : { transitions };
  }

  forceStartEvent(eventId: BattlefieldEventId, context: BattlefieldEventDirectorContext): BattlefieldEventTransition | undefined {
    if (!isBattlefieldEventDirectorEnabled(context) || this.active) {
      return undefined;
    }
    const definition = BATTLEFIELD_EVENT_BY_ID[eventId];
    if (!definition || !this.isEventEligible(definition, context, true)) {
      return undefined;
    }
    return this.startEvent(definition, context);
  }

  resolveActiveEvent(
    outcome: "completed" | "failed",
    context: BattlefieldEventDirectorContext
  ): BattlefieldEventTransition | undefined {
    if (!this.active) {
      return undefined;
    }
    return this.finishActiveEvent(outcome, context, `${this.active.name} ${outcome}.`);
  }

  finishActiveForBattleEnd(context: BattlefieldEventDirectorContext): BattlefieldEventTransition | undefined {
    if (!this.active) {
      return undefined;
    }
    const endContext = {
      ...context,
      elapsedSeconds: Math.max(context.elapsedSeconds, this.active.endsAtSeconds)
    };
    return this.evaluateActiveEvent(endContext) ?? this.finishActiveEvent("failed", context, `${this.active.name} ended with battle.`);
  }

  getActiveEvent(context: BattlefieldEventDirectorContext): ActiveBattlefieldEvent | undefined {
    return this.activeSnapshot(context);
  }

  private chooseNextEvent(context: BattlefieldEventDirectorContext): BattlefieldEventDefinition | undefined {
    return BATTLEFIELD_EVENTS.map((definition, order) => ({
      definition,
      order,
      score: this.scoreEvent(definition, context)
    }))
      .filter((entry) => entry.score > 0)
      .sort((left, right) => right.score - left.score || left.order - right.order)[0]?.definition;
  }

  private scoreEvent(definition: BattlefieldEventDefinition, context: BattlefieldEventDirectorContext): number {
    if (!this.isEventEligible(definition, context, false)) {
      return 0;
    }
    let score = 1;
    if (context.doctrineId && definition.eligibleDoctrineIds.includes(context.doctrineId)) {
      score += 4;
    }
    if (context.missionTypeId && definition.preferredMissionTypeIds.includes(context.missionTypeId)) {
      score += 3;
    }
    if (context.modifierIds.some((modifierId) => definition.preferredModifierIds.includes(modifierId))) {
      score += 2;
    }
    if (context.tacticalPlanId && definition.recommendedTacticalPlanIds.includes(context.tacticalPlanId)) {
      score += 2;
    }
    if (definition.id === "elite_strike" && context.units.some((unit) => unit.alive && unit.enemyEliteSquadId)) {
      score += 2;
    }
    if (definition.id === "reinforcement_window" && context.retinueReinforcementAvailable) {
      score += 2;
    }
    return score;
  }

  private isEventEligible(
    definition: BattlefieldEventDefinition,
    context: BattlefieldEventDirectorContext,
    forced: boolean
  ): boolean {
    if (!forced && this.seenIds.has(definition.id)) {
      return false;
    }
    switch (definition.id) {
      case "site_under_threat":
        return context.captureSites.some((site) => site.owner === "player");
      case "hold_the_line":
        return context.commandHallAlive;
      case "elite_strike":
        return context.units.some((unit) => unit.alive && unit.enemyEliteSquadId);
      case "reinforcement_window":
        return context.retinueReinforcementAvailable && !context.retinueReinforcementUsed;
      case "aether_surge":
        return (
          context.modifierIds.includes("mission_aether_surge") ||
          context.tacticalPlanId === "champion_hunt" ||
          context.doctrineId === "hunter"
        );
      default:
        return false;
    }
  }

  private startEvent(
    definition: BattlefieldEventDefinition,
    context: BattlefieldEventDirectorContext
  ): BattlefieldEventTransition | undefined {
    const target = this.selectEventTarget(definition, context);
    if (!target) {
      return undefined;
    }
    const planMatched = Boolean(context.tacticalPlanId && definition.recommendedTacticalPlanIds.includes(context.tacticalPlanId));
    const durationSeconds = Math.max(
      18,
      definition.durationSeconds - (planMatched ? PLAN_SUPPORT_DURATION_REDUCTION_SECONDS : 0)
    );
    this.active = {
      id: definition.id,
      name: definition.name,
      objectiveLabel: target.objectiveLabel,
      objectiveSummary: definition.objectiveSummary,
      counterplay: definition.counterplay,
      startedAtSeconds: context.elapsedSeconds,
      endsAtSeconds: context.elapsedSeconds + durationSeconds,
      durationSeconds,
      targetId: target.targetId,
      targetName: target.targetName,
      targetPosition: target.targetPosition,
      targetKind: target.targetKind,
      eliteSquadId: target.eliteSquadId,
      planMatched,
      startingUsedAbilityIds: [...context.usedAbilityIds]
    };
    this.startedCount += 1;
    this.seenIds.add(definition.id);
    return {
      type: "started",
      event: this.activeSnapshot(context)!,
      definition,
      telemetryLabel: `${definition.name} started: ${target.objectiveLabel}`,
      heroManaGain: definition.startHeroManaGain,
      pressureNudgeSeconds: definition.pressureNudgeSeconds
    };
  }

  private selectEventTarget(
    definition: BattlefieldEventDefinition,
    context: BattlefieldEventDirectorContext
  ):
    | {
        targetKind: ActiveBattlefieldEvent["targetKind"];
        objectiveLabel: string;
        targetId?: string;
        targetName?: string;
        targetPosition?: Position;
        eliteSquadId?: string;
      }
    | undefined {
    if (definition.id === "site_under_threat") {
      const site = [...context.captureSites]
        .filter((candidate) => candidate.owner === "player")
        .sort((left, right) => scoreSiteTarget(right) - scoreSiteTarget(left) || left.name.localeCompare(right.name))[0];
      return site
        ? {
            targetKind: "site",
            targetId: site.siteId,
            targetName: site.name,
            targetPosition: site.position,
            objectiveLabel: `Hold ${site.name}`
          }
        : undefined;
    }
    if (definition.id === "hold_the_line") {
      const commandHall = context.buildings.find(
        (building) => building.alive && building.team === "player" && building.buildingId === "command_hall"
      );
      return commandHall
        ? {
            targetKind: "command_hall",
            targetId: commandHall.id,
            targetName: commandHall.name,
            targetPosition: commandHall.position,
            objectiveLabel: "Protect Command Hall"
          }
        : undefined;
    }
    if (definition.id === "elite_strike") {
      const elite = context.units.find((unit) => unit.alive && unit.enemyEliteSquadId);
      return elite?.enemyEliteSquadId
        ? {
            targetKind: "elite_squad",
            targetId: elite.enemyEliteSquadId,
            targetName: elite.enemyEliteSquadName ?? "elite squad",
            targetPosition: elite.position,
            eliteSquadId: elite.enemyEliteSquadId,
            objectiveLabel: `Defeat ${elite.enemyEliteSquadName ?? "elite squad"}`
          }
        : undefined;
    }
    if (definition.id === "reinforcement_window") {
      return {
        targetKind: "retinue",
        targetName: "Ready reserve Retinue",
        objectiveLabel: "Optional Retinue call"
      };
    }
    if (definition.id === "aether_surge") {
      return {
        targetKind: "hero",
        targetName: "Hero abilities",
        objectiveLabel: "Use a hero ability"
      };
    }
    return undefined;
  }

  private evaluateActiveEvent(context: BattlefieldEventDirectorContext): BattlefieldEventTransition | undefined {
    const active = this.active;
    if (!active) {
      return undefined;
    }
    if (active.id === "elite_strike" && active.eliteSquadId && !hasLivingEliteSquad(context, active.eliteSquadId)) {
      return this.finishActiveEvent("completed", context, `${active.name} completed: ${active.targetName ?? "elite squad"} defeated.`);
    }
    if (active.id === "reinforcement_window" && context.retinueReinforcementUsed) {
      return this.finishActiveEvent("completed", context, `${active.name} completed: Retinue reinforcement used.`);
    }
    if (active.id === "aether_surge" && context.usedAbilityIds.some((abilityId) => !active.startingUsedAbilityIds.includes(abilityId))) {
      return this.finishActiveEvent("completed", context, `${active.name} completed: hero ability used.`);
    }
    if (active.id === "hold_the_line" && !context.commandHallAlive) {
      return this.finishActiveEvent("failed", context, `${active.name} failed: Command Hall destroyed.`);
    }
    if (context.elapsedSeconds < active.endsAtSeconds) {
      return undefined;
    }
    if (active.id === "site_under_threat") {
      const site = context.captureSites.find((candidate) => candidate.siteId === active.targetId);
      const outcome = site?.owner === "player" ? "completed" : "failed";
      const held = site?.owner === "player" ? "held" : "lost";
      return this.finishActiveEvent(outcome, context, `${active.name} ${outcome}: ${active.targetName ?? "site"} ${held}.`);
    }
    if (active.id === "hold_the_line") {
      return this.finishActiveEvent("completed", context, `${active.name} completed: Command Hall held.`);
    }
    if (active.id === "elite_strike") {
      return this.finishActiveEvent("failed", context, `${active.name} failed: elite squad still active.`);
    }
    if (active.id === "reinforcement_window") {
      return this.finishActiveEvent("failed", context, `${active.name} ended unused.`);
    }
    if (active.id === "aether_surge") {
      return this.finishActiveEvent("failed", context, `${active.name} ended before an ability was used.`);
    }
    return undefined;
  }

  private finishActiveEvent(
    outcome: "completed" | "failed",
    context: BattlefieldEventDirectorContext,
    telemetryLabel: string
  ): BattlefieldEventTransition | undefined {
    const active = this.active;
    if (!active) {
      return undefined;
    }
    const definition = BATTLEFIELD_EVENT_BY_ID[active.id];
    const event = this.activeSnapshot(context)!;
    this.active = undefined;
    this.cooldownSeconds = definition.cooldownSeconds;
    return {
      type: outcome,
      event,
      definition,
      telemetryLabel,
      resourceBonus: outcome === "completed" ? definition.completionBonus : undefined
    };
  }

  private activeSnapshot(context: BattlefieldEventDirectorContext): ActiveBattlefieldEvent | undefined {
    if (!this.active) {
      return undefined;
    }
    const remainingSeconds = Math.max(0, Math.ceil(this.active.endsAtSeconds - context.elapsedSeconds));
    return {
      ...this.active,
      remainingSeconds,
      progressLabel: this.progressLabel(this.active, context, remainingSeconds)
    };
  }

  private progressLabel(
    active: Omit<ActiveBattlefieldEvent, "remainingSeconds" | "progressLabel">,
    context: BattlefieldEventDirectorContext,
    remainingSeconds: number
  ): string {
    if (active.id === "site_under_threat") {
      const site = context.captureSites.find((candidate) => candidate.siteId === active.targetId);
      return `${site?.owner === "player" ? "Held" : "Contested"} - ${remainingSeconds}s`;
    }
    if (active.id === "elite_strike") {
      const remaining = active.eliteSquadId
        ? context.units.filter((unit) => unit.alive && unit.enemyEliteSquadId === active.eliteSquadId).length
        : 0;
      return `${remaining} elite ${remaining === 1 ? "unit" : "units"} - ${remainingSeconds}s`;
    }
    if (active.id === "reinforcement_window") {
      return context.retinueReinforcementUsed ? "Reinforcement used" : `Open - ${remainingSeconds}s`;
    }
    if (active.id === "aether_surge") {
      const used = context.usedAbilityIds.some((abilityId) => !active.startingUsedAbilityIds.includes(abilityId));
      return used ? "Ability used" : `Surge active - ${remainingSeconds}s`;
    }
    return context.commandHallAlive ? `Holding - ${remainingSeconds}s` : "Command Hall down";
  }
}

export function isBattlefieldEventDirectorEnabled(context: BattlefieldEventDirectorContext): boolean {
  return context.mode === "campaign_node" && !context.rewardsDisabled;
}

function scoreSiteTarget(site: BattlefieldEventSiteSnapshot): number {
  return site.incomeAmount + (site.siteLevel ?? 1) * 4 + (site.workerCount ?? 0) * 3;
}

function hasLivingEliteSquad(context: BattlefieldEventDirectorContext, squadId: string): boolean {
  return context.units.some((unit) => unit.alive && unit.enemyEliteSquadId === squadId);
}
