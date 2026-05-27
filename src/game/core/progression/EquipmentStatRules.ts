import type {
  EquipmentSlot,
  HeroStatMods,
  ItemDefinition,
  ItemInstance
} from "../GameTypes";
import type { EquipmentSlots, HeroSaveData } from "../../save/SaveTypes";
import { getItemTotalStatMods } from "../../data/itemAffixes";
import { findItemInstance } from "./AffixRules";
import type { ProgressionActionResult } from "./SkillRules";

export const EQUIPMENT_SLOTS: EquipmentSlot[] = ["weapon", "armor", "trinket", "relic"];

export function calculateEquipmentStatMods(
  inventory: ItemInstance[],
  equipment: EquipmentSlots,
  itemById: Record<string, ItemDefinition>
): HeroStatMods {
  return EQUIPMENT_SLOTS.reduce<HeroStatMods>((mods, slot) => {
    const instance = equipment[slot] ? findItemInstance(inventory, equipment[slot]!) : undefined;
    const item = instance ? itemById[instance.itemId] : undefined;
    return item && instance ? mergeEquipmentStatMods(mods, calculateItemInstanceStatMods(item, instance)) : mods;
  }, {});
}

export function calculateItemInstanceStatMods(item: ItemDefinition, instance: ItemInstance): HeroStatMods {
  return getItemTotalStatMods(item, instance);
}

export function equipItem(
  save: HeroSaveData,
  itemInstanceId: string,
  itemById: Record<string, ItemDefinition>
): ProgressionActionResult {
  const instance = findItemInstance(save.inventory, itemInstanceId);
  if (!instance) {
    return { ok: false, hero: save, message: "Item is not in this hero's inventory." };
  }
  const item = itemById[instance.itemId];
  if (!item) {
    return { ok: false, hero: save, message: "Unknown item." };
  }

  return {
    ok: true,
    hero: {
      ...save,
      equipment: {
        ...save.equipment,
        [item.slot]: instance.instanceId
      }
    },
    message: `${item.name} equipped.`
  };
}

export function unequipItem(save: HeroSaveData, slot: EquipmentSlot): ProgressionActionResult {
  if (!save.equipment[slot]) {
    return { ok: false, hero: save, message: "Nothing is equipped there." };
  }
  const equipment = { ...save.equipment };
  delete equipment[slot];
  return {
    ok: true,
    hero: {
      ...save,
      equipment
    },
    message: "Item unequipped."
  };
}

function mergeEquipmentStatMods(left: HeroStatMods, right: HeroStatMods): HeroStatMods {
  const merged: HeroStatMods = { ...left };
  Object.entries(right).forEach(([key, value]) => {
    if (typeof value === "number") {
      const statKey = key as keyof HeroStatMods;
      merged[statKey] = (merged[statKey] ?? 0) + value;
    }
  });
  return merged;
}
