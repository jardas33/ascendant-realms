import { SCENARIO_LAB_PROFILES } from "./ScenarioLabProfiles";
import type {
  ScenarioLabExtendedReport,
  ScenarioLabNodeRiskDashboardEntry,
  ScenarioLabProfileComparison,
  ScenarioLabWatchpointId
} from "./ScenarioLabTypes";

export interface ScenarioLabOutputArtifacts {
  extendedJson: string;
  extendedMarkdown: string;
  profileComparisonMarkdown: string;
  profileComparisonCsv: string;
  dashboardJson: string;
  dashboardMarkdown: string;
  watchpointsMarkdown: string;
}

export interface ScenarioLabOutputValidationOptions {
  expectedIterationCount?: number;
}

export interface ScenarioLabOutputValidationResult {
  ok: boolean;
  checks: string[];
  errors: string[];
}

const REQUIRED_EXTENDED_WATCHPOINTS: ScenarioLabWatchpointId[] = [
  "retinue_training_yard_ii",
  "greedy_economy",
  "fast_army",
  "early_defeats",
  "pressure_fairness",
  "cinderfen_crossing_fairness",
  "cinderfen_watch_fairness",
  "ashen_outpost_stability",
  "objective_completion_drop",
  "resource_starvation_spike"
];

const FORBIDDEN_HUMAN_FEEDBACK_CLAIMS = [
  "tester said",
  "completed tester forms",
  "human feedback was used",
  "human feedback used: yes",
  "real human feedback confirmed"
];

