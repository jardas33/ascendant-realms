import { BUILDINGS } from "../buildings";
import { validatePrerequisites, type ValidationContext } from "./ValidationTypes";

export function validateBuildings(errors: string[], context: ValidationContext): void {
  BUILDINGS.forEach((building) => {
    if (!context.factionIds.has(building.factionId)) {
      errors.push(`Building ${building.id} references missing faction ${building.factionId}.`);
    }
    if (building.maxHp <= 0) {
      errors.push(`Building ${building.id} must have positive max HP.`);
    }
    if (building.size.width <= 0 || building.size.height <= 0) {
      errors.push(`Building ${building.id} must have a positive footprint size.`);
    }
    if (building.visionRadius <= 0) {
      errors.push(`Building ${building.id} must have a positive vision radius.`);
    }
    if (building.constructionTimeSeconds < 0) {
      errors.push(`Building ${building.id} cannot have negative construction time.`);
    }
    building.buildOptions.forEach((id) => {
      if (!context.buildingIds.has(id)) {
        errors.push(`Building ${building.id} can build missing building ${id}.`);
      }
    });
    building.trainOptions.forEach((id) => {
      if (!context.unitIds.has(id)) {
        errors.push(`Building ${building.id} can train missing unit ${id}.`);
      }
    });
    building.upgradeOptions.forEach((id) => {
      if (!context.upgradeIds.has(id)) {
        errors.push(`Building ${building.id} can research missing upgrade ${id}.`);
      }
    });
    validatePrerequisites(`Building ${building.id}`, building.prerequisites, errors, context);
    if (building.attack) {
      if (building.attack.damage <= 0) {
        errors.push(`Building ${building.id} attack damage must be positive.`);
      }
      if (building.attack.range <= 0) {
        errors.push(`Building ${building.id} attack range must be positive.`);
      }
      if (building.attack.cooldown <= 0) {
        errors.push(`Building ${building.id} attack cooldown must be positive.`);
      }
    }
  });
}
