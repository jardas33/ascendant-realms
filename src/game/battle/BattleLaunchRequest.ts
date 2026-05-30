import type {
  BattleDifficulty,
  BattleMapDefinition,
  CampaignNodeDefinition,
  EnemyAIPersonalityId,
  RewardTableDefinition
} from "../core/GameTypes";
import { isRetinueEligibleUnitTypeId } from "../core/RetinueRules";
import { isHeroSaveData, normalizeHeroSaveData } from "../core/SaveSystem";
import { DEFAULT_AI_PERSONALITY_ID, isAIPersonalityId } from "../data/aiPersonalities";
import { DEFAULT_BATTLE_DIFFICULTY, isBattleDifficulty } from "../data/battlePacing";
import {
  CAMPAIGN_NODE_BY_ID,
  ENEMY_HERO_BY_ID,
  ENEMY_PRESSURE_PLAN_BY_ID,
  FACTION_BY_ID,
  MAP_BY_ID,
  REWARD_TABLE_BY_ID,
  UNIT_BY_ID
} from "../data/contentIndex";
import { DEFAULT_MAP_ID } from "../data/maps";
import { isUnitVeterancyRankId } from "../data/unitVeterancy";
import type { HeroSaveData, RetinueUnitSaveData } from "../save/SaveTypes";

export type BattleLaunchMode = "skirmish" | "campaign_node" | "scenario_mission" | "tutorial";

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
  aiPersonalityId?: EnemyAIPersonalityId;
  enemyHeroId?: string;
  enemyPressurePlanId?: string;
  campaignNodeId?: string;
  scenarioMissionId?: string;
  retinueUnits?: RetinueUnitSaveData[];
  retinueReserveUnits?: RetinueUnitSaveData[];
  rewardsDisabled?: boolean;
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
  aiPersonalityId?: EnemyAIPersonalityId;
  enemyHeroId?: string;
  enemyPressurePlanId?: string;
  campaignNodeId?: string;
  scenarioMissionId?: string;
  retinueUnits?: RetinueUnitSaveData[];
  retinueReserveUnits?: RetinueUnitSaveData[];
  rewardsDisabled?: boolean;
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

export function createTutorialBattleLaunchRequest(
  heroSave: HeroSaveData,
  options: CreateBattleLaunchRequestOptions = {}
): BattleLaunchRequest {
  return createBattleLaunchRequest(heroSave, {
    ...options,
    mode: "tutorial",
    sourceId: options.sourceId ?? "proving_grounds_basics",
    difficulty: options.difficulty ?? "story",
    rewardsDisabled: true
  });
}

export function createCampaignBattleLaunchRequest(
  heroSave: HeroSaveData,
  node: CampaignNodeDefinition | string,
  options: CreateBattleLaunchRequestOptions = {}
): BattleLaunchRequest {
  const definition = typeof node === "string" ? CAMPAIGN_NODE_BY_ID[node] : node;
  if (!definition) {
    return createBattleLaunchRequest(heroSave, {
      ...options,
      mode: "campaign_node",
      campaignNodeId: typeof node === "string" ? node : undefined,
      sourceId: options.sourceId ?? "campaign_missing_node"
    });
  }
  return createBattleLaunchRequest(heroSave, {
    ...options,
    mode: "campaign_node",
    mapId: definition.mapId,
    difficulty: options.difficulty ?? definition.difficulty,
    enemyProfileId: options.enemyProfileId ?? definition.enemyFactionId,
    aiPersonalityId: options.aiPersonalityId ?? definition.aiPersonalityId ?? DEFAULT_AI_PERSONALITY_ID,
    enemyHeroId: options.enemyHeroId ?? definition.enemyHeroId,
    enemyPressurePlanId: options.enemyPressurePlanId ?? definition.enemyPressurePlanId,
    campaignNodeId: definition.id,
    sourceId: options.sourceId ?? `campaign_${definition.id}`
  });
}

