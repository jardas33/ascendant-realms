import { STRONGHOLD_UPGRADE_BY_ID } from "../data/strongholdUpgrades";
import type {
  PlaytestAnalysis,
  PlaytestNodeSummary,
  PlaytestRewardTelemetry,
  PlaytestResult,
  PlaytestStrongholdProfileSummary,
  PlaytestTelemetry
} from "./PlaytestTypes";

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
  const enemyPressureWarnings = buildEnemyPressureWarnings(runs, nodeSummaries);

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
    enemyPressureWarnings,
    suggestedTuningChanges: buildSuggestedTuningChanges({
      nodeSummaries,
      tooEasyNodes,
      tooHardNodes,
      unfairFirstAttackNodes,
      barracksLateBeforePressure,
      weakRewardNodes,
      ashenOutpostBeatable,
      strongholdWarnings,
      enemyPressureWarnings
    }),
    strongholdProfileSummaries,
    nodeSummaries
  };
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
  enemyPressureWarnings: string[];
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
  input.enemyPressureWarnings.forEach((warning) => suggestions.push(warning));
  suggestions.push("Use this bot to guide conservative numeric passes, and reserve deeper map or objective changes for a later review.");
  return suggestions;
}

function buildEnemyPressureWarnings(runs: PlaytestTelemetry[], nodeSummaries: PlaytestNodeSummary[]): string[] {
  const pressureRuns = runs.filter((run) => run.enemyPressurePlanId);
  if (pressureRuns.length === 0) {
    return [];
  }
  return uniqueValues(
    pressureRuns
      .map((run) => run.enemyPressurePlanId)
      .filter((planId): planId is string => Boolean(planId))
  ).flatMap((planId) => {
    const planRuns = pressureRuns.filter((run) => run.enemyPressurePlanId === planId);
    const warnings: string[] = [];
    const triggeredRuns = planRuns.filter((run) => run.triggeredStages.length > 0);
    if (triggeredRuns.length === 0) {
      warnings.push(`${planId}: pressure trivial risk; no simulated stages triggered.`);
    }
    if (triggeredRuns.length > 0 && triggeredRuns.every((run) => run.pressureWarningsShown === 0)) {
      warnings.push(`${planId}: pressure invisible risk; stages triggered without warning telemetry.`);
    }
    const tooHardSummaries = nodeSummaries.filter(
      (summary) =>
        summary.verdict === "too_hard" &&
        planRuns.some((run) => run.nodeId === summary.nodeId && run.strongholdProfileId === summary.strongholdProfileId)
    );
    if (tooHardSummaries.length > 0) {
      warnings.push(
        `${planId}: pressure too-punishing risk; structural too-hard appeared on ${tooHardSummaries
          .map(formatSummaryLabel)
          .join(", ")}.`
      );
    }
    return warnings;
  });
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


export function formatSummaryLabel(summary: PlaytestNodeSummary): string {
  return `${summary.strongholdProfileName} / ${summary.nodeName}`;
}


function uniqueValues<T>(values: T[]): T[] {
  return [...new Set(values)];
}
