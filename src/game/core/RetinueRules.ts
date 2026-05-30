import type {
  CampaignSaveData,
  RetinueUnitSaveData
} from "../save/SaveTypes";
import type {
  UnitVeterancyBattleSummary,
  UnitVeterancyRankId,
  UnitVeterancySummaryEntry
} from "./GameTypes";
import { UNIT_BY_ID } from "../data/contentIndex";
import { getUnitVeterancyRank } from "../data/unitVeterancy";

export const RETINUE_ELIGIBLE_UNIT_TYPE_IDS = ["militia", "ranger", "acolyte"] as const;
export type RetinueEligibleUnitTypeId = (typeof RETINUE_ELIGIBLE_UNIT_TYPE_IDS)[number];

export const RETINUE_ROSTER_CAPACITY = 5;
export const RETINUE_BASE_DEPLOYMENT_CAPACITY = 2;
export const RETINUE_TRAINING_YARD_II_DEPLOYMENT_BONUS = 1;

export interface RetinueAddResult {
  ok: boolean;
  campaign: CampaignSaveData;
  retinueUnit?: RetinueUnitSaveData;
  reason?: string;
}

export interface RetinueCapacityBreakdown {
  activeCount: number;
  capacity: number;
  rosterCapacity: number;
  baseRosterCapacity: number;
  deploymentCount: number;
  deploymentCapacity: number;
  baseDeploymentCapacity: number;
  trainingYardDeploymentBonus: number;
}

export interface RetinueDeploymentToggleResult {
  ok: boolean;
  campaign: CampaignSaveData;
  selected: boolean;
  reason?: string;
}

export function getRetinueCapacity(campaign: CampaignSaveData): number {
  return getRetinueRosterCapacity(campaign);
}

export function getRetinueRosterCapacity(_campaign: CampaignSaveData): number {
  return RETINUE_ROSTER_CAPACITY;
}

export function getRetinueDeploymentCapacity(campaign: CampaignSaveData): number {
  const trainingYardBonus =
    (campaign.strongholdUpgradeRanks.training_yard_ii ?? 0) > 0
      ? RETINUE_TRAINING_YARD_II_DEPLOYMENT_BONUS
      : 0;
  return RETINUE_BASE_DEPLOYMENT_CAPACITY + trainingYardBonus;
}

export function activeRetinueUnits(campaign: CampaignSaveData): RetinueUnitSaveData[] {
  return campaign.retinueUnits.filter((unit) => unit.status === "active" && isRetinueEligibleUnitTypeId(unit.unitTypeId));
}

export function getRetinueCapacityBreakdown(campaign: CampaignSaveData): RetinueCapacityBreakdown {
  const trainingYardBonus =
    (campaign.strongholdUpgradeRanks.training_yard_ii ?? 0) > 0
      ? RETINUE_TRAINING_YARD_II_DEPLOYMENT_BONUS
      : 0;
  const selectedCount = retinueDeploymentUnits(campaign).length;
  return {
    activeCount: activeRetinueUnits(campaign).length,
    capacity: getRetinueRosterCapacity(campaign),
    rosterCapacity: getRetinueRosterCapacity(campaign),
    baseRosterCapacity: RETINUE_ROSTER_CAPACITY,
    deploymentCount: selectedCount,
    deploymentCapacity: RETINUE_BASE_DEPLOYMENT_CAPACITY + trainingYardBonus,
    baseDeploymentCapacity: RETINUE_BASE_DEPLOYMENT_CAPACITY,
    trainingYardDeploymentBonus: trainingYardBonus
  };
}

export function isRetinueEligibleUnitTypeId(value: string): value is RetinueEligibleUnitTypeId {
  return (RETINUE_ELIGIBLE_UNIT_TYPE_IDS as readonly string[]).includes(value);
}

export function isRetinueEligibleVeteran(entry: UnitVeterancySummaryEntry): boolean {
  return entry.survivedBattle && entry.rank !== "recruit" && isRetinueEligibleUnitTypeId(entry.unitTypeId);
}

