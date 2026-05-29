import type { ResourceBag } from "../core/GameTypes";
import { ACT1_CAMPAIGN_SPINE } from "../data/act1CampaignSpine";
import { runScriptedPlaytestSuite } from "./PlaytestRunner";
import type { PlaytestReport, PlaytestScriptId, PlaytestTelemetry } from "./PlaytestTypes";

export type Act1PlayabilityVerdict = "stable" | "stable_forgiving" | "watch_strategy_spread" | "opening_risk";

export interface Act1ScriptTelemetrySummary {
  scriptId: PlaytestScriptId;
  runs: number;
  victories: number;
  defeats: number;
  timeouts: number;
  averageDurationSeconds: number;
}

export interface Act1FailureCauseSummary {
  cause: string;
  count: number;
}

export interface Act1NodePlayabilitySummary {
  order: number;
  nodeId: string;
  nodeName: string;
  actStepTitle: string;
  pacingTier: string;
  mechanicFocus: string[];
  runCount: number;
  victories: number;
  defeats: number;
  timeouts: number;
  winRate: number;
  averageStartingResources: ResourceBag;
  averageDurationSeconds: number;
  averageFirstSiteCaptureSeconds: number | null;
  averageFirstWorkerBuildingSeconds: number | null;
  averageFirstBuildingCompleteSeconds: number | null;
  averageFirstUnitTrainedSeconds: number | null;
  averageFirstEnemyWarningSeconds: number | null;
  averageFirstCombatSeconds: number | null;
  averageFirstPressureSeconds: number | null;
  averageUnitsLost: number;
  averageFinalArmySize: number;
  enemyHeroDefeats: number;
  objectiveCompletions: string[];
  failureCauses: Act1FailureCauseSummary[];
  scriptSummaries: Act1ScriptTelemetrySummary[];
  verdict: Act1PlayabilityVerdict;
  recommendedAction: string;
}

export interface Act1PlayabilityTelemetryReport {
  schemaVersion: 1;
  generatedBy: string;
  sourceGeneratedBy: string;
  sourceRunCount: number;
  act1RunCount: number;
  evidenceBoundary: {
    evidenceType: string;
    measured: string[];
    notMeasured: string[];
  };
  tutorialProtection: {
    label: string;
    simulated: false;
    policy: string;
  };
  nodeSummaries: Act1NodePlayabilitySummary[];
  overallRead: {
    safeBeginnerWinsAllAct1Nodes: boolean;
    numericTuningRecommendation: string;
    copyPolishRecommendation: string;
  };
}

const ACT1_BATTLE_STEPS = ACT1_CAMPAIGN_SPINE.filter((step) => step.kind === "campaign_battle" && step.nodeId);

const RESOURCE_KEYS: Array<keyof ResourceBag> = ["crowns", "stone", "iron", "aether"];

export function buildAct1PlayabilityTelemetryReport(sourceReport: PlaytestReport = runScriptedPlaytestSuite()): Act1PlayabilityTelemetryReport {
  const act1NodeIds = new Set(ACT1_BATTLE_STEPS.map((step) => step.nodeId!));
  const act1Runs = sourceReport.telemetry.filter((run) => act1NodeIds.has(run.nodeId));
  const nodeSummaries = ACT1_BATTLE_STEPS.map((step) => summarizeAct1Node(step.nodeId!, act1Runs));
  const safeBeginnerWinsAllAct1Nodes = nodeSummaries.every((summary) => {
    const safeSummary = summary.scriptSummaries.find((entry) => entry.scriptId === "safe_beginner");
    return safeSummary !== undefined && safeSummary.runs > 0 && safeSummary.victories === safeSummary.runs;
  });
  const strategySpreadNodes = nodeSummaries
    .filter((summary) => summary.verdict === "watch_strategy_spread")
    .map((summary) => summary.nodeName);

  return {
    schemaVersion: 1,
    generatedBy: "Ascendant Realms Act 1 deterministic playability telemetry v1",
    sourceGeneratedBy: sourceReport.generatedBy,
    sourceRunCount: sourceReport.telemetry.length,
    act1RunCount: act1Runs.length,
    evidenceBoundary: {
      evidenceType: "deterministic scripted simulator over existing campaign battle nodes",
      measured: [
        "mission start state",
        "starting resources",
        "first resource-site capture timing",
        "first Worker-built production timing where measurable",
        "first trained-unit timing",
        "enemy warning and first combat timing",
        "battle result, duration, units lost, final army size, and objective completion"
      ],
      notMeasured: [
        "human fun",
        "moment-to-moment stress",
        "visual readability beyond automated UI checks",
        "audio clarity",
        "novice comprehension without manual tester notes"
      ]
    },
    tutorialProtection: {
      label: "Tutorial / Proving Grounds",
      simulated: false,
      policy: "Excluded from persistent campaign telemetry and rewards; it remains no-save and no-reward."
    },
    nodeSummaries,
    overallRead: {
      safeBeginnerWinsAllAct1Nodes,
      numericTuningRecommendation: safeBeginnerWinsAllAct1Nodes
        ? "No numeric tuning is recommended from simulator evidence alone."
        : "Investigate mission-local opening pressure before changing any number.",
      copyPolishRecommendation:
        strategySpreadNodes.length > 0
          ? `Use onboarding copy to warn players to stabilize economy, production, and army staging before pushing ${strategySpreadNodes.join(", ")}.`
          : "Keep Act 1 copy concise; no additional warning copy is required by this telemetry pass."
    }
  };
}