export function createBattleLaunchRequest(
  heroSave: HeroSaveData,
  options: CreateBattleLaunchRequestOptions = {}
): BattleLaunchRequest {
  const mode = options.mode ?? "skirmish";
  const mapId = options.mapId ?? DEFAULT_MAP_ID;
  const sourceId = options.sourceId ?? mode;
  const rewardsDisabled = options.rewardsDisabled ?? (mode === "tutorial" ? true : undefined);
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
    aiPersonalityId: options.aiPersonalityId ?? DEFAULT_AI_PERSONALITY_ID,
    enemyHeroId: options.enemyHeroId,
    enemyPressurePlanId: options.enemyPressurePlanId,
    campaignNodeId: options.campaignNodeId,
    scenarioMissionId: options.scenarioMissionId,
    retinueUnits: sanitizeLaunchRetinueUnits(options.retinueUnits),
    retinueReserveUnits: sanitizeLaunchRetinueUnits(options.retinueReserveUnits),
    rewardsDisabled
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
    heroSave,
    retinueUnits: sanitizeLaunchRetinueUnits(request.retinueUnits),
    retinueReserveUnits: sanitizeLaunchRetinueUnits(request.retinueReserveUnits)
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
  if (request.campaignNodeId && !CAMPAIGN_NODE_BY_ID[request.campaignNodeId]) {
    errors.push(`Battle launch request references missing campaign node ${request.campaignNodeId}.`);
  }
  if (request.mode === "scenario_mission" && !request.scenarioMissionId) {
    errors.push("Scenario mission battle launch requests must include scenarioMissionId.");
  }
  if (request.mode === "tutorial" && request.rewardsDisabled !== true) {
    errors.push("Tutorial battle launch requests must disable rewards.");
  }
  if (!isBattleDifficulty(request.difficulty)) {
    errors.push(`Battle launch request references missing difficulty ${request.difficulty}.`);
  }
  if (request.aiPersonalityId && !isAIPersonalityId(request.aiPersonalityId)) {
    errors.push(`Battle launch request references missing AI personality ${request.aiPersonalityId}.`);
  }
  if (request.enemyProfileId && !FACTION_BY_ID[request.enemyProfileId]) {
    errors.push(`Battle launch request references missing enemy faction ${request.enemyProfileId}.`);
  }
  if (request.enemyHeroId && !ENEMY_HERO_BY_ID[request.enemyHeroId]) {
    errors.push(`Battle launch request references missing enemy hero ${request.enemyHeroId}.`);
  }
  if (request.enemyPressurePlanId && !ENEMY_PRESSURE_PLAN_BY_ID[request.enemyPressurePlanId]) {
    errors.push(`Battle launch request references missing enemy pressure plan ${request.enemyPressurePlanId}.`);
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
        modifiers: request.modifiers ?? [],
        aiPersonalityId: request.aiPersonalityId ?? DEFAULT_AI_PERSONALITY_ID,
        enemyHeroId: request.enemyHeroId,
        enemyPressurePlanId: request.enemyPressurePlanId,
        retinueUnits: sanitizeLaunchRetinueUnits(request.retinueUnits),
        retinueReserveUnits: sanitizeLaunchRetinueUnits(request.retinueReserveUnits),
        rewardsDisabled: request.rewardsDisabled
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

function sanitizeLaunchRetinueUnits(value: unknown): RetinueUnitSaveData[] {
  if (!Array.isArray(value)) {
    return [];
  }
  const seen = new Set<string>();
  return value
    .filter((unit): unit is RetinueUnitSaveData => {
      const entry = unit as Partial<RetinueUnitSaveData>;
      if (
        typeof unit !== "object" ||
        unit === null ||
        typeof entry.retinueUnitId !== "string" ||
        typeof entry.unitTypeId !== "string" ||
        !UNIT_BY_ID[entry.unitTypeId] ||
        !isRetinueEligibleUnitTypeId(entry.unitTypeId) ||
        !isUnitVeterancyRankId(entry.rank) ||
        seen.has(entry.retinueUnitId)
      ) {
        return false;
      }
      seen.add(entry.retinueUnitId);
      return true;
    })
    .map((unit) => ({ ...unit }));
}
