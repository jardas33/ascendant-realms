import type {
  BattleMapDefinition,
  CampaignNodeDefinition,
  EnemyAIPersonalityId,
  Position,
  ResourceBag,
  StrongholdUpgradeId
} from "../core/GameTypes";
import { CAPTURE_TIME_SECONDS } from "../core/Constants";
import { addResources, canAfford, cloneResources, distance, formatTime, payCost } from "../core/MathUtils";
import {
  createCampaignBattleLaunchRequest,
  requireBattleLaunch,
  type BattleLaunchModifier
} from "../battle/BattleLaunchRequest";
import { createBattleRuntime } from "../battle/BattleRuntime";
import {
  applyRivalModifiersToEnemyHeroStats,
  createInitialRivalState,
  formatRivalStateSnapshot,
  getRivalBattleLaunchModifiers,
  updateRivalAfterBattle
} from "../core/RivalRules";
import {
  applyAIPersonalityToConfig,
  applyAIPersonalityToDifficulty,
  applyAIPersonalityToPhase,
  getAIPersonality
} from "../data/aiPersonalities";
import { FIRST_MATCH_TUTORIAL_PROTECTION, getBattleDifficulty, getBattlePhase } from "../data/battlePacing";
import { requireBuilding, requireCampaignNode, requireEnemyHero, requireUnit, requireUpgrade } from "../data/contentIndex";
import { getStrongholdBattleEffects, strongholdLaunchModifierId, STRONGHOLD_UPGRADE_BY_ID } from "../data/strongholdUpgrades";
import { createFallbackCampaignSave } from "../save/SaveDefaults";
import type { CampaignRivalSaveData, HeroSaveData, RetinueUnitSaveData } from "../save/SaveTypes";
import { analyzePlaytestTelemetry } from "./PlaytestAnalyzer";
import { DEFAULT_PLAYTEST_STRONGHOLD_PROFILES } from "./PlaytestProfiles";
import { DEFAULT_PLAYTEST_SCENARIOS } from "./PlaytestScenarios";
import { DEFAULT_PLAYTEST_SCRIPTS, runStrategy } from "./PlaytestStrategies";
import {
  cloneStrongholdBattleEffects,
  createPlaytestHeroForNode,
  firstAttackTime,
  formatResources,
  formatRetinueTelemetry,
  heroStrength,
  initialEnemyArmy,
  initialPlayerUnits,
  retinueStrengthBonusForUnit,
  unitStrength,
  unitStrengthFromStats
} from "./PlaytestTelemetry";
import type {
  PlaytestReport,
  PlaytestResult,
  PlaytestScenarioDefinition,
  PlaytestScriptId,
  PlaytestStrategyDriver,
  PlaytestStrongholdNodePlan,
  PlaytestStrongholdProfileDefinition,
  PlaytestTelemetry
} from "./PlaytestTypes";

interface PendingBuilding {
  id: string;
  completeAt: number;
  completed: boolean;
}

interface PendingEnemyContact {
  contactAt: number;
  unitIds: string[];
  firstWave: boolean;
}

interface CapturedSite {
  id: string;
  nextIncomeAt: number;
}

interface BattleDriverState {
  node: CampaignNodeDefinition;
  map: BattleMapDefinition;
  scriptId: PlaytestScriptId;
  difficulty: ReturnType<typeof applyAIPersonalityToDifficulty>;
  enemyConfig: ReturnType<typeof applyAIPersonalityToConfig>;
  personalityId: EnemyAIPersonalityId;
  personality: ReturnType<typeof getAIPersonality>;
  time: number;
  maxTime: number;
  resources: ResourceBag;
  peakResources: ResourceBag;
  capturedSites: CapturedSite[];
  heroPosition: Position;
  playerUnits: Record<string, number>;
  enemyArmy: string[];
  pendingBuildings: PendingBuilding[];
  completedBuildings: string[];
  researchedUpgrades: string[];
  pendingContacts: PendingEnemyContact[];
  nextEnemyTrainAt: number;
  nextEnemyWaveAt: number;
  nextUnitPlanIndex: number;
  enemyWavesLaunched: number;
  ended: boolean;
  result: PlaytestResult;
  commandLog: string[];
  notes: string[];
  strongholdPlan: PlaytestStrongholdNodePlan;
  heroMaxHpMultiplier: number;
  heroMaxManaMultiplier: number;
  retinueStrengthBonus: number;
  enemyWarningLeadSeconds: number;
  watchtowerRangeMultiplier: number;
  firstBuildingConstructionTimeMultiplier: number;
  unitTrainingTimeMultipliers: Partial<Record<string, number>>;
  firstConstructionBoostUsed: boolean;
  rivalStateBefore?: CampaignRivalSaveData;
  rivalModifiers: BattleLaunchModifier[];
  telemetry: Omit<
    PlaytestTelemetry,
    | "battleDurationSeconds"
    | "resourcesFloated"
    | "peakResourcesFloated"
    | "heroLevel"
    | "heroXpGained"
    | "finalArmySize"
    | "rewardResult"
    | "commandLog"
    | "structuralNotes"
  >;
}


export function runScriptedPlaytestSuite(options: {
  scenarios?: PlaytestScenarioDefinition[];
  scripts?: PlaytestScriptId[];
  strongholdProfiles?: PlaytestStrongholdProfileDefinition[];
} = {}): PlaytestReport {
  const scenarios = options.scenarios ?? DEFAULT_PLAYTEST_SCENARIOS;
  const scripts = options.scripts ?? DEFAULT_PLAYTEST_SCRIPTS;
  const strongholdProfiles = options.strongholdProfiles ?? DEFAULT_PLAYTEST_STRONGHOLD_PROFILES;
  const profilePlans = strongholdProfiles.flatMap((profile) => buildStrongholdProfileNodePlans(profile, scenarios));
  const telemetry = profilePlans.flatMap(({ scenario, strongholdPlan }) => {
    return scripts.map((scriptId) => runScriptedBattlePlaytest({ scenario, scriptId, strongholdPlan }));
  });
  return {
    schemaVersion: 2,
    generatedBy: "Ascendant Realms deterministic scripted playtest v2",
    telemetry,
    analysis: analyzePlaytestTelemetry(telemetry)
  };
}

