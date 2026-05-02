import type { EquipmentSlot, ItemDefinition } from "../core/GameTypes";
import { buildRewardItemPresentations, createDefeatTips, rewardStateLabel, type RewardItemPresentation, type StatDelta } from "../core/ResultsFlow";
import { ITEM_BY_ID } from "../data/contentIndex";
import { getItemAffixStatMods, getItemInstanceAffixes, getItemTotalStatMods } from "../data/itemAffixes";
import { EQUIPPABLE_SLOTS, heroStatsRows } from "./ResultsEquipActions";
import {
  escapeHtml,
  formatDeltas,
  formatDuplicateConversions,
  formatResourceRewards,
  formatStatMods,
  formatTags,
  titleCase
} from "./ResultsFormatting";
import { renderCampaignRewards } from "./ResultsCampaignFlow";
import type { ResultsData } from "./ResultsTypes";

export interface RewardRenderContext {
  currentItemInSlot: (slot: EquipmentSlot) => ItemDefinition | undefined;
  previewEquipDeltas: (itemInstanceId: string) => StatDelta[];
  renderRewardItems: (items: RewardItemPresentation[]) => string;
}

export function renderVictoryRewards(data: ResultsData, context: Omit<RewardRenderContext, "renderRewardItems">): string {
  const reward = data.reward ?? { itemIds: data.rewardItemIds ?? [], resources: {}, xp: 0 };
  const startingInventory = data.startingHeroSave?.inventory ?? [];
  const battleItems = buildRewardItemPresentations({
    itemIds: reward.itemIds,
    itemInstances: reward.itemInstances,
    itemById: ITEM_BY_ID,
    startingInventory
  });
  const rewardContext: RewardRenderContext = {
    ...context,
    renderRewardItems: (items) => renderRewardItems(data, items, context)
  };
  return `
    <div class="results-sections rewards">
      <section class="result-block wide">
        <h2>Battle Rewards</h2>
        <div class="results-grid compact">
          <span>Reward XP</span><strong>${reward.xp}</strong>
          <span>Resource awards</span><strong>${escapeHtml(formatResourceRewards(reward.resources))}</strong>
          <span>Duplicate conversion</span><strong>${escapeHtml(formatDuplicateConversions(reward.duplicateConversions ?? []))}</strong>
        </div>
        ${rewardContext.renderRewardItems(battleItems)}
      </section>
      ${renderCampaignRewards(data, reward.itemIds, rewardContext)}
    </div>
  `;
}

export function renderRewardItems(
  data: ResultsData,
  items: RewardItemPresentation[],
  context: Omit<RewardRenderContext, "renderRewardItems">
): string {
  if (items.length === 0) {
    return `<p class="quiet reward-note">No new item from this reward group. Your inventory remains unchanged.</p>`;
  }
  return `
    <div class="reward-card-list">
      ${items.map((entry) => renderRewardItem(data, entry, context)).join("")}
    </div>
  `;
}

export function renderDefeatTips(data: ResultsData): string {
  const tips = createDefeatTips(data.stats, {
    hero: data.heroSave,
    mapId: data.launchRequest?.mapId,
    campaignNodeId: data.launchRequest?.campaignNodeId
  });
  return `
    <section class="result-block wide defeat-tips">
      <h2>Next Attempt</h2>
      <ul>
        ${tips.map((tip) => `<li>${escapeHtml(tip)}</li>`).join("")}
      </ul>
    </section>
  `;
}

export function renderHeroStats(data: ResultsData): string {
  return `
    <section class="result-block wide hero-stat-strip">
      <h2>Current Hero Stats</h2>
      <div class="stat-list progression-stats">
        ${heroStatsRows(data.heroSave).map(([label, value]) => `<span>${label} <strong>${Math.round(value)}</strong></span>`).join("")}
      </div>
    </section>
  `;
}

function renderRewardItem(
  data: ResultsData,
  entry: RewardItemPresentation,
  context: Omit<RewardRenderContext, "renderRewardItems">
): string {
  const item = entry.item;
  const equipped = entry.instance ? data.heroSave.equipment[item.slot] === entry.instance.instanceId : false;
  const canEquip = EQUIPPABLE_SLOTS.includes(item.slot);
  const currentItem = context.currentItemInSlot(item.slot);
  const deltas = entry.instance ? context.previewEquipDeltas(entry.instance.instanceId) : [];
  const affixes = entry.instance ? getItemInstanceAffixes(item, entry.instance) : [];
  const affixNames = affixes.length > 0 ? affixes.map((affix) => affix.name).join(", ") : "None";
  const totalStatText = entry.instance ? formatStatMods(getItemTotalStatMods(item, entry.instance)) : formatStatMods(item.statMods);
  const affixStatText = entry.instance ? formatStatMods(getItemAffixStatMods(item, entry.instance)) : "No stat modifiers";
  return `
    <article class="reward-card ${rarityClass(item.rarity)} ${entry.state}">
      <div class="reward-card-main">
        <div>
          <strong>${renderItemName(item)} <span class="reward-state">${escapeHtml(rewardStateLabel(entry.state))}</span></strong>
          ${entry.instance ? `<small>Instance: ${escapeHtml(entry.instance.instanceId)} - Source: ${escapeHtml(entry.instance.source)}</small>` : ""}
          <small>${titleCase(item.slot)} - Total: ${escapeHtml(totalStatText)}</small>
          <small class="affix-line">Affixes: ${escapeHtml(affixNames)}</small>
          <small>Base: ${escapeHtml(formatStatMods(item.statMods))}</small>
          <small>Affix stats: ${escapeHtml(affixStatText)}</small>
          <p>${escapeHtml(item.description)}</p>
          <small>${escapeHtml(item.flavorText)}</small>
          <small>${escapeHtml(formatTags(item.tags))}</small>
          <small>${entry.state === "new" ? "Added to inventory." : "Inventory kept one copy."}</small>
        </div>
        <div class="reward-actions">
          <small>Current ${titleCase(item.slot)}: ${currentItem ? escapeHtml(currentItem.name) : "Empty"}</small>
          <small class="stat-preview">${escapeHtml(formatDeltas(deltas))}</small>
          ${entry.instance && !equipped ? `<small class="reward-action-note">Already saved to inventory. Equip now or keep it for later.</small>` : ""}
          ${
            canEquip
              ? `<button data-results-action="equip" data-item-id="${entry.instance?.instanceId ?? ""}" ${equipped || !entry.instance ? "disabled" : ""}>${equipped ? "Equipped" : entry.instance ? "Equip Now" : "Sent to Inventory"}</button>
                ${
                  entry.instance && !equipped
                    ? `<button data-results-action="keep_inventory" data-item-id="${escapeHtml(entry.instance.instanceId)}">Keep in Inventory</button>`
                    : ""
                }`
              : ""
          }
        </div>
      </div>
    </article>
  `;
}

function renderItemName(item: ItemDefinition): string {
  return `${escapeHtml(item.name)} <span class="rarity-pill ${rarityClass(item.rarity)}">${titleCase(item.rarity)}</span>`;
}

function rarityClass(rarity: ItemDefinition["rarity"]): string {
  return `rarity-${rarity}`;
}