export function retinueEligibilityReason(entry: UnitVeterancySummaryEntry): string {
  if (!isRetinueEligibleUnitTypeId(entry.unitTypeId)) {
    return "Not eligible: only Militia, Rangers, and Acolytes can join the retinue.";
  }
  if (!entry.survivedBattle) {
    return "Not eligible: did not survive the battle.";
  }
  if (entry.rank === "recruit") {
    return "Not eligible: needs Seasoned rank or better.";
  }
  return "Eligible: survived at Seasoned rank or better.";
}

export function createRetinueUnitFromVeteran(
  entry: UnitVeterancySummaryEntry,
  sourceBattleId: string,
  acquiredAt = new Date().toISOString()
): RetinueUnitSaveData {
  return {
    retinueUnitId: createRetinueUnitId(sourceBattleId, entry.unitInstanceId),
    unitTypeId: entry.unitTypeId,
    name: entry.unitName,
    rank: entry.rank,
    xp: Math.max(0, Math.floor(entry.xp)),
    kills: Math.max(0, Math.floor(entry.kills)),
    sourceBattleId,
    acquiredAt,
    status: "active",
    battlesSurvived: 1,
    missionsDeployed: 0
  };
}

export function addVeteranToRetinue(
  campaign: CampaignSaveData,
  entry: UnitVeterancySummaryEntry,
  sourceBattleId: string,
  acquiredAt?: string
): RetinueAddResult {
  if (!isRetinueEligibleVeteran(entry)) {
    return {
      ok: false,
      campaign,
      reason: retinueEligibilityReason(entry)
    };
  }

  const retinueUnit = createRetinueUnitFromVeteran(entry, sourceBattleId, acquiredAt);
  if (
    campaign.retinueUnits.some(
      (unit) => unit.retinueUnitId === retinueUnit.retinueUnitId || unit.retinueUnitId === entry.unitInstanceId
    )
  ) {
    return {
      ok: false,
      campaign,
      retinueUnit,
      reason: `${formatRetinueUnitName(retinueUnit)} is already in the retinue.`
    };
  }

  if (activeRetinueUnits(campaign).length >= getRetinueRosterCapacity(campaign)) {
    return {
      ok: false,
      campaign,
      retinueUnit,
      reason: "Retinue roster is full."
    };
  }

  const selectedIds = selectedRetinueUnitIds(campaign);
  const nextDeploymentIds =
    selectedIds.length < getRetinueDeploymentCapacity(campaign)
      ? [...selectedIds, retinueUnit.retinueUnitId]
      : selectedIds;

  return {
    ok: true,
    campaign: {
      ...campaign,
      retinueUnits: [...campaign.retinueUnits, retinueUnit],
      retinueDeploymentIds: nextDeploymentIds
    },
    retinueUnit
  };
}

export function dismissRetinueUnit(campaign: CampaignSaveData, retinueUnitId: string): CampaignSaveData {
  return {
    ...campaign,
    retinueUnits: campaign.retinueUnits.filter((unit) => unit.retinueUnitId !== retinueUnitId),
    retinueDeploymentIds: selectedRetinueUnitIds(campaign).filter((unitId) => unitId !== retinueUnitId)
  };
}

export function updateRetinueAfterBattle(
  campaign: CampaignSaveData,
  summary: UnitVeterancyBattleSummary | undefined,
  lostRetinueUnitIds: string[] = []
): CampaignSaveData {
  const lost = new Set(lostRetinueUnitIds);
  const deployedIds = new Set(retinueDeploymentUnits(campaign).map((unit) => unit.retinueUnitId));
  const entriesById = new Map((summary?.notableVeterans ?? []).map((entry) => [entry.unitInstanceId, entry]));
  const nextRetinueUnits = campaign.retinueUnits
    .filter((unit) => !lost.has(unit.retinueUnitId))
    .map((unit) => {
      const entry = entriesById.get(unit.retinueUnitId);
      const deployed = deployedIds.has(unit.retinueUnitId);
      const base = {
        ...unit,
        missionsDeployed: (unit.missionsDeployed ?? 0) + (deployed ? 1 : 0),
        battlesSurvived: (unit.battlesSurvived ?? 0) + (deployed ? 1 : 0)
      };
      if (!entry) {
        return base;
      }
      return {
        ...base,
        rank: higherRank(unit.rank, entry.rank),
        xp: Math.max(unit.xp, Math.floor(entry.xp)),
        kills: Math.max(unit.kills, Math.floor(entry.kills)),
        status: "active" as const
      };
    });
  return {
    ...campaign,
    retinueUnits: nextRetinueUnits,
    retinueDeploymentIds: selectedRetinueUnitIds({
      ...campaign,
      retinueUnits: nextRetinueUnits
    }).filter((unitId) => !lost.has(unitId))
  };
}

