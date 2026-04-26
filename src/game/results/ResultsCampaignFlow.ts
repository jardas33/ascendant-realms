import { buildRewardItemPresentations } from "../core/ResultsFlow";
import { ITEM_BY_ID } from "../data/contentIndex";
import { escapeHtml, formatDuplicateConversions, formatResourceRewards } from "./ResultsFormatting";
import type { ResultsData } from "./ResultsTypes";
import type { RewardRenderContext } from "./ResultsRewardPanel";

export function renderCampaignRewards(
  data: ResultsData,
  alreadyPresentedItemIds: string[],
  context: RewardRenderContext
): string {
  const campaign = data.campaignResult;
  if (!campaign) {
    return "";
  }
  const startingInventory = data.startingHeroSave?.inventory ?? [];
  const items = buildRewardItemPresentations({
    itemIds: campaign.nodeReward.itemIds,
    itemInstances: campaign.nodeReward.itemInstances,
    itemById: ITEM_BY_ID,
    startingInventory,
    alreadyPresentedIds: alreadyPresentedItemIds
  });
  return `
    <section class="result-block wide campaign-reward-block">
      <h2>Campaign Node Complete</h2>
      <div class="results-grid compact">
        <span>Completed</span><strong>${escapeHtml(campaign.completedNodeName)}</strong>
        <span>Unlocked</span><strong>${campaign.unlockedNodeNames.length > 0 ? escapeHtml(campaign.unlockedNodeNames.join(", ")) : "No new nodes"}</strong>
        <span>Node XP</span><strong>${campaign.nodeReward.xp}</strong>
        <span>Node resources added</span><strong>${escapeHtml(formatResourceRewards(campaign.nodeReward.resources))}</strong>
        <span>Duplicate conversion</span><strong>${escapeHtml(formatDuplicateConversions(campaign.nodeReward.duplicateConversions ?? []))}</strong>
        <span>Campaign bank</span><strong>${escapeHtml(formatResourceRewards(campaign.campaignResources))}</strong>
      </div>
      <p class="quiet reward-note">Node resources were added to the persistent campaign bank. Shops, mercenaries, repairs, upgrades, node choices, and stronghold development can spend this bank in future systems.</p>
      ${context.renderRewardItems(items)}
    </section>
  `;
}