export function runScriptedBattlePlaytest(options: {
  scenario: PlaytestScenarioDefinition;
  scriptId: PlaytestScriptId;
  strongholdPlan?: PlaytestStrongholdNodePlan;
}): PlaytestTelemetry {
  const node = requireCampaignNode(options.scenario.nodeId);
  const heroSave = createPlaytestHeroForNode(node.id);
  const strongholdPlan = options.strongholdPlan ?? noStrongholdPlan();
  const rivalStateBefore = node.enemyHeroId ? createInitialRivalState(node.enemyHeroId) : undefined;
  const rivalCampaign = {
    ...createFallbackCampaignSave(),
    rivals: rivalStateBefore ? [rivalStateBefore] : []
  };
  const rivalModifiers = getRivalBattleLaunchModifiers(rivalCampaign, node);
  const launch = requireBattleLaunch(
    createCampaignBattleLaunchRequest(heroSave, node, {
      difficulty: options.scenario.expectedDifficulty,
      aiPersonalityId: node.aiPersonalityId,
      modifiers: [
        ...strongholdPlan.purchasedUpgradeIds.map((upgradeId) => ({ id: strongholdLaunchModifierId(upgradeId) })),
        ...rivalModifiers
      ],
      retinueUnits: strongholdPlan.retinueUnits
    })
  );
  const driver = new ScriptedBattleDriver({
    node,
    heroSave,
    map: launch.map,
    scriptId: options.scriptId,
    strongholdPlan,
    rivalStateBefore,
    rivalModifiers
  });

  runStrategy(options.scriptId, driver);
  return driver.finish(heroSave);
}


function buildStrongholdProfileNodePlans(
  profile: PlaytestStrongholdProfileDefinition,
  scenarios: PlaytestScenarioDefinition[]
): Array<{ scenario: PlaytestScenarioDefinition; strongholdPlan: PlaytestStrongholdNodePlan }> {
  const campaignBank: ResourceBag = { crowns: 0, stone: 0, iron: 0, aether: 0 };
  const purchasedUpgradeIds: StrongholdUpgradeId[] = [];
  return scenarios.map((scenario) => {
    const purchaseNotes = purchaseAffordableStrongholdTargets(profile, campaignBank, purchasedUpgradeIds);
    const plan: PlaytestStrongholdNodePlan = {
      profileId: profile.id,
      profileName: profile.name,
      targetUpgradeIds: [...profile.targetUpgradeIds],
      purchasedUpgradeIds: [...purchasedUpgradeIds],
      purchaseNotes,
      retinueUnits: deployableRetinueForProfile(profile.retinueUnits ?? [], purchasedUpgradeIds)
    };
    const node = requireCampaignNode(scenario.nodeId);
    addResources(campaignBank, node.rewards.resources ?? {});
    return { scenario, strongholdPlan: plan };
  });
}

function purchaseAffordableStrongholdTargets(
  profile: PlaytestStrongholdProfileDefinition,
  campaignBank: ResourceBag,
  purchasedUpgradeIds: StrongholdUpgradeId[]
): string[] {
  const notes: string[] = [];
  profile.targetUpgradeIds.forEach((upgradeId) => {
    if (purchasedUpgradeIds.includes(upgradeId)) {
      return;
    }
    const upgrade = STRONGHOLD_UPGRADE_BY_ID[upgradeId];
    const hasPrerequisites = Object.entries(upgrade.prerequisites.upgradeRanks ?? {}).every(([requiredUpgradeId, rank]) => {
      return purchasedUpgradeIds.includes(requiredUpgradeId as StrongholdUpgradeId) && (rank ?? 1) <= 1;
    });
    if (!hasPrerequisites) {
      notes.push(`${upgrade.name} waiting on Stronghold prerequisite.`);
      return;
    }
    if (!canAfford(campaignBank, upgrade.cost)) {
      notes.push(`${upgrade.name} not yet affordable from simulated campaign bank (${formatResources(campaignBank)}).`);
      return;
    }
    payCost(campaignBank, upgrade.cost);
    purchasedUpgradeIds.push(upgradeId);
    notes.push(`Purchased ${upgrade.name}; remaining campaign bank ${formatResources(campaignBank)}.`);
  });
  return notes;
}

function noStrongholdPlan(): PlaytestStrongholdNodePlan {
  return {
    profileId: "no_stronghold",
    profileName: "No Stronghold upgrades",
    targetUpgradeIds: [],
    purchasedUpgradeIds: [],
    purchaseNotes: [],
    retinueUnits: []
  };
}


function deployableRetinueForProfile(
  retinueUnits: RetinueUnitSaveData[],
  purchasedUpgradeIds: StrongholdUpgradeId[]
): RetinueUnitSaveData[] {
  const capacity = 2 + (purchasedUpgradeIds.includes("training_yard_ii") ? 1 : 0);
  return retinueUnits.filter((unit) => unit.status === "active").slice(0, capacity);
}


class ScriptedBattleDriver implements PlaytestStrategyDriver {
  private readonly state: BattleDriverState;
  private readonly heroSave: HeroSaveData;

