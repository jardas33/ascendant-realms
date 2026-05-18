import type {
  ScenarioLabExtendedRunMetric,
  ScenarioLabNodeRiskDashboardEntry,
  ScenarioLabProfileComparison,
  ScenarioLabRecord,
  ScenarioLabRegressionStatus,
  ScenarioLabWatchpointId,
  ScenarioLabWatchpointRegression
} from "./ScenarioLabTypes";

interface RegressionThresholdContext {
  profileComparisons: ScenarioLabProfileComparison[];
  nodeRiskDashboard: ScenarioLabNodeRiskDashboardEntry[];
  runMetrics: ScenarioLabExtendedRunMetric[];
}

export function classifyScenarioLabRegressionThresholds(
  context: RegressionThresholdContext
): ScenarioLabWatchpointRegression[] {
  return [
    classifyRetinueDominance(context),
    classifyGreedyCollapse(context),
    classifyFastArmyTrivialization(context),
    classifyEarlyDefeatSpike(context),
    classifyPressureWarningFairness(context),
    classifyCinderfenNodeFairness(context, "cinderfen_crossing_fairness", "Cinderfen Crossing Fairness", "cinderfen_crossing"),
    classifyCinderfenNodeFairness(context, "cinderfen_watch_fairness", "Cinderfen Watch Fairness", "cinderfen_watch"),
    classifyAshenOutpostTimeouts(context),
    classifyObjectiveCompletionDrop(context),
    classifyResourceStarvationSpike(context)
  ];
}

function classifyRetinueDominance(context: RegressionThresholdContext): ScenarioLabWatchpointRegression {
  const profile = requireProfile(context.profileComparisons, "retinue_training_yard_ii");
  const watchpointRuns = context.runMetrics.filter(
    (metric) => metric.profileId === "retinue_training_yard_ii" && isWatchpointNode(metric.nodeId)
  );
  const lowLossWinRate = rate(watchpointRuns.filter((metric) => metric.result === "victory" && metric.unitLosses <= 1).length, watchpointRuns.length);
  const fullFailureRate = profile.lossRate + profile.timeoutRate;
  let status: ScenarioLabRegressionStatus = "Monitor";
  if (profile.winRate >= 0.95 && fullFailureRate === 0 && profile.averageUnitLosses <= 1) {
    status = "Strong signal";
  } else if (profile.winRate >= 0.9 && lowLossWinRate >= 0.95) {
    status = "Warning";
  } else if (lowLossWinRate >= 0.95) {
    status = "Human testing required";
  }
  return regression({
    id: "retinue_training_yard_ii",
    name: "Retinue + Training Yard II Dominance",
    status,
    normal: "Strong earned-power route with some failures or costs outside ideal watchpoint nodes.",
    warning: ">=90% full-profile win rate plus >=95% low-loss wins on Ashen/Cinderfen watchpoint nodes.",
    strong: ">=95% full-profile win rate, zero failures, and <=1 average unit loss.",
    current: `${formatPercent(profile.winRate)} win rate; ${formatPercent(lowLossWinRate)} Ashen/Cinderfen low-loss win rate; ${formatNumber(profile.averageUnitLosses)} average losses.`,
    action:
      status === "Strong signal"
        ? "Hold for human confirmation before any tiny tuning proposal."
        : "Prioritize human testing; do not tune from automation alone.",
    doNotDo: "Do not nerf retinue or Training Yard II from clean automated watchpoint nodes alone.",
    evidence: [
      `${profile.profileName}: ${formatRecord(profile.record)} across ${profile.totalRuns} extended metric rows.`,
      `Ashen/Cinderfen low-loss wins: ${watchpointRuns.filter((metric) => metric.result === "victory" && metric.unitLosses <= 1).length}/${watchpointRuns.length}.`
    ],
    humanTestingNeeded: true
  });
}

