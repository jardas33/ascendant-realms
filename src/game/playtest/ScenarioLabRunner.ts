import { runScriptedPlaytestSuite } from "./PlaytestRunner";
import type { PlaytestReport, PlaytestTelemetry } from "./PlaytestTypes";
import { SCENARIO_LAB_PROFILES } from "./ScenarioLabProfiles";
import { classifyScenarioLabWatchpoints } from "./ScenarioLabClassifier";
import type {
  ScenarioLabFailureReason,
  ScenarioLabMetricAvailability,
  ScenarioLabNodeRiskSummary,
  ScenarioLabProfileDefinition,
  ScenarioLabProfileId,
  ScenarioLabProfileSummary,
  ScenarioLabRecord,
  ScenarioLabReport,
  ScenarioLabRunMetric
} from "./ScenarioLabTypes";

export function runScenarioLab(sourceReport: PlaytestReport = runScriptedPlaytestSuite()): ScenarioLabReport {
  const runMetrics = SCENARIO_LAB_PROFILES.flatMap((profile) => {
    return selectRunsForProfile(sourceReport.telemetry, profile).map((run) => buildRunMetric(profile, run));
  });
  const profiles = SCENARIO_LAB_PROFILES.map((profile) => summarizeProfile(profile, runMetrics));
  const nodeRiskSummaries = summarizeNodeRisks(sourceReport.telemetry);
  const watchpoints = classifyScenarioLabWatchpoints({ profileSummaries: profiles, sourceRuns: sourceReport.telemetry });
  return {
    schemaVersion: 1,
    generatedBy: "Ascendant Realms automated playtest scenario lab v1",
    sourceReportSchemaVersion: sourceReport.schemaVersion,
    sourceRunCount: sourceReport.telemetry.length,
    profiles,
    runMetrics,
    nodeRiskSummaries,
    watchpoints,
    strongestProfileId: profileByStrength(profiles)?.profileId ?? null,
    weakestProfileId: profileByWeakness(profiles)?.profileId ?? null,
    fastestProfileId: profileBySpeed(profiles)?.profileId ?? null,
    mostFailureProneProfileId: profileByFailure(profiles)?.profileId ?? null,
    metricsAvailability: buildMetricAvailability()
  };
}

function selectRunsForProfile(runs: PlaytestTelemetry[], profile: ScenarioLabProfileDefinition): PlaytestTelemetry[] {
  return runs.filter((run) => {
    return (
      profile.preferredStrongholdProfileIds.includes(run.strongholdProfileId) &&
      profile.scriptIds.includes(run.playerScript) &&
      profile.nodeIds.includes(run.nodeId)
    );
  });
}

function buildRunMetric(profile: ScenarioLabProfileDefinition, run: PlaytestTelemetry): ScenarioLabRunMetric {
  const failureReason = classifyFailureReason(run);
  return {
    profileId: profile.id,
    profileName: profile.name,
    sourceStrongholdProfileId: run.strongholdProfileId,
    sourceStrongholdProfileName: run.strongholdProfileName,
    playerScript: run.playerScript,
    nodeId: run.nodeId,
    nodeName: run.nodeName,
    result: run.battleResult,
    failureReason,
    likelyIssue: likelyIssueFor(failureReason),
    clearTimeSeconds: run.battleDurationSeconds,
    heroSurvivalState: "unavailable",
    armySurvivalCount: run.finalArmySize,
    unitLosses: run.unitsLost,
    unitsTrained: run.unitsTrained,
    resourceSurplus: resourceTotal(run.resourcesFloated),
    finalAether: run.resourcesFloated.aether,
    peakAether: run.peakResourcesFloated.aether,
    objectiveCompletionCount: run.objectiveCompletion.length,
    primaryObjectiveCompleted: run.objectiveCompletion.includes("destroy_enemy_stronghold"),
    pressureWarningCount: run.pressureWarningsShown,
    pressureTriggered: run.triggeredStages.length > 0,
    pressureReactionWindowSeconds: pressureReactionWindow(run),
    firstWaveSurvived: run.firstWaveSurvived,
    lossesAfterPressure: run.lossesAfterPressure,
    baseDamageState: "unavailable",
    retinueUsed: run.retinueUnits.length > 0,
    trainingYardIIActive: run.strongholdUpgradeIds.includes("training_yard_ii"),
    greedyEconomyMarker: run.playerScript === "greedy_economy" || profile.markers.greedyEconomy,
    fastArmyMarker: run.playerScript === "fast_army" || profile.markers.fastArmy
  };
}

