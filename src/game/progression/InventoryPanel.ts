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
  const equippedRows = viewModel.rows.filter((row) => row.equipped);
  const storedRows = viewModel.rows.filter((row) => !row.equipped);
  const relicRows = viewModel.rows.filter((row) => row.slotLabel === "Relic");
  return `
      <div class="inventory-section-grid">
        ${renderInventoryGroup("Equipped", "Currently active loadout", equippedRows, "inventory-equipped-group")}
        ${renderInventoryGroup("Stored", "Available rewards and backups", storedRows, "inventory-stored-group")}
        ${
          relicRows.length > 0
            ? `<section class="inventory-group relics" data-testid="relic-list">
                <div class="inventory-group-header">
                  <div>
                    <strong>Relics</strong>
                    <small>Effects are active only while equipped.</small>
                  </div>
                  <span class="tag">${relicRows.length} owned</span>
                </div>
                <div class="inventory-chip-list">
                  ${relicRows
                    .map(
                      (row) =>
                        `<span class="tag ${row.equipped ? "equipped" : ""}">${row.itemNameHtml.replace(/<span class="rarity-pill.*?<\/span>/u, "")}${row.equipped ? " equipped" : ""}</span>`
                    )
                    .join("")}
                </div>
              </section>`
            : ""
        }
      </div>
    `;
}

function renderInventoryGroup(title: string, subtitle: string, rows: InventoryRowViewModel[], testId: string): string {
  return `
    <section class="inventory-group" data-testid="${testId}">
      <div class="inventory-group-header">
        <div>
          <strong>${escapeHtml(title)}</strong>
          <small>${escapeHtml(subtitle)}</small>
        </div>
        <span class="tag">${rows.length}</span>
      </div>
      ${
        rows.length === 0
          ? `<p class="quiet">None.</p>`
          : `<div class="inventory-list">
              ${rows.map(renderInventoryRow).join("")}
            </div>`
      }
    </section>
  `;
}

function renderInventoryRow(row: InventoryRowViewModel): string {
  return `
    <div class="inventory-row ${row.rewarded ? "new" : ""} ${row.rarityClassName}">
      <div>
        <div class="inventory-row-title">
          <strong>${row.itemNameHtml} ${row.rewarded ? "<span>New</span>" : ""}</strong>
          <span class="tag">${escapeHtml(row.slotLabel)}</span>
        </div>
        <small>${escapeHtml(row.totalStatModsText)}</small>
        <small>${escapeHtml(row.ownedStateText)}</small>
        ${row.buildIdentityText ? `<small>${escapeHtml(row.buildIdentityText)}</small>` : ""}
        ${row.synergyText ? `<small class="synergy-line">${escapeHtml(row.synergyText)}</small>` : ""}
        <small class="stat-preview">${escapeHtml(row.statPreviewText)}</small>
        <details class="support-card-details inventory-row-details">
          <summary>More Details</summary>
          <small>Instance: ${escapeHtml(row.instanceId)} - Source: ${escapeHtml(row.source)}</small>
          <small class="affix-line">${escapeHtml(row.affixText)}</small>
          <small>${escapeHtml(row.baseStatModsText)}</small>
          <small>${escapeHtml(row.affixStatModsText)}</small>
          <p>${escapeHtml(row.description)}</p>
          <small>${escapeHtml(row.flavorText)}</small>
          <small>${escapeHtml(row.tagsText)}</small>
        </details>
      </div>
      <div class="inventory-row-actions">
        <button data-progression-action="equip" data-id="${escapeHtml(row.instanceId)}" ${row.equipped ? "disabled" : ""}>${row.equipText}</button>
        ${row.equipped ? `<small>Use Equipment to unequip.</small>` : `<small>${row.rewarded ? "New reward" : "Ready to equip"}</small>`}
      </div>
    </div>
  `;
}