export function validateScenarioLabOutputArtifacts(
  artifacts: ScenarioLabOutputArtifacts,
  options: ScenarioLabOutputValidationOptions = {}
): ScenarioLabOutputValidationResult {
  const checks: string[] = [];
  const errors: string[] = [];
  const expectedIterationCount = options.expectedIterationCount ?? 5;
  const report = parseJson<ScenarioLabExtendedReport>(artifacts.extendedJson, "PLAYTEST_SCENARIO_LAB_EXTENDED.json", errors);
  const dashboard = parseJson<ScenarioLabExtendedReport["dashboard"]>(
    artifacts.dashboardJson,
    "PLAYTEST_BALANCE_REGRESSION_DASHBOARD.json",
    errors
  );

  if (!report || !dashboard) {
    return { ok: false, checks, errors };
  }

  expectEqual(report.schemaVersion, 1, "extended report schema version", checks, errors);
  expectEqual(dashboard.schemaVersion, 1, "dashboard schema version", checks, errors);
  expectEqual(report.iterationCount, expectedIterationCount, "extended iteration count", checks, errors);
  expectEqual(report.iterationSummaries.length, report.iterationCount, "iteration summary count", checks, errors);
  expectEqual(report.totalSourceRuns, sum(report.iterationSummaries.map((summary) => summary.sourceRunCount)), "source run total", checks, errors);
  expectEqual(
    report.totalDerivedMetrics,
    sum(report.iterationSummaries.map((summary) => summary.derivedMetricCount)),
    "derived metric total from iterations",
    checks,
    errors
  );
  expectEqual(report.extendedRunMetrics.length, report.totalDerivedMetrics, "extended metric row count", checks, errors);
  expectEqual(
    report.totalSourceRuns,
    report.sourceRunCountPerIteration * report.iterationCount,
    "source runs per iteration x iteration count",
    checks,
    errors
  );

  const computedFingerprints = uniqueValues(report.extendedRunMetrics.map(derivedMetricFingerprint)).length;
  expectEqual(report.uniqueDerivedMetricFingerprints, computedFingerprints, "unique deterministic metric fingerprint count", checks, errors);
  expectEqual(
    report.uniqueDerivedMetricFingerprints,
    report.totalDerivedMetrics / report.iterationCount,
    "deterministic repeated metric fingerprint count",
    checks,
    errors
  );

  const profileIds = new Set(report.profileComparisons.map((profile) => profile.profileId));
  SCENARIO_LAB_PROFILES.forEach((profile) => {
    if (profileIds.has(profile.id)) {
      checks.push(`profile present: ${profile.id}`);
    } else {
      errors.push(`Missing profile comparison for ${profile.id}.`);
    }
    if (report.extendedRunMetrics.some((metric) => metric.profileId === profile.id)) {
      checks.push(`profile has metrics: ${profile.id}`);
    } else {
      errors.push(`Missing extended metrics for ${profile.id}.`);
    }
  });

  const reportWatchpoints = new Map(report.watchpointRegressions.map((watchpoint) => [watchpoint.watchpointId, watchpoint]));
  const dashboardWatchpoints = new Map(dashboard.watchpointStatuses.map((watchpoint) => [watchpoint.watchpointId, watchpoint]));
  REQUIRED_EXTENDED_WATCHPOINTS.forEach((watchpointId) => {
    const reportWatchpoint = reportWatchpoints.get(watchpointId);
    const dashboardWatchpoint = dashboardWatchpoints.get(watchpointId);
    if (!reportWatchpoint) {
      errors.push(`Missing extended watchpoint ${watchpointId}.`);
    } else if (!reportWatchpoint.status) {
      errors.push(`Watchpoint ${watchpointId} has no status.`);
    } else {
      checks.push(`watchpoint status present: ${watchpointId}`);
    }
    if (!dashboardWatchpoint) {
      errors.push(`Missing dashboard watchpoint ${watchpointId}.`);
    }
  });

  const rankedProfiles = [...report.profileComparisons].sort(profileRankSort);
  expectEqual(report.strongestProfileId, rankedProfiles[0]?.profileId ?? null, "strongest profile id", checks, errors);
  expectEqual(dashboard.strongestProfileId, report.strongestProfileId, "dashboard strongest profile id", checks, errors);
  expectEqual(report.weakestProfileId, weakestProfile(report.profileComparisons)?.profileId ?? null, "weakest profile id", checks, errors);
  expectEqual(dashboard.weakestProfileId, report.weakestProfileId, "dashboard weakest profile id", checks, errors);
  expectEqual(report.biggestTimeoutRiskNodeId, biggestTimeoutRisk(report.nodeRiskDashboard)?.nodeId ?? null, "biggest timeout node", checks, errors);
  expectEqual(dashboard.biggestTimeoutRiskNodeId, report.biggestTimeoutRiskNodeId, "dashboard biggest timeout node", checks, errors);
  expectEqual(report.biggestPressureRiskNodeId, biggestPressureRisk(report.nodeRiskDashboard)?.nodeId ?? null, "biggest pressure node", checks, errors);
  expectEqual(dashboard.biggestPressureRiskNodeId, report.biggestPressureRiskNodeId, "dashboard biggest pressure node", checks, errors);

  const rankedProfileNames = rankedProfiles.map((profile) => profile.profileName);
  const csvProfileNames = parseCsv(artifacts.profileComparisonCsv).slice(1).map((row) => row[1]);
  expectArrayEqual(csvProfileNames, rankedProfileNames, "CSV profile order matches computed ranking", checks, errors);
  const markdownProfileNames = parseFirstMarkdownProfileTable(artifacts.profileComparisonMarkdown);
  expectArrayEqual(markdownProfileNames, rankedProfileNames, "Markdown profile order matches computed ranking", checks, errors);
  expectMarkdownContains(artifacts.extendedMarkdown, `Iterations: ${report.iterationCount}`, "extended markdown iteration count", checks, errors);
  expectMarkdownContains(
    artifacts.extendedMarkdown,
    `Source runs: ${report.sourceRunCountPerIteration} per iteration, ${report.totalSourceRuns} total.`,
    "extended markdown source-run count",
    checks,
    errors
  );
  expectMarkdownContains(
    artifacts.extendedMarkdown,
    `Derived profile-run metrics: ${report.totalDerivedMetrics}.`,
    "extended markdown metric count",
    checks,
    errors
  );
  expectMarkdownContains(
    artifacts.extendedMarkdown,
    `Unique deterministic metric fingerprints: ${report.uniqueDerivedMetricFingerprints}.`,
    "extended markdown deterministic fingerprint count",
    checks,
    errors
  );
  expectMarkdownContains(
    artifacts.dashboardMarkdown,
    `Strongest automated route: ${profileName(report, dashboard.strongestProfileId)}.`,
    "dashboard markdown strongest profile",
    checks,
    errors
  );
  expectMarkdownContains(
    artifacts.dashboardMarkdown,
    `Weakest automated route: ${profileName(report, dashboard.weakestProfileId)}.`,
    "dashboard markdown weakest profile",
    checks,
    errors
  );
  expectMarkdownContains(
    artifacts.dashboardMarkdown,
    `Biggest timeout risk: ${nodeName(report, dashboard.biggestTimeoutRiskNodeId)}.`,
    "dashboard markdown timeout node",
    checks,
    errors
  );
  expectMarkdownContains(
    artifacts.dashboardMarkdown,
    `Biggest pressure-risk signal: ${nodeName(report, dashboard.biggestPressureRiskNodeId)}.`,
    "dashboard markdown pressure node",
    checks,
    errors
  );

  const metricsAvailability = Array.isArray(report.metricsAvailability) ? report.metricsAvailability : [];
  if (metricsAvailability.length === 0) {
    errors.push("Extended report is missing metricsAvailability entries.");
  }
  const unavailableMetrics = metricsAvailability.filter((metric) => metric.status === "unavailable").map((metric) => metric.metric);
  ["hero survival / final hero HP", "base damage", "human noticeability"].forEach((metricName) => {
    if (unavailableMetrics.includes(metricName)) {
      checks.push(`unavailable metric declared: ${metricName}`);
    } else {
      errors.push(`Unavailable metric not declared: ${metricName}.`);
    }
  });
  if (report.extendedRunMetrics.every((metric) => metric.heroSurvivalState === "unavailable" && metric.baseDamageState === "unavailable")) {
    checks.push("unavailable hero/base metrics remain marked unavailable");
  } else {
    errors.push("At least one extended row treats hero/base metrics as measured.");
  }

  Object.entries(artifacts).forEach(([name, content]) => {
    const lower = content.toLowerCase();
    FORBIDDEN_HUMAN_FEEDBACK_CLAIMS.forEach((phrase) => {
      if (lower.includes(phrase)) {
        errors.push(`${name} contains forbidden human-feedback claim phrase: ${phrase}`);
      }
    });
  });
  checks.push("generated outputs avoid forbidden human-feedback claim phrases");

  return { ok: errors.length === 0, checks, errors };
}

