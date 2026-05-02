import type {
  BattleDifficulty,
  BattleMapDefinition,
  CampaignNodeDefinition,
  EnemyAIPersonalityId,
  Position,
  ResourceBag,
  StrongholdUpgradeId,
  CombatStats,
  UnitDefinition
} from "../core/GameTypes";
import { CAPTURE_TIME_SECONDS } from "../core/Constants";
import { addResources, canAfford, cloneResources, distance, formatTime, payCost } from "../core/MathUtils";
import { createFallbackHeroSave } from "../save/SaveDefaults";
import { createCampaignBattleLaunchRequest, requireBattleLaunch } from "../battle/BattleLaunchRequest";
import { createBattleRuntime } from "../battle/BattleRuntime";
import {
  applyAIPersonalityToConfig,
  applyAIPersonalityToDifficulty,
  applyAIPersonalityToPhase,
  getAIPersonality
} from "../data/aiPersonalities";
import {
  FIRST_MATCH_TUTORIAL_PROTECTION,
  getBattleDifficulty,
  getBattlePhase
} from "../data/battlePacing";
import {
  requireBuilding,
  requireCampaignNode,
  requireEnemyHero,
  requireHeroClass,
  requireOrigin,
  requireUnit,
  requireUpgrade
} from "../data/contentIndex";
import {
  STRONGHOLD_UPGRADE_BY_ID,
  getStrongholdBattleEffects,
  strongholdLaunchModifierId,
  type StrongholdBattleEffects
} from "../data/strongholdUpgrades";
import { applyUnitVeterancyStatBonuses, getUnitVeterancyRank } from "../data/unitVeterancy";
import type { HeroSaveData, RetinueUnitSaveData } from "../save/SaveTypes";

export type PlaytestScriptId = "safe_beginner" | "greedy_economy" | "fast_army";
export type PlaytestResult = "victory" | "defeat" | "timeout";
export type PlaytestFindingSeverity = "info" | "watch" | "risk";
export type PlaytestStrongholdProfileId =
  | "no_stronghold"
  | "training_yard_path"
  | "defensive_watch_post_path"
  | "economy_quartermaster_path"
  | "tier_two_quartermaster_path"
  | "chapel_corner_path"
  | "ranger_paths_path"
  | "retinue_veteran_militia"
  | "retinue_veteran_ranger"
  | "retinue_mixed_veterans"
  | "retinue_training_yard_path"
  | "retinue_quartermaster_path";

export interface PlaytestScenarioDefinition {
  nodeId: string;
  expectedDifficulty: BattleDifficulty;
}

export interface PlaytestStrongholdProfileDefinition {
  id: PlaytestStrongholdProfileId;
  name: string;
  description: string;
  targetUpgradeIds: StrongholdUpgradeId[];
  retinueUnits?: RetinueUnitSaveData[];
}

interface PlaytestStrongholdNodePlan {
  profileId: PlaytestStrongholdProfileId;
  profileName: string;
  targetUpgradeIds: StrongholdUpgradeId[];
  purchasedUpgradeIds: StrongholdUpgradeId[];
  purchaseNotes: string[];
  retinueUnits: RetinueUnitSaveData[];
}

export interface PlaytestRewardTelemetry {
  battleItemIds: string[];
  battleResources: Partial<ResourceBag>;
  battleXp: number;
  campaignItemIds: string[];
  campaignResources: Partial<ResourceBag>;
  campaignXp: number;
}

export interface PlaytestTelemetry {
  strongholdProfileId: PlaytestStrongholdProfileId;
  strongholdProfileName: string;
  strongholdTargetUpgradeIds: StrongholdUpgradeId[];
  strongholdUpgradeIds: StrongholdUpgradeId[];
  strongholdPurchaseNotes: string[];
  strongholdEffects: StrongholdBattleEffects;
  retinueUnits: string[];
  nodeId: string;
  nodeName: string;
  mapId: string;
  difficulty: BattleDifficulty;
  aiPersonality: EnemyAIPersonalityId;
  playerScript: PlaytestScriptId;
  battleResult: PlaytestResult;
  battleDurationSeconds: number;
  startingUnits: Record<string, number>;
  startingResources: ResourceBag;
  timeFirstSiteCaptured: number | null;
  timeBarracksPlaced: number | null;
  timeBarracksCompleted: number | null;
  timeFirstUnitTrained: number | null;
  timeFirstEnemyWarning: number | null;
  timeFirstEnemyContact: number | null;
  firstWaveSurvived: boolean;
  unitsTrained: number;
  unitsLost: number;
  buildingsBuilt: string[];
  upgradesResearched: string[];
  resourcesFloated: ResourceBag;
  peakResourcesFloated: ResourceBag;
  heroLevel: number;
  heroXpGained: number;
  finalArmySize: number;
  enemyWavesSurvived: number;
  enemyHeroId: string | null;
  enemyHeroDefeated: boolean;
  timeEnemyHeroJoinedAttack: number | null;
  lossesInvolvingEnemyHero: number;
  objectiveCompletion: string[];
  rewardResult: PlaytestRewardTelemetry | null;
  commandLog: string[];
  structuralNotes: string[];
}

export interface PlaytestNodeSummary {
  strongholdProfileId: PlaytestStrongholdProfileId;
  strongholdProfileName: string;
  nodeId: string;
  nodeName: string;
  mapId: string;
  difficulty: BattleDifficulty;
  aiPersonality: EnemyAIPersonalityId;
  victories: number;
  defeats: number;
  timeouts: number;
  averageDurationSeconds: number;
  barracksBeforePressureRuns: number;
  firstWaveSurvivedRuns: number;
  verdict: "too_easy" | "reasonable" | "too_hard" | "needs_human_review";
  notes: string[];
}

export interface PlaytestStrongholdProfileSummary {
  profileId: PlaytestStrongholdProfileId;
  profileName: string;
  targetUpgradeIds: StrongholdUpgradeId[];
  purchasedUpgradeIds: StrongholdUpgradeId[];
  victories: number;
  defeats: number;
  timeouts: number;
  improvedRuns: number;
  firstPurchaseNodeId: string | null;
  warnings: string[];
}

export interface PlaytestAnalysis {
  tooEasyNodes: string[];
  tooHardNodes: string[];
  fairFirstAttackNodes: string[];
  unfairFirstAttackNodes: string[];
  barracksCompletesBeforePressure: string[];
  barracksLateBeforePressure: string[];
  usefulRewardNodes: string[];
  weakRewardNodes: string[];
  ashenOutpostBeatable: boolean;
  strongholdWarnings: string[];
  suggestedTuningChanges: string[];
  strongholdProfileSummaries: PlaytestStrongholdProfileSummary[];
  nodeSummaries: PlaytestNodeSummary[];
}

