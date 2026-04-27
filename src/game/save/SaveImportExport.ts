import { migrateSaveToCurrent } from "./SaveMigrations";
import type { CurrentStoredGameSave } from "./SaveTypes";

export function parseSaveJson(raw: string): CurrentStoredGameSave | null {
  try {
    return migrateSaveToCurrent(JSON.parse(raw));
  } catch {
    return null;
  }
}

export function stringifySaveJson(save: CurrentStoredGameSave, space?: number): string {
  return JSON.stringify(save, null, space);
}
