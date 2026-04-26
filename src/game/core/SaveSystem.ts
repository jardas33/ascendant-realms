import { SAVE_KEY } from "./Constants";
import type { BattleDifficulty } from "./GameTypes";
import type { AllocatedSkills, CampaignSaveData, EquipmentSlots, HeroSaveData, StoredGameSave } from "../save/SaveTypes";

export class SaveSystem {
  static hasSave(): boolean {
    return SaveSystem.load() !== null;
  }

  static load(): StoredGameSave | null {
    const raw = readRawSave();
    if (!raw) {
      return null;
    }

    try {
      const parsed = JSON.parse(raw) as StoredGameSave;
      const hero = normalizeHeroSaveData(parsed.hero);
      if (parsed.version !== 1 || !hero) {
        return null;
      }
      return {
        ...parsed,
        hero,
        campaign: normalizeCampaignSaveData(parsed.campaign) ?? createFallbackCampaignSave()
      };
    } catch {
      return null;
    }
  }

  static saveHero(hero: HeroSaveData): boolean {
    const normalizedHero = normalizeHeroSaveData(hero);
    if (!normalizedHero) {
      console.warn("Ascendant Realms save skipped because hero data was invalid.");
      return false;
    }
    const save: StoredGameSave = {
      version: 1,
      hero: normalizedHero,
      campaign: SaveSystem.load()?.campaign ?? createFallbackCampaignSave(),
      updatedAt: new Date().toISOString()
    };
    return writeRawSave(JSON.stringify(save));
  }

  static saveGame(hero: HeroSaveData, campaign: CampaignSaveData): boolean {
    const normalizedHero = normalizeHeroSaveData(hero);
    const normalizedCampaign = normalizeCampaignSaveData(campaign);
    if (!normalizedHero || !normalizedCampaign) {
      console.warn("Ascendant Realms save skipped because game data was invalid.");
      return false;
    }
    const save: StoredGameSave = {
      version: 1,
      hero: normalizedHero,
      campaign: normalizedCampaign,
      updatedAt: new Date().toISOString()
    };
    return writeRawSave(JSON.stringify(save));
  }

  static saveCampaign(campaign: CampaignSaveData, heroOverride?: HeroSaveData): boolean {
    const existing = SaveSystem.load();
    const hero = heroOverride ?? existing?.hero;
    if (!hero) {
      return false;
    }
    return SaveSystem.saveGame(hero, campaign);
  }

  static reset(): void {
    removeRawSave();
  }
}

export function isHeroSaveData(value: unknown): value is HeroSaveData {
  return normalizeHeroSaveData(value) !== null;
}

export function isCampaignSaveData(value: unknown): value is CampaignSaveData {
  return normalizeCampaignSaveData(value) !== null;
}