  constructor(options: {
    node: CampaignNodeDefinition;
    heroSave: HeroSaveData;
    map: BattleMapDefinition;
    scriptId: PlaytestScriptId;
    strongholdPlan: PlaytestStrongholdNodePlan;
    rivalStateBefore?: CampaignRivalSaveData;
    rivalModifiers: BattleLaunchModifier[];
  }) {
    const personalityId = options.node.aiPersonalityId ?? "balanced_warlord";
    const personality = getAIPersonality(personalityId);
    const difficulty = applyAIPersonalityToDifficulty(getBattleDifficulty(options.node.difficulty), personality);
    const enemyConfig = applyAIPersonalityToConfig(options.map.scenario.enemyAI, personality);
    const strongholdEffects = getStrongholdBattleEffects(
      options.strongholdPlan.purchasedUpgradeIds.map((upgradeId) => ({ id: strongholdLaunchModifierId(upgradeId) }))
    );
    const startingResources = cloneResources(options.map.scenario.startingResources.player);
    addResources(startingResources, strongholdEffects.startingResources);
    const startingUnits = initialPlayerUnits(options.map);
    strongholdEffects.extraPlayerUnitIds.forEach((unitId) => {
      startingUnits[unitId] = (startingUnits[unitId] ?? 0) + 1;
    });
    options.strongholdPlan.retinueUnits.forEach((unit) => {
      startingUnits[unit.unitTypeId] = (startingUnits[unit.unitTypeId] ?? 0) + 1;
    });
    const retinueStrengthBonus = options.strongholdPlan.retinueUnits.reduce(
      (total, unit) => total + retinueStrengthBonusForUnit(unit),
      0
    );
    this.heroSave = options.heroSave;
    this.state = {
      node: options.node,
      map: options.map,
      scriptId: options.scriptId,
      difficulty,
      enemyConfig,
      personalityId,
      personality,
      time: 0,
      maxTime: options.node.id === "ashen_outpost" ? 1050 : options.node.difficulty === "normal" ? 900 : 780,
      resources: cloneResources(startingResources),
      peakResources: cloneResources(startingResources),
      capturedSites: [],
      heroPosition: { ...options.map.scenario.heroSpawn },
      playerUnits: { ...startingUnits },
      enemyArmy: initialEnemyArmy(options.map, options.node.difficulty),
      pendingBuildings: [],
      completedBuildings: ["command_hall"],
      researchedUpgrades: [],
      pendingContacts: [],
      nextEnemyTrainAt: enemyConfig.trainInterval,
      nextEnemyWaveAt: firstAttackTime(options.node, enemyConfig.initialAttackDelay),
      nextUnitPlanIndex: 0,
      enemyWavesLaunched: 0,
      ended: false,
      result: "timeout",
      commandLog: [],
      notes: [],
      strongholdPlan: options.strongholdPlan,
      heroMaxHpMultiplier: strongholdEffects.heroMaxHpMultiplier,
      heroMaxManaMultiplier: strongholdEffects.heroMaxManaMultiplier,
      retinueStrengthBonus,
      enemyWarningLeadSeconds: strongholdEffects.enemyWarningLeadSeconds,
      watchtowerRangeMultiplier: strongholdEffects.watchtowerRangeMultiplier,
      firstBuildingConstructionTimeMultiplier: strongholdEffects.firstBuildingConstructionTimeMultiplier,
      unitTrainingTimeMultipliers: { ...strongholdEffects.unitTrainingTimeMultipliers },
      firstConstructionBoostUsed: false,
      rivalStateBefore: options.rivalStateBefore,
      rivalModifiers: [...options.rivalModifiers],
      telemetry: {
        strongholdProfileId: options.strongholdPlan.profileId,
        strongholdProfileName: options.strongholdPlan.profileName,
        strongholdTargetUpgradeIds: [...options.strongholdPlan.targetUpgradeIds],
        strongholdUpgradeIds: [...options.strongholdPlan.purchasedUpgradeIds],
        strongholdPurchaseNotes: [...options.strongholdPlan.purchaseNotes],
        strongholdEffects: cloneStrongholdBattleEffects(strongholdEffects),
        retinueUnits: options.strongholdPlan.retinueUnits.map(formatRetinueTelemetry),
        nodeId: options.node.id,
        nodeName: options.node.name,
        mapId: options.map.id,
        difficulty: options.node.difficulty,
        aiPersonality: personalityId,
        playerScript: options.scriptId,
        battleResult: "timeout",
        startingUnits: { ...startingUnits },
        startingResources: cloneResources(startingResources),
        timeFirstSiteCaptured: null,
        timeBarracksPlaced: null,
        timeBarracksCompleted: null,
        timeFirstUnitTrained: null,
        timeFirstEnemyWarning: null,
        timeFirstEnemyContact: null,
        firstWaveSurvived: false,
        unitsTrained: 0,
        unitsLost: 0,
        buildingsBuilt: [],
        upgradesResearched: [],
        enemyWavesSurvived: 0,
        enemyHeroId: options.node.enemyHeroId ?? null,
        enemyHeroDefeated: false,
        timeEnemyHeroJoinedAttack: null,
        lossesInvolvingEnemyHero: 0,
        rivalStateBefore: formatRivalStateSnapshot(options.rivalStateBefore),
        rivalOutcome: "none",
        rivalStateAfter: null,
        rivalModifiersApplied: options.rivalModifiers
          .map((modifier) => modifier.id)
          .filter((id): id is "rival_wary_hp_5" | "rival_emboldened_damage_5" =>
            id === "rival_wary_hp_5" || id === "rival_emboldened_damage_5"
          ),
        lossesAgainstRival: 0,
        rivalFirstDefeatRewardEarned: false,
        rivalDuplicateRewardPrevented: false,
        rivalTrophyEarned: null,
        objectiveCompletion: []
      }
    };
  }

