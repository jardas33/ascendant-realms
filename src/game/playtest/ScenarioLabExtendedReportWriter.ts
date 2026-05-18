import { formatTime } from "../core/MathUtils";
import type {
  ScenarioLabExtendedReport,
  ScenarioLabNodeRiskDashboardEntry,
  ScenarioLabProfileComparison,
  ScenarioLabProfileNodeScriptComparison,
  ScenarioLabRecord,
  ScenarioLabWatchpointRegression
} from "./ScenarioLabTypes";

export function renderExtendedScenarioLabMarkdownReport(report: ScenarioLabExtendedReport): string {
  const lines: string[] = [];
  lines.push("# v0.13.1 Extended Automated Scenario Lab");
  lines.push("");
  lines.push("Evidence type: repeated deterministic simulator evidence only. No human tester feedback is included or implied.");
  lines.push("");
  pushBatchInfo(lines, report);
  lines.push("## Executive Summary");
  lines.push("");
  lines.push(`- Strongest consistent profile: ${profileName(report, report.strongestProfileId)}.`);
  lines.push(`- Weakest / most failure-prone profile: ${profileName(report, report.weakestProfileId)}.`);
  lines.push(`- Fastest consistent profile: ${profileName(report, report.fastestProfileId)}.`);
  lines.push(`- Biggest timeout-risk node: ${nodeName(report, report.biggestTimeoutRiskNodeId)}.`);
  lines.push(`- Biggest pressure-risk node: ${nodeName(report, report.biggestPressureRiskNodeId)}.`);
  lines.push("- Recommended action: no runtime tuning from v0.13.1 automation alone; use this as a regression dashboard and human-test priority map.");
  lines.push("");
  appendProfileComparison(lines, report.profileComparisons);
  appendNodeRiskTable(lines, report.nodeRiskDashboard);
  lines.push("## Profile x Node x Script Risk Rows");
  lines.push("");
  lines.push("| Profile | Node | Script | Runs | Record | Win | Timeout | Loss | Avg clear | Avg losses | Avg resources | Pressure warnings |");
  lines.push("| --- | --- | --- | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |");
  topProfileNodeScriptRisks(report.profileNodeScriptComparisons).forEach((entry) => {
    lines.push(
      `| ${entry.profileName} | ${entry.nodeName} | ${entry.playerScript} | ${entry.totalRuns} | ${formatRecord(entry.record)} | ${formatPercent(
        entry.winRate
      )} | ${formatPercent(entry.timeoutRate)} | ${formatPercent(entry.lossRate)} | ${formatTime(entry.averageClearTimeSeconds)} | ${formatNumber(
        entry.averageUnitLosses
      )} | ${Math.round(entry.averageResourceSurplus)} | ${entry.pressureWarningCount} |`
    );
  });
  lines.push("");
  appendWatchpointStatusTable(lines, report.watchpointRegressions);
  lines.push("## Determinism Notes");
  lines.push("");
  report.determinismNotes.forEach((note) => lines.push(`- ${note}`));
  lines.push("");
  lines.push("## Limits");
  lines.push("");
  lines.push("- Repeated deterministic runs are regression evidence, not new human observations.");
  lines.push("- The five default iterations are intentionally identical deterministic replays; spreads describe the scenario/profile mix, not random variance.");
  lines.push("- The lab still cannot measure fun, stress, warning noticeability, visual readability, human confusion, final hero HP, or base damage.");
  lines.push("- Profile rows overlap intentionally, so compare route evidence views rather than independent player populations.");
  lines.push("- Any tuning candidate still needs a separate decision step and preferably real human playtest notes.");
  lines.push("");
  lines.push("## Metric Availability");
  lines.push("");
  lines.push("| Metric | Status | Note |");
  lines.push("| --- | --- | --- |");
  report.metricsAvailability.forEach((metric) => {
    lines.push(`| ${metric.metric} | ${metric.status} | ${metric.note} |`);
  });
  return formatMarkdownDocument(lines);
}

