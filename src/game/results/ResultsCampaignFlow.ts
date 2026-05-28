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
        <span>Mission reward state</span><strong>${campaign.wasReplay ? "Replay reward" : "First-clear reward"}</strong>
        <span>Campaign node reward</span><strong>${campaign.nodeRewardAlreadyClaimed ? "Already claimed" : "Claimed now"}</strong>
        <span>Unlocked</span><strong>${campaign.unlockedNodeNames.length > 0 ? escapeHtml(campaign.unlockedNodeNames.join(", ")) : "No new nodes"}</strong>
        <span>Node XP</span><strong>${campaign.nodeReward.xp}</strong>
        <span>Node resources added</span><strong>${escapeHtml(formatResourceRewards(campaign.nodeReward.resources))}</strong>
        <span>Duplicate conversion</span><strong>${escapeHtml(formatDuplicateConversions(campaign.nodeReward.duplicateConversions ?? []))}</strong>
        <span>Optional objectives</span><strong>${escapeHtml(formatOptionalObjectiveCredit(campaign.optionalObjectives ?? []))}</strong>
        <span>Campaign bank</span><strong>${escapeHtml(formatResourceRewards(campaign.campaignResources))}</strong>
      </div>
      <p class="quiet reward-note">${escapeHtml(campaignRewardNote(campaign))}</p>
      ${context.renderRewardItems(items)}
    </section>
  `;
}

function formatOptionalObjectiveCredit(objectives: NonNullable<ResultsData["campaignResult"]>["optionalObjectives"]): string {
  if (!objectives || objectives.length === 0) {
    return "None on this mission";
  }
  const newlyRecorded = objectives.filter((objective) => objective.newlyRecorded).length;
  const persisted = objectives.filter((objective) => objective.persisted).length;
  return `${persisted}/${objectives.length} recorded (${newlyRecorded} new this run)`;
}

function campaignRewardNote(campaign: NonNullable<ResultsData["campaignResult"]>): string {
  if (campaign.wasReplay) {
    return campaign.nodeRewardAlreadyClaimed
      ? "Replay clear: reduced repeat battle rewards may apply, but campaign node rewards and objective completion credit do not duplicate."
      : "Replay clear: this old save still had an unclaimed campaign node reward, so it was claimed once and will not duplicate.";
  }
  return "First clear: node resources were added to the persistent campaign bank. Existing town services, event choices, and stronghold upgrades can spend this bank.";
}
