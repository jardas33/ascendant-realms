import { UPGRADES } from "../upgrades";
import { BUILDINGS } from "../buildings";
import { validatePrerequisites, type ValidationContext } from "./ValidationTypes";

const VALID_UPGRADE_CATEGORIES = new Set(["core", "infantry", "ranger", "aether", "defense", "faction_trait"]);

export function validateUpgrades(errors: string[], context: ValidationContext): void {
  UPGRADES.forEach((upgrade) => {
    if (!upgrade.name.trim()) {
      errors.push(`Upgrade ${upgrade.id} needs a display name.`);
    }
    if (!context.buildingIds.has(upgrade.ownerBuildingId)) {
      errors.push(`Upgrade ${upgrade.id} references missing owner building ${upgrade.ownerBuildingId}.`);
    }
    if (!VALID_UPGRADE_CATEGORIES.has(upgrade.category)) {
      errors.push(`Upgrade ${upgrade.id} has invalid category ${upgrade.category}.`);
    }
    if (!Number.isInteger(upgrade.tier) || upgrade.tier <= 0) {
      errors.push(`Upgrade ${upgrade.id} must have a positive integer tier.`);
    }
    if (!upgrade.effectSummary.trim()) {
      errors.push(`Upgrade ${upgrade.id} needs readable effect summary text.`);
    }
    const owner = BUILDINGS.find((building) => building.id === upgrade.ownerBuildingId);
    if (owner && upgrade.category !== "faction_trait" && !owner.upgradeOptions.includes(upgrade.id)) {
      errors.push(`Upgrade ${upgrade.id} owner building ${upgrade.ownerBuildingId} must expose it in upgradeOptions.`);
    }
    if (upgrade.researchTimeSeconds < 0) {
      errors.push(`Upgrade ${upgrade.id} cannot have negative research time.`);
    }
    validatePrerequisites(`Upgrade ${upgrade.id}`, upgrade.prerequisites, errors, context);
    if (upgrade.effects.length === 0) {
      errors.push(`Upgrade ${upgrade.id} must include at least one effect.`);
    }
    upgrade.effects.forEach((effect) => {
      if (effect.type === "unit-stat-mod") {
        if (effect.unitIds.length === 0) {
          errors.push(`Upgrade ${upgrade.id} unit-stat-mod must target at least one unit.`);
        }
        effect.unitIds.forEach((unitId) => {
          if (!context.unitIds.has(unitId)) {
            errors.push(`Upgrade ${upgrade.id} targets missing unit ${unitId}.`);
          }
        });
        if (effect.damageMultiplier !== undefined && effect.damageMultiplier <= 0) {
          errors.push(`Upgrade ${upgrade.id} has invalid damage multiplier.`);
        }
        if (effect.rangeMultiplier !== undefined && effect.rangeMultiplier <= 0) {
          errors.push(`Upgrade ${upgrade.id} has invalid range multiplier.`);
        }
        if (effect.attackCooldownMultiplier !== undefined && effect.attackCooldownMultiplier <= 0) {
          errors.push(`Upgrade ${upgrade.id} has invalid attack cooldown multiplier.`);
        }
      }
      if (effect.type === "building-stat-mod") {
        if (effect.buildingIds.length === 0) {
          errors.push(`Upgrade ${upgrade.id} building-stat-mod must target at least one building.`);
        }
        effect.buildingIds.forEach((buildingId) => {
          if (!context.buildingIds.has(buildingId)) {
            errors.push(`Upgrade ${upgrade.id} targets missing building ${buildingId}.`);
          }
        });
        if (effect.armorBonus === undefined) {
          errors.push(`Upgrade ${upgrade.id} building-stat-mod must change at least one building stat.`);
        }
      }
      if (effect.type === "hero-mana-regen" && effect.multiplier <= 0) {
        errors.push(`Upgrade ${upgrade.id} has invalid hero mana regen multiplier.`);
      }
    });
  });
}
