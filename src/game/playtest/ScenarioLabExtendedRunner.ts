import { classifyScenarioLabRegressionThresholds } from "./ScenarioLabRegressionThresholds";
import { runScenarioLab } from "./ScenarioLabRunner";
import type {
  ScenarioLabAction,
  ScenarioLabBalanceRegressionDashboard,
  ScenarioLabConfidence,
  ScenarioLabDistribution,
  ScenarioLabExtendedOptions,
  ScenarioLabExtendedReport,
  ScenarioLabExtendedRunMetric,
  ScenarioLabIterationSummary,
  ScenarioLabNodeRiskDashboardEntry,
  ScenarioLabProfileComparison,
  ScenarioLabProfileId,
  ScenarioLabProfileNodeScriptComparison,
  ScenarioLabRecord,
  ScenarioLabRegressionStatus,
  ScenarioLabReport,
  ScenarioLabWatchpointId,
  ScenarioLabWatchpointRegression
} from "./ScenarioLabTypes";
import type { PlaytestScriptId } from "./PlaytestTypes";

export const DEFAULT_SCENARIO_LAB_EXTENDED_ITERATIONS = 5;
export const DEFAULT_SCENARIO_LAB_EXTENDED_SEED = "scenario-lab-v0131";

export function runExtendedScenarioLab(options: ScenarioLabExtendedOptions = {}): ScenarioLabExtendedReport {
  const iterationCount = normalizeIterationCount(options.iterations);
  const seed = options.seed?.trim() || DEFAULT_SCENARIO_LAB_EXTENDED_SEED;
  const batchLabel = options.batchLabel?.trim() || "v0.13.1 extended deterministic scenario lab";
  const generatedAt = options.generatedAt ?? new Date().toISOString();
  const buildCommit = options.buildCommit ?? "unrecorded";
  const reports = Array.from({ length: iterationCount }, () => runScenarioLab());
  const iterationSummaries = reports.map((report, index) => buildIterationSummary(report, index + 1, seed));
  const extendedRunMetrics = reports.flatMap((report, reportIndex) => {
    const iteration = reportIndex + 1;
    const seedId = seedFor(seed, iteration);
    return report.runMetrics.map((metric, metricIndex) => ({
      ...metric,
      batchLabel,
      iteration,
      seedId,
      runKey: `${batchLabel}:${seedId}:${metric.profileId}:${metric.nodeId}:${metric.playerScript}:${metric.sourceStrongholdProfileId}:${metricIndex}`
    }));
  });
  const uniqueDerivedMetricFingerprints = uniqueValues(extendedRunMetrics.map((metric) => derivedMetricFingerprint(metric))).length;
  const profileComparisons = summarizeProfileComparisons(reports, extendedRunMetrics);
  const profileNodeScriptComparisons = summarizeProfileNodeScriptComparisons(extendedRunMetrics);
  const nodeRiskDashboard = summarizeNodeRiskDashboard(extendedRunMetrics);
  const watchpointRegressions = classifyScenarioLabRegressionThresholds({
    profileComparisons,
    nodeRiskDashboard,
    runMetrics: extendedRunMetrics
  });
  const dashboard = buildBalanceRegressionDashboard({
    generatedAt,
    buildCommit,
    batchLabel,
    iterationCount,
    seed,
    profileComparisons,
    nodeRiskDashboard,
    watchpointRegressions
  });

  return {
    schemaVersion: 1,
    generatedBy: "Ascendant Realms extended automated playtest scenario lab v0.13.1",
    generatedAt,
    buildCommit,
    batchLabel,
    seed,
    iterationCount,
    sourceRunCountPerIteration: reports[0]?.sourceRunCount ?? 0,
    totalSourceRuns: reports.reduce((total, report) => total + report.sourceRunCount, 0),
    totalDerivedMetrics: extendedRunMetrics.length,
    uniqueDerivedMetricFingerprints,
    iterationSummaries,
    profileComparisons,
    profileNodeScriptComparisons,
    nodeRiskDashboard,
    watchpointRegressions,
    strongestProfileId: dashboard.strongestProfileId,
    weakestProfileId: dashboard.weakestProfileId,
    fastestProfileId: mostFrequentProfile(iterationSummaries.map((summary) => summary.fastestProfileId)),
    mostFailureProneProfileId: dashboard.weakestProfileId,
    biggestTimeoutRiskNodeId: dashboard.biggestTimeoutRiskNodeId,
    biggestPressureRiskNodeId: dashboard.biggestPressureRiskNodeId,
    extendedRunMetrics,
    dashboard,
    metricsAvailability: reports[0]?.metricsAvailability ?? [],
    determinismNotes: [
      "Each iteration reruns the deterministic scripted simulator from the same content baseline.",
      "Seed identifiers are stable evidence labels for repeated batches; they do not introduce random gameplay variation.",
      "The extended batch is a deterministic repeatability check, not a stochastic sample or statistical population.",
      "Repeated identical signals improve regression confidence in the tooling layer, but they are not human playtest feedback."
    ]
  };
}

