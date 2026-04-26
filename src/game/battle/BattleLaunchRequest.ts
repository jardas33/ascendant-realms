import type { BattleDifficulty, BattleMapDefinition, RewardTableDefinition } from "../core/GameTypes";
import { isHeroSaveData, normalizeHeroSaveData } from "../core/SaveSystem";
import { DEFAULT_BATTLE_DIFFICULTY, isBattleDifficulty } from "../data/battlePacing";
import { MAP_BY_ID, REWARD_TABLE_BY_ID } from "../data/contentIndex";
import { DEFAULT_MAP_ID } from "../data/maps";
import type { HeroSaveData } from "../save/SaveTypes";

export type BattleLaunchMode = "skirmish" | "campaign_node" | "scenario_mission";

export interface BattleLaunchModifier {
  id: string;
  value?: string | number | boolean;
}

export interface BattleLaunchRequest {
  requestId: string;
  mode: BattleLaunchMode;
  mapId: string;
  heroSave: HeroSaveData;
  sourceId: string;
  rewardTableId?: string;
  difficulty: BattleDifficulty;
  modifiers: BattleLaunchModifier[];
  enemyProfileId?: string;
  campaignNodeId?: string;
  scenarioMissionId?: string;
}

export interface ResolvedBattleLaunch {
  request: BattleLaunchRequest;
  map: BattleMapDefinition;
  rewardTable: RewardTableDefinition;
  rewardTableId: string;
}

export interface BattleLaunchIndexes {
  mapsById: Record<string, BattleMapDefinition>;
  rewardTablesById: Record<string, RewardTableDefinition>;
}

export type BattleLaunchResolution =
  | { ok: true; launch: ResolvedBattleLaunch }
  | { ok: false; errors: string[] };

export interface CreateBattleLaunchRequestOptions {
  requestId?: string;
  mode?: BattleLaunchMode;
  mapId?: string;
  sourceId?: string;
  rewardTableId?: string;
  difficulty?: BattleDifficulty;
  modifiers?: BattleLaunchModifier[];
  enemyProfileId?: string;
  campaignNodeId?: string;
  scenarioMissionId?: string;
}

const defaultIndexes: BattleLaunchIndexes = {
  mapsById: MAP_BY_ID,
  rewardTablesById: REWARD_TABLE_BY_ID
};

export function createSkirmishBattleLaunchRequest(
  heroSave: HeroSaveData,
  options: CreateBattleLaunchRequestOptions = {}
): BattleLaunchRequest {
  return createBattleLaunchRequest(heroSave, { ...options, mode: options.mode ?? "skirmish" });
}

export function createBattleLaunchRequest(
  heroSave: HeroSaveData,
  options: CreateBattleLaunchRequestOptions = {}
): BattleLaunchRequest {
  const mode = options.mode ?? "skirmish";
  const mapId = options.mapId ?? DEFAULT_MAP_ID;
  const sourceId = options.sourceId ?? mode;
  return {
    requestId: options.requestId ?? buildBattleLaunchRequestId(mode, mapId, sourceId),
    mode,
    mapId,
    heroSave,
    sourceId,
    rewardTableId: options.rewardTableId,
    difficulty: options.difficulty ?? DEFAULT_BATTLE_DIFFICULTY,
    modifiers: options.modifiers ?? [],
    enemyProfileId: options.enemyProfileId,
    campaignNodeId: options.campaignNodeId,
    scenarioMissionId: options.scenarioMissionId
  };
}

export function cloneBattleLaunchRequestWithHero(
  request: BattleLaunchRequest,
  heroSave: HeroSaveData,
  overrides: Partial<Pick<BattleLaunchRequest, "requestId" | "sourceId">> = {}
): BattleLaunchRequest {
  return {
    ...request,
    requestId: overrides.requestId ?? request.requestId,
    sourceId: overrides.sourceId ?? request.sourceId,
    heroSave
  };
}

export function resolveBattleLaunchRequest(
  request: BattleLaunchRequest,
  indexes: BattleLaunchIndexes = defaultIndexes
): BattleLaunchResolution {
  const errors: string[] = [];
  const map = indexes.mapsById[request.mapId];
  const heroSave = normalizeHeroSaveData(request.heroSave);

  if (!request.requestId.trim()) {
    errors.push("Battle launch request must include a requestId.");
  }
  if (!request.sourceId.trim()) {
    errors.push("Battle launch request must include a sourceId.");
  }
  if (!map) {
    errors.push(`Battle launch request references missing map ${request.mapId}.`);
  }
  if (!isHeroSaveData(request.heroSave) || !heroSave) {
    errors.push("Battle launch request includes invalid hero save data.");
  }

  const rewardTableId = request.rewardTableId ?? map?.scenario.rewardTableId ?? "";
  const rewardTable = rewardTableId ? indexes.rewardTablesById[rewardTableId] : undefined;
  if (!rewardTable) {
    errors.push(`Battle launch request references missing reward table ${rewardTableId || "(empty)"}.`);
  }

  if (request.mode === "campaign_node" && !request.campaignNodeId) {
    errors.push("Campaign battle launch requests must include campaignNodeId.");
  }
  if (request.mode === "scenario_mission" && !request.scenarioMissionId) {
    errors.push("Scenario mission battle launch requests must include scenarioMissionId.");
  }
  if (!isBattleDifficulty(request.difficulty)) {
    errors.push(`Battle launch request references missing difficulty ${request.difficulty}.`);
  }

  if (errors.length > 0 || !map || !rewardTable || !heroSave) {
    return { ok: false, errors };
  }

  return {
    ok: true,
    launch: {
      request: {
        ...request,
        heroSave,
        rewardTableId,
        difficulty: request.difficulty ?? DEFAULT_BATTLE_DIFFICULTY,
        modifiers: request.modifiers ?? []
      },
      map,
      rewardTable,
      rewardTableId
    }
  };
}

export function requireBattleLaunch(request: BattleLaunchRequest): ResolvedBattleLaunch {
  const resolved = resolveBattleLaunchRequest(request);
  if (!resolved.ok) {
    throw new Error(`Invalid battle launch request: ${resolved.errors.join(" ")}`);
  }
  return resolved.launch;
}

function buildBattleLaunchRequestId(mode: BattleLaunchMode, mapId: string, sourceId: string): string {
  return `${mode}:${sourceId}:${mapId}`;
}