export interface PlaytestReport {
  schemaVersion: 2;
  generatedBy: string;
  telemetry: PlaytestTelemetry[];
  analysis: PlaytestAnalysis;
}

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

const BATTLE_NODE_IDS = [
  "border_village",
  "old_stone_road",
  "aether_well_ruins",
  "bandit_hillfort",
  "ashen_outpost"
] as const;

export const DEFAULT_PLAYTEST_SCENARIOS: PlaytestScenarioDefinition[] = BATTLE_NODE_IDS.map((nodeId) => {
  const node = requireCampaignNode(nodeId);
  return { nodeId, expectedDifficulty: node.difficulty };
});

export const DEFAULT_PLAYTEST_SCRIPTS: PlaytestScriptId[] = ["safe_beginner", "greedy_economy", "fast_army"];

export const DEFAULT_PLAYTEST_STRONGHOLD_PROFILES: PlaytestStrongholdProfileDefinition[] = [
  {
    id: "no_stronghold",
    name: "No Stronghold upgrades",
    description: "Baseline campaign battles with no persistent Stronghold purchases.",
    targetUpgradeIds: []
  },
  {
    id: "training_yard_path",
    name: "Training Yard path",
    description: "Buys Training Yard I as soon as normal campaign rewards can fund it.",
    targetUpgradeIds: ["training_yard_i"]
  },
  {
    id: "defensive_watch_post_path",
    name: "Defensive Watch Post path",
    description: "Buys Watch Post I as soon as normal campaign rewards can fund it.",
    targetUpgradeIds: ["watch_post_i"]
  },
  {
    id: "economy_quartermaster_path",
    name: "Economy Quartermaster path",
    description: "Buys Quartermaster Stores I as soon as normal campaign rewards can fund it.",
    targetUpgradeIds: ["quartermaster_stores_i"]
  },
  {
    id: "tier_two_quartermaster_path",
    name: "Tier II Quartermaster path",
    description: "Buys Quartermaster Stores I and II as soon as normal campaign rewards can fund them.",
    targetUpgradeIds: ["quartermaster_stores_i", "quartermaster_stores_ii"]
  },
  {
    id: "chapel_corner_path",
    name: "Chapel Corner path",
    description: "Buys Chapel Corner I as soon as normal campaign rewards can fund it.",
    targetUpgradeIds: ["chapel_corner_i"]
  },
  {
    id: "ranger_paths_path",
    name: "Ranger Paths path",
    description: "Buys Training Yard I and Ranger Paths I when normal campaign rewards can fund them.",
    targetUpgradeIds: ["training_yard_i", "ranger_paths_i"]
  },
  {
    id: "retinue_veteran_militia",
    name: "Retinue: Veteran Militia",
    description: "Baseline campaign battles with one saved Veteran Militia deployed from the retinue.",
    targetUpgradeIds: [],
    retinueUnits: [
      createSimRetinueUnit("sim-retinue-veteran-militia", "militia", "veteran", 140, 3)
    ]
  },
  {
    id: "retinue_veteran_ranger",
    name: "Retinue: Veteran Ranger",
    description: "Baseline campaign battles with one saved Veteran Ranger deployed from the retinue.",
    targetUpgradeIds: [],
    retinueUnits: [
      createSimRetinueUnit("sim-retinue-veteran-ranger", "ranger", "veteran", 140, 3)
    ]
  },
  {
    id: "retinue_mixed_veterans",
    name: "Retinue: Mixed Veterans",
    description: "Baseline campaign battles with one Veteran Militia and one Seasoned Ranger deployed from the retinue.",
    targetUpgradeIds: [],
    retinueUnits: [
      createSimRetinueUnit("sim-retinue-mixed-militia", "militia", "veteran", 140, 3),
      createSimRetinueUnit("sim-retinue-mixed-ranger", "ranger", "seasoned", 65, 1)
    ]
  },
  {
    id: "retinue_training_yard_path",
    name: "Retinue + Training Yard II",
    description: "Mixed retinue pressure combined with Training Yard I and II, including the third capacity slot once affordable.",
    targetUpgradeIds: ["training_yard_i", "training_yard_ii"],
    retinueUnits: [
      createSimRetinueUnit("sim-retinue-yard-militia", "militia", "veteran", 140, 3),
      createSimRetinueUnit("sim-retinue-yard-ranger", "ranger", "seasoned", 65, 1),
      createSimRetinueUnit("sim-retinue-yard-second-militia", "militia", "seasoned", 65, 1)
    ]
  },
  {
    id: "retinue_quartermaster_path",
    name: "Retinue + Quartermaster II",
    description: "Mixed retinue pressure combined with the Quartermaster I and II starter-resource path.",
    targetUpgradeIds: ["quartermaster_stores_i", "quartermaster_stores_ii"],
    retinueUnits: [
      createSimRetinueUnit("sim-retinue-quartermaster-militia", "militia", "veteran", 140, 3),
      createSimRetinueUnit("sim-retinue-quartermaster-ranger", "ranger", "seasoned", 65, 1)
    ]
  }
];

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
  const launch = requireBattleLaunch(
    createCampaignBattleLaunchRequest(heroSave, node, {
      difficulty: options.scenario.expectedDifficulty,
      aiPersonalityId: node.aiPersonalityId,
      modifiers: strongholdPlan.purchasedUpgradeIds.map((upgradeId) => ({ id: strongholdLaunchModifierId(upgradeId) })),
      retinueUnits: strongholdPlan.retinueUnits
    })
  );
  const driver = new ScriptedBattleDriver({
    node,
    heroSave,
    map: launch.map,
    scriptId: options.scriptId,
    strongholdPlan
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

function createSimRetinueUnit(
  retinueUnitId: string,
  unitTypeId: string,
  rank: RetinueUnitSaveData["rank"],
  xp: number,
  kills: number
): RetinueUnitSaveData {
  return {
    retinueUnitId,
    unitTypeId,
    rank,
    xp,
    kills,
    sourceBattleId: "playtest_retinue",
    acquiredAt: "2026-05-02T00:00:00.000Z",
    status: "active"
  };
}

function deployableRetinueForProfile(
  retinueUnits: RetinueUnitSaveData[],
  purchasedUpgradeIds: StrongholdUpgradeId[]
): RetinueUnitSaveData[] {
  const capacity = 2 + (purchasedUpgradeIds.includes("training_yard_ii") ? 1 : 0);
  return retinueUnits.filter((unit) => unit.status === "active").slice(0, capacity);
}

export function analyzePlaytestTelemetry(runs: PlaytestTelemetry[]): PlaytestAnalysis {
  const summaryKeys = [
    ...new Set(runs.map((run) => `${run.strongholdProfileId}:${run.nodeId}`))
  ];
  const nodeSummaries = summaryKeys.map((summaryKey) => {
    const [profileId, nodeId] = summaryKey.split(":");
    return summarizeNode(
      runs.filter((run) => run.strongholdProfileId === profileId && run.nodeId === nodeId)
    );
  });
  const tooEasyNodes = nodeSummaries.filter((summary) => summary.verdict === "too_easy").map((summary) => summary.nodeId);
  const tooHardNodes = nodeSummaries.filter((summary) => summary.verdict === "too_hard").map((summary) => summary.nodeId);
  const fairFirstAttackNodes = nodeSummaries
    .filter((summary) => summary.firstWaveSurvivedRuns >= Math.max(1, Math.ceil(summary.victories / 2)))
    .map((summary) => summary.nodeId);
  const unfairFirstAttackNodes = nodeSummaries
    .filter((summary) => summary.firstWaveSurvivedRuns === 0)
    .map((summary) => summary.nodeId);
  const barracksCompletesBeforePressure = nodeSummaries
    .filter((summary) => summary.barracksBeforePressureRuns >= 2)
    .map((summary) => summary.nodeId);
  const barracksLateBeforePressure = nodeSummaries
    .filter((summary) => summary.barracksBeforePressureRuns < 2)
    .map((summary) => summary.nodeId);
  const usefulRewardNodes = nodeSummaries
    .filter((summary) => runs.some((run) => run.nodeId === summary.nodeId && rewardLooksUseful(run.rewardResult)))
    .map((summary) => summary.nodeId);
  const weakRewardNodes = nodeSummaries
    .filter((summary) => !usefulRewardNodes.includes(summary.nodeId))
    .map((summary) => summary.nodeId);
  const ashenOutpostBeatable = runs.some((run) => run.nodeId === "ashen_outpost" && run.battleResult === "victory");
  const strongholdProfileSummaries = summarizeStrongholdProfiles(runs);
  const strongholdWarnings = strongholdProfileSummaries.flatMap((summary) => summary.warnings);

  return {
    tooEasyNodes: [...new Set(tooEasyNodes)],
    tooHardNodes: [...new Set(tooHardNodes)],
    fairFirstAttackNodes: [...new Set(fairFirstAttackNodes)],
    unfairFirstAttackNodes: [...new Set(unfairFirstAttackNodes)],
    barracksCompletesBeforePressure: [...new Set(barracksCompletesBeforePressure)],
    barracksLateBeforePressure: [...new Set(barracksLateBeforePressure)],
    usefulRewardNodes: [...new Set(usefulRewardNodes)],
    weakRewardNodes: [...new Set(weakRewardNodes)],
    ashenOutpostBeatable,
    strongholdWarnings,
    suggestedTuningChanges: buildSuggestedTuningChanges({
      nodeSummaries,
      tooEasyNodes,
      tooHardNodes,
      unfairFirstAttackNodes,
      barracksLateBeforePressure,
      weakRewardNodes,
      ashenOutpostBeatable,
      strongholdWarnings
    }),
    strongholdProfileSummaries,
    nodeSummaries
  };
}

export function renderPlaytestMarkdownReport(report: PlaytestReport): string {
  const lines: string[] = [];
  lines.push("# Automated Playtest Telemetry");
  lines.push("");
  lines.push(`Generated by: ${report.generatedBy}`);
  lines.push("");
  lines.push("## Summary");
  lines.push("");
  lines.push(listLine("Too easy", report.analysis.tooEasyNodes));
  lines.push(listLine("Too hard", report.analysis.tooHardNodes));
  lines.push(
    listLine(
      "Needs human review",
      report.analysis.nodeSummaries.filter((summary) => summary.verdict === "needs_human_review").map(formatSummaryLabel)
    )
  );
  lines.push(listLine("Fair first attack timing", report.analysis.fairFirstAttackNodes));
  lines.push(listLine("Late Barracks pressure risk", report.analysis.barracksLateBeforePressure));
  lines.push(listLine("Useful rewards observed", report.analysis.usefulRewardNodes));
  lines.push(`- Ashen Outpost beatable: ${report.analysis.ashenOutpostBeatable ? "yes" : "no"}`);
  lines.push(listLine("Stronghold warnings", report.analysis.strongholdWarnings));
  lines.push("");
  lines.push("## Tuning Applied");
  lines.push("");
  lines.push("- The simulator now uses the same per-map enemy AI config as the live `EnemyAIController`, including initial attack delay, attack interval, wave size, train interval, expansion cadence, and unit plan.");
  lines.push("- First Claim pacing was softened after the config alignment exposed earlier Easy contact: first attack 180s to 210s, attack interval 62s to 68s, wave target 7 to 6, train interval 5.4s to 5.6s.");
  lines.push("- Hexfire Cult and Fortress Keeper assault caps were reduced to 5 because remaining losses happened after first-wave survival, not before Barracks completion.");
  lines.push("- Ashen Outpost now starts with one extra Militia and Ranger, one fewer enemy Watchtower, lower enemy income/training/pressure, and a smaller defense squad/radius.");
  lines.push("- The Ashen simulator model now treats capturing the Burned Shrine as a staged approach advantage, which lets Safe Beginner beat the fortress while Greedy Economy and Fast Army still fail or time out.");
  lines.push("- Live Ashen Outpost now matches that telemetry assumption: completing Burned Shrine weakens the gate Watchtower and the in-battle HUD lists all three secondary objectives.");
  lines.push("- The report now separates structural too-hard failures from strategy-spread review when Safe Beginner wins with fair Barracks and first-wave timing.");
  lines.push("- Stronghold profiles are telemetry-only simulation paths: upgrades are purchased from simulated campaign-node resources when affordable, then applied as battle-launch effects.");
  lines.push("- Stronghold telemetry now covers every Tier I path plus a Tier II Quartermaster path for no-upgrade, Tier I, and Tier II comparison.");
  lines.push("- Watch Post now models earlier first-wave warning and better Watchtower reach; Quartermaster now models a broader starter bundle and faster first player building construction.");
  lines.push("- Retinue telemetry now covers no retinue, one Veteran Militia, one Veteran Ranger, mixed retinue, mixed retinue plus Training Yard II, and mixed retinue plus Quartermaster II.");
  lines.push("- The simulator now applies the same active retinue capacity used by campaign launches: 2 units by default, +1 only after Training Yard II is purchased.");
  lines.push("- Unit Veterancy thresholds were raised to 55 / 130 / 230 XP, rank stat multipliers were softened to +4% / +8% / +12%, and the armor bonus now starts at Elite.");
  lines.push("- Enemy Hero V1 telemetry now records assigned rival commander id, defeated state, attack-join timing, and losses involving the rival.");
  lines.push("");
  lines.push("## Enemy Hero Balance Pass Result");
  lines.push("");
  lines.push("- The 2026-05-02 telemetry-based enemy hero pass applied no numeric gameplay changes because rival commanders are relevant without creating structural `too_easy` or `too_hard` nodes.");
  lines.push("- Old Stone Road remains unassigned to an enemy hero: all 36 Old Stone Road simulations still win, and adding a rival there would risk making the early Easy lane noisy before the player has seen the mid-campaign commander pattern.");
  lines.push("- Veyra of the Cinders on Aether Well Ruins appears in 36 runs, is defeated in 24, joins attacks around 10:31-10:32 in 17 slow or retinue-assisted runs, and is involved in 12 player losses. Safe Beginner still wins, so her HP, damage, Hexfire Bolt range/cooldown, XP reward, and map assignment remain unchanged.");
  lines.push("- Gorak Emberhand on Bandit Hillfort appears in 36 runs, is defeated in 13, joins attacks around 11:40-11:41 in 12 Greedy Economy runs, and is involved in 12 player losses. His pressure is meaningful but not an early rush, so his HP, damage, Ember Strike/Rally Raiders tuning, XP reward, and Bandit Hillfort assignment remain unchanged.");
  lines.push("- Captain Malrec on Ashen Outpost appears in 36 runs, is defeated in all 36, joins attacks around 10:41-10:42 in 14 slow runs, and is involved in 14 player losses. Ashen remains a milestone because no-retinue and many Stronghold paths still produce timeouts, while mixed retinue sweeps remain human-review rather than structural `too_easy`.");
  lines.push("- Retinue and Stronghold paths make some Ashen outcomes stronger, but the commander data does not isolate a rival-specific overpowered or unfair pattern; keep deathless mixed-retinue Ashen sweeps under human review before buffing Malrec or nerfing retinue-adjacent interactions.");
  lines.push("");
  lines.push("## Retinue Balance Pass Result");
  lines.push("");
  lines.push("- The 2026-05-02 conservative retinue balance pass applied no numeric gameplay changes because telemetry shows no structural `too_easy` or `too_hard` nodes.");
  lines.push("- Retained capacity at 2 active units by default and +1 only from Training Yard II; mixed retinue profiles are strong enough for human review, but no-retinue Ashen Outpost remains beatable.");
  lines.push("- Retained Seasoned+ eligibility, 55 / 130 / 230 XP thresholds, +4% / +8% / +12% rank bonuses, Elite-only +1 armor, and permanent retinue removal on death.");
  lines.push("- Retained Quartermaster II interaction unchanged; the mixed-retinue Quartermaster profile is strong but still classified as human-review rather than structural `too_easy`.");
  lines.push("- Next balance action is human-paced Ashen Outpost review with no retinue, one Veteran, mixed retinue, Training Yard II, and Quartermaster II before changing numbers.");
  lines.push("");
  lines.push("## Stronghold Profile Verdicts");
  lines.push("");
  lines.push("| Profile | Target upgrades | Purchased upgrades | First purchase | Record | Improved runs | Warnings |");
  lines.push("| --- | --- | --- | --- | ---: | ---: | --- |");
  report.analysis.strongholdProfileSummaries.forEach((summary) => {
    lines.push(
      `| ${summary.profileName} | ${formatUpgradeList(summary.targetUpgradeIds)} | ${formatUpgradeList(
        summary.purchasedUpgradeIds
      )} | ${summary.firstPurchaseNodeId ?? "-"} | ${summary.victories}-${summary.defeats}-${summary.timeouts} | ${
        summary.improvedRuns
      } | ${summary.warnings.length > 0 ? summary.warnings.join("; ") : "-"} |`
    );
  });
  lines.push("");
  lines.push("## Node Verdicts");
  lines.push("");
  lines.push("| Profile | Node | Difficulty | AI | Wins | Losses | Barracks before pressure | First wave survived | Verdict |");
  lines.push("| --- | --- | --- | --- | ---: | ---: | ---: | ---: | --- |");
  report.analysis.nodeSummaries.forEach((summary) => {
    const runCount = report.telemetry.filter(
      (run) => run.strongholdProfileId === summary.strongholdProfileId && run.nodeId === summary.nodeId
    ).length;
    lines.push(
      `| ${summary.strongholdProfileName} | ${summary.nodeName} | ${summary.difficulty} | ${summary.aiPersonality} | ${
        summary.victories
      } | ${summary.defeats + summary.timeouts} | ${summary.barracksBeforePressureRuns}/${runCount} | ${
        summary.firstWaveSurvivedRuns
      }/${runCount} | ${summary.verdict} |`
    );
  });
  lines.push("");
  lines.push("## Scenario Runs");
  lines.push("");
  lines.push(
    "| Profile | Node | Script | Upgrades | Retinue | Enemy hero | Launch effects | Starting units | Starting resources | Result | Duration | First wave | Floated resources | Objectives | Rewards |"
  );
  lines.push("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | ---: | --- | --- | --- | --- |");
  report.telemetry.forEach((run) => {
    lines.push(
      `| ${run.strongholdProfileName} | ${run.nodeName} | ${formatScriptName(run.playerScript)} | ${formatUpgradeList(
        run.strongholdUpgradeIds
      )} | ${run.retinueUnits.length > 0 ? run.retinueUnits.join(", ") : "-"} | ${formatEnemyHeroTelemetry(run)} | ${formatStrongholdEffectTelemetry(run.strongholdEffects)} | ${formatUnitCounts(run.startingUnits)} | ${formatResources(
        run.startingResources
      )} | ${run.battleResult} | ${formatTime(run.battleDurationSeconds)} | ${
        run.firstWaveSurvived ? "yes" : "no"
      } | ${formatResources(run.resourcesFloated)} | ${
        run.objectiveCompletion.length > 0 ? run.objectiveCompletion.join(", ") : "-"
      } | ${formatReward(run.rewardResult)} |`
    );
  });
  lines.push("");
  lines.push("## Balance Read");
  lines.push("");
  report.analysis.nodeSummaries.forEach((summary) => {
    lines.push(`### ${summary.strongholdProfileName} - ${summary.nodeName}`);
    lines.push("");
    summary.notes.forEach((note) => lines.push(`- ${note}`));
    lines.push("");
  });
  lines.push("## Suggested Tuning Changes");
  lines.push("");
  report.analysis.suggestedTuningChanges.forEach((suggestion) => lines.push(`- ${suggestion}`));
  lines.push("");
  lines.push("## Human Judgment Still Needed");
  lines.push("");
  lines.push("- The simulator is deterministic and structural; it cannot judge moment-to-moment feel, readability, audio, or player stress.");
  lines.push("- Manual or visual browser playtests are still needed before finalizing deeper map, objective, or fortress-structure changes.");
  lines.push("- Treat remaining suggestions as investigation leads, not proof that more aggressive tuning is automatically correct.");
  lines.push("");
  return `${lines.join("\n")}\n`;
}

class ScriptedBattleDriver {
  private readonly state: BattleDriverState;
  private readonly heroSave: HeroSaveData;

  constructor(options: {
    node: CampaignNodeDefinition;
    heroSave: HeroSaveData;
    map: BattleMapDefinition;
    scriptId: PlaytestScriptId;
    strongholdPlan: PlaytestStrongholdNodePlan;
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
        })),
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
    return {
      ...this.state.telemetry,
      battleResult: this.state.result,
      battleDurationSeconds: Math.round(this.state.time),
      resourcesFloated: cloneResources(this.state.resources),
      peakResourcesFloated: cloneResources(this.state.peakResources),
      heroLevel,
      heroXpGained,
      finalArmySize: this.armySize(),
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
      return unitStrengthFromStats(requireEnemyHero(this.state.node.enemyHeroId).stats);
    }
    return unitStrength(requireUnit(unitId));
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

function runStrategy(scriptId: PlaytestScriptId, driver: ScriptedBattleDriver): void {
  if (scriptId === "safe_beginner") {
    runSafeBeginner(driver);
  } else if (scriptId === "greedy_economy") {
    runGreedyEconomy(driver);
  } else {
    runFastArmy(driver);
  }
}

function runSafeBeginner(driver: ScriptedBattleDriver): void {
  driver.selectHero();
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["crown_shrine", "west_supply_pyre", "west_stone_cut"],
    resources: ["crowns", "stone"]
  });
  driver.selectCommandHall();
  driver.buildBuilding("barracks");
  driver.waitForConstruction("barracks");
  driver.trainUnit("militia");
  driver.setRallyPoint({ x: 520, y: 820 });
  driver.waitUntil(245);
  driver.trainIfAffordable("militia");
  driver.trainIfAffordable("ranger");
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["stone_quarry", "south_iron_cache", "north_stone_scar"],
    resources: ["iron", "stone"]
  });
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["iron_vein", "south_iron_cache", "burned_shrine"],
    resources: ["iron", "aether"]
  });
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["aether_well", "north_aether_spring", "burned_shrine"],
    resources: ["aether", "stone"]
  });
  driver.buildIfAffordable("watchtower");
  driver.buildIfAffordable("mystic_lodge");
  driver.waitForConstruction("mystic_lodge");
  driver.trainIfAffordable("acolyte");
  driver.researchIfAffordable("reinforced_armor_1");
  driver.researchIfAffordable("infantry_weapons_1");
  driver.waitUntilArmySize(10, 620);
  driver.attackEnemyBase("safe beginner timing");
  driver.waitUntilArmySize(12, 760);
  driver.attackEnemyBase("safe beginner second push");
}

