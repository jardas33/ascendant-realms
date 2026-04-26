import type { CampaignNodeDefinition, CampaignNodeStatus } from "../core/GameTypes";
import { getCampaignChoiceAvailability } from "../core/CampaignRules";
import { heroOwnsCatalogItem } from "../core/HeroProgressionRules";
import { CAMPAIGN_MODIFIER_BY_ID, FACTION_BY_ID, ITEM_BY_ID } from "../data/contentIndex";
import type { CampaignSaveData, HeroSaveData } from "../save/SaveTypes";
import { formatCampaignNodeList } from "./CampaignNavigation";
import { escapeHtml, titleCase } from "./CampaignPresentationTypes";
import { formatResourceRewards } from "./CampaignResourcePanel";
import { isTownServiceNode, repeatabilityLabel, townServiceActionLabel } from "./CampaignTownServicesPanel";

export type CampaignChoiceDefinition = NonNullable<CampaignNodeDefinition["choices"]>[number];

interface RenderEventChoicesOptions {
  node: CampaignNodeDefinition;
  status: CampaignNodeStatus;
  campaignSave: CampaignSaveData;
  heroSave: HeroSaveData;
}

export function renderEventChoices(options: RenderEventChoicesOptions): string {
  const { node, status, campaignSave, heroSave } = options;
  const isTown = isTownServiceNode(node);
  return `
      <div class="event-choice-list ${isTown ? "town-service-list" : ""}">
        <h4>${isTown ? "Town Services" : "Choices"}</h4>
        ${node.choices
          ?.map((choice) => {
            const availability = getCampaignChoiceAvailability({
              campaign: campaignSave,
              hero: heroSave,
              node,
              choice
            });
            const locked = status === "locked" || !availability.ok;
            const reason = availability.reasons.join(", ");
            const stock = choice.stockItemId ? ITEM_BY_ID[choice.stockItemId] : undefined;
            return `
              <button class="choice event-choice ${locked ? "locked" : ""}" data-campaign-choice="${choice.id}" ${locked ? "disabled" : ""}>
                <strong>${escapeHtml(choice.label)}</strong>
                <span>${escapeHtml(choice.description)}</span>
                ${stock ? `<small>Stock: ${escapeHtml(stock.name)} - ${titleCase(stock.rarity)} ${titleCase(stock.slot)}</small>` : ""}
                <small>Cost: ${escapeHtml(formatResourceRewards(choice.costs ?? {}).join(", ") || "None")}</small>
                <small>Reward: ${escapeHtml(formatChoiceRewardSummary(choice, heroSave) || "None")}</small>
                <small>${locked ? escapeHtml(reason || "Locked") : isTown ? repeatabilityLabel(choice) : choice.completesNode === false ? "Keeps this node open." : "Completes this node."}</small>
                <span class="choice-cta">${isTown ? townServiceActionLabel(Boolean(stock)) : "Choose"}</span>
              </button>
            `;
          })
          .join("")}
      </div>
    `;
}

export function formatChoiceRewardSummary(choice: CampaignChoiceDefinition, heroSave: HeroSaveData): string {
  const rewards: string[] = [];
  if (choice.rewards?.xp) {
    rewards.push(`${choice.rewards.xp} XP`);
  }
  rewards.push(...formatResourceRewards(choice.rewards?.resources ?? {}));
  (choice.rewards?.itemIds ?? []).forEach((itemId) => rewards.push(ITEM_BY_ID[itemId]?.name ?? itemId));
  [...(choice.modifierIds ?? []), ...(choice.rewards?.modifierIds ?? [])].forEach((modifierId) => {
    rewards.push(`Modifier: ${CAMPAIGN_MODIFIER_BY_ID[modifierId]?.name ?? titleCase(modifierId)}`);
  });
  const reputationChanges = {
    ...(choice.reputationChanges ?? {}),
    ...(choice.rewards?.reputationChanges ?? {})
  };
  Object.entries(reputationChanges).forEach(([factionId, amount]) => {
    rewards.push(`${amount > 0 ? "+" : ""}${amount} ${FACTION_BY_ID[factionId]?.name ?? titleCase(factionId)} reputation`);
  });
  (choice.unlockNodeIds ?? []).forEach((nodeId) => rewards.push(`Unlock ${formatCampaignNodeList([nodeId])}`));
  (choice.rewards?.unlockNodeIds ?? []).forEach((nodeId) => rewards.push(`Unlock ${formatCampaignNodeList([nodeId])}`));
  (choice.lockNodeIds ?? []).forEach((nodeId) => rewards.push(`Lock ${formatCampaignNodeList([nodeId])}`));
  (choice.rewards?.lockNodeIds ?? []).forEach((nodeId) => rewards.push(`Lock ${formatCampaignNodeList([nodeId])}`));
  [...(choice.removeModifierIds ?? []), ...(choice.rewards?.removeModifierIds ?? [])].forEach((modifierId) => {
    rewards.push(`Remove ${CAMPAIGN_MODIFIER_BY_ID[modifierId]?.name ?? titleCase(modifierId)}`);
  });
  if (choice.rewards?.recoverHero) {
    rewards.push("Recover hero");
  }
  if (choice.stockItemId && heroOwnsCatalogItem(heroSave, choice.stockItemId)) {
    rewards.push("Already in inventory");
  }
  return rewards.join(", ");
}