export function renderAct1PlayabilityTelemetryMarkdownReport(report: Act1PlayabilityTelemetryReport): string {
  const lines: string[] = [];
  lines.push("# v0.48 Act 1 Playtest Telemetry Report");
  lines.push("");
  lines.push(`Generated by: ${report.generatedBy}`);
  lines.push(`Source: ${report.sourceGeneratedBy}`);
  lines.push(`Source runs: ${report.sourceRunCount}`);
  lines.push(`Act 1 campaign battle runs: ${report.act1RunCount}`);
  lines.push("");
  lines.push("## Evidence Boundary");
  lines.push("");
  lines.push(`- Evidence type: ${report.evidenceBoundary.evidenceType}.`);
  lines.push(`- Measured: ${report.evidenceBoundary.measured.join("; ")}.`);
  lines.push(`- Not measured: ${report.evidenceBoundary.notMeasured.join("; ")}.`);
  lines.push(`- Tutorial protection: ${report.tutorialProtection.policy}`);
  lines.push("");
  lines.push("## Overall Read");
  lines.push("");
  lines.push(
    `- Safe Beginner wins every Act 1 campaign node: ${report.overallRead.safeBeginnerWinsAllAct1Nodes ? "yes" : "no"}.`
  );
  lines.push(`- Numeric tuning: ${report.overallRead.numericTuningRecommendation}`);
  lines.push(`- Copy polish: ${report.overallRead.copyPolishRecommendation}`);
  lines.push("");
  lines.push("## Node Summary");
  lines.push("");
  lines.push("| Step | Node | Pace | Record | Avg duration | First site | First building | First combat | Avg losses | Verdict |");
  lines.push("| ---: | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |");
  report.nodeSummaries.forEach((summary) => {
    lines.push(
      `| ${summary.order} | ${summary.nodeName} | ${summary.pacingTier} | ${summary.victories}-${summary.defeats}-${summary.timeouts} | ${formatSeconds(
        summary.averageDurationSeconds
      )} | ${formatNullableSeconds(summary.averageFirstSiteCaptureSeconds)} | ${formatNullableSeconds(
        summary.averageFirstBuildingCompleteSeconds
      )} | ${formatNullableSeconds(summary.averageFirstCombatSeconds)} | ${summary.averageUnitsLost.toFixed(1)} | ${summary.verdict} |`
    );
  });
  lines.push("");
  lines.push("## Script Spread");
  lines.push("");
  lines.push("| Node | Safe Beginner | Greedy Economy | Fast Army | Recommended action |");
  lines.push("| --- | ---: | ---: | ---: | --- |");
  report.nodeSummaries.forEach((summary) => {
    lines.push(
      `| ${summary.nodeName} | ${formatScriptRecord(summary, "safe_beginner")} | ${formatScriptRecord(
        summary,
        "greedy_economy"
      )} | ${formatScriptRecord(summary, "fast_army")} | ${summary.recommendedAction} |`
    );
  });
  lines.push("");
  lines.push("## Failure Causes");
  lines.push("");
  report.nodeSummaries.forEach((summary) => {
    lines.push(`### ${summary.nodeName}`);
    lines.push("");
    if (summary.failureCauses.length === 0) {
      lines.push("- No non-victory runs.");
    } else {
      summary.failureCauses.forEach((cause) => lines.push(`- ${cause.cause}: ${cause.count}`));
    }
    lines.push("");
  });
  return `${lines.join("\n")}\n`;
}

