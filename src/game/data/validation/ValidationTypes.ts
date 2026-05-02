import type { BattleMapDefinition } from "../../core/GameTypes";

export interface ValidationContext {
  unitIds: Set<string>;
  buildingIds: Set<string>;
  abilityIds: Set<string>;
  factionIds: Set<string>;
  heroClassIds: Set<string>;
  originIds: Set<string>;
  itemIds: Set<string>;
  itemAffixIds: Set<string>;
  resourceIds: Set<string>;
  skillTreeIds: Set<string>;
  skillNodeIds: Set<string>;
  rewardTableIds: Set<string>;
  upgradeIds: Set<string>;
  strongholdUpgradeIds: Set<string>;
  campaignNodeIds: Set<string>;
  aiPersonalityIds: Set<string>;
  campaignModifierIds: Set<string>;
}

export function idsFor(entries: Array<{ id: string }>, label: string, errors: string[]): Set<string> {
  const ids = new Set<string>();
  entries.forEach((entry) => {
    if (!entry.id.trim()) {
      errors.push(`A ${label} has an empty id.`);
      return;
    }
    if (ids.has(entry.id)) {
      errors.push(`Duplicate ${label} id: ${entry.id}`);
    }
    ids.add(entry.id);
  });
  return ids;
}

export function validateCombatStats(
  label: string,
  stats: { maxHp: number; damage: number; range: number; attackCooldown: number; speed: number }
): void;
export function validateCombatStats(
  label: string,
  stats: { maxHp: number; damage: number; range: number; attackCooldown: number; speed: number },
  errors: string[]
): void;
export function validateCombatStats(
  label: string,
  stats: { maxHp: number; damage: number; range: number; attackCooldown: number; speed: number },
  errors: string[] = []
): void {
  Object.entries(stats).forEach(([stat, value]) => {
    if (!Number.isFinite(value)) {
      errors.push(`${label} has non-finite ${stat}.`);
    }
  });
  if (stats.damage < 0) {
    errors.push(`${label} cannot have negative damage.`);
  }
  if (stats.range < 0) {
    errors.push(`${label} cannot have negative range.`);
  }
  if (stats.speed < 0) {
    errors.push(`${label} cannot have negative speed.`);
  }
}

export function validatePrerequisites(
  label: string,
  prerequisites: { buildingIds?: string[]; upgradeIds?: string[]; heroLevel?: number } | undefined,
  errors: string[],
  context: ValidationContext
): void {
  prerequisites?.buildingIds?.forEach((buildingId) => {
    if (!context.buildingIds.has(buildingId)) {
      errors.push(`${label} requires missing building ${buildingId}.`);
    }
  });
  prerequisites?.upgradeIds?.forEach((upgradeId) => {
    if (!context.upgradeIds.has(upgradeId)) {
      errors.push(`${label} requires missing upgrade ${upgradeId}.`);
    }
  });
  if (prerequisites?.heroLevel !== undefined && prerequisites.heroLevel <= 0) {
    errors.push(`${label} has an invalid hero level prerequisite.`);
  }
}

export function assertUniqueIds(entries: Array<{ id: string }>, label: string, errors: string[]): void {
  const ids = new Set<string>();
  entries.forEach((entry) => {
    if (!entry.id.trim()) {
      errors.push(`${label} has an empty id.`);
    }
    if (ids.has(entry.id)) {
      errors.push(`Duplicate ${label} id: ${entry.id}`);
    }
    ids.add(entry.id);
  });
}

export function validatePointInMap(
  map: BattleMapDefinition,
  point: { x: number; y: number },
  label: string,
  errors: string[]
): void {
  if (!Number.isFinite(point.x) || !Number.isFinite(point.y)) {
    errors.push(`Map ${map.id} ${label} has a non-finite position.`);
    return;
  }
  if (point.x < 0 || point.y < 0 || point.x > map.width || point.y > map.height) {
    errors.push(`Map ${map.id} ${label} is outside map bounds.`);
  }
}
