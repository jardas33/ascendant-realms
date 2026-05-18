import type { PlaytestTelemetry } from "./PlaytestTypes";
import type {
  ScenarioLabAction,
  ScenarioLabConfidence,
  ScenarioLabProfileSummary,
  ScenarioLabWatchpointClassification,
  ScenarioLabWatchpointId
} from "./ScenarioLabTypes";

interface ClassificationContext {
  profileSummaries: ScenarioLabProfileSummary[];
  sourceRuns: PlaytestTelemetry[];
}

export function classifyScenarioLabWatchpoints(context: ClassificationContext): ScenarioLabWatchpointClassification[] {
  return [
    classifyRetinueTrainingYard(context),
    classifyGreedyEconomy(context),
    classifyFastArmy(context),
    classifyEarlyDefeats(context),
    classifyPressureFairness(context),
    classifyCinderfenCrossing(context),
    classifyCinderfenWatch(context),
    classifyAshenOutpost(context)
  ];
}

function classifyRetinueTrainingYard(context: ClassificationContext): ScenarioLabWatchpointClassification {
  const summary = requireSummary(context.profileSummaries, "retinue_training_yard_ii");
  const watchpointRuns = context.sourceRuns.filter(
    (run) => run.strongholdProfileId === "retinue_training_yard_path" && isWatchpointNode(run.nodeId)
  );
  const lowLossWins = watchpointRuns.filter((run) => run.battleResult === "victory" && run.unitsLost <= 1).length;
  const sweptWatchpoints = watchpointRuns.length > 0 && lowLossWins === watchpointRuns.length;
  const action: ScenarioLabAction = sweptWatchpoints ? "needs human testing" : "monitor";
  const confidence: ScenarioLabConfidence = sweptWatchpoints ? "medium" : "low";
  return classification({
    id: "retinue_training_yard_ii",
    name: "Retinue + Training Yard II",
    action,
    confidence,
    verdict: sweptWatchpoints
      ? "Automated watchpoint nodes are very clean, but the full route is not a whole-suite sweep; treat as earned-power human-test priority, not an automated nerf."
      : "Strong but not automatically dominant in the automated suite.",
    evidence: [
      `${summary.profileName}: ${formatRecordWords(summary.record)} across ${summary.runCount} lab runs.`,
      `Ashen/Cinderfen low-loss wins: ${lowLossWins}/${watchpointRuns.length}.`,
      `Average losses: ${formatNumber(summary.averageUnitLosses)}; average final army: ${formatNumber(summary.averageFinalArmySize)}.`
    ],
    humanTestingNeeded: true
  });
}

function classifyGreedyEconomy(context: ClassificationContext): ScenarioLabWatchpointClassification {
  const summary = requireSummary(context.profileSummaries, "greedy_economy");
  const greedyRuns = context.sourceRuns.filter((run) => run.playerScript === "greedy_economy");
  const firstWaveSafe = greedyRuns.filter((run) => run.firstWaveSurvived).length;
  const conversionTimeouts = summary.failureReasons.conversion_timeout;
  return classification({
    id: "greedy_economy",
    name: "Greedy Economy",
    action: conversionTimeouts >= 10 ? "monitor" : "no change",
    confidence: "medium",
    verdict:
      "Greedy failures continue to read as timing and conversion risk: first waves are generally survived, but surplus resources do not consistently become a fast win.",
    evidence: [
      `${summary.profileName}: ${formatRecordWords(summary.record)} across ${summary.runCount} lab runs.`,
      `First wave survived in ${firstWaveSafe}/${greedyRuns.length} Greedy source runs.`,
      `Conversion timeouts: ${conversionTimeouts}; average resource surplus: ${Math.round(summary.averageResourceSurplus)}.`
    ],
    humanTestingNeeded: true
  });
}