function summarizeAct1Node(nodeId: string, runs: PlaytestTelemetry[]): Act1NodePlayabilitySummary {
  const nodeRuns = runs.filter((run) => run.nodeId === nodeId);
  const first = nodeRuns[0];
  const step = ACT1_BATTLE_STEPS.find((entry) => entry.nodeId === nodeId)!;
  const victories = nodeRuns.filter((run) => run.battleResult === "victory").length;
  const defeats = nodeRuns.filter((run) => run.battleResult === "defeat").length;
  const timeouts = nodeRuns.filter((run) => run.battleResult === "timeout").length;
  const safeRuns = nodeRuns.filter((run) => run.playerScript === "safe_beginner");
  const safeWins = safeRuns.filter((run) => run.battleResult === "victory").length;
  const verdict = classifyNodeVerdict(nodeRuns, safeRuns, safeWins);
  return {
    order: step.order,
    nodeId,
    nodeName: first?.nodeName ?? nodeId,
    actStepTitle: step.title,
    pacingTier: step.pacingTier,
    mechanicFocus: [...step.mechanicFocus],
    runCount: nodeRuns.length,
    victories,
    defeats,
    timeouts,
    winRate: ratio(victories, nodeRuns.length),
    averageStartingResources: averageResources(nodeRuns.map((run) => run.startingResources)),
    averageDurationSeconds: average(nodeRuns.map((run) => run.battleDurationSeconds)),
    averageFirstSiteCaptureSeconds: nullableAverage(nodeRuns.map((run) => run.timeFirstSiteCaptured)),
    averageFirstWorkerBuildingSeconds: nullableAverage(nodeRuns.map((run) => run.timeBarracksPlaced)),
    averageFirstBuildingCompleteSeconds: nullableAverage(nodeRuns.map((run) => run.timeBarracksCompleted)),
    averageFirstUnitTrainedSeconds: nullableAverage(nodeRuns.map((run) => run.timeFirstUnitTrained)),
    averageFirstEnemyWarningSeconds: nullableAverage(nodeRuns.map((run) => run.timeFirstEnemyWarning)),
    averageFirstCombatSeconds: nullableAverage(nodeRuns.map((run) => run.timeFirstEnemyContact)),
    averageFirstPressureSeconds: nullableAverage(nodeRuns.map((run) => run.firstPressureTime)),
    averageUnitsLost: average(nodeRuns.map((run) => run.unitsLost)),
    averageFinalArmySize: average(nodeRuns.map((run) => run.finalArmySize)),
    enemyHeroDefeats: nodeRuns.filter((run) => run.enemyHeroDefeated).length,
    objectiveCompletions: [...new Set(nodeRuns.flatMap((run) => run.objectiveCompletion))],
    failureCauses: summarizeFailureCauses(nodeRuns),
    scriptSummaries: summarizeScripts(nodeRuns),
    verdict,
    recommendedAction: recommendationForVerdict(verdict)
  };
}

function classifyNodeVerdict(
  runs: PlaytestTelemetry[],
  safeRuns: PlaytestTelemetry[],
  safeWins: number
): Act1PlayabilityVerdict {
  if (runs.length === 0 || safeRuns.length === 0) {
    return "opening_risk";
  }
  const safeRouteWins = safeWins === safeRuns.length;
  const allWin = runs.every((run) => run.battleResult === "victory");
  const averageLosses = average(runs.map((run) => run.unitsLost));
  if (!safeRouteWins) {
    return "opening_risk";
  }
  if (!allWin) {
    return "watch_strategy_spread";
  }
  return averageLosses <= 1 ? "stable_forgiving" : "stable";
}

