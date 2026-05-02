import type { BattleRewardResult, HeroBaseStats, HeroStatMods, ItemDefinition, ItemInstance } from "../core/GameTypes";
import { calculateItemInstanceStatMods, equipItem, findItemInstance } from "../core/HeroProgressionRules";
import { getItemAffixStatMods, getItemInstanceAffixes } from "../data/itemAffixes";
import type { HeroSaveData } from "../save/SaveTypes";
import type { HeroProgressionCatalogs } from "./HeroProgressionViewModel";
import { liveStatsFor } from "./HeroProgressionViewModel";

export const STAT_PREVIEW_KEYS: Array<keyof HeroBaseStats> = [
  "maxHp",
  "maxMana",
  "damage",
  "armor",
  "range",
  "attackCooldown",
  "speed",
  "might",
  "command",
  "arcana",
  "faith"
];

export function previewEquipDelta(
  save: HeroSaveData,
  item: ItemDefinition,
  equipped: boolean,
  catalogs: HeroProgressionCatalogs,
  instanceId?: string
): string {
  if (equipped) {
    return "Currently equipped.";
  }
  const instance = instanceId ? findItemInstance(save.inventory, instanceId) : save.inventory.find((entry) => entry.itemId === item.id);
  const result = instance ? equipItem(save, instance.instanceId, catalogs.itemById) : { ok: false, hero: save, message: "Item is not in this hero's inventory." };
  if (!result.ok) {
    return result.message;
  }
  const current = liveStatsFor(save, catalogs);
  const next = liveStatsFor(result.hero, catalogs);
  const deltas = STAT_PREVIEW_KEYS.map((key) => [key, Math.round((next[key] - current[key]) * 100) / 100] as const)
    .filter(([, delta]) => delta !== 0)
    .map(([key, delta]) => `${delta > 0 ? "+" : ""}${delta} ${statLabel(key)}`);
  return deltas.length > 0 ? `Preview: ${deltas.join(", ")}` : "Preview: no stat change.";
}

export function formatStatMods(mods: HeroStatMods): string {
  const formatted = Object.entries(mods)
    .map(([key, value]) => `${value && value > 0 ? "+" : ""}${value} ${statLabel(key)}`)
    .join(", ");
  return formatted || "No stat modifiers";
}

export function formatItemBaseStats(item: ItemDefinition): string {
  return `Base: ${formatStatMods(item.statMods)}`;
}

export function formatItemAffixes(item: ItemDefinition, instance: ItemInstance): string {
  const affixes = getItemInstanceAffixes(item, instance);
  return affixes.length > 0 ? `Affixes: ${affixes.map((affix) => affix.name).join(", ")}` : "Affixes: None";
}

export function formatItemAffixStats(item: ItemDefinition, instance: ItemInstance): string {
  return `Affix stats: ${formatStatMods(getItemAffixStatMods(item, instance))}`;
}

export function formatItemTotalStats(item: ItemDefinition, instance: ItemInstance): string {
  return `Total: ${formatStatMods(calculateItemInstanceStatMods(item, instance))}`;
}

export function formatResourceRewards(resources: BattleRewardResult["resources"]): string {
  const rewards = Object.entries(resources)
    .filter(([, amount]) => typeof amount === "number" && amount > 0)
    .map(([resource, amount]) => `${amount} ${titleCase(resource)}`);
  return rewards.length > 0 ? rewards.join(", ") : "None";
}

export function formatTags(tags: string[]): string {
  return tags.length > 0 ? `Tags: ${tags.map(titleCase).join(", ")}` : "No tags";
}

export function renderItemName(item: ItemDefinition): string {
  return `${escapeHtml(item.name)} <span class="rarity-pill ${rarityClass(item.rarity)}">${titleCase(item.rarity)}</span>`;
}

export function rarityClass(rarity: ItemDefinition["rarity"]): string {
  return `rarity-${rarity}`;
}

export function statLabel(key: string): string {
  const labels: Record<string, string> = {
    maxHp: "HP",
    maxMana: "Mana",
    attackCooldown: "Attack cooldown"
  };
  return labels[key] ?? key.replace(/([A-Z])/g, " $1").toLowerCase();
}

export function titleCase(value: string): string {
  return value.charAt(0).toUpperCase() + value.slice(1).replaceAll("_", " ");
}

export function toCssColor(value: number): string {
  return `#${value.toString(16).padStart(6, "0")}`;
}

export function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}
