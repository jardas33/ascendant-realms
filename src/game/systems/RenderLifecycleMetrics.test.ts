import { describe, expect, it } from "vitest";
import {
  addRenderLifecycleCounters,
  cloneRenderLifecycleCounters,
  createEmptyRenderLifecycleCounters,
  renderLifecycleRatesPerSecond,
  setActiveRenderLifecycleMetricsRecorder,
  recordRenderLifecycleMetrics
} from "./RenderLifecycleMetrics";

describe("RenderLifecycleMetrics", () => {
  it("adds deltas and keeps memory as the latest snapshot value", () => {
    const counters = createEmptyRenderLifecycleCounters();

    addRenderLifecycleCounters(counters, {
      frames: 2,
      graphicsCreated: 3,
      domPatches: 4,
      memoryUsedMb: 100
    });
    addRenderLifecycleCounters(counters, {
      frames: 3,
      graphicsDestroyed: 1,
      domPatches: 2,
      memoryUsedMb: 96
    });

    expect(counters.frames).toBe(5);
    expect(counters.graphicsCreated).toBe(3);
    expect(counters.graphicsDestroyed).toBe(1);
    expect(counters.domPatches).toBe(6);
    expect(counters.memoryUsedMb).toBe(96);
  });

  it("computes rates while leaving retained and detached counts out of per-second counters", () => {
    const counters = createEmptyRenderLifecycleCounters();
    counters.frames = 120;
    counters.graphicsCreated = 4;
    counters.retainedObjectCount = 44;
    counters.detachedDomNodes = 2;

    const rates = renderLifecycleRatesPerSecond(counters, 2000);

    expect(rates.frames).toBe(60);
    expect(rates.graphicsCreated).toBe(2);
    expect("retainedObjectCount" in rates).toBe(false);
    expect("detachedDomNodes" in rates).toBe(false);
  });

  it("records through the active private recorder only", () => {
    const deltas: unknown[] = [];
    setActiveRenderLifecycleMetricsRecorder((delta) => deltas.push(delta));
    recordRenderLifecycleMetrics({ textObjectsCreated: 1 });
    setActiveRenderLifecycleMetricsRecorder(undefined);
    recordRenderLifecycleMetrics({ textObjectsCreated: 1 });

    expect(deltas).toEqual([{ textObjectsCreated: 1 }]);
    expect(cloneRenderLifecycleCounters(createEmptyRenderLifecycleCounters()).frames).toBe(0);
  });
});
