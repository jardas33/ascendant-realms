import type { Cost, Position, ResourceBag, TerrainZoneDefinition } from "./GameTypes";

export function distance(a: Position, b: Position): number {
  return Math.hypot(a.x - b.x, a.y - b.y);
}

export function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

export function normalizeVector(x: number, y: number): Position {
  const length = Math.hypot(x, y);
  if (length === 0) {
    return { x: 0, y: 0 };
  }
  return { x: x / length, y: y / length };
}

export function pointInRect(point: Position, rect: TerrainZoneDefinition): boolean {
  return (
    point.x >= rect.x &&
    point.x <= rect.x + rect.width &&
    point.y >= rect.y &&
    point.y <= rect.y + rect.height
  );
}

export function canAfford(resources: ResourceBag, cost: Cost): boolean {
  return (
    resources.crowns >= (cost.crowns ?? 0) &&
    resources.stone >= (cost.stone ?? 0) &&
    resources.iron >= (cost.iron ?? 0) &&
    resources.aether >= (cost.aether ?? 0)
  );
}

export function payCost(resources: ResourceBag, cost: Cost): boolean {
  if (!canAfford(resources, cost)) {
    return false;
  }
  resources.crowns -= cost.crowns ?? 0;
  resources.stone -= cost.stone ?? 0;
  resources.iron -= cost.iron ?? 0;
  resources.aether -= cost.aether ?? 0;
  return true;
}

export function addResources(resources: ResourceBag, add: Partial<ResourceBag>): void {
  resources.crowns += add.crowns ?? 0;
  resources.stone += add.stone ?? 0;
  resources.iron += add.iron ?? 0;
  resources.aether += add.aether ?? 0;
}

export function cloneResources(resources: ResourceBag): ResourceBag {
  return {
    crowns: resources.crowns,
    stone: resources.stone,
    iron: resources.iron,
    aether: resources.aether
  };
}

export function formatTime(totalSeconds: number): string {
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = Math.floor(totalSeconds % 60).toString().padStart(2, "0");
  return `${minutes}:${seconds}`;
}

export function formationOffset(index: number, spacing: number): Position {
  if (index === 0) {
    return { x: 0, y: 0 };
  }
  const ring = Math.ceil(Math.sqrt(index));
  const angle = index * 2.399963229728653;
  return {
    x: Math.cos(angle) * ring * spacing,
    y: Math.sin(angle) * ring * spacing
  };
}