function summarizeProfile(profile: ScenarioLabProfileDefinition, allMetrics: ScenarioLabRunMetric[]): ScenarioLabProfileSummary {
  const metrics = allMetrics.filter((metric) => metric.profileId === profile.id);
  const record = recordFor(metrics);
  const failures = createFailureReasonRecord();
  metrics.forEach((metric) => {
    failures[metric.failureReason] += 1;
  });
  const notes = buildProfileNotes(profile, metrics, failures);
  return {
    profileId: profile.id,
    profileName: profile.name,
    runCount: metrics.length,
    record,
    winRate: divide(record.wins, metrics.length),
    averageClearTimeSeconds: average(metrics.map((metric) => metric.clearTimeSeconds)),
    averageUnitLosses: average(metrics.map((metric) => metric.unitLosses)),
    averageFinalArmySize: average(metrics.map((metric) => metric.armySurvivalCount)),
    averageResourceSurplus: average(metrics.map((metric) => metric.resourceSurplus)),
    averageFinalAether: average(metrics.map((metric) => metric.finalAether)),
    pressureRunCount: metrics.filter((metric) => metric.pressureWarningCount > 0).length,
    pressureWarningCount: metrics.reduce((total, metric) => total + metric.pressureWarningCount, 0),
    averagePressureReactionWindowSeconds: nullableAverage(metrics.map((metric) => metric.pressureReactionWindowSeconds)),
    ashenOutpostRecord: recordFor(metrics.filter((metric) => metric.nodeId === "ashen_outpost")),
    cinderfenCrossingRecord: recordFor(metrics.filter((metric) => metric.nodeId === "cinderfen_crossing")),
    cinderfenWatchRecord: recordFor(metrics.filter((metric) => metric.nodeId === "cinderfen_watch")),
    failureReasons: failures,
    routeVerdict: routeVerdict(profile, metrics, failures),
    confidence: metrics.length >= 20 ? "high" : metrics.length >= 6 ? "medium" : "low",
    notes
  };
}

function summarizeNodeRisks(runs: PlaytestTelemetry[]): ScenarioLabNodeRiskSummary[] {
  return uniqueValues(runs.map((run) => run.nodeId)).map((nodeId) => {
    const nodeRuns = runs.filter((run) => run.nodeId === nodeId);
    const record = recordForRuns(nodeRuns);
    const timeoutCount = record.timeouts;
    const defeatCount = record.defeats;
    const averageUnitLosses = average(nodeRuns.map((run) => run.unitsLost));
    const pressureWarningCount = nodeRuns.reduce((total, run) => total + run.pressureWarningsShown, 0);
    return {
      nodeId,
      nodeName: nodeRuns[0]?.nodeName ?? nodeId,
      record,
      averageUnitLosses,
      timeoutCount,
      defeatCount,
      pressureWarningCount,
      verdict: nodeVerdict(record, averageUnitLosses, pressureWarningCount)
    };
  });
}

function classifyFailureReason(run: PlaytestTelemetry): ScenarioLabFailureReason {
  if (run.battleResult === "victory") {
    return "none";
  }
  if (run.battleResult === "defeat") {
    if (!run.firstWaveSurvived) {
      return "early_pressure_defeat";
    }
    if (run.lossesAfterPressure > 0) {
      return "pressure_attrition_defeat";
    }
    return "failed_assault_defeat";
  }
  if (run.battleResult === "timeout") {
    if (resourceTotal(run.peakResourcesFloated) >= 900 && run.unitsTrained <= 4) {
      return "conversion_timeout";
    }
    if (run.unitsLost >= 5 || run.lossesAfterPressure >= 3) {
      return "attrition_timeout";
    }
    if (!run.objectiveCompletion.includes("destroy_enemy_stronghold")) {
      return "clear_speed_timeout";
    }
    return "unknown_timeout";
  }
  return "none";
}