export function renderProfileComparisonMarkdown(report: ScenarioLabExtendedReport): string {
  const lines: string[] = [];
  lines.push("# v0.13.1 Profile Comparison");
  lines.push("");
  lines.push("Evidence type: repeated deterministic simulator evidence only. No human tester feedback is included or implied.");
  lines.push("");
  pushBatchInfo(lines, report);
  appendProfileComparison(lines, report.profileComparisons);
  lines.push("## Route Verdict Distribution");
  lines.push("");
  report.profileComparisons.forEach((profile) => {
    lines.push(`### ${profile.profileName}`);
    lines.push("");
    profile.routeVerdictDistribution.forEach((entry) => lines.push(`- ${entry.value}: ${entry.count}`));
    lines.push("");
  });
  return formatMarkdownDocument(lines);
}

export function renderProfileComparisonCsv(report: ScenarioLabExtendedReport): string {
  const header = [
    "profileId",
    "profileName",
    "iterationsObserved",
    "totalRuns",
    "wins",
    "defeats",
    "timeouts",
    "winRate",
    "lossRate",
    "timeoutRate",
    "medianClearTimeSeconds",
    "averageClearTimeSeconds",
    "fastestClearTimeSeconds",
    "slowestClearTimeSeconds",
    "clearTimeSpreadSeconds",
    "averageUnitLosses",
    "averageFinalArmySize",
    "averageResourceSurplus",
    "averageFinalAether",
    "objectiveCompletionRate",
    "pressureWarningCount",
    "averagePressureReactionWindowSeconds",
    "stabilityVerdict"
  ];
  const rows = [...report.profileComparisons].sort(profileRankSort).map((profile) =>
    [
      profile.profileId,
      profile.profileName,
      profile.iterationsObserved,
      profile.totalRuns,
      profile.record.wins,
      profile.record.defeats,
      profile.record.timeouts,
      profile.winRate,
      profile.lossRate,
      profile.timeoutRate,
      profile.medianClearTimeSeconds,
      profile.averageClearTimeSeconds,
      profile.fastestClearTimeSeconds,
      profile.slowestClearTimeSeconds,
      profile.clearTimeSpreadSeconds,
      profile.averageUnitLosses,
      profile.averageFinalArmySize,
      profile.averageResourceSurplus,
      profile.averageFinalAether,
      profile.objectiveCompletionRate,
      profile.pressureWarningCount,
      profile.averagePressureReactionWindowSeconds ?? "",
      profile.stabilityVerdict
    ].map(csvCell)
  );
  return `${[header, ...rows].map((row) => row.join(",")).join("\n")}\n`;
}

export function renderBalanceRegressionDashboardMarkdown(report: ScenarioLabExtendedReport): string {
  const dashboard = report.dashboard;
  const lines: string[] = [];
  lines.push("# v0.13.1 Balance Regression Dashboard");
  lines.push("");
  lines.push("Evidence type: repeated deterministic simulator evidence only. No human tester feedback is included or implied.");
  lines.push("");
  lines.push(`Generated at: ${dashboard.generatedAt}`);
  lines.push(`Build commit: ${dashboard.buildCommit}`);
  lines.push(`Batch: ${dashboard.batchLabel}`);
  lines.push(`Iterations: ${dashboard.iterationCount}`);
  lines.push(`Seed label: ${dashboard.seed}`);
  lines.push("");
  lines.push("## Quick Summary");
  lines.push("");
  lines.push(`- Strongest automated route: ${profileName(report, dashboard.strongestProfileId)}.`);
  lines.push(`- Weakest automated route: ${profileName(report, dashboard.weakestProfileId)}.`);
  lines.push(`- Biggest timeout risk: ${nodeName(report, dashboard.biggestTimeoutRiskNodeId)}.`);
  lines.push(`- Biggest pressure-risk signal: ${nodeName(report, dashboard.biggestPressureRiskNodeId)}.`);
  lines.push("");
  appendProfileComparison(lines, dashboard.profileRanking);
  appendWatchpointStatusTable(lines, dashboard.watchpointStatuses);
  appendNodeRiskTable(lines, dashboard.nodeRiskTable);
  lines.push("## Top Monitor Items");
  lines.push("");
  dashboard.topMonitorItems.forEach((item) => lines.push(`- ${item.watchpointName}: ${item.status} - ${item.currentSignal}`));
  lines.push("");
  lines.push("## Do Not Tune Yet");
  lines.push("");
  dashboard.noTuneReasons.forEach((reason) => lines.push(`- ${reason}`));
  lines.push("");
  lines.push("## Human Testing Recommendations");
  lines.push("");
  dashboard.humanTestingRecommendations.forEach((recommendation) => lines.push(`- ${recommendation}`));
  return formatMarkdownDocument(lines);
}

