import { BUILD_RADIUS_FROM_OWNED_BUILDING } from "../core/Constants";
import type { BattleMapDefinition, BuildingDefinition, Position, ResourceBag, Team } from "../core/GameTypes";
import { canAfford, distance } from "../core/MathUtils";

export interface PlacementBuildingSnapshot {
  alive: boolean;
  team: Team;
  position: Position;
  radius: number;
}

export interface PlacementSiteSnapshot {
  position: Position;
  radius: number;
}

export type PlacementFailureReason =
  | "missing-resources"
  | "outside-map"
  | "blocked-terrain"
  | "not-buildable-terrain"
  | "too-far-from-owned-building"
  | "overlaps-building"
  | "overlaps-capture-site";

export interface PlacementResult {
  ok: boolean;
  reason?: PlacementFailureReason;
}

export function canPlaceBuilding(options: {
  point: Position;
  definition: BuildingDefinition;
  resources: ResourceBag;
  map: BattleMapDefinition;
  buildings: PlacementBuildingSnapshot[];
  captureSites: PlacementSiteSnapshot[];
  team: Team;
  buildRadius?: number;
}): PlacementResult {
  const halfWidth = options.definition.size.width / 2;
  const halfHeight = options.definition.size.height / 2;
  const footprint = {
    left: options.point.x - halfWidth,
    right: options.point.x + halfWidth,
    top: options.point.y - halfHeight,
    bottom: options.point.y + halfHeight
  };

  if (!canAfford(options.resources, options.definition.cost)) {
    return { ok: false, reason: "missing-resources" };
  }

  if (
    footprint.left < 0 ||
    footprint.top < 0 ||
    footprint.right > options.map.width ||
    footprint.bottom > options.map.height
  ) {
    return { ok: false, reason: "outside-map" };
  }

  const blocked = options.map.terrainZones.some(
    (zone) => (zone.type === "blocked" || zone.type === "water") && rectanglesOverlap(footprint, zone)
  );
  if (blocked) {
    return { ok: false, reason: "blocked-terrain" };
  }

  const buildable = options.map.terrainZones.some(
    (zone) => zone.type === "buildable" && rectangleContains(zone, footprint)
  );
  if (!buildable) {
    return { ok: false, reason: "not-buildable-terrain" };
  }

  const buildRadius = options.buildRadius ?? BUILD_RADIUS_FROM_OWNED_BUILDING;
  const nearOwnedBuilding = options.buildings.some(
    (building) => building.alive && building.team === options.team && distance(building.position, options.point) <= buildRadius
  );
  if (!nearOwnedBuilding) {
    return { ok: false, reason: "too-far-from-owned-building" };
  }

  const halfExtent = Math.max(options.definition.size.width, options.definition.size.height) / 2;
  const overlapsBuilding = options.buildings.some(
    (building) => building.alive && distance(building.position, options.point) < building.radius + halfExtent + 12
  );
  if (overlapsBuilding) {
    return { ok: false, reason: "overlaps-building" };
  }

  const overlapsSite = options.captureSites.some((site) => distance(site.position, options.point) < site.radius + halfExtent);
  if (overlapsSite) {
    return { ok: false, reason: "overlaps-capture-site" };
  }

  return { ok: true };
}

export function placementReasonText(reason: PlacementFailureReason | undefined): string {
  switch (reason) {
    case "missing-resources":
      return "Insufficient resources.";
    case "outside-map":
      return "Outside the battlefield.";
    case "blocked-terrain":
      return "Blocked terrain.";
    case "not-buildable-terrain":
      return "Not buildable terrain.";
    case "too-far-from-owned-building":
      return "Too far from an owned building.";
    case "overlaps-building":
      return "Overlaps another structure.";
    case "overlaps-capture-site":
      return "Overlaps a resource site.";
    default:
      return "Invalid building site.";
  }
}

function rectanglesOverlap(
  a: { left: number; right: number; top: number; bottom: number },
  b: { x: number; y: number; width: number; height: number }
): boolean {
  return a.left < b.x + b.width && a.right > b.x && a.top < b.y + b.height && a.bottom > b.y;
}

function rectangleContains(
  a: { x: number; y: number; width: number; height: number },
  b: { left: number; right: number; top: number; bottom: number }
): boolean {
  return b.left >= a.x && b.right <= a.x + a.width && b.top >= a.y && b.bottom <= a.y + a.height;
}