function likelyIssueFor(reason: ScenarioLabFailureReason): ScenarioLabRunMetric["likelyIssue"] {
  if (reason === "none") {
    return "none";
  }
  if (reason === "early_pressure_defeat") {
    return "balance";
  }
  if (reason === "conversion_timeout" || reason === "clear_speed_timeout") {
    return "pacing";
  }
  if (reason === "pressure_attrition_defeat" || reason === "attrition_timeout") {
    return "human_noticeability_unknown";
  }
  if (reason === "failed_assault_defeat") {
    return "pacing";
  }
  return "clarity";
}

function pressureReactionWindow(run: PlaytestTelemetry): number | null {
  if (run.firstPressureTime === null || run.timeFirstEnemyContact === null) {
    return null;
  }
  return run.timeFirstEnemyContact - run.firstPressureTime;
}

function routeVerdict(
  profile: ScenarioLabProfileDefinition,
  metrics: ScenarioLabRunMetric[],
  failures: Record<ScenarioLabFailureReason, number>
): string {
  if (metrics.length === 0) {
    return "No automated runs matched this profile.";
  }
  const record = recordFor(metrics);
  const failureCount = record.defeats + record.timeouts;
  const lowLossWins = metrics.filter((metric) => metric.result === "victory" && metric.unitLosses <= 1).length;
  if (record.wins === metrics.length && lowLossWins === metrics.length && profile.id === "retinue_training_yard_ii") {
    return "too-clean watchpoint; needs human testing before any tuning";
  }
  if (profile.id === "greedy_economy" && failures.conversion_timeout + failures.clear_speed_timeout >= 10) {
    return "risky conversion route; monitor clarity and pacing";
  }
  if (profile.id === "fast_army" && failureCount > 0) {
    return "decisive but not free; monitor Cinderfen speed";
  }
  if (failureCount === 0) {
    return "stable";
  }
  if (record.wins > 0 && failureCount > 0) {
    return "strategy spread; needs human testing";
  }
  return "high risk";
}

function buildProfileNotes(
  profile: ScenarioLabProfileDefinition,
  metrics: ScenarioLabRunMetric[],
  failures: Record<ScenarioLabFailureReason, number>
): string[] {
  const notes: string[] = [];
  if (metrics.length === 0) {
    return ["No matching automated telemetry rows."];
  }
  if (profile.markers.trainingYardIIActive) {
    notes.push("Includes Training Yard II / retinue stacking marker.");
  }
  if (profile.markers.greedyEconomy) {
    notes.push("Greedy marker: high surplus with timeouts should be treated as conversion/pacing evidence before buffing economy.");
  }
  if (profile.markers.fastArmy) {
    notes.push("Fast marker: speed is expected; only broad invalidation should become a tuning candidate.");
  }
  if (failures.early_pressure_defeat === 0) {
    notes.push("No repeated early-pressure defeat signal in this profile.");
  }
  if (metrics.some((metric) => metric.pressureWarningCount > 0)) {
    notes.push("Pressure warnings are represented, but human noticeability remains unknown.");
  }
  return notes;
}

function nodeVerdict(record: ScenarioLabRecord, averageUnitLosses: number, pressureWarningCount: number): string {
  if (record.wins === 0) {
    return "high risk";
  }
  if (record.defeats > record.wins) {
    return "defeat-prone";
  }
  if (record.timeouts > record.wins) {
    return "timeout-prone";
  }
  if (averageUnitLosses <= 1 && record.timeouts === 0 && record.defeats === 0) {
    return "stable";
  }
  if (pressureWarningCount > 0) {
    return "pressure watch";
  }
  return "mixed";
}

