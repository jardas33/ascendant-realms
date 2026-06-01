import { escapeHtml, formatResourceRewards } from "./ResultsFormatting";
import type { ResultsData } from "./ResultsTypes";
import type { ResultsViewModel } from "./ResultsViewModel";

export function renderResultsMetaProgressionSummary(data: ResultsData, viewModel: ResultsViewModel): string {
  const reward = data.reward ?? { itemIds: data.rewardItemIds ?? [], resources: {}, xp: 0 };
  const relicLine = data.relicRewardChoice
    ? "Relic choice waiting"
    : data.relicReward
      ? data.relicReward.status === "granted"
        ? `${data.relicReward.item.name} added`
        : `${data.relicReward.item.name} duplicate handled`
      : "No relic change";
  const retinueLine = formatRetinueResultsLine(data);
  const strongholdLine = data.campaignResult
    ? `Campaign resources now ${formatResourceRewards(data.campaignResult.campaignResources)}`
    : "No Stronghold consequence";
  const rewardLine =
    data.stats.outcome === "victory"
      ? `${reward.itemIds.length} battle item${reward.itemIds.length === 1 ? "" : "s"}; ${formatResourceRewards(reward.resources)}`
      : "No victory rewards saved";
  return `
    <section class="results-meta-summary" data-testid="results-meta-progress-summary">
      <div class="meta-card-heading">
        <div>
          <p class="eyebrow">Progression Summary</p>
          <h2>What changed</h2>
        </div>
        <span class="tag">${viewModel.xp.afterHero.skillPoints} skill point${viewModel.xp.afterHero.skillPoints === 1 ? "" : "s"}</span>
      </div>
      <div class="meta-summary-grid compact">
        <span><small>Hero XP</small><strong>${escapeHtml(formatResultsXpLine(data, viewModel))}</strong></span>
        <span><small>Rewards</small><strong>${escapeHtml(rewardLine)}</strong></span>
        <span><small>Relics</small><strong>${escapeHtml(relicLine)}</strong></span>
        <span><small>Retinue</small><strong>${escapeHtml(retinueLine)}</strong></span>
        <span><small>Stronghold</small><strong>${escapeHtml(strongholdLine)}</strong></span>
      </div>
    </section>
  `;
}

function formatResultsXpLine(data: ResultsData, viewModel: ResultsViewModel): string {
  if (data.stats.outcome !== "victory" || data.launchRequest?.mode === "tutorial" || data.launchRequest?.privatePlaytestDemoId) {
    return "No persistent XP change";
  }
  const levelLine =
    viewModel.xp.levelsGained > 0
      ? `level ${viewModel.xp.beforeHero.level} to ${viewModel.xp.afterHero.level}`
      : `level ${viewModel.xp.afterHero.level}`;
  const skillLine = viewModel.skillPointsGained > 0 ? `; +${viewModel.skillPointsGained} skill point` : "";
  return `${data.stats.xpGained} XP; ${levelLine}${skillLine}`;
}

function formatRetinueResultsLine(data: ResultsData): string {
  const lost = data.stats.retinueUnitIdsLost?.length ?? 0;
  const recovering = data.stats.retinueUnitIdsRecovering?.length ?? 0;
  const ready = data.stats.retinueUnitIdsReturnedReady?.length ?? 0;
  const notable = data.stats.veteranSummary?.notableVeterans.length ?? 0;
  const parts = [
    notable > 0 ? `${notable} notable veteran${notable === 1 ? "" : "s"}` : "",
    lost > 0 ? `${lost} lost` : "",
    recovering > 0 ? `${recovering} recovering` : "",
    ready > 0 ? `${ready} ready` : "",
    data.stats.retinueReinforcementUsed ? "reinforcement used" : ""
  ].filter(Boolean);
  return parts.length > 0 ? parts.join("; ") : "No Retinue change";
}