function runGreedyEconomy(driver: ScriptedBattleDriver): void {
  driver.selectHero();
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["crown_shrine", "west_supply_pyre", "ford_toll"],
    resources: ["crowns"]
  });
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["stone_quarry", "west_stone_cut", "north_stone_scar"],
    resources: ["stone"]
  });
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["iron_vein", "south_iron_cache", "south_iron_pit"],
    resources: ["iron"]
  });
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["aether_well", "north_aether_spring", "burned_shrine"],
    resources: ["aether"]
  });
  driver.waitUntil(178);
  driver.selectCommandHall();
  driver.buildBuilding("barracks");
  driver.waitForConstruction("barracks");
  driver.trainIfAffordable("militia");
  driver.trainIfAffordable("ranger");
  driver.setRallyPoint({ x: 780, y: 880 });
  driver.buildIfAffordable("mystic_lodge");
  driver.waitForConstruction("mystic_lodge");
  driver.trainIfAffordable("acolyte");
  driver.researchIfAffordable("ranger_training_1");
  driver.waitUntilArmySize(11, 760);
  driver.attackEnemyBase("greedy economy push");
}

function runFastArmy(driver: ScriptedBattleDriver): void {
  driver.selectCommandHall();
  driver.buildBuilding("barracks");
  driver.waitForConstruction("barracks");
  driver.trainUnit("militia");
  driver.trainIfAffordable("militia");
  driver.trainIfAffordable("ranger");
  driver.selectHero();
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["crown_shrine", "west_supply_pyre", "west_stone_cut"],
    resources: ["crowns", "stone"]
  });
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["iron_vein", "south_iron_cache", "south_iron_pit"],
    resources: ["iron"]
  });
  driver.setRallyPoint({ x: 620, y: 780 });
  driver.trainIfAffordable("militia");
  driver.trainIfAffordable("ranger");
  driver.researchIfAffordable("infantry_weapons_1");
  driver.buildIfAffordable("watchtower");
  driver.waitUntilArmySize(8, 430);
  driver.attackEnemyBase("fast army probe");
  driver.waitUntilArmySize(11, 620);
  driver.attackEnemyBase("fast army follow-up");
}