function buildMetricAvailability(): ScenarioLabMetricAvailability[] {
  return [
    { metric: "win/loss/timeout", status: "available", note: "Read directly from scripted telemetry." },
    { metric: "battle node/profile/script", status: "available", note: "Read directly from scripted telemetry." },
    { metric: "clear time", status: "available", note: "Uses battleDurationSeconds." },
    { metric: "army survival and unit losses", status: "available", note: "Uses finalArmySize and unitsLost." },
    { metric: "resource surplus and Aether state", status: "available", note: "Uses resourcesFloated and peakResourcesFloated." },
    { metric: "objective completion", status: "available", note: "Uses objectiveCompletion ids; full timing/order is not available." },
    { metric: "pressure warning count", status: "available", note: "Uses pressureWarningsShown and triggeredStages." },
    { metric: "pressure reaction window", status: "derived", note: "Derived from firstPressureTime to first enemy contact when both exist." },
    { metric: "retinue / Training Yard II / route markers", status: "derived", note: "Retinue and Training Yard II are derived from source telemetry; behavior markers are derived from scripts and route definitions." },
    { metric: "hero survival / final hero HP", status: "unavailable", note: "Current telemetry tracks hero level and XP, not final HP or death." },
    { metric: "base damage", status: "unavailable", note: "Current telemetry tracks base collapse/defeat notes, not base HP damage." },
    { metric: "human noticeability", status: "unavailable", note: "Automated runs cannot prove whether a human noticed a warning." }
  ];
}

function createFailureReasonRecord(): Record<ScenarioLabFailureReason, number> {
  return {
    none: 0,
    early_pressure_defeat: 0,
    pressure_attrition_defeat: 0,
    failed_assault_defeat: 0,
    conversion_timeout: 0,
    attrition_timeout: 0,
    clear_speed_timeout: 0,
    unknown_timeout: 0
  };
}

function profileByStrength(profiles: ScenarioLabProfileSummary[]): ScenarioLabProfileSummary | undefined {
  const retinueTrainingYard = profiles.find((profile) => {
    return (
      profile.profileId === "retinue_training_yard_ii" &&
      profile.ashenOutpostRecord.defeats + profile.ashenOutpostRecord.timeouts === 0 &&
      profile.cinderfenCrossingRecord.defeats + profile.cinderfenCrossingRecord.timeouts === 0 &&
      profile.cinderfenWatchRecord.defeats + profile.cinderfenWatchRecord.timeouts === 0
    );
  });
  if (retinueTrainingYard) {
    return retinueTrainingYard;
  }
  return [...profiles].sort((left, right) => {
    const winDelta = right.winRate - left.winRate;
    if (winDelta !== 0) {
      return winDelta;
    }
    return left.averageUnitLosses - right.averageUnitLosses;
  })[0];
}

function profileByWeakness(profiles: ScenarioLabProfileSummary[]): ScenarioLabProfileSummary | undefined {
  return [...profiles].sort((left, right) => {
    const leftFailures = left.record.defeats + left.record.timeouts;
    const rightFailures = right.record.defeats + right.record.timeouts;
    if (rightFailures !== leftFailures) {
      return rightFailures - leftFailures;
    }
    return left.winRate - right.winRate;
  })[0];
}

function profileBySpeed(profiles: ScenarioLabProfileSummary[]): ScenarioLabProfileSummary | undefined {
  return profiles
    .filter((profile) => profile.record.wins > 0)
    .sort((left, right) => left.averageClearTimeSeconds - right.averageClearTimeSeconds)[0];
}

function profileByFailure(profiles: ScenarioLabProfileSummary[]): ScenarioLabProfileSummary | undefined {
  return profileByWeakness(profiles);
}

function recordFor(metrics: ScenarioLabRunMetric[]): ScenarioLabRecord {
  return {
    wins: metrics.filter((metric) => metric.result === "victory").length,
    defeats: metrics.filter((metric) => metric.result === "defeat").length,
    timeouts: metrics.filter((metric) => metric.result === "timeout").length
  };
}

function recordForRuns(runs: PlaytestTelemetry[]): ScenarioLabRecord {
  return {
    wins: runs.filter((run) => run.battleResult === "victory").length,
    defeats: runs.filter((run) => run.battleResult === "defeat").length,
    timeouts: runs.filter((run) => run.battleResult === "timeout").length
  };
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

function divide(numerator: number, denominator: number): number {
  return denominator > 0 ? numerator / denominator : 0;
}

function resourceTotal(resources: Partial<Record<"crowns" | "stone" | "iron" | "aether", number>>): number {
  return (resources.crowns ?? 0) + (resources.stone ?? 0) + (resources.iron ?? 0) + (resources.aether ?? 0);
}

function uniqueValues<T>(values: T[]): T[] {
  return [...new Set(values)];
}
