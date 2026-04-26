import { SAVE_KEY } from "./Constants";
import type { BattleDifficulty, EquipmentSlot, ItemInstance, ResourceBag, ResourceKey } from "./GameTypes";
import { DEFAULT_SETTINGS, normalizeSettingsData } from "./Settings";
import { isCampaignModifierId } from "../data/campaignModifiers";
import type {
  AllocatedSkills,
  CampaignSaveData,
  CurrentStoredGameSave,
  EquipmentSlots,
  HeroSaveData,
  SaveSettingsData
} from "../save/SaveTypes";

export const CURRENT_SAVE_VERSION = 2;

export class SaveSystem {
  static hasSave(): boolean {
    const save = SaveSystem.load();
    return Boolean(save && !SaveSystem.isSettingsOnlySave(save));
  }

  static isSettingsOnlySave(save: CurrentStoredGameSave | null | undefined): boolean {
    return Boolean(save?.statistics.settingsOnly === true);
  }

  static load(): CurrentStoredGameSave | null {
    const raw = readRawSave();
    if (!raw) {
      return null;
    }

    return parseSaveJson(raw);
  }

  static saveHero(hero: HeroSaveData): boolean {
    const normalizedHero = normalizeHeroSaveData(hero);
    if (!normalizedHero) {
      console.warn("Ascendant Realms save skipped because hero data was invalid.");
      return false;
    }
    const existing = SaveSystem.load();
    return writeCurrentSave(
      createCurrentStoredGameSave({
        hero: normalizedHero,
        campaign: existing?.campaign ?? createFallbackCampaignSave(),
        previousSave: existing
      })
    );
  }

  static saveGame(hero: HeroSaveData, campaign: CampaignSaveData): boolean {
    const normalizedHero = normalizeHeroSaveData(hero);
    const normalizedCampaign = normalizeCampaignSaveData(campaign);
    if (!normalizedHero || !normalizedCampaign) {
      console.warn("Ascendant Realms save skipped because game data was invalid.");
      return false;
    }
    return writeCurrentSave(
      createCurrentStoredGameSave({
        hero: normalizedHero,
        campaign: normalizedCampaign,
        previousSave: SaveSystem.load()
      })
    );
  }

  static saveCampaign(campaign: CampaignSaveData, heroOverride?: HeroSaveData): boolean {
    const existing = SaveSystem.load();
    const hero = heroOverride ?? existing?.hero;
    if (!hero) {
      return false;
    }
    return SaveSystem.saveGame(hero, campaign);
  }

  static saveSettings(settings: SaveSettingsData): boolean {
    const existing = SaveSystem.load();
    return writeCurrentSave(
      createCurrentStoredGameSave({
        hero: existing?.hero ?? createFallbackHeroSave(),
        campaign: existing?.campaign ?? createFallbackCampaignSave(),
        previousSave: existing,
        settings,
        settingsOnly: !existing || SaveSystem.isSettingsOnlySave(existing)
      })
    );
  }

  static reset(): void {
    removeRawSave();
  }

  static exportSaveJson(): string | null {
    const save = SaveSystem.load();
    return save ? JSON.stringify(save, null, 2) : null;
  }

  static importSaveJson(raw: string): boolean {
    const save = parseSaveJson(raw);
    if (!save) {
      return false;
    }
    return writeCurrentSave(save);
  }
}

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

export function isHeroSaveData(value: unknown): value is HeroSaveData {
  return normalizeHeroSaveData(value) !== null;
}

export function isCampaignSaveData(value: unknown): value is CampaignSaveData {
  return normalizeCampaignSaveData(value) !== null;
}