function classifyFastArmy(context: ClassificationContext): ScenarioLabWatchpointClassification {
  const summary = requireSummary(context.profileSummaries, "fast_army");
  const cinderfenRuns = context.sourceRuns.filter((run) => run.playerScript === "fast_army" && isCinderfenNode(run.nodeId));
  const cinderfenWins = cinderfenRuns.filter((run) => run.battleResult === "victory").length;
  const wholeSuiteFailures = summary.record.defeats + summary.record.timeouts;
  return classification({
    id: "fast_army",
    name: "Fast Army",
    action: cinderfenWins === cinderfenRuns.length && wholeSuiteFailures === 0 ? "tiny tuning candidate" : "monitor",
    confidence: wholeSuiteFailures > 0 ? "medium" : "low",
    verdict:
      wholeSuiteFailures > 0
        ? "Fast Army is decisive in Cinderfen but still pays failure risk across the broader suite; do not slow it just because it is fast."
        : "Fast Army would need human review before any slowdown even if it sweeps Cinderfen.",
    evidence: [
      `${summary.profileName}: ${formatRecordWords(summary.record)} across ${summary.runCount} lab runs.`,
      `Cinderfen Fast Army wins: ${cinderfenWins}/${cinderfenRuns.length}.`,
      `Whole-suite failures: ${wholeSuiteFailures}.`
    ],
    humanTestingNeeded: true
  });
}

function classifyEarlyDefeats(context: ClassificationContext): ScenarioLabWatchpointClassification {
  const earlyRuns = context.sourceRuns.filter((run) => run.nodeId === "border_village" || run.nodeId === "old_stone_road");
  const defeats = earlyRuns.filter((run) => run.battleResult === "defeat").length;
  const firstWaveFailures = earlyRuns.filter((run) => !run.firstWaveSurvived).length;
  return classification({
    id: "early_defeats",
    name: "Early Defeats",
    action: defeats === 0 ? "no change" : "monitor",
    confidence: "high",
    verdict:
      defeats === 0
        ? "Early nodes are structurally stable in automation."
        : "Early failures exist in automation and should be inspected before tuning.",
    evidence: [
      `Early-node record: ${formatRecordWords(recordFor(earlyRuns))}.`,
      `First-wave not-survived markers: ${firstWaveFailures}/${earlyRuns.length}; speed routes can end before absorbing a first wave.`
    ],
    humanTestingNeeded: false
  });
}

function classifyPressureFairness(context: ClassificationContext): ScenarioLabWatchpointClassification {
  const pressureRuns = context.sourceRuns.filter((run) => run.enemyPressurePlanId);
  const triggered = pressureRuns.filter((run) => run.triggeredStages.length > 0);
  const warnings = pressureRuns.reduce((total, run) => total + run.pressureWarningsShown, 0);
  const safeWins = pressureRuns.filter((run) => run.playerScript === "safe_beginner" && run.battleResult === "victory").length;
  const safeRuns = pressureRuns.filter((run) => run.playerScript === "safe_beginner").length;
  return classification({
    id: "pressure_fairness",
    name: "Pressure Fairness",
    action: warnings > 0 && safeWins === safeRuns ? "needs human testing" : "monitor",
    confidence: "medium",
    verdict:
      "Pressure remains structurally actionable in automation, but automated telemetry cannot prove human noticeability during combat stress.",
    evidence: [
      `Pressure runs: ${pressureRuns.length}; triggered: ${triggered.length}; warnings shown: ${warnings}.`,
      `Safe Beginner pressure-node wins: ${safeWins}/${safeRuns}.`,
      `Reinforcement applications: ${pressureRuns.filter((run) => run.reinforcementApplied).length}.`
    ],
    humanTestingNeeded: true
  });
}

function classifyCinderfenCrossing(context: ClassificationContext): ScenarioLabWatchpointClassification {
  return classifyCinderfenNode(context, "cinderfen_crossing", "Cinderfen Crossing Fairness");
}

function classifyCinderfenWatch(context: ClassificationContext): ScenarioLabWatchpointClassification {
  return classifyCinderfenNode(context, "cinderfen_watch", "Cinderfen Watch Fairness");
}

