import { ORIGINS } from "../origins";
import { RESOURCE_DEFINITIONS } from "../resources";

export function validateOrigins(errors: string[]): void {
  ORIGINS.forEach((origin) => {
    Object.entries(origin.statMods).forEach(([stat, value]) => {
      if (value !== undefined && !Number.isFinite(value)) {
        errors.push(`Origin ${origin.id} has a non-finite ${stat} modifier.`);
      }
    });
  });
}

export function validateResources(errors: string[]): void {
  RESOURCE_DEFINITIONS.forEach((resource) => {
    if (!resource.name.trim()) {
      errors.push(`Resource ${resource.id} needs a display name.`);
    }
  });
}
