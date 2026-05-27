import { MAPS } from "../maps";
import { REWARD_TABLES } from "../rewards";
import { RELIC_REWARD_DEFINITIONS } from "../relicRewards";
import { RIVAL_REWARDS } from "../rivalRewards";
import type { RewardTableDefinition } from "../../core/GameTypes";
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
    validateRepeatClearRewardScale(table, errors);
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

export function validateRelicRewards(errors: string[], context: ValidationContext): void {
  const seenEnemyHeroes = new Set<string>();
  RELIC_REWARD_DEFINITIONS.forEach((reward) => {
    if (!reward.name.trim() || !reward.description.trim() || !reward.effectSummary.trim()) {
      errors.push(`Relic reward ${reward.id} needs name, description, and effect copy.`);
    }
    if (reward.persistenceStatus !== "persistent_inventory") {
      errors.push(`Relic reward ${reward.id} must use persistent_inventory status.`);
    }
    if (!context.itemIds.has(reward.itemId)) {
      errors.push(`Relic reward ${reward.id} references missing item ${reward.itemId}.`);
    }
    if (!context.enemyHeroIds.has(reward.sourceEnemyHeroId)) {
      errors.push(`Relic reward ${reward.id} references missing enemy hero ${reward.sourceEnemyHeroId}.`);
    }
    if (seenEnemyHeroes.has(reward.sourceEnemyHeroId)) {
      errors.push(`Relic reward ${reward.id} duplicates source enemy hero ${reward.sourceEnemyHeroId}.`);
    }
    seenEnemyHeroes.add(reward.sourceEnemyHeroId);
    if (reward.tier !== "rival" || reward.category !== "hero_loadout") {
      errors.push(`Relic reward ${reward.id} has invalid tier or category.`);
    }
    if (reward.duplicateCopiesAllowed || reward.duplicatePolicy !== "unique_duplicate_conversion") {
      errors.push(`Relic reward ${reward.id} must block duplicate copies with unique duplicate conversion.`);
    }
    if (!reward.acquisitionSource.trim()) {
      errors.push(`Relic reward ${reward.id} needs acquisition source copy.`);
    }
    if (!Array.isArray(reward.tags) || reward.tags.length === 0) {
      errors.push(`Relic reward ${reward.id} should include at least one tag.`);
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

function validateRepeatClearRewardScale(table: RewardTableDefinition, errors: string[]): void {
  const repeat = table.repeatClearReward;
  if (!repeat) {
    return;
  }
  if ((repeat.itemIds?.length ?? 0) > 0) {
    errors.push(`Reward table ${table.id} repeat-clear reward must not grant direct items.`);
  }
  if (table.firstClearBonus?.xp !== undefined && repeat.xp !== undefined && repeat.xp > table.firstClearBonus.xp) {
    errors.push(`Reward table ${table.id} repeat-clear XP exceeds first-clear XP.`);
  }
  Object.entries(repeat.resources ?? {}).forEach(([resource, amount]) => {
    const firstClearAmount = table.firstClearBonus?.resources?.[resource as keyof NonNullable<typeof table.firstClearBonus.resources>];
    if (firstClearAmount !== undefined && (amount ?? 0) > firstClearAmount) {
      errors.push(`Reward table ${table.id} repeat-clear ${resource} exceeds first-clear ${resource}.`);
    }
  });
}