function summarizeStrongholdProfiles(runs: PlaytestTelemetry[]): PlaytestStrongholdProfileSummary[] {
  const baseline = runs.filter((run) => run.strongholdProfileId === "no_stronghold");
  const profileIds = [...new Set(runs.map((run) => run.strongholdProfileId))];
  return profileIds.map((profileId) => {
    const profileRuns = runs.filter((run) => run.strongholdProfileId === profileId);
    const first = profileRuns[0];
    const targetUpgradeIds = [...new Set(profileRuns.flatMap((run) => run.strongholdTargetUpgradeIds))];
    const purchasedUpgradeIds = [...new Set(profileRuns.flatMap((run) => run.strongholdUpgradeIds))];
    const victories = profileRuns.filter((run) => run.battleResult === "victory").length;
    const defeats = profileRuns.filter((run) => run.battleResult === "defeat").length;
    const timeouts = profileRuns.filter((run) => run.battleResult === "timeout").length;
    const improvedRuns =
      profileId === "no_stronghold"
        ? 0
        : profileRuns.filter((run) => {
            const baselineRun = baseline.find((entry) => entry.nodeId === run.nodeId && entry.playerScript === run.playerScript);
            return baselineRun ? strongholdRunImprovesOnBaseline(run, baselineRun) : false;
          }).length;
    const firstPurchase = profileRuns.find((run) => run.strongholdUpgradeIds.length > 0);
    const warnings: string[] = [];
    if (profileId !== "no_stronghold" && targetUpgradeIds.some((upgradeId) => !purchasedUpgradeIds.includes(upgradeId))) {
      const missing = targetUpgradeIds
        .filter((upgradeId) => !purchasedUpgradeIds.includes(upgradeId))
        .map((upgradeId) => STRONGHOLD_UPGRADE_BY_ID[upgradeId].name);
      warnings.push(`${first.strongholdProfileName}: too expensive in simulated route; never purchased ${missing.join(", ")}.`);
    }
    if (profileId !== "no_stronghold" && purchasedUpgradeIds.length > 0 && improvedRuns === 0) {
      warnings.push(`${first.strongholdProfileName}: purchased upgrade did not improve any simulated outcome.`);
    }
    if (profileId !== "no_stronghold" && profileRuns.length > 0 && profileRuns.every((run) => run.battleResult === "victory" && run.unitsLost <= 1)) {
      warnings.push(`${first.strongholdProfileName}: overpowered risk; it trivialized every simulated node.`);
    }
    return {
      profileId,
      profileName: first.strongholdProfileName,
      targetUpgradeIds,
      purchasedUpgradeIds,
      victories,
      defeats,
      timeouts,
      improvedRuns,
      firstPurchaseNodeId: firstPurchase?.nodeId ?? null,
      warnings
    };
  });
}

