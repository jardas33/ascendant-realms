import type { BattleDifficulty, EquipmentSlot, ItemInstance, ResourceBag, ResourceKey } from "../core/GameTypes";
import {
  RETINUE_BASE_DEPLOYMENT_CAPACITY,
  RETINUE_TRAINING_YARD_II_DEPLOYMENT_BONUS,
  isRetinueEligibleUnitTypeId
} from "../core/RetinueRules";
import {
  isRivalDisposition,
  isRivalLastOutcome,
  isRivalModifierId
} from "../core/RivalRules";
import { isCampaignModifierId } from "../data/campaignModifiers";
import { DEFAULT_CAMPAIGN_CHAPTER_ID, isCampaignChapterId } from "../data/campaignChapters";
import { CAMPAIGN_NODE_BY_ID, ENEMY_HERO_BY_ID, UNIT_BY_ID } from "../data/contentIndex";
import { isStrongholdUpgradeId } from "../data/strongholdUpgrades";
import { isUnitVeterancyRankId } from "../data/unitVeterancy";
import { isKnownMissionObjectiveCompletionId } from "../core/campaign/CampaignMissionRules";
import { DEFAULT_FACTION_REPUTATION } from "./SaveDefaults";
import type {
  AllocatedSkills,
  CampaignRivalSaveData,
  CampaignSaveData,
  EquipmentSlots,
  HeroSaveData,
  RivalTrophySaveData,
  RetinueUnitSaveData
} from "./SaveTypes";

export function isHeroSaveData(value: unknown): value is HeroSaveData {
  return normalizeHeroSaveData(value) !== null;
}

export function isCampaignSaveData(value: unknown): value is CampaignSaveData {
  return normalizeCampaignSaveData(value) !== null;
}

export function normalizeHeroSaveData(value: unknown): HeroSaveData | null {
  if (!isRecord(value)) {
    return null;
  }
  const hasValidBase =
    typeof value.heroName === "string" &&
    typeof value.classId === "string" &&
    typeof value.originId === "string" &&
    isFiniteNumber(value.level) &&
    isFiniteNumber(value.xp) &&
    isFiniteNumber(value.skillPoints) &&
    Array.isArray(value.unlockedAbilities) &&
    value.unlockedAbilities.every((entry) => typeof entry === "string") &&
    isFiniteNumber(value.completedBattles) &&
    isRecord(value.stats) &&
    isFiniteNumber(value.stats.might) &&
    isFiniteNumber(value.stats.command) &&
    isFiniteNumber(value.stats.arcana) &&
    isFiniteNumber(value.stats.faith);

  if (!hasValidBase) {
    return null;
  }

  const stats = value.stats as { might: number; command: number; arcana: number; faith: number };
  const factionReputationSource = isRecord(value.factionReputation) ? value.factionReputation : {};
  if (!Object.values(factionReputationSource).every(isFiniteNumber)) {
    return null;
  }
  const unlockedAbilities = value.unlockedAbilities as string[];
  const inventory = normalizeInventoryInstances(value.inventory, value.items);
  const clearedMapIds = arrayOfStrings(value.clearedMapIds) ? value.clearedMapIds : [];
  const allocatedSkills: AllocatedSkills = {};
  if (isRecord(value.allocatedSkills)) {
    Object.entries(value.allocatedSkills).forEach(([skillId, rank]) => {
      if (isFiniteNumber(rank) && rank > 0) {
        allocatedSkills[skillId] = Math.floor(rank);
      }
    });
  }
  const equipment: EquipmentSlots = {};
  if (isRecord(value.equipment)) {
    Object.entries(value.equipment).forEach(([slot, itemId]) => {
      if (!isEquipmentSlot(slot) || typeof itemId !== "string") {
        return;
      }
      const equippedInstance =
        inventory.find((instance) => instance.instanceId === itemId) ??
        inventory.find((instance) => instance.itemId === itemId);
      if (equippedInstance) {
        equipment[slot] = equippedInstance.instanceId;
        return;
      }
      const fallbackInstance = createMigratedItemInstance(itemId, inventory.length, "legacy_equipped");
      inventory.push(fallbackInstance);
      equipment[slot] = fallbackInstance.instanceId;
    });
  }

  return {
    heroName: value.heroName as string,
    classId: value.classId as string,
    originId: value.originId as string,
    level: clampInteger(value.level, 1),
    xp: clampInteger(value.xp, 0),
    skillPoints: clampInteger(value.skillPoints, 0),
    unlockedAbilities: [...new Set(unlockedAbilities)],
    completedBattles: clampInteger(value.completedBattles, 0),
    clearedMapIds: [...new Set(clearedMapIds)],
    inventory: dedupeItemInstances(inventory),
    equipment,
    allocatedSkills,
    factionReputation: normalizeFactionReputation(factionReputationSource as Record<string, number>),
    stats: {
      might: clampNumber(stats.might, 0),
      command: clampNumber(stats.command, 0),
      arcana: clampNumber(stats.arcana, 0),
      faith: clampNumber(stats.faith, 0)
    }
  };
}

