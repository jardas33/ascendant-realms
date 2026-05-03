import type {
  BattleDifficulty,
  CampaignChapterId,
  EquipmentSlot,
  HeroPrimaryStats,
  ItemInstance,
  ResourceBag,
  UnitVeterancyRankId
} from "../core/GameTypes";

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

export type FogEnabledOverride = "default" | "enabled" | "disabled";

export interface SaveSettingsData {
  masterVolume: number;
  musicVolume: number;
  sfxVolume: number;
  screenShakeEnabled: boolean;
  floatingTextEnabled: boolean;
  fogEnabledOverride: FogEnabledOverride;
  reducedMotionEnabled: boolean;
  uiScale: number;
  colorblindMinimapPalette: boolean;
}

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

export type RetinueUnitStatus = "active" | "wounded";

export interface RetinueUnitSaveData {
  retinueUnitId: string;
  unitTypeId: string;
  name?: string;
  rank: UnitVeterancyRankId;
  xp: number;
  kills: number;
  sourceBattleId: string;
  acquiredAt: string;
  status: RetinueUnitStatus;
}

export type RivalLastOutcome = "unseen" | "escaped" | "defeated" | "wounded" | "triumphant";
export type RivalDisposition = "wary" | "enraged" | "humiliated" | "emboldened";
export type RivalModifierId = "rival_wary_hp_5" | "rival_emboldened_damage_5";

export interface CampaignRivalSaveData {
  enemyHeroId: string;
  encounters: number;
  defeats: number;
  victoriesAgainstPlayer: number;
  lastEncounterNodeId?: string;
  lastOutcome: RivalLastOutcome;
  disposition: RivalDisposition;
  activeModifiers: RivalModifierId[];
  isKnownToPlayer: boolean;
}

export interface RivalTrophySaveData {
  trophyId: string;
  enemyHeroId: string;
  earnedAt: string;
  sourceNodeId: string;
  label: string;
  description: string;
  effect?: string;
}

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
  strongholdUpgradeRanks: Record<string, number>;
  retinueUnits: RetinueUnitSaveData[];
  rivals: CampaignRivalSaveData[];
  rivalTrophies: RivalTrophySaveData[];
  selectedChapterId: CampaignChapterId;
  selectedNodeId?: string;
}