function strongholdRunImprovesOnBaseline(run: PlaytestTelemetry, baseline: PlaytestTelemetry): boolean {
  const resultDelta = resultScore(run.battleResult) - resultScore(baseline.battleResult);
  if (resultDelta > 0) {
    return true;
  }
  if (resultDelta < 0) {
    return false;
  }
  if (!baseline.firstWaveSurvived && run.firstWaveSurvived) {
    return true;
  }
  if (
    baseline.timeFirstEnemyWarning !== null &&
    run.timeFirstEnemyWarning !== null &&
    run.timeFirstEnemyWarning <= baseline.timeFirstEnemyWarning - 10
  ) {
    return true;
  }
  if (
    baseline.timeBarracksCompleted !== null &&
    run.timeBarracksCompleted !== null &&
    run.timeBarracksCompleted <= baseline.timeBarracksCompleted - 2
  ) {
    return true;
  }
  if (
    baseline.timeFirstUnitTrained !== null &&
    run.timeFirstUnitTrained !== null &&
    run.timeFirstUnitTrained <= baseline.timeFirstUnitTrained - 2
  ) {
    return true;
  }
  if (run.battleResult === "victory" && run.battleDurationSeconds <= baseline.battleDurationSeconds - 15) {
    return true;
  }
  if (run.unitsLost <= baseline.unitsLost - 1) {
    return true;
  }
  return run.finalArmySize >= baseline.finalArmySize + 1;
}

