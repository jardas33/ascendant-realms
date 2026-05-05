import type { CampaignNodeDefinition, CampaignNodeStatus } from "../core/GameTypes";
import type { CampaignSaveData, HeroSaveData } from "../save/SaveTypes";
import { createCampaignChoiceViewModels } from "./CampaignChoiceViewModel";
import { escapeHtml } from "./CampaignPresentationTypes";
import { isTownServiceNode } from "./CampaignTownServicesPanel";

export type { CampaignChoiceDefinition } from "./CampaignChoiceViewModel";
export {
  formatChoiceCostSummary,
  formatChoiceModifierSummary,
  formatChoiceReputationSummary,
  formatChoiceRewardSummary
} from "./CampaignChoiceViewModel";

interface RenderEventChoicesOptions {
  node: CampaignNodeDefinition;
  status: CampaignNodeStatus;
  campaignSave: CampaignSaveData;
  heroSave: HeroSaveData;
}

export function renderEventChoices(options: RenderEventChoicesOptions): string {
  const { node, status, campaignSave, heroSave } = options;
  const isTown = isTownServiceNode(node);
  const choices = createCampaignChoiceViewModels({ node, status, campaignSave, heroSave });
  return `
      <div class="event-choice-list ${isTown ? "town-service-list" : ""}">
        <h4>${isTown ? "Town Services" : "Choices"}</h4>
        ${choices
          .map((choiceView) => {
            return `
              <button class="choice event-choice ${choiceView.locked ? "locked" : ""}" data-campaign-choice="${choiceView.choice.id}" ${choiceView.locked ? "disabled" : ""}>
                <strong>${escapeHtml(choiceView.choice.label)}</strong>
                <span>${escapeHtml(choiceView.choice.description)}</span>
                ${choiceView.stock ? `<small>Stock: ${escapeHtml(choiceView.stock.name)} - ${escapeHtml(choiceView.stock.rarityLabel)} ${escapeHtml(choiceView.stock.slotLabel)}</small>` : ""}
                <small>Cost: ${escapeHtml(choiceView.costSummary)}</small>
                <small>Rewards: ${escapeHtml(choiceView.rewardSummary || "None")}</small>
                <small>Reputation: ${escapeHtml(choiceView.reputationSummary || "No reputation change")}</small>
                <small>Modifiers: ${escapeHtml(choiceView.modifierSummary || "None")}</small>
                <small>Outcome: ${escapeHtml(choiceView.outcomeSummary)}</small>
                <small>${escapeHtml(choiceView.availabilityLabel)}</small>
                <span class="choice-cta">${escapeHtml(choiceView.ctaLabel)}</span>
              </button>
            `;
          })
          .join("")}
      </div>
    `;
}
