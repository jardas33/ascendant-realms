import type { BattleDifficulty, EquipmentSlot, HeroPrimaryStats, ItemInstance, ResourceBag } from "../core/GameTypes";

export type EquipmentSlots = Partial<Record<EquipmentSlot, string>>;
export type AllocatedSkills = Record<string, number>;

export interface HeroSaveData {
  heroName: string;
  classId: string;
  originId: string;
  level: number;
  xp: number;
  skillPoints: number;
  unlockedAbilities: string[];
  completedBattles: number;
  clearedMapIds: string[];
  inventory: ItemInstance[];
  equipment: EquipmentSlots;
  allocatedSkills: AllocatedSkills;
  /**
   * Older prototype saves used `items`.
   * New saves write `inventory`, but the loader still accepts this field for migration.
   */
  items?: string[];
  factionReputation: Record<string, number>;
  stats: HeroPrimaryStats;
}

export interface StoredGameSaveV1 {
  version: 1;
  hero: HeroSaveData;
  campaign: CampaignSaveData;
  createdAt?: string;
  updatedAt?: string;
}

// Placeholder for future audio, display, accessibility, and gameplay preferences.
export type SaveSettingsData = Record<string, unknown>;

// Placeholder for future account-wide and campaign-wide analytics.
export type SaveStatisticsData = Record<string, unknown>;

export interface StoredGameSaveV2 {
  version: 2;
  createdAt: string;
  updatedAt: string;
  hero: HeroSaveData;
  campaign: CampaignSaveData;
  settings: SaveSettingsData;
  statistics: SaveStatisticsData;
}

export type CurrentStoredGameSave = StoredGameSaveV2;
export type StoredGameSave = CurrentStoredGameSave;

export interface CampaignSaveData {
  started: boolean;
  difficulty: BattleDifficulty;
  resources: ResourceBag;
  resourcesSpent: ResourceBag;
  completedNodeIds: string[];
  unlockedNodeIds: string[];
  lockedNodeIds: string[];
  nodeRewardsClaimedIds: string[];
  choiceIdsClaimed: string[];
  townServiceClaimedIds: string[];
  townServiceUseCounts: Record<string, number>;
  activeModifierIds: string[];
  selectedNodeId?: string;
}
