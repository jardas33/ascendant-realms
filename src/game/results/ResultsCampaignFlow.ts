import { buildRewardItemPresentations } from "../core/ResultsFlow";
import { getCampaignMissionBriefing, getCampaignScenarioModifierDefinitions } from "../core/campaign/CampaignMissionRules";
import type { CampaignNodeDefinition } from "../core/GameTypes";
import { CAMPAIGN_NODE_BY_ID, ITEM_BY_ID } from "../data/contentIndex";
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
  const node = CAMPAIGN_NODE_BY_ID[campaign.completedNodeId];
  const briefing = node ? getCampaignMissionBriefing(node) : undefined;
  const scenarioModifiers = node ? activeScenarioModifiers(data, node) : [];
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
        <span>Mission type</span><strong>${escapeHtml(briefing?.missionType?.name ?? "Campaign battle")}</strong>
        <span>Primary objective</span><strong>${escapeHtml(briefing?.primaryObjective ?? "Complete the mission.")}</strong>
        <span>Scenario modifiers</span><strong>${escapeHtml(formatScenarioModifiers(scenarioModifiers))}</strong>
        <span>Mission reward state</span><strong>${campaign.wasReplay ? "Replay reward" : "First-clear reward"}</strong>
        <span>Campaign node reward</span><strong>${campaign.nodeRewardAlreadyClaimed ? "Already claimed" : "Claimed now"}</strong>
        <span>Unlocked</span><strong>${campaign.unlockedNodeNames.length > 0 ? escapeHtml(campaign.unlockedNodeNames.join(", ")) : "No new nodes"}</strong>
        <span>Node XP</span><strong>${campaign.nodeReward.xp}</strong>
        <span>Node resources added</span><strong>${escapeHtml(formatResourceRewards(campaign.nodeReward.resources))}</strong>
        <span>Duplicate conversion</span><strong>${escapeHtml(formatDuplicateConversions(campaign.nodeReward.duplicateConversions ?? []))}</strong>
        <span>Optional objectives</span><strong>${escapeHtml(formatOptionalObjectiveCredit(campaign.optionalObjectives ?? []))}</strong>
        <span>Campaign bank</span><strong>${escapeHtml(formatResourceRewards(campaign.campaignResources))}</strong>
      </div>
      <p class="quiet reward-note">${escapeHtml(briefing?.afterActionSummary ?? "Mission state recorded.")}</p>
      <p class="quiet reward-note">${escapeHtml(campaignRewardNote(campaign))}</p>
      ${context.renderRewardItems(items)}
    </section>
  `;
}

function activeScenarioModifiers(
  data: ResultsData,
  node: CampaignNodeDefinition
): ReturnType<typeof getCampaignScenarioModifierDefinitions> {
  const missionModifiers = getCampaignScenarioModifierDefinitions(node);
  const activeIds = new Set(data.launchRequest?.modifiers.map((modifier) => modifier.id) ?? missionModifiers.map((modifier) => modifier.id));
  return missionModifiers.filter((modifier) => activeIds.has(modifier.id));
}

function formatScenarioModifiers(modifiers: ReturnType<typeof getCampaignScenarioModifierDefinitions>): string {
  if (modifiers.length === 0) {
    return "None";
  }
  return modifiers.map((modifier) => `${modifier.name}: ${modifier.description}`).join("; ");
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
