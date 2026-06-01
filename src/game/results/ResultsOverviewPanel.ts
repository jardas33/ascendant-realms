import { getCampaignActResultsGuidance } from "../core/campaign/CampaignActSpineRules";
import { getCampaignMissionBriefing } from "../core/campaign/CampaignMissionRules";
import { formatTime } from "../core/MathUtils";
import { CAMPAIGN_NODE_BY_ID } from "../data/contentIndex";
import { escapeHtml, formatResourceRewards } from "./ResultsFormatting";
import type { ResultsData } from "./ResultsTypes";
import type { ResultsViewModel } from "./ResultsViewModel";

export function renderResultsOverview(data: ResultsData, viewModel: ResultsViewModel): string {
  const missionName = data.campaignResult?.completedNodeName ?? viewModel.map?.name ?? data.launchRequest?.mapId ?? "Unknown battlefield";
  return `
    <section class="results-overview" data-testid="results-overview">
      <div class="results-overview-heading">
        <div>
          <p class="eyebrow">${viewModel.isVictory ? "Mission Complete" : "Mission Failed"}</p>
          <h2>${escapeHtml(missionName)}</h2>
        </div>
        <strong class="results-outcome-pill ${data.stats.outcome}">${viewModel.isVictory ? "Victory" : "Defeat"}</strong>
      </div>
      <div class="results-overview-grid">
        <span>Time</span><strong>${formatTime(data.stats.timeSeconds)}</strong>
        <span>Primary objective</span><strong>${escapeHtml(formatPrimaryObjective(data))}</strong>
        <span>Key rewards</span><strong>${escapeHtml(formatKeyRewards(data, viewModel))}</strong>
        <span>Hero XP</span><strong>${escapeHtml(formatHeroXp(data, viewModel))}</strong>
        <span>Veterans</span><strong>${escapeHtml(formatVeteranHighlight(data))}</strong>
        <span>Next action</span><strong>${escapeHtml(formatNextAction(data, viewModel))}</strong>
      </div>
    </section>
  `;
}

function formatPrimaryObjective(data: ResultsData): string {
  if (data.launchRequest?.privatePlaytestDemoId) {
    return data.stats.outcome === "victory" ? "Private demo objective complete" : "Private demo unresolved";
  }
  if (data.launchRequest?.mode === "tutorial") {
    return data.stats.outcome === "victory" ? "Training complete" : "Training attempt failed";
  }
  if (data.campaignResult?.wasReplay) {
    return data.stats.outcome === "victory" ? "Replay clear" : "Replay failed";
  }
  if (data.campaignResult) {
    const node = CAMPAIGN_NODE_BY_ID[data.campaignResult.completedNodeId];
    const briefing = node ? getCampaignMissionBriefing(node) : undefined;
    const objective = briefing?.primaryObjective ?? "Complete the campaign mission.";
    const outcome = data.stats.outcome === "victory" ? "Secured" : "Failed";
    return `${outcome}: ${objective}`;
  }
  return data.stats.outcome === "victory" ? "Battle won" : "Battle lost";
}

function formatKeyRewards(data: ResultsData, viewModel: ResultsViewModel): string {
  if (data.stats.outcome !== "victory") {
    return "No victory rewards saved";
  }
  if (data.launchRequest?.mode === "tutorial") {
    return "Tutorial is no-save and no-reward";
  }
  if (data.launchRequest?.privatePlaytestDemoId) {
    return "Private demo rewards disabled";
  }
  if (data.relicRewardChoice) {
    return `Relic choice available; ${data.relicRewardChoice.choiceLabel}`;
  }
  if (data.relicReward) {
    return data.relicReward.status === "granted"
      ? `${data.relicReward.item.name} added to inventory`
      : `${data.relicReward.item.name} duplicate converted`;
  }

  const battleResources = data.reward ? formatResourceRewards(data.reward.resources) : "None";
  const campaignResources = data.campaignResult ? formatResourceRewards(data.campaignResult.nodeReward.resources) : "None";
  const rewardParts = [
    viewModel.rewardItemCount > 0 ? `${viewModel.rewardItemCount} item reward${viewModel.rewardItemCount === 1 ? "" : "s"}` : "",
    data.campaignResult?.wasReplay ? "Replay-safe rewards" : data.campaignResult ? "First-clear rewards" : "",
    battleResources !== "None" ? battleResources : "",
    campaignResources !== "None" ? campaignResources : ""
  ].filter(Boolean);
  return rewardParts.length > 0 ? rewardParts.join("; ") : "Rewards applied";
}

function formatHeroXp(data: ResultsData, viewModel: ResultsViewModel): string {
  if (data.stats.outcome !== "victory" || data.launchRequest?.mode === "tutorial" || data.launchRequest?.privatePlaytestDemoId) {
    return "No persistent XP change";
  }
  const levelCopy =
    viewModel.xp.levelsGained > 0
      ? `; level ${viewModel.xp.beforeHero.level} to ${viewModel.xp.afterHero.level}`
      : `; level ${viewModel.xp.afterHero.level}`;
  const skillCopy = viewModel.skillPointsGained > 0 ? `; +${viewModel.skillPointsGained} skill point` : "";
  return `${data.stats.xpGained} battle XP${levelCopy}${skillCopy}`;
}

function formatVeteranHighlight(data: ResultsData): string {
  const summary = data.stats.veteranSummary;
  if (!summary || data.stats.outcome !== "victory") {
    return "None highlighted";
  }
  if (summary.rankedUpUnits.length > 0) {
    const first = summary.rankedUpUnits[0];
    return `${first.unitName} reached ${first.rankName}`;
  }
  if (summary.topSurvivor) {
    return `${summary.topSurvivor.unitName} led survivors`;
  }
  return "Veteran progress recorded";
}

function formatNextAction(data: ResultsData, viewModel: ResultsViewModel): string {
  if (data.stats.outcome !== "victory") {
    return data.launchRequest?.mode === "tutorial" ? "Retry Tutorial or return to Main Menu" : "Retry or return to prep";
  }
  if (data.launchRequest?.mode === "tutorial") {
    return "Return to Main Menu";
  }
  if (data.launchRequest?.privatePlaytestDemoId) {
    return "Return to Campaign Map or replay the demo";
  }
  if (data.relicRewardChoice) {
    return "Choose a relic, then equip or return";
  }
  if (data.campaignResult) {
    const guidance = getCampaignActResultsGuidance({
      completedNodeId: data.campaignResult.completedNodeId,
      wasReplay: data.campaignResult.wasReplay,
      unlockedNodeNames: data.campaignResult.unlockedNodeNames,
      optionalObjectives: data.campaignResult.optionalObjectives,
      rewardItemCount: viewModel.rewardItemCount,
      skillPointsGained: viewModel.skillPointsGained
    });
    if (guidance?.nextAction) {
      return guidance.nextAction;
    }
  }
  if (data.campaignResult?.unlockedNodeNames.length) {
    return `Next mission unlocked: ${data.campaignResult.unlockedNodeNames.join(", ")}`;
  }
  if (data.campaignResult?.wasReplay) {
    return "Return to Campaign Map or replay again";
  }
  return "Return to Campaign Map or open Hero Inventory";
}