  selectHero(): void {
    this.log("select hero");
  }

  selectCommandHall(): void {
    this.log("select Command Hall");
  }

  moveHeroAndUnitsToCapturePoint(siteId: string): void {
    if (this.state.ended || this.hasCaptured(siteId)) {
      return;
    }
    const site = this.state.map.captureSites.find((entry) => entry.id === siteId);
    if (!site) {
      this.note(`Missing capture point ${siteId}.`);
      return;
    }
    this.log(`move hero and army to ${site.name}`);
    const travelSeconds = distance(this.state.heroPosition, site) / 95;
    this.advanceBy(travelSeconds + CAPTURE_TIME_SECONDS);
    this.state.heroPosition = { x: site.x, y: site.y };
    this.state.capturedSites.push({ id: site.id, nextIncomeAt: this.state.time + site.incomeInterval });
    this.state.telemetry.timeFirstSiteCaptured ??= Math.round(this.state.time);
    this.log(`captured ${site.name}`);
  }

  moveHeroAndUnitsToPreferredCapturePoint(options: { preferredIds?: string[]; resources?: Array<keyof ResourceBag> }): void {
    const explicit = options.preferredIds
      ?.map((siteId) => this.state.map.captureSites.find((site) => site.id === siteId))
      .find((site) => site && !this.hasCaptured(site.id));
    if (explicit) {
      this.moveHeroAndUnitsToCapturePoint(explicit.id);
      return;
    }
    const resourceTarget = options.resources
      ?.flatMap((resource) => this.state.map.captureSites.filter((site) => site.resource === resource && !this.hasCaptured(site.id)))
      .sort((a, b) => distance(this.state.heroPosition, a) - distance(this.state.heroPosition, b))[0];
    if (resourceTarget) {
      this.moveHeroAndUnitsToCapturePoint(resourceTarget.id);
      return;
    }
    const nearest = this.state.map.captureSites
      .filter((site) => !this.hasCaptured(site.id))
      .sort((a, b) => distance(this.state.heroPosition, a) - distance(this.state.heroPosition, b))[0];
    if (nearest) {
      this.moveHeroAndUnitsToCapturePoint(nearest.id);
    }
  }

  buildBuilding(buildingId: string): boolean {
    if (this.state.ended || this.hasCompletedBuilding(buildingId) || this.hasPendingBuilding(buildingId)) {
      return false;
    }
    const building = requireBuilding(buildingId);
    if (!payCost(this.state.resources, building.cost)) {
      this.note(`Could not afford ${building.name} at ${formatTime(this.state.time)}.`);
      return false;
    }
    const constructionTimeSeconds = this.applyFirstBuildingConstructionMultiplier(building.constructionTimeSeconds);
    this.state.pendingBuildings.push({
      id: buildingId,
      completeAt: this.state.time + constructionTimeSeconds,
      completed: constructionTimeSeconds <= 0
    });
    this.state.telemetry.buildingsBuilt.push(buildingId);
    if (buildingId === "barracks") {
      this.state.telemetry.timeBarracksPlaced ??= Math.round(this.state.time);
    }
    this.log(`placed ${building.name}`);
    if (constructionTimeSeconds <= 0) {
      this.completeBuilding(buildingId);
    }
    return true;
  }

  private applyFirstBuildingConstructionMultiplier(constructionTimeSeconds: number): number {
    const multiplier = this.state.firstBuildingConstructionTimeMultiplier;
    if (this.state.firstConstructionBoostUsed || multiplier >= 1 || constructionTimeSeconds <= 0) {
      return constructionTimeSeconds;
    }
    this.state.firstConstructionBoostUsed = true;
    return Math.max(1, constructionTimeSeconds * multiplier);
  }

  waitForConstruction(buildingId: string): void {
    const pending = this.state.pendingBuildings.find((building) => building.id === buildingId && !building.completed);
    if (!pending || this.state.ended) {
      return;
    }
    this.log(`wait for ${requireBuilding(buildingId).name} construction`);
    this.advanceTo(pending.completeAt);
  }

  trainUnit(unitId: string): boolean {
    if (this.state.ended) {
      return false;
    }
    const unit = requireUnit(unitId);
    const productionId = unitId === "acolyte" ? "mystic_lodge" : "barracks";
    if (!this.hasCompletedBuilding(productionId)) {
      this.note(`Cannot train ${unit.name}; ${requireBuilding(productionId).name} is not complete.`);
      return false;
    }
    if (!payCost(this.state.resources, unit.cost)) {
      this.note(`Could not afford ${unit.name} at ${formatTime(this.state.time)}.`);
      return false;
    }
    this.log(`queue ${unit.name}`);
    this.advanceBy(this.unitTrainingTime(unitId, unit.trainTime));
    this.state.playerUnits[unitId] = (this.state.playerUnits[unitId] ?? 0) + 1;
    this.state.telemetry.unitsTrained += 1;
    this.state.telemetry.timeFirstUnitTrained ??= Math.round(this.state.time);
    this.log(`trained ${unit.name}`);
    return true;
  }

  setRallyPoint(point: Position): void {
    if (this.state.ended) {
      return;
    }
    this.log(`set rally point at ${Math.round(point.x)},${Math.round(point.y)}`);
  }

  buildIfAffordable(buildingId: string): boolean {
    return canAfford(this.state.resources, requireBuilding(buildingId).cost) && this.buildBuilding(buildingId);
  }

  trainIfAffordable(unitId: string): boolean {
    return canAfford(this.state.resources, requireUnit(unitId).cost) && this.trainUnit(unitId);
  }

