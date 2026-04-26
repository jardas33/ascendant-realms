import type { BattleRewardResult, HeroBaseStats } from "../core/GameTypes";
import type { StatDelta } from "../core/ResultsFlow";
import { ITEM_BY_ID } from "../data/contentIndex";
import { RESOURCE_DEFINITIONS } from "../data/resources";
import { xpProgressForLevel } from "../core/Progression";

export function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

export function titleCase(value: string): string {
  return value.charAt(0).toUpperCase() + value.slice(1).replaceAll("_", " ");
}

export function statLabel(key: string): string {
  const labels: Record<string, string> = {
    maxHp: "HP",
    maxMana: "Mana",
    attackCooldown: "Attack cooldown"
  };
  return labels[key] ?? key.replace(/([A-Z])/g, " $1").toLowerCase();
}

export function formatXpProgress(xp: number, level: number, progress: ReturnType<typeof xpProgressForLevel>): string {
  if (progress.nextLevelXp <= progress.currentLevelXp) {
    return "Level cap reached";
  }
  return `${Math.max(0, xp - progress.currentLevelXp)} / ${progress.nextLevelXp - progress.currentLevelXp} XP (${Math.round(progress.percent)}%)`;
}

export function formatDeltas(deltas: StatDelta[]): string {
  if (deltas.length === 0) {
    return "No stat change.";
  }
  return deltas.map((delta) => `${delta.delta > 0 ? "+" : ""}${delta.delta} ${statLabel(delta.key)}`).join(", ");
}

export function formatStatMods(mods: Partial<Record<keyof HeroBaseStats, number>>): string {
  const formatted = Object.entries(mods)
    .map(([key, value]) => `${value && value > 0 ? "+" : ""}${value} ${statLabel(key)}`)
    .join(", ");
  return formatted || "No stat modifiers";
}

export function formatResourceRewards(resources: BattleRewardResult["resources"]): string {
  const rewards = Object.entries(resources)
    .filter(([, amount]) => typeof amount === "number" && amount > 0)
    .map(([resource, amount]) => `${amount} ${RESOURCE_DEFINITIONS.find((definition) => definition.id === resource)?.name ?? titleCase(resource)}`);
  return rewards.length > 0 ? rewards.join(", ") : "None";
}

export function formatTags(tags: string[]): string {
  return tags.length > 0 ? `Tags: ${tags.map(titleCase).join(", ")}` : "No tags";
}

export function formatDuplicateConversions(conversions: NonNullable<BattleRewardResult["duplicateConversions"]>): string {
  if (conversions.length === 0) {
    return "None";
  }
  return conversions
    .map((conversion) => {
      const item = ITEM_BY_ID[conversion.itemId];
      return `${item?.name ?? conversion.itemId} converted to ${formatResourceRewards(conversion.resources)}`;
    })
    .join(", ");
}
