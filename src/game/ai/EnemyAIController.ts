import type {
  BattleDifficulty,
  BattleDifficultyDefinition,
  BattlePhaseDefinition,
  EnemyDoctrineDefinition,
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
import { ResourceSystem, resourceSiteWorkerSlotCapacity } from "../systems/ResourceSystem";
import { TrainingSystem } from "../systems/TrainingSystem";
import { UpgradeSystem } from "../systems/UpgradeSystem";
import { AIStateMachine } from "./AIStateMachine";
import { createEnemyBaseDevelopmentPlan, type EnemyBaseDevelopmentPlan } from "./EnemyBaseDevelopmentStrategy";
import {
  chooseEnemyResourceSitePlan,
  combatUnitsForTeam,
  isSitePlanOutmatched,
  scoreEnemyResourceSite
} from "./EnemyResourceSiteStrategy";

const RESOURCE_SITE_RAID_INITIAL_DELAY_SECONDS = 150;
const RESOURCE_SITE_RAID_INTERVAL_SECONDS = 62;
const RESOURCE_SITE_UPGRADE_INITIAL_DELAY_SECONDS = 135;
const RESOURCE_SITE_UPGRADE_COOLDOWN_SECONDS = 85;
const RESOURCE_SITE_ABSTRACT_WORKER_INITIAL_DELAY_SECONDS = 170;
const RESOURCE_SITE_ABSTRACT_WORKER_COOLDOWN_SECONDS = 76;
const RESOURCE_SITE_RAID_RETREAT_CHECK_SECONDS = 7;
const RESOURCE_SITE_RAID_MAX_SECONDS = 44;
const RESOURCE_SITE_THREAT_PADDING = 190;
const ENEMY_TECH_INITIAL_DELAY_SECONDS = 115;
const ENEMY_TECH_COOLDOWN_SECONDS = 68;
const ENEMY_TECH_UPGRADE_IDS = [
  "camp_foundations_1",
  "sentry_bracing_1",
  "infantry_weapons_1",
  "reinforced_armor_1",
  "aether_study_1"
] as const;

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
  resourceSystem: ResourceSystem;
  training: TrainingSystem;
  upgradeSystem: UpgradeSystem;
  isUpgradeResearched?: (upgradeId: string) => boolean;
  getAttackTarget: () => Building | undefined;
  getElapsedSeconds: () => number;
  getPlayerMilestones: () => PlayerMilestones;
  onAlert: (message: string, x?: number, y?: number) => void;
  onWaveLaunched: (units: Unit[]) => void;
  difficulty: BattleDifficulty;
  config: EnemyAIConfig;
  aiPersonalityId?: EnemyAIPersonalityId;
  doctrine?: EnemyDoctrineDefinition;
  modifierIds?: string[];
  onDoctrineAction?: (label: string) => void;
  attackWarningLeadSeconds?: number;
  canEnemyHeroJoinAttack?: (unit: Unit) => boolean;
}

export class EnemyAIController {
  readonly state = new AIStateMachine();
  private incomeTimer = 0;
  private trainTimer = 0;
  private expandTimer: number;
  private attackTimer: number;
  private trainPlanIndex = 0;
  private attacksLaunched = 0;
  private raidTimer = RESOURCE_SITE_RAID_INTERVAL_SECONDS;
  private siteUpgradeTimer = RESOURCE_SITE_UPGRADE_COOLDOWN_SECONDS;
  private abstractWorkerTimer = RESOURCE_SITE_ABSTRACT_WORKER_COOLDOWN_SECONDS;
  private techTimer = ENEMY_TECH_COOLDOWN_SECONDS;
  private hunterTimer = 0;
  private activeRaid?: { siteId: string; unitIds: string[]; startedAt: number };
  private readonly knownEnemySiteIds = new Set<string>();
  private readonly alerted = new Set<string>();
  private readonly difficulty: BattleDifficultyDefinition;
  private readonly config: EnemyAIConfig;
  private readonly personality: EnemyAIPersonalityDefinition;
  private currentBasePlan?: EnemyBaseDevelopmentPlan;

