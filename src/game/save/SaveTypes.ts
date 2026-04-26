import type { BattleDifficulty, EquipmentSlot, HeroPrimaryStats, ResourceBag } from "../core/GameTypes";

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
  inventory: string[];
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

export interface StoredGameSave {
  version: number;
  hero: HeroSaveData;
  campaign: CampaignSaveData;
  updatedAt: string;
}

export interface CampaignSaveData {
  started: boolean;
  difficulty: BattleDifficulty;
  resources: ResourceBag;
  completedNodeIds: string[];
  unlockedNodeIds: string[];
  lockedNodeIds: string[];
  nodeRewardsClaimedIds: string[];
  choiceIdsClaimed: string[];
  activeModifierIds: string[];
  selectedNodeId?: string;
}
