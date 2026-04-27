import { DEFAULT_SETTINGS, normalizeSettingsData } from "../core/Settings";
import { CURRENT_SAVE_VERSION, createFallbackCampaignSave } from "./SaveDefaults";
import { normalizeCampaignSaveData, normalizeHeroSaveData } from "./SaveNormalization";
import type { CurrentStoredGameSave } from "./SaveTypes";

export function migrateSaveToCurrent(input: unknown): CurrentStoredGameSave | null {
  if (!isRecord(input)) {
    return null;
  }
  if (input.version === 1) {
    return migrateV1ToV2(input);
  }
  if (input.version === CURRENT_SAVE_VERSION) {
    return normalizeStoredGameSaveV2(input);
  }
  return null;
}

export function migrateV1ToV2(input: unknown): CurrentStoredGameSave | null {
  if (!isRecord(input) || input.version !== 1) {
    return null;
  }
  const now = new Date().toISOString();
  const hero = normalizeHeroSaveData(input.hero);
  if (!hero) {
    return null;
  }
  return {
    version: CURRENT_SAVE_VERSION,
    createdAt: typeof input.createdAt === "string" ? input.createdAt : typeof input.updatedAt === "string" ? input.updatedAt : now,
    updatedAt: typeof input.updatedAt === "string" ? input.updatedAt : now,
    hero,
    campaign: normalizeCampaignSaveData(input.campaign) ?? createFallbackCampaignSave(),
    settings: DEFAULT_SETTINGS,
    statistics: {}
  };
}

function normalizeStoredGameSaveV2(input: unknown): CurrentStoredGameSave | null {
  if (!isRecord(input) || input.version !== CURRENT_SAVE_VERSION) {
    return null;
  }
  const now = new Date().toISOString();
  const hero = normalizeHeroSaveData(input.hero);
  if (!hero) {
    return null;
  }
  return {
    version: CURRENT_SAVE_VERSION,
    createdAt: typeof input.createdAt === "string" ? input.createdAt : now,
    updatedAt: typeof input.updatedAt === "string" ? input.updatedAt : now,
    hero,
    campaign: normalizeCampaignSaveData(input.campaign) ?? createFallbackCampaignSave(),
    settings: normalizeSettingsData(input.settings),
    statistics: isRecord(input.statistics) ? { ...input.statistics } : {}
  };
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}