function buildIterationSummary(report: ScenarioLabReport, iteration: number, seed: string): ScenarioLabIterationSummary {
  const watchpointActions: Partial<Record<ScenarioLabWatchpointId, ScenarioLabAction>> = {};
  report.watchpoints.forEach((watchpoint) => {
    watchpointActions[watchpoint.watchpointId] = watchpoint.action;
  });
  return {
    iteration,
    seedId: seedFor(seed, iteration),
    sourceRunCount: report.sourceRunCount,
    derivedMetricCount: report.runMetrics.length,
    strongestProfileId: report.strongestProfileId,
    weakestProfileId: report.weakestProfileId,
    fastestProfileId: report.fastestProfileId,
    mostFailureProneProfileId: report.mostFailureProneProfileId,
    watchpointActions
  };
}

function summarizeProfileComparisons(
  reports: ScenarioLabReport[],
  metrics: ScenarioLabExtendedRunMetric[]
): ScenarioLabProfileComparison[] {
  const profileOrder = reports[0]?.profiles.map((profile) => ({ id: profile.profileId, name: profile.profileName })) ?? [];
  return profileOrder.map((profile) => {
    const profileMetrics = metrics.filter((metric) => metric.profileId === profile.id);
    const record = recordFor(profileMetrics);
    const clearTimes = profileMetrics.map((metric) => metric.clearTimeSeconds);
    const routeVerdicts = reports
      .map((report) => report.profiles.find((entry) => entry.profileId === profile.id)?.routeVerdict)
      .filter((value): value is string => Boolean(value));
    const confidences = reports
      .map((report) => report.profiles.find((entry) => entry.profileId === profile.id)?.confidence)
      .filter((value): value is ScenarioLabConfidence => Boolean(value));
    const objectiveCompletionCount = profileMetrics.filter((metric) => metric.primaryObjectiveCompleted).length;

    return {
      profileId: profile.id,
      profileName: profile.name,
      iterationsObserved: uniqueValues(profileMetrics.map((metric) => metric.iteration)).length,
      totalRuns: profileMetrics.length,
      record,
      winRate: divide(record.wins, profileMetrics.length),
      lossRate: divide(record.defeats, profileMetrics.length),
      timeoutRate: divide(record.timeouts, profileMetrics.length),
      medianClearTimeSeconds: median(clearTimes),
      averageClearTimeSeconds: average(clearTimes),
      fastestClearTimeSeconds: minOrZero(clearTimes),
      slowestClearTimeSeconds: maxOrZero(clearTimes),
      clearTimeSpreadSeconds: maxOrZero(clearTimes) - minOrZero(clearTimes),
      averageUnitLosses: average(profileMetrics.map((metric) => metric.unitLosses)),
      averageFinalArmySize: average(profileMetrics.map((metric) => metric.armySurvivalCount)),
      averageResourceSurplus: average(profileMetrics.map((metric) => metric.resourceSurplus)),
      averageFinalAether: average(profileMetrics.map((metric) => metric.finalAether)),
      objectiveCompletionRate: divide(objectiveCompletionCount, profileMetrics.length),
      averageObjectiveCompletionCount: average(profileMetrics.map((metric) => metric.objectiveCompletionCount)),
      pressureWarningCount: profileMetrics.reduce((total, metric) => total + metric.pressureWarningCount, 0),
      averagePressureReactionWindowSeconds: nullableAverage(profileMetrics.map((metric) => metric.pressureReactionWindowSeconds)),
      routeVerdictDistribution: distribution(routeVerdicts),
      confidenceDistribution: distribution(confidences),
      stabilityVerdict: profileStabilityVerdict(record, profileMetrics.length)
    };
  });
}

