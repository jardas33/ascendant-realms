import { FACTIONS } from "../factions";
import { assertUniqueIds, type ValidationContext } from "./ValidationTypes";

export function validateFactions(errors: string[], context: ValidationContext): void {
  FACTIONS.forEach((faction) => {
    if (!faction.name.trim() || !faction.fantasy.trim()) {
      errors.push(`Faction ${faction.id} needs name and fantasy text.`);
    }
    if (!faction.mechanics) {
      errors.push(`Faction ${faction.id} needs mechanics.`);
      return;
    }
    if (!faction.mechanics.economyStyle.trim() || !faction.mechanics.militaryStyle.trim() || !faction.mechanics.magicStyle.trim()) {
      errors.push(`Faction ${faction.id} needs economy, military, and magic style text.`);
    }
    faction.mechanics.availableUnitIds.forEach((unitId) => {
      if (!context.unitIds.has(unitId)) {
        errors.push(`Faction ${faction.id} references missing available unit ${unitId}.`);
      }
    });
    faction.mechanics.availableBuildingIds.forEach((buildingId) => {
      if (!context.buildingIds.has(buildingId)) {
        errors.push(`Faction ${faction.id} references missing available building ${buildingId}.`);
      }
    });
    faction.mechanics.availableUpgradeIds.forEach((upgradeId) => {
      if (!context.upgradeIds.has(upgradeId)) {
        errors.push(`Faction ${faction.id} references missing available upgrade ${upgradeId}.`);
      }
    });
    faction.mechanics.aiPersonalityPreferences.forEach((personalityId) => {
      if (!context.aiPersonalityIds.has(personalityId)) {
        errors.push(`Faction ${faction.id} prefers missing AI personality ${personalityId}.`);
      }
    });
    faction.mechanics.campaignReputationHooks.forEach((factionId) => {
      if (!context.factionIds.has(factionId)) {
        errors.push(`Faction ${faction.id} references missing reputation hook ${factionId}.`);
      }
    });
    assertUniqueIds(faction.mechanics.factionModifiers, `Faction ${faction.id} modifier`, errors);
    faction.mechanics.factionModifiers.forEach((modifier) => {
      if (!modifier.name.trim() || !modifier.description.trim()) {
        errors.push(`Faction ${faction.id} modifier ${modifier.id} needs name and description.`);
      }
      if (!["burn-on-hit", "low-health-damage", "wave-speed"].includes(modifier.type)) {
        errors.push(`Faction ${faction.id} modifier ${modifier.id} has invalid type ${modifier.type}.`);
      }
      modifier.unitIds?.forEach((unitId) => {
        if (!context.unitIds.has(unitId)) {
          errors.push(`Faction ${faction.id} modifier ${modifier.id} references missing unit ${unitId}.`);
        }
      });
      if (modifier.type === "burn-on-hit") {
        if (!modifier.burn) {
          errors.push(`Faction ${faction.id} modifier ${modifier.id} needs burn tuning.`);
        } else {
          if (modifier.burn.damagePerSecond <= 0 || modifier.burn.durationSeconds <= 0 || modifier.burn.tickInterval <= 0) {
            errors.push(`Faction ${faction.id} modifier ${modifier.id} has invalid burn tuning.`);
          }
        }
      }
      if (modifier.type === "low-health-damage") {
        if ((modifier.hpThreshold ?? 0) <= 0 || (modifier.hpThreshold ?? 0) >= 1) {
          errors.push(`Faction ${faction.id} modifier ${modifier.id} has invalid HP threshold.`);
        }
        if ((modifier.damageMultiplier ?? 0) <= 0) {
          errors.push(`Faction ${faction.id} modifier ${modifier.id} has invalid damage multiplier.`);
        }
      }
      if (modifier.type === "wave-speed" && (modifier.speedMultiplier ?? 0) <= 0) {
        errors.push(`Faction ${faction.id} modifier ${modifier.id} has invalid speed multiplier.`);
      }
    });
  });
}
