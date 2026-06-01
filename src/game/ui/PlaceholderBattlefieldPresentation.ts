import type { EntityKind, Team } from "../core/GameTypes";

export type UnitPlaceholderSilhouette = "hero" | "worker" | "frontline" | "ranged" | "caster" | "commander";
export type BuildingPlaceholderSilhouette = "command" | "barracks" | "shrine" | "tower" | "utility";

export interface UnitPlaceholderPresentation {
  silhouette: UnitPlaceholderSilhouette;
  fillColor: number;
  strokeColor: number;
  accentColor: number;
  bodyAlpha: number;
  strokeAlpha: number;
  labelVisibleByDefault: boolean;
}

export interface BuildingPlaceholderPresentation {
  silhouette: BuildingPlaceholderSilhouette;
  fillColor: number;
  strokeColor: number;
  accentColor: number;
  labelVisibleByDefault: boolean;
}

const PLAYER_STROKE = 0xdaf6c4;
const ENEMY_STROKE = 0xffa092;
const NEUTRAL_STROKE = 0xf0d978;

export function resolveUnitPlaceholderPresentation(options: {
  unitId: string;
  team: Team;
  kind: Extract<EntityKind, "unit" | "hero">;
  baseColor: number;
}): UnitPlaceholderPresentation {
  const silhouette = resolveUnitSilhouette(options.unitId, options.kind);
  const hostile = options.team === "enemy";
  const friendly = options.team === "player";
  return {
    silhouette,
    fillColor: options.baseColor,
    strokeColor: hostile ? ENEMY_STROKE : friendly ? PLAYER_STROKE : NEUTRAL_STROKE,
    accentColor: resolveUnitAccent(silhouette, options.team),
    bodyAlpha: hostile ? 0.98 : 0.96,
    strokeAlpha: hostile ? 0.94 : 0.9,
    labelVisibleByDefault:
      options.kind === "hero" ||
      silhouette === "commander" ||
      options.unitId === "enemy_commander" ||
      options.unitId === "wild_hound" ||
      options.unitId === "stone_imp"
  };
}

export function resolveBuildingPlaceholderPresentation(options: {
  buildingId: string;
  team: Team;
  baseColor: number;
}): BuildingPlaceholderPresentation {
  const silhouette = resolveBuildingSilhouette(options.buildingId);
  return {
    silhouette,
    fillColor: options.baseColor,
    strokeColor: options.team === "enemy" ? 0xff9b8f : 0xd8edc2,
    accentColor: resolveBuildingAccent(silhouette, options.team),
    labelVisibleByDefault: true
  };
}

function resolveUnitSilhouette(
  unitId: string,
  kind: Extract<EntityKind, "unit" | "hero">
): UnitPlaceholderSilhouette {
  if (kind === "hero") {
    return "hero";
  }
  if (unitId === "enemy_commander") {
    return "commander";
  }
  if (unitId === "worker") {
    return "worker";
  }
  if (unitId === "ranger" || unitId === "hexer") {
    return "ranged";
  }
  if (unitId === "acolyte") {
    return "caster";
  }
  return "frontline";
}

function resolveBuildingSilhouette(buildingId: string): BuildingPlaceholderSilhouette {
  if (buildingId === "command_hall" || buildingId === "enemy_stronghold") {
    return "command";
  }
  if (buildingId.includes("barracks")) {
    return "barracks";
  }
  if (buildingId.includes("mystic") || buildingId.includes("shrine")) {
    return "shrine";
  }
  if (buildingId.includes("watchtower")) {
    return "tower";
  }
  return "utility";
}

function resolveUnitAccent(silhouette: UnitPlaceholderSilhouette, team: Team): number {
  if (team === "enemy") {
    return silhouette === "caster" || silhouette === "commander" ? 0xff7b57 : 0xffc06a;
  }
  if (silhouette === "hero" || silhouette === "caster") {
    return 0x8ff6e5;
  }
  if (silhouette === "ranged") {
    return 0xf0d978;
  }
  return 0xb9f2a0;
}

function resolveBuildingAccent(silhouette: BuildingPlaceholderSilhouette, team: Team): number {
  if (team === "enemy") {
    return silhouette === "tower" ? 0xffc06a : 0xff7b57;
  }
  if (silhouette === "shrine") {
    return 0x8ff6e5;
  }
  if (silhouette === "tower") {
    return 0xf0d978;
  }
  return 0xb9f2a0;
}

