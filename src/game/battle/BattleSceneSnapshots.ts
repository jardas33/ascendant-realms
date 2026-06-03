import Phaser from "phaser";
import type { BattleMapDefinition, ResourceKey } from "../core/GameTypes";
import { Building } from "../entities/Building";
import { CaptureSite } from "../entities/CaptureSite";
import { Hero } from "../entities/Hero";
import { Unit } from "../entities/Unit";
import { isEntityVisibleToPlayer, type FogOfWarSystem } from "../systems/FogOfWarSystem";
import type { MinimapPing, MinimapSnapshot } from "../ui/MinimapView";

interface BattleMinimapSnapshotOptions {
  activeMap: BattleMapDefinition;
  camera: Phaser.Cameras.Scene2D.Camera;
  captureSites: CaptureSite[];
  buildings: Building[];
  units: Unit[];
  hero: Hero;
  selectedRallyBuildings: Building[];
  fogOfWar?: FogOfWarSystem;
  fogEnabled: boolean;
  colorblindPalette?: boolean;
  pings: MinimapPing[];
  isPointExploredByPlayer: (point: { x: number; y: number }) => boolean;
  resourceColor: (resource: ResourceKey) => string;
}

export function createBattleMinimapSnapshot(options: BattleMinimapSnapshotOptions): MinimapSnapshot {
  const {
    activeMap,
    camera,
    captureSites,
    buildings,
    units,
    hero,
    selectedRallyBuildings,
    fogOfWar,
    fogEnabled,
    colorblindPalette,
    pings,
    isPointExploredByPlayer,
    resourceColor
  } = options;
  const cameraWidth = Math.min(activeMap.width, camera.width / camera.zoom);
  const cameraHeight = Math.min(activeMap.height, camera.height / camera.zoom);
  const objectiveSiteIds = new Set<string>();
  for (const objective of activeMap.scenario.objectives.secondaryObjectives ?? []) {
    if (objective.type === "capture_site") {
      objectiveSiteIds.add(objective.targetId);
    }
  }
  const markers: MinimapSnapshot["markers"] = [];

  for (const site of captureSites) {
    if (!isPointExploredByPlayer(site.position)) {
      continue;
    }
    markers.push({
      id: site.id,
      kind: "capture-site",
      team: site.owner,
      x: site.position.x,
      y: site.position.y,
      resource: site.definition.resource,
      resourceColor: resourceColor(site.definition.resource),
      isObjective: objectiveSiteIds.has(site.definition.id)
    });
  }

  for (const camp of activeMap.neutralCamps) {
    if (!isPointExploredByPlayer(camp) || !hasLiveNeutralCampUnit(camp, units)) {
      continue;
    }
    markers.push({
      id: camp.id,
      kind: "camp",
      team: "neutral",
      x: camp.x,
      y: camp.y,
      size: 2.5
    });
  }

  for (const building of buildings) {
    if (!building.alive || !isEntityVisibleToPlayer(building, fogOfWar!, fogEnabled)) {
      continue;
    }
    markers.push({
      id: building.id,
      kind: "building",
      team: building.team,
      x: building.position.x,
      y: building.position.y,
      size: Math.max(2.8, Math.min(5, Math.max(building.definition.size.width, building.definition.size.height) / 38))
    });
  }

  for (const unit of units) {
    if (!unit.alive || !isEntityVisibleToPlayer(unit, fogOfWar!, fogEnabled)) {
      continue;
    }
    markers.push({
      id: unit.id,
      kind: unit.enemyHeroId ? "enemy-hero" : "unit",
      team: unit.team,
      x: unit.position.x,
      y: unit.position.y,
      size: unit.enemyHeroId ? 2.6 : unit === hero ? 2.1 : 1.35
    });
  }

  for (const building of selectedRallyBuildings) {
    if (!building.rallyPoint) {
      continue;
    }
    markers.push({
      id: `rally-${building.id}`,
      kind: "rally",
      team: "player",
      x: building.rallyPoint.x,
      y: building.rallyPoint.y,
      size: 2.3
    });
  }

  return {
    mapWidth: activeMap.width,
    mapHeight: activeMap.height,
    markers,
    camera: {
      x: Phaser.Math.Clamp(camera.scrollX, 0, activeMap.width - cameraWidth),
      y: Phaser.Math.Clamp(camera.scrollY, 0, activeMap.height - cameraHeight),
      width: cameraWidth,
      height: cameraHeight
    },
    pings,
    colorblindPalette: Boolean(colorblindPalette),
    fog: {
      enabled: fogEnabled,
      cells: fogEnabled ? fogOfWar?.cells() : undefined
    }
  };
}

function hasLiveNeutralCampUnit(camp: { x: number; y: number }, units: Unit[]): boolean {
  for (const unit of units) {
    if (
      unit.alive &&
      unit.team === "neutral" &&
      Phaser.Math.Distance.Between(unit.position.x, unit.position.y, camp.x, camp.y) <= 150
    ) {
      return true;
    }
  }
  return false;
}
