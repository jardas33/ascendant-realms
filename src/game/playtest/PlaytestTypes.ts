import type {
  BattleDifficulty,
  EnemyAIPersonalityId,
  Position,
  ResourceBag,
  StrongholdUpgradeId
} from "../core/GameTypes";
import type { StrongholdBattleEffects } from "../data/strongholdUpgrades";
import type { RetinueUnitSaveData, RivalLastOutcome, RivalModifierId } from "../save/SaveTypes";

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

export interface PlaytestStrongholdNodePlan {
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
  rivalStateBefore: string | null;
  rivalOutcome: RivalLastOutcome | "none";
  rivalStateAfter: string | null;
  rivalModifiersApplied: RivalModifierId[];
  lossesAgainstRival: number;
  rivalFirstDefeatRewardEarned: boolean;
  rivalDuplicateRewardPrevented: boolean;
  rivalTrophyEarned: string | null;
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


export interface PlaytestStrategyDriver {
  selectHero(): void;
  selectCommandHall(): void;
  moveHeroAndUnitsToPreferredCapturePoint(options: { preferredIds?: string[]; resources?: Array<keyof ResourceBag> }): void;
  buildBuilding(buildingId: string): boolean;
  waitForConstruction(buildingId: string): void;
  trainUnit(unitId: string): boolean;
  setRallyPoint(point: Position): void;
  buildIfAffordable(buildingId: string): boolean;
  trainIfAffordable(unitId: string): boolean;
  researchIfAffordable(upgradeId: string): boolean;
  waitUntil(targetTime: number): void;
  waitUntilArmySize(targetSize: number, latestTime: number): void;
  attackEnemyBase(label: string): void;
}
