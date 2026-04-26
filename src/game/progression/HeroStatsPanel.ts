import type { HeroBaseStats } from "../core/GameTypes";
import { escapeHtml } from "./ItemComparison";

export function renderHeroStatsPanel(stats: HeroBaseStats): string {
  const rows: Array<[string, number]> = [
    ["HP", stats.maxHp],
    ["Mana", stats.maxMana],
    ["Damage", stats.damage],
    ["Armor", stats.armor],
    ["Speed", stats.speed],
    ["Might", stats.might],
    ["Command", stats.command],
    ["Arcana", stats.arcana],
    ["Faith", stats.faith]
  ];
  return `
      <div class="stat-list progression-stats">
        ${rows.map(([label, value]) => `<span>${label} <strong>${Math.round(value)}</strong></span>`).join("")}
      </div>
    `;
}

export function renderHeroAbilitiesPanel(unlockedAbilities: string[]): string {
  return `
      <div class="tag-row">${unlockedAbilities.map((abilityId) => `<span class="tag">${escapeHtml(abilityId.replaceAll("_", " "))}</span>`).join("")}</div>
    `;
}
