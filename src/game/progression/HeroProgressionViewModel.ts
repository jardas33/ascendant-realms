import { heroPortraitAssetId } from "../assets/AssetKeys";
import type { HeroBaseStats, HeroClassDefinition, ItemDefinition, OriginDefinition, SkillNodeDefinition } from "../core/GameTypes";
import { calculateLiveHeroStats } from "../core/HeroProgressionRules";
import type { HeroSaveData } from "../save/SaveTypes";

export interface HeroProgressionCatalogs {
  heroClassById: Record<string, HeroClassDefinition>;
  originById: Record<string, OriginDefinition>;
  skillNodeById: Record<string, SkillNodeDefinition>;
  itemById: Record<string, ItemDefinition>;
}

export interface HeroProgressionViewModel {
  heroName: string;
  level: number;
  skillPoints: number;
  heroClass: HeroClassDefinition;
  origin: OriginDefinition;
  stats: HeroBaseStats;
  portraitId?: string;
  unlockedAbilities: string[];
}

export function createHeroProgressionViewModel(heroSave: HeroSaveData, catalogs: HeroProgressionCatalogs): HeroProgressionViewModel {
  const heroClass = resolveHeroClass(heroSave, catalogs);
  const origin = resolveOrigin(heroSave, catalogs);

  return {
    heroName: heroSave.heroName,
    level: heroSave.level,
    skillPoints: heroSave.skillPoints,
    heroClass,
    origin,
    stats: liveStatsFor(heroSave, catalogs),
    portraitId: heroPortraitAssetId(heroClass.id),
    unlockedAbilities: heroSave.unlockedAbilities
  };
}

export function liveStatsFor(save: HeroSaveData, catalogs: HeroProgressionCatalogs): HeroBaseStats {
  return calculateLiveHeroStats(save, resolveHeroClass(save, catalogs), resolveOrigin(save, catalogs), catalogs.skillNodeById, catalogs.itemById);
}

export function resolveHeroClass(save: HeroSaveData, catalogs: HeroProgressionCatalogs): HeroClassDefinition {
  return catalogs.heroClassById[save.classId] ?? firstRecordValue(catalogs.heroClassById);
}

export function resolveOrigin(save: HeroSaveData, catalogs: HeroProgressionCatalogs): OriginDefinition {
  return catalogs.originById[save.originId] ?? firstRecordValue(catalogs.originById);
}

function firstRecordValue<T>(record: Record<string, T>): T {
  const first = Object.values(record)[0];
  if (!first) {
    throw new Error("Progression catalog is empty.");
  }
  return first;
}