export function renderExtendedWatchpointsMarkdown(report: ScenarioLabExtendedReport): string {
  const lines: string[] = [];
  lines.push("# v0.13.1 Extended Watchpoints");
  lines.push("");
  lines.push("Evidence type: repeated deterministic simulator evidence only. No human tester feedback is included or implied.");
  lines.push("");
  appendWatchpointStatusTable(lines, report.watchpointRegressions);
  lines.push("## Threshold Detail");
  lines.push("");
  report.watchpointRegressions.forEach((watchpoint) => {
    lines.push(`### ${watchpoint.watchpointName}`);
    lines.push("");
    lines.push(`- Normal expected state: ${watchpoint.normalExpectedState}`);
    lines.push(`- Warning threshold: ${watchpoint.warningThreshold}`);
    lines.push(`- Strong signal threshold: ${watchpoint.strongSignalThreshold}`);
    lines.push(`- Current signal: ${watchpoint.currentSignal}`);
    lines.push(`- Recommended action: ${watchpoint.recommendedAction}`);
    lines.push(`- Do not do: ${watchpoint.doNotDo}`);
    watchpoint.evidence.forEach((evidence) => lines.push(`- Evidence: ${evidence}`));
    lines.push("");
  });
  return formatMarkdownDocument(lines);
}

function pushBatchInfo(lines: string[], report: ScenarioLabExtendedReport): void {
  lines.push(`Generated by: ${report.generatedBy}`);
  lines.push(`Generated at: ${report.generatedAt}`);
  lines.push(`Build commit: ${report.buildCommit}`);
  lines.push(`Batch: ${report.batchLabel}`);
  lines.push(`Iterations: ${report.iterationCount}`);
  lines.push(`Seed label: ${report.seed}`);
  lines.push(`Source runs: ${report.sourceRunCountPerIteration} per iteration, ${report.totalSourceRuns} total.`);
  lines.push(`Derived profile-run metrics: ${report.totalDerivedMetrics}.`);
  lines.push(`Unique deterministic metric fingerprints: ${report.uniqueDerivedMetricFingerprints}.`);
  lines.push("");
}

function appendProfileComparison(lines: string[], profiles: ScenarioLabProfileComparison[]): void {
  lines.push("## Profile Ranking");
  lines.push("");
  lines.push("| Profile | Runs | Record | Win | Timeout | Loss | Median clear | Avg clear | Spread | Avg losses | Avg army | Avg resources | Objective completion | Pressure warnings | Stability |");
  lines.push("| --- | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |");
  const rankedProfiles = [...profiles].sort(profileRankSort);
  rankedProfiles.forEach((profile) => {
    lines.push(
      `| ${profile.profileName} | ${profile.totalRuns} | ${formatRecord(profile.record)} | ${formatPercent(profile.winRate)} | ${formatPercent(
        profile.timeoutRate
      )} | ${formatPercent(profile.lossRate)} | ${formatTime(profile.medianClearTimeSeconds)} | ${formatTime(
        profile.averageClearTimeSeconds
      )} | ${formatTime(profile.clearTimeSpreadSeconds)} | ${formatNumber(profile.averageUnitLosses)} | ${formatNumber(
        profile.averageFinalArmySize
      )} | ${Math.round(profile.averageResourceSurplus)} | ${formatPercent(profile.objectiveCompletionRate)} | ${
        profile.pressureWarningCount
      } | ${profile.stabilityVerdict} |`
    );
  });
  lines.push("");
}

