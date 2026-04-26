import type { EquipmentSlot } from "../core/GameTypes";
import { EQUIPMENT_SLOTS, findItemInstance } from "../core/HeroProgressionRules";
import type { HeroSaveData } from "../save/SaveTypes";
import type { HeroProgressionCatalogs } from "./HeroProgressionViewModel";
import { escapeHtml, formatStatMods, rarityClass, renderItemName, titleCase } from "./ItemComparison";

export interface EquipmentPanelViewModel {
  slots: EquipmentSlotViewModel[];
}

export interface EquipmentSlotViewModel {
  slot: EquipmentSlot;
  slotLabel: string;
  itemNameHtml?: string;
  instanceId?: string;
  statModsText?: string;
  description?: string;
  flavorText?: string;
  rarityClassName?: string;
}

export function createEquipmentViewModel(heroSave: HeroSaveData, catalogs: HeroProgressionCatalogs): EquipmentPanelViewModel {
  const slots = EQUIPMENT_SLOTS.map((slot) => {
    const itemId = heroSave.equipment[slot];
    const instance = itemId ? findItemInstance(heroSave.inventory, itemId) : undefined;
    const item = instance ? catalogs.itemById[instance.itemId] : undefined;

    if (!item) {
      return {
        slot,
        slotLabel: titleCase(slot)
      };
    }

    return {
      slot,
      slotLabel: titleCase(slot),
      itemNameHtml: renderItemName(item),
      instanceId: instance?.instanceId,
      statModsText: formatStatMods(item.statMods),
      description: item.description,
      flavorText: item.flavorText,
      rarityClassName: rarityClass(item.rarity)
    };
  });

  return { slots };
}

export function renderEquipmentPanel(viewModel: EquipmentPanelViewModel): string {
  return `
      <div class="equipment-list">
        ${viewModel.slots
          .map((slot) => {
            const equipped = slot.itemNameHtml !== undefined;
            return `
            <div class="equipment-row ${slot.rarityClassName ?? ""}">
              <div>
                <strong>${slot.slotLabel}</strong>
                ${
                  equipped
                    ? `<span>${slot.itemNameHtml} - ${escapeHtml(slot.statModsText ?? "")}</span>
                      <small>Instance: ${escapeHtml(slot.instanceId ?? "")}</small>
                      <p>${escapeHtml(slot.description ?? "")}</p>
                      <small>${escapeHtml(slot.flavorText ?? "")}</small>`
                    : "<span>Empty</span>"
                }
              </div>
              <button data-progression-action="unequip" data-slot="${slot.slot}" ${equipped ? "" : "disabled"}>Unequip</button>
            </div>
          `;
          })
          .join("")}
      </div>
    `;
}
