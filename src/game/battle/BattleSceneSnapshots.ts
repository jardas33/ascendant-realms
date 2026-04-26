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
  const markers: MinimapSnapshot["markers"] = [
    ...captureSites
      .filter((site) => isPointExploredByPlayer(site.position))
      .map((site) => ({
        id: site.id,
        kind: "capture-site" as const,
        team: site.owner,
        x: site.position.x,
        y: site.position.y,
        resource: site.definition.resource,
        resourceColor: resourceColor(site.definition.resource)
      })),
    ...activeMap.neutralCamps
      .filter((camp) =>
        isPointExploredByPlayer(camp) &&
        units.some(
          (unit) =>
            unit.alive &&
            unit.team === "neutral" &&
            Phaser.Math.Distance.Between(unit.position.x, unit.position.y, camp.x, camp.y) <= 150
        )
      )
      .map((camp) => ({
        id: camp.id,
        kind: "camp" as const,
        team: "neutral" as const,
        x: camp.x,
        y: camp.y,
        size: 2.5
      })),
    ...buildings
      .filter((building) => building.alive && isEntityVisibleToPlayer(building, fogOfWar!, fogEnabled))
      .map((building) => ({
        id: building.id,
        kind: "building" as const,
        team: building.team,
        x: building.position.x,
        y: building.position.y,
        size: Math.max(2.8, Math.min(5, Math.max(building.definition.size.width, building.definition.size.height) / 38))
      })),
    ...units
      .filter((unit) => unit.alive && isEntityVisibleToPlayer(unit, fogOfWar!, fogEnabled))
      .map((unit) => ({
        id: unit.id,
        kind: "unit" as const,
        team: unit.team,
        x: unit.position.x,
        y: unit.position.y,
        size: unit === hero ? 2.1 : 1.35
      })),
    ...selectedRallyBuildings
      .filter((building) => building.rallyPoint)
      .map((building) => ({
        id: `rally-${building.id}`,
        kind: "rally" as const,
        team: "player" as const,
        x: building.rallyPoint?.x ?? building.position.x,
        y: building.rallyPoint?.y ?? building.position.y,
        size: 2.3
      }))
  ];

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
