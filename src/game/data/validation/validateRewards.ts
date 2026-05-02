import { MAPS } from "../maps";
import { REWARD_TABLES } from "../rewards";
import type { ValidationContext } from "./ValidationTypes";

export function validateRewardTables(errors: string[], context: ValidationContext): void {
  REWARD_TABLES.forEach((table) => {
    const guaranteedItemIds = table.guaranteedItemIds ?? [];
    const weightedItemPool = table.weightedItemPool ?? [];
    const resourceRewards = table.resourceRewards ?? [];
    const xpRewards = table.xpRewards ?? [];
    if (table.rolls < 0) {
      errors.push(`Reward table ${table.id} cannot have negative rolls.`);
    }
    if (guaranteedItemIds.length === 0 && weightedItemPool.length === 0) {
      errors.push(`Reward table ${table.id} must include guaranteed items or a weighted item pool.`);
    }
    guaranteedItemIds.forEach((itemId) => validateRewardItemReference(table.id, itemId, errors, context));
    table.deterministicItemIds?.forEach((itemId) => validateRewardItemReference(table.id, itemId, errors, context));
    weightedItemPool.forEach((entry) => {
      validateRewardItemReference(table.id, entry.itemId, errors, context);
      if (entry.weight <= 0) {
        errors.push(`Reward table ${table.id} has non-positive weight for ${entry.itemId}.`);
      }
      entry.mapIds?.forEach((mapId) => {
        if (!MAPS.some((map) => map.id === mapId)) {
          errors.push(`Reward table ${table.id} references missing map ${mapId}.`);
        }
      });
    });
    resourceRewards.forEach((entry) => {
      if (!context.resourceIds.has(entry.resource)) {
        errors.push(`Reward table ${table.id} gives missing resource ${entry.resource}.`);
      }
      if (entry.amount < 0) {
        errors.push(`Reward table ${table.id} has negative resource reward ${entry.resource}.`);
      }
    });
    xpRewards.forEach((entry) => {
      if (entry.amount < 0) {
        errors.push(`Reward table ${table.id} has negative XP reward.`);
      }
    });
    validateRewardBonus(table.id, "first-clear bonus", table.firstClearBonus, errors, context);
    validateRewardBonus(table.id, "repeat-clear reward", table.repeatClearReward, errors, context);
  });
}

function validateRewardItemReference(
  tableId: string,
  itemId: string,
  errors: string[],
  context: ValidationContext
): void {
  if (!context.itemIds.has(itemId)) {
    errors.push(`Reward table ${tableId} references missing item ${itemId}.`);
  }
}

function validateRewardBonus(
  tableId: string,
  label: string,
  bonus: { itemIds?: string[]; resources?: Partial<Record<string, number>>; xp?: number } | undefined,
  errors: string[],
  context: ValidationContext
): void {
  bonus?.itemIds?.forEach((itemId) => validateRewardItemReference(tableId, itemId, errors, context));
  Object.entries(bonus?.resources ?? {}).forEach(([resource, amount]) => {
    if (!context.resourceIds.has(resource)) {
      errors.push(`Reward table ${tableId} ${label} gives missing resource ${resource}.`);
    }
    if ((amount ?? 0) < 0) {
      errors.push(`Reward table ${tableId} ${label} has negative resource reward ${resource}.`);
    }
  });
  if ((bonus?.xp ?? 0) < 0) {
    errors.push(`Reward table ${tableId} ${label} has negative XP reward.`);
  }
}