function classifyCinderfenNode(
  context: ClassificationContext,
  nodeId: "cinderfen_crossing" | "cinderfen_watch",
  name: string
): ScenarioLabWatchpointClassification {
  const runs = context.sourceRuns.filter((run) => run.nodeId === nodeId);
  const safeRuns = runs.filter((run) => run.playerScript === "safe_beginner");
  const safeWins = safeRuns.filter((run) => run.battleResult === "victory").length;
  const pressureWarnings = runs.reduce((total, run) => total + run.pressureWarningsShown, 0);
  const action: ScenarioLabAction = safeWins === safeRuns.length ? "no change" : "monitor";
  return classification({
    id: nodeId === "cinderfen_crossing" ? "cinderfen_crossing_fairness" : "cinderfen_watch_fairness",
    name,
    action,
    confidence: "medium",
    verdict:
      safeWins === safeRuns.length
        ? `${name.replace(" Fairness", "")} is structurally fair for the safe script; remaining questions are route feel and pressure noticeability.`
        : `${name.replace(" Fairness", "")} has safe-route failures and needs closer inspection before tuning.`,
    evidence: [
      `${name.replace(" Fairness", "")} record: ${formatRecordWords(recordFor(runs))}.`,
      `Safe Beginner wins: ${safeWins}/${safeRuns.length}.`,
      `Pressure warnings shown: ${pressureWarnings}.`
    ],
    humanTestingNeeded: true
  });
}

function classifyAshenOutpost(context: ClassificationContext): ScenarioLabWatchpointClassification {
  const runs = context.sourceRuns.filter((run) => run.nodeId === "ashen_outpost");
  const safeRuns = runs.filter((run) => run.playerScript === "safe_beginner");
  const safeWins = safeRuns.filter((run) => run.battleResult === "victory").length;
  const timeouts = runs.filter((run) => run.battleResult === "timeout").length;
  return classification({
    id: "ashen_outpost_stability",
    name: "Ashen Outpost Stability",
    action: safeWins === safeRuns.length ? "monitor" : "needs human testing",
    confidence: "medium",
    verdict:
      "Ashen Outpost remains beatable and stable for safe play, while route timeouts keep it as a pacing and final-assault watchpoint.",
    evidence: [
      `Ashen Outpost record: ${formatRecordWords(recordFor(runs))}.`,
      `Safe Beginner wins: ${safeWins}/${safeRuns.length}.`,
      `Timeouts across all profiles/scripts: ${timeouts}.`
    ],
    humanTestingNeeded: true
  });
}

function classification(input: {
  id: ScenarioLabWatchpointId;
  name: string;
  action: ScenarioLabAction;
  confidence: ScenarioLabConfidence;
  verdict: string;
  evidence: string[];
  humanTestingNeeded: boolean;
}): ScenarioLabWatchpointClassification {
  return {
    watchpointId: input.id,
    watchpointName: input.name,
    action: input.action,
    confidence: input.confidence,
    automatedVerdict: input.verdict,
    evidence: input.evidence,
    humanTestingNeeded: input.humanTestingNeeded
  };
}

function requireSummary(summaries: ScenarioLabProfileSummary[], profileId: ScenarioLabProfileSummary["profileId"]): ScenarioLabProfileSummary {
  const summary = summaries.find((entry) => entry.profileId === profileId);
  if (!summary) {
    throw new Error(`Missing scenario lab profile summary: ${profileId}`);
  }
  return summary;
}

function recordFor(runs: PlaytestTelemetry[]) {
  return {
    wins: runs.filter((run) => run.battleResult === "victory").length,
    defeats: runs.filter((run) => run.battleResult === "defeat").length,
    timeouts: runs.filter((run) => run.battleResult === "timeout").length
  };
}

function formatRecord(record: { wins: number; defeats: number; timeouts: number }): string {
  return `${record.wins} wins / ${record.defeats} defeats / ${record.timeouts} timeouts`;
}

function formatRecordWords(record: { wins: number; defeats: number; timeouts: number }): string {
  return `${formatCount(record.wins, "win")} / ${formatCount(record.defeats, "defeat")} / ${formatCount(
    record.timeouts,
    "timeout"
  )}`;
}

function formatCount(value: number, label: string): string {
  return `${value} ${label}${value === 1 ? "" : "s"}`;
}

function formatNumber(value: number): string {
  return value.toFixed(1);
}

function isWatchpointNode(nodeId: string): boolean {
  return nodeId === "ashen_outpost" || isCinderfenNode(nodeId);
}

function isCinderfenNode(nodeId: string): boolean {
  return nodeId === "cinderfen_crossing" || nodeId === "cinderfen_watch";
}