  constructor(private readonly options: EnemyAIOptions) {
    this.personality = getAIPersonality(options.aiPersonalityId);
    this.difficulty = applyAIPersonalityToDifficulty(getBattleDifficulty(options.difficulty), this.personality);
    this.config = applyAIPersonalityToConfig(options.config, this.personality);
    this.expandTimer = Math.max(0, this.config.expandInterval - this.config.initialExpandDelay);
    this.attackTimer = 0;
    this.hunterTimer = options.doctrine?.activity.hunterCooldownSeconds ?? 0;
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
    this.raidTimer += deltaSeconds;
    this.siteUpgradeTimer += deltaSeconds;
    this.abstractWorkerTimer += deltaSeconds;
    this.techTimer += deltaSeconds;
    this.hunterTimer += deltaSeconds;
    this.trackKnownEnemySites();
    const basePlan = this.createBaseDevelopmentPlan(elapsedSeconds);
    this.currentBasePlan = basePlan;
    this.maybeAnnounceBaseDevelopment(basePlan);

    if (this.incomeTimer >= this.config.incomeInterval) {
      this.incomeTimer = 0;
      addResources(this.options.resources, scaledEnemyIncome(this.config.incomePerTick, this.difficulty.enemyIncomeMultiplier));
    }

    if (this.trainTimer >= this.config.trainInterval) {
      this.trainTimer = 0;
      this.trainEnemyUnit(phase);
    }

    this.maybeUpgradeEnemyResourceSite(elapsedSeconds);
    this.maybeStaffEnemyResourceSite(elapsedSeconds);
    this.maybeResearchEnemyTech(elapsedSeconds, basePlan);

    if (this.maybeRegroupWeakRaid(elapsedSeconds)) {
      return;
    }

    const defenseFocus = this.findDefenseFocus();
    if (defenseFocus) {
      this.state.set("DEFEND");
      this.defendFocus(defenseFocus);
      return;
    }

    const enemyArmy = this.enemyArmy();
    if (this.maybeLaunchHunterPressure(enemyArmy, phase, elapsedSeconds)) {
      return;
    }
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
      this.state.set(basePlan.stage === "late" ? "ESCALATE" : "ATTACK");
      this.options.onAlert(basePlan.stage === "late" ? "Enemy pressure is escalating." : "Enemy attack incoming.");
      if (this.options.doctrine) {
        this.options.onDoctrineAction?.(`${this.options.doctrine.name} attack wave`);
      }
      this.sendAttackWave(attackWave);
      this.options.onWaveLaunched(attackWave);
      return;
    }

    if (this.maybeLaunchEconomyRaid(enemyArmy, phase, elapsedSeconds)) {
      return;
    }