  researchIfAffordable(upgradeId: string): boolean {
    if (this.state.ended || this.state.researchedUpgrades.includes(upgradeId)) {
      return false;
    }
    const upgrade = requireUpgrade(upgradeId);
    if (!this.prerequisitesMet(upgrade.prerequisites?.buildingIds ?? []) || !payCost(this.state.resources, upgrade.cost)) {
      return false;
    }
    this.log(`research ${upgrade.name}`);
    this.advanceBy(upgrade.researchTimeSeconds);
    this.state.researchedUpgrades.push(upgradeId);
    this.state.telemetry.upgradesResearched.push(upgradeId);
    this.log(`completed ${upgrade.name}`);
    return true;
  }

  waitUntil(seconds: number): void {
    this.advanceTo(seconds);
  }

  waitUntilArmySize(size: number, latestTime: number): void {
    while (!this.state.ended && this.armySize() < size && this.state.time < latestTime) {
      if (!this.trainBestAvailableUnit()) {
          this.advanceBy(8);
      }
    }
  }

  attackEnemyBase(label: string): void {
    if (this.state.ended) {
      return;
    }
    this.log(`attack enemy base (${label})`);
    const travelSeconds = distance(this.state.heroPosition, this.state.map.enemyStart) / 82;
    this.advanceBy(travelSeconds);
    const attackStrength = this.playerAttackStrength();
    const defenseStrength = this.enemyBaseDefenseStrength();
    if (attackStrength >= defenseStrength) {
      this.state.result = "victory";
      this.state.ended = true;
      this.state.telemetry.battleResult = "victory";
      this.state.telemetry.objectiveCompletion.push("destroy_enemy_stronghold");
      this.defeatEnemyHeroIfPresent();
      this.completeSecondaryObjectivesForVictory();
      this.log("destroyed enemy Stronghold");
      return;
    }

    const lossCount = Math.min(this.nonHeroArmySize(), Math.max(1, Math.ceil((defenseStrength - attackStrength) / 18)));
    this.loseUnits(lossCount);
    this.note(
      `Attack failed at ${formatTime(this.state.time)}: strength ${Math.round(attackStrength)} into ${Math.round(defenseStrength)}.`
    );
    if (this.nonHeroArmySize() <= 1) {
      this.state.result = "defeat";
      this.state.ended = true;
      this.state.telemetry.battleResult = "defeat";
    }
  }

  finish(heroSave: HeroSaveData): PlaytestTelemetry {
    if (!this.state.ended) {
      this.advanceTo(this.state.maxTime);
    }
    if (!this.state.ended) {
      this.state.result = "timeout";
      this.state.telemetry.battleResult = "timeout";
    }
    const launch = requireBattleLaunch(
      createCampaignBattleLaunchRequest(heroSave, this.state.node, {
        modifiers: this.state.strongholdPlan.purchasedUpgradeIds.map((upgradeId) => ({
          id: strongholdLaunchModifierId(upgradeId)
        })).concat(this.state.rivalModifiers),
        retinueUnits: this.state.strongholdPlan.retinueUnits
      })
    );
    const runtime = createBattleRuntime({ launch });
    runtime.tick(this.state.time);
    this.state.telemetry.buildingsBuilt.forEach((buildingId) => runtime.recordBuildingBuilt(buildingId));
    for (let index = 0; index < this.state.telemetry.unitsTrained; index += 1) {
      runtime.recordUnitTrained("simulated_unit");
    }
    for (let index = 0; index < this.state.telemetry.enemyWavesSurvived; index += 1) {
      runtime.recordEnemyWaveSurvived();
    }
    if (this.state.telemetry.enemyHeroId) {
      const enemyHero = requireEnemyHero(this.state.telemetry.enemyHeroId);
      runtime.recordEnemyHeroPresence(enemyHero.id, enemyHero.name);
      if (this.state.telemetry.timeEnemyHeroJoinedAttack !== null) {
        runtime.recordEnemyHeroJoinedAttack(enemyHero.id, this.state.telemetry.timeEnemyHeroJoinedAttack);
      }
      for (let index = 0; index < this.state.telemetry.lossesInvolvingEnemyHero; index += 1) {
        runtime.recordEnemyHeroPressure(enemyHero.id, enemyHero.name);
      }
      if (this.state.telemetry.enemyHeroDefeated) {
        runtime.recordEnemyHeroDefeated(enemyHero.id, enemyHero.name, this.state.time);
      }
    }
    this.state.telemetry.objectiveCompletion.forEach((objectiveId) => runtime.recordSecondaryObjective(objectiveId));
    if (this.state.telemetry.timeFirstSiteCaptured !== null) {
      runtime.recordResourceCaptured(this.state.capturedSites[0]?.id);
    }
    const completion = runtime.completeBattle({
      outcome: this.state.result === "victory" ? "victory" : "defeat",
      heroSave,
      deterministicRewards: true
    });
    const rewardResult =
      this.state.result === "victory" && completion
        ? {
            battleItemIds: [...completion.rewardItemIds],
            battleResources: { ...completion.reward.resources },
            battleXp: completion.reward.xp,
            campaignItemIds: [...(this.state.node.rewards.itemIds ?? [])],
            campaignResources: { ...(this.state.node.rewards.resources ?? {}) },
            campaignXp: this.state.node.rewards.xp ?? 0
          }
        : null;
    const heroXpGained = rewardResult ? rewardResult.battleXp + rewardResult.campaignXp : 0;
    const heroLevel = completion?.heroSave.level ?? heroSave.level;
    const rivalTelemetry = this.createRivalTelemetry(heroSave);
    return {
      ...this.state.telemetry,
      battleResult: this.state.result,
      battleDurationSeconds: Math.round(this.state.time),
      resourcesFloated: cloneResources(this.state.resources),
      peakResourcesFloated: cloneResources(this.state.peakResources),
      heroLevel,
      heroXpGained,
      finalArmySize: this.armySize(),
      rivalOutcome: rivalTelemetry.rivalOutcome,
      rivalStateAfter: rivalTelemetry.rivalStateAfter,
      lossesAgainstRival: this.state.telemetry.lossesInvolvingEnemyHero,
      rivalFirstDefeatRewardEarned: rivalTelemetry.rivalFirstDefeatRewardEarned,
      rivalDuplicateRewardPrevented: rivalTelemetry.rivalDuplicateRewardPrevented,
      rivalTrophyEarned: rivalTelemetry.rivalTrophyEarned,
      rewardResult,
      commandLog: [...this.state.commandLog],
      structuralNotes: [...this.state.notes]
    };
  }