function classifyGreedyCollapse(context: RegressionThresholdContext): ScenarioLabWatchpointRegression {
  const profile = requireProfile(context.profileComparisons, "greedy_economy");
  const greedyRuns = context.runMetrics.filter((metric) => metric.profileId === "greedy_economy");
  const conversionTimeouts = greedyRuns.filter((metric) => metric.failureReason === "conversion_timeout" || metric.failureReason === "clear_speed_timeout").length;
  const firstWaveSafeRate = rate(greedyRuns.filter((metric) => metric.firstWaveSurvived).length, greedyRuns.length);
  let status: ScenarioLabRegressionStatus = "OK";
  if (profile.timeoutRate >= 0.65 && profile.winRate < 0.25) {
    status = "Warning";
  } else if (profile.timeoutRate >= 0.45 && firstWaveSafeRate >= 0.9) {
    status = "Monitor";
  }
  return regression({
    id: "greedy_economy",
    name: "Greedy Economy Collapse",
    status,
    normal: "Greedy is risky but survives openings; failures read as conversion or pacing rather than raw weakness.",
    warning: ">=65% timeout rate with <25% win rate across repeated extended rows.",
    strong: ">=75% timeout/loss rate plus resource surplus remaining high across multiple nodes.",
    current: `${formatPercent(profile.winRate)} win rate; ${formatPercent(profile.timeoutRate)} timeout rate; ${formatNumber(profile.averageResourceSurplus)} average resource surplus.`,
    action: "Monitor conversion clarity and pacing; keep human testing first.",
    doNotDo: "Do not buff economy just because greed is risky or timeout-prone.",
    evidence: [
      `${profile.profileName}: ${formatRecord(profile.record)} across ${profile.totalRuns} extended metric rows.`,
      `First-wave survived rate: ${formatPercent(firstWaveSafeRate)}; conversion/clear-speed timeouts: ${conversionTimeouts}.`
    ],
    humanTestingNeeded: true
  });
}

function classifyFastArmyTrivialization(context: RegressionThresholdContext): ScenarioLabWatchpointRegression {
  const profile = requireProfile(context.profileComparisons, "fast_army");
  const cinderfenRuns = context.runMetrics.filter((metric) => metric.profileId === "fast_army" && isCinderfenNode(metric.nodeId));
  const cinderfenWinRate = rate(cinderfenRuns.filter((metric) => metric.result === "victory").length, cinderfenRuns.length);
  const failureRate = profile.lossRate + profile.timeoutRate;
  let status: ScenarioLabRegressionStatus = "OK";
  if (cinderfenWinRate >= 0.96 && failureRate <= 0.1 && profile.averageUnitLosses <= 1.5) {
    status = "Warning";
  } else if (cinderfenWinRate >= 0.85) {
    status = "Monitor";
  }
  return regression({
    id: "fast_army",
    name: "Fast Army Trivialization",
    status,
    normal: "Fast Army is faster and often good in Cinderfen but still has failures elsewhere.",
    warning: ">=96% Cinderfen win rate, <=10% whole-profile failure rate, and <=1.5 average losses.",
    strong: "Cinderfen sweep plus whole-suite sweep across repeated runs.",
    current: `${formatPercent(cinderfenWinRate)} Cinderfen win rate; ${formatPercent(failureRate)} whole-profile failure rate.`,
    action: "Monitor Cinderfen speed and ask humans whether it feels decisive or trivial.",
    doNotDo: "Do not slow Fast Army just because it is the fastest route.",
    evidence: [
      `${profile.profileName}: ${formatRecord(profile.record)} across ${profile.totalRuns} extended metric rows.`,
      `Cinderfen Fast Army wins: ${cinderfenRuns.filter((metric) => metric.result === "victory").length}/${cinderfenRuns.length}.`
    ],
    humanTestingNeeded: true
  });
}

function classifyEarlyDefeatSpike(context: RegressionThresholdContext): ScenarioLabWatchpointRegression {
  const earlyRuns = context.runMetrics.filter((metric) => metric.nodeId === "border_village" || metric.nodeId === "old_stone_road");
  const defeatRate = rate(earlyRuns.filter((metric) => metric.result === "defeat").length, earlyRuns.length);
  const earlyPressureDefeatRate = rate(earlyRuns.filter((metric) => metric.failureReason === "early_pressure_defeat").length, earlyRuns.length);
  const status: ScenarioLabRegressionStatus = defeatRate >= 0.15 ? "Strong signal" : defeatRate >= 0.05 ? "Warning" : "OK";
  return regression({
    id: "early_defeats",
    name: "Early Defeat Spike",
    status,
    normal: "Early-node defeats remain near zero in automation.",
    warning: ">=5% early-node defeat rate.",
    strong: ">=15% early-node defeat rate or repeated early-pressure defeats.",
    current: `${formatPercent(defeatRate)} early defeat rate; ${formatPercent(earlyPressureDefeatRate)} early-pressure defeat rate.`,
    action: status === "OK" ? "No change." : "Inspect early-node clarity before tuning.",
    doNotDo: "Do not weaken early tests or mask first-wave failures.",
    evidence: [`Early-node record: ${formatRecord(recordFor(earlyRuns))} across ${earlyRuns.length} extended metric rows.`],
    humanTestingNeeded: false
  });
}