function resultScore(result: PlaytestResult): number {
  if (result === "victory") {
    return 3;
  }
  if (result === "timeout") {
    return 2;
  }
  return 1;
}

function summarizeNode(runs: PlaytestTelemetry[]): PlaytestNodeSummary {
  const first = runs[0];
  const victories = runs.filter((run) => run.battleResult === "victory").length;
  const defeats = runs.filter((run) => run.battleResult === "defeat").length;
  const timeouts = runs.filter((run) => run.battleResult === "timeout").length;
  const averageDurationSeconds =
    runs.reduce((total, run) => total + run.battleDurationSeconds, 0) / Math.max(1, runs.length);
  const barracksBeforePressureRuns = runs.filter((run) => {
    if (run.timeBarracksCompleted === null || run.timeFirstEnemyContact === null) {
      return false;
    }
    return run.timeBarracksCompleted < run.timeFirstEnemyContact;
  }).length;
  const firstWaveSurvivedRuns = runs.filter((run) => run.firstWaveSurvived).length;
  const safeRouteWon = safeBeginnerWon(runs);
  const fairOpening = openingLooksFair(runs, barracksBeforePressureRuns, firstWaveSurvivedRuns);
  const verdict = nodeVerdict(runs, victories, defeats, timeouts, safeRouteWon, fairOpening);
  const notes: string[] = [];
  if (victories === runs.length && first.nodeId !== "border_village") {
    notes.push(
      first.strongholdProfileId.startsWith("retinue_")
        ? "Retinue profile swept this node; review whether saved veterans feel helpful or too mandatory in human play."
        : "All scripted strategies won; verify this node is not over-rewarding broad openings."
    );
  }
  if (victories === 0) {
    notes.push("No scripted strategy won; this is a structural difficulty risk before deeper tuning.");
  }
  if (barracksBeforePressureRuns < 2) {
    notes.push("Barracks completion is late relative to first enemy contact for most scripts.");
  } else {
    notes.push("At least two scripts complete Barracks before first contact.");
  }
  if (firstWaveSurvivedRuns === runs.length) {
    notes.push("All scripts survived the first wave.");
  } else if (firstWaveSurvivedRuns === 0) {
    notes.push("No script survived the first wave.");
  } else {
    notes.push("First wave pressure differentiates scripts, which is useful for balance reads.");
  }
  if (runs.some((run) => run.rewardResult && rewardLooksUseful(run.rewardResult))) {
    notes.push("Victory rewards include meaningful XP, resources, or gear.");
  } else {
    notes.push("No useful victory reward was observed because scripts did not win.");
  }
  if (safeRouteWon && victories < runs.length && fairOpening) {
    notes.push("Safe Beginner wins while riskier scripts fail or time out; treat this as a strategy-spread review, not proof that opening pressure is unfair.");
  }
  return {
    strongholdProfileId: first.strongholdProfileId,
    strongholdProfileName: first.strongholdProfileName,
    nodeId: first.nodeId,
    nodeName: first.nodeName,
    mapId: first.mapId,
    difficulty: first.difficulty,
    aiPersonality: first.aiPersonality,
    victories,
    defeats,
    timeouts,
    averageDurationSeconds,
    barracksBeforePressureRuns,
    firstWaveSurvivedRuns,
    verdict,
    notes
  };
}

function nodeVerdict(
  runs: PlaytestTelemetry[],
  victories: number,
  defeats: number,
  timeouts: number,
  safeRouteWon: boolean,
  fairOpening: boolean
): PlaytestNodeSummary["verdict"] {
  const nodeId = runs[0]?.nodeId;
  if (victories === 0) {
    return "too_hard";
  }
  if (nodeId !== "border_village" && victories === runs.length && runs.every((run) => run.unitsLost <= 1)) {
    if (runs[0]?.strongholdProfileId.startsWith("retinue_")) {
      return "needs_human_review";
    }
    return "too_easy";
  }
  if (nodeId === "border_village" && victories >= 2) {
    return "reasonable";
  }
  if (victories === runs.length) {
    return "reasonable";
  }
  if (victories >= 1 && runs.some((run) => run.battleResult !== "victory")) {
    if (safeRouteWon && fairOpening) {
      return "needs_human_review";
    }
    if (defeats >= 2 || timeouts >= 2) {
      return "too_hard";
    }
    return "reasonable";
  }
  return "needs_human_review";
}

