import { normalizeSettingsData } from "../core/Settings";
import { DEFAULT_CAMPAIGN_CHAPTER_ID } from "../data/campaignChapters";
import type { CampaignSaveData, CurrentStoredGameSave, HeroSaveData, SaveSettingsData } from "./SaveTypes";

export const CURRENT_SAVE_VERSION = 2;

export const DEFAULT_FACTION_REPUTATION: Record<string, number> = {
  free_marches: 10,
  ashen_covenant: -10,
  sylvan_concord: 0,
  common_folk: 0,
  old_faith: 0
};

export function createCurrentStoredGameSave(options: {
  hero: HeroSaveData;
  campaign: CampaignSaveData;
  previousSave?: CurrentStoredGameSave | null;
  settings?: SaveSettingsData;
  settingsOnly?: boolean;
}): CurrentStoredGameSave {
  const now = new Date().toISOString();
  const statistics = { ...(options.previousSave?.statistics ?? {}) };
  if (options.settingsOnly) {
    statistics.settingsOnly = true;
  } else {
    delete statistics.settingsOnly;
  }
  return {
    version: CURRENT_SAVE_VERSION,
    createdAt: options.previousSave?.createdAt ?? now,
    updatedAt: now,
    hero: options.hero,
    campaign: options.campaign,
    settings: normalizeSettingsData(options.settings ?? options.previousSave?.settings),
    statistics
  };
}

export function createFallbackHeroSave(): HeroSaveData {
  return {
    heroName: "Aster",
    classId: "warlord",
    originId: "exiled_noble",
    level: 1,
    xp: 0,
    skillPoints: 0,
    unlockedAbilities: ["rally_banner"],
    completedBattles: 0,
    clearedMapIds: [],
    inventory: [],
    equipment: {},
    allocatedSkills: {},
    factionReputation: { ...DEFAULT_FACTION_REPUTATION },
    stats: {
      might: 8,
      command: 8,
      arcana: 2,
      faith: 3
    }
  };
}

export function createFallbackCampaignSave(): CampaignSaveData {
  return {
    started: false,
    difficulty: "easy",
    resources: {
      crowns: 0,
      stone: 0,
      iron: 0,
      aether: 0
    },
    resourcesSpent: {
      crowns: 0,
      stone: 0,
      iron: 0,
      aether: 0
    },
    completedNodeIds: [],
    unlockedNodeIds: [],
    lockedNodeIds: [],
    nodeRewardsClaimedIds: [],
    choiceIdsClaimed: [],
    townServiceClaimedIds: [],
    townServiceUseCounts: {},
    activeModifierIds: [],
    strongholdUpgradeRanks: {},
    retinueUnits: [],
    rivals: [],
    rivalTrophies: [],
    selectedChapterId: DEFAULT_CAMPAIGN_CHAPTER_ID
  };
}
