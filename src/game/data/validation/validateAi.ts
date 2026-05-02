import { AI_PERSONALITIES } from "../aiPersonalities";
import { BATTLE_DIFFICULTIES } from "../battlePacing";
import { MAPS } from "../maps";
import type { ValidationContext } from "./ValidationTypes";

export function validateAIPersonalities(errors: string[], context: ValidationContext): void {
  AI_PERSONALITIES.forEach((personality) => {
    if (!personality.name.trim() || !personality.shortDescription.trim() || !personality.description.trim()) {
      errors.push(`AI personality ${personality.id} needs name, shortDescription, and description.`);
    }
    if (personality.aggressionLevel < 0 || personality.aggressionLevel > 1) {
      errors.push(`AI personality ${personality.id} aggressionLevel must be between 0 and 1.`);
    }
    personality.preferredUnitIds.forEach((unitId) => {
      if (!context.unitIds.has(unitId)) {
        errors.push(`AI personality ${personality.id} prefers missing unit ${unitId}.`);
      }
    });
    personality.unitPlan.forEach((unitId) => {
      if (!context.unitIds.has(unitId)) {
        errors.push(`AI personality ${personality.id} trains missing unit ${unitId}.`);
      }
    });
    if (personality.unitPlan.length === 0) {
      errors.push(`AI personality ${personality.id} must include a unit plan.`);
    }
    Object.entries(personality.timing).forEach(([field, multiplier]) => {
      if (multiplier <= 0) {
        errors.push(`AI personality ${personality.id} has invalid timing multiplier ${field}.`);
      }
    });
    if (personality.economy.incomeMultiplier < 0) {
      errors.push(`AI personality ${personality.id} cannot have negative income multiplier.`);
    }
    if (personality.waves.attackWaveSizeMultiplier <= 0) {
      errors.push(`AI personality ${personality.id} has invalid attack wave multiplier.`);
    }
    Object.entries(personality.waves.phaseOverrides).forEach(([phaseId, override]) => {
      if (!["opening", "expansion", "pressure", "assault"].includes(phaseId)) {
        errors.push(`AI personality ${personality.id} has invalid phase override ${phaseId}.`);
      }
      override.allowedAttackUnitIds?.forEach((unitId) => {
        if (!context.unitIds.has(unitId)) {
          errors.push(`AI personality ${personality.id} phase ${phaseId} allows missing unit ${unitId}.`);
        }
      });
      override.preferredAttackUnitIds?.forEach((unitId) => {
        if (!context.unitIds.has(unitId)) {
          errors.push(`AI personality ${personality.id} phase ${phaseId} prefers missing unit ${unitId}.`);
        }
      });
      override.trainUnitIds?.forEach((unitId) => {
        if (!context.unitIds.has(unitId)) {
          errors.push(`AI personality ${personality.id} phase ${phaseId} trains missing unit ${unitId}.`);
        }
      });
      Object.keys(override.maxAttackByUnitId ?? {}).forEach((unitId) => {
        if (!context.unitIds.has(unitId)) {
          errors.push(`AI personality ${personality.id} phase ${phaseId} caps missing unit ${unitId}.`);
        }
      });
    });
    if (personality.defense.defendRadiusMultiplier <= 0 || personality.defense.reserveDefenseUnits < 0) {
      errors.push(`AI personality ${personality.id} has invalid defense tuning.`);
    }
  });
}

export function validateDifficulties(errors: string[]): void {
  const knownSpawnIds = new Set(MAPS.flatMap((map) => map.scenario.unitSpawns.map((spawn) => spawn.id)));
  BATTLE_DIFFICULTIES.forEach((difficulty) => {
    if (difficulty.enemyIncomeMultiplier < 0) {
      errors.push(`Difficulty ${difficulty.id} cannot have a negative enemy income multiplier.`);
    }
    if (difficulty.firstAttackDelay < 0 || difficulty.attackInterval <= 0) {
      errors.push(`Difficulty ${difficulty.id} has invalid attack timing.`);
    }
    if (difficulty.attackWaveSize <= 0 || difficulty.minAttackArmySize <= 0) {
      errors.push(`Difficulty ${difficulty.id} has invalid wave sizing.`);
    }
    if (difficulty.expandInterval <= 0 || difficulty.trainInterval <= 0) {
      errors.push(`Difficulty ${difficulty.id} has invalid expansion or training timing.`);
    }
    difficulty.enemyStartingUnitSpawnIds.forEach((spawnId) => {
      if (!knownSpawnIds.has(spawnId)) {
        errors.push(`Difficulty ${difficulty.id} references missing enemy starting spawn ${spawnId}.`);
      }
    });
  });
}
