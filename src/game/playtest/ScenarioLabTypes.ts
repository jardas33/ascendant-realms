import type { PlaytestResult, PlaytestScriptId, PlaytestStrongholdProfileId } from "./PlaytestTypes";

export type ScenarioLabProfileId =
  | "baseline_cautious"
  | "no_retinue"
  | "one_veteran"
  | "mixed_veterans"
  | "retinue_training_yard_ii"
  | "greedy_economy"
  | "fast_army"
  | "pressure_ignoring"
  | "objective_rush"
  | "safe_beginner";

export type ScenarioLabWatchpointId =
  | "retinue_training_yard_ii"
  | "greedy_economy"
  | "fast_army"
  | "early_defeats"
  | "pressure_fairness"
  | "cinderfen_crossing_fairness"
  | "cinderfen_watch_fairness"
  | "ashen_outpost_stability";

export type ScenarioLabRiskAppetite = "low" | "medium" | "high";
export type ScenarioLabPriority = "survive" | "economy" | "speed" | "objectives" | "pressure_probe";
export type ScenarioLabConfidence = "low" | "medium" | "high" | "inconclusive";
export type ScenarioLabAction =
  | "no change"
  | "monitor"
  | "needs human testing"
  | "copy/readability candidate"
  | "tiny tuning candidate"
  | "future systems pass"
  | "future visual/UI pass";

export type ScenarioLabFailureReason =
  | "none"
  | "early_pressure_defeat"
  | "pressure_attrition_defeat"
  | "failed_assault_defeat"
  | "conversion_timeout"
  | "attrition_timeout"
  | "clear_speed_timeout"
  | "unknown_timeout";

export interface ScenarioLabProfileMarkers {
  retinueUsed: boolean;
  trainingYardIIActive: boolean;
  greedyEconomy: boolean;
  fastArmy: boolean;
  pressureProbe: boolean;
}

export interface ScenarioLabProfileDefinition {
  id: ScenarioLabProfileId;
  name: string;
  routeAssumptions: string[];
  playerBehaviorModel: string;
  preferredStrongholdProfileIds: PlaytestStrongholdProfileId[];
  scriptIds: PlaytestScriptId[];
  nodeIds: string[];
  riskAppetite: ScenarioLabRiskAppetite;
  objectivePriority: ScenarioLabPriority;
  retreatSurvivalBias: "low" | "medium" | "high";
  expectedStrengths: string[];
  expectedWeaknesses: string[];
  watchpointRelevance: ScenarioLabWatchpointId[];
  markers: ScenarioLabProfileMarkers;
  automationNotes: string[];
}

export interface ScenarioLabRunMetric {
  profileId: ScenarioLabProfileId;
  profileName: string;
  sourceStrongholdProfileId: PlaytestStrongholdProfileId;
  sourceStrongholdProfileName: string;
  playerScript: PlaytestScriptId;
  nodeId: string;
  nodeName: string;
  result: PlaytestResult;
  failureReason: ScenarioLabFailureReason;
  likelyIssue: "none" | "balance" | "pacing" | "clarity" | "systems" | "human_noticeability_unknown";
  clearTimeSeconds: number;
  heroSurvivalState: "unavailable";
  armySurvivalCount: number;
  unitLosses: number;
  unitsTrained: number;
  resourceSurplus: number;
  finalAether: number;
  peakAether: number;
  objectiveCompletionCount: number;
  pressureWarningCount: number;
  pressureReactionWindowSeconds: number | null;
  baseDamageState: "unavailable";
  retinueUsed: boolean;
  trainingYardIIActive: boolean;
  greedyEconomyMarker: boolean;
  fastArmyMarker: boolean;
}

export interface ScenarioLabRecord {
  wins: number;
  defeats: number;
  timeouts: number;
}

export interface ScenarioLabProfileSummary {
  profileId: ScenarioLabProfileId;
  profileName: string;
  runCount: number;
  record: ScenarioLabRecord;
  winRate: number;
  averageClearTimeSeconds: number;
  averageUnitLosses: number;
  averageFinalArmySize: number;
  averageResourceSurplus: number;
  averageFinalAether: number;
  pressureRunCount: number;
  pressureWarningCount: number;
  averagePressureReactionWindowSeconds: number | null;
  ashenOutpostRecord: ScenarioLabRecord;
  cinderfenCrossingRecord: ScenarioLabRecord;
  cinderfenWatchRecord: ScenarioLabRecord;
  failureReasons: Record<ScenarioLabFailureReason, number>;
  routeVerdict: string;
  confidence: ScenarioLabConfidence;
  notes: string[];
}

export interface ScenarioLabNodeRiskSummary {
  nodeId: string;
  nodeName: string;
  record: ScenarioLabRecord;
  averageUnitLosses: number;
  timeoutCount: number;
  defeatCount: number;
  pressureWarningCount: number;
  verdict: string;
}

export interface ScenarioLabMetricAvailability {
  metric: string;
  status: "available" | "derived" | "unavailable";
  note: string;
}

export interface ScenarioLabWatchpointClassification {
  watchpointId: ScenarioLabWatchpointId;
  watchpointName: string;
  action: ScenarioLabAction;
  confidence: ScenarioLabConfidence;
  automatedVerdict: string;
  evidence: string[];
  humanTestingNeeded: boolean;
}

export interface ScenarioLabReport {
  schemaVersion: 1;
  generatedBy: string;
  sourceReportSchemaVersion: number;
  sourceRunCount: number;
  profiles: ScenarioLabProfileSummary[];
  runMetrics: ScenarioLabRunMetric[];
  nodeRiskSummaries: ScenarioLabNodeRiskSummary[];
  watchpoints: ScenarioLabWatchpointClassification[];
  strongestProfileId: ScenarioLabProfileId | null;
  weakestProfileId: ScenarioLabProfileId | null;
  fastestProfileId: ScenarioLabProfileId | null;
  mostFailureProneProfileId: ScenarioLabProfileId | null;
  metricsAvailability: ScenarioLabMetricAvailability[];
}