  private advanceBy(seconds: number): void {
    this.advanceTo(this.state.time + Math.max(0, seconds));
  }

  private advanceTo(targetTime: number): void {
    const cappedTarget = Math.min(targetTime, this.state.maxTime);
    while (!this.state.ended && this.state.time < cappedTarget) {
      const step = Math.min(1, cappedTarget - this.state.time);
      this.state.time += step;
      this.collectSiteIncome();
      this.updatePeakResources();
      this.completeReadyBuildings();
      this.updateEnemyTraining();
      this.updateEnemyWarning();
      this.updateEnemyWaves();
      this.resolveEnemyContacts();
    }
  }

  private collectSiteIncome(): void {
    this.state.capturedSites.forEach((captured) => {
      const definition = this.state.map.captureSites.find((site) => site.id === captured.id);
      if (!definition) {
        return;
      }
      while (this.state.time >= captured.nextIncomeAt) {
        addResources(this.state.resources, { [definition.resource]: definition.incomeAmount } as Partial<ResourceBag>);
        captured.nextIncomeAt += definition.incomeInterval;
      }
    });
  }

  private completeReadyBuildings(): void {
    this.state.pendingBuildings.forEach((building) => {
      if (!building.completed && this.state.time >= building.completeAt) {
        building.completed = true;
        this.completeBuilding(building.id);
      }
    });
  }

  private completeBuilding(buildingId: string): void {
    if (!this.state.completedBuildings.includes(buildingId)) {
      this.state.completedBuildings.push(buildingId);
      if (buildingId === "barracks") {
        this.state.telemetry.timeBarracksCompleted ??= Math.round(this.state.time);
      }
      this.log(`${requireBuilding(buildingId).name} completed`);
    }
  }

  private updateEnemyTraining(): void {
    while (this.state.time >= this.state.nextEnemyTrainAt) {
      const unitId = this.nextEnemyUnitId();
      if (unitId) {
        this.state.enemyArmy.push(unitId);
      }
      this.state.nextEnemyTrainAt += this.state.enemyConfig.trainInterval;
    }
  }

  private updateEnemyWarning(): void {
    const warningAt = Math.max(20, this.state.enemyConfig.initialAttackDelay - 35 - this.state.enemyWarningLeadSeconds);
    if (this.state.telemetry.timeFirstEnemyWarning === null && this.state.time >= warningAt) {
      this.state.telemetry.timeFirstEnemyWarning = Math.round(this.state.time);
      this.log("enemy forces warning");
    }
  }

  private updateEnemyWaves(): void {
    while (!this.state.ended && this.state.time >= this.state.nextEnemyWaveAt) {
      const wave = this.selectEnemyWave();
      if (wave.length === 0) {
        this.state.nextEnemyWaveAt += 5;
        return;
      }
      this.state.enemyWavesLaunched += 1;
      const contactAt = this.state.time + distance(this.state.map.enemyStart, this.state.map.playerStart) / 82;
      this.state.pendingContacts.push({
        contactAt,
        unitIds: wave,
        firstWave: this.state.enemyWavesLaunched === 1
      });
      if (wave.includes("enemy_commander") && this.state.node.enemyHeroId) {
        this.state.telemetry.timeEnemyHeroJoinedAttack ??= Math.round(this.state.time);
      }
      this.log(`enemy wave ${this.state.enemyWavesLaunched} launched (${wave.join(", ")})`);
      this.state.nextEnemyWaveAt += this.state.enemyConfig.attackInterval;
    }
  }

  private resolveEnemyContacts(): void {
    const ready = this.state.pendingContacts.filter((contact) => this.state.time >= contact.contactAt);
    this.state.pendingContacts = this.state.pendingContacts.filter((contact) => this.state.time < contact.contactAt);
    ready.forEach((contact) => this.resolveEnemyContact(contact));
  }

  private resolveEnemyContact(contact: PendingEnemyContact): void {
    this.state.telemetry.timeFirstEnemyContact ??= Math.round(this.state.time);
    const waveStrength = contact.unitIds.reduce((total, unitId) => total + this.enemyUnitStrength(unitId), 0);
    const defenseStrength = this.playerDefenseStrength();
    const ratio = waveStrength / Math.max(1, defenseStrength);
    const lossesBefore = this.state.telemetry.unitsLost;
    const enemyHeroInvolved = contact.unitIds.includes("enemy_commander") && Boolean(this.state.node.enemyHeroId);
    if (ratio > 1.42) {
      this.loseUnits(this.nonHeroArmySize());
      this.recordEnemyHeroLosses(enemyHeroInvolved, lossesBefore);
      this.state.result = "defeat";
      this.state.ended = true;
      this.state.telemetry.battleResult = "defeat";
      this.note(`Base collapsed to wave ${this.state.enemyWavesLaunched} at ${formatTime(this.state.time)}.`);
      if (contact.firstWave) {
        this.state.telemetry.firstWaveSurvived = false;
      }
      return;
    }
    const losses = Math.min(this.nonHeroArmySize(), Math.max(0, Math.floor(ratio * 2.4)));
    this.loseUnits(losses);
    this.recordEnemyHeroLosses(enemyHeroInvolved, lossesBefore);
    if (enemyHeroInvolved) {
      this.state.telemetry.enemyHeroDefeated = true;
    }
    this.state.telemetry.enemyWavesSurvived += 1;
    if (contact.firstWave) {
      this.state.telemetry.firstWaveSurvived = true;
    }
    this.log(`survived enemy wave ${this.state.enemyWavesLaunched}`);
  }