export function assertScenarioLabOutputArtifacts(
  artifacts: ScenarioLabOutputArtifacts,
  options: ScenarioLabOutputValidationOptions = {}
): ScenarioLabOutputValidationResult {
  const result = validateScenarioLabOutputArtifacts(artifacts, options);
  if (!result.ok) {
    throw new Error(`Scenario lab output validation failed:\n${result.errors.map((error) => `- ${error}`).join("\n")}`);
  }
  return result;
}

function parseJson<T>(content: string, label: string, errors: string[]): T | null {
  try {
    return JSON.parse(content) as T;
  } catch (error) {
    errors.push(`${label} is not valid JSON: ${String(error)}`);
    return null;
  }
}

function profileRankSort(left: ScenarioLabProfileComparison, right: ScenarioLabProfileComparison): number {
  return right.winRate - left.winRate || left.timeoutRate - right.timeoutRate || left.averageUnitLosses - right.averageUnitLosses;
}

function weakestProfile(profiles: ScenarioLabProfileComparison[]): ScenarioLabProfileComparison | undefined {
  return [...profiles].sort((left, right) => {
    const leftFailures = left.lossRate + left.timeoutRate;
    const rightFailures = right.lossRate + right.timeoutRate;
    return rightFailures - leftFailures || left.winRate - right.winRate;
  })[0];
}