export function normalizeCampaignSaveData(value: unknown): CampaignSaveData | null {
  if (!isRecord(value)) {
    return null;
  }
  if (typeof value.started !== "boolean" || typeof value.difficulty !== "string") {
    return null;
  }
  if (!["story", "easy", "normal", "hard"].includes(value.difficulty)) {
    return null;
  }
  const difficulty = value.difficulty as BattleDifficulty;
  const completedNodeIds = arrayOfStrings(value.completedNodeIds) ? value.completedNodeIds : [];
  const unlockedNodeIds = arrayOfStrings(value.unlockedNodeIds) ? value.unlockedNodeIds : [];
  const lockedNodeIds = arrayOfStrings(value.lockedNodeIds) ? value.lockedNodeIds : [];
  const nodeRewardsClaimedIds = arrayOfStrings(value.nodeRewardsClaimedIds) ? value.nodeRewardsClaimedIds : [];
  const optionalObjectiveCompletionIds = arrayOfStrings(value.optionalObjectiveCompletionIds)
    ? value.optionalObjectiveCompletionIds.filter(isKnownMissionObjectiveCompletionId)
    : [];
  const choiceIdsClaimed = arrayOfStrings(value.choiceIdsClaimed) ? value.choiceIdsClaimed : [];
  const townServiceClaimedIds = arrayOfStrings(value.townServiceClaimedIds) ? value.townServiceClaimedIds : [];
  const activeModifierIds = arrayOfStrings(value.activeModifierIds)
    ? value.activeModifierIds.filter(isCampaignModifierId)
    : [];
  const strongholdUpgradeRanks = normalizeStrongholdUpgradeRanks(value.strongholdUpgradeRanks, value.strongholdUpgradeIds);
  const retinueUnits = normalizeRetinueUnits(value.retinueUnits);
  return {
    started: value.started,
    difficulty,
    resources: normalizeResourceBag(value.resources),
    resourcesSpent: normalizeResourceBag(value.resourcesSpent),
    completedNodeIds: [...new Set(completedNodeIds)],
    unlockedNodeIds: [...new Set(unlockedNodeIds)],
    lockedNodeIds: [...new Set(lockedNodeIds)],
    nodeRewardsClaimedIds: [...new Set(nodeRewardsClaimedIds)],
    optionalObjectiveCompletionIds: [...new Set(optionalObjectiveCompletionIds)],
    choiceIdsClaimed: [...new Set(choiceIdsClaimed)],
    townServiceClaimedIds: [...new Set(townServiceClaimedIds)],
    townServiceUseCounts: normalizeStringNumberRecord(value.townServiceUseCounts),
    activeModifierIds: [...new Set(activeModifierIds)],
    strongholdUpgradeRanks,
    retinueUnits,
    retinueDeploymentIds: normalizeRetinueDeploymentIds(value.retinueDeploymentIds, retinueUnits, strongholdUpgradeRanks),
    rivals: normalizeRivalStates(value.rivals),
    rivalTrophies: normalizeRivalTrophies(value.rivalTrophies),
    selectedChapterId: isCampaignChapterId(value.selectedChapterId) ? value.selectedChapterId : DEFAULT_CAMPAIGN_CHAPTER_ID,
    selectedNodeId: typeof value.selectedNodeId === "string" ? value.selectedNodeId : undefined
  };
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function isFiniteNumber(value: unknown): value is number {
  return typeof value === "number" && Number.isFinite(value);
}

function clampInteger(value: unknown, min: number): number {
  return Math.max(min, Math.floor(isFiniteNumber(value) ? value : min));
}

function clampNumber(value: unknown, min: number): number {
  return Math.max(min, isFiniteNumber(value) ? value : min);
}

function clampNumberRange(value: unknown, min: number, max: number): number {
  return Math.min(max, Math.max(min, isFiniteNumber(value) ? value : min));
}

function arrayOfStrings(value: unknown): value is string[] {
  return Array.isArray(value) && value.every((entry) => typeof entry === "string");
}

function isEquipmentSlot(value: string): value is EquipmentSlot {
  return value === "weapon" || value === "armor" || value === "trinket" || value === "relic";
}

function normalizeInventoryInstances(inventoryValue: unknown, legacyItemsValue: unknown): ItemInstance[] {
  const source = Array.isArray(inventoryValue) ? inventoryValue : arrayOfStrings(legacyItemsValue) ? legacyItemsValue : [];
  return source
    .map((entry, index) => normalizeItemInstance(entry, index))
    .filter((entry): entry is ItemInstance => entry !== undefined);
}

function normalizeItemInstance(value: unknown, index: number): ItemInstance | undefined {
  if (typeof value === "string") {
    return createMigratedItemInstance(value, index, "legacy_inventory");
  }
  if (
    !isRecord(value) ||
    typeof value.instanceId !== "string" ||
    typeof value.itemId !== "string" ||
    !value.instanceId.trim() ||
    !value.itemId.trim()
  ) {
    return undefined;
  }
  const acquiredAt = typeof value.acquiredAt === "string" ? value.acquiredAt : new Date().toISOString();
  const source = typeof value.source === "string" && value.source.trim() ? value.source : "unknown";
  return {
    instanceId: value.instanceId,
    itemId: value.itemId,
    acquiredAt,
    source,
    affixes: arrayOfStrings(value.affixes) ? [...new Set(value.affixes)] : [],
    locked: typeof value.locked === "boolean" ? value.locked : false,
    favorite: typeof value.favorite === "boolean" ? value.favorite : false
  };
}

function createMigratedItemInstance(itemId: string, index: number, source: string): ItemInstance {
  return {
    instanceId: `${source}:${sanitizeItemInstanceId(itemId)}:${index + 1}`,
    itemId,
    acquiredAt: new Date().toISOString(),
    source,
    affixes: [],
    locked: false,
    favorite: false
  };
}

function dedupeItemInstances(inventory: ItemInstance[]): ItemInstance[] {
  const seen = new Set<string>();
  return inventory.filter((instance) => {
    if (seen.has(instance.instanceId)) {
      return false;
    }
    seen.add(instance.instanceId);
    return true;
  });
}

function sanitizeItemInstanceId(value: string): string {
  return value.replace(/[^a-zA-Z0-9_-]/g, "_");
}

const RESOURCE_KEYS: ResourceKey[] = ["crowns", "stone", "iron", "aether"];

function normalizeResourceBag(value: unknown): ResourceBag {
  const source = isRecord(value) ? value : {};
  return Object.fromEntries(
    RESOURCE_KEYS.map((resource) => [resource, clampInteger(source[resource], 0)])
  ) as ResourceBag;
}

function normalizeFactionReputation(value: Record<string, number>): Record<string, number> {
  const reputation = { ...DEFAULT_FACTION_REPUTATION };
  Object.entries(value).forEach(([factionId, amount]) => {
    reputation[factionId] = Math.round(clampNumberRange(amount, -100, 100));
  });
  return reputation;
}

function normalizeStringNumberRecord(value: unknown): Record<string, number> {
  if (!isRecord(value)) {
    return {};
  }
  return Object.entries(value).reduce<Record<string, number>>((normalized, [key, amount]) => {
    if (key.trim() && isFiniteNumber(amount) && amount > 0) {
      normalized[key] = Math.floor(amount);
    }
    return normalized;
  }, {});
}

function normalizeStrongholdUpgradeRanks(ranksValue: unknown, legacyIdsValue: unknown): Record<string, number> {
  const ranks: Record<string, number> = {};
  if (isRecord(ranksValue)) {
    Object.entries(ranksValue).forEach(([upgradeId, rank]) => {
      if (isStrongholdUpgradeId(upgradeId) && isFiniteNumber(rank) && rank > 0) {
        ranks[upgradeId] = Math.floor(rank);
      }
    });
  }
  if (arrayOfStrings(legacyIdsValue)) {
    legacyIdsValue.forEach((upgradeId) => {
      if (isStrongholdUpgradeId(upgradeId)) {
        ranks[upgradeId] = Math.max(ranks[upgradeId] ?? 0, 1);
      }
    });
  }
  return ranks;
}

function normalizeRetinueUnits(value: unknown): RetinueUnitSaveData[] {
  if (!Array.isArray(value)) {
    return [];
  }
  const seen = new Set<string>();
  return value
    .map(normalizeRetinueUnit)
    .filter((unit): unit is RetinueUnitSaveData => {
      if (!unit || seen.has(unit.retinueUnitId)) {
        return false;
      }
      seen.add(unit.retinueUnitId);
      return true;
    });
}

function normalizeRetinueDeploymentIds(
  value: unknown,
  retinueUnits: RetinueUnitSaveData[],
  strongholdUpgradeRanks: Record<string, number>
): string[] {
  const activeIds = retinueUnits.filter((unit) => unit.status === "active").map((unit) => unit.retinueUnitId);
  const activeIdSet = new Set(activeIds);
  const source = arrayOfStrings(value) ? value : activeIds;
  const deploymentCap =
    RETINUE_BASE_DEPLOYMENT_CAPACITY +
    ((strongholdUpgradeRanks.training_yard_ii ?? 0) > 0 ? RETINUE_TRAINING_YARD_II_DEPLOYMENT_BONUS : 0);
  const selected: string[] = [];
  source.forEach((unitId) => {
    if (activeIdSet.has(unitId) && !selected.includes(unitId)) {
      selected.push(unitId);
    }
  });
  return selected.slice(0, deploymentCap);
}

function normalizeRetinueUnit(value: unknown): RetinueUnitSaveData | undefined {
  if (!isRecord(value)) {
    return undefined;
  }
  if (
    typeof value.retinueUnitId !== "string" ||
    !value.retinueUnitId.trim() ||
    typeof value.unitTypeId !== "string" ||
    !UNIT_BY_ID[value.unitTypeId] ||
    !isRetinueEligibleUnitTypeId(value.unitTypeId) ||
    !isUnitVeterancyRankId(value.rank)
  ) {
    return undefined;
  }
  return {
    retinueUnitId: value.retinueUnitId,
    unitTypeId: value.unitTypeId,
    name: typeof value.name === "string" && value.name.trim() ? value.name : undefined,
    rank: value.rank,
    xp: clampInteger(value.xp, 0),
    kills: clampInteger(value.kills, 0),
    sourceBattleId: typeof value.sourceBattleId === "string" && value.sourceBattleId.trim() ? value.sourceBattleId : "unknown",
    acquiredAt: typeof value.acquiredAt === "string" ? value.acquiredAt : new Date().toISOString(),
    status: value.status === "wounded" ? "wounded" : "active",
    battlesSurvived: clampInteger(value.battlesSurvived, 0),
    missionsDeployed: clampInteger(value.missionsDeployed, 0)
  };
}

function normalizeRivalStates(value: unknown): CampaignRivalSaveData[] {
  if (!Array.isArray(value)) {
    return [];
  }
  const seen = new Set<string>();
  return value
    .map(normalizeRivalState)
    .filter((rival): rival is CampaignRivalSaveData => {
      if (!rival || seen.has(rival.enemyHeroId)) {
        return false;
      }
      seen.add(rival.enemyHeroId);
      return true;
    });
}

function normalizeRivalState(value: unknown): CampaignRivalSaveData | undefined {
  if (!isRecord(value)) {
    return undefined;
  }
  if (typeof value.enemyHeroId !== "string" || !ENEMY_HERO_BY_ID[value.enemyHeroId]) {
    return undefined;
  }
  const activeModifiers = arrayOfStrings(value.activeModifiers)
    ? value.activeModifiers.filter(isRivalModifierId)
    : [];
  return {
    enemyHeroId: value.enemyHeroId,
    encounters: clampInteger(value.encounters, 0),
    defeats: clampInteger(value.defeats, 0),
    victoriesAgainstPlayer: clampInteger(value.victoriesAgainstPlayer, 0),
    lastEncounterNodeId:
      typeof value.lastEncounterNodeId === "string" && value.lastEncounterNodeId.trim()
        ? value.lastEncounterNodeId
        : undefined,
    lastOutcome: isRivalLastOutcome(value.lastOutcome) ? value.lastOutcome : "unseen",
    disposition: isRivalDisposition(value.disposition) ? value.disposition : "wary",
    activeModifiers: [...new Set(activeModifiers)],
    isKnownToPlayer: typeof value.isKnownToPlayer === "boolean" ? value.isKnownToPlayer : false
  };
}

function normalizeRivalTrophies(value: unknown): RivalTrophySaveData[] {
  if (!Array.isArray(value)) {
    return [];
  }
  const seen = new Set<string>();
  return value
    .map(normalizeRivalTrophy)
    .filter((trophy): trophy is RivalTrophySaveData => {
      if (!trophy || seen.has(trophy.trophyId)) {
        return false;
      }
      seen.add(trophy.trophyId);
      return true;
    });
}

function normalizeRivalTrophy(value: unknown): RivalTrophySaveData | undefined {
  if (!isRecord(value)) {
    return undefined;
  }
  if (
    typeof value.trophyId !== "string" ||
    !value.trophyId.trim() ||
    typeof value.enemyHeroId !== "string" ||
    !ENEMY_HERO_BY_ID[value.enemyHeroId] ||
    typeof value.label !== "string" ||
    !value.label.trim() ||
    typeof value.description !== "string" ||
    !value.description.trim()
  ) {
    return undefined;
  }
  const sourceNodeId =
    typeof value.sourceNodeId === "string" && CAMPAIGN_NODE_BY_ID[value.sourceNodeId]
      ? value.sourceNodeId
      : "unknown";
  return {
    trophyId: value.trophyId,
    enemyHeroId: value.enemyHeroId,
    earnedAt: typeof value.earnedAt === "string" ? value.earnedAt : new Date().toISOString(),
    sourceNodeId,
    label: value.label,
    description: value.description,
    effect: typeof value.effect === "string" && value.effect.trim() ? value.effect : undefined
  };
}
