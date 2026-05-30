import { UNITS } from "../units";
import {
  PLAYER_UNIT_ROLE_IDS,
  UNIT_ROLE_IDENTITIES,
  UNIT_ROLE_TAGS,
  type UnitRoleTag
} from "../unitRoles";
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
  validateUnitRoleIdentities(errors, context);
}

function validateUnitRoleIdentities(errors: string[], context: ValidationContext): void {
  const validTags = new Set<UnitRoleTag>(UNIT_ROLE_TAGS);
  const seen = new Set<string>();
  UNIT_ROLE_IDENTITIES.forEach((identity) => {
    if (seen.has(identity.unitId)) {
      errors.push(`Duplicate unit role identity id: ${identity.unitId}.`);
    }
    seen.add(identity.unitId);
    if (!context.unitIds.has(identity.unitId)) {
      errors.push(`Unit role identity ${identity.unitId} references missing unit.`);
    }
    if (!identity.label.trim()) {
      errors.push(`Unit role identity ${identity.unitId} needs a label.`);
    }
    if (!identity.summary.trim()) {
      errors.push(`Unit role identity ${identity.unitId} needs a summary.`);
    }
    if (!identity.tacticalHint.trim()) {
      errors.push(`Unit role identity ${identity.unitId} needs a tactical hint.`);
    }
    if (identity.tags.length === 0) {
      errors.push(`Unit role identity ${identity.unitId} needs at least one tag.`);
    }
    const tags = new Set<UnitRoleTag>();
    identity.tags.forEach((tag) => {
      if (!validTags.has(tag)) {
        errors.push(`Unit role identity ${identity.unitId} has invalid tag ${tag}.`);
      }
      if (tags.has(tag)) {
        errors.push(`Unit role identity ${identity.unitId} repeats tag ${tag}.`);
      }
      tags.add(tag);
    });
  });

  PLAYER_UNIT_ROLE_IDS.forEach((unitId) => {
    if (!seen.has(unitId)) {
      errors.push(`Player unit ${unitId} needs a role identity.`);
    }
  });
}