function biggestTimeoutRisk(nodes: ScenarioLabNodeRiskDashboardEntry[]): ScenarioLabNodeRiskDashboardEntry | undefined {
  return [...nodes].sort((left, right) => right.timeoutRate - left.timeoutRate)[0];
}

function biggestPressureRisk(nodes: ScenarioLabNodeRiskDashboardEntry[]): ScenarioLabNodeRiskDashboardEntry | undefined {
  return [...nodes].sort((left, right) => right.pressureWarningCount - left.pressureWarningCount)[0];
}

function parseFirstMarkdownProfileTable(markdown: string): string[] {
  const lines = markdown.split(/\r?\n/u);
  const start = lines.findIndex((line) => line.trim() === "## Profile Ranking");
  if (start < 0) {
    return [];
  }
  const rows: string[] = [];
  for (let index = start + 1; index < lines.length; index += 1) {
    const line = lines[index].trim();
    if (!line) {
      if (rows.length > 0) {
        break;
      }
      continue;
    }
    if (!line.startsWith("|") || line.includes("---") || line.includes("| Profile |")) {
      continue;
    }
    const cells = line
      .slice(1, -1)
      .split("|")
      .map((cell) => cell.trim());
    rows.push(cells[0]);
  }
  return rows;
}

function parseCsv(csv: string): string[][] {
  return csv
    .trim()
    .split(/\r?\n/u)
    .filter(Boolean)
    .map((line) => {
      const cells: string[] = [];
      let current = "";
      let quoted = false;
      for (let index = 0; index < line.length; index += 1) {
        const character = line[index];
        if (character === "\"" && line[index + 1] === "\"") {
          current += "\"";
          index += 1;
        } else if (character === "\"") {
          quoted = !quoted;
        } else if (character === "," && !quoted) {
          cells.push(current);
          current = "";
        } else {
          current += character;
        }
      }
      cells.push(current);
      return cells;
    });
}

function expectEqual<T>(actual: T, expected: T, label: string, checks: string[], errors: string[]): void {
  if (Object.is(actual, expected)) {
    checks.push(`${label}: ${String(actual)}`);
  } else {
    errors.push(`${label} mismatch: expected ${String(expected)}, got ${String(actual)}.`);
  }
}

function expectArrayEqual(actual: string[], expected: string[], label: string, checks: string[], errors: string[]): void {
  const sameLength = actual.length === expected.length;
  const sameValues = sameLength && actual.every((value, index) => value === expected[index]);
  if (sameValues) {
    checks.push(label);
  } else {
    errors.push(`${label} mismatch: expected [${expected.join(", ")}], got [${actual.join(", ")}].`);
  }
}

function expectMarkdownContains(markdown: string, text: string, label: string, checks: string[], errors: string[]): void {
  if (markdown.includes(text)) {
    checks.push(label);
  } else {
    errors.push(`${label} missing expected text: ${text}`);
  }
}

function profileName(report: ScenarioLabExtendedReport, profileId: string | null): string {
  if (!profileId) {
    return "none";
  }
  return report.profileComparisons.find((profile) => profile.profileId === profileId)?.profileName ?? profileId;
}

function nodeName(report: ScenarioLabExtendedReport, nodeId: string | null): string {
  if (!nodeId) {
    return "none";
  }
  return report.nodeRiskDashboard.find((node) => node.nodeId === nodeId)?.nodeName ?? nodeId;
}

function uniqueValues<T>(values: T[]): T[] {
  return [...new Set(values)];
}

function sum(values: number[]): number {
  return values.reduce((total, value) => total + value, 0);
}

function derivedMetricFingerprint(metric: ScenarioLabExtendedReport["extendedRunMetrics"][number]): string {
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
