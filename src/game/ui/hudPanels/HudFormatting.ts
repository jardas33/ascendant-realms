import { LEVEL_XP_THRESHOLDS } from "../../core/Constants";
import type { BuildingDefinition, UnitDefinition, UpgradeDefinition } from "../../core/GameTypes";
import { xpProgressForLevel } from "../../core/Progression";
import type { Hero } from "../../entities/Hero";
import { UNIT_BY_ID, UPGRADE_BY_ID } from "../../data/contentIndex";

export function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

export function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

export function toCssColor(value: number): string {
  return `#${value.toString(16).padStart(6, "0")}`;
}

export function heroXpPercent(hero: Hero): number {
  return xpProgressForLevel(hero.xp, hero.level, LEVEL_XP_THRESHOLDS).percent;
}

export function unitName(unitId: string): string {
  return UNIT_BY_ID[unitId]?.name ?? unitId;
}

export function upgradeName(upgradeId: string): string {
  return UPGRADE_BY_ID[upgradeId]?.name ?? upgradeId;
}

export function formatBuildingSummary(definition: BuildingDefinition): string {
  const parts = [`HP ${definition.maxHp}`];
  if (definition.constructionTimeSeconds > 0) {
    parts.push(`${definition.constructionTimeSeconds}s build`);
  }
  if (definition.attack) {
    parts.push(`${definition.attack.damage} damage`, `${definition.attack.range} range`);
  }
  if (definition.trainOptions.length > 0) {
    parts.push(`trains ${definition.trainOptions.map((unitId) => unitName(unitId)).join(", ")}`);
  }
  return parts.join(" - ");
}

export function formatUnitSummary(definition: UnitDefinition): string {
  const stats = definition.stats;
  return `HP ${stats.maxHp} - ${stats.damage} damage - ${stats.range} range - ${definition.trainTime}s train`;
}

export function formatUpgradeEffects(definition: UpgradeDefinition): string {
  const effects = definition.effects.flatMap((effect) => {
    if (effect.type === "hero-mana-regen") {
      return [`${formatMultiplierPercent(effect.multiplier)} hero mana regen`];
    }

    const unitNames = effect.unitIds.map((unitId) => unitName(unitId)).join("/");
    const modifiers = [];
    if (effect.damageMultiplier !== undefined) {
      modifiers.push(`${formatMultiplierPercent(effect.damageMultiplier)} damage`);
    }
    if (effect.rangeMultiplier !== undefined) {
      modifiers.push(`${formatMultiplierPercent(effect.rangeMultiplier)} range`);
    }
    if (effect.attackCooldownMultiplier !== undefined) {
      modifiers.push(`${formatInverseMultiplierPercent(effect.attackCooldownMultiplier)} attack cooldown`);
    }
    if (effect.armorBonus !== undefined) {
      modifiers.push(`${effect.armorBonus > 0 ? "+" : ""}${effect.armorBonus} armor`);
    }
    return modifiers.length > 0 ? [`${unitNames}: ${modifiers.join(", ")}`] : [];
  });
  return effects.join("; ");
}

export function renderProgress(label: string, progress: number): string {
  return `
    <div class="progress-line">
      ${label ? `<span>${escapeHtml(label)}</span>` : ""}
      <div class="progress-strip"><i style="width:${Math.max(0, Math.min(100, progress * 100))}%"></i></div>
    </div>
  `;
}

export function formatMultiplierPercent(multiplier: number): string {
  const percent = Math.round((multiplier - 1) * 100);
  return `${percent > 0 ? "+" : ""}${percent}%`;
}

export function formatInverseMultiplierPercent(multiplier: number): string {
  const percent = Math.round((1 - multiplier) * 100);
  return `${percent > 0 ? "-" : "+"}${Math.abs(percent)}%`;
}
