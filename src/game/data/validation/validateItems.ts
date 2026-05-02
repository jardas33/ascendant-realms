import { ITEMS } from "../items";
import type { ValidationContext } from "./ValidationTypes";

export function validateItems(errors: string[], context: ValidationContext): void {
  ITEMS.forEach((item) => {
    if (!["weapon", "armor", "trinket", "relic"].includes(item.slot)) {
      errors.push(`Item ${item.id} has invalid equipment slot ${item.slot}.`);
    }
    if (!["common", "uncommon", "rare", "epic", "legendary"].includes(item.rarity)) {
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
