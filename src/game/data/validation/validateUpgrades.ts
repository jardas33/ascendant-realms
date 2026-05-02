import { UPGRADES } from "../upgrades";
import { validatePrerequisites, type ValidationContext } from "./ValidationTypes";

export function validateUpgrades(errors: string[], context: ValidationContext): void {
  UPGRADES.forEach((upgrade) => {
    if (!upgrade.name.trim()) {
      errors.push(`Upgrade ${upgrade.id} needs a display name.`);
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
      if (effect.type === "hero-mana-regen" && effect.multiplier <= 0) {
        errors.push(`Upgrade ${upgrade.id} has invalid hero mana regen multiplier.`);
      }
    });
  });
}