export function retinueDeploymentUnits(campaign: CampaignSaveData): RetinueUnitSaveData[] {
  const activeUnits = activeRetinueUnits(campaign);
  const activeById = new Map(activeUnits.map((unit) => [unit.retinueUnitId, unit]));
  return selectedRetinueUnitIds(campaign)
    .map((unitId) => activeById.get(unitId))
    .filter((unit): unit is RetinueUnitSaveData => Boolean(unit))
    .slice(0, getRetinueDeploymentCapacity(campaign));
}

export function selectedRetinueUnitIds(campaign: CampaignSaveData): string[] {
  const activeIds = new Set(activeRetinueUnits(campaign).map((unit) => unit.retinueUnitId));
  const source = Array.isArray(campaign.retinueDeploymentIds)
    ? campaign.retinueDeploymentIds
    : activeRetinueUnits(campaign).map((unit) => unit.retinueUnitId);
  const selected: string[] = [];
  source.forEach((unitId) => {
    if (activeIds.has(unitId) && !selected.includes(unitId)) {
      selected.push(unitId);
    }
  });
  return selected.slice(0, getRetinueDeploymentCapacity(campaign));
}

export function toggleRetinueDeployment(campaign: CampaignSaveData, retinueUnitId: string): RetinueDeploymentToggleResult {
  const activeIds = new Set(activeRetinueUnits(campaign).map((unit) => unit.retinueUnitId));
  if (!activeIds.has(retinueUnitId)) {
    return {
      ok: false,
      campaign,
      selected: false,
      reason: "That Retinue unit is not available."
    };
  }
  const selectedIds = selectedRetinueUnitIds(campaign);
  if (selectedIds.includes(retinueUnitId)) {
    return {
      ok: true,
      campaign: {
        ...campaign,
        retinueDeploymentIds: selectedIds.filter((unitId) => unitId !== retinueUnitId)
      },
      selected: false
    };
  }
  if (selectedIds.length >= getRetinueDeploymentCapacity(campaign)) {
    return {
      ok: false,
      campaign,
      selected: false,
      reason: "Retinue deployment cap reached."
    };
  }
  return {
    ok: true,
    campaign: {
      ...campaign,
      retinueDeploymentIds: [...selectedIds, retinueUnitId]
    },
    selected: true
  };
}

export function formatRetinueUnitName(unit: RetinueUnitSaveData): string {
  return unit.name?.trim() || UNIT_BY_ID[unit.unitTypeId]?.name || unit.unitTypeId;
}

export function formatRetinueUnitSummary(unit: RetinueUnitSaveData): string {
  const rank = getUnitVeterancyRank(unit.rank);
  return `${rank.name} ${formatRetinueUnitName(unit)} (${unit.xp} XP, ${unit.kills} kills, ${unit.battlesSurvived ?? 0} survived, ${unit.missionsDeployed ?? 0} deployed)`;
}

export function formatRetinueDeploymentLabel(unit: RetinueUnitSaveData): string {
  const rank = getUnitVeterancyRank(unit.rank);
  const unitTypeName = UNIT_BY_ID[unit.unitTypeId]?.name ?? formatRetinueUnitName(unit);
  return `${rank.name} ${unitTypeName}`;
}

function createRetinueUnitId(sourceBattleId: string, unitInstanceId: string): string {
  return `retinue:${sanitizeId(sourceBattleId)}:${sanitizeId(unitInstanceId)}`;
}

function sanitizeId(value: string): string {
  return value.replace(/[^a-zA-Z0-9_-]/g, "_");
}

function higherRank(left: UnitVeterancyRankId, right: UnitVeterancyRankId): UnitVeterancyRankId {
  return getUnitVeterancyRank(right).minXp > getUnitVeterancyRank(left).minXp ? right : left;
}
