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
export const RETINUE_RECOVERY_HP_RATIO_THRESHOLD = 0.35;
export const RETINUE_RECOVERY_MISSION_STEPS = 1;

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
  readyCount: number;
  recoveringCount: number;
  reserveCount: number;
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

export interface RetinueHealthSnapshot {
  retinueUnitId: string;
  hpRatio: number;
}

export interface RetinueBattleUpdateSummary {
  participatingUnitIds: string[];
  survivedIds: string[];
  lostIds: string[];
  enteredRecoveryIds: string[];
  returnedReadyIds: string[];
  reinforcementUsed: boolean;
  reinforcementUnitId?: string;
}

export interface RetinueBattleUpdateResult {
  campaign: CampaignSaveData;
  summary: RetinueBattleUpdateSummary;
}

export interface RetinueBattleUpdateOptions {
  lostRetinueUnitIds?: string[];
  participatingRetinueUnitIds?: string[];
  survivorHealth?: RetinueHealthSnapshot[];
  progressionStepCompleted?: boolean;
  reinforcementUsed?: boolean;
  reinforcementUnitId?: string;
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

export function retinueRosterUnits(campaign: CampaignSaveData): RetinueUnitSaveData[] {
  return campaign.retinueUnits.filter(
    (unit) => (unit.status === "active" || unit.status === "recovering") && isRetinueEligibleUnitTypeId(unit.unitTypeId)
  );
}

export function recoveringRetinueUnits(campaign: CampaignSaveData): RetinueUnitSaveData[] {
  return retinueRosterUnits(campaign).filter((unit) => unit.status === "recovering");
}

export function retinueReserveUnits(campaign: CampaignSaveData): RetinueUnitSaveData[] {
  const selectedIds = new Set(selectedRetinueUnitIds(campaign));
  return retinueRosterUnits(campaign).filter((unit) => !selectedIds.has(unit.retinueUnitId));
}

export function getRetinueCapacityBreakdown(campaign: CampaignSaveData): RetinueCapacityBreakdown {
  const trainingYardBonus =
    (campaign.strongholdUpgradeRanks.training_yard_ii ?? 0) > 0
      ? RETINUE_TRAINING_YARD_II_DEPLOYMENT_BONUS
      : 0;
  const roster = retinueRosterUnits(campaign);
  const ready = activeRetinueUnits(campaign);
  const selected = retinueDeploymentUnits(campaign);
  const selectedCount = retinueDeploymentUnits(campaign).length;
  return {
    activeCount: roster.length,
    capacity: getRetinueRosterCapacity(campaign),
    rosterCapacity: getRetinueRosterCapacity(campaign),
    baseRosterCapacity: RETINUE_ROSTER_CAPACITY,
    readyCount: ready.length,
    recoveringCount: roster.length - ready.length,
    reserveCount: Math.max(0, ready.length - selected.length),
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

  if (retinueRosterUnits(campaign).length >= getRetinueRosterCapacity(campaign)) {
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
  return updateRetinueAfterBattleDetailed(campaign, summary, { lostRetinueUnitIds }).campaign;
}

export function updateRetinueAfterBattleDetailed(
  campaign: CampaignSaveData,
  summary: UnitVeterancyBattleSummary | undefined,
  options: RetinueBattleUpdateOptions = {}
): RetinueBattleUpdateResult {
  const lost = new Set(options.lostRetinueUnitIds ?? []);
  const participatingUnitIds = uniqueStrings(
    options.participatingRetinueUnitIds ?? retinueDeploymentUnits(campaign).map((unit) => unit.retinueUnitId)
  );
  const participatingIds = new Set(participatingUnitIds);
  const lowHealthIds = new Set(
    (options.survivorHealth ?? [])
      .filter((snapshot) => snapshot.hpRatio <= RETINUE_RECOVERY_HP_RATIO_THRESHOLD)
      .map((snapshot) => snapshot.retinueUnitId)
  );
  const entriesById = new Map((summary?.notableVeterans ?? []).map((entry) => [entry.unitInstanceId, entry]));
  const enteredRecoveryIds: string[] = [];
  const returnedReadyIds: string[] = [];
  const lostIds: string[] = [];
  const nextRetinueUnits = campaign.retinueUnits
    .filter((unit) => {
      const removed = lost.has(unit.retinueUnitId);
      if (removed) {
        lostIds.push(unit.retinueUnitId);
      }
      return !removed;
    })
    .map((unit) => {
      const entry = entriesById.get(unit.retinueUnitId);
      const participated = participatingIds.has(unit.retinueUnitId);
      const base: RetinueUnitSaveData = {
        ...unit,
        missionsDeployed: (unit.missionsDeployed ?? 0) + (participated ? 1 : 0),
        battlesSurvived: (unit.battlesSurvived ?? 0) + (participated ? 1 : 0)
      };
      const withVeterancy = entry
        ? {
            ...base,
            rank: higherRank(unit.rank, entry.rank),
            xp: Math.max(unit.xp, Math.floor(entry.xp)),
            kills: Math.max(unit.kills, Math.floor(entry.kills))
          }
        : base;
      if (participated && lowHealthIds.has(unit.retinueUnitId)) {
        enteredRecoveryIds.push(unit.retinueUnitId);
        return {
          ...withVeterancy,
          status: "recovering" as const,
          recoveryMissionsRemaining: RETINUE_RECOVERY_MISSION_STEPS
        };
      }
      if (withVeterancy.status === "recovering") {
        const remaining = options.progressionStepCompleted
          ? Math.max(0, (withVeterancy.recoveryMissionsRemaining ?? RETINUE_RECOVERY_MISSION_STEPS) - 1)
          : withVeterancy.recoveryMissionsRemaining ?? RETINUE_RECOVERY_MISSION_STEPS;
        if (remaining <= 0) {
          returnedReadyIds.push(unit.retinueUnitId);
          return {
            ...withVeterancy,
            status: "active" as const,
            recoveryMissionsRemaining: undefined
          };
        }
        return {
          ...withVeterancy,
          status: "recovering" as const,
          recoveryMissionsRemaining: remaining
        };
      }
      return {
        ...withVeterancy,
        status: "active" as const,
        recoveryMissionsRemaining: undefined
      };
    });
  const nextCampaign = {
    ...campaign,
    retinueUnits: nextRetinueUnits,
    retinueDeploymentIds: selectedRetinueUnitIds({
      ...campaign,
      retinueUnits: nextRetinueUnits
    })
  };
  const survivedIds = participatingUnitIds.filter((unitId) => !lost.has(unitId));
  return {
    campaign: nextCampaign,
    summary: {
      participatingUnitIds,
      survivedIds,
      lostIds: uniqueStrings(lostIds),
      enteredRecoveryIds: uniqueStrings(enteredRecoveryIds),
      returnedReadyIds: uniqueStrings(returnedReadyIds),
      reinforcementUsed: Boolean(options.reinforcementUsed),
      reinforcementUnitId: options.reinforcementUnitId
    }
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
  const unit = retinueRosterUnits(campaign).find((entry) => entry.retinueUnitId === retinueUnitId);
  if (!unit) {
    return {
      ok: false,
      campaign,
      selected: false,
      reason: "That Retinue unit is not available."
    };
  }
  if (unit.status === "recovering") {
    return {
      ok: false,
      campaign,
      selected: false,
      reason: "Recovering Retinue units cannot deploy until ready."
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
  return `${rank.name} ${formatRetinueUnitName(unit)} (${formatRetinueStatusLabel(unit)}, ${unit.xp} XP, ${unit.kills} kills, ${unit.battlesSurvived ?? 0} survived, ${unit.missionsDeployed ?? 0} deployed)`;
}

export function formatRetinueDeploymentLabel(unit: RetinueUnitSaveData): string {
  const rank = getUnitVeterancyRank(unit.rank);
  const unitTypeName = UNIT_BY_ID[unit.unitTypeId]?.name ?? formatRetinueUnitName(unit);
  return `${rank.name} ${unitTypeName}`;
}

export function formatRetinueStatusLabel(unit: RetinueUnitSaveData, selected = false): string {
  if (unit.status === "recovering") {
    const remaining = Math.max(1, unit.recoveryMissionsRemaining ?? RETINUE_RECOVERY_MISSION_STEPS);
    return `Recovering (${remaining} mission${remaining === 1 ? "" : "s"})`;
  }
  return selected ? "Deployed" : "Ready";
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

function uniqueStrings(values: readonly string[]): string[] {
  return [...new Set(values.filter((value) => typeof value === "string" && value.trim()))];
}