function summarizeProfileNodeScriptComparisons(metrics: ScenarioLabExtendedRunMetric[]): ScenarioLabProfileNodeScriptComparison[] {
  const groups = groupBy(metrics, (metric) => `${metric.profileId}|${metric.nodeId}|${metric.playerScript}`);
  return Object.values(groups)
    .map((group) => {
      const first = group[0];
      const record = recordFor(group);
      return {
        profileId: first.profileId,
        profileName: first.profileName,
        nodeId: first.nodeId,
        nodeName: first.nodeName,
        playerScript: first.playerScript,
        totalRuns: group.length,
        record,
        winRate: divide(record.wins, group.length),
        timeoutRate: divide(record.timeouts, group.length),
        lossRate: divide(record.defeats, group.length),
        averageClearTimeSeconds: average(group.map((metric) => metric.clearTimeSeconds)),
        averageUnitLosses: average(group.map((metric) => metric.unitLosses)),
        averageResourceSurplus: average(group.map((metric) => metric.resourceSurplus)),
        pressureWarningCount: group.reduce((total, metric) => total + metric.pressureWarningCount, 0)
      };
    })
    .sort((left, right) => left.profileName.localeCompare(right.profileName) || left.nodeName.localeCompare(right.nodeName));
}

function summarizeNodeRiskDashboard(metrics: ScenarioLabExtendedRunMetric[]): ScenarioLabNodeRiskDashboardEntry[] {
  return uniqueValues(metrics.map((metric) => metric.nodeId)).map((nodeId) => {
    const nodeMetrics = metrics.filter((metric) => metric.nodeId === nodeId);
    const record = recordFor(nodeMetrics);
    const greedyMetrics = nodeMetrics.filter((metric) => metric.profileId === "greedy_economy");
    const fastMetrics = nodeMetrics.filter((metric) => metric.profileId === "fast_army");
    const retinueMetrics = nodeMetrics.filter((metric) => metric.profileId === "retinue_training_yard_ii");
    const pressureIgnoringMetrics = nodeMetrics.filter((metric) => metric.profileId === "pressure_ignoring");
    const noRetinueMetrics = nodeMetrics.filter((metric) => metric.profileId === "no_retinue");
    const timeoutRate = divide(record.timeouts, nodeMetrics.length);
    const lossRate = divide(record.defeats, nodeMetrics.length);
    const pressureWarningCount = nodeMetrics.reduce((total, metric) => total + metric.pressureWarningCount, 0);
    const status = nodeStatus(timeoutRate, lossRate, pressureWarningCount);
    return {
      nodeId,
      nodeName: nodeMetrics[0]?.nodeName ?? nodeId,
      totalRuns: nodeMetrics.length,
      record,
      winRate: divide(record.wins, nodeMetrics.length),
      timeoutRate,
      lossRate,
      averageUnitLosses: average(nodeMetrics.map((metric) => metric.unitLosses)),
      pressureWarningCount,
      greedyEconomyRecord: recordFor(greedyMetrics),
      fastArmyRecord: recordFor(fastMetrics),
      retinueTrainingYardRecord: recordFor(retinueMetrics),
      pressureIgnoringRecord: recordFor(pressureIgnoringMetrics),
      retinueAdvantageScore: retinueAdvantage(retinueMetrics, noRetinueMetrics),
      status,
      verdict: nodeVerdict(status, timeoutRate, lossRate, pressureWarningCount)
    };
  });
}

