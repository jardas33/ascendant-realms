export interface SpatialQueryCounters {
  frames: number;
  pathRequests: number;
  pathCacheHits: number;
  pathCacheMisses: number;
  duplicatePathRequests: number;
  unchangedDestinationReuses: number;
  entityListRebuilds: number;
  entityListEntries: number;
  entityIdLookups: number;
  entityIdLookupHits: number;
  entityIdLookupMisses: number;
  targetAcquisitionScans: number;
  immediateMeleeScans: number;
  entitiesVisited: number;
  distanceCalculations: number;
}

export type SpatialQueryCounterDelta = Partial<SpatialQueryCounters>;
export type SpatialQueryMetricsRecorder = (delta: SpatialQueryCounterDelta) => void;

export interface SpatialNearestMetrics {
  entitiesVisited: number;
  distanceCalculations: number;
}

export function createEmptySpatialQueryCounters(): SpatialQueryCounters {
  return {
    frames: 0,
    pathRequests: 0,
    pathCacheHits: 0,
    pathCacheMisses: 0,
    duplicatePathRequests: 0,
    unchangedDestinationReuses: 0,
    entityListRebuilds: 0,
    entityListEntries: 0,
    entityIdLookups: 0,
    entityIdLookupHits: 0,
    entityIdLookupMisses: 0,
    targetAcquisitionScans: 0,
    immediateMeleeScans: 0,
    entitiesVisited: 0,
    distanceCalculations: 0
  };
}

export function addSpatialQueryCounters(target: SpatialQueryCounters, delta: SpatialQueryCounterDelta): void {
  for (const key of Object.keys(delta) as Array<keyof SpatialQueryCounters>) {
    target[key] += delta[key] ?? 0;
  }
}

export function cloneSpatialQueryCounters(counters: SpatialQueryCounters): SpatialQueryCounters {
  return { ...counters };
}
