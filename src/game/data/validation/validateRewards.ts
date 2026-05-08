import { MAPS } from "../maps";
import { REWARD_TABLES } from "../rewards";
import { RIVAL_REWARDS } from "../rivalRewards";
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
    if (!table.repeatClearReward) {
      errors.push(`Reward table ${table.id} needs an explicit repeat-clear reward.`);
    }
    guaranteedItemIds.forEach((itemId) => validateRewardItemReference(table.id, itemId, errors, context));
    validateUniqueItemIds(table.id, "deterministic item", table.deterministicItemIds ?? [], errors);
    table.deterministicItemIds?.forEach((itemId) => validateRewardItemReference(table.id, itemId, errors, context));
    validateUniqueItemIds(table.id, "weighted item", weightedItemPool.map((entry) => entry.itemId), errors);
    weightedItemPool.forEach((entry) => {
      validateRewardItemReference(table.id, entry.itemId, errors, context);
      if (entry.weight <= 0) {
        errors.push(`Reward table ${table.id} has non-positive weight for ${entry.itemId}.`);
      }
      if (entry.firstClearOnly && entry.repeatClearOnly) {
        errors.push(`Reward table ${table.id} marks ${entry.itemId} as both first-clear-only and repeat-clear-only.`);
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

export function validateRivalRewards(errors: string[], context: ValidationContext): void {
  const seenEnemyHeroes = new Set<string>();
  const seenTrophies = new Set<string>();
  RIVAL_REWARDS.forEach((reward) => {
    if (!context.enemyHeroIds.has(reward.enemyHeroId)) {
      errors.push(`Rival reward references missing enemy hero ${reward.enemyHeroId}.`);
    }
    if (seenEnemyHeroes.has(reward.enemyHeroId)) {
      errors.push(`Rival reward duplicates enemy hero ${reward.enemyHeroId}.`);
    }
    seenEnemyHeroes.add(reward.enemyHeroId);

    const firstDefeat = reward.firstDefeat;
    if (firstDefeat.xp < 0) {
      errors.push(`Rival reward ${reward.enemyHeroId} has negative XP.`);
    }
    if (firstDefeat.itemId && !context.itemIds.has(firstDefeat.itemId)) {
      errors.push(`Rival reward ${reward.enemyHeroId} references missing item ${firstDefeat.itemId}.`);
    }
    if (firstDefeat.reputation && !context.factionIds.has(firstDefeat.reputation.factionId)) {
      errors.push(`Rival reward ${reward.enemyHeroId} references missing faction ${firstDefeat.reputation.factionId}.`);
    }
    Object.entries(firstDefeat.resources).forEach(([resource, amount]) => {
      if (!context.resourceIds.has(resource)) {
        errors.push(`Rival reward ${reward.enemyHeroId} gives missing resource ${resource}.`);
      }
      if ((amount ?? 0) < 0) {
        errors.push(`Rival reward ${reward.enemyHeroId} has negative resource reward ${resource}.`);
      }
    });
    if (!firstDefeat.trophy.trophyId.trim()) {
      errors.push(`Rival reward ${reward.enemyHeroId} has an empty trophy id.`);
    }
    if (seenTrophies.has(firstDefeat.trophy.trophyId)) {
      errors.push(`Rival reward trophy ${firstDefeat.trophy.trophyId} is duplicated.`);
    }
    seenTrophies.add(firstDefeat.trophy.trophyId);
    if (!firstDefeat.trophy.label.trim() || !firstDefeat.trophy.description.trim()) {
      errors.push(`Rival reward ${reward.enemyHeroId} trophy needs label and description.`);
    }
  });
}

function validateUniqueItemIds(tableId: string, label: string, itemIds: string[], errors: string[]): void {
  const seen = new Set<string>();
  itemIds.forEach((itemId) => {
    if (seen.has(itemId)) {
      errors.push(`Reward table ${tableId} duplicates ${label} ${itemId}.`);
    }
    seen.add(itemId);
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