    if (this.expandTimer >= this.config.expandInterval) {
      this.expandTimer = 0;
      this.state.set(enemyArmy.length >= 3 ? "EXPAND" : "BUILD_ARMY");
      this.maybeAlert("scouts", "Enemy scouts are moving.", true);
      this.executeSiteExpansionPlan(enemyArmy, phase);
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

  private executeSiteExpansionPlan(army: Unit[], phase: BattlePhaseDefinition): boolean {
    if (army.length === 0) {
      return false;
    }
    const plan = chooseEnemyResourceSitePlan(this.resourceSiteContext(), new Set(["capture", "retake"]));
    if (!plan) {
      return false;
    }
    const squad = this.selectSiteSquad(army, phase, plan.recommendedSquadSize);
    if (squad.length === 0 || isSitePlanOutmatched(plan, squad)) {
      return false;
    }
    if (plan.task === "retake") {
      this.state.set("CONTEST_SITE");
      this.options.onAlert(`Enemy forces are moving to retake ${plan.site.definition.name}.`, plan.site.position.x, plan.site.position.y - 74);
    }
    this.moveSquadToSite(squad, plan.site);
    return true;
  }

  private maybeLaunchEconomyRaid(army: Unit[], phase: BattlePhaseDefinition, elapsedSeconds: number): boolean {
    if (
      elapsedSeconds < this.resourceSiteRaidInitialDelaySeconds() ||
      this.raidTimer < this.resourceSiteRaidIntervalSeconds() ||
      this.activeRaid
    ) {
      return false;
    }
    const plan = chooseEnemyResourceSitePlan(this.resourceSiteContext(), new Set(["raid"]));
    if (!plan) {
      return false;
    }
    const squad = this.selectSiteSquad(army, phase, plan.recommendedSquadSize + this.doctrineRaidSquadBonus());
    if (squad.length < Math.min(2, plan.recommendedSquadSize) || isSitePlanOutmatched(plan, squad)) {
      return false;
    }
    this.raidTimer = 0;
    this.activeRaid = {
      siteId: plan.site.id,
      unitIds: squad.map((unit) => unit.id),
      startedAt: elapsedSeconds
    };
    this.state.set("RAID_SITE");
    this.options.onAlert(`Enemy raid forming at ${plan.site.definition.name}.`, plan.site.position.x, plan.site.position.y - 74);
    this.options.onDoctrineAction?.(`${this.options.doctrine?.name ?? "Enemy"} raid at ${plan.site.definition.name}`);
    this.moveSquadToSite(squad, plan.site);
    return true;
  }

  private maybeRegroupWeakRaid(elapsedSeconds: number): boolean {
    const raid = this.activeRaid;
    if (!raid) {
      return false;
    }
    const raidAge = elapsedSeconds - raid.startedAt;
    const site = this.options.getCaptureSites().find((candidate) => candidate.id === raid.siteId);
    const raidUnits = this.options.getUnits().filter((unit) => raid.unitIds.includes(unit.id) && unit.alive);
    if (!site || site.owner !== "player" || raidUnits.length === 0 || raidAge > RESOURCE_SITE_RAID_MAX_SECONDS) {
      this.activeRaid = undefined;
      return false;
    }
    if (raidAge < RESOURCE_SITE_RAID_RETREAT_CHECK_SECONDS) {
      return false;
    }
    const plan = scoreEnemyResourceSite(site, this.resourceSiteContext());
    if (!isSitePlanOutmatched(plan, raidUnits)) {
      return false;
    }
    this.activeRaid = undefined;
    this.state.set("RETREAT");
    this.moveSquadToPoint(raidUnits, this.enemyBasePosition());
    this.maybeAlert("raid-regroup", "Enemy raiders are regrouping.", true);
    return true;
  }

  private maybeResearchEnemyTech(elapsedSeconds: number, basePlan: EnemyBaseDevelopmentPlan): boolean {
    if (
      elapsedSeconds < ENEMY_TECH_INITIAL_DELAY_SECONDS ||
      this.techTimer < this.enemyTechCooldownSeconds() ||
      this.enemyUpgradeQueueDepth() > 0
    ) {
      return false;
    }

    for (const candidate of basePlan.techCandidates) {
      const researched = this.options.upgradeSystem.queueUpgrade(candidate.building, candidate.upgradeId, this.options.resources, {
        announce: false
      });
      if (!researched) {
        continue;
      }
      this.techTimer = 0;
      const defensive = candidate.upgradeId === "camp_foundations_1" || candidate.upgradeId === "sentry_bracing_1";
      this.state.set(defensive ? "FORTIFY_BASE" : "TECH_UP");
      this.options.onAlert(
        defensive ? "Enemy is fortifying." : "Enemy tech is advancing.",
        candidate.building.position.x,
        candidate.building.position.y - 74
      );
      this.options.onDoctrineAction?.(`${this.options.doctrine?.name ?? "Enemy"} tech: ${candidate.reason}`);
      return true;
    }

    return false;
  }

  private maybeUpgradeEnemyResourceSite(elapsedSeconds: number): boolean {
    if (
      elapsedSeconds < RESOURCE_SITE_UPGRADE_INITIAL_DELAY_SECONDS ||
      this.siteUpgradeTimer < RESOURCE_SITE_UPGRADE_COOLDOWN_SECONDS
    ) {
      return false;
    }
    const target = this.options
      .getCaptureSites()
      .filter((site) => site.alive && site.owner === "enemy" && site.siteLevel < 2)
      .sort((a, b) => this.enemySiteUpgradeValue(b) - this.enemySiteUpgradeValue(a))[0];
    if (!target) {
      return false;
    }
    const upgraded = this.options.resourceSystem.requestSiteUpgrade(target, this.options.resources, {
      owner: "enemy",
      announce: false
    });
    if (!upgraded) {
      return false;
    }
    this.siteUpgradeTimer = 0;
    this.abstractWorkerTimer = 0;
    this.state.set("UPGRADE_SITE");
    this.options.onAlert(`${target.definition.name} has been improved by the enemy.`, target.position.x, target.position.y - 78);
    return true;
  }

  private maybeStaffEnemyResourceSite(elapsedSeconds: number): boolean {
    if (
      elapsedSeconds < RESOURCE_SITE_ABSTRACT_WORKER_INITIAL_DELAY_SECONDS ||
      this.abstractWorkerTimer < RESOURCE_SITE_ABSTRACT_WORKER_COOLDOWN_SECONDS
    ) {
      return false;
    }
    const target = this.options
      .getCaptureSites()
      .filter(
        (site) =>
          site.alive &&
          site.owner === "enemy" &&
          site.siteLevel >= 2 &&
          site.abstractEnemyWorkerSlots < Math.min(1, resourceSiteWorkerSlotCapacity(site))
      )
      .sort((a, b) => this.enemySiteUpgradeValue(b) - this.enemySiteUpgradeValue(a))[0];
    if (!target) {
      return false;
    }
    target.setAbstractEnemyWorkerSlots(target.abstractEnemyWorkerSlots + 1);
    this.abstractWorkerTimer = 0;
    return true;
  }

  private moveSquadToSite(army: Unit[], target: CaptureSite): void {
    army.forEach((unit, index) => {
      unit.commandMove({ x: target.position.x + index * 20, y: target.position.y + index * 16 }, true);
    });
  }

  private maybeLaunchHunterPressure(army: Unit[], phase: BattlePhaseDefinition, elapsedSeconds: number): boolean {
    const doctrine = this.options.doctrine;
    if (!doctrine || doctrine.id !== "hunter") {
      return false;
    }
    const initialDelay = doctrine.activity.hunterInitialDelaySeconds ?? 215;
    const cooldown = doctrine.activity.hunterCooldownSeconds ?? 118;
    const requestedSize = doctrine.activity.hunterEscortCount ?? 3;
    if (elapsedSeconds < initialDelay || this.hunterTimer < cooldown) {
      return false;
    }
    const target = this.hunterPressureTarget();
    if (!target) {
      return false;
    }
    const candidates = army.filter((unit) => this.canStandardUnitJoinAttack(unit, phase));
    const squad = candidates.slice(0, requestedSize);
    if (squad.length < requestedSize) {
      return false;
    }
    this.hunterTimer = 0;
    this.state.set("HUNTER_PRESSURE");
    squad.forEach((unit) => unit.commandAttack(target.id, target.definition.name));
    this.options.onAlert(
      `Hunter squad is probing ${target.retinueUnitId ? "your Retinue" : "your hero"}.`,
      target.position.x,
      target.position.y - 70
    );
    this.options.onDoctrineAction?.(
      target.retinueUnitId ? "Hunter pressure on Retinue" : "Hunter pressure on hero"
    );
    return true;
  }

  private hunterPressureTarget(): Unit | undefined {
    const playerBase = this.options.getAttackTarget();
    const enemyBase = this.enemyBasePosition();
    return this.options
      .getUnits()
      .filter((unit) => unit.alive && unit.team === "player" && (unit.kind === "hero" || Boolean(unit.retinueUnitId)))
      .filter((unit) => !playerBase || distance(unit.position, playerBase.position) >= 320 || distance(unit.position, enemyBase) <= 760)
      .sort((left, right) => {
        const leftPriority = left.retinueUnitId ? 0 : 1;
        const rightPriority = right.retinueUnitId ? 0 : 1;
        return leftPriority - rightPriority || distance(left.position, enemyBase) - distance(right.position, enemyBase);
      })[0];
  }

  private resourceSiteRaidInitialDelaySeconds(): number {
    return this.options.doctrine?.activity.resourceRaidInitialDelaySeconds ?? RESOURCE_SITE_RAID_INITIAL_DELAY_SECONDS;
  }

  private resourceSiteRaidIntervalSeconds(): number {
    const multiplier = this.doctrineActivityMultiplier(this.options.doctrine?.activity.resourceRaidCooldownMultiplier ?? 1);
    return Math.max(42, RESOURCE_SITE_RAID_INTERVAL_SECONDS * multiplier);
  }

  private enemyTechCooldownSeconds(): number {
    return Math.max(50, ENEMY_TECH_COOLDOWN_SECONDS * (this.options.doctrine?.activity.techCooldownMultiplier ?? 1));
  }

  private doctrineRaidSquadBonus(): number {
    return Math.max(0, Math.min(1, this.options.doctrine?.activity.resourceRaidSquadBonus ?? 0));
  }

  private doctrineDefenseReserveBonus(): number {
    return Math.max(0, Math.min(1, this.options.doctrine?.activity.defenseReserveBonus ?? 0));
  }

  private doctrineAttackWaveSizeBonus(): number {
    const bonus = this.options.doctrine?.activity.attackWaveSizeBonus ?? 0;
    if (bonus <= 0 || this.options.getElapsedSeconds() < 300) {
      return 0;
    }
    return Math.min(1, bonus);
  }

  private doctrineActivityMultiplier(baseMultiplier: number): number {
    const patrolModifier = this.options.modifierIds?.includes("mission_enemy_patrols") ? 0.94 : 1;
    return baseMultiplier * patrolModifier;
  }

  private moveSquadToPoint(army: Unit[], target: Position): void {
    army.forEach((unit, index) => {
      unit.commandMove({ x: target.x + index * 18, y: target.y + index * 14 }, false);
    });
  }

  private selectSiteSquad(army: Unit[], phase: BattlePhaseDefinition, requestedSize: number): Unit[] {
    if (requestedSize <= 0) {
      return [];
    }
    const candidates = army.filter((unit) => this.canJoinSiteStrategy(unit, phase));
    const idle = candidates.filter((unit) => !unit.attackTargetId);
    const pool = idle.length >= Math.min(requestedSize, candidates.length) ? idle : candidates;
    const reserve = (this.currentBasePlan?.defenseReserveUnits ?? 0) + this.doctrineDefenseReserveBonus();
    const availableCount = Math.max(0, pool.length - reserve);
    return pool.slice(0, Math.min(requestedSize, availableCount));
  }

  private canJoinSiteStrategy(unit: Unit, phase: BattlePhaseDefinition): boolean {
    if (!unit.alive || unit.team !== "enemy") {
      return false;
    }
    if (unit.enemyHeroId) {
      return false;
    }
    if (unit.definition.id === "enemy_commander") {
      return phase.enemy.commanderAllowed && this.options.getElapsedSeconds() >= this.difficulty.commanderJoinDelay;
    }
    return true;
  }

  private resourceSiteContext() {
    return {
      sites: this.options.getCaptureSites(),
      enemyUnits: combatUnitsForTeam(this.options.getUnits(), "enemy"),
      playerUnits: combatUnitsForTeam(this.options.getUnits(), "player"),
      enemyBasePosition: this.enemyBasePosition(),
      knownEnemySiteIds: this.knownEnemySiteIds
    };
  }

  private createBaseDevelopmentPlan(elapsedSeconds: number): EnemyBaseDevelopmentPlan {
    return createEnemyBaseDevelopmentPlan({
      elapsedSeconds,
      resources: this.options.resources,
      buildings: this.options.getBuildings(),
      sites: this.options.getCaptureSites(),
      enemyUnits: combatUnitsForTeam(this.options.getUnits(), "enemy"),
      playerUnits: combatUnitsForTeam(this.options.getUnits(), "player"),
      enemyBasePosition: this.enemyBasePosition(),
      researchedUpgradeIds: this.currentEnemyResearchedUpgradeIds()
    });
  }

  private currentEnemyResearchedUpgradeIds(): ReadonlySet<string> {
    const ids = new Set<string>();
    ENEMY_TECH_UPGRADE_IDS.forEach((upgradeId) => {
      if (this.options.isUpgradeResearched?.(upgradeId)) {
        ids.add(upgradeId);
      }
    });
    this.options.getUnits().forEach((unit) => {
      if (unit.team === "enemy") {
        unit.appliedUpgradeIds?.forEach((upgradeId) => ids.add(upgradeId));
      }
    });
    this.options.getBuildings().forEach((building) => {
      if (building.team === "enemy") {
        building.appliedUpgradeIds?.forEach((upgradeId) => ids.add(upgradeId));
      }
    });
    return ids;
  }

  private enemyUpgradeQueueDepth(): number {
    return this.options
      .getBuildings()
      .filter((building) => building.alive && building.team === "enemy")
      .reduce((sum, building) => sum + building.upgradeQueue.length, 0);
  }

  private trackKnownEnemySites(): void {
    this.options.getCaptureSites().forEach((site) => {
      if (site.owner === "enemy") {
        this.knownEnemySiteIds.add(site.definition.id);
      }
    });
  }

  private enemySiteUpgradeValue(site: CaptureSite): number {
    return site.definition.incomeAmount * (site.siteLevel >= 2 ? 1.35 : 1) - distance(this.enemyBasePosition(), site.position) / 190;
  }

  private enemyBasePosition(): Position {
    return (
      this.options
        .getBuildings()
        .find((building) => building.alive && building.team === "enemy" && building.definition.id === this.config.baseBuildingId)
        ?.position ?? { x: 0, y: 0 }
    );
  }

  private findDefenseFocus(): { target: Unit; site?: CaptureSite } | undefined {
    const enemyBase = this.options
      .getBuildings()
      .find((building) => building.alive && building.team === "enemy" && building.definition.id === this.config.baseBuildingId);
    if (!enemyBase) {
      return;
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
      return { target: baseThreat };
    }

    const plan = chooseEnemyResourceSitePlan(this.resourceSiteContext(), new Set(["defend"]));
    if (!plan) {
      return undefined;
    }
    const squad = this.defenseSquad();
    if (squad.length === 0 || isSitePlanOutmatched(plan, squad)) {
      return undefined;
    }
    const siteThreat = this.options
      .getUnits()
      .find(
        (unit) =>
          unit.alive &&
          unit.team === "player" &&
          distance(unit.position, plan.site.position as Position) <= plan.site.definition.radius + RESOURCE_SITE_THREAT_PADDING
      );
    return siteThreat ? { target: siteThreat, site: plan.site } : undefined;
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
    const strategicBonus = (this.currentBasePlan?.attackWaveSizeBonus ?? 0) + this.doctrineAttackWaveSizeBonus();
    let maxSize = Math.min(this.config.attackWaveSize + strategicBonus, phase.enemy.maxAttackWaveSize + strategicBonus);
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
    if (unit.enemyHeroId) {
      return this.canEnemyHeroJoinCoordinatedAttack(unit, phase);
    }
    return this.canStandardUnitJoinAttack(unit, phase);
  }

  private canStandardUnitJoinAttack(unit: Unit, phase: BattlePhaseDefinition): boolean {
    const unitId = unit.definition.id;
    if (!phase.enemy.allowedAttackUnitIds.includes(unitId)) {
      return false;
    }
    if (unitId === "enemy_commander") {
      const canJoinFirstAttack = this.personality.commander.joinsFirstAttack || this.attacksLaunched > 0;
      return (
        canJoinFirstAttack &&
        phase.enemy.commanderAllowed &&
        this.options.getElapsedSeconds() >= this.difficulty.commanderJoinDelay &&
        (this.options.canEnemyHeroJoinAttack?.(unit) ?? true)
      );
    }
    return true;
  }

  private canEnemyHeroJoinCoordinatedAttack(unit: Unit, phase: BattlePhaseDefinition): boolean {
    const unitId = unit.definition.id;
    if (!phase.enemy.allowedAttackUnitIds.includes(unitId)) {
      return false;
    }
    const basePlan = this.currentBasePlan;
    if (
      !basePlan ||
      basePlan.stage !== "late" ||
      basePlan.attackWaveSizeBonus <= 0 ||
      !phase.enemy.commanderAllowed ||
      this.attacksLaunched === 0 ||
      this.options.getElapsedSeconds() < this.difficulty.commanderJoinDelay
    ) {
      return false;
    }
    if (!(this.options.canEnemyHeroJoinAttack?.(unit) ?? true)) {
      return false;
    }
    const escortCount = this.enemyArmy().filter((ally) => ally !== unit && this.canStandardUnitJoinAttack(ally, phase)).length;
    return escortCount >= Math.max(3, this.config.minAttackArmySize);
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
    const strategicReserve = (this.currentBasePlan?.defenseReserveUnits ?? 0) + this.doctrineDefenseReserveBonus();
    const reserveCount = Math.min(
      this.personality.defense.reserveDefenseUnits + strategicReserve,
      Math.max(0, candidates.length - 1)
    );
    if (reserveCount <= 0) {
      return candidates;
    }
    return candidates.slice(0, Math.max(1, candidates.length - reserveCount));
  }

  private defendFocus(focus: { target: Unit; site?: CaptureSite }): void {
    if (focus.site) {
      this.maybeAlert(`defending-site-${focus.site.definition.id}`, `Enemy defending site: ${focus.site.definition.name}.`, true);
    } else {
      this.maybeAlert("defending-base", "Enemy defending base.", true);
    }
    this.defenseSquad().forEach((unit) => unit.commandAttack(focus.target.id));
  }

  private maybeAnnounceBaseDevelopment(basePlan: EnemyBaseDevelopmentPlan): void {
    if (basePlan.stage === "mid") {
      this.maybeAlert("base-stage-mid", basePlan.status, basePlan.ownedSiteCount > 0 || basePlan.baseThreatPower > 0);
    }
    if (basePlan.stage === "late") {
      this.maybeAlert("base-stage-late", basePlan.status, basePlan.ownedSiteCount > 0);
    }
  }

  private enemyArmy(): Unit[] {
    return this.options.getUnits().filter((unit) => unit.alive && unit.team === "enemy");
  }

  private defenseSquad(): Unit[] {
    const army = this.enemyArmy();
    return [
      ...army.filter((unit) => unit.enemyHeroId),
      ...army.filter((unit) => !unit.enemyHeroId)
    ].slice(0, this.config.defenseSquadSize);
  }
}