function recommendationForVerdict(verdict: Act1PlayabilityVerdict): string {
  switch (verdict) {
    case "opening_risk":
      return "Inspect mission-local opening pressure before changing any global values.";
    case "watch_strategy_spread":
      return "Do not tune numerically yet; reinforce economy, production, and staging guidance.";
    case "stable_forgiving":
      return "Keep forgiving pacing; watch reward and replay clarity in manual retest.";
    case "stable":
    default:
      return "Keep current numbers and verify feel through hosted/manual play.";
  }
}

function summarizeScripts(runs: PlaytestTelemetry[]): Act1ScriptTelemetrySummary[] {
  const scriptIds: PlaytestScriptId[] = ["safe_beginner", "greedy_economy", "fast_army"];
  return scriptIds.map((scriptId) => {
    const scriptRuns = runs.filter((run) => run.playerScript === scriptId);
    return {
      scriptId,
      runs: scriptRuns.length,
      victories: scriptRuns.filter((run) => run.battleResult === "victory").length,
      defeats: scriptRuns.filter((run) => run.battleResult === "defeat").length,
      timeouts: scriptRuns.filter((run) => run.battleResult === "timeout").length,
      averageDurationSeconds: average(scriptRuns.map((run) => run.battleDurationSeconds))
    };
  });
}

function summarizeFailureCauses(runs: PlaytestTelemetry[]): Act1FailureCauseSummary[] {
  const counts = new Map<string, number>();
  runs
    .filter((run) => run.battleResult !== "victory")
    .forEach((run) => {
      const cause = classifyFailureCause(run);
      counts.set(cause, (counts.get(cause) ?? 0) + 1);
    });
  return [...counts.entries()]
    .map(([cause, count]) => ({ cause, count }))
    .sort((a, b) => b.count - a.count || a.cause.localeCompare(b.cause));
}

function classifyFailureCause(run: PlaytestTelemetry): string {
  if (run.battleResult === "defeat" && !run.firstWaveSurvived) {
    return "early pressure defeat";
  }
  if (run.battleResult === "defeat") {
    return run.enemyHeroId && run.lossesInvolvingEnemyHero > 0 ? "commander attrition defeat" : "army attrition defeat";
  }
  if (run.enemyHeroDefeated) {
    return "post-commander clear-speed timeout";
  }
  if (run.unitsTrained < 4) {
    return "production conversion timeout";
  }
  if (resourceTotal(run.resourcesFloated) >= 500) {
    return "resource conversion timeout";
  }
  return "clear-speed timeout";
}

function average(values: number[]): number {
  if (values.length === 0) {
    return 0;
  }
  return round1(values.reduce((total, value) => total + value, 0) / values.length);
}

function nullableAverage(values: Array<number | null>): number | null {
  const actualValues = values.filter((value): value is number => value !== null);
  return actualValues.length > 0 ? average(actualValues) : null;
}

function averageResources(resources: ResourceBag[]): ResourceBag {
  return RESOURCE_KEYS.reduce<ResourceBag>(
    (result, key) => {
      result[key] = Math.round(average(resources.map((entry) => entry[key])));
      return result;
    },
    { crowns: 0, stone: 0, iron: 0, aether: 0 }
  );
}

function resourceTotal(resources: ResourceBag): number {
  return RESOURCE_KEYS.reduce((total, key) => total + resources[key], 0);
}

function ratio(numerator: number, denominator: number): number {
  return denominator > 0 ? round2(numerator / denominator) : 0;
}

function round1(value: number): number {
  return Math.round(value * 10) / 10;
}

function round2(value: number): number {
  return Math.round(value * 100) / 100;
}

function formatScriptRecord(summary: Act1NodePlayabilitySummary, scriptId: PlaytestScriptId): string {
  const script = summary.scriptSummaries.find((entry) => entry.scriptId === scriptId);
  return script ? `${script.victories}-${script.defeats}-${script.timeouts}` : "-";
}

function formatNullableSeconds(seconds: number | null): string {
  return seconds === null ? "-" : formatSeconds(seconds);
}

function formatSeconds(seconds: number): string {
  const minutes = Math.floor(seconds / 60);
  const remaining = Math.round(seconds - minutes * 60).toString().padStart(2, "0");
  return `${minutes}:${remaining}`;
}
