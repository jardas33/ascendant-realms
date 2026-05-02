import { STRONGHOLD_UPGRADES } from "../strongholdUpgrades";
import type { ValidationContext } from "./ValidationTypes";

export function validateStrongholdUpgrades(errors: string[], context: ValidationContext): void {
  STRONGHOLD_UPGRADES.forEach((upgrade) => {
    if (!upgrade.name.trim() || !upgrade.description.trim() || !upgrade.flavorText.trim()) {
      errors.push(`Stronghold upgrade ${upgrade.id} needs name, description, and flavor text.`);
    }
    if (upgrade.tier <= 0) {
      errors.push(`Stronghold upgrade ${upgrade.id} must have a positive tier.`);
    }
    if (upgrade.maxRank <= 0) {
      errors.push(`Stronghold upgrade ${upgrade.id} must have a positive max rank.`);
    }
    Object.entries(upgrade.cost).forEach(([resource, amount]) => {
      if (!context.resourceIds.has(resource)) {
        errors.push(`Stronghold upgrade ${upgrade.id} costs missing resource ${resource}.`);
      }
      if ((amount ?? 0) < 0) {
        errors.push(`Stronghold upgrade ${upgrade.id} has negative ${resource} cost.`);
      }
    });
    Object.entries(upgrade.prerequisites.upgradeRanks ?? {}).forEach(([requiredUpgradeId, requiredRank]) => {
      if (!context.strongholdUpgradeIds.has(requiredUpgradeId)) {
        errors.push(`Stronghold upgrade ${upgrade.id} requires missing stronghold upgrade ${requiredUpgradeId}.`);
      }
      if ((requiredRank ?? 0) <= 0) {
        errors.push(`Stronghold upgrade ${upgrade.id} has invalid prerequisite rank for ${requiredUpgradeId}.`);
      }
    });
    upgrade.prerequisites.completedNodeIds?.forEach((nodeId) => {
      if (!context.campaignNodeIds.has(nodeId)) {
        errors.push(`Stronghold upgrade ${upgrade.id} requires missing campaign node ${nodeId}.`);
      }
    });
    if (upgrade.effects.length === 0) {
      errors.push(`Stronghold upgrade ${upgrade.id} must include at least one effect.`);
    }
    upgrade.effects.forEach((effect) => {
      if (effect.type === "extra-starting-unit") {
        if (!context.unitIds.has(effect.unitId)) {
          errors.push(`Stronghold upgrade ${upgrade.id} spawns missing unit ${effect.unitId}.`);
        }
        if (effect.count <= 0) {
          errors.push(`Stronghold upgrade ${upgrade.id} has invalid extra unit count.`);
        }
      }
      if (effect.type === "starting-resources") {
        Object.entries(effect.resources).forEach(([resource, amount]) => {
          if (!context.resourceIds.has(resource)) {
            errors.push(`Stronghold upgrade ${upgrade.id} grants missing starting resource ${resource}.`);
          }
          if ((amount ?? 0) < 0) {
            errors.push(`Stronghold upgrade ${upgrade.id} has negative starting ${resource}.`);
          }
        });
      }
      if (effect.type === "hero-max-hp-multiplier" && effect.multiplier <= 0) {
        errors.push(`Stronghold upgrade ${upgrade.id} has invalid hero HP multiplier.`);
      }
      if (effect.type === "building-vision-bonus" && effect.amount <= 0) {
        errors.push(`Stronghold upgrade ${upgrade.id} has invalid building vision bonus.`);
      }
    });
  });
}