export function normalizeHeroSaveData(value: unknown): HeroSaveData | null {
  if (!isRecord(value)) {
    return null;
  }
  const hasValidBase =
    typeof value.heroName === "string" &&
    typeof value.classId === "string" &&
    typeof value.originId === "string" &&
    isFiniteNumber(value.level) &&
    isFiniteNumber(value.xp) &&
    isFiniteNumber(value.skillPoints) &&
    Array.isArray(value.unlockedAbilities) &&
    value.unlockedAbilities.every((entry) => typeof entry === "string") &&
    isFiniteNumber(value.completedBattles) &&
    isRecord(value.factionReputation) &&
    Object.values(value.factionReputation).every(isFiniteNumber) &&
    isRecord(value.stats) &&
    isFiniteNumber(value.stats.might) &&
    isFiniteNumber(value.stats.command) &&
    isFiniteNumber(value.stats.arcana) &&
    isFiniteNumber(value.stats.faith);

  if (!hasValidBase) {
    return null;
  }

  const stats = value.stats as { might: number; command: number; arcana: number; faith: number };
  const factionReputation = value.factionReputation as Record<string, number>;
  const unlockedAbilities = value.unlockedAbilities as string[];
  const inventory = arrayOfStrings(value.inventory) ? value.inventory : arrayOfStrings(value.items) ? value.items : [];
  const clearedMapIds = arrayOfStrings(value.clearedMapIds) ? value.clearedMapIds : [];
  const allocatedSkills: AllocatedSkills = {};
  if (isRecord(value.allocatedSkills)) {
    Object.entries(value.allocatedSkills).forEach(([skillId, rank]) => {
      if (isFiniteNumber(rank) && rank > 0) {
        allocatedSkills[skillId] = Math.floor(rank);
      }
    });
  }
  const equipment: EquipmentSlots = {};
  if (isRecord(value.equipment)) {
    Object.entries(value.equipment).forEach(([slot, itemId]) => {
      if ((slot === "weapon" || slot === "armor" || slot === "trinket" || slot === "relic") && typeof itemId === "string" && inventory.includes(itemId)) {
        equipment[slot] = itemId;
      }
    });
  }

  return {
    heroName: value.heroName as string,
    classId: value.classId as string,
    originId: value.originId as string,
    level: clampInteger(value.level, 1),
    xp: clampInteger(value.xp, 0),
    skillPoints: clampInteger(value.skillPoints, 0),
    unlockedAbilities: [...new Set(unlockedAbilities)],
    completedBattles: clampInteger(value.completedBattles, 0),
    clearedMapIds: [...new Set(clearedMapIds)],
    inventory: [...new Set(inventory)],
    equipment,
    allocatedSkills,
    factionReputation: { ...factionReputation },
    stats: {
      might: clampNumber(stats.might, 0),
      command: clampNumber(stats.command, 0),
      arcana: clampNumber(stats.arcana, 0),
      faith: clampNumber(stats.faith, 0)
    }
  };
}

export function normalizeCampaignSaveData(value: unknown): CampaignSaveData | null {
  if (!isRecord(value)) {
    return null;
  }
  if (typeof value.started !== "boolean" || typeof value.difficulty !== "string") {
    return null;
  }
  if (!["story", "easy", "normal", "hard"].includes(value.difficulty)) {
    return null;
  }
  const difficulty = value.difficulty as BattleDifficulty;
  const completedNodeIds = arrayOfStrings(value.completedNodeIds) ? value.completedNodeIds : [];
  const unlockedNodeIds = arrayOfStrings(value.unlockedNodeIds) ? value.unlockedNodeIds : [];
  const nodeRewardsClaimedIds = arrayOfStrings(value.nodeRewardsClaimedIds) ? value.nodeRewardsClaimedIds : [];
  return {
    started: value.started,
    difficulty,
    completedNodeIds: [...new Set(completedNodeIds)],
    unlockedNodeIds: [...new Set(unlockedNodeIds)],
    nodeRewardsClaimedIds: [...new Set(nodeRewardsClaimedIds)],
    selectedNodeId: typeof value.selectedNodeId === "string" ? value.selectedNodeId : undefined
  };
}

function readRawSave(): string | null {
  try {
    return globalThis.localStorage?.getItem(SAVE_KEY) ?? null;
  } catch (error) {
    console.warn("Ascendant Realms could not read local save data.", error);
    return null;
  }
}

function writeRawSave(value: string): boolean {
  try {
    globalThis.localStorage?.setItem(SAVE_KEY, value);
    return true;
  } catch (error) {
    console.warn("Ascendant Realms could not write local save data.", error);
    return false;
  }
}

function removeRawSave(): void {
  try {
    globalThis.localStorage?.removeItem(SAVE_KEY);
  } catch (error) {
    console.warn("Ascendant Realms could not reset local save data.", error);
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function isFiniteNumber(value: unknown): value is number {
  return typeof value === "number" && Number.isFinite(value);
}

function clampInteger(value: unknown, min: number): number {
  return Math.max(min, Math.floor(isFiniteNumber(value) ? value : min));
}

function clampNumber(value: unknown, min: number): number {
  return Math.max(min, isFiniteNumber(value) ? value : min);
}

function arrayOfStrings(value: unknown): value is string[] {
  return Array.isArray(value) && value.every((entry) => typeof entry === "string");
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
    factionReputation: {
      free_marches: 10
    },
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
    completedNodeIds: [],
    unlockedNodeIds: [],
    nodeRewardsClaimedIds: []
  };
}