  private selectEnemyWave(): string[] {
    const phase = applyAIPersonalityToPhase(getBattlePhase(this.state.time), this.state.personality);
    if (!phase.enemy.baseAttackAllowed) {
      return [];
    }
    if (this.state.node.id === "border_village" && this.state.enemyWavesLaunched === 0) {
      if (this.state.time < FIRST_MATCH_TUTORIAL_PROTECTION.firstAttackAllowedAfterSeconds) {
        return [];
      }
      if (this.state.capturedSites.length === 0 && this.state.time < FIRST_MATCH_TUTORIAL_PROTECTION.firstAttackForceAfterSeconds) {
        return [];
      }
    }
    let maxWave = Math.min(this.state.enemyConfig.attackWaveSize, phase.enemy.maxAttackWaveSize);
    if (
      this.state.node.id === "border_village" &&
      this.state.enemyWavesLaunched === 0 &&
      !this.hasCompletedBuilding("barracks") &&
      this.state.time < FIRST_MATCH_TUTORIAL_PROTECTION.largeAttackAllowedAfterSeconds
    ) {
      maxWave = Math.min(maxWave, FIRST_MATCH_TUTORIAL_PROTECTION.earlyAttackMaxWaveSize);
    }
    const candidates = this.state.enemyArmy.filter((unitId) => this.canEnemyUnitJoinAttack(unitId, phase));
    if (candidates.length < Math.min(this.state.enemyConfig.minAttackArmySize, maxWave)) {
      return [];
    }
    const selected: string[] = [];
    const counts: Record<string, number> = {};
    phase.enemy.preferredAttackUnitIds.forEach((preferredId) => {
      if (selected.length >= maxWave) {
        return;
      }
      const index = candidates.findIndex((unitId) => {
        const cap = phase.enemy.maxAttackByUnitId?.[unitId] ?? Number.POSITIVE_INFINITY;
        return unitId === preferredId && (counts[unitId] ?? 0) < cap;
      });
      if (index >= 0) {
        selected.push(candidates[index]);
        counts[preferredId] = (counts[preferredId] ?? 0) + 1;
        candidates.splice(index, 1);
      }
    });
    while (selected.length < maxWave && candidates.length > 0) {
      selected.push(candidates.shift() as string);
    }
    selected.forEach((unitId) => {
      const index = this.state.enemyArmy.indexOf(unitId);
      if (index >= 0) {
        this.state.enemyArmy.splice(index, 1);
      }
    });
    return selected;
  }

  private nextEnemyUnitId(): string | undefined {
    const plan = this.state.enemyConfig.unitPlan;
    if (plan.length === 0) {
      return undefined;
    }
    const unitId = plan[this.state.nextUnitPlanIndex % plan.length];
    this.state.nextUnitPlanIndex += 1;
    return unitId;
  }

  private canEnemyUnitJoinAttack(unitId: string, phase: ReturnType<typeof getBattlePhase>): boolean {
    if (!phase.enemy.allowedAttackUnitIds.includes(unitId)) {
      return false;
    }
    if (unitId !== "enemy_commander") {
      return true;
    }
    const canJoinFirstAttack = this.state.personality.commander.joinsFirstAttack || this.state.enemyWavesLaunched > 0;
    return canJoinFirstAttack && phase.enemy.commanderAllowed && this.state.time >= this.state.difficulty.commanderJoinDelay;
  }

  private enemyUnitStrength(unitId: string): number {
    if (unitId === "enemy_commander" && this.state.node.enemyHeroId) {
      return unitStrengthFromStats(
        applyRivalModifiersToEnemyHeroStats(requireEnemyHero(this.state.node.enemyHeroId).stats, this.state.rivalModifiers)
      );
    }
    return unitStrength(requireUnit(unitId));
  }

  private createRivalTelemetry(heroSave: HeroSaveData): Pick<
    PlaytestTelemetry,
    "rivalOutcome" | "rivalStateAfter" | "rivalFirstDefeatRewardEarned" | "rivalDuplicateRewardPrevented" | "rivalTrophyEarned"
  > {
    if (!this.state.node.enemyHeroId || !this.state.rivalStateBefore) {
      return {
        rivalOutcome: "none",
        rivalStateAfter: null,
        rivalFirstDefeatRewardEarned: false,
        rivalDuplicateRewardPrevented: false,
        rivalTrophyEarned: null
      };
    }
    const update = updateRivalAfterBattle({
      campaign: {
        ...createFallbackCampaignSave(),
        rivals: [this.state.rivalStateBefore]
      },
      hero: heroSave,
      nodeId: this.state.node.id,
      enemyHeroId: this.state.node.enemyHeroId,
      playerWon: this.state.result === "victory",
      enemyHeroDefeated: this.state.telemetry.enemyHeroDefeated
    });
    return {
      rivalOutcome: update.rivalResult?.lastOutcome ?? "none",
      rivalStateAfter: formatRivalStateSnapshot(update.campaign.rivals.find((rival) => rival.enemyHeroId === this.state.node.enemyHeroId)),
      rivalFirstDefeatRewardEarned: Boolean(update.rivalResult?.firstDefeatRewardEarned),
      rivalDuplicateRewardPrevented: Boolean(update.rivalResult?.duplicateFirstDefeatRewardPrevented),
      rivalTrophyEarned: update.rivalResult?.trophyEarned?.trophyId ?? null
    };
  }