function classifyPressureWarningFairness(context: RegressionThresholdContext): ScenarioLabWatchpointRegression {
  const pressureRuns = context.runMetrics.filter((metric) => metric.pressureTriggered || metric.pressureWarningCount > 0 || isCinderfenNode(metric.nodeId));
  const safeRuns = pressureRuns.filter((metric) => metric.profileId === "safe_beginner");
  const safeWinRate = rate(safeRuns.filter((metric) => metric.result === "victory").length, safeRuns.length);
  const warningRate = rate(pressureRuns.filter((metric) => metric.pressureWarningCount > 0).length, pressureRuns.length);
  const averageWindow = nullableAverage(pressureRuns.map((metric) => metric.pressureReactionWindowSeconds));
  let status: ScenarioLabRegressionStatus = "Human testing required";
  if (safeWinRate < 0.9 || warningRate < 0.5) {
    status = "Warning";
  }
  return regression({
    id: "pressure_fairness",
    name: "Pressure Warning Fairness",
    status,
    normal: "Safe routes win pressure nodes and warnings appear before pressure matters.",
    warning: "<90% safe-route pressure win rate, warnings missing from most pressure rows, or very short reaction windows.",
    strong: "Repeated safe-route pressure defeats with missing/late warnings.",
    current: `${formatPercent(safeWinRate)} Safe Beginner pressure-node win rate; ${formatPercent(warningRate)} warning-row rate; average reaction window ${formatNullableSeconds(averageWindow)}.`,
    action: "Human testing required for noticeability and stress.",
    doNotDo: "Do not treat warning counts as proof that humans saw or understood warnings.",
    evidence: [
      `Pressure/Cinderfen rows: ${pressureRuns.length}.`,
      `Pressure warnings shown: ${pressureRuns.reduce((total, metric) => total + metric.pressureWarningCount, 0)}.`
    ],
    humanTestingNeeded: true
  });
}

function classifyCinderfenNodeFairness(
  context: RegressionThresholdContext,
  id: "cinderfen_crossing_fairness" | "cinderfen_watch_fairness",
  name: string,
  nodeId: "cinderfen_crossing" | "cinderfen_watch"
): ScenarioLabWatchpointRegression {
  const nodeRuns = context.runMetrics.filter((metric) => metric.nodeId === nodeId);
  const safeRuns = nodeRuns.filter((metric) => metric.profileId === "safe_beginner");
  const safeWinRate = rate(safeRuns.filter((metric) => metric.result === "victory").length, safeRuns.length);
  const timeoutRate = rate(nodeRuns.filter((metric) => metric.result === "timeout").length, nodeRuns.length);
  const status: ScenarioLabRegressionStatus = safeWinRate < 1 ? "Warning" : timeoutRate >= 0.45 ? "Monitor" : "OK";
  return regression({
    id,
    name,
    status,
    normal: "Safe Beginner wins all current rows; other route timeouts can remain monitor items.",
    warning: "Any repeated Safe Beginner failure or >=45% route timeout rate.",
    strong: "Safe-route losses/timeouts across repeated runs.",
    current: `${formatPercent(safeWinRate)} Safe Beginner win rate; ${formatPercent(timeoutRate)} all-profile timeout rate.`,
    action: status === "OK" ? "No structural tuning; prioritize human route feel." : "Inspect route pacing before any tuning.",
    doNotDo: "Do not tune Cinderfen from non-safe route timeouts alone.",
    evidence: [`${name.replace(" Fairness", "")} record: ${formatRecord(recordFor(nodeRuns))} across ${nodeRuns.length} extended metric rows.`],
    humanTestingNeeded: true
  });
}

function classifyAshenOutpostTimeouts(context: RegressionThresholdContext): ScenarioLabWatchpointRegression {
  const node = requireNode(context.nodeRiskDashboard, "ashen_outpost");
  let status: ScenarioLabRegressionStatus = "OK";
  if (node.timeoutRate >= 0.35) {
    status = "Monitor";
  }
  if (node.lossRate >= 0.1) {
    status = "Warning";
  }
  return regression({
    id: "ashen_outpost_stability",
    name: "Ashen Outpost Timeout Spike",
    status,
    normal: "Safe play remains stable, with route timeouts watched as pacing/final-assault evidence.",
    warning: "Any repeated safe-route failures or >=10% defeat rate.",
    strong: "Safe-route failures plus high timeout rate across repeated batches.",
    current: `${formatPercent(node.timeoutRate)} timeout rate; ${formatPercent(node.lossRate)} defeat rate.`,
    action: "Monitor final-assault pacing and ask humans whether timeouts feel fair.",
    doNotDo: "Do not change Ashen Outpost numbers from timeout telemetry alone.",
    evidence: [`Ashen Outpost record: ${formatRecord(node.record)} across ${node.totalRuns} extended metric rows.`],
    humanTestingNeeded: true
  });
}

