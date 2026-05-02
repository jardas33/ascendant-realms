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

export const RETINUE_BASE_CAPACITY = 2;
export const RETINUE_TRAINING_YARD_II_CAPACITY_BONUS = 1;

export interface RetinueAddResult {
  ok: boolean;
  campaign: CampaignSaveData;
  retinueUnit?: RetinueUnitSaveData;
  reason?: string;
}

export function getRetinueCapacity(campaign: CampaignSaveData): number {
  const trainingYardBonus =
    (campaign.strongholdUpgradeRanks.training_yard_ii ?? 0) > 0
      ? RETINUE_TRAINING_YARD_II_CAPACITY_BONUS
      : 0;
  return RETINUE_BASE_CAPACITY + trainingYardBonus;
}

export function activeRetinueUnits(campaign: CampaignSaveData): RetinueUnitSaveData[] {
  return campaign.retinueUnits.filter((unit) => unit.status === "active");
}

export function isRetinueEligibleVeteran(entry: UnitVeterancySummaryEntry): boolean {
  return entry.survivedBattle && entry.rank !== "recruit";
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
    status: "active"
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
      reason: "Only surviving Seasoned or better units can join the retinue."
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

  if (activeRetinueUnits(campaign).length >= getRetinueCapacity(campaign)) {
    return {
      ok: false,
      campaign,
      retinueUnit,
      reason: "Retinue capacity is full."
    };
  }

  return {
    ok: true,
    campaign: {
      ...campaign,
      retinueUnits: [...campaign.retinueUnits, retinueUnit]
    },
    retinueUnit
  };
}

export function dismissRetinueUnit(campaign: CampaignSaveData, retinueUnitId: string): CampaignSaveData {
  return {
    ...campaign,
    retinueUnits: campaign.retinueUnits.filter((unit) => unit.retinueUnitId !== retinueUnitId)
  };
}

export function updateRetinueAfterBattle(
  campaign: CampaignSaveData,
  summary: UnitVeterancyBattleSummary | undefined,
  lostRetinueUnitIds: string[] = []
): CampaignSaveData {
  const lost = new Set(lostRetinueUnitIds);
  const entriesById = new Map((summary?.notableVeterans ?? []).map((entry) => [entry.unitInstanceId, entry]));
  return {
    ...campaign,
    retinueUnits: campaign.retinueUnits
      .filter((unit) => !lost.has(unit.retinueUnitId))
      .map((unit) => {
        const entry = entriesById.get(unit.retinueUnitId);
        if (!entry) {
          return unit;
        }
        return {
          ...unit,
          rank: higherRank(unit.rank, entry.rank),
          xp: Math.max(unit.xp, Math.floor(entry.xp)),
          kills: Math.max(unit.kills, Math.floor(entry.kills)),
          status: "active"
        };
      })
  };
}

export function retinueDeploymentUnits(campaign: CampaignSaveData): RetinueUnitSaveData[] {
  return activeRetinueUnits(campaign).slice(0, getRetinueCapacity(campaign));
}

export function formatRetinueUnitName(unit: RetinueUnitSaveData): string {
  return unit.name?.trim() || UNIT_BY_ID[unit.unitTypeId]?.name || unit.unitTypeId;
}

export function formatRetinueUnitSummary(unit: RetinueUnitSaveData): string {
  const rank = getUnitVeterancyRank(unit.rank);
  return `${rank.name} ${formatRetinueUnitName(unit)} (${unit.xp} XP, ${unit.kills} kills)`;
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