function parseSaveJson(raw: string): CurrentStoredGameSave | null {
  try {
    return migrateSaveToCurrent(JSON.parse(raw));
  } catch {
    return null;
  }
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

function createCurrentStoredGameSave(options: {
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

function writeCurrentSave(save: CurrentStoredGameSave): boolean {
  return writeRawSave(JSON.stringify(save));
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
    isRecord(value.stats) &&
    isFiniteNumber(value.stats.might) &&
    isFiniteNumber(value.stats.command) &&
    isFiniteNumber(value.stats.arcana) &&
    isFiniteNumber(value.stats.faith);

  if (!hasValidBase) {
    return null;
  }

  const stats = value.stats as { might: number; command: number; arcana: number; faith: number };
  const factionReputationSource = isRecord(value.factionReputation) ? value.factionReputation : {};
  if (!Object.values(factionReputationSource).every(isFiniteNumber)) {
    return null;
  }
  const unlockedAbilities = value.unlockedAbilities as string[];
  const inventory = normalizeInventoryInstances(value.inventory, value.items);
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
      if (!isEquipmentSlot(slot) || typeof itemId !== "string") {
        return;
      }
      const equippedInstance = inventory.find((instance) => instance.instanceId === itemId) ?? inventory.find((instance) => instance.itemId === itemId);
      if (equippedInstance) {
        equipment[slot] = equippedInstance.instanceId;
        return;
      }
      const fallbackInstance = createMigratedItemInstance(itemId, inventory.length, "legacy_equipped");
      inventory.push(fallbackInstance);
      equipment[slot] = fallbackInstance.instanceId;
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
    inventory: dedupeItemInstances(inventory),
    equipment,
    allocatedSkills,
    factionReputation: normalizeFactionReputation(factionReputationSource as Record<string, number>),
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
  const lockedNodeIds = arrayOfStrings(value.lockedNodeIds) ? value.lockedNodeIds : [];
  const nodeRewardsClaimedIds = arrayOfStrings(value.nodeRewardsClaimedIds) ? value.nodeRewardsClaimedIds : [];
  const choiceIdsClaimed = arrayOfStrings(value.choiceIdsClaimed) ? value.choiceIdsClaimed : [];
  const townServiceClaimedIds = arrayOfStrings(value.townServiceClaimedIds) ? value.townServiceClaimedIds : [];
  const activeModifierIds = arrayOfStrings(value.activeModifierIds) ? value.activeModifierIds.filter(isCampaignModifierId) : [];
  return {
    started: value.started,
    difficulty,
    resources: normalizeResourceBag(value.resources),
    resourcesSpent: normalizeResourceBag(value.resourcesSpent),
    completedNodeIds: [...new Set(completedNodeIds)],
    unlockedNodeIds: [...new Set(unlockedNodeIds)],
    lockedNodeIds: [...new Set(lockedNodeIds)],
    nodeRewardsClaimedIds: [...new Set(nodeRewardsClaimedIds)],
    choiceIdsClaimed: [...new Set(choiceIdsClaimed)],
    townServiceClaimedIds: [...new Set(townServiceClaimedIds)],
    townServiceUseCounts: normalizeStringNumberRecord(value.townServiceUseCounts),
    activeModifierIds: [...new Set(activeModifierIds)],
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

function clampNumberRange(value: unknown, min: number, max: number): number {
  return Math.min(max, Math.max(min, isFiniteNumber(value) ? value : min));
}

function arrayOfStrings(value: unknown): value is string[] {
  return Array.isArray(value) && value.every((entry) => typeof entry === "string");
}

function isEquipmentSlot(value: string): value is EquipmentSlot {
  return value === "weapon" || value === "armor" || value === "trinket" || value === "relic";
}

function normalizeInventoryInstances(inventoryValue: unknown, legacyItemsValue: unknown): ItemInstance[] {
  const source = Array.isArray(inventoryValue) ? inventoryValue : arrayOfStrings(legacyItemsValue) ? legacyItemsValue : [];
  return source
    .map((entry, index) => normalizeItemInstance(entry, index))
    .filter((entry): entry is ItemInstance => entry !== undefined);
}

function normalizeItemInstance(value: unknown, index: number): ItemInstance | undefined {
  if (typeof value === "string") {
    return createMigratedItemInstance(value, index, "legacy_inventory");
  }
  if (!isRecord(value) || typeof value.instanceId !== "string" || typeof value.itemId !== "string" || !value.instanceId.trim() || !value.itemId.trim()) {
    return undefined;
  }
  const acquiredAt = typeof value.acquiredAt === "string" ? value.acquiredAt : new Date().toISOString();
  const source = typeof value.source === "string" && value.source.trim() ? value.source : "unknown";
  return {
    instanceId: value.instanceId,
    itemId: value.itemId,
    acquiredAt,
    source,
    affixes: arrayOfStrings(value.affixes) ? [...new Set(value.affixes)] : [],
    locked: typeof value.locked === "boolean" ? value.locked : false,
    favorite: typeof value.favorite === "boolean" ? value.favorite : false
  };
}

function createMigratedItemInstance(itemId: string, index: number, source: string): ItemInstance {
  return {
    instanceId: `${source}:${sanitizeItemInstanceId(itemId)}:${index + 1}`,
    itemId,
    acquiredAt: new Date().toISOString(),
    source,
    affixes: [],
    locked: false,
    favorite: false
  };
}

function dedupeItemInstances(inventory: ItemInstance[]): ItemInstance[] {
  const seen = new Set<string>();
  return inventory.filter((instance) => {
    if (seen.has(instance.instanceId)) {
      return false;
    }
    seen.add(instance.instanceId);
    return true;
  });
}

function sanitizeItemInstanceId(value: string): string {
  return value.replace(/[^a-zA-Z0-9_-]/g, "_");
}

const RESOURCE_KEYS: ResourceKey[] = ["crowns", "stone", "iron", "aether"];
const DEFAULT_FACTION_REPUTATION: Record<string, number> = {
  free_marches: 10,
  ashen_covenant: -10,
  sylvan_concord: 0,
  common_folk: 0,
  old_faith: 0
};

function normalizeResourceBag(value: unknown): ResourceBag {
  const source = isRecord(value) ? value : {};
  return Object.fromEntries(
    RESOURCE_KEYS.map((resource) => [resource, clampInteger(source[resource], 0)])
  ) as ResourceBag;
}

function normalizeFactionReputation(value: Record<string, number>): Record<string, number> {
  const reputation = { ...DEFAULT_FACTION_REPUTATION };
  Object.entries(value).forEach(([factionId, amount]) => {
    reputation[factionId] = Math.round(clampNumberRange(amount, -100, 100));
  });
  return reputation;
}

function normalizeStringNumberRecord(value: unknown): Record<string, number> {
  if (!isRecord(value)) {
    return {};
  }
  return Object.entries(value).reduce<Record<string, number>>((normalized, [key, amount]) => {
    if (key.trim() && isFiniteNumber(amount) && amount > 0) {
      normalized[key] = Math.floor(amount);
    }
    return normalized;
  }, {});
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
    activeModifierIds: []
  };
}