function classifyObjectiveCompletionDrop(context: RegressionThresholdContext): ScenarioLabWatchpointRegression {
  const completionRate = rate(context.runMetrics.filter((metric) => metric.primaryObjectiveCompleted).length, context.runMetrics.length);
  const status: ScenarioLabRegressionStatus = completionRate < 0.45 ? "Strong signal" : completionRate < 0.55 ? "Warning" : completionRate < 0.7 ? "Monitor" : "OK";
  return regression({
    id: "objective_completion_drop",
    name: "Objective Completion Drop",
    status,
    normal: "Primary objective completion stays at or above 70% across overlapped extended profile rows.",
    warning: "<55% primary objective completion rate.",
    strong: "<45% primary objective completion rate.",
    current: `${formatPercent(completionRate)} primary objective completion rate.`,
    action: status === "OK" ? "No change." : "Inspect node/profile combinations before any gameplay proposal.",
    doNotDo: "Do not infer player confusion from objective completion alone.",
    evidence: [`Primary objective completed in ${context.runMetrics.filter((metric) => metric.primaryObjectiveCompleted).length}/${context.runMetrics.length} extended metric rows.`],
    humanTestingNeeded: status !== "OK"
  });
}

function classifyResourceStarvationSpike(context: RegressionThresholdContext): ScenarioLabWatchpointRegression {
  const shortageRuns = context.runMetrics.filter((metric) => metric.resourceSurplus < 250 && metric.result !== "victory");
  const shortageRate = rate(shortageRuns.length, context.runMetrics.length);
  const status: ScenarioLabRegressionStatus = shortageRate >= 0.35 ? "Future systems pass" : shortageRate >= 0.2 ? "Warning" : shortageRate >= 0.1 ? "Monitor" : "OK";
  return regression({
    id: "resource_starvation_spike",
    name: "Resource Starvation Spike",
    status,
    normal: "Resource problems are localized, not a global economy starvation signal.",
    warning: ">=20% non-victory rows end with very low resource surplus.",
    strong: ">=35% non-victory starvation rows, suggesting future economy-system review.",
    current: `${formatPercent(shortageRate)} low-resource non-victory row rate.`,
    action: status === "OK" ? "No change." : "Review economy clarity before any resource tuning.",
    doNotDo: "Do not globally raise resources without node/profile evidence.",
    evidence: [`Low-resource non-victory rows: ${shortageRuns.length}/${context.runMetrics.length}.`],
    humanTestingNeeded: false
  });
}

function regression(input: {
  id: ScenarioLabWatchpointId;
  name: string;
  status: ScenarioLabRegressionStatus;
  normal: string;
  warning: string;
  strong: string;
  current: string;
  action: string;
  doNotDo: string;
  evidence: string[];
  humanTestingNeeded: boolean;
}): ScenarioLabWatchpointRegression {
  return {
    watchpointId: input.id,
    watchpointName: input.name,
    status: input.status,
    normalExpectedState: input.normal,
    warningThreshold: input.warning,
    strongSignalThreshold: input.strong,
    currentSignal: input.current,
    recommendedAction: input.action,
    doNotDo: input.doNotDo,
    evidence: input.evidence,
    humanTestingNeeded: input.humanTestingNeeded
  };
}

function requireProfile(profiles: ScenarioLabProfileComparison[], profileId: ScenarioLabProfileComparison["profileId"]): ScenarioLabProfileComparison {
  const profile = profiles.find((entry) => entry.profileId === profileId);
  if (!profile) {
    throw new Error(`Missing profile comparison: ${profileId}`);
  }
  return profile;
}

function requireNode(nodes: ScenarioLabNodeRiskDashboardEntry[], nodeId: string): ScenarioLabNodeRiskDashboardEntry {
  const node = nodes.find((entry) => entry.nodeId === nodeId);
  if (!node) {
    throw new Error(`Missing node dashboard entry: ${nodeId}`);
  }
  return node;
}

function recordFor(metrics: ScenarioLabExtendedRunMetric[]): ScenarioLabRecord {
  return {
    wins: metrics.filter((metric) => metric.result === "victory").length,
    defeats: metrics.filter((metric) => metric.result === "defeat").length,
    timeouts: metrics.filter((metric) => metric.result === "timeout").length
  };
}

function rate(numerator: number, denominator: number): number {
  return denominator > 0 ? numerator / denominator : 0;
}

function nullableAverage(values: Array<number | null>): number | null {
  const numeric = values.filter((value): value is number => value !== null && Number.isFinite(value));
  if (numeric.length === 0) {
    return null;
  }
  return numeric.reduce((total, value) => total + value, 0) / numeric.length;
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

function formatNullableSeconds(value: number | null): string {
  return value === null ? "unavailable" : `${formatNumber(value)}s`;
}

function isWatchpointNode(nodeId: string): boolean {
  return nodeId === "ashen_outpost" || isCinderfenNode(nodeId);
}

function isCinderfenNode(nodeId: string): boolean {
  return nodeId === "cinderfen_crossing" || nodeId === "cinderfen_watch";
}
