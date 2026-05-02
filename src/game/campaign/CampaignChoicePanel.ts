import type { CampaignNodeDefinition, CampaignNodeStatus } from "../core/GameTypes";
import { getCampaignChoiceAvailability } from "../core/CampaignRules";
import { heroOwnsCatalogItem } from "../core/HeroProgressionRules";
import { CAMPAIGN_MODIFIER_BY_ID, FACTION_BY_ID, ITEM_BY_ID } from "../data/contentIndex";
import { getAdjustedCampaignChoiceCost, getAdjustedCampaignChoiceRewards } from "../data/reputation";
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
            const costSummary = formatChoiceCostSummary({ node, choice, heroSave });
            const rewardSummary = formatChoiceRewardSummary(choice, heroSave, node);
            const reputationSummary = formatChoiceReputationSummary(choice, heroSave, node);
            const modifierSummary = formatChoiceModifierSummary(choice, heroSave, node);
            const locked = status === "locked" || !availability.ok;
            const reason = availability.reasons.join(", ");
            const stock = choice.stockItemId ? ITEM_BY_ID[choice.stockItemId] : undefined;
            return `
              <button class="choice event-choice ${locked ? "locked" : ""}" data-campaign-choice="${choice.id}" ${locked ? "disabled" : ""}>
                <strong>${escapeHtml(choice.label)}</strong>
                <span>${escapeHtml(choice.description)}</span>
                ${stock ? `<small>Stock: ${escapeHtml(stock.name)} - ${titleCase(stock.rarity)} ${titleCase(stock.slot)}</small>` : ""}
                <small>Cost: ${escapeHtml(costSummary)}</small>
                <small>Rewards: ${escapeHtml(rewardSummary || "None")}</small>
                <small>Reputation: ${escapeHtml(reputationSummary || "No reputation change")}</small>
                <small>Modifiers: ${escapeHtml(modifierSummary || "None")}</small>
                <small>Outcome: ${escapeHtml(choice.completesNode === false ? "Keeps this node open." : isTown ? repeatabilityLabel(choice) : "Completes this node.")}</small>
                <small>${locked ? escapeHtml(reason || "Locked") : isTown ? repeatabilityLabel(choice) : "Available"}</small>
                <span class="choice-cta">${isTown ? townServiceActionLabel(Boolean(stock)) : "Choose"}</span>
              </button>
            `;
          })
          .join("")}
      </div>
    `;
}

export function formatChoiceCostSummary(options: {
  node: CampaignNodeDefinition;
  choice: CampaignChoiceDefinition;
  heroSave: HeroSaveData;
}): string {
  const adjustedCost = getAdjustedCampaignChoiceCost({
    hero: options.heroSave,
    node: options.node,
    choice: options.choice
  });
  const adjusted = formatResourceRewards(adjustedCost).join(", ") || "None";
  const base = formatResourceRewards(options.choice.costs ?? {}).join(", ") || "None";
  return adjusted === base ? adjusted : `${adjusted} (base ${base})`;
}

export function formatChoiceRewardSummary(
  choice: CampaignChoiceDefinition,
  heroSave: HeroSaveData,
  node?: CampaignNodeDefinition
): string {
  const rewards: string[] = [];
  const adjustedRewards = node
    ? getAdjustedCampaignChoiceRewards({
        hero: heroSave,
        node,
        choice
      })
    : choice.rewards;
  if (adjustedRewards?.xp) {
    rewards.push(`${adjustedRewards.xp} XP`);
  }
  rewards.push(...formatResourceRewards(adjustedRewards?.resources ?? {}));
  (adjustedRewards?.itemIds ?? []).forEach((itemId) => rewards.push(ITEM_BY_ID[itemId]?.name ?? itemId));
  if (node && adjustedRewards?.resources?.aether !== choice.rewards?.resources?.aether && (choice.rewards?.resources?.aether ?? 0) > 0) {
    rewards.push("Old Faith Friendly bonus included");
  }
  (choice.unlockNodeIds ?? []).forEach((nodeId) => rewards.push(`Unlock ${formatCampaignNodeList([nodeId])}`));
  (adjustedRewards?.unlockNodeIds ?? []).forEach((nodeId) => rewards.push(`Unlock ${formatCampaignNodeList([nodeId])}`));
  (choice.lockNodeIds ?? []).forEach((nodeId) => rewards.push(`Lock ${formatCampaignNodeList([nodeId])}`));
  (adjustedRewards?.lockNodeIds ?? []).forEach((nodeId) => rewards.push(`Lock ${formatCampaignNodeList([nodeId])}`));
  if (adjustedRewards?.recoverHero) {
    rewards.push("Recover hero");
  }
  if (choice.stockItemId && heroOwnsCatalogItem(heroSave, choice.stockItemId)) {
    rewards.push("Already in inventory");
  }
  return rewards.join(", ");
}

export function formatChoiceReputationSummary(
  choice: CampaignChoiceDefinition,
  heroSave: HeroSaveData,
  node?: CampaignNodeDefinition
): string {
  const adjustedRewards = node
    ? getAdjustedCampaignChoiceRewards({
        hero: heroSave,
        node,
        choice
      })
    : choice.rewards;
  const reputationChanges = {
    ...(choice.reputationChanges ?? {}),
    ...(adjustedRewards?.reputationChanges ?? {})
  };
  return Object.entries(reputationChanges)
    .map(([factionId, amount]) => `${amount > 0 ? "+" : ""}${amount} ${FACTION_BY_ID[factionId]?.name ?? titleCase(factionId)}`)
    .join(", ");
}

export function formatChoiceModifierSummary(
  choice: CampaignChoiceDefinition,
  heroSave: HeroSaveData,
  node?: CampaignNodeDefinition
): string {
  const adjustedRewards = node
    ? getAdjustedCampaignChoiceRewards({
        hero: heroSave,
        node,
        choice
      })
    : choice.rewards;
  const rewards: string[] = [];
  [...(choice.modifierIds ?? []), ...(adjustedRewards?.modifierIds ?? [])].forEach((modifierId) => {
    rewards.push(`Gain ${CAMPAIGN_MODIFIER_BY_ID[modifierId]?.name ?? titleCase(modifierId)}`);
  });
  [...(choice.removeModifierIds ?? []), ...(adjustedRewards?.removeModifierIds ?? [])].forEach((modifierId) => {
    rewards.push(`Remove ${CAMPAIGN_MODIFIER_BY_ID[modifierId]?.name ?? titleCase(modifierId)}`);
  });
  return rewards.join(", ");
}
