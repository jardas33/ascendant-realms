import type { BattleRewardResult, ItemDefinition, ItemInstance } from "../core/GameTypes";
import { getActiveHeroBuildSynergy } from "../core/HeroProgressionRules";
import type { HeroSaveData } from "../save/SaveTypes";
import type { HeroProgressionCatalogs } from "./HeroProgressionViewModel";
import {
  escapeHtml,
  formatItemAffixes,
  formatItemAffixStats,
  formatItemBaseStats,
  formatItemTotalStats,
  formatRelicItemBuildText,
  formatTags,
  previewEquipDelta,
  rarityClass,
  renderItemName,
  titleCase
} from "./ItemComparison";

export interface InventoryPanelViewModel {
  rows: InventoryRowViewModel[];
}

export interface InventoryRowViewModel {
  instanceId: string;
  source: string;
  slotLabel: string;
  baseStatModsText: string;
  affixText: string;
  affixStatModsText: string;
  totalStatModsText: string;
  tagsText: string;
  buildIdentityText?: string;
  synergyText?: string;
  ownedStateText: string;
  description: string;
  flavorText: string;
  itemNameHtml: string;
  rarityClassName: string;
  statPreviewText: string;
  rewarded: boolean;
  equipped: boolean;
  equipText: string;
}

export interface InventoryPanelOptions {
  heroSave: HeroSaveData;
  rewardItemIds: string[];
  reward?: BattleRewardResult;
  catalogs: HeroProgressionCatalogs;
}

export function createInventoryViewModel({ heroSave, rewardItemIds, reward, catalogs }: InventoryPanelOptions): InventoryPanelViewModel {
  const activeSynergy = getActiveHeroBuildSynergy(heroSave, catalogs.skillNodeById, catalogs.itemById);
  const rows = heroSave.inventory
    .map((instance) => ({ instance, item: catalogs.itemById[instance.itemId] }))
    .filter((entry): entry is { instance: ItemInstance; item: ItemDefinition } => entry.item !== undefined)
    .map(({ instance, item }) => {
      const equipped = heroSave.equipment[item.slot] === instance.instanceId;
      const rewarded = rewardItemIds.includes(item.id) || (reward?.itemInstances ?? []).some((rewardInstance) => rewardInstance.instanceId === instance.instanceId);
      const equipText = rewarded && !equipped ? "Equip Now" : equipped ? "Equipped" : "Equip";

      return {
        instanceId: instance.instanceId,
        source: instance.source,
        slotLabel: titleCase(item.slot),
        baseStatModsText: formatItemBaseStats(item),
        affixText: formatItemAffixes(item, instance),
        affixStatModsText: formatItemAffixStats(item, instance),
        totalStatModsText: formatItemTotalStats(item, instance),
        tagsText: formatTags(item.tags),
        buildIdentityText: formatRelicItemBuildText(item),
        synergyText: equipped && item.slot === "relic" && activeSynergy ? `${activeSynergy.summary} ${activeSynergy.abilitySummary}` : undefined,
        ownedStateText: equipped ? "Owned - equipped" : "Owned - available",
        description: item.description,
        flavorText: item.flavorText,
        itemNameHtml: renderItemName(item),
        rarityClassName: rarityClass(item.rarity),
        statPreviewText: previewEquipDelta(heroSave, item, equipped, catalogs, instance.instanceId),
        rewarded,
        equipped,
        equipText
      };
    });

  return { rows };
}

export function renderInventoryPanel(viewModel: InventoryPanelViewModel): string {
  if (viewModel.rows.length === 0) {
    return `<p class="quiet">Win battles to earn equipment rewards.</p>`;
  }
  return `
      <div class="inventory-list">
        ${viewModel.rows
          .map(
            (row) => `
              <div class="inventory-row ${row.rewarded ? "new" : ""} ${row.rarityClassName}">
                <div>
                  <strong>${row.itemNameHtml} ${row.rewarded ? "<span>New</span>" : ""}</strong>
                  <small>Instance: ${escapeHtml(row.instanceId)} - Source: ${escapeHtml(row.source)}</small>
                  <small>${row.slotLabel} - ${escapeHtml(row.totalStatModsText)}</small>
                  <small>${escapeHtml(row.ownedStateText)}</small>
                  <small class="affix-line">${escapeHtml(row.affixText)}</small>
                  <small>${escapeHtml(row.baseStatModsText)}</small>
                  <small>${escapeHtml(row.affixStatModsText)}</small>
                  ${row.buildIdentityText ? `<small>${escapeHtml(row.buildIdentityText)}</small>` : ""}
                  ${row.synergyText ? `<small class="synergy-line">${escapeHtml(row.synergyText)}</small>` : ""}
                  <p>${escapeHtml(row.description)}</p>
                  <small>${escapeHtml(row.flavorText)}</small>
                  <small>${escapeHtml(row.tagsText)}</small>
                  <small class="stat-preview">${escapeHtml(row.statPreviewText)}</small>
                </div>
                <button data-progression-action="equip" data-id="${escapeHtml(row.instanceId)}" ${row.equipped ? "disabled" : ""}>${row.equipText}</button>
              </div>
            `
          )
          .join("")}
      </div>
    `;
}
