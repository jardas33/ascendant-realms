import { ITEM_AFFIXES } from "../itemAffixes";
import { ITEMS } from "../items";
import type { ValidationContext } from "./ValidationTypes";

const EQUIPMENT_SLOTS = ["weapon", "armor", "trinket", "relic"];
const ITEM_RARITIES = ["common", "uncommon", "rare", "epic", "legendary"];
const ITEM_AFFIX_TIERS = ["minor", "major"];

export function validateItems(errors: string[], context: ValidationContext): void {
  ITEMS.forEach((item) => {
    if (!EQUIPMENT_SLOTS.includes(item.slot)) {
      errors.push(`Item ${item.id} has invalid equipment slot ${item.slot}.`);
    }
    if (!ITEM_RARITIES.includes(item.rarity)) {
      errors.push(`Item ${item.id} has invalid rarity ${item.rarity}.`);
    }
    if (item.unique !== undefined && typeof item.unique !== "boolean") {
      errors.push(`Item ${item.id} has invalid unique flag.`);
    }
    if (!item.name.trim() || !item.description.trim() || !item.flavorText.trim()) {
      errors.push(`Item ${item.id} needs name, description, and flavor text.`);
    }
    if (!Array.isArray(item.tags) || item.tags.length === 0) {
      errors.push(`Item ${item.id} should include at least one tag.`);
    }
    item.classAffinity?.forEach((classId) => {
      if (!context.heroClassIds.has(classId)) {
        errors.push(`Item ${item.id} references missing hero class affinity ${classId}.`);
      }
    });
    if (item.factionOrigin && !context.factionIds.has(item.factionOrigin)) {
      errors.push(`Item ${item.id} references missing faction origin ${item.factionOrigin}.`);
    }
    Object.entries(item.statMods).forEach(([stat, value]) => {
      if (value !== undefined && !Number.isFinite(value)) {
        errors.push(`Item ${item.id} has a non-finite ${stat} modifier.`);
      }
    });
  });
}

export function validateItemAffixes(errors: string[]): void {
  ITEM_AFFIXES.forEach((affix) => {
    if (!affix.name.trim()) {
      errors.push(`Item affix ${affix.id} needs a name.`);
    }
    if (!ITEM_AFFIX_TIERS.includes(affix.tier)) {
      errors.push(`Item affix ${affix.id} has invalid tier ${affix.tier}.`);
    }
    if (!Array.isArray(affix.allowedSlots) || affix.allowedSlots.length === 0) {
      errors.push(`Item affix ${affix.id} needs at least one allowed slot.`);
    }
    affix.allowedSlots.forEach((slot) => {
      if (!EQUIPMENT_SLOTS.includes(slot)) {
        errors.push(`Item affix ${affix.id} has invalid slot ${slot}.`);
      }
    });
    if (!Array.isArray(affix.tags) || affix.tags.length === 0) {
      errors.push(`Item affix ${affix.id} should include at least one tag.`);
    }
    if (!Number.isFinite(affix.weight) || affix.weight <= 0) {
      errors.push(`Item affix ${affix.id} has invalid weight.`);
    }
    Object.entries(affix.statMods).forEach(([stat, value]) => {
      if (value !== undefined && !Number.isFinite(value)) {
        errors.push(`Item affix ${affix.id} has a non-finite ${stat} modifier.`);
      }
    });
  });
}
