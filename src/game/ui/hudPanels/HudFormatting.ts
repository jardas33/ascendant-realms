import { LEVEL_XP_THRESHOLDS } from "../../core/Constants";
import type { BuildingDefinition, UnitDefinition, UpgradeDefinition } from "../../core/GameTypes";
import { xpProgressForLevel } from "../../core/Progression";
import type { Hero } from "../../entities/Hero";
import { BUILDING_BY_ID, UNIT_BY_ID, UPGRADE_BY_ID } from "../../data/contentIndex";

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

export function buildingName(buildingId: string): string {
  return BUILDING_BY_ID[buildingId]?.name ?? buildingId;
}

export function formatBuildingRole(definition: BuildingDefinition): string {
  if (definition.id === "command_hall") {
    return "Base hub: trains Workers only, anchors the camp, and researches core upgrades.";
  }
  if (definition.id === "barracks") {
    return "Army production: trains Militia and Rangers and researches basic troop upgrades.";
  }
  if (definition.id === "mystic_lodge") {
    return "Mystic support: trains Acolytes and researches Aether Study I.";
  }
  if (definition.id === "watchtower") {
    return "Defense: inactive while incomplete, attacks nearby enemies when complete, and researches tower defenses.";
  }

  const actions = formatBuildingActionPhrases(definition);
  return actions.length > 0 ? `Production: ${actions.join("; ")}.` : "Structure: no active production role.";
}

export function formatBuildingUnlockSummary(definition: BuildingDefinition): string {
  const actions = formatBuildingActionPhrases(definition);
  return actions.length > 0 ? `Unlocks when complete: ${actions.join("; ")}.` : "No production actions unlock on completion.";
}

export function formatBuildingSummary(definition: BuildingDefinition): string {
  const parts = [`HP ${definition.maxHp}`];
  const trainOptions = definition.trainOptions ?? [];
  const upgradeOptions = definition.upgradeOptions ?? [];
  if (definition.constructionTimeSeconds > 0) {
    parts.push(`${definition.constructionTimeSeconds}s build`);
  }
  if (definition.attack) {
    parts.push(`${definition.attack.damage} damage`, `${definition.attack.range} range`);
  }
  if (trainOptions.length > 0) {
    parts.push(`trains ${trainOptions.map((unitId) => unitName(unitId)).join(", ")}`);
  }
  if (upgradeOptions.length > 0) {
    parts.push(`researches ${upgradeOptions.map((upgradeId) => upgradeName(upgradeId)).join(", ")}`);
  }
  return parts.join(" - ");
}

export function formatUnitSummary(definition: UnitDefinition): string {
  const stats = definition.stats;
  return `HP ${stats.maxHp} - ${stats.damage} damage - ${stats.range} range - ${definition.trainTime}s train`;
}

export function formatUpgradeEffects(definition: UpgradeDefinition): string {
  if (definition.effectSummary.trim()) {
    return definition.effectSummary;
  }

  const effects = definition.effects.flatMap((effect) => {
    if (effect.type === "hero-mana-regen") {
      return [`${formatMultiplierPercent(effect.multiplier)} hero mana regen`];
    }
    if (effect.type === "building-stat-mod") {
      const buildingNames = effect.buildingIds.map((buildingId) => buildingName(buildingId)).join("/");
      const modifiers = [];
      if (effect.armorBonus !== undefined) {
        modifiers.push(`${effect.armorBonus > 0 ? "+" : ""}${effect.armorBonus} armor`);
      }
      return modifiers.length > 0 ? [`${buildingNames}: ${modifiers.join(", ")}`] : [];
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

export function formatUpgradeOwner(definition: UpgradeDefinition): string {
  return `Owner: ${buildingName(definition.ownerBuildingId)}`;
}

export function formatUpgradeRequirements(definition: UpgradeDefinition): string {
  const requirements = [
    ...(definition.prerequisites.buildingIds ?? []).map((buildingId) => `completed ${buildingName(buildingId)}`),
    ...(definition.prerequisites.upgradeIds ?? []).map((upgradeId) => upgradeName(upgradeId)),
    ...(definition.prerequisites.heroLevel !== undefined ? [`hero level ${definition.prerequisites.heroLevel}`] : [])
  ];
  return requirements.length > 0 ? `Requires: ${requirements.join(", ")}` : "Requires: no prerequisite";
}

export function formatUpgradeCategory(definition: UpgradeDefinition): string {
  return `Category: ${definition.category.replaceAll("_", " ").replace(/\b\w/g, (letter) => letter.toUpperCase())}`;
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

function formatBuildingActionPhrases(definition: BuildingDefinition): string[] {
  const actions: string[] = [];
  const trainOptions = definition.trainOptions ?? [];
  const upgradeOptions = definition.upgradeOptions ?? [];
  if (trainOptions.length > 0) {
    actions.push(`trains ${trainOptions.map((unitId) => unitName(unitId)).join(", ")}`);
  }
  if (upgradeOptions.length > 0) {
    actions.push(`researches ${upgradeOptions.map((upgradeId) => upgradeName(upgradeId)).join(", ")}`);
  }
  if (definition.attack) {
    actions.push(`defensive attack (${definition.attack.damage} damage, ${definition.attack.range} range)`);
  }
  return actions;
}