  private recordEnemyHeroLosses(enemyHeroInvolved: boolean, lossesBefore: number): void {
    if (!enemyHeroInvolved) {
      return;
    }
    const losses = Math.max(0, this.state.telemetry.unitsLost - lossesBefore);
    this.state.telemetry.lossesInvolvingEnemyHero += losses;
  }

  private defeatEnemyHeroIfPresent(): void {
    if (!this.state.node.enemyHeroId || !this.state.enemyArmy.includes("enemy_commander")) {
      return;
    }
    this.state.telemetry.enemyHeroDefeated = true;
    const index = this.state.enemyArmy.indexOf("enemy_commander");
    if (index >= 0) {
      this.state.enemyArmy.splice(index, 1);
    }
  }

  private completeSecondaryObjectivesForVictory(): void {
    this.state.map.scenario.objectives.secondaryObjectives?.forEach((objective) => {
      if (objective.type === "capture_site" && !this.hasCaptured(objective.targetId)) {
        return;
      }
      this.state.telemetry.objectiveCompletion.push(objective.id);
    });
  }

  private playerDefenseStrength(): number {
    return this.playerAttackStrength() * 0.92 + this.countBuilding("watchtower") * 18 * this.state.watchtowerRangeMultiplier + 8;
  }

  private playerAttackStrength(): number {
    const upgrades = this.state.researchedUpgrades.length;
    const unitScore = Object.entries(this.state.playerUnits).reduce((total, [unitId, count]) => {
      return total + unitStrength(requireUnit(unitId)) * count;
    }, 0);
    return (unitScore + this.state.retinueStrengthBonus + heroStrength(this.heroSave) * this.state.heroMaxHpMultiplier) * (1 + upgrades * 0.045);
  }

  private enemyBaseDefenseStrength(): number {
    const towerCount = this.state.map.scenario.buildingSpawns.filter(
      (spawn) => spawn.team === "enemy" && spawn.buildingId === "watchtower"
    ).length;
    const reserveLimit = Math.max(3, this.state.enemyConfig.defenseSquadSize);
    const reserve = this.state.enemyArmy
      .slice(0, reserveLimit)
      .reduce((total, unitId) => total + this.enemyUnitStrength(unitId) * 0.32, 0);
    const fortressBonus = this.fortressApproachBonus();
    return 78 + towerCount * 34 + reserve + fortressBonus;
  }

  private fortressApproachBonus(): number {
    if (this.state.map.id === "ashen_outpost") {
      return this.hasCaptured("burned_shrine") ? 56 : 74;
    }
    return this.state.map.id === "broken_ford" ? 74 : 52;
  }

  private armySize(): number {
    return this.nonHeroArmySize() + 1;
  }

  private nonHeroArmySize(): number {
    return Object.values(this.state.playerUnits).reduce((total, count) => total + count, 0);
  }

  private loseUnits(count: number): void {
    let remaining = count;
    const lossOrder = ["militia", "ranger", "acolyte"];
    lossOrder.forEach((unitId) => {
      while (remaining > 0 && (this.state.playerUnits[unitId] ?? 0) > 0) {
        this.state.playerUnits[unitId] -= 1;
        remaining -= 1;
        this.state.telemetry.unitsLost += 1;
      }
    });
  }

  private trainBestAvailableUnit(): boolean {
    const militiaCount = this.state.playerUnits.militia ?? 0;
    const rangerCount = this.state.playerUnits.ranger ?? 0;
    const acolyteCount = this.state.playerUnits.acolyte ?? 0;
    const preferred =
      this.hasCompletedBuilding("mystic_lodge") && acolyteCount < 3
        ? ["acolyte", "ranger", "militia"]
        : rangerCount < Math.max(2, Math.floor(militiaCount / 2))
          ? ["ranger", "militia", "acolyte"]
          : ["militia", "ranger", "acolyte"];
    return preferred.some((unitId) => this.trainIfAffordable(unitId));
  }

  private unitTrainingTime(unitId: string, baseTime: number): number {
    const multiplier = this.state.unitTrainingTimeMultipliers[unitId] ?? 1;
    return Math.max(1, baseTime * multiplier);
  }

  private hasCaptured(siteId: string): boolean {
    return this.state.capturedSites.some((site) => site.id === siteId);
  }

  private hasPendingBuilding(buildingId: string): boolean {
    return this.state.pendingBuildings.some((building) => building.id === buildingId && !building.completed);
  }

  private hasCompletedBuilding(buildingId: string): boolean {
    return this.state.completedBuildings.includes(buildingId);
  }

  private countBuilding(buildingId: string): number {
    return this.state.completedBuildings.filter((id) => id === buildingId).length;
  }

  private prerequisitesMet(buildingIds: string[]): boolean {
    return buildingIds.every((buildingId) => this.hasCompletedBuilding(buildingId));
  }

  private updatePeakResources(): void {
    this.state.peakResources.crowns = Math.max(this.state.peakResources.crowns, this.state.resources.crowns);
    this.state.peakResources.stone = Math.max(this.state.peakResources.stone, this.state.resources.stone);
    this.state.peakResources.iron = Math.max(this.state.peakResources.iron, this.state.resources.iron);
    this.state.peakResources.aether = Math.max(this.state.peakResources.aether, this.state.resources.aether);
  }

  private log(message: string): void {
    this.state.commandLog.push(`${formatTime(this.state.time)} ${message}`);
  }

  private note(message: string): void {
    this.state.notes.push(message);
  }
}