function buildBalanceRegressionDashboard(input: {
  generatedAt: string;
  buildCommit: string;
  batchLabel: string;
  iterationCount: number;
  seed: string;
  profileComparisons: ScenarioLabProfileComparison[];
  nodeRiskDashboard: ScenarioLabNodeRiskDashboardEntry[];
  watchpointRegressions: ScenarioLabWatchpointRegression[];
}): ScenarioLabBalanceRegressionDashboard {
  const profileRanking = [...input.profileComparisons].sort(profileRankSort);
  const nodeRiskTable = [...input.nodeRiskDashboard].sort(nodeRiskSort);
  const topMonitorItems = input.watchpointRegressions
    .filter((watchpoint) => watchpoint.status !== "OK")
    .sort(watchpointStatusSort)
    .slice(0, 5);
  const biggestTimeoutRisk = [...input.nodeRiskDashboard].sort((left, right) => right.timeoutRate - left.timeoutRate)[0];
  const biggestPressureRisk = [...input.nodeRiskDashboard].sort((left, right) => right.pressureWarningCount - left.pressureWarningCount)[0];
  return {
    schemaVersion: 1,
    generatedAt: input.generatedAt,
    buildCommit: input.buildCommit,
    batchLabel: input.batchLabel,
    iterationCount: input.iterationCount,
    seed: input.seed,
    strongestProfileId: profileRanking[0]?.profileId ?? null,
    weakestProfileId: [...input.profileComparisons].sort((left, right) => {
      const leftFailures = left.lossRate + left.timeoutRate;
      const rightFailures = right.lossRate + right.timeoutRate;
      return rightFailures - leftFailures || left.winRate - right.winRate;
    })[0]?.profileId ?? null,
    biggestTimeoutRiskNodeId: biggestTimeoutRisk?.nodeId ?? null,
    biggestPressureRiskNodeId: biggestPressureRisk?.nodeId ?? null,
    topMonitorItems,
    profileRanking,
    watchpointStatuses: input.watchpointRegressions,
    nodeRiskTable,
    noTuneReasons: [
      "The extended batch repeats deterministic simulator evidence; it is stronger regression evidence, not human feedback.",
      "No watchpoint combines repeated automated signals with real human confirmation.",
      "Pressure-warning noticeability, route feel, and fun remain unavailable to automation.",
      "Most current signals are monitor or human-testing outcomes rather than numeric-tuning outcomes."
    ],
    humanTestingRecommendations: [
      "Retinue + Training Yard II through Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch.",
      "Greedy Economy with explicit notes on resource-to-army conversion timing.",
      "Fast Army through Cinderfen to judge decisive play versus trivialization.",
      "Pressure warning noticeability under real combat stress.",
      "Ashen Outpost pacing and final-assault readability."
    ]
  };
}

function profileStabilityVerdict(record: ScenarioLabRecord, totalRuns: number): string {
  const failureRate = divide(record.defeats + record.timeouts, totalRuns);
  if (failureRate === 0) {
    return "consistent stable";
  }
  if (failureRate < 0.15) {
    return "mostly stable";
  }
  if (failureRate < 0.45) {
    return "mixed route";
  }
  return "unstable route";
}

function nodeStatus(timeoutRate: number, lossRate: number, pressureWarningCount: number): ScenarioLabRegressionStatus {
  if (lossRate >= 0.35) {
    return "Warning";
  }
  if (timeoutRate >= 0.35) {
    return "Monitor";
  }
  if (pressureWarningCount > 0) {
    return "Monitor";
  }
  return "OK";
}

function nodeVerdict(status: ScenarioLabRegressionStatus, timeoutRate: number, lossRate: number, pressureWarningCount: number): string {
  if (status === "Warning") {
    return `loss-risk node (${formatPercent(lossRate)} defeat rate)`;
  }
  if (timeoutRate >= 0.35) {
    return `timeout-risk node (${formatPercent(timeoutRate)} timeout rate)`;
  }
  if (pressureWarningCount > 0) {
    return "pressure-watch node";
  }
  return "structurally stable";
}

function retinueAdvantage(retinueMetrics: ScenarioLabExtendedRunMetric[], baselineMetrics: ScenarioLabExtendedRunMetric[]): number {
  if (retinueMetrics.length === 0 || baselineMetrics.length === 0) {
    return 0;
  }
  const retinueRecord = recordFor(retinueMetrics);
  const baselineRecord = recordFor(baselineMetrics);
  const winDelta = divide(retinueRecord.wins, retinueMetrics.length) - divide(baselineRecord.wins, baselineMetrics.length);
  const clearDelta = average(baselineMetrics.map((metric) => metric.clearTimeSeconds)) - average(retinueMetrics.map((metric) => metric.clearTimeSeconds));
  const lossDelta = average(baselineMetrics.map((metric) => metric.unitLosses)) - average(retinueMetrics.map((metric) => metric.unitLosses));
  return winDelta * 100 + clearDelta / 10 + lossDelta * 5;
}

function profileRankSort(left: ScenarioLabProfileComparison, right: ScenarioLabProfileComparison): number {
  return right.winRate - left.winRate || left.timeoutRate - right.timeoutRate || left.averageUnitLosses - right.averageUnitLosses;
}

function nodeRiskSort(left: ScenarioLabNodeRiskDashboardEntry, right: ScenarioLabNodeRiskDashboardEntry): number {
  return right.lossRate + right.timeoutRate - (left.lossRate + left.timeoutRate) || right.averageUnitLosses - left.averageUnitLosses;
}

