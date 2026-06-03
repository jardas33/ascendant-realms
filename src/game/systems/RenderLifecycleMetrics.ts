export interface RenderLifecycleCounters {
  frames: number;
  graphicsCreated: number;
  graphicsDestroyed: number;
  spritesCreated: number;
  spritesDestroyed: number;
  textObjectsCreated: number;
  textObjectsDestroyed: number;
  domNodesCreated: number;
  domNodesDestroyed: number;
  geometryRebuilds: number;
  terrainRedraws: number;
  fogRedraws: number;
  ringRedraws: number;
  lumeRedraws: number;
  commandMarkerRedraws: number;
  labelLayouts: number;
  healthBarUpdates: number;
  minimapSnapshots: number;
  hudViewModels: number;
  domPatches: number;
  notificationPatches: number;
  retainedObjectCount: number;
  detachedDomNodes: number;
  memoryUsedMb?: number;
}

export type RenderLifecycleCounterDelta = Partial<RenderLifecycleCounters>;
export type RenderLifecycleMetricsRecorder = (delta: RenderLifecycleCounterDelta) => void;

let activeRecorder: RenderLifecycleMetricsRecorder | undefined;

const NUMERIC_RENDER_LIFECYCLE_COUNTER_KEYS = [
  "frames",
  "graphicsCreated",
  "graphicsDestroyed",
  "spritesCreated",
  "spritesDestroyed",
  "textObjectsCreated",
  "textObjectsDestroyed",
  "domNodesCreated",
  "domNodesDestroyed",
  "geometryRebuilds",
  "terrainRedraws",
  "fogRedraws",
  "ringRedraws",
  "lumeRedraws",
  "commandMarkerRedraws",
  "labelLayouts",
  "healthBarUpdates",
  "minimapSnapshots",
  "hudViewModels",
  "domPatches",
  "notificationPatches",
  "retainedObjectCount",
  "detachedDomNodes"
] as const satisfies ReadonlyArray<Exclude<keyof RenderLifecycleCounters, "memoryUsedMb">>;

const RENDER_LIFECYCLE_RATE_KEYS = NUMERIC_RENDER_LIFECYCLE_COUNTER_KEYS.filter(
  (key): key is Exclude<(typeof NUMERIC_RENDER_LIFECYCLE_COUNTER_KEYS)[number], "retainedObjectCount" | "detachedDomNodes"> =>
    key !== "retainedObjectCount" && key !== "detachedDomNodes"
);

export function createEmptyRenderLifecycleCounters(): RenderLifecycleCounters {
  return {
    frames: 0,
    graphicsCreated: 0,
    graphicsDestroyed: 0,
    spritesCreated: 0,
    spritesDestroyed: 0,
    textObjectsCreated: 0,
    textObjectsDestroyed: 0,
    domNodesCreated: 0,
    domNodesDestroyed: 0,
    geometryRebuilds: 0,
    terrainRedraws: 0,
    fogRedraws: 0,
    ringRedraws: 0,
    lumeRedraws: 0,
    commandMarkerRedraws: 0,
    labelLayouts: 0,
    healthBarUpdates: 0,
    minimapSnapshots: 0,
    hudViewModels: 0,
    domPatches: 0,
    notificationPatches: 0,
    retainedObjectCount: 0,
    detachedDomNodes: 0
  };
}

export function addRenderLifecycleCounters(
  target: RenderLifecycleCounters,
  delta: RenderLifecycleCounterDelta
): RenderLifecycleCounters {
  for (const key of NUMERIC_RENDER_LIFECYCLE_COUNTER_KEYS) {
    target[key] += delta[key] ?? 0;
  }
  if (delta.memoryUsedMb !== undefined) {
    target.memoryUsedMb = delta.memoryUsedMb;
  }
  return target;
}

export function cloneRenderLifecycleCounters(counters: RenderLifecycleCounters): RenderLifecycleCounters {
  return { ...createEmptyRenderLifecycleCounters(), ...counters };
}

export function setActiveRenderLifecycleMetricsRecorder(recorder?: RenderLifecycleMetricsRecorder): void {
  activeRecorder = recorder;
}

export function recordRenderLifecycleMetrics(delta: RenderLifecycleCounterDelta): void {
  activeRecorder?.(delta);
}

export function renderLifecycleRatesPerSecond(
  counters: RenderLifecycleCounters,
  sampleMs: number
): Omit<RenderLifecycleCounters, "retainedObjectCount" | "detachedDomNodes" | "memoryUsedMb"> {
  const seconds = Math.max(0.001, sampleMs / 1000);
  const rates = {} as Omit<RenderLifecycleCounters, "retainedObjectCount" | "detachedDomNodes" | "memoryUsedMb">;
  for (const key of RENDER_LIFECYCLE_RATE_KEYS) {
    rates[key] = roundMetric(counters[key] / seconds);
  }
  return rates;
}

function roundMetric(value: number): number {
  return Number((Number.isFinite(value) ? value : 0).toFixed(2));
}
