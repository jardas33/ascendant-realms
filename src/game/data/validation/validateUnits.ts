import { UNITS } from "../units";
import { validateCombatStats, validatePrerequisites, type ValidationContext } from "./ValidationTypes";

export function validateUnits(errors: string[], context: ValidationContext): void {
  UNITS.forEach((unit) => {
    if (!context.factionIds.has(unit.factionId)) {
      errors.push(`Unit ${unit.id} references missing faction ${unit.factionId}.`);
    }
    if (unit.stats.maxHp <= 0) {
      errors.push(`Unit ${unit.id} must have positive max HP.`);
    }
    if (unit.stats.attackCooldown <= 0) {
      errors.push(`Unit ${unit.id} must have positive attack cooldown.`);
    }
    if (unit.trainTime < 0) {
      errors.push(`Unit ${unit.id} cannot have negative train time.`);
    }
    if (unit.radius <= 0) {
      errors.push(`Unit ${unit.id} must have a positive radius.`);
    }
    if (unit.visionRadius <= 0) {
      errors.push(`Unit ${unit.id} must have a positive vision radius.`);
    }
    unit.buildOptions?.forEach((id) => {
      if (!context.buildingIds.has(id)) {
        errors.push(`Unit ${unit.id} can build missing building ${id}.`);
      }
    });
    validatePrerequisites(`Unit ${unit.id}`, unit.prerequisites, errors, context);
    validateCombatStats(`Unit ${unit.id}`, unit.stats, errors);
  });
}
