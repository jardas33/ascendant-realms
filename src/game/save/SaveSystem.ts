import { SAVE_KEY } from "../core/Constants";
import {
  createCurrentStoredGameSave,
  createFallbackCampaignSave,
  createFallbackHeroSave
} from "./SaveDefaults";
import { parseSaveJson, stringifySaveJson } from "./SaveImportExport";
import { normalizeCampaignSaveData, normalizeHeroSaveData } from "./SaveNormalization";
import type { CampaignSaveData, CurrentStoredGameSave, HeroSaveData, SaveSettingsData } from "./SaveTypes";

export { CURRENT_SAVE_VERSION, createFallbackCampaignSave, createFallbackHeroSave } from "./SaveDefaults";
export { parseSaveJson, stringifySaveJson } from "./SaveImportExport";
export { migrateSaveToCurrent, migrateV1ToV2 } from "./SaveMigrations";
export {
  isCampaignSaveData,
  isHeroSaveData,
  normalizeCampaignSaveData,
  normalizeHeroSaveData
} from "./SaveNormalization";

// Public save facade. Storage IO stays here; migrations, defaults, and normalization live in focused modules.
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

  static clear(): void {
    removeRawSave();
  }

  static reset(): void {
    SaveSystem.clear();
  }

  static exportSaveJson(): string | null {
    const save = SaveSystem.load();
    return save ? stringifySaveJson(save, 2) : null;
  }

  static importSaveJson(raw: string): boolean {
    const save = parseSaveJson(raw);
    if (!save) {
      return false;
    }
    return writeCurrentSave(save);
  }
}

function writeCurrentSave(save: CurrentStoredGameSave): boolean {
  return writeRawSave(stringifySaveJson(save));
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