function profileRankSort(left: ScenarioLabProfileComparison, right: ScenarioLabProfileComparison): number {
  return right.winRate - left.winRate || left.timeoutRate - right.timeoutRate || left.averageUnitLosses - right.averageUnitLosses;
}

function appendNodeRiskTable(lines: string[], nodes: ScenarioLabNodeRiskDashboardEntry[]): void {
  lines.push("## Node Risk Dashboard");
  lines.push("");
  lines.push("| Node | Runs | Record | Win | Timeout | Loss | Avg losses | Pressure warnings | Greedy | Fast | Retinue+Yard | Pressure-Ignoring | Retinue advantage | Status | Verdict |");
  lines.push("| --- | ---: | --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- | --- | ---: | --- | --- |");
  const rankedNodes = [...nodes].sort(nodeRiskSort);
  rankedNodes.forEach((node) => {
    lines.push(
      `| ${node.nodeName} | ${node.totalRuns} | ${formatRecord(node.record)} | ${formatPercent(node.winRate)} | ${formatPercent(
        node.timeoutRate
      )} | ${formatPercent(node.lossRate)} | ${formatNumber(node.averageUnitLosses)} | ${node.pressureWarningCount} | ${formatRecord(
        node.greedyEconomyRecord
      )} | ${formatRecord(node.fastArmyRecord)} | ${formatRecord(node.retinueTrainingYardRecord)} | ${formatRecord(
        node.pressureIgnoringRecord
      )} | ${formatNumber(node.retinueAdvantageScore)} | ${node.status} | ${node.verdict} |`
    );
  });
  lines.push("");
}

function nodeRiskSort(left: ScenarioLabNodeRiskDashboardEntry, right: ScenarioLabNodeRiskDashboardEntry): number {
  const leftRisk = left.lossRate + left.timeoutRate;
  const rightRisk = right.lossRate + right.timeoutRate;
  return rightRisk - leftRisk || right.averageUnitLosses - left.averageUnitLosses || right.pressureWarningCount - left.pressureWarningCount;
}

function appendWatchpointStatusTable(lines: string[], watchpoints: ScenarioLabWatchpointRegression[]): void {
  lines.push("## Watchpoint Status");
  lines.push("");
  lines.push("| Watchpoint | Status | Human testing | Current signal | Recommended action |");
  lines.push("| --- | --- | --- | --- | --- |");
  watchpoints.forEach((watchpoint) => {
    lines.push(
      `| ${watchpoint.watchpointName} | ${watchpoint.status} | ${watchpoint.humanTestingNeeded ? "yes" : "no"} | ${
        watchpoint.currentSignal
      } | ${watchpoint.recommendedAction} |`
    );
  });
  lines.push("");
}

function topProfileNodeScriptRisks(entries: ScenarioLabProfileNodeScriptComparison[]): ScenarioLabProfileNodeScriptComparison[] {
  return [...entries]
    .sort((left, right) => {
      const leftRisk = left.lossRate + left.timeoutRate;
      const rightRisk = right.lossRate + right.timeoutRate;
      return rightRisk - leftRisk || right.averageUnitLosses - left.averageUnitLosses;
    })
    .slice(0, 24);
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

function formatRecord(record: ScenarioLabRecord): string {
  return `${record.wins}-${record.defeats}-${record.timeouts}`;
}

function formatPercent(value: number): string {
  return `${Math.round(value * 100)}%`;
}

function formatNumber(value: number): string {
  return value.toFixed(1);
}

function csvCell(value: string | number): string {
  const text = String(value);
  return /[",\n]/u.test(text) ? `"${text.replace(/"/gu, "\"\"")}"` : text;
}

function formatMarkdownDocument(lines: string[]): string {
  while (lines[lines.length - 1] === "") {
    lines.pop();
  }
  return `${lines.join("\n")}\n`;
}