function buildSuggestedTuningChanges(input: {
  nodeSummaries: PlaytestNodeSummary[];
  tooEasyNodes: string[];
  tooHardNodes: string[];
  unfairFirstAttackNodes: string[];
  barracksLateBeforePressure: string[];
  weakRewardNodes: string[];
  ashenOutpostBeatable: boolean;
  strongholdWarnings: string[];
}): string[] {
  const suggestions: string[] = [];
  const humanReviewNodes = input.nodeSummaries
    .filter((summary) => summary.verdict === "needs_human_review")
    .map(formatSummaryLabel);
  if (input.tooHardNodes.length > 0) {
    suggestions.push(
      `Investigate remaining pressure on ${input.tooHardNodes.join(", ")} before further changes; only tune first attack delay, wave size, or starting resources when opening timing also fails.`
    );
  }
  if (humanReviewNodes.length > 0) {
    suggestions.push(
      `Review strategy spread on ${humanReviewNodes.join(", ")} before more numeric changes; Safe Beginner can stabilize, so remaining failures are more likely objective route, army timing, or final-assault attrition than first-wave unfairness.`
    );
  }
  if (input.tooEasyNodes.length > 0) {
    suggestions.push(
      `Review ${input.tooEasyNodes.join(", ")} for over-safe openings; likely levers are enemy attack interval or objective defense, not new systems.`
    );
  }
  if (input.barracksLateBeforePressure.length > 0) {
    suggestions.push(
      `Check whether Barracks timing is fair on ${input.barracksLateBeforePressure.join(", ")}; avoid tuning until a human confirms the opening feels rushed.`
    );
  }
  if (input.unfairFirstAttackNodes.length > 0) {
    suggestions.push(
      `First-wave survival failed across scripts on ${input.unfairFirstAttackNodes.join(", ")}; inspect warning timing and first-contact travel time.`
    );
  }
  if (input.weakRewardNodes.length > 0) {
    suggestions.push(
      `No victory reward was observed for ${input.weakRewardNodes.join(", ")} in this run; improve survivability reads before reward tuning.`
    );
  }
  if (!input.ashenOutpostBeatable) {
    suggestions.push("Ashen Outpost was not beaten by the scripted suite; inspect fortress assault requirements before any deeper structural tuning.");
  }
  input.strongholdWarnings.forEach((warning) => suggestions.push(warning));
  suggestions.push("Use this bot to guide conservative numeric passes, and reserve deeper map or objective changes for a later review.");
  return suggestions;
}

function safeBeginnerWon(runs: PlaytestTelemetry[]): boolean {
  return runs.some((run) => run.playerScript === "safe_beginner" && run.battleResult === "victory");
}

function openingLooksFair(runs: PlaytestTelemetry[], barracksBeforePressureRuns: number, firstWaveSurvivedRuns: number): boolean {
  return barracksBeforePressureRuns >= Math.max(1, Math.ceil(runs.length / 2)) && firstWaveSurvivedRuns === runs.length;
}

function rewardLooksUseful(reward: PlaytestRewardTelemetry | null): boolean {
  if (!reward) {
    return false;
  }
  const resourceTotal = Object.values(reward.battleResources).reduce((total, amount) => total + (amount ?? 0), 0);
  const campaignResourceTotal = Object.values(reward.campaignResources).reduce((total, amount) => total + (amount ?? 0), 0);
  return (
    reward.battleItemIds.length > 0 ||
    reward.campaignItemIds.length > 0 ||
    reward.battleXp + reward.campaignXp >= 40 ||
    resourceTotal + campaignResourceTotal >= 50
  );
}

function createPlaytestHeroForNode(nodeId: string): HeroSaveData {
  const hero = createFallbackHeroSave();
  if (nodeId === "border_village") {
    return hero;
  }
  if (nodeId === "old_stone_road") {
    return {
      ...hero,
      xp: 75,
      completedBattles: 1,
      clearedMapIds: ["first_claim"],
      inventory: [{ instanceId: "sim-weathered-sword", itemId: "weathered_command_sword", acquiredAt: "sim", source: "playtest", affixes: [] }]
    };
  }
  if (nodeId === "ashen_outpost") {
    return {
      ...hero,
      level: 3,
      xp: 270,
      skillPoints: 1,
      completedBattles: 4,
      clearedMapIds: ["first_claim", "broken_ford"],
      inventory: [
        { instanceId: "sim-weathered-sword", itemId: "weathered_command_sword", acquiredAt: "sim", source: "playtest", affixes: [] },
        { instanceId: "sim-fordbreaker", itemId: "fordbreaker_halberd", acquiredAt: "sim", source: "playtest", affixes: [] },
        { instanceId: "sim-captains-seal", itemId: "captains_seal", acquiredAt: "sim", source: "playtest", affixes: [] }
      ],
      stats: { ...hero.stats, might: hero.stats.might + 2, command: hero.stats.command + 1 }
    };
  }
  return {
    ...hero,
    level: 2,
    xp: 140,
    skillPoints: 1,
    completedBattles: 2,
    clearedMapIds: ["first_claim"],
    inventory: [
      { instanceId: "sim-weathered-sword", itemId: "weathered_command_sword", acquiredAt: "sim", source: "playtest", affixes: [] }
    ],
    stats: { ...hero.stats, might: hero.stats.might + 1 }
  };
}

function initialPlayerUnits(map: BattleMapDefinition): Record<string, number> {
  return map.scenario.unitSpawns
    .filter((spawn) => spawn.team === "player")
    .reduce<Record<string, number>>((counts, spawn) => {
      counts[spawn.unitId] = (counts[spawn.unitId] ?? 0) + 1;
      return counts;
    }, {});
}

function initialEnemyArmy(map: BattleMapDefinition, difficulty: BattleDifficulty): string[] {
  const allowed = new Set(getBattleDifficulty(difficulty).enemyStartingUnitSpawnIds);
  return map.scenario.unitSpawns
    .filter((spawn) => spawn.team === "enemy" && allowed.has(spawn.id))
    .map((spawn) => spawn.unitId);
}

function firstAttackTime(node: CampaignNodeDefinition, firstAttackDelay: number): number {
  if (node.id === "border_village") {
    return Math.max(firstAttackDelay, FIRST_MATCH_TUTORIAL_PROTECTION.firstAttackAllowedAfterSeconds);
  }
  return firstAttackDelay;
}

function unitStrength(unit: UnitDefinition): number {
  return unitStrengthFromStats(unit.stats);
}

function unitStrengthFromStats(stats: CombatStats): number {
  const rangeFactor = stats.range >= 120 ? 1.22 : 1;
  return stats.maxHp / 22 + (stats.damage / stats.attackCooldown) * rangeFactor + stats.armor * 1.6;
}