function watchpointStatusSort(left: ScenarioLabWatchpointRegression, right: ScenarioLabWatchpointRegression): number {
  return statusWeight(right.status) - statusWeight(left.status) || left.watchpointName.localeCompare(right.watchpointName);
}

function statusWeight(status: ScenarioLabRegressionStatus): number {
  if (status === "Strong signal" || status === "Future systems pass") {
    return 5;
  }
  if (status === "Warning") {
    return 4;
  }
  if (status === "Human testing required") {
    return 3;
  }
  if (status === "Monitor") {
    return 2;
  }
  return 1;
}

function mostFrequentProfile(values: Array<ScenarioLabProfileId | null>): ScenarioLabProfileId | null {
  const counts = new Map<ScenarioLabProfileId, number>();
  values.forEach((value) => {
    if (value) {
      counts.set(value, (counts.get(value) ?? 0) + 1);
    }
  });
  return [...counts.entries()].sort((left, right) => right[1] - left[1])[0]?.[0] ?? null;
}

function normalizeIterationCount(iterations: number | undefined): number {
  if (iterations === undefined || !Number.isFinite(iterations)) {
    return DEFAULT_SCENARIO_LAB_EXTENDED_ITERATIONS;
  }
  return Math.max(1, Math.min(25, Math.floor(iterations)));
}

function seedFor(seed: string, iteration: number): string {
  return `${seed}-iteration-${iteration}`;
}

function recordFor(metrics: ScenarioLabExtendedRunMetric[]): ScenarioLabRecord {
  return {
    wins: metrics.filter((metric) => metric.result === "victory").length,
    defeats: metrics.filter((metric) => metric.result === "defeat").length,
    timeouts: metrics.filter((metric) => metric.result === "timeout").length
  };
}

function distribution<T extends string>(values: T[]): ScenarioLabDistribution<T>[] {
  const counts = new Map<T, number>();
  values.forEach((value) => counts.set(value, (counts.get(value) ?? 0) + 1));
  return [...counts.entries()].map(([value, count]) => ({ value, count }));
}

function groupBy<T>(values: T[], keyFor: (value: T) => string): Record<string, T[]> {
  return values.reduce<Record<string, T[]>>((groups, value) => {
    const key = keyFor(value);
    groups[key] = groups[key] ?? [];
    groups[key].push(value);
    return groups;
  }, {});
}

function uniqueValues<T>(values: T[]): T[] {
  return [...new Set(values)];
}

function average(values: number[]): number {
  if (values.length === 0) {
    return 0;
  }
  return values.reduce((total, value) => total + value, 0) / values.length;
}

function nullableAverage(values: Array<number | null>): number | null {
  const numeric = values.filter((value): value is number => value !== null && Number.isFinite(value));
  return numeric.length > 0 ? average(numeric) : null;
}

function median(values: number[]): number {
  if (values.length === 0) {
    return 0;
  }
  const sorted = [...values].sort((left, right) => left - right);
  const middle = Math.floor(sorted.length / 2);
  return sorted.length % 2 === 0 ? (sorted[middle - 1] + sorted[middle]) / 2 : sorted[middle];
}

function minOrZero(values: number[]): number {
  return values.length > 0 ? Math.min(...values) : 0;
}

function maxOrZero(values: number[]): number {
  return values.length > 0 ? Math.max(...values) : 0;
}

function divide(numerator: number, denominator: number): number {
  return denominator > 0 ? numerator / denominator : 0;
}

function formatPercent(value: number): string {
  return `${Math.round(value * 100)}%`;
}

function derivedMetricFingerprint(metric: ScenarioLabExtendedRunMetric): string {
  return [
    metric.profileId,
    metric.sourceStrongholdProfileId,
    metric.playerScript,
    metric.nodeId,
    metric.result,
    metric.failureReason,
    metric.clearTimeSeconds,
    metric.armySurvivalCount,
    metric.unitLosses,
    metric.unitsTrained,
    metric.resourceSurplus,
    metric.finalAether,
    metric.peakAether,
    metric.objectiveCompletionCount,
    metric.primaryObjectiveCompleted,
    metric.pressureWarningCount,
    metric.pressureTriggered,
    metric.pressureReactionWindowSeconds ?? "null",
    metric.firstWaveSurvived,
    metric.lossesAfterPressure,
    metric.retinueUsed,
    metric.trainingYardIIActive,
    metric.greedyEconomyMarker,
    metric.fastArmyMarker
  ].join("|");
}