function retinueStrengthBonusForUnit(unit: RetinueUnitSaveData): number {
  const definition = requireUnit(unit.unitTypeId);
  return Math.max(0, unitStrengthFromStats(applyUnitVeterancyStatBonuses(definition.stats, unit.rank)) - unitStrength(definition));
}

function heroStrength(hero: HeroSaveData): number {
  const heroClass = requireHeroClass(hero.classId);
  const origin = requireOrigin(hero.originId);
  return (
    heroClass.baseStats.maxHp / 24 +
    heroClass.baseStats.damage / heroClass.baseStats.attackCooldown +
    hero.level * 4 +
    hero.stats.might * 0.8 +
    hero.stats.command * 0.6 +
    (origin.statMods.might ?? 0) * 0.7
  );
}

function formatOptionalTime(seconds: number | null): string {
  return seconds === null ? "-" : formatTime(seconds);
}

function formatReward(reward: PlaytestRewardTelemetry | null): string {
  if (!reward) {
    return "-";
  }
  const itemText = [...reward.battleItemIds, ...reward.campaignItemIds].join(", ");
  const resourceTotal =
    Object.values(reward.battleResources).reduce((total, amount) => total + (amount ?? 0), 0) +
    Object.values(reward.campaignResources).reduce((total, amount) => total + (amount ?? 0), 0);
  return `${reward.battleXp + reward.campaignXp} XP, ${resourceTotal} resources${itemText ? `, ${itemText}` : ""}`;
}

function cloneStrongholdBattleEffects(effects: StrongholdBattleEffects): StrongholdBattleEffects {
  return {
    extraPlayerUnitIds: [...effects.extraPlayerUnitIds],
    startingResources: { ...effects.startingResources },
    heroMaxHpMultiplier: effects.heroMaxHpMultiplier,
    heroMaxManaMultiplier: effects.heroMaxManaMultiplier,
    buildingVisionBonus: effects.buildingVisionBonus,
    enemyWarningLeadSeconds: effects.enemyWarningLeadSeconds,
    watchtowerRangeMultiplier: effects.watchtowerRangeMultiplier,
    firstBuildingConstructionTimeMultiplier: effects.firstBuildingConstructionTimeMultiplier,
    unitTrainingTimeMultipliers: { ...effects.unitTrainingTimeMultipliers }
  };
}

function formatStrongholdEffectTelemetry(effects: StrongholdBattleEffects): string {
  const parts: string[] = [];
  if (effects.extraPlayerUnitIds.length > 0) {
    parts.push(`units ${effects.extraPlayerUnitIds.join(", ")}`);
  }
  if (Object.values(effects.startingResources).some((amount) => (amount ?? 0) > 0)) {
    parts.push(`resources ${formatResources(effects.startingResources)}`);
  }
  if (effects.heroMaxHpMultiplier > 1 || effects.heroMaxManaMultiplier > 1) {
    parts.push(
      `hero ${Math.round((effects.heroMaxHpMultiplier - 1) * 100)}% HP/${Math.round(
        (effects.heroMaxManaMultiplier - 1) * 100
      )}% Mana`
    );
  }
  if (effects.buildingVisionBonus > 0) {
    parts.push(`vision +${effects.buildingVisionBonus}`);
  }
  if (effects.enemyWarningLeadSeconds > 0) {
    parts.push(`warning +${effects.enemyWarningLeadSeconds}s`);
  }
  if (effects.watchtowerRangeMultiplier > 1) {
    parts.push(`tower +${Math.round((effects.watchtowerRangeMultiplier - 1) * 100)}%`);
  }
  if (effects.firstBuildingConstructionTimeMultiplier < 1) {
    parts.push(`first build ${Math.round((1 - effects.firstBuildingConstructionTimeMultiplier) * 100)}% faster`);
  }
  Object.entries(effects.unitTrainingTimeMultipliers).forEach(([unitId, multiplier]) => {
    if (multiplier !== undefined && multiplier < 1) {
      parts.push(`${titleCase(unitId)} train ${Math.round((1 - multiplier) * 100)}% faster`);
    }
  });
  return parts.length > 0 ? parts.join("; ") : "-";
}

function formatResources(resources: Partial<ResourceBag>): string {
  const parts = [
    ["Crowns", resources.crowns ?? 0],
    ["Stone", resources.stone ?? 0],
    ["Iron", resources.iron ?? 0],
    ["Aether", resources.aether ?? 0]
  ] as const;
  const active = parts.filter(([, amount]) => amount > 0);
  return active.length > 0 ? active.map(([label, amount]) => `${amount} ${label}`).join(", ") : "none";
}

function formatUnitCounts(units: Record<string, number>): string {
  const active = Object.entries(units).filter(([, count]) => count > 0);
  return active.length > 0
    ? active
        .map(([unitId, count]) => `${count} ${titleCase(unitId)}`)
        .join(", ")
    : "none";
}

function formatUpgradeList(upgradeIds: StrongholdUpgradeId[]): string {
  return upgradeIds.length > 0 ? upgradeIds.map((upgradeId) => STRONGHOLD_UPGRADE_BY_ID[upgradeId].name).join(", ") : "none";
}

function formatRetinueTelemetry(unit: RetinueUnitSaveData): string {
  return `${getUnitVeterancyRank(unit.rank).name} ${titleCase(unit.unitTypeId)}`;
}

function formatEnemyHeroTelemetry(run: PlaytestTelemetry): string {
  if (!run.enemyHeroId) {
    return "-";
  }
  const joined = run.timeEnemyHeroJoinedAttack === null ? "held" : `joined ${formatTime(run.timeEnemyHeroJoinedAttack)}`;
  const defeated = run.enemyHeroDefeated ? "defeated" : "alive";
  const losses = run.lossesInvolvingEnemyHero > 0 ? `, losses ${run.lossesInvolvingEnemyHero}` : "";
  return `${run.enemyHeroId} ${defeated}, ${joined}${losses}`;
}

function listLine(label: string, values: string[]): string {
  const unique = uniqueValues(values);
  return `- ${label}: ${unique.length > 0 ? unique.join(", ") : "none"}`;
}

function formatScriptName(scriptId: PlaytestScriptId): string {
  return scriptId
    .split("_")
    .map((part) => part[0].toUpperCase() + part.slice(1))
    .join(" ");
}

function titleCase(value: string): string {
  return value
    .split("_")
    .map((part) => part[0].toUpperCase() + part.slice(1))
    .join(" ");
}

function formatSummaryLabel(summary: PlaytestNodeSummary): string {
  return `${summary.strongholdProfileName} / ${summary.nodeName}`;
}

function uniqueValues<T>(values: T[]): T[] {
  return [...new Set(values)];
}
